From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [BUGS] [CHECKER] 99 synchronization bugs and a lock summary
 database
Date: Sat, 03 Jul 2004 17:03:24 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <874qopbjqr.fsf@devron.myhome.or.jp>
References: <20040702004956.448c95d9.akpm@osdl.org>
	<E1BgLql-00055X-00@gondolin.me.apana.org.au>
	<20040702123022.563ee931.akpm@osdl.org>
	<20040702125008.25e65252@dell_ss3.pdx.osdl.net>
	<87wu1l3aug.fsf@devron.myhome.or.jp>
	<20040703061320.GA24115@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, Andrew Morton <akpm@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040703061320.GA24115@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:

> > +static int ipmr_mfc_release(struct inode *inode, struct file *file)
> > +{
> > +	struct seq_file *seq = file->private_data;
> > +	kfree(seq->private);
> > +	return seq_release(inode, file);
> >  }
> >  
> >  static struct file_operations ipmr_mfc_fops = {
> > @@ -1862,7 +1864,7 @@ static struct file_operations ipmr_mfc_f
> >  	.open    = ipmr_mfc_open,
> >  	.read    = seq_read,
> >  	.llseek  = seq_lseek,
> > -	.release = seq_release,
> > +	.release = ipmr_mfc_release,
> >  };
> >  #endif	
> 
> This is a good catch.  But you probably need to fix the vif stuff as
> well.

Yes, right. I didn't notice it. Thanks.

   - use seq_release_private for ipmr_vif/mfc_fops.

The anothor bug, it->cache need in *->seq_start* by NULL. Otherwise,
it->cache can be pointed the previous state by lseek().

e.g.
    ->seq_next()
         it->cache = &mfc_unres_queue
    ->seq_stop()
    lseek()
        ->seq_start()
              return SEQ_START_TOKEN (it->cache still has &mfc_unres_queue)
        ->seq_show()
        ->seq_stop()
              bang

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>




---

 net/ipv4/ipmr.c |   45 ++++++++++++++++++++-------------------------
 1 files changed, 20 insertions(+), 25 deletions(-)

diff -puN net/ipv4/ipmr.c~ipmr-cleanup net/ipv4/ipmr.c
--- linux-2.6.7/net/ipv4/ipmr.c~ipmr-cleanup	2004-07-03 14:13:50.000000000 +0900
+++ linux-2.6.7-hirofumi/net/ipv4/ipmr.c	2004-07-03 16:53:05.000000000 +0900
@@ -1702,7 +1702,7 @@ static struct file_operations ipmr_vif_f
 	.open    = ipmr_vif_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 
 struct ipmr_mfc_iter {
@@ -1710,7 +1710,6 @@ struct ipmr_mfc_iter {
 	int ct;
 };
 
-
 static struct mfc_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
 {
 	struct mfc_cache *mfc;
@@ -1734,9 +1733,11 @@ static struct mfc_cache *ipmr_mfc_seq_id
 	return NULL;
 }
 
-
 static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	struct ipmr_mfc_iter *it = seq->private;
+	it->cache = NULL;
+	it->ct = 0;
 	return *pos ? ipmr_mfc_seq_idx(seq->private, *pos - 1) 
 		: SEQ_START_TOKEN;
 }
@@ -1754,31 +1755,27 @@ static void *ipmr_mfc_seq_next(struct se
 	if (mfc->next)
 		return mfc->next;
 	
-	if (it->cache == &mfc_unres_queue) 
-		goto end_of_list;
+	if (it->cache == mfc_cache_array) {
+		while (++it->ct < MFC_LINES) {
+			mfc = mfc_cache_array[it->ct];
+			if (mfc)
+				return mfc;
+		}
 
-	BUG_ON(it->cache != mfc_cache_array);
+		/*
+		 * exhausted cache_array, show unresolved.
+		 * So switch to mfc_unres_queue.
+		 */
+		read_unlock(&mrt_lock);
 
-	while (++it->ct < MFC_LINES) {
-		mfc = mfc_cache_array[it->ct];
+		it->cache = &mfc_unres_queue;
+		it->ct = 0;
+		spin_lock_bh(&mfc_unres_lock);
+		mfc = mfc_unres_queue;
 		if (mfc)
 			return mfc;
 	}
 
-	/* exhausted cache_array, show unresolved */
-	read_unlock(&mrt_lock);
-	it->cache = &mfc_unres_queue;
-	it->ct = 0;
-		
-	spin_lock_bh(&mfc_unres_lock);
-	mfc = mfc_unres_queue;
-	if (mfc) 
-		return mfc;
-
- end_of_list:
-	spin_unlock_bh(&mfc_unres_lock);
-	it->cache = NULL;
-
 	return NULL;
 }
 
@@ -1846,7 +1843,6 @@ static int ipmr_mfc_open(struct inode *i
 	if (rc)
 		goto out_kfree;
 
-	memset(s, 0, sizeof(*s));
 	seq = file->private_data;
 	seq->private = s;
 out:
@@ -1854,7 +1850,6 @@ out:
 out_kfree:
 	kfree(s);
 	goto out;
-
 }
 
 static struct file_operations ipmr_mfc_fops = {
@@ -1862,7 +1857,7 @@ static struct file_operations ipmr_mfc_f
 	.open    = ipmr_mfc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = seq_release_private,
 };
 #endif	
 

_

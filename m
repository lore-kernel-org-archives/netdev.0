From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [BUGS] [CHECKER] 99 synchronization bugs and a lock summary
 database
Date: Sat, 03 Jul 2004 14:42:47 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87wu1l3aug.fsf@devron.myhome.or.jp>
References: <20040702004956.448c95d9.akpm@osdl.org>
	<E1BgLql-00055X-00@gondolin.me.apana.org.au>
	<20040702123022.563ee931.akpm@osdl.org>
	<20040702125008.25e65252@dell_ss3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, Herbert Xu
 <herbert@gondor.apana.org.au>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040702125008.25e65252@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> > > Andrew Morton <akpm@osdl.org> wrote:
> > > > 
> > > > Could someone please take a look at the locking in
> > > > net/ipv4/ipmr.c:ipmr_mfc_seq_next?  It seems rather broken.
> > > 
> > > Obfuscated yes, broken no.
> > 
> > Really?  Even if that goto
> > 
> > 	if (it->cache == &mfc_unres_queue) 
> > 		goto end_of_list;
> > 
> > is taken?
> 
> The problem is that the seq_file interface is trying to create an iterator
> over  a set of data.  The interface expects that the usage will always fit
> a given pattern.
> 
> The implied semantic is:
> 	if returned handle is NULL, then nothing is locked and it->cache = NULL
> 
> 	if returned handle is in the mfc_cache_table then
> 		it->cache points to mfc_cache_array and mrt_lock is held
> 	if returned handle is in the mfc_unres_queue then
> 		it->cache points to mfc_unres_queue and mfc_unres_lock is held
> 
> the seq_next is only valid to mean give me the next entry after the passed handle
> therefore if there are no more entries after the handle and the handle was on
> the unresolved queue, then the end is reached. 
> 
> When seq_stop is called, the it->cache pointer will be NULL so no unlock is done.

How about the following patch? At lease, this seems to need ipmr_mfc_release().
Untested patch, sorry.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>


 net/ipv4/ipmr.c |   50 ++++++++++++++++++++++++++------------------------
 1 files changed, 26 insertions(+), 24 deletions(-)

diff -puN net/ipv4/ipmr.c~ipmr-cleanup net/ipv4/ipmr.c
--- linux-2.6.7/net/ipv4/ipmr.c~ipmr-cleanup	2004-07-03 14:13:50.000000000 +0900
+++ linux-2.6.7-hirofumi/net/ipv4/ipmr.c	2004-07-03 14:30:54.000000000 +0900
@@ -1710,7 +1710,6 @@ struct ipmr_mfc_iter {
 	int ct;
 };
 
-
 static struct mfc_cache *ipmr_mfc_seq_idx(struct ipmr_mfc_iter *it, loff_t pos)
 {
 	struct mfc_cache *mfc;
@@ -1734,7 +1733,6 @@ static struct mfc_cache *ipmr_mfc_seq_id
 	return NULL;
 }
 
-
 static void *ipmr_mfc_seq_start(struct seq_file *seq, loff_t *pos)
 {
 	return *pos ? ipmr_mfc_seq_idx(seq->private, *pos - 1) 
@@ -1754,31 +1752,29 @@ static void *ipmr_mfc_seq_next(struct se
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
-		if (mfc)
-			return mfc;
+		it->cache = &mfc_unres_queue;
+		it->ct = 0;
+		spin_lock_bh(&mfc_unres_lock);
+		if (it->cache == mfc_unres_queue) {
+			mfc = mfc_unres_queue;
+			if (mfc)
+				return mfc;
+		}
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
 
@@ -1854,7 +1850,13 @@ out:
 out_kfree:
 	kfree(s);
 	goto out;
+}
 
+static int ipmr_mfc_release(struct inode *inode, struct file *file)
+{
+	struct seq_file *seq = file->private_data;
+	kfree(seq->private);
+	return seq_release(inode, file);
 }
 
 static struct file_operations ipmr_mfc_fops = {
@@ -1862,7 +1864,7 @@ static struct file_operations ipmr_mfc_f
 	.open    = ipmr_mfc_open,
 	.read    = seq_read,
 	.llseek  = seq_lseek,
-	.release = seq_release,
+	.release = ipmr_mfc_release,
 };
 #endif	
 

_

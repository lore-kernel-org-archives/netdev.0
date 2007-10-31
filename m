From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH]: Fix networking scatterlist regressions.
Date: Wed, 31 Oct 2007 09:14:28 +0100
Message-ID: <20071031081428.GF5059@kernel.dk>
References: <20071030.204002.193703502.davem@davemloft.net> <20071031074621.GB5059@kernel.dk> <20071031.005802.204286555.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au,
	rusty@rustcorp.com.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from brick.kernel.dk ([87.55.233.238]:20600 "EHLO kernel.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753249AbXJaIRI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Oct 2007 04:17:08 -0400
Content-Disposition: inline
In-Reply-To: <20071031.005802.204286555.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 31 2007, David Miller wrote:
> From: Jens Axboe <jens.axboe@oracle.com>
> Date: Wed, 31 Oct 2007 08:46:21 +0100
> 
> > On Tue, Oct 30 2007, David Miller wrote:
> > > @@ -293,7 +293,7 @@ decryptor(struct scatterlist *sg, void *data)
> > >  	if (thislen == 0)
> > >  		return 0;
> > >  
> > > -	sg_mark_end(desc->frags, desc->fragno);
> > > +	__sg_mark_end(desc->frags, desc->fragno);
> > >  
> > >  	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
> > >  					  desc->frags, thislen);
> > 
> > Hmm? These don't seem right. It also has a weird code sequence:
>  ...
> > Did something go wrong there?
> 
> Yes, I fixed those up after doing some allmodconfig builds.
> 
> Here is the final patch I actually pushed to Linus:

Here's the sg_mark_end() patch on top of that.

>From 2f5371509d3d4d09269bf7a46868da2ac5c61d77 Mon Sep 17 00:00:00 2001
From: Jens Axboe <jens.axboe@oracle.com>
Date: Wed, 31 Oct 2007 09:11:10 +0100
Subject: [PATCH] [SG] Get rid of __sg_mark_end()

sg_mark_end() overwrites the page_link information, but all users want
__sg_mark_end() behaviour where we just set the end bit. That is the most
natural way to use the sg list, since you'll fill it in and then mark the
end point.

So change sg_mark_end() to only set the termination bit. Add a sg_magic
debug check as well, and clear a chain pointer if it is set.

Signed-off-by: Jens Axboe <jens.axboe@oracle.com>
---
 block/ll_rw_blk.c                     |    2 +-
 drivers/scsi/scsi_lib.c               |    2 +-
 include/linux/scatterlist.h           |   22 ++++++++++++----------
 net/core/skbuff.c                     |    2 +-
 net/ipv4/tcp_ipv4.c                   |    2 +-
 net/ipv6/tcp_ipv6.c                   |    2 +-
 net/rxrpc/rxkad.c                     |    2 +-
 net/sunrpc/auth_gss/gss_krb5_crypto.c |    6 +++---
 8 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/block/ll_rw_blk.c b/block/ll_rw_blk.c
index e948407..fdc0707 100644
--- a/block/ll_rw_blk.c
+++ b/block/ll_rw_blk.c
@@ -1369,7 +1369,7 @@ new_segment:
 	} /* segments in rq */
 
 	if (sg)
-		__sg_mark_end(sg);
+		sg_mark_end(sg);
 
 	return nsegs;
 }
diff --git a/drivers/scsi/scsi_lib.c b/drivers/scsi/scsi_lib.c
index 61fdaf0..88de771 100644
--- a/drivers/scsi/scsi_lib.c
+++ b/drivers/scsi/scsi_lib.c
@@ -785,7 +785,7 @@ struct scatterlist *scsi_alloc_sgtable(struct scsi_cmnd *cmd, gfp_t gfp_mask)
 		 * end-of-list
 		 */
 		if (!left)
-			sg_mark_end(sgl, this);
+			sg_mark_end(&sgl[this - 1]);
 
 		/*
 		 * don't allow subsequent mempool allocs to sleep, it would
diff --git a/include/linux/scatterlist.h b/include/linux/scatterlist.h
index d5e1876..b2116a1 100644
--- a/include/linux/scatterlist.h
+++ b/include/linux/scatterlist.h
@@ -188,21 +188,23 @@ static inline void sg_chain(struct scatterlist *prv, unsigned int prv_nents,
 
 /**
  * sg_mark_end - Mark the end of the scatterlist
- * @sgl:	Scatterlist
- * @nents:	Number of entries in sgl
+ * @sg:		 SG entryScatterlist
  *
  * Description:
- *   Marks the last entry as the termination point for sg_next()
+ *   Marks the passed in sg entry as the termination point for the sg
+ *   table. A call to sg_next() on this entry will return NULL.
  *
  **/
-static inline void sg_mark_end(struct scatterlist *sgl, unsigned int nents)
-{
-	sgl[nents - 1].page_link = 0x02;
-}
-
-static inline void __sg_mark_end(struct scatterlist *sg)
+static inline void sg_mark_end(struct scatterlist *sg)
 {
+#ifdef CONFIG_DEBUG_SG
+	BUG_ON(sg->sg_magic != SG_MAGIC);
+#endif
+	/*
+	 * Set termination bit, clear potential chain bit
+	 */
 	sg->page_link |= 0x02;
+	sg->page_link &= ~0x01;
 }
 
 /**
@@ -218,7 +220,7 @@ static inline void __sg_mark_end(struct scatterlist *sg)
 static inline void sg_init_table(struct scatterlist *sgl, unsigned int nents)
 {
 	memset(sgl, 0, sizeof(*sgl) * nents);
-	sg_mark_end(sgl, nents);
+	sg_mark_end(&sgl[nents - 1]);
 #ifdef CONFIG_DEBUG_SG
 	{
 		unsigned int i;
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 64b50ff..32d5826 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2095,7 +2095,7 @@ int skb_to_sgvec(struct sk_buff *skb, struct scatterlist *sg, int offset, int le
 {
 	int nsg = __skb_to_sgvec(skb, sg, offset, len);
 
-	__sg_mark_end(&sg[nsg - 1]);
+	sg_mark_end(&sg[nsg - 1]);
 
 	return nsg;
 }
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index eec02b2..d438dfb 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1083,7 +1083,7 @@ static int tcp_v4_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	sg_set_buf(&sg[block++], key->key, key->keylen);
 	nbytes += key->keylen;
 
-	__sg_mark_end(&sg[block - 1]);
+	sg_mark_end(&sg[block - 1]);
 
 	/* Now store the Hash into the packet */
 	err = crypto_hash_init(desc);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 4b90328..06be2a1 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -781,7 +781,7 @@ static int tcp_v6_do_calc_md5_hash(char *md5_hash, struct tcp_md5sig_key *key,
 	sg_set_buf(&sg[block++], key->key, key->keylen);
 	nbytes += key->keylen;
 
-	__sg_mark_end(&sg[block - 1]);
+	sg_mark_end(&sg[block - 1]);
 
 	/* Now store the hash into the packet */
 	err = crypto_hash_init(desc);
diff --git a/net/rxrpc/rxkad.c b/net/rxrpc/rxkad.c
index c387cf6..e09a95a 100644
--- a/net/rxrpc/rxkad.c
+++ b/net/rxrpc/rxkad.c
@@ -702,7 +702,7 @@ static void rxkad_sg_set_buf2(struct scatterlist sg[2],
 		nsg++;
 	}
 
-	__sg_mark_end(&sg[nsg - 1]);
+	sg_mark_end(&sg[nsg - 1]);
 
 	ASSERTCMP(sg[0].length + sg[1].length, ==, buflen);
 }
diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index ab7cbd6..0dd7923 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -211,8 +211,8 @@ encryptor(struct scatterlist *sg, void *data)
 	if (thislen == 0)
 		return 0;
 
-	__sg_mark_end(&desc->infrags[desc->fragno - 1]);
-	__sg_mark_end(&desc->outfrags[desc->fragno - 1]);
+	sg_mark_end(&desc->infrags[desc->fragno - 1]);
+	sg_mark_end(&desc->outfrags[desc->fragno - 1]);
 
 	ret = crypto_blkcipher_encrypt_iv(&desc->desc, desc->outfrags,
 					  desc->infrags, thislen);
@@ -293,7 +293,7 @@ decryptor(struct scatterlist *sg, void *data)
 	if (thislen == 0)
 		return 0;
 
-	__sg_mark_end(&desc->frags[desc->fragno - 1]);
+	sg_mark_end(&desc->frags[desc->fragno - 1]);
 
 	ret = crypto_blkcipher_decrypt_iv(&desc->desc, desc->frags,
 					  desc->frags, thislen);
-- 
1.5.3.GIT



-- 
Jens Axboe


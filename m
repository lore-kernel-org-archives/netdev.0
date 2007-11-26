From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 2/10] [SKBUFF]: Add skb_morph
Date: Mon, 26 Nov 2007 23:10:30 +0800
Message-ID: <20071126151030.GC28022@gondor.apana.org.au>
References: <20071014042604.GA11431@gondor.apana.org.au> <E1Igv4m-00030E-00@gondolin.me.apana.org.au> <200711260650.lAQ6oOL9006774@toshiba.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kaber@trash.net, davem@davemloft.net, hadi@cyberus.ca,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3613 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754155AbXKZPKq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 10:10:46 -0500
Content-Disposition: inline
In-Reply-To: <200711260650.lAQ6oOL9006774@toshiba.co.jp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 26, 2007 at 03:50:22PM +0900, Yasuyuki KOZAKAI wrote:
>
> The refcount of nfct is leaked by this function. As a result,
> nf_conntrack_ipv6.ko cannot be unloaded after doing "ping6 -s 2000 ..." .
> dst->dst and dst->secpath are also needed to be released, I think.
> 
> Please consider to apply this patch.

Good catch! Thanks for spotting this.

I'm going to add the following patch to net-2.6.

[SKBUFF]: Free old skb properly in skb_morph

The skb_morph function only freed the data part of the dst skb, but leaked
the auxiliary data such as the netfilter fields.  This patch fixes this by
moving the relevant parts from __kfree_skb to skb_release_all and calling
it in skb_morph.

It also makes kfree_skbmem static since it's no longer called anywhere else
and it now no longer does skb_release_data.

Thanks to Yasuyuki KOZAKAI for finding this problem and posting a patch for
it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 91140fe..bddd50b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -356,7 +356,6 @@ static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
 	return __alloc_skb(size, priority, 1, -1);
 }
 
-extern void	       kfree_skbmem(struct sk_buff *skb);
 extern struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src);
 extern struct sk_buff *skb_clone(struct sk_buff *skb,
 				 gfp_t priority);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 32d5826..5b4ce9b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -275,12 +275,11 @@ static void skb_release_data(struct sk_buff *skb)
 /*
  *	Free an skbuff by memory without cleaning the state.
  */
-void kfree_skbmem(struct sk_buff *skb)
+static void kfree_skbmem(struct sk_buff *skb)
 {
 	struct sk_buff *other;
 	atomic_t *fclone_ref;
 
-	skb_release_data(skb);
 	switch (skb->fclone) {
 	case SKB_FCLONE_UNAVAILABLE:
 		kmem_cache_free(skbuff_head_cache, skb);
@@ -307,16 +306,8 @@ void kfree_skbmem(struct sk_buff *skb)
 	}
 }
 
-/**
- *	__kfree_skb - private function
- *	@skb: buffer
- *
- *	Free an sk_buff. Release anything attached to the buffer.
- *	Clean the state. This is an internal helper function. Users should
- *	always call kfree_skb
- */
-
-void __kfree_skb(struct sk_buff *skb)
+/* Free everything but the sk_buff shell. */
+static void skb_release_all(struct sk_buff *skb)
 {
 	dst_release(skb->dst);
 #ifdef CONFIG_XFRM
@@ -340,7 +331,21 @@ void __kfree_skb(struct sk_buff *skb)
 	skb->tc_verd = 0;
 #endif
 #endif
+	skb_release_data(skb);
+}
+
+/**
+ *	__kfree_skb - private function
+ *	@skb: buffer
+ *
+ *	Free an sk_buff. Release anything attached to the buffer.
+ *	Clean the state. This is an internal helper function. Users should
+ *	always call kfree_skb
+ */
 
+void __kfree_skb(struct sk_buff *skb)
+{
+	skb_release_all(skb);
 	kfree_skbmem(skb);
 }
 
@@ -441,7 +446,7 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
  */
 struct sk_buff *skb_morph(struct sk_buff *dst, struct sk_buff *src)
 {
-	skb_release_data(dst);
+	skb_release_all(dst);
 	return __skb_clone(dst, src);
 }
 EXPORT_SYMBOL_GPL(skb_morph);

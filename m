From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: skbuff: Move new code into __copy_skb_header
Date: Sat, 23 May 2009 18:11:37 +1000
Message-ID: <20090523081137.GA12567@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Moore <paul.moore@hp.com>,
	Sujith <Sujith.Manoharan@atheros.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:59430 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751290AbZEWILm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 May 2009 04:11:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi:

skbuff: Move new __skb_clone code into __copy_skb_header

It seems that people just keep on adding stuff to __skb_clone
instead __copy_skb_header.  This is wrong as it means your brand-new
attributes won't always get copied as you intended.

This patch moves them to the right place, and adds a comment to
prevent this from happening again.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index e505b53..cb58b4b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -538,6 +538,7 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 	new->protocol		= old->protocol;
 	new->mark		= old->mark;
+	new->iif		= old->iif;
 	__nf_copy(new, old);
 #if defined(CONFIG_NETFILTER_XT_TARGET_TRACE) || \
     defined(CONFIG_NETFILTER_XT_TARGET_TRACE_MODULE)
@@ -550,10 +551,18 @@ static void __copy_skb_header(struct sk_buff *new, const struct sk_buff *old)
 #endif
 #endif
 	new->vlan_tci		= old->vlan_tci;
+#if defined(CONFIG_MAC80211) || defined(CONFIG_MAC80211_MODULE)
+	new->do_not_encrypt	= old->do_not_encrypt;
+	new->requeue		= old->requeue;
+#endif
 
 	skb_copy_secmark(new, old);
 }
 
+/*
+ * You should not add any new code to this function.  Add it to
+ * __copy_skb_header above instead.
+ */
 static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 {
 #define C(x) n->x = skb->x
@@ -569,16 +578,11 @@ static struct sk_buff *__skb_clone(struct sk_buff *n, struct sk_buff *skb)
 	n->cloned = 1;
 	n->nohdr = 0;
 	n->destructor = NULL;
-	C(iif);
 	C(tail);
 	C(end);
 	C(head);
 	C(data);
 	C(truesize);
-#if defined(CONFIG_MAC80211) || defined(CONFIG_MAC80211_MODULE)
-	C(do_not_encrypt);
-	C(requeue);
-#endif
 	atomic_set(&n->users, 1);
 
 	atomic_inc(&(skb_shinfo(skb)->dataref));

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

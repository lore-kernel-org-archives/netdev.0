From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 7/7] [IPSEC]: Move state lock into x->type->output
Date: Tue, 09 Oct 2007 22:36:37 +0800
Message-ID: <E1IfGCL-0005MT-00@gondolin.me.apana.org.au>
References: <20071009143517.GA20486@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1024 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753110AbXJIOgn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 10:36:43 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move state lock into x->type->output

This patch releases the lock on the state before calling x->type->output.
It also adds the lock to the spots where they're currently needed.

Most of those places (all except mip6) are expected to disappear with
async crypto.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ah4.c         |    7 ++++++-
 net/ipv4/esp4.c        |   10 ++++++++--
 net/ipv6/ah6.c         |    9 ++++++---
 net/ipv6/esp6.c        |   10 ++++++++--
 net/ipv6/mip6.c        |    4 ++++
 net/xfrm/xfrm_output.c |    8 ++++----
 6 files changed, 36 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 58af298..3513149 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -5,6 +5,7 @@
 #include <net/ah.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
+#include <linux/spinlock.h>
 #include <net/icmp.h>
 #include <net/protocol.h>
 #include <asm/scatterlist.h>
@@ -97,10 +98,14 @@ static int ah_output(struct xfrm_state *x, struct sk_buff *skb)
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
+
+	spin_lock_bh(&x->lock);
 	err = ah_mac_digest(ahp, skb, ah->auth_data);
+	memcpy(ah->auth_data, ahp->work_icv, ahp->icv_trunc_len);
+	spin_unlock_bh(&x->lock);
+
 	if (err)
 		goto error;
-	memcpy(ah->auth_data, ahp->work_icv, ahp->icv_trunc_len);
 
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index ffd5653..452910d 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -8,6 +8,7 @@
 #include <linux/kernel.h>
 #include <linux/pfkeyv2.h>
 #include <linux/random.h>
+#include <linux/spinlock.h>
 #include <net/icmp.h>
 #include <net/protocol.h>
 #include <net/udp.h>
@@ -66,6 +67,8 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	top_iph->tot_len = htons(skb->len + alen);
 	*(skb_tail_pointer(trailer) - 1) = top_iph->protocol;
 
+	spin_lock_bh(&x->lock);
+
 	/* this is non-NULL only with UDP Encapsulation */
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
@@ -111,7 +114,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
 			sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
 			if (!sg)
-				goto error;
+				goto unlock;
 		}
 		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
 		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
@@ -120,7 +123,7 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	} while (0);
 
 	if (unlikely(err))
-		goto error;
+		goto unlock;
 
 	if (esp->conf.ivlen) {
 		memcpy(esph->enc_data, esp->conf.ivec, esp->conf.ivlen);
@@ -133,6 +136,9 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 		memcpy(pskb_put(skb, trailer, alen), esp->auth.work_icv, alen);
 	}
 
+unlock:
+	spin_unlock_bh(&x->lock);
+
 	ip_send_check(top_iph);
 
 error:
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ff904a7..c51d775 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -29,6 +29,7 @@
 #include <net/ah.h>
 #include <linux/crypto.h>
 #include <linux/pfkeyv2.h>
+#include <linux/spinlock.h>
 #include <linux/string.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
@@ -284,12 +285,14 @@ static int ah6_output(struct xfrm_state *x, struct sk_buff *skb)
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
 	ah->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
+
+	spin_lock_bh(&x->lock);
 	err = ah_mac_digest(ahp, skb, ah->auth_data);
-	if (err)
-		goto error_free_iph;
 	memcpy(ah->auth_data, ahp->work_icv, ahp->icv_trunc_len);
+	spin_unlock_bh(&x->lock);
 
-	err = 0;
+	if (err)
+		goto error_free_iph;
 
 	memcpy(top_iph, tmp_base, sizeof(tmp_base));
 	if (tmp_ext) {
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 9fc1940..7355bb0 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -34,6 +34,7 @@
 #include <linux/kernel.h>
 #include <linux/pfkeyv2.h>
 #include <linux/random.h>
+#include <linux/spinlock.h>
 #include <net/icmp.h>
 #include <net/ipv6.h>
 #include <net/protocol.h>
@@ -98,6 +99,8 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(XFRM_SKB_CB(skb)->seq);
 
+	spin_lock_bh(&x->lock);
+
 	if (esp->conf.ivlen) {
 		if (unlikely(!esp->conf.ivinitted)) {
 			get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
@@ -112,7 +115,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 		if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
 			sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
 			if (!sg)
-				goto error;
+				goto unlock;
 		}
 		skb_to_sgvec(skb, sg, esph->enc_data+esp->conf.ivlen-skb->data, clen);
 		err = crypto_blkcipher_encrypt(&desc, sg, sg, clen);
@@ -121,7 +124,7 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	} while (0);
 
 	if (unlikely(err))
-		goto error;
+		goto unlock;
 
 	if (esp->conf.ivlen) {
 		memcpy(esph->enc_data, esp->conf.ivec, esp->conf.ivlen);
@@ -134,6 +137,9 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 		memcpy(pskb_put(skb, trailer, alen), esp->auth.work_icv, alen);
 	}
 
+unlock:
+	spin_unlock_bh(&x->lock);
+
 error:
 	return err;
 }
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 7261c29..6475bac 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -172,7 +172,9 @@ static int mip6_destopt_output(struct xfrm_state *x, struct sk_buff *skb)
 	len = ((char *)hao - (char *)dstopt) + sizeof(*hao);
 
 	memcpy(&hao->addr, &iph->saddr, sizeof(hao->addr));
+	spin_lock_bh(&x->lock);
 	memcpy(&iph->saddr, x->coaddr, sizeof(iph->saddr));
+	spin_unlock_bh(&x->lock);
 
 	BUG_TRAP(len == x->props.header_len);
 	dstopt->hdrlen = (x->props.header_len >> 3) - 1;
@@ -381,7 +383,9 @@ static int mip6_rthdr_output(struct xfrm_state *x, struct sk_buff *skb)
 	BUG_TRAP(rt2->rt_hdr.hdrlen == 2);
 
 	memcpy(&rt2->addr, &iph->daddr, sizeof(rt2->addr));
+	spin_lock_bh(&x->lock);
 	memcpy(&iph->daddr, x->coaddr, sizeof(iph->daddr));
+	spin_unlock_bh(&x->lock);
 
 	return 0;
 }
diff --git a/net/xfrm/xfrm_output.c b/net/xfrm/xfrm_output.c
index 9847bae..0eb3377 100644
--- a/net/xfrm/xfrm_output.c
+++ b/net/xfrm/xfrm_output.c
@@ -67,15 +67,15 @@ int xfrm_output(struct sk_buff *skb)
 		if (err)
 			goto error;
 
-		err = x->type->output(x, skb);
-		if (err)
-			goto error;
-
 		x->curlft.bytes += skb->len;
 		x->curlft.packets++;
 
 		spin_unlock_bh(&x->lock);
 
+		err = x->type->output(x, skb);
+		if (err)
+			goto error_nolock;
+
 		if (!(skb->dst = dst_pop(dst))) {
 			err = -EHOSTUNREACH;
 			goto error_nolock;

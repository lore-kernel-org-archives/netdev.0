From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 23/24] [IPSEC]: Move integrity stat collection into xfrm_input
Date: Wed, 07 Nov 2007 22:08:40 +0800
Message-ID: <E1IplaC-0001Iv-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3805 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758301AbXKGO1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:27:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move integrity stat collection into xfrm_input

Similar to the moving out of the replay processing on the output,
this patch moves the integrity stat collectin from x->type->input
into xfrm_input.

This would eventually allow transforms such as AH/ESP to be lockless.

The error value EBADMSG (currently unused in the crypto layer) is used
to indicate a failed integrity check.  In future this error can be
directly returned by the crypto layer once we switch to aead algorithms.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ah4.c        |    3 +--
 net/ipv4/esp4.c       |   13 ++++++++-----
 net/ipv6/ah6.c        |    3 +--
 net/ipv6/esp6.c       |    3 +--
 net/xfrm/xfrm_input.c |    5 ++++-
 5 files changed, 15 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index 5fc346d..a989d29 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -177,9 +177,8 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		err = ah_mac_digest(ahp, skb, ah->auth_data);
 		if (err)
 			goto out;
-		err = -EINVAL;
 		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
-			x->stats.integrity_failed++;
+			err = -EBADMSG;
 			goto out;
 		}
 	}
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index c31bccb..7f1854c 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -162,7 +162,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	u8 nexthdr[2];
 	struct scatterlist *sg;
 	int padlen;
-	int err;
+	int err = -EINVAL;
 
 	if (!pskb_may_pull(skb, sizeof(*esph)))
 		goto out;
@@ -182,13 +182,14 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 			BUG();
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
-			x->stats.integrity_failed++;
+			err = -EBADMSG;
 			goto out;
 		}
 	}
 
-	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0)
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
 		goto out;
+	nfrags = err;
 
 	skb->ip_summed = CHECKSUM_NONE;
 
@@ -201,6 +202,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	sg = &esp->sgbuf[0];
 
 	if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
+		err = -ENOMEM;
 		sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
 		if (!sg)
 			goto out;
@@ -213,11 +215,12 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (unlikely(sg != &esp->sgbuf[0]))
 		kfree(sg);
 	if (unlikely(err))
-		return err;
+		goto out;
 
 	if (skb_copy_bits(skb, skb->len-alen-2, nexthdr, 2))
 		BUG();
 
+	err = -EINVAL;
 	padlen = nexthdr[0];
 	if (padlen+2 >= elen)
 		goto out;
@@ -271,7 +274,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	return nexthdr[1];
 
 out:
-	return -EINVAL;
+	return err;
 }
 
 static u32 esp4_get_mtu(struct xfrm_state *x, int mtu)
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 4eaf550..d4b59ec 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -379,10 +379,9 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		err = ah_mac_digest(ahp, skb, ah->auth_data);
 		if (err)
 			goto free_out;
-		err = -EINVAL;
 		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
 			LIMIT_NETDEBUG(KERN_WARNING "ipsec ah authentication error\n");
-			x->stats.integrity_failed++;
+			err = -EBADMSG;
 			goto free_out;
 		}
 	}
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 7db66f1..c37982b 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -177,8 +177,7 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 			BUG();
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
-			x->stats.integrity_failed++;
-			ret = -EINVAL;
+			ret = -EBADMSG;
 			goto out;
 		}
 	}
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index 587f347..b7d68eb 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -147,8 +147,11 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 			goto drop_unlock;
 
 		nexthdr = x->type->input(x, skb);
-		if (nexthdr <= 0)
+		if (nexthdr <= 0) {
+			if (nexthdr == -EBADMSG)
+				x->stats.integrity_failed++;
 			goto drop_unlock;
+		}
 
 		skb_network_header(skb)[nhoff] = nexthdr;
 

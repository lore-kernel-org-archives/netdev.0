From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 24/24] [IPSEC]: Move state lock into x->type->input
Date: Wed, 07 Nov 2007 22:08:41 +0800
Message-ID: <E1IplaD-0001J4-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3753 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757859AbXKGO0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:26:15 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPSEC]: Move state lock into x->type->input

This patch releases the lock on the state before calling x->type->input.
It also adds the lock to the spots where they're currently needed.

Most of those places (all except mip6) are expected to disappear with
async crypto.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 net/ipv4/ah4.c        |   14 ++++++++++----
 net/ipv4/esp4.c       |   24 +++++++++++++++---------
 net/ipv6/ah6.c        |    9 +++++++--
 net/ipv6/esp6.c       |   37 +++++++++++++++++++++++--------------
 net/ipv6/mip6.c       |   14 ++++++++++----
 net/xfrm/xfrm_input.c |    4 ++++
 6 files changed, 69 insertions(+), 33 deletions(-)

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index a989d29..d76803a 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -169,6 +169,8 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		if (ip_clear_mutable_options(iph, &dummy))
 			goto out;
 	}
+
+	spin_lock(&x->lock);
 	{
 		u8 auth_data[MAX_AH_AUTH_LEN];
 
@@ -176,12 +178,16 @@ static int ah_input(struct xfrm_state *x, struct sk_buff *skb)
 		skb_push(skb, ihl);
 		err = ah_mac_digest(ahp, skb, ah->auth_data);
 		if (err)
-			goto out;
-		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
+			goto unlock;
+		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len))
 			err = -EBADMSG;
-			goto out;
-		}
 	}
+unlock:
+	spin_unlock(&x->lock);
+
+	if (err)
+		goto out;
+
 	skb->network_header += ah_hlen;
 	memcpy(skb_network_header(skb), work_buf, ihl);
 	skb->transport_header = skb->network_header;
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 7f1854c..de4592c 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -170,29 +170,31 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	if (elen <= 0 || (elen & (blksize-1)))
 		goto out;
 
+	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
+		goto out;
+	nfrags = err;
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	spin_lock(&x->lock);
+
 	/* If integrity check is required, do this. */
 	if (esp->auth.icv_full_len) {
 		u8 sum[alen];
 
 		err = esp_mac_digest(esp, skb, 0, skb->len - alen);
 		if (err)
-			goto out;
+			goto unlock;
 
 		if (skb_copy_bits(skb, skb->len - alen, sum, alen))
 			BUG();
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
 			err = -EBADMSG;
-			goto out;
+			goto unlock;
 		}
 	}
 
-	if ((err = skb_cow_data(skb, 0, &trailer)) < 0)
-		goto out;
-	nfrags = err;
-
-	skb->ip_summed = CHECKSUM_NONE;
-
 	esph = (struct ip_esp_hdr *)skb->data;
 
 	/* Get ivec. This can be wrong, check against another impls. */
@@ -205,7 +207,7 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 		err = -ENOMEM;
 		sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
 		if (!sg)
-			goto out;
+			goto unlock;
 	}
 	sg_init_table(sg, nfrags);
 	skb_to_sgvec(skb, sg,
@@ -214,6 +216,10 @@ static int esp_input(struct xfrm_state *x, struct sk_buff *skb)
 	err = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 	if (unlikely(sg != &esp->sgbuf[0]))
 		kfree(sg);
+
+unlock:
+	spin_unlock(&x->lock);
+
 	if (unlikely(err))
 		goto out;
 
diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index d4b59ec..1b51d1e 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -370,6 +370,7 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 	ip6h->flow_lbl[2] = 0;
 	ip6h->hop_limit   = 0;
 
+	spin_lock(&x->lock);
 	{
 		u8 auth_data[MAX_AH_AUTH_LEN];
 
@@ -378,13 +379,17 @@ static int ah6_input(struct xfrm_state *x, struct sk_buff *skb)
 		skb_push(skb, hdr_len);
 		err = ah_mac_digest(ahp, skb, ah->auth_data);
 		if (err)
-			goto free_out;
+			goto unlock;
 		if (memcmp(ahp->work_icv, auth_data, ahp->icv_trunc_len)) {
 			LIMIT_NETDEBUG(KERN_WARNING "ipsec ah authentication error\n");
 			err = -EBADMSG;
-			goto free_out;
 		}
 	}
+unlock:
+	spin_unlock(&x->lock);
+
+	if (err)
+		goto free_out;
 
 	skb->network_header += ah_hlen;
 	memcpy(skb_network_header(skb), tmp_hdr, hdr_len);
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index c37982b..bb0e562 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -165,30 +165,32 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 		goto out;
 	}
 
+	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	spin_lock(&x->lock);
+
 	/* If integrity check is required, do this. */
 	if (esp->auth.icv_full_len) {
 		u8 sum[alen];
 
 		ret = esp_mac_digest(esp, skb, 0, skb->len - alen);
 		if (ret)
-			goto out;
+			goto unlock;
 
 		if (skb_copy_bits(skb, skb->len - alen, sum, alen))
 			BUG();
 
 		if (unlikely(memcmp(esp->auth.work_icv, sum, alen))) {
 			ret = -EBADMSG;
-			goto out;
+			goto unlock;
 		}
 	}
 
-	if ((nfrags = skb_cow_data(skb, 0, &trailer)) < 0) {
-		ret = -EINVAL;
-		goto out;
-	}
-
-	skb->ip_summed = CHECKSUM_NONE;
-
 	esph = (struct ip_esp_hdr *)skb->data;
 	iph = ipv6_hdr(skb);
 
@@ -197,15 +199,13 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 		crypto_blkcipher_set_iv(tfm, esph->enc_data, esp->conf.ivlen);
 
 	{
-		u8 nexthdr[2];
 		struct scatterlist *sg = &esp->sgbuf[0];
-		u8 padlen;
 
 		if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
 			sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
 			if (!sg) {
 				ret = -ENOMEM;
-				goto out;
+				goto unlock;
 			}
 		}
 		sg_init_table(sg, nfrags);
@@ -215,8 +215,17 @@ static int esp6_input(struct xfrm_state *x, struct sk_buff *skb)
 		ret = crypto_blkcipher_decrypt(&desc, sg, sg, elen);
 		if (unlikely(sg != &esp->sgbuf[0]))
 			kfree(sg);
-		if (unlikely(ret))
-			goto out;
+	}
+
+unlock:
+	spin_unlock(&x->lock);
+
+	if (unlikely(ret))
+		goto out;
+
+	{
+		u8 nexthdr[2];
+		u8 padlen;
 
 		if (skb_copy_bits(skb, skb->len-alen-2, nexthdr, 2))
 			BUG();
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index edfd9cd..49d3966 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -128,12 +128,15 @@ static int mip6_destopt_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	struct ipv6_destopt_hdr *destopt = (struct ipv6_destopt_hdr *)skb->data;
+	int err = destopt->nexthdr;
 
+	spin_lock(&x->lock);
 	if (!ipv6_addr_equal(&iph->saddr, (struct in6_addr *)x->coaddr) &&
 	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
-		return -ENOENT;
+		err = -ENOENT;
+	spin_unlock(&x->lock);
 
-	return destopt->nexthdr;
+	return err;
 }
 
 /* Destination Option Header is inserted.
@@ -344,12 +347,15 @@ static struct xfrm_type mip6_destopt_type =
 static int mip6_rthdr_input(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct rt2_hdr *rt2 = (struct rt2_hdr *)skb->data;
+	int err = rt2->rt_hdr.nexthdr;
 
+	spin_lock(&x->lock);
 	if (!ipv6_addr_equal(&rt2->addr, (struct in6_addr *)x->coaddr) &&
 	    !ipv6_addr_any((struct in6_addr *)x->coaddr))
-		return -ENOENT;
+		err = -ENOENT;
+	spin_unlock(&x->lock);
 
-	return rt2->rt_hdr.nexthdr;
+	return err;
 }
 
 /* Routing Header type 2 is inserted.
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index b7d68eb..5cad522 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -146,7 +146,11 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 		if (xfrm_state_check_expire(x))
 			goto drop_unlock;
 
+		spin_unlock(&x->lock);
+
 		nexthdr = x->type->input(x, skb);
+
+		spin_lock(&x->lock);
 		if (nexthdr <= 0) {
 			if (nexthdr == -EBADMSG)
 				x->stats.integrity_failed++;

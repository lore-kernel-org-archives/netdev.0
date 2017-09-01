From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/2] xfrm: Add support for network devices capable of removing the ESP trailer
Date: Fri, 1 Sep 2017 09:30:45 +0200
Message-ID: <1504251046-17106-2-git-send-email-steffen.klassert@secunet.com>
References: <1504251046-17106-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:50304 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751498AbdIAHax (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 03:30:53 -0400
In-Reply-To: <1504251046-17106-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yossi Kuperman <yossiku@mellanox.com>

In conjunction with crypto offload [1], removing the ESP trailer by
hardware can potentially improve the performance by avoiding (1) a
cache miss incurred by reading the nexthdr field and (2) the necessity
to calculate the csum value of the trailer in order to keep skb->csum
valid.

This patch introduces the changes to the xfrm stack and merely serves
as an infrastructure. Subsequent patch to mlx5 driver will put this to
a good use.

[1] https://www.mail-archive.com/netdev@vger.kernel.org/msg175733.html

Signed-off-by: Yossi Kuperman <yossiku@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 include/net/xfrm.h    |  1 +
 net/ipv4/esp4.c       | 70 ++++++++++++++++++++++++++++++++++-----------------
 net/ipv6/esp6.c       | 51 ++++++++++++++++++++++++++-----------
 net/xfrm/xfrm_input.c |  5 ++++
 4 files changed, 89 insertions(+), 38 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 9c7b70c..f002a2c 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -1019,6 +1019,7 @@ struct xfrm_offload {
 #define	CRYPTO_FALLBACK		8
 #define	XFRM_GSO_SEGMENT	16
 #define	XFRM_GRO		32
+#define	XFRM_ESP_NO_TRAILER	64
 
 	__u32			status;
 #define CRYPTO_SUCCESS				1
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 741acd7..3190005 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -499,19 +499,59 @@ static int esp_output(struct xfrm_state *x, struct sk_buff *skb)
 	return esp_output_tail(x, skb, &esp);
 }
 
+static inline int esp_remove_trailer(struct sk_buff *skb)
+{
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
+	struct crypto_aead *aead = x->data;
+	int alen, hlen, elen;
+	int padlen, trimlen;
+	__wsum csumdiff;
+	u8 nexthdr[2];
+	int ret;
+
+	alen = crypto_aead_authsize(aead);
+	hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
+	elen = skb->len - hlen;
+
+	if (xo && (xo->flags & XFRM_ESP_NO_TRAILER)) {
+		ret = xo->proto;
+		goto out;
+	}
+
+	if (skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2))
+		BUG();
+
+	ret = -EINVAL;
+	padlen = nexthdr[0];
+	if (padlen + 2 + alen >= elen) {
+		net_dbg_ratelimited("ipsec esp packet is garbage padlen=%d, elen=%d\n",
+				    padlen + 2, elen - alen);
+		goto out;
+	}
+
+	trimlen = alen + padlen + 2;
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		csumdiff = skb_checksum(skb, skb->len - trimlen, trimlen, 0);
+		skb->csum = csum_block_sub(skb->csum, csumdiff,
+					   skb->len - trimlen);
+	}
+	pskb_trim(skb, skb->len - trimlen);
+
+	ret = nexthdr[1];
+
+out:
+	return ret;
+}
+
 int esp_input_done2(struct sk_buff *skb, int err)
 {
 	const struct iphdr *iph;
 	struct xfrm_state *x = xfrm_input_state(skb);
 	struct xfrm_offload *xo = xfrm_offload(skb);
 	struct crypto_aead *aead = x->data;
-	int alen = crypto_aead_authsize(aead);
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
-	int elen = skb->len - hlen;
 	int ihl;
-	u8 nexthdr[2];
-	int padlen, trimlen;
-	__wsum csumdiff;
 
 	if (!xo || (xo && !(xo->flags & CRYPTO_DONE)))
 		kfree(ESP_SKB_CB(skb)->tmp);
@@ -519,16 +559,10 @@ int esp_input_done2(struct sk_buff *skb, int err)
 	if (unlikely(err))
 		goto out;
 
-	if (skb_copy_bits(skb, skb->len-alen-2, nexthdr, 2))
-		BUG();
-
-	err = -EINVAL;
-	padlen = nexthdr[0];
-	if (padlen + 2 + alen >= elen)
+	err = esp_remove_trailer(skb);
+	if (unlikely(err < 0))
 		goto out;
 
-	/* ... check padding bits here. Silly. :-) */
-
 	iph = ip_hdr(skb);
 	ihl = iph->ihl * 4;
 
@@ -569,22 +603,12 @@ int esp_input_done2(struct sk_buff *skb, int err)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	trimlen = alen + padlen + 2;
-	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		csumdiff = skb_checksum(skb, skb->len - trimlen, trimlen, 0);
-		skb->csum = csum_block_sub(skb->csum, csumdiff,
-					   skb->len - trimlen);
-	}
-	pskb_trim(skb, skb->len - trimlen);
-
 	skb_pull_rcsum(skb, hlen);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		skb_reset_transport_header(skb);
 	else
 		skb_set_transport_header(skb, -ihl);
 
-	err = nexthdr[1];
-
 	/* RFC4303: Drop dummy packets without any error */
 	if (err == IPPROTO_NONE)
 		err = -EINVAL;
diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 74bde20..7fb41b0 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -461,29 +461,30 @@ static int esp6_output(struct xfrm_state *x, struct sk_buff *skb)
 	return esp6_output_tail(x, skb, &esp);
 }
 
-int esp6_input_done2(struct sk_buff *skb, int err)
+static inline int esp_remove_trailer(struct sk_buff *skb)
 {
 	struct xfrm_state *x = xfrm_input_state(skb);
 	struct xfrm_offload *xo = xfrm_offload(skb);
 	struct crypto_aead *aead = x->data;
-	int alen = crypto_aead_authsize(aead);
-	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
-	int elen = skb->len - hlen;
-	int hdr_len = skb_network_header_len(skb);
+	int alen, hlen, elen;
 	int padlen, trimlen;
 	__wsum csumdiff;
 	u8 nexthdr[2];
+	int ret;
 
-	if (!xo || (xo && !(xo->flags & CRYPTO_DONE)))
-		kfree(ESP_SKB_CB(skb)->tmp);
+	alen = crypto_aead_authsize(aead);
+	hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
+	elen = skb->len - hlen;
 
-	if (unlikely(err))
+	if (xo && (xo->flags & XFRM_ESP_NO_TRAILER)) {
+		ret = xo->proto;
 		goto out;
+	}
 
 	if (skb_copy_bits(skb, skb->len - alen - 2, nexthdr, 2))
 		BUG();
 
-	err = -EINVAL;
+	ret = -EINVAL;
 	padlen = nexthdr[0];
 	if (padlen + 2 + alen >= elen) {
 		net_dbg_ratelimited("ipsec esp packet is garbage padlen=%d, elen=%d\n",
@@ -491,26 +492,46 @@ int esp6_input_done2(struct sk_buff *skb, int err)
 		goto out;
 	}
 
-	/* ... check padding bits here. Silly. :-) */
-
 	trimlen = alen + padlen + 2;
 	if (skb->ip_summed == CHECKSUM_COMPLETE) {
-		skb_postpull_rcsum(skb, skb_network_header(skb),
-				   skb_network_header_len(skb));
 		csumdiff = skb_checksum(skb, skb->len - trimlen, trimlen, 0);
 		skb->csum = csum_block_sub(skb->csum, csumdiff,
 					   skb->len - trimlen);
 	}
 	pskb_trim(skb, skb->len - trimlen);
 
+	ret = nexthdr[1];
+
+out:
+	return ret;
+}
+
+int esp6_input_done2(struct sk_buff *skb, int err)
+{
+	struct xfrm_state *x = xfrm_input_state(skb);
+	struct xfrm_offload *xo = xfrm_offload(skb);
+	struct crypto_aead *aead = x->data;
+	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
+	int hdr_len = skb_network_header_len(skb);
+
+	if (!xo || (xo && !(xo->flags & CRYPTO_DONE)))
+		kfree(ESP_SKB_CB(skb)->tmp);
+
+	if (unlikely(err))
+		goto out;
+
+	err = esp_remove_trailer(skb);
+	if (unlikely(err < 0))
+		goto out;
+
+	skb_postpull_rcsum(skb, skb_network_header(skb),
+			   skb_network_header_len(skb));
 	skb_pull_rcsum(skb, hlen);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		skb_reset_transport_header(skb);
 	else
 		skb_set_transport_header(skb, -hdr_len);
 
-	err = nexthdr[1];
-
 	/* RFC4303: Drop dummy packets without any error */
 	if (err == IPPROTO_NONE)
 		err = -EINVAL;
diff --git a/net/xfrm/xfrm_input.c b/net/xfrm/xfrm_input.c
index f07eec5..2515cd2 100644
--- a/net/xfrm/xfrm_input.c
+++ b/net/xfrm/xfrm_input.c
@@ -247,6 +247,11 @@ int xfrm_input(struct sk_buff *skb, int nexthdr, __be32 spi, int encap_type)
 					goto drop;
 				}
 
+				if (xo->status & CRYPTO_INVALID_PROTOCOL) {
+					XFRM_INC_STATS(net, LINUX_MIB_XFRMINSTATEPROTOERROR);
+					goto drop;
+				}
+
 				XFRM_INC_STATS(net, LINUX_MIB_XFRMINBUFFERERROR);
 				goto drop;
 			}
-- 
2.7.4

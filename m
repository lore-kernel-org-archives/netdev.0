From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/8] esp4: Support RX checksum with crypto offload
Date: Mon, 21 Aug 2017 07:49:26 +0200
Message-ID: <1503294573-10206-2-git-send-email-steffen.klassert@secunet.com>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34896 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751019AbdHUFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 21 Aug 2017 01:49:42 -0400
In-Reply-To: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

Keep the device's reported ip_summed indication in case crypto
was offloaded by the device. Subtract the csum values of the
stripped parts (esp header+iv, esp trailer+auth_data) to keep
value correct.

Note: CHECKSUM_COMPLETE should be indicated only if skb->csum
has the post-decryption offload csum value.

Signed-off-by: Ariel Levkovich <lariel@mellanox.com>
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/esp4.c         | 14 +++++++++++---
 net/ipv4/esp4_offload.c |  4 +++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 0cbee0a..741acd7 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -510,7 +510,8 @@ int esp_input_done2(struct sk_buff *skb, int err)
 	int elen = skb->len - hlen;
 	int ihl;
 	u8 nexthdr[2];
-	int padlen;
+	int padlen, trimlen;
+	__wsum csumdiff;
 
 	if (!xo || (xo && !(xo->flags & CRYPTO_DONE)))
 		kfree(ESP_SKB_CB(skb)->tmp);
@@ -568,8 +569,15 @@ int esp_input_done2(struct sk_buff *skb, int err)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	pskb_trim(skb, skb->len - alen - padlen - 2);
-	__skb_pull(skb, hlen);
+	trimlen = alen + padlen + 2;
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		csumdiff = skb_checksum(skb, skb->len - trimlen, trimlen, 0);
+		skb->csum = csum_block_sub(skb->csum, csumdiff,
+					   skb->len - trimlen);
+	}
+	pskb_trim(skb, skb->len - trimlen);
+
+	skb_pull_rcsum(skb, hlen);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		skb_reset_transport_header(skb);
 	else
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index e066601..05831de 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -182,11 +182,13 @@ static struct sk_buff *esp4_gso_segment(struct sk_buff *skb,
 static int esp_input_tail(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct crypto_aead *aead = x->data;
+	struct xfrm_offload *xo = xfrm_offload(skb);
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead)))
 		return -EINVAL;
 
-	skb->ip_summed = CHECKSUM_NONE;
+	if (!(xo->flags & CRYPTO_DONE))
+		skb->ip_summed = CHECKSUM_NONE;
 
 	return esp_input_done2(skb, 0);
 }
-- 
2.7.4

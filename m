From: ilant@mellanox.com
Subject: [PATCH net-next 1/4] esp4: Support RX checksum with crypto offload
Date: Thu, 22 Jun 2017 15:31:56 +0300
Message-ID: <20170622123159.8348-2-ilant@mellanox.com>
References: <20170622123159.8348-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, Ilan Tayari <ilant@mellanox.com>,
        Ariel Levkovich <lariel@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10041.outbound.protection.outlook.com ([40.107.1.41]:36016
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751835AbdFVMcU (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 22 Jun 2017 08:32:20 -0400
In-Reply-To: <20170622123159.8348-1-ilant@mellanox.com>
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
---
 net/ipv4/esp4.c         | 13 +++++++++++--
 net/ipv4/esp4_offload.c |  4 +++-
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 1f18b4650253..2eab0992b127 100644
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
@@ -568,7 +569,15 @@ int esp_input_done2(struct sk_buff *skb, int err)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	pskb_trim(skb, skb->len - alen - padlen - 2);
+	trimlen = alen + padlen + 2;
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		csumdiff = skb_checksum(skb, skb->len - trimlen, trimlen, 0);
+		skb->csum = csum_block_sub(skb->csum, csumdiff,
+					   skb->len - trimlen);
+		skb_postpull_rcsum(skb, skb->data, hlen);
+	}
+
+	pskb_trim(skb, skb->len - trimlen);
 	__skb_pull(skb, hlen);
 	if (x->props.mode == XFRM_MODE_TUNNEL)
 		skb_reset_transport_header(skb);
diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index e0666016a764..05831dea00f4 100644
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
2.11.0

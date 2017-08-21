From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 2/8] esp6: Support RX checksum with crypto offload
Date: Mon, 21 Aug 2017 07:49:27 +0200
Message-ID: <1503294573-10206-3-git-send-email-steffen.klassert@secunet.com>
References: <1503294573-10206-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:34910 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751094AbdHUFtm (ORCPT <rfc822;netdev@vger.kernel.org>);
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
 net/ipv6/esp6.c         | 14 +++++++++++---
 net/ipv6/esp6_offload.c |  4 +++-
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/ipv6/esp6.c b/net/ipv6/esp6.c
index 9ed3547..0ca1db6 100644
--- a/net/ipv6/esp6.c
+++ b/net/ipv6/esp6.c
@@ -470,7 +470,8 @@ int esp6_input_done2(struct sk_buff *skb, int err)
 	int hlen = sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead);
 	int elen = skb->len - hlen;
 	int hdr_len = skb_network_header_len(skb);
-	int padlen;
+	int padlen, trimlen;
+	__wsum csumdiff;
 	u8 nexthdr[2];
 
 	if (!xo || (xo && !(xo->flags & CRYPTO_DONE)))
@@ -492,8 +493,15 @@ int esp6_input_done2(struct sk_buff *skb, int err)
 
 	/* ... check padding bits here. Silly. :-) */
 
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
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index f02f131..eec3add 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -209,11 +209,13 @@ static struct sk_buff *esp6_gso_segment(struct sk_buff *skb,
 static int esp6_input_tail(struct xfrm_state *x, struct sk_buff *skb)
 {
 	struct crypto_aead *aead = x->data;
+	struct xfrm_offload *xo = xfrm_offload(skb);
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr) + crypto_aead_ivsize(aead)))
 		return -EINVAL;
 
-	skb->ip_summed = CHECKSUM_NONE;
+	if (!(xo->flags & CRYPTO_DONE))
+		skb->ip_summed = CHECKSUM_NONE;
 
 	return esp6_input_done2(skb, 0);
 }
-- 
2.7.4

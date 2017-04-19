From: <ilant@mellanox.com>
Subject: [PATCH ipsec-next] esp4/6: Fix GSO path for non-GSO SW-crypto packets
Date: Wed, 19 Apr 2017 08:41:01 +0300
Message-ID: <20170419054101.16738-1-ilant@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Boris Pismenny <borisp@mellanox.com>,
        Yevgeny Kliteynik <kliteyn@mellanox.com>,
        Yossi Kuperman <yossiku@mellanox.com>,
        Ilan Tayari <ilant@mellanox.com>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0040.outbound.protection.outlook.com ([104.47.2.40]:44947
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1759626AbdDSFlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Apr 2017 01:41:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ilan Tayari <ilant@mellanox.com>

If esp*_offload module is loaded, outbound packets take the
GSO code path, being encapsulated at layer 3, but encrypted
in layer 2. validate_xmit_xfrm calls esp*_xmit for that.

esp*_xmit was wrongfully detecting these packets as going
through hardware crypto offload, while in fact they should
be encrypted in software, causing plaintext leakage to
the network, and also dropping at the receiver side.

Perform the encryption in esp*_xmit, if the SA doesn't have
a hardware offload_handle.

Also, align esp6 code to esp4 logic.

Fixes: fca11ebde3f0 ("esp4: Reorganize esp_output")
Fixes: 383d0350f2cc ("esp6: Reorganize esp_output")
Signed-off-by: Ilan Tayari <ilant@mellanox.com>
---
 net/ipv4/esp4_offload.c | 4 ++--
 net/ipv6/esp6_offload.c | 7 ++++---
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/esp4_offload.c b/net/ipv4/esp4_offload.c
index f3e33c26dc33..e0666016a764 100644
--- a/net/ipv4/esp4_offload.c
+++ b/net/ipv4/esp4_offload.c
@@ -209,8 +209,8 @@ static int esp_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features_
 	if (!xo)
 		return -EINVAL;
 
-	if (!(features & NETIF_F_HW_ESP) ||
-	    (x->xso.offload_handle &&  x->xso.dev != skb->dev)) {
+	if (!(features & NETIF_F_HW_ESP) || !x->xso.offload_handle ||
+	    (x->xso.dev != skb->dev)) {
 		xo->flags |= CRYPTO_FALLBACK;
 		hw_offload = false;
 	}
diff --git a/net/ipv6/esp6_offload.c b/net/ipv6/esp6_offload.c
index 95f10728abaa..d950d43ba255 100644
--- a/net/ipv6/esp6_offload.c
+++ b/net/ipv6/esp6_offload.c
@@ -211,9 +211,10 @@ static int esp6_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features
 	if (!xo)
 		return -EINVAL;
 
-	if (!(features & NETIF_F_HW_ESP) ||
-	    (x->xso.offload_handle &&  x->xso.dev != skb->dev)) {
+	if (!(features & NETIF_F_HW_ESP) || !x->xso.offload_handle ||
+	    (x->xso.dev != skb->dev)) {
 		xo->flags |= CRYPTO_FALLBACK;
+		hw_offload = false;
 	}
 
 	esp.proto = xo->proto;
@@ -254,7 +255,7 @@ static int esp6_xmit(struct xfrm_state *x, struct sk_buff *skb,  netdev_features
 		ipv6_hdr(skb)->payload_len = htons(len);
 	}
 
-	if (x->xso.offload_handle && !(xo->flags & CRYPTO_FALLBACK))
+	if (hw_offload)
 		return 0;
 
 	esp.seqno = cpu_to_be64(xo->seq.low + ((u64)xo->seq.hi << 32));
-- 
2.11.0

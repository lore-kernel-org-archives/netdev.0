From: Li Yang <leoli@freescale.com>
Subject: [PATCH] gianfar: reallocate skb when headroom is not enough for fcb
Date: Wed, 25 Mar 2009 17:15:33 +0800
Message-ID: <1237972533-11195-1-git-send-email-leoli@freescale.com>
References: <20090325.000643.55804624.davem@davemloft.net>
Cc: netdev@vger.kernel.org, Li Yang <leoli@freescale.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:42823 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752991AbZCYIui (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Mar 2009 04:50:38 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id n2P8o6wX001070
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 01:50:36 -0700 (MST)
Received: from zch01exm26.fsl.freescale.net (zch01exm26.ap.freescale.net [10.192.129.221])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id n2P8o460009521
	for <netdev@vger.kernel.org>; Wed, 25 Mar 2009 03:50:05 -0500 (CDT)
In-Reply-To: <20090325.000643.55804624.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gianfar uses a hardware header FCB for offloading.  However when used
with bridging or IP forwarding, TX skb might not have enough headroom
for the FCB.  Reallocate skb for such cases.

Signed-off-by: Li Yang <leoli@freescale.com>
---
 drivers/net/gianfar.c |   31 +++++++++++++++++++++----------
 1 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 9831b3f..29dc4ee 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -1206,10 +1206,19 @@ static int gfar_enet_open(struct net_device *dev)
 	return err;
 }
 
-static inline struct txfcb *gfar_add_fcb(struct sk_buff *skb)
+static inline struct txfcb *gfar_add_fcb(struct sk_buff **skbp)
 {
-	struct txfcb *fcb = (struct txfcb *)skb_push (skb, GMAC_FCB_LEN);
-
+	struct txfcb *fcb;
+	struct sk_buff *skb = *skbp;
+
+	if (unlikely(skb_headroom(skb) < GMAC_FCB_LEN)) {
+		struct sk_buff *old_skb = skb;
+		skb = skb_realloc_headroom(old_skb, GMAC_FCB_LEN);
+		if (!skb)
+			return NULL;
+		dev_kfree_skb_any(old_skb);
+	}
+	fcb = (struct txfcb *)skb_push(skb, GMAC_FCB_LEN);
 	cacheable_memzero(fcb, GMAC_FCB_LEN);
 
 	return fcb;
@@ -1330,18 +1339,20 @@ static int gfar_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Set up checksumming */
 	if (CHECKSUM_PARTIAL == skb->ip_summed) {
-		fcb = gfar_add_fcb(skb);
-		lstatus |= BD_LFLAG(TXBD_TOE);
-		gfar_tx_checksum(skb, fcb);
+		fcb = gfar_add_fcb(&skb);
+		if (likely(fcb != NULL)) {
+			lstatus |= BD_LFLAG(TXBD_TOE);
+			gfar_tx_checksum(skb, fcb);
+		}
 	}
 
 	if (priv->vlgrp && vlan_tx_tag_present(skb)) {
-		if (unlikely(NULL == fcb)) {
-			fcb = gfar_add_fcb(skb);
+		if (unlikely(NULL == fcb))
+			fcb = gfar_add_fcb(&skb);
+		if (likely(fcb != NULL)) {
 			lstatus |= BD_LFLAG(TXBD_TOE);
+			gfar_tx_vlan(skb, fcb);
 		}
-
-		gfar_tx_vlan(skb, fcb);
 	}
 
 	/* setup the TxBD length and buffer pointer for the first BD */
-- 
1.5.4


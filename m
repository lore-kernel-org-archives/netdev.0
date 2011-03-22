From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 2/5] be2net: parse vid and vtm fields of rx-compl only if vlanf bit is set
Date: Tue, 22 Mar 2011 12:19:26 +0530
Message-ID: <4436e7a9-1d03-45ea-b511-f09eab2e9819@exht1.ad.emulex.com>
References: <1300776569-15586-1-git-send-email-sathya.perla@emulex.com>
 <1300776569-15586-2-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Sathya Perla <sathya.perla@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:5039 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753171Ab1CVGul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Mar 2011 02:50:41 -0400
In-Reply-To: <1300776569-15586-2-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 7a5d6a3..6616300 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1101,8 +1101,12 @@ static void be_parse_rx_compl_v1(struct be_adapter *adapter,
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, numfrags, compl);
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v1, cast_enc, compl);
-	rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtm, compl);
-	rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vlan_tag, compl);
+	if (rxcp->vlanf) {
+		rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vtm,
+				compl);
+		rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v1, vlan_tag,
+				compl);
+	}
 }
 
 static void be_parse_rx_compl_v0(struct be_adapter *adapter,
@@ -1127,8 +1131,12 @@ static void be_parse_rx_compl_v0(struct be_adapter *adapter,
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, numfrags, compl);
 	rxcp->pkt_type =
 		AMAP_GET_BITS(struct amap_eth_rx_compl_v0, cast_enc, compl);
-	rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtm, compl);
-	rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vlan_tag, compl);
+	if (rxcp->vlanf) {
+		rxcp->vtm = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vtm,
+				compl);
+		rxcp->vid = AMAP_GET_BITS(struct amap_eth_rx_compl_v0, vlan_tag,
+				compl);
+	}
 }
 
 static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
@@ -1150,15 +1158,19 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
 	else
 		be_parse_rx_compl_v0(adapter, compl, rxcp);
 
-	/* vlanf could be wrongly set in some cards. ignore if vtm is not set */
-	if ((adapter->function_mode & 0x400) && !rxcp->vtm)
-		rxcp->vlanf = 0;
+	if (rxcp->vlanf) {
+		/* vlanf could be wrongly set in some cards.
+		 * ignore if vtm is not set */
+		if ((adapter->function_mode & 0x400) && !rxcp->vtm)
+			rxcp->vlanf = 0;
 
-	if (!lancer_chip(adapter))
-		rxcp->vid = swab16(rxcp->vid);
+		if (!lancer_chip(adapter))
+			rxcp->vid = swab16(rxcp->vid);
 
-	if ((adapter->pvid == rxcp->vid) && !adapter->vlan_tag[rxcp->vid])
-		rxcp->vlanf = 0;
+		if ((adapter->pvid == rxcp->vid) &&
+			!adapter->vlan_tag[rxcp->vid])
+			rxcp->vlanf = 0;
+	}
 
 	/* As the compl has been parsed, reset it; we wont touch it again */
 	compl->dw[offsetof(struct amap_eth_rx_compl_v1, valid) / 32] = 0;
-- 
1.6.5.2


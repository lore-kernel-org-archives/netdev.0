From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next-2.6 3/6] be2net: parse vid and vtm fields of rx-compl only if vlanf bit is set
Date: Fri, 18 Mar 2011 18:50:59 +0530
Message-ID: <4370935b-9267-4cf5-a36f-88375bb3cb2c@exht1.ad.emulex.com>
References: <1300454462-1234-1-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-2-git-send-email-sathya.perla@emulex.com>
 <1300454462-1234-3-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sathya Perla <sathya.perla@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:9939 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756515Ab1CRNVj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 09:21:39 -0400
In-Reply-To: <1300454462-1234-3-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/benet/be_main.c |   34 +++++++++++++++++++++++-----------
 1 files changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 18c6da4..6be06df 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1096,8 +1096,12 @@ static void be_parse_rx_compl_v1(struct be_adapter *adapter,
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
@@ -1122,8 +1126,12 @@ static void be_parse_rx_compl_v0(struct be_adapter *adapter,
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
@@ -1145,15 +1153,19 @@ static struct be_rx_compl_info *be_rx_compl_get(struct be_rx_obj *rxo)
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


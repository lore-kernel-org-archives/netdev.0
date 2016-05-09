From: John Crispin <john@phrozen.org>
Subject: [PATCH V2 02/22] net-next: mediatek: fix gigabit and flow control advertisement
Date: Mon,  9 May 2016 12:03:54 +0200
Message-ID: <1462788254-40572-3-git-send-email-john@phrozen.org>
References: <1462788254-40572-1-git-send-email-john@phrozen.org>
Cc: nbd@nbd.name, netdev@vger.kernel.org,
	linux-mediatek@lists.infradead.org, John Crispin <john@phrozen.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:47298 "EHLO nbd.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbcEIKEa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 May 2016 06:04:30 -0400
In-Reply-To: <1462788254-40572-1-git-send-email-john@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current code will not setup the PHYs advertisement features correctly.
Fix this and properly advertise Gigabit features and properly handle
asymmetric pause frames.

Signed-off-by: John Crispin <john@phrozen.org>
---
 drivers/net/ethernet/mediatek/mtk_eth_soc.c |   16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mediatek/mtk_eth_soc.c b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
index 28f169f..a76aec20 100644
--- a/drivers/net/ethernet/mediatek/mtk_eth_soc.c
+++ b/drivers/net/ethernet/mediatek/mtk_eth_soc.c
@@ -133,6 +133,8 @@ static int mtk_mdio_read(struct mii_bus *bus, int phy_addr, int phy_reg)
 static void mtk_phy_link_adjust(struct net_device *dev)
 {
 	struct mtk_mac *mac = netdev_priv(dev);
+	u16 lcl_adv, rmt_adv = 0;
+	u8 flowctrl;
 	u32 mcr = MAC_MCR_MAX_RX_1536 | MAC_MCR_IPG_CFG |
 		  MAC_MCR_FORCE_MODE | MAC_MCR_TX_EN |
 		  MAC_MCR_RX_EN | MAC_MCR_BACKOFF_EN |
@@ -154,7 +156,16 @@ static void mtk_phy_link_adjust(struct net_device *dev)
 		mcr |= MAC_MCR_FORCE_DPX;
 
 	if (mac->phy_dev->pause)
-		mcr |= MAC_MCR_FORCE_RX_FC | MAC_MCR_FORCE_TX_FC;
+		rmt_adv = LPA_PAUSE_CAP;
+	if (mac->phy_dev->asym_pause)
+		rmt_adv |= LPA_PAUSE_ASYM;
+
+	lcl_adv = mii_advertise_flowctrl(FLOW_CTRL_RX | FLOW_CTRL_TX);
+	flowctrl = mii_resolve_flowctrl_fdx(lcl_adv, rmt_adv);
+	if (flowctrl & FLOW_CTRL_TX)
+		mcr |= MAC_MCR_FORCE_TX_FC;
+	if (flowctrl & FLOW_CTRL_RX)
+		mcr |= MAC_MCR_FORCE_RX_FC;
 
 	mtk_w32(mac->hw, mcr, MTK_MAC_MCR(mac->id));
 
@@ -236,7 +247,8 @@ static int mtk_phy_connect(struct mtk_mac *mac)
 	mac->phy_dev->autoneg = AUTONEG_ENABLE;
 	mac->phy_dev->speed = 0;
 	mac->phy_dev->duplex = 0;
-	mac->phy_dev->supported &= PHY_BASIC_FEATURES;
+	mac->phy_dev->supported &= PHY_GBIT_FEATURES | SUPPORTED_Pause |
+				   ~SUPPORTED_Asym_Pause;
 	mac->phy_dev->advertising = mac->phy_dev->supported |
 				    ADVERTISED_Autoneg;
 	phy_start_aneg(mac->phy_dev);
-- 
1.7.10.4

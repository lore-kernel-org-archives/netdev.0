From: Michael Chan <mchan@broadcom.com>
Subject: [PATCH net-next 3/4] bnx2: Report MDI/MDIX status to ethtool.
Date: Tue, 31 Dec 2013 23:22:34 -0800
Message-ID: <1388560955-32586-4-git-send-email-mchan@broadcom.com>
References: <1388560955-32586-1-git-send-email-mchan@broadcom.com>
 <1388560955-32586-2-git-send-email-mchan@broadcom.com>
 <1388560955-32586-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:57851 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbaAAG6s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 01:58:48 -0500
In-Reply-To: <1388560955-32586-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |   16 ++++++++++++++++
 drivers/net/ethernet/broadcom/bnx2.h |    4 ++++
 2 files changed, 20 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index b380c69..3fcabd9 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -1197,6 +1197,8 @@ bnx2_copper_linkup(struct bnx2 *bp)
 {
 	u32 bmcr;
 
+	bp->phy_flags &= ~BNX2_PHY_FLAG_MDIX;
+
 	bnx2_read_phy(bp, bp->mii_bmcr, &bmcr);
 	if (bmcr & BMCR_ANENABLE) {
 		u32 local_adv, remote_adv, common;
@@ -1255,6 +1257,14 @@ bnx2_copper_linkup(struct bnx2 *bp)
 		}
 	}
 
+	if (bp->link_up) {
+		u32 ext_status;
+
+		bnx2_read_phy(bp, MII_BNX2_EXT_STATUS, &ext_status);
+		if (ext_status & EXT_STATUS_MDIX)
+			bp->phy_flags |= BNX2_PHY_FLAG_MDIX;
+	}
+
 	return 0;
 }
 
@@ -6874,6 +6884,12 @@ bnx2_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 	if (netif_carrier_ok(dev)) {
 		ethtool_cmd_speed_set(cmd, bp->line_speed);
 		cmd->duplex = bp->duplex;
+		if (!(bp->phy_flags & BNX2_PHY_FLAG_SERDES)) {
+			if (bp->phy_flags & BNX2_PHY_FLAG_MDIX)
+				cmd->eth_tp_mdix = ETH_TP_MDI_X;
+			else
+				cmd->eth_tp_mdix = ETH_TP_MDI;
+		}
 	}
 	else {
 		ethtool_cmd_speed_set(cmd, -1);
diff --git a/drivers/net/ethernet/broadcom/bnx2.h b/drivers/net/ethernet/broadcom/bnx2.h
index 39f40d1..f1cf2c4 100644
--- a/drivers/net/ethernet/broadcom/bnx2.h
+++ b/drivers/net/ethernet/broadcom/bnx2.h
@@ -6471,6 +6471,9 @@ struct l2_fhdr {
 
 #define BCM5708S_TX_ACTL3			0x17
 
+#define MII_BNX2_EXT_STATUS			0x11
+#define EXT_STATUS_MDIX				 (1 << 13)
+
 #define MII_BNX2_AUX_CTL			0x18
 #define AUX_CTL_MISC_CTL			 0x7007
 #define AUX_CTL_MISC_CTL_WIRESPEED		  (1 << 4)
@@ -6850,6 +6853,7 @@ struct bnx2 {
 #define BNX2_PHY_FLAG_REMOTE_PHY_CAP		0x00000800
 #define BNX2_PHY_FLAG_FORCED_DOWN		0x00001000
 #define BNX2_PHY_FLAG_NO_PARALLEL		0x00002000
+#define BNX2_PHY_FLAG_MDIX			0x00004000
 
 	u32			mii_bmcr;
 	u32			mii_bmsr;
-- 
1.7.1

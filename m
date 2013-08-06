From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 3/6 net-next] bnx2: Refactor WoL setup into a separate
 function.
Date: Tue, 6 Aug 2013 15:50:09 -0700
Message-ID: <1375829412-26425-4-git-send-email-mchan@broadcom.com>
References: <1375829412-26425-1-git-send-email-mchan@broadcom.com>
 <1375829412-26425-2-git-send-email-mchan@broadcom.com>
 <1375829412-26425-3-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4097 "EHLO mms3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756691Ab3HFW2O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 18:28:14 -0400
In-Reply-To: <1375829412-26425-3-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separate MAC and PHY WoL setup code into a separate function.

Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2.c |  161 +++++++++++++++++-----------------
 1 files changed, 81 insertions(+), 80 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
index ac72f80..0b54ca0 100644
--- a/drivers/net/ethernet/broadcom/bnx2.c
+++ b/drivers/net/ethernet/broadcom/bnx2.c
@@ -3908,6 +3908,86 @@ init_cpu_err:
 	return rc;
 }
 
+static void
+bnx2_setup_wol(struct bnx2 *bp)
+{
+	int i;
+	u32 val, wol_msg;
+
+	if (bp->wol) {
+		u32 advertising;
+		u8 autoneg;
+
+		autoneg = bp->autoneg;
+		advertising = bp->advertising;
+
+		if (bp->phy_port == PORT_TP) {
+			bp->autoneg = AUTONEG_SPEED;
+			bp->advertising = ADVERTISED_10baseT_Half |
+				ADVERTISED_10baseT_Full |
+				ADVERTISED_100baseT_Half |
+				ADVERTISED_100baseT_Full |
+				ADVERTISED_Autoneg;
+		}
+
+		spin_lock_bh(&bp->phy_lock);
+		bnx2_setup_phy(bp, bp->phy_port);
+		spin_unlock_bh(&bp->phy_lock);
+
+		bp->autoneg = autoneg;
+		bp->advertising = advertising;
+
+		bnx2_set_mac_addr(bp, bp->dev->dev_addr, 0);
+
+		val = BNX2_RD(bp, BNX2_EMAC_MODE);
+
+		/* Enable port mode. */
+		val &= ~BNX2_EMAC_MODE_PORT;
+		val |= BNX2_EMAC_MODE_MPKT_RCVD |
+		       BNX2_EMAC_MODE_ACPI_RCVD |
+		       BNX2_EMAC_MODE_MPKT;
+		if (bp->phy_port == PORT_TP) {
+			val |= BNX2_EMAC_MODE_PORT_MII;
+		} else {
+			val |= BNX2_EMAC_MODE_PORT_GMII;
+			if (bp->line_speed == SPEED_2500)
+				val |= BNX2_EMAC_MODE_25G_MODE;
+		}
+
+		BNX2_WR(bp, BNX2_EMAC_MODE, val);
+
+		/* receive all multicast */
+		for (i = 0; i < NUM_MC_HASH_REGISTERS; i++) {
+			BNX2_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
+				0xffffffff);
+		}
+		BNX2_WR(bp, BNX2_EMAC_RX_MODE, BNX2_EMAC_RX_MODE_SORT_MODE);
+
+		val = 1 | BNX2_RPM_SORT_USER0_BC_EN | BNX2_RPM_SORT_USER0_MC_EN;
+		BNX2_WR(bp, BNX2_RPM_SORT_USER0, 0x0);
+		BNX2_WR(bp, BNX2_RPM_SORT_USER0, val);
+		BNX2_WR(bp, BNX2_RPM_SORT_USER0, val | BNX2_RPM_SORT_USER0_ENA);
+
+		/* Need to enable EMAC and RPM for WOL. */
+		BNX2_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
+			BNX2_MISC_ENABLE_SET_BITS_RX_PARSER_MAC_ENABLE |
+			BNX2_MISC_ENABLE_SET_BITS_TX_HEADER_Q_ENABLE |
+			BNX2_MISC_ENABLE_SET_BITS_EMAC_ENABLE);
+
+		val = BNX2_RD(bp, BNX2_RPM_CONFIG);
+		val &= ~BNX2_RPM_CONFIG_ACPI_ENA;
+		BNX2_WR(bp, BNX2_RPM_CONFIG, val);
+
+		wol_msg = BNX2_DRV_MSG_CODE_SUSPEND_WOL;
+	} else {
+			wol_msg = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
+	}
+
+	if (!(bp->flags & BNX2_FLAG_NO_WOL))
+		bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT3 | wol_msg, 1, 0);
+
+}
+
 static int
 bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 {
@@ -3929,86 +4009,7 @@ bnx2_set_power_state(struct bnx2 *bp, pci_power_t state)
 		break;
 	}
 	case PCI_D3hot: {
-		int i;
-		u32 val, wol_msg;
-
-		if (bp->wol) {
-			u32 advertising;
-			u8 autoneg;
-
-			autoneg = bp->autoneg;
-			advertising = bp->advertising;
-
-			if (bp->phy_port == PORT_TP) {
-				bp->autoneg = AUTONEG_SPEED;
-				bp->advertising = ADVERTISED_10baseT_Half |
-					ADVERTISED_10baseT_Full |
-					ADVERTISED_100baseT_Half |
-					ADVERTISED_100baseT_Full |
-					ADVERTISED_Autoneg;
-			}
-
-			spin_lock_bh(&bp->phy_lock);
-			bnx2_setup_phy(bp, bp->phy_port);
-			spin_unlock_bh(&bp->phy_lock);
-
-			bp->autoneg = autoneg;
-			bp->advertising = advertising;
-
-			bnx2_set_mac_addr(bp, bp->dev->dev_addr, 0);
-
-			val = BNX2_RD(bp, BNX2_EMAC_MODE);
-
-			/* Enable port mode. */
-			val &= ~BNX2_EMAC_MODE_PORT;
-			val |= BNX2_EMAC_MODE_MPKT_RCVD |
-			       BNX2_EMAC_MODE_ACPI_RCVD |
-			       BNX2_EMAC_MODE_MPKT;
-			if (bp->phy_port == PORT_TP)
-				val |= BNX2_EMAC_MODE_PORT_MII;
-			else {
-				val |= BNX2_EMAC_MODE_PORT_GMII;
-				if (bp->line_speed == SPEED_2500)
-					val |= BNX2_EMAC_MODE_25G_MODE;
-			}
-
-			BNX2_WR(bp, BNX2_EMAC_MODE, val);
-
-			/* receive all multicast */
-			for (i = 0; i < NUM_MC_HASH_REGISTERS; i++) {
-				BNX2_WR(bp, BNX2_EMAC_MULTICAST_HASH0 + (i * 4),
-					0xffffffff);
-			}
-			BNX2_WR(bp, BNX2_EMAC_RX_MODE,
-				BNX2_EMAC_RX_MODE_SORT_MODE);
-
-			val = 1 | BNX2_RPM_SORT_USER0_BC_EN |
-			      BNX2_RPM_SORT_USER0_MC_EN;
-			BNX2_WR(bp, BNX2_RPM_SORT_USER0, 0x0);
-			BNX2_WR(bp, BNX2_RPM_SORT_USER0, val);
-			BNX2_WR(bp, BNX2_RPM_SORT_USER0, val |
-				BNX2_RPM_SORT_USER0_ENA);
-
-			/* Need to enable EMAC and RPM for WOL. */
-			BNX2_WR(bp, BNX2_MISC_ENABLE_SET_BITS,
-				BNX2_MISC_ENABLE_SET_BITS_RX_PARSER_MAC_ENABLE |
-				BNX2_MISC_ENABLE_SET_BITS_TX_HEADER_Q_ENABLE |
-				BNX2_MISC_ENABLE_SET_BITS_EMAC_ENABLE);
-
-			val = BNX2_RD(bp, BNX2_RPM_CONFIG);
-			val &= ~BNX2_RPM_CONFIG_ACPI_ENA;
-			BNX2_WR(bp, BNX2_RPM_CONFIG, val);
-
-			wol_msg = BNX2_DRV_MSG_CODE_SUSPEND_WOL;
-		}
-		else {
-			wol_msg = BNX2_DRV_MSG_CODE_SUSPEND_NO_WOL;
-		}
-
-		if (!(bp->flags & BNX2_FLAG_NO_WOL))
-			bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT3 | wol_msg,
-				     1, 0);
-
+		bnx2_setup_wol(bp);
 		pci_wake_from_d3(bp->pdev, bp->wol);
 		if ((BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A0) ||
 		    (BNX2_CHIP_ID(bp) == BNX2_CHIP_ID_5706_A1)) {
-- 
1.7.1

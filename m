From: Yaniv Rosner <yanivr@broadcom.com>
Subject: [PATCH net 1/5] bnx2x: Fix 578xx-KR 1G link
Date: Wed, 1 Jan 2014 11:06:41 +0200
Message-ID: <1388567205-20210-2-git-send-email-yanivr@broadcom.com>
References: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev <netdev@vger.kernel.org>,
	Yaniv Rosner <yanivr@broadcom.com>,
	Ariel Elior <ariele@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:31603 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752986AbaAAJIF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 04:08:05 -0500
In-Reply-To: <1388567205-20210-1-git-send-email-yanivr@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a problem where 578xx-KR is unable to get link when connected to 1G link
partner. Two fixes were required:
One was to force CL37 sync_status low to prevent Warpcore from getting stuck in
CL73 parallel detect loop while link partner is sending.
Second fix was to enable auto-detect mode, thus allowing the Warpcore to select
the higher speed protocol between 10G-KR (over CL73), or go down to 1G over CL73
when there's indication for it.

Signed-off-by: Yaniv Rosner <yanivr@broadcom.com>
Signed-off-by: Ariel Elior <ariele@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c |   13 +++++++++++++
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h  |    1 +
 2 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
index 20dcc02..efbf729 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_link.c
@@ -3865,6 +3865,19 @@ static void bnx2x_warpcore_enable_AN_KR(struct bnx2x_phy *phy,
 
 		bnx2x_warpcore_enable_AN_KR2(phy, params, vars);
 	} else {
+		/* Enable Auto-Detect to support 1G over CL37 as well */
+		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_SERDESDIGITAL_CONTROL1000X1, 0x10);
+
+		/* Force cl48 sync_status LOW to avoid getting stuck in CL73
+		 * parallel-detect loop when CL73 and CL37 are enabled.
+		 */
+		CL22_WR_OVER_CL45(bp, phy, MDIO_REG_BANK_AER_BLOCK,
+				  MDIO_AER_BLOCK_AER_REG, 0);
+		bnx2x_cl45_write(bp, phy, MDIO_WC_DEVAD,
+				 MDIO_WC_REG_RXB_ANA_RX_CONTROL_PCI, 0x0800);
+		bnx2x_set_aer_mmd(params, phy);
+
 		bnx2x_disable_kr2(params, vars, phy);
 	}
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
index 3efbb35..14ffb6e 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_reg.h
@@ -7179,6 +7179,7 @@ Theotherbitsarereservedandshouldbezero*/
 #define MDIO_WC_REG_RX1_PCI_CTRL			0x80ca
 #define MDIO_WC_REG_RX2_PCI_CTRL			0x80da
 #define MDIO_WC_REG_RX3_PCI_CTRL			0x80ea
+#define MDIO_WC_REG_RXB_ANA_RX_CONTROL_PCI		0x80fa
 #define MDIO_WC_REG_XGXSBLK2_UNICORE_MODE_10G		0x8104
 #define MDIO_WC_REG_XGXS_STATUS3			0x8129
 #define MDIO_WC_REG_PAR_DET_10G_STATUS			0x8130
-- 
1.7.1

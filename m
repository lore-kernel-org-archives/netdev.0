From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 6/8] amd-xgbe-phy: Updates to KR training initiation
Date: Fri, 25 Jul 2014 16:11:27 -0500
Message-ID: <20140725211127.32358.45712.stgit@tlendack-t1.amdoffice.net>
References: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0235.outbound.protection.outlook.com ([207.46.163.235]:40271
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S934542AbaGYVLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 17:11:33 -0400
In-Reply-To: <20140725211052.32358.54337.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As part of changing rates to KR mode, KR training is initiated. If
the KR training is restarted it is possible to enter an invalid logic
state. This can be avoided by asserting a training reset bit before
initiating the KR training and then clearing the training reset bit.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index a2d778a..39428e5 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -119,10 +119,13 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #endif
 
 /* SerDes integration register offsets */
+#define SIR0_KR_RT_1			0x002c
 #define SIR0_STATUS			0x0040
 #define SIR1_SPEED			0x0000
 
 /* SerDes integration register entry bit positions and sizes */
+#define SIR0_KR_RT_1_RESET_INDEX	11
+#define SIR0_KR_RT_1_RESET_WIDTH	1
 #define SIR0_STATUS_RX_READY_INDEX	0
 #define SIR0_STATUS_RX_READY_WIDTH	1
 #define SIR0_STATUS_TX_READY_INDEX	8
@@ -636,9 +639,13 @@ static enum amd_xgbe_phy_an amd_xgbe_an_tx_training(struct phy_device *phydev,
 	if (ret < 0)
 		return AMD_XGBE_AN_ERROR;
 
+	XSIR0_IOWRITE_BITS(priv, SIR0_KR_RT_1, RESET, 1);
+
 	ret |= 0x01;
 	phy_write_mmd(phydev, MDIO_MMD_PMAPMD, MDIO_PMA_10GBR_PMD_CTRL, ret);
 
+	XSIR0_IOWRITE_BITS(priv, SIR0_KR_RT_1, RESET, 0);
+
 	return AMD_XGBE_AN_EVENT;
 }
 

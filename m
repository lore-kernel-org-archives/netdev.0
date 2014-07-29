From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v2 5/8] amd-xgbe-phy: Updates to rate change complete
 check
Date: Tue, 29 Jul 2014 08:57:37 -0500
Message-ID: <20140729135737.2791.47692.stgit@tlendack-t1.amdoffice.net>
References: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1lp0140.outbound.protection.outlook.com ([207.46.163.140]:18927
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753759AbaG2N5p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2014 09:57:45 -0400
In-Reply-To: <20140729135707.2791.75918.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the logic will loop endlessly waiting for a rate change
to complete.  Add a counter so that if the rate change signals
never indicate complete the loop will eventually exit.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |   27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index b35293d..a2d778a 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -95,6 +95,8 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XNP_MP_FORMATTED		(1 << 13)
 #define XNP_NP_EXCHANGE			(1 << 15)
 
+#define XGBE_PHY_RATECHANGE_COUNT	100
+
 #ifndef MDIO_PMA_10GBR_PMD_CTRL
 #define MDIO_PMA_10GBR_PMD_CTRL		0x0096
 #endif
@@ -193,6 +195,16 @@ do {									\
 	(_var) |= (((_val) & ((0x1 << (_width)) - 1)) << (_index));	\
 } while (0)
 
+#define XSIR_GET_BITS(_var, _prefix, _field)				\
+	GET_BITS((_var),						\
+		 _prefix##_##_field##_INDEX,				\
+		 _prefix##_##_field##_WIDTH)
+
+#define XSIR_SET_BITS(_var, _prefix, _field, _val)			\
+	SET_BITS((_var),						\
+		 _prefix##_##_field##_INDEX,				\
+		 _prefix##_##_field##_WIDTH, (_val))
+
 /* Macros for reading or writing SerDes integration registers
  *  The ioread macros will get bit fields or full values using the
  *  register definitions formed using the input names
@@ -387,14 +399,25 @@ static void amd_xgbe_phy_serdes_start_ratechange(struct phy_device *phydev)
 static void amd_xgbe_phy_serdes_complete_ratechange(struct phy_device *phydev)
 {
 	struct amd_xgbe_phy_priv *priv = phydev->priv;
+	unsigned int wait;
+	u16 status;
 
 	/* Release Rx and Tx ratechange */
 	XSIR1_IOWRITE_BITS(priv, SIR1_SPEED, RATECHANGE, 0);
 
 	/* Wait for Rx and Tx ready */
-	while (!XSIR0_IOREAD_BITS(priv, SIR0_STATUS, RX_READY) &&
-	       !XSIR0_IOREAD_BITS(priv, SIR0_STATUS, TX_READY))
+	wait = XGBE_PHY_RATECHANGE_COUNT;
+	while (wait--) {
 		usleep_range(10, 20);
+
+		status = XSIR0_IOREAD(priv, SIR0_STATUS);
+		if (XSIR_GET_BITS(status, SIR0_STATUS, RX_READY) &&
+		    XSIR_GET_BITS(status, SIR0_STATUS, TX_READY))
+			return;
+	}
+
+	netdev_err(phydev->attached_dev, "SerDes rx/tx not ready (%#hx)\n",
+		   status);
 }
 
 static int amd_xgbe_phy_xgmii_mode(struct phy_device *phydev)

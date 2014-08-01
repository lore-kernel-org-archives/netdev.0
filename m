From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next 2/2] amd-xgbe-phy: Allow more time for Rx/Tx to
 become ready
Date: Fri, 1 Aug 2014 11:56:36 -0500
Message-ID: <20140801165636.20602.82088.stgit@tlendack-t1.amdoffice.net>
References: <20140801165623.20602.457.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2lp0237.outbound.protection.outlook.com ([207.46.163.237]:45809
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755240AbaHAQ4l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Aug 2014 12:56:41 -0400
In-Reply-To: <20140801165623.20602.457.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current time range waiting for Rx/Tx to become ready can sometimes
be too short if a connection is not present.  Increase the number of
retries and the sleep to give a bit more time. Also, change level of
the message issued from _err to _dbg if Rx/Tx do not become ready
since the underlying logic will function as if no link is established
and retry eventually.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/phy/amd-xgbe-phy.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/phy/amd-xgbe-phy.c b/drivers/net/phy/amd-xgbe-phy.c
index 388e302..f3230ee 100644
--- a/drivers/net/phy/amd-xgbe-phy.c
+++ b/drivers/net/phy/amd-xgbe-phy.c
@@ -95,7 +95,7 @@ MODULE_DESCRIPTION("AMD 10GbE (amd-xgbe) PHY driver");
 #define XNP_MP_FORMATTED		(1 << 13)
 #define XNP_NP_EXCHANGE			(1 << 15)
 
-#define XGBE_PHY_RATECHANGE_COUNT	100
+#define XGBE_PHY_RATECHANGE_COUNT	500
 
 #ifndef MDIO_PMA_10GBR_PMD_CTRL
 #define MDIO_PMA_10GBR_PMD_CTRL		0x0096
@@ -411,7 +411,7 @@ static void amd_xgbe_phy_serdes_complete_ratechange(struct phy_device *phydev)
 	/* Wait for Rx and Tx ready */
 	wait = XGBE_PHY_RATECHANGE_COUNT;
 	while (wait--) {
-		usleep_range(10, 20);
+		usleep_range(50, 75);
 
 		status = XSIR0_IOREAD(priv, SIR0_STATUS);
 		if (XSIR_GET_BITS(status, SIR0_STATUS, RX_READY) &&
@@ -419,7 +419,7 @@ static void amd_xgbe_phy_serdes_complete_ratechange(struct phy_device *phydev)
 			return;
 	}
 
-	netdev_err(phydev->attached_dev, "SerDes rx/tx not ready (%#hx)\n",
+	netdev_dbg(phydev->attached_dev, "SerDes rx/tx not ready (%#hx)\n",
 		   status);
 }
 

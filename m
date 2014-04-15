From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: [PATCH 2/3] net: mvneta: properly configure the MAC <-> PHY connection in all situations
Date: Tue, 15 Apr 2014 15:50:20 +0200
Message-ID: <1397569821-5530-3-git-send-email-thomas.petazzoni@free-electrons.com>
References: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Lior Amsalem <alior@marvell.com>,
	Dmitri Epshtein <dima@marvell.com>,
	Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
	George Joseph <george.joseph@fairview5.com>, arno@natisbad.org,
	Willy Tarreau <w@1wt.eu>,
	Alexander Reuter <Alexander.Reuter@gmx.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:40754 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753506AbaDONu2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Apr 2014 09:50:28 -0400
In-Reply-To: <1397569821-5530-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 5445eaf309ff ('mvneta: Try to fix mvneta when compiled as
module') fixed the mvneta driver to make it work properly when loaded
as a module in SGMII configuration, which was tested successful by the
author on the Armada XP OpenBlocks AX3, which uses SGMII.

However, some other platforms, namely the Armada XP GP don't use
SGMII, but a QSGMII connection between the MAC and the PHY, and this
case was not supported by the mvneta driver, which was relying on
configuration put in place by the bootloader. While this works when
the mvneta driver is built-in (because clocks are not gated), it
breaks when mvneta is built as a module, because the clock is gated
(all configuration is lost) and then re-enabled when the mvneta driver
is loaded.

In order to support all of RGMII, SGMII and QSGMII, this commit
reworks how the PHY interface configuration is done, and simplifies
it: it removes the mvneta_port_sgmii_config() and
mvneta_gmac_rgmii_set() functions, which were strange because
mvneta_gmac_rgmii_set() was called in all cases, even for SGMII
configurations. Also, the mvneta_gmac_rgmii_set() function was taking
a boolean as argument, which was always true.

Instead, all the PHY interface configuration logic is moved into the
mvneta_port_power_up() function, in a much simpler 'switch' construct,
with four cases:

 - QSGMII: the RGMIIEn bit, the PCSEn bit in GMAC_CTRL_2 are set, and
   the SERDES is configured in QSGMII. Technically speaking,
   configuring the SERDES of the first port would be sufficient, but
   it is simpler to do it on all ports.

 - SGMII: the RGMIIEn bit, the PCSEn bit in GMAC_CTRL_2 are set, and
   the SERDES is configured as SGMII.

 - RGMII: the RGMIIEn bit in GMAC_CTRL_2 is set. The PCSEn bit is kept
   cleared, and no SERDES configuration is done, because RGMII is not
   using SERDES lanes.

 - other: an error is returned. For this reason, the
   mvneta_port_power_up() now returns an int instead of nothing, and
   the return value is checked by mvneta_probe().

This has been successfully tested on:

 * Armada XP DB, which has two RGMII and two SGMII connections
 * Armada XP GP, which uses QSGMII for its four interfaces
 * Armada 370 Mirabox, which has two RGMII connections

Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 73 ++++++++++++++++-------------------
 1 file changed, 34 insertions(+), 39 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b248bcb..14786c8 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -89,8 +89,9 @@
 #define      MVNETA_TX_IN_PRGRS                  BIT(1)
 #define      MVNETA_TX_FIFO_EMPTY                BIT(8)
 #define MVNETA_RX_MIN_FRAME_SIZE                 0x247c
-#define MVNETA_SGMII_SERDES_CFG			 0x24A0
+#define MVNETA_SERDES_CFG			 0x24A0
 #define      MVNETA_SGMII_SERDES_PROTO		 0x0cc7
+#define      MVNETA_QSGMII_SERDES_PROTO		 0x0667
 #define MVNETA_TYPE_PRIO                         0x24bc
 #define      MVNETA_FORCE_UNI                    BIT(21)
 #define MVNETA_TXQ_CMD_1                         0x24e4
@@ -711,35 +712,6 @@ static void mvneta_rxq_bm_disable(struct mvneta_port *pp,
 	mvreg_write(pp, MVNETA_RXQ_CONFIG_REG(rxq->id), val);
 }
 
-
-
-/* Sets the RGMII Enable bit (RGMIIEn) in port MAC control register */
-static void mvneta_gmac_rgmii_set(struct mvneta_port *pp, int enable)
-{
-	u32  val;
-
-	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
-
-	if (enable)
-		val |= MVNETA_GMAC2_PORT_RGMII;
-	else
-		val &= ~MVNETA_GMAC2_PORT_RGMII;
-
-	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
-}
-
-/* Config SGMII port */
-static void mvneta_port_sgmii_config(struct mvneta_port *pp)
-{
-	u32 val;
-
-	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
-	val |= MVNETA_GMAC2_PCS_ENABLE;
-	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
-
-	mvreg_write(pp, MVNETA_SGMII_SERDES_CFG, MVNETA_SGMII_SERDES_PROTO);
-}
-
 /* Start the Ethernet port RX and TX activity */
 static void mvneta_port_up(struct mvneta_port *pp)
 {
@@ -2749,26 +2721,44 @@ static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
 }
 
 /* Power up the port */
-static void mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
+static int mvneta_port_power_up(struct mvneta_port *pp, int phy_mode)
 {
-	u32 val;
+	u32 ctrl;
 
 	/* MAC Cause register should be cleared */
 	mvreg_write(pp, MVNETA_UNIT_INTR_CAUSE, 0);
 
-	if (phy_mode == PHY_INTERFACE_MODE_SGMII)
-		mvneta_port_sgmii_config(pp);
+	ctrl = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
 
-	mvneta_gmac_rgmii_set(pp, 1);
+	/* Even though it might look weird, when we're configured in
+	 * SGMII or QSGMII mode, the RGMII bit needs to be set.
+	 */
+	switch(phy_mode) {
+	case PHY_INTERFACE_MODE_QSGMII:
+		mvreg_write(pp, MVNETA_SERDES_CFG, MVNETA_QSGMII_SERDES_PROTO);
+		ctrl |= MVNETA_GMAC2_PCS_ENABLE | MVNETA_GMAC2_PORT_RGMII;
+		break;
+	case PHY_INTERFACE_MODE_SGMII:
+		mvreg_write(pp, MVNETA_SERDES_CFG, MVNETA_SGMII_SERDES_PROTO);
+		ctrl |= MVNETA_GMAC2_PCS_ENABLE | MVNETA_GMAC2_PORT_RGMII;
+		break;
+	case PHY_INTERFACE_MODE_RGMII:
+	case PHY_INTERFACE_MODE_RGMII_ID:
+		ctrl |= MVNETA_GMAC2_PORT_RGMII;
+		break;
+	default:
+		return -EINVAL;
+	}
 
 	/* Cancel Port Reset */
-	val = mvreg_read(pp, MVNETA_GMAC_CTRL_2);
-	val &= ~MVNETA_GMAC2_PORT_RESET;
-	mvreg_write(pp, MVNETA_GMAC_CTRL_2, val);
+	ctrl &= ~MVNETA_GMAC2_PORT_RESET;
+	mvreg_write(pp, MVNETA_GMAC_CTRL_2, ctrl);
 
 	while ((mvreg_read(pp, MVNETA_GMAC_CTRL_2) &
 		MVNETA_GMAC2_PORT_RESET) != 0)
 		continue;
+
+	return 0;
 }
 
 /* Device initialization routine */
@@ -2879,7 +2869,12 @@ static int mvneta_probe(struct platform_device *pdev)
 		dev_err(&pdev->dev, "can't init eth hal\n");
 		goto err_free_stats;
 	}
-	mvneta_port_power_up(pp, phy_mode);
+
+	err = mvneta_port_power_up(pp, phy_mode);
+	if (err < 0) {
+		dev_err(&pdev->dev, "can't power up port\n");
+		goto err_deinit;
+	}
 
 	dram_target_info = mv_mbus_dram_info();
 	if (dram_target_info)
-- 
1.8.3.2

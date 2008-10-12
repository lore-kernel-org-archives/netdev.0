From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] net/bfin_mac.c MDIO namespace fixes
Date: Sun, 12 Oct 2008 14:37:37 +0300
Message-ID: <20081012113737.GF31153@cs181140183.pp.htv.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	cooloney@kernel.org
To: Lennert Buytenhek <buytenh@marvell.com>,
	"David S. Miller" <davem@davemloft.net>, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6.pp.htv.fi ([213.243.153.40]:43734 "EHLO smtp6.pp.htv.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615AbYJLLie (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Oct 2008 07:38:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 2e888103295f47b8fcbf7e9bb8c5da97dd2ecd76
(phylib: add mdiobus_{read,write}) causes the
following compile error:

<--  snip  -->

...
  CC      drivers/net/bfin_mac.o
drivers/net/bfin_mac.c:272: error: conflicting types for 'mdiobus_read'
include/linux/phy.h:130: error: previous declaration of 'mdiobus_read' was here
drivers/net/bfin_mac.c:287: error: conflicting types for 'mdiobus_write'
include/linux/phy.h:131: error: previous declaration of 'mdiobus_write' was here
make[3]: *** [drivers/net/bfin_mac.o] Error 1

<--  snip  -->

This patch prefixes the driver functions with bfin_


Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 drivers/net/bfin_mac.c |   26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
index a0d41c5..b458d60 100644
--- a/drivers/net/bfin_mac.c
+++ b/drivers/net/bfin_mac.c
@@ -253,7 +253,7 @@ init_error:
  * MII operations
  */
 /* Wait until the previous MDC/MDIO transaction has completed */
-static void mdio_poll(void)
+static void bfin_mdio_poll(void)
 {
 	int timeout_cnt = MAX_TIMEOUT_CNT;
 
@@ -269,25 +269,25 @@ static void mdio_poll(void)
 }
 
 /* Read an off-chip register in a PHY through the MDC/MDIO port */
-static int mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
+static int bfin_mdiobus_read(struct mii_bus *bus, int phy_addr, int regnum)
 {
-	mdio_poll();
+	bfin_mdio_poll();
 
 	/* read mode */
 	bfin_write_EMAC_STAADD(SET_PHYAD((u16) phy_addr) |
 				SET_REGAD((u16) regnum) |
 				STABUSY);
 
-	mdio_poll();
+	bfin_mdio_poll();
 
 	return (int) bfin_read_EMAC_STADAT();
 }
 
 /* Write an off-chip register in a PHY through the MDC/MDIO port */
-static int mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
-			 u16 value)
+static int bfin_mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
+			      u16 value)
 {
-	mdio_poll();
+	bfin_mdio_poll();
 
 	bfin_write_EMAC_STADAT((u32) value);
 
@@ -297,12 +297,12 @@ static int mdiobus_write(struct mii_bus *bus, int phy_addr, int regnum,
 				STAOP |
 				STABUSY);
 
-	mdio_poll();
+	bfin_mdio_poll();
 
 	return 0;
 }
 
-static int mdiobus_reset(struct mii_bus *bus)
+static int bfin_mdiobus_reset(struct mii_bus *bus)
 {
 	return 0;
 }
@@ -818,7 +818,7 @@ static void bfin_mac_enable(void)
 	bfin_write_DMA1_CONFIG(rx_list_head->desc_a.config);
 
 	/* Wait MII done */
-	mdio_poll();
+	bfin_mdio_poll();
 
 	/* We enable only RX here */
 	/* ASTP   : Enable Automatic Pad Stripping
@@ -1063,9 +1063,9 @@ static int __devinit bfin_mac_probe(struct platform_device *pdev)
 		goto out_err_mdiobus_alloc;
 
 	lp->mii_bus->priv = ndev;
-	lp->mii_bus->read = mdiobus_read;
-	lp->mii_bus->write = mdiobus_write;
-	lp->mii_bus->reset = mdiobus_reset;
+	lp->mii_bus->read = bfin_mdiobus_read;
+	lp->mii_bus->write = bfin_mdiobus_write;
+	lp->mii_bus->reset = bfin_mdiobus_reset;
 	lp->mii_bus->name = "bfin_mac_mdio";
 	snprintf(lp->mii_bus->id, MII_BUS_ID_SIZE, "0");
 	lp->mii_bus->irq = kmalloc(sizeof(int)*PHY_MAX_ADDR, GFP_KERNEL);


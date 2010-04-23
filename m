From: Andy Fleming <afleming@freescale.com>
Subject: [RFC 2/2] phylib: Convert MDIO bitbang to new MDIO 45 format
Date: Thu, 22 Apr 2010 23:38:17 -0500
Message-ID: <1271997497-6896-3-git-send-email-afleming@freescale.com>
References: <1271997497-6896-1-git-send-email-afleming@freescale.com>
 <1271997497-6896-2-git-send-email-afleming@freescale.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:56147 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754885Ab0DWEiV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 00:38:21 -0400
In-Reply-To: <1271997497-6896-2-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we've added somewhat more complete MDIO 45 support to the PHY
Lib, convert the MDIO bitbang driver to use this new infrastructure.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/phy/mdio-bitbang.c |   23 +++++++++++------------
 1 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index 2f6f02e..4c0c89b 100644
--- a/drivers/net/phy/mdio-bitbang.c
+++ b/drivers/net/phy/mdio-bitbang.c
@@ -134,11 +134,10 @@ static void mdiobb_cmd(struct mdiobb_ctrl *ctrl, int op, u8 phy, u8 reg)
    MII_ADDR_C45 into the address. Theoretically clause 45 and normal devices
    can exist on the same bus. Normal devices should ignore the MDIO_ADDR
    phase. */
-static int mdiobb_cmd_addr(struct mdiobb_ctrl *ctrl, int phy, u32 addr)
+static void mdiobb_cmd_addr(struct mdiobb_ctrl *ctrl, int phy, int devad,
+				int reg)
 {
-	unsigned int dev_addr = (addr >> 16) & 0x1F;
-	unsigned int reg = addr & 0xFFFF;
-	mdiobb_cmd(ctrl, MDIO_C45_ADDR, phy, dev_addr);
+	mdiobb_cmd(ctrl, MDIO_C45_ADDR, phy, devad);
 
 	/* send the turnaround (10) */
 	mdiobb_send_bit(ctrl, 1);
@@ -148,8 +147,6 @@ static int mdiobb_cmd_addr(struct mdiobb_ctrl *ctrl, int phy, u32 addr)
 
 	ctrl->ops->set_mdio_dir(ctrl, 0);
 	mdiobb_get_bit(ctrl);
-
-	return dev_addr;
 }
 
 static int mdiobb_read(struct mii_bus *bus, int phy, int devad, int reg)
@@ -157,9 +154,10 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int devad, int reg)
 	struct mdiobb_ctrl *ctrl = bus->priv;
 	int ret, i;
 
-	if (reg & MII_ADDR_C45) {
-		reg = mdiobb_cmd_addr(ctrl, phy, reg);
-		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, reg);
+	/* Clause 22 PHYs only use devad = 0, and Clause 45 only use nonzero */
+	if (devad) {
+		mdiobb_cmd_addr(ctrl, phy, devad, reg);
+		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, devad);
 	} else
 		mdiobb_cmd(ctrl, MDIO_READ, phy, reg);
 
@@ -186,9 +184,10 @@ static int mdiobb_write(struct mii_bus *bus, int phy, int devad, int reg,
 {
 	struct mdiobb_ctrl *ctrl = bus->priv;
 
-	if (reg & MII_ADDR_C45) {
-		reg = mdiobb_cmd_addr(ctrl, phy, reg);
-		mdiobb_cmd(ctrl, MDIO_C45_WRITE, phy, reg);
+	/* Clause 22 PHYs only use devad = 0, and Clause 45 only use nonzero */
+	if (devad) {
+		mdiobb_cmd_addr(ctrl, phy, devad, reg);
+		mdiobb_cmd(ctrl, MDIO_C45_WRITE, phy, devad);
 	} else
 		mdiobb_cmd(ctrl, MDIO_WRITE, phy, reg);
 
-- 
1.6.5.2.g6ff9a


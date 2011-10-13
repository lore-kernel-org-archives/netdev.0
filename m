From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH v3 2/3] phylib: Convert MDIO bitbang to new MDIO 45 format
Date: Thu, 13 Oct 2011 09:37:39 -0500
Message-ID: <1318516660-25452-3-git-send-email-afleming@freescale.com>
References: <1318516660-25452-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from am1ehsobe003.messaging.microsoft.com ([213.199.154.206]:58812
	"EHLO AM1EHSOBE003.bigfish.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755481Ab1JMOiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Oct 2011 10:38:24 -0400
In-Reply-To: <1318516660-25452-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now that we've added somewhat more complete MDIO 45 support to the PHY
Lib, convert the MDIO bitbang driver to use this new infrastructure.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
v2: rebase on top of tree
v3: Make patch series more coherent

 drivers/net/phy/mdio-bitbang.c |   29 +++++++++++++++--------------
 1 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/phy/mdio-bitbang.c b/drivers/net/phy/mdio-bitbang.c
index 2f6f02e..df7f496 100644
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
@@ -157,11 +154,13 @@ static int mdiobb_read(struct mii_bus *bus, int phy, int devad, int reg)
 	struct mdiobb_ctrl *ctrl = bus->priv;
 	int ret, i;
 
-	if (reg & MII_ADDR_C45) {
-		reg = mdiobb_cmd_addr(ctrl, phy, reg);
-		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, reg);
-	} else
+	/* Clause 22 PHYs don't have a devad */
+	if (devad == MDIO_DEVAD_NONE)
 		mdiobb_cmd(ctrl, MDIO_READ, phy, reg);
+	else {
+		mdiobb_cmd_addr(ctrl, phy, devad, reg);
+		mdiobb_cmd(ctrl, MDIO_C45_READ, phy, devad);
+	}
 
 	ctrl->ops->set_mdio_dir(ctrl, 0);
 
@@ -186,11 +185,13 @@ static int mdiobb_write(struct mii_bus *bus, int phy, int devad, int reg,
 {
 	struct mdiobb_ctrl *ctrl = bus->priv;
 
-	if (reg & MII_ADDR_C45) {
-		reg = mdiobb_cmd_addr(ctrl, phy, reg);
-		mdiobb_cmd(ctrl, MDIO_C45_WRITE, phy, reg);
-	} else
+	/* Clause 22 PHYs don't have a devad */
+	if (devad == MDIO_DEVAD_NONE)
 		mdiobb_cmd(ctrl, MDIO_WRITE, phy, reg);
+	else {
+		mdiobb_cmd_addr(ctrl, phy, devad, reg);
+		mdiobb_cmd(ctrl, MDIO_C45_WRITE, phy, devad);
+	}
 
 	/* send the turnaround (10) */
 	mdiobb_send_bit(ctrl, 1);
-- 
1.7.3.4

From: Andy Fleming <afleming@freescale.com>
Subject: [PATCH] Fix PHY Lib support for gianfar and ucc_geth
Date: Tue,  5 Feb 2008 16:35:30 -0600
Message-ID: <12022509302322-git-send-email-afleming@freescale.com>
Cc: Andy Fleming <afleming@freescale.com>
To: jeff@garzik.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from de01egw02.freescale.net ([192.88.165.103]:46775 "EHLO
	de01egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762244AbYBEWfs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Feb 2008 17:35:48 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The PHY Lib now uses mutexes instead of spin_locks.  ucc_geth
and gianfar both grab the locks in their mdio_reset functions,
so they need to use mutex_(un)lock instead.  This was not caught
until someone tested it on an SMP system.

Signed-off-by: Andy Fleming <afleming@freescale.com>
---
 drivers/net/gianfar_mii.c  |    4 ++--
 drivers/net/ucc_geth_mii.c |    4 ++--
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 100bf41..6a647d9 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -127,7 +127,7 @@ int gfar_mdio_reset(struct mii_bus *bus)
 	struct gfar_mii __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
 
-	spin_lock_bh(&bus->mdio_lock);
+	mutex_lock(&bus->mdio_lock);
 
 	/* Reset the management interface */
 	gfar_write(&regs->miimcfg, MIIMCFG_RESET);
@@ -140,7 +140,7 @@ int gfar_mdio_reset(struct mii_bus *bus)
 			timeout--)
 		cpu_relax();
 
-	spin_unlock_bh(&bus->mdio_lock);
+	mutex_unlock(&bus->mdio_lock);
 
 	if(timeout <= 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index e3ba14a..c69e654 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -109,7 +109,7 @@ int uec_mdio_reset(struct mii_bus *bus)
 	struct ucc_mii_mng __iomem *regs = (void __iomem *)bus->priv;
 	unsigned int timeout = PHY_INIT_TIMEOUT;
 
-	spin_lock_bh(&bus->mdio_lock);
+	mutex_lock(&bus->mdio_lock);
 
 	/* Reset the management interface */
 	out_be32(&regs->miimcfg, MIIMCFG_RESET_MANAGEMENT);
@@ -121,7 +121,7 @@ int uec_mdio_reset(struct mii_bus *bus)
 	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
 		cpu_relax();
 
-	spin_unlock_bh(&bus->mdio_lock);
+	mutex_unlock(&bus->mdio_lock);
 
 	if (timeout <= 0) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n", bus->name);
-- 
1.5.0.2.230.gfbe3d-dirty


From: Timur Tabi <timur@freescale.com>
Subject: [PATCH] net/fsl_pq_mdio: use spin_event_timeout() to poll the indicator register
Date: Tue, 3 Jul 2012 18:16:21 -0500
Message-ID: <1341357381-10861-1-git-send-email-timur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
To: Andy Fleming <afleming@freescale.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ch1ehsobe004.messaging.microsoft.com ([216.32.181.184]:5104
	"EHLO ch1outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757324Ab2GCXQ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 19:16:27 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Macro spin_event_timeout() was designed for simple polling of hardware
registers with a timeout, so use it when we poll the MIIMIND register.
This allows us to return an error code instead of polling indefinitely.

Note that PHY_INIT_TIMEOUT is a count of loop iterations, so we can't use
it for spin_event_timeout(), which asks for microseconds.

Signed-off-by: Timur Tabi <timur@freescale.com>
---
 drivers/net/ethernet/freescale/fsl_pq_mdio.c |   25 +++++++++++++++----------
 1 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index 9eb8159..ab0fabd 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -64,6 +64,8 @@ struct fsl_pq_mdio_priv {
 int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
 		int regnum, u16 value)
 {
+	u32 status;
+
 	/* Set the PHY address and the register address we want to write */
 	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
 
@@ -71,10 +73,10 @@ int fsl_pq_local_mdio_write(struct fsl_pq_mdio __iomem *regs, int mii_id,
 	out_be32(&regs->miimcon, value);
 
 	/* Wait for the transaction to finish */
-	while (in_be32(&regs->miimind) & MIIMIND_BUSY)
-		cpu_relax();
+	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
+		1000, 0);
 
-	return 0;
+	return status ? 0 : -ETIMEDOUT;
 }
 
 /*
@@ -91,6 +93,7 @@ int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
 		int mii_id, int regnum)
 {
 	u16 value;
+	u32 status;
 
 	/* Set the PHY address and the register address we want to read */
 	out_be32(&regs->miimadd, (mii_id << 8) | regnum);
@@ -99,9 +102,11 @@ int fsl_pq_local_mdio_read(struct fsl_pq_mdio __iomem *regs,
 	out_be32(&regs->miimcom, 0);
 	out_be32(&regs->miimcom, MII_READ_COMMAND);
 
-	/* Wait for the transaction to finish */
-	while (in_be32(&regs->miimind) & (MIIMIND_NOTVALID | MIIMIND_BUSY))
-		cpu_relax();
+	/* Wait for the transaction to finish, normally less than 100us */
+	status = spin_event_timeout(!(in_be32(&regs->miimind) &
+		(MIIMIND_NOTVALID | MIIMIND_BUSY)), 1000, 0);
+	if (!status)
+		return -ETIMEDOUT;
 
 	/* Grab the value of the register from miimstat */
 	value = in_be32(&regs->miimstat);
@@ -144,7 +149,7 @@ int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 static int fsl_pq_mdio_reset(struct mii_bus *bus)
 {
 	struct fsl_pq_mdio __iomem *regs = fsl_pq_mdio_get_regs(bus);
-	int timeout = PHY_INIT_TIMEOUT;
+	u32 status;
 
 	mutex_lock(&bus->mdio_lock);
 
@@ -155,12 +160,12 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	out_be32(&regs->miimcfg, MIIMCFG_INIT_VALUE);
 
 	/* Wait until the bus is free */
-	while ((in_be32(&regs->miimind) & MIIMIND_BUSY) && timeout--)
-		cpu_relax();
+	status = spin_event_timeout(!(in_be32(&regs->miimind) &	MIIMIND_BUSY),
+		1000, 0);
 
 	mutex_unlock(&bus->mdio_lock);
 
-	if (timeout < 0) {
+	if (!status) {
 		printk(KERN_ERR "%s: The MII Bus is stuck!\n",
 				bus->name);
 		return -EBUSY;
-- 
1.7.3.4

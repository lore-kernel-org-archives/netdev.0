From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: [net v2 3/8] net/fsl_pq_mdio: Replace spin_event_timeout() with arch independent
Date: Tue, 7 Oct 2014 10:44:30 +0300
Message-ID: <1412667875-18225-4-git-send-email-claudiu.manoil@freescale.com>
References: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "David S. Miller" <davem@davemloft.net>,
	Xiubo Li <Li.Xiubo@freescale.com>,
	Shruti Kanetkar <Shruti@freescale.com>,
	"Kim Phillips" <kim.phillips@freescale.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [65.55.169.143] ([65.55.169.143]:3299 "EHLO
	na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753176AbaJGHrN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Oct 2014 03:47:13 -0400
In-Reply-To: <1412667875-18225-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

spin_event_timeout() is PPC dependent, use an arch independent
equivalent instead.

Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
---
v2 - none

 drivers/net/ethernet/freescale/fsl_pq_mdio.c | 36 ++++++++++++++++++----------
 1 file changed, 23 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/freescale/fsl_pq_mdio.c b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
index a422838..964c6bf 100644
--- a/drivers/net/ethernet/freescale/fsl_pq_mdio.c
+++ b/drivers/net/ethernet/freescale/fsl_pq_mdio.c
@@ -104,7 +104,7 @@ static int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 {
 	struct fsl_pq_mdio_priv *priv = bus->priv;
 	struct fsl_pq_mii __iomem *regs = priv->regs;
-	u32 status;
+	unsigned int timeout;
 
 	/* Set the PHY address and the register address we want to write */
 	iowrite32be((mii_id << 8) | regnum, &regs->miimadd);
@@ -113,10 +113,13 @@ static int fsl_pq_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
 	iowrite32be(value, &regs->miimcon);
 
 	/* Wait for the transaction to finish */
-	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
-				    MIIMIND_BUSY), MII_TIMEOUT, 0);
+	timeout = MII_TIMEOUT;
+	while ((ioread32be(&regs->miimind) & MIIMIND_BUSY) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
 
-	return status ? 0 : -ETIMEDOUT;
+	return timeout ? 0 : -ETIMEDOUT;
 }
 
 /*
@@ -133,7 +136,7 @@ static int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 {
 	struct fsl_pq_mdio_priv *priv = bus->priv;
 	struct fsl_pq_mii __iomem *regs = priv->regs;
-	u32 status;
+	unsigned int timeout;
 	u16 value;
 
 	/* Set the PHY address and the register address we want to read */
@@ -144,10 +147,14 @@ static int fsl_pq_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
 	iowrite32be(MII_READ_COMMAND, &regs->miimcom);
 
 	/* Wait for the transaction to finish, normally less than 100us */
-	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
-				    (MIIMIND_NOTVALID | MIIMIND_BUSY)),
-				    MII_TIMEOUT, 0);
-	if (!status)
+	timeout = MII_TIMEOUT;
+	while ((ioread32be(&regs->miimind) &
+	       (MIIMIND_NOTVALID | MIIMIND_BUSY)) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
+
+	if (!timeout)
 		return -ETIMEDOUT;
 
 	/* Grab the value of the register from miimstat */
@@ -162,7 +169,7 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 {
 	struct fsl_pq_mdio_priv *priv = bus->priv;
 	struct fsl_pq_mii __iomem *regs = priv->regs;
-	u32 status;
+	unsigned int timeout;
 
 	mutex_lock(&bus->mdio_lock);
 
@@ -173,12 +180,15 @@ static int fsl_pq_mdio_reset(struct mii_bus *bus)
 	iowrite32be(MIIMCFG_INIT_VALUE, &regs->miimcfg);
 
 	/* Wait until the bus is free */
-	status = spin_event_timeout(!(ioread32be(&regs->miimind) &
-				    MIIMIND_BUSY), MII_TIMEOUT, 0);
+	timeout = MII_TIMEOUT;
+	while ((ioread32be(&regs->miimind) & MIIMIND_BUSY) && timeout) {
+		cpu_relax();
+		timeout--;
+	}
 
 	mutex_unlock(&bus->mdio_lock);
 
-	if (!status) {
+	if (!timeout) {
 		dev_err(&bus->dev, "timeout waiting for MII bus\n");
 		return -EBUSY;
 	}
-- 
1.7.11.7

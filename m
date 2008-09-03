From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: [PATCH 05/17] mv643xx_eth: use the SMI done interrupt to wait for SMI access completion
Date: Wed,  3 Sep 2008 14:29:32 +0200
Message-ID: <1220444984-20150-6-git-send-email-buytenh@wantstofly.org>
References: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Cc: Dale Farnsworth <dale@farnsworth.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:52895 "EHLO
	delta.wantstofly.org" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752495AbYICM3s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 08:29:48 -0400
In-Reply-To: <1220444984-20150-1-git-send-email-buytenh@wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the platform code has passed us the IRQ number of the mv643xx_eth
top-level error interrupt, use the error interrupt to wait for SMI
access completion instead of polling the SMI busy bit, since SMI bus
accesses can take up to tens of milliseconds.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
---
 drivers/net/mv643xx_eth.c |  191 +++++++++++++++++++++++++++++++-------------
 1 files changed, 134 insertions(+), 57 deletions(-)

diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index 2d43401..b41860d 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -72,6 +72,13 @@ static char mv643xx_eth_driver_version[] = "1.3";
  */
 #define PHY_ADDR			0x0000
 #define SMI_REG				0x0004
+#define  SMI_BUSY			0x10000000
+#define  SMI_READ_VALID			0x08000000
+#define  SMI_OPCODE_READ		0x04000000
+#define  SMI_OPCODE_WRITE		0x00000000
+#define ERR_INT_CAUSE			0x0080
+#define  ERR_INT_SMI_DONE		0x00000010
+#define ERR_INT_MASK			0x0084
 #define WINDOW_BASE(w)			(0x0200 + ((w) << 3))
 #define WINDOW_SIZE(w)			(0x0204 + ((w) << 3))
 #define WINDOW_REMAP_HIGH(w)		(0x0280 + ((w) << 2))
@@ -254,6 +261,15 @@ struct mv643xx_eth_shared_private {
 	struct mutex phy_lock;
 
 	/*
+	 * If we have access to the error interrupt pin (which is
+	 * somewhat misnamed as it not only reflects internal errors
+	 * but also reflects SMI completion), use that to wait for
+	 * SMI access completion instead of polling the SMI busy bit.
+	 */
+	int err_interrupt;
+	wait_queue_head_t smi_busy_wait;
+
+	/*
 	 * Per-port MBUS window access register value.
 	 */
 	u32 win_protect;
@@ -979,68 +995,103 @@ static void txq_set_wrr(struct tx_queue *txq, int weight)
 
 
 /* mii management interface *************************************************/
-#define SMI_BUSY		0x10000000
-#define SMI_READ_VALID		0x08000000
-#define SMI_OPCODE_READ		0x04000000
-#define SMI_OPCODE_WRITE	0x00000000
+static irqreturn_t mv643xx_eth_err_irq(int irq, void *dev_id)
+{
+	struct mv643xx_eth_shared_private *msp = dev_id;
 
-static void smi_reg_read(struct mv643xx_eth_private *mp, unsigned int addr,
-			 unsigned int reg, unsigned int *value)
+	if (readl(msp->base + ERR_INT_CAUSE) & ERR_INT_SMI_DONE) {
+		writel(~ERR_INT_SMI_DONE, msp->base + ERR_INT_CAUSE);
+		wake_up(&msp->smi_busy_wait);
+		return IRQ_HANDLED;
+	}
+
+	return IRQ_NONE;
+}
+
+static int smi_is_done(struct mv643xx_eth_shared_private *msp)
 {
-	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	int i;
+	return !(readl(msp->base + SMI_REG) & SMI_BUSY);
+}
 
-	/* the SMI register is a shared resource */
-	mutex_lock(&mp->shared_smi->phy_lock);
+static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
+{
+	if (msp->err_interrupt == NO_IRQ) {
+		int i;
 
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
-		if (i == 1000) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
+		for (i = 0; !smi_is_done(msp); i++) {
+			if (i == 10)
+				return -ETIMEDOUT;
+			msleep(10);
 		}
-		udelay(10);
+
+		return 0;
+	}
+
+	if (!wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
+				msecs_to_jiffies(100)))
+		return -ETIMEDOUT;
+
+	return 0;
+}
+
+static int smi_reg_read(struct mv643xx_eth_private *mp,
+			unsigned int addr, unsigned int reg)
+{
+	struct mv643xx_eth_shared_private *msp = mp->shared_smi;
+	void __iomem *smi_reg = msp->base + SMI_REG;
+	int ret;
+
+	mutex_lock(&msp->phy_lock);
+
+	if (smi_wait_ready(msp)) {
+		printk("%s: SMI bus busy timeout\n", mp->dev->name);
+		ret = -ETIMEDOUT;
+		goto out;
 	}
 
 	writel(SMI_OPCODE_READ | (reg << 21) | (addr << 16), smi_reg);
 
-	/* now wait for the data to be valid */
-	for (i = 0; !(readl(smi_reg) & SMI_READ_VALID); i++) {
-		if (i == 1000) {
-			printk("%s: PHY read timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(10);
+	if (smi_wait_ready(msp)) {
+		printk("%s: SMI bus busy timeout\n", mp->dev->name);
+		ret = -ETIMEDOUT;
+		goto out;
 	}
 
-	*value = readl(smi_reg) & 0xffff;
+	ret = readl(smi_reg);
+	if (!(ret & SMI_READ_VALID)) {
+		printk("%s: SMI bus read not valid\n", mp->dev->name);
+		ret = -ENODEV;
+		goto out;
+	}
+
+	ret &= 0xffff;
+
 out:
-	mutex_unlock(&mp->shared_smi->phy_lock);
+	mutex_unlock(&msp->phy_lock);
+
+	return ret;
 }
 
-static void smi_reg_write(struct mv643xx_eth_private *mp,
-			  unsigned int addr,
-			  unsigned int reg, unsigned int value)
+static int smi_reg_write(struct mv643xx_eth_private *mp, unsigned int addr,
+			 unsigned int reg, unsigned int value)
 {
-	void __iomem *smi_reg = mp->shared_smi->base + SMI_REG;
-	int i;
+	struct mv643xx_eth_shared_private *msp = mp->shared_smi;
+	void __iomem *smi_reg = msp->base + SMI_REG;
 
-	/* the SMI register is a shared resource */
-	mutex_lock(&mp->shared_smi->phy_lock);
+	mutex_lock(&msp->phy_lock);
 
-	/* wait for the SMI register to become available */
-	for (i = 0; readl(smi_reg) & SMI_BUSY; i++) {
-		if (i == 1000) {
-			printk("%s: PHY busy timeout\n", mp->dev->name);
-			goto out;
-		}
-		udelay(10);
+	if (smi_wait_ready(msp)) {
+		printk("%s: SMI bus busy timeout\n", mp->dev->name);
+		mutex_unlock(&msp->phy_lock);
+		return -ETIMEDOUT;
 	}
 
 	writel(SMI_OPCODE_WRITE | (reg << 21) |
 		(addr << 16) | (value & 0xffff), smi_reg);
-out:
-	mutex_unlock(&mp->shared_smi->phy_lock);
+
+	mutex_unlock(&msp->phy_lock);
+
+	return 0;
 }
 
 
@@ -1877,16 +1928,19 @@ static irqreturn_t mv643xx_eth_irq(int irq, void *dev_id)
 
 static void phy_reset(struct mv643xx_eth_private *mp)
 {
-	unsigned int data;
+	int data;
+
+	data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+	if (data < 0)
+		return;
 
-	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
 	data |= BMCR_RESET;
-	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data);
+	if (smi_reg_write(mp, mp->phy_addr, MII_BMCR, data) < 0)
+		return;
 
 	do {
-		udelay(1);
-		smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
-	} while (data & BMCR_RESET);
+		data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+	} while (data >= 0 && data & BMCR_RESET);
 }
 
 static void port_start(struct mv643xx_eth_private *mp)
@@ -2214,11 +2268,7 @@ static void mv643xx_eth_netpoll(struct net_device *dev)
 static int mv643xx_eth_mdio_read(struct net_device *dev, int addr, int reg)
 {
 	struct mv643xx_eth_private *mp = netdev_priv(dev);
-	int val;
-
-	smi_reg_read(mp, addr, reg, &val);
-
-	return val;
+	return smi_reg_read(mp, addr, reg);
 }
 
 static void mv643xx_eth_mdio_write(struct net_device *dev, int addr, int reg, int val)
@@ -2317,6 +2367,24 @@ static int mv643xx_eth_shared_probe(struct platform_device *pdev)
 
 	mutex_init(&msp->phy_lock);
 
+	msp->err_interrupt = NO_IRQ;
+	init_waitqueue_head(&msp->smi_busy_wait);
+
+	/*
+	 * Check whether the error interrupt is hooked up.
+	 */
+	res = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
+	if (res != NULL) {
+		int err;
+
+		err = request_irq(res->start, mv643xx_eth_err_irq,
+				  IRQF_SHARED, "mv643xx_eth", msp);
+		if (!err) {
+			writel(ERR_INT_SMI_DONE, msp->base + ERR_INT_MASK);
+			msp->err_interrupt = res->start;
+		}
+	}
+
 	/*
 	 * (Re-)program MBUS remapping windows if we are asked to.
 	 */
@@ -2343,6 +2411,8 @@ static int mv643xx_eth_shared_remove(struct platform_device *pdev)
 {
 	struct mv643xx_eth_shared_private *msp = platform_get_drvdata(pdev);
 
+	if (msp->err_interrupt != NO_IRQ)
+		free_irq(msp->err_interrupt, msp);
 	iounmap(msp->base);
 	kfree(msp);
 
@@ -2431,13 +2501,20 @@ static void set_params(struct mv643xx_eth_private *mp,
 
 static int phy_detect(struct mv643xx_eth_private *mp)
 {
-	unsigned int data;
-	unsigned int data2;
+	int data;
+	int data2;
+
+	data = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+	if (data < 0)
+		return -ENODEV;
+
+	if (smi_reg_write(mp, mp->phy_addr, MII_BMCR, data ^ BMCR_ANENABLE) < 0)
+		return -ENODEV;
 
-	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data);
-	smi_reg_write(mp, mp->phy_addr, MII_BMCR, data ^ BMCR_ANENABLE);
+	data2 = smi_reg_read(mp, mp->phy_addr, MII_BMCR);
+	if (data2 < 0)
+		return -ENODEV;
 
-	smi_reg_read(mp, mp->phy_addr, MII_BMCR, &data2);
 	if (((data ^ data2) & BMCR_ANENABLE) == 0)
 		return -ENODEV;
 
-- 
1.5.6.4


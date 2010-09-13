From: Cyril Chemparathy <cyril@ti.com>
Subject: [PATCH 7/9] net: davinci_mdio: work around emac soft-reset during i/o
Date: Mon, 13 Sep 2010 14:07:29 -0400
Message-ID: <1284401251-8846-8-git-send-email-cyril@ti.com>
References: <1284401251-8846-1-git-send-email-cyril@ti.com>
Cc: michael.williamson@criticallink.com, caglarakyuz@gmail.com,
	bparrot@ti.com, Cyril Chemparathy <cyril@ti.com>
To: netdev@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com,
	linux-omap@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:39561 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754660Ab0IMSHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 14:07:39 -0400
In-Reply-To: <1284401251-8846-1-git-send-email-cyril@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On certain devices (e.g. da8xx), the hardware design ties emac soft-reset to
the mdio module.  In these cases, when the emac device is opened, an in-flight
mdio transaction could fail by returning the controller to idle state.  This
patch detects this condition and works around it by retrying the failed
transaction.

In addition, defensive timeouts have been added to prevent an indefinite
lockup in case of an unexpected hardware error.

Signed-off-by: Cyril Chemparathy <cyril@ti.com>
Signed-off-by: Michael Williamson <michael.williamson@criticallink.com>
Signed-off-by: Caglar Akyuz <caglarakyuz@gmail.com>
---
 drivers/net/davinci_mdio.c |   92 ++++++++++++++++++++++++++++++++++++-------
 1 files changed, 77 insertions(+), 15 deletions(-)

diff --git a/drivers/net/davinci_mdio.c b/drivers/net/davinci_mdio.c
index f2d7639..7615040 100644
--- a/drivers/net/davinci_mdio.c
+++ b/drivers/net/davinci_mdio.c
@@ -36,6 +36,13 @@
 #include <linux/io.h>
 #include <linux/davinci_emac.h>
 
+/*
+ * This timeout definition is a worst-case ultra defensive measure against
+ * unexpected controller lock ups.  Ideally, we should never ever hit this
+ * scenario in practice.
+ */
+#define MDIO_TIMEOUT		100 /* msecs */
+
 #define PHY_REG_MASK		0x1f
 #define PHY_ID_MASK		0x1f
 
@@ -150,30 +157,53 @@ static int davinci_mdio_reset(struct mii_bus *bus)
 }
 
 /* wait until hardware is ready for another user access */
-static inline u32 wait_for_user_access(struct davinci_mdio_data *data)
+static inline int wait_for_user_access(struct davinci_mdio_data *data)
 {
 	struct davinci_mdio_regs __iomem *regs = data->regs;
+	unsigned long timeout = jiffies + msecs_to_jiffies(MDIO_TIMEOUT);
 	u32 reg;
 
-	while ((reg = __raw_readl(&regs->user[0].access)) & USERACCESS_GO)
-		;
-
-	return reg;
+	while (time_after(timeout, jiffies)) {
+		reg = __raw_readl(&regs->user[0].access);
+		if ((reg & USERACCESS_GO) == 0)
+			return 0;
+
+		reg = __raw_readl(&regs->control);
+		if ((reg & CONTROL_IDLE) == 0)
+			continue;
+
+		/*
+		 * An emac soft_reset may have clobbered the mdio controller's
+		 * state machine.  We need to reset and retry the current
+		 * operation
+		 */
+		dev_warn(data->dev, "resetting idled controller\n");
+		__davinci_mdio_reset(data);
+		return -EAGAIN;
+	}
+	dev_err(data->dev, "timed out waiting for user access\n");
+	return -ETIMEDOUT;
 }
 
 /* wait until hardware state machine is idle */
-static inline void wait_for_idle(struct davinci_mdio_data *data)
+static inline int wait_for_idle(struct davinci_mdio_data *data)
 {
 	struct davinci_mdio_regs __iomem *regs = data->regs;
+	unsigned long timeout = jiffies + msecs_to_jiffies(MDIO_TIMEOUT);
 
-	while ((__raw_readl(&regs->control) & CONTROL_IDLE) == 0)
-		;
+	while (time_after(timeout, jiffies)) {
+		if (__raw_readl(&regs->control) & CONTROL_IDLE)
+			return 0;
+	}
+	dev_err(data->dev, "timed out waiting for idle\n");
+	return -ETIMEDOUT;
 }
 
 static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 reg;
+	int ret;
 
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
@@ -185,14 +215,32 @@ static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 		return -ENODEV;
 	}
 
-	wait_for_user_access(data);
 	reg = (USERACCESS_GO | USERACCESS_READ | (phy_reg << 21) |
 	       (phy_id << 16));
-	__raw_writel(reg, &data->regs->user[0].access);
-	reg = wait_for_user_access(data);
+
+	while (1) {
+		ret = wait_for_user_access(data);
+		if (ret == -EAGAIN)
+			continue;
+		if (ret < 0)
+			break;
+
+		__raw_writel(reg, &data->regs->user[0].access);
+
+		ret = wait_for_user_access(data);
+		if (ret == -EAGAIN)
+			continue;
+		if (ret < 0)
+			break;
+
+		reg = __raw_readl(&data->regs->user[0].access);
+		ret = (reg & USERACCESS_ACK) ? (reg & USERACCESS_DATA) : -EIO;
+		break;
+	}
+
 	spin_unlock(&data->lock);
 
-	return (reg & USERACCESS_ACK) ? (reg & USERACCESS_DATA) : -EIO;
+	return ret;
 }
 
 static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
@@ -200,6 +248,7 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 reg;
+	int ret;
 
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
@@ -211,11 +260,24 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 		return -ENODEV;
 	}
 
-	wait_for_user_access(data);
 	reg = (USERACCESS_GO | USERACCESS_WRITE | (phy_reg << 21) |
 		   (phy_id << 16) | (phy_data & USERACCESS_DATA));
-	__raw_writel(reg, &data->regs->user[0].access);
-	wait_for_user_access(data);
+
+	while (1) {
+		ret = wait_for_user_access(data);
+		if (ret == -EAGAIN)
+			continue;
+		if (ret < 0)
+			break;
+
+		__raw_writel(reg, &data->regs->user[0].access);
+
+		ret = wait_for_user_access(data);
+		if (ret == -EAGAIN)
+			continue;
+		break;
+	}
+
 	spin_unlock(&data->lock);
 
 	return 0;
-- 
1.7.0.4


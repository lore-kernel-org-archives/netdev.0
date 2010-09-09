From: Cyril Chemparathy <cyril@ti.com>
Subject: Re: [PATCH v3 00/10] split out emac cpdma and mdio for reuse
Date: Thu, 09 Sep 2010 15:51:58 -0400
Message-ID: <4C893ADE.809@ti.com>
References: <1283891142-15522-1-git-send-email-cyril@ti.com> <871v95f2xv.fsf@deeprootsystems.com> <4C86F369.6040906@criticallink.com> <4C880733.5010909@ti.com> <4C882EAA.9030903@criticallink.com> <4C892AC0.80409@criticallink.com>
Reply-To: cyril@ti.com
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000203060304030403090904"
Cc: Kevin Hilman <khilman@deeprootsystems.com>,
	"tony@atomide.com" <tony@atomide.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davinci-linux-open-source@linux.davincidsp.com"
	<davinci-linux-open-source@linux.davincidsp.com>,
	"linux-omap@vger.kernel.org" <linux-omap@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Michael Williamson <michael.williamson@criticallink.com>
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <4C892AC0.80409@criticallink.com>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000203060304030403090904
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi Mike,

[...]
> The hang is in wait_for_user_access() in the davinci_mdio_read() call.  Looks like
> the state machine got put back into IDLE somewhere between the MDIO probe and the 
> EMAC probe. Seems like there should be some sort of time-out and error message 
> in the wait_for_user_access() method.... (maybe even a check for IDLE??)
> 
> If I add a patch to check the state machine for IDLE and then re-enable it in the
> davinci_mdio_read() call, it is able to press on and come up.  I don't see any calls
> to the davinci_mdio_suspend() call, so I am wondering if the EMAC probe routine, 
> particularly the application of the SOFTRESET, is causing the MDIO to drop back to 
> IDLE / disabled.
> 
> I can post the patch if you like, but it is a bit of a hack...

An EMAC soft-reset clobbering the MDIO controller state is a
possibility.  I will poll TI designers to see if this could be the case.

In any case, a couple of unanswered questions remain:

  1. Why don't other davinci devices display similar behavior?

  2. If the answer to #1 above is that the timing window is pretty slim
     (i.e., only if an MDIO read/write is in progress during EMAC
     soft-reset), why do we hit this situation consistently on
     mityomap?

I have put together a quick patch (tested dm365).  See attached.

Regards
Cyril.

--------------000203060304030403090904
Content-Type: text/x-patch;
 name="mdio-check-idle.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="mdio-check-idle.patch"

diff --git a/drivers/net/davinci_mdio.c b/drivers/net/davinci_mdio.c
index d34a53a..96a0f9e 100644
--- a/drivers/net/davinci_mdio.c
+++ b/drivers/net/davinci_mdio.c
@@ -36,6 +36,7 @@
 #include <linux/io.h>
 #include <linux/davinci_emac.h>
 
+#define MDIO_TIMEOUT		10		/* msecs */
 #define PHY_REG_MASK		0x1f
 #define PHY_ID_MASK		0x1f
 
@@ -85,31 +86,74 @@ struct davinci_mdio_data {
 	bool		suspended;
 };
 
+static void __davinci_mdio_reset(struct mii_bus *bus)
+{
+	struct davinci_mdio_data *data = bus->priv;
+	u32 mdio_in_freq, div;
+
+	mdio_in_freq = clk_get_rate(data->clk);
+	div = (mdio_in_freq / data->pdata.bus_freq) - 1;
+	if (div > CONTROL_MAX_DIV)
+		div = CONTROL_MAX_DIV;
+
+	/* set enable and clock divider */
+	__raw_writel(div | CONTROL_ENABLE, &data->regs->control);
+}
+
 /* wait until hardware is ready for another user access */
-static inline u32 wait_for_user_access(struct davinci_mdio_data *data)
+static inline int wait_for_user_access(struct davinci_mdio_data *data)
 {
-	struct davinci_mdio_regs __iomem *regs = data->regs;
+	unsigned long timeout = jiffies + msecs_to_jiffies(MDIO_TIMEOUT);
 	u32 reg;
+	int ret = -ETIMEDOUT;
 
-	while ((reg = __raw_readl(&regs->user[0].access)) & USERACCESS_GO)
-		;
+	while (time_after(timeout, jiffies)) {
+		reg = __raw_readl(&data->regs->user[0].access);
+		if ((reg & USERACCESS_GO) == 0) {
+			ret = 0;
+			break;
+		}
 
-	return reg;
+		reg = __raw_readl(&data->regs->control);
+		if (reg & CONTROL_IDLE) {
+			/*
+			 * An emac soft_reset may have clobbered the mdio
+			 * controller's state machine.  We need to reset and
+			 * retry the current operation
+			 */
+			dev_warn(data->dev, "controller idle in transaction, "
+					    "resetting\n");
+			__davinci_mdio_reset(data->bus);
+			ret = -EAGAIN;
+			break;
+		}
+	}
+	return ret;
 }
 
 /* wait until hardware state machine is idle */
-static inline void wait_for_idle(struct davinci_mdio_data *data)
+static inline int wait_for_idle(struct davinci_mdio_data *data)
 {
-	struct davinci_mdio_regs __iomem *regs = data->regs;
+	unsigned long timeout = jiffies + msecs_to_jiffies(MDIO_TIMEOUT);
+	int ret = -ETIMEDOUT;
+	u32 reg;
 
-	while ((__raw_readl(&regs->control) & CONTROL_IDLE) == 0)
-		;
+	while (time_after(timeout, jiffies)) {
+		reg = __raw_readl(&data->regs->control);
+		if (reg & CONTROL_IDLE) {
+			ret = 0;
+			break;
+		}
+	}
+
+	return ret;
 }
 
 static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 reg;
+	int ret;
 
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
@@ -121,14 +165,32 @@ static int davinci_mdio_read(struct mii_bus *bus, int phy_id, int phy_reg)
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
@@ -136,6 +198,7 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
 {
 	struct davinci_mdio_data *data = bus->priv;
 	u32 reg;
+	int ret;
 
 	if (phy_reg & ~PHY_REG_MASK || phy_id & ~PHY_ID_MASK)
 		return -EINVAL;
@@ -147,23 +210,68 @@ static int davinci_mdio_write(struct mii_bus *bus, int phy_id,
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
 }
 
+static int davinci_mdio_reset(struct mii_bus *bus)
+{
+	struct davinci_mdio_data *data = bus->priv;
+	u32 phy_mask;
+
+	__davinci_mdio_reset(bus);
+
+	/*
+	 * wait for scan logic to settle:
+	 * the scan time consists of (a) a large fixed component, and (b) a
+	 * small component that varies with the mii bus frequency.  These
+	 * were estimated using measurements at 1.1 and 2.2 MHz on tnetv107x
+	 * silicon.  Since the effect of (b) was found to be largely
+	 * negligible, we keep things simple here.
+	 */
+	mdelay(1);
+
+	/* get phy mask from the alive register */
+	phy_mask = __raw_readl(&data->regs->alive);
+	if (phy_mask) {
+		/* restrict mdio bus to live phys only */
+		dev_info(data->dev, "detected phy mask %x\n", ~phy_mask);
+		phy_mask = ~phy_mask;
+	} else {
+		/* desperately scan all phys */
+		dev_warn(data->dev, "failed to detect live phys, scanning all\n");
+		phy_mask = 0;
+	}
+	bus->phy_mask = phy_mask;
+
+	return 0;
+}
+
 static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 {
 	struct mdio_platform_data *pdata = pdev->dev.platform_data;
 	struct device *dev = &pdev->dev;
 	struct davinci_mdio_data *data;
 	struct resource *res;
-	u32 mdio_in_freq, mdio_out_freq, div, phy_mask, ver;
 	struct phy_device *phy;
 	int ret, addr;
 
@@ -185,6 +293,7 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 	data->bus->name		= dev_name(dev);
 	data->bus->read		= davinci_mdio_read,
 	data->bus->write	= davinci_mdio_write,
+	data->bus->reset	= davinci_mdio_reset,
 	data->bus->parent	= dev;
 	data->bus->priv		= data;
 	snprintf(data->bus->id, MII_BUS_ID_SIZE, "%x", pdev->id);
@@ -225,43 +334,6 @@ static int __devinit davinci_mdio_probe(struct platform_device *pdev)
 		goto bail_out;
 	}
 
-	mdio_in_freq = clk_get_rate(data->clk);
-	div = (mdio_in_freq / data->pdata.bus_freq) - 1;
-	if (div > CONTROL_MAX_DIV)
-		div = CONTROL_MAX_DIV;
-	mdio_out_freq = mdio_in_freq / (div + 1);
-
-	/* set enable and clock divider */
-	__raw_writel(div | CONTROL_ENABLE, &data->regs->control);
-
-	/*
-	 * wait for scan logic to settle:
-	 * the scan time consists of (a) a large fixed component, and (b) a
-	 * small component that varies with the mii bus frequency.  These
-	 * were estimated using measurements at 1.1 and 2.2 MHz on tnetv107x
-	 * silicon.  Since the effect of (b) was found to be largely
-	 * negligible, we keep things simple here.
-	 */
-	mdelay(1);
-
-	/* dump hardware version info */
-	ver = __raw_readl(&data->regs->version);
-	dev_info(dev, "davinci mdio revision %d.%d\n",
-			(ver >> 8) & 0xff, ver & 0xff);
-
-	/* get phy mask from the alive register */
-	phy_mask = __raw_readl(&data->regs->alive);
-	if (phy_mask) {
-		/* restrict mdio bus to live phys only */
-		dev_info(dev, "detected phy mask %x\n", ~phy_mask);
-		phy_mask = ~phy_mask;
-	} else {
-		/* desperately scan all phys */
-		dev_warn(dev, "failed to detect live phys, scanning all\n");
-		phy_mask = 0;
-	}
-	data->bus->phy_mask = phy_mask;
-
 	/* register the mii bus */
 	ret = mdiobus_register(data->bus);
 	if (ret)
@@ -324,7 +396,7 @@ static int davinci_mdio_suspend(struct device *dev)
 	ctrl = __raw_readl(&data->regs->control);
 	ctrl &= ~CONTROL_ENABLE;
 	__raw_writel(ctrl, &data->regs->control);
-	wait_for_idle(data);
+	WARN_ON(wait_for_idle(data) < 0);
 
 	if (data->clk)
 		clk_disable(data->clk);

--------------000203060304030403090904--

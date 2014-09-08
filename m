From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH 02/13] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Mon, 8 Sep 2014 17:10:31 +0300
Message-ID: <1410185442-907-3-git-send-email-rogerq@ti.com>
References: <1410185442-907-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <tglx@linutronix.de>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>, Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>, <tony@atomide.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from arroyo.ext.ti.com ([192.94.94.40]:58817 "EHLO arroyo.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752869AbaIHOLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 10:11:15 -0400
In-Reply-To: <1410185442-907-1-git-send-email-rogerq@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some TI SoCs like DRA7 have a RAMINIT register specification
different from the other AMxx SoCs and as expected by the
existing driver.

To add more insanity, this register is shared with other
IPs like DSS, PCIe and PWM.

Provides a more generic mechanism to specify the RAMINIT
register location and START/DONE bit position and use the
syscon/regmap framework to access the register.

Signed-off-by: Roger Quadros <rogerq@ti.com>
---
 .../devicetree/bindings/net/can/c_can.txt          |   7 ++
 drivers/net/can/c_can/c_can.h                      |  11 ++-
 drivers/net/can/c_can/c_can_platform.c             | 106 +++++++++++++++------
 3 files changed, 95 insertions(+), 29 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index 8f1ae81..0856209 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -13,6 +13,13 @@ Optional properties:
 - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
 			  instance number
 
+- raminit-syscon	: Handle to system control region that contains the
+			  RAMINIT register. If specified, the second memory resource
+			  in the reg property must index into the RAMINIT
+			  register within the syscon region
+- raminit-start-bit	: Bit posistion of START bit in the RAMINIT register
+- raminit-done-bit	: Bit position of DONE bit in the RAMINIT register
+
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
 Future plan is to migrate hwmod data base contents into device tree
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 99ad1aa..bf68822 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -169,6 +169,14 @@ enum c_can_dev_id {
 	BOSCH_D_CAN,
 };
 
+/* Out of band RAMINIT register access via syscon regmap */
+struct c_can_raminit {
+	struct regmap *syscon;	/* for raminit ctrl. reg. access */
+	unsigned int reg;	/* register index within syscon */
+	u8 start_bit;	/* START bit position in raminit reg. */
+	u8 done_bit;	/* DONE bit position in raminit reg. */
+};
+
 /* c_can private data structure */
 struct c_can_priv {
 	struct can_priv can;	/* must be the first member */
@@ -186,8 +194,7 @@ struct c_can_priv {
 	const u16 *regs;
 	void *priv;		/* for board-specific data */
 	enum c_can_dev_id type;
-	u32 __iomem *raminit_ctrlreg;
-	int instance;
+	struct c_can_raminit raminit_sys;	/* RAMINIT via syscon regmap */
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
 	u32 comm_rcv_high;
 	u32 rxmasked;
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index b144e71..e7ec3b6 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -32,6 +32,8 @@
 #include <linux/clk.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regmap.h>
 
 #include <linux/can/dev.h>
 
@@ -72,48 +74,59 @@ static void c_can_plat_write_reg_aligned_to_32bit(const struct c_can_priv *priv,
 	writew(val, priv->base + 2 * priv->regs[index]);
 }
 
-static void c_can_hw_raminit_wait_ti(const struct c_can_priv *priv, u32 mask,
-				  u32 val)
+static void c_can_hw_raminit_wait_syscon(const struct c_can_priv *priv,
+					 u32 mask, u32 val)
 {
 	int timeout = 0;
+	const struct c_can_raminit *raminit = &priv->raminit_sys;
+	u32 ctrl;
+
 	/* We look only at the bits of our instance. */
 	val &= mask;
-	while ((readl(priv->raminit_ctrlreg) & mask) != val) {
+	do {
 		udelay(1);
 		timeout++;
 
+		regmap_read(raminit->syscon, raminit->reg, &ctrl);
 		if (timeout == 1000) {
 			dev_err(&priv->dev->dev, "%s: time out\n", __func__);
 			break;
 		}
-	}
+	} while ((ctrl & mask) != val);
 }
 
-static void c_can_hw_raminit_ti(const struct c_can_priv *priv, bool enable)
+static void c_can_hw_raminit_syscon(const struct c_can_priv *priv, bool enable)
 {
-	u32 mask = CAN_RAMINIT_ALL_MASK(priv->instance);
+	u32 mask;
 	u32 ctrl;
+	const struct c_can_raminit *raminit = &priv->raminit_sys;
 
 	spin_lock(&raminit_lock);
 
-	ctrl = readl(priv->raminit_ctrlreg);
+	mask = 1 << raminit->start_bit | 1 << raminit->done_bit;
+	regmap_read(raminit->syscon, raminit->reg, &ctrl);
+
 	/* We clear the done and start bit first. The start bit is
 	 * looking at the 0 -> transition, but is not self clearing;
 	 * And we clear the init done bit as well.
+	 * NOTE: DONE must be written with 1 to clear it.
 	 */
-	ctrl &= ~CAN_RAMINIT_START_MASK(priv->instance);
-	ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
-	writel(ctrl, priv->raminit_ctrlreg);
-	ctrl &= ~CAN_RAMINIT_DONE_MASK(priv->instance);
-	c_can_hw_raminit_wait_ti(priv, mask, ctrl);
+	ctrl &= ~(1 << raminit->start_bit);
+	ctrl |= 1 << raminit->done_bit;
+	regmap_write(raminit->syscon, raminit->reg, ctrl);
+
+	ctrl &= ~(1 << raminit->done_bit);
+	c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
 
 	if (enable) {
 		/* Set start bit and wait for the done bit. */
-		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
-		writel(ctrl, priv->raminit_ctrlreg);
-		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
-		c_can_hw_raminit_wait_ti(priv, mask, ctrl);
+		ctrl |= 1 << raminit->start_bit;
+		regmap_write(raminit->syscon, raminit->reg, ctrl);
+
+		ctrl |= 1 << raminit->done_bit;
+		c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
 	}
+
 	spin_unlock(&raminit_lock);
 }
 
@@ -202,6 +215,8 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	struct resource *mem, *res;
 	int irq;
 	struct clk *clk;
+	struct device_node *np = pdev->dev.of_node;
+	u32 val;
 
 	if (pdev->dev.of_node) {
 		match = of_match_device(c_can_of_table, &pdev->dev);
@@ -271,11 +286,6 @@ static int c_can_plat_probe(struct platform_device *pdev)
 		priv->read_reg32 = d_can_plat_read_reg32;
 		priv->write_reg32 = d_can_plat_write_reg32;
 
-		if (pdev->dev.of_node)
-			priv->instance = of_alias_get_id(pdev->dev.of_node, "d_can");
-		else
-			priv->instance = pdev->id;
-
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
 		/* Not all D_CAN modules have a separate register for the D_CAN
 		 * RAM initialization. Use default RAM init bit in D_CAN module
@@ -286,12 +296,54 @@ static int c_can_plat_probe(struct platform_device *pdev)
 			break;
 		}
 
-		priv->raminit_ctrlreg = devm_ioremap(&pdev->dev, res->start,
-						     resource_size(res));
-		if (!priv->raminit_ctrlreg || priv->instance < 0)
-			dev_info(&pdev->dev, "control memory is not used for raminit\n");
-		else
-			priv->raminit = c_can_hw_raminit_ti;
+		/* If separate RAMINIT register is specified access
+		 * it using syscon regmap. Mostly for TI platforms.
+		 */
+		ret = -EINVAL;
+		if (!np) {
+			dev_err(&pdev->dev,
+				"separate RAMINIT reg. not supported on non DT\n");
+			goto exit_free_device;
+		}
+
+		priv->raminit_sys.syscon = syscon_regmap_lookup_by_phandle(np,
+									   "raminit-syscon");
+		if (IS_ERR(priv->raminit_sys.syscon)) {
+			dev_err(&pdev->dev,
+				"couldn't get syscon regmap for RAMINIT reg.\n");
+			goto exit_free_device;
+		}
+
+		priv->raminit_sys.reg = res->start;
+		if (of_property_read_u32(np, "raminit-start-bit",
+					 &val)) {
+			dev_err(&pdev->dev,
+				"missing raminit-start-bit property\n");
+			goto exit_free_device;
+		}
+
+		if (val > 31) {
+			dev_err(&pdev->dev,
+				"invalid raminit-start-bit property\n");
+			goto exit_free_device;
+		}
+
+		priv->raminit_sys.start_bit = val;
+		if (of_property_read_u32(np, "raminit-done-bit",
+					 &val)) {
+			dev_err(&pdev->dev,
+				"missing raminit-done-bit property\n");
+			goto exit_free_device;
+		}
+
+		if (val > 31) {
+			dev_err(&pdev->dev,
+				"invalid raminit-done-bit property\n");
+			goto exit_free_device;
+		}
+
+		priv->raminit_sys.done_bit = val;
+		priv->raminit = c_can_hw_raminit_syscon;
 		break;
 	default:
 		ret = -EINVAL;
-- 
1.8.3.2

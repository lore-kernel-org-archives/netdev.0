From: Roger Quadros <rogerq@ti.com>
Subject: [PATCH v4 4/8] net: can: c_can: Add syscon/regmap RAMINIT mechanism
Date: Fri, 7 Nov 2014 16:49:18 +0200
Message-ID: <1415371762-29885-5-git-send-email-rogerq@ti.com>
References: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wsa@the-dreams.de>, <tony@atomide.com>, <tglx@linutronix.de>,
	<mugunthanvnm@ti.com>, <george.cherian@ti.com>, <balbi@ti.com>,
	<nsekhar@ti.com>, <nm@ti.com>,
	<sergei.shtylyov@cogentembedded.com>, <linux-omap@vger.kernel.org>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	Roger Quadros <rogerq@ti.com>
To: <wg@grandegger.com>, <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1415371762-29885-1-git-send-email-rogerq@ti.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
 .../devicetree/bindings/net/can/c_can.txt          |   3 +
 drivers/net/can/c_can/c_can.h                      |  11 +-
 drivers/net/can/c_can/c_can_platform.c             | 112 ++++++++++++++-------
 3 files changed, 86 insertions(+), 40 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/can/c_can.txt b/Documentation/devicetree/bindings/net/can/c_can.txt
index 8f1ae81..a3ca3ee 100644
--- a/Documentation/devicetree/bindings/net/can/c_can.txt
+++ b/Documentation/devicetree/bindings/net/can/c_can.txt
@@ -12,6 +12,9 @@ Required properties:
 Optional properties:
 - ti,hwmods		: Must be "d_can<n>" or "c_can<n>", n being the
 			  instance number
+- syscon-raminit	: Handle to system control region that contains the
+			  RAMINIT register, register offset to the RAMINIT
+			  register and the CAN instance number (0 offset).
 
 Note: "ti,hwmods" field is used to fetch the base address and irq
 resources from TI, omap hwmod data base during device registration.
diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index 3c305a1..0e17c7b 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -179,6 +179,14 @@ struct c_can_driver_data {
 	bool raminit_pulse;	/* If set, sets and clears START bit (pulse) */
 };
 
+/* Out of band RAMINIT register access via syscon regmap */
+struct c_can_raminit {
+	struct regmap *syscon;	/* for raminit ctrl. reg. access */
+	unsigned int reg;	/* register index within syscon */
+	u8 start_bit;
+	u8 done_bit;
+};
+
 /* c_can private data structure */
 struct c_can_priv {
 	struct can_priv can;	/* must be the first member */
@@ -196,8 +204,7 @@ struct c_can_priv {
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
index 20deb67..3776483 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -32,14 +32,13 @@
 #include <linux/clk.h>
 #include <linux/of.h>
 #include <linux/of_device.h>
+#include <linux/mfd/syscon.h>
+#include <linux/regmap.h>
 
 #include <linux/can/dev.h>
 
 #include "c_can.h"
 
-#define CAN_RAMINIT_START_MASK(i)	(0x001 << (i))
-#define CAN_RAMINIT_DONE_MASK(i)	(0x100 << (i))
-#define CAN_RAMINIT_ALL_MASK(i)		(0x101 << (i))
 #define DCAN_RAM_INIT_BIT		(1 << 3)
 static DEFINE_SPINLOCK(raminit_lock);
 /*
@@ -72,47 +71,61 @@ static void c_can_plat_write_reg_aligned_to_32bit(const struct c_can_priv *priv,
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
+	u8 start_bit, done_bit;
+
+	start_bit = raminit->start_bit;
+	done_bit = raminit->done_bit;
 
 	spin_lock(&raminit_lock);
 
-	ctrl = readl(priv->raminit_ctrlreg);
+	mask = 1 << start_bit | 1 << done_bit;
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
+	ctrl &= ~(1 << start_bit);
+	ctrl |= 1 << done_bit;
+	regmap_write(raminit->syscon, raminit->reg, ctrl);
+
+	ctrl &= ~(1 << done_bit);
+	c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
 
 	if (enable) {
 		/* Set start bit and wait for the done bit. */
-		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
-		writel(ctrl, priv->raminit_ctrlreg);
-		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
-		c_can_hw_raminit_wait_ti(priv, mask, ctrl);
+		ctrl |= 1 << start_bit;
+		regmap_write(raminit->syscon, raminit->reg, ctrl);
+
+		ctrl |= 1 << done_bit;
+		c_can_hw_raminit_wait_syscon(priv, mask, ctrl);
 	}
 	spin_unlock(&raminit_lock);
 }
@@ -206,10 +219,11 @@ static int c_can_plat_probe(struct platform_device *pdev)
 	struct net_device *dev;
 	struct c_can_priv *priv;
 	const struct of_device_id *match;
-	struct resource *mem, *res;
+	struct resource *mem;
 	int irq;
 	struct clk *clk;
 	const struct c_can_driver_data *drvdata;
+	struct device_node *np = pdev->dev.of_node;
 
 	match = of_match_device(c_can_of_table, &pdev->dev);
 	if (match) {
@@ -278,27 +292,49 @@ static int c_can_plat_probe(struct platform_device *pdev)
 		priv->read_reg32 = d_can_plat_read_reg32;
 		priv->write_reg32 = d_can_plat_write_reg32;
 
-		if (pdev->dev.of_node)
-			priv->instance = of_alias_get_id(pdev->dev.of_node, "d_can");
-		else
-			priv->instance = pdev->id;
-
-		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
-		/* Not all D_CAN modules have a separate register for the D_CAN
-		 * RAM initialization. Use default RAM init bit in D_CAN module
-		 * if not specified in DT.
+		/* Check if we need custom RAMINIT via syscon. Mostly for TI
+		 * platforms. Only supported with DT boot.
 		 */
-		if (!res) {
+		if (np && of_property_read_bool(np, "syscon-raminit")) {
+			u32 id;
+			struct c_can_raminit *raminit = &priv->raminit_sys;
+
+			ret = -EINVAL;
+			raminit->syscon = syscon_regmap_lookup_by_phandle(np,
+									  "syscon-raminit");
+			if (IS_ERR(raminit->syscon)) {
+				dev_err(&pdev->dev,
+					"couldn't get syscon regmap for RAMINIT\n");
+				goto exit_free_device;
+			}
+
+			if (of_property_read_u32_index(np, "syscon-raminit", 1,
+						       &raminit->reg)) {
+				dev_err(&pdev->dev,
+					"couldn't get the RAMINIT reg. offset!\n");
+				goto exit_free_device;
+			}
+
+			if (of_property_read_u32_index(np, "syscon-raminit", 2,
+						       &id)) {
+				dev_err(&pdev->dev,
+					"couldn't get the CAN instance ID\n");
+				goto exit_free_device;
+			}
+
+			if (id >= drvdata->num_can) {
+				dev_err(&pdev->dev,
+					"Invalid CAN instance ID\n");
+				goto exit_free_device;
+			}
+
+			raminit->start_bit = drvdata->raminit_start_bits[id];
+			raminit->done_bit = drvdata->raminit_done_bits[id];
+
+			priv->raminit = c_can_hw_raminit_syscon;
+		} else {
 			priv->raminit = c_can_hw_raminit;
-			break;
 		}
-
-		priv->raminit_ctrlreg = devm_ioremap(&pdev->dev, res->start,
-						     resource_size(res));
-		if (!priv->raminit_ctrlreg || priv->instance < 0)
-			dev_info(&pdev->dev, "control memory is not used for raminit\n");
-		else
-			priv->raminit = c_can_hw_raminit_ti;
 		break;
 	default:
 		ret = -EINVAL;
-- 
1.8.3.2


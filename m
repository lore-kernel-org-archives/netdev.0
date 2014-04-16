From: <tthayer@altera.com>
Subject: [PATCH] net: c_can: Add support for D_CAN module RAM Init.
Date: Wed, 16 Apr 2014 13:29:33 -0500
Message-ID: <1397672973-3480-2-git-send-email-tthayer@altera.com>
References: <1397672973-3480-1-git-send-email-tthayer@altera.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <socketcan@hartkopp.net>, <anilkumar@ti.com>, <tglx@linutronix.de>,
	<tthayer.linux@gmail.com>, Thor Thayer <tthayer@altera.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: <linux-can@vger.kernel.org>, <wg@grandegger.com>,
	<mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1397672973-3480-1-git-send-email-tthayer@altera.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thor Thayer <tthayer@altera.com>

The D_CAN driver was written to support the TI D_CAN implementation
which placed the D_CAN RAM reset in a separate register. In the
standard D_CAN module the RAM Init is in the D_CAN module so
handle the RAM Init differently.

Signed-off-by: Thor Thayer <tthayer@altera.com>
To: linux-can <linux-can@vger.kernel.org>
To: Wolfgang Grandegger <wg@grandegger.com>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Cc: Oliver Hartkopp <socketcan@hartkopp.net>
Cc: AnilKumar Ch <anilkumar@ti.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev <netdev@vger.kernel.org>
---
 drivers/net/can/c_can/c_can.h          |    3 ++
 drivers/net/can/c_can/c_can_platform.c |   49 +++++++++++++++++++++++++-------
 2 files changed, 42 insertions(+), 10 deletions(-)

diff --git a/drivers/net/can/c_can/c_can.h b/drivers/net/can/c_can/c_can.h
index faa8404..64ff936 100644
--- a/drivers/net/can/c_can/c_can.h
+++ b/drivers/net/can/c_can/c_can.h
@@ -88,6 +88,7 @@ enum reg {
 	C_CAN_INTPND2_REG,
 	C_CAN_MSGVAL1_REG,
 	C_CAN_MSGVAL2_REG,
+	C_CAN_FUNCTION_REG,
 };
 
 static const u16 reg_map_c_can[] = {
@@ -139,6 +140,7 @@ static const u16 reg_map_d_can[] = {
 	[C_CAN_BRPEXT_REG]	= 0x0E,
 	[C_CAN_INT_REG]		= 0x10,
 	[C_CAN_TEST_REG]	= 0x14,
+	[C_CAN_FUNCTION_REG]	= 0x18,
 	[C_CAN_TXRQST1_REG]	= 0x88,
 	[C_CAN_TXRQST2_REG]	= 0x8A,
 	[C_CAN_NEWDAT1_REG]	= 0x9C,
@@ -201,6 +203,7 @@ struct c_can_priv {
 	unsigned int instance;
 	void (*raminit) (const struct c_can_priv *priv, bool enable);
 	u32 dlc[C_CAN_MSG_OBJ_TX_NUM];
+	u32 raminit_type_flag;
 };
 
 struct net_device *alloc_c_can_dev(void);
diff --git a/drivers/net/can/c_can/c_can_platform.c b/drivers/net/can/c_can/c_can_platform.c
index 806d927..47bbcaf 100644
--- a/drivers/net/can/c_can/c_can_platform.c
+++ b/drivers/net/can/c_can/c_can_platform.c
@@ -41,6 +41,12 @@
 #define CAN_RAMINIT_DONE_MASK(i)	(0x100 << (i))
 #define CAN_RAMINIT_ALL_MASK(i)		(0x101 << (i))
 static DEFINE_SPINLOCK(raminit_lock);
+#define DCAN_RAM_INIT_BIT		(1 << 3)
+struct c_can_ram_init_masks {
+	u32 start;
+	u32 done;
+	u32 all;
+};
 /*
  * 16-bit c_can registers can be arranged differently in the memory
  * architecture of different implementations. For example: 16-bit
@@ -82,9 +88,19 @@ static void c_can_hw_raminit_wait(const struct c_can_priv *priv, u32 mask,
 
 static void c_can_hw_raminit(const struct c_can_priv *priv, bool enable)
 {
-	u32 mask = CAN_RAMINIT_ALL_MASK(priv->instance);
+	struct c_can_ram_init_masks ram_init_masks;
 	u32 ctrl;
 
+	if (priv->raminit_type_flag) {
+		ram_init_masks.start = CAN_RAMINIT_START_MASK(priv->instance);
+		ram_init_masks.done = CAN_RAMINIT_DONE_MASK(priv->instance);
+		ram_init_masks.all = CAN_RAMINIT_ALL_MASK(priv->instance);
+	} else {
+		ram_init_masks.start = DCAN_RAM_INIT_BIT;
+		ram_init_masks.done = 0;
+		ram_init_masks.all = 0;
+	}
+
 	spin_lock(&raminit_lock);
 
 	ctrl = readl(priv->raminit_ctrlreg);
@@ -92,18 +108,18 @@ static void c_can_hw_raminit(const struct c_can_priv *priv, bool enable)
 	 * looking at the 0 -> transition, but is not self clearing;
 	 * And we clear the init done bit as well.
 	 */
-	ctrl &= ~CAN_RAMINIT_START_MASK(priv->instance);
-	ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
+	ctrl &= ~ram_init_masks.start;
+	ctrl |= ram_init_masks.done;
 	writel(ctrl, priv->raminit_ctrlreg);
-	ctrl &= ~CAN_RAMINIT_DONE_MASK(priv->instance);
-	c_can_hw_raminit_wait(priv, ctrl, mask);
+	ctrl &= ~ram_init_masks.done;
+	c_can_hw_raminit_wait(priv, ctrl, ram_init_masks.all);
 
 	if (enable) {
 		/* Set start bit and wait for the done bit. */
-		ctrl |= CAN_RAMINIT_START_MASK(priv->instance);
+		ctrl |= ram_init_masks.start;
 		writel(ctrl, priv->raminit_ctrlreg);
-		ctrl |= CAN_RAMINIT_DONE_MASK(priv->instance);
-		c_can_hw_raminit_wait(priv, ctrl, mask);
+		ctrl |= ram_init_masks.done;
+		c_can_hw_raminit_wait(priv, ctrl, ram_init_masks.all);
 	}
 	spin_unlock(&raminit_lock);
 }
@@ -221,11 +237,24 @@ static int c_can_plat_probe(struct platform_device *pdev)
 			priv->instance = pdev->id;
 
 		res = platform_get_resource(pdev, IORESOURCE_MEM, 1);
+		/* Not all D_CAN module have a separate register for the D_CAN
+		 * RAM initialization. Use default RAM init bit in D_CAN module
+		 * if not specified in DT.
+		 */
+		if (!res) {
+			priv->raminit = c_can_hw_raminit;
+			priv->raminit_type_flag = 0;
+			priv->raminit_ctrlreg = addr +
+				priv->regs[C_CAN_FUNCTION_REG];
+			break;
+		}
 		priv->raminit_ctrlreg = devm_ioremap_resource(&pdev->dev, res);
-		if (IS_ERR(priv->raminit_ctrlreg) || (int)priv->instance < 0)
+		if (IS_ERR(priv->raminit_ctrlreg) || (int)priv->instance < 0) {
 			dev_info(&pdev->dev, "control memory is not used for raminit\n");
-		else
+		} else {
 			priv->raminit = c_can_hw_raminit;
+			priv->raminit_type_flag = 1;
+		}
 		break;
 	default:
 		ret = -EINVAL;
-- 
1.7.9.5


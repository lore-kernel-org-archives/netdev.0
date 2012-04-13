From: Roland Stigge <stigge@antcom.de>
Subject: [PATCH RESEND v3 8/8] i2c: Add device tree support to i2c-pnx.c
Date: Sat, 14 Apr 2012 00:36:39 +0200
Message-ID: <1334356600-20950-8-git-send-email-stigge@antcom.de>
References: <1334356600-20950-1-git-send-email-stigge@antcom.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Roland Stigge <stigge@antcom.de>
To: arm@kernel.org, linux-arm-kernel@lists.infradead.org,
 linux-i2c@vger.kernel.org, linux-kernel@vger.kernel.org,
 w.sang@pengutronix.de, srinivas.bakki@nxp.com, kevin.wells@nxp.com,
 gregkh@linuxfoundation.org, netdev@vger.kernel.org,
 rtc-linux@googlegroups.com, a.zummo@towertech.it,
 linux-watchdog@vger.kernel.org, wim@iguana.be, jonsmirl@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1334356600-20950-1-git-send-email-stigge@antcom.de>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds device tree support to the pnx-i2c driver by using platform
resources for memory region and irq and removing dependency on mach includes.

The following platforms are affected:

* PNX
* LPC31xx (WIP)
* LPC32xx

The patch is based on a patch by Jon Smirl, working on lpc31xx integration

Signed-off-by: Roland Stigge <stigge@antcom.de>
Reviewed-by: Arnd Bergmann <arnd@arndb.de>

---

 Applies to v3.4-rc2

 Documentation/devicetree/bindings/i2c/pnx.txt |   40 ++++++++++++++++
 drivers/i2c/busses/i2c-pnx.c                  |   65 +++++++++++++++++++-------
 include/linux/i2c-pnx.h                       |    1 
 3 files changed, 89 insertions(+), 17 deletions(-)

--- /dev/null
+++ linux-2.6/Documentation/devicetree/bindings/i2c/pnx.txt
@@ -0,0 +1,40 @@
+* NXP PNX I2C Controller
+
+Required properties:
+
+ - reg: Offset and length of the register set for the device
+ - compatible: should be "nxp,pnx-i2c"
+ - interrupts: configure one interrupt line
+ - #address-cells: always 1 (for i2c addresses)
+ - #size-cells: always 0
+
+Optional properties:
+
+ - interrupt-parent: the phandle for the interrupt controller that
+   services interrupts for this device.
+ - clock-frequency: desired I2C bus clock frequency in Hz, Default: 100000 Hz
+ - pnx,timeout: I2C bus timeout in milliseconds, Default: 10 ms
+ - slave-addr: Address used by the controller, Hardware default: 110
+
+Examples:
+
+	i2c1: i2c@400a0000 {
+		compatible = "nxp,pnx-i2c";
+		reg = <0x400a0000 0x100>;
+		interrupt-parent = <&mic>;
+		interrupts = <51 0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+	};
+
+	i2c2: i2c@400a8000 {
+		compatible = "nxp,pnx-i2c";
+		reg = <0x400a8000 0x100>;
+		interrupt-parent = <&mic>;
+		interrupts = <50 0>;
+		#address-cells = <1>;
+		#size-cells = <0>;
+		clock-frequency = <0x186a0>;
+		pnx,timeout = <0x64>;
+		slave-addr = <0x11>;
+	};
--- linux-2.6.orig/drivers/i2c/busses/i2c-pnx.c
+++ linux-2.6/drivers/i2c/busses/i2c-pnx.c
@@ -23,10 +23,11 @@
 #include <linux/err.h>
 #include <linux/clk.h>
 #include <linux/slab.h>
+#include <linux/of_i2c.h>
 
-#define I2C_PNX_TIMEOUT		10 /* msec */
-#define I2C_PNX_SPEED_KHZ	100
-#define I2C_PNX_REGION_SIZE	0x100
+#define I2C_PNX_TIMEOUT_DEFAULT		10 /* msec */
+#define I2C_PNX_SPEED_KHZ_DEFAULT	100
+#define I2C_PNX_REGION_SIZE		0x100
 
 enum {
 	mstatus_tdi = 0x00000001,
@@ -74,8 +75,9 @@ enum {
 #define I2C_REG_TXS(a)	((a)->ioaddr + 0x28)	/* Tx slave FIFO (RO) */
 #define I2C_REG_STFL(a)	((a)->ioaddr + 0x2c)	/* Tx slave FIFO level (RO) */
 
-static inline int wait_timeout(long timeout, struct i2c_pnx_algo_data *data)
+static inline int wait_timeout(struct i2c_pnx_algo_data *data)
 {
+	long timeout = data->timeout;
 	while (timeout > 0 &&
 			(ioread32(I2C_REG_STS(data)) & mstatus_active)) {
 		mdelay(1);
@@ -84,8 +86,9 @@ static inline int wait_timeout(long time
 	return (timeout <= 0);
 }
 
-static inline int wait_reset(long timeout, struct i2c_pnx_algo_data *data)
+static inline int wait_reset(struct i2c_pnx_algo_data *data)
 {
+	long timeout = data->timeout;
 	while (timeout > 0 &&
 			(ioread32(I2C_REG_CTL(data)) & mcntrl_reset)) {
 		mdelay(1);
@@ -97,7 +100,7 @@ static inline int wait_reset(long timeou
 static inline void i2c_pnx_arm_timer(struct i2c_pnx_algo_data *alg_data)
 {
 	struct timer_list *timer = &alg_data->mif.timer;
-	unsigned long expires = msecs_to_jiffies(I2C_PNX_TIMEOUT);
+	unsigned long expires = msecs_to_jiffies(alg_data->timeout);
 
 	if (expires <= 1)
 		expires = 2;
@@ -135,7 +138,7 @@ static int i2c_pnx_start(unsigned char s
 	}
 
 	/* First, make sure bus is idle */
-	if (wait_timeout(I2C_PNX_TIMEOUT, alg_data)) {
+	if (wait_timeout(alg_data)) {
 		/* Somebody else is monopolizing the bus */
 		dev_err(&alg_data->adapter.dev,
 			"%s: Bus busy. Slave addr = %02x, cntrl = %x, stat = %x\n",
@@ -228,7 +231,7 @@ static int i2c_pnx_master_xmit(struct i2
 		if (alg_data->mif.len == 0) {
 			if (alg_data->last) {
 				/* Wait until the STOP is seen. */
-				if (wait_timeout(I2C_PNX_TIMEOUT, alg_data))
+				if (wait_timeout(alg_data))
 					dev_err(&alg_data->adapter.dev,
 						"The bus is still active after timeout\n");
 			}
@@ -326,7 +329,7 @@ static int i2c_pnx_master_rcv(struct i2c
 		if (alg_data->mif.len == 0) {
 			if (alg_data->last)
 				/* Wait until the STOP is seen. */
-				if (wait_timeout(I2C_PNX_TIMEOUT, alg_data))
+				if (wait_timeout(alg_data))
 					dev_err(&alg_data->adapter.dev,
 						"The bus is still active after timeout\n");
 
@@ -442,7 +445,7 @@ static void i2c_pnx_timeout(unsigned lon
 
 	ctl |= mcntrl_reset;
 	iowrite32(ctl, I2C_REG_CTL(alg_data));
-	wait_reset(I2C_PNX_TIMEOUT, alg_data);
+	wait_reset(alg_data);
 	alg_data->mif.ret = -EIO;
 	complete(&alg_data->mif.complete);
 }
@@ -457,18 +460,18 @@ static inline void bus_reset_if_active(s
 			alg_data->adapter.name);
 		iowrite32(ioread32(I2C_REG_CTL(alg_data)) | mcntrl_reset,
 			  I2C_REG_CTL(alg_data));
-		wait_reset(I2C_PNX_TIMEOUT, alg_data);
+		wait_reset(alg_data);
 	} else if (!(stat & mstatus_rfe) || !(stat & mstatus_tfe)) {
 		/* If there is data in the fifo's after transfer,
 		 * flush fifo's by reset.
 		 */
 		iowrite32(ioread32(I2C_REG_CTL(alg_data)) | mcntrl_reset,
 			  I2C_REG_CTL(alg_data));
-		wait_reset(I2C_PNX_TIMEOUT, alg_data);
+		wait_reset(alg_data);
 	} else if (stat & mstatus_nai) {
 		iowrite32(ioread32(I2C_REG_CTL(alg_data)) | mcntrl_reset,
 			  I2C_REG_CTL(alg_data));
-		wait_reset(I2C_PNX_TIMEOUT, alg_data);
+		wait_reset(alg_data);
 	}
 }
 
@@ -612,6 +615,8 @@ static int __devinit i2c_pnx_probe(struc
 	struct i2c_pnx_algo_data *alg_data;
 	unsigned long freq;
 	struct resource *res;
+	u32 speed = I2C_PNX_SPEED_KHZ_DEFAULT * 1000;
+	u32 slave_addr = ~0;
 
 	alg_data = kzalloc(sizeof(*alg_data), GFP_KERNEL);
 	if (!alg_data) {
@@ -626,6 +631,18 @@ static int __devinit i2c_pnx_probe(struc
 	alg_data->adapter.algo_data = alg_data;
 	alg_data->adapter.nr = pdev->id;
 
+	alg_data->timeout = I2C_PNX_TIMEOUT_DEFAULT;
+#ifdef CONFIG_OF
+	alg_data->adapter.dev.of_node = of_node_get(pdev->dev.of_node);
+	if (pdev->dev.of_node) {
+		of_property_read_u32(pdev->dev.of_node, "pnx,timeout",
+				     &alg_data->timeout);
+		of_property_read_u32(pdev->dev.of_node, "clock-frequency",
+				     &speed);
+		of_property_read_u32(pdev->dev.of_node, "slave-addr",
+				     &slave_addr);
+	}
+#endif
 	alg_data->clk = clk_get(&pdev->dev, NULL);
 	if (IS_ERR(alg_data->clk)) {
 		ret = PTR_ERR(alg_data->clk);
@@ -651,7 +668,7 @@ static int __devinit i2c_pnx_probe(struc
 		dev_err(&pdev->dev,
 		       "I/O region 0x%08x for I2C already in use.\n",
 		       res->start);
-		ret = -ENODEV;
+		ret = -ENOMEM;
 		goto out_clkget;
 	}
 
@@ -667,6 +684,9 @@ static int __devinit i2c_pnx_probe(struc
 	if (ret)
 		goto out_unmap;
 
+	if (slave_addr != ~0)
+		iowrite32(slave_addr, I2C_REG_ADR(alg_data));
+
 	freq = clk_get_rate(alg_data->clk);
 
 	/*
@@ -680,14 +700,14 @@ static int __devinit i2c_pnx_probe(struc
 	 * the deglitching filter length.
 	 */
 
-	tmp = ((freq / 1000) / I2C_PNX_SPEED_KHZ) / 2 - 2;
+	tmp = (freq / speed) / 2 - 2;
 	if (tmp > 0x3FF)
 		tmp = 0x3FF;
 	iowrite32(tmp, I2C_REG_CKH(alg_data));
 	iowrite32(tmp, I2C_REG_CKL(alg_data));
 
 	iowrite32(mcntrl_reset, I2C_REG_CTL(alg_data));
-	if (wait_reset(I2C_PNX_TIMEOUT, alg_data)) {
+	if (wait_reset(alg_data)) {
 		ret = -ENODEV;
 		goto out_clock;
 	}
@@ -699,7 +719,7 @@ static int __devinit i2c_pnx_probe(struc
 		goto out_irq;
 	}
 	ret = request_irq(alg_data->irq, i2c_pnx_interrupt,
-			0, pdev->name, alg_data);
+			  0, pdev->name, alg_data);
 	if (ret)
 		goto out_clock;
 
@@ -710,6 +730,8 @@ static int __devinit i2c_pnx_probe(struc
 		goto out_irq;
 	}
 
+	of_i2c_register_devices(&alg_data->adapter);
+
 	dev_dbg(&pdev->dev, "%s: Master at %#8x, irq %d.\n",
 		alg_data->adapter.name, res->start, alg_data->irq);
 
@@ -748,10 +770,19 @@ static int __devexit i2c_pnx_remove(stru
 	return 0;
 }
 
+#ifdef CONFIG_OF
+static const struct of_device_id i2c_pnx_of_match[] = {
+	{ .compatible = "nxp,pnx-i2c" },
+	{ },
+};
+MODULE_DEVICE_TABLE(of, i2c_pnx_of_match);
+#endif
+
 static struct platform_driver i2c_pnx_driver = {
 	.driver = {
 		.name = "pnx-i2c",
 		.owner = THIS_MODULE,
+		.of_match_table = of_match_ptr(i2c_pnx_of_match),
 	},
 	.probe = i2c_pnx_probe,
 	.remove = __devexit_p(i2c_pnx_remove),
--- linux-2.6.orig/include/linux/i2c-pnx.h
+++ linux-2.6/include/linux/i2c-pnx.h
@@ -32,6 +32,7 @@ struct i2c_pnx_algo_data {
 	struct i2c_adapter	adapter;
 	phys_addr_t		base;
 	int			irq;
+	u32			timeout;
 };
 
 #endif /* __I2C_PNX_H__ */

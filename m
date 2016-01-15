From: Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH 1/2] ne: DeviceTree support.
Date: Sat, 16 Jan 2016 01:19:45 +0900
Message-ID: <1452874786-21202-1-git-send-email-ysato@users.sourceforge.jp>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add basic device tree support.

Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
---
 Documentation/devicetree/bindings/net/ne2000.txt | 17 +++++++++++++++++
 drivers/net/ethernet/8390/ne.c                   | 20 +++++++++++++++++++-
 2 files changed, 36 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/ne2000.txt

diff --git a/Documentation/devicetree/bindings/net/ne2000.txt b/Documentation/devicetree/bindings/net/ne2000.txt
new file mode 100644
index 0000000..8b0dfbf
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ne2000.txt
@@ -0,0 +1,17 @@
+NE2000 compatible network controller
+
+Required properties:
+- compatible: "national,ne2000"
+- reg: base address and length of NE2000.
+- interrupts: interrupt specifier for the sole interrupt.
+- national,dcr: DCR setting value.
+
+Example
+
+	ne2000: ethernet@200000 {
+		compatible = "national,ne2000";
+		reg = <0x200000 32>;
+		interrupts = <17 0>;
+		national,dcr = <0x48>;
+	};
+
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index c063b41..a9dde5b 100644
--- a/drivers/net/ethernet/8390/ne.c
+++ b/drivers/net/ethernet/8390/ne.c
@@ -52,6 +52,7 @@ static const char version2[] =
 #include <linux/etherdevice.h>
 #include <linux/jiffies.h>
 #include <linux/platform_device.h>
+#include <linux/of.h>
 
 #include <asm/io.h>
 
@@ -72,6 +73,7 @@ static int io[MAX_NE_CARDS];
 static int irq[MAX_NE_CARDS];
 static int bad[MAX_NE_CARDS];
 static u32 ne_msg_enable;
+static unsigned int of_dcr_val;
 
 #ifdef MODULE
 module_param_array(io, int, NULL, 0);
@@ -171,6 +173,8 @@ bad_clone_list[] __initdata = {
 #  define DCR_VAL 0x48		/* 8-bit mode */
 #elif defined(CONFIG_ATARI)	/* 8-bit mode on Atari, normal on Q40 */
 #  define DCR_VAL (MACH_IS_ATARI ? 0x48 : 0x49)
+#elif defined(CONFIG_OF_NET)
+#  define DCR_VAL of_dcr_val
 #else
 #  define DCR_VAL 0x49
 #endif
@@ -304,7 +308,8 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 	struct ei_device *ei_local = netdev_priv(dev);
 
 	if (!request_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
-		return -EBUSY;
+		if (!request_mem_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
+			return -EBUSY;
 
 	reg0 = inb_p(ioaddr);
 	if (reg0 == 0xFF) {
@@ -808,11 +813,18 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
+	if (dev_of_node(&pdev->dev))
+		of_property_read_u32(dev_of_node(&pdev->dev),
+				     "national,dcr", &of_dcr_val);
+
 	/* ne.c doesn't populate resources in platform_device, but
 	 * rbtx4927_ne_init and rbtx4938_ne_init do register devices
 	 * with resources.
 	 */
 	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
+	if (!res)
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
+
 	if (res) {
 		dev->base_addr = res->start;
 		dev->irq = platform_get_irq(pdev, 0);
@@ -914,12 +926,18 @@ static int ne_drv_resume(struct platform_device *pdev)
 #define ne_drv_resume NULL
 #endif
 
+static const struct of_device_id ne2000_of_table[] __maybe_unused = {
+	{ .compatible = "national,ne2000" },
+	{ }
+};
+
 static struct platform_driver ne_driver = {
 	.remove		= ne_drv_remove,
 	.suspend	= ne_drv_suspend,
 	.resume		= ne_drv_resume,
 	.driver		= {
 		.name	= DRV_NAME,
+		.of_match_table = of_match_ptr(ne2000_of_table),
 	},
 };
 
-- 
2.6.1

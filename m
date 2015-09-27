From: Yoshinori Sato <ysato@users.sourceforge.jp>
Subject: [PATCH 2/2] ne: DeviceTree support.
Date: Sun, 27 Sep 2015 23:19:16 +0900
Message-ID: <1443363556-29937-2-git-send-email-ysato@users.sourceforge.jp>
References: <1443363556-29937-1-git-send-email-ysato@users.sourceforge.jp>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.asahi-net.or.jp ([202.224.39.197]:41492 "EHLO
	mail1.asahi-net.or.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755879AbbI0Ojl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Sep 2015 10:39:41 -0400
In-Reply-To: <1443363556-29937-1-git-send-email-ysato@users.sourceforge.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Yoshinori Sato <ysato@users.sourceforge.jp>
---
 Documentation/devicetree/bindings/net/ne2000.txt | 17 +++++++++++++++++
 drivers/net/ethernet/8390/ne.c                   | 20 +++++++++++++++++++-
 2 files changed, 36 insertions(+), 1 deletion(-)
 create mode 100644 Documentation/devicetree/bindings/net/ne2000.txt

diff --git a/Documentation/devicetree/bindings/net/ne2000.txt b/Documentation/devicetree/bindings/net/ne2000.txt
new file mode 100644
index 0000000..69b68dfb
--- /dev/null
+++ b/Documentation/devicetree/bindings/net/ne2000.txt
@@ -0,0 +1,17 @@
+NE2000 compatible network controller
+
+Required properties:
+- compatible: "novell,ne2000"
+- reg: base address and length of NE2000.
+- interrupts: interrupt specifier for the sole interrupt.
+- novell,dcr: DCR setting value.
+
+Example
+
+	ne2000: ethernet@200000 {
+		compatible = "realtek,rtl8019as", "novell,ne2000";
+		reg = <0x200000 32>;
+		interrupts = <17 0>;
+		novell,dcr = <0x48>;
+	};
+
diff --git a/drivers/net/ethernet/8390/ne.c b/drivers/net/ethernet/8390/ne.c
index 576917c..f0a0400 100644
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
+		if(!request_mem_region(ioaddr, NE_IO_EXTENT, DRV_NAME))
+			return -EBUSY;
 
 	reg0 = inb_p(ioaddr);
 	if (reg0 == 0xFF) {
@@ -809,11 +814,18 @@ static int __init ne_drv_probe(struct platform_device *pdev)
 	if (!dev)
 		return -ENOMEM;
 
+
+	if (dev->dev.of_node)
+		of_property_read_u32(dev->dev.of_node,
+				     "novell,dcr", &of_dcr_val);
+
 	/* ne.c doesn't populate resources in platform_device, but
 	 * rbtx4927_ne_init and rbtx4938_ne_init do register devices
 	 * with resources.
 	 */
 	res = platform_get_resource(pdev, IORESOURCE_IO, 0);
+	if (res == NULL)
+		res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
 	if (res) {
 		dev->base_addr = res->start;
 		dev->irq = platform_get_irq(pdev, 0);
@@ -915,12 +927,18 @@ static int ne_drv_resume(struct platform_device *pdev)
 #define ne_drv_resume NULL
 #endif
 
+static const struct of_device_id ne2000_of_table[] __maybe_unused = {
+	{ .compatible = "novell,ne2000" },
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
2.1.4

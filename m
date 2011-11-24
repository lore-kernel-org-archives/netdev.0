From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH] can: sja1000_isa: convert to platform driver to support x86_64
 systems
Date: Thu, 24 Nov 2011 10:58:22 +0100
Message-ID: <4ECE153E.7090408@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	Willy Lambert <lambert.willy@gmail.com>
To: Netdev@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This driver is currently not supported on x86_64 systems because the
"isa_driver" interface is used (CONFIG_ISA=y). To overcome this
limitation, the driver is converted to a platform driver, similar to
the serial 8250 driver.

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
---
 drivers/net/can/sja1000/Kconfig       |    1 -
 drivers/net/can/sja1000/sja1000_isa.c |   94 +++++++++++++++++++++++----------
 2 files changed, 65 insertions(+), 30 deletions(-)

diff --git a/drivers/net/can/sja1000/Kconfig b/drivers/net/can/sja1000/Kconfig
index fe9e64d..36e9d59 100644
--- a/drivers/net/can/sja1000/Kconfig
+++ b/drivers/net/can/sja1000/Kconfig
@@ -6,7 +6,6 @@ if CAN_SJA1000
 
 config CAN_SJA1000_ISA
 	tristate "ISA Bus based legacy SJA1000 driver"
-	depends on ISA
 	---help---
 	  This driver adds legacy support for SJA1000 chips connected to
 	  the ISA bus using I/O port, memory mapped or indirect access.
diff --git a/drivers/net/can/sja1000/sja1000_isa.c b/drivers/net/can/sja1000/sja1000_isa.c
index f0840d5..90c5c2d 100644
--- a/drivers/net/can/sja1000/sja1000_isa.c
+++ b/drivers/net/can/sja1000/sja1000_isa.c
@@ -17,7 +17,7 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/isa.h>
+#include <linux/platform_device.h>
 #include <linux/interrupt.h>
 #include <linux/netdevice.h>
 #include <linux/delay.h>
@@ -75,6 +75,8 @@ MODULE_PARM_DESC(ocr, "Output control register "
 #define SJA1000_IOSIZE          0x20
 #define SJA1000_IOSIZE_INDIRECT 0x02
 
+static struct platform_device *sja1000_isa_devs[MAXDEV];
+
 static u8 sja1000_isa_mem_read_reg(const struct sja1000_priv *priv, int reg)
 {
 	return readb(priv->reg_base + reg);
@@ -115,26 +117,18 @@ static void sja1000_isa_port_write_reg_indirect(const struct sja1000_priv *priv,
 	outb(val, base + 1);
 }
 
-static int __devinit sja1000_isa_match(struct device *pdev, unsigned int idx)
-{
-	if (port[idx] || mem[idx]) {
-		if (irq[idx])
-			return 1;
-	} else if (idx)
-		return 0;
-
-	dev_err(pdev, "insufficient parameters supplied\n");
-	return 0;
-}
-
-static int __devinit sja1000_isa_probe(struct device *pdev, unsigned int idx)
+static int __devinit sja1000_isa_probe(struct platform_device *pdev)
 {
 	struct net_device *dev;
 	struct sja1000_priv *priv;
 	void __iomem *base = NULL;
 	int iosize = SJA1000_IOSIZE;
+	int idx = pdev->id;
 	int err;
 
+	dev_dbg(&pdev->dev, "probing idx=%d: port=%#lx, mem=%#lx, irq=%d\n",
+		idx, port[idx], mem[idx], irq[idx]);
+
 	if (mem[idx]) {
 		if (!request_mem_region(mem[idx], iosize, DRV_NAME)) {
 			err = -EBUSY;
@@ -203,17 +197,17 @@ static int __devinit sja1000_isa_probe(struct device *pdev, unsigned int idx)
 	else
 		priv->cdr = CDR_DEFAULT;
 
-	dev_set_drvdata(pdev, dev);
-	SET_NETDEV_DEV(dev, pdev);
+	dev_set_drvdata(&pdev->dev, dev);
+	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	err = register_sja1000dev(dev);
 	if (err) {
-		dev_err(pdev, "registering %s failed (err=%d)\n",
+		dev_err(&pdev->dev, "registering %s failed (err=%d)\n",
 			DRV_NAME, err);
 		goto exit_unmap;
 	}
 
-	dev_info(pdev, "%s device registered (reg_base=0x%p, irq=%d)\n",
+	dev_info(&pdev->dev, "%s device registered (reg_base=0x%p, irq=%d)\n",
 		 DRV_NAME, priv->reg_base, dev->irq);
 	return 0;
 
@@ -229,13 +223,14 @@ static int __devinit sja1000_isa_probe(struct device *pdev, unsigned int idx)
 	return err;
 }
 
-static int __devexit sja1000_isa_remove(struct device *pdev, unsigned int idx)
+static int __devexit sja1000_isa_remove(struct platform_device *pdev)
 {
-	struct net_device *dev = dev_get_drvdata(pdev);
+	struct net_device *dev = dev_get_drvdata(&pdev->dev);
 	struct sja1000_priv *priv = netdev_priv(dev);
+	int idx = pdev->id;
 
 	unregister_sja1000dev(dev);
-	dev_set_drvdata(pdev, NULL);
+	dev_set_drvdata(&pdev->dev, NULL);
 
 	if (mem[idx]) {
 		iounmap(priv->reg_base);
@@ -251,29 +246,70 @@ static int __devexit sja1000_isa_remove(struct device *pdev, unsigned int idx)
 	return 0;
 }
 
-static struct isa_driver sja1000_isa_driver = {
-	.match = sja1000_isa_match,
+static struct platform_driver sja1000_isa_driver = {
 	.probe = sja1000_isa_probe,
 	.remove = __devexit_p(sja1000_isa_remove),
 	.driver = {
 		.name = DRV_NAME,
+		.owner = THIS_MODULE,
 	},
 };
 
 static int __init sja1000_isa_init(void)
 {
-	int err = isa_register_driver(&sja1000_isa_driver, MAXDEV);
+	int idx, err;
+
+	for (idx = 0; idx < MAXDEV; idx++) {
+		if ((port[idx] || mem[idx]) && irq[idx]) {
+			sja1000_isa_devs[idx] =
+				platform_device_alloc(DRV_NAME, idx);
+			if (!sja1000_isa_devs[idx]) {
+				err = -ENOMEM;
+				goto exit_free_devices;
+			}
+			err = platform_device_add(sja1000_isa_devs[idx]);
+			if (err) {
+				platform_device_put(sja1000_isa_devs[idx]);
+				goto exit_free_devices;
+			}
+			pr_debug("%s: platform device %d: port=%#lx, mem=%#lx, "
+				 "irq=%d\n",
+				 DRV_NAME, idx, port[idx], mem[idx], irq[idx]);
+		} else if (idx == 0 || port[idx] || mem[idx]) {
+				pr_err("%s: insufficient parameters supplied\n",
+				       DRV_NAME);
+				err = -EINVAL;
+				goto exit_free_devices;
+		}
+	}
+
+	err = platform_driver_register(&sja1000_isa_driver);
+	if (err)
+		goto exit_free_devices;
+
+	pr_info("Legacy %s driver for max. %d devices registered\n",
+		DRV_NAME, MAXDEV);
+
+	return 0;
+
+exit_free_devices:
+	while (--idx >= 0) {
+		if (sja1000_isa_devs[idx])
+			platform_device_unregister(sja1000_isa_devs[idx]);
+	}
 
-	if (!err)
-		printk(KERN_INFO
-		       "Legacy %s driver for max. %d devices registered\n",
-		       DRV_NAME, MAXDEV);
 	return err;
 }
 
 static void __exit sja1000_isa_exit(void)
 {
-	isa_unregister_driver(&sja1000_isa_driver);
+	int idx;
+
+	platform_driver_unregister(&sja1000_isa_driver);
+	for (idx = 0; idx < MAXDEV; idx++) {
+		if (sja1000_isa_devs[idx])
+			platform_device_unregister(sja1000_isa_devs[idx]);
+	}
 }
 
 module_init(sja1000_isa_init);
-- 
1.7.4.1



From: David Woodhouse <dwmw2@infradead.org>
Subject: [PATCH 1/4] solos-pci: add GPIO support for newer versions on Geos board
Date: Wed, 19 Dec 2012 21:01:18 +0000
Message-ID: <1355950881-31550-1-git-send-email-dwmw2@infradead.org>
Cc: Nathan Williams <nathan@traverse.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:34933
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076Ab2LSVBg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2012 16:01:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nathan Williams <nathan@traverse.com.au>

dwmw2: Tidy up a little, simpler matching on which GPIO is being accessed,
       only register on newer boards, register under PCI device instead of
       duplicating them under each ATM device.

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
Signed-off-by: David Woodhouse <David.Woodhouse@intel.com>
---
 drivers/atm/solos-pci.c | 105 ++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 105 insertions(+)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index c909b7b..473d808 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -56,6 +56,7 @@
 #define FLASH_BUSY	0x60
 #define FPGA_MODE	0x5C
 #define FLASH_MODE	0x58
+#define GPIO_STATUS	0x54
 #define TX_DMA_ADDR(port)	(0x40 + (4 * (port)))
 #define RX_DMA_ADDR(port)	(0x30 + (4 * (port)))
 
@@ -498,6 +499,78 @@ static ssize_t console_store(struct device *dev, struct device_attribute *attr,
 	return err?:count;
 }
 
+struct geos_gpio_attr {
+	struct device_attribute attr;
+	int offset;
+};
+
+#define SOLOS_GPIO_ATTR(_name, _mode, _show, _store, _offset)	\
+	struct geos_gpio_attr gpio_attr_##_name = {		\
+		.attr = __ATTR(_name, _mode, _show, _store),	\
+		.offset = _offset }
+
+static ssize_t geos_gpio_store(struct device *dev, struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct geos_gpio_attr *gattr = container_of(attr, struct geos_gpio_attr, attr);
+	struct solos_card *card = pci_get_drvdata(pdev);
+	uint32_t data32;
+
+	if (count != 1 && (count != 2 || buf[1] != '\n'))
+		return -EINVAL;
+
+	spin_lock_irq(&card->param_queue_lock);
+	data32 = ioread32(card->config_regs + GPIO_STATUS);
+	if (buf[0] == '1') {
+		data32 |= 1 << gattr->offset;
+		iowrite32(data32, card->config_regs + GPIO_STATUS);
+	} else if (buf[0] == '0') {
+		data32 &= ~(1 << gattr->offset);
+		iowrite32(data32, card->config_regs + GPIO_STATUS);
+	} else {
+		count = -EINVAL;
+	}
+	spin_lock_irq(&card->param_queue_lock);
+	return count;
+}
+
+static ssize_t geos_gpio_show(struct device *dev, struct device_attribute *attr,
+			      char *buf)
+{
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct geos_gpio_attr *gattr = container_of(attr, struct geos_gpio_attr, attr);
+	struct solos_card *card = pci_get_drvdata(pdev);
+	uint32_t data32;
+
+	data32 = ioread32(card->config_regs + GPIO_STATUS);
+	data32 = (data32 >> gattr->offset) & 1;
+
+	return sprintf(buf, "%d\n", data32);
+}
+
+static ssize_t hardware_show(struct device *dev, struct device_attribute *attr,
+			     char *buf)
+{
+	struct pci_dev *pdev = container_of(dev, struct pci_dev, dev);
+	struct geos_gpio_attr *gattr = container_of(attr, struct geos_gpio_attr, attr);
+	struct solos_card *card = pci_get_drvdata(pdev);
+	uint32_t data32;
+
+	data32 = ioread32(card->config_regs + GPIO_STATUS);
+	switch (gattr->offset) {
+	case 0:
+		/* HardwareVersion */
+		data32 = data32 & 0x1F;
+		break;
+	case 1:
+		/* HardwareVariant */
+		data32 = (data32 >> 5) & 0x0F;
+		break;
+	}
+	return sprintf(buf, "%d\n", data32);
+}
+
 static DEVICE_ATTR(console, 0644, console_show, console_store);
 
 
@@ -506,6 +579,14 @@ static DEVICE_ATTR(console, 0644, console_show, console_store);
 
 #include "solos-attrlist.c"
 
+static SOLOS_GPIO_ATTR(GPIO1, 0644, geos_gpio_show, geos_gpio_store, 9);
+static SOLOS_GPIO_ATTR(GPIO2, 0644, geos_gpio_show, geos_gpio_store, 10);
+static SOLOS_GPIO_ATTR(GPIO3, 0644, geos_gpio_show, geos_gpio_store, 11);
+static SOLOS_GPIO_ATTR(GPIO4, 0644, geos_gpio_show, geos_gpio_store, 12);
+static SOLOS_GPIO_ATTR(GPIO5, 0644, geos_gpio_show, geos_gpio_store, 13);
+static SOLOS_GPIO_ATTR(PushButton, 0444, geos_gpio_show, NULL, 14);
+static SOLOS_GPIO_ATTR(HardwareVersion, 0444, hardware_show, NULL, 0);
+static SOLOS_GPIO_ATTR(HardwareVariant, 0444, hardware_show, NULL, 1);
 #undef SOLOS_ATTR_RO
 #undef SOLOS_ATTR_RW
 
@@ -522,6 +603,23 @@ static struct attribute_group solos_attr_group = {
 	.name = "parameters",
 };
 
+static struct attribute *gpio_attrs[] = {
+	&gpio_attr_GPIO1.attr.attr,
+	&gpio_attr_GPIO2.attr.attr,
+	&gpio_attr_GPIO3.attr.attr,
+	&gpio_attr_GPIO4.attr.attr,
+	&gpio_attr_GPIO5.attr.attr,
+	&gpio_attr_PushButton.attr.attr,
+	&gpio_attr_HardwareVersion.attr.attr,
+	&gpio_attr_HardwareVariant.attr.attr,
+	NULL
+};
+
+static struct attribute_group gpio_attr_group = {
+	.attrs = gpio_attrs,
+	.name = "gpio",
+};
+
 static int flash_upgrade(struct solos_card *card, int chip)
 {
 	const struct firmware *fw;
@@ -1179,6 +1277,10 @@ static int fpga_probe(struct pci_dev *dev, const struct pci_device_id *id)
 	if (err)
 		goto out_free_irq;
 
+	if (card->fpga_version >= DMA_SUPPORTED &&
+	    sysfs_create_group(&card->dev->dev.kobj, &gpio_attr_group))
+		dev_err(&card->dev->dev, "Could not register parameter group for GPIOs\n");
+
 	return 0;
 
  out_free_irq:
@@ -1289,6 +1391,9 @@ static void fpga_remove(struct pci_dev *dev)
 	iowrite32(1, card->config_regs + FPGA_MODE);
 	(void)ioread32(card->config_regs + FPGA_MODE); 
 
+	if (card->fpga_version >= DMA_SUPPORTED)
+		sysfs_remove_group(&card->dev->dev.kobj, &gpio_attr_group);
+
 	atm_remove(card);
 
 	free_irq(dev->irq, card);
-- 
1.8.0.1

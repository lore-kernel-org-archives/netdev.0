From: Nathan Williams <nathan@traverse.com.au>
Subject: [PATCH 3/4] atm: solos-pci: Add support for Geos GPIO pins
Date: Wed, 05 Oct 2011 15:45:15 +1100
Message-ID: <1317789915.2424.89.camel@dualcore.traverse>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net,
	David Woodhouse <dwmw2@infradead.org>,
	linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Geos ADSL2+ routers have on-board Solos chipsets with some
extra I/O pins and a push button connected to the FPGA.

PCB version and variant numbers are also made available
through the HardwareVersion and HardwareVariant attributes.

Signed-off-by: Nathan Williams <nathan@traverse.com.au>
---
 drivers/atm/solos-pci.c |   98 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 98 insertions(+), 0 deletions(-)

diff --git a/drivers/atm/solos-pci.c b/drivers/atm/solos-pci.c
index bd01aa3..33c0c2b 100644
--- a/drivers/atm/solos-pci.c
+++ b/drivers/atm/solos-pci.c
@@ -56,6 +56,7 @@
 #define FLASH_BUSY	0x60
 #define FPGA_MODE	0x5C
 #define FLASH_MODE	0x58
+#define GPIO_STATUS	0x54
 #define TX_DMA_ADDR(port)	(0x40 + (4 * (port)))
 #define RX_DMA_ADDR(port)	(0x30 + (4 * (port)))
 
@@ -498,6 +499,87 @@ static ssize_t console_store(struct device *dev, struct device_attribute *attr,
 	return err?:count;
 }
 
+struct geos_gpio {
+	char *name;
+	int offset;
+};
+
+static struct geos_gpio geos_gpio_pins[] = {
+	{"GPIO1", 9},
+	{"GPIO2", 10},
+	{"GPIO3", 11},
+	{"GPIO4", 12},
+	{"GPIO5", 13},
+	{"PushButton", 14},
+	{NULL, 0}
+};
+
+static ssize_t geos_gpio_store(struct device *dev, struct device_attribute *attr,
+			       const char *buf, size_t count)
+{
+	struct atm_dev *atmdev = container_of(dev, struct atm_dev, class_dev);
+	struct solos_card *card = atmdev->dev_data;
+	uint32_t data32;
+
+	struct geos_gpio *p = geos_gpio_pins;
+	while(p->name){
+		if(!strcmp(attr->attr.name, p->name)){
+			break;
+		}
+		p++;
+	}
+
+	data32 = ioread32(card->config_regs + GPIO_STATUS);
+	if(buf[0] == '1'){
+		data32 |= 1 << p->offset;
+		iowrite32(data32, card->config_regs + GPIO_STATUS);
+	} else if(buf[0] == '0') {
+		data32 &= ~(1 << p->offset);
+		iowrite32(data32, card->config_regs + GPIO_STATUS);
+	}
+	return count;
+}
+
+static ssize_t geos_gpio_show(struct device *dev, struct device_attribute *attr,
+			      char *buf)
+{
+	struct atm_dev *atmdev = container_of(dev, struct atm_dev, class_dev);
+	struct solos_card *card = atmdev->dev_data;
+	uint32_t data32;
+
+	struct geos_gpio *p = geos_gpio_pins;
+	while(p->name){
+		if(!strcmp(attr->attr.name, p->name)){
+			break;
+		}
+		p++;
+	}
+
+	data32 = ioread32(card->config_regs + GPIO_STATUS);
+	data32 = (data32 >> p->offset) & 1;
+
+	return sprintf(buf, "%d\n", data32);
+}
+
+static ssize_t hardware_show(struct device *dev, struct device_attribute *attr,
+			     char *buf)
+{
+	struct atm_dev *atmdev = container_of(dev, struct atm_dev, class_dev);
+	struct solos_card *card = atmdev->dev_data;
+	uint32_t data32;
+
+	data32 = ioread32(card->config_regs + GPIO_STATUS);
+	if(!strcmp(attr->attr.name, "HardwareVersion")){
+		data32 = data32 & 0x1F;
+		return sprintf(buf, "%d\n", data32);
+	} else if(!strcmp(attr->attr.name, "HardwareVariant")){
+		data32 = (data32 >> 5) & 0x0F;
+		return sprintf(buf, "%d\n", data32);
+	}
+
+	return sprintf(buf, "Error\n");
+}
+
 static DEVICE_ATTR(console, 0644, console_show, console_store);
 
 
@@ -506,6 +588,14 @@ static DEVICE_ATTR(console, 0644, console_show, console_store);
 
 #include "solos-attrlist.c"
 
+static DEVICE_ATTR(GPIO1, 0644, geos_gpio_show, geos_gpio_store);
+static DEVICE_ATTR(GPIO2, 0644, geos_gpio_show, geos_gpio_store);
+static DEVICE_ATTR(GPIO3, 0644, geos_gpio_show, geos_gpio_store);
+static DEVICE_ATTR(GPIO4, 0644, geos_gpio_show, geos_gpio_store);
+static DEVICE_ATTR(GPIO5, 0644, geos_gpio_show, geos_gpio_store);
+static DEVICE_ATTR(PushButton, 0444, geos_gpio_show, NULL);
+static DEVICE_ATTR(HardwareVersion, 0444, hardware_show, NULL);
+static DEVICE_ATTR(HardwareVariant, 0444, hardware_show, NULL);
 #undef SOLOS_ATTR_RO
 #undef SOLOS_ATTR_RW
 
@@ -514,6 +604,14 @@ static DEVICE_ATTR(console, 0644, console_show, console_store);
 
 static struct attribute *solos_attrs[] = {
 #include "solos-attrlist.c"
+	&dev_attr_GPIO1.attr,
+	&dev_attr_GPIO2.attr,
+	&dev_attr_GPIO3.attr,
+	&dev_attr_GPIO4.attr,
+	&dev_attr_GPIO5.attr,
+	&dev_attr_PushButton.attr,
+	&dev_attr_HardwareVersion.attr,
+	&dev_attr_HardwareVariant.attr,
 	NULL
 };
 
-- 
1.7.2.5

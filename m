From: Evgeny Boger <boger@contactless.ru>
Subject: [PATCH 1/1] Add support for GPIOs for SMSC LAN95xx chips.
Date: Sun, 11 May 2014 17:34:14 +0400
Message-ID: <1399815254-30229-1-git-send-email-boger@contactless.ru>
Cc: Evgeny Boger <boger@contactless.ru>
To: Steve Glendinning <steve.glendinning@shawell.net>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f54.google.com ([209.85.215.54]:47755 "EHLO
	mail-la0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755717AbaEKNeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 May 2014 09:34:36 -0400
Received: by mail-la0-f54.google.com with SMTP id pv20so1192096lab.27
        for <netdev@vger.kernel.org>; Sun, 11 May 2014 06:34:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There might be 11 GPIOs in total. Last three GPIOs  (offsets 8-11, 0-based) are shared
with FDX, LNKA, SPD LEDs respectively. The LEDs are driven by chip by default
at startup time. Once the corresponding GPIO is requested, the chip LED drive
logic is disabled.

Based on commented out code presumably from SMSC original driver.
https://github.com/olerem/barebox/blob/master/drivers/net/usb/smsc95xx.c

Signed-off-by: Evgeny Boger <boger@contactless.ru>
---
 drivers/net/usb/smsc95xx.c | 266 +++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 266 insertions(+)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 424db65e..af29adf 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -29,6 +29,8 @@
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
+#include <linux/gpio.h>
+
 #include "smsc95xx.h"
 
 #define SMSC_CHIPNAME			"smsc95xx"
@@ -68,6 +70,13 @@ struct smsc95xx_priv {
 	spinlock_t mac_cr_lock;
 	u8 features;
 	u8 suspend_flags;
+
+	struct usbnet *dev;
+#ifdef CONFIG_GPIOLIB
+	struct gpio_chip gpio;
+	struct mutex gpio_lock;	/* lock for GPIO functions */
+#endif
+
 };
 
 static bool turbo_mode = true;
@@ -1099,6 +1108,246 @@ static const struct net_device_ops smsc95xx_netdev_ops = {
 	.ndo_set_features	= smsc95xx_set_features,
 };
 
+/* ******************************** GPIO ********************************* */
+
+#ifdef CONFIG_GPIOLIB
+
+static inline u32 smsc95xx_gpio_get_register(unsigned gpio)
+{
+	if (gpio < 8)
+		return GPIO_CFG;
+	else
+		return LED_GPIO_CFG;
+}
+
+static inline u8 smsc95xx_gpio_get_enable_offset(unsigned gpio)
+{
+	return (gpio < 8) ? (24 + gpio) : (gpio * 4 - 16);
+}
+
+static inline u8 smsc95xx_gpio_get_type_offset(unsigned gpio)
+{
+	return (gpio < 8) ? (16 + gpio) : gpio;
+}
+
+static inline u8 smsc95xx_gpio_get_dir_offset(unsigned gpio)
+{
+	return (gpio < 8) ? (8 + gpio) : (gpio - 4);
+}
+
+static inline u8 smsc95xx_gpio_get_val_offset(unsigned gpio)
+{
+	return (gpio < 8) ? (gpio) : (gpio - 8);
+}
+
+
+static int smsc95xx_gpio_request(struct gpio_chip *gpio, unsigned offset)
+{
+	int ret = -1;
+	u32 val, reg;
+	int type_shift;
+
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+
+	reg = smsc95xx_gpio_get_register(offset);
+	type_shift = smsc95xx_gpio_get_type_offset(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	ret = smsc95xx_read_reg(pdata->dev, reg, &val);
+	if (ret >= 0) {
+		val &= ~BIT(smsc95xx_gpio_get_enable_offset(offset));
+
+		val |= BIT(type_shift);
+		val &= ~BIT(smsc95xx_gpio_get_dir_offset(offset));
+
+		ret = smsc95xx_write_reg(pdata->dev, reg, val);
+	}
+
+	mutex_unlock(&pdata->gpio_lock);
+
+
+	return (ret < 0) ? ret : 0;
+}
+
+static void smsc95xx_gpio_free(struct gpio_chip *gpio, unsigned offset)
+{
+	int ret = -1;
+	u32 val, reg;
+	int type_shift;
+
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+
+	reg = smsc95xx_gpio_get_register(offset);
+	type_shift = smsc95xx_gpio_get_type_offset(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	ret = smsc95xx_read_reg(pdata->dev, reg, &val);
+	if (ret >= 0) {
+		val |= BIT(smsc95xx_gpio_get_enable_offset(offset));
+
+		if (offset >= 8) {
+			/* Let the chip control LED GPIOs */
+			val &= ~BIT(type_shift);
+			val |= BIT(smsc95xx_gpio_get_dir_offset(offset));
+		}
+
+		ret = smsc95xx_write_reg(pdata->dev, reg, val);
+
+	}
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	if (ret < 0)
+		netif_err(pdata->dev, ifdown, pdata->dev->net,
+			"error freeing gpio %d\n", offset);
+
+}
+
+static int smsc95xx_gpio_direction_input(struct gpio_chip *gpio,
+			unsigned offset)
+{
+	int ret = -1;
+	u32 val, reg;
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+
+	reg = smsc95xx_gpio_get_register(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	ret = smsc95xx_read_reg(pdata->dev, reg, &val);
+	if (ret >= 0) {
+		val &= ~BIT(smsc95xx_gpio_get_dir_offset(offset));
+
+		ret = smsc95xx_write_reg(pdata->dev, reg, val);
+	}
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	return (ret < 0) ? ret : 0;
+}
+
+static int smsc95xx_gpio_direction_output(struct gpio_chip *gpio,
+			unsigned offset, int value)
+{
+	int ret = -1;
+	u32 val, reg;
+
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	reg = smsc95xx_gpio_get_register(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	ret = smsc95xx_read_reg(pdata->dev, reg, &val);
+
+	if (ret >= 0) {
+		val |= BIT(smsc95xx_gpio_get_dir_offset(offset));
+
+		if (value)
+			val |= BIT(smsc95xx_gpio_get_val_offset(offset));
+		else
+			val &= ~BIT(smsc95xx_gpio_get_val_offset(offset));
+
+		ret = smsc95xx_write_reg(pdata->dev, reg, val);
+	}
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	return (ret < 0) ? ret : 0;
+}
+
+static int smsc95xx_gpio_get(struct gpio_chip *gpio, unsigned offset)
+{
+	int ret = -1;
+	u32 val, reg;
+
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+
+	reg = smsc95xx_gpio_get_register(offset);
+
+	ret = smsc95xx_read_reg(pdata->dev, reg, &val);
+
+	if (ret < 0) {
+		netif_err(pdata->dev, ifdown, pdata->dev->net,
+			"error reading gpio %d\n", offset);
+		return -EINVAL;
+	}
+
+	return (val >> smsc95xx_gpio_get_val_offset(offset)) & 0x01;
+}
+
+static void smsc95xx_gpio_set(struct gpio_chip *gpio, unsigned offset,
+				int value)
+{
+	int ret = -1;
+	u32 val, reg;
+
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	reg = smsc95xx_gpio_get_register(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	ret = smsc95xx_read_reg(pdata->dev, reg, &val);
+
+	if (ret >= 0) {
+		if (value)
+			val |= BIT(smsc95xx_gpio_get_val_offset(offset));
+		else
+			val &= ~BIT(smsc95xx_gpio_get_val_offset(offset));
+
+		ret = smsc95xx_write_reg(pdata->dev, reg, val);
+	}
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	if (ret < 0) {
+		netif_err(pdata->dev, ifdown, pdata->dev->net,
+			"error writing gpio %d=%d\n", offset, value);
+		return;
+	}
+}
+
+
+
+#endif /* CONFIG_GPIOLIB */
+
+
+
+static int smsc95xx_register_gpio(struct usbnet *dev)
+{
+#ifdef CONFIG_GPIOLIB
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	pdata->gpio.label = SMSC_CHIPNAME;
+	pdata->gpio.request	= smsc95xx_gpio_request;
+	pdata->gpio.free		= smsc95xx_gpio_free;
+	pdata->gpio.get		= smsc95xx_gpio_get;
+	pdata->gpio.set		= smsc95xx_gpio_set;
+	pdata->gpio.direction_input = smsc95xx_gpio_direction_input;
+	pdata->gpio.direction_output = smsc95xx_gpio_direction_output;
+
+	pdata->gpio.base = -1;
+	pdata->gpio.ngpio = 11;
+	pdata->gpio.can_sleep = 1;
+	pdata->gpio.dev = &dev->udev->dev;
+	pdata->gpio.owner = THIS_MODULE;
+
+	mutex_init(&pdata->gpio_lock);
+
+	return gpiochip_add(&pdata->gpio);
+#else
+	return 0;
+#endif
+}
+
+
 static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct smsc95xx_priv *pdata = NULL;
@@ -1120,6 +1369,8 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	if (!pdata)
 		return -ENOMEM;
 
+	pdata->dev = dev;
+
 	spin_lock_init(&pdata->mac_cr_lock);
 
 	if (DEFAULT_TX_CSUM_ENABLE)
@@ -1153,17 +1404,32 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+
+	ret = smsc95xx_register_gpio(dev);
+	if (ret < 0)
+		return ret;
+
 	return 0;
 }
 
 static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 {
+	int ret;
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	if (pdata) {
+		#ifdef CONFIG_GPIOLIB
+		ret = gpiochip_remove(&pdata->gpio);
+		if (ret) {
+			netif_err(dev, ifdown, dev->net,
+				"error removing gpiochip\n");
+		}
+		#endif
+
 		netif_dbg(dev, ifdown, dev->net, "free pdata\n");
 		kfree(pdata);
 		pdata = NULL;
 		dev->data[0] = 0;
+
 	}
 }
 
-- 
1.8.3.2

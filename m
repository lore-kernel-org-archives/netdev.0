From: Evgeny Boger <boger@contactless.ru>
Subject: [PATCH v3] Add support for GPIOs for SMSC LAN95xx chips.
Date: Thu,  9 Oct 2014 02:14:58 +0400
Message-ID: <1412806498-22556-1-git-send-email-boger@contactless.ru>
References: <CAN_we7MbMywYzysn_Q_iRAOZZuE+KU_jDJxMW-Qz0KK0RHwSRQ@mail.gmail.com>
Cc: Evgeny Boger <boger@contactless.ru>
To: Daniele Forsi <dforsi@gmail.com>,
	Steve Glendinning <steve.glendinning@shawell.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:54110 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933742AbaJHWPP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 18:15:15 -0400
Received: by mail-lb0-f174.google.com with SMTP id p9so37204lbv.5
        for <netdev@vger.kernel.org>; Wed, 08 Oct 2014 15:15:13 -0700 (PDT)
In-Reply-To: <CAN_we7MbMywYzysn_Q_iRAOZZuE+KU_jDJxMW-Qz0KK0RHwSRQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There might be 11 GPIOs in total.
Last three GPIOs  (offsets 8-10, 0-based) are shared with FDX, LNKA, SPD
LEDs respectively. The LEDs are driven by chip by default at startup time.
Once the corresponding GPIO is requested, the chip LED drive logic is disabled.

The numbering scheme according to datasheets differs a bit between LAN9500
and LAN951x.

For LAN951x:
GPIOs with offsets 0-7 are named "GPIO3" - "GPIO7",
offsets 8-10 are for "GPIO0" - "GPIO2" (these three are multiplexed with nFDX_LED,
nLNKA_LED, nSPD_LED).

For LAN9500:
The datasheet name is the same as the corresponding offset, i.e. offsets 0-10 are
for "GPIO0"-"GPIO10".

Signed-off-by: Evgeny Boger <boger@contactless.ru>
---
Changes:
    v3: Remove more unnecessary newlines and return statement.
        Fix typo in commit message (max offset 10, was: 11)
        Add note on GPIO numbering scheme
        
    v2:  Remove unnecessary newlines.
     Store cached gpio register values in order to
            1) speed-up gpio_set by avoiding reading gpio
                register prior to writing
            2) restore gpio register settings after chip reset 
                which is triggered for instance on link up

 drivers/net/usb/smsc95xx.c | 295 +++++++++++++++++++++++++++++++++++++++++++--
 drivers/net/usb/smsc95xx.h |   1 +
 2 files changed, 287 insertions(+), 9 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index f3cef7c..d5d8735 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -31,6 +31,7 @@
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
 #include <linux/slab.h>
+#include <linux/gpio.h>
 #include "smsc95xx.h"
 
 #define SMSC_CHIPNAME			"smsc95xx"
@@ -70,6 +71,14 @@ struct smsc95xx_priv {
 	spinlock_t mac_cr_lock;
 	u8 features;
 	u8 suspend_flags;
+	struct usbnet *dev;
+#ifdef CONFIG_GPIOLIB
+	struct gpio_chip gpio;
+	struct mutex gpio_lock;	/* lock for GPIO functions */
+#endif
+
+	u32 reg_gpio_cfg;
+	u32 reg_led_gpio_cfg;
 };
 
 static bool turbo_mode = true;
@@ -877,7 +886,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 static int smsc95xx_reset(struct usbnet *dev)
 {
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
-	u32 read_buf, write_buf, burst_cap;
+	u32 read_buf, burst_cap;
 	int ret = 0, timeout;
 
 	netif_dbg(dev, ifup, dev->net, "entering smsc95xx_reset\n");
@@ -886,6 +895,24 @@ static int smsc95xx_reset(struct usbnet *dev)
 	if (ret < 0)
 		return ret;
 
+	/* restore and re-read GPIO registers immediately after requesting Lite Reset */
+
+	ret = smsc95xx_write_reg(dev, GPIO_CFG, pdata->reg_gpio_cfg);
+	if (ret < 0)
+		return ret;
+
+	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, pdata->reg_led_gpio_cfg);
+	if (ret < 0)
+		return ret;
+
+	ret = smsc95xx_read_reg(dev, GPIO_CFG, &pdata->reg_gpio_cfg);
+	if (ret < 0)
+		return ret;
+
+	ret = smsc95xx_read_reg(dev, LED_GPIO_CFG, &pdata->reg_led_gpio_cfg);
+	if (ret < 0)
+		return ret;
+
 	timeout = 0;
 	do {
 		msleep(10);
@@ -1019,13 +1046,6 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x\n", read_buf);
 
-	/* Configure GPIO pins as LED outputs */
-	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
-		LED_GPIO_CFG_FDX_LED;
-	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, write_buf);
-	if (ret < 0)
-		return ret;
-
 	/* Init Tx */
 	ret = smsc95xx_write_reg(dev, FLOW, 0);
 	if (ret < 0)
@@ -1101,6 +1121,237 @@ static const struct net_device_ops smsc95xx_netdev_ops = {
 	.ndo_set_features	= smsc95xx_set_features,
 };
 
+/* ******************************** GPIO ********************************* */
+/* Note: the numbering scheme according to datasheets differs a bit
+ * between LAN9500 and LAN951x.
+ *
+ * For LAN951x:
+ * 	GPIOs with offsets 0-7 are named "GPIO3" - "GPIO7", offsets 8-10 are
+ *  for "GPIO0" - "GPIO2" (these three are multiplexed with nFDX_LED,
+ *  nLNKA_LED, nSPD_LED).
+ *
+ * For LAN9500:
+ *  the datasheet name is the same as the corresponding offset, i.e.
+ *  offsets 0-10 are for "GPIO0"-"GPIO10".
+*/
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
+static inline u32 *smsc95xx_gpio_get_reg_cache_ptr(struct smsc95xx_priv *pdata, unsigned gpio)
+{
+	return (gpio < 8) ? (&pdata->reg_gpio_cfg) : (&pdata->reg_led_gpio_cfg);
+}
+
+static int smsc95xx_gpio_request(struct gpio_chip *gpio, unsigned offset)
+{
+	int ret = -1;
+	u32 reg;
+	int type_shift;
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	u32 *reg_cache_ptr = smsc95xx_gpio_get_reg_cache_ptr(pdata, offset);
+
+	reg = smsc95xx_gpio_get_register(offset);
+	type_shift = smsc95xx_gpio_get_type_offset(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	*reg_cache_ptr &= ~BIT(smsc95xx_gpio_get_enable_offset(offset));
+	*reg_cache_ptr |= BIT(type_shift);
+	*reg_cache_ptr &= ~BIT(smsc95xx_gpio_get_dir_offset(offset));
+
+	ret = smsc95xx_write_reg(pdata->dev, reg, *reg_cache_ptr);
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	return (ret < 0) ? ret : 0;
+}
+
+static void smsc95xx_gpio_free(struct gpio_chip *gpio, unsigned offset)
+{
+	int ret = -1;
+	u32 reg;
+	int type_shift;
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	u32 *reg_cache_ptr = smsc95xx_gpio_get_reg_cache_ptr(pdata, offset);
+
+	reg = smsc95xx_gpio_get_register(offset);
+	type_shift = smsc95xx_gpio_get_type_offset(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	*reg_cache_ptr |= BIT(smsc95xx_gpio_get_enable_offset(offset));
+
+	if (offset >= 8) {
+		/* Let the chip control LED GPIOs */
+		*reg_cache_ptr &= ~BIT(type_shift);
+		*reg_cache_ptr |= BIT(smsc95xx_gpio_get_dir_offset(offset));
+	}
+
+	ret = smsc95xx_write_reg(pdata->dev, reg, *reg_cache_ptr);
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	if (ret < 0)
+		netif_err(pdata->dev, ifdown, pdata->dev->net,
+			"error freeing gpio %d\n", offset);
+}
+
+static int smsc95xx_gpio_direction_input(struct gpio_chip *gpio,
+			unsigned offset)
+{
+	int ret = -1;
+	u32 reg;
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	u32 *reg_cache_ptr = smsc95xx_gpio_get_reg_cache_ptr(pdata, offset);
+
+	reg = smsc95xx_gpio_get_register(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	*reg_cache_ptr &= ~BIT(smsc95xx_gpio_get_dir_offset(offset));
+	ret = smsc95xx_write_reg(pdata->dev, reg, *reg_cache_ptr);
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
+	u32 reg;
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	u32 *reg_cache_ptr = smsc95xx_gpio_get_reg_cache_ptr(pdata, offset);
+
+	reg = smsc95xx_gpio_get_register(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	*reg_cache_ptr |= BIT(smsc95xx_gpio_get_dir_offset(offset));
+
+	if (value)
+		*reg_cache_ptr |= BIT(smsc95xx_gpio_get_val_offset(offset));
+	else
+		*reg_cache_ptr &= ~BIT(smsc95xx_gpio_get_val_offset(offset));
+
+	ret = smsc95xx_write_reg(pdata->dev, reg, *reg_cache_ptr);
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	return (ret < 0) ? ret : 0;
+}
+
+static int smsc95xx_gpio_get(struct gpio_chip *gpio, unsigned offset)
+{
+	int ret = -1;
+	u32 reg;
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	u32 *reg_cache_ptr = smsc95xx_gpio_get_reg_cache_ptr(pdata, offset);
+
+	reg = smsc95xx_gpio_get_register(offset);
+
+	ret = smsc95xx_read_reg(pdata->dev, reg, reg_cache_ptr);
+
+	if (ret < 0) {
+		netif_err(pdata->dev, ifdown, pdata->dev->net,
+			"error reading gpio %d\n", offset);
+		return -EINVAL;
+	}
+
+	return (*reg_cache_ptr >> smsc95xx_gpio_get_val_offset(offset)) & 0x01;
+}
+
+static void smsc95xx_gpio_set(struct gpio_chip *gpio, unsigned offset,
+				int value)
+{
+	int ret = -1;
+	u32 reg;
+	struct smsc95xx_priv *pdata =
+			container_of(gpio, struct smsc95xx_priv, gpio);
+	u32 *reg_cache_ptr = smsc95xx_gpio_get_reg_cache_ptr(pdata, offset);
+
+	reg = smsc95xx_gpio_get_register(offset);
+
+	mutex_lock(&pdata->gpio_lock);
+
+	if (value)
+		*reg_cache_ptr |= BIT(smsc95xx_gpio_get_val_offset(offset));
+	else
+		*reg_cache_ptr &= ~BIT(smsc95xx_gpio_get_val_offset(offset));
+
+	ret = smsc95xx_write_reg(pdata->dev, reg, *reg_cache_ptr);
+
+	mutex_unlock(&pdata->gpio_lock);
+
+	if (ret < 0) {
+		netif_err(pdata->dev, ifdown, pdata->dev->net,
+			"error writing gpio %d=%d\n", offset, value);
+	}
+}
+
+#endif /* CONFIG_GPIOLIB */
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
 static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	struct smsc95xx_priv *pdata = NULL;
@@ -1122,6 +1373,8 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	if (!pdata)
 		return -ENOMEM;
 
+	pdata->dev = dev;
+
 	spin_lock_init(&pdata->mac_cr_lock);
 
 	if (DEFAULT_TX_CSUM_ENABLE)
@@ -1139,7 +1392,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	/* detect device revision as different features may be available */
 	ret = smsc95xx_read_reg(dev, ID_REV, &val);
 	if (ret < 0)
-		return ret;
+		goto free;
 	val >>= 16;
 
 	if ((val == ID_REV_CHIP_ID_9500A_) || (val == ID_REV_CHIP_ID_9530_) ||
@@ -1155,17 +1408,41 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->net->flags |= IFF_MULTICAST;
 	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD_CSUM;
 	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+
+	/* initialize GPIO register cache */
+	pdata->reg_gpio_cfg = GPIO_CFG_DEFAULT;
+	pdata->reg_led_gpio_cfg = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
+								 LED_GPIO_CFG_FDX_LED;
+
+	ret = smsc95xx_register_gpio(dev);
+	if (ret < 0)
+		goto free;
+
 	return 0;
+
+free:
+	kfree(pdata);
+	return ret;
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
 
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
index f360ee3..b729094 100644
--- a/drivers/net/usb/smsc95xx.h
+++ b/drivers/net/usb/smsc95xx.h
@@ -114,6 +114,7 @@
 #define LED_GPIO_CFG_FDX_LED		(0x00010000)
 
 #define GPIO_CFG			(0x28)
+#define GPIO_CFG_DEFAULT    (0x1f000000) /* gpios disabled */
 
 #define AFC_CFG				(0x2C)
 
-- 
1.9.1

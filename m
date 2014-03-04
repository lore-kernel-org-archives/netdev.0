From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net] r8152: disable the ECM mode
Date: Tue, 4 Mar 2014 20:47:48 +0800
Message-ID: <1393937268-23798-1-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <oliver@neukum.org>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are known issues for switching the drivers between ECM mode and
vendor mode. The interrup transfer may become abnormal. The hardware
may have the opportunity to die if you change the configuration without
unloading the current driver first, because all the control transfers
of the current driver would fail after the command of switching the
configuration.

Although to use the ecm driver and vendor driver independently is fine,
it may have problems to change the driver from one to the other by
switching the configuration. Additionally, now the vendor mode driver
is more powerful than the ECM driver. Thus, disable the ECM mode driver,
and let r8152 to set the configuration to vendor mode and reset the
device automatically.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/Makefile    |   2 +-
 drivers/net/usb/cdc_ether.c |   7 ++
 drivers/net/usb/r8152.c     |  15 +--
 drivers/net/usb/r815x.c     | 248 --------------------------------------------
 4 files changed, 17 insertions(+), 255 deletions(-)
 delete mode 100644 drivers/net/usb/r815x.c

diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 433f0a0..e2797f1 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -11,7 +11,7 @@ obj-$(CONFIG_USB_HSO)		+= hso.o
 obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
 asix-y := asix_devices.o asix_common.o ax88172a.o
 obj-$(CONFIG_USB_NET_AX88179_178A)      += ax88179_178a.o
-obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o r815x.o
+obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
 obj-$(CONFIG_USB_NET_SR9700)	+= sr9700.o
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 42e1769..bd363b2 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -652,6 +652,13 @@ static const struct usb_device_id	products[] = {
 	.driver_info = 0,
 },
 
+/* Samsung USB Ethernet Adapters */
+{
+	USB_DEVICE_AND_INTERFACE_INFO(SAMSUNG_VENDOR_ID, 0xa101, USB_CLASS_COMM,
+			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
+	.driver_info = 0,
+},
+
 /* WHITELIST!!!
  *
  * CDC Ether uses two interfaces, not necessarily consecutive.
diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index d89dbe3..adb12f3 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -449,9 +449,6 @@ enum rtl8152_flags {
 #define MCU_TYPE_PLA			0x0100
 #define MCU_TYPE_USB			0x0000
 
-#define REALTEK_USB_DEVICE(vend, prod)	\
-	USB_DEVICE_INTERFACE_CLASS(vend, prod, USB_CLASS_VENDOR_SPEC)
-
 struct rx_desc {
 	__le32 opts1;
 #define RX_LEN_MASK			0x7fff
@@ -2739,6 +2736,12 @@ static int rtl8152_probe(struct usb_interface *intf,
 	struct net_device *netdev;
 	int ret;
 
+	if (udev->actconfig->desc.bConfigurationValue != 1) {
+		usb_driver_set_configuration(udev, 1);
+		return -ENODEV;
+	}
+
+	usb_reset_device(udev);
 	netdev = alloc_etherdev(sizeof(struct r8152));
 	if (!netdev) {
 		dev_err(&intf->dev, "Out of memory\n");
@@ -2819,9 +2822,9 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 
 /* table of devices that work with this driver */
 static struct usb_device_id rtl8152_table[] = {
-	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8152)},
-	{REALTEK_USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8153)},
-	{REALTEK_USB_DEVICE(VENDOR_ID_SAMSUNG, PRODUCT_ID_SAMSUNG)},
+	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8152)},
+	{USB_DEVICE(VENDOR_ID_REALTEK, PRODUCT_ID_RTL8153)},
+	{USB_DEVICE(VENDOR_ID_SAMSUNG, PRODUCT_ID_SAMSUNG)},
 	{}
 };
 
diff --git a/drivers/net/usb/r815x.c b/drivers/net/usb/r815x.c
deleted file mode 100644
index f0a8791..0000000
--- a/drivers/net/usb/r815x.c
+++ /dev/null
@@ -1,248 +0,0 @@
-#include <linux/module.h>
-#include <linux/netdevice.h>
-#include <linux/mii.h>
-#include <linux/usb.h>
-#include <linux/usb/cdc.h>
-#include <linux/usb/usbnet.h>
-
-#define RTL815x_REQT_READ	0xc0
-#define RTL815x_REQT_WRITE	0x40
-#define RTL815x_REQ_GET_REGS	0x05
-#define RTL815x_REQ_SET_REGS	0x05
-
-#define MCU_TYPE_PLA		0x0100
-#define OCP_BASE		0xe86c
-#define BASE_MII		0xa400
-
-#define BYTE_EN_DWORD		0xff
-#define BYTE_EN_WORD		0x33
-#define BYTE_EN_BYTE		0x11
-
-#define R815x_PHY_ID		32
-#define REALTEK_VENDOR_ID	0x0bda
-
-
-static int pla_read_word(struct usb_device *udev, u16 index)
-{
-	int ret;
-	u8 shift = index & 2;
-	__le32 *tmp;
-
-	tmp = kmalloc(sizeof(*tmp), GFP_KERNEL);
-	if (!tmp)
-		return -ENOMEM;
-
-	index &= ~3;
-
-	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
-			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
-			      index, MCU_TYPE_PLA, tmp, sizeof(*tmp), 500);
-	if (ret < 0)
-		goto out2;
-
-	ret = __le32_to_cpu(*tmp);
-	ret >>= (shift * 8);
-	ret &= 0xffff;
-
-out2:
-	kfree(tmp);
-	return ret;
-}
-
-static int pla_write_word(struct usb_device *udev, u16 index, u32 data)
-{
-	__le32 *tmp;
-	u32 mask = 0xffff;
-	u16 byen = BYTE_EN_WORD;
-	u8 shift = index & 2;
-	int ret;
-
-	tmp = kmalloc(sizeof(*tmp), GFP_KERNEL);
-	if (!tmp)
-		return -ENOMEM;
-
-	data &= mask;
-
-	if (shift) {
-		byen <<= shift;
-		mask <<= (shift * 8);
-		data <<= (shift * 8);
-		index &= ~3;
-	}
-
-	ret = usb_control_msg(udev, usb_rcvctrlpipe(udev, 0),
-			      RTL815x_REQ_GET_REGS, RTL815x_REQT_READ,
-			      index, MCU_TYPE_PLA, tmp, sizeof(*tmp), 500);
-	if (ret < 0)
-		goto out3;
-
-	data |= __le32_to_cpu(*tmp) & ~mask;
-	*tmp = __cpu_to_le32(data);
-
-	ret = usb_control_msg(udev, usb_sndctrlpipe(udev, 0),
-			      RTL815x_REQ_SET_REGS, RTL815x_REQT_WRITE,
-			      index, MCU_TYPE_PLA | byen, tmp, sizeof(*tmp),
-			      500);
-
-out3:
-	kfree(tmp);
-	return ret;
-}
-
-static int ocp_reg_read(struct usbnet *dev, u16 addr)
-{
-	u16 ocp_base, ocp_index;
-	int ret;
-
-	ocp_base = addr & 0xf000;
-	ret = pla_write_word(dev->udev, OCP_BASE, ocp_base);
-	if (ret < 0)
-		goto out;
-
-	ocp_index = (addr & 0x0fff) | 0xb000;
-	ret = pla_read_word(dev->udev, ocp_index);
-
-out:
-	return ret;
-}
-
-static int ocp_reg_write(struct usbnet *dev, u16 addr, u16 data)
-{
-	u16 ocp_base, ocp_index;
-	int ret;
-
-	ocp_base = addr & 0xf000;
-	ret = pla_write_word(dev->udev, OCP_BASE, ocp_base);
-	if (ret < 0)
-		goto out1;
-
-	ocp_index = (addr & 0x0fff) | 0xb000;
-	ret = pla_write_word(dev->udev, ocp_index, data);
-
-out1:
-	return ret;
-}
-
-static int r815x_mdio_read(struct net_device *netdev, int phy_id, int reg)
-{
-	struct usbnet *dev = netdev_priv(netdev);
-	int ret;
-
-	if (phy_id != R815x_PHY_ID)
-		return -EINVAL;
-
-	if (usb_autopm_get_interface(dev->intf) < 0)
-		return -ENODEV;
-
-	ret = ocp_reg_read(dev, BASE_MII + reg * 2);
-
-	usb_autopm_put_interface(dev->intf);
-	return ret;
-}
-
-static
-void r815x_mdio_write(struct net_device *netdev, int phy_id, int reg, int val)
-{
-	struct usbnet *dev = netdev_priv(netdev);
-
-	if (phy_id != R815x_PHY_ID)
-		return;
-
-	if (usb_autopm_get_interface(dev->intf) < 0)
-		return;
-
-	ocp_reg_write(dev, BASE_MII + reg * 2, val);
-
-	usb_autopm_put_interface(dev->intf);
-}
-
-static int r8153_bind(struct usbnet *dev, struct usb_interface *intf)
-{
-	int status;
-
-	status = usbnet_cdc_bind(dev, intf);
-	if (status < 0)
-		return status;
-
-	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = r815x_mdio_read;
-	dev->mii.mdio_write = r815x_mdio_write;
-	dev->mii.phy_id_mask = 0x3f;
-	dev->mii.reg_num_mask = 0x1f;
-	dev->mii.phy_id = R815x_PHY_ID;
-	dev->mii.supports_gmii = 1;
-
-	return status;
-}
-
-static int r8152_bind(struct usbnet *dev, struct usb_interface *intf)
-{
-	int status;
-
-	status = usbnet_cdc_bind(dev, intf);
-	if (status < 0)
-		return status;
-
-	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = r815x_mdio_read;
-	dev->mii.mdio_write = r815x_mdio_write;
-	dev->mii.phy_id_mask = 0x3f;
-	dev->mii.reg_num_mask = 0x1f;
-	dev->mii.phy_id = R815x_PHY_ID;
-	dev->mii.supports_gmii = 0;
-
-	return status;
-}
-
-static const struct driver_info r8152_info = {
-	.description =	"RTL8152 ECM Device",
-	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
-	.bind =		r8152_bind,
-	.unbind =	usbnet_cdc_unbind,
-	.status =	usbnet_cdc_status,
-	.manage_power =	usbnet_manage_power,
-};
-
-static const struct driver_info r8153_info = {
-	.description =	"RTL8153 ECM Device",
-	.flags =	FLAG_ETHER | FLAG_POINTTOPOINT,
-	.bind =		r8153_bind,
-	.unbind =	usbnet_cdc_unbind,
-	.status =	usbnet_cdc_status,
-	.manage_power =	usbnet_manage_power,
-};
-
-static const struct usb_device_id products[] = {
-{
-	USB_DEVICE_AND_INTERFACE_INFO(REALTEK_VENDOR_ID, 0x8152, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &r8152_info,
-},
-
-{
-	USB_DEVICE_AND_INTERFACE_INFO(REALTEK_VENDOR_ID, 0x8153, USB_CLASS_COMM,
-			USB_CDC_SUBCLASS_ETHERNET, USB_CDC_PROTO_NONE),
-	.driver_info = (unsigned long) &r8153_info,
-},
-
-	{ },		/* END */
-};
-MODULE_DEVICE_TABLE(usb, products);
-
-static struct usb_driver r815x_driver = {
-	.name =		"r815x",
-	.id_table =	products,
-	.probe =	usbnet_probe,
-	.disconnect =	usbnet_disconnect,
-	.suspend =	usbnet_suspend,
-	.resume =	usbnet_resume,
-	.reset_resume =	usbnet_resume,
-	.supports_autosuspend = 1,
-	.disable_hub_initiated_lpm = 1,
-};
-
-module_usb_driver(r815x_driver);
-
-MODULE_AUTHOR("Hayes Wang");
-MODULE_DESCRIPTION("Realtek USB ECM device");
-MODULE_LICENSE("GPL");
-- 
1.8.4.2

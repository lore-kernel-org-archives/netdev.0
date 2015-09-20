From: Matthew Garrett <mjg59@coreos.com>
Subject: [PATCH] usbnet: New driver for QinHeng CH9200 devices
Date: Sun, 20 Sep 2015 02:25:38 -0700
Message-ID: <1442741138-8193-1-git-send-email-mjg59@coreos.com>
Cc: oneukum@suse.com, Matthew Garrett <mjg59@srcf.ucam.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([93.93.128.6]:55349 "EHLO
	cavan.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754450AbbITKFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Sep 2015 06:05:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matthew Garrett <mjg59@srcf.ucam.org>

There's a bunch of cheap USB 10/100 devices based on QinHeng chipsets. The
vendor driver supports the CH9100 and CH9200 devices, but the majority of
the code is of the if (ch9100) {} else {} form, with the most significant
difference being that CH9200 provides a real MII interface but CH9100 fakes
one with a bunch of global variables and magic commands. I don't have a
CH9100, so it's probably better if someone who does provides an independent
driver for it. In any case, this is a lightly cleaned up version of the
vendor driver with all the CH9100 code dropped.

Signed-off-by: Matthew Garrett <mjg59@srcf.ucam.org>
---
 drivers/net/usb/Kconfig  |  11 ++
 drivers/net/usb/Makefile |   2 +-
 drivers/net/usb/ch9200.c | 443 +++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 455 insertions(+), 1 deletion(-)
 create mode 100644 drivers/net/usb/ch9200.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 1610b79..fbb9325 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -583,4 +583,15 @@ config USB_VL600
 
 	  http://ubuntuforums.org/showpost.php?p=10589647&postcount=17
 
+config USB_NET_CH9200
+	tristate "QingHeng CH9200 USB ethernet support"
+	depends on USB_USBNET
+	select MII
+	help
+	  Choose this option if you have a USB ethernet adapter with a QinHeng
+	  CH9200 chipset.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called ch9200.
+
 endif # USB_NET_DRIVERS
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index cf6a0e6..b5f0406 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -38,4 +38,4 @@ obj-$(CONFIG_USB_NET_HUAWEI_CDC_NCM)	+= huawei_cdc_ncm.o
 obj-$(CONFIG_USB_VL600)		+= lg-vl600.o
 obj-$(CONFIG_USB_NET_QMI_WWAN)	+= qmi_wwan.o
 obj-$(CONFIG_USB_NET_CDC_MBIM)	+= cdc_mbim.o
-
+obj-$(CONFIG_USB_NET_CH9200)	+= ch9200.o
diff --git a/drivers/net/usb/ch9200.c b/drivers/net/usb/ch9200.c
new file mode 100644
index 0000000..cabb670
--- /dev/null
+++ b/drivers/net/usb/ch9200.c
@@ -0,0 +1,443 @@
+/*
+ * USB 10M/100M ethernet adapter
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2. This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied
+ *
+ */
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/sched.h>
+#include <linux/stddef.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/crc32.h>
+#include <linux/usb/usbnet.h>
+#include <linux/slab.h>
+
+#define CH9200_VID		0x1A86
+#define CH9200_PID_E092		0xE092
+
+#define CTRL_TIMEOUT_MS		1000
+
+#define CONTROL_TIMEOUT_MS 1000
+
+#define REQUEST_READ	0x0E
+#define REQUEST_WRITE	0x0F
+
+/* Address space:
+ * 00-63 : MII
+ * 64-128: MAC
+ *
+ * Note: all accesses must be 16-bit
+ */
+
+#define MAC_REG_CTRL 64
+#define MAC_REG_STATUS 66
+#define MAC_REG_INTERRUPT_MASK 68
+#define MAC_REG_PHY_COMMAND 70
+#define MAC_REG_PHY_DATA 72
+#define MAC_REG_STATION_L 74
+#define MAC_REG_STATION_M 76
+#define MAC_REG_STATION_H 78
+#define MAC_REG_HASH_L 80
+#define MAC_REG_HASH_M1 82
+#define MAC_REG_HASH_M2 84
+#define MAC_REG_HASH_H 86
+#define MAC_REG_THRESHOLD 88
+#define MAC_REG_FIFO_DEPTH 90
+#define MAC_REG_PAUSE 92
+#define MAC_REG_FLOW_CONTROL 94
+
+/* Control register bits
+ *
+ * Note: bits 13 and 15 are reserved
+ */
+#define LOOPBACK		(0x01 << 14)
+#define BASE100X		(0x01 << 12)
+#define MBPS_10			(0x01 << 11)
+#define DUPLEX_MODE		(0x01 << 10)
+#define PAUSE_FRAME		(0x01 << 9)
+#define PROMISCUOUS		(0x01 << 8)
+#define MULTICAST		(0x01 << 7)
+#define BROADCAST		(0x01 << 6)
+#define HASH			(0x01 << 5)
+#define APPEND_PAD		(0x01 << 4)
+#define APPEND_CRC		(0x01 << 3)
+#define TRANSMITTER_ACTION	(0x01 << 2)
+#define RECEIVER_ACTION		(0x01 << 1)
+#define DMA_ACTION		(0x01 << 0)
+
+/* Status register bits
+ *
+ * Note: bits 7-15 are reserved
+ */
+#define ALIGNMENT		(0x01 << 6)
+#define FIFO_OVER_RUN		(0x01 << 5)
+#define FIFO_UNDER_RUN		(0x01 << 4)
+#define RX_ERROR		(0x01 << 3)
+#define RX_COMPLETE		(0x01 << 2)
+#define TX_ERROR		(0x01 << 1)
+#define TX_COMPLETE		(0x01 << 0)
+
+/* FIFO depth register bits
+ *
+ * Note: bits 6 and 14 are reserved
+ */
+
+#define ETH_TXBD		(0x01 << 15)
+#define ETN_TX_FIFO_DEPTH	(0x01 << 8)
+#define ETH_RXBD		(0x01 << 7)
+#define ETH_RX_FIFO_DEPTH	(0x01 << 0)
+
+static int control_read(struct usbnet *dev,
+			unsigned char request, unsigned short value,
+			unsigned short index, void *data, unsigned short size,
+			int timeout)
+{
+	unsigned char *buf = NULL;
+	unsigned char request_type;
+	int err = 0;
+
+	if (request == REQUEST_READ)
+		request_type = (USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_OTHER);
+	else
+		request_type = (USB_DIR_IN | USB_TYPE_VENDOR |
+				USB_RECIP_DEVICE);
+
+	netdev_dbg(dev->net, "Control_read() index=0x%02x size=%d\n",
+		   index, size);
+
+	buf = kmalloc(size, GFP_KERNEL);
+	if (!buf) {
+		err = -ENOMEM;
+		goto err_out;
+	}
+
+	err = usb_control_msg(dev->udev,
+			      usb_rcvctrlpipe(dev->udev, 0),
+			      request, request_type, value, index, buf, size,
+			      timeout);
+	if (err == size)
+		memcpy(data, buf, size);
+	else if (err >= 0)
+		err = -EINVAL;
+	kfree(buf);
+
+	return err;
+
+err_out:
+	return err;
+}
+
+static int control_write(struct usbnet *dev, unsigned char request,
+			 unsigned short value, unsigned short index,
+			 void *data, unsigned short size, int timeout)
+{
+	unsigned char *buf = NULL;
+	unsigned char request_type;
+	int err = 0;
+
+	if (request == REQUEST_WRITE)
+		request_type = (USB_DIR_OUT | USB_TYPE_VENDOR |
+				USB_RECIP_OTHER);
+	else
+		request_type = (USB_DIR_OUT | USB_TYPE_VENDOR |
+				USB_RECIP_DEVICE);
+
+	netdev_dbg(dev->net, "Control_write() index=0x%02x size=%d\n",
+		   index, size);
+
+	if (data) {
+		buf = kmalloc(size, GFP_KERNEL);
+		if (!buf) {
+			err = -ENOMEM;
+			goto err_out;
+		}
+		memcpy(buf, data, size);
+	}
+
+	err = usb_control_msg(dev->udev,
+			      usb_sndctrlpipe(dev->udev, 0),
+			      request, request_type, value, index, buf, size,
+			      timeout);
+	if (err >= 0 && err < size)
+		err = -EINVAL;
+	kfree(buf);
+
+	return 0;
+
+err_out:
+	return err;
+}
+
+static int ch9200_mdio_read(struct net_device *netdev, int phy_id, int loc)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	unsigned char buff[2];
+
+	netdev_dbg(netdev, "ch9200_mdio_read phy_id:%02x loc:%02x\n",
+		   phy_id, loc);
+
+	if (phy_id != 0)
+		return -ENODEV;
+
+	control_read(dev, REQUEST_READ, 0, loc * 2, buff, 0x02,
+		     CONTROL_TIMEOUT_MS);
+
+	return (buff[0] | buff[1] << 8);
+}
+
+static void ch9200_mdio_write(struct net_device *netdev,
+			      int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	unsigned char buff[2];
+
+	netdev_dbg(netdev, "ch9200_mdio_write() phy_id=%02x loc:%02x\n",
+		   phy_id, loc);
+
+	if (phy_id != 0)
+		return;
+
+	buff[0] = (unsigned char)val;
+	buff[1] = (unsigned char)(val >> 8);
+
+	control_write(dev, REQUEST_WRITE, 0, loc * 2, buff, 0x02,
+		      CONTROL_TIMEOUT_MS);
+}
+
+static int ch9200_link_reset(struct usbnet *dev)
+{
+	struct ethtool_cmd ecmd;
+
+	mii_check_media(&dev->mii, 1, 1);
+	mii_ethtool_gset(&dev->mii, &ecmd);
+
+	netdev_dbg(dev->net, "link_reset() speed:%d duplex:%d\n",
+		   ecmd.speed, ecmd.duplex);
+
+	return 0;
+}
+
+static void ch9200_status(struct usbnet *dev, struct urb *urb)
+{
+	int link;
+	unsigned char *buf;
+
+	if (urb->actual_length < 16)
+		return;
+
+	buf = urb->transfer_buffer;
+	link = !!(buf[0] & 0x01);
+
+	if (link) {
+		netif_carrier_on(dev->net);
+		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+	} else {
+		netif_carrier_off(dev->net);
+	}
+}
+
+static struct sk_buff *ch9200_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
+				       gfp_t flags)
+{
+	int i = 0;
+	int len = 0;
+	int tx_overhead = 0;
+
+	tx_overhead = 0x40;
+
+	len = skb->len;
+	if (skb_headroom(skb) < tx_overhead) {
+		struct sk_buff *skb2;
+
+		skb2 = skb_copy_expand(skb, tx_overhead, 0, flags);
+		dev_kfree_skb_any(skb);
+		skb = skb2;
+		if (!skb)
+			return NULL;
+	}
+
+	__skb_push(skb, tx_overhead);
+	/* usbnet adds padding if length is a multiple of packet size
+	 * if so, adjust length value in header
+	 */
+	if ((skb->len % dev->maxpacket) == 0)
+		len++;
+
+	skb->data[0] = len;
+	skb->data[1] = len >> 8;
+	skb->data[2] = 0x00;
+	skb->data[3] = 0x80;
+
+	for (i = 4; i < 48; i++)
+		skb->data[i] = 0x00;
+
+	skb->data[48] = len;
+	skb->data[49] = len >> 8;
+	skb->data[50] = 0x00;
+	skb->data[51] = 0x80;
+
+	for (i = 52; i < 64; i++)
+		skb->data[i] = 0x00;
+
+	return skb;
+}
+
+static int ch9200_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	int len = 0;
+	int rx_overhead = 0;
+
+	rx_overhead = 64;
+
+	if (unlikely(skb->len < rx_overhead)) {
+		dev_err(&dev->udev->dev, "unexpected tiny rx frame\n");
+		return 0;
+	}
+
+	len = (skb->data[skb->len - 16] | skb->data[skb->len - 15] << 8);
+	skb_trim(skb, len);
+
+	return 1;
+}
+
+static int get_mac_address(struct usbnet *dev, unsigned char *data)
+{
+	int err = 0;
+	unsigned char mac_addr[0x06];
+	int rd_mac_len = 0;
+
+	netdev_dbg(dev->net, "get_mac_address:\n\tusbnet VID:%0x PID:%0x\n",
+		   dev->udev->descriptor.idVendor,
+		   dev->udev->descriptor.idProduct);
+
+	memset(mac_addr, 0, sizeof(mac_addr));
+	rd_mac_len = control_read(dev, REQUEST_READ, 0,
+				  MAC_REG_STATION_L, mac_addr, 0x02,
+				  CONTROL_TIMEOUT_MS);
+	rd_mac_len += control_read(dev, REQUEST_READ, 0, MAC_REG_STATION_M,
+				   mac_addr + 2, 0x02, CONTROL_TIMEOUT_MS);
+	rd_mac_len += control_read(dev, REQUEST_READ, 0, MAC_REG_STATION_H,
+				   mac_addr + 4, 0x02, CONTROL_TIMEOUT_MS);
+	if (rd_mac_len != ETH_ALEN)
+		err = -EINVAL;
+
+	data[0] = mac_addr[5];
+	data[1] = mac_addr[4];
+	data[2] = mac_addr[3];
+	data[3] = mac_addr[2];
+	data[4] = mac_addr[1];
+	data[5] = mac_addr[0];
+
+	return err;
+}
+
+static int ch9200_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int retval = 0;
+	unsigned char data[2];
+
+	retval = usbnet_get_endpoints(dev, intf);
+	if (retval)
+		return retval;
+
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ch9200_mdio_read;
+	dev->mii.mdio_write = ch9200_mdio_write;
+	dev->mii.reg_num_mask = 0x1f;
+
+	dev->mii.phy_id_mask = 0x1f;
+
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+	dev->rx_urb_size = 24 * 64 + 16;
+	mii_nway_restart(&dev->mii);
+
+	data[0] = 0x01;
+	data[1] = 0x0F;
+	retval = control_write(dev, REQUEST_WRITE, 0, MAC_REG_THRESHOLD, data,
+			       0x02, CONTROL_TIMEOUT_MS);
+
+	data[0] = 0xA0;
+	data[1] = 0x90;
+	retval = control_write(dev, REQUEST_WRITE, 0, MAC_REG_FIFO_DEPTH, data,
+			       0x02, CONTROL_TIMEOUT_MS);
+
+	data[0] = 0x30;
+	data[1] = 0x00;
+	retval = control_write(dev, REQUEST_WRITE, 0, MAC_REG_PAUSE, data,
+			       0x02, CONTROL_TIMEOUT_MS);
+
+	data[0] = 0x17;
+	data[1] = 0xD8;
+	retval = control_write(dev, REQUEST_WRITE, 0, MAC_REG_FLOW_CONTROL,
+			       data, 0x02, CONTROL_TIMEOUT_MS);
+
+	/* Undocumented register */
+	data[0] = 0x01;
+	data[1] = 0x00;
+	retval = control_write(dev, REQUEST_WRITE, 0, 254, data, 0x02,
+			       CONTROL_TIMEOUT_MS);
+
+	data[0] = 0x5F;
+	data[1] = 0x0D;
+	retval = control_write(dev, REQUEST_WRITE, 0, MAC_REG_CTRL, data, 0x02,
+			       CONTROL_TIMEOUT_MS);
+
+	retval = get_mac_address(dev, dev->net->dev_addr);
+
+	return retval;
+}
+
+static const struct driver_info ch9200_info = {
+	.description = "CH9200 USB to Network Adaptor",
+	.flags = FLAG_ETHER,
+	.bind = ch9200_bind,
+	.rx_fixup = ch9200_rx_fixup,
+	.tx_fixup = ch9200_tx_fixup,
+	.status = ch9200_status,
+	.link_reset = ch9200_link_reset,
+	.reset = ch9200_link_reset,
+};
+
+static const struct usb_device_id ch9200_products[] = {
+	{
+	 USB_DEVICE(0x1A86, 0xE092),
+	 .driver_info = (unsigned long)&ch9200_info,
+	 },
+	{},
+};
+
+MODULE_DEVICE_TABLE(usb, ch9200_products);
+
+static struct usb_driver ch9200_driver = {
+	.name = "ch9200",
+	.id_table = ch9200_products,
+	.probe = usbnet_probe,
+	.disconnect = usbnet_disconnect,
+	.suspend = usbnet_suspend,
+	.resume = usbnet_resume,
+};
+
+static int __init ch9200_init(void)
+{
+	return usb_register(&ch9200_driver);
+}
+
+static void __exit ch9200_exit(void)
+{
+	usb_deregister(&ch9200_driver);
+}
+
+module_init(ch9200_init);
+module_exit(ch9200_exit);
+
+MODULE_DESCRIPTION("QinHeng CH9200 USB Network device");
+MODULE_LICENSE("GPL");
-- 
2.4.3

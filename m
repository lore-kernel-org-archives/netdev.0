From: Christian Riesch <christian.riesch@omicron.at>
Subject: [PATCH 3/4] asix: Factor out common code
Date: Fri, 6 Jul 2012 13:33:07 +0200
Message-ID: <1341574388-7464-4-git-send-email-christian.riesch@omicron.at>
References: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Oliver Neukum <oneukum@suse.de>,
	Eric Dumazet <edumazet@google.com>,
	Allan Chou <allan@asix.com.tw>,
	Mark Lord <kernel@teksavvy.com>,
	Grant Grundler <grundler@chromium.org>,
	Ming Lei <tom.leiming@gmail.com>,
	Michael Riesch <michael@riesch.at>,
	Christian Riesch <christian.riesch@omicron.at>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns.omicron.at ([212.183.10.25]:54477 "EHLO ns.omicron.at"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030257Ab2GFLrA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:47:00 -0400
In-Reply-To: <1341574388-7464-1-git-send-email-christian.riesch@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the new driver for the AX88172A to share code with the
existing drivers for ASIX devices.

Signed-off-by: Christian Riesch <christian.riesch@omicron.at>
---
 drivers/net/usb/Makefile       |    2 +-
 drivers/net/usb/asix.h         |  211 +++++++++++++
 drivers/net/usb/asix_common.c  |  525 ++++++++++++++++++++++++++++++++
 drivers/net/usb/asix_devices.c |  645 +---------------------------------------
 4 files changed, 738 insertions(+), 645 deletions(-)
 create mode 100644 drivers/net/usb/asix.h
 create mode 100644 drivers/net/usb/asix_common.c

diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 2c8f7b4..a9490d9 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -8,7 +8,7 @@ obj-$(CONFIG_USB_PEGASUS)	+= pegasus.o
 obj-$(CONFIG_USB_RTL8150)	+= rtl8150.o
 obj-$(CONFIG_USB_HSO)		+= hso.o
 obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
-asix-y := asix_devices.o
+asix-y := asix_devices.o asix_common.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
new file mode 100644
index 0000000..5339578
--- /dev/null
+++ b/drivers/net/usb/asix.h
@@ -0,0 +1,211 @@
+/*
+ * ASIX AX8817X based USB 2.0 Ethernet Devices
+ * Copyright (C) 2003-2006 David Hollis <dhollis@davehollis.com>
+ * Copyright (C) 2005 Phil Chang <pchang23@sbcglobal.net>
+ * Copyright (C) 2006 James Painter <jamie.painter@iname.com>
+ * Copyright (c) 2002-2003 TiVo Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#ifndef _ASIX_H
+#define _ASIX_H
+
+#include <linux/module.h>
+#include <linux/kmod.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/workqueue.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/crc32.h>
+#include <linux/usb/usbnet.h>
+#include <linux/slab.h>
+#include <linux/if_vlan.h>
+
+/* #define	DEBUG	*/		/* error path messages, extra info */
+/* #define	VERBOSE	*/		/* more; success messages */
+
+#define DRIVER_VERSION "22-Dec-2011"
+#define DRIVER_NAME "asix"
+
+/* ASIX AX8817X based USB 2.0 Ethernet Devices */
+#define AX_CMD_SET_SW_MII		0x06
+#define AX_CMD_READ_MII_REG		0x07
+#define AX_CMD_WRITE_MII_REG		0x08
+#define AX_CMD_SET_HW_MII		0x0a
+#define AX_CMD_READ_EEPROM		0x0b
+#define AX_CMD_WRITE_EEPROM		0x0c
+#define AX_CMD_WRITE_ENABLE		0x0d
+#define AX_CMD_WRITE_DISABLE		0x0e
+#define AX_CMD_READ_RX_CTL		0x0f
+#define AX_CMD_WRITE_RX_CTL		0x10
+#define AX_CMD_READ_IPG012		0x11
+#define AX_CMD_WRITE_IPG0		0x12
+#define AX_CMD_WRITE_IPG1		0x13
+#define AX_CMD_READ_NODE_ID		0x13
+#define AX_CMD_WRITE_NODE_ID		0x14
+#define AX_CMD_WRITE_IPG2		0x14
+#define AX_CMD_WRITE_MULTI_FILTER	0x16
+#define AX88172_CMD_READ_NODE_ID	0x17
+#define AX_CMD_READ_PHY_ID		0x19
+#define AX_CMD_READ_MEDIUM_STATUS	0x1a
+#define AX_CMD_WRITE_MEDIUM_MODE	0x1b
+#define AX_CMD_READ_MONITOR_MODE	0x1c
+#define AX_CMD_WRITE_MONITOR_MODE	0x1d
+#define AX_CMD_READ_GPIOS		0x1e
+#define AX_CMD_WRITE_GPIOS		0x1f
+#define AX_CMD_SW_RESET			0x20
+#define AX_CMD_SW_PHY_STATUS		0x21
+#define AX_CMD_SW_PHY_SELECT		0x22
+
+#define AX_MONITOR_MODE			0x01
+#define AX_MONITOR_LINK			0x02
+#define AX_MONITOR_MAGIC		0x04
+#define AX_MONITOR_HSFS			0x10
+
+/* AX88172 Medium Status Register values */
+#define AX88172_MEDIUM_FD		0x02
+#define AX88172_MEDIUM_TX		0x04
+#define AX88172_MEDIUM_FC		0x10
+#define AX88172_MEDIUM_DEFAULT \
+		(AX88172_MEDIUM_FD | AX88172_MEDIUM_TX | AX88172_MEDIUM_FC)
+
+#define AX_MCAST_FILTER_SIZE		8
+#define AX_MAX_MCAST			64
+
+#define AX_SWRESET_CLEAR		0x00
+#define AX_SWRESET_RR			0x01
+#define AX_SWRESET_RT			0x02
+#define AX_SWRESET_PRTE			0x04
+#define AX_SWRESET_PRL			0x08
+#define AX_SWRESET_BZ			0x10
+#define AX_SWRESET_IPRL			0x20
+#define AX_SWRESET_IPPD			0x40
+
+#define AX88772_IPG0_DEFAULT		0x15
+#define AX88772_IPG1_DEFAULT		0x0c
+#define AX88772_IPG2_DEFAULT		0x12
+
+/* AX88772 & AX88178 Medium Mode Register */
+#define AX_MEDIUM_PF		0x0080
+#define AX_MEDIUM_JFE		0x0040
+#define AX_MEDIUM_TFC		0x0020
+#define AX_MEDIUM_RFC		0x0010
+#define AX_MEDIUM_ENCK		0x0008
+#define AX_MEDIUM_AC		0x0004
+#define AX_MEDIUM_FD		0x0002
+#define AX_MEDIUM_GM		0x0001
+#define AX_MEDIUM_SM		0x1000
+#define AX_MEDIUM_SBP		0x0800
+#define AX_MEDIUM_PS		0x0200
+#define AX_MEDIUM_RE		0x0100
+
+#define AX88178_MEDIUM_DEFAULT	\
+	(AX_MEDIUM_PS | AX_MEDIUM_FD | AX_MEDIUM_AC | \
+	 AX_MEDIUM_RFC | AX_MEDIUM_TFC | AX_MEDIUM_JFE | \
+	 AX_MEDIUM_RE)
+
+#define AX88772_MEDIUM_DEFAULT	\
+	(AX_MEDIUM_FD | AX_MEDIUM_RFC | \
+	 AX_MEDIUM_TFC | AX_MEDIUM_PS | \
+	 AX_MEDIUM_AC | AX_MEDIUM_RE)
+
+/* AX88772 & AX88178 RX_CTL values */
+#define AX_RX_CTL_SO		0x0080
+#define AX_RX_CTL_AP		0x0020
+#define AX_RX_CTL_AM		0x0010
+#define AX_RX_CTL_AB		0x0008
+#define AX_RX_CTL_SEP		0x0004
+#define AX_RX_CTL_AMALL		0x0002
+#define AX_RX_CTL_PRO		0x0001
+#define AX_RX_CTL_MFB_2048	0x0000
+#define AX_RX_CTL_MFB_4096	0x0100
+#define AX_RX_CTL_MFB_8192	0x0200
+#define AX_RX_CTL_MFB_16384	0x0300
+
+#define AX_DEFAULT_RX_CTL	(AX_RX_CTL_SO | AX_RX_CTL_AB)
+
+/* GPIO 0 .. 2 toggles */
+#define AX_GPIO_GPO0EN		0x01	/* GPIO0 Output enable */
+#define AX_GPIO_GPO_0		0x02	/* GPIO0 Output value */
+#define AX_GPIO_GPO1EN		0x04	/* GPIO1 Output enable */
+#define AX_GPIO_GPO_1		0x08	/* GPIO1 Output value */
+#define AX_GPIO_GPO2EN		0x10	/* GPIO2 Output enable */
+#define AX_GPIO_GPO_2		0x20	/* GPIO2 Output value */
+#define AX_GPIO_RESERVED	0x40	/* Reserved */
+#define AX_GPIO_RSE		0x80	/* Reload serial EEPROM */
+
+#define AX_EEPROM_MAGIC		0xdeadbeef
+#define AX88172_EEPROM_LEN	0x40
+#define AX88772_EEPROM_LEN	0xff
+
+/* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
+struct asix_data {
+	u8 multi_filter[AX_MCAST_FILTER_SIZE];
+	u8 mac_addr[ETH_ALEN];
+	u8 phymode;
+	u8 ledmode;
+	u8 eeprom_len;
+};
+
+int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+		  u16 size, void *data);
+
+int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+		   u16 size, void *data);
+
+void asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value,
+			  u16 index, u16 size, void *data);
+
+int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb);
+
+struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
+			      gfp_t flags);
+
+int asix_set_sw_mii(struct usbnet *dev);
+int asix_set_hw_mii(struct usbnet *dev);
+
+int asix_get_phy_addr(struct usbnet *dev);
+
+int asix_sw_reset(struct usbnet *dev, u8 flags);
+
+u16 asix_read_rx_ctl(struct usbnet *dev);
+int asix_write_rx_ctl(struct usbnet *dev, u16 mode);
+
+u16 asix_read_medium_status(struct usbnet *dev);
+int asix_write_medium_mode(struct usbnet *dev, u16 mode);
+
+int asix_write_gpio(struct usbnet *dev, u16 value, int sleep);
+
+void asix_set_multicast(struct net_device *net);
+
+int asix_mdio_read(struct net_device *netdev, int phy_id, int loc);
+void asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val);
+
+void asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo);
+int asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo);
+
+int asix_get_eeprom_len(struct net_device *net);
+int asix_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
+		    u8 *data);
+
+void asix_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info);
+
+int asix_set_mac_address(struct net_device *net, void *p);
+
+#endif /* _ASIX_H */
diff --git a/drivers/net/usb/asix_common.c b/drivers/net/usb/asix_common.c
new file mode 100644
index 0000000..8231948
--- /dev/null
+++ b/drivers/net/usb/asix_common.c
@@ -0,0 +1,525 @@
+/*
+ * ASIX AX8817X based USB 2.0 Ethernet Devices
+ * Copyright (C) 2003-2006 David Hollis <dhollis@davehollis.com>
+ * Copyright (C) 2005 Phil Chang <pchang23@sbcglobal.net>
+ * Copyright (C) 2006 James Painter <jamie.painter@iname.com>
+ * Copyright (c) 2002-2003 TiVo Inc.
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include "asix.h"
+
+int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+		  u16 size, void *data)
+{
+	void *buf;
+	int err = -ENOMEM;
+
+	netdev_dbg(dev->net, "asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
+
+	buf = kmalloc(size, GFP_KERNEL);
+	if (!buf)
+		goto out;
+
+	err = usb_control_msg(
+		dev->udev,
+		usb_rcvctrlpipe(dev->udev, 0),
+		cmd,
+		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+		value,
+		index,
+		buf,
+		size,
+		USB_CTRL_GET_TIMEOUT);
+	if (err == size)
+		memcpy(data, buf, size);
+	else if (err >= 0)
+		err = -EINVAL;
+	kfree(buf);
+
+out:
+	return err;
+}
+
+int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+			     u16 size, void *data)
+{
+	void *buf = NULL;
+	int err = -ENOMEM;
+
+	netdev_dbg(dev->net, "asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
+
+	if (data) {
+		buf = kmemdup(data, size, GFP_KERNEL);
+		if (!buf)
+			goto out;
+	}
+
+	err = usb_control_msg(
+		dev->udev,
+		usb_sndctrlpipe(dev->udev, 0),
+		cmd,
+		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+		value,
+		index,
+		buf,
+		size,
+		USB_CTRL_SET_TIMEOUT);
+	kfree(buf);
+
+out:
+	return err;
+}
+
+static void asix_async_cmd_callback(struct urb *urb)
+{
+	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
+	int status = urb->status;
+
+	if (status < 0)
+		pr_debug("asix_async_cmd_callback() failed with %d",
+			 status);
+
+	kfree(req);
+	usb_free_urb(urb);
+}
+
+void asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+			  u16 size, void *data)
+{
+	struct usb_ctrlrequest *req;
+	int status;
+	struct urb *urb;
+
+	netdev_dbg(dev->net, "asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
+		netdev_err(dev->net, "Error allocating URB in write_cmd_async!\n");
+		return;
+	}
+
+	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
+	if (!req) {
+		netdev_err(dev->net, "Failed to allocate memory for control request\n");
+		usb_free_urb(urb);
+		return;
+	}
+
+	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
+	req->bRequest = cmd;
+	req->wValue = cpu_to_le16(value);
+	req->wIndex = cpu_to_le16(index);
+	req->wLength = cpu_to_le16(size);
+
+	usb_fill_control_urb(urb, dev->udev,
+			     usb_sndctrlpipe(dev->udev, 0),
+			     (void *)req, data, size,
+			     asix_async_cmd_callback, req);
+
+	status = usb_submit_urb(urb, GFP_ATOMIC);
+	if (status < 0) {
+		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
+			   status);
+		kfree(req);
+		usb_free_urb(urb);
+	}
+}
+
+int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	int offset = 0;
+
+	while (offset + sizeof(u32) < skb->len) {
+		struct sk_buff *ax_skb;
+		u16 size;
+		u32 header = get_unaligned_le32(skb->data + offset);
+
+		offset += sizeof(u32);
+
+		/* get the packet length */
+		size = (u16) (header & 0x7ff);
+		if (size != ((~header >> 16) & 0x07ff)) {
+			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
+			return 0;
+		}
+
+		if ((size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) ||
+		    (size + offset > skb->len)) {
+			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
+				   size);
+			return 0;
+		}
+		ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
+		if (!ax_skb)
+			return 0;
+
+		skb_put(ax_skb, size);
+		memcpy(ax_skb->data, skb->data + offset, size);
+		usbnet_skb_return(dev, ax_skb);
+
+		offset += (size + 1) & 0xfffe;
+	}
+
+	if (skb->len != offset) {
+		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d\n",
+			   skb->len);
+		return 0;
+	}
+	return 1;
+}
+
+struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
+			      gfp_t flags)
+{
+	int padlen;
+	int headroom = skb_headroom(skb);
+	int tailroom = skb_tailroom(skb);
+	u32 packet_len;
+	u32 padbytes = 0xffff0000;
+
+	padlen = ((skb->len + 4) & (dev->maxpacket - 1)) ? 0 : 4;
+
+	if ((!skb_cloned(skb)) &&
+	    ((headroom + tailroom) >= (4 + padlen))) {
+		if ((headroom < 4) || (tailroom < padlen)) {
+			skb->data = memmove(skb->head + 4, skb->data, skb->len);
+			skb_set_tail_pointer(skb, skb->len);
+		}
+	} else {
+		struct sk_buff *skb2;
+		skb2 = skb_copy_expand(skb, 4, padlen, flags);
+		dev_kfree_skb_any(skb);
+		skb = skb2;
+		if (!skb)
+			return NULL;
+	}
+
+	skb_push(skb, 4);
+	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
+	cpu_to_le32s(&packet_len);
+	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));
+
+	if (padlen) {
+		cpu_to_le32s(&padbytes);
+		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
+		skb_put(skb, sizeof(padbytes));
+	}
+	return skb;
+}
+
+int asix_set_sw_mii(struct usbnet *dev)
+{
+	int ret;
+	ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to enable software MII access\n");
+	return ret;
+}
+
+int asix_set_hw_mii(struct usbnet *dev)
+{
+	int ret;
+	ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to enable hardware MII access\n");
+	return ret;
+}
+
+int asix_get_phy_addr(struct usbnet *dev)
+{
+	u8 buf[2];
+	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
+
+	netdev_dbg(dev->net, "asix_get_phy_addr()\n");
+
+	if (ret < 0) {
+		netdev_err(dev->net, "Error reading PHYID register: %02x\n",
+			   ret);
+		goto out;
+	}
+	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
+		   *((__le16 *)buf));
+	ret = buf[1];
+
+out:
+	return ret;
+}
+
+int asix_sw_reset(struct usbnet *dev, u8 flags)
+{
+	int ret;
+
+	ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to send software reset: %02x\n",
+			   ret);
+
+	return ret;
+}
+
+u16 asix_read_rx_ctl(struct usbnet *dev)
+{
+	__le16 v;
+	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
+
+	if (ret < 0) {
+		netdev_err(dev->net, "Error reading RX_CTL register: %02x\n",
+			   ret);
+		goto out;
+	}
+	ret = le16_to_cpu(v);
+out:
+	return ret;
+}
+
+int asix_write_rx_ctl(struct usbnet *dev, u16 mode)
+{
+	int ret;
+
+	netdev_dbg(dev->net, "asix_write_rx_ctl() - mode = 0x%04x\n", mode);
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_RX_CTL, mode, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to write RX_CTL mode to 0x%04x: %02x\n",
+			   mode, ret);
+
+	return ret;
+}
+
+u16 asix_read_medium_status(struct usbnet *dev)
+{
+	__le16 v;
+	int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
+
+	if (ret < 0) {
+		netdev_err(dev->net, "Error reading Medium Status register: %02x\n",
+			   ret);
+		return ret;	/* TODO: callers not checking for error ret */
+	}
+
+	return le16_to_cpu(v);
+
+}
+
+int asix_write_medium_mode(struct usbnet *dev, u16 mode)
+{
+	int ret;
+
+	netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n",
+		   mode);
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
+			   mode, ret);
+
+	return ret;
+}
+
+int asix_write_gpio(struct usbnet *dev, u16 value, int sleep)
+{
+	int ret;
+
+	netdev_dbg(dev->net, "asix_write_gpio() - value = 0x%04x\n", value);
+	ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to write GPIO value 0x%04x: %02x\n",
+			   value, ret);
+
+	if (sleep)
+		msleep(sleep);
+
+	return ret;
+}
+
+/*
+ * AX88772 & AX88178 have a 16-bit RX_CTL value
+ */
+void asix_set_multicast(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct asix_data *data = (struct asix_data *)&dev->data;
+	u16 rx_ctl = AX_DEFAULT_RX_CTL;
+
+	if (net->flags & IFF_PROMISC) {
+		rx_ctl |= AX_RX_CTL_PRO;
+	} else if (net->flags & IFF_ALLMULTI ||
+		   netdev_mc_count(net) > AX_MAX_MCAST) {
+		rx_ctl |= AX_RX_CTL_AMALL;
+	} else if (netdev_mc_empty(net)) {
+		/* just broadcast and directed */
+	} else {
+		/* We use the 20 byte dev->data
+		 * for our 8 byte filter buffer
+		 * to avoid allocating memory that
+		 * is tricky to free later */
+		struct netdev_hw_addr *ha;
+		u32 crc_bits;
+
+		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
+
+		/* Build the multicast hash filter. */
+		netdev_for_each_mc_addr(ha, net) {
+			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
+			data->multi_filter[crc_bits >> 3] |=
+			    1 << (crc_bits & 7);
+		}
+
+		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
+				     AX_MCAST_FILTER_SIZE, data->multi_filter);
+
+		rx_ctl |= AX_RX_CTL_AM;
+	}
+
+	asix_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+}
+
+int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	__le16 res;
+
+	mutex_lock(&dev->phy_mutex);
+	asix_set_sw_mii(dev);
+	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
+		      (__u16)loc, 2, &res);
+	asix_set_hw_mii(dev);
+	mutex_unlock(&dev->phy_mutex);
+
+	netdev_dbg(dev->net, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+		   phy_id, loc, le16_to_cpu(res));
+
+	return le16_to_cpu(res);
+}
+
+void asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	__le16 res = cpu_to_le16(val);
+
+	netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+		   phy_id, loc, val);
+	mutex_lock(&dev->phy_mutex);
+	asix_set_sw_mii(dev);
+	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
+	asix_set_hw_mii(dev);
+	mutex_unlock(&dev->phy_mutex);
+}
+
+void asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 opt;
+
+	if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
+		wolinfo->supported = 0;
+		wolinfo->wolopts = 0;
+		return;
+	}
+	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
+	wolinfo->wolopts = 0;
+	if (opt & AX_MONITOR_LINK)
+		wolinfo->wolopts |= WAKE_PHY;
+	if (opt & AX_MONITOR_MAGIC)
+		wolinfo->wolopts |= WAKE_MAGIC;
+}
+
+int asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 opt = 0;
+
+	if (wolinfo->wolopts & WAKE_PHY)
+		opt |= AX_MONITOR_LINK;
+	if (wolinfo->wolopts & WAKE_MAGIC)
+		opt |= AX_MONITOR_MAGIC;
+
+	if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
+			   opt, 0, 0, NULL) < 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+int asix_get_eeprom_len(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct asix_data *data = (struct asix_data *)&dev->data;
+
+	return data->eeprom_len;
+}
+
+int asix_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom,
+		    u8 *data)
+{
+	struct usbnet *dev = netdev_priv(net);
+	__le16 *ebuf = (__le16 *)data;
+	int i;
+
+	/* Crude hack to ensure that we don't overwrite memory
+	 * if an odd length is supplied
+	 */
+	if (eeprom->len % 2)
+		return -EINVAL;
+
+	eeprom->magic = AX_EEPROM_MAGIC;
+
+	/* ax8817x returns 2 bytes from eeprom on read */
+	for (i = 0; i < eeprom->len / 2; i++) {
+		if (asix_read_cmd(dev, AX_CMD_READ_EEPROM,
+				  eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
+			return -EINVAL;
+	}
+	return 0;
+}
+
+void asix_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct asix_data *data = (struct asix_data *)&dev->data;
+
+	/* Inherit standard device info */
+	usbnet_get_drvinfo(net, info);
+	strncpy(info->driver, DRIVER_NAME, sizeof info->driver);
+	strncpy(info->version, DRIVER_VERSION, sizeof info->version);
+	info->eedump_len = data->eeprom_len;
+}
+
+int asix_set_mac_address(struct net_device *net, void *p)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct asix_data *data = (struct asix_data *)&dev->data;
+	struct sockaddr *addr = p;
+
+	if (netif_running(net))
+		return -EBUSY;
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
+
+	/* We use the 20 byte dev->data
+	 * for our 6 byte mac buffer
+	 * to avoid allocating memory that
+	 * is tricky to free later */
+	memcpy(data->mac_addr, addr->sa_data, ETH_ALEN);
+	asix_write_cmd_async(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
+			     data->mac_addr);
+
+	return 0;
+}
diff --git a/drivers/net/usb/asix_devices.c b/drivers/net/usb/asix_devices.c
index 9210f40..c8682a5 100644
--- a/drivers/net/usb/asix_devices.c
+++ b/drivers/net/usb/asix_devices.c
@@ -23,134 +23,7 @@
 /* #define	DEBUG	*/		/* error path messages, extra info */
 /* #define	VERBOSE	*/		/* more; success messages */
 
-#include <linux/module.h>
-#include <linux/kmod.h>
-#include <linux/init.h>
-#include <linux/netdevice.h>
-#include <linux/etherdevice.h>
-#include <linux/ethtool.h>
-#include <linux/workqueue.h>
-#include <linux/mii.h>
-#include <linux/usb.h>
-#include <linux/crc32.h>
-#include <linux/usb/usbnet.h>
-#include <linux/slab.h>
-#include <linux/if_vlan.h>
-
-#define DRIVER_VERSION "22-Dec-2011"
-#define DRIVER_NAME "asix"
-
-/* ASIX AX8817X based USB 2.0 Ethernet Devices */
-
-#define AX_CMD_SET_SW_MII		0x06
-#define AX_CMD_READ_MII_REG		0x07
-#define AX_CMD_WRITE_MII_REG		0x08
-#define AX_CMD_SET_HW_MII		0x0a
-#define AX_CMD_READ_EEPROM		0x0b
-#define AX_CMD_WRITE_EEPROM		0x0c
-#define AX_CMD_WRITE_ENABLE		0x0d
-#define AX_CMD_WRITE_DISABLE		0x0e
-#define AX_CMD_READ_RX_CTL		0x0f
-#define AX_CMD_WRITE_RX_CTL		0x10
-#define AX_CMD_READ_IPG012		0x11
-#define AX_CMD_WRITE_IPG0		0x12
-#define AX_CMD_WRITE_IPG1		0x13
-#define AX_CMD_READ_NODE_ID		0x13
-#define AX_CMD_WRITE_NODE_ID		0x14
-#define AX_CMD_WRITE_IPG2		0x14
-#define AX_CMD_WRITE_MULTI_FILTER	0x16
-#define AX88172_CMD_READ_NODE_ID	0x17
-#define AX_CMD_READ_PHY_ID		0x19
-#define AX_CMD_READ_MEDIUM_STATUS	0x1a
-#define AX_CMD_WRITE_MEDIUM_MODE	0x1b
-#define AX_CMD_READ_MONITOR_MODE	0x1c
-#define AX_CMD_WRITE_MONITOR_MODE	0x1d
-#define AX_CMD_READ_GPIOS		0x1e
-#define AX_CMD_WRITE_GPIOS		0x1f
-#define AX_CMD_SW_RESET			0x20
-#define AX_CMD_SW_PHY_STATUS		0x21
-#define AX_CMD_SW_PHY_SELECT		0x22
-
-#define AX_MONITOR_MODE			0x01
-#define AX_MONITOR_LINK			0x02
-#define AX_MONITOR_MAGIC		0x04
-#define AX_MONITOR_HSFS			0x10
-
-/* AX88172 Medium Status Register values */
-#define AX88172_MEDIUM_FD		0x02
-#define AX88172_MEDIUM_TX		0x04
-#define AX88172_MEDIUM_FC		0x10
-#define AX88172_MEDIUM_DEFAULT \
-		(AX88172_MEDIUM_FD | AX88172_MEDIUM_TX | AX88172_MEDIUM_FC)
-
-#define AX_MCAST_FILTER_SIZE		8
-#define AX_MAX_MCAST			64
-
-#define AX_SWRESET_CLEAR		0x00
-#define AX_SWRESET_RR			0x01
-#define AX_SWRESET_RT			0x02
-#define AX_SWRESET_PRTE			0x04
-#define AX_SWRESET_PRL			0x08
-#define AX_SWRESET_BZ			0x10
-#define AX_SWRESET_IPRL			0x20
-#define AX_SWRESET_IPPD			0x40
-
-#define AX88772_IPG0_DEFAULT		0x15
-#define AX88772_IPG1_DEFAULT		0x0c
-#define AX88772_IPG2_DEFAULT		0x12
-
-/* AX88772 & AX88178 Medium Mode Register */
-#define AX_MEDIUM_PF		0x0080
-#define AX_MEDIUM_JFE		0x0040
-#define AX_MEDIUM_TFC		0x0020
-#define AX_MEDIUM_RFC		0x0010
-#define AX_MEDIUM_ENCK		0x0008
-#define AX_MEDIUM_AC		0x0004
-#define AX_MEDIUM_FD		0x0002
-#define AX_MEDIUM_GM		0x0001
-#define AX_MEDIUM_SM		0x1000
-#define AX_MEDIUM_SBP		0x0800
-#define AX_MEDIUM_PS		0x0200
-#define AX_MEDIUM_RE		0x0100
-
-#define AX88178_MEDIUM_DEFAULT	\
-	(AX_MEDIUM_PS | AX_MEDIUM_FD | AX_MEDIUM_AC | \
-	 AX_MEDIUM_RFC | AX_MEDIUM_TFC | AX_MEDIUM_JFE | \
-	 AX_MEDIUM_RE)
-
-#define AX88772_MEDIUM_DEFAULT	\
-	(AX_MEDIUM_FD | AX_MEDIUM_RFC | \
-	 AX_MEDIUM_TFC | AX_MEDIUM_PS | \
-	 AX_MEDIUM_AC | AX_MEDIUM_RE)
-
-/* AX88772 & AX88178 RX_CTL values */
-#define AX_RX_CTL_SO		0x0080
-#define AX_RX_CTL_AP		0x0020
-#define AX_RX_CTL_AM		0x0010
-#define AX_RX_CTL_AB		0x0008
-#define AX_RX_CTL_SEP		0x0004
-#define AX_RX_CTL_AMALL		0x0002
-#define AX_RX_CTL_PRO		0x0001
-#define AX_RX_CTL_MFB_2048	0x0000
-#define AX_RX_CTL_MFB_4096	0x0100
-#define AX_RX_CTL_MFB_8192	0x0200
-#define AX_RX_CTL_MFB_16384	0x0300
-
-#define AX_DEFAULT_RX_CTL	(AX_RX_CTL_SO | AX_RX_CTL_AB)
-
-/* GPIO 0 .. 2 toggles */
-#define AX_GPIO_GPO0EN		0x01	/* GPIO0 Output enable */
-#define AX_GPIO_GPO_0		0x02	/* GPIO0 Output value */
-#define AX_GPIO_GPO1EN		0x04	/* GPIO1 Output enable */
-#define AX_GPIO_GPO_1		0x08	/* GPIO1 Output value */
-#define AX_GPIO_GPO2EN		0x10	/* GPIO2 Output enable */
-#define AX_GPIO_GPO_2		0x20	/* GPIO2 Output value */
-#define AX_GPIO_RESERVED	0x40	/* Reserved */
-#define AX_GPIO_RSE		0x80	/* Reload serial EEPROM */
-
-#define AX_EEPROM_MAGIC		0xdeadbeef
-#define AX88172_EEPROM_LEN	0x40
-#define AX88772_EEPROM_LEN	0xff
+#include "asix.h"
 
 #define PHY_MODE_MARVELL	0x0000
 #define MII_MARVELL_LED_CTRL	0x0018
@@ -166,15 +39,6 @@
 
 #define	PHY_MODE_RTL8211CL	0x000C
 
-/* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
-struct asix_data {
-	u8 multi_filter[AX_MCAST_FILTER_SIZE];
-	u8 mac_addr[ETH_ALEN];
-	u8 phymode;
-	u8 ledmode;
-	u8 eeprom_len;
-};
-
 struct ax88172_int_data {
 	__le16 res1;
 	u8 link;
@@ -183,209 +47,6 @@ struct ax88172_int_data {
 	__le16 res3;
 } __packed;
 
-static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
-			    u16 size, void *data)
-{
-	void *buf;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-
-	buf = kmalloc(size, GFP_KERNEL);
-	if (!buf)
-		goto out;
-
-	err = usb_control_msg(
-		dev->udev,
-		usb_rcvctrlpipe(dev->udev, 0),
-		cmd,
-		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		value,
-		index,
-		buf,
-		size,
-		USB_CTRL_GET_TIMEOUT);
-	if (err == size)
-		memcpy(data, buf, size);
-	else if (err >= 0)
-		err = -EINVAL;
-	kfree(buf);
-
-out:
-	return err;
-}
-
-static int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
-			     u16 size, void *data)
-{
-	void *buf = NULL;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-
-	if (data) {
-		buf = kmemdup(data, size, GFP_KERNEL);
-		if (!buf)
-			goto out;
-	}
-
-	err = usb_control_msg(
-		dev->udev,
-		usb_sndctrlpipe(dev->udev, 0),
-		cmd,
-		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
-		value,
-		index,
-		buf,
-		size,
-		USB_CTRL_SET_TIMEOUT);
-	kfree(buf);
-
-out:
-	return err;
-}
-
-static void asix_async_cmd_callback(struct urb *urb)
-{
-	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
-	int status = urb->status;
-
-	if (status < 0)
-		pr_debug("asix_async_cmd_callback() failed with %d",
-			 status);
-
-	kfree(req);
-	usb_free_urb(urb);
-}
-
-static void
-asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
-		     u16 size, void *data)
-{
-	struct usb_ctrlrequest *req;
-	int status;
-	struct urb *urb;
-
-	netdev_dbg(dev->net, "asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-
-	urb = usb_alloc_urb(0, GFP_ATOMIC);
-	if (!urb) {
-		netdev_err(dev->net, "Error allocating URB in write_cmd_async!\n");
-		return;
-	}
-
-	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
-	if (!req) {
-		netdev_err(dev->net, "Failed to allocate memory for control request\n");
-		usb_free_urb(urb);
-		return;
-	}
-
-	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
-	req->bRequest = cmd;
-	req->wValue = cpu_to_le16(value);
-	req->wIndex = cpu_to_le16(index);
-	req->wLength = cpu_to_le16(size);
-
-	usb_fill_control_urb(urb, dev->udev,
-			     usb_sndctrlpipe(dev->udev, 0),
-			     (void *)req, data, size,
-			     asix_async_cmd_callback, req);
-
-	status = usb_submit_urb(urb, GFP_ATOMIC);
-	if (status < 0) {
-		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
-			   status);
-		kfree(req);
-		usb_free_urb(urb);
-	}
-}
-
-static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
-{
-	int offset = 0;
-
-	while (offset + sizeof(u32) < skb->len) {
-		struct sk_buff *ax_skb;
-		u16 size;
-		u32 header = get_unaligned_le32(skb->data + offset);
-
-		offset += sizeof(u32);
-
-		/* get the packet length */
-		size = (u16) (header & 0x7ff);
-		if (size != ((~header >> 16) & 0x07ff)) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
-			return 0;
-		}
-
-		if ((size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) ||
-		    (size + offset > skb->len)) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
-				   size);
-			return 0;
-		}
-		ax_skb = netdev_alloc_skb_ip_align(dev->net, size);
-		if (!ax_skb)
-			return 0;
-
-		skb_put(ax_skb, size);
-		memcpy(ax_skb->data, skb->data + offset, size);
-		usbnet_skb_return(dev, ax_skb);
-
-		offset += (size + 1) & 0xfffe;
-	}
-
-	if (skb->len != offset) {
-		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d\n",
-			   skb->len);
-		return 0;
-	}
-	return 1;
-}
-
-static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
-					gfp_t flags)
-{
-	int padlen;
-	int headroom = skb_headroom(skb);
-	int tailroom = skb_tailroom(skb);
-	u32 packet_len;
-	u32 padbytes = 0xffff0000;
-
-	padlen = ((skb->len + 4) & (dev->maxpacket - 1)) ? 0 : 4;
-
-	if ((!skb_cloned(skb)) &&
-	    ((headroom + tailroom) >= (4 + padlen))) {
-		if ((headroom < 4) || (tailroom < padlen)) {
-			skb->data = memmove(skb->head + 4, skb->data, skb->len);
-			skb_set_tail_pointer(skb, skb->len);
-		}
-	} else {
-		struct sk_buff *skb2;
-		skb2 = skb_copy_expand(skb, 4, padlen, flags);
-		dev_kfree_skb_any(skb);
-		skb = skb2;
-		if (!skb)
-			return NULL;
-	}
-
-	skb_push(skb, 4);
-	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
-	cpu_to_le32s(&packet_len);
-	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));
-
-	if (padlen) {
-		cpu_to_le32s(&padbytes);
-		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
-		skb_put(skb, sizeof(padbytes));
-	}
-	return skb;
-}
-
 static void asix_status(struct usbnet *dev, struct urb *urb)
 {
 	struct ax88172_int_data *event;
@@ -407,204 +68,6 @@ static void asix_status(struct usbnet *dev, struct urb *urb)
 	}
 }
 
-static inline int asix_set_sw_mii(struct usbnet *dev)
-{
-	int ret;
-	ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to enable software MII access\n");
-	return ret;
-}
-
-static inline int asix_set_hw_mii(struct usbnet *dev)
-{
-	int ret;
-	ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to enable hardware MII access\n");
-	return ret;
-}
-
-static inline int asix_get_phy_addr(struct usbnet *dev)
-{
-	u8 buf[2];
-	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
-
-	netdev_dbg(dev->net, "asix_get_phy_addr()\n");
-
-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading PHYID register: %02x\n",
-			   ret);
-		goto out;
-	}
-	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
-		   *((__le16 *)buf));
-	ret = buf[1];
-
-out:
-	return ret;
-}
-
-static int asix_sw_reset(struct usbnet *dev, u8 flags)
-{
-	int ret;
-
-	ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to send software reset: %02x\n",
-			   ret);
-
-	return ret;
-}
-
-static u16 asix_read_rx_ctl(struct usbnet *dev)
-{
-	__le16 v;
-	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
-
-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading RX_CTL register: %02x\n",
-			   ret);
-		goto out;
-	}
-	ret = le16_to_cpu(v);
-out:
-	return ret;
-}
-
-static int asix_write_rx_ctl(struct usbnet *dev, u16 mode)
-{
-	int ret;
-
-	netdev_dbg(dev->net, "asix_write_rx_ctl() - mode = 0x%04x\n", mode);
-	ret = asix_write_cmd(dev, AX_CMD_WRITE_RX_CTL, mode, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to write RX_CTL mode to 0x%04x: %02x\n",
-			   mode, ret);
-
-	return ret;
-}
-
-static u16 asix_read_medium_status(struct usbnet *dev)
-{
-	__le16 v;
-	int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
-
-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading Medium Status register: %02x\n",
-			   ret);
-		return ret;	/* TODO: callers not checking for error ret */
-	}
-
-	return le16_to_cpu(v);
-
-}
-
-static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
-{
-	int ret;
-
-	netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n",
-		   mode);
-	ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
-			   mode, ret);
-
-	return ret;
-}
-
-static int asix_write_gpio(struct usbnet *dev, u16 value, int sleep)
-{
-	int ret;
-
-	netdev_dbg(dev->net, "asix_write_gpio() - value = 0x%04x\n", value);
-	ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to write GPIO value 0x%04x: %02x\n",
-			   value, ret);
-
-	if (sleep)
-		msleep(sleep);
-
-	return ret;
-}
-
-/*
- * AX88772 & AX88178 have a 16-bit RX_CTL value
- */
-static void asix_set_multicast(struct net_device *net)
-{
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u16 rx_ctl = AX_DEFAULT_RX_CTL;
-
-	if (net->flags & IFF_PROMISC) {
-		rx_ctl |= AX_RX_CTL_PRO;
-	} else if (net->flags & IFF_ALLMULTI ||
-		   netdev_mc_count(net) > AX_MAX_MCAST) {
-		rx_ctl |= AX_RX_CTL_AMALL;
-	} else if (netdev_mc_empty(net)) {
-		/* just broadcast and directed */
-	} else {
-		/* We use the 20 byte dev->data
-		 * for our 8 byte filter buffer
-		 * to avoid allocating memory that
-		 * is tricky to free later */
-		struct netdev_hw_addr *ha;
-		u32 crc_bits;
-
-		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
-
-		/* Build the multicast hash filter. */
-		netdev_for_each_mc_addr(ha, net) {
-			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
-			data->multi_filter[crc_bits >> 3] |=
-			    1 << (crc_bits & 7);
-		}
-
-		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
-				     AX_MCAST_FILTER_SIZE, data->multi_filter);
-
-		rx_ctl |= AX_RX_CTL_AM;
-	}
-
-	asix_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
-}
-
-static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
-{
-	struct usbnet *dev = netdev_priv(netdev);
-	__le16 res;
-
-	mutex_lock(&dev->phy_mutex);
-	asix_set_sw_mii(dev);
-	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
-		      (__u16)loc, 2, &res);
-	asix_set_hw_mii(dev);
-	mutex_unlock(&dev->phy_mutex);
-
-	netdev_dbg(dev->net, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
-		   phy_id, loc, le16_to_cpu(res));
-
-	return le16_to_cpu(res);
-}
-
-static void
-asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
-{
-	struct usbnet *dev = netdev_priv(netdev);
-	__le16 res = cpu_to_le16(val);
-
-	netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
-		   phy_id, loc, val);
-	mutex_lock(&dev->phy_mutex);
-	asix_set_sw_mii(dev);
-	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
-	asix_set_hw_mii(dev);
-	mutex_unlock(&dev->phy_mutex);
-}
-
 /* Get the PHY Identifier from the PHYSID1 & PHYSID2 MII registers */
 static u32 asix_get_phyid(struct usbnet *dev)
 {
@@ -635,88 +98,6 @@ static u32 asix_get_phyid(struct usbnet *dev)
 	return phy_id;
 }
 
-static void
-asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
-{
-	struct usbnet *dev = netdev_priv(net);
-	u8 opt;
-
-	if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
-		wolinfo->supported = 0;
-		wolinfo->wolopts = 0;
-		return;
-	}
-	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
-	wolinfo->wolopts = 0;
-	if (opt & AX_MONITOR_LINK)
-		wolinfo->wolopts |= WAKE_PHY;
-	if (opt & AX_MONITOR_MAGIC)
-		wolinfo->wolopts |= WAKE_MAGIC;
-}
-
-static int
-asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
-{
-	struct usbnet *dev = netdev_priv(net);
-	u8 opt = 0;
-
-	if (wolinfo->wolopts & WAKE_PHY)
-		opt |= AX_MONITOR_LINK;
-	if (wolinfo->wolopts & WAKE_MAGIC)
-		opt |= AX_MONITOR_MAGIC;
-
-	if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
-			   opt, 0, 0, NULL) < 0)
-		return -EINVAL;
-
-	return 0;
-}
-
-static int asix_get_eeprom_len(struct net_device *net)
-{
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	return data->eeprom_len;
-}
-
-static int asix_get_eeprom(struct net_device *net,
-			      struct ethtool_eeprom *eeprom, u8 *data)
-{
-	struct usbnet *dev = netdev_priv(net);
-	__le16 *ebuf = (__le16 *)data;
-	int i;
-
-	/* Crude hack to ensure that we don't overwrite memory
-	 * if an odd length is supplied
-	 */
-	if (eeprom->len % 2)
-		return -EINVAL;
-
-	eeprom->magic = AX_EEPROM_MAGIC;
-
-	/* ax8817x returns 2 bytes from eeprom on read */
-	for (i = 0; i < eeprom->len / 2; i++) {
-		if (asix_read_cmd(dev, AX_CMD_READ_EEPROM,
-				  eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
-			return -EINVAL;
-	}
-	return 0;
-}
-
-static void asix_get_drvinfo(struct net_device *net,
-			     struct ethtool_drvinfo *info)
-{
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	/* Inherit standard device info */
-	usbnet_get_drvinfo(net, info);
-	strncpy(info->driver, DRIVER_NAME, sizeof info->driver);
-	strncpy(info->version, DRIVER_VERSION, sizeof info->version);
-	info->eedump_len = data->eeprom_len;
-}
-
 static u32 asix_get_link(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -731,30 +112,6 @@ static int asix_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
 }
 
-static int asix_set_mac_address(struct net_device *net, void *p)
-{
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	struct sockaddr *addr = p;
-
-	if (netif_running(net))
-		return -EBUSY;
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
-
-	/* We use the 20 byte dev->data
-	 * for our 6 byte mac buffer
-	 * to avoid allocating memory that
-	 * is tricky to free later */
-	memcpy(data->mac_addr, addr->sa_data, ETH_ALEN);
-	asix_write_cmd_async(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
-			     data->mac_addr);
-
-	return 0;
-}
-
 /* We need to override some ethtool_ops so we require our
    own structure so we don't interfere with other usbnet
    devices that may be connected at the same time. */
-- 
1.7.0.4

From: liujunliang_ljl-9Onoh4P/yGk@public.gmane.org
Subject: [PATCH] USB2NET : SR9700 : One chip USB 1.1 USB2NET SR9700 Device Driver Support
Date: Sat, 24 Aug 2013 19:26:00 +0800
Message-ID: <1377343560-10524-1-git-send-email-liujunliang_ljl@163.com>
Cc: horms-/R6kz+dDXgpPR4JQBCEnsQ@public.gmane.org, joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org, romieu-W8zweXLXuWQS+FvcfC7Uqw@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	sunhecheng-i49A8sVr+H5BDgjK7y7TUQ@public.gmane.org, liujl <liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: liujl <liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>


Signed-off-by: liujl <liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>
---
 drivers/net/usb/Kconfig  |    8 +
 drivers/net/usb/Makefile |    1 +
 drivers/net/usb/sr9700.c |  551 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/sr9700.h |  172 ++++++++++++++
 4 files changed, 732 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/sr9700.c
 create mode 100644 drivers/net/usb/sr9700.h

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 287cc62..a94b196 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -272,6 +272,14 @@ config USB_NET_DM9601
 	  This option adds support for Davicom DM9601 based USB 1.1
 	  10/100 Ethernet adapters.
 
+config USB_NET_SR9700
+	tristate "CoreChip-sz SR9700 based USB 1.1 10/100 ethernet devices"
+	depends on USB_USBNET
+	select CRC32
+	help
+	  This option adds support for CoreChip-sz SR9700 based USB 1.1
+	  10/100 Ethernet adapters.
+
 config USB_NET_SMSC75XX
 	tristate "SMSC LAN75XX based USB 2.0 gigabit ethernet devices"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 9ab5c9d..bba87a2 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_USB_NET_AX88179_178A)      += ax88179_178a.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
+obj-$(CONFIG_USB_NET_SR9700)	+= sr9700.o
 obj-$(CONFIG_USB_NET_SMSC75XX)	+= smsc75xx.o
 obj-$(CONFIG_USB_NET_SMSC95XX)	+= smsc95xx.o
 obj-$(CONFIG_USB_NET_GL620A)	+= gl620a.o
diff --git a/drivers/net/usb/sr9700.c b/drivers/net/usb/sr9700.c
new file mode 100644
index 0000000..27c86ec
--- /dev/null
+++ b/drivers/net/usb/sr9700.c
@@ -0,0 +1,551 @@
+/*
+ * CoreChip-sz SR9700 one chip USB 1.1 Ethernet Devices
+ *
+ * Author : liujl <liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>
+ *
+ * Based on dm9601.c
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
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
+
+#include "sr9700.h"
+
+static int sr_read(struct usbnet *dev, u8 reg, u16 length, void *data)
+{
+	int err;
+
+	err = usbnet_read_cmd(dev, SR_RD_REGS, SR_REQ_RD_REG,
+					0, reg, data, length);
+	if ((err != length) && (err >= 0))
+		err = -EINVAL;
+	return err;
+}
+
+static int sr_write(struct usbnet *dev, u8 reg, u16 length, void *data)
+{
+	int err;
+
+	err = usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG,
+					0, reg, data, length);
+	if ((err >= 0) && (err < length))
+		err = -EINVAL;
+	return err;
+}
+
+static int sr_read_reg(struct usbnet *dev, u8 reg, u8 *value)
+{
+	return sr_read(dev, reg, 1, value);
+}
+
+static int sr_write_reg(struct usbnet *dev, u8 reg, u8 value)
+{
+	return usbnet_write_cmd(dev, SR_WR_REGS, SR_REQ_WR_REG,
+					value, reg, NULL, 0);
+}
+
+static void sr_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
+{
+	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
+					0, reg, data, length);
+}
+
+static void sr_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
+{
+	usbnet_write_cmd_async(dev, SR_WR_REGS, SR_REQ_WR_REG,
+					value, reg, NULL, 0);
+}
+
+static int wait_phy_eeprom_ready(struct usbnet *dev, int phy)
+{
+	int i, ret;
+
+	ret = 0;
+	for (i = 0; i < SR_SHARE_TIMEOUT; i++) {
+		u8 tmp = 0;
+
+		udelay(1);
+		ret = sr_read_reg(dev, EPCR, &tmp);
+		if (ret < 0)
+			goto out;
+
+		/* ready */
+		if ((tmp & EPCR_ERRE) == 0)
+			break;
+	}
+
+	if (i >= SR_SHARE_TIMEOUT) {
+		netdev_err(dev->net, "%s write timed out!\n",
+						phy ? "phy" : "eeprom");
+		ret = -EIO;
+		goto out;
+	}
+
+out:
+	return ret;
+}
+
+static int sr_share_read_word(struct usbnet *dev, int phy, u8 reg, __le16 *value)
+{
+	int ret;
+
+	mutex_lock(&dev->phy_mutex);
+
+	sr_write_reg(dev, EPAR, phy ? (reg | 0x40) : reg);
+	sr_write_reg(dev, EPCR, phy ? 0xc : 0x4);
+
+	ret = wait_phy_eeprom_ready(dev, phy);
+	if (ret < 0)
+		goto out;
+
+	sr_write_reg(dev, EPCR, 0x0);
+	ret = sr_read(dev, EPDR, 2, value);
+
+	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
+					phy, reg, *value, ret);
+
+out:
+	mutex_unlock(&dev->phy_mutex);
+	return ret;
+}
+
+static int sr_share_write_word(struct usbnet *dev, int phy, u8 reg, __le16 value)
+{
+	int ret;
+
+	mutex_lock(&dev->phy_mutex);
+
+	ret = sr_write(dev, EPDR, 2, &value);
+	if (ret < 0)
+		goto out;
+
+	sr_write_reg(dev, EPAR, phy ? (reg | 0x40) : reg);
+	sr_write_reg(dev, EPCR, phy ? 0x1a : 0x12);
+
+	ret = wait_phy_eeprom_ready(dev, phy);
+	if (ret < 0)
+		goto out;
+
+	sr_write_reg(dev, EPCR, 0x0);
+
+out:
+	mutex_unlock(&dev->phy_mutex);
+	return ret;
+}
+
+static int sr_read_eeprom_word(struct usbnet *dev, u8 offset, void *value)
+{
+	return sr_share_read_word(dev, 0, offset, value);
+}
+
+static int sr9700_get_eeprom_len(struct net_device *dev)
+{
+	return SR_EEPROM_LEN;
+}
+
+static int sr9700_get_eeprom(struct net_device *net, struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(net);
+	__le16 *ebuf = (__le16 *)data;
+	int ret = 0;
+	int i;
+
+	/* access is 16bit */
+	if ((eeprom->offset & 0x01) || (eeprom->len & 0x01))
+		return -EINVAL;
+
+	for (i = 0; i < eeprom->len / 2; i++)
+		ret = sr_read_eeprom_word(dev, eeprom->offset / 2 + i, &ebuf[i]);
+
+	return ret;
+}
+
+static int sr_mdio_read(struct net_device *netdev, int phy_id, int loc)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	__le16 res;
+	int rc = 0;
+
+	if (phy_id) {
+		netdev_dbg(dev->net, "Only internal phy supported\n");
+		return 0;
+	}
+
+	/* Access NSR_LINKST bit for link status instead of MII_BMSR */
+	if (loc == MII_BMSR) {
+		u8 value;
+
+		sr_read_reg(dev, NSR, &value);
+		if (value & NSR_LINKST)
+			rc = 1;
+	}
+	sr_share_read_word(dev, 1, loc, &res);
+	if (rc == 1)
+		res = le16_to_cpu(res) | BMSR_LSTATUS;
+	else
+		res = le16_to_cpu(res) & ~BMSR_LSTATUS;
+
+	netdev_dbg(dev->net, "sr_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+					phy_id, loc, res);
+
+	return res;
+}
+
+static void sr_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	__le16 res = cpu_to_le16(val);
+
+	if (phy_id) {
+		netdev_dbg(dev->net, "Only internal phy supported\n");
+		return;
+	}
+
+	netdev_dbg(dev->net, "sr_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+					phy_id, loc, val);
+
+	sr_share_write_word(dev, 1, loc, res);
+}
+
+static u32 sr9700_get_link(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 value = 0;
+	int rc = 0;
+
+	/* Get the Link Status directly */
+	sr_read_reg(dev, NSR, &value);
+	if (value & NSR_LINKST)
+		rc = 1;
+
+	return rc;
+}
+
+static int sr9700_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
+}
+
+static const struct ethtool_ops sr9700_ethtool_ops = {
+		.get_drvinfo	= usbnet_get_drvinfo,
+		.get_link		= sr9700_get_link,
+		.get_msglevel	= usbnet_get_msglevel,
+		.set_msglevel	= usbnet_set_msglevel,
+		.get_eeprom_len	= sr9700_get_eeprom_len,
+		.get_eeprom		= sr9700_get_eeprom,
+		.get_settings	= usbnet_get_settings,
+		.set_settings	= usbnet_set_settings,
+		.nway_reset		= usbnet_nway_reset,
+};
+
+static void sr9700_set_multicast(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	/* We use the 20 byte dev->data for our 8 byte filter buffer
+	 * to avoid allocating memory that is tricky to free later
+	 */
+	u8 *hashes = (u8 *)&dev->data;
+	/* rx_ctl setting : enable, disable_long, disable_crc */
+	u8 rx_ctl = RCR_RXEN | RCR_DIS_CRC | RCR_DIS_LONG;
+
+	memset(hashes, 0x00, SR_MCAST_SIZE);
+	/* broadcast address */
+	hashes[SR_MCAST_SIZE - 1] |= SR_MCAST_ADDR_FLAG;
+	if (net->flags & IFF_PROMISC) {
+		rx_ctl |= RCR_PRMSC;
+	} else if (net->flags & IFF_ALLMULTI ||
+			  netdev_mc_count(net) > SR_MCAST_MAX) {
+		rx_ctl |= RCR_RUNT;
+	} else if (!netdev_mc_empty(net)) {
+		struct netdev_hw_addr *ha;
+		netdev_for_each_mc_addr(ha, net) {
+			u32 crc = ether_crc(ETH_ALEN, ha->addr) >> 26;
+			hashes[crc >> 3] |= 1 << (crc & 0x7);
+		}
+	}
+
+	sr_write_async(dev, MAR, SR_MCAST_SIZE, hashes);
+	sr_write_reg_async(dev, RCR, rx_ctl);
+}
+
+static int sr9700_set_mac_address(struct net_device *net, void *p)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data)) {
+		netdev_err(net, "not setting invalid mac address %pM\n",
+						addr->sa_data);
+		return -EINVAL;
+	}
+
+	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
+	sr_write_async(dev, PAR, 6, dev->net->dev_addr);
+
+	return 0;
+}
+
+static const struct net_device_ops sr9700_netdev_ops = {
+		.ndo_open			= usbnet_open,
+		.ndo_stop			= usbnet_stop,
+		.ndo_start_xmit		= usbnet_start_xmit,
+		.ndo_tx_timeout		= usbnet_tx_timeout,
+		.ndo_change_mtu		= usbnet_change_mtu,
+		.ndo_validate_addr	= eth_validate_addr,
+		.ndo_do_ioctl		= sr9700_ioctl,
+		.ndo_set_rx_mode	= sr9700_set_multicast,
+		.ndo_set_mac_address	= sr9700_set_mac_address,
+};
+
+static int sr9700_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+
+	ret = usbnet_get_endpoints(dev, intf);
+	if (ret)
+		goto out;
+
+	dev->net->netdev_ops = &sr9700_netdev_ops;
+	dev->net->ethtool_ops = &sr9700_ethtool_ops;
+	dev->net->hard_header_len += SR_TX_OVERHEAD;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+	/* bulkin buffer is preferably not less than 3K */
+	dev->rx_urb_size = 3072;
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = sr_mdio_read;
+	dev->mii.mdio_write = sr_mdio_write;
+	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.reg_num_mask = 0x1f;
+
+	/* reset the sr9700 */
+	sr_write_reg(dev, NCR, 1);
+	udelay(20);
+
+	/* read MAC
+	 * After Chip Power on, the Chip will reload the MAC from
+	 * EEPROM automatically to PAR. In case there is no EEPROM externally,
+	 * a default MAC address is stored in PAR for making chip work properly.
+	 */
+	if (sr_read(dev, PAR, ETH_ALEN, dev->net->dev_addr) < 0) {
+		netdev_err(dev->net, "Error reading MAC address\n");
+		ret = -ENODEV;
+		goto out;
+	}
+
+	/* power up and reset phy */
+	sr_write_reg(dev, PRR, 1);
+	/* at least 10ms, here 20ms for safe */
+	mdelay(20);
+	sr_write_reg(dev, PRR, 0);
+	/* at least 1ms, here 2ms for reading right register */
+	udelay(2 * 1000);
+
+	/* receive broadcast packets */
+	sr9700_set_multicast(dev->net);
+
+	sr_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	sr_mdio_write(dev->net, dev->mii.phy_id,
+					MII_ADVERTISE, ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+	mii_nway_restart(&dev->mii);
+
+out:
+	return ret;
+}
+
+static int sr9700_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	struct sk_buff *sr_skb;
+	int len;
+
+	/* skb content (packets) format :
+	 *					p0			p1			p2	......	pm
+	 *			     /	  \
+	 *			/				\
+	 *		/							\
+	 *  /										\
+	 * p0b0 p0b1 p0b2 p0b3 ...... p0b(n-4) p0b(n-3)...p0bn
+	 *
+	 * p0 : packet 0
+	 * p0b0 : packet 0 byte 0
+	 *
+	 * b0: rx status
+	 * b1: packet length (incl crc) low
+	 * b2: packet length (incl crc) high
+	 * b3..n-4: packet data
+	 * bn-3..bn: ethernet packet crc
+	 */
+	if (unlikely(skb->len < SR_RX_OVERHEAD)) {
+		netdev_err(dev->net, "unexpected tiny rx frame\n");
+		return 0;
+	}
+
+	/* one skb may contains multiple packets */
+	while (skb->len > SR_RX_OVERHEAD) {
+		if (skb->data[0] != 0x40)
+			return 0;
+
+		/* ignore the CRC length */
+		len = (skb->data[1] | (skb->data[2] << 8)) - 4;
+
+		if (len > ETH_FRAME_LEN)
+			return 0;
+
+		/* the last packet of current skb */
+		if (skb->len == (len + SR_RX_OVERHEAD))	{
+			skb_pull(skb, 3);
+			skb->len = len;
+			skb->tail = skb->data + len;
+			skb->truesize = len + sizeof(struct sk_buff);
+			return 2;
+		}
+
+		/* skb_clone is used for address align */
+		sr_skb = skb_clone(skb, GFP_ATOMIC);
+		if (!sr_skb)
+			return 0;
+
+		sr_skb->len = len;
+		sr_skb->data = skb->data + 3;
+		sr_skb->tail = skb->data + len;
+		sr_skb->truesize = len + sizeof(struct sk_buff);
+		usbnet_skb_return(dev, sr_skb);
+
+		skb_pull(skb, len + SR_RX_OVERHEAD);
+	};
+
+	return 0;
+}
+
+static struct sk_buff *sr9700_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
+{
+	int len;
+
+	/* SR9700 can only send out one ethernet packet at once.
+	 *
+	 * b0 b1 b2 b3 ...... b(n-4) b(n-3)...bn
+	 *
+	 * b0: rx status
+	 * b1: packet length (incl crc) low
+	 * b2: packet length (incl crc) high
+	 * b3..n-4: packet data
+	 * bn-3..bn: ethernet packet crc
+	 */
+
+	len = skb->len;
+
+	if (skb_headroom(skb) < SR_TX_OVERHEAD) {
+		struct sk_buff *skb2;
+
+		skb2 = skb_copy_expand(skb, SR_TX_OVERHEAD, 0, flags);
+		dev_kfree_skb_any(skb);
+		skb = skb2;
+		if (!skb)
+			return NULL;
+	}
+
+	__skb_push(skb, SR_TX_OVERHEAD);
+
+	/* usbnet adds padding if length is a multiple of packet size
+	 * if so, adjust length value in header
+	 */
+	if ((skb->len % dev->maxpacket) == 0)
+		len++;
+
+	skb->data[0] = len;
+	skb->data[1] = len >> 8;
+
+	return skb;
+}
+
+static void sr9700_status(struct usbnet *dev, struct urb *urb)
+{
+	int link;
+	u8 *buf;
+
+	/* format:
+	   b0: net status
+	   b1: tx status 1
+	   b2: tx status 2
+	   b3: rx status
+	   b4: rx overflow
+	   b5: rx count
+	   b6: tx count
+	   b7: gpr
+	*/
+
+	if (urb->actual_length < 8)
+		return;
+
+	buf = urb->transfer_buffer;
+
+	link = !!(buf[0] & 0x40);
+	if (netif_carrier_ok(dev->net) != link) {
+		usbnet_link_change(dev, link, 1);
+		netdev_dbg(dev->net, "Link Status is: %d\n", link);
+	}
+}
+
+static int sr9700_link_reset(struct usbnet *dev)
+{
+	struct ethtool_cmd ecmd;
+
+	mii_check_media(&dev->mii, 1, 1);
+	mii_ethtool_gset(&dev->mii, &ecmd);
+
+	netdev_dbg(dev->net, "link_reset() speed: %d duplex: %d\n",
+					ecmd.speed, ecmd.duplex);
+
+	return 0;
+}
+
+static const struct driver_info sr9700_driver_info = {
+		.description	= "CoreChip SR9700 USB Ethernet",
+		.flags		= FLAG_ETHER,
+		.bind		= sr9700_bind,
+		.rx_fixup	= sr9700_rx_fixup,
+		.tx_fixup	= sr9700_tx_fixup,
+		.status		= sr9700_status,
+		.link_reset	= sr9700_link_reset,
+		.reset		= sr9700_link_reset,
+};
+
+static const struct usb_device_id products[] = {
+	{
+	 USB_DEVICE(0x0fe6, 0x9700),	/* SR9700 device */
+	 .driver_info = (unsigned long)&sr9700_driver_info,
+	 },
+	{},			/* END */
+};
+
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver sr9700_usb_driver = {
+		.name = "sr9700",
+		.id_table = products,
+		.probe = usbnet_probe,
+		.disconnect = usbnet_disconnect,
+		.suspend = usbnet_suspend,
+		.resume = usbnet_resume,
+		.disable_hub_initiated_lpm = 1,
+};
+
+module_usb_driver(sr9700_usb_driver);
+
+MODULE_AUTHOR("liujl <liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>");
+MODULE_DESCRIPTION("SR9700 one chip USB 1.1 USB to Ethernet device from http://www.corechip-sz.com/");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/usb/sr9700.h b/drivers/net/usb/sr9700.h
new file mode 100644
index 0000000..f1968ae
--- /dev/null
+++ b/drivers/net/usb/sr9700.h
@@ -0,0 +1,172 @@
+/*
+ * CoreChip-sz SR9700 one chip USB 1.1 Ethernet Devices
+ *
+ * Author : liujl <liujunliang_ljl-9Onoh4P/yGk@public.gmane.org>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ */
+
+#ifndef _SR9700_H
+#define	_SR9700_H
+
+/* sr9700 spec. register table on Linux platform */
+
+/* Network Control Reg */
+#define	NCR			0x00
+#define		NCR_RST			(1 << 0)
+#define		NCR_LBK			(3 << 1)
+#define		NCR_FDX			(1 << 3)
+#define		NCR_WAKEEN		(1 << 6)
+/* Network Status Reg */
+#define	NSR			0x01
+#define		NSR_RXRDY		(1 << 0)
+#define		NSR_RXOV		(1 << 1)
+#define		NSR_TX1END		(1 << 2)
+#define		NSR_TX2END		(1 << 3)
+#define		NSR_TXFULL		(1 << 4)
+#define		NSR_WAKEST		(1 << 5)
+#define		NSR_LINKST		(1 << 6)
+#define		NSR_SPEED		(1 << 7)
+/* Tx Control Reg */
+#define	TCR			0x02
+#define		TCR_CRC_DIS		(1 << 1)
+#define		TCR_PAD_DIS		(1 << 2)
+#define		TCR_LC_CARE		(1 << 3)
+#define		TCR_CRS_CARE	(1 << 4)
+#define		TCR_EXCECM		(1 << 5)
+#define		TCR_LF_EN		(1 << 6)
+/* Tx Status Reg for Packet Index 1 */
+#define	TSR1		0x03
+#define		TSR1_EC			(1 << 2)
+#define		TSR1_COL		(1 << 3)
+#define		TSR1_LC			(1 << 4)
+#define		TSR1_NC			(1 << 5)
+#define		TSR1_LOC		(1 << 6)
+#define		TSR1_TLF		(1 << 7)
+/* Tx Status Reg for Packet Index 2 */
+#define	TSR2		0x04
+#define		TSR2_EC			(1 << 2)
+#define		TSR2_COL		(1 << 3)
+#define		TSR2_LC			(1 << 4)
+#define		TSR2_NC			(1 << 5)
+#define		TSR2_LOC		(1 << 6)
+#define		TSR2_TLF		(1 << 7)
+/* Rx Control Reg*/
+#define	RCR			0x05
+#define		RCR_RXEN		(1 << 0)
+#define		RCR_PRMSC		(1 << 1)
+#define		RCR_RUNT		(1 << 2)
+#define		RCR_ALL			(1 << 3)
+#define		RCR_DIS_CRC		(1 << 4)
+#define		RCR_DIS_LONG	(1 << 5)
+/* Rx Status Reg */
+#define	RSR			0x06
+#define		RSR_AE			(1 << 2)
+#define		RSR_MF			(1 << 6)
+#define		RSR_RF			(1 << 7)
+/* Rx Overflow Counter Reg */
+#define	ROCR		0x07
+#define		ROCR_ROC		(0x7F << 0)
+#define		ROCR_RXFU		(1 << 7)
+/* Back Pressure Threshold Reg */
+#define	BPTR		0x08
+#define		BPTR_JPT		(0x0F << 0)
+#define		BPTR_BPHW		(0x0F << 4)
+/* Flow Control Threshold Reg */
+#define	FCTR		0x09
+#define		FCTR_LWOT		(0x0F << 0)
+#define		FCTR_HWOT		(0x0F << 4)
+/* rx/tx Flow Control Reg */
+#define	FCR			0x0A
+#define		FCR_FLCE		(1 << 0)
+#define		FCR_BKPA		(1 << 4)
+#define		FCR_TXPEN		(1 << 5)
+#define		FCR_TXPF		(1 << 6)
+#define		FCR_TXP0		(1 << 7)
+/* Eeprom & Phy Control Reg */
+#define	EPCR		0x0B
+#define		EPCR_ERRE		(1 << 0)
+#define		EPCR_ERPRW		(1 << 1)
+#define		EPCR_ERPRR		(1 << 2)
+#define		EPCR_EPOS		(1 << 3)
+#define		EPCR_WEP		(1 << 4)
+/* Eeprom & Phy Address Reg */
+#define	EPAR		0x0C
+#define		EPAR_EROA		(0x3F << 0)
+#define		EPAR_PHY_ADR	(0x03 << 6)
+/* Eeprom &	Phy Data Reg */
+#define	EPDR		0x0D	/* 0x0D ~ 0x0E for Data Reg Low & High */
+/* Wakeup Control Reg */
+#define	WCR			0x0F
+#define		WCR_MAGICST		(1 << 0)
+#define		WCR_LINKST		(1 << 2)
+#define		WCR_MAGICEN		(1 << 3)
+#define		WCR_LINKEN		(1 << 5)
+/* Physical Address Reg */
+#define	PAR			0x10	/* 0x10 ~ 0x15 6 bytes for PAR */
+/* Multicast Address Reg */
+#define	MAR			0x16	/* 0x16 ~ 0x1D 8 bytes for MAR */
+/* 0x1e unused */
+/* Phy Reset Reg */
+#define	PRR			0x1F
+#define		PRR_PHY_RST		(1 << 0)
+/* Tx sdram Write Pointer Address Low */
+#define	TWPAL		0x20
+/* Tx sdram Write Pointer Address High */
+#define	TWPAH		0x21
+/* Tx sdram Read Pointer Address Low */
+#define	TRPAL		0x22
+/* Tx sdram Read Pointer Address High */
+#define	TRPAH		0x23
+/* Rx sdram Write Pointer Address Low */
+#define	RWPAL		0x24
+/* Rx sdram Write Pointer Address High */
+#define	RWPAH		0x25
+/* Rx sdram Read Pointer Address Low */
+#define	RRPAL		0x26
+/* Rx sdram Read Pointer Address High */
+#define	RRPAH		0x27
+/* Vendor ID register */
+#define	VID			0x28	/* 0x28 ~ 0x29 2 bytes for VID */
+/* Product ID register */
+#define	PID			0x2A	/* 0x2A ~ 0x2B 2 bytes for PID */
+/* CHIP Revision register */
+#define	CHIPR		0x2C
+/* 0x2D --> 0xEF unused */
+/* USB Device Address */
+#define	USBDA		0xF0
+#define		USBDA_USBFA		(0x7F << 0)
+/* RX packet Counter Reg */
+#define	RXC			0xF1
+/* Tx packet Counter & USB Status Reg */
+#define	TXC_USBS	0xF2
+#define		TXC_USBS_TXC0		(1 << 0)
+#define		TXC_USBS_TXC1		(1 << 1)
+#define		TXC_USBS_TXC2		(1 << 2)
+#define		TXC_USBS_EP1RDY		(1 << 5)
+#define		TXC_USBS_SUSFLAG	(1 << 6)
+#define		TXC_USBS_RXFAULT	(1 << 7)
+/* USB Control register */
+#define	USBC		0xF4
+#define		USBC_EP3NAK		(1 << 4)
+#define		USBC_EP3ACK		(1 << 5)
+
+/* Register access commands and flags */
+#define	SR_RD_REGS		0x00
+#define	SR_WR_REGS		0x01
+#define	SR_WR_REG		0x03
+#define	SR_REQ_RD_REG	(USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE)
+#define	SR_REQ_WR_REG	(USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE)
+
+/* parameters */
+#define	SR_SHARE_TIMEOUT	1000
+#define	SR_EEPROM_LEN		256
+#define	SR_MCAST_SIZE		8
+#define	SR_MCAST_ADDR_FLAG	0x80
+#define	SR_MCAST_MAX		64
+#define	SR_TX_OVERHEAD		2	/* 2bytes header */
+#define	SR_RX_OVERHEAD		7	/* 3bytes header + 4crc tail */
+
+#endif	/* _SR9700_H */
-- 
1.7.0.4


--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

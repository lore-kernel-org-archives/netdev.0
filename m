From: liujunliang_ljl@163.com
Subject: [PATCH] USB2NET : SR9800 : One chip USB2.0 USB2NET SR9800 Device Driver Support
Date: Tue, 28 Jan 2014 16:36:40 +0800
Message-ID: <1390898200-9925-1-git-send-email-liujunliang_ljl@163.com>
Cc: horms@verge.net.au, joe@perches.com, romieu@fr.zoreil.com,
	gregkh@linuxfoundation.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	sunhecheng@vip.126.com, liujunliang_ljl@163.com
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Liu Junliang <liujunliang_ljl@163.com>


Signed-off-by: Liu Junliang <liujunliang_ljl@163.com>
---
 drivers/net/usb/Kconfig  |   16 +
 drivers/net/usb/Makefile |    1 +
 drivers/net/usb/sr9800.c |  874 ++++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/sr9800.h |  202 +++++++++++
 4 files changed, 1093 insertions(+)
 create mode 100644 drivers/net/usb/sr9800.c
 create mode 100644 drivers/net/usb/sr9800.h

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 47b0f73..2551bf6 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -291,6 +291,22 @@ config USB_NET_SR9700
 	  This option adds support for CoreChip-sz SR9700 based USB 1.1
 	  10/100 Ethernet adapters.
 
+config USB_NET_SR9800
+	tristate "CoreChip-sz SR9800 based USB 2.0 10/100 ethernet devices"
+	depends on USB_USBNET
+	select CRC32
+	default y
+	---help---
+	  Say Y if you want to use one of the following 100Mbps USB Ethernet
+	  device based on the CoreChip-sz SR9800 chip.
+
+	  This driver makes the adapter appear as a normal Ethernet interface,
+	  typically on eth0, if it is the only ethernet device, or perhaps on
+	  eth1, if you have a PCI or ISA ethernet card installed.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called sr9800.
+
 config USB_NET_SMSC75XX
 	tristate "SMSC LAN75XX based USB 2.0 gigabit ethernet devices"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index b17b5e8..433f0a0 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -15,6 +15,7 @@ obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o r815x.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
 obj-$(CONFIG_USB_NET_SR9700)	+= sr9700.o
+obj-$(CONFIG_USB_NET_SR9800)	+= sr9800.o
 obj-$(CONFIG_USB_NET_SMSC75XX)	+= smsc75xx.o
 obj-$(CONFIG_USB_NET_SMSC95XX)	+= smsc95xx.o
 obj-$(CONFIG_USB_NET_GL620A)	+= gl620a.o
diff --git a/drivers/net/usb/sr9800.c b/drivers/net/usb/sr9800.c
new file mode 100644
index 0000000..ab15973
--- /dev/null
+++ b/drivers/net/usb/sr9800.c
@@ -0,0 +1,874 @@
+/* CoreChip-sz SR9800 one chip USB 2.0 Ethernet Devices
+ *
+ * Author : Liu Junliang <liujunliang_ljl@163.com>
+ *
+ * Based on asix_common.c, asix_devices.c
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.*
+ */
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
+#include "sr9800.h"
+
+static int sr_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+			    u16 size, void *data)
+{
+	int err;
+
+	err = usbnet_read_cmd(dev, cmd, SR_REQ_RD_REG, value, index,
+			      data, size);
+	if ((err != size) && (err >= 0))
+		err = -EINVAL;
+
+	return err;
+}
+
+static int sr_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+			     u16 size, void *data)
+{
+	int err;
+
+	err = usbnet_write_cmd(dev, cmd, SR_REQ_WR_REG, value, index,
+			      data, size);
+	if ((err != size) && (err >= 0))
+		err = -EINVAL;
+
+	return err;
+}
+
+static void
+sr_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+		   u16 size, void *data)
+{
+	usbnet_write_cmd_async(dev, cmd, SR_REQ_WR_REG, value, index, data,
+			       size);
+}
+
+static int sr_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	int offset = 0;
+
+	while (offset + sizeof(u32) < skb->len) {
+		struct sk_buff *sr_skb;
+		u16 size;
+		u32 header = get_unaligned_le32(skb->data + offset);
+
+		offset += sizeof(u32);
+		/* get the packet length */
+		size = (u16) (header & 0x7ff);
+		if (size != ((~header >> 16) & 0x07ff)) {
+			netdev_err(dev->net,
+				   "sr_rx_fixup() Bad Header Length\n");
+			return 0;
+		}
+
+		if ((size > dev->net->mtu + ETH_HLEN + VLAN_HLEN) ||
+		    (size + offset > skb->len)) {
+			netdev_err(dev->net,
+				   "sr_rx_fixup() Bad RX Length %d\n", size);
+			return 0;
+		}
+		sr_skb = netdev_alloc_skb_ip_align(dev->net, size);
+		if (!sr_skb)
+			return 0;
+
+		skb_put(sr_skb, size);
+		memcpy(sr_skb->data, skb->data + offset, size);
+		usbnet_skb_return(dev, sr_skb);
+
+		offset += (size + 1) & 0xfffe;
+	}
+
+	if (skb->len != offset) {
+		netdev_err(dev->net, "sr_rx_fixup() Bad SKB Length %d\n",
+			   skb->len);
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct sk_buff *sr_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
+					gfp_t flags)
+{
+	int headroom = skb_headroom(skb);
+	int tailroom = skb_tailroom(skb);
+	u32 padbytes = 0xffff0000;
+	u32 packet_len;
+	int padlen;
+
+	padlen = ((skb->len + 4) % (dev->maxpacket - 1)) ? 0 : 4;
+
+	if ((!skb_cloned(skb)) && ((headroom + tailroom) >= (4 + padlen))) {
+		if ((headroom < 4) || (tailroom < padlen)) {
+			skb->data = memmove(skb->head + 4, skb->data,
+					    skb->len);
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
+
+	return skb;
+}
+
+static void sr_status(struct usbnet *dev, struct urb *urb)
+{
+	struct sr9800_int_data *event;
+	int link;
+
+	if (urb->actual_length < 8)
+		return;
+
+	event = urb->transfer_buffer;
+	link = event->link & 0x01;
+	if (netif_carrier_ok(dev->net) != link) {
+		usbnet_link_change(dev, link, 1);
+		netdev_dbg(dev->net, "Link Status is: %d\n", link);
+	}
+
+	return;
+}
+
+static inline int sr_set_sw_mii(struct usbnet *dev)
+{
+	int ret;
+
+	ret = sr_write_cmd(dev, SR_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to enable software MII access\n");
+	return ret;
+}
+
+static inline int sr_set_hw_mii(struct usbnet *dev)
+{
+	int ret;
+
+	ret = sr_write_cmd(dev, SR_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to enable hardware MII access\n");
+	return ret;
+}
+
+static inline int sr_get_phy_addr(struct usbnet *dev)
+{
+	u8 buf[2];
+	int ret;
+
+	ret = sr_read_cmd(dev, SR_CMD_READ_PHY_ID, 0, 0, 2, buf);
+	if (ret < 0) {
+		netdev_err(dev->net, "Error reading PHYID register:%02x\n",
+			   ret);
+		goto out;
+	}
+	netdev_dbg(dev->net, "sr_get_phy_addr() returning 0x%04x\n",
+		   *((__le16 *)buf));
+
+	ret = buf[1];
+
+out:
+	return ret;
+}
+
+static int sr_sw_reset(struct usbnet *dev, u8 flags)
+{
+	int ret;
+
+	ret = sr_write_cmd(dev, SR_CMD_SW_RESET, flags, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to send software reset:%02x\n",
+			   ret);
+
+	return ret;
+}
+
+static u16 sr_read_rx_ctl(struct usbnet *dev)
+{
+	__le16 v;
+	int ret;
+
+	ret = sr_read_cmd(dev, SR_CMD_READ_RX_CTL, 0, 0, 2, &v);
+	if (ret < 0) {
+		netdev_err(dev->net, "Error reading RX_CTL register:%02x\n",
+			   ret);
+		goto out;
+	}
+
+	ret = le16_to_cpu(v);
+out:
+	return ret;
+}
+
+static int sr_write_rx_ctl(struct usbnet *dev, u16 mode)
+{
+	int ret;
+
+	netdev_dbg(dev->net, "sr_write_rx_ctl() - mode = 0x%04x\n", mode);
+	ret = sr_write_cmd(dev, SR_CMD_WRITE_RX_CTL, mode, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net,
+			   "Failed to write RX_CTL mode to 0x%04x:%02x\n",
+			   mode, ret);
+
+	return ret;
+}
+
+static u16 sr_read_medium_status(struct usbnet *dev)
+{
+	__le16 v;
+	int ret;
+
+	ret = sr_read_cmd(dev, SR_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
+	if (ret < 0) {
+		netdev_err(dev->net,
+			   "Error reading Medium Status register:%02x\n", ret);
+		return ret;	/* TODO: callers not checking for error ret */
+	}
+
+	return le16_to_cpu(v);
+}
+
+static int sr_write_medium_mode(struct usbnet *dev, u16 mode)
+{
+	int ret;
+
+	netdev_dbg(dev->net, "sr_write_medium_mode() - mode = 0x%04x\n", mode);
+	ret = sr_write_cmd(dev, SR_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net,
+			   "Failed to write Medium Mode mode to 0x%04x:%02x\n",
+			   mode, ret);
+	return ret;
+}
+
+static int sr_write_gpio(struct usbnet *dev, u16 value, int sleep)
+{
+	int ret;
+
+	netdev_dbg(dev->net, "sr_write_gpio() - value = 0x%04x\n", value);
+	ret = sr_write_cmd(dev, SR_CMD_WRITE_GPIOS, value, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "Failed to write GPIO value 0x%04x:%02x\n",
+			   value, ret);
+	if (sleep)
+		msleep(sleep);
+
+	return ret;
+}
+
+/* SR9800 have a 16-bit RX_CTL value */
+static void sr_set_multicast(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct sr_data *data = (struct sr_data *)&dev->data;
+	u16 rx_ctl = SR_DEFAULT_RX_CTL;
+
+	if (net->flags & IFF_PROMISC) {
+		rx_ctl |= SR_RX_CTL_PRO;
+	} else if (net->flags & IFF_ALLMULTI ||
+		   netdev_mc_count(net) > SR_MAX_MCAST) {
+		rx_ctl |= SR_RX_CTL_AMALL;
+	} else if (netdev_mc_empty(net)) {
+		/* just broadcast and directed */
+	} else {
+		/* We use the 20 byte dev->data
+		 * for our 8 byte filter buffer
+		 * to avoid allocating memory that
+		 * is tricky to free later
+		 */
+		struct netdev_hw_addr *ha;
+		u32 crc_bits;
+
+		memset(data->multi_filter, 0, SR_MCAST_FILTER_SIZE);
+
+		/* Build the multicast hash filter. */
+		netdev_for_each_mc_addr(ha, net) {
+			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
+			data->multi_filter[crc_bits >> 3] |=
+			    1 << (crc_bits & 7);
+		}
+
+		sr_write_cmd_async(dev, SR_CMD_WRITE_MULTI_FILTER, 0, 0,
+				   SR_MCAST_FILTER_SIZE, data->multi_filter);
+
+		rx_ctl |= SR_RX_CTL_AM;
+	}
+
+	sr_write_cmd_async(dev, SR_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+}
+
+static int sr_mdio_read(struct net_device *net, int phy_id, int loc)
+{
+	struct usbnet *dev = netdev_priv(net);
+	__le16 res;
+
+	mutex_lock(&dev->phy_mutex);
+	sr_set_sw_mii(dev);
+	sr_read_cmd(dev, SR_CMD_READ_MII_REG, phy_id, (__u16)loc, 2, &res);
+	sr_set_hw_mii(dev);
+	mutex_unlock(&dev->phy_mutex);
+
+	netdev_dbg(dev->net,
+		   "sr_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+		   phy_id, loc, le16_to_cpu(res));
+
+	return le16_to_cpu(res);
+}
+
+static void
+sr_mdio_write(struct net_device *net, int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(net);
+	__le16 res = cpu_to_le16(val);
+
+	netdev_dbg(dev->net,
+		   "sr_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+		   phy_id, loc, val);
+	mutex_lock(&dev->phy_mutex);
+	sr_set_sw_mii(dev);
+	sr_write_cmd(dev, SR_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
+	sr_set_hw_mii(dev);
+	mutex_unlock(&dev->phy_mutex);
+}
+
+/* Get the PHY Identifier from the PHYSID1 & PHYSID2 MII registers */
+static u32 sr_get_phyid(struct usbnet *dev)
+{
+	int phy_reg;
+	u32 phy_id;
+	int i;
+
+	/* Poll for the rare case the FW or phy isn't ready yet.  */
+	for (i = 0; i < 100; i++) {
+		phy_reg = sr_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
+		if (phy_reg != 0 && phy_reg != 0xFFFF)
+			break;
+		mdelay(1);
+	}
+
+	if (phy_reg <= 0 || phy_reg == 0xFFFF)
+		return 0;
+
+	phy_id = (phy_reg & 0xffff) << 16;
+
+	phy_reg = sr_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID2);
+	if (phy_reg < 0)
+		return 0;
+
+	phy_id |= (phy_reg & 0xffff);
+
+	return phy_id;
+}
+
+static void
+sr_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 opt;
+
+	if (sr_read_cmd(dev, SR_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
+		wolinfo->supported = 0;
+		wolinfo->wolopts = 0;
+		return;
+	}
+	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
+	wolinfo->wolopts = 0;
+	if (opt & SR_MONITOR_LINK)
+		wolinfo->wolopts |= WAKE_PHY;
+	if (opt & SR_MONITOR_MAGIC)
+		wolinfo->wolopts |= WAKE_MAGIC;
+}
+
+static int
+sr_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 opt = 0;
+
+	if (wolinfo->wolopts & WAKE_PHY)
+		opt |= SR_MONITOR_LINK;
+	if (wolinfo->wolopts & WAKE_MAGIC)
+		opt |= SR_MONITOR_MAGIC;
+
+	if (sr_write_cmd(dev, SR_CMD_WRITE_MONITOR_MODE,
+			 opt, 0, 0, NULL) < 0)
+		return -EINVAL;
+
+	return 0;
+}
+
+static int sr_get_eeprom_len(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct sr_data *data = (struct sr_data *)&dev->data;
+
+	return data->eeprom_len;
+}
+
+static int sr_get_eeprom(struct net_device *net,
+			      struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(net);
+	__le16 *ebuf = (__le16 *)data;
+	int ret;
+	int i;
+
+	/* Crude hack to ensure that we don't overwrite memory
+	 * if an odd length is supplied
+	 */
+	if (eeprom->len % 2)
+		return -EINVAL;
+
+	eeprom->magic = SR_EEPROM_MAGIC;
+
+	/* sr9800 returns 2 bytes from eeprom on read */
+	for (i = 0; i < eeprom->len / 2; i++) {
+		ret = sr_read_cmd(dev, SR_CMD_READ_EEPROM, eeprom->offset + i,
+				  0, 2, &ebuf[i]);
+		if (ret < 0)
+			return -EINVAL;
+	}
+	return 0;
+}
+
+static void sr_get_drvinfo(struct net_device *net,
+				 struct ethtool_drvinfo *info)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct sr_data *data = (struct sr_data *)&dev->data;
+
+	/* Inherit standard device info */
+	usbnet_get_drvinfo(net, info);
+	strncpy(info->driver, DRIVER_NAME, sizeof(info->driver));
+	strncpy(info->version, DRIVER_VERSION, sizeof(info->version));
+	info->eedump_len = data->eeprom_len;
+}
+
+static u32 sr_get_link(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	return mii_link_ok(&dev->mii);
+}
+
+static int sr_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
+}
+
+static int sr_set_mac_address(struct net_device *net, void *p)
+{
+	struct usbnet *dev = netdev_priv(net);
+	struct sr_data *data = (struct sr_data *)&dev->data;
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
+	 * is tricky to free later
+	 */
+	memcpy(data->mac_addr, addr->sa_data, ETH_ALEN);
+	sr_write_cmd_async(dev, SR_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
+			   data->mac_addr);
+
+	return 0;
+}
+
+static const struct ethtool_ops sr9800_ethtool_ops = {
+	.get_drvinfo	= sr_get_drvinfo,
+	.get_link	= sr_get_link,
+	.get_msglevel	= usbnet_get_msglevel,
+	.set_msglevel	= usbnet_set_msglevel,
+	.get_wol	= sr_get_wol,
+	.set_wol	= sr_set_wol,
+	.get_eeprom_len	= sr_get_eeprom_len,
+	.get_eeprom	= sr_get_eeprom,
+	.get_settings	= usbnet_get_settings,
+	.set_settings	= usbnet_set_settings,
+	.nway_reset	= usbnet_nway_reset,
+};
+
+static int sr9800_link_reset(struct usbnet *dev)
+{
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+	u16 mode;
+
+	mii_check_media(&dev->mii, 1, 1);
+	mii_ethtool_gset(&dev->mii, &ecmd);
+	mode = SR9800_MEDIUM_DEFAULT;
+
+	if (ethtool_cmd_speed(&ecmd) != SPEED_100)
+		mode &= ~SR_MEDIUM_PS;
+
+	if (ecmd.duplex != DUPLEX_FULL)
+		mode &= ~SR_MEDIUM_FD;
+
+	netdev_dbg(dev->net, "link_reset speed: %u duplex: %d mode: 0x%04x\n",
+		   ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
+
+	sr_write_medium_mode(dev, mode);
+
+	return 0;
+}
+
+
+static inline int sr9800_set_default_mode(struct usbnet *dev)
+{
+	u16 rx_ctl;
+	int ret;
+
+	sr_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	sr_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+		      ADVERTISE_ALL | ADVERTISE_CSMA);
+	mii_nway_restart(&dev->mii);
+
+	ret = sr_write_medium_mode(dev, SR9800_MEDIUM_DEFAULT);
+	if (ret < 0)
+		goto out;
+
+	ret = sr_write_cmd(dev, SR_CMD_WRITE_IPG012,
+				SR9800_IPG0_DEFAULT | SR9800_IPG1_DEFAULT,
+				SR9800_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_dbg(dev->net, "Write IPG,IPG1,IPG2 failed: %d", ret);
+		goto out;
+	}
+
+	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
+	ret = sr_write_rx_ctl(dev, SR_DEFAULT_RX_CTL);
+	if (ret < 0)
+		goto out;
+
+	rx_ctl = sr_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x after all initializations",
+		   rx_ctl);
+
+	rx_ctl = sr_read_medium_status(dev);
+	netdev_dbg(dev->net, "Medium Status : 0x%04x after all initializations",
+		   rx_ctl);
+
+	return 0;
+out:
+	return ret;
+}
+
+static int sr9800_reset(struct usbnet *dev)
+{
+	struct sr_data *data = (struct sr_data *)&dev->data;
+	int ret, embd_phy;
+	u16 rx_ctl;
+
+	ret = sr_write_gpio(dev,
+			SR_GPIO_RSE | SR_GPIO_GPO_2 | SR_GPIO_GPO2EN, 5);
+	if (ret < 0)
+		goto out;
+
+	embd_phy = ((sr_get_phy_addr(dev) & 0x1f) == 0x10 ? 1 : 0);
+
+	ret = sr_write_cmd(dev, SR_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_dbg(dev->net, "Select PHY #1 failed: %d", ret);
+		goto out;
+	}
+
+	ret = sr_sw_reset(dev, SR_SWRESET_IPPD | SR_SWRESET_PRL);
+	if (ret < 0)
+		goto out;
+
+	msleep(150);
+
+	ret = sr_sw_reset(dev, SR_SWRESET_CLEAR);
+	if (ret < 0)
+		goto out;
+
+	msleep(150);
+
+	if (embd_phy) {
+		ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
+		if (ret < 0)
+			goto out;
+	} else {
+		ret = sr_sw_reset(dev, SR_SWRESET_PRTE);
+		if (ret < 0)
+			goto out;
+	}
+
+	msleep(150);
+	rx_ctl = sr_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset", rx_ctl);
+	ret = sr_write_rx_ctl(dev, 0x0000);
+	if (ret < 0)
+		goto out;
+
+	rx_ctl = sr_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
+
+	ret = sr_sw_reset(dev, SR_SWRESET_PRL);
+	if (ret < 0)
+		goto out;
+
+	msleep(150);
+
+	ret = sr_sw_reset(dev, SR_SWRESET_IPRL | SR_SWRESET_PRL);
+	if (ret < 0)
+		goto out;
+
+	msleep(150);
+
+	ret = sr9800_set_default_mode(dev);
+	if (ret < 0)
+		goto out;
+
+	/* Rewrite MAC address */
+	memcpy(data->mac_addr, dev->net->dev_addr, ETH_ALEN);
+	ret = sr_write_cmd(dev, SR_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
+							data->mac_addr);
+	if (ret < 0)
+		goto out;
+
+	return 0;
+
+out:
+	return ret;
+}
+
+static const struct net_device_ops sr9800_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_set_mac_address	= sr_set_mac_address,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= sr_ioctl,
+	.ndo_set_rx_mode        = sr_set_multicast,
+};
+
+static int sr9800_phy_powerup(struct usbnet *dev)
+{
+	int ret;
+
+	/* set the embedded Ethernet PHY in power-down state */
+	ret = sr_sw_reset(dev, SR_SWRESET_IPPD | SR_SWRESET_IPRL);
+	if (ret < 0) {
+		netdev_err(dev->net, "Failed to power down PHY : %d", ret);
+		return ret;
+	}
+	msleep(20);
+
+	/* set the embedded Ethernet PHY in power-up state */
+	ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
+	if (ret < 0) {
+		netdev_err(dev->net, "Failed to reset PHY: %d", ret);
+		return ret;
+	}
+	msleep(600);
+
+	/* set the embedded Ethernet PHY in reset state */
+	ret = sr_sw_reset(dev, SR_SWRESET_CLEAR);
+	if (ret < 0) {
+		netdev_err(dev->net, "Failed to power up PHY: %d", ret);
+		return ret;
+	}
+	msleep(20);
+
+	/* set the embedded Ethernet PHY in power-up state */
+	ret = sr_sw_reset(dev, SR_SWRESET_IPRL);
+	if (ret < 0) {
+		netdev_err(dev->net, "Failed to reset PHY: %d", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int sr9800_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct sr_data *data = (struct sr_data *)&dev->data;
+	u16 led01_mux, led23_mux;
+	int ret, embd_phy;
+	u32 phyid;
+	u16 rx_ctl;
+
+	data->eeprom_len = SR9800_EEPROM_LEN;
+
+	usbnet_get_endpoints(dev, intf);
+
+	/* LED Setting Rule :
+	 * AABB:CCDD
+	 * AA : MFA0(LED0)
+	 * BB : MFA1(LED1)
+	 * CC : MFA2(LED2), Reserved for SR9800
+	 * DD : MFA3(LED3), Reserved for SR9800
+	 */
+	led01_mux = (SR_LED_MUX_LINK_ACTIVE << 8) | SR_LED_MUX_LINK;
+	led23_mux = (SR_LED_MUX_LINK_ACTIVE << 8) | SR_LED_MUX_TX_ACTIVE;
+	ret = sr_write_cmd(dev, SR_CMD_LED_MUX, led01_mux, led23_mux, 0, NULL);
+	if (ret < 0) {
+			netdev_err(dev->net, "set LINK LED failed : %d", ret);
+			goto out;
+	}
+
+	/* Get the MAC address */
+	ret = sr_read_cmd(dev, SR_CMD_READ_NODE_ID, 0, 0, ETH_ALEN,
+			  dev->net->dev_addr);
+	if (ret < 0) {
+		netdev_dbg(dev->net, "Failed to read MAC address: %d", ret);
+		return ret;
+	}
+	netdev_dbg(dev->net, "mac addr : 0x%x:0x%x:0x%x:0x%x:0x%x:0x%x\n",
+		   dev->net->dev_addr[0], dev->net->dev_addr[1],
+		   dev->net->dev_addr[2], dev->net->dev_addr[3],
+		   dev->net->dev_addr[4], dev->net->dev_addr[5]);
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = sr_mdio_read;
+	dev->mii.mdio_write = sr_mdio_write;
+	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.phy_id = sr_get_phy_addr(dev);
+
+	dev->net->netdev_ops = &sr9800_netdev_ops;
+	dev->net->ethtool_ops = &sr9800_ethtool_ops;
+
+	embd_phy = ((dev->mii.phy_id & 0x1f) == 0x10 ? 1 : 0);
+	/* Reset the PHY to normal operation mode */
+	ret = sr_write_cmd(dev, SR_CMD_SW_PHY_SELECT, embd_phy, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_dbg(dev->net, "Select PHY #1 failed: %d", ret);
+		return ret;
+	}
+
+	/* Init PHY routine */
+	ret = sr9800_phy_powerup(dev);
+	if (ret < 0)
+		goto out;
+
+	rx_ctl = sr_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x after software reset", rx_ctl);
+	ret = sr_write_rx_ctl(dev, 0x0000);
+	if (ret < 0)
+		goto out;
+
+	rx_ctl = sr_read_rx_ctl(dev);
+	netdev_dbg(dev->net, "RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
+
+	/* Read PHYID register *AFTER* the PHY was reset properly */
+	phyid = sr_get_phyid(dev);
+	netdev_dbg(dev->net, "PHYID=0x%08x", phyid);
+
+	/* medium mode setting */
+	ret = sr9800_set_default_mode(dev);
+	if (ret < 0)
+		goto out;
+
+	if (dev->udev->speed == USB_SPEED_HIGH) {
+		ret = sr_write_cmd(dev, SR_CMD_BULKIN_SIZE,
+			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_4K].byte_cnt,
+			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_4K].threshold,
+			0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "Reset RX_CTL failed: %d", ret);
+			goto out;
+		}
+		dev->rx_urb_size =
+			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_4K].size;
+	} else {
+		ret = sr_write_cmd(dev, SR_CMD_BULKIN_SIZE,
+			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_2K].byte_cnt,
+			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_2K].threshold,
+			0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "Reset RX_CTL failed: %d", ret);
+			goto out;
+		}
+		dev->rx_urb_size =
+			SR9800_BULKIN_SIZE[SR9800_MAX_BULKIN_2K].size;
+	}
+	netdev_dbg(dev->net, "sr9800_bind : setting rx_urb_size with : %ld\n",
+		   dev->rx_urb_size);
+	return 0;
+
+out:
+	return ret;
+}
+
+static const struct driver_info sr9800_driver_info = {
+	.description	= "CoreChip SR9800 USB 2.0 Ethernet",
+	.bind		= sr9800_bind,
+	.status		= sr_status,
+	.link_reset	= sr9800_link_reset,
+	.reset		= sr9800_reset,
+	.flags		= DRIVER_FLAG,
+	.rx_fixup	= sr_rx_fixup,
+	.tx_fixup	= sr_tx_fixup,
+};
+
+static const struct usb_device_id	products[] = {
+	{
+		USB_DEVICE(0x0fe6, 0x9800),	/* SR9800 Device  */
+		.driver_info = (unsigned long) &sr9800_driver_info,
+	},
+	{},		/* END */
+};
+
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver sr_driver = {
+	.name		= DRIVER_NAME,
+	.id_table	= products,
+	.probe		= usbnet_probe,
+	.suspend	= usbnet_suspend,
+	.resume		= usbnet_resume,
+	.disconnect	= usbnet_disconnect,
+	.supports_autosuspend = 1,
+};
+
+module_usb_driver(sr_driver);
+
+MODULE_AUTHOR("Liu Junliang <liujunliang_ljl@163.com");
+MODULE_VERSION(DRIVER_VERSION);
+MODULE_DESCRIPTION("SR9800 USB 2.0 USB2NET Dev : http://www.corechip-sz.com");
+MODULE_LICENSE("GPL");
+
diff --git a/drivers/net/usb/sr9800.h b/drivers/net/usb/sr9800.h
new file mode 100644
index 0000000..18f6702
--- /dev/null
+++ b/drivers/net/usb/sr9800.h
@@ -0,0 +1,202 @@
+/* CoreChip-sz SR9800 one chip USB 2.0 Ethernet Devices
+ *
+ * Author : Liu Junliang <liujunliang_ljl@163.com>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+#ifndef	_SR9800_H
+#define	_SR9800_H
+
+/* SR9800 spec. command table on Linux Platform */
+
+/* command : Software Station Management Control Reg */
+#define SR_CMD_SET_SW_MII		0x06
+/* command : PHY Read Reg */
+#define SR_CMD_READ_MII_REG		0x07
+/* command : PHY Write Reg */
+#define SR_CMD_WRITE_MII_REG		0x08
+/* command : Hardware Station Management Control Reg */
+#define SR_CMD_SET_HW_MII		0x0a
+/* command : SROM Read Reg */
+#define SR_CMD_READ_EEPROM		0x0b
+/* command : SROM Write Reg */
+#define SR_CMD_WRITE_EEPROM		0x0c
+/* command : SROM Write Enable Reg */
+#define SR_CMD_WRITE_ENABLE		0x0d
+/* command : SROM Write Disable Reg */
+#define SR_CMD_WRITE_DISABLE		0x0e
+/* command : RX Control Read Reg */
+#define SR_CMD_READ_RX_CTL		0x0f
+#define		SR_RX_CTL_PRO			(1 << 0)
+#define		SR_RX_CTL_AMALL			(1 << 1)
+#define		SR_RX_CTL_SEP			(1 << 2)
+#define		SR_RX_CTL_AB			(1 << 3)
+#define		SR_RX_CTL_AM			(1 << 4)
+#define		SR_RX_CTL_AP			(1 << 5)
+#define		SR_RX_CTL_ARP			(1 << 6)
+#define		SR_RX_CTL_SO			(1 << 7)
+#define		SR_RX_CTL_RH1M			(1 << 8)
+#define		SR_RX_CTL_RH2M			(1 << 9)
+#define		SR_RX_CTL_RH3M			(1 << 10)
+/* command : RX Control Write Reg */
+#define SR_CMD_WRITE_RX_CTL		0x10
+/* command : IPG0/IPG1/IPG2 Control Read Reg */
+#define SR_CMD_READ_IPG012		0x11
+/* command : IPG0/IPG1/IPG2 Control Write Reg */
+#define SR_CMD_WRITE_IPG012		0x12
+/* command : Node ID Read Reg */
+#define SR_CMD_READ_NODE_ID		0x13
+/* command : Node ID Write Reg */
+#define SR_CMD_WRITE_NODE_ID		0x14
+/* command : Multicast Filter Array Read Reg */
+#define	SR_CMD_READ_MULTI_FILTER	0x15
+/* command : Multicast Filter Array Write Reg */
+#define SR_CMD_WRITE_MULTI_FILTER	0x16
+/* command : Eth/HomePNA PHY Address Reg */
+#define SR_CMD_READ_PHY_ID		0x19
+/* command : Medium Status Read Reg */
+#define SR_CMD_READ_MEDIUM_STATUS	0x1a
+#define		SR_MONITOR_LINK			(1 << 1)
+#define		SR_MONITOR_MAGIC		(1 << 2)
+#define		SR_MONITOR_HSFS			(1 << 4)
+/* command : Medium Status Write Reg */
+#define SR_CMD_WRITE_MEDIUM_MODE	0x1b
+#define		SR_MEDIUM_GM			(1 << 0)
+#define		SR_MEDIUM_FD			(1 << 1)
+#define		SR_MEDIUM_AC			(1 << 2)
+#define		SR_MEDIUM_ENCK			(1 << 3)
+#define		SR_MEDIUM_RFC			(1 << 4)
+#define		SR_MEDIUM_TFC			(1 << 5)
+#define		SR_MEDIUM_JFE			(1 << 6)
+#define		SR_MEDIUM_PF			(1 << 7)
+#define		SR_MEDIUM_RE			(1 << 8)
+#define		SR_MEDIUM_PS			(1 << 9)
+#define		SR_MEDIUM_RSV			(1 << 10)
+#define		SR_MEDIUM_SBP			(1 << 11)
+#define		SR_MEDIUM_SM			(1 << 12)
+/* command : Monitor Mode Status Read Reg */
+#define SR_CMD_READ_MONITOR_MODE	0x1c
+/* command : Monitor Mode Status Write Reg */
+#define SR_CMD_WRITE_MONITOR_MODE	0x1d
+/* command : GPIO Status Read Reg */
+#define SR_CMD_READ_GPIOS		0x1e
+#define		SR_GPIO_GPO0EN		(1 << 0) /* GPIO0 Output enable */
+#define		SR_GPIO_GPO_0		(1 << 1) /* GPIO0 Output value */
+#define		SR_GPIO_GPO1EN		(1 << 2) /* GPIO1 Output enable */
+#define		SR_GPIO_GPO_1		(1 << 3) /* GPIO1 Output value */
+#define		SR_GPIO_GPO2EN		(1 << 4) /* GPIO2 Output enable */
+#define		SR_GPIO_GPO_2		(1 << 5) /* GPIO2 Output value */
+#define		SR_GPIO_RESERVED	(1 << 6) /* Reserved */
+#define		SR_GPIO_RSE		(1 << 7) /* Reload serial EEPROM */
+/* command : GPIO Status Write Reg */
+#define SR_CMD_WRITE_GPIOS		0x1f
+/* command : Eth PHY Power and Reset Control Reg */
+#define SR_CMD_SW_RESET			0x20
+#define		SR_SWRESET_CLEAR		0x00
+#define		SR_SWRESET_RR			(1 << 0)
+#define		SR_SWRESET_RT			(1 << 1)
+#define		SR_SWRESET_PRTE			(1 << 2)
+#define		SR_SWRESET_PRL			(1 << 3)
+#define		SR_SWRESET_BZ			(1 << 4)
+#define		SR_SWRESET_IPRL			(1 << 5)
+#define		SR_SWRESET_IPPD			(1 << 6)
+/* command : Software Interface Selection Status Read Reg */
+#define SR_CMD_SW_PHY_STATUS		0x21
+/* command : Software Interface Selection Status Write Reg */
+#define SR_CMD_SW_PHY_SELECT		0x22
+/* command : BULK in Buffer Size Reg */
+#define	SR_CMD_BULKIN_SIZE		0x2A
+/* command : LED_MUX Control Reg */
+#define	SR_CMD_LED_MUX			0x70
+#define		SR_LED_MUX_TX_ACTIVE		(1 << 0)
+#define		SR_LED_MUX_RX_ACTIVE		(1 << 1)
+#define		SR_LED_MUX_COLLISION		(1 << 2)
+#define		SR_LED_MUX_DUP_COL		(1 << 3)
+#define		SR_LED_MUX_DUP			(1 << 4)
+#define		SR_LED_MUX_SPEED		(1 << 5)
+#define		SR_LED_MUX_LINK_ACTIVE		(1 << 6)
+#define		SR_LED_MUX_LINK			(1 << 7)
+
+/* Register Access Flags */
+#define SR_REQ_RD_REG   (USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE)
+#define SR_REQ_WR_REG   (USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE)
+
+/* Multicast Filter Array size & Max Number */
+#define	SR_MCAST_FILTER_SIZE		8
+#define	SR_MAX_MCAST			64
+
+/* IPG0/1/2 Default Value */
+#define	SR9800_IPG0_DEFAULT		0x15
+#define	SR9800_IPG1_DEFAULT		0x0c
+#define	SR9800_IPG2_DEFAULT		0x12
+
+/* Medium Status Default Mode */
+#define SR9800_MEDIUM_DEFAULT	\
+	(SR_MEDIUM_FD | SR_MEDIUM_RFC | \
+	 SR_MEDIUM_TFC | SR_MEDIUM_PS | \
+	 SR_MEDIUM_AC | SR_MEDIUM_RE)
+
+/* RX Control Default Setting */
+#define SR_DEFAULT_RX_CTL	\
+	(SR_RX_CTL_SO | SR_RX_CTL_AB | SR_RX_CTL_RH1M)
+
+/* EEPROM Magic Number & EEPROM Size */
+#define SR_EEPROM_MAGIC			0xdeadbeef
+#define SR9800_EEPROM_LEN		0xff
+
+/* SR9800 Driver Version and Driver Name */
+#define DRIVER_VERSION			"11-Nov-2013"
+#define DRIVER_NAME			"CoreChips"
+#define	DRIVER_FLAG		\
+	(FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR |  FLAG_MULTI_PACKET)
+
+/* SR9800 BULKIN Buffer Size */
+#define SR9800_MAX_BULKIN_2K		0
+#define SR9800_MAX_BULKIN_4K		1
+#define SR9800_MAX_BULKIN_6K		2
+#define SR9800_MAX_BULKIN_8K		3
+#define SR9800_MAX_BULKIN_16K		4
+#define SR9800_MAX_BULKIN_20K		5
+#define SR9800_MAX_BULKIN_24K		6
+#define SR9800_MAX_BULKIN_32K		7
+
+struct {unsigned short size, byte_cnt, threshold; } SR9800_BULKIN_SIZE[] = {
+	/* 2k */
+	{2048, 0x8000, 0x8001},
+	/* 4k */
+	{4096, 0x8100, 0x8147},
+	/* 6k */
+	{6144, 0x8200, 0x81EB},
+	/* 8k */
+	{8192, 0x8300, 0x83D7},
+	/* 16 */
+	{16384, 0x8400, 0x851E},
+	/* 20k */
+	{20480, 0x8500, 0x8666},
+	/* 24k */
+	{24576, 0x8600, 0x87AE},
+	/* 32k */
+	{32768, 0x8700, 0x8A3D},
+};
+
+/* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
+struct sr_data {
+	u8 multi_filter[SR_MCAST_FILTER_SIZE];
+	u8 mac_addr[ETH_ALEN];
+	u8 phymode;
+	u8 ledmode;
+	u8 eeprom_len;
+};
+
+struct sr9800_int_data {
+	__le16 res1;
+	u8 link;
+	__le16 res2;
+	u8 status;
+	__le16 res3;
+} __packed;
+
+#endif	/* _SR9800_H */
-- 
1.7.9.5

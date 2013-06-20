From: Joseph CHANG <josright123@gmail.com>
Subject: [PATCH 1/1] net: add dm9620 net usb driver
Date: Thu, 20 Jun 2013 20:20:01 +0800
Message-ID: <1371730801-2288-1-git-send-email-josright123@gmail.com>
Cc: Joseph CHANG <josright123@gmail.com>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, joseph_chang@davicom.com.tw,
	josright@hotmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DM9620 is an USB2.0 network adapter rather than DM9601 USB1.1. This
driver processed the RX data 4 bytes header, TX data 2 bytes header,
make the control bit exactly right in PHY write function, and optional
IFF_ALLMUTLI bit for RX control.

Tested good for many platforms, include X86 desktop and ARM embedded.

Signed-off-by: Joseph CHANG <josright123@gmail.com>
---
 drivers/net/usb/Kconfig  |   13 +
 drivers/net/usb/Makefile |    1 +
 drivers/net/usb/dm9620.c |  796 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 810 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/dm9620.c

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 287cc62..e9c9e2a 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -272,6 +272,19 @@ config USB_NET_DM9601
 	  This option adds support for Davicom DM9601 based USB 1.1
 	  10/100 Ethernet adapters.
 
+config USB_NET_DM9620
+	tristate "Davicom DM9620/21 based USB 2.0 10/100 ethernet devices"
+	depends on USB_USBNET
+	select CRC32
+	help
+	  This option adds support for Davicom DM9620 based USB 2.0
+	  10/100 Ethernet adapters.
+
+	  This driver creates an interface named "ethX", where X depends on
+	  what other networking devices you have in use.
+
+	  To compile this driver as a module, choose M here.
+
 config USB_NET_SMSC75XX
 	tristate "SMSC LAN75XX based USB 2.0 gigabit ethernet devices"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 9ab5c9d..7d95e5c 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -14,6 +14,7 @@ obj-$(CONFIG_USB_NET_AX88179_178A)      += ax88179_178a.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
+obj-$(CONFIG_USB_NET_DM9620)	+= dm9620.o
 obj-$(CONFIG_USB_NET_SMSC75XX)	+= smsc75xx.o
 obj-$(CONFIG_USB_NET_SMSC95XX)	+= smsc95xx.o
 obj-$(CONFIG_USB_NET_GL620A)	+= gl620a.o
diff --git a/drivers/net/usb/dm9620.c b/drivers/net/usb/dm9620.c
new file mode 100644
index 0000000..aa4226b
--- /dev/null
+++ b/drivers/net/usb/dm9620.c
@@ -0,0 +1,796 @@
+/*
+ * Davicom DM9620 USB 2.0 10/100Mbps ethernet devices
+ *
+ * Peter Korsgaard <jacmet@sunsite.dk>
+ *
+ * This file is licensed under the terms of the GNU General Public License
+ * version 2.  This program is licensed "as is" without any warranty of any
+ * kind, whether express or implied.
+ */
+
+/* #define DEBUG */
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
+#include <linux/slab.h>
+
+/* control requests */
+#define DM_READ_REGS	0x00
+#define DM_WRITE_REGS	0x01
+#define DM_READ_MEMS	0x02
+#define DM_WRITE_REG	0x03
+#define DM_WRITE_MEMS	0x05
+#define DM_WRITE_MEM	0x07
+
+/* registers */
+#define DM_NET_CTRL	0x00
+#define DM_RX_CTRL	0x05
+#define DM_FCR		0x0a
+#define DM_SHARED_CTRL	0x0b
+#define DM_SHARED_ADDR	0x0c
+#define DM_SHARED_DATA	0x0d	/* low + high */
+#define DM_SHARED_DL	0x0d
+#define DM_SHARED_DH	0x0e
+#define DM_WAKEUP_CTRL  0x0f
+#define DM_PHY_ADDR	0x10	/* 6 bytes */
+#define DM_MCAST_ADDR	0x16	/* 8 bytes */
+#define DM_GPR_CTRL	0x1e
+#define DM_GPR_DATA	0x1f
+#define DM_PID		0x2a
+#define DM_CHIP_ID	0x2c
+#define DM_XPHY_CTRL	0x2e	/* reserved */
+#define DM_TX_CRC_CTRL	0x31
+#define DM_RX_CRC_CTRL	0x32
+#define DM_AZR		0x3f	/* reserved */
+#define DM_USB_CTRL	0xf4
+#define DM_MODE_CTRL	0x91	/* only on dm9620 */
+#define DM_CHIP_ID_EX	0x5C
+
+#define MD96XX_EEPROM_MAGIC	0x9620
+#define DM_MAX_MCAST	64
+#define DM_MCAST_SIZE	8
+#define DM_EEPROM_LEN	256
+#define DM_TX_OVERHEAD	2	/* 2 byte header */
+#define DM_RX_OVERHEAD	8	/* 4 byte header + 4 byte crc tail */
+#define DM_TIMEOUT	1000
+
+#define DM_NCR_RST	(1<<0)
+#define DM_NCR_WAKEEN	(1<<6)
+
+#define DM_FCR_TXPEN	(1<<5)
+#define DM_FCR_BKPM	(1<<3)
+#define DM_FCR_FLCE	(1<<0)
+
+#define DMSC_WEP	(1<<4)
+#define DMSC_ERPRW	(1<<1)
+#define DMSC_ERRE	(1<<0)
+
+#define DM_LINKEN	(1<<5)
+#define DM_MAGICEN	(1<<3)
+
+#define DM_TX_UDPCSE	(1<<2)
+#define DM_TX_TCPCSE	(1<<1)
+#define DM_TX_IPCSE	(1<<0)
+#define DM_RX_RCSEN	(1<<1)
+#define DM_MODE_DM_TXRX	(0<<4)
+#define DM_MODE_CDC_TRX	(1<<4)
+#define DM_MODE_DM_DESC	(0<<5)
+#define DM_MODE_CDC_DES	(1<<5)
+
+#define DM_USB_EP3ACK	(1<<5)
+
+#define DM_MODE9601	(0<<7)
+#define DM_MODE9620	(1<<7)
+#define DM9620_PHY_ID	1	/* Stone add For kernel read phy register */
+
+#define VID_DAVICOM	0x0a46
+
+#define PID_DM9620	0x9620
+#define PID_DM9621	0x9621
+#define PID_DM9622	0x9622
+#define PID_DM9620A	0x0269
+#define PID_DM9621A	0x1269
+
+static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
+{
+	int err;
+	err = usbnet_read_cmd(dev, DM_READ_REGS,
+			       USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       0, reg, data, length);
+	if (err != length && err >= 0)
+		err = -EINVAL;
+	return err;
+}
+
+static int dm_read_reg(struct usbnet *dev, u8 reg, u8 *value)
+{
+	return dm_read(dev, reg, 1, value);
+}
+
+static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
+{
+	int err;
+	err = usbnet_write_cmd(dev, DM_WRITE_REGS,
+				USB_DIR_OUT | USB_TYPE_VENDOR |
+				USB_RECIP_DEVICE,
+				0, reg, data, length);
+
+	if (err >= 0 && err < length)
+		err = -EINVAL;
+	return err;
+}
+
+static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
+{
+	return usbnet_write_cmd(dev, DM_WRITE_REG,
+				USB_DIR_OUT | USB_TYPE_VENDOR |
+				USB_RECIP_DEVICE,
+				value, reg, NULL, 0);
+}
+
+static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
+{
+	usbnet_write_cmd_async(dev, DM_WRITE_REGS,
+			       USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       0, reg, data, length);
+}
+
+static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
+{
+	usbnet_write_cmd_async(dev, DM_WRITE_REG,
+			       USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+			       value, reg, NULL, 0);
+}
+
+static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg,
+	__le16 *value)
+{
+	int ret, i;
+
+	mutex_lock(&dev->phy_mutex);
+
+	dm_write_reg(dev, DM_SHARED_ADDR, phy ? (reg | 0x40) : reg);
+	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0xc : 0x4);
+
+	for (i = 0; i < DM_TIMEOUT; i++) {
+		u8 tmp = 0;
+
+		udelay(1);
+		ret = dm_read_reg(dev, DM_SHARED_CTRL, &tmp);
+		if (ret < 0)
+			goto out;
+
+		/* ready */
+		if ((tmp & 1) == 0)
+			break;
+	}
+
+	if (i == DM_TIMEOUT) {
+		netdev_err(dev->net, "%s read timed out!\n",
+			phy ? "phy" : "eeprom");
+		ret = -EIO;
+		goto out;
+	}
+
+	dm_write_reg(dev, DM_SHARED_CTRL, 0x0);
+	ret = dm_read(dev, DM_SHARED_DATA, 2, value);
+
+	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
+		   phy, reg, *value, ret);
+
+ out:
+	mutex_unlock(&dev->phy_mutex);
+	return ret;
+}
+
+static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg,
+	__le16 value)
+{
+	int ret, i;
+
+	mutex_lock(&dev->phy_mutex);
+
+	ret = dm_write(dev, DM_SHARED_DATA, 2, &value);
+	if (ret < 0)
+		goto out;
+
+	dm_write_reg(dev, DM_SHARED_ADDR, phy ? (reg | 0x40) : reg);
+	dm_write_reg(dev, DM_SHARED_CTRL, phy ? 0x0a : 0x12);
+
+	for (i = 0; i < DM_TIMEOUT; i++) {
+		u8 tmp = 0;
+
+		udelay(1);
+		ret = dm_read_reg(dev, DM_SHARED_CTRL, &tmp);
+		if (ret < 0)
+			goto out;
+
+		/* ready */
+		if ((tmp & 1) == 0)
+			break;
+	}
+
+	if (i == DM_TIMEOUT) {
+		netdev_err(dev->net, "%s write timed out!\n",
+			phy ? "phy" : "eeprom");
+		ret = -EIO;
+		goto out;
+	}
+
+	dm_write_reg(dev, DM_SHARED_CTRL, 0x0);
+
+out:
+	mutex_unlock(&dev->phy_mutex);
+	return ret;
+}
+
+static void device_polling(struct usbnet *dev, u8 reg, u8 dmsc_bit,
+		u8 uexpected)
+{
+	int i, ret;
+	u8 tmp = 0;
+	for (i = 0; i < DM_TIMEOUT; i++) {
+		udelay(1);
+		ret = dm_read_reg(dev, reg, &tmp);
+		if (ret < 0) {
+			netdev_err(dev->net,
+				"[dm962 read reg] (reg: 0x%02x) error!\n",
+				reg);
+			break;
+		}
+		if ((tmp & dmsc_bit) == uexpected) /* ready */
+			break;
+	}
+	if (i == DM_TIMEOUT)
+		netdev_err(dev->net, "[dm962 time out] on polling bit:0x%x\n",
+			dmsc_bit);
+}
+
+static void dm_write_eeprom_word(struct usbnet *dev, u8 offset, u8 *data)
+{
+	mutex_lock(&dev->phy_mutex);
+
+	dm_write_reg(dev, DM_SHARED_ADDR, offset);
+	dm_write_reg(dev, DM_SHARED_DH, data[1]);
+	dm_write_reg(dev, DM_SHARED_DL, data[0]);
+	dm_write_reg(dev, DM_SHARED_CTRL, DMSC_WEP | DMSC_ERPRW);
+	device_polling(dev, DM_SHARED_CTRL, DMSC_ERRE, 0x00);
+	dm_write_reg(dev, DM_SHARED_CTRL, 0);
+
+	mutex_unlock(&dev->phy_mutex);
+}
+
+static int dm_read_eeprom_word(struct usbnet *dev, u8 offset, void *value)
+{
+	return dm_read_shared_word(dev, 0, offset, value);
+}
+
+static int dm9620_set_eeprom(struct net_device *net,
+		struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(net);
+	int offset = eeprom->offset;
+	int len = eeprom->len;
+	int done;
+
+	if (eeprom->magic != MD96XX_EEPROM_MAGIC) {
+		netdev_err(dev->net, "EEPROM: magic value mismatch, magic = 0x%x\n",
+			eeprom->magic);
+		return -EINVAL;
+	}
+
+	while (len > 0) {
+		if (len & 1 || offset & 1) {
+			int which = offset & 1;
+			u8 tmp[2];
+			dm_read_eeprom_word(dev, offset / 2, tmp);
+			tmp[which] = *data;
+			dm_write_eeprom_word(dev, offset / 2, tmp);
+			usleep_range(10000, 15000);
+			done = 1;
+		} else {
+			dm_write_eeprom_word(dev, offset / 2, data);
+			done = 2;
+		}
+		data += done;
+		offset += done;
+		len -= done;
+	}
+	return 0;
+}
+
+static int dm9620_get_eeprom_len(struct net_device *dev)
+{
+	return DM_EEPROM_LEN;
+}
+
+static int dm9620_get_eeprom(struct net_device *net,
+			     struct ethtool_eeprom *eeprom, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(net);
+	__le16 *ebuf = (__le16 *) data;
+	int i;
+
+	/* access is 16bit */
+	if ((eeprom->offset % 2) || (eeprom->len % 2))
+		return -EINVAL;
+
+	for (i = 0; i < eeprom->len / 2; i++) {
+		if (dm_read_eeprom_word(dev, eeprom->offset / 2 + i,
+					&ebuf[i]) < 0)
+			return -EINVAL;
+	}
+	return 0;
+}
+
+static int dm9620_mdio_read(struct net_device *netdev, int phy_id, int loc)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	__le16 res;
+
+	dm_read_shared_word(dev, 1, loc, &res);
+
+	netdev_dbg(dev->net,
+		   "dm9620_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+		   phy_id, loc, le16_to_cpu(res));
+
+	return le16_to_cpu(res);
+}
+
+static void dm9620_mdio_write(struct net_device *netdev, int phy_id, int loc,
+			      int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	__le16 res = cpu_to_le16(val);
+
+
+	netdev_dbg(dev->net, "dm9620_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+		   phy_id, loc, val);
+
+	dm_write_shared_word(dev, 1, loc, res);
+}
+
+static void dm9620_get_drvinfo(struct net_device *net,
+			       struct ethtool_drvinfo *info)
+{
+	/* Inherit standard device info */
+	usbnet_get_drvinfo(net, info);
+	info->eedump_len = DM_EEPROM_LEN;
+}
+
+static u32 dm9620_get_link(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	return mii_link_ok(&dev->mii);
+}
+
+static int dm9620_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
+{
+	struct usbnet *dev = netdev_priv(net);
+
+	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
+}
+
+static void
+dm9620_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 opt;
+
+	if (dm_read_reg(dev, DM_WAKEUP_CTRL, &opt) < 0) {
+		wolinfo->supported = 0;
+		wolinfo->wolopts = 0;
+		return;
+	}
+	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
+	wolinfo->wolopts = 0;
+
+	if (opt & DM_LINKEN)
+		wolinfo->wolopts |= WAKE_PHY;
+	if (opt & DM_MAGICEN)
+		wolinfo->wolopts |= WAKE_MAGIC;
+}
+
+static int
+dm9620_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 opt = 0;
+
+	if (wolinfo->wolopts & WAKE_PHY)
+		opt |= DM_LINKEN;
+	if (wolinfo->wolopts & WAKE_MAGIC)
+		opt |= DM_MAGICEN;
+
+	dm_write_reg(dev, DM_WAKEUP_CTRL, opt);
+	/* enable WAKEEN */
+	return dm_write_reg(dev, DM_NET_CTRL, DM_NCR_WAKEEN);
+}
+
+static const struct ethtool_ops dm9620_ethtool_ops = {
+	.get_drvinfo	= dm9620_get_drvinfo,
+	.get_link	= dm9620_get_link,
+	.get_msglevel	= usbnet_get_msglevel,
+	.set_msglevel	= usbnet_set_msglevel,
+	.get_eeprom_len	= dm9620_get_eeprom_len,
+	.get_eeprom	= dm9620_get_eeprom,
+	.set_eeprom	= dm9620_set_eeprom,
+	.get_settings	= usbnet_get_settings,
+	.set_settings	= usbnet_set_settings,
+	.nway_reset	= usbnet_nway_reset,
+	.get_wol	= dm9620_get_wol,
+	.set_wol	= dm9620_set_wol,
+};
+
+static void dm9620_set_multicast(struct net_device *net)
+{
+	struct usbnet *dev = netdev_priv(net);
+	/* We use the 20 byte dev->data for our 8 byte filter buffer
+	 * to avoid allocating memory that is tricky to free later
+	 */
+	u8 *hashes = (u8 *) &dev->data;
+	u8 rx_ctl = 0x31;
+
+	memset(hashes, 0, DM_MCAST_SIZE);
+	hashes[DM_MCAST_SIZE - 1] |= 0x80;	/* broadcast address */
+
+	if (net->flags & IFF_PROMISC) {
+		rx_ctl |= 0x02;
+	} else if (net->flags & IFF_ALLMULTI ||
+		   netdev_mc_count(net) > DM_MAX_MCAST) {
+		rx_ctl |= 0x08;
+	} else if (!netdev_mc_empty(net)) {
+		struct netdev_hw_addr *ha;
+
+		netdev_for_each_mc_addr(ha, net) {
+			u32 crc = ether_crc(ETH_ALEN, ha->addr) >> 26;
+			hashes[crc >> 3] |= 1 << (crc & 0x7);
+		}
+	}
+
+	dm_write_async(dev, DM_MCAST_ADDR, DM_MCAST_SIZE, hashes);
+	dm_write_reg_async(dev, DM_RX_CTRL, rx_ctl);
+}
+
+static void __dm9620_set_mac_address(struct usbnet *dev)
+{
+	dm_write_async(dev, DM_PHY_ADDR, ETH_ALEN, dev->net->dev_addr);
+}
+
+static int dm9620_set_mac_address(struct net_device *net, void *p)
+{
+	struct sockaddr *addr = p;
+	struct usbnet *dev = netdev_priv(net);
+
+	if (!is_valid_ether_addr(addr->sa_data)) {
+		dev_err(&net->dev, "not setting invalid mac address %pM\n",
+								addr->sa_data);
+		return -EINVAL;
+	}
+
+	memcpy(net->dev_addr, addr->sa_data, net->addr_len);
+	__dm9620_set_mac_address(dev);
+
+	return 0;
+}
+
+static const struct net_device_ops dm9620_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl		= dm9620_ioctl,
+	.ndo_set_rx_mode	= dm9620_set_multicast,
+	.ndo_set_mac_address	= dm9620_set_mac_address,
+};
+
+static int dm9620_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	u8 mac[ETH_ALEN], id;
+	u16 value;
+
+	ret = usbnet_get_endpoints(dev, intf);
+	if (ret)
+		return ret;
+
+	dev->net->netdev_ops = &dm9620_netdev_ops;
+	dev->net->ethtool_ops = &dm9620_ethtool_ops;
+	dev->net->hard_header_len += DM_TX_OVERHEAD;
+	dev->hard_mtu = dev->net->mtu + dev->net->hard_header_len;
+
+	/* ftp fail fixed */
+	dev->rx_urb_size = dev->net->mtu + ETH_HLEN + DM_RX_OVERHEAD+1;
+
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = dm9620_mdio_read;
+	dev->mii.mdio_write = dm9620_mdio_write;
+	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.phy_id = DM9620_PHY_ID;
+
+	/* reset */
+	dm_write_reg(dev, DM_NET_CTRL, 1);
+	usleep_range(20, 30);
+
+	/* read MAC */
+	if (dm_read(dev, DM_PHY_ADDR, ETH_ALEN, mac) < 0) {
+		netdev_err(dev->net, "Error reading MAC address\n");
+		return -ENODEV;
+	}
+
+	/* Overwrite the auto-generated address only with good ones */
+	if (is_valid_ether_addr(mac))
+		memcpy(dev->net->dev_addr, mac, ETH_ALEN);
+	else {
+		netdev_warn(dev->net,
+			"dm9620: No valid MAC address in EEPROM, using %pM\n",
+			dev->net->dev_addr);
+		__dm9620_set_mac_address(dev);
+	}
+
+	if (dm_read_reg(dev, DM_CHIP_ID, &id) < 0) {
+		netdev_err(dev->net, "Error reading chip ID\n");
+		return -ENODEV;
+	}
+
+	dm_read(dev, DM_PID, 2, &value);
+
+	/* Add for check Product dm9620a/21a */
+	if (value == PID_DM9620A || value == PID_DM9621A)
+		dm_write_reg(dev, DM_MODE_CTRL, DM_MODE9620 | DM_MODE_CDC_DES);
+	else
+		dm_write_reg(dev, DM_MODE_CTRL, DM_MODE9620);
+
+	dm_write_reg(dev, DM_RX_CRC_CTRL, DM_RX_RCSEN);
+
+	/* power up phy */
+	dm_write_reg(dev, DM_GPR_CTRL, 1);
+	dm_write_reg(dev, DM_GPR_DATA, 0);
+
+	/* receive broadcast packets */
+	dm9620_set_multicast(dev->net);
+
+	dm9620_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+
+	/* TX Pause Packet Enable */
+	dm_write_reg(dev, DM_FCR, DM_FCR_TXPEN | DM_FCR_BKPM | DM_FCR_FLCE);
+
+	/* Pause Capability on */
+	dm9620_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+
+	dm_write_reg(dev, DM_USB_CTRL, DM_USB_EP3ACK);
+
+	mii_nway_restart(&dev->mii);
+
+	return 0;
+}
+
+static void dm9620_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	netdev_warn(dev->net, "[dm962] Linux Driver = V2.6 - unbind\n");
+}
+
+static int dm9620_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	u8 status;
+	int len;
+
+	/* format:
+	 * b0: rx_flag
+	 * b1: rx status
+	 * b2: packet length (incl crc) low
+	 * b3: packet length (incl crc) high
+	 * b4..n-4: packet data
+	 * bn-3..bn: ethernet crc
+	 */
+	if (unlikely(skb->len < DM_RX_OVERHEAD)) {
+		dev_err(&dev->udev->dev, "unexpected tiny rx frame\n");
+		return 0;
+	}
+
+	status = skb->data[1];
+	len = (skb->data[2] | (skb->data[3] << 8)) - 4;
+
+	if (unlikely(status & 0xbf)) {
+		if (status & 0x01)
+			dev->net->stats.rx_fifo_errors++;
+		if (status & 0x02)
+			dev->net->stats.rx_crc_errors++;
+		if (status & 0x04)
+			dev->net->stats.rx_frame_errors++;
+		if (status & 0x20)
+			dev->net->stats.rx_missed_errors++;
+		if (status & 0x90)
+			dev->net->stats.rx_length_errors++;
+		return 0;
+	}
+
+	skb_pull(skb, 4);
+	skb_trim(skb, len);
+
+	return 1;
+}
+
+static bool davicom_bulkout_fix(int len, unsigned fullp)
+{
+	len = ((len+1)/2)*2;
+	len += 2;
+	return !(len % fullp) ? true : false;
+}
+
+static int dm9620_tx_oddadd_len(int len)
+{
+	return len & 1;
+}
+
+static int dm9620_tx_fulladd_len(int len, unsigned full_pld)
+{
+	if (davicom_bulkout_fix(len, full_pld))
+		return 2;
+	return 0;
+}
+
+static struct sk_buff *dm9620_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
+				       gfp_t flags)
+{
+	int len;
+	int oddadd_len, fulladd_len, newtailroom;
+
+	/* format:
+	 * b1: packet length low
+	 * b2: packet length high
+	 * b3..n: packet data
+	 */
+	len = skb->len;
+
+	oddadd_len = dm9620_tx_oddadd_len(len);
+	fulladd_len = dm9620_tx_fulladd_len(len, dev->maxpacket);
+	newtailroom = oddadd_len + fulladd_len;
+
+	if (skb_headroom(skb) < DM_TX_OVERHEAD ||
+		skb_tailroom(skb) < newtailroom) {
+		struct sk_buff *skb2;
+
+		if (skb_headroom(skb) < DM_TX_OVERHEAD &&
+			skb_tailroom(skb) < newtailroom)
+			skb2 = skb_copy_expand(skb, DM_TX_OVERHEAD, newtailroom,
+				flags);
+		else if (skb_headroom(skb) < DM_TX_OVERHEAD)
+			skb2 = skb_copy_expand(skb, DM_TX_OVERHEAD, 0, flags);
+		else
+			skb2 = skb_copy_expand(skb, 0, newtailroom, flags);
+		dev_kfree_skb_any(skb);
+		skb = skb2;
+		if (!skb)
+			return NULL;
+	}
+
+	/* add 2 bytes header which is data[0], data[1]
+	 * with extra 2 bytes bulkout len
+	 */
+	__skb_push(skb, DM_TX_OVERHEAD);
+
+	/* add 1, 2, or 3 bytes for tailer
+	 * with different variate bulkout len
+	 */
+	if (newtailroom)
+		__skb_put(skb, newtailroom);
+
+	/* add 2 bytes in length if a multiple of packet size */
+	len += fulladd_len;
+
+	skb->data[0] = len;
+	skb->data[1] = len >> 8;
+
+	return skb;
+}
+
+static void dm9620_status(struct usbnet *dev, struct urb *urb)
+{
+	int link;
+	u8 *buf;
+
+	/* format:
+	 * b0: net status
+	 * b1: tx status 1
+	 * b2: tx status 2
+	 * b3: rx status
+	 * b4: rx overflow
+	 * b5: rx count
+	 * b6: tx count
+	 * b7: gpr
+	 */
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
+static int dm9620_link_reset(struct usbnet *dev)
+{
+	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+
+	mii_check_media(&dev->mii, 1, 1);
+	mii_ethtool_gset(&dev->mii, &ecmd);
+	dm_write_reg(dev, DM_USB_CTRL, DM_USB_EP3ACK);
+
+	netdev_dbg(dev->net, "link_reset() speed: %u duplex: %d\n",
+		   ethtool_cmd_speed(&ecmd), ecmd.duplex);
+
+	return 0;
+}
+
+static const struct driver_info dm9620_info = {
+	.description	= "Davicom DM9620 USB Ethernet",
+	.flags		= FLAG_ETHER | FLAG_LINK_INTR,
+	.bind		= dm9620_bind,
+	.rx_fixup	= dm9620_rx_fixup,
+	.tx_fixup	= dm9620_tx_fixup,
+	.status		= dm9620_status,
+	.link_reset	= dm9620_link_reset,
+	.reset		= dm9620_link_reset,
+	.unbind		= dm9620_unbind,
+};
+
+static const struct usb_device_id products[] = {
+	{
+	 USB_DEVICE(VID_DAVICOM, PID_DM9620),	/* dm9620 */
+	 .driver_info = (unsigned long)&dm9620_info,
+	 },
+	{
+	 USB_DEVICE(VID_DAVICOM, PID_DM9621),	/* dm9621 */
+	 .driver_info = (unsigned long)&dm9620_info,
+	 },
+	{
+	 USB_DEVICE(VID_DAVICOM, PID_DM9622),	/* dm9622 */
+	 .driver_info = (unsigned long)&dm9620_info,
+	 },
+	{
+	 USB_DEVICE(VID_DAVICOM, PID_DM9620A),	/* dm9620a */
+	 .driver_info = (unsigned long)&dm9620_info,
+	 },
+	{
+	 USB_DEVICE(VID_DAVICOM, PID_DM9621A),	/* dm9621a */
+	 .driver_info = (unsigned long)&dm9620_info,
+	 },
+	{},
+};
+
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver dm9620_driver = {
+	.name = "dm9620",
+	.id_table = products,
+	.probe = usbnet_probe,
+	.disconnect = usbnet_disconnect,
+	.suspend = usbnet_suspend,
+	.resume = usbnet_resume,
+	.disable_hub_initiated_lpm = 1,
+};
+
+module_usb_driver(dm9620_driver);
+
+MODULE_AUTHOR("Peter Korsgaard <jacmet@sunsite.dk>");
+MODULE_DESCRIPTION("Davicom DM9620 USB 2.0 ethernet devices");
+MODULE_LICENSE("GPL");
-- 
1.7.1

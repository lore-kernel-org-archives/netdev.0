From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/4] smsc75xx: SMSC LAN75xx USB gigabit ethernet adapter driver
Date: Wed, 10 Mar 2010 18:26:54 +0000
Message-ID: <1268245617-13698-2-git-send-email-steve.glendinning@smsc.com>
References: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 77-44-110-64.xdsl.murphx.net ([77.44.110.64]:48054 "EHLO
	drevil2.shawell.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755802Ab0CJS1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 13:27:05 -0500
Received: from localhost.localdomain (unknown [10.0.20.109])
	by drevil2.shawell.net (Postfix) with ESMTP id 708F167E39
	for <netdev@vger.kernel.org>; Wed, 10 Mar 2010 18:26:57 +0000 (GMT)
In-Reply-To: <1268245617-13698-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a driver for SMSC's LAN7500 family of USB 2.0
to gigabit ethernet adapters.  It's loosely based on the smsc95xx
driver but the device registers for LAN7500 are completely different.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/Kconfig    |    8 +
 drivers/net/usb/Makefile   |    1 +
 drivers/net/usb/smsc75xx.c | 1184 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/smsc75xx.h |  421 ++++++++++++++++
 4 files changed, 1614 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/smsc75xx.c
 create mode 100644 drivers/net/usb/smsc75xx.h

diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 32d9356..ba56ce4 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -204,6 +204,14 @@ config USB_NET_DM9601
 	  This option adds support for Davicom DM9601 based USB 1.1
 	  10/100 Ethernet adapters.
 
+config USB_NET_SMSC75XX
+	tristate "SMSC LAN75XX based USB 2.0 gigabit ethernet devices"
+	depends on USB_USBNET
+	select CRC32
+	help
+	  This option adds support for SMSC LAN95XX based USB 2.0
+	  Gigabit Ethernet adapters.
+
 config USB_NET_SMSC95XX
 	tristate "SMSC LAN95XX based USB 2.0 10/100 ethernet devices"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index e17afb7..82ea629 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -11,6 +11,7 @@ obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_CDC_EEM)	+= cdc_eem.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
+obj-$(CONFIG_USB_NET_SMSC75XX)	+= smsc75xx.o
 obj-$(CONFIG_USB_NET_SMSC95XX)	+= smsc95xx.o
 obj-$(CONFIG_USB_NET_GL620A)	+= gl620a.o
 obj-$(CONFIG_USB_NET_NET1080)	+= net1080.o
diff --git a/drivers/net/usb/smsc75xx.c b/drivers/net/usb/smsc75xx.c
new file mode 100644
index 0000000..ffb8d25
--- /dev/null
+++ b/drivers/net/usb/smsc75xx.c
@@ -0,0 +1,1184 @@
+ /***************************************************************************
+ *
+ * Copyright (C) 2007-2010 SMSC
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ *****************************************************************************/
+
+#include <linux/module.h>
+#include <linux/kmod.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+#include <linux/usb.h>
+#include <linux/crc32.h>
+#include <linux/usb/usbnet.h>
+#include "smsc75xx.h"
+
+#define SMSC_CHIPNAME			"smsc75xx"
+#define SMSC_DRIVER_VERSION		"1.0.0"
+#define HS_USB_PKT_SIZE			(512)
+#define FS_USB_PKT_SIZE			(64)
+#define DEFAULT_HS_BURST_CAP_SIZE	(16 * 1024 + 5 * HS_USB_PKT_SIZE)
+#define DEFAULT_FS_BURST_CAP_SIZE	(6 * 1024 + 33 * FS_USB_PKT_SIZE)
+#define DEFAULT_BULK_IN_DELAY		(0x00002000)
+#define MAX_SINGLE_PACKET_SIZE		(9000)
+#define LAN75XX_EEPROM_MAGIC		(0x7500)
+#define EEPROM_MAC_OFFSET		(0x01)
+#define SMSC75XX_INTERNAL_PHY_ID	(1)
+#define SMSC75XX_TX_OVERHEAD		(8)
+#define MAX_RX_FIFO_SIZE		(20 * 1024)
+#define MAX_TX_FIFO_SIZE		(12 * 1024)
+#define USB_VENDOR_ID_SMSC		(0x0424)
+#define USB_PRODUCT_ID_LAN7500		(0x7500)
+#define USB_PRODUCT_ID_LAN7505		(0x7505)
+
+#define check_warn(ret, fmt, args...) \
+	({ if (ret < 0) netdev_warn(dev->net, fmt, ##args); })
+
+#define check_warn_return(ret, fmt, args...) \
+	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); return ret; } })
+
+#define check_warn_goto_done(ret, fmt, args...) \
+	({ if (ret < 0) { netdev_warn(dev->net, fmt, ##args); goto done; } })
+
+struct smsc75xx_priv {
+	struct usbnet *dev;
+	u32 rfe_ctl;
+	u32 multicast_hash_table[DP_SEL_VHF_HASH_LEN];
+	struct mutex dataport_mutex;
+	spinlock_t rfe_ctl_lock;
+	struct work_struct set_multicast;
+};
+
+struct usb_context {
+	struct usb_ctrlrequest req;
+	struct usbnet *dev;
+};
+
+static int turbo_mode = true;
+module_param(turbo_mode, bool, 0644);
+MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
+
+static int __must_check smsc75xx_read_reg(struct usbnet *dev, u32 index,
+					  u32 *data)
+{
+	u32 *buf = kmalloc(4, GFP_KERNEL);
+	int ret;
+
+	BUG_ON(!dev);
+
+	if (!buf)
+		return -ENOMEM;
+
+	ret = usb_control_msg(dev->udev, usb_rcvctrlpipe(dev->udev, 0),
+		USB_VENDOR_REQUEST_READ_REGISTER,
+		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
+
+	if (unlikely(ret < 0))
+		netdev_warn(dev->net,
+			"Failed to read register index 0x%08x", index);
+
+	le32_to_cpus(buf);
+	*data = *buf;
+	kfree(buf);
+
+	return ret;
+}
+
+static int __must_check smsc75xx_write_reg(struct usbnet *dev, u32 index,
+					   u32 data)
+{
+	u32 *buf = kmalloc(4, GFP_KERNEL);
+	int ret;
+
+	BUG_ON(!dev);
+
+	if (!buf)
+		return -ENOMEM;
+
+	*buf = data;
+	cpu_to_le32s(buf);
+
+	ret = usb_control_msg(dev->udev, usb_sndctrlpipe(dev->udev, 0),
+		USB_VENDOR_REQUEST_WRITE_REGISTER,
+		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
+		00, index, buf, 4, USB_CTRL_SET_TIMEOUT);
+
+	if (unlikely(ret < 0))
+		netdev_warn(dev->net,
+			"Failed to write register index 0x%08x", index);
+
+	kfree(buf);
+
+	return ret;
+}
+
+/* Loop until the read is completed with timeout
+ * called with phy_mutex held */
+static int smsc75xx_phy_wait_not_busy(struct usbnet *dev)
+{
+	unsigned long start_time = jiffies;
+	u32 val;
+	int ret;
+
+	do {
+		ret = smsc75xx_read_reg(dev, MII_ACCESS, &val);
+		check_warn_return(ret, "Error reading MII_ACCESS");
+
+		if (!(val & MII_ACCESS_BUSY))
+			return 0;
+	} while (!time_after(jiffies, start_time + HZ));
+
+	return -EIO;
+}
+
+static int smsc75xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u32 val, addr;
+	int ret;
+
+	mutex_lock(&dev->phy_mutex);
+
+	/* confirm MII not busy */
+	ret = smsc75xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_read");
+
+	/* set the address, index & direction (read from PHY) */
+	phy_id &= dev->mii.phy_id_mask;
+	idx &= dev->mii.reg_num_mask;
+	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
+		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
+		| MII_ACCESS_READ;
+	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
+	check_warn_goto_done(ret, "Error writing MII_ACCESS");
+
+	ret = smsc75xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "Timed out reading MII reg %02X", idx);
+
+	ret = smsc75xx_read_reg(dev, MII_DATA, &val);
+	check_warn_goto_done(ret, "Error reading MII_DATA");
+
+	ret = (u16)(val & 0xFFFF);
+
+done:
+	mutex_unlock(&dev->phy_mutex);
+	return ret;
+}
+
+static void smsc75xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
+				int regval)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u32 val, addr;
+	int ret;
+
+	mutex_lock(&dev->phy_mutex);
+
+	/* confirm MII not busy */
+	ret = smsc75xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "MII is busy in smsc75xx_mdio_write");
+
+	val = regval;
+	ret = smsc75xx_write_reg(dev, MII_DATA, val);
+	check_warn_goto_done(ret, "Error writing MII_DATA");
+
+	/* set the address, index & direction (write to PHY) */
+	phy_id &= dev->mii.phy_id_mask;
+	idx &= dev->mii.reg_num_mask;
+	addr = ((phy_id << MII_ACCESS_PHY_ADDR_SHIFT) & MII_ACCESS_PHY_ADDR)
+		| ((idx << MII_ACCESS_REG_ADDR_SHIFT) & MII_ACCESS_REG_ADDR)
+		| MII_ACCESS_WRITE;
+	ret = smsc75xx_write_reg(dev, MII_ACCESS, addr);
+	check_warn_goto_done(ret, "Error writing MII_ACCESS");
+
+	ret = smsc75xx_phy_wait_not_busy(dev);
+	check_warn_goto_done(ret, "Timed out writing MII reg %02X", idx);
+
+done:
+	mutex_unlock(&dev->phy_mutex);
+}
+
+static int smsc75xx_wait_eeprom(struct usbnet *dev)
+{
+	unsigned long start_time = jiffies;
+	u32 val;
+	int ret;
+
+	do {
+		ret = smsc75xx_read_reg(dev, E2P_CMD, &val);
+		check_warn_return(ret, "Error reading E2P_CMD");
+
+		if (!(val & E2P_CMD_BUSY) || (val & E2P_CMD_TIMEOUT))
+			break;
+		udelay(40);
+	} while (!time_after(jiffies, start_time + HZ));
+
+	if (val & (E2P_CMD_TIMEOUT | E2P_CMD_BUSY)) {
+		netdev_warn(dev->net, "EEPROM read operation timeout");
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static int smsc75xx_eeprom_confirm_not_busy(struct usbnet *dev)
+{
+	unsigned long start_time = jiffies;
+	u32 val;
+	int ret;
+
+	do {
+		ret = smsc75xx_read_reg(dev, E2P_CMD, &val);
+		check_warn_return(ret, "Error reading E2P_CMD");
+
+		if (!(val & E2P_CMD_BUSY))
+			return 0;
+
+		udelay(40);
+	} while (!time_after(jiffies, start_time + HZ));
+
+	netdev_warn(dev->net, "EEPROM is busy");
+	return -EIO;
+}
+
+static int smsc75xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
+				u8 *data)
+{
+	u32 val;
+	int i, ret;
+
+	BUG_ON(!dev);
+	BUG_ON(!data);
+
+	ret = smsc75xx_eeprom_confirm_not_busy(dev);
+	if (ret)
+		return ret;
+
+	for (i = 0; i < length; i++) {
+		val = E2P_CMD_BUSY | E2P_CMD_READ | (offset & E2P_CMD_ADDR);
+		ret = smsc75xx_write_reg(dev, E2P_CMD, val);
+		check_warn_return(ret, "Error writing E2P_CMD");
+
+		ret = smsc75xx_wait_eeprom(dev);
+		if (ret < 0)
+			return ret;
+
+		ret = smsc75xx_read_reg(dev, E2P_DATA, &val);
+		check_warn_return(ret, "Error reading E2P_DATA");
+
+		data[i] = val & 0xFF;
+		offset++;
+	}
+
+	return 0;
+}
+
+static int smsc75xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
+				 u8 *data)
+{
+	u32 val;
+	int i, ret;
+
+	BUG_ON(!dev);
+	BUG_ON(!data);
+
+	ret = smsc75xx_eeprom_confirm_not_busy(dev);
+	if (ret)
+		return ret;
+
+	/* Issue write/erase enable command */
+	val = E2P_CMD_BUSY | E2P_CMD_EWEN;
+	ret = smsc75xx_write_reg(dev, E2P_CMD, val);
+	check_warn_return(ret, "Error writing E2P_CMD");
+
+	ret = smsc75xx_wait_eeprom(dev);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < length; i++) {
+
+		/* Fill data register */
+		val = data[i];
+		ret = smsc75xx_write_reg(dev, E2P_DATA, val);
+		check_warn_return(ret, "Error writing E2P_DATA");
+
+		/* Send "write" command */
+		val = E2P_CMD_BUSY | E2P_CMD_WRITE | (offset & E2P_CMD_ADDR);
+		ret = smsc75xx_write_reg(dev, E2P_CMD, val);
+		check_warn_return(ret, "Error writing E2P_CMD");
+
+		ret = smsc75xx_wait_eeprom(dev);
+		if (ret < 0)
+			return ret;
+
+		offset++;
+	}
+
+	return 0;
+}
+
+static int smsc75xx_dataport_wait_not_busy(struct usbnet *dev)
+{
+	int i, ret;
+
+	for (i = 0; i < 100; i++) {
+		u32 dp_sel;
+		ret = smsc75xx_read_reg(dev, DP_SEL, &dp_sel);
+		check_warn_return(ret, "Error reading DP_SEL");
+
+		if (dp_sel & DP_SEL_DPRDY)
+			return 0;
+
+		udelay(40);
+	}
+
+	netdev_warn(dev->net, "smsc75xx_dataport_wait_not_busy timed out");
+
+	return -EIO;
+}
+
+static int smsc75xx_dataport_write(struct usbnet *dev, u32 ram_select, u32 addr,
+				   u32 length, u32 *buf)
+{
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	u32 dp_sel;
+	int i, ret;
+
+	mutex_lock(&pdata->dataport_mutex);
+
+	ret = smsc75xx_dataport_wait_not_busy(dev);
+	check_warn_goto_done(ret, "smsc75xx_dataport_write busy on entry");
+
+	ret = smsc75xx_read_reg(dev, DP_SEL, &dp_sel);
+	check_warn_goto_done(ret, "Error reading DP_SEL");
+
+	dp_sel &= ~DP_SEL_RSEL;
+	dp_sel |= ram_select;
+	ret = smsc75xx_write_reg(dev, DP_SEL, dp_sel);
+	check_warn_goto_done(ret, "Error writing DP_SEL");
+
+	for (i = 0; i < length; i++) {
+		ret = smsc75xx_write_reg(dev, DP_ADDR, addr + i);
+		check_warn_goto_done(ret, "Error writing DP_ADDR");
+
+		ret = smsc75xx_write_reg(dev, DP_DATA, buf[i]);
+		check_warn_goto_done(ret, "Error writing DP_DATA");
+
+		ret = smsc75xx_write_reg(dev, DP_CMD, DP_CMD_WRITE);
+		check_warn_goto_done(ret, "Error writing DP_CMD");
+
+		ret = smsc75xx_dataport_wait_not_busy(dev);
+		check_warn_goto_done(ret, "smsc75xx_dataport_write timeout");
+	}
+
+done:
+	mutex_unlock(&pdata->dataport_mutex);
+	return ret;
+}
+
+/* returns hash bit number for given MAC address */
+static u32 smsc75xx_hash(char addr[ETH_ALEN])
+{
+	return (ether_crc(ETH_ALEN, addr) >> 23) & 0x1ff;
+}
+
+static void smsc75xx_deferred_multicast_write(struct work_struct *param)
+{
+	struct smsc75xx_priv *pdata =
+		container_of(param, struct smsc75xx_priv, set_multicast);
+	struct usbnet *dev = pdata->dev;
+	int ret;
+
+	netif_dbg(dev, drv, dev->net, "deferred multicast write 0x%08x",
+		pdata->rfe_ctl);
+
+	smsc75xx_dataport_write(dev, DP_SEL_VHF, DP_SEL_VHF_VLAN_LEN,
+		DP_SEL_VHF_HASH_LEN, pdata->multicast_hash_table);
+
+	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
+	check_warn(ret, "Error writing RFE_CRL");
+}
+
+static void smsc75xx_set_multicast(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	unsigned long flags;
+	int i;
+
+	spin_lock_irqsave(&pdata->rfe_ctl_lock, flags);
+
+	pdata->rfe_ctl &=
+		~(RFE_CTL_AU | RFE_CTL_AM | RFE_CTL_DPF | RFE_CTL_MHF);
+	pdata->rfe_ctl |= RFE_CTL_AB;
+
+	for (i = 0; i < DP_SEL_VHF_HASH_LEN; i++)
+		pdata->multicast_hash_table[i] = 0;
+
+	if (dev->net->flags & IFF_PROMISC) {
+		netif_dbg(dev, drv, dev->net, "promiscuous mode enabled");
+		pdata->rfe_ctl |= RFE_CTL_AM | RFE_CTL_AU;
+	} else if (dev->net->flags & IFF_ALLMULTI) {
+		netif_dbg(dev, drv, dev->net, "receive all multicast enabled");
+		pdata->rfe_ctl |= RFE_CTL_AM | RFE_CTL_DPF;
+	} else if (!netdev_mc_empty(dev->net)) {
+		struct dev_mc_list *mc_list;
+
+		netif_dbg(dev, drv, dev->net, "receive multicast hash filter");
+
+		pdata->rfe_ctl |= RFE_CTL_MHF | RFE_CTL_DPF;
+
+		netdev_for_each_mc_addr(mc_list, netdev) {
+			u32 bitnum = smsc75xx_hash(mc_list->dmi_addr);
+			pdata->multicast_hash_table[bitnum / 32] |=
+				(1 << (bitnum % 32));
+		}
+	} else {
+		netif_dbg(dev, drv, dev->net, "receive own packets only");
+		pdata->rfe_ctl |= RFE_CTL_DPF;
+	}
+
+	spin_unlock_irqrestore(&pdata->rfe_ctl_lock, flags);
+
+	/* defer register writes to a sleepable context */
+	schedule_work(&pdata->set_multicast);
+}
+
+static int smsc75xx_update_flowcontrol(struct usbnet *dev, u8 duplex,
+					    u16 lcladv, u16 rmtadv)
+{
+	u32 flow = 0, fct_flow = 0;
+	int ret;
+
+	if (duplex == DUPLEX_FULL) {
+		u8 cap = mii_resolve_flowctrl_fdx(lcladv, rmtadv);
+
+		if (cap & FLOW_CTRL_TX) {
+			flow = (FLOW_TX_FCEN | 0xFFFF);
+			/* set fct_flow thresholds to 20% and 80% */
+			fct_flow = (8 << 8) | 32;
+		}
+
+		if (cap & FLOW_CTRL_RX)
+			flow |= FLOW_RX_FCEN;
+
+		netif_dbg(dev, link, dev->net, "rx pause %s, tx pause %s",
+			(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
+			(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+	} else {
+		netif_dbg(dev, link, dev->net, "half duplex");
+	}
+
+	ret = smsc75xx_write_reg(dev, FLOW, flow);
+	check_warn_return(ret, "Error writing FLOW");
+
+	ret = smsc75xx_write_reg(dev, FCT_FLOW, fct_flow);
+	check_warn_return(ret, "Error writing FCT_FLOW");
+
+	return 0;
+}
+
+static int smsc75xx_link_reset(struct usbnet *dev)
+{
+	struct mii_if_info *mii = &dev->mii;
+	struct ethtool_cmd ecmd;
+	u16 lcladv, rmtadv;
+	int ret;
+
+	/* clear interrupt status */
+	ret = smsc75xx_mdio_read(dev->net, mii->phy_id, PHY_INT_SRC);
+	check_warn_return(ret, "Error reading PHY_INT_SRC");
+
+	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
+	check_warn_return(ret, "Error writing INT_STS");
+
+	mii_check_media(mii, 1, 1);
+	mii_ethtool_gset(&dev->mii, &ecmd);
+	lcladv = smsc75xx_mdio_read(dev->net, mii->phy_id, MII_ADVERTISE);
+	rmtadv = smsc75xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
+
+	netif_dbg(dev, link, dev->net, "speed: %d duplex: %d lcladv: %04x"
+		" rmtadv: %04x", ecmd.speed, ecmd.duplex, lcladv, rmtadv);
+
+	return smsc75xx_update_flowcontrol(dev, ecmd.duplex, lcladv, rmtadv);
+}
+
+static void smsc75xx_status(struct usbnet *dev, struct urb *urb)
+{
+	u32 intdata;
+
+	if (urb->actual_length != 4) {
+		netdev_warn(dev->net,
+			"unexpected urb length %d", urb->actual_length);
+		return;
+	}
+
+	memcpy(&intdata, urb->transfer_buffer, 4);
+	le32_to_cpus(&intdata);
+
+	netif_dbg(dev, link, dev->net, "intdata: 0x%08X", intdata);
+
+	if (intdata & INT_ENP_PHY_INT)
+		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+	else
+		netdev_warn(dev->net,
+			"unexpected interrupt, intdata=0x%08X", intdata);
+}
+
+static int smsc75xx_ethtool_get_eeprom_len(struct net_device *net)
+{
+	return MAX_EEPROM_SIZE;
+}
+
+static int smsc75xx_ethtool_get_eeprom(struct net_device *netdev,
+				       struct ethtool_eeprom *ee, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	ee->magic = LAN75XX_EEPROM_MAGIC;
+
+	return smsc75xx_read_eeprom(dev, ee->offset, ee->len, data);
+}
+
+static int smsc75xx_ethtool_set_eeprom(struct net_device *netdev,
+				       struct ethtool_eeprom *ee, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	if (ee->magic != LAN75XX_EEPROM_MAGIC) {
+		netdev_warn(dev->net,
+			"EEPROM: magic value mismatch: 0x%x", ee->magic);
+		return -EINVAL;
+	}
+
+	return smsc75xx_write_eeprom(dev, ee->offset, ee->len, data);
+}
+
+static const struct ethtool_ops smsc75xx_ethtool_ops = {
+	.get_link	= usbnet_get_link,
+	.nway_reset	= usbnet_nway_reset,
+	.get_drvinfo	= usbnet_get_drvinfo,
+	.get_msglevel	= usbnet_get_msglevel,
+	.set_msglevel	= usbnet_set_msglevel,
+	.get_settings	= usbnet_get_settings,
+	.set_settings	= usbnet_set_settings,
+	.get_eeprom_len	= smsc75xx_ethtool_get_eeprom_len,
+	.get_eeprom	= smsc75xx_ethtool_get_eeprom,
+	.set_eeprom	= smsc75xx_ethtool_set_eeprom,
+};
+
+static int smsc75xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
+}
+
+static void smsc75xx_init_mac_address(struct usbnet *dev)
+{
+	/* try reading mac address from EEPROM */
+	if (smsc75xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
+			dev->net->dev_addr) == 0) {
+		if (is_valid_ether_addr(dev->net->dev_addr)) {
+			/* eeprom values are valid so use them */
+			netif_dbg(dev, ifup, dev->net,
+				"MAC address read from EEPROM");
+			return;
+		}
+	}
+
+	/* no eeprom, or eeprom values are invalid. generate random MAC */
+	random_ether_addr(dev->net->dev_addr);
+	netif_dbg(dev, ifup, dev->net, "MAC address set to random_ether_addr");
+}
+
+static int smsc75xx_set_mac_address(struct usbnet *dev)
+{
+	u32 addr_lo = dev->net->dev_addr[0] | dev->net->dev_addr[1] << 8 |
+		dev->net->dev_addr[2] << 16 | dev->net->dev_addr[3] << 24;
+	u32 addr_hi = dev->net->dev_addr[4] | dev->net->dev_addr[5] << 8;
+
+	int ret = smsc75xx_write_reg(dev, RX_ADDRH, addr_hi);
+	check_warn_return(ret, "Failed to write RX_ADDRH: %d", ret);
+
+	ret = smsc75xx_write_reg(dev, RX_ADDRL, addr_lo);
+	check_warn_return(ret, "Failed to write RX_ADDRL: %d", ret);
+
+	addr_hi |= ADDR_FILTX_FB_VALID;
+	ret = smsc75xx_write_reg(dev, ADDR_FILTX, addr_hi);
+	check_warn_return(ret, "Failed to write ADDR_FILTX: %d", ret);
+
+	ret = smsc75xx_write_reg(dev, ADDR_FILTX + 4, addr_lo);
+	check_warn_return(ret, "Failed to write ADDR_FILTX+4: %d", ret);
+
+	return 0;
+}
+
+static int smsc75xx_phy_initialize(struct usbnet *dev)
+{
+	int bmcr, timeout = 0;
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = smsc75xx_mdio_read;
+	dev->mii.mdio_write = smsc75xx_mdio_write;
+	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.phy_id = SMSC75XX_INTERNAL_PHY_ID;
+
+	/* reset phy and wait for reset to complete */
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+
+	do {
+		msleep(10);
+		bmcr = smsc75xx_mdio_read(dev->net, dev->mii.phy_id, MII_BMCR);
+		check_warn_return(bmcr, "Error reading MII_BMCR");
+		timeout++;
+	} while ((bmcr & MII_BMCR) && (timeout < 100));
+
+	if (timeout >= 100) {
+		netdev_warn(dev->net, "timeout on PHY Reset");
+		return -EIO;
+	}
+
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP |
+		ADVERTISE_PAUSE_ASYM);
+
+	/* read to clear */
+	smsc75xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
+	check_warn_return(bmcr, "Error reading PHY_INT_SRC");
+
+	smsc75xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
+		PHY_INT_MASK_DEFAULT);
+	mii_nway_restart(&dev->mii);
+
+	netif_dbg(dev, ifup, dev->net, "phy initialised successfully");
+	return 0;
+}
+
+static int smsc75xx_set_rx_max_frame_length(struct usbnet *dev, int size)
+{
+	int ret = 0;
+	u32 buf;
+	bool rxenabled;
+
+	ret = smsc75xx_read_reg(dev, MAC_RX, &buf);
+	check_warn_return(ret, "Failed to read MAC_RX: %d", ret);
+
+	rxenabled = ((buf & MAC_RX_RXEN) != 0);
+
+	if (rxenabled) {
+		buf &= ~MAC_RX_RXEN;
+		ret = smsc75xx_write_reg(dev, MAC_RX, buf);
+		check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+	}
+
+	/* add 4 to size for FCS */
+	buf &= ~MAC_RX_MAX_SIZE;
+	buf |= (((size + 4) << MAC_RX_MAX_SIZE_SHIFT) & MAC_RX_MAX_SIZE);
+
+	ret = smsc75xx_write_reg(dev, MAC_RX, buf);
+	check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+
+	if (rxenabled) {
+		buf |= MAC_RX_RXEN;
+		ret = smsc75xx_write_reg(dev, MAC_RX, buf);
+		check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+	}
+
+	return 0;
+}
+
+static int smsc75xx_change_mtu(struct net_device *netdev, int new_mtu)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	int ret = smsc75xx_set_rx_max_frame_length(dev, new_mtu);
+	check_warn_return(ret, "Failed to set mac rx frame length");
+
+	return usbnet_change_mtu(netdev, new_mtu);
+}
+
+static int smsc75xx_reset(struct usbnet *dev)
+{
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	u32 buf;
+	int ret = 0, timeout;
+
+	netif_dbg(dev, ifup, dev->net, "entering smsc75xx_reset");
+
+	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
+	check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+
+	buf |= HW_CFG_LRST;
+
+	ret = smsc75xx_write_reg(dev, HW_CFG, buf);
+	check_warn_return(ret, "Failed to write HW_CFG: %d", ret);
+
+	timeout = 0;
+	do {
+		msleep(10);
+		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
+		check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+		timeout++;
+	} while ((buf & HW_CFG_LRST) && (timeout < 100));
+
+	if (timeout >= 100) {
+		netdev_warn(dev->net, "timeout on completion of Lite Reset");
+		return -EIO;
+	}
+
+	netif_dbg(dev, ifup, dev->net, "Lite reset complete, resetting PHY");
+
+	ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
+	check_warn_return(ret, "Failed to read PMT_CTL: %d", ret);
+
+	buf |= PMT_CTL_PHY_RST;
+
+	ret = smsc75xx_write_reg(dev, PMT_CTL, buf);
+	check_warn_return(ret, "Failed to write PMT_CTL: %d", ret);
+
+	timeout = 0;
+	do {
+		msleep(10);
+		ret = smsc75xx_read_reg(dev, PMT_CTL, &buf);
+		check_warn_return(ret, "Failed to read PMT_CTL: %d", ret);
+		timeout++;
+	} while ((buf & PMT_CTL_PHY_RST) && (timeout < 100));
+
+	if (timeout >= 100) {
+		netdev_warn(dev->net, "timeout waiting for PHY Reset");
+		return -EIO;
+	}
+
+	netif_dbg(dev, ifup, dev->net, "PHY reset complete");
+
+	smsc75xx_init_mac_address(dev);
+
+	ret = smsc75xx_set_mac_address(dev);
+	check_warn_return(ret, "Failed to set mac address");
+
+	netif_dbg(dev, ifup, dev->net, "MAC Address: %pM", dev->net->dev_addr);
+
+	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
+	check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG : 0x%08x", buf);
+
+	buf |= HW_CFG_BIR;
+
+	ret = smsc75xx_write_reg(dev, HW_CFG, buf);
+	check_warn_return(ret, "Failed to write HW_CFG: %d", ret);
+
+	ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
+	check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "Read Value from HW_CFG after "
+			"writing HW_CFG_BIR: 0x%08x", buf);
+
+	if (!turbo_mode) {
+		buf = 0;
+		dev->rx_urb_size = MAX_SINGLE_PACKET_SIZE;
+	} else if (dev->udev->speed == USB_SPEED_HIGH) {
+		buf = DEFAULT_HS_BURST_CAP_SIZE / HS_USB_PKT_SIZE;
+		dev->rx_urb_size = DEFAULT_HS_BURST_CAP_SIZE;
+	} else {
+		buf = DEFAULT_FS_BURST_CAP_SIZE / FS_USB_PKT_SIZE;
+		dev->rx_urb_size = DEFAULT_FS_BURST_CAP_SIZE;
+	}
+
+	netif_dbg(dev, ifup, dev->net, "rx_urb_size=%ld",
+		(ulong)dev->rx_urb_size);
+
+	ret = smsc75xx_write_reg(dev, BURST_CAP, buf);
+	check_warn_return(ret, "Failed to write BURST_CAP: %d", ret);
+
+	ret = smsc75xx_read_reg(dev, BURST_CAP, &buf);
+	check_warn_return(ret, "Failed to read BURST_CAP: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net,
+		"Read Value from BURST_CAP after writing: 0x%08x", buf);
+
+	ret = smsc75xx_write_reg(dev, BULK_IN_DLY, DEFAULT_BULK_IN_DELAY);
+	check_warn_return(ret, "Failed to write BULK_IN_DLY: %d", ret);
+
+	ret = smsc75xx_read_reg(dev, BULK_IN_DLY, &buf);
+	check_warn_return(ret, "Failed to read BULK_IN_DLY: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net,
+		"Read Value from BULK_IN_DLY after writing: 0x%08x", buf);
+
+	if (turbo_mode) {
+		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
+		check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+
+		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x", buf);
+
+		buf |= (HW_CFG_MEF | HW_CFG_BCE);
+
+		ret = smsc75xx_write_reg(dev, HW_CFG, buf);
+		check_warn_return(ret, "Failed to write HW_CFG: %d", ret);
+
+		ret = smsc75xx_read_reg(dev, HW_CFG, &buf);
+		check_warn_return(ret, "Failed to read HW_CFG: %d", ret);
+
+		netif_dbg(dev, ifup, dev->net, "HW_CFG: 0x%08x", buf);
+	}
+
+	/* set FIFO sizes */
+	buf = (MAX_RX_FIFO_SIZE - 512) / 512;
+	ret = smsc75xx_write_reg(dev, FCT_RX_FIFO_END, buf);
+	check_warn_return(ret, "Failed to write FCT_RX_FIFO_END: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "FCT_RX_FIFO_END set to 0x%08x", buf);
+
+	buf = (MAX_TX_FIFO_SIZE - 512) / 512;
+	ret = smsc75xx_write_reg(dev, FCT_TX_FIFO_END, buf);
+	check_warn_return(ret, "Failed to write FCT_TX_FIFO_END: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "FCT_TX_FIFO_END set to 0x%08x", buf);
+
+	ret = smsc75xx_write_reg(dev, INT_STS, INT_STS_CLEAR_ALL);
+	check_warn_return(ret, "Failed to write INT_STS: %d", ret);
+
+	ret = smsc75xx_read_reg(dev, ID_REV, &buf);
+	check_warn_return(ret, "Failed to read ID_REV: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "ID_REV = 0x%08x", buf);
+
+	/* Configure GPIO pins as LED outputs */
+	ret = smsc75xx_read_reg(dev, LED_GPIO_CFG, &buf);
+	check_warn_return(ret, "Failed to read LED_GPIO_CFG: %d", ret);
+
+	buf &= ~(LED_GPIO_CFG_LED2_FUN_SEL | LED_GPIO_CFG_LED10_FUN_SEL);
+	buf |= LED_GPIO_CFG_LEDGPIO_EN | LED_GPIO_CFG_LED2_FUN_SEL;
+
+	ret = smsc75xx_write_reg(dev, LED_GPIO_CFG, buf);
+	check_warn_return(ret, "Failed to write LED_GPIO_CFG: %d", ret);
+
+	ret = smsc75xx_write_reg(dev, FLOW, 0);
+	check_warn_return(ret, "Failed to write FLOW: %d", ret);
+
+	ret = smsc75xx_write_reg(dev, FCT_FLOW, 0);
+	check_warn_return(ret, "Failed to write FCT_FLOW: %d", ret);
+
+	/* Don't need rfe_ctl_lock during initialisation */
+	ret = smsc75xx_read_reg(dev, RFE_CTL, &pdata->rfe_ctl);
+	check_warn_return(ret, "Failed to read RFE_CTL: %d", ret);
+
+	pdata->rfe_ctl |= RFE_CTL_AB | RFE_CTL_DPF;
+
+	ret = smsc75xx_write_reg(dev, RFE_CTL, pdata->rfe_ctl);
+	check_warn_return(ret, "Failed to write RFE_CTL: %d", ret);
+
+	ret = smsc75xx_read_reg(dev, RFE_CTL, &pdata->rfe_ctl);
+	check_warn_return(ret, "Failed to read RFE_CTL: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "RFE_CTL set to 0x%08x", pdata->rfe_ctl);
+
+	smsc75xx_set_multicast(dev->net);
+
+	ret = smsc75xx_phy_initialize(dev);
+	check_warn_return(ret, "Failed to initialize PHY: %d", ret);
+
+	ret = smsc75xx_read_reg(dev, INT_EP_CTL, &buf);
+	check_warn_return(ret, "Failed to read INT_EP_CTL: %d", ret);
+
+	/* enable PHY interrupts */
+	buf |= INT_ENP_PHY_INT;
+
+	ret = smsc75xx_write_reg(dev, INT_EP_CTL, buf);
+	check_warn_return(ret, "Failed to write INT_EP_CTL: %d", ret);
+
+	ret = smsc75xx_read_reg(dev, MAC_TX, &buf);
+	check_warn_return(ret, "Failed to read MAC_TX: %d", ret);
+
+	buf |= MAC_TX_TXEN;
+
+	ret = smsc75xx_write_reg(dev, MAC_TX, buf);
+	check_warn_return(ret, "Failed to write MAC_TX: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "MAC_TX set to 0x%08x", buf);
+
+	ret = smsc75xx_read_reg(dev, FCT_TX_CTL, &buf);
+	check_warn_return(ret, "Failed to read FCT_TX_CTL: %d", ret);
+
+	buf |= FCT_TX_CTL_EN;
+
+	ret = smsc75xx_write_reg(dev, FCT_TX_CTL, buf);
+	check_warn_return(ret, "Failed to write FCT_TX_CTL: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "FCT_TX_CTL set to 0x%08x", buf);
+
+	ret = smsc75xx_set_rx_max_frame_length(dev, 1514);
+	check_warn_return(ret, "Failed to set max rx frame length");
+
+	ret = smsc75xx_read_reg(dev, MAC_RX, &buf);
+	check_warn_return(ret, "Failed to read MAC_RX: %d", ret);
+
+	buf |= MAC_RX_RXEN;
+
+	ret = smsc75xx_write_reg(dev, MAC_RX, buf);
+	check_warn_return(ret, "Failed to write MAC_RX: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "MAC_RX set to 0x%08x", buf);
+
+	ret = smsc75xx_read_reg(dev, FCT_RX_CTL, &buf);
+	check_warn_return(ret, "Failed to read FCT_RX_CTL: %d", ret);
+
+	buf |= FCT_RX_CTL_EN;
+
+	ret = smsc75xx_write_reg(dev, FCT_RX_CTL, buf);
+	check_warn_return(ret, "Failed to write FCT_RX_CTL: %d", ret);
+
+	netif_dbg(dev, ifup, dev->net, "FCT_RX_CTL set to 0x%08x", buf);
+
+	netif_dbg(dev, ifup, dev->net, "smsc75xx_reset, return 0");
+	return 0;
+}
+
+static const struct net_device_ops smsc75xx_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= smsc75xx_change_mtu,
+	.ndo_set_mac_address 	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_do_ioctl 		= smsc75xx_ioctl,
+	.ndo_set_multicast_list = smsc75xx_set_multicast,
+};
+
+static int smsc75xx_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct smsc75xx_priv *pdata = NULL;
+	int ret;
+
+	printk(KERN_INFO SMSC_CHIPNAME " v" SMSC_DRIVER_VERSION "\n");
+
+	ret = usbnet_get_endpoints(dev, intf);
+	check_warn_return(ret, "usbnet_get_endpoints failed: %d", ret);
+
+	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc75xx_priv),
+		GFP_KERNEL);
+
+	pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	if (!pdata) {
+		netdev_warn(dev->net, "Unable to allocate smsc75xx_priv");
+		return -ENOMEM;
+	}
+
+	pdata->dev = dev;
+
+	spin_lock_init(&pdata->rfe_ctl_lock);
+	mutex_init(&pdata->dataport_mutex);
+
+	INIT_WORK(&pdata->set_multicast, smsc75xx_deferred_multicast_write);
+
+	/* Init all registers */
+	ret = smsc75xx_reset(dev);
+
+	dev->net->netdev_ops = &smsc75xx_netdev_ops;
+	dev->net->ethtool_ops = &smsc75xx_ethtool_ops;
+	dev->net->flags |= IFF_MULTICAST;
+	dev->net->hard_header_len += SMSC75XX_TX_OVERHEAD;
+	return 0;
+}
+
+static void smsc75xx_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct smsc75xx_priv *pdata = (struct smsc75xx_priv *)(dev->data[0]);
+	if (pdata) {
+		netif_dbg(dev, ifdown, dev->net, "free pdata");
+		kfree(pdata);
+		pdata = NULL;
+		dev->data[0] = 0;
+	}
+}
+
+static int smsc75xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	while (skb->len > 0) {
+		u32 rx_cmd_a, rx_cmd_b, align_count, size;
+		struct sk_buff *ax_skb;
+		unsigned char *packet;
+
+		memcpy(&rx_cmd_a, skb->data, sizeof(rx_cmd_a));
+		le32_to_cpus(&rx_cmd_a);
+		skb_pull(skb, 4);
+
+		memcpy(&rx_cmd_b, skb->data, sizeof(rx_cmd_b));
+		le32_to_cpus(&rx_cmd_b);
+		skb_pull(skb, 4 + NET_IP_ALIGN);
+
+		packet = skb->data;
+
+		/* get the packet length */
+		size = (rx_cmd_a & RX_CMD_A_LEN) - NET_IP_ALIGN;
+		align_count = (4 - ((size + NET_IP_ALIGN) % 4)) % 4;
+
+		if (unlikely(rx_cmd_a & RX_CMD_A_RED)) {
+			netif_dbg(dev, rx_err, dev->net,
+				"Error rx_cmd_a=0x%08x", rx_cmd_a);
+			dev->net->stats.rx_errors++;
+			dev->net->stats.rx_dropped++;
+
+			if (rx_cmd_a & RX_CMD_A_FCS)
+				dev->net->stats.rx_crc_errors++;
+			else if (rx_cmd_a & (RX_CMD_A_LONG | RX_CMD_A_RUNT))
+				dev->net->stats.rx_frame_errors++;
+		} else {
+			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */
+			if (unlikely(size > (ETH_FRAME_LEN + 12))) {
+				netif_dbg(dev, rx_err, dev->net,
+					"size err rx_cmd_a=0x%08x", rx_cmd_a);
+				return 0;
+			}
+
+			/* last frame in this batch */
+			if (skb->len == size) {
+				skb->ip_summed = CHECKSUM_NONE;
+				skb_trim(skb, skb->len - 4); /* remove fcs */
+				skb->truesize = size + sizeof(struct sk_buff);
+
+				return 1;
+			}
+
+			ax_skb = skb_clone(skb, GFP_ATOMIC);
+			if (unlikely(!ax_skb)) {
+				netdev_warn(dev->net, "Error allocating skb");
+				return 0;
+			}
+
+			ax_skb->len = size;
+			ax_skb->data = packet;
+			skb_set_tail_pointer(ax_skb, size);
+
+			ax_skb->ip_summed = CHECKSUM_NONE;
+			skb_trim(ax_skb, ax_skb->len - 4); /* remove fcs */
+			ax_skb->truesize = size + sizeof(struct sk_buff);
+
+			usbnet_skb_return(dev, ax_skb);
+		}
+
+		skb_pull(skb, size);
+
+		/* padding bytes before the next frame starts */
+		if (skb->len)
+			skb_pull(skb, align_count);
+	}
+
+	if (unlikely(skb->len < 0)) {
+		netdev_warn(dev->net, "invalid rx length<0 %d", skb->len);
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct sk_buff *smsc75xx_tx_fixup(struct usbnet *dev,
+					 struct sk_buff *skb, gfp_t flags)
+{
+	u32 tx_cmd_a, tx_cmd_b;
+
+	/* We do not advertise SG, so skbs should be already linearized */
+	BUG_ON(skb_shinfo(skb)->nr_frags);
+
+	if (skb_headroom(skb) < SMSC75XX_TX_OVERHEAD) {
+		struct sk_buff *skb2 =
+			skb_copy_expand(skb, SMSC75XX_TX_OVERHEAD, 0, flags);
+		dev_kfree_skb_any(skb);
+		skb = skb2;
+		if (!skb)
+			return NULL;
+	}
+
+	tx_cmd_a = (u32)(skb->len & TX_CMD_A_LEN) | TX_CMD_A_FCS;
+
+	tx_cmd_b = 0;
+
+	skb_push(skb, 4);
+	cpu_to_le32s(&tx_cmd_b);
+	memcpy(skb->data, &tx_cmd_b, 4);
+
+	skb_push(skb, 4);
+	cpu_to_le32s(&tx_cmd_a);
+	memcpy(skb->data, &tx_cmd_a, 4);
+
+	return skb;
+}
+
+static const struct driver_info smsc75xx_info = {
+	.description	= "smsc75xx USB 2.0 Gigabit Ethernet",
+	.bind		= smsc75xx_bind,
+	.unbind		= smsc75xx_unbind,
+	.link_reset	= smsc75xx_link_reset,
+	.reset		= smsc75xx_reset,
+	.rx_fixup	= smsc75xx_rx_fixup,
+	.tx_fixup	= smsc75xx_tx_fixup,
+	.status		= smsc75xx_status,
+	.flags		= FLAG_ETHER | FLAG_SEND_ZLP,
+};
+
+static const struct usb_device_id products[] = {
+	{
+		/* SMSC7500 USB Gigabit Ethernet Device */
+		USB_DEVICE(USB_VENDOR_ID_SMSC, USB_PRODUCT_ID_LAN7500),
+		.driver_info = (unsigned long) &smsc75xx_info,
+	},
+	{
+		/* SMSC7500 USB Gigabit Ethernet Device */
+		USB_DEVICE(USB_VENDOR_ID_SMSC, USB_PRODUCT_ID_LAN7505),
+		.driver_info = (unsigned long) &smsc75xx_info,
+	},
+	{ },		/* END */
+};
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver smsc75xx_driver = {
+	.name		= SMSC_CHIPNAME,
+	.id_table	= products,
+	.probe		= usbnet_probe,
+	.suspend	= usbnet_suspend,
+	.resume		= usbnet_resume,
+	.disconnect	= usbnet_disconnect,
+};
+
+static int __init smsc75xx_init(void)
+{
+	return usb_register(&smsc75xx_driver);
+}
+module_init(smsc75xx_init);
+
+static void __exit smsc75xx_exit(void)
+{
+	usb_deregister(&smsc75xx_driver);
+}
+module_exit(smsc75xx_exit);
+
+MODULE_AUTHOR("Nancy Lin");
+MODULE_AUTHOR("Steve Glendinning <steve.glendinning@smsc.com>");
+MODULE_DESCRIPTION("SMSC75XX USB 2.0 Gigabit Ethernet Devices");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/usb/smsc75xx.h b/drivers/net/usb/smsc75xx.h
new file mode 100644
index 0000000..16e98c7
--- /dev/null
+++ b/drivers/net/usb/smsc75xx.h
@@ -0,0 +1,421 @@
+ /***************************************************************************
+ *
+ * Copyright (C) 2007-2010 SMSC
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version 2
+ * of the License, or (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ *****************************************************************************/
+
+#ifndef _SMSC75XX_H
+#define _SMSC75XX_H
+
+/* Tx command words */
+#define TX_CMD_A_LSO			(0x08000000)
+#define TX_CMD_A_IPE			(0x04000000)
+#define TX_CMD_A_TPE			(0x02000000)
+#define TX_CMD_A_IVTG			(0x01000000)
+#define TX_CMD_A_RVTG			(0x00800000)
+#define TX_CMD_A_FCS			(0x00400000)
+#define TX_CMD_A_LEN			(0x000FFFFF)
+
+#define TX_CMD_B_MSS			(0x3FFF0000)
+#define TX_CMD_B_MSS_SHIFT		(16)
+#define TX_MSS_MIN			((u16)8)
+#define TX_CMD_B_VTAG			(0x0000FFFF)
+
+/* Rx command words */
+#define RX_CMD_A_ICE			(0x80000000)
+#define RX_CMD_A_TCE			(0x40000000)
+#define RX_CMD_A_IPV			(0x20000000)
+#define RX_CMD_A_PID			(0x18000000)
+#define RX_CMD_A_PID_NIP		(0x00000000)
+#define RX_CMD_A_PID_TCP		(0x08000000)
+#define RX_CMD_A_PID_UDP		(0x10000000)
+#define RX_CMD_A_PID_PP			(0x18000000)
+#define RX_CMD_A_PFF			(0x04000000)
+#define RX_CMD_A_BAM			(0x02000000)
+#define RX_CMD_A_MAM			(0x01000000)
+#define RX_CMD_A_FVTG			(0x00800000)
+#define RX_CMD_A_RED			(0x00400000)
+#define RX_CMD_A_RWT			(0x00200000)
+#define RX_CMD_A_RUNT			(0x00100000)
+#define RX_CMD_A_LONG			(0x00080000)
+#define RX_CMD_A_RXE			(0x00040000)
+#define RX_CMD_A_DRB			(0x00020000)
+#define RX_CMD_A_FCS			(0x00010000)
+#define RX_CMD_A_UAM			(0x00008000)
+#define RX_CMD_A_LCSM			(0x00004000)
+#define RX_CMD_A_LEN			(0x00003FFF)
+
+#define RX_CMD_B_CSUM			(0xFFFF0000)
+#define RX_CMD_B_CSUM_SHIFT		(16)
+#define RX_CMD_B_VTAG			(0x0000FFFF)
+
+/* SCSRs */
+#define ID_REV				(0x0000)
+
+#define FPGA_REV			(0x0004)
+
+#define BOND_CTL			(0x0008)
+
+#define INT_STS				(0x000C)
+#define INT_STS_RDFO_INT		(0x00400000)
+#define INT_STS_TXE_INT			(0x00200000)
+#define INT_STS_MACRTO_INT		(0x00100000)
+#define INT_STS_TX_DIS_INT		(0x00080000)
+#define INT_STS_RX_DIS_INT		(0x00040000)
+#define INT_STS_PHY_INT_		(0x00020000)
+#define INT_STS_MAC_ERR_INT		(0x00008000)
+#define INT_STS_TDFU			(0x00004000)
+#define INT_STS_TDFO			(0x00002000)
+#define INT_STS_GPIOS			(0x00000FFF)
+#define INT_STS_CLEAR_ALL		(0xFFFFFFFF)
+
+#define HW_CFG				(0x0010)
+#define HW_CFG_SMDET_STS		(0x00008000)
+#define HW_CFG_SMDET_EN			(0x00004000)
+#define HW_CFG_EEM			(0x00002000)
+#define HW_CFG_RST_PROTECT		(0x00001000)
+#define HW_CFG_PORT_SWAP		(0x00000800)
+#define HW_CFG_PHY_BOOST		(0x00000600)
+#define HW_CFG_PHY_BOOST_NORMAL		(0x00000000)
+#define HW_CFG_PHY_BOOST_4		(0x00002000)
+#define HW_CFG_PHY_BOOST_8		(0x00004000)
+#define HW_CFG_PHY_BOOST_12		(0x00006000)
+#define HW_CFG_LEDB			(0x00000100)
+#define HW_CFG_BIR			(0x00000080)
+#define HW_CFG_SBP			(0x00000040)
+#define HW_CFG_IME			(0x00000020)
+#define HW_CFG_MEF			(0x00000010)
+#define HW_CFG_ETC			(0x00000008)
+#define HW_CFG_BCE			(0x00000004)
+#define HW_CFG_LRST			(0x00000002)
+#define HW_CFG_SRST			(0x00000001)
+
+#define PMT_CTL				(0x0014)
+#define PMT_CTL_PHY_PWRUP		(0x00000400)
+#define PMT_CTL_RES_CLR_WKP_EN		(0x00000100)
+#define PMT_CTL_DEV_RDY			(0x00000080)
+#define PMT_CTL_SUS_MODE		(0x00000060)
+#define PMT_CTL_SUS_MODE_0		(0x00000000)
+#define PMT_CTL_SUS_MODE_1		(0x00000020)
+#define PMT_CTL_SUS_MODE_2		(0x00000040)
+#define PMT_CTL_SUS_MODE_3		(0x00000060)
+#define PMT_CTL_PHY_RST			(0x00000010)
+#define PMT_CTL_WOL_EN			(0x00000008)
+#define PMT_CTL_ED_EN			(0x00000004)
+#define PMT_CTL_WUPS			(0x00000003)
+#define PMT_CTL_WUPS_NO			(0x00000000)
+#define PMT_CTL_WUPS_ED			(0x00000001)
+#define PMT_CTL_WUPS_WOL		(0x00000002)
+#define PMT_CTL_WUPS_MULTI		(0x00000003)
+
+#define LED_GPIO_CFG			(0x0018)
+#define LED_GPIO_CFG_LED2_FUN_SEL	(0x80000000)
+#define LED_GPIO_CFG_LED10_FUN_SEL	(0x40000000)
+#define LED_GPIO_CFG_LEDGPIO_EN		(0x0000F000)
+#define LED_GPIO_CFG_LEDGPIO_EN_0	(0x00001000)
+#define LED_GPIO_CFG_LEDGPIO_EN_1	(0x00002000)
+#define LED_GPIO_CFG_LEDGPIO_EN_2	(0x00004000)
+#define LED_GPIO_CFG_LEDGPIO_EN_3	(0x00008000)
+#define LED_GPIO_CFG_GPBUF		(0x00000F00)
+#define LED_GPIO_CFG_GPBUF_0		(0x00000100)
+#define LED_GPIO_CFG_GPBUF_1		(0x00000200)
+#define LED_GPIO_CFG_GPBUF_2		(0x00000400)
+#define LED_GPIO_CFG_GPBUF_3		(0x00000800)
+#define LED_GPIO_CFG_GPDIR		(0x000000F0)
+#define LED_GPIO_CFG_GPDIR_0		(0x00000010)
+#define LED_GPIO_CFG_GPDIR_1		(0x00000020)
+#define LED_GPIO_CFG_GPDIR_2		(0x00000040)
+#define LED_GPIO_CFG_GPDIR_3		(0x00000080)
+#define LED_GPIO_CFG_GPDATA		(0x0000000F)
+#define LED_GPIO_CFG_GPDATA_0		(0x00000001)
+#define LED_GPIO_CFG_GPDATA_1		(0x00000002)
+#define LED_GPIO_CFG_GPDATA_2		(0x00000004)
+#define LED_GPIO_CFG_GPDATA_3		(0x00000008)
+
+#define GPIO_CFG			(0x001C)
+#define GPIO_CFG_SHIFT			(24)
+#define GPIO_CFG_GPEN			(0xFF000000)
+#define GPIO_CFG_GPBUF			(0x00FF0000)
+#define GPIO_CFG_GPDIR			(0x0000FF00)
+#define GPIO_CFG_GPDATA			(0x000000FF)
+
+#define GPIO_WAKE			(0x0020)
+#define GPIO_WAKE_PHY_LINKUP_EN		(0x80000000)
+#define GPIO_WAKE_POL			(0x0FFF0000)
+#define GPIO_WAKE_POL_SHIFT		(16)
+#define GPIO_WAKE_WK			(0x00000FFF)
+
+#define DP_SEL				(0x0024)
+#define DP_SEL_DPRDY			(0x80000000)
+#define DP_SEL_RSEL			(0x0000000F)
+#define DP_SEL_URX			(0x00000000)
+#define DP_SEL_VHF			(0x00000001)
+#define DP_SEL_VHF_HASH_LEN		(16)
+#define DP_SEL_VHF_VLAN_LEN		(128)
+#define DP_SEL_LSO_HEAD			(0x00000002)
+#define DP_SEL_FCT_RX			(0x00000003)
+#define DP_SEL_FCT_TX			(0x00000004)
+#define DP_SEL_DESCRIPTOR		(0x00000005)
+#define DP_SEL_WOL			(0x00000006)
+
+#define DP_CMD				(0x0028)
+#define DP_CMD_WRITE			(0x01)
+#define DP_CMD_READ			(0x00)
+
+#define DP_ADDR				(0x002C)
+
+#define DP_DATA				(0x0030)
+
+#define BURST_CAP			(0x0034)
+#define BURST_CAP_MASK			(0x0000000F)
+
+#define INT_EP_CTL			(0x0038)
+#define INT_EP_CTL_INTEP_ON		(0x80000000)
+#define INT_EP_CTL_RDFO_EN		(0x00400000)
+#define INT_EP_CTL_TXE_EN		(0x00200000)
+#define INT_EP_CTL_MACROTO_EN		(0x00100000)
+#define INT_EP_CTL_TX_DIS_EN		(0x00080000)
+#define INT_EP_CTL_RX_DIS_EN		(0x00040000)
+#define INT_EP_CTL_PHY_EN_		(0x00020000)
+#define INT_EP_CTL_MAC_ERR_EN		(0x00008000)
+#define INT_EP_CTL_TDFU_EN		(0x00004000)
+#define INT_EP_CTL_TDFO_EN		(0x00002000)
+#define INT_EP_CTL_RX_FIFO_EN		(0x00001000)
+#define INT_EP_CTL_GPIOX_EN		(0x00000FFF)
+
+#define BULK_IN_DLY			(0x003C)
+#define BULK_IN_DLY_MASK		(0xFFFF)
+
+#define E2P_CMD				(0x0040)
+#define E2P_CMD_BUSY			(0x80000000)
+#define E2P_CMD_MASK			(0x70000000)
+#define E2P_CMD_READ			(0x00000000)
+#define E2P_CMD_EWDS			(0x10000000)
+#define E2P_CMD_EWEN			(0x20000000)
+#define E2P_CMD_WRITE			(0x30000000)
+#define E2P_CMD_WRAL			(0x40000000)
+#define E2P_CMD_ERASE			(0x50000000)
+#define E2P_CMD_ERAL			(0x60000000)
+#define E2P_CMD_RELOAD			(0x70000000)
+#define E2P_CMD_TIMEOUT			(0x00000400)
+#define E2P_CMD_LOADED			(0x00000200)
+#define E2P_CMD_ADDR			(0x000001FF)
+
+#define MAX_EEPROM_SIZE			(512)
+
+#define E2P_DATA			(0x0044)
+#define E2P_DATA_MASK_			(0x000000FF)
+
+#define RFE_CTL				(0x0060)
+#define RFE_CTL_TCPUDP_CKM		(0x00001000)
+#define RFE_CTL_IP_CKM			(0x00000800)
+#define RFE_CTL_AB			(0x00000400)
+#define RFE_CTL_AM			(0x00000200)
+#define RFE_CTL_AU			(0x00000100)
+#define RFE_CTL_VS			(0x00000080)
+#define RFE_CTL_UF			(0x00000040)
+#define RFE_CTL_VF			(0x00000020)
+#define RFE_CTL_SPF			(0x00000010)
+#define RFE_CTL_MHF			(0x00000008)
+#define RFE_CTL_DHF			(0x00000004)
+#define RFE_CTL_DPF			(0x00000002)
+#define RFE_CTL_RST_RF			(0x00000001)
+
+#define VLAN_TYPE			(0x0064)
+#define VLAN_TYPE_MASK			(0x0000FFFF)
+
+#define FCT_RX_CTL			(0x0090)
+#define FCT_RX_CTL_EN			(0x80000000)
+#define FCT_RX_CTL_RST			(0x40000000)
+#define FCT_RX_CTL_SBF			(0x02000000)
+#define FCT_RX_CTL_OVERFLOW		(0x01000000)
+#define FCT_RX_CTL_FRM_DROP		(0x00800000)
+#define FCT_RX_CTL_RX_NOT_EMPTY		(0x00400000)
+#define FCT_RX_CTL_RX_EMPTY		(0x00200000)
+#define FCT_RX_CTL_RX_DISABLED		(0x00100000)
+#define FCT_RX_CTL_RXUSED		(0x0000FFFF)
+
+#define FCT_TX_CTL			(0x0094)
+#define FCT_TX_CTL_EN			(0x80000000)
+#define FCT_TX_CTL_RST			(0x40000000)
+#define FCT_TX_CTL_TX_NOT_EMPTY		(0x00400000)
+#define FCT_TX_CTL_TX_EMPTY		(0x00200000)
+#define FCT_TX_CTL_TX_DISABLED		(0x00100000)
+#define FCT_TX_CTL_TXUSED		(0x0000FFFF)
+
+#define FCT_RX_FIFO_END			(0x0098)
+#define FCT_RX_FIFO_END_MASK		(0x0000007F)
+
+#define FCT_TX_FIFO_END			(0x009C)
+#define FCT_TX_FIFO_END_MASK		(0x0000003F)
+
+#define FCT_FLOW			(0x00A0)
+#define FCT_FLOW_THRESHOLD_OFF		(0x00007F00)
+#define FCT_FLOW_THRESHOLD_OFF_SHIFT	(8)
+#define FCT_FLOW_THRESHOLD_ON		(0x0000007F)
+
+/* MAC CSRs */
+#define MAC_CR				(0x100)
+#define MAC_CR_ADP			(0x00002000)
+#define MAC_CR_ADD			(0x00001000)
+#define MAC_CR_ASD			(0x00000800)
+#define MAC_CR_INT_LOOP			(0x00000400)
+#define MAC_CR_BOLMT			(0x000000C0)
+#define MAC_CR_FDPX			(0x00000008)
+#define MAC_CR_CFG			(0x00000006)
+#define MAC_CR_CFG_10			(0x00000000)
+#define MAC_CR_CFG_100			(0x00000002)
+#define MAC_CR_CFG_1000			(0x00000004)
+#define MAC_CR_RST			(0x00000001)
+
+#define MAC_RX				(0x104)
+#define MAC_RX_MAX_SIZE			(0x3FFF0000)
+#define MAC_RX_MAX_SIZE_SHIFT		(16)
+#define MAC_RX_FCS_STRIP		(0x00000010)
+#define MAC_RX_FSE			(0x00000004)
+#define MAC_RX_RXD			(0x00000002)
+#define MAC_RX_RXEN			(0x00000001)
+
+#define MAC_TX				(0x108)
+#define MAC_TX_BFCS			(0x00000004)
+#define MAC_TX_TXD			(0x00000002)
+#define MAC_TX_TXEN			(0x00000001)
+
+#define FLOW				(0x10C)
+#define FLOW_FORCE_FC			(0x80000000)
+#define FLOW_TX_FCEN			(0x40000000)
+#define FLOW_RX_FCEN			(0x20000000)
+#define FLOW_FPF			(0x10000000)
+#define FLOW_PAUSE_TIME			(0x0000FFFF)
+
+#define RAND_SEED			(0x110)
+#define RAND_SEED_MASK			(0x0000FFFF)
+
+#define ERR_STS				(0x114)
+#define ERR_STS_FCS_ERR			(0x00000100)
+#define ERR_STS_LFRM_ERR		(0x00000080)
+#define ERR_STS_RUNT_ERR		(0x00000040)
+#define ERR_STS_COLLISION_ERR		(0x00000010)
+#define ERR_STS_ALIGN_ERR		(0x00000008)
+#define ERR_STS_URUN_ERR		(0x00000004)
+
+#define RX_ADDRH			(0x118)
+#define RX_ADDRH_MASK			(0x0000FFFF)
+
+#define RX_ADDRL			(0x11C)
+
+#define MII_ACCESS			(0x120)
+#define MII_ACCESS_PHY_ADDR		(0x0000F800)
+#define MII_ACCESS_PHY_ADDR_SHIFT	(11)
+#define MII_ACCESS_REG_ADDR		(0x000007C0)
+#define MII_ACCESS_REG_ADDR_SHIFT	(6)
+#define MII_ACCESS_READ			(0x00000000)
+#define MII_ACCESS_WRITE		(0x00000002)
+#define MII_ACCESS_BUSY			(0x00000001)
+
+#define MII_DATA			(0x124)
+#define MII_DATA_MASK			(0x0000FFFF)
+
+#define WUCSR				(0x140)
+#define WUCSR_PFDA_FR			(0x00000080)
+#define WUCSR_WUFR			(0x00000040)
+#define WUCSR_MPR			(0x00000020)
+#define WUCSR_BCAST_FR			(0x00000010)
+#define WUCSR_PFDA_EN			(0x00000008)
+#define WUCSR_WUEN			(0x00000004)
+#define WUCSR_MPEN			(0x00000002)
+#define WUCSR_BCST_EN			(0x00000001)
+
+#define WUF_CFGX			(0x144)
+#define WUF_CFGX_EN			(0x80000000)
+#define WUF_CFGX_ATYPE			(0x03000000)
+#define WUF_CFGX_ATYPE_UNICAST		(0x00000000)
+#define WUF_CFGX_ATYPE_MULTICAST	(0x02000000)
+#define WUF_CFGX_ATYPE_ALL		(0x03000000)
+#define WUF_CFGX_PATTERN_OFFSET		(0x007F0000)
+#define WUF_CFGX_PATTERN_OFFSET_SHIFT	(16)
+#define WUF_CFGX_CRC16			(0x0000FFFF)
+#define WUF_NUM				(8)
+
+#define WUF_MASKX			(0x170)
+#define WUF_MASKX_AVALID		(0x80000000)
+#define WUF_MASKX_ATYPE			(0x40000000)
+
+#define ADDR_FILTX			(0x300)
+#define ADDR_FILTX_FB_VALID		(0x80000000)
+#define ADDR_FILTX_FB_TYPE		(0x40000000)
+#define ADDR_FILTX_FB_ADDRHI		(0x0000FFFF)
+#define ADDR_FILTX_SB_ADDRLO		(0xFFFFFFFF)
+
+#define WUCSR2				(0x500)
+#define WUCSR2_NS_RCD			(0x00000040)
+#define WUCSR2_ARP_RCD			(0x00000020)
+#define WUCSR2_TCPSYN_RCD		(0x00000010)
+#define WUCSR2_NS_OFFLOAD		(0x00000004)
+#define WUCSR2_ARP_OFFLOAD		(0x00000002)
+#define WUCSR2_TCPSYN_OFFLOAD		(0x00000001)
+
+#define WOL_FIFO_STS			(0x504)
+
+#define IPV6_ADDRX			(0x510)
+
+#define IPV4_ADDRX			(0x590)
+
+
+/* Vendor-specific PHY Definitions */
+
+/* Mode Control/Status Register */
+#define PHY_MODE_CTRL_STS		(17)
+#define MODE_CTRL_STS_EDPWRDOWN		((u16)0x2000)
+#define MODE_CTRL_STS_ENERGYON		((u16)0x0002)
+
+#define PHY_INT_SRC			(29)
+#define PHY_INT_SRC_ENERGY_ON		((u16)0x0080)
+#define PHY_INT_SRC_ANEG_COMP		((u16)0x0040)
+#define PHY_INT_SRC_REMOTE_FAULT	((u16)0x0020)
+#define PHY_INT_SRC_LINK_DOWN		((u16)0x0010)
+
+#define PHY_INT_MASK			(30)
+#define PHY_INT_MASK_ENERGY_ON		((u16)0x0080)
+#define PHY_INT_MASK_ANEG_COMP		((u16)0x0040)
+#define PHY_INT_MASK_REMOTE_FAULT	((u16)0x0020)
+#define PHY_INT_MASK_LINK_DOWN		((u16)0x0010)
+#define PHY_INT_MASK_DEFAULT		(PHY_INT_MASK_ANEG_COMP | \
+					 PHY_INT_MASK_LINK_DOWN)
+
+#define PHY_SPECIAL			(31)
+#define PHY_SPECIAL_SPD			((u16)0x001C)
+#define PHY_SPECIAL_SPD_10HALF		((u16)0x0004)
+#define PHY_SPECIAL_SPD_10FULL		((u16)0x0014)
+#define PHY_SPECIAL_SPD_100HALF		((u16)0x0008)
+#define PHY_SPECIAL_SPD_100FULL		((u16)0x0018)
+
+/* USB Vendor Requests */
+#define USB_VENDOR_REQUEST_WRITE_REGISTER	0xA0
+#define USB_VENDOR_REQUEST_READ_REGISTER	0xA1
+#define USB_VENDOR_REQUEST_GET_STATS		0xA2
+
+/* Interrupt Endpoint status word bitfields */
+#define INT_ENP_RDFO_INT		((u32)BIT(22))
+#define INT_ENP_TXE_INT			((u32)BIT(21))
+#define INT_ENP_TX_DIS_INT		((u32)BIT(19))
+#define INT_ENP_RX_DIS_INT		((u32)BIT(18))
+#define INT_ENP_PHY_INT			((u32)BIT(17))
+#define INT_ENP_MAC_ERR_INT		((u32)BIT(15))
+#define INT_ENP_RX_FIFO_DATA_INT	((u32)BIT(12))
+
+#endif /* _SMSC75XX_H */
-- 
1.6.6.1


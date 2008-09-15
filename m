From: Steve Glendinning <steve.glendinning@smsc.com>
Subject: [PATCH 1/1] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Mon, 15 Sep 2008 16:33:37 +0100
Message-ID: <1221492817-29427-2-git-send-email-steve.glendinning@smsc.com>
References: <1221492817-29427-1-git-send-email-steve.glendinning@smsc.com>
Cc: Ian Saturley <ian.saturley@smsc.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-usb@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [86.54.240.113] ([86.54.240.113]:42657 "EHLO drevil.shawell.net"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753200AbYIOPdu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Sep 2008 11:33:50 -0400
In-Reply-To: <1221492817-29427-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Attached is a driver for SMSC's LAN9500 USB2.0 10/100 ethernet
adapter.

Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>
---
 MAINTAINERS                |    6 +
 drivers/net/usb/Kconfig    |    8 +
 drivers/net/usb/Makefile   |    1 +
 drivers/net/usb/smsc95xx.c | 1211 ++++++++++++++++++++++++++++++++++++++++++++
 drivers/net/usb/smsc95xx.h |  253 +++++++++
 5 files changed, 1479 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/usb/smsc95xx.c
 create mode 100644 drivers/net/usb/smsc95xx.h

diff --git a/MAINTAINERS b/MAINTAINERS
index 0a613cb..f52d541 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -4333,6 +4333,12 @@ L:      linux-usb@vger.kernel.org
 W:	http://www.connecttech.com
 S:	Supported
 
+USB SMSC95XX ETHERNET DRIVER
+P:	Steve Glendinning
+M:	steve.glendinning@smsc.com
+L:	netdev@vger.kernel.org
+S:	Supported
+
 USB SN9C1xx DRIVER
 P:	Luca Risolia
 M:	luca.risolia@studio.unibo.it
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 0973b6e..8ee2103 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -188,6 +188,14 @@ config USB_NET_DM9601
 	  This option adds support for Davicom DM9601 based USB 1.1
 	  10/100 Ethernet adapters.
 
+config USB_NET_SMSC95XX
+	tristate "SMSC LAN95XX based USB 2.0 10/100 ethernet devices"
+	depends on USB_USBNET
+	select CRC32
+	help
+	  This option adds support for SMSC LAN95XX based USB 2.0
+	  10/100 Ethernet adapters.
+
 config USB_NET_GL620A
 	tristate "GeneSys GL620USB-A based cables"
 	depends on USB_USBNET
diff --git a/drivers/net/usb/Makefile b/drivers/net/usb/Makefile
index 24800c1..6ce218d 100644
--- a/drivers/net/usb/Makefile
+++ b/drivers/net/usb/Makefile
@@ -10,6 +10,7 @@ obj-$(CONFIG_USB_HSO)		+= hso.o
 obj-$(CONFIG_USB_NET_AX8817X)	+= asix.o
 obj-$(CONFIG_USB_NET_CDCETHER)	+= cdc_ether.o
 obj-$(CONFIG_USB_NET_DM9601)	+= dm9601.o
+obj-$(CONFIG_USB_NET_SMSC95XX)	+= smsc95xx.o
 obj-$(CONFIG_USB_NET_GL620A)	+= gl620a.o
 obj-$(CONFIG_USB_NET_NET1080)	+= net1080.o
 obj-$(CONFIG_USB_NET_PLUSB)	+= plusb.o
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
new file mode 100644
index 0000000..b7c5fd4
--- /dev/null
+++ b/drivers/net/usb/smsc95xx.c
@@ -0,0 +1,1211 @@
+ /***************************************************************************
+ *
+ * Copyright (C) 2007-2008 SMSC
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
+#include "smsc95xx.h"
+
+#define SMSC_CHIPNAME			"smsc95xx"
+#define SMSC_DRIVER_VERSION		"1.0.2"
+#define HS_USB_PKT_SIZE			(512)
+#define FS_USB_PKT_SIZE			(64)
+#define DEFAULT_HS_BURST_CAP_SIZE	(16 * 1024 + 5 * HS_USB_PKT_SIZE)
+#define DEFAULT_FS_BURST_CAP_SIZE	(6 * 1024 + 33 * FS_USB_PKT_SIZE)
+#define DEFAULT_BULK_IN_DELAY		(0x00002000)
+#define MAX_SINGLE_PACKET_SIZE		(2048)
+#define LAN95XX_EEPROM_MAGIC		(0x9500)
+#define EEPROM_MAC_OFFSET		(0x01)
+#define DEFAULT_RX_CSUM_ENABLE		(true)
+#define SMSC95XX_INTERNAL_PHY_ID	(1)
+#define SMSC95XX_TX_OVERHEAD		(8)
+
+struct smsc95xx_priv {
+	u32 mac_cr;
+	spinlock_t mac_cr_lock;
+	bool use_rx_csum;
+};
+
+struct usb_context {
+	struct usb_ctrlrequest req;
+	struct completion notify;
+	struct usbnet *dev;
+};
+
+u32 debug_mode;
+module_param(debug_mode, uint, 0);
+MODULE_PARM_DESC(debug_mode, "enable/disable debug messages");
+
+int turbo_mode = true;
+module_param(turbo_mode, bool, 0);
+MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx transaction");
+
+static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
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
+		devwarn(dev, "Failed to read register index 0x%08x", index);
+
+	le32_to_cpus(buf);
+	*data = *buf;
+	kfree(buf);
+
+	return ret;
+}
+
+static int smsc95xx_write_reg(struct usbnet *dev, u32 index, u32 data)
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
+		devwarn(dev, "Failed to write register index 0x%08x", index);
+
+	kfree(buf);
+
+	return ret;
+}
+
+/* Loop until the read is completed with timeout
+ * called with phy_mutex held */
+static int smsc95xx_phy_wait_not_busy(struct usbnet *dev)
+{
+	int i;
+	u32 val;
+
+	for (i = 0; i < 100; i++) {
+		smsc95xx_read_reg(dev, MII_ADDR, &val);
+		if (!(val & MII_BUSY_))
+			return 0;
+		udelay(1);
+	}
+
+	return -EIO;
+}
+
+static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u32 val, addr;
+
+	mutex_lock(&dev->phy_mutex);
+
+	/* confirm MII not busy */
+	if (smsc95xx_phy_wait_not_busy(dev)) {
+		devwarn(dev, "MII is busy in smsc95xx_mdio_read");
+		mutex_unlock(&dev->phy_mutex);
+		return -EIO;
+	}
+
+	/* set the address, index & direction (read from PHY) */
+	phy_id &= dev->mii.phy_id_mask;
+	idx &= dev->mii.reg_num_mask;
+	addr = (phy_id << 11) | (idx << 6) | MII_READ_;
+	smsc95xx_write_reg(dev, MII_ADDR, addr);
+
+	if (smsc95xx_phy_wait_not_busy(dev)) {
+		devwarn(dev, "Timed out reading MII reg %02X", idx);
+		mutex_unlock(&dev->phy_mutex);
+		return -EIO;
+	}
+
+	smsc95xx_read_reg(dev, MII_DATA, &val);
+
+	mutex_unlock(&dev->phy_mutex);
+
+	return (u16)(val & 0xFFFF);
+}
+
+static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
+				int regval)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u32 val, addr;
+
+	mutex_lock(&dev->phy_mutex);
+
+	/* confirm MII not busy */
+	if (smsc95xx_phy_wait_not_busy(dev)) {
+		devwarn(dev, "MII is busy in smsc95xx_mdio_write");
+		mutex_unlock(&dev->phy_mutex);
+		return;
+	}
+
+	val = regval;
+	smsc95xx_write_reg(dev, MII_DATA, val);
+
+	/* set the address, index & direction (write to PHY) */
+	phy_id &= dev->mii.phy_id_mask;
+	idx &= dev->mii.reg_num_mask;
+	addr = (phy_id << 11) | (idx << 6) | MII_WRITE_;
+	smsc95xx_write_reg(dev, MII_ADDR, addr);
+
+	if (smsc95xx_phy_wait_not_busy(dev))
+		devwarn(dev, "Timed out writing MII reg %02X", idx);
+
+	mutex_unlock(&dev->phy_mutex);
+}
+
+static int smsc95xx_wait_eeprom(struct usbnet *dev)
+{
+	u32 val;
+	int i;
+
+	for (i = 0; i < 1000; i++) {
+		smsc95xx_read_reg(dev, E2P_CMD, &val);
+		if (!(val & E2P_CMD_BUSY_) || (val & E2P_CMD_TIMEOUT_))
+			break;
+		udelay(40);
+	}
+
+	if (val & (E2P_CMD_TIMEOUT_ | E2P_CMD_BUSY_)) {
+		devwarn(dev, "EEPROM read operation timeout");
+		return -EIO;
+	}
+
+	return 0;
+}
+
+static int smsc95xx_read_eeprom(struct usbnet *dev, u32 offset, u32 length,
+				u8 *data)
+{
+	u32 val;
+	int i, ret;
+
+	BUG_ON(!dev);
+	BUG_ON(!data);
+
+	/* confirm eeprom not busy */
+	for (i = 0; i < 1000; i++) {
+		smsc95xx_read_reg(dev, E2P_CMD, &val);
+		if (!(val & E2P_CMD_BUSY_) || !(val & E2P_CMD_LOADED_))
+			break;
+		udelay(40);
+	}
+
+	if (!(val & E2P_CMD_LOADED_)) {
+		devwarn(dev, "No EEPROM present");
+		return -EIO;
+	}
+
+	if (val & E2P_CMD_BUSY_) {
+		devwarn(dev, "EEPROM is busy");
+		return -EIO;
+	}
+
+	for (i = 0; i < length; i++) {
+		val = E2P_CMD_BUSY_ | E2P_CMD_READ_ | (offset & E2P_CMD_ADDR_);
+		smsc95xx_write_reg(dev, E2P_CMD, val);
+
+		ret = smsc95xx_wait_eeprom(dev);
+		if (ret < 0)
+			return ret;
+
+		smsc95xx_read_reg(dev, E2P_DATA, &val);
+
+		data[i] = val & 0xFF;
+		offset++;
+	}
+
+	return 0;
+}
+
+static int smsc95xx_write_eeprom(struct usbnet *dev, u32 offset, u32 length,
+				 u8 *data)
+{
+	u32 val;
+	int i, ret;
+
+	BUG_ON(!dev);
+	BUG_ON(!data);
+
+	/* confirm eeprom not busy */
+	for (i = 0; i < 1000; i++) {
+		smsc95xx_read_reg(dev, E2P_CMD, &val);
+		if (!(val & E2P_CMD_BUSY_) || !(val & E2P_CMD_LOADED_))
+			break;
+		udelay(40);
+	}
+
+	if (!(val & E2P_CMD_LOADED_)) {
+		devwarn(dev, "No EEPROM present");
+		return -EIO;
+	}
+
+	if (val & E2P_CMD_BUSY_) {
+		devwarn(dev, "EEPROM is busy");
+		return -EIO;
+	}
+
+	/* Issue write/erase enable command */
+	val = E2P_CMD_BUSY_ | E2P_CMD_EWEN_;
+	smsc95xx_write_reg(dev, E2P_CMD, val);
+
+	ret = smsc95xx_wait_eeprom(dev);
+	if (ret < 0)
+		return ret;
+
+	for (i = 0; i < length; i++) {
+
+		/* Fill data register */
+		val = data[i];
+		smsc95xx_write_reg(dev, E2P_DATA, val);
+
+		/* Send "write" command */
+		val = E2P_CMD_BUSY_ | E2P_CMD_WRITE_ | (offset & E2P_CMD_ADDR_);
+		smsc95xx_write_reg(dev, E2P_CMD, val);
+
+		ret = smsc95xx_wait_eeprom(dev);
+		if (ret < 0)
+			return ret;
+
+		offset++;
+	}
+
+	return 0;
+}
+
+static void smsc95xx_async_cmd_callback(struct urb *urb, struct pt_regs *regs)
+{
+	struct usb_context *usb_context = urb->context;
+	struct usbnet *dev = usb_context->dev;
+
+	if (urb->status < 0)
+		devwarn(dev, "async callback failed with %d", urb->status);
+
+	complete(&usb_context->notify);
+
+	kfree(usb_context);
+	usb_free_urb(urb);
+}
+
+static int smsc95xx_write_reg_async(struct usbnet *dev, u32 index, u32 *data)
+{
+	struct usb_context *usb_context;
+	int status;
+	struct urb *urb;
+	const u32 size = 4;
+
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (!urb) {
+		devwarn(dev, "Error allocating URB");
+		return -ENOMEM;
+	}
+
+	usb_context = kmalloc(sizeof(struct usb_context), GFP_ATOMIC);
+	if (usb_context == NULL) {
+		devwarn(dev, "Error allocating control msg");
+		usb_free_urb(urb);
+		return -ENOMEM;
+	}
+
+	usb_context->req.bRequestType =
+		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
+	usb_context->req.bRequest = USB_VENDOR_REQUEST_WRITE_REGISTER;
+	usb_context->req.wValue = 00;
+	usb_context->req.wIndex = cpu_to_le32(index);
+	usb_context->req.wLength = cpu_to_le32(size);
+	init_completion(&usb_context->notify);
+
+	usb_fill_control_urb(urb, dev->udev, usb_sndctrlpipe(dev->udev, 0),
+		(void *)&usb_context->req, data, size,
+		(usb_complete_t)smsc95xx_async_cmd_callback,
+		(void *)usb_context);
+
+	status = usb_submit_urb(urb, GFP_ATOMIC);
+	if (status < 0) {
+		devwarn(dev, "Error submitting control msg, sts=%d", status);
+		kfree(usb_context);
+		usb_free_urb(urb);
+	}
+
+	return status;
+}
+
+/* returns hash bit number for given MAC address
+ * example:
+ * 01 00 5E 00 00 01 -> returns bit number 31 */
+static unsigned int smsc95xx_hash(char addr[ETH_ALEN])
+{
+	return (ether_crc(ETH_ALEN, addr) >> 26) & 0x3f;
+}
+
+static void smsc95xx_set_multicast(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	u32 hash_hi = 0;
+	u32 hash_lo = 0;
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
+
+	if (dev->net->flags & IFF_PROMISC) {
+		if (netif_msg_drv(dev))
+			devdbg(dev, "promiscuous mode enabled");
+		pdata->mac_cr |= MAC_CR_PRMS_;
+		pdata->mac_cr &= ~(MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+	} else if (dev->net->flags & IFF_ALLMULTI) {
+		if (netif_msg_drv(dev))
+			devdbg(dev, "receive all multicast enabled");
+		pdata->mac_cr |= MAC_CR_MCPAS_;
+		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
+	} else if (dev->net->mc_count > 0) {
+		struct dev_mc_list *mc_list = dev->net->mc_list;
+		int count = 0;
+
+		pdata->mac_cr |= MAC_CR_HPFILT_;
+		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_MCPAS_);
+
+		while (mc_list) {
+			count++;
+			if (mc_list->dmi_addrlen == ETH_ALEN) {
+				u32 bitnum = smsc95xx_hash(mc_list->dmi_addr);
+				u32 mask = 0x01 << (bitnum & 0x1F);
+				if (bitnum & 0x20)
+					hash_hi |= mask;
+				else
+					hash_lo |= mask;
+			} else {
+				devwarn(dev, "dmi_addrlen != 6");
+			}
+			mc_list = mc_list->next;
+		}
+
+		if (count != ((u32)dev->net->mc_count))
+			devwarn(dev, "mc_count != dev->mc_count");
+
+		if (netif_msg_drv(dev))
+			devdbg(dev, "HASHH=0x%08X, HASHL=0x%08X", hash_hi,
+				hash_lo);
+	} else {
+		if (netif_msg_drv(dev))
+			devdbg(dev, "receive own packets only");
+		pdata->mac_cr &=
+			~(MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
+	}
+
+	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
+
+	/* Initiate async writes, as we can't wait for completion here */
+	smsc95xx_write_reg_async(dev, HASHH, &hash_hi);
+	smsc95xx_write_reg_async(dev, HASHL, &hash_lo);
+	smsc95xx_write_reg_async(dev, MAC_CR, &pdata->mac_cr);
+}
+
+static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev,
+					    struct ethtool_cmd *ecmd)
+{
+	u32 flow, afc_cfg = 0;
+
+	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
+	if (ret < 0) {
+		devwarn(dev, "error reading AFC_CFG");
+		return;
+	}
+
+	if (ecmd->duplex == DUPLEX_FULL) {
+		if (ecmd->advertising & ADVERTISED_Pause) {
+			/* Both ends support symmetric pause, enable
+			 * PAUSE receive and transmit */
+			if (netif_msg_link(dev))
+				devdbg(dev, "full duplex symmetric pause");
+			flow = 0xFFFF0002;
+			afc_cfg |= 0xF;
+		} else if (ecmd->advertising & ADVERTISED_Asym_Pause) {
+			/* Both ends support asymmetric pause, Enable PAUSE
+			 * receive, disable PAUSE transmit */
+			if (netif_msg_link(dev))
+				devdbg(dev, "full duplex asymmetric pause");
+			flow = 0xFFFF0002;
+			afc_cfg &= ~0xF;
+		} else {
+			/* Disable PAUSE receive and transmit */
+			if (netif_msg_link(dev))
+				devdbg(dev, "full duplex no pause");
+			flow = 0;
+			afc_cfg &= ~0xF;
+		}
+	} else {
+		if (netif_msg_link(dev))
+			devdbg(dev, "half duplex");
+		flow = 0;
+		afc_cfg |= 0xF;
+	}
+
+	smsc95xx_write_reg(dev, FLOW, flow);
+	smsc95xx_write_reg(dev,	AFC_CFG, afc_cfg);
+}
+
+static int smsc95xx_link_reset(struct usbnet *dev)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	struct ethtool_cmd ecmd;
+	unsigned long flags;
+	u32 intdata;
+
+	/* clear interrupt status */
+	smsc95xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
+	intdata = 0xFFFFFFFF;
+	smsc95xx_write_reg(dev, INT_STS, intdata);
+
+	mii_check_media(&dev->mii, 1, 1);
+	mii_ethtool_gset(&dev->mii, &ecmd);
+
+	if (netif_msg_link(dev))
+		devdbg(dev, "speed: %d duplex: %d", ecmd.speed, ecmd.duplex);
+
+	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
+	if (ecmd.duplex != DUPLEX_FULL) {
+		pdata->mac_cr &= ~MAC_CR_FDPX_;
+		pdata->mac_cr |= MAC_CR_RCVOWN_;
+	} else {
+		pdata->mac_cr &= ~MAC_CR_RCVOWN_;
+		pdata->mac_cr |= MAC_CR_FDPX_;
+	}
+	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
+
+	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+
+	smsc95xx_phy_update_flowcontrol(dev, &ecmd);
+
+	return 0;
+}
+
+static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
+{
+	u32 intdata;
+
+	if (urb->actual_length != 4) {
+		devwarn(dev, "unexpected urb length %d", urb->actual_length);
+		return;
+	}
+
+	memcpy(&intdata, urb->transfer_buffer, 4);
+	le32_to_cpus(intdata);
+
+	if (netif_msg_link(dev))
+		devdbg(dev, "intdata: 0x%08X", intdata);
+
+	if (intdata & INT_ENP_PHY_INT_)
+		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+	else
+		devwarn(dev, "unexpected interrupt, intdata=0x%08X", intdata);
+}
+
+/* Enable or disable Rx checksum offload engine */
+static int smsc95xx_set_rx_csum(struct usbnet *dev, bool enable)
+{
+	u32 read_buf;
+	int ret = smsc95xx_read_reg(dev, COE_CR, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read COE_CR: %d", ret);
+		return ret;
+	}
+
+	if (enable)
+		read_buf |= Rx_COE_EN_;
+	else
+		read_buf &= ~Rx_COE_EN_;
+
+	ret = smsc95xx_write_reg(dev, COE_CR, read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write COE_CR: %d", ret);
+		return ret;
+	}
+
+	if (netif_msg_hw(dev))
+		devdbg(dev, "COE_CR = 0x%08x", read_buf);
+	return 0;
+}
+
+static int smsc95xx_ethtool_get_eeprom_len(struct net_device *net)
+{
+	return MAX_EEPROM_SIZE;
+}
+
+static int smsc95xx_ethtool_get_eeprom(struct net_device *netdev,
+				       struct ethtool_eeprom *ee, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	ee->magic = LAN95XX_EEPROM_MAGIC;
+
+	return smsc95xx_read_eeprom(dev, ee->offset, ee->len, data);
+}
+
+static int smsc95xx_ethtool_set_eeprom(struct net_device *netdev,
+				       struct ethtool_eeprom *ee, u8 *data)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	if (ee->magic != LAN95XX_EEPROM_MAGIC) {
+		devwarn(dev, "EEPROM: magic value mismatch, magic = 0x%x",
+			ee->magic);
+		return -EINVAL;
+	}
+
+	return smsc95xx_write_eeprom(dev, ee->offset, ee->len, data);
+}
+
+static u32 smsc95xx_ethtool_get_rx_csum(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	return pdata->use_rx_csum ? true : false;
+}
+
+static int smsc95xx_ethtool_set_rx_csum(struct net_device *netdev, u32 val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	pdata->use_rx_csum = val ? true : false;
+
+	return smsc95xx_set_rx_csum(dev, pdata->use_rx_csum);
+}
+
+static struct ethtool_ops smsc95xx_ethtool_ops = {
+	.get_link	= usbnet_get_link,
+	.nway_reset	= usbnet_nway_reset,
+	.get_drvinfo	= usbnet_get_drvinfo,
+	.get_msglevel	= usbnet_get_msglevel,
+	.set_msglevel	= usbnet_set_msglevel,
+	.get_settings	= usbnet_get_settings,
+	.set_settings	= usbnet_set_settings,
+	.get_eeprom_len	= smsc95xx_ethtool_get_eeprom_len,
+	.get_eeprom	= smsc95xx_ethtool_get_eeprom,
+	.set_eeprom	= smsc95xx_ethtool_set_eeprom,
+	.get_rx_csum	= smsc95xx_ethtool_get_rx_csum,
+	.set_rx_csum	= smsc95xx_ethtool_set_rx_csum,
+};
+
+static int smsc95xx_ioctl(struct net_device *netdev, struct ifreq *rq, int cmd)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+
+	if (!netif_running(netdev))
+		return -EINVAL;
+
+	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
+}
+
+static void smsc95xx_init_mac_address(struct usbnet *dev)
+{
+	/* try reading mac address from EEPROM */
+	if (smsc95xx_read_eeprom(dev, EEPROM_MAC_OFFSET, ETH_ALEN,
+			dev->net->dev_addr) == 0) {
+		if (is_valid_ether_addr(dev->net->dev_addr)) {
+			/* eeprom values are valid so use them */
+			if (netif_msg_ifup(dev))
+				devdbg(dev, "MAC address read from EEPROM");
+			return;
+		}
+	}
+
+	/* no eeprom, or eeprom values are invalid. generate random MAC */
+	random_ether_addr(dev->net->dev_addr);
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "MAC address set to random_ether_addr");
+}
+
+static int smsc95xx_set_mac_address(struct usbnet *dev)
+{
+	u32 addr_lo = dev->net->dev_addr[0] | dev->net->dev_addr[1] << 8 |
+		dev->net->dev_addr[2] << 16 | dev->net->dev_addr[3] << 24;
+	u32 addr_hi = dev->net->dev_addr[4] | dev->net->dev_addr[5] << 8;
+	int ret;
+
+	ret = smsc95xx_write_reg(dev, ADDRL, addr_lo);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write ADDRL: %d", ret);
+		return ret;
+	}
+
+	ret = smsc95xx_write_reg(dev, ADDRH, addr_hi);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write ADDRH: %d", ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+/* starts the TX path */
+static void smsc95xx_start_tx_path(struct usbnet *dev)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	unsigned long flags;
+	u32 reg_val;
+
+	/* Enable Tx at MAC */
+	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
+	pdata->mac_cr |= MAC_CR_TXEN_;
+	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
+
+	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+
+	/* Enable Tx at SCSRs */
+	reg_val = TX_CFG_ON_;
+	smsc95xx_write_reg(dev, TX_CFG, reg_val);
+}
+
+/* Starts the Receive path */
+static void smsc95xx_start_rx_path(struct usbnet *dev)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	unsigned long flags;
+
+	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
+	pdata->mac_cr |= MAC_CR_RXEN_;
+	spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
+
+	smsc95xx_write_reg(dev, MAC_CR, pdata->mac_cr);
+}
+
+static int smsc95xx_phy_initialize(struct usbnet *dev)
+{
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = smsc95xx_mdio_read;
+	dev->mii.mdio_write = smsc95xx_mdio_write;
+	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.reg_num_mask = 0x1f;
+	dev->mii.phy_id = SMSC95XX_INTERNAL_PHY_ID;
+
+	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP |
+		ADVERTISE_PAUSE_ASYM);
+
+	/* read to clear */
+	smsc95xx_mdio_read(dev->net, dev->mii.phy_id, PHY_INT_SRC);
+
+	smsc95xx_mdio_write(dev->net, dev->mii.phy_id, PHY_INT_MASK,
+		PHY_INT_MASK_DEFAULT_);
+	mii_nway_restart(&dev->mii);
+
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "phy initialised succesfully");
+	return 0;
+}
+
+static int smsc95xx_reset(struct usbnet *dev)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	u32 read_buf, write_buf, burst_cap;
+	int ret = 0, timeout;
+	DECLARE_MAC_BUF(mac);
+
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "entering smsc95xx_reset");
+
+	write_buf = HW_CFG_LRST_;
+	ret = smsc95xx_write_reg(dev, HW_CFG, write_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write HW_CFG_LRST_ bit in HW_CFG "
+			"register, ret = %d", ret);
+		return ret;
+	}
+
+	timeout = 0;
+	do {
+		ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
+		if (ret < 0) {
+			devwarn(dev, "Failed to read HW_CFG: %d", ret);
+			return ret;
+		}
+		msleep(10);
+		timeout++;
+	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
+
+	if (timeout >= 100) {
+		devwarn(dev, "timeout waiting for completion of Lite Reset");
+		return ret;
+	}
+
+	write_buf = PM_CTL_PHY_RST_;
+	ret = smsc95xx_write_reg(dev, PM_CTRL, write_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write PM_CTRL: %d", ret);
+		return ret;
+	}
+
+	timeout = 0;
+	do {
+		ret = smsc95xx_read_reg(dev, PM_CTRL, &read_buf);
+		if (ret < 0) {
+			devwarn(dev, "Failed to read PM_CTRL: %d", ret);
+			return ret;
+		}
+		msleep(10);
+		timeout++;
+	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
+
+	if (timeout >= 100) {
+		devwarn(dev, "timeout waiting for PHY Reset");
+		return ret;
+	}
+
+	smsc95xx_init_mac_address(dev);
+
+	ret = smsc95xx_set_mac_address(dev);
+	if (ret < 0)
+		return ret;
+
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "MAC Address: %s",
+			print_mac(mac, dev->net->dev_addr));
+
+	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		return ret;
+	}
+
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "Read Value from HW_CFG : 0x%08x", read_buf);
+
+	read_buf |= HW_CFG_BIR_;
+
+	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write HW_CFG_BIR_ bit in HW_CFG "
+			"register, ret = %d", ret);
+		return ret;
+	}
+
+	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		return ret;
+	}
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "Read Value from HW_CFG after writing "
+			"HW_CFG_BIR_: 0x%08x", read_buf);
+
+	if (!turbo_mode) {
+		burst_cap = 0;
+		dev->rx_urb_size = MAX_SINGLE_PACKET_SIZE;
+	} else if (dev->udev->speed == USB_SPEED_HIGH) {
+		burst_cap = DEFAULT_HS_BURST_CAP_SIZE / HS_USB_PKT_SIZE;
+		dev->rx_urb_size = DEFAULT_HS_BURST_CAP_SIZE;
+	} else {
+		burst_cap = DEFAULT_FS_BURST_CAP_SIZE / FS_USB_PKT_SIZE;
+		dev->rx_urb_size = DEFAULT_FS_BURST_CAP_SIZE;
+	}
+
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "rx_urb_size=%ld", (ulong)dev->rx_urb_size);
+
+	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write BURST_CAP: %d", ret);
+		return ret;
+	}
+
+	ret = smsc95xx_read_reg(dev, BURST_CAP, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read BURST_CAP: %d", ret);
+		return ret;
+	}
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "Read Value from BURST_CAP after writing: 0x%08x",
+			read_buf);
+
+	read_buf = DEFAULT_BULK_IN_DELAY;
+	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, read_buf);
+	if (ret < 0) {
+		devwarn(dev, "ret = %d", ret);
+		return ret;
+	}
+
+	ret = smsc95xx_read_reg(dev, BULK_IN_DLY, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read BULK_IN_DLY: %d", ret);
+		return ret;
+	}
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "Read Value from BULK_IN_DLY after writing: "
+			"0x%08x", read_buf);
+
+	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		return ret;
+	}
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "Read Value from HW_CFG: 0x%08x", read_buf);
+
+	if (turbo_mode)
+		read_buf |= (HW_CFG_MEF_ | HW_CFG_BCE_);
+
+	read_buf &= ~HW_CFG_RXDOFF_;
+
+	/* set Rx data offset=2, Make IP header aligns on word boundary. */
+	read_buf |= NET_IP_ALIGN << 9;
+
+	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write HW_CFG register, ret=%d", ret);
+		return ret;
+	}
+
+	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		return ret;
+	}
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "Read Value from HW_CFG after writing: 0x%08x",
+			read_buf);
+
+	write_buf = 0xFFFFFFFF;
+	ret = smsc95xx_write_reg(dev, INT_STS, write_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write INT_STS register, ret=%d", ret);
+		return ret;
+	}
+
+	ret = smsc95xx_read_reg(dev, ID_REV, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read ID_REV: %d", ret);
+		return ret;
+	}
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "ID_REV = 0x%08x", read_buf);
+
+	/* Init Tx */
+	write_buf = 0;
+	ret = smsc95xx_write_reg(dev, FLOW, write_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write FLOW: %d", ret);
+		return ret;
+	}
+
+	read_buf = AFC_CFG_DEFAULT;
+	ret = smsc95xx_write_reg(dev, AFC_CFG, read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write AFC_CFG: %d", ret);
+		return ret;
+	}
+
+	/* Don't need mac_cr_lock during initialisation */
+	ret = smsc95xx_read_reg(dev, MAC_CR, &pdata->mac_cr);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read MAC_CR: %d", ret);
+		return ret;
+	}
+
+	/* Init Rx */
+	/* Set Vlan */
+	write_buf = (u32)ETH_P_8021Q;
+	ret = smsc95xx_write_reg(dev, VLAN1, write_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write VAN1: %d", ret);
+		return ret;
+	}
+
+	/* Enable or disable Rx checksum offload engine */
+	ret = smsc95xx_set_rx_csum(dev, pdata->use_rx_csum);
+	if (ret < 0) {
+		devwarn(dev, "Failed to set Rx csum offload: %d", ret);
+		return ret;
+	}
+
+	smsc95xx_set_multicast(dev->net);
+
+	if (smsc95xx_phy_initialize(dev) < 0)
+		return -EIO;
+
+	ret = smsc95xx_read_reg(dev, INT_EP_CTL, &read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to read INT_EP_CTL: %d", ret);
+		return ret;
+	}
+
+	/* enable PHY interrupts */
+	read_buf |= INT_EP_CTL_PHY_INT_;
+
+	ret = smsc95xx_write_reg(dev, INT_EP_CTL, read_buf);
+	if (ret < 0) {
+		devwarn(dev, "Failed to write INT_EP_CTL: %d", ret);
+		return ret;
+	}
+
+	smsc95xx_start_tx_path(dev);
+	smsc95xx_start_rx_path(dev);
+
+	if (netif_msg_ifup(dev))
+		devdbg(dev, "smsc95xx_reset, return 0");
+	return 0;
+}
+
+static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct smsc95xx_priv *pdata = NULL;
+	int ret;
+
+	printk(KERN_INFO SMSC_CHIPNAME " v" SMSC_DRIVER_VERSION "\n");
+
+	ret = usbnet_get_endpoints(dev, intf);
+	if (ret < 0) {
+		devwarn(dev, "usbnet_get_endpoints failed: %d", ret);
+		return ret;
+	}
+
+	dev->data[0] = (unsigned long)kzalloc(sizeof(struct smsc95xx_priv),
+		GFP_KERNEL);
+
+	pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	if (!pdata) {
+		devwarn(dev, "Unable to allocate struct smsc95xx_priv");
+		return -ENOMEM;
+	}
+
+	spin_lock_init(&pdata->mac_cr_lock);
+
+	pdata->use_rx_csum = DEFAULT_RX_CSUM_ENABLE;
+
+	/* Init all registers */
+	ret = smsc95xx_reset(dev);
+
+	dev->net->do_ioctl = smsc95xx_ioctl;
+	dev->net->ethtool_ops = &smsc95xx_ethtool_ops;
+	dev->net->set_multicast_list = smsc95xx_set_multicast;
+	dev->net->flags |= IFF_MULTICAST;
+	dev->net->hard_header_len += SMSC95XX_TX_OVERHEAD;
+	return 0;
+}
+
+static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+	if (pdata) {
+		if (netif_msg_ifdown(dev))
+			devdbg(dev, "free pdata");
+		kfree(pdata);
+		pdata = NULL;
+		dev->data[0] = 0;
+	}
+}
+
+static void smsc95xx_rx_csum_offload(struct sk_buff *skb)
+{
+	skb->csum = *(u16 *)(skb_tail_pointer(skb) - 2);
+	skb->ip_summed = CHECKSUM_COMPLETE;
+	skb_trim(skb, skb->len - 2);
+}
+
+static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
+
+	while (skb->len > 0) {
+		u32 header, align_count;
+		struct sk_buff *ax_skb;
+		unsigned char *packet;
+		u16 size;
+
+		memcpy(&header, skb->data, sizeof(header));
+		le32_to_cpus(&header);
+		skb_pull(skb, 4 + NET_IP_ALIGN);
+		packet = skb->data;
+
+		/* get the packet length */
+		size = (u16)((header & RX_STS_FL_) >> 16);
+		align_count = (4 - ((size + NET_IP_ALIGN) % 4)) % 4;
+
+		if (unlikely(header & RX_STS_ES_)) {
+			if (netif_msg_rx_err(dev))
+				devdbg(dev, "Error header=0x%08x", header);
+			dev->stats.rx_errors++;
+			dev->stats.rx_dropped++;
+
+			if (header & RX_STS_CRC_) {
+				dev->stats.rx_crc_errors++;
+			} else {
+				if (header & (RX_STS_TL_ | RX_STS_RF_))
+					dev->stats.rx_frame_errors++;
+
+				if ((header & RX_STS_LE_) &&
+					(!(header & RX_STS_FT_)))
+					dev->stats.rx_length_errors++;
+			}
+		} else {
+			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */
+			if (unlikely(size > (ETH_FRAME_LEN + 12))) {
+				if (netif_msg_rx_err(dev))
+					devdbg(dev, "size err header=0x%08x",
+						header);
+				return 0;
+			}
+
+			/* last frame in this batch */
+			if (skb->len == size) {
+				if (pdata->use_rx_csum)
+					smsc95xx_rx_csum_offload(skb);
+
+				skb->truesize = size + sizeof(struct sk_buff);
+
+				return 1;
+			}
+
+			ax_skb = skb_clone(skb, GFP_ATOMIC);
+			if (unlikely(!ax_skb)) {
+				devwarn(dev, "Error allocating skb");
+				return 0;
+			}
+
+			ax_skb->len = size;
+			ax_skb->data = packet;
+			skb_set_tail_pointer(ax_skb, size);
+
+			if (pdata->use_rx_csum)
+				smsc95xx_rx_csum_offload(ax_skb);
+
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
+		devwarn(dev, "invalid rx length<0 %d", skb->len);
+		return 0;
+	}
+
+	return 1;
+}
+
+static struct sk_buff *smsc95xx_tx_fixup(struct usbnet *dev,
+					 struct sk_buff *skb, gfp_t flags)
+{
+	u32 tx_cmd_a, tx_cmd_b;
+
+	if (skb_headroom(skb) < SMSC95XX_TX_OVERHEAD) {
+		struct sk_buff *skb2 = skb_copy_expand(skb,
+			SMSC95XX_TX_OVERHEAD, 0, flags);
+		dev_kfree_skb_any(skb);
+		skb = skb2;
+		if (!skb)
+			return NULL;
+	}
+
+	skb_push(skb, 4);
+	tx_cmd_b = (u32)(skb->len - 4);
+	cpu_to_le32s(&tx_cmd_b);
+	memcpy(skb->data, &tx_cmd_b, 4);
+
+	skb_push(skb, 4);
+	tx_cmd_a = (u32)(skb->len - 8) | TX_CMD_A_FIRST_SEG_ |
+		TX_CMD_A_LAST_SEG_;
+	cpu_to_le32s(&tx_cmd_a);
+	memcpy(skb->data, &tx_cmd_a, 4);
+
+	return skb;
+}
+
+static const struct driver_info smsc95xx_info = {
+	.description	= "smsc95xx USB 2.0 Ethernet",
+	.bind		= smsc95xx_bind,
+	.unbind		= smsc95xx_unbind,
+	.link_reset	= smsc95xx_link_reset,
+	.reset		= smsc95xx_reset,
+	.rx_fixup	= smsc95xx_rx_fixup,
+	.tx_fixup	= smsc95xx_tx_fixup,
+	.status		= smsc95xx_status,
+	.flags		= FLAG_ETHER,
+};
+
+static const struct usb_device_id products[] = {
+	{
+		/* SMSC9500 USB Ethernet Device */
+		USB_DEVICE(0x0424, 0x9500),
+		.driver_info = (unsigned long) &smsc95xx_info,
+	},
+	{ },		/* END */
+};
+MODULE_DEVICE_TABLE(usb, products);
+
+static struct usb_driver smsc95xx_driver = {
+	.name		= "smsc95xx",
+	.id_table	= products,
+	.probe		= usbnet_probe,
+	.suspend	= usbnet_suspend,
+	.resume		= usbnet_resume,
+	.disconnect	= usbnet_disconnect,
+};
+
+static int __init smsc95xx_init(void)
+{
+	return usb_register(&smsc95xx_driver);
+}
+module_init(smsc95xx_init);
+
+static void __exit smsc95xx_exit(void)
+{
+	usb_deregister(&smsc95xx_driver);
+}
+module_exit(smsc95xx_exit);
+
+MODULE_AUTHOR("Nancy Lin");
+MODULE_AUTHOR("Steve Glendinning <steve.glendinning@smsc.com>");
+MODULE_DESCRIPTION("SMSC95XX USB 2.0 Ethernet Devices");
+MODULE_LICENSE("GPL");
diff --git a/drivers/net/usb/smsc95xx.h b/drivers/net/usb/smsc95xx.h
new file mode 100644
index 0000000..66b5c84
--- /dev/null
+++ b/drivers/net/usb/smsc95xx.h
@@ -0,0 +1,253 @@
+ /***************************************************************************
+ *
+ * Copyright (C) 2007-2008 SMSC
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
+#ifndef _SMSC95XX_H
+#define _SMSC95XX_H
+
+/* Tx command words */
+#define TX_CMD_A_DATA_OFFSET_		(0x001F0000)
+#define TX_CMD_A_FIRST_SEG_		(0x00002000)
+#define TX_CMD_A_LAST_SEG_		(0x00001000)
+#define TX_CMD_A_BUF_SIZE_		(0x000007FF)
+
+#define TX_CMD_B_CSUM_ENABLE		(0x00004000)
+#define TX_CMD_B_ADD_CRC_DISABLE_	(0x00002000)
+#define TX_CMD_B_DISABLE_PADDING_	(0x00001000)
+#define TX_CMD_B_PKT_BYTE_LENGTH_	(0x000007FF)
+
+/* Rx status word */
+#define RX_STS_FF_			(0x40000000)	/* Filter Fail */
+#define RX_STS_FL_			(0x3FFF0000)	/* Frame Length */
+#define RX_STS_ES_			(0x00008000)	/* Error Summary */
+#define RX_STS_BF_			(0x00002000)	/* Broadcast Frame */
+#define RX_STS_LE_			(0x00001000)	/* Length Error */
+#define RX_STS_RF_			(0x00000800)	/* Runt Frame */
+#define RX_STS_MF_			(0x00000400)	/* Multicast Frame */
+#define RX_STS_TL_			(0x00000080)	/* Frame too long */
+#define RX_STS_CS_			(0x00000040)	/* Collision Seen */
+#define RX_STS_FT_			(0x00000020)	/* Frame Type */
+#define RX_STS_RW_			(0x00000010)	/* Receive Watchdog */
+#define RX_STS_ME_			(0x00000008)	/* Mii Error */
+#define RX_STS_DB_			(0x00000004)	/* Dribbling */
+#define RX_STS_CRC_			(0x00000002)	/* CRC Error */
+
+/* SCSRs */
+#define ID_REV				(0x00)
+#define ID_REV_CHIP_ID_MASK_		(0xFFFF0000)
+#define ID_REV_CHIP_REV_MASK_		(0x0000FFFF)
+#define ID_REV_CHIP_ID_9500_		(0x9500)
+
+#define INT_STS				(0x08)
+#define INT_STS_TX_STOP_		(0x00020000)
+#define INT_STS_RX_STOP_		(0x00010000)
+#define INT_STS_PHY_INT_		(0x00008000)
+#define INT_STS_TXE_			(0x00004000)
+#define INT_STS_TDFU_			(0x00002000)
+#define INT_STS_TDFO_			(0x00001000)
+#define INT_STS_RXDF_			(0x00000800)
+#define INT_STS_GPIOS_			(0x000007FF)
+
+#define RX_CFG				(0x0C)
+#define RX_FIFO_FLUSH_			(0x00000001)
+
+#define TX_CFG				(0x10)
+#define TX_CFG_ON_			(0x00000004)
+#define TX_CFG_STOP_			(0x00000002)
+#define TX_CFG_FIFO_FLUSH_		(0x00000001)
+
+#define HW_CFG				(0x14)
+#define HW_CFG_BIR_			(0x00001000)
+#define HW_CFG_LEDB_			(0x00000800)
+#define HW_CFG_RXDOFF_			(0x00000600)
+#define HW_CFG_DRP_			(0x00000040)
+#define HW_CFG_MEF_			(0x00000020)
+#define HW_CFG_LRST_			(0x00000008)
+#define HW_CFG_PSEL_			(0x00000004)
+#define HW_CFG_BCE_			(0x00000002)
+#define HW_CFG_SRST_			(0x00000001)
+
+#define PM_CTRL				(0x20)
+#define PM_CTL_DEV_RDY_			(0x00000080)
+#define PM_CTL_SUS_MODE_		(0x00000060)
+#define PM_CTL_SUS_MODE_0		(0x00000000)
+#define PM_CTL_SUS_MODE_1		(0x00000020)
+#define PM_CTL_SUS_MODE_2		(0x00000060)
+#define PM_CTL_PHY_RST_			(0x00000010)
+#define PM_CTL_WOL_EN_			(0x00000008)
+#define PM_CTL_ED_EN_			(0x00000004)
+#define PM_CTL_WUPS_			(0x00000003)
+#define PM_CTL_WUPS_NO_			(0x00000000)
+#define PM_CTL_WUPS_ED_			(0x00000001)
+#define PM_CTL_WUPS_WOL_		(0x00000002)
+#define PM_CTL_WUPS_MULTI_		(0x00000003)
+
+#define LED_GPIO_CFG			(0x24)
+
+#define GPIO_CFG			(0x28)
+
+#define AFC_CFG				(0x2C)
+
+/* Hi watermark = 15.5Kb (~10 mtu pkts) */
+/* low watermark = 3k (~2 mtu pkts) */
+/* backpressure duration = ~ 350us */
+/* Apply FC on any frame. */
+#define AFC_CFG_DEFAULT			(0x00F830A1)
+
+#define E2P_CMD				(0x30)
+#define E2P_CMD_BUSY_			(0x80000000)
+#define E2P_CMD_MASK_			(0x70000000)
+#define E2P_CMD_READ_			(0x00000000)
+#define E2P_CMD_EWDS_			(0x10000000)
+#define E2P_CMD_EWEN_			(0x20000000)
+#define E2P_CMD_WRITE_			(0x30000000)
+#define E2P_CMD_WRAL_			(0x40000000)
+#define E2P_CMD_ERASE_			(0x50000000)
+#define E2P_CMD_ERAL_			(0x60000000)
+#define E2P_CMD_RELOAD_			(0x70000000)
+#define E2P_CMD_TIMEOUT_		(0x00000400)
+#define E2P_CMD_LOADED_			(0x00000200)
+#define E2P_CMD_ADDR_			(0x000001FF)
+
+#define MAX_EEPROM_SIZE			(512)
+
+#define E2P_DATA			(0x34)
+#define E2P_DATA_MASK_			(0x000000FF)
+
+#define BURST_CAP			(0x38)
+
+#define GPIO_WAKE			(0x64)
+
+#define INT_EP_CTL			(0x68)
+#define INT_EP_CTL_INTEP_		(0x80000000)
+#define INT_EP_CTL_MACRTO_		(0x00080000)
+#define INT_EP_CTL_TX_STOP_		(0x00020000)
+#define INT_EP_CTL_RX_STOP_		(0x00010000)
+#define INT_EP_CTL_PHY_INT_		(0x00008000)
+#define INT_EP_CTL_TXE_			(0x00004000)
+#define INT_EP_CTL_TDFU_		(0x00002000)
+#define INT_EP_CTL_TDFO_		(0x00001000)
+#define INT_EP_CTL_RXDF_		(0x00000800)
+#define INT_EP_CTL_GPIOS_		(0x000007FF)
+
+#define BULK_IN_DLY			(0x6C)
+
+/* MAC CSRs */
+#define MAC_CR				(0x100)
+#define MAC_CR_RXALL_			(0x80000000)
+#define MAC_CR_RCVOWN_			(0x00800000)
+#define MAC_CR_LOOPBK_			(0x00200000)
+#define MAC_CR_FDPX_			(0x00100000)
+#define MAC_CR_MCPAS_			(0x00080000)
+#define MAC_CR_PRMS_			(0x00040000)
+#define MAC_CR_INVFILT_			(0x00020000)
+#define MAC_CR_PASSBAD_			(0x00010000)
+#define MAC_CR_HFILT_			(0x00008000)
+#define MAC_CR_HPFILT_			(0x00002000)
+#define MAC_CR_LCOLL_			(0x00001000)
+#define MAC_CR_BCAST_			(0x00000800)
+#define MAC_CR_DISRTY_			(0x00000400)
+#define MAC_CR_PADSTR_			(0x00000100)
+#define MAC_CR_BOLMT_MASK		(0x000000C0)
+#define MAC_CR_DFCHK_			(0x00000020)
+#define MAC_CR_TXEN_			(0x00000008)
+#define MAC_CR_RXEN_			(0x00000004)
+
+#define ADDRH				(0x104)
+
+#define ADDRL				(0x108)
+
+#define HASHH				(0x10C)
+
+#define HASHL				(0x110)
+
+#define MII_ADDR			(0x114)
+#define MII_WRITE_			(0x02)
+#define MII_BUSY_			(0x01)
+#define MII_READ_			(0x00) /* ~of MII Write bit */
+
+#define MII_DATA			(0x118)
+
+#define FLOW				(0x11C)
+#define FLOW_FCPT_			(0xFFFF0000)
+#define FLOW_FCPASS_			(0x00000004)
+#define FLOW_FCEN_			(0x00000002)
+#define FLOW_FCBSY_			(0x00000001)
+
+#define VLAN1				(0x120)
+
+#define VLAN2				(0x124)
+
+#define WUFF				(0x128)
+
+#define WUCSR				(0x12C)
+
+#define COE_CR				(0x130)
+#define Tx_COE_EN_			(0x00010000)
+#define Rx_COE_MODE_			(0x00000002)
+#define Rx_COE_EN_			(0x00000001)
+
+/* Vendor-specific PHY Definitions */
+
+/* Mode Control/Status Register */
+#define PHY_MODE_CTRL_STS		(17)
+#define MODE_CTRL_STS_EDPWRDOWN_	((u16)0x2000)
+#define MODE_CTRL_STS_ENERGYON_		((u16)0x0002)
+
+#define SPECIAL_CTRL_STS		(27)
+#define SPECIAL_CTRL_STS_OVRRD_AMDIX_	((u16)0x8000)
+#define SPECIAL_CTRL_STS_AMDIX_ENABLE_	((u16)0x4000)
+#define SPECIAL_CTRL_STS_AMDIX_STATE_	((u16)0x2000)
+
+#define PHY_INT_SRC			(29)
+#define PHY_INT_SRC_ENERGY_ON_		((u16)0x0080)
+#define PHY_INT_SRC_ANEG_COMP_		((u16)0x0040)
+#define PHY_INT_SRC_REMOTE_FAULT_	((u16)0x0020)
+#define PHY_INT_SRC_LINK_DOWN_		((u16)0x0010)
+
+#define PHY_INT_MASK			(30)
+#define PHY_INT_MASK_ENERGY_ON_		((u16)0x0080)
+#define PHY_INT_MASK_ANEG_COMP_		((u16)0x0040)
+#define PHY_INT_MASK_REMOTE_FAULT_	((u16)0x0020)
+#define PHY_INT_MASK_LINK_DOWN_		((u16)0x0010)
+#define PHY_INT_MASK_DEFAULT_		(PHY_INT_MASK_ANEG_COMP_ | \
+					 PHY_INT_MASK_LINK_DOWN_)
+
+#define PHY_SPECIAL			(31)
+#define PHY_SPECIAL_SPD_		((u16)0x001C)
+#define PHY_SPECIAL_SPD_10HALF_		((u16)0x0004)
+#define PHY_SPECIAL_SPD_10FULL_		((u16)0x0014)
+#define PHY_SPECIAL_SPD_100HALF_	((u16)0x0008)
+#define PHY_SPECIAL_SPD_100FULL_	((u16)0x0018)
+
+/* USB Vendor Requests */
+#define USB_VENDOR_REQUEST_WRITE_REGISTER	0xA0
+#define USB_VENDOR_REQUEST_READ_REGISTER	0xA1
+#define USB_VENDOR_REQUEST_GET_STATS		0xA2
+
+/* Interrupt Endpoint status word bitfields */
+#define INT_ENP_TX_STOP_		((u32)BIT(17))
+#define INT_ENP_RX_STOP_		((u32)BIT(16))
+#define INT_ENP_PHY_INT_		((u32)BIT(15))
+#define INT_ENP_TXE_			((u32)BIT(14))
+#define INT_ENP_TDFU_			((u32)BIT(13))
+#define INT_ENP_TDFO_			((u32)BIT(12))
+#define INT_ENP_RXDF_			((u32)BIT(11))
+
+#endif /* _SMSC95XX_H */
-- 
1.5.5.1


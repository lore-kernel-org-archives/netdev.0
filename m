From: Joe Perches <joe@perches.com>
Subject: [PATCH] usbnet: convert dev(dbg|err|warn|info) macros to usbnet_(dbg|err|warn|info)
Date: Tue,  9 Feb 2010 17:43:15 -0800
Message-ID: <3d8577211d88cce1fb6f4c1b54c5aa413a1f325a.1265765892.git.joe@perches.com>
Cc: linux-usb@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Oliver Neukum <oliver@neukum.name>,
	Peter Korsgaard <jacmet@sunsite.dk>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	David Brownell <dbrownell@users.sourceforge.net>
To: Greg Kroah-Hartman <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1934 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755131Ab0BJBnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 20:43:16 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These macros are too similar to the dev_<level> equivalents
but take a usbnet * argument.  Make the macro names match
the argument and make them more distinct.

Fix the usbnet_info macro to remove the trailing ;
so it can be used in an if/else.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/asix.c       |   97 ++++++++++++----------
 drivers/net/usb/cdc_eem.c    |   10 ++-
 drivers/net/usb/cdc_ether.c  |   18 ++--
 drivers/net/usb/dm9601.c     |   49 ++++++------
 drivers/net/usb/int51x1.c    |   15 ++--
 drivers/net/usb/net1080.c    |  100 +++++++++++-----------
 drivers/net/usb/rndis_host.c |   10 +-
 drivers/net/usb/smsc95xx.c   |  188 ++++++++++++++++++++++--------------------
 drivers/net/usb/usbnet.c     |  161 ++++++++++++++++++------------------
 include/linux/usb/usbnet.h   |   28 +++---
 10 files changed, 348 insertions(+), 328 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index a516185..482aa88 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -184,8 +184,8 @@ static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 	void *buf;
 	int err = -ENOMEM;
 
-	devdbg(dev,"asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
-		cmd, value, index, size);
+	usbnet_dbg(dev, "asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
+		   cmd, value, index, size);
 
 	buf = kmalloc(size, GFP_KERNEL);
 	if (!buf)
@@ -217,8 +217,8 @@ static int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 	void *buf = NULL;
 	int err = -ENOMEM;
 
-	devdbg(dev,"asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
-		cmd, value, index, size);
+	usbnet_dbg(dev, "asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
 
 	if (data) {
 		buf = kmalloc(size, GFP_KERNEL);
@@ -264,15 +264,15 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 	int status;
 	struct urb *urb;
 
-	devdbg(dev,"asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
-		cmd, value, index, size);
+	usbnet_dbg(dev, "asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
 	if ((urb = usb_alloc_urb(0, GFP_ATOMIC)) == NULL) {
-		deverr(dev, "Error allocating URB in write_cmd_async!");
+		usbnet_err(dev, "Error allocating URB in write_cmd_async!\n");
 		return;
 	}
 
 	if ((req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC)) == NULL) {
-		deverr(dev, "Failed to allocate memory for control request");
+		usbnet_err(dev, "Failed to allocate memory for control request\n");
 		usb_free_urb(urb);
 		return;
 	}
@@ -289,8 +289,8 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			     asix_async_cmd_callback, req);
 
 	if((status = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
-		deverr(dev, "Error submitting the control message: status=%d",
-				status);
+		usbnet_err(dev, "Error submitting the control message: status=%d\n",
+			   status);
 		kfree(req);
 		usb_free_urb(urb);
 	}
@@ -314,7 +314,7 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	while (skb->len > 0) {
 		if ((short)(header & 0x0000ffff) !=
 		    ~((short)((header & 0xffff0000) >> 16))) {
-			deverr(dev,"asix_rx_fixup() Bad Header Length");
+			usbnet_err(dev, "asix_rx_fixup() Bad Header Length\n");
 		}
 		/* get the packet length */
 		size = (u16) (header & 0x0000ffff);
@@ -322,7 +322,8 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		if ((skb->len) - ((size + 1) & 0xfffe) == 0)
 			return 2;
 		if (size > ETH_FRAME_LEN) {
-			deverr(dev,"asix_rx_fixup() Bad RX Length %d", size);
+			usbnet_err(dev, "asix_rx_fixup() Bad RX Length %d\n",
+				   size);
 			return 0;
 		}
 		ax_skb = skb_clone(skb, GFP_ATOMIC);
@@ -348,7 +349,8 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 	if (skb->len < 0) {
-		deverr(dev,"asix_rx_fixup() Bad SKB Length %d", skb->len);
+		usbnet_err(dev, "asix_rx_fixup() Bad SKB Length %d\n",
+			   skb->len);
 		return 0;
 	}
 	return 1;
@@ -409,7 +411,7 @@ static void asix_status(struct usbnet *dev, struct urb *urb)
 			usbnet_defer_kevent (dev, EVENT_LINK_RESET );
 		} else
 			netif_carrier_off(dev->net);
-		devdbg(dev, "Link Status is: %d", link);
+		usbnet_dbg(dev, "Link Status is: %d\n", link);
 	}
 }
 
@@ -418,7 +420,7 @@ static inline int asix_set_sw_mii(struct usbnet *dev)
 	int ret;
 	ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to enable software MII access");
+		usbnet_err(dev, "Failed to enable software MII access\n");
 	return ret;
 }
 
@@ -427,7 +429,7 @@ static inline int asix_set_hw_mii(struct usbnet *dev)
 	int ret;
 	ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to enable hardware MII access");
+		usbnet_err(dev, "Failed to enable hardware MII access\n");
 	return ret;
 }
 
@@ -436,13 +438,14 @@ static inline int asix_get_phy_addr(struct usbnet *dev)
 	u8 buf[2];
 	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
 
-	devdbg(dev, "asix_get_phy_addr()");
+	usbnet_dbg(dev, "asix_get_phy_addr()\n");
 
 	if (ret < 0) {
-		deverr(dev, "Error reading PHYID register: %02x", ret);
+		usbnet_err(dev, "Error reading PHYID register: %02x\n", ret);
 		goto out;
 	}
-	devdbg(dev, "asix_get_phy_addr() returning 0x%04x", *((__le16 *)buf));
+	usbnet_dbg(dev, "asix_get_phy_addr() returning 0x%04x\n",
+		   *((__le16 *)buf));
 	ret = buf[1];
 
 out:
@@ -455,7 +458,7 @@ static int asix_sw_reset(struct usbnet *dev, u8 flags)
 
         ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev,"Failed to send software reset: %02x", ret);
+		usbnet_err(dev, "Failed to send software reset: %02x\n", ret);
 
 	return ret;
 }
@@ -466,7 +469,7 @@ static u16 asix_read_rx_ctl(struct usbnet *dev)
 	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
 
 	if (ret < 0) {
-		deverr(dev, "Error reading RX_CTL register: %02x", ret);
+		usbnet_err(dev, "Error reading RX_CTL register: %02x\n", ret);
 		goto out;
 	}
 	ret = le16_to_cpu(v);
@@ -478,11 +481,11 @@ static int asix_write_rx_ctl(struct usbnet *dev, u16 mode)
 {
 	int ret;
 
-	devdbg(dev,"asix_write_rx_ctl() - mode = 0x%04x", mode);
+	usbnet_dbg(dev, "asix_write_rx_ctl() - mode = 0x%04x\n", mode);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_RX_CTL, mode, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to write RX_CTL mode to 0x%04x: %02x",
-		       mode, ret);
+		usbnet_err(dev, "Failed to write RX_CTL mode to 0x%04x: %02x\n",
+			   mode, ret);
 
 	return ret;
 }
@@ -493,7 +496,8 @@ static u16 asix_read_medium_status(struct usbnet *dev)
 	int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
 
 	if (ret < 0) {
-		deverr(dev, "Error reading Medium Status register: %02x", ret);
+		usbnet_err(dev, "Error reading Medium Status register: %02x\n",
+			   ret);
 		goto out;
 	}
 	ret = le16_to_cpu(v);
@@ -505,11 +509,11 @@ static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
 {
 	int ret;
 
-	devdbg(dev,"asix_write_medium_mode() - mode = 0x%04x", mode);
+	usbnet_dbg(dev, "asix_write_medium_mode() - mode = 0x%04x\n", mode);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to write Medium Mode mode to 0x%04x: %02x",
-			mode, ret);
+		usbnet_err(dev, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
+			   mode, ret);
 
 	return ret;
 }
@@ -518,11 +522,11 @@ static int asix_write_gpio(struct usbnet *dev, u16 value, int sleep)
 {
 	int ret;
 
-	devdbg(dev,"asix_write_gpio() - value = 0x%04x", value);
+	usbnet_dbg(dev, "asix_write_gpio() - value = 0x%04x\n", value);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to write GPIO value 0x%04x: %02x",
-			value, ret);
+		usbnet_err(dev, "Failed to write GPIO value 0x%04x: %02x\n",
+			   value, ret);
 
 	if (sleep)
 		msleep(sleep);
@@ -588,7 +592,8 @@ static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	asix_set_hw_mii(dev);
 	mutex_unlock(&dev->phy_mutex);
 
-	devdbg(dev, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x", phy_id, loc, le16_to_cpu(res));
+	usbnet_dbg(dev, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+		   phy_id, loc, le16_to_cpu(res));
 
 	return le16_to_cpu(res);
 }
@@ -599,7 +604,8 @@ asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
 	struct usbnet *dev = netdev_priv(netdev);
 	__le16 res = cpu_to_le16(val);
 
-	devdbg(dev, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x", phy_id, loc, val);
+	usbnet_dbg(dev, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+		   phy_id, loc, val);
 	mutex_lock(&dev->phy_mutex);
 	asix_set_sw_mii(dev);
 	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
@@ -800,7 +806,8 @@ static int ax88172_link_reset(struct usbnet *dev)
 	if (ecmd.duplex != DUPLEX_FULL)
 		mode |= ~AX88172_MEDIUM_FD;
 
-	devdbg(dev, "ax88172_link_reset() speed: %d duplex: %d setting mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
+	usbnet_dbg(dev, "ax88172_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
+		   ecmd.speed, ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -902,7 +909,8 @@ static int ax88772_link_reset(struct usbnet *dev)
 	if (ecmd.duplex != DUPLEX_FULL)
 		mode &= ~AX_MEDIUM_FD;
 
-	devdbg(dev, "ax88772_link_reset() speed: %d duplex: %d setting mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
+	usbnet_dbg(dev, "ax88772_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
+		   ecmd.speed, ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -1059,10 +1067,10 @@ static int marvell_phy_init(struct usbnet *dev)
 	struct asix_data *data = (struct asix_data *)&dev->data;
 	u16 reg;
 
-	devdbg(dev,"marvell_phy_init()");
+	usbnet_dbg(dev, "marvell_phy_init()\n");
 
 	reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_MARVELL_STATUS);
-	devdbg(dev,"MII_MARVELL_STATUS = 0x%04x", reg);
+	usbnet_dbg(dev, "MII_MARVELL_STATUS = 0x%04x\n", reg);
 
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_MARVELL_CTRL,
 			MARVELL_CTRL_RXDELAY | MARVELL_CTRL_TXDELAY);
@@ -1070,7 +1078,7 @@ static int marvell_phy_init(struct usbnet *dev)
 	if (data->ledmode) {
 		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
 			MII_MARVELL_LED_CTRL);
-		devdbg(dev,"MII_MARVELL_LED_CTRL (1) = 0x%04x", reg);
+		usbnet_dbg(dev, "MII_MARVELL_LED_CTRL (1) = 0x%04x\n", reg);
 
 		reg &= 0xf8ff;
 		reg |= (1 + 0x0100);
@@ -1079,7 +1087,7 @@ static int marvell_phy_init(struct usbnet *dev)
 
 		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
 			MII_MARVELL_LED_CTRL);
-		devdbg(dev,"MII_MARVELL_LED_CTRL (2) = 0x%04x", reg);
+		usbnet_dbg(dev, "MII_MARVELL_LED_CTRL (2) = 0x%04x\n", reg);
 		reg &= 0xfc0f;
 	}
 
@@ -1090,7 +1098,7 @@ static int marvell_led_status(struct usbnet *dev, u16 speed)
 {
 	u16 reg = asix_mdio_read(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL);
 
-	devdbg(dev, "marvell_led_status() read 0x%04x", reg);
+	usbnet_dbg(dev, "marvell_led_status() read 0x%04x\n", reg);
 
 	/* Clear out the center LED bits - 0x03F0 */
 	reg &= 0xfc0f;
@@ -1106,7 +1114,7 @@ static int marvell_led_status(struct usbnet *dev, u16 speed)
 			reg |= 0x02f0;
 	}
 
-	devdbg(dev, "marvell_led_status() writing 0x%04x", reg);
+	usbnet_dbg(dev, "marvell_led_status() writing 0x%04x\n", reg);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL, reg);
 
 	return 0;
@@ -1118,7 +1126,7 @@ static int ax88178_link_reset(struct usbnet *dev)
 	struct ethtool_cmd ecmd;
 	struct asix_data *data = (struct asix_data *)&dev->data;
 
-	devdbg(dev,"ax88178_link_reset()");
+	usbnet_dbg(dev, "ax88178_link_reset()\n");
 
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -1138,7 +1146,8 @@ static int ax88178_link_reset(struct usbnet *dev)
 	else
 		mode &= ~AX_MEDIUM_FD;
 
-	devdbg(dev, "ax88178_link_reset() speed: %d duplex: %d setting mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
+	usbnet_dbg(dev, "ax88178_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
+		   ecmd.speed, ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -1188,7 +1197,7 @@ static int ax88178_change_mtu(struct net_device *net, int new_mtu)
 	struct usbnet *dev = netdev_priv(net);
 	int ll_mtu = new_mtu + net->hard_header_len + 4;
 
-	devdbg(dev, "ax88178_change_mtu() new_mtu=%d", new_mtu);
+	usbnet_dbg(dev, "ax88178_change_mtu() new_mtu=%d\n", new_mtu);
 
 	if (new_mtu <= 0 || ll_mtu > 16384)
 		return -EINVAL;
diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index c337ffc..8d58176 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -73,7 +73,7 @@ static void eem_linkcmd(struct usbnet *dev, struct sk_buff *skb)
 		usb_free_urb(urb);
 fail:
 		dev_kfree_skb(skb);
-		devwarn(dev, "link cmd failure\n");
+		usbnet_warn(dev, "link cmd failure\n\n");
 		return;
 	}
 }
@@ -212,7 +212,8 @@ static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			 * b15:		1 (EEM command)
 			 */
 			if (header & BIT(14)) {
-				devdbg(dev, "reserved command %04x\n", header);
+				usbnet_dbg(dev, "reserved command %04x\n\n",
+					   header);
 				continue;
 			}
 
@@ -255,8 +256,9 @@ static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			case 1:		/* Echo response */
 			case 5:		/* Tickle */
 			default:	/* reserved */
-				devwarn(dev, "unexpected link command %d\n",
-						bmEEMCmd);
+				usbnet_warn(dev,
+					    "unexpected link command %d\n\n",
+					    bmEEMCmd);
 				continue;
 			}
 
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4f27f02..375973d 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -340,9 +340,9 @@ EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
 static void dumpspeed(struct usbnet *dev, __le32 *speeds)
 {
 	if (netif_msg_timer(dev))
-		devinfo(dev, "link speeds: %u kbps up, %u kbps down",
-			__le32_to_cpu(speeds[0]) / 1000,
-		__le32_to_cpu(speeds[1]) / 1000);
+		usbnet_info(dev, "link speeds: %u kbps up, %u kbps down\n",
+			    __le32_to_cpu(speeds[0]) / 1000,
+			    __le32_to_cpu(speeds[1]) / 1000);
 }
 
 static void cdc_status(struct usbnet *dev, struct urb *urb)
@@ -362,8 +362,8 @@ static void cdc_status(struct usbnet *dev, struct urb *urb)
 	switch (event->bNotificationType) {
 	case USB_CDC_NOTIFY_NETWORK_CONNECTION:
 		if (netif_msg_timer(dev))
-			devdbg(dev, "CDC: carrier %s",
-					event->wValue ? "on" : "off");
+			usbnet_dbg(dev, "CDC: carrier %s\n",
+				   event->wValue ? "on" : "off");
 		if (event->wValue)
 			netif_carrier_on(dev->net);
 		else
@@ -371,8 +371,8 @@ static void cdc_status(struct usbnet *dev, struct urb *urb)
 		break;
 	case USB_CDC_NOTIFY_SPEED_CHANGE:	/* tx/rx rates */
 		if (netif_msg_timer(dev))
-			devdbg(dev, "CDC: speed change (len %d)",
-					urb->actual_length);
+			usbnet_dbg(dev, "CDC: speed change (len %d)\n",
+				   urb->actual_length);
 		if (urb->actual_length != (sizeof *event + 8))
 			set_bit(EVENT_STS_SPLIT, &dev->flags);
 		else
@@ -382,8 +382,8 @@ static void cdc_status(struct usbnet *dev, struct urb *urb)
 	 * but there are no standard formats for the response data.
 	 */
 	default:
-		deverr(dev, "CDC: unexpected notification %02x!",
-				 event->bNotificationType);
+		usbnet_err(dev, "CDC: unexpected notification %02x!\n",
+			   event->bNotificationType);
 		break;
 	}
 }
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index 3d406f9..3f541ab 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -58,7 +58,7 @@ static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 	void *buf;
 	int err = -ENOMEM;
 
-	devdbg(dev, "dm_read() reg=0x%02x length=%d", reg, length);
+	usbnet_dbg(dev, "dm_read() reg=0x%02x length=%d\n", reg, length);
 
 	buf = kmalloc(length, GFP_KERNEL);
 	if (!buf)
@@ -89,7 +89,7 @@ static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 	void *buf = NULL;
 	int err = -ENOMEM;
 
-	devdbg(dev, "dm_write() reg=0x%02x, length=%d", reg, length);
+	usbnet_dbg(dev, "dm_write() reg=0x%02x, length=%d\n", reg, length);
 
 	if (data) {
 		buf = kmalloc(length, GFP_KERNEL);
@@ -112,7 +112,8 @@ static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 
 static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
 {
-	devdbg(dev, "dm_write_reg() reg=0x%02x, value=0x%02x", reg, value);
+	usbnet_dbg(dev, "dm_write_reg() reg=0x%02x, value=0x%02x\n",
+		   reg, value);
 	return usb_control_msg(dev->udev,
 			       usb_sndctrlpipe(dev->udev, 0),
 			       DM_WRITE_REG,
@@ -142,13 +143,13 @@ static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		deverr(dev, "Error allocating URB in dm_write_async_helper!");
+		usbnet_err(dev, "Error allocating URB in dm_write_async_helper!\n");
 		return;
 	}
 
 	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
 	if (!req) {
-		deverr(dev, "Failed to allocate memory for control request");
+		usbnet_err(dev, "Failed to allocate memory for control request\n");
 		usb_free_urb(urb);
 		return;
 	}
@@ -166,8 +167,8 @@ static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status < 0) {
-		deverr(dev, "Error submitting the control message: status=%d",
-		       status);
+		usbnet_err(dev, "Error submitting the control message: status=%d\n",
+			   status);
 		kfree(req);
 		usb_free_urb(urb);
 	}
@@ -175,15 +176,15 @@ static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
 
 static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
-	devdbg(dev, "dm_write_async() reg=0x%02x length=%d", reg, length);
+	usbnet_dbg(dev, "dm_write_async() reg=0x%02x length=%d\n", reg, length);
 
 	dm_write_async_helper(dev, reg, 0, length, data);
 }
 
 static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
 {
-	devdbg(dev, "dm_write_reg_async() reg=0x%02x value=0x%02x",
-	       reg, value);
+	usbnet_dbg(dev, "dm_write_reg_async() reg=0x%02x value=0x%02x\n",
+		   reg, value);
 
 	dm_write_async_helper(dev, reg, value, 0, NULL);
 }
@@ -211,7 +212,7 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 	}
 
 	if (i == DM_TIMEOUT) {
-		deverr(dev, "%s read timed out!", phy ? "phy" : "eeprom");
+		usbnet_err(dev, "%s read timed out!\n", phy ? "phy" : "eeprom");
 		ret = -EIO;
 		goto out;
 	}
@@ -219,8 +220,8 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 	dm_write_reg(dev, DM_SHARED_CTRL, 0x0);
 	ret = dm_read(dev, DM_SHARED_DATA, 2, value);
 
-	devdbg(dev, "read shared %d 0x%02x returned 0x%04x, %d",
-	       phy, reg, *value, ret);
+	usbnet_dbg(dev, "read shared %d 0x%02x returned 0x%04x, %d\n",
+		   phy, reg, *value, ret);
 
  out:
 	mutex_unlock(&dev->phy_mutex);
@@ -254,7 +255,7 @@ static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 valu
 	}
 
 	if (i == DM_TIMEOUT) {
-		deverr(dev, "%s write timed out!", phy ? "phy" : "eeprom");
+		usbnet_err(dev, "%s write timed out!\n", phy ? "phy" : "eeprom");
 		ret = -EIO;
 		goto out;
 	}
@@ -304,15 +305,15 @@ static int dm9601_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	__le16 res;
 
 	if (phy_id) {
-		devdbg(dev, "Only internal phy supported");
+		usbnet_dbg(dev, "Only internal phy supported\n");
 		return 0;
 	}
 
 	dm_read_shared_word(dev, 1, loc, &res);
 
-	devdbg(dev,
-	       "dm9601_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x",
-	       phy_id, loc, le16_to_cpu(res));
+	usbnet_dbg(dev,
+		   "dm9601_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+		   phy_id, loc, le16_to_cpu(res));
 
 	return le16_to_cpu(res);
 }
@@ -324,12 +325,12 @@ static void dm9601_mdio_write(struct net_device *netdev, int phy_id, int loc,
 	__le16 res = cpu_to_le16(val);
 
 	if (phy_id) {
-		devdbg(dev, "Only internal phy supported");
+		usbnet_dbg(dev, "Only internal phy supported\n");
 		return;
 	}
 
-	devdbg(dev,"dm9601_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x",
-	       phy_id, loc, val);
+	usbnet_dbg(dev, "dm9601_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+		   phy_id, loc, val);
 
 	dm_write_shared_word(dev, 1, loc, res);
 }
@@ -592,7 +593,7 @@ static void dm9601_status(struct usbnet *dev, struct urb *urb)
 		}
 		else
 			netif_carrier_off(dev->net);
-		devdbg(dev, "Link Status is: %d", link);
+		usbnet_dbg(dev, "Link Status is: %d\n", link);
 	}
 }
 
@@ -603,8 +604,8 @@ static int dm9601_link_reset(struct usbnet *dev)
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
 
-	devdbg(dev, "link_reset() speed: %d duplex: %d",
-	       ecmd.speed, ecmd.duplex);
+	usbnet_dbg(dev, "link_reset() speed: %d duplex: %d\n",
+		   ecmd.speed, ecmd.duplex);
 
 	return 0;
 }
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index 55cf708..afac8e7 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -51,7 +51,7 @@ static int int51x1_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	int len;
 
 	if (!(pskb_may_pull(skb, INT51X1_HEADER_SIZE))) {
-		deverr(dev, "unexpected tiny rx frame");
+		usbnet_err(dev, "unexpected tiny rx frame\n");
 		return 0;
 	}
 
@@ -138,25 +138,25 @@ static void int51x1_set_multicast(struct net_device *netdev)
 	if (netdev->flags & IFF_PROMISC) {
 		/* do not expect to see traffic of other PLCs */
 		filter |= PACKET_TYPE_PROMISCUOUS;
-		devinfo(dev, "promiscuous mode enabled");
+		usbnet_info(dev, "promiscuous mode enabled\n");
 	} else if (netdev->mc_count ||
 		  (netdev->flags & IFF_ALLMULTI)) {
 		filter |= PACKET_TYPE_ALL_MULTICAST;
-		devdbg(dev, "receive all multicast enabled");
+		usbnet_dbg(dev, "receive all multicast enabled\n");
 	} else {
 		/* ~PROMISCUOUS, ~MULTICAST */
-		devdbg(dev, "receive own packets only");
+		usbnet_dbg(dev, "receive own packets only\n");
 	}
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		devwarn(dev, "Error allocating URB");
+		usbnet_warn(dev, "Error allocating URB\n");
 		return;
 	}
 
 	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req) {
-		devwarn(dev, "Error allocating control msg");
+		usbnet_warn(dev, "Error allocating control msg\n");
 		goto out;
 	}
 
@@ -173,7 +173,8 @@ static void int51x1_set_multicast(struct net_device *netdev)
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status < 0) {
-		devwarn(dev, "Error submitting control msg, sts=%d", status);
+		usbnet_warn(dev, "Error submitting control msg, sts=%d\n",
+			    status);
 		goto out1;
 	}
 	return;
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index aeb1ab0..2ecefe6 100644
--- a/drivers/net/usb/net1080.c
+++ b/drivers/net/usb/net1080.c
@@ -205,23 +205,24 @@ static inline void nc_dump_usbctl(struct usbnet *dev, u16 usbctl)
 {
 	if (!netif_msg_link(dev))
 		return;
-	devdbg(dev, "net1080 %s-%s usbctl 0x%x:%s%s%s%s%s;"
-			" this%s%s;"
-			" other%s%s; r/o 0x%x",
-		dev->udev->bus->bus_name, dev->udev->devpath,
-		usbctl,
-		(usbctl & USBCTL_ENABLE_LANG) ? " lang" : "",
-		(usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" : "",
-		(usbctl & USBCTL_ENABLE_PROD) ? " prod" : "",
-		(usbctl & USBCTL_ENABLE_SERIAL) ? " serial" : "",
-		(usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
-
-		(usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" : "",
-		(usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
-		(usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" : "",
-		(usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
-		usbctl & ~USBCTL_WRITABLE_MASK
-		);
+	usbnet_dbg(dev, "net1080 %s-%s usbctl 0x%x:%s;"
+		   " this%s;"
+		   " other%s; r/o 0x%x\n",
+		   dev->udev->bus->bus_name, dev->udev->devpath,
+		   usbctl,
+		   (usbctl & USBCTL_ENABLE_LANG) ? " lang" :
+		   (usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" :
+		   (usbctl & USBCTL_ENABLE_PROD) ? " prod" :
+		   (usbctl & USBCTL_ENABLE_SERIAL) ? " serial" :
+		   (usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
+
+		   (usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" :
+		   (usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
+
+		   (usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" :
+		   (usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
+
+		   usbctl & ~USBCTL_WRITABLE_MASK);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -250,28 +251,25 @@ static inline void nc_dump_status(struct usbnet *dev, u16 status)
 {
 	if (!netif_msg_link(dev))
 		return;
-	devdbg(dev, "net1080 %s-%s status 0x%x:"
-			" this (%c) PKT=%d%s%s%s;"
-			" other PKT=%d%s%s%s; unspec 0x%x",
-		dev->udev->bus->bus_name, dev->udev->devpath,
-		status,
-
-		// XXX the packet counts don't seem right
-		// (1 at reset, not 0); maybe UNSPEC too
-
-		(status & STATUS_PORT_A) ? 'A' : 'B',
-		STATUS_PACKETS_THIS(status),
-		(status & STATUS_CONN_THIS) ? " CON" : "",
-		(status & STATUS_SUSPEND_THIS) ? " SUS" : "",
-		(status & STATUS_MAILBOX_THIS) ? " MBOX" : "",
-
-		STATUS_PACKETS_OTHER(status),
-		(status & STATUS_CONN_OTHER) ? " CON" : "",
-		(status & STATUS_SUSPEND_OTHER) ? " SUS" : "",
-		(status & STATUS_MAILBOX_OTHER) ? " MBOX" : "",
-
-		status & STATUS_UNSPEC_MASK
-		);
+	usbnet_dbg(dev, "net1080 %s-%s status 0x%x: this (%c) PKT=%d%s; other PKT=%d%s; unspec 0x%x\n",
+		   dev->udev->bus->bus_name, dev->udev->devpath,
+		   status,
+
+		   // XXX the packet counts don't seem right
+		   // (1 at reset, not 0); maybe UNSPEC too
+
+		   (status & STATUS_PORT_A) ? 'A' : 'B',
+		   STATUS_PACKETS_THIS(status),
+		   (status & STATUS_CONN_THIS) ? " CON" :
+		   (status & STATUS_SUSPEND_THIS) ? " SUS" :
+		   (status & STATUS_MAILBOX_THIS) ? " MBOX" : "",
+
+		   STATUS_PACKETS_OTHER(status),
+		   (status & STATUS_CONN_OTHER) ? " CON" :
+		   (status & STATUS_SUSPEND_OTHER) ? " SUS" :
+		   (status & STATUS_MAILBOX_OTHER) ? " MBOX" : "",
+
+		   status & STATUS_UNSPEC_MASK);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -287,9 +285,9 @@ static inline void nc_dump_status(struct usbnet *dev, u16 status)
 static inline void nc_dump_ttl(struct usbnet *dev, u16 ttl)
 {
 	if (netif_msg_link(dev))
-		devdbg(dev, "net1080 %s-%s ttl 0x%x this = %d, other = %d",
-			dev->udev->bus->bus_name, dev->udev->devpath,
-			ttl, TTL_THIS(ttl), TTL_OTHER(ttl));
+		usbnet_dbg(dev, "net1080 %s-%s ttl 0x%x this = %d, other = %d\n",
+			   dev->udev->bus->bus_name, dev->udev->devpath,
+			   ttl, TTL_THIS(ttl), TTL_OTHER(ttl));
 }
 
 /*-------------------------------------------------------------------------*/
@@ -335,9 +333,9 @@ static int net1080_reset(struct usbnet *dev)
 	dbg("%s: assigned TTL, %d ms", dev->net->name, NC_READ_TTL_MS);
 
 	if (netif_msg_link(dev))
-		devinfo(dev, "port %c, peer %sconnected",
-			(status & STATUS_PORT_A) ? 'A' : 'B',
-			(status & STATUS_CONN_OTHER) ? "" : "dis"
+		usbnet_info(dev, "port %c, peer %sconnected\n",
+			    (status & STATUS_PORT_A) ? 'A' : 'B',
+			    (status & STATUS_CONN_OTHER) ? "" : "dis"
 			);
 	retval = 0;
 
@@ -416,7 +414,7 @@ static void nc_ensure_sync(struct usbnet *dev)
 		}
 
 		if (netif_msg_rx_err(dev))
-			devdbg(dev, "flush net1080; too many framing errors");
+			usbnet_dbg(dev, "flush net1080; too many framing errors\n");
 		dev->frame_errors = 0;
 	}
 }
@@ -486,8 +484,8 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		return 0;
 	}
 #if 0
-	devdbg(dev, "frame <rx h %d p %d id %d", header->hdr_len,
-		header->packet_len, header->packet_id);
+	usbnet_dbg(dev, "frame <rx h %d p %d id %d\n", header->hdr_len,
+		   header->packet_len, header->packet_id);
 #endif
 	dev->frame_errors = 0;
 	return 1;
@@ -547,9 +545,9 @@ encapsulate:
 	trailer = (struct nc_trailer *) skb_put(skb, sizeof *trailer);
 	put_unaligned(header->packet_id, &trailer->packet_id);
 #if 0
-	devdbg(dev, "frame >tx h %d p %d id %d",
-		header->hdr_len, header->packet_len,
-		header->packet_id);
+	usbnet_dbg(dev, "frame >tx h %d p %d id %d\n",
+		   header->hdr_len, header->packet_len,
+		   header->packet_id);
 #endif
 	return skb;
 }
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 490fa8f..522b4c2 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -57,8 +57,8 @@
  */
 void rndis_status(struct usbnet *dev, struct urb *urb)
 {
-	devdbg(dev, "rndis status urb, len %d stat %d",
-		urb->actual_length, urb->status);
+	usbnet_dbg(dev, "rndis status urb, len %d stat %d\n",
+		   urb->actual_length, urb->status);
 	// FIXME for keepalives, respond immediately (asynchronously)
 	// if not an RNDIS status, do like cdc_status(dev,urb) does
 }
@@ -497,9 +497,9 @@ int rndis_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			     skb->len < msg_len ||
 			     (data_offset + data_len + 8) > msg_len)) {
 			dev->net->stats.rx_frame_errors++;
-			devdbg(dev, "bad rndis message %d/%d/%d/%d, len %d",
-				le32_to_cpu(hdr->msg_type),
-				msg_len, data_offset, data_len, skb->len);
+			usbnet_dbg(dev, "bad rndis message %d/%d/%d/%d, len %d\n",
+				   le32_to_cpu(hdr->msg_type),
+				   msg_len, data_offset, data_len, skb->len);
 			return 0;
 		}
 		skb_pull(skb, 8 + data_offset);
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 0c3c738..57419e2 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -78,7 +78,7 @@ static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
 		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
 
 	if (unlikely(ret < 0))
-		devwarn(dev, "Failed to read register index 0x%08x", index);
+		usbnet_warn(dev, "Failed to read register index 0x%08x\n", index);
 
 	le32_to_cpus(buf);
 	*data = *buf;
@@ -106,7 +106,7 @@ static int smsc95xx_write_reg(struct usbnet *dev, u32 index, u32 data)
 		00, index, buf, 4, USB_CTRL_SET_TIMEOUT);
 
 	if (unlikely(ret < 0))
-		devwarn(dev, "Failed to write register index 0x%08x", index);
+		usbnet_warn(dev, "Failed to write register index 0x%08x\n", index);
 
 	kfree(buf);
 
@@ -138,7 +138,7 @@ static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 
 	/* confirm MII not busy */
 	if (smsc95xx_phy_wait_not_busy(dev)) {
-		devwarn(dev, "MII is busy in smsc95xx_mdio_read");
+		usbnet_warn(dev, "MII is busy in smsc95xx_mdio_read\n");
 		mutex_unlock(&dev->phy_mutex);
 		return -EIO;
 	}
@@ -150,7 +150,7 @@ static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 	smsc95xx_write_reg(dev, MII_ADDR, addr);
 
 	if (smsc95xx_phy_wait_not_busy(dev)) {
-		devwarn(dev, "Timed out reading MII reg %02X", idx);
+		usbnet_warn(dev, "Timed out reading MII reg %02X\n", idx);
 		mutex_unlock(&dev->phy_mutex);
 		return -EIO;
 	}
@@ -172,7 +172,7 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 
 	/* confirm MII not busy */
 	if (smsc95xx_phy_wait_not_busy(dev)) {
-		devwarn(dev, "MII is busy in smsc95xx_mdio_write");
+		usbnet_warn(dev, "MII is busy in smsc95xx_mdio_write\n");
 		mutex_unlock(&dev->phy_mutex);
 		return;
 	}
@@ -187,7 +187,7 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 	smsc95xx_write_reg(dev, MII_ADDR, addr);
 
 	if (smsc95xx_phy_wait_not_busy(dev))
-		devwarn(dev, "Timed out writing MII reg %02X", idx);
+		usbnet_warn(dev, "Timed out writing MII reg %02X\n", idx);
 
 	mutex_unlock(&dev->phy_mutex);
 }
@@ -205,7 +205,7 @@ static int smsc95xx_wait_eeprom(struct usbnet *dev)
 	} while (!time_after(jiffies, start_time + HZ));
 
 	if (val & (E2P_CMD_TIMEOUT_ | E2P_CMD_BUSY_)) {
-		devwarn(dev, "EEPROM read operation timeout");
+		usbnet_warn(dev, "EEPROM read operation timeout\n");
 		return -EIO;
 	}
 
@@ -226,7 +226,7 @@ static int smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 		udelay(40);
 	} while (!time_after(jiffies, start_time + HZ));
 
-	devwarn(dev, "EEPROM is busy");
+	usbnet_warn(dev, "EEPROM is busy\n");
 	return -EIO;
 }
 
@@ -308,7 +308,7 @@ static void smsc95xx_async_cmd_callback(struct urb *urb)
 	int status = urb->status;
 
 	if (status < 0)
-		devwarn(dev, "async callback failed with %d", status);
+		usbnet_warn(dev, "async callback failed with %d\n", status);
 
 	kfree(usb_context);
 	usb_free_urb(urb);
@@ -323,13 +323,13 @@ static int smsc95xx_write_reg_async(struct usbnet *dev, u16 index, u32 *data)
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		devwarn(dev, "Error allocating URB");
+		usbnet_warn(dev, "Error allocating URB\n");
 		return -ENOMEM;
 	}
 
 	usb_context = kmalloc(sizeof(struct usb_context), GFP_ATOMIC);
 	if (usb_context == NULL) {
-		devwarn(dev, "Error allocating control msg");
+		usbnet_warn(dev, "Error allocating control msg\n");
 		usb_free_urb(urb);
 		return -ENOMEM;
 	}
@@ -348,7 +348,8 @@ static int smsc95xx_write_reg_async(struct usbnet *dev, u16 index, u32 *data)
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status < 0) {
-		devwarn(dev, "Error submitting control msg, sts=%d", status);
+		usbnet_warn(dev, "Error submitting control msg, sts=%d\n",
+			    status);
 		kfree(usb_context);
 		usb_free_urb(urb);
 	}
@@ -376,12 +377,12 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 
 	if (dev->net->flags & IFF_PROMISC) {
 		if (netif_msg_drv(dev))
-			devdbg(dev, "promiscuous mode enabled");
+			usbnet_dbg(dev, "promiscuous mode enabled\n");
 		pdata->mac_cr |= MAC_CR_PRMS_;
 		pdata->mac_cr &= ~(MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
 	} else if (dev->net->flags & IFF_ALLMULTI) {
 		if (netif_msg_drv(dev))
-			devdbg(dev, "receive all multicast enabled");
+			usbnet_dbg(dev, "receive all multicast enabled\n");
 		pdata->mac_cr |= MAC_CR_MCPAS_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
 	} else if (dev->net->mc_count > 0) {
@@ -401,20 +402,20 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 				else
 					hash_lo |= mask;
 			} else {
-				devwarn(dev, "dmi_addrlen != 6");
+				usbnet_warn(dev, "dmi_addrlen != 6\n");
 			}
 			mc_list = mc_list->next;
 		}
 
 		if (count != ((u32)dev->net->mc_count))
-			devwarn(dev, "mc_count != dev->mc_count");
+			usbnet_warn(dev, "mc_count != dev->mc_count\n");
 
 		if (netif_msg_drv(dev))
-			devdbg(dev, "HASHH=0x%08X, HASHL=0x%08X", hash_hi,
-				hash_lo);
+			usbnet_dbg(dev, "HASHH=0x%08X, HASHL=0x%08X\n",
+				   hash_hi, hash_lo);
 	} else {
 		if (netif_msg_drv(dev))
-			devdbg(dev, "receive own packets only");
+			usbnet_dbg(dev, "receive own packets only\n");
 		pdata->mac_cr &=
 			~(MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
 	}
@@ -434,7 +435,7 @@ static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 
 	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
 	if (ret < 0) {
-		devwarn(dev, "error reading AFC_CFG");
+		usbnet_warn(dev, "error reading AFC_CFG\n");
 		return;
 	}
 
@@ -452,12 +453,12 @@ static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 			afc_cfg &= ~0xF;
 
 		if (netif_msg_link(dev))
-			devdbg(dev, "rx pause %s, tx pause %s",
-				(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
-				(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+			usbnet_dbg(dev, "rx pause %s, tx pause %s\n",
+				   cap & FLOW_CTRL_RX ? "enabled" : "disabled",
+				   cap & FLOW_CTRL_TX ? "enabled" : "disabled");
 	} else {
 		if (netif_msg_link(dev))
-			devdbg(dev, "half duplex");
+			usbnet_dbg(dev, "half duplex\n");
 		flow = 0;
 		afc_cfg |= 0xF;
 	}
@@ -486,8 +487,8 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	rmtadv = smsc95xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
 
 	if (netif_msg_link(dev))
-		devdbg(dev, "speed: %d duplex: %d lcladv: %04x rmtadv: %04x",
-			ecmd.speed, ecmd.duplex, lcladv, rmtadv);
+		usbnet_dbg(dev, "speed: %d duplex: %d lcladv: %04x rmtadv: %04x\n",
+			   ecmd.speed, ecmd.duplex, lcladv, rmtadv);
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	if (ecmd.duplex != DUPLEX_FULL) {
@@ -511,7 +512,8 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 	u32 intdata;
 
 	if (urb->actual_length != 4) {
-		devwarn(dev, "unexpected urb length %d", urb->actual_length);
+		usbnet_warn(dev, "unexpected urb length %d\n",
+			    urb->actual_length);
 		return;
 	}
 
@@ -519,12 +521,13 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 	le32_to_cpus(&intdata);
 
 	if (netif_msg_link(dev))
-		devdbg(dev, "intdata: 0x%08X", intdata);
+		usbnet_dbg(dev, "intdata: 0x%08X\n", intdata);
 
 	if (intdata & INT_ENP_PHY_INT_)
 		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
 	else
-		devwarn(dev, "unexpected interrupt, intdata=0x%08X", intdata);
+		usbnet_warn(dev, "unexpected interrupt, intdata=0x%08X\n",
+			    intdata);
 }
 
 /* Enable or disable Tx & Rx checksum offload engines */
@@ -534,7 +537,7 @@ static int smsc95xx_set_csums(struct usbnet *dev)
 	u32 read_buf;
 	int ret = smsc95xx_read_reg(dev, COE_CR, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read COE_CR: %d", ret);
+		usbnet_warn(dev, "Failed to read COE_CR: %d\n", ret);
 		return ret;
 	}
 
@@ -550,12 +553,12 @@ static int smsc95xx_set_csums(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, COE_CR, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write COE_CR: %d", ret);
+		usbnet_warn(dev, "Failed to write COE_CR: %d\n", ret);
 		return ret;
 	}
 
 	if (netif_msg_hw(dev))
-		devdbg(dev, "COE_CR = 0x%08x", read_buf);
+		usbnet_dbg(dev, "COE_CR = 0x%08x\n", read_buf);
 	return 0;
 }
 
@@ -580,8 +583,8 @@ static int smsc95xx_ethtool_set_eeprom(struct net_device *netdev,
 	struct usbnet *dev = netdev_priv(netdev);
 
 	if (ee->magic != LAN95XX_EEPROM_MAGIC) {
-		devwarn(dev, "EEPROM: magic value mismatch, magic = 0x%x",
-			ee->magic);
+		usbnet_warn(dev, "EEPROM: magic value mismatch, magic = 0x%x\n",
+			    ee->magic);
 		return -EINVAL;
 	}
 
@@ -660,7 +663,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 		if (is_valid_ether_addr(dev->net->dev_addr)) {
 			/* eeprom values are valid so use them */
 			if (netif_msg_ifup(dev))
-				devdbg(dev, "MAC address read from EEPROM");
+				usbnet_dbg(dev, "MAC address read from EEPROM\n");
 			return;
 		}
 	}
@@ -668,7 +671,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
 	random_ether_addr(dev->net->dev_addr);
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "MAC address set to random_ether_addr");
+		usbnet_dbg(dev, "MAC address set to random_ether_addr\n");
 }
 
 static int smsc95xx_set_mac_address(struct usbnet *dev)
@@ -680,13 +683,13 @@ static int smsc95xx_set_mac_address(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, ADDRL, addr_lo);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write ADDRL: %d", ret);
+		usbnet_warn(dev, "Failed to write ADDRL: %d\n", ret);
 		return ret;
 	}
 
 	ret = smsc95xx_write_reg(dev, ADDRH, addr_hi);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write ADDRH: %d", ret);
+		usbnet_warn(dev, "Failed to write ADDRH: %d\n", ret);
 		return ret;
 	}
 
@@ -748,7 +751,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 	mii_nway_restart(&dev->mii);
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "phy initialised successfully");
+		usbnet_dbg(dev, "phy initialised successfully\n");
 	return 0;
 }
 
@@ -760,13 +763,13 @@ static int smsc95xx_reset(struct usbnet *dev)
 	int ret = 0, timeout;
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "entering smsc95xx_reset");
+		usbnet_dbg(dev, "entering smsc95xx_reset\n");
 
 	write_buf = HW_CFG_LRST_;
 	ret = smsc95xx_write_reg(dev, HW_CFG, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write HW_CFG_LRST_ bit in HW_CFG "
-			"register, ret = %d", ret);
+		usbnet_warn(dev, "Failed to write HW_CFG_LRST_ bit in HW_CFG register, ret = %d\n",
+			    ret);
 		return ret;
 	}
 
@@ -774,7 +777,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	do {
 		ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 		if (ret < 0) {
-			devwarn(dev, "Failed to read HW_CFG: %d", ret);
+			usbnet_warn(dev, "Failed to read HW_CFG: %d\n", ret);
 			return ret;
 		}
 		msleep(10);
@@ -782,14 +785,14 @@ static int smsc95xx_reset(struct usbnet *dev)
 	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
 
 	if (timeout >= 100) {
-		devwarn(dev, "timeout waiting for completion of Lite Reset");
+		usbnet_warn(dev, "timeout waiting for completion of Lite Reset\n");
 		return ret;
 	}
 
 	write_buf = PM_CTL_PHY_RST_;
 	ret = smsc95xx_write_reg(dev, PM_CTRL, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write PM_CTRL: %d", ret);
+		usbnet_warn(dev, "Failed to write PM_CTRL: %d\n", ret);
 		return ret;
 	}
 
@@ -797,7 +800,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	do {
 		ret = smsc95xx_read_reg(dev, PM_CTRL, &read_buf);
 		if (ret < 0) {
-			devwarn(dev, "Failed to read PM_CTRL: %d", ret);
+			usbnet_warn(dev, "Failed to read PM_CTRL: %d\n", ret);
 			return ret;
 		}
 		msleep(10);
@@ -805,7 +808,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
 
 	if (timeout >= 100) {
-		devwarn(dev, "timeout waiting for PHY Reset");
+		usbnet_warn(dev, "timeout waiting for PHY Reset\n");
 		return ret;
 	}
 
@@ -816,34 +819,34 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "MAC Address: %pM", dev->net->dev_addr);
+		usbnet_dbg(dev, "MAC Address: %pM\n", dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		usbnet_warn(dev, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG : 0x%08x", read_buf);
+		usbnet_dbg(dev, "Read Value from HW_CFG : 0x%08x\n", read_buf);
 
 	read_buf |= HW_CFG_BIR_;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write HW_CFG_BIR_ bit in HW_CFG "
-			"register, ret = %d", ret);
+		usbnet_warn(dev, "Failed to write HW_CFG_BIR_ bit in HW_CFG register, ret = %d\n",
+			    ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		usbnet_warn(dev, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG after writing "
-			"HW_CFG_BIR_: 0x%08x", read_buf);
+		usbnet_dbg(dev, "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
+			   read_buf);
 
 	if (!turbo_mode) {
 		burst_cap = 0;
@@ -857,46 +860,46 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "rx_urb_size=%ld", (ulong)dev->rx_urb_size);
+		usbnet_dbg(dev, "rx_urb_size=%ld\n", (ulong)dev->rx_urb_size);
 
 	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write BURST_CAP: %d", ret);
+		usbnet_warn(dev, "Failed to write BURST_CAP: %d\n", ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, BURST_CAP, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read BURST_CAP: %d", ret);
+		usbnet_warn(dev, "Failed to read BURST_CAP: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from BURST_CAP after writing: 0x%08x",
-			read_buf);
+		usbnet_dbg(dev, "Read Value from BURST_CAP after writing: 0x%08x\n",
+			   read_buf);
 
 	read_buf = DEFAULT_BULK_IN_DELAY;
 	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "ret = %d", ret);
+		usbnet_warn(dev, "ret = %d\n", ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, BULK_IN_DLY, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read BULK_IN_DLY: %d", ret);
+		usbnet_warn(dev, "Failed to read BULK_IN_DLY: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from BULK_IN_DLY after writing: "
-			"0x%08x", read_buf);
+		usbnet_dbg(dev, "Read Value from BULK_IN_DLY after writing: 0x%08x\n",
+			   read_buf);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		usbnet_warn(dev, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG: 0x%08x", read_buf);
+		usbnet_dbg(dev, "Read Value from HW_CFG: 0x%08x\n", read_buf);
 
 	if (turbo_mode)
 		read_buf |= (HW_CFG_MEF_ | HW_CFG_BCE_);
@@ -908,41 +911,43 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write HW_CFG register, ret=%d", ret);
+		usbnet_warn(dev, "Failed to write HW_CFG register, ret=%d\n",
+			    ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		usbnet_warn(dev, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG after writing: 0x%08x",
-			read_buf);
+		usbnet_dbg(dev, "Read Value from HW_CFG after writing: 0x%08x\n",
+			   read_buf);
 
 	write_buf = 0xFFFFFFFF;
 	ret = smsc95xx_write_reg(dev, INT_STS, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write INT_STS register, ret=%d", ret);
+		usbnet_warn(dev, "Failed to write INT_STS register, ret=%d\n",
+			    ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, ID_REV, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read ID_REV: %d", ret);
+		usbnet_warn(dev, "Failed to read ID_REV: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "ID_REV = 0x%08x", read_buf);
+		usbnet_dbg(dev, "ID_REV = 0x%08x\n", read_buf);
 
 	/* Configure GPIO pins as LED outputs */
 	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
 		LED_GPIO_CFG_FDX_LED;
 	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write LED_GPIO_CFG register, ret=%d",
-			ret);
+		usbnet_warn(dev, "Failed to write LED_GPIO_CFG register, ret=%d\n",
+			    ret);
 		return ret;
 	}
 
@@ -950,21 +955,21 @@ static int smsc95xx_reset(struct usbnet *dev)
 	write_buf = 0;
 	ret = smsc95xx_write_reg(dev, FLOW, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write FLOW: %d", ret);
+		usbnet_warn(dev, "Failed to write FLOW: %d\n", ret);
 		return ret;
 	}
 
 	read_buf = AFC_CFG_DEFAULT;
 	ret = smsc95xx_write_reg(dev, AFC_CFG, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write AFC_CFG: %d", ret);
+		usbnet_warn(dev, "Failed to write AFC_CFG: %d\n", ret);
 		return ret;
 	}
 
 	/* Don't need mac_cr_lock during initialisation */
 	ret = smsc95xx_read_reg(dev, MAC_CR, &pdata->mac_cr);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read MAC_CR: %d", ret);
+		usbnet_warn(dev, "Failed to read MAC_CR: %d\n", ret);
 		return ret;
 	}
 
@@ -973,7 +978,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	write_buf = (u32)ETH_P_8021Q;
 	ret = smsc95xx_write_reg(dev, VLAN1, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write VAN1: %d", ret);
+		usbnet_warn(dev, "Failed to write VAN1: %d\n", ret);
 		return ret;
 	}
 
@@ -981,7 +986,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
 	ret = smsc95xx_set_csums(dev);
 	if (ret < 0) {
-		devwarn(dev, "Failed to set csum offload: %d", ret);
+		usbnet_warn(dev, "Failed to set csum offload: %d\n", ret);
 		return ret;
 	}
 
@@ -992,7 +997,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	ret = smsc95xx_read_reg(dev, INT_EP_CTL, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read INT_EP_CTL: %d", ret);
+		usbnet_warn(dev, "Failed to read INT_EP_CTL: %d\n", ret);
 		return ret;
 	}
 
@@ -1001,7 +1006,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, INT_EP_CTL, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write INT_EP_CTL: %d", ret);
+		usbnet_warn(dev, "Failed to write INT_EP_CTL: %d\n", ret);
 		return ret;
 	}
 
@@ -1009,7 +1014,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	smsc95xx_start_rx_path(dev);
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "smsc95xx_reset, return 0");
+		usbnet_dbg(dev, "smsc95xx_reset, return 0\n");
 	return 0;
 }
 
@@ -1034,7 +1039,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	ret = usbnet_get_endpoints(dev, intf);
 	if (ret < 0) {
-		devwarn(dev, "usbnet_get_endpoints failed: %d", ret);
+		usbnet_warn(dev, "usbnet_get_endpoints failed: %d\n", ret);
 		return ret;
 	}
 
@@ -1043,7 +1048,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	if (!pdata) {
-		devwarn(dev, "Unable to allocate struct smsc95xx_priv");
+		usbnet_warn(dev, "Unable to allocate struct smsc95xx_priv\n");
 		return -ENOMEM;
 	}
 
@@ -1067,7 +1072,7 @@ static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	if (pdata) {
 		if (netif_msg_ifdown(dev))
-			devdbg(dev, "free pdata");
+			usbnet_dbg(dev, "free pdata\n");
 		kfree(pdata);
 		pdata = NULL;
 		dev->data[0] = 0;
@@ -1102,7 +1107,8 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		if (unlikely(header & RX_STS_ES_)) {
 			if (netif_msg_rx_err(dev))
-				devdbg(dev, "Error header=0x%08x", header);
+				usbnet_dbg(dev, "Error header=0x%08x\n",
+					   header);
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_dropped++;
 
@@ -1120,8 +1126,8 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */
 			if (unlikely(size > (ETH_FRAME_LEN + 12))) {
 				if (netif_msg_rx_err(dev))
-					devdbg(dev, "size err header=0x%08x",
-						header);
+					usbnet_dbg(dev, "size err header=0x%08x\n",
+						   header);
 				return 0;
 			}
 
@@ -1137,7 +1143,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 			ax_skb = skb_clone(skb, GFP_ATOMIC);
 			if (unlikely(!ax_skb)) {
-				devwarn(dev, "Error allocating skb");
+				usbnet_warn(dev, "Error allocating skb\n");
 				return 0;
 			}
 
@@ -1161,7 +1167,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 	if (unlikely(skb->len < 0)) {
-		devwarn(dev, "invalid rx length<0 %d", skb->len);
+		usbnet_warn(dev, "invalid rx length<0 %d\n", skb->len);
 		return 0;
 	}
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 035fab0..9f2747d 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -243,12 +243,12 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	dev->net->stats.rx_bytes += skb->len;
 
 	if (netif_msg_rx_status (dev))
-		devdbg (dev, "< rx, len %zu, type 0x%x",
-			skb->len + sizeof (struct ethhdr), skb->protocol);
+		usbnet_dbg(dev, "< rx, len %zu, type 0x%x\n",
+			   skb->len + sizeof (struct ethhdr), skb->protocol);
 	memset (skb->cb, 0, sizeof (struct skb_data));
 	status = netif_rx (skb);
 	if (status != NET_RX_SUCCESS && netif_msg_rx_err (dev))
-		devdbg (dev, "netif_rx status %d", status);
+		usbnet_dbg(dev, "netif_rx status %d\n", status);
 }
 EXPORT_SYMBOL_GPL(usbnet_skb_return);
 
@@ -313,9 +313,9 @@ void usbnet_defer_kevent (struct usbnet *dev, int work)
 {
 	set_bit (work, &dev->flags);
 	if (!schedule_work (&dev->kevent))
-		deverr (dev, "kevent %d may have been dropped", work);
+		usbnet_err(dev, "kevent %d may have been dropped\n", work);
 	else
-		devdbg (dev, "kevent %d scheduled", work);
+		usbnet_dbg(dev, "kevent %d scheduled\n", work);
 }
 EXPORT_SYMBOL_GPL(usbnet_defer_kevent);
 
@@ -333,7 +333,7 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 
 	if ((skb = alloc_skb (size + NET_IP_ALIGN, flags)) == NULL) {
 		if (netif_msg_rx_err (dev))
-			devdbg (dev, "no rx skb");
+			usbnet_dbg(dev, "no rx skb\n");
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 		usb_free_urb (urb);
 		return;
@@ -364,12 +364,12 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 			break;
 		case -ENODEV:
 			if (netif_msg_ifdown (dev))
-				devdbg (dev, "device gone");
+				usbnet_dbg(dev, "device gone\n");
 			netif_device_detach (dev->net);
 			break;
 		default:
 			if (netif_msg_rx_err (dev))
-				devdbg (dev, "rx submit, %d", retval);
+				usbnet_dbg(dev, "rx submit, %d\n", retval);
 			tasklet_schedule (&dev->bh);
 			break;
 		case 0:
@@ -377,7 +377,7 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 		}
 	} else {
 		if (netif_msg_ifdown (dev))
-			devdbg (dev, "rx: stopped");
+			usbnet_dbg(dev, "rx: stopped\n");
 		retval = -ENOLINK;
 	}
 	spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
@@ -401,7 +401,7 @@ static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 		usbnet_skb_return (dev, skb);
 	else {
 		if (netif_msg_rx_err (dev))
-			devdbg (dev, "drop");
+			usbnet_dbg(dev, "drop\n");
 error:
 		dev->net->stats.rx_errors++;
 		skb_queue_tail (&dev->done, skb);
@@ -429,7 +429,7 @@ static void rx_complete (struct urb *urb)
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_length_errors++;
 			if (netif_msg_rx_err (dev))
-				devdbg (dev, "rx length %d", skb->len);
+				usbnet_dbg(dev, "rx length %d\n", skb->len);
 		}
 		break;
 
@@ -447,7 +447,7 @@ static void rx_complete (struct urb *urb)
 	case -ECONNRESET:		/* async unlink */
 	case -ESHUTDOWN:		/* hardware gone */
 		if (netif_msg_ifdown (dev))
-			devdbg (dev, "rx shutdown, code %d", urb_status);
+			usbnet_dbg(dev, "rx shutdown, code %d\n", urb_status);
 		goto block;
 
 	/* we get controller i/o faults during khubd disconnect() delays.
@@ -461,7 +461,7 @@ static void rx_complete (struct urb *urb)
 		if (!timer_pending (&dev->delay)) {
 			mod_timer (&dev->delay, jiffies + THROTTLE_JIFFIES);
 			if (netif_msg_link (dev))
-				devdbg (dev, "rx throttle %d", urb_status);
+				usbnet_dbg(dev, "rx throttle %d\n", urb_status);
 		}
 block:
 		entry->state = rx_cleanup;
@@ -478,7 +478,7 @@ block:
 		entry->state = rx_cleanup;
 		dev->net->stats.rx_errors++;
 		if (netif_msg_rx_err (dev))
-			devdbg (dev, "rx status %d", urb_status);
+			usbnet_dbg(dev, "rx status %d\n", urb_status);
 		break;
 	}
 
@@ -493,7 +493,7 @@ block:
 		usb_free_urb (urb);
 	}
 	if (netif_msg_rx_err (dev))
-		devdbg (dev, "no read resubmitted");
+		usbnet_dbg(dev, "no read resubmitted\n");
 }
 
 static void intr_complete (struct urb *urb)
@@ -511,14 +511,14 @@ static void intr_complete (struct urb *urb)
 	case -ENOENT:		/* urb killed */
 	case -ESHUTDOWN:	/* hardware gone */
 		if (netif_msg_ifdown (dev))
-			devdbg (dev, "intr shutdown, code %d", status);
+			usbnet_dbg(dev, "intr shutdown, code %d\n", status);
 		return;
 
 	/* NOTE:  not throttling like RX/TX, since this endpoint
 	 * already polls infrequently
 	 */
 	default:
-		devdbg (dev, "intr status %d", status);
+		usbnet_dbg(dev, "intr status %d\n", status);
 		break;
 	}
 
@@ -528,7 +528,7 @@ static void intr_complete (struct urb *urb)
 	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
 	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status != 0 && netif_msg_timer (dev))
-		deverr(dev, "intr resubmit --> %d", status);
+		usbnet_err(dev, "intr resubmit --> %d\n", status);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -537,7 +537,7 @@ void usbnet_pause_rx(struct usbnet *dev)
 	set_bit(EVENT_RX_PAUSED, &dev->flags);
 
 	if (netif_msg_rx_status(dev))
-		devdbg(dev, "paused rx queue enabled");
+		usbnet_dbg(dev, "paused rx queue enabled\n");
 }
 EXPORT_SYMBOL_GPL(usbnet_pause_rx);
 
@@ -556,7 +556,8 @@ void usbnet_resume_rx(struct usbnet *dev)
 	tasklet_schedule(&dev->bh);
 
 	if (netif_msg_rx_status(dev))
-		devdbg(dev, "paused rx queue disabled, %d skbs requeued", num);
+		usbnet_dbg(dev, "paused rx queue disabled, %d skbs requeued\n",
+			   num);
 }
 EXPORT_SYMBOL_GPL(usbnet_resume_rx);
 
@@ -589,7 +590,7 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 		// these (async) unlinks complete immediately
 		retval = usb_unlink_urb (urb);
 		if (retval != -EINPROGRESS && retval != 0)
-			devdbg (dev, "unlink urb err, %d", retval);
+			usbnet_dbg(dev, "unlink urb err, %d\n", retval);
 		else
 			count++;
 	}
@@ -632,8 +633,8 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 			schedule_timeout(UNLINK_TIMEOUT_MS);
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			if (netif_msg_ifdown(dev))
-				devdbg(dev, "waited for %d urb completions",
-					temp);
+				usbnet_dbg(dev, "waited for %d urb completions\n",
+					   temp);
 	}
 	set_current_state(TASK_RUNNING);
 	dev->wait = NULL;
@@ -649,9 +650,9 @@ int usbnet_stop (struct net_device *net)
 	netif_stop_queue (net);
 
 	if (netif_msg_ifdown (dev))
-		devinfo (dev, "stop stats: rx/tx %ld/%ld, errs %ld/%ld",
-			net->stats.rx_packets, net->stats.tx_packets,
-			net->stats.rx_errors, net->stats.tx_errors
+		usbnet_info(dev, "stop stats: rx/tx %ld/%ld, errs %ld/%ld\n",
+			    net->stats.rx_packets, net->stats.tx_packets,
+			    net->stats.rx_errors, net->stats.tx_errors
 			);
 
 	/* allow minidriver to stop correctly (wireless devices to turn off
@@ -659,11 +660,11 @@ int usbnet_stop (struct net_device *net)
 	if (info->stop) {
 		retval = info->stop(dev);
 		if (retval < 0 && netif_msg_ifdown(dev))
-			devinfo(dev,
-				"stop fail (%d) usbnet usb-%s-%s, %s",
-				retval,
-				dev->udev->bus->bus_name, dev->udev->devpath,
-				info->description);
+			usbnet_info(dev,
+				    "stop fail (%d) usbnet usb-%s-%s, %s\n",
+				    retval,
+				    dev->udev->bus->bus_name, dev->udev->devpath,
+				    info->description);
 	}
 
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
@@ -703,29 +704,31 @@ int usbnet_open (struct net_device *net)
 
 	if ((retval = usb_autopm_get_interface(dev->intf)) < 0) {
 		if (netif_msg_ifup (dev))
-			devinfo (dev,
-				"resumption fail (%d) usbnet usb-%s-%s, %s",
-				retval,
-				dev->udev->bus->bus_name, dev->udev->devpath,
-			info->description);
+			usbnet_info(dev,
+				    "resumption fail (%d) usbnet usb-%s-%s, %s\n",
+				    retval,
+				    dev->udev->bus->bus_name,
+				    dev->udev->devpath,
+				    info->description);
 		goto done_nopm;
 	}
 
 	// put into "known safe" state
 	if (info->reset && (retval = info->reset (dev)) < 0) {
 		if (netif_msg_ifup (dev))
-			devinfo (dev,
-				"open reset fail (%d) usbnet usb-%s-%s, %s",
-				retval,
-				dev->udev->bus->bus_name, dev->udev->devpath,
-			info->description);
+			usbnet_info(dev,
+				    "open reset fail (%d) usbnet usb-%s-%s, %s\n",
+				    retval,
+				    dev->udev->bus->bus_name,
+				    dev->udev->devpath,
+				    info->description);
 		goto done;
 	}
 
 	// insist peer be connected
 	if (info->check_connect && (retval = info->check_connect (dev)) < 0) {
 		if (netif_msg_ifup (dev))
-			devdbg (dev, "can't open; %d", retval);
+			usbnet_dbg(dev, "can't open; %d\n", retval);
 		goto done;
 	}
 
@@ -734,7 +737,7 @@ int usbnet_open (struct net_device *net)
 		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
 		if (retval < 0) {
 			if (netif_msg_ifup (dev))
-				deverr (dev, "intr submit %d", retval);
+				usbnet_err(dev, "intr submit %d\n", retval);
 			goto done;
 		}
 	}
@@ -756,10 +759,9 @@ int usbnet_open (struct net_device *net)
 		else
 			framing = "simple";
 
-		devinfo (dev, "open: enable queueing "
-				"(rx %d, tx %d) mtu %d %s framing",
-			(int)RX_QLEN (dev), (int)TX_QLEN (dev), dev->net->mtu,
-			framing);
+		usbnet_info(dev, "open: enable queueing (rx %d, tx %d) mtu %d %s framing\n",
+			    (int)RX_QLEN(dev), (int)TX_QLEN(dev),
+			    dev->net->mtu, framing);
 	}
 
 	// delay posting reads until we're fully open
@@ -908,8 +910,8 @@ kevent (struct work_struct *work)
 		    status != -ESHUTDOWN) {
 			if (netif_msg_tx_err (dev))
 fail_pipe:
-				deverr (dev, "can't clear tx halt, status %d",
-					status);
+				usbnet_err(dev, "can't clear tx halt, status %d\n",
+					   status);
 		} else {
 			clear_bit (EVENT_TX_HALT, &dev->flags);
 			if (status != -ESHUTDOWN)
@@ -928,8 +930,8 @@ fail_pipe:
 		    status != -ESHUTDOWN) {
 			if (netif_msg_rx_err (dev))
 fail_halt:
-				deverr (dev, "can't clear rx halt, status %d",
-					status);
+				usbnet_err(dev, "can't clear rx halt, status %d\n",
+					   status);
 		} else {
 			clear_bit (EVENT_RX_HALT, &dev->flags);
 			tasklet_schedule (&dev->bh);
@@ -967,18 +969,18 @@ fail_lowmem:
 		if(info->link_reset && (retval = info->link_reset(dev)) < 0) {
 			usb_autopm_put_interface(dev->intf);
 skip_reset:
-			devinfo(dev, "link reset failed (%d) usbnet usb-%s-%s, %s",
-				retval,
-				dev->udev->bus->bus_name, dev->udev->devpath,
-				info->description);
+			usbnet_info(dev, "link reset failed (%d) usbnet usb-%s-%s, %s\n",
+				    retval,
+				    dev->udev->bus->bus_name,
+				    dev->udev->devpath,
+				    info->description);
 		} else {
 			usb_autopm_put_interface(dev->intf);
 		}
 	}
 
 	if (dev->flags)
-		devdbg (dev, "kevent done, flags = 0x%lx",
-			dev->flags);
+		usbnet_dbg(dev, "kevent done, flags = 0x%lx\n", dev->flags);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -1015,14 +1017,15 @@ static void tx_complete (struct urb *urb)
 				mod_timer (&dev->delay,
 					jiffies + THROTTLE_JIFFIES);
 				if (netif_msg_link (dev))
-					devdbg (dev, "tx throttle %d",
-							urb->status);
+					usbnet_dbg(dev, "tx throttle %d\n",
+						   urb->status);
 			}
 			netif_stop_queue (dev->net);
 			break;
 		default:
 			if (netif_msg_tx_err (dev))
-				devdbg (dev, "tx err %d", entry->urb->status);
+				usbnet_dbg(dev, "tx err %d\n",
+					   entry->urb->status);
 			break;
 		}
 	}
@@ -1065,7 +1068,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
 		if (!skb) {
 			if (netif_msg_tx_err (dev))
-				devdbg (dev, "can't tx_fixup skb");
+				usbnet_dbg(dev, "can't tx_fixup skb\n");
 			goto drop;
 		}
 	}
@@ -1073,7 +1076,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 
 	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
 		if (netif_msg_tx_err (dev))
-			devdbg (dev, "no urb");
+			usbnet_dbg(dev, "no urb\n");
 		goto drop;
 	}
 
@@ -1113,7 +1116,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		/* no use to process more packets */
 		netif_stop_queue(net);
 		spin_unlock_irqrestore(&dev->txq.lock, flags);
-		devdbg(dev, "Delaying transmission for resumption");
+		usbnet_dbg(dev, "Delaying transmission for resumption\n");
 		goto deferred;
 	}
 #endif
@@ -1127,7 +1130,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	default:
 		usb_autopm_put_interface_async(dev->intf);
 		if (netif_msg_tx_err (dev))
-			devdbg (dev, "tx: submit urb err %d", retval);
+			usbnet_dbg(dev, "tx: submit urb err %d\n", retval);
 		break;
 	case 0:
 		net->trans_start = jiffies;
@@ -1139,15 +1142,15 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 
 	if (retval) {
 		if (netif_msg_tx_err (dev))
-			devdbg (dev, "drop, code %d", retval);
+			usbnet_dbg(dev, "drop, code %d\n", retval);
 drop:
 		dev->net->stats.tx_dropped++;
 		if (skb)
 			dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
 	} else if (netif_msg_tx_queued (dev)) {
-		devdbg (dev, "> tx, len %d, type 0x%x",
-			length, skb->protocol);
+		usbnet_dbg(dev, "> tx, len %d, type 0x%x\n",
+			   length, skb->protocol);
 	}
 #ifdef CONFIG_PM
 deferred:
@@ -1179,7 +1182,7 @@ static void usbnet_bh (unsigned long param)
 			dev_kfree_skb (skb);
 			continue;
 		default:
-			devdbg (dev, "bogus skb state %d", entry->state);
+			usbnet_dbg(dev, "bogus skb state %d\n", entry->state);
 		}
 	}
 
@@ -1208,8 +1211,8 @@ static void usbnet_bh (unsigned long param)
 					rx_submit (dev, urb, GFP_ATOMIC);
 			}
 			if (temp != dev->rxq.qlen && netif_msg_link (dev))
-				devdbg (dev, "rxqlen %d --> %d",
-						temp, dev->rxq.qlen);
+				usbnet_dbg(dev, "rxqlen %d --> %d\n",
+					   temp, dev->rxq.qlen);
 			if (dev->rxq.qlen < qlen)
 				tasklet_schedule (&dev->bh);
 		}
@@ -1241,10 +1244,10 @@ void usbnet_disconnect (struct usb_interface *intf)
 	xdev = interface_to_usbdev (intf);
 
 	if (netif_msg_probe (dev))
-		devinfo (dev, "unregister '%s' usb-%s-%s, %s",
-			intf->dev.driver->name,
-			xdev->bus->bus_name, xdev->devpath,
-			dev->driver_info->description);
+		usbnet_info(dev, "unregister '%s' usb-%s-%s, %s\n",
+			    intf->dev.driver->name,
+			    xdev->bus->bus_name, xdev->devpath,
+			    dev->driver_info->description);
 
 	net = dev->net;
 	unregister_netdev (net);
@@ -1408,11 +1411,11 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	if (status)
 		goto out3;
 	if (netif_msg_probe (dev))
-		devinfo (dev, "register '%s' at usb-%s-%s, %s, %pM",
-			udev->dev.driver->name,
-			xdev->bus->bus_name, xdev->devpath,
-			dev->driver_info->description,
-			net->dev_addr);
+		usbnet_info(dev, "register '%s' at usb-%s-%s, %s, %pM\n",
+			    udev->dev.driver->name,
+			    xdev->bus->bus_name, xdev->devpath,
+			    dev->driver_info->description,
+			    net->dev_addr);
 
 	// ok, it's ready to go.
 	usb_set_intfdata (udev, dev);
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 8ce6135..9c8219b 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -218,21 +218,21 @@ extern int usbnet_nway_reset(struct net_device *net);
  * used before it has one ... notably, in minidriver bind() calls.
  */
 #ifdef DEBUG
-#define devdbg(usbnet, fmt, arg...) \
-	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
+#define usbnet_dbg(usbnet, fmt, arg...)					\
+	printk(KERN_DEBUG "%s: " fmt, (usbnet)->net->name, ##arg)
 #else
-#define devdbg(usbnet, fmt, arg...) \
-	({ if (0) printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , \
-		## arg); 0; })
+#define usbnet_dbg(usbnet, fmt, arg...)					\
+({									\
+	if (0)								\
+		printk(KERN_DEBUG "%s: " fmt, (usbnet)->net->name, ##arg); \
+	0;								\
+})
 #endif
-
-#define deverr(usbnet, fmt, arg...) \
-	printk(KERN_ERR "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
-#define devwarn(usbnet, fmt, arg...) \
-	printk(KERN_WARNING "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
-
-#define devinfo(usbnet, fmt, arg...) \
-	printk(KERN_INFO "%s: " fmt "\n" , (usbnet)->net->name , ## arg); \
-
+#define usbnet_err(usbnet, fmt, arg...)					\
+	printk(KERN_ERR "%s: " fmt, (usbnet)->net->name, ##arg)
+#define usbnet_warn(usbnet, fmt, arg...)				\
+	printk(KERN_WARNING "%s: " fmt, (usbnet)->net->name, ##arg)
+#define usbnet_info(usbnet, fmt, arg...)				\
+	printk(KERN_INFO "%s: " fmt, (usbnet)->net->name, ##arg)
 
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.7.0.rc1.33.g07cf0f


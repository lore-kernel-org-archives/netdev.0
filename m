From: Joe Perches <joe@perches.com>
Subject: [PATCH V3 net-next 1/2] usbnet: Convert dev(dbg|err|warn|info) macros to netdev_<level>
Date: Wed, 17 Feb 2010 12:30:23 -0800
Message-ID: <d1fb00491120673703e5a74425855692bc70aba0.1266438216.git.joe@perches.com>
References: <20100217.000422.246530855.davem@davemloft.net> <cover.1266438216.git.joe@perches.com>
Cc: David Brownell <david-b@pacbell.net>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	Tilman Schmidt <tilman@imap.cc>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1037 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755773Ab0BQUa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Feb 2010 15:30:27 -0500
In-Reply-To: <cover.1266438216.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These macros are too similar to the dev_<level> equivalents
but take a usbnet * argument.  Convert them to the recently
introduced netdev_<level> macros and remove the old macros.

The old macros had "\n" appended to the format string.
Add the "\n" to the converted uses.

Some existing uses of the dev<foo> macros in cdc_eem.c
probably mistakenly had trailing "\n".  No "\n" added there.

Fix net1080 this/other log message inversion.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/usb/asix.c            |   97 ++++++-----
 drivers/net/usb/cdc_eem.c         |   10 +-
 drivers/net/usb/cdc_ether.c       |   18 +-
 drivers/net/usb/dm9601.c          |   49 +++---
 drivers/net/usb/int51x1.c         |   15 +-
 drivers/net/usb/net1080.c         |  101 ++++++------
 drivers/net/usb/rndis_host.c      |   10 +-
 drivers/net/usb/smsc95xx.c        |  188 +++++++++++-----------
 drivers/net/usb/usbnet.c          |  162 ++++++++++---------
 drivers/net/wireless/rndis_wlan.c |  325 ++++++++++++++++++++-----------------
 include/linux/usb/usbnet.h        |   21 ---
 11 files changed, 507 insertions(+), 489 deletions(-)

diff --git a/drivers/net/usb/asix.c b/drivers/net/usb/asix.c
index f025517..f605204 100644
--- a/drivers/net/usb/asix.c
+++ b/drivers/net/usb/asix.c
@@ -184,8 +184,8 @@ static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 	void *buf;
 	int err = -ENOMEM;
 
-	devdbg(dev,"asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
-		cmd, value, index, size);
+	netdev_dbg(dev->net, "asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
 
 	buf = kmalloc(size, GFP_KERNEL);
 	if (!buf)
@@ -217,8 +217,8 @@ static int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 	void *buf = NULL;
 	int err = -ENOMEM;
 
-	devdbg(dev,"asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
-		cmd, value, index, size);
+	netdev_dbg(dev->net, "asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
 
 	if (data) {
 		buf = kmalloc(size, GFP_KERNEL);
@@ -264,15 +264,15 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 	int status;
 	struct urb *urb;
 
-	devdbg(dev,"asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d",
-		cmd, value, index, size);
+	netdev_dbg(dev->net, "asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
+		   cmd, value, index, size);
 	if ((urb = usb_alloc_urb(0, GFP_ATOMIC)) == NULL) {
-		deverr(dev, "Error allocating URB in write_cmd_async!");
+		netdev_err(dev->net, "Error allocating URB in write_cmd_async!\n");
 		return;
 	}
 
 	if ((req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC)) == NULL) {
-		deverr(dev, "Failed to allocate memory for control request");
+		netdev_err(dev->net, "Failed to allocate memory for control request\n");
 		usb_free_urb(urb);
 		return;
 	}
@@ -289,8 +289,8 @@ asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			     asix_async_cmd_callback, req);
 
 	if((status = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
-		deverr(dev, "Error submitting the control message: status=%d",
-				status);
+		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
+			   status);
 		kfree(req);
 		usb_free_urb(urb);
 	}
@@ -314,7 +314,7 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	while (skb->len > 0) {
 		if ((short)(header & 0x0000ffff) !=
 		    ~((short)((header & 0xffff0000) >> 16))) {
-			deverr(dev,"asix_rx_fixup() Bad Header Length");
+			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
 		}
 		/* get the packet length */
 		size = (u16) (header & 0x0000ffff);
@@ -322,7 +322,8 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		if ((skb->len) - ((size + 1) & 0xfffe) == 0)
 			return 2;
 		if (size > ETH_FRAME_LEN) {
-			deverr(dev,"asix_rx_fixup() Bad RX Length %d", size);
+			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
+				   size);
 			return 0;
 		}
 		ax_skb = skb_clone(skb, GFP_ATOMIC);
@@ -348,7 +349,8 @@ static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 	if (skb->len < 0) {
-		deverr(dev,"asix_rx_fixup() Bad SKB Length %d", skb->len);
+		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d\n",
+			   skb->len);
 		return 0;
 	}
 	return 1;
@@ -409,7 +411,7 @@ static void asix_status(struct usbnet *dev, struct urb *urb)
 			usbnet_defer_kevent (dev, EVENT_LINK_RESET );
 		} else
 			netif_carrier_off(dev->net);
-		devdbg(dev, "Link Status is: %d", link);
+		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
 
@@ -418,7 +420,7 @@ static inline int asix_set_sw_mii(struct usbnet *dev)
 	int ret;
 	ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to enable software MII access");
+		netdev_err(dev->net, "Failed to enable software MII access\n");
 	return ret;
 }
 
@@ -427,7 +429,7 @@ static inline int asix_set_hw_mii(struct usbnet *dev)
 	int ret;
 	ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to enable hardware MII access");
+		netdev_err(dev->net, "Failed to enable hardware MII access\n");
 	return ret;
 }
 
@@ -436,13 +438,14 @@ static inline int asix_get_phy_addr(struct usbnet *dev)
 	u8 buf[2];
 	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
 
-	devdbg(dev, "asix_get_phy_addr()");
+	netdev_dbg(dev->net, "asix_get_phy_addr()\n");
 
 	if (ret < 0) {
-		deverr(dev, "Error reading PHYID register: %02x", ret);
+		netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
 		goto out;
 	}
-	devdbg(dev, "asix_get_phy_addr() returning 0x%04x", *((__le16 *)buf));
+	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
+		   *((__le16 *)buf));
 	ret = buf[1];
 
 out:
@@ -455,7 +458,7 @@ static int asix_sw_reset(struct usbnet *dev, u8 flags)
 
         ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev,"Failed to send software reset: %02x", ret);
+		netdev_err(dev->net, "Failed to send software reset: %02x\n", ret);
 
 	return ret;
 }
@@ -466,7 +469,7 @@ static u16 asix_read_rx_ctl(struct usbnet *dev)
 	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
 
 	if (ret < 0) {
-		deverr(dev, "Error reading RX_CTL register: %02x", ret);
+		netdev_err(dev->net, "Error reading RX_CTL register: %02x\n", ret);
 		goto out;
 	}
 	ret = le16_to_cpu(v);
@@ -478,11 +481,11 @@ static int asix_write_rx_ctl(struct usbnet *dev, u16 mode)
 {
 	int ret;
 
-	devdbg(dev,"asix_write_rx_ctl() - mode = 0x%04x", mode);
+	netdev_dbg(dev->net, "asix_write_rx_ctl() - mode = 0x%04x\n", mode);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_RX_CTL, mode, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to write RX_CTL mode to 0x%04x: %02x",
-		       mode, ret);
+		netdev_err(dev->net, "Failed to write RX_CTL mode to 0x%04x: %02x\n",
+			   mode, ret);
 
 	return ret;
 }
@@ -493,7 +496,8 @@ static u16 asix_read_medium_status(struct usbnet *dev)
 	int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
 
 	if (ret < 0) {
-		deverr(dev, "Error reading Medium Status register: %02x", ret);
+		netdev_err(dev->net, "Error reading Medium Status register: %02x\n",
+			   ret);
 		goto out;
 	}
 	ret = le16_to_cpu(v);
@@ -505,11 +509,11 @@ static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
 {
 	int ret;
 
-	devdbg(dev,"asix_write_medium_mode() - mode = 0x%04x", mode);
+	netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n", mode);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to write Medium Mode mode to 0x%04x: %02x",
-			mode, ret);
+		netdev_err(dev->net, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
+			   mode, ret);
 
 	return ret;
 }
@@ -518,11 +522,11 @@ static int asix_write_gpio(struct usbnet *dev, u16 value, int sleep)
 {
 	int ret;
 
-	devdbg(dev,"asix_write_gpio() - value = 0x%04x", value);
+	netdev_dbg(dev->net, "asix_write_gpio() - value = 0x%04x\n", value);
 	ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
 	if (ret < 0)
-		deverr(dev, "Failed to write GPIO value 0x%04x: %02x",
-			value, ret);
+		netdev_err(dev->net, "Failed to write GPIO value 0x%04x: %02x\n",
+			   value, ret);
 
 	if (sleep)
 		msleep(sleep);
@@ -588,7 +592,8 @@ static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	asix_set_hw_mii(dev);
 	mutex_unlock(&dev->phy_mutex);
 
-	devdbg(dev, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x", phy_id, loc, le16_to_cpu(res));
+	netdev_dbg(dev->net, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+		   phy_id, loc, le16_to_cpu(res));
 
 	return le16_to_cpu(res);
 }
@@ -599,7 +604,8 @@ asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
 	struct usbnet *dev = netdev_priv(netdev);
 	__le16 res = cpu_to_le16(val);
 
-	devdbg(dev, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x", phy_id, loc, val);
+	netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+		   phy_id, loc, val);
 	mutex_lock(&dev->phy_mutex);
 	asix_set_sw_mii(dev);
 	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
@@ -800,7 +806,8 @@ static int ax88172_link_reset(struct usbnet *dev)
 	if (ecmd.duplex != DUPLEX_FULL)
 		mode |= ~AX88172_MEDIUM_FD;
 
-	devdbg(dev, "ax88172_link_reset() speed: %d duplex: %d setting mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
+	netdev_dbg(dev->net, "ax88172_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
+		   ecmd.speed, ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -902,7 +909,8 @@ static int ax88772_link_reset(struct usbnet *dev)
 	if (ecmd.duplex != DUPLEX_FULL)
 		mode &= ~AX_MEDIUM_FD;
 
-	devdbg(dev, "ax88772_link_reset() speed: %d duplex: %d setting mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
+	netdev_dbg(dev->net, "ax88772_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
+		   ecmd.speed, ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -1059,10 +1067,10 @@ static int marvell_phy_init(struct usbnet *dev)
 	struct asix_data *data = (struct asix_data *)&dev->data;
 	u16 reg;
 
-	devdbg(dev,"marvell_phy_init()");
+	netdev_dbg(dev->net, "marvell_phy_init()\n");
 
 	reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_MARVELL_STATUS);
-	devdbg(dev,"MII_MARVELL_STATUS = 0x%04x", reg);
+	netdev_dbg(dev->net, "MII_MARVELL_STATUS = 0x%04x\n", reg);
 
 	asix_mdio_write(dev->net, dev->mii.phy_id, MII_MARVELL_CTRL,
 			MARVELL_CTRL_RXDELAY | MARVELL_CTRL_TXDELAY);
@@ -1070,7 +1078,7 @@ static int marvell_phy_init(struct usbnet *dev)
 	if (data->ledmode) {
 		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
 			MII_MARVELL_LED_CTRL);
-		devdbg(dev,"MII_MARVELL_LED_CTRL (1) = 0x%04x", reg);
+		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (1) = 0x%04x\n", reg);
 
 		reg &= 0xf8ff;
 		reg |= (1 + 0x0100);
@@ -1079,7 +1087,7 @@ static int marvell_phy_init(struct usbnet *dev)
 
 		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
 			MII_MARVELL_LED_CTRL);
-		devdbg(dev,"MII_MARVELL_LED_CTRL (2) = 0x%04x", reg);
+		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (2) = 0x%04x\n", reg);
 		reg &= 0xfc0f;
 	}
 
@@ -1090,7 +1098,7 @@ static int marvell_led_status(struct usbnet *dev, u16 speed)
 {
 	u16 reg = asix_mdio_read(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL);
 
-	devdbg(dev, "marvell_led_status() read 0x%04x", reg);
+	netdev_dbg(dev->net, "marvell_led_status() read 0x%04x\n", reg);
 
 	/* Clear out the center LED bits - 0x03F0 */
 	reg &= 0xfc0f;
@@ -1106,7 +1114,7 @@ static int marvell_led_status(struct usbnet *dev, u16 speed)
 			reg |= 0x02f0;
 	}
 
-	devdbg(dev, "marvell_led_status() writing 0x%04x", reg);
+	netdev_dbg(dev->net, "marvell_led_status() writing 0x%04x\n", reg);
 	asix_mdio_write(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL, reg);
 
 	return 0;
@@ -1118,7 +1126,7 @@ static int ax88178_link_reset(struct usbnet *dev)
 	struct ethtool_cmd ecmd;
 	struct asix_data *data = (struct asix_data *)&dev->data;
 
-	devdbg(dev,"ax88178_link_reset()");
+	netdev_dbg(dev->net, "ax88178_link_reset()\n");
 
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
@@ -1138,7 +1146,8 @@ static int ax88178_link_reset(struct usbnet *dev)
 	else
 		mode &= ~AX_MEDIUM_FD;
 
-	devdbg(dev, "ax88178_link_reset() speed: %d duplex: %d setting mode to 0x%04x", ecmd.speed, ecmd.duplex, mode);
+	netdev_dbg(dev->net, "ax88178_link_reset() speed: %d duplex: %d setting mode to 0x%04x\n",
+		   ecmd.speed, ecmd.duplex, mode);
 
 	asix_write_medium_mode(dev, mode);
 
@@ -1188,7 +1197,7 @@ static int ax88178_change_mtu(struct net_device *net, int new_mtu)
 	struct usbnet *dev = netdev_priv(net);
 	int ll_mtu = new_mtu + net->hard_header_len + 4;
 
-	devdbg(dev, "ax88178_change_mtu() new_mtu=%d", new_mtu);
+	netdev_dbg(dev->net, "ax88178_change_mtu() new_mtu=%d\n", new_mtu);
 
 	if (new_mtu <= 0 || ll_mtu > 16384)
 		return -EINVAL;
diff --git a/drivers/net/usb/cdc_eem.c b/drivers/net/usb/cdc_eem.c
index c337ffc..a4a85a6 100644
--- a/drivers/net/usb/cdc_eem.c
+++ b/drivers/net/usb/cdc_eem.c
@@ -73,7 +73,7 @@ static void eem_linkcmd(struct usbnet *dev, struct sk_buff *skb)
 		usb_free_urb(urb);
 fail:
 		dev_kfree_skb(skb);
-		devwarn(dev, "link cmd failure\n");
+		netdev_warn(dev->net, "link cmd failure\n");
 		return;
 	}
 }
@@ -212,7 +212,8 @@ static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			 * b15:		1 (EEM command)
 			 */
 			if (header & BIT(14)) {
-				devdbg(dev, "reserved command %04x\n", header);
+				netdev_dbg(dev->net, "reserved command %04x\n",
+					   header);
 				continue;
 			}
 
@@ -255,8 +256,9 @@ static int eem_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			case 1:		/* Echo response */
 			case 5:		/* Tickle */
 			default:	/* reserved */
-				devwarn(dev, "unexpected link command %d\n",
-						bmEEMCmd);
+				netdev_warn(dev->net,
+					    "unexpected link command %d\n",
+					    bmEEMCmd);
 				continue;
 			}
 
diff --git a/drivers/net/usb/cdc_ether.c b/drivers/net/usb/cdc_ether.c
index 4f27f02..7e5a752 100644
--- a/drivers/net/usb/cdc_ether.c
+++ b/drivers/net/usb/cdc_ether.c
@@ -340,9 +340,9 @@ EXPORT_SYMBOL_GPL(usbnet_cdc_unbind);
 static void dumpspeed(struct usbnet *dev, __le32 *speeds)
 {
 	if (netif_msg_timer(dev))
-		devinfo(dev, "link speeds: %u kbps up, %u kbps down",
-			__le32_to_cpu(speeds[0]) / 1000,
-		__le32_to_cpu(speeds[1]) / 1000);
+		netdev_info(dev->net, "link speeds: %u kbps up, %u kbps down\n",
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
+			netdev_dbg(dev->net, "CDC: carrier %s\n",
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
+			netdev_dbg(dev->net, "CDC: speed change (len %d)\n",
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
+		netdev_err(dev->net, "CDC: unexpected notification %02x!\n",
+			   event->bNotificationType);
 		break;
 	}
 }
diff --git a/drivers/net/usb/dm9601.c b/drivers/net/usb/dm9601.c
index c820fec..2693397 100644
--- a/drivers/net/usb/dm9601.c
+++ b/drivers/net/usb/dm9601.c
@@ -58,7 +58,7 @@ static int dm_read(struct usbnet *dev, u8 reg, u16 length, void *data)
 	void *buf;
 	int err = -ENOMEM;
 
-	devdbg(dev, "dm_read() reg=0x%02x length=%d", reg, length);
+	netdev_dbg(dev->net, "dm_read() reg=0x%02x length=%d\n", reg, length);
 
 	buf = kmalloc(length, GFP_KERNEL);
 	if (!buf)
@@ -89,7 +89,7 @@ static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 	void *buf = NULL;
 	int err = -ENOMEM;
 
-	devdbg(dev, "dm_write() reg=0x%02x, length=%d", reg, length);
+	netdev_dbg(dev->net, "dm_write() reg=0x%02x, length=%d\n", reg, length);
 
 	if (data) {
 		buf = kmalloc(length, GFP_KERNEL);
@@ -112,7 +112,8 @@ static int dm_write(struct usbnet *dev, u8 reg, u16 length, void *data)
 
 static int dm_write_reg(struct usbnet *dev, u8 reg, u8 value)
 {
-	devdbg(dev, "dm_write_reg() reg=0x%02x, value=0x%02x", reg, value);
+	netdev_dbg(dev->net, "dm_write_reg() reg=0x%02x, value=0x%02x\n",
+		   reg, value);
 	return usb_control_msg(dev->udev,
 			       usb_sndctrlpipe(dev->udev, 0),
 			       DM_WRITE_REG,
@@ -142,13 +143,13 @@ static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		deverr(dev, "Error allocating URB in dm_write_async_helper!");
+		netdev_err(dev->net, "Error allocating URB in dm_write_async_helper!\n");
 		return;
 	}
 
 	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
 	if (!req) {
-		deverr(dev, "Failed to allocate memory for control request");
+		netdev_err(dev->net, "Failed to allocate memory for control request\n");
 		usb_free_urb(urb);
 		return;
 	}
@@ -166,8 +167,8 @@ static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status < 0) {
-		deverr(dev, "Error submitting the control message: status=%d",
-		       status);
+		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
+			   status);
 		kfree(req);
 		usb_free_urb(urb);
 	}
@@ -175,15 +176,15 @@ static void dm_write_async_helper(struct usbnet *dev, u8 reg, u8 value,
 
 static void dm_write_async(struct usbnet *dev, u8 reg, u16 length, void *data)
 {
-	devdbg(dev, "dm_write_async() reg=0x%02x length=%d", reg, length);
+	netdev_dbg(dev->net, "dm_write_async() reg=0x%02x length=%d\n", reg, length);
 
 	dm_write_async_helper(dev, reg, 0, length, data);
 }
 
 static void dm_write_reg_async(struct usbnet *dev, u8 reg, u8 value)
 {
-	devdbg(dev, "dm_write_reg_async() reg=0x%02x value=0x%02x",
-	       reg, value);
+	netdev_dbg(dev->net, "dm_write_reg_async() reg=0x%02x value=0x%02x\n",
+		   reg, value);
 
 	dm_write_async_helper(dev, reg, value, 0, NULL);
 }
@@ -211,7 +212,7 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 	}
 
 	if (i == DM_TIMEOUT) {
-		deverr(dev, "%s read timed out!", phy ? "phy" : "eeprom");
+		netdev_err(dev->net, "%s read timed out!\n", phy ? "phy" : "eeprom");
 		ret = -EIO;
 		goto out;
 	}
@@ -219,8 +220,8 @@ static int dm_read_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 *valu
 	dm_write_reg(dev, DM_SHARED_CTRL, 0x0);
 	ret = dm_read(dev, DM_SHARED_DATA, 2, value);
 
-	devdbg(dev, "read shared %d 0x%02x returned 0x%04x, %d",
-	       phy, reg, *value, ret);
+	netdev_dbg(dev->net, "read shared %d 0x%02x returned 0x%04x, %d\n",
+		   phy, reg, *value, ret);
 
  out:
 	mutex_unlock(&dev->phy_mutex);
@@ -254,7 +255,7 @@ static int dm_write_shared_word(struct usbnet *dev, int phy, u8 reg, __le16 valu
 	}
 
 	if (i == DM_TIMEOUT) {
-		deverr(dev, "%s write timed out!", phy ? "phy" : "eeprom");
+		netdev_err(dev->net, "%s write timed out!\n", phy ? "phy" : "eeprom");
 		ret = -EIO;
 		goto out;
 	}
@@ -304,15 +305,15 @@ static int dm9601_mdio_read(struct net_device *netdev, int phy_id, int loc)
 	__le16 res;
 
 	if (phy_id) {
-		devdbg(dev, "Only internal phy supported");
+		netdev_dbg(dev->net, "Only internal phy supported\n");
 		return 0;
 	}
 
 	dm_read_shared_word(dev, 1, loc, &res);
 
-	devdbg(dev,
-	       "dm9601_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x",
-	       phy_id, loc, le16_to_cpu(res));
+	netdev_dbg(dev->net,
+		   "dm9601_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
+		   phy_id, loc, le16_to_cpu(res));
 
 	return le16_to_cpu(res);
 }
@@ -324,12 +325,12 @@ static void dm9601_mdio_write(struct net_device *netdev, int phy_id, int loc,
 	__le16 res = cpu_to_le16(val);
 
 	if (phy_id) {
-		devdbg(dev, "Only internal phy supported");
+		netdev_dbg(dev->net, "Only internal phy supported\n");
 		return;
 	}
 
-	devdbg(dev,"dm9601_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x",
-	       phy_id, loc, val);
+	netdev_dbg(dev->net, "dm9601_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
+		   phy_id, loc, val);
 
 	dm_write_shared_word(dev, 1, loc, res);
 }
@@ -592,7 +593,7 @@ static void dm9601_status(struct usbnet *dev, struct urb *urb)
 		}
 		else
 			netif_carrier_off(dev->net);
-		devdbg(dev, "Link Status is: %d", link);
+		netdev_dbg(dev->net, "Link Status is: %d\n", link);
 	}
 }
 
@@ -603,8 +604,8 @@ static int dm9601_link_reset(struct usbnet *dev)
 	mii_check_media(&dev->mii, 1, 1);
 	mii_ethtool_gset(&dev->mii, &ecmd);
 
-	devdbg(dev, "link_reset() speed: %d duplex: %d",
-	       ecmd.speed, ecmd.duplex);
+	netdev_dbg(dev->net, "link_reset() speed: %d duplex: %d\n",
+		   ecmd.speed, ecmd.duplex);
 
 	return 0;
 }
diff --git a/drivers/net/usb/int51x1.c b/drivers/net/usb/int51x1.c
index 9ab5c19..3c228df 100644
--- a/drivers/net/usb/int51x1.c
+++ b/drivers/net/usb/int51x1.c
@@ -51,7 +51,7 @@ static int int51x1_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	int len;
 
 	if (!(pskb_may_pull(skb, INT51X1_HEADER_SIZE))) {
-		deverr(dev, "unexpected tiny rx frame");
+		netdev_err(dev->net, "unexpected tiny rx frame\n");
 		return 0;
 	}
 
@@ -138,25 +138,25 @@ static void int51x1_set_multicast(struct net_device *netdev)
 	if (netdev->flags & IFF_PROMISC) {
 		/* do not expect to see traffic of other PLCs */
 		filter |= PACKET_TYPE_PROMISCUOUS;
-		devinfo(dev, "promiscuous mode enabled");
+		netdev_info(dev->net, "promiscuous mode enabled\n");
 	} else if (!netdev_mc_empty(netdev) ||
 		  (netdev->flags & IFF_ALLMULTI)) {
 		filter |= PACKET_TYPE_ALL_MULTICAST;
-		devdbg(dev, "receive all multicast enabled");
+		netdev_dbg(dev->net, "receive all multicast enabled\n");
 	} else {
 		/* ~PROMISCUOUS, ~MULTICAST */
-		devdbg(dev, "receive own packets only");
+		netdev_dbg(dev->net, "receive own packets only\n");
 	}
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		devwarn(dev, "Error allocating URB");
+		netdev_warn(dev->net, "Error allocating URB\n");
 		return;
 	}
 
 	req = kmalloc(sizeof(*req), GFP_ATOMIC);
 	if (!req) {
-		devwarn(dev, "Error allocating control msg");
+		netdev_warn(dev->net, "Error allocating control msg\n");
 		goto out;
 	}
 
@@ -173,7 +173,8 @@ static void int51x1_set_multicast(struct net_device *netdev)
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status < 0) {
-		devwarn(dev, "Error submitting control msg, sts=%d", status);
+		netdev_warn(dev->net, "Error submitting control msg, sts=%d\n",
+			    status);
 		goto out1;
 	}
 	return;
diff --git a/drivers/net/usb/net1080.c b/drivers/net/usb/net1080.c
index aeb1ab0..f699405 100644
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
+	netdev_dbg(dev->net, "net1080 %s-%s usbctl 0x%x:%s%s%s%s%s;"
+		   " this%s%s;"
+		   " other%s%s; r/o 0x%x\n",
+		   dev->udev->bus->bus_name, dev->udev->devpath,
+		   usbctl,
+		   (usbctl & USBCTL_ENABLE_LANG) ? " lang" : "",
+		   (usbctl & USBCTL_ENABLE_MFGR) ? " mfgr" : "",
+		   (usbctl & USBCTL_ENABLE_PROD) ? " prod" : "",
+		   (usbctl & USBCTL_ENABLE_SERIAL) ? " serial" : "",
+		   (usbctl & USBCTL_ENABLE_DEFAULTS) ? " defaults" : "",
+
+		   (usbctl & USBCTL_FLUSH_THIS) ? " FLUSH" : "",
+		   (usbctl & USBCTL_DISCONN_THIS) ? " DIS" : "",
+
+		   (usbctl & USBCTL_FLUSH_OTHER) ? " FLUSH" : "",
+		   (usbctl & USBCTL_DISCONN_OTHER) ? " DIS" : "",
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
+	netdev_dbg(dev->net, "net1080 %s-%s status 0x%x: this (%c) PKT=%d%s%s%s; other PKT=%d%s%s%s; unspec 0x%x\n",
+		   dev->udev->bus->bus_name, dev->udev->devpath,
+		   status,
+
+		   // XXX the packet counts don't seem right
+		   // (1 at reset, not 0); maybe UNSPEC too
+
+		   (status & STATUS_PORT_A) ? 'A' : 'B',
+		   STATUS_PACKETS_THIS(status),
+		   (status & STATUS_CONN_THIS) ? " CON" : "",
+		   (status & STATUS_SUSPEND_THIS) ? " SUS" : "",
+		   (status & STATUS_MAILBOX_THIS) ? " MBOX" : "",
+
+		   STATUS_PACKETS_OTHER(status),
+		   (status & STATUS_CONN_OTHER) ? " CON" : "",
+		   (status & STATUS_SUSPEND_OTHER) ? " SUS" : "",
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
+		netdev_dbg(dev->net, "net1080 %s-%s ttl 0x%x this = %d, other = %d\n",
+			   dev->udev->bus->bus_name, dev->udev->devpath,
+			   ttl, TTL_THIS(ttl), TTL_OTHER(ttl));
 }
 
 /*-------------------------------------------------------------------------*/
@@ -335,10 +333,9 @@ static int net1080_reset(struct usbnet *dev)
 	dbg("%s: assigned TTL, %d ms", dev->net->name, NC_READ_TTL_MS);
 
 	if (netif_msg_link(dev))
-		devinfo(dev, "port %c, peer %sconnected",
-			(status & STATUS_PORT_A) ? 'A' : 'B',
-			(status & STATUS_CONN_OTHER) ? "" : "dis"
-			);
+		netdev_info(dev->net, "port %c, peer %sconnected\n",
+			    (status & STATUS_PORT_A) ? 'A' : 'B',
+			    (status & STATUS_CONN_OTHER) ? "" : "dis");
 	retval = 0;
 
 done:
@@ -416,7 +413,7 @@ static void nc_ensure_sync(struct usbnet *dev)
 		}
 
 		if (netif_msg_rx_err(dev))
-			devdbg(dev, "flush net1080; too many framing errors");
+			netdev_dbg(dev->net, "flush net1080; too many framing errors\n");
 		dev->frame_errors = 0;
 	}
 }
@@ -486,8 +483,8 @@ static int net1080_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 		return 0;
 	}
 #if 0
-	devdbg(dev, "frame <rx h %d p %d id %d", header->hdr_len,
-		header->packet_len, header->packet_id);
+	netdev_dbg(dev->net, "frame <rx h %d p %d id %d\n", header->hdr_len,
+		   header->packet_len, header->packet_id);
 #endif
 	dev->frame_errors = 0;
 	return 1;
@@ -547,9 +544,9 @@ encapsulate:
 	trailer = (struct nc_trailer *) skb_put(skb, sizeof *trailer);
 	put_unaligned(header->packet_id, &trailer->packet_id);
 #if 0
-	devdbg(dev, "frame >tx h %d p %d id %d",
-		header->hdr_len, header->packet_len,
-		header->packet_id);
+	netdev_dbg(dev->net, "frame >tx h %d p %d id %d\n",
+		   header->hdr_len, header->packet_len,
+		   header->packet_id);
 #endif
 	return skb;
 }
diff --git a/drivers/net/usb/rndis_host.c b/drivers/net/usb/rndis_host.c
index 490fa8f..f01f024 100644
--- a/drivers/net/usb/rndis_host.c
+++ b/drivers/net/usb/rndis_host.c
@@ -57,8 +57,8 @@
  */
 void rndis_status(struct usbnet *dev, struct urb *urb)
 {
-	devdbg(dev, "rndis status urb, len %d stat %d",
-		urb->actual_length, urb->status);
+	netdev_dbg(dev->net, "rndis status urb, len %d stat %d\n",
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
+			netdev_dbg(dev->net, "bad rndis message %d/%d/%d/%d, len %d\n",
+				   le32_to_cpu(hdr->msg_type),
+				   msg_len, data_offset, data_len, skb->len);
 			return 0;
 		}
 		skb_pull(skb, 8 + data_offset);
diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index 48555d0..d4cbcef 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -78,7 +78,7 @@ static int smsc95xx_read_reg(struct usbnet *dev, u32 index, u32 *data)
 		00, index, buf, 4, USB_CTRL_GET_TIMEOUT);
 
 	if (unlikely(ret < 0))
-		devwarn(dev, "Failed to read register index 0x%08x", index);
+		netdev_warn(dev->net, "Failed to read register index 0x%08x\n", index);
 
 	le32_to_cpus(buf);
 	*data = *buf;
@@ -106,7 +106,7 @@ static int smsc95xx_write_reg(struct usbnet *dev, u32 index, u32 data)
 		00, index, buf, 4, USB_CTRL_SET_TIMEOUT);
 
 	if (unlikely(ret < 0))
-		devwarn(dev, "Failed to write register index 0x%08x", index);
+		netdev_warn(dev->net, "Failed to write register index 0x%08x\n", index);
 
 	kfree(buf);
 
@@ -138,7 +138,7 @@ static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 
 	/* confirm MII not busy */
 	if (smsc95xx_phy_wait_not_busy(dev)) {
-		devwarn(dev, "MII is busy in smsc95xx_mdio_read");
+		netdev_warn(dev->net, "MII is busy in smsc95xx_mdio_read\n");
 		mutex_unlock(&dev->phy_mutex);
 		return -EIO;
 	}
@@ -150,7 +150,7 @@ static int smsc95xx_mdio_read(struct net_device *netdev, int phy_id, int idx)
 	smsc95xx_write_reg(dev, MII_ADDR, addr);
 
 	if (smsc95xx_phy_wait_not_busy(dev)) {
-		devwarn(dev, "Timed out reading MII reg %02X", idx);
+		netdev_warn(dev->net, "Timed out reading MII reg %02X\n", idx);
 		mutex_unlock(&dev->phy_mutex);
 		return -EIO;
 	}
@@ -172,7 +172,7 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 
 	/* confirm MII not busy */
 	if (smsc95xx_phy_wait_not_busy(dev)) {
-		devwarn(dev, "MII is busy in smsc95xx_mdio_write");
+		netdev_warn(dev->net, "MII is busy in smsc95xx_mdio_write\n");
 		mutex_unlock(&dev->phy_mutex);
 		return;
 	}
@@ -187,7 +187,7 @@ static void smsc95xx_mdio_write(struct net_device *netdev, int phy_id, int idx,
 	smsc95xx_write_reg(dev, MII_ADDR, addr);
 
 	if (smsc95xx_phy_wait_not_busy(dev))
-		devwarn(dev, "Timed out writing MII reg %02X", idx);
+		netdev_warn(dev->net, "Timed out writing MII reg %02X\n", idx);
 
 	mutex_unlock(&dev->phy_mutex);
 }
@@ -205,7 +205,7 @@ static int smsc95xx_wait_eeprom(struct usbnet *dev)
 	} while (!time_after(jiffies, start_time + HZ));
 
 	if (val & (E2P_CMD_TIMEOUT_ | E2P_CMD_BUSY_)) {
-		devwarn(dev, "EEPROM read operation timeout");
+		netdev_warn(dev->net, "EEPROM read operation timeout\n");
 		return -EIO;
 	}
 
@@ -226,7 +226,7 @@ static int smsc95xx_eeprom_confirm_not_busy(struct usbnet *dev)
 		udelay(40);
 	} while (!time_after(jiffies, start_time + HZ));
 
-	devwarn(dev, "EEPROM is busy");
+	netdev_warn(dev->net, "EEPROM is busy\n");
 	return -EIO;
 }
 
@@ -308,7 +308,7 @@ static void smsc95xx_async_cmd_callback(struct urb *urb)
 	int status = urb->status;
 
 	if (status < 0)
-		devwarn(dev, "async callback failed with %d", status);
+		netdev_warn(dev->net, "async callback failed with %d\n", status);
 
 	kfree(usb_context);
 	usb_free_urb(urb);
@@ -323,13 +323,13 @@ static int smsc95xx_write_reg_async(struct usbnet *dev, u16 index, u32 *data)
 
 	urb = usb_alloc_urb(0, GFP_ATOMIC);
 	if (!urb) {
-		devwarn(dev, "Error allocating URB");
+		netdev_warn(dev->net, "Error allocating URB\n");
 		return -ENOMEM;
 	}
 
 	usb_context = kmalloc(sizeof(struct usb_context), GFP_ATOMIC);
 	if (usb_context == NULL) {
-		devwarn(dev, "Error allocating control msg");
+		netdev_warn(dev->net, "Error allocating control msg\n");
 		usb_free_urb(urb);
 		return -ENOMEM;
 	}
@@ -348,7 +348,8 @@ static int smsc95xx_write_reg_async(struct usbnet *dev, u16 index, u32 *data)
 
 	status = usb_submit_urb(urb, GFP_ATOMIC);
 	if (status < 0) {
-		devwarn(dev, "Error submitting control msg, sts=%d", status);
+		netdev_warn(dev->net, "Error submitting control msg, sts=%d\n",
+			    status);
 		kfree(usb_context);
 		usb_free_urb(urb);
 	}
@@ -376,12 +377,12 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 
 	if (dev->net->flags & IFF_PROMISC) {
 		if (netif_msg_drv(dev))
-			devdbg(dev, "promiscuous mode enabled");
+			netdev_dbg(dev->net, "promiscuous mode enabled\n");
 		pdata->mac_cr |= MAC_CR_PRMS_;
 		pdata->mac_cr &= ~(MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
 	} else if (dev->net->flags & IFF_ALLMULTI) {
 		if (netif_msg_drv(dev))
-			devdbg(dev, "receive all multicast enabled");
+			netdev_dbg(dev->net, "receive all multicast enabled\n");
 		pdata->mac_cr |= MAC_CR_MCPAS_;
 		pdata->mac_cr &= ~(MAC_CR_PRMS_ | MAC_CR_HPFILT_);
 	} else if (!netdev_mc_empty(dev->net)) {
@@ -401,20 +402,20 @@ static void smsc95xx_set_multicast(struct net_device *netdev)
 				else
 					hash_lo |= mask;
 			} else {
-				devwarn(dev, "dmi_addrlen != 6");
+				netdev_warn(dev->net, "dmi_addrlen != 6\n");
 			}
 			mc_list = mc_list->next;
 		}
 
 		if (count != ((u32) netdev_mc_count(dev->net)))
-			devwarn(dev, "mc_count != dev->mc_count");
+			netdev_warn(dev->net, "mc_count != dev->mc_count\n");
 
 		if (netif_msg_drv(dev))
-			devdbg(dev, "HASHH=0x%08X, HASHL=0x%08X", hash_hi,
-				hash_lo);
+			netdev_dbg(dev->net, "HASHH=0x%08X, HASHL=0x%08X\n",
+				   hash_hi, hash_lo);
 	} else {
 		if (netif_msg_drv(dev))
-			devdbg(dev, "receive own packets only");
+			netdev_dbg(dev->net, "receive own packets only\n");
 		pdata->mac_cr &=
 			~(MAC_CR_PRMS_ | MAC_CR_MCPAS_ | MAC_CR_HPFILT_);
 	}
@@ -434,7 +435,7 @@ static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 
 	int ret = smsc95xx_read_reg(dev, AFC_CFG, &afc_cfg);
 	if (ret < 0) {
-		devwarn(dev, "error reading AFC_CFG");
+		netdev_warn(dev->net, "error reading AFC_CFG\n");
 		return;
 	}
 
@@ -452,12 +453,12 @@ static void smsc95xx_phy_update_flowcontrol(struct usbnet *dev, u8 duplex,
 			afc_cfg &= ~0xF;
 
 		if (netif_msg_link(dev))
-			devdbg(dev, "rx pause %s, tx pause %s",
-				(cap & FLOW_CTRL_RX ? "enabled" : "disabled"),
-				(cap & FLOW_CTRL_TX ? "enabled" : "disabled"));
+			netdev_dbg(dev->net, "rx pause %s, tx pause %s\n",
+				   cap & FLOW_CTRL_RX ? "enabled" : "disabled",
+				   cap & FLOW_CTRL_TX ? "enabled" : "disabled");
 	} else {
 		if (netif_msg_link(dev))
-			devdbg(dev, "half duplex");
+			netdev_dbg(dev->net, "half duplex\n");
 		flow = 0;
 		afc_cfg |= 0xF;
 	}
@@ -486,8 +487,8 @@ static int smsc95xx_link_reset(struct usbnet *dev)
 	rmtadv = smsc95xx_mdio_read(dev->net, mii->phy_id, MII_LPA);
 
 	if (netif_msg_link(dev))
-		devdbg(dev, "speed: %d duplex: %d lcladv: %04x rmtadv: %04x",
-			ecmd.speed, ecmd.duplex, lcladv, rmtadv);
+		netdev_dbg(dev->net, "speed: %d duplex: %d lcladv: %04x rmtadv: %04x\n",
+			   ecmd.speed, ecmd.duplex, lcladv, rmtadv);
 
 	spin_lock_irqsave(&pdata->mac_cr_lock, flags);
 	if (ecmd.duplex != DUPLEX_FULL) {
@@ -511,7 +512,8 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 	u32 intdata;
 
 	if (urb->actual_length != 4) {
-		devwarn(dev, "unexpected urb length %d", urb->actual_length);
+		netdev_warn(dev->net, "unexpected urb length %d\n",
+			    urb->actual_length);
 		return;
 	}
 
@@ -519,12 +521,13 @@ static void smsc95xx_status(struct usbnet *dev, struct urb *urb)
 	le32_to_cpus(&intdata);
 
 	if (netif_msg_link(dev))
-		devdbg(dev, "intdata: 0x%08X", intdata);
+		netdev_dbg(dev->net, "intdata: 0x%08X\n", intdata);
 
 	if (intdata & INT_ENP_PHY_INT_)
 		usbnet_defer_kevent(dev, EVENT_LINK_RESET);
 	else
-		devwarn(dev, "unexpected interrupt, intdata=0x%08X", intdata);
+		netdev_warn(dev->net, "unexpected interrupt, intdata=0x%08X\n",
+			    intdata);
 }
 
 /* Enable or disable Tx & Rx checksum offload engines */
@@ -534,7 +537,7 @@ static int smsc95xx_set_csums(struct usbnet *dev)
 	u32 read_buf;
 	int ret = smsc95xx_read_reg(dev, COE_CR, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read COE_CR: %d", ret);
+		netdev_warn(dev->net, "Failed to read COE_CR: %d\n", ret);
 		return ret;
 	}
 
@@ -550,12 +553,12 @@ static int smsc95xx_set_csums(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, COE_CR, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write COE_CR: %d", ret);
+		netdev_warn(dev->net, "Failed to write COE_CR: %d\n", ret);
 		return ret;
 	}
 
 	if (netif_msg_hw(dev))
-		devdbg(dev, "COE_CR = 0x%08x", read_buf);
+		netdev_dbg(dev->net, "COE_CR = 0x%08x\n", read_buf);
 	return 0;
 }
 
@@ -580,8 +583,8 @@ static int smsc95xx_ethtool_set_eeprom(struct net_device *netdev,
 	struct usbnet *dev = netdev_priv(netdev);
 
 	if (ee->magic != LAN95XX_EEPROM_MAGIC) {
-		devwarn(dev, "EEPROM: magic value mismatch, magic = 0x%x",
-			ee->magic);
+		netdev_warn(dev->net, "EEPROM: magic value mismatch, magic = 0x%x\n",
+			    ee->magic);
 		return -EINVAL;
 	}
 
@@ -660,7 +663,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 		if (is_valid_ether_addr(dev->net->dev_addr)) {
 			/* eeprom values are valid so use them */
 			if (netif_msg_ifup(dev))
-				devdbg(dev, "MAC address read from EEPROM");
+				netdev_dbg(dev->net, "MAC address read from EEPROM\n");
 			return;
 		}
 	}
@@ -668,7 +671,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
 	/* no eeprom, or eeprom values are invalid. generate random MAC */
 	random_ether_addr(dev->net->dev_addr);
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "MAC address set to random_ether_addr");
+		netdev_dbg(dev->net, "MAC address set to random_ether_addr\n");
 }
 
 static int smsc95xx_set_mac_address(struct usbnet *dev)
@@ -680,13 +683,13 @@ static int smsc95xx_set_mac_address(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, ADDRL, addr_lo);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write ADDRL: %d", ret);
+		netdev_warn(dev->net, "Failed to write ADDRL: %d\n", ret);
 		return ret;
 	}
 
 	ret = smsc95xx_write_reg(dev, ADDRH, addr_hi);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write ADDRH: %d", ret);
+		netdev_warn(dev->net, "Failed to write ADDRH: %d\n", ret);
 		return ret;
 	}
 
@@ -748,7 +751,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
 	mii_nway_restart(&dev->mii);
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "phy initialised successfully");
+		netdev_dbg(dev->net, "phy initialised successfully\n");
 	return 0;
 }
 
@@ -760,13 +763,13 @@ static int smsc95xx_reset(struct usbnet *dev)
 	int ret = 0, timeout;
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "entering smsc95xx_reset");
+		netdev_dbg(dev->net, "entering smsc95xx_reset\n");
 
 	write_buf = HW_CFG_LRST_;
 	ret = smsc95xx_write_reg(dev, HW_CFG, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write HW_CFG_LRST_ bit in HW_CFG "
-			"register, ret = %d", ret);
+		netdev_warn(dev->net, "Failed to write HW_CFG_LRST_ bit in HW_CFG register, ret = %d\n",
+			    ret);
 		return ret;
 	}
 
@@ -774,7 +777,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	do {
 		ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 		if (ret < 0) {
-			devwarn(dev, "Failed to read HW_CFG: %d", ret);
+			netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 			return ret;
 		}
 		msleep(10);
@@ -782,14 +785,14 @@ static int smsc95xx_reset(struct usbnet *dev)
 	} while ((read_buf & HW_CFG_LRST_) && (timeout < 100));
 
 	if (timeout >= 100) {
-		devwarn(dev, "timeout waiting for completion of Lite Reset");
+		netdev_warn(dev->net, "timeout waiting for completion of Lite Reset\n");
 		return ret;
 	}
 
 	write_buf = PM_CTL_PHY_RST_;
 	ret = smsc95xx_write_reg(dev, PM_CTRL, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write PM_CTRL: %d", ret);
+		netdev_warn(dev->net, "Failed to write PM_CTRL: %d\n", ret);
 		return ret;
 	}
 
@@ -797,7 +800,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	do {
 		ret = smsc95xx_read_reg(dev, PM_CTRL, &read_buf);
 		if (ret < 0) {
-			devwarn(dev, "Failed to read PM_CTRL: %d", ret);
+			netdev_warn(dev->net, "Failed to read PM_CTRL: %d\n", ret);
 			return ret;
 		}
 		msleep(10);
@@ -805,7 +808,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	} while ((read_buf & PM_CTL_PHY_RST_) && (timeout < 100));
 
 	if (timeout >= 100) {
-		devwarn(dev, "timeout waiting for PHY Reset");
+		netdev_warn(dev->net, "timeout waiting for PHY Reset\n");
 		return ret;
 	}
 
@@ -816,34 +819,34 @@ static int smsc95xx_reset(struct usbnet *dev)
 		return ret;
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "MAC Address: %pM", dev->net->dev_addr);
+		netdev_dbg(dev->net, "MAC Address: %pM\n", dev->net->dev_addr);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG : 0x%08x", read_buf);
+		netdev_dbg(dev->net, "Read Value from HW_CFG : 0x%08x\n", read_buf);
 
 	read_buf |= HW_CFG_BIR_;
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write HW_CFG_BIR_ bit in HW_CFG "
-			"register, ret = %d", ret);
+		netdev_warn(dev->net, "Failed to write HW_CFG_BIR_ bit in HW_CFG register, ret = %d\n",
+			    ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG after writing "
-			"HW_CFG_BIR_: 0x%08x", read_buf);
+		netdev_dbg(dev->net, "Read Value from HW_CFG after writing HW_CFG_BIR_: 0x%08x\n",
+			   read_buf);
 
 	if (!turbo_mode) {
 		burst_cap = 0;
@@ -857,46 +860,46 @@ static int smsc95xx_reset(struct usbnet *dev)
 	}
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "rx_urb_size=%ld", (ulong)dev->rx_urb_size);
+		netdev_dbg(dev->net, "rx_urb_size=%ld\n", (ulong)dev->rx_urb_size);
 
 	ret = smsc95xx_write_reg(dev, BURST_CAP, burst_cap);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write BURST_CAP: %d", ret);
+		netdev_warn(dev->net, "Failed to write BURST_CAP: %d\n", ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, BURST_CAP, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read BURST_CAP: %d", ret);
+		netdev_warn(dev->net, "Failed to read BURST_CAP: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from BURST_CAP after writing: 0x%08x",
-			read_buf);
+		netdev_dbg(dev->net, "Read Value from BURST_CAP after writing: 0x%08x\n",
+			   read_buf);
 
 	read_buf = DEFAULT_BULK_IN_DELAY;
 	ret = smsc95xx_write_reg(dev, BULK_IN_DLY, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "ret = %d", ret);
+		netdev_warn(dev->net, "ret = %d\n", ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, BULK_IN_DLY, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read BULK_IN_DLY: %d", ret);
+		netdev_warn(dev->net, "Failed to read BULK_IN_DLY: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from BULK_IN_DLY after writing: "
-			"0x%08x", read_buf);
+		netdev_dbg(dev->net, "Read Value from BULK_IN_DLY after writing: 0x%08x\n",
+			   read_buf);
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG: 0x%08x", read_buf);
+		netdev_dbg(dev->net, "Read Value from HW_CFG: 0x%08x\n", read_buf);
 
 	if (turbo_mode)
 		read_buf |= (HW_CFG_MEF_ | HW_CFG_BCE_);
@@ -908,41 +911,43 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, HW_CFG, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write HW_CFG register, ret=%d", ret);
+		netdev_warn(dev->net, "Failed to write HW_CFG register, ret=%d\n",
+			    ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, HW_CFG, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read HW_CFG: %d", ret);
+		netdev_warn(dev->net, "Failed to read HW_CFG: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "Read Value from HW_CFG after writing: 0x%08x",
-			read_buf);
+		netdev_dbg(dev->net, "Read Value from HW_CFG after writing: 0x%08x\n",
+			   read_buf);
 
 	write_buf = 0xFFFFFFFF;
 	ret = smsc95xx_write_reg(dev, INT_STS, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write INT_STS register, ret=%d", ret);
+		netdev_warn(dev->net, "Failed to write INT_STS register, ret=%d\n",
+			    ret);
 		return ret;
 	}
 
 	ret = smsc95xx_read_reg(dev, ID_REV, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read ID_REV: %d", ret);
+		netdev_warn(dev->net, "Failed to read ID_REV: %d\n", ret);
 		return ret;
 	}
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "ID_REV = 0x%08x", read_buf);
+		netdev_dbg(dev->net, "ID_REV = 0x%08x\n", read_buf);
 
 	/* Configure GPIO pins as LED outputs */
 	write_buf = LED_GPIO_CFG_SPD_LED | LED_GPIO_CFG_LNK_LED |
 		LED_GPIO_CFG_FDX_LED;
 	ret = smsc95xx_write_reg(dev, LED_GPIO_CFG, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write LED_GPIO_CFG register, ret=%d",
-			ret);
+		netdev_warn(dev->net, "Failed to write LED_GPIO_CFG register, ret=%d\n",
+			    ret);
 		return ret;
 	}
 
@@ -950,21 +955,21 @@ static int smsc95xx_reset(struct usbnet *dev)
 	write_buf = 0;
 	ret = smsc95xx_write_reg(dev, FLOW, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write FLOW: %d", ret);
+		netdev_warn(dev->net, "Failed to write FLOW: %d\n", ret);
 		return ret;
 	}
 
 	read_buf = AFC_CFG_DEFAULT;
 	ret = smsc95xx_write_reg(dev, AFC_CFG, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write AFC_CFG: %d", ret);
+		netdev_warn(dev->net, "Failed to write AFC_CFG: %d\n", ret);
 		return ret;
 	}
 
 	/* Don't need mac_cr_lock during initialisation */
 	ret = smsc95xx_read_reg(dev, MAC_CR, &pdata->mac_cr);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read MAC_CR: %d", ret);
+		netdev_warn(dev->net, "Failed to read MAC_CR: %d\n", ret);
 		return ret;
 	}
 
@@ -973,7 +978,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	write_buf = (u32)ETH_P_8021Q;
 	ret = smsc95xx_write_reg(dev, VLAN1, write_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write VAN1: %d", ret);
+		netdev_warn(dev->net, "Failed to write VAN1: %d\n", ret);
 		return ret;
 	}
 
@@ -981,7 +986,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	ethtool_op_set_tx_hw_csum(netdev, pdata->use_tx_csum);
 	ret = smsc95xx_set_csums(dev);
 	if (ret < 0) {
-		devwarn(dev, "Failed to set csum offload: %d", ret);
+		netdev_warn(dev->net, "Failed to set csum offload: %d\n", ret);
 		return ret;
 	}
 
@@ -992,7 +997,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	ret = smsc95xx_read_reg(dev, INT_EP_CTL, &read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to read INT_EP_CTL: %d", ret);
+		netdev_warn(dev->net, "Failed to read INT_EP_CTL: %d\n", ret);
 		return ret;
 	}
 
@@ -1001,7 +1006,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 
 	ret = smsc95xx_write_reg(dev, INT_EP_CTL, read_buf);
 	if (ret < 0) {
-		devwarn(dev, "Failed to write INT_EP_CTL: %d", ret);
+		netdev_warn(dev->net, "Failed to write INT_EP_CTL: %d\n", ret);
 		return ret;
 	}
 
@@ -1009,7 +1014,7 @@ static int smsc95xx_reset(struct usbnet *dev)
 	smsc95xx_start_rx_path(dev);
 
 	if (netif_msg_ifup(dev))
-		devdbg(dev, "smsc95xx_reset, return 0");
+		netdev_dbg(dev->net, "smsc95xx_reset, return 0\n");
 	return 0;
 }
 
@@ -1034,7 +1039,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	ret = usbnet_get_endpoints(dev, intf);
 	if (ret < 0) {
-		devwarn(dev, "usbnet_get_endpoints failed: %d", ret);
+		netdev_warn(dev->net, "usbnet_get_endpoints failed: %d\n", ret);
 		return ret;
 	}
 
@@ -1043,7 +1048,7 @@ static int smsc95xx_bind(struct usbnet *dev, struct usb_interface *intf)
 
 	pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	if (!pdata) {
-		devwarn(dev, "Unable to allocate struct smsc95xx_priv");
+		netdev_warn(dev->net, "Unable to allocate struct smsc95xx_priv\n");
 		return -ENOMEM;
 	}
 
@@ -1067,7 +1072,7 @@ static void smsc95xx_unbind(struct usbnet *dev, struct usb_interface *intf)
 	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
 	if (pdata) {
 		if (netif_msg_ifdown(dev))
-			devdbg(dev, "free pdata");
+			netdev_dbg(dev->net, "free pdata\n");
 		kfree(pdata);
 		pdata = NULL;
 		dev->data[0] = 0;
@@ -1102,7 +1107,8 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 		if (unlikely(header & RX_STS_ES_)) {
 			if (netif_msg_rx_err(dev))
-				devdbg(dev, "Error header=0x%08x", header);
+				netdev_dbg(dev->net, "Error header=0x%08x\n",
+					   header);
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_dropped++;
 
@@ -1120,8 +1126,8 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 			/* ETH_FRAME_LEN + 4(CRC) + 2(COE) + 4(Vlan) */
 			if (unlikely(size > (ETH_FRAME_LEN + 12))) {
 				if (netif_msg_rx_err(dev))
-					devdbg(dev, "size err header=0x%08x",
-						header);
+					netdev_dbg(dev->net, "size err header=0x%08x\n",
+						   header);
 				return 0;
 			}
 
@@ -1137,7 +1143,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 
 			ax_skb = skb_clone(skb, GFP_ATOMIC);
 			if (unlikely(!ax_skb)) {
-				devwarn(dev, "Error allocating skb");
+				netdev_warn(dev->net, "Error allocating skb\n");
 				return 0;
 			}
 
@@ -1161,7 +1167,7 @@ static int smsc95xx_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	}
 
 	if (unlikely(skb->len < 0)) {
-		devwarn(dev, "invalid rx length<0 %d", skb->len);
+		netdev_warn(dev->net, "invalid rx length<0 %d\n", skb->len);
 		return 0;
 	}
 
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index 035fab0..8e73293 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -243,12 +243,12 @@ void usbnet_skb_return (struct usbnet *dev, struct sk_buff *skb)
 	dev->net->stats.rx_bytes += skb->len;
 
 	if (netif_msg_rx_status (dev))
-		devdbg (dev, "< rx, len %zu, type 0x%x",
-			skb->len + sizeof (struct ethhdr), skb->protocol);
+		netdev_dbg(dev->net, "< rx, len %zu, type 0x%x\n",
+			   skb->len + sizeof (struct ethhdr), skb->protocol);
 	memset (skb->cb, 0, sizeof (struct skb_data));
 	status = netif_rx (skb);
 	if (status != NET_RX_SUCCESS && netif_msg_rx_err (dev))
-		devdbg (dev, "netif_rx status %d", status);
+		netdev_dbg(dev->net, "netif_rx status %d\n", status);
 }
 EXPORT_SYMBOL_GPL(usbnet_skb_return);
 
@@ -313,9 +313,9 @@ void usbnet_defer_kevent (struct usbnet *dev, int work)
 {
 	set_bit (work, &dev->flags);
 	if (!schedule_work (&dev->kevent))
-		deverr (dev, "kevent %d may have been dropped", work);
+		netdev_err(dev->net, "kevent %d may have been dropped\n", work);
 	else
-		devdbg (dev, "kevent %d scheduled", work);
+		netdev_dbg(dev->net, "kevent %d scheduled\n", work);
 }
 EXPORT_SYMBOL_GPL(usbnet_defer_kevent);
 
@@ -333,7 +333,7 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 
 	if ((skb = alloc_skb (size + NET_IP_ALIGN, flags)) == NULL) {
 		if (netif_msg_rx_err (dev))
-			devdbg (dev, "no rx skb");
+			netdev_dbg(dev->net, "no rx skb\n");
 		usbnet_defer_kevent (dev, EVENT_RX_MEMORY);
 		usb_free_urb (urb);
 		return;
@@ -364,12 +364,12 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 			break;
 		case -ENODEV:
 			if (netif_msg_ifdown (dev))
-				devdbg (dev, "device gone");
+				netdev_dbg(dev->net, "device gone\n");
 			netif_device_detach (dev->net);
 			break;
 		default:
 			if (netif_msg_rx_err (dev))
-				devdbg (dev, "rx submit, %d", retval);
+				netdev_dbg(dev->net, "rx submit, %d\n", retval);
 			tasklet_schedule (&dev->bh);
 			break;
 		case 0:
@@ -377,7 +377,7 @@ static void rx_submit (struct usbnet *dev, struct urb *urb, gfp_t flags)
 		}
 	} else {
 		if (netif_msg_ifdown (dev))
-			devdbg (dev, "rx: stopped");
+			netdev_dbg(dev->net, "rx: stopped\n");
 		retval = -ENOLINK;
 	}
 	spin_unlock_irqrestore (&dev->rxq.lock, lockflags);
@@ -401,7 +401,7 @@ static inline void rx_process (struct usbnet *dev, struct sk_buff *skb)
 		usbnet_skb_return (dev, skb);
 	else {
 		if (netif_msg_rx_err (dev))
-			devdbg (dev, "drop");
+			netdev_dbg(dev->net, "drop\n");
 error:
 		dev->net->stats.rx_errors++;
 		skb_queue_tail (&dev->done, skb);
@@ -429,7 +429,7 @@ static void rx_complete (struct urb *urb)
 			dev->net->stats.rx_errors++;
 			dev->net->stats.rx_length_errors++;
 			if (netif_msg_rx_err (dev))
-				devdbg (dev, "rx length %d", skb->len);
+				netdev_dbg(dev->net, "rx length %d\n", skb->len);
 		}
 		break;
 
@@ -447,7 +447,7 @@ static void rx_complete (struct urb *urb)
 	case -ECONNRESET:		/* async unlink */
 	case -ESHUTDOWN:		/* hardware gone */
 		if (netif_msg_ifdown (dev))
-			devdbg (dev, "rx shutdown, code %d", urb_status);
+			netdev_dbg(dev->net, "rx shutdown, code %d\n", urb_status);
 		goto block;
 
 	/* we get controller i/o faults during khubd disconnect() delays.
@@ -461,7 +461,7 @@ static void rx_complete (struct urb *urb)
 		if (!timer_pending (&dev->delay)) {
 			mod_timer (&dev->delay, jiffies + THROTTLE_JIFFIES);
 			if (netif_msg_link (dev))
-				devdbg (dev, "rx throttle %d", urb_status);
+				netdev_dbg(dev->net, "rx throttle %d\n", urb_status);
 		}
 block:
 		entry->state = rx_cleanup;
@@ -478,7 +478,7 @@ block:
 		entry->state = rx_cleanup;
 		dev->net->stats.rx_errors++;
 		if (netif_msg_rx_err (dev))
-			devdbg (dev, "rx status %d", urb_status);
+			netdev_dbg(dev->net, "rx status %d\n", urb_status);
 		break;
 	}
 
@@ -493,7 +493,7 @@ block:
 		usb_free_urb (urb);
 	}
 	if (netif_msg_rx_err (dev))
-		devdbg (dev, "no read resubmitted");
+		netdev_dbg(dev->net, "no read resubmitted\n");
 }
 
 static void intr_complete (struct urb *urb)
@@ -511,14 +511,14 @@ static void intr_complete (struct urb *urb)
 	case -ENOENT:		/* urb killed */
 	case -ESHUTDOWN:	/* hardware gone */
 		if (netif_msg_ifdown (dev))
-			devdbg (dev, "intr shutdown, code %d", status);
+			netdev_dbg(dev->net, "intr shutdown, code %d\n", status);
 		return;
 
 	/* NOTE:  not throttling like RX/TX, since this endpoint
 	 * already polls infrequently
 	 */
 	default:
-		devdbg (dev, "intr status %d", status);
+		netdev_dbg(dev->net, "intr status %d\n", status);
 		break;
 	}
 
@@ -528,7 +528,7 @@ static void intr_complete (struct urb *urb)
 	memset(urb->transfer_buffer, 0, urb->transfer_buffer_length);
 	status = usb_submit_urb (urb, GFP_ATOMIC);
 	if (status != 0 && netif_msg_timer (dev))
-		deverr(dev, "intr resubmit --> %d", status);
+		netdev_err(dev->net, "intr resubmit --> %d\n", status);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -537,7 +537,7 @@ void usbnet_pause_rx(struct usbnet *dev)
 	set_bit(EVENT_RX_PAUSED, &dev->flags);
 
 	if (netif_msg_rx_status(dev))
-		devdbg(dev, "paused rx queue enabled");
+		netdev_dbg(dev->net, "paused rx queue enabled\n");
 }
 EXPORT_SYMBOL_GPL(usbnet_pause_rx);
 
@@ -556,7 +556,8 @@ void usbnet_resume_rx(struct usbnet *dev)
 	tasklet_schedule(&dev->bh);
 
 	if (netif_msg_rx_status(dev))
-		devdbg(dev, "paused rx queue disabled, %d skbs requeued", num);
+		netdev_dbg(dev->net, "paused rx queue disabled, %d skbs requeued\n",
+			   num);
 }
 EXPORT_SYMBOL_GPL(usbnet_resume_rx);
 
@@ -589,7 +590,7 @@ static int unlink_urbs (struct usbnet *dev, struct sk_buff_head *q)
 		// these (async) unlinks complete immediately
 		retval = usb_unlink_urb (urb);
 		if (retval != -EINPROGRESS && retval != 0)
-			devdbg (dev, "unlink urb err, %d", retval);
+			netdev_dbg(dev->net, "unlink urb err, %d\n", retval);
 		else
 			count++;
 	}
@@ -632,8 +633,8 @@ static void usbnet_terminate_urbs(struct usbnet *dev)
 			schedule_timeout(UNLINK_TIMEOUT_MS);
 			set_current_state(TASK_UNINTERRUPTIBLE);
 			if (netif_msg_ifdown(dev))
-				devdbg(dev, "waited for %d urb completions",
-					temp);
+				netdev_dbg(dev->net, "waited for %d urb completions\n",
+					   temp);
 	}
 	set_current_state(TASK_RUNNING);
 	dev->wait = NULL;
@@ -649,21 +650,20 @@ int usbnet_stop (struct net_device *net)
 	netif_stop_queue (net);
 
 	if (netif_msg_ifdown (dev))
-		devinfo (dev, "stop stats: rx/tx %ld/%ld, errs %ld/%ld",
-			net->stats.rx_packets, net->stats.tx_packets,
-			net->stats.rx_errors, net->stats.tx_errors
-			);
+		netdev_info(dev->net, "stop stats: rx/tx %ld/%ld, errs %ld/%ld\n",
+			    net->stats.rx_packets, net->stats.tx_packets,
+			    net->stats.rx_errors, net->stats.tx_errors);
 
 	/* allow minidriver to stop correctly (wireless devices to turn off
 	 * radio etc) */
 	if (info->stop) {
 		retval = info->stop(dev);
 		if (retval < 0 && netif_msg_ifdown(dev))
-			devinfo(dev,
-				"stop fail (%d) usbnet usb-%s-%s, %s",
-				retval,
-				dev->udev->bus->bus_name, dev->udev->devpath,
-				info->description);
+			netdev_info(dev->net,
+				    "stop fail (%d) usbnet usb-%s-%s, %s\n",
+				    retval,
+				    dev->udev->bus->bus_name, dev->udev->devpath,
+				    info->description);
 	}
 
 	if (!(info->flags & FLAG_AVOID_UNLINK_URBS))
@@ -703,29 +703,31 @@ int usbnet_open (struct net_device *net)
 
 	if ((retval = usb_autopm_get_interface(dev->intf)) < 0) {
 		if (netif_msg_ifup (dev))
-			devinfo (dev,
-				"resumption fail (%d) usbnet usb-%s-%s, %s",
-				retval,
-				dev->udev->bus->bus_name, dev->udev->devpath,
-			info->description);
+			netdev_info(dev->net,
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
+			netdev_info(dev->net,
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
+			netdev_dbg(dev->net, "can't open; %d\n", retval);
 		goto done;
 	}
 
@@ -734,7 +736,7 @@ int usbnet_open (struct net_device *net)
 		retval = usb_submit_urb (dev->interrupt, GFP_KERNEL);
 		if (retval < 0) {
 			if (netif_msg_ifup (dev))
-				deverr (dev, "intr submit %d", retval);
+				netdev_err(dev->net, "intr submit %d\n", retval);
 			goto done;
 		}
 	}
@@ -756,10 +758,9 @@ int usbnet_open (struct net_device *net)
 		else
 			framing = "simple";
 
-		devinfo (dev, "open: enable queueing "
-				"(rx %d, tx %d) mtu %d %s framing",
-			(int)RX_QLEN (dev), (int)TX_QLEN (dev), dev->net->mtu,
-			framing);
+		netdev_info(dev->net, "open: enable queueing (rx %d, tx %d) mtu %d %s framing\n",
+			    (int)RX_QLEN(dev), (int)TX_QLEN(dev),
+			    dev->net->mtu, framing);
 	}
 
 	// delay posting reads until we're fully open
@@ -908,8 +909,8 @@ kevent (struct work_struct *work)
 		    status != -ESHUTDOWN) {
 			if (netif_msg_tx_err (dev))
 fail_pipe:
-				deverr (dev, "can't clear tx halt, status %d",
-					status);
+				netdev_err(dev->net, "can't clear tx halt, status %d\n",
+					   status);
 		} else {
 			clear_bit (EVENT_TX_HALT, &dev->flags);
 			if (status != -ESHUTDOWN)
@@ -928,8 +929,8 @@ fail_pipe:
 		    status != -ESHUTDOWN) {
 			if (netif_msg_rx_err (dev))
 fail_halt:
-				deverr (dev, "can't clear rx halt, status %d",
-					status);
+				netdev_err(dev->net, "can't clear rx halt, status %d\n",
+					   status);
 		} else {
 			clear_bit (EVENT_RX_HALT, &dev->flags);
 			tasklet_schedule (&dev->bh);
@@ -967,18 +968,18 @@ fail_lowmem:
 		if(info->link_reset && (retval = info->link_reset(dev)) < 0) {
 			usb_autopm_put_interface(dev->intf);
 skip_reset:
-			devinfo(dev, "link reset failed (%d) usbnet usb-%s-%s, %s",
-				retval,
-				dev->udev->bus->bus_name, dev->udev->devpath,
-				info->description);
+			netdev_info(dev->net, "link reset failed (%d) usbnet usb-%s-%s, %s\n",
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
+		netdev_dbg(dev->net, "kevent done, flags = 0x%lx\n", dev->flags);
 }
 
 /*-------------------------------------------------------------------------*/
@@ -1015,14 +1016,15 @@ static void tx_complete (struct urb *urb)
 				mod_timer (&dev->delay,
 					jiffies + THROTTLE_JIFFIES);
 				if (netif_msg_link (dev))
-					devdbg (dev, "tx throttle %d",
-							urb->status);
+					netdev_dbg(dev->net, "tx throttle %d\n",
+						   urb->status);
 			}
 			netif_stop_queue (dev->net);
 			break;
 		default:
 			if (netif_msg_tx_err (dev))
-				devdbg (dev, "tx err %d", entry->urb->status);
+				netdev_dbg(dev->net, "tx err %d\n",
+					   entry->urb->status);
 			break;
 		}
 	}
@@ -1065,7 +1067,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		skb = info->tx_fixup (dev, skb, GFP_ATOMIC);
 		if (!skb) {
 			if (netif_msg_tx_err (dev))
-				devdbg (dev, "can't tx_fixup skb");
+				netdev_dbg(dev->net, "can't tx_fixup skb\n");
 			goto drop;
 		}
 	}
@@ -1073,7 +1075,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 
 	if (!(urb = usb_alloc_urb (0, GFP_ATOMIC))) {
 		if (netif_msg_tx_err (dev))
-			devdbg (dev, "no urb");
+			netdev_dbg(dev->net, "no urb\n");
 		goto drop;
 	}
 
@@ -1113,7 +1115,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 		/* no use to process more packets */
 		netif_stop_queue(net);
 		spin_unlock_irqrestore(&dev->txq.lock, flags);
-		devdbg(dev, "Delaying transmission for resumption");
+		netdev_dbg(dev->net, "Delaying transmission for resumption\n");
 		goto deferred;
 	}
 #endif
@@ -1127,7 +1129,7 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 	default:
 		usb_autopm_put_interface_async(dev->intf);
 		if (netif_msg_tx_err (dev))
-			devdbg (dev, "tx: submit urb err %d", retval);
+			netdev_dbg(dev->net, "tx: submit urb err %d\n", retval);
 		break;
 	case 0:
 		net->trans_start = jiffies;
@@ -1139,15 +1141,15 @@ netdev_tx_t usbnet_start_xmit (struct sk_buff *skb,
 
 	if (retval) {
 		if (netif_msg_tx_err (dev))
-			devdbg (dev, "drop, code %d", retval);
+			netdev_dbg(dev->net, "drop, code %d\n", retval);
 drop:
 		dev->net->stats.tx_dropped++;
 		if (skb)
 			dev_kfree_skb_any (skb);
 		usb_free_urb (urb);
 	} else if (netif_msg_tx_queued (dev)) {
-		devdbg (dev, "> tx, len %d, type 0x%x",
-			length, skb->protocol);
+		netdev_dbg(dev->net, "> tx, len %d, type 0x%x\n",
+			   length, skb->protocol);
 	}
 #ifdef CONFIG_PM
 deferred:
@@ -1179,7 +1181,7 @@ static void usbnet_bh (unsigned long param)
 			dev_kfree_skb (skb);
 			continue;
 		default:
-			devdbg (dev, "bogus skb state %d", entry->state);
+			netdev_dbg(dev->net, "bogus skb state %d\n", entry->state);
 		}
 	}
 
@@ -1208,8 +1210,8 @@ static void usbnet_bh (unsigned long param)
 					rx_submit (dev, urb, GFP_ATOMIC);
 			}
 			if (temp != dev->rxq.qlen && netif_msg_link (dev))
-				devdbg (dev, "rxqlen %d --> %d",
-						temp, dev->rxq.qlen);
+				netdev_dbg(dev->net, "rxqlen %d --> %d\n",
+					   temp, dev->rxq.qlen);
 			if (dev->rxq.qlen < qlen)
 				tasklet_schedule (&dev->bh);
 		}
@@ -1241,10 +1243,10 @@ void usbnet_disconnect (struct usb_interface *intf)
 	xdev = interface_to_usbdev (intf);
 
 	if (netif_msg_probe (dev))
-		devinfo (dev, "unregister '%s' usb-%s-%s, %s",
-			intf->dev.driver->name,
-			xdev->bus->bus_name, xdev->devpath,
-			dev->driver_info->description);
+		netdev_info(dev->net, "unregister '%s' usb-%s-%s, %s\n",
+			    intf->dev.driver->name,
+			    xdev->bus->bus_name, xdev->devpath,
+			    dev->driver_info->description);
 
 	net = dev->net;
 	unregister_netdev (net);
@@ -1408,11 +1410,11 @@ usbnet_probe (struct usb_interface *udev, const struct usb_device_id *prod)
 	if (status)
 		goto out3;
 	if (netif_msg_probe (dev))
-		devinfo (dev, "register '%s' at usb-%s-%s, %s, %pM",
-			udev->dev.driver->name,
-			xdev->bus->bus_name, xdev->devpath,
-			dev->driver_info->description,
-			net->dev_addr);
+		netdev_info(dev->net, "register '%s' at usb-%s-%s, %s, %pM\n",
+			    udev->dev.driver->name,
+			    xdev->bus->bus_name, xdev->devpath,
+			    dev->driver_info->description,
+			    net->dev_addr);
 
 	// ok, it's ready to go.
 	usb_set_intfdata (udev, dev);
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index 14692bc..65cbd06 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -728,9 +728,9 @@ static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
 	ret = rndis_command(dev, u.header, buflen);
 	priv->current_command_oid = 0;
 	if (ret < 0)
-		devdbg(dev, "rndis_query_oid(%s): rndis_command() failed, %d "
-			"(%08x)", oid_to_string(oid), ret,
-			le32_to_cpu(u.get_c->status));
+		netdev_dbg(dev->net, "%s(%s): rndis_command() failed, %d (%08x)\n",
+			   __func__, oid_to_string(oid), ret,
+			   le32_to_cpu(u.get_c->status));
 
 	if (ret == 0) {
 		memcpy(data, u.buf + le32_to_cpu(u.get_c->offset) + 8, *len);
@@ -741,9 +741,9 @@ static int rndis_query_oid(struct usbnet *dev, __le32 oid, void *data, int *len)
 
 		ret = rndis_error_status(u.get_c->status);
 		if (ret < 0)
-			devdbg(dev, "rndis_query_oid(%s): device returned "
-				"error,  0x%08x (%d)", oid_to_string(oid),
-				le32_to_cpu(u.get_c->status), ret);
+			netdev_dbg(dev->net, "%s(%s): device returned error,  0x%08x (%d)\n",
+				   __func__, oid_to_string(oid),
+				   le32_to_cpu(u.get_c->status), ret);
 	}
 
 	mutex_unlock(&priv->command_lock);
@@ -791,17 +791,17 @@ static int rndis_set_oid(struct usbnet *dev, __le32 oid, void *data, int len)
 	ret = rndis_command(dev, u.header, buflen);
 	priv->current_command_oid = 0;
 	if (ret < 0)
-		devdbg(dev, "rndis_set_oid(%s): rndis_command() failed, %d "
-			"(%08x)", oid_to_string(oid), ret,
-			le32_to_cpu(u.set_c->status));
+		netdev_dbg(dev->net, "%s(%s): rndis_command() failed, %d (%08x)\n",
+			   __func__, oid_to_string(oid), ret,
+			   le32_to_cpu(u.set_c->status));
 
 	if (ret == 0) {
 		ret = rndis_error_status(u.set_c->status);
 
 		if (ret < 0)
-			devdbg(dev, "rndis_set_oid(%s): device returned error, "
-				"0x%08x (%d)", oid_to_string(oid),
-				le32_to_cpu(u.set_c->status), ret);
+			netdev_dbg(dev->net, "%s(%s): device returned error, 0x%08x (%d)\n",
+				   __func__, oid_to_string(oid),
+				   le32_to_cpu(u.set_c->status), ret);
 	}
 
 	mutex_unlock(&priv->command_lock);
@@ -870,11 +870,11 @@ static int rndis_set_config_parameter(struct usbnet *dev, char *param,
 #endif
 
 	if (value_type == 2)
-		devdbg(dev, "setting config parameter: %s, value: %s",
-						param, (u8 *)value);
+		netdev_dbg(dev->net, "setting config parameter: %s, value: %s\n",
+			   param, (u8 *)value);
 	else
-		devdbg(dev, "setting config parameter: %s, value: %d",
-						param, *(u32 *)value);
+		netdev_dbg(dev->net, "setting config parameter: %s, value: %d\n",
+			   param, *(u32 *)value);
 
 	infobuf->name_offs = cpu_to_le32(sizeof(*infobuf));
 	infobuf->name_length = cpu_to_le32(param_len);
@@ -897,20 +897,21 @@ static int rndis_set_config_parameter(struct usbnet *dev, char *param,
 	}
 
 #ifdef DEBUG
-	devdbg(dev, "info buffer (len: %d):", info_len);
+	netdev_dbg(dev->net, "info buffer (len: %d)\n", info_len);
 	for (i = 0; i < info_len; i += 12) {
 		u32 *tmp = (u32 *)((u8 *)infobuf + i);
-		devdbg(dev, "%08X:%08X:%08X",
-			cpu_to_be32(tmp[0]),
-			cpu_to_be32(tmp[1]),
-			cpu_to_be32(tmp[2]));
+		netdev_dbg(dev->net, "%08X:%08X:%08X\n",
+			   cpu_to_be32(tmp[0]),
+			   cpu_to_be32(tmp[1]),
+			   cpu_to_be32(tmp[2]));
 	}
 #endif
 
 	ret = rndis_set_oid(dev, OID_GEN_RNDIS_CONFIG_PARAMETER,
 							infobuf, info_len);
 	if (ret != 0)
-		devdbg(dev, "setting rndis config parameter failed, %d.", ret);
+		netdev_dbg(dev->net, "setting rndis config parameter failed, %d\n",
+			   ret);
 
 	kfree(infobuf);
 	return ret;
@@ -945,13 +946,13 @@ static int set_essid(struct usbnet *usbdev, struct ndis_80211_ssid *ssid)
 
 	ret = rndis_set_oid(usbdev, OID_802_11_SSID, ssid, sizeof(*ssid));
 	if (ret < 0) {
-		devwarn(usbdev, "setting SSID failed (%08X)", ret);
+		netdev_warn(usbdev->net, "setting SSID failed (%08X)\n", ret);
 		return ret;
 	}
 	if (ret == 0) {
 		memcpy(&priv->essid, ssid, sizeof(priv->essid));
 		priv->radio_on = true;
-		devdbg(usbdev, "set_essid: radio_on = true");
+		netdev_dbg(usbdev->net, "%s(): radio_on = true\n", __func__);
 	}
 
 	return ret;
@@ -963,7 +964,8 @@ static int set_bssid(struct usbnet *usbdev, u8 bssid[ETH_ALEN])
 
 	ret = rndis_set_oid(usbdev, OID_802_11_BSSID, bssid, ETH_ALEN);
 	if (ret < 0) {
-		devwarn(usbdev, "setting BSSID[%pM] failed (%08X)", bssid, ret);
+		netdev_warn(usbdev->net, "setting BSSID[%pM] failed (%08X)\n",
+			    bssid, ret);
 		return ret;
 	}
 
@@ -1021,7 +1023,8 @@ static int disassociate(struct usbnet *usbdev, bool reset_ssid)
 		ret = rndis_set_oid(usbdev, OID_802_11_DISASSOCIATE, NULL, 0);
 		if (ret == 0) {
 			priv->radio_on = false;
-			devdbg(usbdev, "disassociate: radio_on = false");
+			netdev_dbg(usbdev->net, "%s(): radio_on = false\n",
+				   __func__);
 
 			if (reset_ssid)
 				msleep(100);
@@ -1054,8 +1057,8 @@ static int set_auth_mode(struct usbnet *usbdev, u32 wpa_version,
 	__le32 tmp;
 	int auth_mode, ret;
 
-	devdbg(usbdev, "set_auth_mode: wpa_version=0x%x authalg=0x%x "
-		"keymgmt=0x%x", wpa_version, auth_type, keymgmt);
+	netdev_dbg(usbdev->net, "%s(): wpa_version=0x%x authalg=0x%x keymgmt=0x%x\n",
+		   __func__, wpa_version, auth_type, keymgmt);
 
 	if (wpa_version & NL80211_WPA_VERSION_2) {
 		if (keymgmt & RNDIS_WLAN_KEY_MGMT_802_1X)
@@ -1082,7 +1085,8 @@ static int set_auth_mode(struct usbnet *usbdev, u32 wpa_version,
 	ret = rndis_set_oid(usbdev, OID_802_11_AUTHENTICATION_MODE, &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
-		devwarn(usbdev, "setting auth mode failed (%08X)", ret);
+		netdev_warn(usbdev->net, "setting auth mode failed (%08X)\n",
+			    ret);
 		return ret;
 	}
 
@@ -1098,7 +1102,8 @@ static int set_priv_filter(struct usbnet *usbdev)
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 	__le32 tmp;
 
-	devdbg(usbdev, "set_priv_filter: wpa_version=0x%x", priv->wpa_version);
+	netdev_dbg(usbdev->net, "%s(): wpa_version=0x%x\n",
+		   __func__, priv->wpa_version);
 
 	if (priv->wpa_version & NL80211_WPA_VERSION_2 ||
 	    priv->wpa_version & NL80211_WPA_VERSION_1)
@@ -1116,8 +1121,8 @@ static int set_encr_mode(struct usbnet *usbdev, int pairwise, int groupwise)
 	__le32 tmp;
 	int encr_mode, ret;
 
-	devdbg(usbdev, "set_encr_mode: cipher_pair=0x%x cipher_group=0x%x",
-		pairwise, groupwise);
+	netdev_dbg(usbdev->net, "%s(): cipher_pair=0x%x cipher_group=0x%x\n",
+		   __func__, pairwise, groupwise);
 
 	if (pairwise & RNDIS_WLAN_ALG_CCMP)
 		encr_mode = NDIS_80211_ENCR_CCMP_ENABLED;
@@ -1136,7 +1141,8 @@ static int set_encr_mode(struct usbnet *usbdev, int pairwise, int groupwise)
 	ret = rndis_set_oid(usbdev, OID_802_11_ENCRYPTION_STATUS, &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
-		devwarn(usbdev, "setting encr mode failed (%08X)", ret);
+		netdev_warn(usbdev->net, "setting encr mode failed (%08X)\n",
+			    ret);
 		return ret;
 	}
 
@@ -1151,13 +1157,15 @@ static int set_infra_mode(struct usbnet *usbdev, int mode)
 	__le32 tmp;
 	int ret;
 
-	devdbg(usbdev, "set_infra_mode: infra_mode=0x%x", priv->infra_mode);
+	netdev_dbg(usbdev->net, "%s(): infra_mode=0x%x\n",
+		   __func__, priv->infra_mode);
 
 	tmp = cpu_to_le32(mode);
 	ret = rndis_set_oid(usbdev, OID_802_11_INFRASTRUCTURE_MODE, &tmp,
 								sizeof(tmp));
 	if (ret != 0) {
-		devwarn(usbdev, "setting infra mode failed (%08X)", ret);
+		netdev_warn(usbdev->net, "setting infra mode failed (%08X)\n",
+			    ret);
 		return ret;
 	}
 
@@ -1174,7 +1182,7 @@ static int set_rts_threshold(struct usbnet *usbdev, u32 rts_threshold)
 {
 	__le32 tmp;
 
-	devdbg(usbdev, "set_rts_threshold %i", rts_threshold);
+	netdev_dbg(usbdev->net, "%s(): %i\n", __func__, rts_threshold);
 
 	if (rts_threshold < 0 || rts_threshold > 2347)
 		rts_threshold = 2347;
@@ -1188,7 +1196,7 @@ static int set_frag_threshold(struct usbnet *usbdev, u32 frag_threshold)
 {
 	__le32 tmp;
 
-	devdbg(usbdev, "set_frag_threshold %i", frag_threshold);
+	netdev_dbg(usbdev->net, "%s(): %i\n", __func__, frag_threshold);
 
 	if (frag_threshold < 256 || frag_threshold > 2346)
 		frag_threshold = 2346;
@@ -1222,7 +1230,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 	unsigned int dsconfig;
 	int len, ret;
 
-	devdbg(usbdev, "set_channel(%d)", channel);
+	netdev_dbg(usbdev->net, "%s(%d)\n", __func__, channel);
 
 	/* this OID is valid only when not associated */
 	if (is_associated(usbdev))
@@ -1233,7 +1241,8 @@ static int set_channel(struct usbnet *usbdev, int channel)
 	len = sizeof(config);
 	ret = rndis_query_oid(usbdev, OID_802_11_CONFIGURATION, &config, &len);
 	if (ret < 0) {
-		devdbg(usbdev, "set_channel: querying configuration failed");
+		netdev_dbg(usbdev->net, "%s(): querying configuration failed\n",
+			   __func__);
 		return ret;
 	}
 
@@ -1241,7 +1250,7 @@ static int set_channel(struct usbnet *usbdev, int channel)
 	ret = rndis_set_oid(usbdev, OID_802_11_CONFIGURATION, &config,
 								sizeof(config));
 
-	devdbg(usbdev, "set_channel: %d -> %d", channel, ret);
+	netdev_dbg(usbdev->net, "%s(): %d -> %d\n", __func__, channel, ret);
 
 	return ret;
 }
@@ -1255,7 +1264,8 @@ static int add_wep_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	u32 cipher;
 	int ret;
 
-	devdbg(usbdev, "add_wep_key(idx: %d, len: %d)", index, key_len);
+	netdev_dbg(usbdev->net, "%s(idx: %d, len: %d)\n",
+		   __func__, index, key_len);
 
 	if ((key_len != 5 && key_len != 13) || index < 0 || index > 3)
 		return -EINVAL;
@@ -1277,15 +1287,15 @@ static int add_wep_key(struct usbnet *usbdev, const u8 *key, int key_len,
 		ret = set_encr_mode(usbdev, RNDIS_WLAN_ALG_WEP,
 							RNDIS_WLAN_ALG_NONE);
 		if (ret)
-			devwarn(usbdev, "encryption couldn't be enabled (%08X)",
-									ret);
+			netdev_warn(usbdev->net, "encryption couldn't be enabled (%08X)\n",
+				    ret);
 	}
 
 	ret = rndis_set_oid(usbdev, OID_802_11_ADD_WEP, &ndis_key,
 							sizeof(ndis_key));
 	if (ret != 0) {
-		devwarn(usbdev, "adding encryption key %d failed (%08X)",
-							index+1, ret);
+		netdev_warn(usbdev->net, "adding encryption key %d failed (%08X)\n",
+			    index + 1, ret);
 		return ret;
 	}
 
@@ -1307,22 +1317,23 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	int ret;
 
 	if (index < 0 || index >= 4) {
-		devdbg(usbdev, "add_wpa_key: index out of range (%i)", index);
+		netdev_dbg(usbdev->net, "%s(): index out of range (%i)\n",
+			   __func__, index);
 		return -EINVAL;
 	}
 	if (key_len > sizeof(ndis_key.material) || key_len < 0) {
-		devdbg(usbdev, "add_wpa_key: key length out of range (%i)",
-			key_len);
+		netdev_dbg(usbdev->net, "%s(): key length out of range (%i)\n",
+			   __func__, key_len);
 		return -EINVAL;
 	}
 	if (flags & NDIS_80211_ADDKEY_SET_INIT_RECV_SEQ) {
 		if (!rx_seq || seq_len <= 0) {
-			devdbg(usbdev, "add_wpa_key: recv seq flag without"
-					"buffer");
+			netdev_dbg(usbdev->net, "%s(): recv seq flag without buffer\n",
+				   __func__);
 			return -EINVAL;
 		}
 		if (rx_seq && seq_len > sizeof(ndis_key.rsc)) {
-			devdbg(usbdev, "add_wpa_key: too big recv seq buffer");
+			netdev_dbg(usbdev->net, "%s(): too big recv seq buffer\n", __func__);
 			return -EINVAL;
 		}
 	}
@@ -1330,15 +1341,16 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 	is_addr_ok = addr && !is_zero_ether_addr(addr) &&
 					!is_broadcast_ether_addr(addr);
 	if ((flags & NDIS_80211_ADDKEY_PAIRWISE_KEY) && !is_addr_ok) {
-		devdbg(usbdev, "add_wpa_key: pairwise but bssid invalid (%pM)",
-			addr);
+		netdev_dbg(usbdev->net, "%s(): pairwise but bssid invalid (%pM)\n",
+			   __func__, addr);
 		return -EINVAL;
 	}
 
-	devdbg(usbdev, "add_wpa_key(%i): flags:%i%i%i", index,
-			!!(flags & NDIS_80211_ADDKEY_TRANSMIT_KEY),
-			!!(flags & NDIS_80211_ADDKEY_PAIRWISE_KEY),
-			!!(flags & NDIS_80211_ADDKEY_SET_INIT_RECV_SEQ));
+	netdev_dbg(usbdev->net, "%s(%i): flags:%i%i%i\n",
+		   __func__, index,
+		   !!(flags & NDIS_80211_ADDKEY_TRANSMIT_KEY),
+		   !!(flags & NDIS_80211_ADDKEY_PAIRWISE_KEY),
+		   !!(flags & NDIS_80211_ADDKEY_SET_INIT_RECV_SEQ));
 
 	memset(&ndis_key, 0, sizeof(ndis_key));
 
@@ -1372,7 +1384,8 @@ static int add_wpa_key(struct usbnet *usbdev, const u8 *key, int key_len,
 
 	ret = rndis_set_oid(usbdev, OID_802_11_ADD_KEY, &ndis_key,
 					le32_to_cpu(ndis_key.size));
-	devdbg(usbdev, "add_wpa_key: OID_802_11_ADD_KEY -> %08X", ret);
+	netdev_dbg(usbdev->net, "%s(): OID_802_11_ADD_KEY -> %08X\n",
+		   __func__, ret);
 	if (ret != 0)
 		return ret;
 
@@ -1401,7 +1414,7 @@ static int restore_key(struct usbnet *usbdev, int key_idx)
 
 	key = priv->encr_keys[key_idx];
 
-	devdbg(usbdev, "restore_key: %i:%i", key_idx, key.len);
+	netdev_dbg(usbdev->net, "%s(): %i:%i\n", __func__, key_idx, key.len);
 
 	if (key.len == 0)
 		return 0;
@@ -1436,8 +1449,9 @@ static int remove_key(struct usbnet *usbdev, int index, const u8 *bssid)
 
 	is_wpa = is_wpa_key(priv, index);
 
-	devdbg(usbdev, "remove_key: %i:%s:%i", index, is_wpa ? "wpa" : "wep",
-		priv->encr_keys[index].len);
+	netdev_dbg(usbdev->net, "%s(): %i:%s:%i\n",
+		   __func__, index, is_wpa ? "wpa" : "wep",
+		   priv->encr_keys[index].len);
 
 	clear_key(priv, index);
 
@@ -1464,9 +1478,9 @@ static int remove_key(struct usbnet *usbdev, int index, const u8 *bssid)
 		ret = rndis_set_oid(usbdev, OID_802_11_REMOVE_WEP, &keyindex,
 							sizeof(keyindex));
 		if (ret != 0) {
-			devwarn(usbdev,
-				"removing encryption key %d failed (%08X)",
-				index, ret);
+			netdev_warn(usbdev->net,
+				    "removing encryption key %d failed (%08X)\n",
+				    index, ret);
 			return ret;
 		}
 	}
@@ -1498,9 +1512,9 @@ static void set_multicast_list(struct usbnet *usbdev)
 		size = min(priv->multicast_size, netdev_mc_count(usbdev->net));
 		buf = kmalloc(size * ETH_ALEN, GFP_KERNEL);
 		if (!buf) {
-			devwarn(usbdev,
-				"couldn't alloc %d bytes of memory",
-				size * ETH_ALEN);
+			netdev_warn(usbdev->net,
+				    "couldn't alloc %d bytes of memory\n",
+				    size * ETH_ALEN);
 			return;
 		}
 
@@ -1520,8 +1534,8 @@ static void set_multicast_list(struct usbnet *usbdev)
 		else
 			filter |= RNDIS_PACKET_TYPE_ALL_MULTICAST;
 
-		devdbg(usbdev, "OID_802_3_MULTICAST_LIST(%d, max: %d) -> %d",
-						i, priv->multicast_size, ret);
+		netdev_dbg(usbdev->net, "OID_802_3_MULTICAST_LIST(%d, max: %d) -> %d\n",
+			   i, priv->multicast_size, ret);
 
 		kfree(buf);
 	}
@@ -1529,12 +1543,12 @@ static void set_multicast_list(struct usbnet *usbdev)
 	ret = rndis_set_oid(usbdev, OID_GEN_CURRENT_PACKET_FILTER, &filter,
 							sizeof(filter));
 	if (ret < 0) {
-		devwarn(usbdev, "couldn't set packet filter: %08x",
-							le32_to_cpu(filter));
+		netdev_warn(usbdev->net, "couldn't set packet filter: %08x\n",
+			    le32_to_cpu(filter));
 	}
 
-	devdbg(usbdev, "OID_GEN_CURRENT_PACKET_FILTER(%08x) -> %d",
-						le32_to_cpu(filter), ret);
+	netdev_dbg(usbdev->net, "OID_GEN_CURRENT_PACKET_FILTER(%08x) -> %d\n",
+		   le32_to_cpu(filter), ret);
 }
 
 /*
@@ -1592,7 +1606,8 @@ static int rndis_set_tx_power(struct wiphy *wiphy, enum tx_power_setting type,
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
 
-	devdbg(usbdev, "rndis_set_tx_power type:0x%x dbm:%i", type, dbm);
+	netdev_dbg(usbdev->net, "%s(): type:0x%x dbm:%i\n",
+		   __func__, type, dbm);
 
 	/* Device doesn't support changing txpower after initialization, only
 	 * turn off/on radio. Support 'auto' mode and setting same dBm that is
@@ -1615,7 +1630,7 @@ static int rndis_get_tx_power(struct wiphy *wiphy, int *dbm)
 
 	*dbm = get_bcm4320_power_dbm(priv);
 
-	devdbg(usbdev, "rndis_get_tx_power dbm:%i", *dbm);
+	netdev_dbg(usbdev->net, "%s(): dbm:%i\n", __func__, *dbm);
 
 	return 0;
 }
@@ -1629,7 +1644,7 @@ static int rndis_scan(struct wiphy *wiphy, struct net_device *dev,
 	int ret;
 	__le32 tmp;
 
-	devdbg(usbdev, "cfg80211.scan");
+	netdev_dbg(usbdev->net, "cfg80211.scan\n");
 
 	/* Get current bssid list from device before new scan, as new scan
 	 * clears internal bssid list.
@@ -1669,8 +1684,8 @@ static struct cfg80211_bss *rndis_bss_info_update(struct usbnet *usbdev,
 	int ie_len, bssid_len;
 	u8 *ie;
 
-	devdbg(usbdev, " found bssid: '%.32s' [%pM]", bssid->ssid.essid,
-							bssid->mac);
+	netdev_dbg(usbdev->net, " found bssid: '%.32s' [%pM]\n",
+		   bssid->ssid.essid, bssid->mac);
 
 	/* parse bssid structure */
 	bssid_len = le32_to_cpu(bssid->length);
@@ -1712,7 +1727,7 @@ static int rndis_check_bssid_list(struct usbnet *usbdev)
 	int ret = -EINVAL, len, count, bssid_len;
 	bool resized = false;
 
-	devdbg(usbdev, "check_bssid_list");
+	netdev_dbg(usbdev->net, "check_bssid_list\n");
 
 	len = CONTROL_BUFFER_SIZE;
 resize_buf:
@@ -1736,8 +1751,8 @@ resize_buf:
 	bssid = bssid_list->bssid;
 	bssid_len = le32_to_cpu(bssid->length);
 	count = le32_to_cpu(bssid_list->num_items);
-	devdbg(usbdev, "check_bssid_list: %d BSSIDs found (buflen: %d)", count,
-									len);
+	netdev_dbg(usbdev->net, "check_bssid_list: %d BSSIDs found (buflen: %d)\n",
+		   count, len);
 
 	while (count && ((void *)bssid + bssid_len) <= (buf + len)) {
 		rndis_bss_info_update(usbdev, bssid);
@@ -1759,7 +1774,7 @@ static void rndis_get_scan_results(struct work_struct *work)
 	struct usbnet *usbdev = priv->usbdev;
 	int ret;
 
-	devdbg(usbdev, "get_scan_results");
+	netdev_dbg(usbdev->net, "get_scan_results\n");
 
 	if (!priv->scan_request)
 		return;
@@ -1793,7 +1808,7 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	if (sme->crypto.n_ciphers_pairwise > 0 &&
 			pairwise == RNDIS_WLAN_ALG_NONE) {
-		deverr(usbdev, "Unsupported pairwise cipher");
+		netdev_err(usbdev->net, "Unsupported pairwise cipher\n");
 		return -ENOTSUPP;
 	}
 
@@ -1803,28 +1818,30 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	if (sme->crypto.n_akm_suites > 0 &&
 			keymgmt == RNDIS_WLAN_KEY_MGMT_NONE) {
-		deverr(usbdev, "Invalid keymgmt");
+		netdev_err(usbdev->net, "Invalid keymgmt\n");
 		return -ENOTSUPP;
 	}
 
-	devdbg(usbdev, "cfg80211.connect('%.32s':[%pM]:%d:[%d,0x%x:0x%x]:[0x%x:"
-			"0x%x]:0x%x)", sme->ssid, sme->bssid, chan,
-			sme->privacy, sme->crypto.wpa_versions, sme->auth_type,
-			groupwise, pairwise, keymgmt);
+	netdev_dbg(usbdev->net, "cfg80211.connect('%.32s':[%pM]:%d:[%d,0x%x:0x%x]:[0x%x:0x%x]:0x%x)\n",
+		   sme->ssid, sme->bssid, chan,
+		   sme->privacy, sme->crypto.wpa_versions, sme->auth_type,
+		   groupwise, pairwise, keymgmt);
 
 	if (is_associated(usbdev))
 		disassociate(usbdev, false);
 
 	ret = set_infra_mode(usbdev, NDIS_80211_INFRA_INFRA);
 	if (ret < 0) {
-		devdbg(usbdev, "connect: set_infra_mode failed, %d", ret);
+		netdev_dbg(usbdev->net, "connect: set_infra_mode failed, %d\n",
+			   ret);
 		goto err_turn_radio_on;
 	}
 
 	ret = set_auth_mode(usbdev, sme->crypto.wpa_versions, sme->auth_type,
 								keymgmt);
 	if (ret < 0) {
-		devdbg(usbdev, "connect: set_auth_mode failed, %d", ret);
+		netdev_dbg(usbdev->net, "connect: set_auth_mode failed, %d\n",
+			   ret);
 		goto err_turn_radio_on;
 	}
 
@@ -1832,14 +1849,16 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	ret = set_encr_mode(usbdev, pairwise, groupwise);
 	if (ret < 0) {
-		devdbg(usbdev, "connect: set_encr_mode failed, %d", ret);
+		netdev_dbg(usbdev->net, "connect: set_encr_mode failed, %d\n",
+			   ret);
 		goto err_turn_radio_on;
 	}
 
 	if (channel) {
 		ret = set_channel(usbdev, chan);
 		if (ret < 0) {
-			devdbg(usbdev, "connect: set_channel failed, %d", ret);
+			netdev_dbg(usbdev->net, "connect: set_channel failed, %d\n",
+				   ret);
 			goto err_turn_radio_on;
 		}
 	}
@@ -1848,8 +1867,8 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 		priv->encr_tx_key_index = sme->key_idx;
 		ret = add_wep_key(usbdev, sme->key, sme->key_len, sme->key_idx);
 		if (ret < 0) {
-			devdbg(usbdev, "connect: add_wep_key failed, %d "
-				"(%d, %d)", ret, sme->key_len, sme->key_idx);
+			netdev_dbg(usbdev->net, "connect: add_wep_key failed, %d (%d, %d)\n",
+				   ret, sme->key_len, sme->key_idx);
 			goto err_turn_radio_on;
 		}
 	}
@@ -1858,7 +1877,8 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 				!is_broadcast_ether_addr(sme->bssid)) {
 		ret = set_bssid(usbdev, sme->bssid);
 		if (ret < 0) {
-			devdbg(usbdev, "connect: set_bssid failed, %d", ret);
+			netdev_dbg(usbdev->net, "connect: set_bssid failed, %d\n",
+				   ret);
 			goto err_turn_radio_on;
 		}
 	} else
@@ -1880,7 +1900,7 @@ static int rndis_connect(struct wiphy *wiphy, struct net_device *dev,
 
 	ret = set_essid(usbdev, &ssid);
 	if (ret < 0)
-		devdbg(usbdev, "connect: set_essid failed, %d", ret);
+		netdev_dbg(usbdev->net, "connect: set_essid failed, %d\n", ret);
 	return ret;
 
 err_turn_radio_on:
@@ -1895,7 +1915,7 @@ static int rndis_disconnect(struct wiphy *wiphy, struct net_device *dev,
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
 
-	devdbg(usbdev, "cfg80211.disconnect(%d)", reason_code);
+	netdev_dbg(usbdev->net, "cfg80211.disconnect(%d)\n", reason_code);
 
 	priv->connected = false;
 	memset(priv->bssid, 0, ETH_ALEN);
@@ -1929,21 +1949,23 @@ static int rndis_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 		alg = RNDIS_WLAN_ALG_NONE;
 	}
 
-	devdbg(usbdev, "cfg80211.join_ibss('%.32s':[%pM]:%d:%d)", params->ssid,
-					params->bssid, chan, params->privacy);
+	netdev_dbg(usbdev->net, "cfg80211.join_ibss('%.32s':[%pM]:%d:%d)\n",
+		   params->ssid, params->bssid, chan, params->privacy);
 
 	if (is_associated(usbdev))
 		disassociate(usbdev, false);
 
 	ret = set_infra_mode(usbdev, NDIS_80211_INFRA_ADHOC);
 	if (ret < 0) {
-		devdbg(usbdev, "join_ibss: set_infra_mode failed, %d", ret);
+		netdev_dbg(usbdev->net, "join_ibss: set_infra_mode failed, %d\n",
+			   ret);
 		goto err_turn_radio_on;
 	}
 
 	ret = set_auth_mode(usbdev, 0, auth_type, RNDIS_WLAN_KEY_MGMT_NONE);
 	if (ret < 0) {
-		devdbg(usbdev, "join_ibss: set_auth_mode failed, %d", ret);
+		netdev_dbg(usbdev->net, "join_ibss: set_auth_mode failed, %d\n",
+			   ret);
 		goto err_turn_radio_on;
 	}
 
@@ -1951,15 +1973,16 @@ static int rndis_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 
 	ret = set_encr_mode(usbdev, alg, RNDIS_WLAN_ALG_NONE);
 	if (ret < 0) {
-		devdbg(usbdev, "join_ibss: set_encr_mode failed, %d", ret);
+		netdev_dbg(usbdev->net, "join_ibss: set_encr_mode failed, %d\n",
+			   ret);
 		goto err_turn_radio_on;
 	}
 
 	if (channel) {
 		ret = set_channel(usbdev, chan);
 		if (ret < 0) {
-			devdbg(usbdev, "join_ibss: set_channel failed, %d",
-				ret);
+			netdev_dbg(usbdev->net, "join_ibss: set_channel failed, %d\n",
+				   ret);
 			goto err_turn_radio_on;
 		}
 	}
@@ -1968,7 +1991,8 @@ static int rndis_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 				!is_broadcast_ether_addr(params->bssid)) {
 		ret = set_bssid(usbdev, params->bssid);
 		if (ret < 0) {
-			devdbg(usbdev, "join_ibss: set_bssid failed, %d", ret);
+			netdev_dbg(usbdev->net, "join_ibss: set_bssid failed, %d\n",
+				   ret);
 			goto err_turn_radio_on;
 		}
 	} else
@@ -1988,7 +2012,8 @@ static int rndis_join_ibss(struct wiphy *wiphy, struct net_device *dev,
 
 	ret = set_essid(usbdev, &ssid);
 	if (ret < 0)
-		devdbg(usbdev, "join_ibss: set_essid failed, %d", ret);
+		netdev_dbg(usbdev->net, "join_ibss: set_essid failed, %d\n",
+			   ret);
 	return ret;
 
 err_turn_radio_on:
@@ -2002,7 +2027,7 @@ static int rndis_leave_ibss(struct wiphy *wiphy, struct net_device *dev)
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
 
-	devdbg(usbdev, "cfg80211.leave_ibss()");
+	netdev_dbg(usbdev->net, "cfg80211.leave_ibss()\n");
 
 	priv->connected = false;
 	memset(priv->bssid, 0, ETH_ALEN);
@@ -2028,8 +2053,8 @@ static int rndis_add_key(struct wiphy *wiphy, struct net_device *netdev,
 	struct usbnet *usbdev = priv->usbdev;
 	__le32 flags;
 
-	devdbg(usbdev, "rndis_add_key(%i, %pM, %08x)", key_index, mac_addr,
-							params->cipher);
+	netdev_dbg(usbdev->net, "%s(%i, %pM, %08x)\n",
+		   __func__, key_index, mac_addr, params->cipher);
 
 	switch (params->cipher) {
 	case WLAN_CIPHER_SUITE_WEP40:
@@ -2050,8 +2075,8 @@ static int rndis_add_key(struct wiphy *wiphy, struct net_device *netdev,
 				key_index, mac_addr, params->seq,
 				params->seq_len, params->cipher, flags);
 	default:
-		devdbg(usbdev, "rndis_add_key: unsupported cipher %08x",
-							params->cipher);
+		netdev_dbg(usbdev->net, "%s(): unsupported cipher %08x\n",
+			   __func__, params->cipher);
 		return -ENOTSUPP;
 	}
 }
@@ -2062,7 +2087,7 @@ static int rndis_del_key(struct wiphy *wiphy, struct net_device *netdev,
 	struct rndis_wlan_private *priv = wiphy_priv(wiphy);
 	struct usbnet *usbdev = priv->usbdev;
 
-	devdbg(usbdev, "rndis_del_key(%i, %pM)", key_index, mac_addr);
+	netdev_dbg(usbdev->net, "%s(%i, %pM)\n", __func__, key_index, mac_addr);
 
 	return remove_key(usbdev, key_index, mac_addr);
 }
@@ -2074,7 +2099,7 @@ static int rndis_set_default_key(struct wiphy *wiphy, struct net_device *netdev,
 	struct usbnet *usbdev = priv->usbdev;
 	struct rndis_wlan_encr_key key;
 
-	devdbg(usbdev, "rndis_set_default_key(%i)", key_index);
+	netdev_dbg(usbdev->net, "%s(%i)\n", __func__, key_index);
 
 	priv->encr_tx_key_index = key_index;
 
@@ -2188,7 +2213,8 @@ static void rndis_wlan_do_link_up_work(struct usbnet *usbdev)
 	if (ret < 0)
 		memset(bssid, 0, sizeof(bssid));
 
-	devdbg(usbdev, "link up work: [%pM] %s", bssid, roamed ? "roamed" : "");
+	netdev_dbg(usbdev->net, "link up work: [%pM]%s\n",
+		   bssid, roamed ? " roamed" : "");
 
 	/* Internal bss list in device always contains at least the currently
 	 * connected bss and we can get it to cfg80211 with
@@ -2270,8 +2296,8 @@ static void rndis_wlan_auth_indication(struct usbnet *usbdev,
 	/* must have at least one array entry */
 	if (len < offsetof(struct ndis_80211_status_indication, u) +
 				sizeof(struct ndis_80211_auth_request)) {
-		devinfo(usbdev, "authentication indication: "
-				"too short message (%i)", len);
+		netdev_info(usbdev->net, "authentication indication: too short message (%i)\n",
+			    len);
 		return;
 	}
 
@@ -2298,8 +2324,8 @@ static void rndis_wlan_auth_indication(struct usbnet *usbdev,
 			type = "group_error";
 		}
 
-		devinfo(usbdev, "authentication indication: %s (0x%08x)", type,
-				le32_to_cpu(auth_req->flags));
+		netdev_info(usbdev->net, "authentication indication: %s (0x%08x)\n",
+			    type, le32_to_cpu(auth_req->flags));
 
 		if (pairwise_error) {
 			key_type = NL80211_KEYTYPE_PAIRWISE;
@@ -2335,8 +2361,8 @@ static void rndis_wlan_pmkid_cand_list_indication(struct usbnet *usbdev,
 
 	if (len < offsetof(struct ndis_80211_status_indication, u) +
 				sizeof(struct ndis_80211_pmkid_cand_list)) {
-		devinfo(usbdev, "pmkid candidate list indication: "
-				"too short message (%i)", len);
+		netdev_info(usbdev->net, "pmkid candidate list indication: too short message (%i)\n",
+			    len);
 		return;
 	}
 
@@ -2346,18 +2372,16 @@ static void rndis_wlan_pmkid_cand_list_indication(struct usbnet *usbdev,
 			offsetof(struct ndis_80211_status_indication, u);
 
 	if (len < expected_len) {
-		devinfo(usbdev, "pmkid candidate list indication: "
-				"list larger than buffer (%i < %i)",
-				len, expected_len);
+		netdev_info(usbdev->net, "pmkid candidate list indication: list larger than buffer (%i < %i)\n",
+			    len, expected_len);
 		return;
 	}
 
 	cand_list = &indication->u.cand_list;
 
-	devinfo(usbdev, "pmkid candidate list indication: "
-			"version %i, candidates %i",
-			le32_to_cpu(cand_list->version),
-			le32_to_cpu(cand_list->num_candidates));
+	netdev_info(usbdev->net, "pmkid candidate list indication: version %i, candidates %i\n",
+		    le32_to_cpu(cand_list->version),
+		    le32_to_cpu(cand_list->num_candidates));
 
 	if (le32_to_cpu(cand_list->version) != 1)
 		return;
@@ -2366,8 +2390,8 @@ static void rndis_wlan_pmkid_cand_list_indication(struct usbnet *usbdev,
 		struct ndis_80211_pmkid_candidate *cand =
 						&cand_list->candidate_list[i];
 
-		devdbg(usbdev, "cand[%i]: flags: 0x%08x, bssid: %pM",
-				i, le32_to_cpu(cand->flags), cand->bssid);
+		netdev_dbg(usbdev->net, "cand[%i]: flags: 0x%08x, bssid: %pM\n",
+			   i, le32_to_cpu(cand->flags), cand->bssid);
 
 #if 0
 		struct iw_pmkid_cand pcand;
@@ -2398,15 +2422,14 @@ static void rndis_wlan_media_specific_indication(struct usbnet *usbdev,
 	len = le32_to_cpu(msg->length);
 
 	if (len < 8) {
-		devinfo(usbdev, "media specific indication, "
-				"ignore too short message (%i < 8)", len);
+		netdev_info(usbdev->net, "media specific indication, ignore too short message (%i < 8)\n",
+			    len);
 		return;
 	}
 
 	if (offset + len > buflen) {
-		devinfo(usbdev, "media specific indication, "
-				"too large to fit to buffer (%i > %i)",
-				offset + len, buflen);
+		netdev_info(usbdev->net, "media specific indication, too large to fit to buffer (%i > %i)\n",
+			    offset + len, buflen);
 		return;
 	}
 
@@ -2414,13 +2437,13 @@ static void rndis_wlan_media_specific_indication(struct usbnet *usbdev,
 
 	switch (le32_to_cpu(indication->status_type)) {
 	case NDIS_80211_STATUSTYPE_RADIOSTATE:
-		devinfo(usbdev, "radio state indication: %i",
-			le32_to_cpu(indication->u.radio_status));
+		netdev_info(usbdev->net, "radio state indication: %i\n",
+			    le32_to_cpu(indication->u.radio_status));
 		return;
 
 	case NDIS_80211_STATUSTYPE_MEDIASTREAMMODE:
-		devinfo(usbdev, "media stream mode indication: %i",
-			le32_to_cpu(indication->u.media_stream_mode));
+		netdev_info(usbdev->net, "media stream mode indication: %i\n",
+			    le32_to_cpu(indication->u.media_stream_mode));
 		return;
 
 	case NDIS_80211_STATUSTYPE_AUTHENTICATION:
@@ -2432,9 +2455,8 @@ static void rndis_wlan_media_specific_indication(struct usbnet *usbdev,
 		return;
 
 	default:
-		devinfo(usbdev, "media specific indication: "
-				"unknown status type 0x%08x",
-				le32_to_cpu(indication->status_type));
+		netdev_info(usbdev->net, "media specific indication: unknown status type 0x%08x\n",
+			    le32_to_cpu(indication->status_type));
 	}
 }
 
@@ -2451,14 +2473,13 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 			 * and userspace to think that device is
 			 * roaming/reassociating when it isn't.
 			 */
-			devdbg(usbdev, "ignored OID_802_11_ADD_KEY triggered "
-					"'media connect'");
+			netdev_dbg(usbdev->net, "ignored OID_802_11_ADD_KEY triggered 'media connect'\n");
 			return;
 		}
 
 		usbnet_pause_rx(usbdev);
 
-		devinfo(usbdev, "media connect");
+		netdev_info(usbdev->net, "media connect\n");
 
 		/* queue work to avoid recursive calls into rndis_command */
 		set_bit(WORK_LINK_UP, &priv->work_pending);
@@ -2466,7 +2487,7 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 		break;
 
 	case RNDIS_STATUS_MEDIA_DISCONNECT:
-		devinfo(usbdev, "media disconnect");
+		netdev_info(usbdev->net, "media disconnect\n");
 
 		/* queue work to avoid recursive calls into rndis_command */
 		set_bit(WORK_LINK_DOWN, &priv->work_pending);
@@ -2478,8 +2499,8 @@ static void rndis_wlan_indication(struct usbnet *usbdev, void *ind, int buflen)
 		break;
 
 	default:
-		devinfo(usbdev, "indication: 0x%08x",
-				le32_to_cpu(msg->status));
+		netdev_info(usbdev->net, "indication: 0x%08x\n",
+			    le32_to_cpu(msg->status));
 		break;
 	}
 }
@@ -2544,8 +2565,8 @@ static void rndis_device_poller(struct work_struct *work)
 	if (ret == 0)
 		priv->last_qual = level_to_qual(le32_to_cpu(rssi));
 
-	devdbg(usbdev, "dev-poller: OID_802_11_RSSI -> %d, rssi:%d, qual: %d",
-		ret, le32_to_cpu(rssi), level_to_qual(le32_to_cpu(rssi)));
+	netdev_dbg(usbdev->net, "dev-poller: OID_802_11_RSSI -> %d, rssi:%d, qual: %d\n",
+		   ret, le32_to_cpu(rssi), level_to_qual(le32_to_cpu(rssi)));
 
 	/* Workaround transfer stalls on poor quality links.
 	 * TODO: find right way to fix these stalls (as stalls do not happen
@@ -2838,11 +2859,11 @@ static int rndis_wlan_reset(struct usbnet *usbdev)
 	struct rndis_wlan_private *priv = get_rndis_wlan_priv(usbdev);
 	int retval;
 
-	devdbg(usbdev, "rndis_wlan_reset");
+	netdev_dbg(usbdev->net, "%s()\n", __func__);
 
 	retval = rndis_reset(usbdev);
 	if (retval)
-		devwarn(usbdev, "rndis_reset() failed: %d", retval);
+		netdev_warn(usbdev->net, "rndis_reset failed: %d\n", retval);
 
 	/* rndis_reset cleared multicast list, so restore here.
 	   (set_multicast_list() also turns on current packet filter) */
@@ -2860,7 +2881,7 @@ static int rndis_wlan_stop(struct usbnet *usbdev)
 	int retval;
 	__le32 filter;
 
-	devdbg(usbdev, "rndis_wlan_stop");
+	netdev_dbg(usbdev->net, "%s()\n", __func__);
 
 	retval = disassociate(usbdev, false);
 
diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
index 8ce6135..df1e83d 100644
--- a/include/linux/usb/usbnet.h
+++ b/include/linux/usb/usbnet.h
@@ -214,25 +214,4 @@ extern void usbnet_set_msglevel (struct net_device *, u32);
 extern void usbnet_get_drvinfo (struct net_device *, struct ethtool_drvinfo *);
 extern int usbnet_nway_reset(struct net_device *net);
 
-/* messaging support includes the interface name, so it must not be
- * used before it has one ... notably, in minidriver bind() calls.
- */
-#ifdef DEBUG
-#define devdbg(usbnet, fmt, arg...) \
-	printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
-#else
-#define devdbg(usbnet, fmt, arg...) \
-	({ if (0) printk(KERN_DEBUG "%s: " fmt "\n" , (usbnet)->net->name , \
-		## arg); 0; })
-#endif
-
-#define deverr(usbnet, fmt, arg...) \
-	printk(KERN_ERR "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
-#define devwarn(usbnet, fmt, arg...) \
-	printk(KERN_WARNING "%s: " fmt "\n" , (usbnet)->net->name , ## arg)
-
-#define devinfo(usbnet, fmt, arg...) \
-	printk(KERN_INFO "%s: " fmt "\n" , (usbnet)->net->name , ## arg); \
-
-
 #endif /* __LINUX_USB_USBNET_H */
-- 
1.7.0.14.g7e948


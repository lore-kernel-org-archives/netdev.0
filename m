From: Mark Lord <kernel@teksavvy.com>
Subject: [PATCH] drivers/net/usb/asix:  resync from vendor's copy
Date: Wed, 02 Nov 2011 15:36:30 -0400
Message-ID: <4EB19BBE.5050602@teksavvy.com>
References: <4EA89972.5060101@teksavvy.com> <20111026.194045.2019668159403582571.davem@davemloft.net> <4EA8B283.3010105@teksavvy.com> <20111026.221719.2216112919297458522.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------030107060700060006000702"
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ironport2-out.teksavvy.com ([206.248.154.181]:43706 "EHLO
	ironport2-out.pppoe.ca" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751246Ab1KBTgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 15:36:38 -0400
In-Reply-To: <20111026.221719.2216112919297458522.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------030107060700060006000702
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

On 11-10-26 10:17 PM, David Miller wrote:
> From: Mark Lord <kernel@teksavvy.com>
> Date: Wed, 26 Oct 2011 21:23:15 -0400
>
>> Any strong advance objections to replacing the in-kernel version
>> with a (fixed) vendor open source version?
>
> It need to meet the coding etc. standards for inclusion, last
> time I looked at it their driver indeed need a bit of cleaning
> up.
>
> It's a sad situation, they started with the upstream driver and
> just hacked on it however they pleased in their private copy.
> So now we have this huge divergance and no effort on their part
> to rectify things.


Okay, here's a first cut at it for review/comment.
After a round or two of this, I'll submit it more
properly for upstream inclusion.

Let's try and fix the stuff that _needs_ fixing,
but hopefully not be too nit-picky about it.
The in-kernel driver doesn't work for any hardware
I have here, and this one works for all of it.
Lots of others are probably in the same boat.

Patch included inline for comments, and also attached
due to thunderbird's propensity for modifying things..

------------------ snip -------------------

First cut (for review) at updating the in-kernel asix usb/network driver
from the latest vendor GPL version of the driver, obtained from here:

  http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver

The original vendor copy used a local "axusbnet" middleware (rather than "usbnet").
I've converted it back to using "usbnet", made a ton of cosmetic changes
to get it to pass checkpatch.pl, and removed a small amount of code duplication.

It can use more work going forward, but it is important to get it upstream
sooner than later -- the current in-kernel driver fails with many devices,
both old and new.  This updated version works with everything I have available
to test with, and also handles suspend / resume (unlike the in-kernel one).

Signed-off-by: Mark Lord <mlord@pobox.com>

--- linux-3.0/drivers/net/usb/asix.c	2011-10-12 17:59:03.000000000 -0400
+++ linux/drivers/net/usb/asix.c	2011-11-01 19:00:50.051289683 -0400
@@ -20,11 +20,9 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */

-// #define	DEBUG			// error path messages, extra info
-// #define	VERBOSE			// more; success messages
-
 #include <linux/module.h>
 #include <linux/kmod.h>
+#include <linux/sched.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -34,404 +32,117 @@
 #include <linux/usb.h>
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
-#include <linux/slab.h>
-
-#define DRIVER_VERSION "14-Jun-2006"
-static const char driver_name [] = "asix";
+#include "asix.h"

-/* ASIX AX8817X based USB 2.0 Ethernet Devices */
+#define DRIVER_VERSION	"5.0.0"
+static const char driver_name[] = "asix";

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
-		( AX88172_MEDIUM_FD | AX88172_MEDIUM_TX | AX88172_MEDIUM_FC )
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
-	 AX_MEDIUM_RE )
-
-#define AX88772_MEDIUM_DEFAULT	\
-	(AX_MEDIUM_FD | AX_MEDIUM_RFC | \
-	 AX_MEDIUM_TFC | AX_MEDIUM_PS | \
-	 AX_MEDIUM_AC | AX_MEDIUM_RE )
-
-/* AX88772 & AX88178 RX_CTL values */
-#define AX_RX_CTL_SO			0x0080
-#define AX_RX_CTL_AP			0x0020
-#define AX_RX_CTL_AM			0x0010
-#define AX_RX_CTL_AB			0x0008
-#define AX_RX_CTL_SEP			0x0004
-#define AX_RX_CTL_AMALL			0x0002
-#define AX_RX_CTL_PRO			0x0001
-#define AX_RX_CTL_MFB_2048		0x0000
-#define AX_RX_CTL_MFB_4096		0x0100
-#define AX_RX_CTL_MFB_8192		0x0200
-#define AX_RX_CTL_MFB_16384		0x0300
-
-#define AX_DEFAULT_RX_CTL	\
-	(AX_RX_CTL_SO | AX_RX_CTL_AB )
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
-
-#define PHY_MODE_MARVELL	0x0000
-#define MII_MARVELL_LED_CTRL	0x0018
-#define MII_MARVELL_STATUS	0x001b
-#define MII_MARVELL_CTRL	0x0014
-
-#define MARVELL_LED_MANUAL	0x0019
-
-#define MARVELL_STATUS_HWCFG	0x0004
-
-#define MARVELL_CTRL_TXDELAY	0x0002
-#define MARVELL_CTRL_RXDELAY	0x0080
-
-/* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
-struct asix_data {
-	u8 multi_filter[AX_MCAST_FILTER_SIZE];
-	u8 mac_addr[ETH_ALEN];
-	u8 phymode;
-	u8 ledmode;
-	u8 eeprom_len;
-};
+static char driver_version[] =
+	"ASIX USB Ethernet Adapter: v" DRIVER_VERSION \
+	" " __TIME__ " " __DATE__ "\n";
+
+/* configuration of maximum bulk in size */
+static int bsize = AX88772B_MAX_BULKIN_16K;
+module_param(bsize, int, 0);
+MODULE_PARM_DESC(bsize, "Maximum transfer size per bulk");
+
+static void ax88772b_link_reset(struct work_struct *work);
+static void ax88772a_link_reset(struct work_struct *work);
+static void ax88772_link_reset(struct work_struct *work);
+static int ax88772a_phy_powerup(struct usbnet *dev);

-struct ax88172_int_data {
-	__le16 res1;
-	u8 link;
-	__le16 res2;
-	u8 status;
-	__le16 res3;
-} __packed;
+/* ASIX AX8817X based USB 2.0 Ethernet Devices */

-static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+static int ax8817x_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			    u16 size, void *data)
 {
-	void *buf;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "asix_read_cmd() cmd=0x%02x value=0x%04x index=0x%04x
size=%d\n",
-		   cmd, value, index, size);
-
-	buf = kmalloc(size, GFP_KERNEL);
-	if (!buf)
-		goto out;
-
-	err = usb_control_msg(
+	return usb_control_msg(
 		dev->udev,
 		usb_rcvctrlpipe(dev->udev, 0),
 		cmd,
 		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		value,
 		index,
-		buf,
+		data,
 		size,
 		USB_CTRL_GET_TIMEOUT);
-	if (err == size)
-		memcpy(data, buf, size);
-	else if (err >= 0)
-		err = -EINVAL;
-	kfree(buf);
-
-out:
-	return err;
 }

-static int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+static int ax8817x_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			     u16 size, void *data)
 {
-	void *buf = NULL;
-	int err = -ENOMEM;
-
-	netdev_dbg(dev->net, "asix_write_cmd() cmd=0x%02x value=0x%04x index=0x%04x
size=%d\n",
-		   cmd, value, index, size);
-
-	if (data) {
-		buf = kmemdup(data, size, GFP_KERNEL);
-		if (!buf)
-			goto out;
-	}
-
-	err = usb_control_msg(
+	return usb_control_msg(
 		dev->udev,
 		usb_sndctrlpipe(dev->udev, 0),
 		cmd,
 		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		value,
 		index,
-		buf,
+		data,
 		size,
 		USB_CTRL_SET_TIMEOUT);
-	kfree(buf);
-
-out:
-	return err;
 }

-static void asix_async_cmd_callback(struct urb *urb)
+static void ax8817x_async_cmd_callback(struct urb *urb)
 {
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
-	int status = urb->status;

-	if (status < 0)
-		printk(KERN_DEBUG "asix_async_cmd_callback() failed with %d",
-			status);
+	if (urb->status < 0)
+		printk(KERN_DEBUG "ax8817x_async_cmd_callback() failed with %d",
+			urb->status);

 	kfree(req);
 	usb_free_urb(urb);
 }

-static void
-asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
-				    u16 size, void *data)
+static int ax8817x_set_mac_addr(struct net_device *net, void *p)
 {
-	struct usb_ctrlrequest *req;
-	int status;
-	struct urb *urb;
-
-	netdev_dbg(dev->net, "asix_write_cmd_async() cmd=0x%02x value=0x%04x
index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-	if ((urb = usb_alloc_urb(0, GFP_ATOMIC)) == NULL) {
-		netdev_err(dev->net, "Error allocating URB in write_cmd_async!\n");
-		return;
-	}
-
-	if ((req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC)) == NULL) {
-		netdev_err(dev->net, "Failed to allocate memory for control request\n");
-		usb_free_urb(urb);
-		return;
-	}
+	struct usbnet *dev = netdev_priv(net);
+	struct sockaddr *addr = p;

-	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
-	req->bRequest = cmd;
-	req->wValue = cpu_to_le16(value);
-	req->wIndex = cpu_to_le16(index);
-	req->wLength = cpu_to_le16(size);
+	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);

-	usb_fill_control_urb(urb, dev->udev,
-			     usb_sndctrlpipe(dev->udev, 0),
-			     (void *)req, data, size,
-			     asix_async_cmd_callback, req);
+	/* Set the MAC address */
+	return ax8817x_write_cmd(dev, AX88772_CMD_WRITE_NODE_ID,
+			   0, 0, ETH_ALEN, net->dev_addr);

-	if((status = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
-		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
-			   status);
-		kfree(req);
-		usb_free_urb(urb);
-	}
 }

-static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+static void ax8817x_status(struct usbnet *dev, struct urb *urb)
 {
-	u8  *head;
-	u32  header;
-	char *packet;
-	struct sk_buff *ax_skb;
-	u16 size;
-
-	head = (u8 *) skb->data;
-	memcpy(&header, head, sizeof(header));
-	le32_to_cpus(&header);
-	packet = head + sizeof(header);
-
-	skb_pull(skb, 4);
-
-	while (skb->len > 0) {
-		if ((short)(header & 0x0000ffff) !=
-		    ~((short)((header & 0xffff0000) >> 16))) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
-		}
-		/* get the packet length */
-		size = (u16) (header & 0x0000ffff);
-
-		if ((skb->len) - ((size + 1) & 0xfffe) == 0) {
-			u8 alignment = (unsigned long)skb->data & 0x3;
-			if (alignment != 0x2) {
-				/*
-				 * not 16bit aligned so use the room provided by
-				 * the 32 bit header to align the data
-				 *
-				 * note we want 16bit alignment as MAC header is
-				 * 14bytes thus ip header will be aligned on
-				 * 32bit boundary so accessing ipheader elements
-				 * using a cast to struct ip header wont cause
-				 * an unaligned accesses.
-				 */
-				u8 realignment = (alignment + 2) & 0x3;
-				memmove(skb->data - realignment,
-					skb->data,
-					size);
-				skb->data -= realignment;
-				skb_set_tail_pointer(skb, size);
-			}
-			return 2;
-		}
-
-		if (size > dev->net->mtu + ETH_HLEN) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
-				   size);
-			return 0;
-		}
-		ax_skb = skb_clone(skb, GFP_ATOMIC);
-		if (ax_skb) {
-			u8 alignment = (unsigned long)packet & 0x3;
-			ax_skb->len = size;
-
-			if (alignment != 0x2) {
-				/*
-				 * not 16bit aligned use the room provided by
-				 * the 32 bit header to align the data
-				 */
-				u8 realignment = (alignment + 2) & 0x3;
-				memmove(packet - realignment, packet, size);
-				packet -= realignment;
-			}
-			ax_skb->data = packet;
-			skb_set_tail_pointer(ax_skb, size);
-			usbnet_skb_return(dev, ax_skb);
-		} else {
-			return 0;
-		}
-
-		skb_pull(skb, (size + 1) & 0xfffe);
+	struct ax88172_int_data *event;
+	int link;

-		if (skb->len == 0)
-			break;
+	if (urb->actual_length < 8)
+		return;

-		head = (u8 *) skb->data;
-		memcpy(&header, head, sizeof(header));
-		le32_to_cpus(&header);
-		packet = head + sizeof(header);
-		skb_pull(skb, 4);
-	}
+	event = urb->transfer_buffer;
+	link = event->link & 0x01;

-	if (skb->len < 0) {
-		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d\n",
-			   skb->len);
-		return 0;
+	if (netif_carrier_ok(dev->net) != link) {
+		if (link) {
+			netif_carrier_on(dev->net);
+			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+		} else
+			netif_carrier_off(dev->net);
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
-	return 1;
 }

-static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
-					gfp_t flags)
+static void ax88178_status(struct usbnet *dev, struct urb *urb)
 {
-	int padlen;
-	int headroom = skb_headroom(skb);
-	int tailroom = skb_tailroom(skb);
-	u32 packet_len;
-	u32 padbytes = 0xffff0000;
-
-	padlen = ((skb->len + 4) % 512) ? 0 : 4;
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
+	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;

-	if ((skb->len % 512) == 0) {
-		cpu_to_le32s(&padbytes);
-		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
-		skb_put(skb, sizeof(padbytes));
-	}
-	return skb;
+	if (priv->EepromData == PHY_MODE_MAC_TO_MAC_GMII)
+		return;
+	ax8817x_status(dev, urb);
 }

-static void asix_status(struct usbnet *dev, struct urb *urb)
+static void ax88772_status(struct usbnet *dev, struct urb *urb)
 {
 	struct ax88172_int_data *event;
+	struct ax88772_data *priv = (struct ax88772_data *)dev->driver_priv;
 	int link;

 	if (urb->actual_length < 8)
@@ -439,285 +150,538 @@

 	event = urb->transfer_buffer;
 	link = event->link & 0x01;
+
 	if (netif_carrier_ok(dev->net) != link) {
 		if (link) {
 			netif_carrier_on(dev->net);
-			usbnet_defer_kevent (dev, EVENT_LINK_RESET );
-		} else
+			priv->Event = AX_SET_RX_CFG;
+		} else {
 			netif_carrier_off(dev->net);
-		netdev_dbg(dev->net, "Link Status is: %d\n", link);
+			if (priv->Event == AX_NOP) {
+				priv->Event = PHY_POWER_DOWN;
+				priv->TickToExpire = 25;
+			}
+		}
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
-}

-static inline int asix_set_sw_mii(struct usbnet *dev)
-{
-	int ret;
-	ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to enable software MII access\n");
-	return ret;
+	if (priv->Event)
+		queue_work(priv->ax_work, &priv->check_link);
 }

-static inline int asix_set_hw_mii(struct usbnet *dev)
+static void ax88772a_status(struct usbnet *dev, struct urb *urb)
 {
-	int ret;
-	ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to enable hardware MII access\n");
-	return ret;
-}
+	struct ax88172_int_data *event;
+	struct ax88772a_data *priv = (struct ax88772a_data *)dev->driver_priv;
+	int link;
+	int PowSave = (priv->EepromData >> 14);

-static inline int asix_get_phy_addr(struct usbnet *dev)
-{
-	u8 buf[2];
-	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
+	if (urb->actual_length < 8)
+		return;

-	netdev_dbg(dev->net, "asix_get_phy_addr()\n");
+	event = urb->transfer_buffer;
+	link = event->link & 0x01;

-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
-		goto out;
+	if (netif_carrier_ok(dev->net) != link) {
+
+		if (link) {
+			netif_carrier_on(dev->net);
+			priv->Event = AX_SET_RX_CFG;
+		} else if ((PowSave == 0x3) || (PowSave == 0x1)) {
+			netif_carrier_off(dev->net);
+			if (priv->Event == AX_NOP) {
+				priv->Event = CHK_CABLE_EXIST;
+				priv->TickToExpire = 14;
+			}
+		} else {
+			netif_carrier_off(dev->net);
+			priv->Event = AX_NOP;
+		}
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
-	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
-		   *((__le16 *)buf));
-	ret = buf[1];

-out:
-	return ret;
+	if (priv->Event)
+		queue_work(priv->ax_work, &priv->check_link);
 }

-static int asix_sw_reset(struct usbnet *dev, u8 flags)
+static void ax88772b_status(struct usbnet *dev, struct urb *urb)
 {
-	int ret;
-
-        ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to send software reset: %02x\n", ret);
-
-	return ret;
-}
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+	struct ax88172_int_data *event;
+	int link;

-static u16 asix_read_rx_ctl(struct usbnet *dev)
-{
-	__le16 v;
-	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
+	if (urb->actual_length < 8)
+		return;

-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading RX_CTL register: %02x\n", ret);
-		goto out;
+	event = urb->transfer_buffer;
+	link = event->link & AX_INT_PPLS_LINK;
+	if (netif_carrier_ok(dev->net) != link) {
+		if (link) {
+			netif_carrier_on(dev->net);
+			priv->Event = AX_SET_RX_CFG;
+		} else {
+			netif_carrier_off(dev->net);
+			priv->time_to_chk = jiffies;
+		}
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
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

-	return ret;
-}
+	if (!link) {
+		int no_cable = (event->link & AX_INT_CABOFF_UNPLUG) ? 1 : 0;

-static u16 asix_read_medium_status(struct usbnet *dev)
-{
-	__le16 v;
-	int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
+		if (no_cable) {
+			if ((priv->psc &
+			    (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1)) &&
+			     !priv->pw_enabled) {
+				/*
+				 * AX88772B already entered power saving state
+				 */
+				priv->pw_enabled = 1;
+			}

-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading Medium Status register: %02x\n",
-			   ret);
-		goto out;
+		} else {
+			/* AX88772B resumed from power saving state */
+			if (priv->pw_enabled ||
+				(jiffies >
+				   (priv->time_to_chk + AX88772B_WATCHDOG))) {
+				if (priv->pw_enabled)
+					priv->pw_enabled = 0;
+				priv->Event = PHY_POWER_UP;
+				priv->time_to_chk = jiffies;
+			}
+		}
 	}
-	ret = le16_to_cpu(v);
-out:
-	return ret;
+
+	if (priv->Event)
+		queue_work(priv->ax_work, &priv->check_link);
 }

-static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
+static void
+ax8817x_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+				    u16 size, void *data)
 {
-	int ret;
-
-	netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n", mode);
-	ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
-			   mode, ret);
+	struct usb_ctrlrequest *req;
+	int status;
+	struct urb *urb;

-	return ret;
-}
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (urb == NULL) {
+		netdev_err(dev->net, "%s: usb_alloc_urb() failed\n", __func__);
+		return;
+	}

-static int asix_write_gpio(struct usbnet *dev, u16 value, int sleep)
-{
-	int ret;
+	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
+	if (req == NULL) {
+		netdev_err(dev->net, "%s: kmalloc() failed\n", __func__);
+		usb_free_urb(urb);
+		return;
+	}

-	netdev_dbg(dev->net, "asix_write_gpio() - value = 0x%04x\n", value);
-	ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to write GPIO value 0x%04x: %02x\n",
-			   value, ret);
+	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
+	req->bRequest = cmd;
+	req->wValue = cpu_to_le16(value);
+	req->wIndex = cpu_to_le16(index);
+	req->wLength = cpu_to_le16(size);

-	if (sleep)
-		msleep(sleep);
+	usb_fill_control_urb(urb, dev->udev,
+			     usb_sndctrlpipe(dev->udev, 0),
+			     (void *)req, data, size,
+			     ax8817x_async_cmd_callback, req);

-	return ret;
+	status = usb_submit_urb(urb, GFP_ATOMIC);
+	if (status < 0) {
+		netdev_err(dev->net, "%s: usb_submit_urb() failed, err=%d\n",
+						__func__, status);
+		kfree(req);
+		usb_free_urb(urb);
+	}
 }

-/*
- * AX88772 & AX88178 have a 16-bit RX_CTL value
- */
-static void asix_set_multicast(struct net_device *net)
+static void ax8817x_set_multicast(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u16 rx_ctl = AX_DEFAULT_RX_CTL;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	u8 rx_ctl = AX_RX_CTL_START | AX_RX_CTL_AB;
+	int mc_count;
+
+	mc_count = netdev_mc_count(net);

 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= AX_RX_CTL_PRO;
-	} else if (net->flags & IFF_ALLMULTI ||
-		   netdev_mc_count(net) > AX_MAX_MCAST) {
+	} else if (net->flags & IFF_ALLMULTI
+		   || mc_count > AX_MAX_MCAST) {
 		rx_ctl |= AX_RX_CTL_AMALL;
-	} else if (netdev_mc_empty(net)) {
+	} else if (mc_count == 0) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct netdev_hw_addr *ha;
 		u32 crc_bits;
-
+		struct netdev_hw_addr *ha;
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
-
-		/* Build the multicast hash filter. */
 		netdev_for_each_mc_addr(ha, net) {
 			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |=
-			    1 << (crc_bits & 7);
+				1 << (crc_bits & 7);
 		}
-
-		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
+		ax8817x_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
 				   AX_MCAST_FILTER_SIZE, data->multi_filter);

 		rx_ctl |= AX_RX_CTL_AM;
 	}

-	asix_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+	ax8817x_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
 }

-static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
+static void ax88772b_set_multicast(struct net_device *net)
 {
-	struct usbnet *dev = netdev_priv(netdev);
-	__le16 res;
-
-	mutex_lock(&dev->phy_mutex);
-	asix_set_sw_mii(dev);
-	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
-				(__u16)loc, 2, &res);
-	asix_set_hw_mii(dev);
-	mutex_unlock(&dev->phy_mutex);
-
-	netdev_dbg(dev->net, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x,
returns=0x%04x\n",
-		   phy_id, loc, le16_to_cpu(res));
-
-	return le16_to_cpu(res);
-}
+	struct usbnet *dev = netdev_priv(net);
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	u16 rx_ctl = (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_HEADER_DEFAULT);
+	int mc_count;

-static void
-asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
-{
-	struct usbnet *dev = netdev_priv(netdev);
-	__le16 res = cpu_to_le16(val);
+	mc_count = netdev_mc_count(net);

-	netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
-		   phy_id, loc, val);
-	mutex_lock(&dev->phy_mutex);
-	asix_set_sw_mii(dev);
-	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
-	asix_set_hw_mii(dev);
-	mutex_unlock(&dev->phy_mutex);
-}
+	if (net->flags & IFF_PROMISC) {
+		rx_ctl |= AX_RX_CTL_PRO;
+	} else if (net->flags & IFF_ALLMULTI
+		   || mc_count > AX_MAX_MCAST) {
+		rx_ctl |= AX_RX_CTL_AMALL;
+	} else if (mc_count == 0) {
+		/* just broadcast and directed */
+	} else {
+		/* We use the 20 byte dev->data
+		 * for our 8 byte filter buffer
+		 * to avoid allocating memory that
+		 * is tricky to free later */
+		u32 crc_bits;
+
+		struct netdev_hw_addr *ha;
+		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
+		netdev_for_each_mc_addr(ha, net) {
+			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
+			data->multi_filter[crc_bits >> 3] |=
+				1 << (crc_bits & 7);
+		}
+		ax8817x_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
+				   AX_MCAST_FILTER_SIZE, data->multi_filter);
+
+		rx_ctl |= AX_RX_CTL_AM;
+	}
+
+	ax8817x_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+}

-/* Get the PHY Identifier from the PHYSID1 & PHYSID2 MII registers */
-static u32 asix_get_phyid(struct usbnet *dev)
+static int ax8817x_mdio_read(struct net_device *netdev, int phy_id, int loc)
 {
-	int phy_reg;
-	u32 phy_id;
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+	u16 ret;

-	phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
-	if (phy_reg < 0)
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
 		return 0;

-	phy_id = (phy_reg & 0xffff) << 16;
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id, (__u16)loc, 2, res);
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+
+	ret = *res & 0xffff;
+	kfree(res);
+
+	return ret;
+}
+
+static int
+ax8817x_swmii_mdio_read(struct net_device *netdev, int phy_id, int loc)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+	u16 ret;

-	phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID2);
-	if (phy_reg < 0)
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
 		return 0;

-	phy_id |= (phy_reg & 0xffff);
+	ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
+				(__u16)loc, 2, res);

-	return phy_id;
+	ret = *res & 0xffff;
+	kfree(res);
+
+	return ret;
+}
+
+/* same as above, but converts resulting value to cpu byte order */
+static int ax8817x_mdio_read_le(struct net_device *netdev, int phy_id, int loc)
+{
+	return le16_to_cpu(ax8817x_mdio_read(netdev, phy_id, loc));
+}
+
+static int
+ax8817x_swmii_mdio_read_le(struct net_device *netdev, int phy_id, int loc)
+{
+	return le16_to_cpu(ax8817x_swmii_mdio_read(netdev, phy_id, loc));
 }

 static void
-asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+ax8817x_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
 {
-	struct usbnet *dev = netdev_priv(net);
-	u8 opt;
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
+		return;
+	*res = val;
+
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)loc, 2, res);
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+
+	kfree(res);
+}

-	if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
-		wolinfo->supported = 0;
-		wolinfo->wolopts = 0;
+static void ax8817x_swmii_mdio_write(struct net_device *netdev,
+			int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
+		return;
+	*res = val;
+
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)loc, 2, res);
+
+	kfree(res);
+}
+
+static void
+ax88772b_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
 		return;
+	*res = val;
+
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)loc, 2, res);
+
+	if (loc == MII_ADVERTISE) {
+		*res = cpu_to_le16(BMCR_ANENABLE | BMCR_ANRESTART);
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)MII_BMCR, 2, res);
 	}
-	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
-	wolinfo->wolopts = 0;
-	if (opt & AX_MONITOR_MODE) {
-		if (opt & AX_MONITOR_LINK)
-			wolinfo->wolopts |= WAKE_PHY;
-		if (opt & AX_MONITOR_MAGIC)
-			wolinfo->wolopts |= WAKE_MAGIC;
+
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+
+	kfree(res);
+}
+
+/* same as above, but converts new value to le16 byte order before writing */
+static void
+ax8817x_mdio_write_le(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	ax8817x_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
+}
+
+static void ax8817x_swmii_mdio_write_le(struct net_device *netdev,
+			int phy_id, int loc, int val)
+{
+	ax8817x_swmii_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
+}
+
+static void
+ax88772b_mdio_write_le(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	ax88772b_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
+}
+
+static int asix_write_medium_mode(struct usbnet *dev, u16 value)
+{
+	int ret;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE,
+						value, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "%s (0x%04x) failed, err=%d\n",
+						__func__, value, ret);
+	return ret;
+}
+
+static int ax88772_suspend(struct usb_interface *intf,
+			pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	u16 *medium;
+
+	medium = kmalloc(2, GFP_ATOMIC);
+	if (!medium)
+		return usbnet_suspend(intf, message);
+
+	ax8817x_read_cmd(dev, AX_CMD_READ_MEDIUM_MODE, 0, 0, 2, medium);
+	asix_write_medium_mode(dev, *medium & ~AX88772_MEDIUM_RX_ENABLE);
+
+	kfree(medium);
+	return usbnet_suspend(intf, message);
+}
+
+static int ax88772b_suspend(struct usb_interface *intf,
+			pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+	u16 *tmp16;
+	u8 *opt;
+
+	tmp16 = kmalloc(2, GFP_ATOMIC);
+	if (!tmp16)
+		return usbnet_suspend(intf, message);
+	opt = (u8 *)tmp16;
+
+	ax8817x_read_cmd(dev, AX_CMD_READ_MEDIUM_MODE, 0, 0, 2, tmp16);
+	asix_write_medium_mode(dev, *tmp16 & ~AX88772_MEDIUM_RX_ENABLE);
+
+	ax8817x_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, opt);
+	if (!(*opt & AX_MONITOR_LINK) && !(*opt & AX_MONITOR_MAGIC)) {
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+			AX_SWRESET_IPRL | AX_SWRESET_IPPD, 0, 0, NULL);
+	} else {
+
+		if (priv->psc & AX_SWRESET_WOLLP) {
+			*tmp16 = ax8817x_mdio_read_le(dev->net,
+					dev->mii.phy_id, MII_BMCR);
+			ax8817x_mdio_write_le(dev->net, dev->mii.phy_id,
+					MII_BMCR, *tmp16 | BMCR_ANENABLE);
+
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | priv->psc, 0, 0, NULL);
+		}
+
+		if (priv->psc &
+		    (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1)) {
+			*opt |= AX_MONITOR_LINK;
+			ax8817x_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
+					*opt, 0, 0, NULL);
+		}
+	}
+
+	kfree(tmp16);
+	return usbnet_suspend(intf, message);
+}
+
+static int ax88772_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+
+	netif_carrier_off(dev->net);
+	return usbnet_resume(intf);
+}
+
+static int ax88772b_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (priv->psc & AX_SWRESET_WOLLP) {
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | (priv->psc & 0x7FFF),
+				0, 0, NULL);
 	}
+	if (priv->psc & (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1))
+		ax88772a_phy_powerup(dev);
+	netif_carrier_off(dev->net);
+	return usbnet_resume(intf);
+}
+
+static int ax88172_link_reset(struct usbnet *dev)
+{
+	u16 lpa;
+	u16 adv;
+	u16 res;
+	u8 mode;
+
+	mode = AX_MEDIUM_TX_ABORT_ALLOW | AX_MEDIUM_FLOW_CONTROL_EN;
+	lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
+	adv = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_ADVERTISE);
+	res = mii_nway_result(lpa|adv);
+	if (res & LPA_DUPLEX)
+		mode |= AX_MEDIUM_FULL_DUPLEX;
+	asix_write_medium_mode(dev, mode);
+	return 0;
+}
+
+static void
+ax8817x_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 *opt;
+
+	wolinfo->supported = 0;
+	wolinfo->wolopts = 0;
+
+	opt = kmalloc(1, GFP_KERNEL);
+	if (!opt)
+		return;
+
+	if (ax8817x_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, opt) < 0)
+		return;
+
+	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
+
+	if (*opt & AX_MONITOR_LINK)
+		wolinfo->wolopts |= WAKE_PHY;
+	if (*opt & AX_MONITOR_MAGIC)
+		wolinfo->wolopts |= WAKE_MAGIC;
+
+	kfree(opt);
 }

 static int
-asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+ax8817x_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
 {
 	struct usbnet *dev = netdev_priv(net);
-	u8 opt = 0;
+	u8 *opt;
+
+	opt = kmalloc(1, GFP_KERNEL);
+	if (!opt)
+		return -ENOMEM;

+	*opt = 0;
 	if (wolinfo->wolopts & WAKE_PHY)
-		opt |= AX_MONITOR_LINK;
+		*opt |= AX_MONITOR_LINK;
 	if (wolinfo->wolopts & WAKE_MAGIC)
-		opt |= AX_MONITOR_MAGIC;
-	if (opt != 0)
-		opt |= AX_MONITOR_MODE;
+		*opt |= AX_MONITOR_MAGIC;

-	if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
-			      opt, 0, 0, NULL) < 0)
-		return -EINVAL;
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE, *opt, 0, 0, NULL);

+	kfree(opt);
 	return 0;
 }

-static int asix_get_eeprom_len(struct net_device *net)
+static int ax8817x_get_eeprom_len(struct net_device *net)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	return data->eeprom_len;
+	return AX_EEPROM_LEN;
 }

-static int asix_get_eeprom(struct net_device *net,
+static int ax8817x_get_eeprom(struct net_device *net,
 			      struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct usbnet *dev = netdev_priv(net);
-	__le16 *ebuf = (__le16 *)data;
+	u16 *ebuf = (u16 *)data;
 	int i;

 	/* Crude hack to ensure that we don't overwrite memory
@@ -729,862 +693,2452 @@
 	eeprom->magic = AX_EEPROM_MAGIC;

 	/* ax8817x returns 2 bytes from eeprom on read */
-	for (i=0; i < eeprom->len / 2; i++) {
-		if (asix_read_cmd(dev, AX_CMD_READ_EEPROM,
+	for (i = 0; i < eeprom->len / 2; i++) {
+		if (ax8817x_read_cmd(dev, AX_CMD_READ_EEPROM,
 			eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
 			return -EINVAL;
 	}
 	return 0;
 }

-static void asix_get_drvinfo (struct net_device *net,
+static void ax8817x_get_drvinfo(struct net_device *net,
 				 struct ethtool_drvinfo *info)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
 	/* Inherit standard device info */
 	usbnet_get_drvinfo(net, info);
-	strncpy (info->driver, driver_name, sizeof info->driver);
-	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
-	info->eedump_len = data->eeprom_len;
+	info->eedump_len = 0x3e;
 }

-static u32 asix_get_link(struct net_device *net)
+static int ax8817x_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-
-	return mii_link_ok(&dev->mii);
+	return mii_ethtool_gset(&dev->mii, cmd);
 }

-static int asix_ioctl (struct net_device *net, struct ifreq *rq, int cmd)
+static int ax8817x_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-
-	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
+	return mii_ethtool_sset(&dev->mii, cmd);
 }

-static int asix_set_mac_address(struct net_device *net, void *p)
+/*
+ * We need to override some ethtool_ops so we require our
+ * own structure so we don't interfere with other usbnet
+ * devices that may be connected at the same time.
+ */
+static struct ethtool_ops ax8817x_ethtool_ops = {
+	.get_drvinfo		= ax8817x_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_msglevel		= usbnet_get_msglevel,
+	.set_msglevel		= usbnet_set_msglevel,
+	.get_wol		= ax8817x_get_wol,
+	.set_wol		= ax8817x_set_wol,
+	.get_eeprom_len		= ax8817x_get_eeprom_len,
+	.get_eeprom		= ax8817x_get_eeprom,
+	.get_settings		= ax8817x_get_settings,
+	.set_settings		= ax8817x_set_settings,
+};
+
+static int ax8817x_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	struct sockaddr *addr = p;
-
-	if (netif_running(net))
-		return -EBUSY;
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;

-	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
-
-	/* We use the 20 byte dev->data
-	 * for our 6 byte mac buffer
-	 * to avoid allocating memory that
-	 * is tricky to free later */
-	memcpy(data->mac_addr, addr->sa_data, ETH_ALEN);
-	asix_write_cmd_async(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
-							data->mac_addr);
-
-	return 0;
+	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
 }

-/* We need to override some ethtool_ops so we require our
-   own structure so we don't interfere with other usbnet
-   devices that may be connected at the same time. */
-static const struct ethtool_ops ax88172_ethtool_ops = {
-	.get_drvinfo		= asix_get_drvinfo,
-	.get_link		= asix_get_link,
-	.get_msglevel		= usbnet_get_msglevel,
-	.set_msglevel		= usbnet_set_msglevel,
-	.get_wol		= asix_get_wol,
-	.set_wol		= asix_set_wol,
-	.get_eeprom_len		= asix_get_eeprom_len,
-	.get_eeprom		= asix_get_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
-	.nway_reset		= usbnet_nway_reset,
+static const struct net_device_ops ax88x72_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_do_ioctl		= ax8817x_ioctl,
+	.ndo_set_mac_address	= ax8817x_set_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list	= ax8817x_set_multicast,
 };

-static void ax88172_set_multicast(struct net_device *net)
+static int asix_read_mac(struct usbnet *dev, u8 op)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u8 rx_ctl = 0x8c;
+	u8 *buf;
+	int ret, len = ETH_ALEN;

-	if (net->flags & IFF_PROMISC) {
-		rx_ctl |= 0x01;
-	} else if (net->flags & IFF_ALLMULTI ||
-		   netdev_mc_count(net) > AX_MAX_MCAST) {
-		rx_ctl |= 0x02;
-	} else if (netdev_mc_empty(net)) {
-		/* just broadcast and directed */
+	buf = kzalloc(len, GFP_KERNEL);
+	if (!buf) {
+		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
+		return -ENOMEM;
+	}
+	ret = ax8817x_read_cmd(dev, op, 0, 0, len, buf);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s failed, err=%d\n", __func__, ret);
 	} else {
-		/* We use the 20 byte dev->data
-		 * for our 8 byte filter buffer
-		 * to avoid allocating memory that
-		 * is tricky to free later */
-		struct netdev_hw_addr *ha;
-		u32 crc_bits;
+		memcpy(dev->net->dev_addr, buf, len);
+		ret = 0;
+	}
+	kfree(buf);
+	return ret;
+}

-		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
+static int asix_read_phyid(struct usbnet *dev, u8 op)
+{
+	u8 *buf;
+	int ret, len = 2;

-		/* Build the multicast hash filter. */
-		netdev_for_each_mc_addr(ha, net) {
-			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
-			data->multi_filter[crc_bits >> 3] |=
-			    1 << (crc_bits & 7);
-		}
+	buf = kzalloc(len, GFP_KERNEL);
+	if (!buf) {
+		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
+		return -ENOMEM;
+	}
+	ret = ax8817x_read_cmd(dev, op, 0, 0, len, buf);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s failed, err=%d\n", __func__, ret);
+	} else if (ret < len) {
+		netdev_err(dev->net, "%s read only %d/%d bytes\n",
+						__func__, ret, len);
+		ret = -EIO;
+	} else {
+		dev->mii.phy_id = buf[1];
+		ret = 0;
+	}
+	kfree(buf);
+	return ret;
+}

-		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
-				   AX_MCAST_FILTER_SIZE, data->multi_filter);
+static int asix_read_eeprom_le16(struct usbnet *dev, u8 offset, u16 *data)
+{
+	u16 *buf;
+	int ret, len = 2;

-		rx_ctl |= 0x10;
+	buf = kzalloc(len, GFP_KERNEL);
+	if (!buf) {
+		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
+		return -ENOMEM;
 	}

-	asix_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+	ret = ax8817x_read_cmd(dev, AX_CMD_READ_EEPROM, offset, 0, len, buf);
+	if (ret != 2) {
+		netdev_err(dev->net, "%s failed offset 0x%02x, err=%d\n",
+						__func__, offset, ret);
+	} else {
+		le16_to_cpus(buf);
+		*data = *buf;
+		ret = 0;
+	}
+	kfree(buf);
+	return ret;
 }

-static int ax88172_link_reset(struct usbnet *dev)
+static int asix_read_mac_from_eeprom(struct usbnet *dev)
 {
-	u8 mode;
-	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+	u16 buf[ETH_ALEN / 2];
+	int i, ret;

-	mii_check_media(&dev->mii, 1, 1);
-	mii_ethtool_gset(&dev->mii, &ecmd);
-	mode = AX88172_MEDIUM_DEFAULT;
+	memset(buf, 0, sizeof(buf));
+	for (i = 0; i < ETH_ALEN; i += 2) {
+		ret = asix_read_eeprom_le16(dev, i + 4, buf + i);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s failed\n", __func__);
+			return ret;
+		}
+	}
+	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	return 0;
+}

-	if (ecmd.duplex != DUPLEX_FULL)
-		mode |= ~AX88172_MEDIUM_FD;
+static int asix_phy_select(struct usbnet *dev, u16 physel)
+{
+	int ret;

-	netdev_dbg(dev->net, "ax88172_link_reset() speed: %u duplex: %d setting mode
to 0x%04x\n",
-		   ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_PHY_SELECT, physel, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "%s (0x%04x) failed, err=%d\n",
+						__func__, physel, ret);
+	return ret;
+}

-	asix_write_medium_mode(dev, mode);
+static int asix_write_gpio(struct usbnet *dev, unsigned int wait, u16 value)
+{
+	int ret;

+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s (0x%x) failed\n", __func__, value);
+		return ret;
+	}
+	if (!wait)
+		wait = 5;
+	if (wait < 20)
+		usleep_range(wait * 1000, wait * (1000 * 2));
+	else
+		msleep(wait);
 	return 0;
 }

-static const struct net_device_ops ax88172_netdev_ops = {
-	.ndo_open		= usbnet_open,
-	.ndo_stop		= usbnet_stop,
-	.ndo_start_xmit		= usbnet_start_xmit,
-	.ndo_tx_timeout		= usbnet_tx_timeout,
-	.ndo_change_mtu		= usbnet_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_do_ioctl		= asix_ioctl,
-	.ndo_set_multicast_list = ax88172_set_multicast,
-};
-
-static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
+static int ax8817x_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret = 0;
-	u8 buf[ETH_ALEN];
 	int i;
 	unsigned long gpio_bits = dev->driver_info->data;
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	data->eeprom_len = AX88172_EEPROM_LEN;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;

-	usbnet_get_endpoints(dev,intf);
+	usbnet_get_endpoints(dev, intf);

 	/* Toggle the GPIOs in a manufacturer/model specific way */
 	for (i = 2; i >= 0; i--) {
-		if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS,
-					(gpio_bits >> (i * 8)) & 0xff, 0, 0,
-					NULL)) < 0)
-			goto out;
-		msleep(5);
+		ret = asix_write_gpio(dev, 0, (gpio_bits >> (i * 8)) & 0xff);
+		if (ret)
+			goto err_out;
 	}

-	if ((ret = asix_write_rx_ctl(dev, 0x80)) < 0)
-		goto out;
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x80, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: WRITE_RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}

 	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
-		dbg("read AX_CMD_READ_NODE_ID failed: %d", ret);
-		goto out;
-	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	ret = asix_read_mac(dev, AX_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;

 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = asix_mdio_read;
-	dev->mii.mdio_write = asix_mdio_write;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
 	dev->mii.phy_id_mask = 0x3f;
 	dev->mii.reg_num_mask = 0x1f;
-	dev->mii.phy_id = asix_get_phy_addr(dev);
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax8817x_ethtool_ops;

-	dev->net->netdev_ops = &ax88172_netdev_ops;
-	dev->net->ethtool_ops = &ax88172_ethtool_ops;
+	/* Register suspend and resume functions */
+	data->suspend = usbnet_suspend;
+	data->resume = usbnet_resume;

-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
 	mii_nway_restart(&dev->mii);

+	printk(KERN_INFO "%s\n", driver_version);
 	return 0;

-out:
+err_out:
 	return ret;
 }

-static const struct ethtool_ops ax88772_ethtool_ops = {
-	.get_drvinfo		= asix_get_drvinfo,
-	.get_link		= asix_get_link,
+static struct ethtool_ops ax88772_ethtool_ops = {
+	.get_drvinfo		= ax8817x_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= usbnet_get_msglevel,
 	.set_msglevel		= usbnet_set_msglevel,
-	.get_wol		= asix_get_wol,
-	.set_wol		= asix_set_wol,
-	.get_eeprom_len		= asix_get_eeprom_len,
-	.get_eeprom		= asix_get_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
-	.nway_reset		= usbnet_nway_reset,
+	.get_wol		= ax8817x_get_wol,
+	.set_wol		= ax8817x_set_wol,
+	.get_eeprom_len		= ax8817x_get_eeprom_len,
+	.get_eeprom		= ax8817x_get_eeprom,
+	.get_settings		= ax8817x_get_settings,
+	.set_settings		= ax8817x_set_settings,
 };

-static int ax88772_link_reset(struct usbnet *dev)
+static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 {
-	u16 mode;
-	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+	int ret;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88772_data *priv;

-	mii_check_media(&dev->mii, 1, 1);
-	mii_ethtool_gset(&dev->mii, &ecmd);
-	mode = AX88772_MEDIUM_DEFAULT;
+	usbnet_get_endpoints(dev, intf);

-	if (ethtool_cmd_speed(&ecmd) != SPEED_100)
-		mode &= ~AX_MEDIUM_PS;
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;

-	if (ecmd.duplex != DUPLEX_FULL)
-		mode &= ~AX_MEDIUM_FD;
+	priv->ax_work = create_singlethread_workqueue("ax88772");
+	if (!priv->ax_work) {
+		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
+		kfree(priv);
+		return -ENOMEM;
+	}

-	netdev_dbg(dev->net, "ax88772_link_reset() speed: %u duplex: %d setting mode
to 0x%04x\n",
-		   ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
+	priv->dev = dev;
+	INIT_WORK(&priv->check_link, ax88772_link_reset);

-	asix_write_medium_mode(dev, mode);
+	/* reload eeprom data */
+	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE|AXGPIOS_GPO2|AXGPIOS_GPO2EN);
+	if (ret)
+		goto err_out;

-	return 0;
-}
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;

-static const struct net_device_ops ax88772_netdev_ops = {
-	.ndo_open		= usbnet_open,
-	.ndo_stop		= usbnet_stop,
-	.ndo_start_xmit		= usbnet_start_xmit,
-	.ndo_tx_timeout		= usbnet_tx_timeout,
-	.ndo_change_mtu		= usbnet_change_mtu,
-	.ndo_set_mac_address 	= asix_set_mac_address,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_do_ioctl		= asix_ioctl,
-	.ndo_set_multicast_list = asix_set_multicast,
-};
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;
+	if (dev->mii.phy_id == 0x10) {
+		ret = asix_phy_select(dev, 0x0001);
+		if (ret < 0)
+			goto err_out;
+
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to power down PHY"
+						", err=%d\n", __func__, ret);
+			goto err_out;
+		}

-static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
-{
-	int ret, embd_phy;
-	u16 rx_ctl;
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u8 buf[ETH_ALEN];
-	u32 phyid;
-
-	data->eeprom_len = AX88772_EEPROM_LEN;
-
-	usbnet_get_endpoints(dev,intf);
-
-	if ((ret = asix_write_gpio(dev,
-			AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5)) < 0)
-		goto out;
-
-	/* 0x10 is the phy id of the embedded 10/100 ethernet phy */
-	embd_phy = ((asix_get_phy_addr(dev) & 0x1f) == 0x10 ? 1 : 0);
-	if ((ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT,
-				embd_phy, 0, 0, NULL)) < 0) {
-		dbg("Select PHY #1 failed: %d", ret);
-		goto out;
-	}
+		msleep(150);
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_CLEAR, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: SW_RESET failed, err=%d\n",
+								__func__, ret);
+			goto err_out;
+		}

-	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL)) < 0)
-		goto out;
+		msleep(150);
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to set PHY reset "
+					"control, err=%d\n", __func__, ret);
+			goto err_out;
+		}
+	} else {
+		ret = asix_phy_select(dev, 0x0000);
+		if (ret < 0)
+			goto err_out;
+
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to power down "
+				"internal PHY, err=%d\n", __func__, ret);
+			goto err_out;
+		}
+	}

 	msleep(150);
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_CLEAR)) < 0)
-		goto out;
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x0000, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: Failed to reset RX_CTL, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}

-	msleep(150);
-	if (embd_phy) {
-		if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
-			goto out;
-	}
-	else {
-		if ((ret = asix_sw_reset(dev, AX_SWRESET_PRTE)) < 0)
-			goto out;
+	/* Get the MAC address */
+	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: Failed to enable software MII"
+					", err=%d\n", __func__, ret);
+		goto err_out;
 	}

-	msleep(150);
-	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x after software reset", rx_ctl);
-	if ((ret = asix_write_rx_ctl(dev, 0x0000)) < 0)
-		goto out;
+	if (dev->mii.phy_id == 0x10) {
+		ret = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 2);
+		if (ret != 0x003b) {
+			netdev_err(dev->net, "%s: PHY reg 2 not 0x3b00: 0x%x\n",
+							__func__, ret);
+			goto err_out;
+		}
+
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to set "
+				"external PHY reset pin level, err=%d\n",
+				__func__, ret);
+			goto err_out;
+		}
+		msleep(150);
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to set "
+				"internal/external PHY reset control, err=%d\n",
+				__func__, ret);
+			goto err_out;
+		}
+		msleep(150);
+	}
+
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772_suspend;
+	data->resume = ax88772_resume;
+
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+					ADVERTISE_ALL | ADVERTISE_CSMA);
+
+	mii_nway_restart(&dev->mii);
+	priv->autoneg_start = jiffies;
+	priv->Event = WAIT_AUTONEG_COMPLETE;
+
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT << 8,
+			AX88772_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: WRITE_IPG0/1/2 failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: SET_HW_MII failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x0088, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: WRITE_RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
+	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
+		/*
+		 * hard_mtu  is still the default;
+		 *  the device does not support jumbo eth frames
+		 */
+		dev->rx_urb_size = 2048;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return 0;
+
+err_out:
+	destroy_workqueue(priv->ax_work);
+	kfree(priv);
+	return ret;
+}
+
+static void ax88772_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88772_data *priv = (struct ax88772_data *)dev->driver_priv;
+
+	if (priv) {
+
+		flush_workqueue(priv->ax_work);
+		destroy_workqueue(priv->ax_work);
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+
+		/* Power down PHY */
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int ax88772a_phy_powerup(struct usbnet *dev)
+{
+	int ret;
+	/* set the embedded Ethernet PHY in power-down state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_IPRL, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: power down PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	msleep(20); /* was 10ms */
+
+
+	/* set the embedded Ethernet PHY in power-up state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_IPRL,
+							0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	msleep(600);
+
+	/* set the embedded Ethernet PHY in reset state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_CLEAR,
+							0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: power up PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	/* set the embedded Ethernet PHY in power-up state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_IPRL,
+							0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: second reset PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int ax88772a_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret = -EIO;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88772a_data *priv;
+
+	usbnet_get_endpoints(dev, intf);
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
+
+	priv->ax_work = create_singlethread_workqueue("ax88772a");
+	if (!priv->ax_work) {
+		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
+		kfree(priv);
+		return -ENOMEM;
+	}
+
+	priv->dev = dev;
+	INIT_WORK(&priv->check_link, ax88772a_link_reset);
+
+	/* Get the EEPROM data*/
+	ret = asix_read_eeprom_le16(dev, 0x17, &priv->EepromData);
+	if (ret < 0)
+		goto err_out;
+
+	/* reload eeprom data */
+	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE);
+	if (ret)
+		goto err_out;
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;
+
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;
+	if (dev->mii.phy_id != 0x10) {
+		netdev_err(dev->net, "%s: Got wrong PHY_ID: 0x%02x\n",
+						__func__, dev->mii.phy_id);
+		ret = -EIO;
+		goto err_out;
+	}
+
+	/* select the embedded 10/100 Ethernet PHY */
+	ret = asix_phy_select(dev,
+			AX_PHYSEL_SSEN | AX_PHYSEL_PSEL | AX_PHYSEL_SSMII);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax88772a_phy_powerup(dev);
+	if (ret < 0)
+		goto err_out;

-	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
+	/* stop MAC operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+				AX_RX_CTL_STOP, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}

 	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
-		dbg("Failed to read MAC address: %d", ret);
-		goto out;
+	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	/* make sure the driver can enable sw mii operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: enable software MII failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772_suspend;
+	data->resume = ax88772_resume;
+
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+
+	mii_nway_restart(&dev->mii);
+	priv->autoneg_start = jiffies;
+	priv->Event = WAIT_AUTONEG_COMPLETE;
+
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772A_IPG0_DEFAULT | AX88772A_IPG1_DEFAULT << 8,
+			AX88772A_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: write IPG,IPG1,IPG2 failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+				AX_RX_CTL_START | AX_RX_CTL_AB, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: Reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
+	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
+		/*
+		 * hard_mtu  is still the default;
+		 *  the device does not support jumbo eth frames
+		 */
+		dev->rx_urb_size = 2048;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return ret;
+
+err_out:
+	destroy_workqueue(priv->ax_work);
+	kfree(priv);
+	return ret;
+}
+
+static void ax88772a_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88772a_data *priv = (struct ax88772a_data *)dev->driver_priv;
+
+	if (priv) {
+
+		flush_workqueue(priv->ax_work);
+		destroy_workqueue(priv->ax_work);
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+
+		/* Power down PHY */
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int ax88772b_set_csums(struct usbnet *dev)
+{
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+	u16 checksum;
+
+	if (priv->checksum & AX_RX_CHECKSUM)
+		checksum = AX_RXCOE_DEF_CSUM;
+	else
+		checksum = 0;
+
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_RXCOE_CTL,
+				 checksum, 0, 0, NULL);
+
+	if (priv->checksum & AX_TX_CHECKSUM)
+		checksum = AX_TXCOE_DEF_CSUM;
+	else
+		checksum = 0;
+
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_TXCOE_CTL,
+				 checksum, 0, 0, NULL);
+
+	return 0;
+}
+
+static u32 ax88772b_get_tx_csum(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	return priv->checksum & AX_TX_CHECKSUM;
+}
+
+static u32 ax88772b_get_rx_csum(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	return priv->checksum & AX_RX_CHECKSUM;
+}
+
+static int ax88772b_set_rx_csum(struct net_device *netdev, u32 val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (val)
+		priv->checksum |= AX_RX_CHECKSUM;
+	else
+		priv->checksum &= ~AX_RX_CHECKSUM;
+
+	return ax88772b_set_csums(dev);
+}
+
+static int ax88772b_set_tx_csum(struct net_device *netdev, u32 val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (val)
+		priv->checksum |= AX_TX_CHECKSUM;
+	else
+		priv->checksum &= ~AX_TX_CHECKSUM;
+
+	ethtool_op_set_tx_csum(netdev, val);
+
+	return ax88772b_set_csums(dev);
+}
+
+static struct ethtool_ops ax88772b_ethtool_ops = {
+	.get_drvinfo		= ax8817x_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_msglevel		= usbnet_get_msglevel,
+	.set_msglevel		= usbnet_set_msglevel,
+	.get_wol		= ax8817x_get_wol,
+	.set_wol		= ax8817x_set_wol,
+	.get_eeprom_len		= ax8817x_get_eeprom_len,
+	.get_eeprom		= ax8817x_get_eeprom,
+	.get_settings		= ax8817x_get_settings,
+	.set_settings		= ax8817x_set_settings,
+	.set_tx_csum		= ax88772b_set_tx_csum,
+	.get_tx_csum		= ax88772b_get_tx_csum,
+	.get_rx_csum		= ax88772b_get_rx_csum,
+	.set_rx_csum		= ax88772b_set_rx_csum,
+};
+
+static const struct net_device_ops ax88772b_netdev_ops = {
+	.ndo_open			= usbnet_open,
+	.ndo_stop			= usbnet_stop,
+	.ndo_start_xmit	= usbnet_start_xmit,
+	.ndo_tx_timeout	= usbnet_tx_timeout,
+	.ndo_change_mtu	= usbnet_change_mtu,
+	.ndo_do_ioctl		= ax8817x_ioctl,
+	.ndo_set_mac_address	= ax8817x_set_mac_addr,
+	.ndo_validate_addr		= eth_validate_addr,
+	.ndo_set_multicast_list = ax88772b_set_multicast,
+};
+
+static int ax88772b_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88772b_data *priv;
+	int rx_size;
+	u16 tmp16;
+
+	usbnet_get_endpoints(dev, intf);
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
+
+	priv->ax_work = create_singlethread_workqueue("ax88772b");
+	if (!priv->ax_work) {
+		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
+		kfree(priv);
+		return -ENOMEM;
+	}
+
+	priv->dev = dev;
+	INIT_WORK(&priv->check_link, ax88772b_link_reset);
+
+	/* reload eeprom data */
+	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE);
+	if (ret)
+		goto err_out;
+
+	/* Get the EEPROM data*/
+	ret = asix_read_eeprom_le16(dev, 0x18, &priv->psc);
+	if (ret < 0)
+		goto err_out;
+	priv->psc &= 0xFF00;
+
+	/* Get the MAC address from the eeprom */
+	ret = asix_read_mac_from_eeprom(dev);
+	if (ret < 0)
+		goto err_out;
+
+	/* Set the MAC address */
+	ret = ax8817x_write_cmd(dev, AX88772_CMD_WRITE_NODE_ID,
+			0, 0, ETH_ALEN, dev->net->dev_addr);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: set mac addr failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);

 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = asix_mdio_read;
-	dev->mii.mdio_write = asix_mdio_write;
-	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax88772b_mdio_write_le;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;
+
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;
+	if (dev->mii.phy_id != 0x10) {
+		netdev_err(dev->net, "%s: Got wrong PHY_ID: 0x%02x\n",
+						__func__, dev->mii.phy_id);
+		ret = -EIO;
+		goto err_out;
+	}
+
+	/* select the embedded 10/100 Ethernet PHY */
+	ret = asix_phy_select(dev,
+			AX_PHYSEL_SSEN | AX_PHYSEL_PSEL | AX_PHYSEL_SSMII);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax88772a_phy_powerup(dev);
+	if (ret < 0)
+		goto err_out;
+
+	/* stop MAC operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+				AX_RX_CTL_STOP, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* make sure the driver can enable sw mii operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: enable software MII failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	dev->net->netdev_ops = &ax88772b_netdev_ops;
+	dev->net->ethtool_ops = &ax88772b_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772b_suspend;
+	data->resume = ax88772b_resume;
+
+	tmp16 = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, 0x12,
+			((tmp16 & 0xFF9F) | 0x0040));
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+	mii_nway_restart(&dev->mii);
+
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772A_IPG0_DEFAULT | AX88772A_IPG1_DEFAULT << 8,
+			AX88772A_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: write interfram gap failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	dev->net->features |= NETIF_F_IP_CSUM;
+	dev->net->features |= NETIF_F_IPV6_CSUM;
+
+	priv->checksum = AX_RX_CHECKSUM | AX_TX_CHECKSUM;
+	ret = ax88772b_set_csums(dev);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: write RX_COE/TX_COE failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	rx_size = bsize & 0x07;
+	if (dev->udev->speed == USB_SPEED_HIGH) {
+		ret = ax8817x_write_cmd(dev, 0x2A,
+				AX88772B_BULKIN_SIZE[rx_size].byte_cnt,
+				AX88772B_BULKIN_SIZE[rx_size].threshold,
+				0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: set rx_size failed, err=%d\n",
+							__func__, ret);
+			goto err_out;
+		}
+		dev->rx_urb_size = AX88772B_BULKIN_SIZE[rx_size].size;
+	} else {
+		ret = ax8817x_write_cmd(dev, 0x2A, 0x8000, 0x8001, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: set rx_size failed, err=%d\n",
+							__func__, ret);
+			goto err_out;
+		}
+		dev->rx_urb_size = 2048;
+	}
+
+	/* Configure RX header type */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+		      (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_HEADER_DEFAULT),
+		      0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Overwrite power saving configuration from eeprom */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+	    AX_SWRESET_IPRL | (priv->psc & 0x7FFF), 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: set phy power saving failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return ret;
+
+err_out:
+	destroy_workqueue(priv->ax_work);
+	kfree(priv);
+	return ret;
+}
+
+static void ax88772b_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (priv) {
+
+		flush_workqueue(priv->ax_work);
+		destroy_workqueue(priv->ax_work);
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+
+		/* Power down PHY */
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int
+ax88178_media_check(struct usbnet *dev, struct ax88178_data *priv)
+{
+	int fullduplex;
+	u16 tempshort = 0;
+	u16 media;
+	u16 advertise, lpa, result, stat1000;
+
+	advertise = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_ADVERTISE);
+	lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
+	result = advertise & lpa;
+
+	stat1000 = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_STAT1000);
+
+	if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+	    (priv->LedMode == 1)) {
+		tempshort = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MARVELL_MANUAL_LED) & 0xfc0f;
+	}
+
+	fullduplex = 1;
+	if (stat1000 & LPA_1000FULL) {
+		media = MEDIUM_GIGA_MODE | MEDIUM_FULL_DUPLEX_MODE |
+			MEDIUM_ENABLE_125MHZ | MEDIUM_ENABLE_RECEIVE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x3e0;
+	} else if (result & LPA_100FULL) {
+		media = MEDIUM_FULL_DUPLEX_MODE | MEDIUM_ENABLE_RECEIVE |
+			MEDIUM_MII_100M_MODE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x3b0;
+	} else if (result & LPA_100HALF) {
+		fullduplex = 0;
+		media = MEDIUM_ENABLE_RECEIVE | MEDIUM_MII_100M_MODE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x3b0;
+	} else if (result & LPA_10FULL) {
+		media = MEDIUM_FULL_DUPLEX_MODE | MEDIUM_ENABLE_RECEIVE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x2f0;
+	} else {
+		media = MEDIUM_ENABLE_RECEIVE;
+		fullduplex = 0;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+				tempshort |= 0x02f0;
+	}
+
+	if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+	    (priv->LedMode == 1)) {
+		ax8817x_mdio_write_le(dev->net,
+			dev->mii.phy_id, MARVELL_MANUAL_LED, tempshort);
+	}
+
+	media |= 0x0004;
+	if (priv->UseRgmii)
+		media |= 0x0008;
+	if (fullduplex) {
+		media |= 0x0020;  /* enable tx flow control as default */
+		media |= 0x0010;  /* enable rx flow control as default */
+	}
+
+	return media;
+}
+
+static void Vitess_8601_Init(struct usbnet *dev, int State)
+{
+	u16 reg;
+
+	switch (State) {
+	case 0:	/* tx, rx clock skew */
+		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 31, 1);
+		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 28, 0);
+		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 31, 0);
+		break;
+
+	case 1:
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0x52B5);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x009E);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xDD39);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87AA);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xA7B4);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x003f) | 0x003c;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87B4);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa794);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x003f) | 0x003e;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x8794);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x00f7);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xbe36);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x879e);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa7a0);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x003f) | 0x0034;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a0);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x003c);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xf3cf);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a2);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x003c);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xf3cf);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a4);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x003c);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xd287);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a6);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa7a8);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x0fff) | 0x0125;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a8);
+
+		/* Enable Smart Pre-emphasis */
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa7fa);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x0008) | 0x0008;
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87fa);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0);
+
+		break;
+	}
+}
+
+static int
+ax88178_phy_init(struct usbnet *dev, struct ax88178_data *priv)
+{
+	int i;
+	u16 PhyAnar, PhyAuxCtrl, PhyCtrl, TempShort, PhyID1;
+	u16 PhyReg = 0;
+
+	/* Disable MII operation of AX88178 Hardware */
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
+
+
+	/* Read SROM - MiiPhy Address (ID) */
+	ax8817x_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, &dev->mii.phy_id);
+	le16_to_cpus(&dev->mii.phy_id);
+
+	/* Initialize MII structure */
+	dev->mii.phy_id >>= 8;
+	dev->mii.phy_id &= PHY_ID_MASK;
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
+	dev->mii.phy_id_mask = 0x3f;
 	dev->mii.reg_num_mask = 0x1f;
-	dev->mii.phy_id = asix_get_phy_addr(dev);
+	dev->mii.supports_gmii = 1;

-	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
+	if (priv->PhyMode == PHY_MODE_MAC_TO_MAC_GMII) {
+		priv->UseRgmii = 0;
+		priv->MediaLink = MEDIUM_GIGA_MODE |
+					  MEDIUM_FULL_DUPLEX_MODE |
+					  MEDIUM_ENABLE_125MHZ |
+					  MEDIUM_ENABLE_RECEIVE |
+					  MEDIUM_ENABLE_RX_FLOWCTRL |
+					  MEDIUM_ENABLE_TX_FLOWCTRL;
+
+		goto SkipPhySetting;
+	}
+
+	/* test read phy register 2 */
+	if (!priv->UseGpio0) {
+		i = 1000;
+		while (i--) {
+			PhyID1 = ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, GMII_PHY_OUI);
+			if ((PhyID1 == 0x000f) || (PhyID1 == 0x0141) ||
+			    (PhyID1 == 0x0282) || (PhyID1 == 0x004d) ||
+			    (PhyID1 == 0x0243) || (PhyID1 == 0x001C) ||
+			    (PhyID1 == 0x0007))
+				break;
+			usleep_range(5, 20);
+		}
+		if (i < 0)
+			return -EIO;
+	}

-	if ((ret = asix_sw_reset(dev, AX_SWRESET_PRL)) < 0)
-		goto out;
+	priv->UseRgmii = 0;
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 27);
+		if (!(PhyReg & 4)) {
+			priv->UseRgmii = 1;
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 20, 0x82);
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+	} else if ((priv->PhyMode == PHY_MODE_AGERE_V0) ||
+		 (priv->PhyMode == PHY_MODE_AGERE_V0_GMII)) {
+		if (priv->PhyMode == PHY_MODE_AGERE_V0) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+	} else if (priv->PhyMode == PHY_MODE_CICADA_V1) {
+		/* not Cameo */
+		if (!priv->UseGpio0 || priv->LedMode) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}

-	msleep(150);
+		for (i = 0; i < (sizeof(CICADA_FAMILY_HWINIT) /
+				 sizeof(CICADA_FAMILY_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id,
+					CICADA_FAMILY_HWINIT[i].offset,
+					CICADA_FAMILY_HWINIT[i].value);
+		}
+
+	} else if (priv->PhyMode == PHY_MODE_CICADA_V2) {
+		/* not Cameo */
+		if (!priv->UseGpio0 || priv->LedMode) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+
+		for (i = 0; i < (sizeof(CICADA_V2_HWINIT) /
+				 sizeof(CICADA_V2_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, CICADA_V2_HWINIT[i].offset,
+				CICADA_V2_HWINIT[i].value);
+		}
+	} else if (priv->PhyMode == PHY_MODE_CICADA_V2_ASIX) {
+		/* not Cameo */
+		if (!priv->UseGpio0 || priv->LedMode) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+
+		for (i = 0; i < (sizeof(CICADA_V2_HWINIT) /
+				 sizeof(CICADA_V2_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, CICADA_V2_HWINIT[i].offset,
+				CICADA_V2_HWINIT[i].value);
+		}
+	} else if (priv->PhyMode == PHY_MODE_RTL8211CL) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+	} else if (priv->PhyMode == PHY_MODE_RTL8211BN) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+	} else if (priv->PhyMode == PHY_MODE_RTL8251CL) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+	} else if (priv->PhyMode == PHY_MODE_VSC8601) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		/* Vitess_8601_Init(dev, 0); */
+	}
+
+	if (priv->PhyMode != PHY_MODE_ATTANSIC_V0) {
+		/* software reset */
+		ax8817x_swmii_mdio_write_le(
+			dev->net, dev->mii.phy_id, GMII_PHY_CONTROL,
+			ax8817x_swmii_mdio_read_le(
+				dev->net, dev->mii.phy_id, GMII_PHY_CONTROL)
+				| GMII_CONTROL_RESET);
+		usleep_range(1000, 2000);
+	}
+
+	if ((priv->PhyMode == PHY_MODE_AGERE_V0) ||
+	    (priv->PhyMode == PHY_MODE_AGERE_V0_GMII)) {
+		if (priv->PhyMode == PHY_MODE_AGERE_V0) {
+			i = 1000;
+			while (i--) {
+				ax8817x_swmii_mdio_write_le(dev->net,
+						dev->mii.phy_id, 21, 0x1001);
+
+				PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 21);
+				if ((PhyReg & 0xf00f) == 0x1001)
+					break;
+			}
+			if (i < 0)
+				return -EIO;
+		}
+
+		if (priv->LedMode == 4) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 28, 0x7417);
+		} else if (priv->LedMode == 9) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 28, 0x7a10);
+		} else if (priv->LedMode == 10) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 28, 0x7a13);
+		}
+
+		for (i = 0; i < (sizeof(AGERE_FAMILY_HWINIT) /
+				 sizeof(AGERE_FAMILY_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, AGERE_FAMILY_HWINIT[i].offset,
+				AGERE_FAMILY_HWINIT[i].value);
+		}
+	} else if (priv->PhyMode == PHY_MODE_RTL8211CL) {
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x1f, 0x0005);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x0c, 0);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x01,
+				(ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 0x01) | 0x0080));
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x1f, 0);
+
+		if (priv->LedMode == 12) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 0x1f, 0x0002);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 0x1a, 0x00cb);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 0x1f, 0);
+		}
+	} else if (priv->PhyMode == PHY_MODE_VSC8601) {
+		Vitess_8601_Init(dev, 1);
+	}
+
+	/* read phy register 0 */
+	PhyCtrl = ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL);
+	TempShort = PhyCtrl;
+	PhyCtrl &= ~(GMII_CONTROL_POWER_DOWN | GMII_CONTROL_ISOLATE);
+	if (PhyCtrl != TempShort) {
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL, PhyCtrl);
+	}
+
+	/* led */
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		if (priv->LedMode == 1) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 24) & 0xf8ff) | (1 + 0x100);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+			PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 25) & 0xfc0f;
+
+		} else if (priv->LedMode == 2) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0xf886) |
+					(1 + 0x10 + 0x300);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 5) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0xf8be) |
+					(1 + 0x40 + 0x300);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 7) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 24) & 0xf8ff) |
+						(1 + 0x100);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 8) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0xf8be) |
+					(1 + 0x40 + 0x100);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 11) {
+
+			PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0x4106;
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		}
+	} else if ((priv->PhyMode == PHY_MODE_CICADA_V1) ||
+		   (priv->PhyMode == PHY_MODE_CICADA_V2) ||
+		   (priv->PhyMode == PHY_MODE_CICADA_V2_ASIX)) {
+
+		if (priv->LedMode == 3) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 27) & 0xFCFF) | 0x0100;
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 27, PhyReg);
+		}
+
+	}
+
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		if (priv->LedMode == 1)
+			PhyReg |= 0x3f0;
+	}
+	PhyAnar = 1 | (GMII_ANAR_PAUSE | GMII_ANAR_100TXFD | GMII_ANAR_100TX |
+		       GMII_ANAR_10TFD | GMII_ANAR_10T | GMII_ANAR_ASYM_PAUSE);
+	PhyAuxCtrl = GMII_1000_AUX_CTRL_FD_CAPABLE;
+	ax8817x_swmii_mdio_write_le(dev->net,
+			dev->mii.phy_id, GMII_PHY_ANAR, PhyAnar);
+	ax8817x_swmii_mdio_write_le(dev->net,
+			dev->mii.phy_id, GMII_PHY_1000BT_CONTROL, PhyAuxCtrl);
+
+	if (priv->PhyMode == PHY_MODE_VSC8601) {
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0x52B5);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xA7F8);
+		TempShort = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 17) & (~0x0018);
+		ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 17, TempShort);
+		TempShort = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 18);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, TempShort);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87F8);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0);
+	}
+
+	if (priv->PhyMode == PHY_MODE_ATTANSIC_V0) {
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL, 0x9000);
+
+	} else {
+		PhyCtrl &= ~GMII_CONTROL_LOOPBACK;
+		PhyCtrl |= (GMII_CONTROL_ENABLE_AUTO | GMII_CONTROL_START_AUTO);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL, PhyCtrl);
+	}
+
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		if (priv->LedMode == 1)
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 25, PhyReg);
+	}
+
+SkipPhySetting:
+
+	asix_write_medium_mode(dev, priv->MediaLink);
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772_IPG0_DEFAULT | (AX88772_IPG1_DEFAULT << 8),
+			AX88772_IPG2_DEFAULT, 0, NULL);
+	usleep_range(1000, 2000);
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+	return 0;
+}
+
+static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *priv;
+
+	usbnet_get_endpoints(dev, intf);
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
+
+	/* Get the EEPROM data*/
+	ret = asix_read_eeprom_le16(dev, 0x17, &priv->EepromData);
+	if (ret < 0)
+		goto err_out;
+
+	if (priv->EepromData == 0xffff) {
+		priv->PhyMode  = PHY_MODE_MARVELL;
+		priv->LedMode  = 0;
+		priv->UseGpio0 = 1;
+	} else {
+		priv->PhyMode = (u8)(priv->EepromData & EEPROMMASK);
+		priv->LedMode = (u8)(priv->EepromData >> 8);
+		if (priv->LedMode == 6)	/* for buffalo new (use gpio2) */
+			priv->LedMode = 1;
+		else if (priv->LedMode == 1)
+			priv->BuffaloOld = 1;
+
+
+		if (priv->EepromData & 0x80)
+			priv->UseGpio0 = 0; /* MARVEL se and other */
+		else
+			priv->UseGpio0 = 1; /* cameo */
+	}
+
+	if (priv->UseGpio0) {
+
+		if (priv->PhyMode == PHY_MODE_MARVELL) {
+
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO0EN | AXGPIOS_RSE);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 15,
+				AXGPIOS_GPO2 | AXGPIOS_GPO2EN |
+				AXGPIOS_GPO0EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 245,
+				AXGPIOS_GPO2EN | AXGPIOS_GPO0EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO2 | AXGPIOS_GPO2EN |
+				AXGPIOS_GPO0EN);
+			if (ret)
+				goto err_out;
+
+		} else { /* vitesse */
+
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_RSE | AXGPIOS_GPO0EN |
+				AXGPIOS_GPO0);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 245,
+				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
+				AXGPIOS_GPO2EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+		}
+
+	} else { /* use gpio1 */
+
+		if (priv->BuffaloOld) {
+			ret = asix_write_gpio(dev, 350,
+				AXGPIOS_GPO1 | AXGPIOS_GPO1EN |
+				AXGPIOS_RSE);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 350,
+				AXGPIOS_GPO1EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1);
+			if (ret)
+				goto err_out;
+		} else {
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO1 | AXGPIOS_GPO1EN |
+				AXGPIOS_RSE);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 245,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
+				AXGPIOS_GPO2EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+		}
+	}
+
+	ret = asix_phy_select(dev, 0);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_PRL, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: SW_RESET failed\n", __func__);
+		goto err_out;
+	}
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: RX_CTL failed\n", __func__);
+		goto err_out;
+	}
+
+	/* Get the MAC address */
+	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax88178_phy_init(dev, priv);
+	if (ret < 0)
+		goto err_out;
+
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax8817x_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772_suspend;
+	data->resume = ax88772_resume;
+
+	if (dev->driver_info->flags & FLAG_FRAMING_AX)
+		dev->rx_urb_size = 16384;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+			(AX_RX_CTL_MFB | AX_RX_CTL_START | AX_RX_CTL_AB),
+			0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: RX_CTL failed\n", __func__);
+		goto err_out;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return ret;
+
+err_out:
+	kfree(priv);
+	return ret;
+}
+
+static void ax88178_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;
+
+	if (priv) {
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int ax88772_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	u8  *head;
+	u32  header;
+	char *packet;
+	struct sk_buff *ax_skb;
+	u16 size;
+
+	head = (u8 *) skb->data;
+	memcpy(&header, head, sizeof(header));
+	le32_to_cpus(&header);
+	packet = head + sizeof(header);

-	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL)) < 0)
-		goto out;
+	skb_pull(skb, 4);

-	msleep(150);
+	while (skb->len > 0) {
+		if ((short)(header & 0x0000ffff) !=
+		    ~((short)((header & 0xffff0000) >> 16))) {
+			netdev_err(dev->net,
+				"%s: header length data is error 0x%08x, %d\n",
+				__func__, header, skb->len);
+		}
+		/* get the packet length */
+		size = (u16) (header & 0x0000ffff);

-	dev->net->netdev_ops = &ax88772_netdev_ops;
-	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+		if ((skb->len) - ((size + 1) & 0xfffe) == 0) {

-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
-			ADVERTISE_ALL | ADVERTISE_CSMA);
-	mii_nway_restart(&dev->mii);
+			/* Make sure ip header is aligned on 32-bit boundary */
+			if (!((unsigned long)skb->data & 0x02)) {
+				memmove(skb->data - 2, skb->data, size);
+				skb->data -= 2;
+				skb_set_tail_pointer(skb, size);
+			}
+			skb->truesize = size + sizeof(struct sk_buff);
+			return 2;
+		}

-	if ((ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT)) < 0)
-		goto out;
+		if (size > ETH_FRAME_LEN) {
+			netdev_err(dev->net, "%s: invalid rx length %d\n",
+							__func__, size);
+			return 0;
+		}
+		ax_skb = skb_clone(skb, GFP_ATOMIC);
+		if (ax_skb) {

-	if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
-				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
-				AX88772_IPG2_DEFAULT, 0, NULL)) < 0) {
-		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
-		goto out;
-	}
+			/* Make sure ip header is aligned on 32-bit boundary */
+			if (!((unsigned long)packet & 0x02)) {
+				memmove(packet - 2, packet, size);
+				packet -= 2;
+			}
+			ax_skb->data = packet;
+			skb_set_tail_pointer(ax_skb, size);
+			ax_skb->truesize = size + sizeof(struct sk_buff);
+			usbnet_skb_return(dev, ax_skb);

-	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
-	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
-		goto out;
+		} else {
+			return 0;
+		}

-	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x after all initializations", rx_ctl);
+		skb_pull(skb, (size + 1) & 0xfffe);

-	rx_ctl = asix_read_medium_status(dev);
-	dbg("Medium Status is 0x%04x after all initializations", rx_ctl);
+		if (skb->len == 0)
+			break;

-	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
-	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
-		/* hard_mtu  is still the default - the device does not support
-		   jumbo eth frames */
-		dev->rx_urb_size = 2048;
+		head = (u8 *) skb->data;
+		memcpy(&header, head, sizeof(header));
+		le32_to_cpus(&header);
+		packet = head + sizeof(header);
+		skb_pull(skb, 4);
 	}
-	return 0;

-out:
-	return ret;
+	if (skb->len < 0) {
+		netdev_err(dev->net, "%s: invalid rx length %d\n",
+						__func__, skb->len);
+		return 0;
+	}
+	return 1;
 }

-static struct ethtool_ops ax88178_ethtool_ops = {
-	.get_drvinfo		= asix_get_drvinfo,
-	.get_link		= asix_get_link,
-	.get_msglevel		= usbnet_get_msglevel,
-	.set_msglevel		= usbnet_set_msglevel,
-	.get_wol		= asix_get_wol,
-	.set_wol		= asix_set_wol,
-	.get_eeprom_len		= asix_get_eeprom_len,
-	.get_eeprom		= asix_get_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
-	.nway_reset		= usbnet_nway_reset,
-};
-
-static int marvell_phy_init(struct usbnet *dev)
+static struct sk_buff *ax88772_tx_fixup(struct usbnet *dev,
+					struct sk_buff *skb, gfp_t flags)
 {
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u16 reg;
-
-	netdev_dbg(dev->net, "marvell_phy_init()\n");
+	int padlen = ((skb->len + 4) % 512) ? 0 : 4;
+	u32 packet_len;
+	u32 padbytes = 0xffff0000;
+	int headroom = skb_headroom(skb);
+	int tailroom = skb_tailroom(skb);

-	reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_MARVELL_STATUS);
-	netdev_dbg(dev->net, "MII_MARVELL_STATUS = 0x%04x\n", reg);
+	if ((!skb_cloned(skb))
+	    && ((headroom + tailroom) >= (4 + padlen))) {
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

-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_MARVELL_CTRL,
-			MARVELL_CTRL_RXDELAY | MARVELL_CTRL_TXDELAY);
+	skb_push(skb, 4);
+	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
+	cpu_to_le32s(&packet_len);
+	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));

-	if (data->ledmode) {
-		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL);
-		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (1) = 0x%04x\n", reg);
-
-		reg &= 0xf8ff;
-		reg |= (1 + 0x0100);
-		asix_mdio_write(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL, reg);
-
-		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL);
-		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (2) = 0x%04x\n", reg);
-		reg &= 0xfc0f;
+	if ((skb->len % 512) == 0) {
+		cpu_to_le32s(&padbytes);
+		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
+		skb_put(skb, sizeof(padbytes));
 	}
-
-	return 0;
+	return skb;
 }

-static int marvell_led_status(struct usbnet *dev, u16 speed)
+static void
+ax88772b_rx_checksum(struct sk_buff *skb, struct ax88772b_rx_header *rx_hdr)
 {
-	u16 reg = asix_mdio_read(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL);
-
-	netdev_dbg(dev->net, "marvell_led_status() read 0x%04x\n", reg);
+	skb->ip_summed = CHECKSUM_NONE;

-	/* Clear out the center LED bits - 0x03F0 */
-	reg &= 0xfc0f;
+	/* checksum error bit is set */
+	if (rx_hdr->l3_csum_err || rx_hdr->l4_csum_err)
+		return;

-	switch (speed) {
-		case SPEED_1000:
-			reg |= 0x03e0;
-			break;
-		case SPEED_100:
-			reg |= 0x03b0;
-			break;
-		default:
-			reg |= 0x02f0;
+	/* It must be a TCP or UDP packet with a valid checksum */
+	if ((rx_hdr->l4_type == AX_RXHDR_L4_TYPE_TCP) ||
+	    (rx_hdr->l4_type == AX_RXHDR_L4_TYPE_UDP)) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
-
-	netdev_dbg(dev->net, "marvell_led_status() writing 0x%04x\n", reg);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL, reg);
-
-	return 0;
 }

-static int ax88178_link_reset(struct usbnet *dev)
+static int ax88772b_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
-	u16 mode;
-	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u32 speed;
-
-	netdev_dbg(dev->net, "ax88178_link_reset()\n");
-
-	mii_check_media(&dev->mii, 1, 1);
-	mii_ethtool_gset(&dev->mii, &ecmd);
-	mode = AX88178_MEDIUM_DEFAULT;
-	speed = ethtool_cmd_speed(&ecmd);
-
-	if (speed == SPEED_1000)
-		mode |= AX_MEDIUM_GM;
-	else if (speed == SPEED_100)
-		mode |= AX_MEDIUM_PS;
-	else
-		mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);
+	struct ax88772b_rx_header rx_hdr;
+	struct sk_buff *ax_skb;
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;

-	mode |= AX_MEDIUM_ENCK;
+	while (skb->len > 0) {

-	if (ecmd.duplex == DUPLEX_FULL)
-		mode |= AX_MEDIUM_FD;
-	else
-		mode &= ~AX_MEDIUM_FD;
+		memcpy(&rx_hdr, skb->data, sizeof(struct ax88772b_rx_header));

-	netdev_dbg(dev->net, "ax88178_link_reset() speed: %u duplex: %d setting mode
to 0x%04x\n",
-		   speed, ecmd.duplex, mode);
+		if ((short)rx_hdr.len != (~((short)rx_hdr.len_bar) & 0x7FF))
+			return 0;
+		if (rx_hdr.len > (ETH_FRAME_LEN + 4)) {
+			netdev_err(dev->net, "%s: invalid rx length %d\n",
+						__func__, rx_hdr.len);
+			return 0;
+		}

-	asix_write_medium_mode(dev, mode);
+		if (skb->len - ((rx_hdr.len +
+				 sizeof(struct ax88772b_rx_header) + 3) &
+				 0xfffc) == 0) {
+			skb_pull(skb, sizeof(struct ax88772b_rx_header));
+			skb->len = rx_hdr.len;

-	if (data->phymode == PHY_MODE_MARVELL && data->ledmode)
-		marvell_led_status(dev, speed);
+			skb_set_tail_pointer(skb, rx_hdr.len);
+			skb->truesize = rx_hdr.len + sizeof(struct sk_buff);

-	return 0;
-}
+			if (priv->checksum & AX_RX_CHECKSUM)
+				ax88772b_rx_checksum(skb, &rx_hdr);

-static void ax88178_set_mfb(struct usbnet *dev)
-{
-	u16 mfb = AX_RX_CTL_MFB_16384;
-	u16 rxctl;
-	u16 medium;
-	int old_rx_urb_size = dev->rx_urb_size;
+			return 2;
+		}

-	if (dev->hard_mtu < 2048) {
-		dev->rx_urb_size = 2048;
-		mfb = AX_RX_CTL_MFB_2048;
-	} else if (dev->hard_mtu < 4096) {
-		dev->rx_urb_size = 4096;
-		mfb = AX_RX_CTL_MFB_4096;
-	} else if (dev->hard_mtu < 8192) {
-		dev->rx_urb_size = 8192;
-		mfb = AX_RX_CTL_MFB_8192;
-	} else if (dev->hard_mtu < 16384) {
-		dev->rx_urb_size = 16384;
-		mfb = AX_RX_CTL_MFB_16384;
-	}
+		ax_skb = skb_clone(skb, GFP_ATOMIC);
+		if (ax_skb) {
+			ax_skb->len = rx_hdr.len;
+			ax_skb->data = skb->data +
+				       sizeof(struct ax88772b_rx_header);
+			skb_set_tail_pointer(ax_skb, rx_hdr.len);
+			ax_skb->truesize = rx_hdr.len + sizeof(struct sk_buff);
+			if (priv->checksum & AX_RX_CHECKSUM)
+				ax88772b_rx_checksum(ax_skb, &rx_hdr);
+			usbnet_skb_return(dev, ax_skb);

-	rxctl = asix_read_rx_ctl(dev);
-	asix_write_rx_ctl(dev, (rxctl & ~AX_RX_CTL_MFB_16384) | mfb);
+		} else {
+			return 0;
+		}

-	medium = asix_read_medium_status(dev);
-	if (dev->net->mtu > 1500)
-		medium |= AX_MEDIUM_JFE;
-	else
-		medium &= ~AX_MEDIUM_JFE;
-	asix_write_medium_mode(dev, medium);
+		skb_pull(skb, ((rx_hdr.len +
+				sizeof(struct ax88772b_rx_header) + 3)
+				& 0xfffc));
+	}

-	if (dev->rx_urb_size > old_rx_urb_size)
-		usbnet_unlink_rx_urbs(dev);
+	if (skb->len < 0) {
+		netdev_err(dev->net, "%s: invalid rx length %d\n",
+					__func__, skb->len);
+		return 0;
+	}
+	return 1;
 }

-static int ax88178_change_mtu(struct net_device *net, int new_mtu)
+static struct sk_buff *
+ax88772b_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
-	struct usbnet *dev = netdev_priv(net);
-	int ll_mtu = new_mtu + net->hard_header_len + 4;
+	int padlen = ((skb->len + 4) % 512) ? 0 : 4;
+	u32 packet_len;
+	u32 padbytes = 0xffff0000;
+	int headroom = skb_headroom(skb);
+	int tailroom = skb_tailroom(skb);

-	netdev_dbg(dev->net, "ax88178_change_mtu() new_mtu=%d\n", new_mtu);
+	if ((!skb_cloned(skb))
+	    && ((headroom + tailroom) >= (4 + padlen))) {
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

-	if (new_mtu <= 0 || ll_mtu > 16384)
-		return -EINVAL;
+	skb_push(skb, 4);
+	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);

-	if ((ll_mtu % dev->maxpacket) == 0)
-		return -EDOM;
+	cpu_to_le32s(&packet_len);
+	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));

-	net->mtu = new_mtu;
-	dev->hard_mtu = net->mtu + net->hard_header_len;
-	ax88178_set_mfb(dev);
+	if ((skb->len % 512) == 0) {
+		cpu_to_le32s(&padbytes);
+		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
+		skb_put(skb, sizeof(padbytes));
+	}

-	return 0;
+	return skb;
 }

-static const struct net_device_ops ax88178_netdev_ops = {
-	.ndo_open		= usbnet_open,
-	.ndo_stop		= usbnet_stop,
-	.ndo_start_xmit		= usbnet_start_xmit,
-	.ndo_tx_timeout		= usbnet_tx_timeout,
-	.ndo_set_mac_address 	= asix_set_mac_address,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = asix_set_multicast,
-	.ndo_do_ioctl 		= asix_ioctl,
-	.ndo_change_mtu 	= ax88178_change_mtu,
+static const u8 ChkCntSel[6][3] = {
+	{12, 23, 31},
+	{12, 31, 23},
+	{23, 31, 12},
+	{23, 12, 31},
+	{31, 12, 23},
+	{31, 23, 12}
 };

-static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
+static void ax88772_link_reset(struct work_struct *work)
 {
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	int ret;
-	u8 buf[ETH_ALEN];
-	__le16 eeprom;
-	u8 status;
-	int gpio0 = 0;
-	u32 phyid;
-
-	usbnet_get_endpoints(dev,intf);
-
-	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
-	dbg("GPIO Status: 0x%04x", status);
-
-	asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
-	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
-	asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL);
-
-	dbg("EEPROM index 0x17 is 0x%04x", eeprom);
-
-	if (eeprom == cpu_to_le16(0xffff)) {
-		data->phymode = PHY_MODE_MARVELL;
-		data->ledmode = 0;
-		gpio0 = 1;
-	} else {
-		data->phymode = le16_to_cpu(eeprom) & 7;
-		data->ledmode = le16_to_cpu(eeprom) >> 8;
-		gpio0 = (le16_to_cpu(eeprom) & 0x80) ? 0 : 1;
-	}
-	dbg("GPIO0: %d, PhyMode: %d", gpio0, data->phymode);
-
-	asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
-	if ((le16_to_cpu(eeprom) >> 8) != 1) {
-		asix_write_gpio(dev, 0x003c, 30);
-		asix_write_gpio(dev, 0x001c, 300);
-		asix_write_gpio(dev, 0x003c, 30);
-	} else {
-		dbg("gpio phymode == 1 path");
-		asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
-		asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30);
+	struct ax88772_data *priv = container_of(work,
+					struct ax88772_data, check_link);
+	struct usbnet *dev = priv->dev;
+
+	if (priv->Event == AX_SET_RX_CFG) {
+		u16 bmcr;
+		u16 mode;
+
+		priv->Event = AX_NOP;
+
+		mode = AX88772_MEDIUM_DEFAULT;
+
+		bmcr = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_BMCR);
+		if (!(bmcr & BMCR_FULLDPLX))
+			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
+		if (!(bmcr & BMCR_SPEED100))
+			mode &= ~AX88772_MEDIUM_100MB;
+		asix_write_medium_mode(dev, mode);
+		return;
 	}

-	asix_sw_reset(dev, 0);
-	msleep(150);
-
-	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
-	msleep(150);
-
-	asix_write_rx_ctl(dev, 0);
+	switch (priv->Event) {
+	case WAIT_AUTONEG_COMPLETE:
+		if (jiffies > (priv->autoneg_start + 5 * HZ)) {
+			priv->Event = PHY_POWER_DOWN;
+			priv->TickToExpire = 23;
+		}
+		break;
+	case PHY_POWER_DOWN:
+		if (priv->TickToExpire == 23) {
+			/* Set Phy Power Down */
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					  AX_SWRESET_IPPD,
+					  0, 0, NULL);
+			--priv->TickToExpire;
+		} else if (--priv->TickToExpire == 0) {
+			/* Set Phy Power Up */
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL, 0, 0, NULL);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_IPRL, 0, 0, NULL);
+			usleep_range(10000, 20000);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL, 0, 0, NULL);
+			msleep(60);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_CLEAR, 0, 0, NULL);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL, 0, 0, NULL);
+			ax8817x_mdio_write_le(dev->net, dev->mii.phy_id,
+				MII_ADVERTISE,
+				ADVERTISE_ALL | ADVERTISE_CSMA |
+				ADVERTISE_PAUSE_CAP);
+			mii_nway_restart(&dev->mii);

-	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
-		dbg("Failed to read MAC address: %d", ret);
-		goto out;
+			priv->Event = PHY_POWER_UP;
+			priv->TickToExpire = 47;
+		}
+		break;
+	case PHY_POWER_UP:
+		if (--priv->TickToExpire == 0) {
+			priv->Event = PHY_POWER_DOWN;
+			priv->TickToExpire = 23;
+		}
+		break;
+	default:
+		break;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	return;
+}

-	/* Initialize MII structure */
-	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = asix_mdio_read;
-	dev->mii.mdio_write = asix_mdio_write;
-	dev->mii.phy_id_mask = 0x1f;
-	dev->mii.reg_num_mask = 0xff;
-	dev->mii.supports_gmii = 1;
-	dev->mii.phy_id = asix_get_phy_addr(dev);
+static void ax88772a_link_reset(struct work_struct *work)
+{
+	struct ax88772a_data *priv = container_of(work,
+					struct ax88772a_data, check_link);
+	struct usbnet *dev = priv->dev;
+	int PowSave = (priv->EepromData >> 14);
+	u16 phy_reg;
+
+	if (priv->Event == AX_SET_RX_CFG) {
+		u16 bmcr;
+		u16 mode;

-	dev->net->netdev_ops = &ax88178_netdev_ops;
-	dev->net->ethtool_ops = &ax88178_ethtool_ops;
+		priv->Event = AX_NOP;

-	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
+		mode = AX88772_MEDIUM_DEFAULT;

-	if (data->phymode == PHY_MODE_MARVELL) {
-		marvell_phy_init(dev);
-		msleep(60);
+		bmcr = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_BMCR);
+		if (!(bmcr & BMCR_FULLDPLX))
+			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
+		if (!(bmcr & BMCR_SPEED100))
+			mode &= ~AX88772_MEDIUM_100MB;
+		asix_write_medium_mode(dev, mode);
+		return;
 	}

-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
-			BMCR_RESET | BMCR_ANENABLE);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+	switch (priv->Event) {
+	case WAIT_AUTONEG_COMPLETE:
+		if (jiffies > (priv->autoneg_start + 5 * HZ)) {
+			priv->Event = CHK_CABLE_EXIST;
+			priv->TickToExpire = 14;
+		}
+		break;
+	case CHK_CABLE_EXIST:
+		phy_reg = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+		if ((phy_reg != 0x8012) && (phy_reg != 0x8013)) {
+			ax8817x_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x16, 0x4040);
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_STATUS;
+			priv->TickToExpire = 31;
+		} else if (--priv->TickToExpire == 0) {
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_EXIST_AGAIN;
+			if (PowSave == 0x03) {
+				priv->TickToExpire = 47;
+			} else if (PowSave == 0x01) {
+				priv->DlyIndex = (u8)(jiffies % 6);
+				priv->DlySel = 0;
+				priv->TickToExpire =
+				ChkCntSel[priv->DlyIndex][priv->DlySel];
+			}
+		}
+		break;
+	case CHK_CABLE_EXIST_AGAIN:
+		/* if cable disconnected */
+		phy_reg = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+		if ((phy_reg != 0x8012) && (phy_reg != 0x8013)) {
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_STATUS;
+			priv->TickToExpire = 31;
+		} else if (--priv->TickToExpire == 0) {
+			/* Power down PHY */
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					  AX_SWRESET_IPPD,
+					  0, 0, NULL);
+			priv->Event = PHY_POWER_DOWN;
+			if (PowSave == 0x03)
+				priv->TickToExpire = 23;
+			else if (PowSave == 0x01)
+				priv->TickToExpire = 31;
+		}
+		break;
+	case PHY_POWER_DOWN:
+		if (--priv->TickToExpire == 0)
+			priv->Event = PHY_POWER_UP;
+		break;
+	case CHK_CABLE_STATUS:
+		if (--priv->TickToExpire == 0) {
+			ax8817x_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x16, 0x4040);
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_EXIST_AGAIN;
+			if (PowSave == 0x03) {
+				priv->TickToExpire = 47;
+			} else if (PowSave == 0x01) {
+				priv->DlyIndex = (u8)(jiffies % 6);
+				priv->DlySel = 0;
+				priv->TickToExpire =
+				ChkCntSel[priv->DlyIndex][priv->DlySel];
+			}
+		}
+		break;
+	case PHY_POWER_UP:
+		ax88772a_phy_powerup(dev);
+		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+		mii_nway_restart(&dev->mii);
+		priv->Event = CHK_CABLE_EXIST_AGAIN;
+		if (PowSave == 0x03) {
+			priv->TickToExpire = 47;
+		} else if (PowSave == 0x01) {
+			if (++priv->DlySel >= 3) {
+				priv->DlyIndex = (u8)(jiffies % 6);
+				priv->DlySel = 0;
+			}
+			priv->TickToExpire =
+				ChkCntSel[priv->DlyIndex][priv->DlySel];
+		}
+		break;
+	default:
+		break;
+	}
+
+	return;
+}
+
+static void ax88772b_link_reset(struct work_struct *work)
+{
+	struct ax88772b_data *priv = container_of(work,
+					struct ax88772b_data, check_link);
+	struct usbnet *dev = priv->dev;
+
+	switch (priv->Event) {
+	case AX_SET_RX_CFG:
+	{
+		u16 bmcr = ax8817x_mdio_read_le(dev->net,
+					dev->mii.phy_id, MII_BMCR);
+		u16 mode = AX88772_MEDIUM_DEFAULT;
+
+		if (!(bmcr & BMCR_FULLDPLX))
+			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
+		if (!(bmcr & BMCR_SPEED100))
+			mode &= ~AX88772_MEDIUM_100MB;
+		asix_write_medium_mode(dev, mode);
+		break;
+	}
+	case PHY_POWER_UP:
+	{
+		u16 tmp16;
+
+		ax88772a_phy_powerup(dev);
+		tmp16 = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, 0x12,
+				((tmp16 & 0xFF9F) | 0x0040));
+		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
-			ADVERTISE_1000FULL);
+		break;
+	}
+	default:
+		break;
+	}

-	mii_nway_restart(&dev->mii);
+	priv->Event = AX_NOP;

-	if ((ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT)) < 0)
-		goto out;
+	return;
+}

-	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
-		goto out;
+static int ax88178_set_media(struct usbnet *dev)
+{
+	int	ret;
+	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;
+	int media;

-	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
-	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
-		/* hard_mtu  is still the default - the device does not support
-		   jumbo eth frames */
-		dev->rx_urb_size = 2048;
-	}
+	media = ax88178_media_check(dev, priv);
+	if (media < 0)
+		return media;
+	ret = asix_write_medium_mode(dev, media);
+	if (ret < 0)
+		return ret;
 	return 0;
+}

-out:
-	return ret;
+static int ax88178_link_reset(struct usbnet *dev)
+{
+	return ax88178_set_media(dev);
+}
+
+static int ax_suspend(struct usb_interface *intf,
+			pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+
+	return data->suspend(intf, message);
+}
+
+static int ax_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+
+	return data->resume(intf);
 }

+static const struct driver_info ax88178_info = {
+	.description = "ASIX AX88178 USB 2.0 Ethernet",
+	.bind = ax88178_bind,
+	.unbind = ax88178_unbind,
+	.status = ax88178_status,
+	.link_reset = ax88178_link_reset,
+	.reset = ax88178_link_reset,
+	.flags =  FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
+};
+
+static const struct driver_info belkin178_info = {
+	.description = "Belkin Gigabit USB 2.0 Network Adapter",
+	.bind = ax88178_bind,
+	.unbind = ax88178_unbind,
+	.status = ax8817x_status,
+	.link_reset = ax88178_link_reset,
+	.reset = ax88178_link_reset,
+	.flags =  FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
+};
+
 static const struct driver_info ax8817x_info = {
 	.description = "ASIX AX8817x USB 2.0 Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x00130103,
+	.flags =  FLAG_ETHER,
 };

 static const struct driver_info dlink_dub_e100_info = {
 	.description = "DLink DUB-E100 USB Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x009f9d9f,
+	.flags =  FLAG_ETHER,
 };

 static const struct driver_info netgear_fa120_info = {
 	.description = "Netgear FA-120 USB Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x00130103,
+	.flags =  FLAG_ETHER,
 };

 static const struct driver_info hawking_uf200_info = {
 	.description = "Hawking UF200 USB Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x001f1d1f,
+	.flags =  FLAG_ETHER,
 };

 static const struct driver_info ax88772_info = {
 	.description = "ASIX AX88772 USB 2.0 Ethernet",
 	.bind = ax88772_bind,
-	.status = asix_status,
-	.link_reset = ax88772_link_reset,
-	.reset = ax88772_link_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
-	.rx_fixup = asix_rx_fixup,
-	.tx_fixup = asix_tx_fixup,
+	.unbind = ax88772_unbind,
+	.status = ax88772_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
 };

-static const struct driver_info ax88178_info = {
-	.description = "ASIX AX88178 USB 2.0 Ethernet",
-	.bind = ax88178_bind,
-	.status = asix_status,
-	.link_reset = ax88178_link_reset,
-	.reset = ax88178_link_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
-	.rx_fixup = asix_rx_fixup,
-	.tx_fixup = asix_tx_fixup,
+static const struct driver_info dlink_dub_e100b_info = {
+	.description = "D-Link DUB-E100 USB 2.0 Fast Ethernet Adapter",
+	.bind = ax88772_bind,
+	.unbind = ax88772_unbind,
+	.status = ax88772_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
 };

-static const struct usb_device_id	products [] = {
+static const struct driver_info ax88772a_info = {
+	.description = "ASIX AX88772A USB 2.0 Ethernet",
+	.bind = ax88772a_bind,
+	.unbind = ax88772a_unbind,
+	.status = ax88772a_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
+};
+
+static const struct driver_info ax88772b_info = {
+	.description = "ASIX AX88772B USB 2.0 Ethernet",
+	.bind = ax88772b_bind,
+	.unbind = ax88772b_unbind,
+	.status = ax88772b_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772b_rx_fixup,
+	.tx_fixup = ax88772b_tx_fixup,
+};
+
+static const struct usb_device_id	products[] = {
 {
-	// Linksys USB200M
-	USB_DEVICE (0x077b, 0x2226),
+	/* 88178 */
+	USB_DEVICE(0x0b95, 0x1780),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* 88178 for billianton linksys */
+	USB_DEVICE(0x077b, 0x2226),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* ABOCOM for linksys */
+	USB_DEVICE(0x1737, 0x0039),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* ABOCOM  for pci */
+	USB_DEVICE(0x14ea, 0xab11),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* Belkin */
+	USB_DEVICE(0x050d, 0x5055),
+	.driver_info =	(unsigned long) &belkin178_info,
+}, {
+	/* Linksys USB200M */
+	USB_DEVICE(0x077b, 0x2226),
 	.driver_info =	(unsigned long) &ax8817x_info,
 }, {
-	// Netgear FA120
-	USB_DEVICE (0x0846, 0x1040),
+	/* Netgear FA120 */
+	USB_DEVICE(0x0846, 0x1040),
 	.driver_info =  (unsigned long) &netgear_fa120_info,
 }, {
-	// DLink DUB-E100
-	USB_DEVICE (0x2001, 0x1a00),
+	/* DLink DUB-E100 */
+	USB_DEVICE(0x2001, 0x1a00),
 	.driver_info =  (unsigned long) &dlink_dub_e100_info,
 }, {
-	// Intellinet, ST Lab USB Ethernet
-	USB_DEVICE (0x0b95, 0x1720),
+	/* DLink DUB-E100B */
+	USB_DEVICE(0x2001, 0x3c05),
+	.driver_info =  (unsigned long) &dlink_dub_e100b_info,
+}, {
+	/* DLink DUB-E100B */
+	USB_DEVICE(0x07d1, 0x3c05),
+	.driver_info =  (unsigned long) &dlink_dub_e100b_info,
+}, {
+	/* Intellinet, ST Lab USB Ethernet */
+	USB_DEVICE(0x0b95, 0x1720),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Hawking UF200, TrendNet TU2-ET100
-	USB_DEVICE (0x07b8, 0x420a),
+	/* Hawking UF200, TrendNet TU2-ET100 */
+	USB_DEVICE(0x07b8, 0x420a),
 	.driver_info =  (unsigned long) &hawking_uf200_info,
 }, {
-	// Billionton Systems, USB2AR
-	USB_DEVICE (0x08dd, 0x90ff),
+	/* Billionton Systems, USB2AR */
+	USB_DEVICE(0x08dd, 0x90ff),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// ATEN UC210T
-	USB_DEVICE (0x0557, 0x2009),
+	/* ATEN UC210T */
+	USB_DEVICE(0x0557, 0x2009),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Buffalo LUA-U2-KTX
-	USB_DEVICE (0x0411, 0x003d),
+	/* Buffalo LUA-U2-KTX */
+	USB_DEVICE(0x0411, 0x003d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Buffalo LUA-U2-GT 10/100/1000
-	USB_DEVICE (0x0411, 0x006e),
-	.driver_info =  (unsigned long) &ax88178_info,
-}, {
-	// Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter"
-	USB_DEVICE (0x6189, 0x182d),
+	/* Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter" */
+	USB_DEVICE(0x6189, 0x182d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// corega FEther USB2-TX
-	USB_DEVICE (0x07aa, 0x0017),
+	/* corega FEther USB2-TX */
+	USB_DEVICE(0x07aa, 0x0017),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Surecom EP-1427X-2
-	USB_DEVICE (0x1189, 0x0893),
-	.driver_info = (unsigned long) &ax8817x_info,
-}, {
-	// goodway corp usb gwusb2e
-	USB_DEVICE (0x1631, 0x6200),
+	/* Surecom EP-1427X-2 */
+	USB_DEVICE(0x1189, 0x0893),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
-	// JVC MP-PRX1 Port Replicator
-	USB_DEVICE (0x04f1, 0x3008),
+	/* goodway corp usb gwusb2e */
+	USB_DEVICE(0x1631, 0x6200),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
-	// ASIX AX88772B 10/100
-	USB_DEVICE (0x0b95, 0x772b),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// ASIX AX88772 10/100
-	USB_DEVICE (0x0b95, 0x7720),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// ASIX AX88178 10/100/1000
-	USB_DEVICE (0x0b95, 0x1780),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// Logitec LAN-GTJ/U2A
-	USB_DEVICE (0x0789, 0x0160),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// Linksys USB200M Rev 2
-	USB_DEVICE (0x13b1, 0x0018),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// 0Q0 cable ethernet
-	USB_DEVICE (0x1557, 0x7720),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// DLink DUB-E100 H/W Ver B1
-	USB_DEVICE (0x07d1, 0x3c05),
+	/* ASIX AX88772 10/100 */
+	USB_DEVICE(0x0b95, 0x7720),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// DLink DUB-E100 H/W Ver B1 Alternate
-	USB_DEVICE (0x2001, 0x3c05),
+	/* ASIX AX88772 10/100 */
+	USB_DEVICE(0x125E, 0x180D),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// Linksys USB1000
-	USB_DEVICE (0x1737, 0x0039),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// IO-DATA ETG-US2
-	USB_DEVICE (0x04bb, 0x0930),
-	.driver_info = (unsigned long) &ax88178_info,
+	/* ASIX AX88772A 10/100 */
+	USB_DEVICE(0x0b95, 0x772A),
+	.driver_info = (unsigned long) &ax88772a_info,
+}, {
+	/* ASIX AX88772A 10/100 */
+	USB_DEVICE(0x0db0, 0xA877),
+	.driver_info = (unsigned long) &ax88772a_info,
+}, {
+	/* ASIX AX88772A 10/100 */
+	USB_DEVICE(0x0421, 0x772A),
+	.driver_info = (unsigned long) &ax88772a_info,
+}, {
+	/* Linksys 200M */
+	USB_DEVICE(0x13B1, 0x0018),
+	.driver_info = (unsigned long) &ax88772a_info,
 }, {
-	// Belkin F5D5055
-	USB_DEVICE(0x050d, 0x5055),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// Apple USB Ethernet Adapter
 	USB_DEVICE(0x05ac, 0x1402),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// Cables-to-Go USB Ethernet Adapter
-	USB_DEVICE(0x0b95, 0x772a),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// ABOCOM for pci
-	USB_DEVICE(0x14ea, 0xab11),
-	.driver_info = (unsigned long) &ax88178_info,
+	.driver_info = (unsigned long) &ax88772a_info,
 }, {
-	// ASIX 88772a
-	USB_DEVICE(0x0db0, 0xa877),
-	.driver_info = (unsigned long) &ax88772_info,
+	/* ASIX AX88772B 10/100 */
+	USB_DEVICE(0x0b95, 0x772B),
+	.driver_info = (unsigned long) &ax88772b_info,
+}, {
+	/* ASIX AX88772B 10/100 */
+	USB_DEVICE(0x0b95, 0x7E2B),
+	.driver_info = (unsigned long) &ax88772b_info,
 },
-	{ },		// END
+	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);

 static struct usb_driver asix_driver = {
-	.name =		"asix",
+	.name =		driver_name,
 	.id_table =	products,
 	.probe =	usbnet_probe,
-	.suspend =	usbnet_suspend,
-	.resume =	usbnet_resume,
+	.suspend =	ax_suspend,
+	.resume =	ax_resume,
 	.disconnect =	usbnet_disconnect,
-	.supports_autosuspend = 1,
 };

 static int __init asix_init(void)
 {
- 	return usb_register(&asix_driver);
+	return usb_register(&asix_driver);
 }
 module_init(asix_init);

 static void __exit asix_exit(void)
 {
- 	usb_deregister(&asix_driver);
+	usb_deregister(&asix_driver);
 }
 module_exit(asix_exit);

--- pristine/drivers/net/usb/asix.h	1969-12-31 19:00:00.000000000 -0500
+++ linux/drivers/net/usb/asix.h	2011-11-02 15:15:34.099164264 -0400
@@ -0,0 +1,526 @@
+#ifndef	__LINUX_USBNET_ASIX_H
+#define	__LINUX_USBNET_ASIX_H
+
+/*
+ * Turn on this flag if the implementation of your USB host controller
+ * cannot handle non-double word aligned buffer.
+ * When turn on this flag, driver will fixup egress packet aligned on double
+ * word boundary before deliver to USB host controller. And will Disable the
+ * function "skb_reserve (skb, NET_IP_ALIGN)" to retain the buffer aligned on
+ * double word alignment for ingress packets.
+ */
+#define AX_FORCE_BUFF_ALIGN		0
+
+#define AX_MONITOR_MODE			0x01
+#define AX_MONITOR_LINK			0x02
+#define AX_MONITOR_MAGIC		0x04
+#define AX_MONITOR_HSFS			0x10
+
+/* AX88172 Medium Status Register values */
+#define AX_MEDIUM_FULL_DUPLEX		0x02
+#define AX_MEDIUM_TX_ABORT_ALLOW	0x04
+#define AX_MEDIUM_FLOW_CONTROL_EN	0x10
+#define AX_MCAST_FILTER_SIZE		8
+#define AX_MAX_MCAST			64
+
+#define AX_EEPROM_LEN			0x40
+
+#define AX_SWRESET_CLEAR		0x00
+#define AX_SWRESET_RR			0x01
+#define AX_SWRESET_RT			0x02
+#define AX_SWRESET_PRTE			0x04
+#define AX_SWRESET_PRL			0x08
+#define AX_SWRESET_BZ			0x10
+#define AX_SWRESET_IPRL			0x20
+#define AX_SWRESET_IPPD			0x40
+#define AX_SWRESET_IPOSC		0x0080
+#define AX_SWRESET_IPPSL_0		0x0100
+#define AX_SWRESET_IPPSL_1		0x0200
+#define AX_SWRESET_IPCOPS		0x0400
+#define AX_SWRESET_IPCOPSC		0x0800
+#define AX_SWRESET_AUTODETACH		0x1000
+#define AX_SWRESET_WOLLP		0x8000
+
+#define AX88772_IPG0_DEFAULT		0x15
+#define AX88772_IPG1_DEFAULT		0x0c
+#define AX88772_IPG2_DEFAULT		0x0E
+
+#define AX88772A_IPG0_DEFAULT		0x15
+#define AX88772A_IPG1_DEFAULT		0x16
+#define AX88772A_IPG2_DEFAULT		0x1A
+
+#define AX88772_MEDIUM_FULL_DUPLEX	0x0002
+#define AX88772_MEDIUM_RESERVED		0x0004
+#define AX88772_MEDIUM_RX_FC_ENABLE	0x0010
+#define AX88772_MEDIUM_TX_FC_ENABLE	0x0020
+#define AX88772_MEDIUM_PAUSE_FORMAT	0x0080
+#define AX88772_MEDIUM_RX_ENABLE	0x0100
+#define AX88772_MEDIUM_100MB		0x0200
+#define AX88772_MEDIUM_DEFAULT	\
+	(AX88772_MEDIUM_FULL_DUPLEX  | AX88772_MEDIUM_RX_FC_ENABLE | \
+	 AX88772_MEDIUM_TX_FC_ENABLE | AX88772_MEDIUM_100MB | \
+	 AX88772_MEDIUM_RESERVED     | AX88772_MEDIUM_RX_ENABLE)
+
+#define AX_CMD_SET_SW_MII		0x06
+#define AX_CMD_READ_MII_REG		0x07
+#define AX_CMD_WRITE_MII_REG		0x08
+#define AX_CMD_SET_HW_MII		0x0a
+#define AX_CMD_READ_EEPROM		0x0b
+#define AX_CMD_WRITE_EEPROM		0x0c
+#define AX_CMD_WRITE_EEPROM_EN		0x0d
+#define AX_CMD_WRITE_EEPROM_DIS		0x0e
+#define AX_CMD_WRITE_RX_CTL		0x10
+#define AX_CMD_READ_IPG012		0x11
+#define AX_CMD_WRITE_IPG0		0x12
+#define AX_CMD_WRITE_IPG1		0x13
+#define AX_CMD_WRITE_IPG2		0x14
+#define AX_CMD_WRITE_MULTI_FILTER	0x16
+#define AX_CMD_READ_NODE_ID		0x17
+#define AX_CMD_READ_PHY_ID		0x19
+#define AX_CMD_READ_MEDIUM_MODE		0x1a
+#define AX_CMD_WRITE_MEDIUM_MODE	0x1b
+#define AX_CMD_READ_MONITOR_MODE	0x1c
+#define AX_CMD_WRITE_MONITOR_MODE	0x1d
+#define AX_CMD_WRITE_GPIOS		0x1f
+#define AX_CMD_SW_RESET			0x20
+#define AX_CMD_SW_PHY_STATUS		0x21
+#define AX_CMD_SW_PHY_SELECT		0x22
+	#define AX_PHYSEL_PSEL		(1 << 0)
+	#define AX_PHYSEL_ASEL		(1 << 1)
+	#define AX_PHYSEL_SSMII		(1 << 2)
+	#define AX_PHYSEL_SSRMII	(2 << 2)
+	#define AX_PHYSEL_SSRRMII	(3 << 2)
+	#define AX_PHYSEL_SSEN		(1 << 4)
+#define AX88772_CMD_READ_NODE_ID	0x13
+#define AX88772_CMD_WRITE_NODE_ID	0x14
+#define AX_CMD_READ_RXCOE_CTL		0x2b
+#define AX_CMD_WRITE_RXCOE_CTL		0x2c
+#define AX_CMD_READ_TXCOE_CTL		0x2d
+#define AX_CMD_WRITE_TXCOE_CTL		0x2e
+
+#define REG_LENGTH			2
+#define PHY_ID_MASK			0x1f
+
+#define AX_RXCOE_IPCE			0x0001
+#define AX_RXCOE_IPVE			0x0002
+#define AX_RXCOE_V6VE			0x0004
+#define AX_RXCOE_TCPE			0x0008
+#define AX_RXCOE_UDPE			0x0010
+#define AX_RXCOE_ICMP			0x0020
+#define AX_RXCOE_IGMP			0x0040
+#define AX_RXCOE_ICV6			0x0080
+#define AX_RXCOE_TCPV6			0x0100
+#define AX_RXCOE_UDPV6			0x0200
+#define AX_RXCOE_ICMV6			0x0400
+#define AX_RXCOE_IGMV6			0x0800
+#define AX_RXCOE_ICV6V6			0x1000
+#define AX_RXCOE_FOPC			0x8000
+#define AX_RXCOE_DEF_CSUM		(AX_RXCOE_IPCE  | AX_RXCOE_IPVE  | \
+					 AX_RXCOE_V6VE  | AX_RXCOE_TCPE  | \
+					 AX_RXCOE_UDPE  | AX_RXCOE_ICV6  | \
+					 AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6)
+
+#define AX_RXCOE_64TE			0x0100
+#define AX_RXCOE_PPPOE			0x0200
+#define AX_RXCOE_RPCE			0x8000
+
+#define AX_TXCOE_IP			0x0001
+#define AX_TXCOE_TCP			0x0002
+#define AX_TXCOE_UDP			0x0004
+#define AX_TXCOE_ICMP			0x0008
+#define AX_TXCOE_IGMP			0x0010
+#define AX_TXCOE_ICV6			0x0020
+
+#define AX_TXCOE_TCPV6			0x0100
+#define AX_TXCOE_UDPV6			0x0200
+#define AX_TXCOE_ICMV6			0x0400
+#define AX_TXCOE_IGMV6			0x0800
+#define AX_TXCOE_ICV6V6			0x1000
+#define AX_TXCOE_DEF_CSUM		(AX_TXCOE_TCP   | AX_TXCOE_UDP | \
+					 AX_TXCOE_TCPV6 | AX_TXCOE_UDPV6)
+
+#define AX_TXCOE_64TE			0x0001
+#define AX_TXCOE_PPPE			0x0002
+
+#define AX88772B_MAX_BULKIN_2K		0
+#define AX88772B_MAX_BULKIN_4K		1
+#define AX88772B_MAX_BULKIN_6K		2
+#define AX88772B_MAX_BULKIN_8K		3
+#define AX88772B_MAX_BULKIN_16K		4
+#define AX88772B_MAX_BULKIN_20K		5
+#define AX88772B_MAX_BULKIN_24K		6
+#define AX88772B_MAX_BULKIN_32K		7
+
+struct {unsigned short size, byte_cnt, threshold; } AX88772B_BULKIN_SIZE[] = {
+	{2048, 0x8000, 0x8001},		/* 2k */
+	{4096, 0x8100, 0x8147},		/* 4k */
+	{6144, 0x8200, 0x81EB},		/* 6k */
+	{8192, 0x8300, 0x83D7},		/* 8k */
+	{16384, 0x8400, 0x851E},	/* 16 */
+	{20480, 0x8500, 0x8666},	/* 20k */
+	{24576, 0x8600, 0x87AE},	/* 24k */
+	{32768, 0x8700, 0x8A3D},	/* 32k */
+};
+
+
+#define AX_RX_CTL_RH1M		0x0100	/* Enable RX-Header mode 0 */
+#define AX_RX_CTL_RH2M		0x0200	/* Enable IP header in receive buffer
+					   aligned on 32-bit aligment */
+#define AX_RX_CTL_RH3M		0x0400	/* checksum value in rx header 3 */
+#define AX_RX_HEADER_DEFAULT	(AX_RX_CTL_RH1M | AX_RX_CTL_RH2M)
+
+#define AX_RX_CTL_MFB		0x0300	/* Maximum Frame size 16384bytes */
+#define AX_RX_CTL_START		0x0080	/* Ethernet MAC start */
+#define AX_RX_CTL_AP		0x0020	/* Accept phys addr from mcast array */
+#define AX_RX_CTL_AM		0x0010
+#define AX_RX_CTL_AB		0x0008	/* Accetp Brocadcast frames*/
+#define AX_RX_CTL_SEP		0x0004	/* Save error packets */
+#define AX_RX_CTL_AMALL		0x0002	/* Accetp all multicast frames */
+#define AX_RX_CTL_PRO		0x0001	/* Promiscuous Mode */
+#define AX_RX_CTL_STOP		0x0000	/* Stop MAC */
+
+#define AX_MONITOR_MODE		0x01
+#define AX_MONITOR_LINK		0x02
+#define AX_MONITOR_MAGIC	0x04
+#define AX_MONITOR_HSFS		0x10
+
+#define AX_MCAST_FILTER_SIZE	8
+#define AX_MAX_MCAST		64
+#define AX_INTERRUPT_BUFSIZE	8
+
+#define AX_EEPROM_LEN		0x40
+#define AX_EEPROM_MAGIC		0xdeadbeef
+#define EEPROMMASK		0x7f
+
+/* GPIO REGISTER */
+#define AXGPIOS_GPO0EN		(1 << 0)
+#define AXGPIOS_GPO0		(1 << 1)
+#define AXGPIOS_GPO1EN		(1 << 2)
+#define AXGPIOS_GPO1		(1 << 3)
+#define AXGPIOS_GPO2EN		(1 << 4)
+#define AXGPIOS_GPO2		(1 << 5)
+#define AXGPIOS_RSE		(1 << 7)
+
+/* TX-header format */
+#define AX_TX_HDR_CPHI		0x4000
+#define AX_TX_HDR_DICF		0x8000
+
+/* GMII register numbers */
+#define GMII_PHY_CONTROL		0x00	/* control */
+#define GMII_PHY_STATUS			0x01	/* status */
+#define GMII_PHY_OUI			0x02	/* most of the OUI bits */
+#define GMII_PHY_MODEL			0x03	/* model/rev & rest of OUI */
+#define GMII_PHY_ANAR			0x04	/* AN advertisement */
+#define GMII_PHY_ANLPAR			0x05	/* AN Link Partner */
+#define GMII_PHY_ANER			0x06	/* AN expansion */
+#define GMII_PHY_1000BT_CONTROL		0x09	/* control for 1000BT */
+#define GMII_PHY_1000BT_STATUS		0x0A	/* status for 1000BT */
+
+/* Bit definitions: GMII Control */
+#define GMII_CONTROL_RESET		0x8000	/* reset bit in control reg */
+#define GMII_CONTROL_LOOPBACK		0x4000	/* loopback in control reg */
+#define GMII_CONTROL_10MB		0x0000	/* 10 Mbit */
+#define GMII_CONTROL_100MB		0x2000	/* 100Mbit */
+#define GMII_CONTROL_1000MB		0x0040	/* 1000Mbit */
+#define GMII_CONTROL_SPEED_BITS		0x2040	/* speed bit mask */
+#define GMII_CONTROL_ENABLE_AUTO	0x1000	/* autonegotiate enable */
+#define GMII_CONTROL_POWER_DOWN		0x0800
+#define GMII_CONTROL_ISOLATE		0x0400	/* islolate bit */
+#define GMII_CONTROL_START_AUTO		0x0200	/* restart autonegotiate */
+#define GMII_CONTROL_FULL_DUPLEX	0x0100
+
+/* Bit definitions: GMII Status */
+#define GMII_STATUS_100MB_MASK		0xE000	/* any indicates 100 Mbit */
+#define GMII_STATUS_10MB_MASK		0x1800	/* either indicates 10 Mbit */
+#define GMII_STATUS_AUTO_DONE		0x0020	/* auto neg complete */
+#define GMII_STATUS_AUTO		0x0008	/* auto neg is available */
+#define GMII_STATUS_LINK_UP		0x0004	/* link status bit */
+#define GMII_STATUS_EXTENDED		0x0001	/* extended regs exist */
+#define GMII_STATUS_100T4		0x8000	/* 100BT4 capable */
+#define GMII_STATUS_100TXFD		0x4000	/* 100BTX full duplex capable */
+#define GMII_STATUS_100TX		0x2000	/* 100BTX capable */
+#define GMII_STATUS_10TFD		0x1000	/* 10BT full duplex capable */
+#define GMII_STATUS_10T			0x0800	/* 10BT capable */
+
+/* Bit definitions: Auto-Negotiation Advertisement */
+#define GMII_ANAR_ASYM_PAUSE		0x0800	/* support asymetric pause */
+#define GMII_ANAR_PAUSE			0x0400	/* support pause packets */
+#define GMII_ANAR_100T4			0x0200	/* support 100BT4 */
+#define GMII_ANAR_100TXFD		0x0100	/* support 100BTX full duplex */
+#define GMII_ANAR_100TX			0x0080	/* support 100BTX half duplex */
+#define GMII_ANAR_10TFD			0x0040	/* support 10BT full duplex */
+#define GMII_ANAR_10T			0x0020	/* support 10BT half duplex */
+#define GMII_SELECTOR_FIELD		0x001F	/* selector field. */
+
+/* Bit definitions: Auto-Negotiation Link Partner Ability */
+#define GMII_ANLPAR_100T4		0x0200	/* support 100BT4 */
+#define GMII_ANLPAR_100TXFD		0x0100	/* support 100BTX full duplex */
+#define GMII_ANLPAR_100TX		0x0080	/* support 100BTX half duplex */
+#define GMII_ANLPAR_10TFD		0x0040	/* support 10BT full duplex */
+#define GMII_ANLPAR_10T			0x0020	/* support 10BT half duplex */
+#define GMII_ANLPAR_PAUSE		0x0400	/* support pause packets */
+#define GMII_ANLPAR_ASYM_PAUSE		0x0800	/* support asymetric pause */
+#define GMII_ANLPAR_ACK			0x4000	/* LCB successfully rx'd */
+#define GMII_SELECTOR_8023		0x0001;
+
+/* Bit definitions: 1000BaseT AUX Control.
+ * FD="Full-Duplex", HD="Half-Duplex"
+ */
+#define GMII_1000_AUX_CTRL_MASTER_SLAVE		0x1000
+#define GMII_1000_AUX_CTRL_FD_CAPABLE		0x0200
+#define GMII_1000_AUX_CTRL_HD_CAPABLE		0x0100
+
+/* Bit definitions: 1000BaseT AUX Status */
+#define GMII_1000_AUX_STATUS_FD_CAPABLE		0x0800
+#define GMII_1000_AUX_STATUS_HD_CAPABLE		0x0400
+
+/* Cicada MII Registers */
+#define GMII_AUX_CTRL_STATUS			0x1C
+#define GMII_AUX_ANEG_CPLT			0x8000
+#define GMII_AUX_FDX				0x0020
+#define GMII_AUX_SPEED_1000			0x0010
+#define GMII_AUX_SPEED_100			0x0008
+
+#ifndef ADVERTISE_PAUSE_CAP
+#define ADVERTISE_PAUSE_CAP			0x0400
+#endif
+
+#ifndef MII_STAT1000
+#define MII_STAT1000				0x000A
+#endif
+
+#ifndef LPA_1000FULL
+#define LPA_1000FULL				0x0800
+#endif
+
+/* medium mode register */
+#define MEDIUM_GIGA_MODE			0x0001
+#define MEDIUM_FULL_DUPLEX_MODE			0x0002
+#define MEDIUM_TX_ABORT_MODE			0x0004
+#define MEDIUM_ENABLE_125MHZ			0x0008
+#define MEDIUM_ENABLE_RX_FLOWCTRL		0x0010
+#define MEDIUM_ENABLE_TX_FLOWCTRL		0x0020
+#define MEDIUM_ENABLE_JUMBO_FRAME		0x0040
+#define MEDIUM_CHECK_PAUSE_FRAME_MODE		0x0080
+#define MEDIUM_ENABLE_RECEIVE			0x0100
+#define MEDIUM_MII_100M_MODE			0x0200
+#define MEDIUM_ENABLE_JAM_PATTERN		0x0400
+#define MEDIUM_ENABLE_STOP_BACKPRESSURE		0x0800
+#define MEDIUM_ENABLE_SUPPER_MAC_SUPPORT	0x1000
+
+/* PHY mode */
+#define PHY_MODE_MARVELL		0
+#define PHY_MODE_CICADA_FAMILY		1
+#define PHY_MODE_CICADA_V1		1
+#define PHY_MODE_AGERE_FAMILY		2
+#define PHY_MODE_AGERE_V0		2
+#define PHY_MODE_CICADA_V2		5
+#define PHY_MODE_AGERE_V0_GMII		6
+#define PHY_MODE_CICADA_V2_ASIX		9
+#define PHY_MODE_VSC8601		10
+#define PHY_MODE_RTL8211CL		12
+#define PHY_MODE_RTL8211BN		13
+#define PHY_MODE_RTL8251CL		14
+#define PHY_MODE_ATTANSIC_V0		0x40
+#define PHY_MODE_ATTANSIC_FAMILY	0x40
+#define PHY_MODE_MAC_TO_MAC_GMII	0x7C
+
+/*  */
+#define LED_MODE_MARVELL		0
+#define LED_MODE_CAMEO			1
+
+#define MARVELL_LED_CTRL		0x18
+#define MARVELL_MANUAL_LED		0x19
+
+#define PHY_IDENTIFIER			0x0002
+#define PHY_AGERE_IDENTIFIER		0x0282
+#define PHY_CICADA_IDENTIFIER		0x000f
+#define PHY_MARVELL_IDENTIFIER		0x0141
+
+#define PHY_MARVELL_STATUS		0x001b
+#define MARVELL_STATUS_HWCFG		0x0004	/* SGMII without clock */
+
+#define PHY_MARVELL_CTRL		0x0014
+#define MARVELL_CTRL_RXDELAY		0x0080
+#define MARVELL_CTRL_TXDELAY		0x0002
+
+#define PHY_CICADA_EXTPAGE		0x001f
+#define CICADA_EXTPAGE_EN		0x0001
+#define CICADA_EXTPAGE_DIS		0x0000
+
+
+struct {unsigned short value, offset; } CICADA_FAMILY_HWINIT[] = {
+	{0x0001, 0x001f}, {0x1c25, 0x0017}, {0x2a30, 0x001f}, {0x234c, 0x0010},
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0xa7fa, 0x0000},
+	{0x0012, 0x0002}, {0x3002, 0x0001}, {0x87fa, 0x0000}, {0x52b5, 0x001f},
+	{0xafac, 0x0000}, {0x000d, 0x0002}, {0x001c, 0x0001}, {0x8fac, 0x0000},
+	{0x2a30, 0x001f}, {0x0012, 0x0008}, {0x2a30, 0x001f}, {0x0400, 0x0014},
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0xa760, 0x0000},
+	{0x0000, 0x0002}, {0xfaff, 0x0001}, {0x8760, 0x0000}, {0x52b5, 0x001f},
+	{0xa760, 0x0000}, {0x0000, 0x0002}, {0xfaff, 0x0001}, {0x8760, 0x0000},
+	{0x52b5, 0x001f}, {0xafae, 0x0000}, {0x0004, 0x0002}, {0x0671, 0x0001},
+	{0x8fae, 0x0000}, {0x2a30, 0x001f}, {0x0012, 0x0008}, {0x0000, 0x001f},
+};
+
+struct {unsigned short value, offset; } CICADA_V2_HWINIT[] = {
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0x000f, 0x0002},
+	{0x472a, 0x0001}, {0x8fa4, 0x0000}, {0x2a30, 0x001f}, {0x0212, 0x0008},
+	{0x0000, 0x001f},
+};
+
+struct {unsigned short value, offset; } CICADA_V2_ASIX_HWINIT[] = {
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0x0012, 0x0002},
+	{0x3002, 0x0001}, {0x87fa, 0x0000}, {0x52b5, 0x001f}, {0x000f, 0x0002},
+	{0x472a, 0x0001}, {0x8fa4, 0x0000}, {0x2a30, 0x001f}, {0x0212, 0x0008},
+	{0x0000, 0x001f},
+};
+
+struct {unsigned short value, offset; } AGERE_FAMILY_HWINIT[] = {
+	{0x0800, 0x0000}, {0x0007, 0x0012}, {0x8805, 0x0010}, {0xb03e, 0x0011},
+	{0x8808, 0x0010}, {0xe110, 0x0011}, {0x8806, 0x0010}, {0xb03e, 0x0011},
+	{0x8807, 0x0010}, {0xff00, 0x0011}, {0x880e, 0x0010}, {0xb4d3, 0x0011},
+	{0x880f, 0x0010}, {0xb4d3, 0x0011}, {0x8810, 0x0010}, {0xb4d3, 0x0011},
+	{0x8817, 0x0010}, {0x1c00, 0x0011}, {0x300d, 0x0010}, {0x0001, 0x0011},
+	{0x0002, 0x0012},
+};
+
+struct ax88178_data {
+	u16	EepromData;
+	u16	MediaLink;
+	int	UseGpio0;
+	int	UseRgmii;
+	u8	PhyMode;
+	u8	LedMode;
+	u8	BuffaloOld;
+};
+
+enum watchdog_state {
+	AX_NOP = 0,
+	CHK_LINK,			/* Routine A */
+	CHK_CABLE_EXIST,		/* Called by A */
+	CHK_CABLE_EXIST_AGAIN,		/* Routine B */
+	PHY_POWER_UP,			/* Called by B */
+	PHY_POWER_UP_BH,
+	PHY_POWER_DOWN,
+	CHK_CABLE_STATUS,		/* Routine C */
+	WAIT_AUTONEG_COMPLETE,
+	AX_SET_RX_CFG,
+};
+
+struct ax88772b_data {
+	struct usbnet *dev;
+	struct workqueue_struct *ax_work;
+	struct work_struct check_link;
+	unsigned long time_to_chk;
+	u16 psc;
+	u8 pw_enabled;
+	u8 Event;
+	u8 checksum;
+};
+
+struct ax88772a_data {
+	struct usbnet *dev;
+	struct workqueue_struct *ax_work;
+	struct work_struct check_link;
+	unsigned long autoneg_start;
+#define AX88772B_WATCHDOG	(6 * HZ)
+	u8 Event;
+	u8 TickToExpire;
+	u8 DlyIndex;
+	u8 DlySel;
+	u16 EepromData;
+};
+
+struct ax88772_data {
+	struct usbnet *dev;
+	struct workqueue_struct *ax_work;
+	struct work_struct check_link;
+	unsigned long autoneg_start;
+	u8 Event;
+	u8 TickToExpire;
+};
+
+#define AX_RX_CHECKSUM		1
+#define AX_TX_CHECKSUM		2
+
+/* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
+struct ax8817x_data {
+	u8 multi_filter[AX_MCAST_FILTER_SIZE];
+	int (*resume) (struct usb_interface *intf);
+	int (*suspend) (struct usb_interface *intf, pm_message_t message);
+};
+
+struct __packed ax88172_int_data {
+	u16 res1;
+#define AX_INT_PPLS_LINK	(1 << 0)
+#define AX_INT_SPLS_LINK	(1 << 1)
+#define AX_INT_CABOFF_UNPLUG	(1 << 7)
+	u8 link;
+	u16 res2;
+	u8 status;
+	u16 res3;
+};
+
+#define AX_RXHDR_L4_ERR		(1 << 8)
+#define AX_RXHDR_L3_ERR		(1 << 9)
+
+#define AX_RXHDR_L4_TYPE_UDP		1
+#define AX_RXHDR_L4_TYPE_ICMP		2
+#define AX_RXHDR_L4_TYPE_IGMP		3
+#define AX_RXHDR_L4_TYPE_TCP		4
+#define AX_RXHDR_L4_TYPE_TCMPV6		5
+#define AX_RXHDR_L4_TYPE_MASK		7
+
+#define AX_RXHDR_L3_TYPE_IP		1
+#define AX_RXHDR_L3_TYPE_IPV6		2
+
+struct __packed ax88772b_rx_header {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u16	len:11,
+		res1:1,
+		crc:1,
+		mii:1,
+		runt:1,
+		mc_bc:1;
+
+	u16	len_bar:11,
+		res2:5;
+
+	u8	vlan_ind:3,
+		vlan_tag_striped:1,
+		pri:3,
+		res3:1;
+
+	u8	l4_csum_err:1,
+		l3_csum_err:1,
+		l4_type:3,
+		l3_type:2,
+		ce:1;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	u16	mc_bc:1,
+		runt:1,
+		mii:1,
+		crc:1,
+		res1:1,
+		len:11;
+
+	u16	res2:5,
+		len_bar:11;
+
+	u8	res3:1,
+		pri:3,
+		vlan_tag_striped:1,
+		vlan_ind:3;
+
+	u8	ce:1,
+		l3_type:2,
+		l4_type:3,
+		l3_csum_err:1,
+		l4_csum_err:1;
+#else
+#error	"Please fix <asm/byteorder.h>"
+#endif
+};
+
+#endif /* __LINUX_USBNET_ASIX_H */
+

--------------030107060700060006000702
Content-Type: text/x-patch;
 name="30_asix_vendor_driver.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="30_asix_vendor_driver.patch"

First cut (for review) at updating the in-kernel asix usb/network driver
from the latest vendor GPL version of the driver, obtained from here:

  http://www.asix.com.tw/download.php?sub=searchresult&PItemID=84&download=driver

The original vendor copy used a local "axusbnet" middleware (rather than "usbnet").
I've converted it back to using "usbnet", made a ton of cosmetic changes
to get it to pass checkpatch.pl, and removed a small amount of code duplication.

It can use more work going forward, but it is important to get it upstream
sooner than later -- the current in-kernel driver fails with many devices,
both old and new.  This updated version works with everything I have available
to test with, and also handles suspend / resume (unlike the in-kernel one).

Signed-off-by: Mark Lord <mlord@pobox.com>

--- linux-3.0/drivers/net/usb/asix.c	2011-10-12 17:59:03.000000000 -0400
+++ linux/drivers/net/usb/asix.c	2011-11-01 19:00:50.051289683 -0400
@@ -20,11 +20,9 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
  */
 
-// #define	DEBUG			// error path messages, extra info
-// #define	VERBOSE			// more; success messages
-
 #include <linux/module.h>
 #include <linux/kmod.h>
+#include <linux/sched.h>
 #include <linux/init.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
@@ -34,404 +32,117 @@
 #include <linux/usb.h>
 #include <linux/crc32.h>
 #include <linux/usb/usbnet.h>
-#include <linux/slab.h>
-
-#define DRIVER_VERSION "14-Jun-2006"
-static const char driver_name [] = "asix";
+#include "asix.h"
 
-/* ASIX AX8817X based USB 2.0 Ethernet Devices */
+#define DRIVER_VERSION	"5.0.0"
+static const char driver_name[] = "asix";
 
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
-		( AX88172_MEDIUM_FD | AX88172_MEDIUM_TX | AX88172_MEDIUM_FC )
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
-	 AX_MEDIUM_RE )
-
-#define AX88772_MEDIUM_DEFAULT	\
-	(AX_MEDIUM_FD | AX_MEDIUM_RFC | \
-	 AX_MEDIUM_TFC | AX_MEDIUM_PS | \
-	 AX_MEDIUM_AC | AX_MEDIUM_RE )
-
-/* AX88772 & AX88178 RX_CTL values */
-#define AX_RX_CTL_SO			0x0080
-#define AX_RX_CTL_AP			0x0020
-#define AX_RX_CTL_AM			0x0010
-#define AX_RX_CTL_AB			0x0008
-#define AX_RX_CTL_SEP			0x0004
-#define AX_RX_CTL_AMALL			0x0002
-#define AX_RX_CTL_PRO			0x0001
-#define AX_RX_CTL_MFB_2048		0x0000
-#define AX_RX_CTL_MFB_4096		0x0100
-#define AX_RX_CTL_MFB_8192		0x0200
-#define AX_RX_CTL_MFB_16384		0x0300
-
-#define AX_DEFAULT_RX_CTL	\
-	(AX_RX_CTL_SO | AX_RX_CTL_AB )
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
-
-#define PHY_MODE_MARVELL	0x0000
-#define MII_MARVELL_LED_CTRL	0x0018
-#define MII_MARVELL_STATUS	0x001b
-#define MII_MARVELL_CTRL	0x0014
-
-#define MARVELL_LED_MANUAL	0x0019
-
-#define MARVELL_STATUS_HWCFG	0x0004
-
-#define MARVELL_CTRL_TXDELAY	0x0002
-#define MARVELL_CTRL_RXDELAY	0x0080
-
-/* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
-struct asix_data {
-	u8 multi_filter[AX_MCAST_FILTER_SIZE];
-	u8 mac_addr[ETH_ALEN];
-	u8 phymode;
-	u8 ledmode;
-	u8 eeprom_len;
-};
+static char driver_version[] =
+	"ASIX USB Ethernet Adapter: v" DRIVER_VERSION \
+	" " __TIME__ " " __DATE__ "\n";
+
+/* configuration of maximum bulk in size */
+static int bsize = AX88772B_MAX_BULKIN_16K;
+module_param(bsize, int, 0);
+MODULE_PARM_DESC(bsize, "Maximum transfer size per bulk");
+
+static void ax88772b_link_reset(struct work_struct *work);
+static void ax88772a_link_reset(struct work_struct *work);
+static void ax88772_link_reset(struct work_struct *work);
+static int ax88772a_phy_powerup(struct usbnet *dev);
 
-struct ax88172_int_data {
-	__le16 res1;
-	u8 link;
-	__le16 res2;
-	u8 status;
-	__le16 res3;
-} __packed;
+/* ASIX AX8817X based USB 2.0 Ethernet Devices */
 
-static int asix_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+static int ax8817x_read_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			    u16 size, void *data)
 {
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
+	return usb_control_msg(
 		dev->udev,
 		usb_rcvctrlpipe(dev->udev, 0),
 		cmd,
 		USB_DIR_IN | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		value,
 		index,
-		buf,
+		data,
 		size,
 		USB_CTRL_GET_TIMEOUT);
-	if (err == size)
-		memcpy(data, buf, size);
-	else if (err >= 0)
-		err = -EINVAL;
-	kfree(buf);
-
-out:
-	return err;
 }
 
-static int asix_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+static int ax8817x_write_cmd(struct usbnet *dev, u8 cmd, u16 value, u16 index,
 			     u16 size, void *data)
 {
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
+	return usb_control_msg(
 		dev->udev,
 		usb_sndctrlpipe(dev->udev, 0),
 		cmd,
 		USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE,
 		value,
 		index,
-		buf,
+		data,
 		size,
 		USB_CTRL_SET_TIMEOUT);
-	kfree(buf);
-
-out:
-	return err;
 }
 
-static void asix_async_cmd_callback(struct urb *urb)
+static void ax8817x_async_cmd_callback(struct urb *urb)
 {
 	struct usb_ctrlrequest *req = (struct usb_ctrlrequest *)urb->context;
-	int status = urb->status;
 
-	if (status < 0)
-		printk(KERN_DEBUG "asix_async_cmd_callback() failed with %d",
-			status);
+	if (urb->status < 0)
+		printk(KERN_DEBUG "ax8817x_async_cmd_callback() failed with %d",
+			urb->status);
 
 	kfree(req);
 	usb_free_urb(urb);
 }
 
-static void
-asix_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
-				    u16 size, void *data)
+static int ax8817x_set_mac_addr(struct net_device *net, void *p)
 {
-	struct usb_ctrlrequest *req;
-	int status;
-	struct urb *urb;
-
-	netdev_dbg(dev->net, "asix_write_cmd_async() cmd=0x%02x value=0x%04x index=0x%04x size=%d\n",
-		   cmd, value, index, size);
-	if ((urb = usb_alloc_urb(0, GFP_ATOMIC)) == NULL) {
-		netdev_err(dev->net, "Error allocating URB in write_cmd_async!\n");
-		return;
-	}
-
-	if ((req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC)) == NULL) {
-		netdev_err(dev->net, "Failed to allocate memory for control request\n");
-		usb_free_urb(urb);
-		return;
-	}
+	struct usbnet *dev = netdev_priv(net);
+	struct sockaddr *addr = p;
 
-	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
-	req->bRequest = cmd;
-	req->wValue = cpu_to_le16(value);
-	req->wIndex = cpu_to_le16(index);
-	req->wLength = cpu_to_le16(size);
+	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
 
-	usb_fill_control_urb(urb, dev->udev,
-			     usb_sndctrlpipe(dev->udev, 0),
-			     (void *)req, data, size,
-			     asix_async_cmd_callback, req);
+	/* Set the MAC address */
+	return ax8817x_write_cmd(dev, AX88772_CMD_WRITE_NODE_ID,
+			   0, 0, ETH_ALEN, net->dev_addr);
 
-	if((status = usb_submit_urb(urb, GFP_ATOMIC)) < 0) {
-		netdev_err(dev->net, "Error submitting the control message: status=%d\n",
-			   status);
-		kfree(req);
-		usb_free_urb(urb);
-	}
 }
 
-static int asix_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+static void ax8817x_status(struct usbnet *dev, struct urb *urb)
 {
-	u8  *head;
-	u32  header;
-	char *packet;
-	struct sk_buff *ax_skb;
-	u16 size;
-
-	head = (u8 *) skb->data;
-	memcpy(&header, head, sizeof(header));
-	le32_to_cpus(&header);
-	packet = head + sizeof(header);
-
-	skb_pull(skb, 4);
-
-	while (skb->len > 0) {
-		if ((short)(header & 0x0000ffff) !=
-		    ~((short)((header & 0xffff0000) >> 16))) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad Header Length\n");
-		}
-		/* get the packet length */
-		size = (u16) (header & 0x0000ffff);
-
-		if ((skb->len) - ((size + 1) & 0xfffe) == 0) {
-			u8 alignment = (unsigned long)skb->data & 0x3;
-			if (alignment != 0x2) {
-				/*
-				 * not 16bit aligned so use the room provided by
-				 * the 32 bit header to align the data
-				 *
-				 * note we want 16bit alignment as MAC header is
-				 * 14bytes thus ip header will be aligned on
-				 * 32bit boundary so accessing ipheader elements
-				 * using a cast to struct ip header wont cause
-				 * an unaligned accesses.
-				 */
-				u8 realignment = (alignment + 2) & 0x3;
-				memmove(skb->data - realignment,
-					skb->data,
-					size);
-				skb->data -= realignment;
-				skb_set_tail_pointer(skb, size);
-			}
-			return 2;
-		}
-
-		if (size > dev->net->mtu + ETH_HLEN) {
-			netdev_err(dev->net, "asix_rx_fixup() Bad RX Length %d\n",
-				   size);
-			return 0;
-		}
-		ax_skb = skb_clone(skb, GFP_ATOMIC);
-		if (ax_skb) {
-			u8 alignment = (unsigned long)packet & 0x3;
-			ax_skb->len = size;
-
-			if (alignment != 0x2) {
-				/*
-				 * not 16bit aligned use the room provided by
-				 * the 32 bit header to align the data
-				 */
-				u8 realignment = (alignment + 2) & 0x3;
-				memmove(packet - realignment, packet, size);
-				packet -= realignment;
-			}
-			ax_skb->data = packet;
-			skb_set_tail_pointer(ax_skb, size);
-			usbnet_skb_return(dev, ax_skb);
-		} else {
-			return 0;
-		}
-
-		skb_pull(skb, (size + 1) & 0xfffe);
+	struct ax88172_int_data *event;
+	int link;
 
-		if (skb->len == 0)
-			break;
+	if (urb->actual_length < 8)
+		return;
 
-		head = (u8 *) skb->data;
-		memcpy(&header, head, sizeof(header));
-		le32_to_cpus(&header);
-		packet = head + sizeof(header);
-		skb_pull(skb, 4);
-	}
+	event = urb->transfer_buffer;
+	link = event->link & 0x01;
 
-	if (skb->len < 0) {
-		netdev_err(dev->net, "asix_rx_fixup() Bad SKB Length %d\n",
-			   skb->len);
-		return 0;
+	if (netif_carrier_ok(dev->net) != link) {
+		if (link) {
+			netif_carrier_on(dev->net);
+			usbnet_defer_kevent(dev, EVENT_LINK_RESET);
+		} else
+			netif_carrier_off(dev->net);
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
-	return 1;
 }
 
-static struct sk_buff *asix_tx_fixup(struct usbnet *dev, struct sk_buff *skb,
-					gfp_t flags)
+static void ax88178_status(struct usbnet *dev, struct urb *urb)
 {
-	int padlen;
-	int headroom = skb_headroom(skb);
-	int tailroom = skb_tailroom(skb);
-	u32 packet_len;
-	u32 padbytes = 0xffff0000;
-
-	padlen = ((skb->len + 4) % 512) ? 0 : 4;
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
+	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;
 
-	if ((skb->len % 512) == 0) {
-		cpu_to_le32s(&padbytes);
-		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
-		skb_put(skb, sizeof(padbytes));
-	}
-	return skb;
+	if (priv->EepromData == PHY_MODE_MAC_TO_MAC_GMII)
+		return;
+	ax8817x_status(dev, urb);
 }
 
-static void asix_status(struct usbnet *dev, struct urb *urb)
+static void ax88772_status(struct usbnet *dev, struct urb *urb)
 {
 	struct ax88172_int_data *event;
+	struct ax88772_data *priv = (struct ax88772_data *)dev->driver_priv;
 	int link;
 
 	if (urb->actual_length < 8)
@@ -439,285 +150,538 @@
 
 	event = urb->transfer_buffer;
 	link = event->link & 0x01;
+
 	if (netif_carrier_ok(dev->net) != link) {
 		if (link) {
 			netif_carrier_on(dev->net);
-			usbnet_defer_kevent (dev, EVENT_LINK_RESET );
-		} else
+			priv->Event = AX_SET_RX_CFG;
+		} else {
 			netif_carrier_off(dev->net);
-		netdev_dbg(dev->net, "Link Status is: %d\n", link);
+			if (priv->Event == AX_NOP) {
+				priv->Event = PHY_POWER_DOWN;
+				priv->TickToExpire = 25;
+			}
+		}
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
-}
 
-static inline int asix_set_sw_mii(struct usbnet *dev)
-{
-	int ret;
-	ret = asix_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to enable software MII access\n");
-	return ret;
+	if (priv->Event)
+		queue_work(priv->ax_work, &priv->check_link);
 }
 
-static inline int asix_set_hw_mii(struct usbnet *dev)
+static void ax88772a_status(struct usbnet *dev, struct urb *urb)
 {
-	int ret;
-	ret = asix_write_cmd(dev, AX_CMD_SET_HW_MII, 0x0000, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to enable hardware MII access\n");
-	return ret;
-}
+	struct ax88172_int_data *event;
+	struct ax88772a_data *priv = (struct ax88772a_data *)dev->driver_priv;
+	int link;
+	int PowSave = (priv->EepromData >> 14);
 
-static inline int asix_get_phy_addr(struct usbnet *dev)
-{
-	u8 buf[2];
-	int ret = asix_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, buf);
+	if (urb->actual_length < 8)
+		return;
 
-	netdev_dbg(dev->net, "asix_get_phy_addr()\n");
+	event = urb->transfer_buffer;
+	link = event->link & 0x01;
 
-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading PHYID register: %02x\n", ret);
-		goto out;
+	if (netif_carrier_ok(dev->net) != link) {
+
+		if (link) {
+			netif_carrier_on(dev->net);
+			priv->Event = AX_SET_RX_CFG;
+		} else if ((PowSave == 0x3) || (PowSave == 0x1)) {
+			netif_carrier_off(dev->net);
+			if (priv->Event == AX_NOP) {
+				priv->Event = CHK_CABLE_EXIST;
+				priv->TickToExpire = 14;
+			}
+		} else {
+			netif_carrier_off(dev->net);
+			priv->Event = AX_NOP;
+		}
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
-	netdev_dbg(dev->net, "asix_get_phy_addr() returning 0x%04x\n",
-		   *((__le16 *)buf));
-	ret = buf[1];
 
-out:
-	return ret;
+	if (priv->Event)
+		queue_work(priv->ax_work, &priv->check_link);
 }
 
-static int asix_sw_reset(struct usbnet *dev, u8 flags)
+static void ax88772b_status(struct usbnet *dev, struct urb *urb)
 {
-	int ret;
-
-        ret = asix_write_cmd(dev, AX_CMD_SW_RESET, flags, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to send software reset: %02x\n", ret);
-
-	return ret;
-}
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+	struct ax88172_int_data *event;
+	int link;
 
-static u16 asix_read_rx_ctl(struct usbnet *dev)
-{
-	__le16 v;
-	int ret = asix_read_cmd(dev, AX_CMD_READ_RX_CTL, 0, 0, 2, &v);
+	if (urb->actual_length < 8)
+		return;
 
-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading RX_CTL register: %02x\n", ret);
-		goto out;
+	event = urb->transfer_buffer;
+	link = event->link & AX_INT_PPLS_LINK;
+	if (netif_carrier_ok(dev->net) != link) {
+		if (link) {
+			netif_carrier_on(dev->net);
+			priv->Event = AX_SET_RX_CFG;
+		} else {
+			netif_carrier_off(dev->net);
+			priv->time_to_chk = jiffies;
+		}
+		netdev_warn(dev->net, "%s: link status is: %d\n",
+						__func__, link);
 	}
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
 
-	return ret;
-}
+	if (!link) {
+		int no_cable = (event->link & AX_INT_CABOFF_UNPLUG) ? 1 : 0;
 
-static u16 asix_read_medium_status(struct usbnet *dev)
-{
-	__le16 v;
-	int ret = asix_read_cmd(dev, AX_CMD_READ_MEDIUM_STATUS, 0, 0, 2, &v);
+		if (no_cable) {
+			if ((priv->psc &
+			    (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1)) &&
+			     !priv->pw_enabled) {
+				/*
+				 * AX88772B already entered power saving state
+				 */
+				priv->pw_enabled = 1;
+			}
 
-	if (ret < 0) {
-		netdev_err(dev->net, "Error reading Medium Status register: %02x\n",
-			   ret);
-		goto out;
+		} else {
+			/* AX88772B resumed from power saving state */
+			if (priv->pw_enabled ||
+				(jiffies >
+				   (priv->time_to_chk + AX88772B_WATCHDOG))) {
+				if (priv->pw_enabled)
+					priv->pw_enabled = 0;
+				priv->Event = PHY_POWER_UP;
+				priv->time_to_chk = jiffies;
+			}
+		}
 	}
-	ret = le16_to_cpu(v);
-out:
-	return ret;
+
+	if (priv->Event)
+		queue_work(priv->ax_work, &priv->check_link);
 }
 
-static int asix_write_medium_mode(struct usbnet *dev, u16 mode)
+static void
+ax8817x_write_cmd_async(struct usbnet *dev, u8 cmd, u16 value, u16 index,
+				    u16 size, void *data)
 {
-	int ret;
-
-	netdev_dbg(dev->net, "asix_write_medium_mode() - mode = 0x%04x\n", mode);
-	ret = asix_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE, mode, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to write Medium Mode mode to 0x%04x: %02x\n",
-			   mode, ret);
+	struct usb_ctrlrequest *req;
+	int status;
+	struct urb *urb;
 
-	return ret;
-}
+	urb = usb_alloc_urb(0, GFP_ATOMIC);
+	if (urb == NULL) {
+		netdev_err(dev->net, "%s: usb_alloc_urb() failed\n", __func__);
+		return;
+	}
 
-static int asix_write_gpio(struct usbnet *dev, u16 value, int sleep)
-{
-	int ret;
+	req = kmalloc(sizeof(struct usb_ctrlrequest), GFP_ATOMIC);
+	if (req == NULL) {
+		netdev_err(dev->net, "%s: kmalloc() failed\n", __func__);
+		usb_free_urb(urb);
+		return;
+	}
 
-	netdev_dbg(dev->net, "asix_write_gpio() - value = 0x%04x\n", value);
-	ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
-	if (ret < 0)
-		netdev_err(dev->net, "Failed to write GPIO value 0x%04x: %02x\n",
-			   value, ret);
+	req->bRequestType = USB_DIR_OUT | USB_TYPE_VENDOR | USB_RECIP_DEVICE;
+	req->bRequest = cmd;
+	req->wValue = cpu_to_le16(value);
+	req->wIndex = cpu_to_le16(index);
+	req->wLength = cpu_to_le16(size);
 
-	if (sleep)
-		msleep(sleep);
+	usb_fill_control_urb(urb, dev->udev,
+			     usb_sndctrlpipe(dev->udev, 0),
+			     (void *)req, data, size,
+			     ax8817x_async_cmd_callback, req);
 
-	return ret;
+	status = usb_submit_urb(urb, GFP_ATOMIC);
+	if (status < 0) {
+		netdev_err(dev->net, "%s: usb_submit_urb() failed, err=%d\n",
+						__func__, status);
+		kfree(req);
+		usb_free_urb(urb);
+	}
 }
 
-/*
- * AX88772 & AX88178 have a 16-bit RX_CTL value
- */
-static void asix_set_multicast(struct net_device *net)
+static void ax8817x_set_multicast(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u16 rx_ctl = AX_DEFAULT_RX_CTL;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	u8 rx_ctl = AX_RX_CTL_START | AX_RX_CTL_AB;
+	int mc_count;
+
+	mc_count = netdev_mc_count(net);
 
 	if (net->flags & IFF_PROMISC) {
 		rx_ctl |= AX_RX_CTL_PRO;
-	} else if (net->flags & IFF_ALLMULTI ||
-		   netdev_mc_count(net) > AX_MAX_MCAST) {
+	} else if (net->flags & IFF_ALLMULTI
+		   || mc_count > AX_MAX_MCAST) {
 		rx_ctl |= AX_RX_CTL_AMALL;
-	} else if (netdev_mc_empty(net)) {
+	} else if (mc_count == 0) {
 		/* just broadcast and directed */
 	} else {
 		/* We use the 20 byte dev->data
 		 * for our 8 byte filter buffer
 		 * to avoid allocating memory that
 		 * is tricky to free later */
-		struct netdev_hw_addr *ha;
 		u32 crc_bits;
-
+		struct netdev_hw_addr *ha;
 		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
-
-		/* Build the multicast hash filter. */
 		netdev_for_each_mc_addr(ha, net) {
 			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
 			data->multi_filter[crc_bits >> 3] |=
-			    1 << (crc_bits & 7);
+				1 << (crc_bits & 7);
 		}
-
-		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
+		ax8817x_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
 				   AX_MCAST_FILTER_SIZE, data->multi_filter);
 
 		rx_ctl |= AX_RX_CTL_AM;
 	}
 
-	asix_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+	ax8817x_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
 }
 
-static int asix_mdio_read(struct net_device *netdev, int phy_id, int loc)
+static void ax88772b_set_multicast(struct net_device *net)
 {
-	struct usbnet *dev = netdev_priv(netdev);
-	__le16 res;
-
-	mutex_lock(&dev->phy_mutex);
-	asix_set_sw_mii(dev);
-	asix_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
-				(__u16)loc, 2, &res);
-	asix_set_hw_mii(dev);
-	mutex_unlock(&dev->phy_mutex);
-
-	netdev_dbg(dev->net, "asix_mdio_read() phy_id=0x%02x, loc=0x%02x, returns=0x%04x\n",
-		   phy_id, loc, le16_to_cpu(res));
-
-	return le16_to_cpu(res);
-}
+	struct usbnet *dev = netdev_priv(net);
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	u16 rx_ctl = (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_HEADER_DEFAULT);
+	int mc_count;
 
-static void
-asix_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
-{
-	struct usbnet *dev = netdev_priv(netdev);
-	__le16 res = cpu_to_le16(val);
+	mc_count = netdev_mc_count(net);
 
-	netdev_dbg(dev->net, "asix_mdio_write() phy_id=0x%02x, loc=0x%02x, val=0x%04x\n",
-		   phy_id, loc, val);
-	mutex_lock(&dev->phy_mutex);
-	asix_set_sw_mii(dev);
-	asix_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id, (__u16)loc, 2, &res);
-	asix_set_hw_mii(dev);
-	mutex_unlock(&dev->phy_mutex);
-}
+	if (net->flags & IFF_PROMISC) {
+		rx_ctl |= AX_RX_CTL_PRO;
+	} else if (net->flags & IFF_ALLMULTI
+		   || mc_count > AX_MAX_MCAST) {
+		rx_ctl |= AX_RX_CTL_AMALL;
+	} else if (mc_count == 0) {
+		/* just broadcast and directed */
+	} else {
+		/* We use the 20 byte dev->data
+		 * for our 8 byte filter buffer
+		 * to avoid allocating memory that
+		 * is tricky to free later */
+		u32 crc_bits;
+
+		struct netdev_hw_addr *ha;
+		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
+		netdev_for_each_mc_addr(ha, net) {
+			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
+			data->multi_filter[crc_bits >> 3] |=
+				1 << (crc_bits & 7);
+		}
+		ax8817x_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
+				   AX_MCAST_FILTER_SIZE, data->multi_filter);
+
+		rx_ctl |= AX_RX_CTL_AM;
+	}
+
+	ax8817x_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+}
 
-/* Get the PHY Identifier from the PHYSID1 & PHYSID2 MII registers */
-static u32 asix_get_phyid(struct usbnet *dev)
+static int ax8817x_mdio_read(struct net_device *netdev, int phy_id, int loc)
 {
-	int phy_reg;
-	u32 phy_id;
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+	u16 ret;
 
-	phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID1);
-	if (phy_reg < 0)
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
 		return 0;
 
-	phy_id = (phy_reg & 0xffff) << 16;
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id, (__u16)loc, 2, res);
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+
+	ret = *res & 0xffff;
+	kfree(res);
+
+	return ret;
+}
+
+static int
+ax8817x_swmii_mdio_read(struct net_device *netdev, int phy_id, int loc)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+	u16 ret;
 
-	phy_reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_PHYSID2);
-	if (phy_reg < 0)
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
 		return 0;
 
-	phy_id |= (phy_reg & 0xffff);
+	ax8817x_read_cmd(dev, AX_CMD_READ_MII_REG, phy_id,
+				(__u16)loc, 2, res);
 
-	return phy_id;
+	ret = *res & 0xffff;
+	kfree(res);
+
+	return ret;
+}
+
+/* same as above, but converts resulting value to cpu byte order */
+static int ax8817x_mdio_read_le(struct net_device *netdev, int phy_id, int loc)
+{
+	return le16_to_cpu(ax8817x_mdio_read(netdev, phy_id, loc));
+}
+
+static int
+ax8817x_swmii_mdio_read_le(struct net_device *netdev, int phy_id, int loc)
+{
+	return le16_to_cpu(ax8817x_swmii_mdio_read(netdev, phy_id, loc));
 }
 
 static void
-asix_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+ax8817x_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
 {
-	struct usbnet *dev = netdev_priv(net);
-	u8 opt;
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
+		return;
+	*res = val;
+
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)loc, 2, res);
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+
+	kfree(res);
+}
 
-	if (asix_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, &opt) < 0) {
-		wolinfo->supported = 0;
-		wolinfo->wolopts = 0;
+static void ax8817x_swmii_mdio_write(struct net_device *netdev,
+			int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
+		return;
+	*res = val;
+
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)loc, 2, res);
+
+	kfree(res);
+}
+
+static void
+ax88772b_mdio_write(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	u16 *res;
+
+	res = kmalloc(2, GFP_ATOMIC);
+	if (!res)
 		return;
+	*res = val;
+
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)loc, 2, res);
+
+	if (loc == MII_ADVERTISE) {
+		*res = cpu_to_le16(BMCR_ANENABLE | BMCR_ANRESTART);
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_MII_REG, phy_id,
+				(__u16)MII_BMCR, 2, res);
 	}
-	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
-	wolinfo->wolopts = 0;
-	if (opt & AX_MONITOR_MODE) {
-		if (opt & AX_MONITOR_LINK)
-			wolinfo->wolopts |= WAKE_PHY;
-		if (opt & AX_MONITOR_MAGIC)
-			wolinfo->wolopts |= WAKE_MAGIC;
+
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+
+	kfree(res);
+}
+
+/* same as above, but converts new value to le16 byte order before writing */
+static void
+ax8817x_mdio_write_le(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	ax8817x_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
+}
+
+static void ax8817x_swmii_mdio_write_le(struct net_device *netdev,
+			int phy_id, int loc, int val)
+{
+	ax8817x_swmii_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
+}
+
+static void
+ax88772b_mdio_write_le(struct net_device *netdev, int phy_id, int loc, int val)
+{
+	ax88772b_mdio_write(netdev, phy_id, loc, cpu_to_le16(val));
+}
+
+static int asix_write_medium_mode(struct usbnet *dev, u16 value)
+{
+	int ret;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_MEDIUM_MODE,
+						value, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "%s (0x%04x) failed, err=%d\n",
+						__func__, value, ret);
+	return ret;
+}
+
+static int ax88772_suspend(struct usb_interface *intf,
+			pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	u16 *medium;
+
+	medium = kmalloc(2, GFP_ATOMIC);
+	if (!medium)
+		return usbnet_suspend(intf, message);
+
+	ax8817x_read_cmd(dev, AX_CMD_READ_MEDIUM_MODE, 0, 0, 2, medium);
+	asix_write_medium_mode(dev, *medium & ~AX88772_MEDIUM_RX_ENABLE);
+
+	kfree(medium);
+	return usbnet_suspend(intf, message);
+}
+
+static int ax88772b_suspend(struct usb_interface *intf,
+			pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+	u16 *tmp16;
+	u8 *opt;
+
+	tmp16 = kmalloc(2, GFP_ATOMIC);
+	if (!tmp16)
+		return usbnet_suspend(intf, message);
+	opt = (u8 *)tmp16;
+
+	ax8817x_read_cmd(dev, AX_CMD_READ_MEDIUM_MODE, 0, 0, 2, tmp16);
+	asix_write_medium_mode(dev, *tmp16 & ~AX88772_MEDIUM_RX_ENABLE);
+
+	ax8817x_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, opt);
+	if (!(*opt & AX_MONITOR_LINK) && !(*opt & AX_MONITOR_MAGIC)) {
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+			AX_SWRESET_IPRL | AX_SWRESET_IPPD, 0, 0, NULL);
+	} else {
+
+		if (priv->psc & AX_SWRESET_WOLLP) {
+			*tmp16 = ax8817x_mdio_read_le(dev->net,
+					dev->mii.phy_id, MII_BMCR);
+			ax8817x_mdio_write_le(dev->net, dev->mii.phy_id,
+					MII_BMCR, *tmp16 | BMCR_ANENABLE);
+
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | priv->psc, 0, 0, NULL);
+		}
+
+		if (priv->psc &
+		    (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1)) {
+			*opt |= AX_MONITOR_LINK;
+			ax8817x_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
+					*opt, 0, 0, NULL);
+		}
+	}
+
+	kfree(tmp16);
+	return usbnet_suspend(intf, message);
+}
+
+static int ax88772_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+
+	netif_carrier_off(dev->net);
+	return usbnet_resume(intf);
+}
+
+static int ax88772b_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (priv->psc & AX_SWRESET_WOLLP) {
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | (priv->psc & 0x7FFF),
+				0, 0, NULL);
 	}
+	if (priv->psc & (AX_SWRESET_IPPSL_0 | AX_SWRESET_IPPSL_1))
+		ax88772a_phy_powerup(dev);
+	netif_carrier_off(dev->net);
+	return usbnet_resume(intf);
+}
+
+static int ax88172_link_reset(struct usbnet *dev)
+{
+	u16 lpa;
+	u16 adv;
+	u16 res;
+	u8 mode;
+
+	mode = AX_MEDIUM_TX_ABORT_ALLOW | AX_MEDIUM_FLOW_CONTROL_EN;
+	lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
+	adv = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_ADVERTISE);
+	res = mii_nway_result(lpa|adv);
+	if (res & LPA_DUPLEX)
+		mode |= AX_MEDIUM_FULL_DUPLEX;
+	asix_write_medium_mode(dev, mode);
+	return 0;
+}
+
+static void
+ax8817x_get_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+{
+	struct usbnet *dev = netdev_priv(net);
+	u8 *opt;
+
+	wolinfo->supported = 0;
+	wolinfo->wolopts = 0;
+
+	opt = kmalloc(1, GFP_KERNEL);
+	if (!opt)
+		return;
+
+	if (ax8817x_read_cmd(dev, AX_CMD_READ_MONITOR_MODE, 0, 0, 1, opt) < 0)
+		return;
+
+	wolinfo->supported = WAKE_PHY | WAKE_MAGIC;
+
+	if (*opt & AX_MONITOR_LINK)
+		wolinfo->wolopts |= WAKE_PHY;
+	if (*opt & AX_MONITOR_MAGIC)
+		wolinfo->wolopts |= WAKE_MAGIC;
+
+	kfree(opt);
 }
 
 static int
-asix_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
+ax8817x_set_wol(struct net_device *net, struct ethtool_wolinfo *wolinfo)
 {
 	struct usbnet *dev = netdev_priv(net);
-	u8 opt = 0;
+	u8 *opt;
+
+	opt = kmalloc(1, GFP_KERNEL);
+	if (!opt)
+		return -ENOMEM;
 
+	*opt = 0;
 	if (wolinfo->wolopts & WAKE_PHY)
-		opt |= AX_MONITOR_LINK;
+		*opt |= AX_MONITOR_LINK;
 	if (wolinfo->wolopts & WAKE_MAGIC)
-		opt |= AX_MONITOR_MAGIC;
-	if (opt != 0)
-		opt |= AX_MONITOR_MODE;
+		*opt |= AX_MONITOR_MAGIC;
 
-	if (asix_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE,
-			      opt, 0, 0, NULL) < 0)
-		return -EINVAL;
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_MONITOR_MODE, *opt, 0, 0, NULL);
 
+	kfree(opt);
 	return 0;
 }
 
-static int asix_get_eeprom_len(struct net_device *net)
+static int ax8817x_get_eeprom_len(struct net_device *net)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	return data->eeprom_len;
+	return AX_EEPROM_LEN;
 }
 
-static int asix_get_eeprom(struct net_device *net,
+static int ax8817x_get_eeprom(struct net_device *net,
 			      struct ethtool_eeprom *eeprom, u8 *data)
 {
 	struct usbnet *dev = netdev_priv(net);
-	__le16 *ebuf = (__le16 *)data;
+	u16 *ebuf = (u16 *)data;
 	int i;
 
 	/* Crude hack to ensure that we don't overwrite memory
@@ -729,862 +693,2452 @@
 	eeprom->magic = AX_EEPROM_MAGIC;
 
 	/* ax8817x returns 2 bytes from eeprom on read */
-	for (i=0; i < eeprom->len / 2; i++) {
-		if (asix_read_cmd(dev, AX_CMD_READ_EEPROM,
+	for (i = 0; i < eeprom->len / 2; i++) {
+		if (ax8817x_read_cmd(dev, AX_CMD_READ_EEPROM,
 			eeprom->offset + i, 0, 2, &ebuf[i]) < 0)
 			return -EINVAL;
 	}
 	return 0;
 }
 
-static void asix_get_drvinfo (struct net_device *net,
+static void ax8817x_get_drvinfo(struct net_device *net,
 				 struct ethtool_drvinfo *info)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
 	/* Inherit standard device info */
 	usbnet_get_drvinfo(net, info);
-	strncpy (info->driver, driver_name, sizeof info->driver);
-	strncpy (info->version, DRIVER_VERSION, sizeof info->version);
-	info->eedump_len = data->eeprom_len;
+	info->eedump_len = 0x3e;
 }
 
-static u32 asix_get_link(struct net_device *net)
+static int ax8817x_get_settings(struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-
-	return mii_link_ok(&dev->mii);
+	return mii_ethtool_gset(&dev->mii, cmd);
 }
 
-static int asix_ioctl (struct net_device *net, struct ifreq *rq, int cmd)
+static int ax8817x_set_settings(struct net_device *net, struct ethtool_cmd *cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-
-	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
+	return mii_ethtool_sset(&dev->mii, cmd);
 }
 
-static int asix_set_mac_address(struct net_device *net, void *p)
+/*
+ * We need to override some ethtool_ops so we require our
+ * own structure so we don't interfere with other usbnet
+ * devices that may be connected at the same time.
+ */
+static struct ethtool_ops ax8817x_ethtool_ops = {
+	.get_drvinfo		= ax8817x_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_msglevel		= usbnet_get_msglevel,
+	.set_msglevel		= usbnet_set_msglevel,
+	.get_wol		= ax8817x_get_wol,
+	.set_wol		= ax8817x_set_wol,
+	.get_eeprom_len		= ax8817x_get_eeprom_len,
+	.get_eeprom		= ax8817x_get_eeprom,
+	.get_settings		= ax8817x_get_settings,
+	.set_settings		= ax8817x_set_settings,
+};
+
+static int ax8817x_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
 {
 	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	struct sockaddr *addr = p;
-
-	if (netif_running(net))
-		return -EBUSY;
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
 
-	memcpy(net->dev_addr, addr->sa_data, ETH_ALEN);
-
-	/* We use the 20 byte dev->data
-	 * for our 6 byte mac buffer
-	 * to avoid allocating memory that
-	 * is tricky to free later */
-	memcpy(data->mac_addr, addr->sa_data, ETH_ALEN);
-	asix_write_cmd_async(dev, AX_CMD_WRITE_NODE_ID, 0, 0, ETH_ALEN,
-							data->mac_addr);
-
-	return 0;
+	return generic_mii_ioctl(&dev->mii, if_mii(rq), cmd, NULL);
 }
 
-/* We need to override some ethtool_ops so we require our
-   own structure so we don't interfere with other usbnet
-   devices that may be connected at the same time. */
-static const struct ethtool_ops ax88172_ethtool_ops = {
-	.get_drvinfo		= asix_get_drvinfo,
-	.get_link		= asix_get_link,
-	.get_msglevel		= usbnet_get_msglevel,
-	.set_msglevel		= usbnet_set_msglevel,
-	.get_wol		= asix_get_wol,
-	.set_wol		= asix_set_wol,
-	.get_eeprom_len		= asix_get_eeprom_len,
-	.get_eeprom		= asix_get_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
-	.nway_reset		= usbnet_nway_reset,
+static const struct net_device_ops ax88x72_netdev_ops = {
+	.ndo_open		= usbnet_open,
+	.ndo_stop		= usbnet_stop,
+	.ndo_start_xmit		= usbnet_start_xmit,
+	.ndo_tx_timeout		= usbnet_tx_timeout,
+	.ndo_change_mtu		= usbnet_change_mtu,
+	.ndo_do_ioctl		= ax8817x_ioctl,
+	.ndo_set_mac_address	= ax8817x_set_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_set_multicast_list	= ax8817x_set_multicast,
 };
 
-static void ax88172_set_multicast(struct net_device *net)
+static int asix_read_mac(struct usbnet *dev, u8 op)
 {
-	struct usbnet *dev = netdev_priv(net);
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u8 rx_ctl = 0x8c;
+	u8 *buf;
+	int ret, len = ETH_ALEN;
 
-	if (net->flags & IFF_PROMISC) {
-		rx_ctl |= 0x01;
-	} else if (net->flags & IFF_ALLMULTI ||
-		   netdev_mc_count(net) > AX_MAX_MCAST) {
-		rx_ctl |= 0x02;
-	} else if (netdev_mc_empty(net)) {
-		/* just broadcast and directed */
+	buf = kzalloc(len, GFP_KERNEL);
+	if (!buf) {
+		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
+		return -ENOMEM;
+	}
+	ret = ax8817x_read_cmd(dev, op, 0, 0, len, buf);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s failed, err=%d\n", __func__, ret);
 	} else {
-		/* We use the 20 byte dev->data
-		 * for our 8 byte filter buffer
-		 * to avoid allocating memory that
-		 * is tricky to free later */
-		struct netdev_hw_addr *ha;
-		u32 crc_bits;
+		memcpy(dev->net->dev_addr, buf, len);
+		ret = 0;
+	}
+	kfree(buf);
+	return ret;
+}
 
-		memset(data->multi_filter, 0, AX_MCAST_FILTER_SIZE);
+static int asix_read_phyid(struct usbnet *dev, u8 op)
+{
+	u8 *buf;
+	int ret, len = 2;
 
-		/* Build the multicast hash filter. */
-		netdev_for_each_mc_addr(ha, net) {
-			crc_bits = ether_crc(ETH_ALEN, ha->addr) >> 26;
-			data->multi_filter[crc_bits >> 3] |=
-			    1 << (crc_bits & 7);
-		}
+	buf = kzalloc(len, GFP_KERNEL);
+	if (!buf) {
+		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
+		return -ENOMEM;
+	}
+	ret = ax8817x_read_cmd(dev, op, 0, 0, len, buf);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s failed, err=%d\n", __func__, ret);
+	} else if (ret < len) {
+		netdev_err(dev->net, "%s read only %d/%d bytes\n",
+						__func__, ret, len);
+		ret = -EIO;
+	} else {
+		dev->mii.phy_id = buf[1];
+		ret = 0;
+	}
+	kfree(buf);
+	return ret;
+}
 
-		asix_write_cmd_async(dev, AX_CMD_WRITE_MULTI_FILTER, 0, 0,
-				   AX_MCAST_FILTER_SIZE, data->multi_filter);
+static int asix_read_eeprom_le16(struct usbnet *dev, u8 offset, u16 *data)
+{
+	u16 *buf;
+	int ret, len = 2;
 
-		rx_ctl |= 0x10;
+	buf = kzalloc(len, GFP_KERNEL);
+	if (!buf) {
+		netdev_err(dev->net, "%s kzalloc failed\n", __func__);
+		return -ENOMEM;
 	}
 
-	asix_write_cmd_async(dev, AX_CMD_WRITE_RX_CTL, rx_ctl, 0, 0, NULL);
+	ret = ax8817x_read_cmd(dev, AX_CMD_READ_EEPROM, offset, 0, len, buf);
+	if (ret != 2) {
+		netdev_err(dev->net, "%s failed offset 0x%02x, err=%d\n",
+						__func__, offset, ret);
+	} else {
+		le16_to_cpus(buf);
+		*data = *buf;
+		ret = 0;
+	}
+	kfree(buf);
+	return ret;
 }
 
-static int ax88172_link_reset(struct usbnet *dev)
+static int asix_read_mac_from_eeprom(struct usbnet *dev)
 {
-	u8 mode;
-	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+	u16 buf[ETH_ALEN / 2];
+	int i, ret;
 
-	mii_check_media(&dev->mii, 1, 1);
-	mii_ethtool_gset(&dev->mii, &ecmd);
-	mode = AX88172_MEDIUM_DEFAULT;
+	memset(buf, 0, sizeof(buf));
+	for (i = 0; i < ETH_ALEN; i += 2) {
+		ret = asix_read_eeprom_le16(dev, i + 4, buf + i);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s failed\n", __func__);
+			return ret;
+		}
+	}
+	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	return 0;
+}
 
-	if (ecmd.duplex != DUPLEX_FULL)
-		mode |= ~AX88172_MEDIUM_FD;
+static int asix_phy_select(struct usbnet *dev, u16 physel)
+{
+	int ret;
 
-	netdev_dbg(dev->net, "ax88172_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
-		   ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_PHY_SELECT, physel, 0, 0, NULL);
+	if (ret < 0)
+		netdev_err(dev->net, "%s (0x%04x) failed, err=%d\n",
+						__func__, physel, ret);
+	return ret;
+}
 
-	asix_write_medium_mode(dev, mode);
+static int asix_write_gpio(struct usbnet *dev, unsigned int wait, u16 value)
+{
+	int ret;
 
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_GPIOS, value, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s (0x%x) failed\n", __func__, value);
+		return ret;
+	}
+	if (!wait)
+		wait = 5;
+	if (wait < 20)
+		usleep_range(wait * 1000, wait * (1000 * 2));
+	else
+		msleep(wait);
 	return 0;
 }
 
-static const struct net_device_ops ax88172_netdev_ops = {
-	.ndo_open		= usbnet_open,
-	.ndo_stop		= usbnet_stop,
-	.ndo_start_xmit		= usbnet_start_xmit,
-	.ndo_tx_timeout		= usbnet_tx_timeout,
-	.ndo_change_mtu		= usbnet_change_mtu,
-	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_do_ioctl		= asix_ioctl,
-	.ndo_set_multicast_list = ax88172_set_multicast,
-};
-
-static int ax88172_bind(struct usbnet *dev, struct usb_interface *intf)
+static int ax8817x_bind(struct usbnet *dev, struct usb_interface *intf)
 {
 	int ret = 0;
-	u8 buf[ETH_ALEN];
 	int i;
 	unsigned long gpio_bits = dev->driver_info->data;
-	struct asix_data *data = (struct asix_data *)&dev->data;
-
-	data->eeprom_len = AX88172_EEPROM_LEN;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
 
-	usbnet_get_endpoints(dev,intf);
+	usbnet_get_endpoints(dev, intf);
 
 	/* Toggle the GPIOs in a manufacturer/model specific way */
 	for (i = 2; i >= 0; i--) {
-		if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_GPIOS,
-					(gpio_bits >> (i * 8)) & 0xff, 0, 0,
-					NULL)) < 0)
-			goto out;
-		msleep(5);
+		ret = asix_write_gpio(dev, 0, (gpio_bits >> (i * 8)) & 0xff);
+		if (ret)
+			goto err_out;
 	}
 
-	if ((ret = asix_write_rx_ctl(dev, 0x80)) < 0)
-		goto out;
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x80, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: WRITE_RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
 
 	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX88172_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
-		dbg("read AX_CMD_READ_NODE_ID failed: %d", ret);
-		goto out;
-	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	ret = asix_read_mac(dev, AX_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = asix_mdio_read;
-	dev->mii.mdio_write = asix_mdio_write;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
 	dev->mii.phy_id_mask = 0x3f;
 	dev->mii.reg_num_mask = 0x1f;
-	dev->mii.phy_id = asix_get_phy_addr(dev);
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax8817x_ethtool_ops;
 
-	dev->net->netdev_ops = &ax88172_netdev_ops;
-	dev->net->ethtool_ops = &ax88172_ethtool_ops;
+	/* Register suspend and resume functions */
+	data->suspend = usbnet_suspend;
+	data->resume = usbnet_resume;
 
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 		ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
 	mii_nway_restart(&dev->mii);
 
+	printk(KERN_INFO "%s\n", driver_version);
 	return 0;
 
-out:
+err_out:
 	return ret;
 }
 
-static const struct ethtool_ops ax88772_ethtool_ops = {
-	.get_drvinfo		= asix_get_drvinfo,
-	.get_link		= asix_get_link,
+static struct ethtool_ops ax88772_ethtool_ops = {
+	.get_drvinfo		= ax8817x_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
 	.get_msglevel		= usbnet_get_msglevel,
 	.set_msglevel		= usbnet_set_msglevel,
-	.get_wol		= asix_get_wol,
-	.set_wol		= asix_set_wol,
-	.get_eeprom_len		= asix_get_eeprom_len,
-	.get_eeprom		= asix_get_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
-	.nway_reset		= usbnet_nway_reset,
+	.get_wol		= ax8817x_get_wol,
+	.set_wol		= ax8817x_set_wol,
+	.get_eeprom_len		= ax8817x_get_eeprom_len,
+	.get_eeprom		= ax8817x_get_eeprom,
+	.get_settings		= ax8817x_get_settings,
+	.set_settings		= ax8817x_set_settings,
 };
 
-static int ax88772_link_reset(struct usbnet *dev)
+static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
 {
-	u16 mode;
-	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
+	int ret;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88772_data *priv;
 
-	mii_check_media(&dev->mii, 1, 1);
-	mii_ethtool_gset(&dev->mii, &ecmd);
-	mode = AX88772_MEDIUM_DEFAULT;
+	usbnet_get_endpoints(dev, intf);
 
-	if (ethtool_cmd_speed(&ecmd) != SPEED_100)
-		mode &= ~AX_MEDIUM_PS;
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
 
-	if (ecmd.duplex != DUPLEX_FULL)
-		mode &= ~AX_MEDIUM_FD;
+	priv->ax_work = create_singlethread_workqueue("ax88772");
+	if (!priv->ax_work) {
+		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
+		kfree(priv);
+		return -ENOMEM;
+	}
 
-	netdev_dbg(dev->net, "ax88772_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
-		   ethtool_cmd_speed(&ecmd), ecmd.duplex, mode);
+	priv->dev = dev;
+	INIT_WORK(&priv->check_link, ax88772_link_reset);
 
-	asix_write_medium_mode(dev, mode);
+	/* reload eeprom data */
+	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE|AXGPIOS_GPO2|AXGPIOS_GPO2EN);
+	if (ret)
+		goto err_out;
 
-	return 0;
-}
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;
 
-static const struct net_device_ops ax88772_netdev_ops = {
-	.ndo_open		= usbnet_open,
-	.ndo_stop		= usbnet_stop,
-	.ndo_start_xmit		= usbnet_start_xmit,
-	.ndo_tx_timeout		= usbnet_tx_timeout,
-	.ndo_change_mtu		= usbnet_change_mtu,
-	.ndo_set_mac_address 	= asix_set_mac_address,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_do_ioctl		= asix_ioctl,
-	.ndo_set_multicast_list = asix_set_multicast,
-};
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;
+	if (dev->mii.phy_id == 0x10) {
+		ret = asix_phy_select(dev, 0x0001);
+		if (ret < 0)
+			goto err_out;
+
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to power down PHY"
+						", err=%d\n", __func__, ret);
+			goto err_out;
+		}
 
-static int ax88772_bind(struct usbnet *dev, struct usb_interface *intf)
-{
-	int ret, embd_phy;
-	u16 rx_ctl;
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u8 buf[ETH_ALEN];
-	u32 phyid;
-
-	data->eeprom_len = AX88772_EEPROM_LEN;
-
-	usbnet_get_endpoints(dev,intf);
-
-	if ((ret = asix_write_gpio(dev,
-			AX_GPIO_RSE | AX_GPIO_GPO_2 | AX_GPIO_GPO2EN, 5)) < 0)
-		goto out;
-
-	/* 0x10 is the phy id of the embedded 10/100 ethernet phy */
-	embd_phy = ((asix_get_phy_addr(dev) & 0x1f) == 0x10 ? 1 : 0);
-	if ((ret = asix_write_cmd(dev, AX_CMD_SW_PHY_SELECT,
-				embd_phy, 0, 0, NULL)) < 0) {
-		dbg("Select PHY #1 failed: %d", ret);
-		goto out;
-	}
+		msleep(150);
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_CLEAR, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: SW_RESET failed, err=%d\n",
+								__func__, ret);
+			goto err_out;
+		}
 
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPPD | AX_SWRESET_PRL)) < 0)
-		goto out;
+		msleep(150);
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to set PHY reset "
+					"control, err=%d\n", __func__, ret);
+			goto err_out;
+		}
+	} else {
+		ret = asix_phy_select(dev, 0x0000);
+		if (ret < 0)
+			goto err_out;
+
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to power down "
+				"internal PHY, err=%d\n", __func__, ret);
+			goto err_out;
+		}
+	}
 
 	msleep(150);
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_CLEAR)) < 0)
-		goto out;
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x0000, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: Failed to reset RX_CTL, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
 
-	msleep(150);
-	if (embd_phy) {
-		if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL)) < 0)
-			goto out;
-	}
-	else {
-		if ((ret = asix_sw_reset(dev, AX_SWRESET_PRTE)) < 0)
-			goto out;
+	/* Get the MAC address */
+	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: Failed to enable software MII"
+					", err=%d\n", __func__, ret);
+		goto err_out;
 	}
 
-	msleep(150);
-	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x after software reset", rx_ctl);
-	if ((ret = asix_write_rx_ctl(dev, 0x0000)) < 0)
-		goto out;
+	if (dev->mii.phy_id == 0x10) {
+		ret = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 2);
+		if (ret != 0x003b) {
+			netdev_err(dev->net, "%s: PHY reg 2 not 0x3b00: 0x%x\n",
+							__func__, ret);
+			goto err_out;
+		}
+
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to set "
+				"external PHY reset pin level, err=%d\n",
+				__func__, ret);
+			goto err_out;
+		}
+		msleep(150);
+		ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL | AX_SWRESET_PRL, 0, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: Failed to set "
+				"internal/external PHY reset control, err=%d\n",
+				__func__, ret);
+			goto err_out;
+		}
+		msleep(150);
+	}
+
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772_suspend;
+	data->resume = ax88772_resume;
+
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+					ADVERTISE_ALL | ADVERTISE_CSMA);
+
+	mii_nway_restart(&dev->mii);
+	priv->autoneg_start = jiffies;
+	priv->Event = WAIT_AUTONEG_COMPLETE;
+
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT << 8,
+			AX88772_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: WRITE_IPG0/1/2 failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: SET_HW_MII failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0x0088, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: WRITE_RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
+	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
+		/*
+		 * hard_mtu  is still the default;
+		 *  the device does not support jumbo eth frames
+		 */
+		dev->rx_urb_size = 2048;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return 0;
+
+err_out:
+	destroy_workqueue(priv->ax_work);
+	kfree(priv);
+	return ret;
+}
+
+static void ax88772_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88772_data *priv = (struct ax88772_data *)dev->driver_priv;
+
+	if (priv) {
+
+		flush_workqueue(priv->ax_work);
+		destroy_workqueue(priv->ax_work);
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+
+		/* Power down PHY */
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int ax88772a_phy_powerup(struct usbnet *dev)
+{
+	int ret;
+	/* set the embedded Ethernet PHY in power-down state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_IPRL, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: power down PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	msleep(20); /* was 10ms */
+
+
+	/* set the embedded Ethernet PHY in power-up state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_IPRL,
+							0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	msleep(600);
+
+	/* set the embedded Ethernet PHY in reset state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_CLEAR,
+							0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: power up PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	/* set the embedded Ethernet PHY in power-up state */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET, AX_SWRESET_IPRL,
+							0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: second reset PHY failed, err=%d\n",
+							__func__, ret);
+		return ret;
+	}
+
+	return 0;
+}
+
+static int ax88772a_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret = -EIO;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88772a_data *priv;
+
+	usbnet_get_endpoints(dev, intf);
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
+
+	priv->ax_work = create_singlethread_workqueue("ax88772a");
+	if (!priv->ax_work) {
+		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
+		kfree(priv);
+		return -ENOMEM;
+	}
+
+	priv->dev = dev;
+	INIT_WORK(&priv->check_link, ax88772a_link_reset);
+
+	/* Get the EEPROM data*/
+	ret = asix_read_eeprom_le16(dev, 0x17, &priv->EepromData);
+	if (ret < 0)
+		goto err_out;
+
+	/* reload eeprom data */
+	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE);
+	if (ret)
+		goto err_out;
+
+	/* Initialize MII structure */
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;
+
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;
+	if (dev->mii.phy_id != 0x10) {
+		netdev_err(dev->net, "%s: Got wrong PHY_ID: 0x%02x\n",
+						__func__, dev->mii.phy_id);
+		ret = -EIO;
+		goto err_out;
+	}
+
+	/* select the embedded 10/100 Ethernet PHY */
+	ret = asix_phy_select(dev,
+			AX_PHYSEL_SSEN | AX_PHYSEL_PSEL | AX_PHYSEL_SSMII);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax88772a_phy_powerup(dev);
+	if (ret < 0)
+		goto err_out;
 
-	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x setting to 0x0000", rx_ctl);
+	/* stop MAC operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+				AX_RX_CTL_STOP, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
 
 	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
-		dbg("Failed to read MAC address: %d", ret);
-		goto out;
+	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	/* make sure the driver can enable sw mii operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: enable software MII failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772_suspend;
+	data->resume = ax88772_resume;
+
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+
+	mii_nway_restart(&dev->mii);
+	priv->autoneg_start = jiffies;
+	priv->Event = WAIT_AUTONEG_COMPLETE;
+
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772A_IPG0_DEFAULT | AX88772A_IPG1_DEFAULT << 8,
+			AX88772A_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: write IPG,IPG1,IPG2 failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+				AX_RX_CTL_START | AX_RX_CTL_AB, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: Reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
+	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
+		/*
+		 * hard_mtu  is still the default;
+		 *  the device does not support jumbo eth frames
+		 */
+		dev->rx_urb_size = 2048;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return ret;
+
+err_out:
+	destroy_workqueue(priv->ax_work);
+	kfree(priv);
+	return ret;
+}
+
+static void ax88772a_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88772a_data *priv = (struct ax88772a_data *)dev->driver_priv;
+
+	if (priv) {
+
+		flush_workqueue(priv->ax_work);
+		destroy_workqueue(priv->ax_work);
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+
+		/* Power down PHY */
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int ax88772b_set_csums(struct usbnet *dev)
+{
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+	u16 checksum;
+
+	if (priv->checksum & AX_RX_CHECKSUM)
+		checksum = AX_RXCOE_DEF_CSUM;
+	else
+		checksum = 0;
+
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_RXCOE_CTL,
+				 checksum, 0, 0, NULL);
+
+	if (priv->checksum & AX_TX_CHECKSUM)
+		checksum = AX_TXCOE_DEF_CSUM;
+	else
+		checksum = 0;
+
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_TXCOE_CTL,
+				 checksum, 0, 0, NULL);
+
+	return 0;
+}
+
+static u32 ax88772b_get_tx_csum(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	return priv->checksum & AX_TX_CHECKSUM;
+}
+
+static u32 ax88772b_get_rx_csum(struct net_device *netdev)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	return priv->checksum & AX_RX_CHECKSUM;
+}
+
+static int ax88772b_set_rx_csum(struct net_device *netdev, u32 val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (val)
+		priv->checksum |= AX_RX_CHECKSUM;
+	else
+		priv->checksum &= ~AX_RX_CHECKSUM;
+
+	return ax88772b_set_csums(dev);
+}
+
+static int ax88772b_set_tx_csum(struct net_device *netdev, u32 val)
+{
+	struct usbnet *dev = netdev_priv(netdev);
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (val)
+		priv->checksum |= AX_TX_CHECKSUM;
+	else
+		priv->checksum &= ~AX_TX_CHECKSUM;
+
+	ethtool_op_set_tx_csum(netdev, val);
+
+	return ax88772b_set_csums(dev);
+}
+
+static struct ethtool_ops ax88772b_ethtool_ops = {
+	.get_drvinfo		= ax8817x_get_drvinfo,
+	.get_link		= ethtool_op_get_link,
+	.get_msglevel		= usbnet_get_msglevel,
+	.set_msglevel		= usbnet_set_msglevel,
+	.get_wol		= ax8817x_get_wol,
+	.set_wol		= ax8817x_set_wol,
+	.get_eeprom_len		= ax8817x_get_eeprom_len,
+	.get_eeprom		= ax8817x_get_eeprom,
+	.get_settings		= ax8817x_get_settings,
+	.set_settings		= ax8817x_set_settings,
+	.set_tx_csum		= ax88772b_set_tx_csum,
+	.get_tx_csum		= ax88772b_get_tx_csum,
+	.get_rx_csum		= ax88772b_get_rx_csum,
+	.set_rx_csum		= ax88772b_set_rx_csum,
+};
+
+static const struct net_device_ops ax88772b_netdev_ops = {
+	.ndo_open			= usbnet_open,
+	.ndo_stop			= usbnet_stop,
+	.ndo_start_xmit	= usbnet_start_xmit,
+	.ndo_tx_timeout	= usbnet_tx_timeout,
+	.ndo_change_mtu	= usbnet_change_mtu,
+	.ndo_do_ioctl		= ax8817x_ioctl,
+	.ndo_set_mac_address	= ax8817x_set_mac_addr,
+	.ndo_validate_addr		= eth_validate_addr,
+	.ndo_set_multicast_list = ax88772b_set_multicast,
+};
+
+static int ax88772b_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88772b_data *priv;
+	int rx_size;
+	u16 tmp16;
+
+	usbnet_get_endpoints(dev, intf);
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
+
+	priv->ax_work = create_singlethread_workqueue("ax88772b");
+	if (!priv->ax_work) {
+		netdev_err(dev->net, "%s: create workqueue failed\n", __func__);
+		kfree(priv);
+		return -ENOMEM;
+	}
+
+	priv->dev = dev;
+	INIT_WORK(&priv->check_link, ax88772b_link_reset);
+
+	/* reload eeprom data */
+	ret = asix_write_gpio(dev, 0, AXGPIOS_RSE);
+	if (ret)
+		goto err_out;
+
+	/* Get the EEPROM data*/
+	ret = asix_read_eeprom_le16(dev, 0x18, &priv->psc);
+	if (ret < 0)
+		goto err_out;
+	priv->psc &= 0xFF00;
+
+	/* Get the MAC address from the eeprom */
+	ret = asix_read_mac_from_eeprom(dev);
+	if (ret < 0)
+		goto err_out;
+
+	/* Set the MAC address */
+	ret = ax8817x_write_cmd(dev, AX88772_CMD_WRITE_NODE_ID,
+			0, 0, ETH_ALEN, dev->net->dev_addr);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: set mac addr failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
 
 	/* Initialize MII structure */
 	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = asix_mdio_read;
-	dev->mii.mdio_write = asix_mdio_write;
-	dev->mii.phy_id_mask = 0x1f;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax88772b_mdio_write_le;
+	dev->mii.phy_id_mask = 0xff;
+	dev->mii.reg_num_mask = 0xff;
+
+	/* Get the PHY id */
+	ret = asix_read_phyid(dev, AX_CMD_READ_PHY_ID);
+	if (ret < 0)
+		goto err_out;
+	if (dev->mii.phy_id != 0x10) {
+		netdev_err(dev->net, "%s: Got wrong PHY_ID: 0x%02x\n",
+						__func__, dev->mii.phy_id);
+		ret = -EIO;
+		goto err_out;
+	}
+
+	/* select the embedded 10/100 Ethernet PHY */
+	ret = asix_phy_select(dev,
+			AX_PHYSEL_SSEN | AX_PHYSEL_PSEL | AX_PHYSEL_SSMII);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax88772a_phy_powerup(dev);
+	if (ret < 0)
+		goto err_out;
+
+	/* stop MAC operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+				AX_RX_CTL_STOP, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* make sure the driver can enable sw mii operation */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: enable software MII failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	dev->net->netdev_ops = &ax88772b_netdev_ops;
+	dev->net->ethtool_ops = &ax88772b_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772b_suspend;
+	data->resume = ax88772b_resume;
+
+	tmp16 = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, 0x12,
+			((tmp16 & 0xFF9F) | 0x0040));
+	ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+	mii_nway_restart(&dev->mii);
+
+	ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772A_IPG0_DEFAULT | AX88772A_IPG1_DEFAULT << 8,
+			AX88772A_IPG2_DEFAULT, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: write interfram gap failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	dev->net->features |= NETIF_F_IP_CSUM;
+	dev->net->features |= NETIF_F_IPV6_CSUM;
+
+	priv->checksum = AX_RX_CHECKSUM | AX_TX_CHECKSUM;
+	ret = ax88772b_set_csums(dev);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: write RX_COE/TX_COE failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	rx_size = bsize & 0x07;
+	if (dev->udev->speed == USB_SPEED_HIGH) {
+		ret = ax8817x_write_cmd(dev, 0x2A,
+				AX88772B_BULKIN_SIZE[rx_size].byte_cnt,
+				AX88772B_BULKIN_SIZE[rx_size].threshold,
+				0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: set rx_size failed, err=%d\n",
+							__func__, ret);
+			goto err_out;
+		}
+		dev->rx_urb_size = AX88772B_BULKIN_SIZE[rx_size].size;
+	} else {
+		ret = ax8817x_write_cmd(dev, 0x2A, 0x8000, 0x8001, 0, NULL);
+		if (ret < 0) {
+			netdev_err(dev->net, "%s: set rx_size failed, err=%d\n",
+							__func__, ret);
+			goto err_out;
+		}
+		dev->rx_urb_size = 2048;
+	}
+
+	/* Configure RX header type */
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+		      (AX_RX_CTL_START | AX_RX_CTL_AB | AX_RX_HEADER_DEFAULT),
+		      0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: reset RX_CTL failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	/* Overwrite power saving configuration from eeprom */
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+	    AX_SWRESET_IPRL | (priv->psc & 0x7FFF), 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: set phy power saving failed, err=%d\n",
+							__func__, ret);
+		goto err_out;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return ret;
+
+err_out:
+	destroy_workqueue(priv->ax_work);
+	kfree(priv);
+	return ret;
+}
+
+static void ax88772b_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
+
+	if (priv) {
+
+		flush_workqueue(priv->ax_work);
+		destroy_workqueue(priv->ax_work);
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+
+		/* Power down PHY */
+		ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					AX_SWRESET_IPPD, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int
+ax88178_media_check(struct usbnet *dev, struct ax88178_data *priv)
+{
+	int fullduplex;
+	u16 tempshort = 0;
+	u16 media;
+	u16 advertise, lpa, result, stat1000;
+
+	advertise = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_ADVERTISE);
+	lpa = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, MII_LPA);
+	result = advertise & lpa;
+
+	stat1000 = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_STAT1000);
+
+	if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+	    (priv->LedMode == 1)) {
+		tempshort = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MARVELL_MANUAL_LED) & 0xfc0f;
+	}
+
+	fullduplex = 1;
+	if (stat1000 & LPA_1000FULL) {
+		media = MEDIUM_GIGA_MODE | MEDIUM_FULL_DUPLEX_MODE |
+			MEDIUM_ENABLE_125MHZ | MEDIUM_ENABLE_RECEIVE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x3e0;
+	} else if (result & LPA_100FULL) {
+		media = MEDIUM_FULL_DUPLEX_MODE | MEDIUM_ENABLE_RECEIVE |
+			MEDIUM_MII_100M_MODE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x3b0;
+	} else if (result & LPA_100HALF) {
+		fullduplex = 0;
+		media = MEDIUM_ENABLE_RECEIVE | MEDIUM_MII_100M_MODE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x3b0;
+	} else if (result & LPA_10FULL) {
+		media = MEDIUM_FULL_DUPLEX_MODE | MEDIUM_ENABLE_RECEIVE;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+			tempshort |= 0x2f0;
+	} else {
+		media = MEDIUM_ENABLE_RECEIVE;
+		fullduplex = 0;
+		if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+		    (priv->LedMode == 1))
+				tempshort |= 0x02f0;
+	}
+
+	if ((priv->PhyMode == PHY_MODE_MARVELL) &&
+	    (priv->LedMode == 1)) {
+		ax8817x_mdio_write_le(dev->net,
+			dev->mii.phy_id, MARVELL_MANUAL_LED, tempshort);
+	}
+
+	media |= 0x0004;
+	if (priv->UseRgmii)
+		media |= 0x0008;
+	if (fullduplex) {
+		media |= 0x0020;  /* enable tx flow control as default */
+		media |= 0x0010;  /* enable rx flow control as default */
+	}
+
+	return media;
+}
+
+static void Vitess_8601_Init(struct usbnet *dev, int State)
+{
+	u16 reg;
+
+	switch (State) {
+	case 0:	/* tx, rx clock skew */
+		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 31, 1);
+		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 28, 0);
+		ax8817x_swmii_mdio_write_le(dev->net, dev->mii.phy_id, 31, 0);
+		break;
+
+	case 1:
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0x52B5);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x009E);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xDD39);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87AA);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xA7B4);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x003f) | 0x003c;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87B4);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa794);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x003f) | 0x003e;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x8794);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x00f7);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xbe36);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x879e);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa7a0);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x003f) | 0x0034;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a0);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x003c);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xf3cf);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a2);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x003c);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xf3cf);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a4);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, 0x003c);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, 0xd287);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a6);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa7a8);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x0fff) | 0x0125;
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87a8);
+
+		/* Enable Smart Pre-emphasis */
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xa7fa);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18,
+				ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 18));
+
+		reg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 17) & ~0x0008) | 0x0008;
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 17, reg);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87fa);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0);
+
+		break;
+	}
+}
+
+static int
+ax88178_phy_init(struct usbnet *dev, struct ax88178_data *priv)
+{
+	int i;
+	u16 PhyAnar, PhyAuxCtrl, PhyCtrl, TempShort, PhyID1;
+	u16 PhyReg = 0;
+
+	/* Disable MII operation of AX88178 Hardware */
+	ax8817x_write_cmd(dev, AX_CMD_SET_SW_MII, 0x0000, 0, 0, NULL);
+
+
+	/* Read SROM - MiiPhy Address (ID) */
+	ax8817x_read_cmd(dev, AX_CMD_READ_PHY_ID, 0, 0, 2, &dev->mii.phy_id);
+	le16_to_cpus(&dev->mii.phy_id);
+
+	/* Initialize MII structure */
+	dev->mii.phy_id >>= 8;
+	dev->mii.phy_id &= PHY_ID_MASK;
+	dev->mii.dev = dev->net;
+	dev->mii.mdio_read = ax8817x_mdio_read_le;
+	dev->mii.mdio_write = ax8817x_mdio_write_le;
+	dev->mii.phy_id_mask = 0x3f;
 	dev->mii.reg_num_mask = 0x1f;
-	dev->mii.phy_id = asix_get_phy_addr(dev);
+	dev->mii.supports_gmii = 1;
 
-	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
+	if (priv->PhyMode == PHY_MODE_MAC_TO_MAC_GMII) {
+		priv->UseRgmii = 0;
+		priv->MediaLink = MEDIUM_GIGA_MODE |
+					  MEDIUM_FULL_DUPLEX_MODE |
+					  MEDIUM_ENABLE_125MHZ |
+					  MEDIUM_ENABLE_RECEIVE |
+					  MEDIUM_ENABLE_RX_FLOWCTRL |
+					  MEDIUM_ENABLE_TX_FLOWCTRL;
+
+		goto SkipPhySetting;
+	}
+
+	/* test read phy register 2 */
+	if (!priv->UseGpio0) {
+		i = 1000;
+		while (i--) {
+			PhyID1 = ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, GMII_PHY_OUI);
+			if ((PhyID1 == 0x000f) || (PhyID1 == 0x0141) ||
+			    (PhyID1 == 0x0282) || (PhyID1 == 0x004d) ||
+			    (PhyID1 == 0x0243) || (PhyID1 == 0x001C) ||
+			    (PhyID1 == 0x0007))
+				break;
+			usleep_range(5, 20);
+		}
+		if (i < 0)
+			return -EIO;
+	}
 
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_PRL)) < 0)
-		goto out;
+	priv->UseRgmii = 0;
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 27);
+		if (!(PhyReg & 4)) {
+			priv->UseRgmii = 1;
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 20, 0x82);
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+	} else if ((priv->PhyMode == PHY_MODE_AGERE_V0) ||
+		 (priv->PhyMode == PHY_MODE_AGERE_V0_GMII)) {
+		if (priv->PhyMode == PHY_MODE_AGERE_V0) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+	} else if (priv->PhyMode == PHY_MODE_CICADA_V1) {
+		/* not Cameo */
+		if (!priv->UseGpio0 || priv->LedMode) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
 
-	msleep(150);
+		for (i = 0; i < (sizeof(CICADA_FAMILY_HWINIT) /
+				 sizeof(CICADA_FAMILY_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id,
+					CICADA_FAMILY_HWINIT[i].offset,
+					CICADA_FAMILY_HWINIT[i].value);
+		}
+
+	} else if (priv->PhyMode == PHY_MODE_CICADA_V2) {
+		/* not Cameo */
+		if (!priv->UseGpio0 || priv->LedMode) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+
+		for (i = 0; i < (sizeof(CICADA_V2_HWINIT) /
+				 sizeof(CICADA_V2_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, CICADA_V2_HWINIT[i].offset,
+				CICADA_V2_HWINIT[i].value);
+		}
+	} else if (priv->PhyMode == PHY_MODE_CICADA_V2_ASIX) {
+		/* not Cameo */
+		if (!priv->UseGpio0 || priv->LedMode) {
+			priv->UseRgmii = 1;
+			priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		}
+
+		for (i = 0; i < (sizeof(CICADA_V2_HWINIT) /
+				 sizeof(CICADA_V2_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, CICADA_V2_HWINIT[i].offset,
+				CICADA_V2_HWINIT[i].value);
+		}
+	} else if (priv->PhyMode == PHY_MODE_RTL8211CL) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+	} else if (priv->PhyMode == PHY_MODE_RTL8211BN) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+	} else if (priv->PhyMode == PHY_MODE_RTL8251CL) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+	} else if (priv->PhyMode == PHY_MODE_VSC8601) {
+		priv->UseRgmii = 1;
+		priv->MediaLink |= MEDIUM_ENABLE_125MHZ;
+		/* Vitess_8601_Init(dev, 0); */
+	}
+
+	if (priv->PhyMode != PHY_MODE_ATTANSIC_V0) {
+		/* software reset */
+		ax8817x_swmii_mdio_write_le(
+			dev->net, dev->mii.phy_id, GMII_PHY_CONTROL,
+			ax8817x_swmii_mdio_read_le(
+				dev->net, dev->mii.phy_id, GMII_PHY_CONTROL)
+				| GMII_CONTROL_RESET);
+		usleep_range(1000, 2000);
+	}
+
+	if ((priv->PhyMode == PHY_MODE_AGERE_V0) ||
+	    (priv->PhyMode == PHY_MODE_AGERE_V0_GMII)) {
+		if (priv->PhyMode == PHY_MODE_AGERE_V0) {
+			i = 1000;
+			while (i--) {
+				ax8817x_swmii_mdio_write_le(dev->net,
+						dev->mii.phy_id, 21, 0x1001);
+
+				PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 21);
+				if ((PhyReg & 0xf00f) == 0x1001)
+					break;
+			}
+			if (i < 0)
+				return -EIO;
+		}
+
+		if (priv->LedMode == 4) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 28, 0x7417);
+		} else if (priv->LedMode == 9) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 28, 0x7a10);
+		} else if (priv->LedMode == 10) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 28, 0x7a13);
+		}
+
+		for (i = 0; i < (sizeof(AGERE_FAMILY_HWINIT) /
+				 sizeof(AGERE_FAMILY_HWINIT[0])); i++) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, AGERE_FAMILY_HWINIT[i].offset,
+				AGERE_FAMILY_HWINIT[i].value);
+		}
+	} else if (priv->PhyMode == PHY_MODE_RTL8211CL) {
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x1f, 0x0005);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x0c, 0);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x01,
+				(ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 0x01) | 0x0080));
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x1f, 0);
+
+		if (priv->LedMode == 12) {
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 0x1f, 0x0002);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 0x1a, 0x00cb);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 0x1f, 0);
+		}
+	} else if (priv->PhyMode == PHY_MODE_VSC8601) {
+		Vitess_8601_Init(dev, 1);
+	}
+
+	/* read phy register 0 */
+	PhyCtrl = ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL);
+	TempShort = PhyCtrl;
+	PhyCtrl &= ~(GMII_CONTROL_POWER_DOWN | GMII_CONTROL_ISOLATE);
+	if (PhyCtrl != TempShort) {
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL, PhyCtrl);
+	}
+
+	/* led */
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		if (priv->LedMode == 1) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+				dev->mii.phy_id, 24) & 0xf8ff) | (1 + 0x100);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+			PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 25) & 0xfc0f;
+
+		} else if (priv->LedMode == 2) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0xf886) |
+					(1 + 0x10 + 0x300);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 5) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0xf8be) |
+					(1 + 0x40 + 0x300);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 7) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+						dev->mii.phy_id, 24) & 0xf8ff) |
+						(1 + 0x100);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 8) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0xf8be) |
+					(1 + 0x40 + 0x100);
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		} else if (priv->LedMode == 11) {
+
+			PhyReg = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 24) & 0x4106;
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 24, PhyReg);
+
+		}
+	} else if ((priv->PhyMode == PHY_MODE_CICADA_V1) ||
+		   (priv->PhyMode == PHY_MODE_CICADA_V2) ||
+		   (priv->PhyMode == PHY_MODE_CICADA_V2_ASIX)) {
+
+		if (priv->LedMode == 3) {
+
+			PhyReg = (ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 27) & 0xFCFF) | 0x0100;
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 27, PhyReg);
+		}
+
+	}
+
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		if (priv->LedMode == 1)
+			PhyReg |= 0x3f0;
+	}
+	PhyAnar = 1 | (GMII_ANAR_PAUSE | GMII_ANAR_100TXFD | GMII_ANAR_100TX |
+		       GMII_ANAR_10TFD | GMII_ANAR_10T | GMII_ANAR_ASYM_PAUSE);
+	PhyAuxCtrl = GMII_1000_AUX_CTRL_FD_CAPABLE;
+	ax8817x_swmii_mdio_write_le(dev->net,
+			dev->mii.phy_id, GMII_PHY_ANAR, PhyAnar);
+	ax8817x_swmii_mdio_write_le(dev->net,
+			dev->mii.phy_id, GMII_PHY_1000BT_CONTROL, PhyAuxCtrl);
+
+	if (priv->PhyMode == PHY_MODE_VSC8601) {
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0x52B5);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0xA7F8);
+		TempShort = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 17) & (~0x0018);
+		ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 17, TempShort);
+		TempShort = ax8817x_swmii_mdio_read_le(dev->net,
+					dev->mii.phy_id, 18);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 18, TempShort);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 16, 0x87F8);
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, 31, 0);
+	}
+
+	if (priv->PhyMode == PHY_MODE_ATTANSIC_V0) {
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL, 0x9000);
+
+	} else {
+		PhyCtrl &= ~GMII_CONTROL_LOOPBACK;
+		PhyCtrl |= (GMII_CONTROL_ENABLE_AUTO | GMII_CONTROL_START_AUTO);
+
+		ax8817x_swmii_mdio_write_le(dev->net,
+				dev->mii.phy_id, GMII_PHY_CONTROL, PhyCtrl);
+	}
+
+	if (priv->PhyMode == PHY_MODE_MARVELL) {
+		if (priv->LedMode == 1)
+			ax8817x_swmii_mdio_write_le(dev->net,
+					dev->mii.phy_id, 25, PhyReg);
+	}
+
+SkipPhySetting:
+
+	asix_write_medium_mode(dev, priv->MediaLink);
+	ax8817x_write_cmd(dev, AX_CMD_WRITE_IPG0,
+			AX88772_IPG0_DEFAULT | (AX88772_IPG1_DEFAULT << 8),
+			AX88772_IPG2_DEFAULT, 0, NULL);
+	usleep_range(1000, 2000);
+	ax8817x_write_cmd(dev, AX_CMD_SET_HW_MII, 0, 0, 0, NULL);
+	return 0;
+}
+
+static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
+{
+	int ret;
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+	struct ax88178_data *priv;
+
+	usbnet_get_endpoints(dev, intf);
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		netdev_err(dev->net, "%s: kzalloc(priv) failed\n", __func__);
+		return -ENOMEM;
+	}
+	dev->driver_priv = priv;
+
+	/* Get the EEPROM data*/
+	ret = asix_read_eeprom_le16(dev, 0x17, &priv->EepromData);
+	if (ret < 0)
+		goto err_out;
+
+	if (priv->EepromData == 0xffff) {
+		priv->PhyMode  = PHY_MODE_MARVELL;
+		priv->LedMode  = 0;
+		priv->UseGpio0 = 1;
+	} else {
+		priv->PhyMode = (u8)(priv->EepromData & EEPROMMASK);
+		priv->LedMode = (u8)(priv->EepromData >> 8);
+		if (priv->LedMode == 6)	/* for buffalo new (use gpio2) */
+			priv->LedMode = 1;
+		else if (priv->LedMode == 1)
+			priv->BuffaloOld = 1;
+
+
+		if (priv->EepromData & 0x80)
+			priv->UseGpio0 = 0; /* MARVEL se and other */
+		else
+			priv->UseGpio0 = 1; /* cameo */
+	}
+
+	if (priv->UseGpio0) {
+
+		if (priv->PhyMode == PHY_MODE_MARVELL) {
+
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO0EN | AXGPIOS_RSE);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 15,
+				AXGPIOS_GPO2 | AXGPIOS_GPO2EN |
+				AXGPIOS_GPO0EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 245,
+				AXGPIOS_GPO2EN | AXGPIOS_GPO0EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO2 | AXGPIOS_GPO2EN |
+				AXGPIOS_GPO0EN);
+			if (ret)
+				goto err_out;
+
+		} else { /* vitesse */
+
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_RSE | AXGPIOS_GPO0EN |
+				AXGPIOS_GPO0);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 245,
+				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
+				AXGPIOS_GPO2EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO0EN | AXGPIOS_GPO0 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+		}
+
+	} else { /* use gpio1 */
+
+		if (priv->BuffaloOld) {
+			ret = asix_write_gpio(dev, 350,
+				AXGPIOS_GPO1 | AXGPIOS_GPO1EN |
+				AXGPIOS_RSE);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 350,
+				AXGPIOS_GPO1EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1);
+			if (ret)
+				goto err_out;
+		} else {
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO1 | AXGPIOS_GPO1EN |
+				AXGPIOS_RSE);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 25,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 245,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
+				AXGPIOS_GPO2EN);
+			if (ret)
+				goto err_out;
+			ret = asix_write_gpio(dev, 0,
+				AXGPIOS_GPO1EN | AXGPIOS_GPO1 |
+				AXGPIOS_GPO2EN | AXGPIOS_GPO2);
+			if (ret)
+				goto err_out;
+		}
+	}
+
+	ret = asix_phy_select(dev, 0);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_PRL, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: SW_RESET failed\n", __func__);
+		goto err_out;
+	}
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL, 0, 0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: RX_CTL failed\n", __func__);
+		goto err_out;
+	}
+
+	/* Get the MAC address */
+	ret = asix_read_mac(dev, AX88772_CMD_READ_NODE_ID);
+	if (ret < 0)
+		goto err_out;
+
+	ret = ax88178_phy_init(dev, priv);
+	if (ret < 0)
+		goto err_out;
+
+	dev->net->netdev_ops = &ax88x72_netdev_ops;
+	dev->net->ethtool_ops = &ax8817x_ethtool_ops;
+
+	/* Register suspend and resume functions */
+	data->suspend = ax88772_suspend;
+	data->resume = ax88772_resume;
+
+	if (dev->driver_info->flags & FLAG_FRAMING_AX)
+		dev->rx_urb_size = 16384;
+
+	ret = ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+			(AX_RX_CTL_MFB | AX_RX_CTL_START | AX_RX_CTL_AB),
+			0, 0, NULL);
+	if (ret < 0) {
+		netdev_err(dev->net, "%s: RX_CTL failed\n", __func__);
+		goto err_out;
+	}
+
+	printk(KERN_INFO "%s\n", driver_version);
+	return ret;
+
+err_out:
+	kfree(priv);
+	return ret;
+}
+
+static void ax88178_unbind(struct usbnet *dev, struct usb_interface *intf)
+{
+	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;
+
+	if (priv) {
+
+		/* stop MAC operation */
+		ax8817x_write_cmd(dev, AX_CMD_WRITE_RX_CTL,
+					AX_RX_CTL_STOP, 0, 0, NULL);
+		kfree(priv);
+	}
+}
+
+static int ax88772_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	u8  *head;
+	u32  header;
+	char *packet;
+	struct sk_buff *ax_skb;
+	u16 size;
+
+	head = (u8 *) skb->data;
+	memcpy(&header, head, sizeof(header));
+	le32_to_cpus(&header);
+	packet = head + sizeof(header);
 
-	if ((ret = asix_sw_reset(dev, AX_SWRESET_IPRL | AX_SWRESET_PRL)) < 0)
-		goto out;
+	skb_pull(skb, 4);
 
-	msleep(150);
+	while (skb->len > 0) {
+		if ((short)(header & 0x0000ffff) !=
+		    ~((short)((header & 0xffff0000) >> 16))) {
+			netdev_err(dev->net,
+				"%s: header length data is error 0x%08x, %d\n",
+				__func__, header, skb->len);
+		}
+		/* get the packet length */
+		size = (u16) (header & 0x0000ffff);
 
-	dev->net->netdev_ops = &ax88772_netdev_ops;
-	dev->net->ethtool_ops = &ax88772_ethtool_ops;
+		if ((skb->len) - ((size + 1) & 0xfffe) == 0) {
 
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR, BMCR_RESET);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
-			ADVERTISE_ALL | ADVERTISE_CSMA);
-	mii_nway_restart(&dev->mii);
+			/* Make sure ip header is aligned on 32-bit boundary */
+			if (!((unsigned long)skb->data & 0x02)) {
+				memmove(skb->data - 2, skb->data, size);
+				skb->data -= 2;
+				skb_set_tail_pointer(skb, size);
+			}
+			skb->truesize = size + sizeof(struct sk_buff);
+			return 2;
+		}
 
-	if ((ret = asix_write_medium_mode(dev, AX88772_MEDIUM_DEFAULT)) < 0)
-		goto out;
+		if (size > ETH_FRAME_LEN) {
+			netdev_err(dev->net, "%s: invalid rx length %d\n",
+							__func__, size);
+			return 0;
+		}
+		ax_skb = skb_clone(skb, GFP_ATOMIC);
+		if (ax_skb) {
 
-	if ((ret = asix_write_cmd(dev, AX_CMD_WRITE_IPG0,
-				AX88772_IPG0_DEFAULT | AX88772_IPG1_DEFAULT,
-				AX88772_IPG2_DEFAULT, 0, NULL)) < 0) {
-		dbg("Write IPG,IPG1,IPG2 failed: %d", ret);
-		goto out;
-	}
+			/* Make sure ip header is aligned on 32-bit boundary */
+			if (!((unsigned long)packet & 0x02)) {
+				memmove(packet - 2, packet, size);
+				packet -= 2;
+			}
+			ax_skb->data = packet;
+			skb_set_tail_pointer(ax_skb, size);
+			ax_skb->truesize = size + sizeof(struct sk_buff);
+			usbnet_skb_return(dev, ax_skb);
 
-	/* Set RX_CTL to default values with 2k buffer, and enable cactus */
-	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
-		goto out;
+		} else {
+			return 0;
+		}
 
-	rx_ctl = asix_read_rx_ctl(dev);
-	dbg("RX_CTL is 0x%04x after all initializations", rx_ctl);
+		skb_pull(skb, (size + 1) & 0xfffe);
 
-	rx_ctl = asix_read_medium_status(dev);
-	dbg("Medium Status is 0x%04x after all initializations", rx_ctl);
+		if (skb->len == 0)
+			break;
 
-	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
-	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
-		/* hard_mtu  is still the default - the device does not support
-		   jumbo eth frames */
-		dev->rx_urb_size = 2048;
+		head = (u8 *) skb->data;
+		memcpy(&header, head, sizeof(header));
+		le32_to_cpus(&header);
+		packet = head + sizeof(header);
+		skb_pull(skb, 4);
 	}
-	return 0;
 
-out:
-	return ret;
+	if (skb->len < 0) {
+		netdev_err(dev->net, "%s: invalid rx length %d\n",
+						__func__, skb->len);
+		return 0;
+	}
+	return 1;
 }
 
-static struct ethtool_ops ax88178_ethtool_ops = {
-	.get_drvinfo		= asix_get_drvinfo,
-	.get_link		= asix_get_link,
-	.get_msglevel		= usbnet_get_msglevel,
-	.set_msglevel		= usbnet_set_msglevel,
-	.get_wol		= asix_get_wol,
-	.set_wol		= asix_set_wol,
-	.get_eeprom_len		= asix_get_eeprom_len,
-	.get_eeprom		= asix_get_eeprom,
-	.get_settings		= usbnet_get_settings,
-	.set_settings		= usbnet_set_settings,
-	.nway_reset		= usbnet_nway_reset,
-};
-
-static int marvell_phy_init(struct usbnet *dev)
+static struct sk_buff *ax88772_tx_fixup(struct usbnet *dev,
+					struct sk_buff *skb, gfp_t flags)
 {
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u16 reg;
-
-	netdev_dbg(dev->net, "marvell_phy_init()\n");
+	int padlen = ((skb->len + 4) % 512) ? 0 : 4;
+	u32 packet_len;
+	u32 padbytes = 0xffff0000;
+	int headroom = skb_headroom(skb);
+	int tailroom = skb_tailroom(skb);
 
-	reg = asix_mdio_read(dev->net, dev->mii.phy_id, MII_MARVELL_STATUS);
-	netdev_dbg(dev->net, "MII_MARVELL_STATUS = 0x%04x\n", reg);
+	if ((!skb_cloned(skb))
+	    && ((headroom + tailroom) >= (4 + padlen))) {
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
 
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_MARVELL_CTRL,
-			MARVELL_CTRL_RXDELAY | MARVELL_CTRL_TXDELAY);
+	skb_push(skb, 4);
+	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
+	cpu_to_le32s(&packet_len);
+	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));
 
-	if (data->ledmode) {
-		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL);
-		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (1) = 0x%04x\n", reg);
-
-		reg &= 0xf8ff;
-		reg |= (1 + 0x0100);
-		asix_mdio_write(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL, reg);
-
-		reg = asix_mdio_read(dev->net, dev->mii.phy_id,
-			MII_MARVELL_LED_CTRL);
-		netdev_dbg(dev->net, "MII_MARVELL_LED_CTRL (2) = 0x%04x\n", reg);
-		reg &= 0xfc0f;
+	if ((skb->len % 512) == 0) {
+		cpu_to_le32s(&padbytes);
+		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
+		skb_put(skb, sizeof(padbytes));
 	}
-
-	return 0;
+	return skb;
 }
 
-static int marvell_led_status(struct usbnet *dev, u16 speed)
+static void
+ax88772b_rx_checksum(struct sk_buff *skb, struct ax88772b_rx_header *rx_hdr)
 {
-	u16 reg = asix_mdio_read(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL);
-
-	netdev_dbg(dev->net, "marvell_led_status() read 0x%04x\n", reg);
+	skb->ip_summed = CHECKSUM_NONE;
 
-	/* Clear out the center LED bits - 0x03F0 */
-	reg &= 0xfc0f;
+	/* checksum error bit is set */
+	if (rx_hdr->l3_csum_err || rx_hdr->l4_csum_err)
+		return;
 
-	switch (speed) {
-		case SPEED_1000:
-			reg |= 0x03e0;
-			break;
-		case SPEED_100:
-			reg |= 0x03b0;
-			break;
-		default:
-			reg |= 0x02f0;
+	/* It must be a TCP or UDP packet with a valid checksum */
+	if ((rx_hdr->l4_type == AX_RXHDR_L4_TYPE_TCP) ||
+	    (rx_hdr->l4_type == AX_RXHDR_L4_TYPE_UDP)) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
-
-	netdev_dbg(dev->net, "marvell_led_status() writing 0x%04x\n", reg);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MARVELL_LED_MANUAL, reg);
-
-	return 0;
 }
 
-static int ax88178_link_reset(struct usbnet *dev)
+static int ax88772b_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 {
-	u16 mode;
-	struct ethtool_cmd ecmd = { .cmd = ETHTOOL_GSET };
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	u32 speed;
-
-	netdev_dbg(dev->net, "ax88178_link_reset()\n");
-
-	mii_check_media(&dev->mii, 1, 1);
-	mii_ethtool_gset(&dev->mii, &ecmd);
-	mode = AX88178_MEDIUM_DEFAULT;
-	speed = ethtool_cmd_speed(&ecmd);
-
-	if (speed == SPEED_1000)
-		mode |= AX_MEDIUM_GM;
-	else if (speed == SPEED_100)
-		mode |= AX_MEDIUM_PS;
-	else
-		mode &= ~(AX_MEDIUM_PS | AX_MEDIUM_GM);
+	struct ax88772b_rx_header rx_hdr;
+	struct sk_buff *ax_skb;
+	struct ax88772b_data *priv = (struct ax88772b_data *)dev->driver_priv;
 
-	mode |= AX_MEDIUM_ENCK;
+	while (skb->len > 0) {
 
-	if (ecmd.duplex == DUPLEX_FULL)
-		mode |= AX_MEDIUM_FD;
-	else
-		mode &= ~AX_MEDIUM_FD;
+		memcpy(&rx_hdr, skb->data, sizeof(struct ax88772b_rx_header));
 
-	netdev_dbg(dev->net, "ax88178_link_reset() speed: %u duplex: %d setting mode to 0x%04x\n",
-		   speed, ecmd.duplex, mode);
+		if ((short)rx_hdr.len != (~((short)rx_hdr.len_bar) & 0x7FF))
+			return 0;
+		if (rx_hdr.len > (ETH_FRAME_LEN + 4)) {
+			netdev_err(dev->net, "%s: invalid rx length %d\n",
+						__func__, rx_hdr.len);
+			return 0;
+		}
 
-	asix_write_medium_mode(dev, mode);
+		if (skb->len - ((rx_hdr.len +
+				 sizeof(struct ax88772b_rx_header) + 3) &
+				 0xfffc) == 0) {
+			skb_pull(skb, sizeof(struct ax88772b_rx_header));
+			skb->len = rx_hdr.len;
 
-	if (data->phymode == PHY_MODE_MARVELL && data->ledmode)
-		marvell_led_status(dev, speed);
+			skb_set_tail_pointer(skb, rx_hdr.len);
+			skb->truesize = rx_hdr.len + sizeof(struct sk_buff);
 
-	return 0;
-}
+			if (priv->checksum & AX_RX_CHECKSUM)
+				ax88772b_rx_checksum(skb, &rx_hdr);
 
-static void ax88178_set_mfb(struct usbnet *dev)
-{
-	u16 mfb = AX_RX_CTL_MFB_16384;
-	u16 rxctl;
-	u16 medium;
-	int old_rx_urb_size = dev->rx_urb_size;
+			return 2;
+		}
 
-	if (dev->hard_mtu < 2048) {
-		dev->rx_urb_size = 2048;
-		mfb = AX_RX_CTL_MFB_2048;
-	} else if (dev->hard_mtu < 4096) {
-		dev->rx_urb_size = 4096;
-		mfb = AX_RX_CTL_MFB_4096;
-	} else if (dev->hard_mtu < 8192) {
-		dev->rx_urb_size = 8192;
-		mfb = AX_RX_CTL_MFB_8192;
-	} else if (dev->hard_mtu < 16384) {
-		dev->rx_urb_size = 16384;
-		mfb = AX_RX_CTL_MFB_16384;
-	}
+		ax_skb = skb_clone(skb, GFP_ATOMIC);
+		if (ax_skb) {
+			ax_skb->len = rx_hdr.len;
+			ax_skb->data = skb->data +
+				       sizeof(struct ax88772b_rx_header);
+			skb_set_tail_pointer(ax_skb, rx_hdr.len);
+			ax_skb->truesize = rx_hdr.len + sizeof(struct sk_buff);
+			if (priv->checksum & AX_RX_CHECKSUM)
+				ax88772b_rx_checksum(ax_skb, &rx_hdr);
+			usbnet_skb_return(dev, ax_skb);
 
-	rxctl = asix_read_rx_ctl(dev);
-	asix_write_rx_ctl(dev, (rxctl & ~AX_RX_CTL_MFB_16384) | mfb);
+		} else {
+			return 0;
+		}
 
-	medium = asix_read_medium_status(dev);
-	if (dev->net->mtu > 1500)
-		medium |= AX_MEDIUM_JFE;
-	else
-		medium &= ~AX_MEDIUM_JFE;
-	asix_write_medium_mode(dev, medium);
+		skb_pull(skb, ((rx_hdr.len +
+				sizeof(struct ax88772b_rx_header) + 3)
+				& 0xfffc));
+	}
 
-	if (dev->rx_urb_size > old_rx_urb_size)
-		usbnet_unlink_rx_urbs(dev);
+	if (skb->len < 0) {
+		netdev_err(dev->net, "%s: invalid rx length %d\n",
+					__func__, skb->len);
+		return 0;
+	}
+	return 1;
 }
 
-static int ax88178_change_mtu(struct net_device *net, int new_mtu)
+static struct sk_buff *
+ax88772b_tx_fixup(struct usbnet *dev, struct sk_buff *skb, gfp_t flags)
 {
-	struct usbnet *dev = netdev_priv(net);
-	int ll_mtu = new_mtu + net->hard_header_len + 4;
+	int padlen = ((skb->len + 4) % 512) ? 0 : 4;
+	u32 packet_len;
+	u32 padbytes = 0xffff0000;
+	int headroom = skb_headroom(skb);
+	int tailroom = skb_tailroom(skb);
 
-	netdev_dbg(dev->net, "ax88178_change_mtu() new_mtu=%d\n", new_mtu);
+	if ((!skb_cloned(skb))
+	    && ((headroom + tailroom) >= (4 + padlen))) {
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
 
-	if (new_mtu <= 0 || ll_mtu > 16384)
-		return -EINVAL;
+	skb_push(skb, 4);
+	packet_len = (((skb->len - 4) ^ 0x0000ffff) << 16) + (skb->len - 4);
 
-	if ((ll_mtu % dev->maxpacket) == 0)
-		return -EDOM;
+	cpu_to_le32s(&packet_len);
+	skb_copy_to_linear_data(skb, &packet_len, sizeof(packet_len));
 
-	net->mtu = new_mtu;
-	dev->hard_mtu = net->mtu + net->hard_header_len;
-	ax88178_set_mfb(dev);
+	if ((skb->len % 512) == 0) {
+		cpu_to_le32s(&padbytes);
+		memcpy(skb_tail_pointer(skb), &padbytes, sizeof(padbytes));
+		skb_put(skb, sizeof(padbytes));
+	}
 
-	return 0;
+	return skb;
 }
 
-static const struct net_device_ops ax88178_netdev_ops = {
-	.ndo_open		= usbnet_open,
-	.ndo_stop		= usbnet_stop,
-	.ndo_start_xmit		= usbnet_start_xmit,
-	.ndo_tx_timeout		= usbnet_tx_timeout,
-	.ndo_set_mac_address 	= asix_set_mac_address,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_set_multicast_list = asix_set_multicast,
-	.ndo_do_ioctl 		= asix_ioctl,
-	.ndo_change_mtu 	= ax88178_change_mtu,
+static const u8 ChkCntSel[6][3] = {
+	{12, 23, 31},
+	{12, 31, 23},
+	{23, 31, 12},
+	{23, 12, 31},
+	{31, 12, 23},
+	{31, 23, 12}
 };
 
-static int ax88178_bind(struct usbnet *dev, struct usb_interface *intf)
+static void ax88772_link_reset(struct work_struct *work)
 {
-	struct asix_data *data = (struct asix_data *)&dev->data;
-	int ret;
-	u8 buf[ETH_ALEN];
-	__le16 eeprom;
-	u8 status;
-	int gpio0 = 0;
-	u32 phyid;
-
-	usbnet_get_endpoints(dev,intf);
-
-	asix_read_cmd(dev, AX_CMD_READ_GPIOS, 0, 0, 1, &status);
-	dbg("GPIO Status: 0x%04x", status);
-
-	asix_write_cmd(dev, AX_CMD_WRITE_ENABLE, 0, 0, 0, NULL);
-	asix_read_cmd(dev, AX_CMD_READ_EEPROM, 0x0017, 0, 2, &eeprom);
-	asix_write_cmd(dev, AX_CMD_WRITE_DISABLE, 0, 0, 0, NULL);
-
-	dbg("EEPROM index 0x17 is 0x%04x", eeprom);
-
-	if (eeprom == cpu_to_le16(0xffff)) {
-		data->phymode = PHY_MODE_MARVELL;
-		data->ledmode = 0;
-		gpio0 = 1;
-	} else {
-		data->phymode = le16_to_cpu(eeprom) & 7;
-		data->ledmode = le16_to_cpu(eeprom) >> 8;
-		gpio0 = (le16_to_cpu(eeprom) & 0x80) ? 0 : 1;
-	}
-	dbg("GPIO0: %d, PhyMode: %d", gpio0, data->phymode);
-
-	asix_write_gpio(dev, AX_GPIO_RSE | AX_GPIO_GPO_1 | AX_GPIO_GPO1EN, 40);
-	if ((le16_to_cpu(eeprom) >> 8) != 1) {
-		asix_write_gpio(dev, 0x003c, 30);
-		asix_write_gpio(dev, 0x001c, 300);
-		asix_write_gpio(dev, 0x003c, 30);
-	} else {
-		dbg("gpio phymode == 1 path");
-		asix_write_gpio(dev, AX_GPIO_GPO1EN, 30);
-		asix_write_gpio(dev, AX_GPIO_GPO1EN | AX_GPIO_GPO_1, 30);
+	struct ax88772_data *priv = container_of(work,
+					struct ax88772_data, check_link);
+	struct usbnet *dev = priv->dev;
+
+	if (priv->Event == AX_SET_RX_CFG) {
+		u16 bmcr;
+		u16 mode;
+
+		priv->Event = AX_NOP;
+
+		mode = AX88772_MEDIUM_DEFAULT;
+
+		bmcr = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_BMCR);
+		if (!(bmcr & BMCR_FULLDPLX))
+			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
+		if (!(bmcr & BMCR_SPEED100))
+			mode &= ~AX88772_MEDIUM_100MB;
+		asix_write_medium_mode(dev, mode);
+		return;
 	}
 
-	asix_sw_reset(dev, 0);
-	msleep(150);
-
-	asix_sw_reset(dev, AX_SWRESET_PRL | AX_SWRESET_IPPD);
-	msleep(150);
-
-	asix_write_rx_ctl(dev, 0);
+	switch (priv->Event) {
+	case WAIT_AUTONEG_COMPLETE:
+		if (jiffies > (priv->autoneg_start + 5 * HZ)) {
+			priv->Event = PHY_POWER_DOWN;
+			priv->TickToExpire = 23;
+		}
+		break;
+	case PHY_POWER_DOWN:
+		if (priv->TickToExpire == 23) {
+			/* Set Phy Power Down */
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					  AX_SWRESET_IPPD,
+					  0, 0, NULL);
+			--priv->TickToExpire;
+		} else if (--priv->TickToExpire == 0) {
+			/* Set Phy Power Up */
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL, 0, 0, NULL);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPPD | AX_SWRESET_IPRL, 0, 0, NULL);
+			usleep_range(10000, 20000);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL, 0, 0, NULL);
+			msleep(60);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_CLEAR, 0, 0, NULL);
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+				AX_SWRESET_IPRL, 0, 0, NULL);
+			ax8817x_mdio_write_le(dev->net, dev->mii.phy_id,
+				MII_ADVERTISE,
+				ADVERTISE_ALL | ADVERTISE_CSMA |
+				ADVERTISE_PAUSE_CAP);
+			mii_nway_restart(&dev->mii);
 
-	/* Get the MAC address */
-	if ((ret = asix_read_cmd(dev, AX_CMD_READ_NODE_ID,
-				0, 0, ETH_ALEN, buf)) < 0) {
-		dbg("Failed to read MAC address: %d", ret);
-		goto out;
+			priv->Event = PHY_POWER_UP;
+			priv->TickToExpire = 47;
+		}
+		break;
+	case PHY_POWER_UP:
+		if (--priv->TickToExpire == 0) {
+			priv->Event = PHY_POWER_DOWN;
+			priv->TickToExpire = 23;
+		}
+		break;
+	default:
+		break;
 	}
-	memcpy(dev->net->dev_addr, buf, ETH_ALEN);
+	return;
+}
 
-	/* Initialize MII structure */
-	dev->mii.dev = dev->net;
-	dev->mii.mdio_read = asix_mdio_read;
-	dev->mii.mdio_write = asix_mdio_write;
-	dev->mii.phy_id_mask = 0x1f;
-	dev->mii.reg_num_mask = 0xff;
-	dev->mii.supports_gmii = 1;
-	dev->mii.phy_id = asix_get_phy_addr(dev);
+static void ax88772a_link_reset(struct work_struct *work)
+{
+	struct ax88772a_data *priv = container_of(work,
+					struct ax88772a_data, check_link);
+	struct usbnet *dev = priv->dev;
+	int PowSave = (priv->EepromData >> 14);
+	u16 phy_reg;
+
+	if (priv->Event == AX_SET_RX_CFG) {
+		u16 bmcr;
+		u16 mode;
 
-	dev->net->netdev_ops = &ax88178_netdev_ops;
-	dev->net->ethtool_ops = &ax88178_ethtool_ops;
+		priv->Event = AX_NOP;
 
-	phyid = asix_get_phyid(dev);
-	dbg("PHYID=0x%08x", phyid);
+		mode = AX88772_MEDIUM_DEFAULT;
 
-	if (data->phymode == PHY_MODE_MARVELL) {
-		marvell_phy_init(dev);
-		msleep(60);
+		bmcr = ax8817x_mdio_read_le(dev->net,
+				dev->mii.phy_id, MII_BMCR);
+		if (!(bmcr & BMCR_FULLDPLX))
+			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
+		if (!(bmcr & BMCR_SPEED100))
+			mode &= ~AX88772_MEDIUM_100MB;
+		asix_write_medium_mode(dev, mode);
+		return;
 	}
 
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_BMCR,
-			BMCR_RESET | BMCR_ANENABLE);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+	switch (priv->Event) {
+	case WAIT_AUTONEG_COMPLETE:
+		if (jiffies > (priv->autoneg_start + 5 * HZ)) {
+			priv->Event = CHK_CABLE_EXIST;
+			priv->TickToExpire = 14;
+		}
+		break;
+	case CHK_CABLE_EXIST:
+		phy_reg = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+		if ((phy_reg != 0x8012) && (phy_reg != 0x8013)) {
+			ax8817x_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x16, 0x4040);
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_STATUS;
+			priv->TickToExpire = 31;
+		} else if (--priv->TickToExpire == 0) {
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_EXIST_AGAIN;
+			if (PowSave == 0x03) {
+				priv->TickToExpire = 47;
+			} else if (PowSave == 0x01) {
+				priv->DlyIndex = (u8)(jiffies % 6);
+				priv->DlySel = 0;
+				priv->TickToExpire =
+				ChkCntSel[priv->DlyIndex][priv->DlySel];
+			}
+		}
+		break;
+	case CHK_CABLE_EXIST_AGAIN:
+		/* if cable disconnected */
+		phy_reg = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+		if ((phy_reg != 0x8012) && (phy_reg != 0x8013)) {
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_STATUS;
+			priv->TickToExpire = 31;
+		} else if (--priv->TickToExpire == 0) {
+			/* Power down PHY */
+			ax8817x_write_cmd(dev, AX_CMD_SW_RESET,
+					  AX_SWRESET_IPPD,
+					  0, 0, NULL);
+			priv->Event = PHY_POWER_DOWN;
+			if (PowSave == 0x03)
+				priv->TickToExpire = 23;
+			else if (PowSave == 0x01)
+				priv->TickToExpire = 31;
+		}
+		break;
+	case PHY_POWER_DOWN:
+		if (--priv->TickToExpire == 0)
+			priv->Event = PHY_POWER_UP;
+		break;
+	case CHK_CABLE_STATUS:
+		if (--priv->TickToExpire == 0) {
+			ax8817x_mdio_write_le(dev->net,
+				dev->mii.phy_id, 0x16, 0x4040);
+			mii_nway_restart(&dev->mii);
+			priv->Event = CHK_CABLE_EXIST_AGAIN;
+			if (PowSave == 0x03) {
+				priv->TickToExpire = 47;
+			} else if (PowSave == 0x01) {
+				priv->DlyIndex = (u8)(jiffies % 6);
+				priv->DlySel = 0;
+				priv->TickToExpire =
+				ChkCntSel[priv->DlyIndex][priv->DlySel];
+			}
+		}
+		break;
+	case PHY_POWER_UP:
+		ax88772a_phy_powerup(dev);
+		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
+			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
+		mii_nway_restart(&dev->mii);
+		priv->Event = CHK_CABLE_EXIST_AGAIN;
+		if (PowSave == 0x03) {
+			priv->TickToExpire = 47;
+		} else if (PowSave == 0x01) {
+			if (++priv->DlySel >= 3) {
+				priv->DlyIndex = (u8)(jiffies % 6);
+				priv->DlySel = 0;
+			}
+			priv->TickToExpire =
+				ChkCntSel[priv->DlyIndex][priv->DlySel];
+		}
+		break;
+	default:
+		break;
+	}
+
+	return;
+}
+
+static void ax88772b_link_reset(struct work_struct *work)
+{
+	struct ax88772b_data *priv = container_of(work,
+					struct ax88772b_data, check_link);
+	struct usbnet *dev = priv->dev;
+
+	switch (priv->Event) {
+	case AX_SET_RX_CFG:
+	{
+		u16 bmcr = ax8817x_mdio_read_le(dev->net,
+					dev->mii.phy_id, MII_BMCR);
+		u16 mode = AX88772_MEDIUM_DEFAULT;
+
+		if (!(bmcr & BMCR_FULLDPLX))
+			mode &= ~AX88772_MEDIUM_FULL_DUPLEX;
+		if (!(bmcr & BMCR_SPEED100))
+			mode &= ~AX88772_MEDIUM_100MB;
+		asix_write_medium_mode(dev, mode);
+		break;
+	}
+	case PHY_POWER_UP:
+	{
+		u16 tmp16;
+
+		ax88772a_phy_powerup(dev);
+		tmp16 = ax8817x_mdio_read_le(dev->net, dev->mii.phy_id, 0x12);
+		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, 0x12,
+				((tmp16 & 0xFF9F) | 0x0040));
+		ax8817x_mdio_write_le(dev->net, dev->mii.phy_id, MII_ADVERTISE,
 			ADVERTISE_ALL | ADVERTISE_CSMA | ADVERTISE_PAUSE_CAP);
-	asix_mdio_write(dev->net, dev->mii.phy_id, MII_CTRL1000,
-			ADVERTISE_1000FULL);
+		break;
+	}
+	default:
+		break;
+	}
 
-	mii_nway_restart(&dev->mii);
+	priv->Event = AX_NOP;
 
-	if ((ret = asix_write_medium_mode(dev, AX88178_MEDIUM_DEFAULT)) < 0)
-		goto out;
+	return;
+}
 
-	if ((ret = asix_write_rx_ctl(dev, AX_DEFAULT_RX_CTL)) < 0)
-		goto out;
+static int ax88178_set_media(struct usbnet *dev)
+{
+	int	ret;
+	struct ax88178_data *priv = (struct ax88178_data *)dev->driver_priv;
+	int media;
 
-	/* Asix framing packs multiple eth frames into a 2K usb bulk transfer */
-	if (dev->driver_info->flags & FLAG_FRAMING_AX) {
-		/* hard_mtu  is still the default - the device does not support
-		   jumbo eth frames */
-		dev->rx_urb_size = 2048;
-	}
+	media = ax88178_media_check(dev, priv);
+	if (media < 0)
+		return media;
+	ret = asix_write_medium_mode(dev, media);
+	if (ret < 0)
+		return ret;
 	return 0;
+}
 
-out:
-	return ret;
+static int ax88178_link_reset(struct usbnet *dev)
+{
+	return ax88178_set_media(dev);
+}
+
+static int ax_suspend(struct usb_interface *intf,
+			pm_message_t message)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+
+	return data->suspend(intf, message);
+}
+
+static int ax_resume(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct ax8817x_data *data = (struct ax8817x_data *)&dev->data;
+
+	return data->resume(intf);
 }
 
+static const struct driver_info ax88178_info = {
+	.description = "ASIX AX88178 USB 2.0 Ethernet",
+	.bind = ax88178_bind,
+	.unbind = ax88178_unbind,
+	.status = ax88178_status,
+	.link_reset = ax88178_link_reset,
+	.reset = ax88178_link_reset,
+	.flags =  FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
+};
+
+static const struct driver_info belkin178_info = {
+	.description = "Belkin Gigabit USB 2.0 Network Adapter",
+	.bind = ax88178_bind,
+	.unbind = ax88178_unbind,
+	.status = ax8817x_status,
+	.link_reset = ax88178_link_reset,
+	.reset = ax88178_link_reset,
+	.flags =  FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
+};
+
 static const struct driver_info ax8817x_info = {
 	.description = "ASIX AX8817x USB 2.0 Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x00130103,
+	.flags =  FLAG_ETHER,
 };
 
 static const struct driver_info dlink_dub_e100_info = {
 	.description = "DLink DUB-E100 USB Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x009f9d9f,
+	.flags =  FLAG_ETHER,
 };
 
 static const struct driver_info netgear_fa120_info = {
 	.description = "Netgear FA-120 USB Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x00130103,
+	.flags =  FLAG_ETHER,
 };
 
 static const struct driver_info hawking_uf200_info = {
 	.description = "Hawking UF200 USB Ethernet",
-	.bind = ax88172_bind,
-	.status = asix_status,
+	.bind = ax8817x_bind,
+	.status = ax8817x_status,
 	.link_reset = ax88172_link_reset,
 	.reset = ax88172_link_reset,
-	.flags =  FLAG_ETHER | FLAG_LINK_INTR,
-	.data = 0x001f1d1f,
+	.flags =  FLAG_ETHER,
 };
 
 static const struct driver_info ax88772_info = {
 	.description = "ASIX AX88772 USB 2.0 Ethernet",
 	.bind = ax88772_bind,
-	.status = asix_status,
-	.link_reset = ax88772_link_reset,
-	.reset = ax88772_link_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
-	.rx_fixup = asix_rx_fixup,
-	.tx_fixup = asix_tx_fixup,
+	.unbind = ax88772_unbind,
+	.status = ax88772_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
 };
 
-static const struct driver_info ax88178_info = {
-	.description = "ASIX AX88178 USB 2.0 Ethernet",
-	.bind = ax88178_bind,
-	.status = asix_status,
-	.link_reset = ax88178_link_reset,
-	.reset = ax88178_link_reset,
-	.flags = FLAG_ETHER | FLAG_FRAMING_AX | FLAG_LINK_INTR,
-	.rx_fixup = asix_rx_fixup,
-	.tx_fixup = asix_tx_fixup,
+static const struct driver_info dlink_dub_e100b_info = {
+	.description = "D-Link DUB-E100 USB 2.0 Fast Ethernet Adapter",
+	.bind = ax88772_bind,
+	.unbind = ax88772_unbind,
+	.status = ax88772_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
 };
 
-static const struct usb_device_id	products [] = {
+static const struct driver_info ax88772a_info = {
+	.description = "ASIX AX88772A USB 2.0 Ethernet",
+	.bind = ax88772a_bind,
+	.unbind = ax88772a_unbind,
+	.status = ax88772a_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772_rx_fixup,
+	.tx_fixup = ax88772_tx_fixup,
+};
+
+static const struct driver_info ax88772b_info = {
+	.description = "ASIX AX88772B USB 2.0 Ethernet",
+	.bind = ax88772b_bind,
+	.unbind = ax88772b_unbind,
+	.status = ax88772b_status,
+	.flags = FLAG_ETHER | FLAG_FRAMING_AX,
+	.rx_fixup = ax88772b_rx_fixup,
+	.tx_fixup = ax88772b_tx_fixup,
+};
+
+static const struct usb_device_id	products[] = {
 {
-	// Linksys USB200M
-	USB_DEVICE (0x077b, 0x2226),
+	/* 88178 */
+	USB_DEVICE(0x0b95, 0x1780),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* 88178 for billianton linksys */
+	USB_DEVICE(0x077b, 0x2226),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* ABOCOM for linksys */
+	USB_DEVICE(0x1737, 0x0039),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* ABOCOM  for pci */
+	USB_DEVICE(0x14ea, 0xab11),
+	.driver_info =	(unsigned long) &ax88178_info,
+}, {
+	/* Belkin */
+	USB_DEVICE(0x050d, 0x5055),
+	.driver_info =	(unsigned long) &belkin178_info,
+}, {
+	/* Linksys USB200M */
+	USB_DEVICE(0x077b, 0x2226),
 	.driver_info =	(unsigned long) &ax8817x_info,
 }, {
-	// Netgear FA120
-	USB_DEVICE (0x0846, 0x1040),
+	/* Netgear FA120 */
+	USB_DEVICE(0x0846, 0x1040),
 	.driver_info =  (unsigned long) &netgear_fa120_info,
 }, {
-	// DLink DUB-E100
-	USB_DEVICE (0x2001, 0x1a00),
+	/* DLink DUB-E100 */
+	USB_DEVICE(0x2001, 0x1a00),
 	.driver_info =  (unsigned long) &dlink_dub_e100_info,
 }, {
-	// Intellinet, ST Lab USB Ethernet
-	USB_DEVICE (0x0b95, 0x1720),
+	/* DLink DUB-E100B */
+	USB_DEVICE(0x2001, 0x3c05),
+	.driver_info =  (unsigned long) &dlink_dub_e100b_info,
+}, {
+	/* DLink DUB-E100B */
+	USB_DEVICE(0x07d1, 0x3c05),
+	.driver_info =  (unsigned long) &dlink_dub_e100b_info,
+}, {
+	/* Intellinet, ST Lab USB Ethernet */
+	USB_DEVICE(0x0b95, 0x1720),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Hawking UF200, TrendNet TU2-ET100
-	USB_DEVICE (0x07b8, 0x420a),
+	/* Hawking UF200, TrendNet TU2-ET100 */
+	USB_DEVICE(0x07b8, 0x420a),
 	.driver_info =  (unsigned long) &hawking_uf200_info,
 }, {
-	// Billionton Systems, USB2AR
-	USB_DEVICE (0x08dd, 0x90ff),
+	/* Billionton Systems, USB2AR */
+	USB_DEVICE(0x08dd, 0x90ff),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// ATEN UC210T
-	USB_DEVICE (0x0557, 0x2009),
+	/* ATEN UC210T */
+	USB_DEVICE(0x0557, 0x2009),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Buffalo LUA-U2-KTX
-	USB_DEVICE (0x0411, 0x003d),
+	/* Buffalo LUA-U2-KTX */
+	USB_DEVICE(0x0411, 0x003d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Buffalo LUA-U2-GT 10/100/1000
-	USB_DEVICE (0x0411, 0x006e),
-	.driver_info =  (unsigned long) &ax88178_info,
-}, {
-	// Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter"
-	USB_DEVICE (0x6189, 0x182d),
+	/* Sitecom LN-029 "USB 2.0 10/100 Ethernet adapter" */
+	USB_DEVICE(0x6189, 0x182d),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// corega FEther USB2-TX
-	USB_DEVICE (0x07aa, 0x0017),
+	/* corega FEther USB2-TX */
+	USB_DEVICE(0x07aa, 0x0017),
 	.driver_info =  (unsigned long) &ax8817x_info,
 }, {
-	// Surecom EP-1427X-2
-	USB_DEVICE (0x1189, 0x0893),
-	.driver_info = (unsigned long) &ax8817x_info,
-}, {
-	// goodway corp usb gwusb2e
-	USB_DEVICE (0x1631, 0x6200),
+	/* Surecom EP-1427X-2 */
+	USB_DEVICE(0x1189, 0x0893),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
-	// JVC MP-PRX1 Port Replicator
-	USB_DEVICE (0x04f1, 0x3008),
+	/* goodway corp usb gwusb2e */
+	USB_DEVICE(0x1631, 0x6200),
 	.driver_info = (unsigned long) &ax8817x_info,
 }, {
-	// ASIX AX88772B 10/100
-	USB_DEVICE (0x0b95, 0x772b),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// ASIX AX88772 10/100
-	USB_DEVICE (0x0b95, 0x7720),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// ASIX AX88178 10/100/1000
-	USB_DEVICE (0x0b95, 0x1780),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// Logitec LAN-GTJ/U2A
-	USB_DEVICE (0x0789, 0x0160),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// Linksys USB200M Rev 2
-	USB_DEVICE (0x13b1, 0x0018),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// 0Q0 cable ethernet
-	USB_DEVICE (0x1557, 0x7720),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// DLink DUB-E100 H/W Ver B1
-	USB_DEVICE (0x07d1, 0x3c05),
+	/* ASIX AX88772 10/100 */
+	USB_DEVICE(0x0b95, 0x7720),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// DLink DUB-E100 H/W Ver B1 Alternate
-	USB_DEVICE (0x2001, 0x3c05),
+	/* ASIX AX88772 10/100 */
+	USB_DEVICE(0x125E, 0x180D),
 	.driver_info = (unsigned long) &ax88772_info,
 }, {
-	// Linksys USB1000
-	USB_DEVICE (0x1737, 0x0039),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// IO-DATA ETG-US2
-	USB_DEVICE (0x04bb, 0x0930),
-	.driver_info = (unsigned long) &ax88178_info,
+	/* ASIX AX88772A 10/100 */
+	USB_DEVICE(0x0b95, 0x772A),
+	.driver_info = (unsigned long) &ax88772a_info,
+}, {
+	/* ASIX AX88772A 10/100 */
+	USB_DEVICE(0x0db0, 0xA877),
+	.driver_info = (unsigned long) &ax88772a_info,
+}, {
+	/* ASIX AX88772A 10/100 */
+	USB_DEVICE(0x0421, 0x772A),
+	.driver_info = (unsigned long) &ax88772a_info,
+}, {
+	/* Linksys 200M */
+	USB_DEVICE(0x13B1, 0x0018),
+	.driver_info = (unsigned long) &ax88772a_info,
 }, {
-	// Belkin F5D5055
-	USB_DEVICE(0x050d, 0x5055),
-	.driver_info = (unsigned long) &ax88178_info,
-}, {
-	// Apple USB Ethernet Adapter
 	USB_DEVICE(0x05ac, 0x1402),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// Cables-to-Go USB Ethernet Adapter
-	USB_DEVICE(0x0b95, 0x772a),
-	.driver_info = (unsigned long) &ax88772_info,
-}, {
-	// ABOCOM for pci
-	USB_DEVICE(0x14ea, 0xab11),
-	.driver_info = (unsigned long) &ax88178_info,
+	.driver_info = (unsigned long) &ax88772a_info,
 }, {
-	// ASIX 88772a
-	USB_DEVICE(0x0db0, 0xa877),
-	.driver_info = (unsigned long) &ax88772_info,
+	/* ASIX AX88772B 10/100 */
+	USB_DEVICE(0x0b95, 0x772B),
+	.driver_info = (unsigned long) &ax88772b_info,
+}, {
+	/* ASIX AX88772B 10/100 */
+	USB_DEVICE(0x0b95, 0x7E2B),
+	.driver_info = (unsigned long) &ax88772b_info,
 },
-	{ },		// END
+	{ },		/* END */
 };
 MODULE_DEVICE_TABLE(usb, products);
 
 static struct usb_driver asix_driver = {
-	.name =		"asix",
+	.name =		driver_name,
 	.id_table =	products,
 	.probe =	usbnet_probe,
-	.suspend =	usbnet_suspend,
-	.resume =	usbnet_resume,
+	.suspend =	ax_suspend,
+	.resume =	ax_resume,
 	.disconnect =	usbnet_disconnect,
-	.supports_autosuspend = 1,
 };
 
 static int __init asix_init(void)
 {
- 	return usb_register(&asix_driver);
+	return usb_register(&asix_driver);
 }
 module_init(asix_init);
 
 static void __exit asix_exit(void)
 {
- 	usb_deregister(&asix_driver);
+	usb_deregister(&asix_driver);
 }
 module_exit(asix_exit);
 
--- pristine/drivers/net/usb/asix.h	1969-12-31 19:00:00.000000000 -0500
+++ linux/drivers/net/usb/asix.h	2011-11-02 15:15:34.099164264 -0400
@@ -0,0 +1,526 @@
+#ifndef	__LINUX_USBNET_ASIX_H
+#define	__LINUX_USBNET_ASIX_H
+
+/*
+ * Turn on this flag if the implementation of your USB host controller
+ * cannot handle non-double word aligned buffer.
+ * When turn on this flag, driver will fixup egress packet aligned on double
+ * word boundary before deliver to USB host controller. And will Disable the
+ * function "skb_reserve (skb, NET_IP_ALIGN)" to retain the buffer aligned on
+ * double word alignment for ingress packets.
+ */
+#define AX_FORCE_BUFF_ALIGN		0
+
+#define AX_MONITOR_MODE			0x01
+#define AX_MONITOR_LINK			0x02
+#define AX_MONITOR_MAGIC		0x04
+#define AX_MONITOR_HSFS			0x10
+
+/* AX88172 Medium Status Register values */
+#define AX_MEDIUM_FULL_DUPLEX		0x02
+#define AX_MEDIUM_TX_ABORT_ALLOW	0x04
+#define AX_MEDIUM_FLOW_CONTROL_EN	0x10
+#define AX_MCAST_FILTER_SIZE		8
+#define AX_MAX_MCAST			64
+
+#define AX_EEPROM_LEN			0x40
+
+#define AX_SWRESET_CLEAR		0x00
+#define AX_SWRESET_RR			0x01
+#define AX_SWRESET_RT			0x02
+#define AX_SWRESET_PRTE			0x04
+#define AX_SWRESET_PRL			0x08
+#define AX_SWRESET_BZ			0x10
+#define AX_SWRESET_IPRL			0x20
+#define AX_SWRESET_IPPD			0x40
+#define AX_SWRESET_IPOSC		0x0080
+#define AX_SWRESET_IPPSL_0		0x0100
+#define AX_SWRESET_IPPSL_1		0x0200
+#define AX_SWRESET_IPCOPS		0x0400
+#define AX_SWRESET_IPCOPSC		0x0800
+#define AX_SWRESET_AUTODETACH		0x1000
+#define AX_SWRESET_WOLLP		0x8000
+
+#define AX88772_IPG0_DEFAULT		0x15
+#define AX88772_IPG1_DEFAULT		0x0c
+#define AX88772_IPG2_DEFAULT		0x0E
+
+#define AX88772A_IPG0_DEFAULT		0x15
+#define AX88772A_IPG1_DEFAULT		0x16
+#define AX88772A_IPG2_DEFAULT		0x1A
+
+#define AX88772_MEDIUM_FULL_DUPLEX	0x0002
+#define AX88772_MEDIUM_RESERVED		0x0004
+#define AX88772_MEDIUM_RX_FC_ENABLE	0x0010
+#define AX88772_MEDIUM_TX_FC_ENABLE	0x0020
+#define AX88772_MEDIUM_PAUSE_FORMAT	0x0080
+#define AX88772_MEDIUM_RX_ENABLE	0x0100
+#define AX88772_MEDIUM_100MB		0x0200
+#define AX88772_MEDIUM_DEFAULT	\
+	(AX88772_MEDIUM_FULL_DUPLEX  | AX88772_MEDIUM_RX_FC_ENABLE | \
+	 AX88772_MEDIUM_TX_FC_ENABLE | AX88772_MEDIUM_100MB | \
+	 AX88772_MEDIUM_RESERVED     | AX88772_MEDIUM_RX_ENABLE)
+
+#define AX_CMD_SET_SW_MII		0x06
+#define AX_CMD_READ_MII_REG		0x07
+#define AX_CMD_WRITE_MII_REG		0x08
+#define AX_CMD_SET_HW_MII		0x0a
+#define AX_CMD_READ_EEPROM		0x0b
+#define AX_CMD_WRITE_EEPROM		0x0c
+#define AX_CMD_WRITE_EEPROM_EN		0x0d
+#define AX_CMD_WRITE_EEPROM_DIS		0x0e
+#define AX_CMD_WRITE_RX_CTL		0x10
+#define AX_CMD_READ_IPG012		0x11
+#define AX_CMD_WRITE_IPG0		0x12
+#define AX_CMD_WRITE_IPG1		0x13
+#define AX_CMD_WRITE_IPG2		0x14
+#define AX_CMD_WRITE_MULTI_FILTER	0x16
+#define AX_CMD_READ_NODE_ID		0x17
+#define AX_CMD_READ_PHY_ID		0x19
+#define AX_CMD_READ_MEDIUM_MODE		0x1a
+#define AX_CMD_WRITE_MEDIUM_MODE	0x1b
+#define AX_CMD_READ_MONITOR_MODE	0x1c
+#define AX_CMD_WRITE_MONITOR_MODE	0x1d
+#define AX_CMD_WRITE_GPIOS		0x1f
+#define AX_CMD_SW_RESET			0x20
+#define AX_CMD_SW_PHY_STATUS		0x21
+#define AX_CMD_SW_PHY_SELECT		0x22
+	#define AX_PHYSEL_PSEL		(1 << 0)
+	#define AX_PHYSEL_ASEL		(1 << 1)
+	#define AX_PHYSEL_SSMII		(1 << 2)
+	#define AX_PHYSEL_SSRMII	(2 << 2)
+	#define AX_PHYSEL_SSRRMII	(3 << 2)
+	#define AX_PHYSEL_SSEN		(1 << 4)
+#define AX88772_CMD_READ_NODE_ID	0x13
+#define AX88772_CMD_WRITE_NODE_ID	0x14
+#define AX_CMD_READ_RXCOE_CTL		0x2b
+#define AX_CMD_WRITE_RXCOE_CTL		0x2c
+#define AX_CMD_READ_TXCOE_CTL		0x2d
+#define AX_CMD_WRITE_TXCOE_CTL		0x2e
+
+#define REG_LENGTH			2
+#define PHY_ID_MASK			0x1f
+
+#define AX_RXCOE_IPCE			0x0001
+#define AX_RXCOE_IPVE			0x0002
+#define AX_RXCOE_V6VE			0x0004
+#define AX_RXCOE_TCPE			0x0008
+#define AX_RXCOE_UDPE			0x0010
+#define AX_RXCOE_ICMP			0x0020
+#define AX_RXCOE_IGMP			0x0040
+#define AX_RXCOE_ICV6			0x0080
+#define AX_RXCOE_TCPV6			0x0100
+#define AX_RXCOE_UDPV6			0x0200
+#define AX_RXCOE_ICMV6			0x0400
+#define AX_RXCOE_IGMV6			0x0800
+#define AX_RXCOE_ICV6V6			0x1000
+#define AX_RXCOE_FOPC			0x8000
+#define AX_RXCOE_DEF_CSUM		(AX_RXCOE_IPCE  | AX_RXCOE_IPVE  | \
+					 AX_RXCOE_V6VE  | AX_RXCOE_TCPE  | \
+					 AX_RXCOE_UDPE  | AX_RXCOE_ICV6  | \
+					 AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6)
+
+#define AX_RXCOE_64TE			0x0100
+#define AX_RXCOE_PPPOE			0x0200
+#define AX_RXCOE_RPCE			0x8000
+
+#define AX_TXCOE_IP			0x0001
+#define AX_TXCOE_TCP			0x0002
+#define AX_TXCOE_UDP			0x0004
+#define AX_TXCOE_ICMP			0x0008
+#define AX_TXCOE_IGMP			0x0010
+#define AX_TXCOE_ICV6			0x0020
+
+#define AX_TXCOE_TCPV6			0x0100
+#define AX_TXCOE_UDPV6			0x0200
+#define AX_TXCOE_ICMV6			0x0400
+#define AX_TXCOE_IGMV6			0x0800
+#define AX_TXCOE_ICV6V6			0x1000
+#define AX_TXCOE_DEF_CSUM		(AX_TXCOE_TCP   | AX_TXCOE_UDP | \
+					 AX_TXCOE_TCPV6 | AX_TXCOE_UDPV6)
+
+#define AX_TXCOE_64TE			0x0001
+#define AX_TXCOE_PPPE			0x0002
+
+#define AX88772B_MAX_BULKIN_2K		0
+#define AX88772B_MAX_BULKIN_4K		1
+#define AX88772B_MAX_BULKIN_6K		2
+#define AX88772B_MAX_BULKIN_8K		3
+#define AX88772B_MAX_BULKIN_16K		4
+#define AX88772B_MAX_BULKIN_20K		5
+#define AX88772B_MAX_BULKIN_24K		6
+#define AX88772B_MAX_BULKIN_32K		7
+
+struct {unsigned short size, byte_cnt, threshold; } AX88772B_BULKIN_SIZE[] = {
+	{2048, 0x8000, 0x8001},		/* 2k */
+	{4096, 0x8100, 0x8147},		/* 4k */
+	{6144, 0x8200, 0x81EB},		/* 6k */
+	{8192, 0x8300, 0x83D7},		/* 8k */
+	{16384, 0x8400, 0x851E},	/* 16 */
+	{20480, 0x8500, 0x8666},	/* 20k */
+	{24576, 0x8600, 0x87AE},	/* 24k */
+	{32768, 0x8700, 0x8A3D},	/* 32k */
+};
+
+
+#define AX_RX_CTL_RH1M		0x0100	/* Enable RX-Header mode 0 */
+#define AX_RX_CTL_RH2M		0x0200	/* Enable IP header in receive buffer
+					   aligned on 32-bit aligment */
+#define AX_RX_CTL_RH3M		0x0400	/* checksum value in rx header 3 */
+#define AX_RX_HEADER_DEFAULT	(AX_RX_CTL_RH1M | AX_RX_CTL_RH2M)
+
+#define AX_RX_CTL_MFB		0x0300	/* Maximum Frame size 16384bytes */
+#define AX_RX_CTL_START		0x0080	/* Ethernet MAC start */
+#define AX_RX_CTL_AP		0x0020	/* Accept phys addr from mcast array */
+#define AX_RX_CTL_AM		0x0010
+#define AX_RX_CTL_AB		0x0008	/* Accetp Brocadcast frames*/
+#define AX_RX_CTL_SEP		0x0004	/* Save error packets */
+#define AX_RX_CTL_AMALL		0x0002	/* Accetp all multicast frames */
+#define AX_RX_CTL_PRO		0x0001	/* Promiscuous Mode */
+#define AX_RX_CTL_STOP		0x0000	/* Stop MAC */
+
+#define AX_MONITOR_MODE		0x01
+#define AX_MONITOR_LINK		0x02
+#define AX_MONITOR_MAGIC	0x04
+#define AX_MONITOR_HSFS		0x10
+
+#define AX_MCAST_FILTER_SIZE	8
+#define AX_MAX_MCAST		64
+#define AX_INTERRUPT_BUFSIZE	8
+
+#define AX_EEPROM_LEN		0x40
+#define AX_EEPROM_MAGIC		0xdeadbeef
+#define EEPROMMASK		0x7f
+
+/* GPIO REGISTER */
+#define AXGPIOS_GPO0EN		(1 << 0)
+#define AXGPIOS_GPO0		(1 << 1)
+#define AXGPIOS_GPO1EN		(1 << 2)
+#define AXGPIOS_GPO1		(1 << 3)
+#define AXGPIOS_GPO2EN		(1 << 4)
+#define AXGPIOS_GPO2		(1 << 5)
+#define AXGPIOS_RSE		(1 << 7)
+
+/* TX-header format */
+#define AX_TX_HDR_CPHI		0x4000
+#define AX_TX_HDR_DICF		0x8000
+
+/* GMII register numbers */
+#define GMII_PHY_CONTROL		0x00	/* control */
+#define GMII_PHY_STATUS			0x01	/* status */
+#define GMII_PHY_OUI			0x02	/* most of the OUI bits */
+#define GMII_PHY_MODEL			0x03	/* model/rev & rest of OUI */
+#define GMII_PHY_ANAR			0x04	/* AN advertisement */
+#define GMII_PHY_ANLPAR			0x05	/* AN Link Partner */
+#define GMII_PHY_ANER			0x06	/* AN expansion */
+#define GMII_PHY_1000BT_CONTROL		0x09	/* control for 1000BT */
+#define GMII_PHY_1000BT_STATUS		0x0A	/* status for 1000BT */
+
+/* Bit definitions: GMII Control */
+#define GMII_CONTROL_RESET		0x8000	/* reset bit in control reg */
+#define GMII_CONTROL_LOOPBACK		0x4000	/* loopback in control reg */
+#define GMII_CONTROL_10MB		0x0000	/* 10 Mbit */
+#define GMII_CONTROL_100MB		0x2000	/* 100Mbit */
+#define GMII_CONTROL_1000MB		0x0040	/* 1000Mbit */
+#define GMII_CONTROL_SPEED_BITS		0x2040	/* speed bit mask */
+#define GMII_CONTROL_ENABLE_AUTO	0x1000	/* autonegotiate enable */
+#define GMII_CONTROL_POWER_DOWN		0x0800
+#define GMII_CONTROL_ISOLATE		0x0400	/* islolate bit */
+#define GMII_CONTROL_START_AUTO		0x0200	/* restart autonegotiate */
+#define GMII_CONTROL_FULL_DUPLEX	0x0100
+
+/* Bit definitions: GMII Status */
+#define GMII_STATUS_100MB_MASK		0xE000	/* any indicates 100 Mbit */
+#define GMII_STATUS_10MB_MASK		0x1800	/* either indicates 10 Mbit */
+#define GMII_STATUS_AUTO_DONE		0x0020	/* auto neg complete */
+#define GMII_STATUS_AUTO		0x0008	/* auto neg is available */
+#define GMII_STATUS_LINK_UP		0x0004	/* link status bit */
+#define GMII_STATUS_EXTENDED		0x0001	/* extended regs exist */
+#define GMII_STATUS_100T4		0x8000	/* 100BT4 capable */
+#define GMII_STATUS_100TXFD		0x4000	/* 100BTX full duplex capable */
+#define GMII_STATUS_100TX		0x2000	/* 100BTX capable */
+#define GMII_STATUS_10TFD		0x1000	/* 10BT full duplex capable */
+#define GMII_STATUS_10T			0x0800	/* 10BT capable */
+
+/* Bit definitions: Auto-Negotiation Advertisement */
+#define GMII_ANAR_ASYM_PAUSE		0x0800	/* support asymetric pause */
+#define GMII_ANAR_PAUSE			0x0400	/* support pause packets */
+#define GMII_ANAR_100T4			0x0200	/* support 100BT4 */
+#define GMII_ANAR_100TXFD		0x0100	/* support 100BTX full duplex */
+#define GMII_ANAR_100TX			0x0080	/* support 100BTX half duplex */
+#define GMII_ANAR_10TFD			0x0040	/* support 10BT full duplex */
+#define GMII_ANAR_10T			0x0020	/* support 10BT half duplex */
+#define GMII_SELECTOR_FIELD		0x001F	/* selector field. */
+
+/* Bit definitions: Auto-Negotiation Link Partner Ability */
+#define GMII_ANLPAR_100T4		0x0200	/* support 100BT4 */
+#define GMII_ANLPAR_100TXFD		0x0100	/* support 100BTX full duplex */
+#define GMII_ANLPAR_100TX		0x0080	/* support 100BTX half duplex */
+#define GMII_ANLPAR_10TFD		0x0040	/* support 10BT full duplex */
+#define GMII_ANLPAR_10T			0x0020	/* support 10BT half duplex */
+#define GMII_ANLPAR_PAUSE		0x0400	/* support pause packets */
+#define GMII_ANLPAR_ASYM_PAUSE		0x0800	/* support asymetric pause */
+#define GMII_ANLPAR_ACK			0x4000	/* LCB successfully rx'd */
+#define GMII_SELECTOR_8023		0x0001;
+
+/* Bit definitions: 1000BaseT AUX Control.
+ * FD="Full-Duplex", HD="Half-Duplex"
+ */
+#define GMII_1000_AUX_CTRL_MASTER_SLAVE		0x1000
+#define GMII_1000_AUX_CTRL_FD_CAPABLE		0x0200
+#define GMII_1000_AUX_CTRL_HD_CAPABLE		0x0100
+
+/* Bit definitions: 1000BaseT AUX Status */
+#define GMII_1000_AUX_STATUS_FD_CAPABLE		0x0800
+#define GMII_1000_AUX_STATUS_HD_CAPABLE		0x0400
+
+/* Cicada MII Registers */
+#define GMII_AUX_CTRL_STATUS			0x1C
+#define GMII_AUX_ANEG_CPLT			0x8000
+#define GMII_AUX_FDX				0x0020
+#define GMII_AUX_SPEED_1000			0x0010
+#define GMII_AUX_SPEED_100			0x0008
+
+#ifndef ADVERTISE_PAUSE_CAP
+#define ADVERTISE_PAUSE_CAP			0x0400
+#endif
+
+#ifndef MII_STAT1000
+#define MII_STAT1000				0x000A
+#endif
+
+#ifndef LPA_1000FULL
+#define LPA_1000FULL				0x0800
+#endif
+
+/* medium mode register */
+#define MEDIUM_GIGA_MODE			0x0001
+#define MEDIUM_FULL_DUPLEX_MODE			0x0002
+#define MEDIUM_TX_ABORT_MODE			0x0004
+#define MEDIUM_ENABLE_125MHZ			0x0008
+#define MEDIUM_ENABLE_RX_FLOWCTRL		0x0010
+#define MEDIUM_ENABLE_TX_FLOWCTRL		0x0020
+#define MEDIUM_ENABLE_JUMBO_FRAME		0x0040
+#define MEDIUM_CHECK_PAUSE_FRAME_MODE		0x0080
+#define MEDIUM_ENABLE_RECEIVE			0x0100
+#define MEDIUM_MII_100M_MODE			0x0200
+#define MEDIUM_ENABLE_JAM_PATTERN		0x0400
+#define MEDIUM_ENABLE_STOP_BACKPRESSURE		0x0800
+#define MEDIUM_ENABLE_SUPPER_MAC_SUPPORT	0x1000
+
+/* PHY mode */
+#define PHY_MODE_MARVELL		0
+#define PHY_MODE_CICADA_FAMILY		1
+#define PHY_MODE_CICADA_V1		1
+#define PHY_MODE_AGERE_FAMILY		2
+#define PHY_MODE_AGERE_V0		2
+#define PHY_MODE_CICADA_V2		5
+#define PHY_MODE_AGERE_V0_GMII		6
+#define PHY_MODE_CICADA_V2_ASIX		9
+#define PHY_MODE_VSC8601		10
+#define PHY_MODE_RTL8211CL		12
+#define PHY_MODE_RTL8211BN		13
+#define PHY_MODE_RTL8251CL		14
+#define PHY_MODE_ATTANSIC_V0		0x40
+#define PHY_MODE_ATTANSIC_FAMILY	0x40
+#define PHY_MODE_MAC_TO_MAC_GMII	0x7C
+
+/*  */
+#define LED_MODE_MARVELL		0
+#define LED_MODE_CAMEO			1
+
+#define MARVELL_LED_CTRL		0x18
+#define MARVELL_MANUAL_LED		0x19
+
+#define PHY_IDENTIFIER			0x0002
+#define PHY_AGERE_IDENTIFIER		0x0282
+#define PHY_CICADA_IDENTIFIER		0x000f
+#define PHY_MARVELL_IDENTIFIER		0x0141
+
+#define PHY_MARVELL_STATUS		0x001b
+#define MARVELL_STATUS_HWCFG		0x0004	/* SGMII without clock */
+
+#define PHY_MARVELL_CTRL		0x0014
+#define MARVELL_CTRL_RXDELAY		0x0080
+#define MARVELL_CTRL_TXDELAY		0x0002
+
+#define PHY_CICADA_EXTPAGE		0x001f
+#define CICADA_EXTPAGE_EN		0x0001
+#define CICADA_EXTPAGE_DIS		0x0000
+
+
+struct {unsigned short value, offset; } CICADA_FAMILY_HWINIT[] = {
+	{0x0001, 0x001f}, {0x1c25, 0x0017}, {0x2a30, 0x001f}, {0x234c, 0x0010},
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0xa7fa, 0x0000},
+	{0x0012, 0x0002}, {0x3002, 0x0001}, {0x87fa, 0x0000}, {0x52b5, 0x001f},
+	{0xafac, 0x0000}, {0x000d, 0x0002}, {0x001c, 0x0001}, {0x8fac, 0x0000},
+	{0x2a30, 0x001f}, {0x0012, 0x0008}, {0x2a30, 0x001f}, {0x0400, 0x0014},
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0xa760, 0x0000},
+	{0x0000, 0x0002}, {0xfaff, 0x0001}, {0x8760, 0x0000}, {0x52b5, 0x001f},
+	{0xa760, 0x0000}, {0x0000, 0x0002}, {0xfaff, 0x0001}, {0x8760, 0x0000},
+	{0x52b5, 0x001f}, {0xafae, 0x0000}, {0x0004, 0x0002}, {0x0671, 0x0001},
+	{0x8fae, 0x0000}, {0x2a30, 0x001f}, {0x0012, 0x0008}, {0x0000, 0x001f},
+};
+
+struct {unsigned short value, offset; } CICADA_V2_HWINIT[] = {
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0x000f, 0x0002},
+	{0x472a, 0x0001}, {0x8fa4, 0x0000}, {0x2a30, 0x001f}, {0x0212, 0x0008},
+	{0x0000, 0x001f},
+};
+
+struct {unsigned short value, offset; } CICADA_V2_ASIX_HWINIT[] = {
+	{0x2a30, 0x001f}, {0x0212, 0x0008}, {0x52b5, 0x001f}, {0x0012, 0x0002},
+	{0x3002, 0x0001}, {0x87fa, 0x0000}, {0x52b5, 0x001f}, {0x000f, 0x0002},
+	{0x472a, 0x0001}, {0x8fa4, 0x0000}, {0x2a30, 0x001f}, {0x0212, 0x0008},
+	{0x0000, 0x001f},
+};
+
+struct {unsigned short value, offset; } AGERE_FAMILY_HWINIT[] = {
+	{0x0800, 0x0000}, {0x0007, 0x0012}, {0x8805, 0x0010}, {0xb03e, 0x0011},
+	{0x8808, 0x0010}, {0xe110, 0x0011}, {0x8806, 0x0010}, {0xb03e, 0x0011},
+	{0x8807, 0x0010}, {0xff00, 0x0011}, {0x880e, 0x0010}, {0xb4d3, 0x0011},
+	{0x880f, 0x0010}, {0xb4d3, 0x0011}, {0x8810, 0x0010}, {0xb4d3, 0x0011},
+	{0x8817, 0x0010}, {0x1c00, 0x0011}, {0x300d, 0x0010}, {0x0001, 0x0011},
+	{0x0002, 0x0012},
+};
+
+struct ax88178_data {
+	u16	EepromData;
+	u16	MediaLink;
+	int	UseGpio0;
+	int	UseRgmii;
+	u8	PhyMode;
+	u8	LedMode;
+	u8	BuffaloOld;
+};
+
+enum watchdog_state {
+	AX_NOP = 0,
+	CHK_LINK,			/* Routine A */
+	CHK_CABLE_EXIST,		/* Called by A */
+	CHK_CABLE_EXIST_AGAIN,		/* Routine B */
+	PHY_POWER_UP,			/* Called by B */
+	PHY_POWER_UP_BH,
+	PHY_POWER_DOWN,
+	CHK_CABLE_STATUS,		/* Routine C */
+	WAIT_AUTONEG_COMPLETE,
+	AX_SET_RX_CFG,
+};
+
+struct ax88772b_data {
+	struct usbnet *dev;
+	struct workqueue_struct *ax_work;
+	struct work_struct check_link;
+	unsigned long time_to_chk;
+	u16 psc;
+	u8 pw_enabled;
+	u8 Event;
+	u8 checksum;
+};
+
+struct ax88772a_data {
+	struct usbnet *dev;
+	struct workqueue_struct *ax_work;
+	struct work_struct check_link;
+	unsigned long autoneg_start;
+#define AX88772B_WATCHDOG	(6 * HZ)
+	u8 Event;
+	u8 TickToExpire;
+	u8 DlyIndex;
+	u8 DlySel;
+	u16 EepromData;
+};
+
+struct ax88772_data {
+	struct usbnet *dev;
+	struct workqueue_struct *ax_work;
+	struct work_struct check_link;
+	unsigned long autoneg_start;
+	u8 Event;
+	u8 TickToExpire;
+};
+
+#define AX_RX_CHECKSUM		1
+#define AX_TX_CHECKSUM		2
+
+/* This structure cannot exceed sizeof(unsigned long [5]) AKA 20 bytes */
+struct ax8817x_data {
+	u8 multi_filter[AX_MCAST_FILTER_SIZE];
+	int (*resume) (struct usb_interface *intf);
+	int (*suspend) (struct usb_interface *intf, pm_message_t message);
+};
+
+struct __packed ax88172_int_data {
+	u16 res1;
+#define AX_INT_PPLS_LINK	(1 << 0)
+#define AX_INT_SPLS_LINK	(1 << 1)
+#define AX_INT_CABOFF_UNPLUG	(1 << 7)
+	u8 link;
+	u16 res2;
+	u8 status;
+	u16 res3;
+};
+
+#define AX_RXHDR_L4_ERR		(1 << 8)
+#define AX_RXHDR_L3_ERR		(1 << 9)
+
+#define AX_RXHDR_L4_TYPE_UDP		1
+#define AX_RXHDR_L4_TYPE_ICMP		2
+#define AX_RXHDR_L4_TYPE_IGMP		3
+#define AX_RXHDR_L4_TYPE_TCP		4
+#define AX_RXHDR_L4_TYPE_TCMPV6		5
+#define AX_RXHDR_L4_TYPE_MASK		7
+
+#define AX_RXHDR_L3_TYPE_IP		1
+#define AX_RXHDR_L3_TYPE_IPV6		2
+
+struct __packed ax88772b_rx_header {
+#if defined(__LITTLE_ENDIAN_BITFIELD)
+	u16	len:11,
+		res1:1,
+		crc:1,
+		mii:1,
+		runt:1,
+		mc_bc:1;
+
+	u16	len_bar:11,
+		res2:5;
+
+	u8	vlan_ind:3,
+		vlan_tag_striped:1,
+		pri:3,
+		res3:1;
+
+	u8	l4_csum_err:1,
+		l3_csum_err:1,
+		l4_type:3,
+		l3_type:2,
+		ce:1;
+#elif defined(__BIG_ENDIAN_BITFIELD)
+	u16	mc_bc:1,
+		runt:1,
+		mii:1,
+		crc:1,
+		res1:1,
+		len:11;
+
+	u16	res2:5,
+		len_bar:11;
+
+	u8	res3:1,
+		pri:3,
+		vlan_tag_striped:1,
+		vlan_ind:3;
+
+	u8	ce:1,
+		l3_type:2,
+		l4_type:3,
+		l3_csum_err:1,
+		l4_csum_err:1;
+#else
+#error	"Please fix <asm/byteorder.h>"
+#endif
+};
+
+#endif /* __LINUX_USBNET_ASIX_H */
+

--------------030107060700060006000702--

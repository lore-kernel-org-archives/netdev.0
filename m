From: Samuel Ortiz <samuel@sortiz.org>
Subject: [PATCH] [IrDA] KingSun/DonShine USB IrDA dongle support
Date: Thu, 10 May 2007 01:40:27 +0300
Message-ID: <20070509224027.GA4458@sortiz.org>
Reply-To: Samuel Ortiz <samuel@sortiz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, irda-users@lists.sourceforge.net,
	a_villacis@palosanto.com
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp24.orange.fr ([193.252.22.25]:20692 "EHLO smtp24.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754798AbXEIWjO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 May 2007 18:39:14 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Alex Villac=EF=BF=BDs Lasso <a_villacis@palosanto.com>

This dongle does not follow the usb-irda specification, so it needs its
own special driver. In addition, it uses interrupt endpoints instead of
bulk ones as the rest of USB IrDA dongles supported by Linux (just to b=
e
different?) and data reads need to be parsed to extract the valid bytes
before being unwrapped (details in the comment at the start of the
source). No speed commands have been discovered for this dongle, and I
suspect it does not have any at all.

On plugin, this dongle reports vendor and device IDs: 0x07c0:0x4200 .

The Windows driver that is used normally to control this dongle has a
filename of DSIR620.SYS .

Signed-off-by: Alex Villac=EF=BF=BDs Lasso <a_villacis@palosanto.com>
Signed-off-by: Samuel Ortiz <samuel@sortiz.org>

---
 drivers/net/irda/Kconfig       |   14 +
 drivers/net/irda/Makefile      |    1 +
 drivers/net/irda/kingsun-sir.c |  657 ++++++++++++++++++++++++++++++++=
++++++++
 3 files changed, 672 insertions(+), 0 deletions(-)
 create mode 100644 drivers/net/irda/kingsun-sir.c

diff --git a/drivers/net/irda/Kconfig b/drivers/net/irda/Kconfig
index 7c8ccc0..9d28c75 100644
--- a/drivers/net/irda/Kconfig
+++ b/drivers/net/irda/Kconfig
@@ -141,6 +141,20 @@ config ACT200L_DONGLE
 	  To activate support for ACTiSYS IR-200L dongle you will have to
 	  start irattach like this: "irattach -d act200l".
=20
+config KINGSUN_DONGLE
+	tristate "KingSun/DonShine DS-620 IrDA-USB dongle"
+	depends on IRDA && USB && EXPERIMENTAL
+	help
+	  Say Y or M here if you want to build support for the KingSun/DonShi=
ne
+	  DS-620 IrDA-USB bridge device driver.
+
+	  This USB bridge does not conform to the IrDA-USB device class
+	  specification, and therefore needs its own specific driver. This
+	  dongle supports SIR speed only (9600 bps).
+
+	  To compile it as a module, choose M here: the module will be called
+	  kingsun-sir.
+
 comment "Old SIR device drivers"
=20
 config IRPORT_SIR
diff --git a/drivers/net/irda/Makefile b/drivers/net/irda/Makefile
index 5be09f1..233a2f9 100644
--- a/drivers/net/irda/Makefile
+++ b/drivers/net/irda/Makefile
@@ -45,6 +45,7 @@ obj-$(CONFIG_MCP2120_DONGLE)	+=3D mcp2120-sir.o
 obj-$(CONFIG_ACT200L_DONGLE)	+=3D act200l-sir.o
 obj-$(CONFIG_MA600_DONGLE)	+=3D ma600-sir.o
 obj-$(CONFIG_TOIM3232_DONGLE)	+=3D toim3232-sir.o
+obj-$(CONFIG_KINGSUN_DONGLE)	+=3D kingsun-sir.o
=20
 # The SIR helper module
 sir-dev-objs :=3D sir_dev.o sir_dongle.o
diff --git a/drivers/net/irda/kingsun-sir.c b/drivers/net/irda/kingsun-=
sir.c
new file mode 100644
index 0000000..a1eb130
--- /dev/null
+++ b/drivers/net/irda/kingsun-sir.c
@@ -0,0 +1,657 @@
+/*********************************************************************=
********
+*
+* Filename:      kingsun-sir.c
+* Version:       0.1.1
+* Description:   Irda KingSun/DonShine USB Dongle
+* Status:        Experimental
+* Author:        Alex Villac=EF=BF=BDs Lasso <a_villacis@palosanto.com=
>
+*
+*  	Based on stir4200 and mcs7780 drivers, with (strange?) differences
+*
+*	This program is free software; you can redistribute it and/or modify
+*	it under the terms of the GNU General Public License as published by
+*	the Free Software Foundation; either version 2 of the License.
+*
+*	This program is distributed in the hope that it will be useful,
+*	but WITHOUT ANY WARRANTY; without even the implied warranty of
+*	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+*	GNU General Public License for more details.
+*
+*	You should have received a copy of the GNU General Public License
+*	along with this program; if not, write to the Free Software
+*	Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
+*
+**********************************************************************=
*******/
+
+/*
+ * This is my current (2007-04-25) understanding of how this dongle is=
 supposed
+ * to work. This is based on reverse-engineering and examination of th=
e packet
+ * data sent and received by the WinXP driver using USBSnoopy. Feel fr=
ee to
+ * update here as more of this dongle is known:
+ *
+ * General: Unlike the other USB IrDA dongles, this particular dongle =
exposes,
+ * not two bulk (in and out) endpoints, but two *interrupt* ones. This=
 dongle,
+ * like the bulk based ones (stir4200.c and mcs7780.c), requires polli=
ng in
+ * order to receive data.
+ * Transmission: Just like stir4200, this dongle uses a raw stream of =
data,
+ * which needs to be wrapped and escaped in a similar way as in stir42=
00.c.
+ * Reception: Poll-based, as in stir4200. Each read returns the conten=
ts of a
+ * 8-byte buffer, of which the first byte (LSB) indicates the number o=
f bytes
+ * (1-7) of valid data contained within the remaining 7 bytes. For exa=
mple, if
+ * the buffer had the following contents:
+ *  06 ff ff ff c0 01 04 aa
+ * This means that (06) there are 6 bytes of valid data. The byte 0xaa=
 at the
+ * end is garbage (left over from a previous reception) and is discard=
ed.
+ * If a read returns an "impossible" value as the length of valid data=
 (such as
+ * 0x36) in the first byte, then the buffer is uninitialized (as is th=
e case of
+ * first plug-in) and its contents should be discarded. There is curre=
ntly no
+ * evidence that the top 5 bits of the 1st byte of the buffer can have=
 values
+ * other than 0 once reception begins.
+ * Once valid bytes are collected, the assembled stream is a sequence =
of
+ * wrapped IrDA frames that is unwrapped and unescaped as in stir4200.=
c.
+ * BIG FAT WARNING: the dongle does *not* reset the RX buffer in any w=
ay after
+ * a successful read from the host, which means that in absence of fur=
ther
+ * reception, repeated reads from the dongle will return the exact sam=
e
+ * contents repeatedly. Attempts to be smart and cache a previous read=
 seem
+ * to result in corrupted packets, so this driver depends on the unwra=
p logic
+ * to sort out any repeated reads.
+ * Speed change: no commands observed so far to change speed, assumed =
fixed
+ * 9600bps (SIR).
+ */
+
+#include <linux/module.h>
+#include <linux/moduleparam.h>
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/init.h>
+#include <linux/slab.h>
+#include <linux/module.h>
+#include <linux/kref.h>
+#include <linux/usb.h>
+#include <linux/device.h>
+#include <linux/crc32.h>
+
+#include <asm/unaligned.h>
+#include <asm/byteorder.h>
+#include <asm/uaccess.h>
+
+#include <net/irda/irda.h>
+#include <net/irda/wrapper.h>
+#include <net/irda/crc.h>
+
+/*
+ * According to lsusb, 0x07c0 is assigned to
+ * "Code Mercenaries Hard- und Software GmbH"
+ */
+#define KING_VENDOR_ID 0x07c0
+#define KING_PRODUCT_ID 0x4200
+
+/* These are the currently known USB ids */
+static struct usb_device_id dongles[] =3D {
+    /* KingSun Co,Ltd  IrDA/USB Bridge */
+    { USB_DEVICE(KING_VENDOR_ID, KING_PRODUCT_ID) },
+    { }
+};
+
+MODULE_DEVICE_TABLE(usb, dongles);
+
+#define KINGSUN_MTT 0x07
+
+#define KINGSUN_FIFO_SIZE		4096
+#define KINGSUN_EP_IN			0
+#define KINGSUN_EP_OUT			1
+
+struct kingsun_cb {
+	struct usb_device *usbdev;      /* init: probe_irda */
+	struct net_device *netdev;      /* network layer */
+	struct irlap_cb   *irlap;       /* The link layer we are binded to */
+	struct net_device_stats stats;	/* network statistics */
+	struct qos_info   qos;
+
+	__u8		  *in_buf;	/* receive buffer */
+	__u8		  *out_buf;	/* transmit buffer */
+	__u8		  max_rx;	/* max. atomic read from dongle
+					   (usually 8), also size of in_buf */
+	__u8		  max_tx;	/* max. atomic write to dongle
+					   (usually 8) */
+
+	iobuff_t  	  rx_buff;	/* receive unwrap state machine */
+	struct timeval	  rx_time;
+	spinlock_t lock;
+	int receiving;
+
+	__u8 ep_in;
+	__u8 ep_out;
+
+	struct urb	 *tx_urb;
+	struct urb	 *rx_urb;
+};
+
+/* Callback transmission routine */
+static void kingsun_send_irq(struct urb *urb)
+{
+	struct kingsun_cb *kingsun =3D urb->context;
+	struct net_device *netdev =3D kingsun->netdev;
+
+	/* in process of stopping, just drop data */
+	if (!netif_running(kingsun->netdev)) {
+		err("kingsun_send_irq: Network not running!");
+		return;
+	}
+
+	/* unlink, shutdown, unplug, other nasties */
+	if (urb->status !=3D 0) {
+		err("kingsun_send_irq: urb asynchronously failed - %d",
+		    urb->status);
+	}
+	netif_wake_queue(netdev);
+}
+
+/*
+ * Called from net/core when new frame is available.
+ */
+static int kingsun_hard_xmit(struct sk_buff *skb, struct net_device *n=
etdev)
+{
+	struct kingsun_cb *kingsun;
+	int wraplen;
+	int ret =3D 0;
+
+	if (skb =3D=3D NULL || netdev =3D=3D NULL)
+		return -EINVAL;
+
+	netif_stop_queue(netdev);
+
+	/* the IRDA wrapping routines don't deal with non linear skb */
+	SKB_LINEAR_ASSERT(skb);
+
+	kingsun =3D netdev_priv(netdev);
+
+	spin_lock(&kingsun->lock);
+
+	/* Append data to the end of whatever data remains to be transmitted =
*/
+	wraplen =3D async_wrap_skb(skb,
+		kingsun->out_buf,
+		KINGSUN_FIFO_SIZE);
+
+	/* Calculate how much data can be transmitted in this urb */
+	usb_fill_int_urb(kingsun->tx_urb, kingsun->usbdev,
+		usb_sndintpipe(kingsun->usbdev, kingsun->ep_out),
+		kingsun->out_buf, wraplen, kingsun_send_irq,
+		kingsun, 1);
+
+	if ((ret =3D usb_submit_urb(kingsun->tx_urb, GFP_ATOMIC))) {
+		err("kingsun_hard_xmit: failed tx_urb submit: %d", ret);
+		switch (ret) {
+		case -ENODEV:
+		case -EPIPE:
+			break;
+		default:
+			kingsun->stats.tx_errors++;
+			netif_start_queue(netdev);
+		}
+	} else {
+		kingsun->stats.tx_packets++;
+		kingsun->stats.tx_bytes +=3D skb->len;
+	}
+
+	dev_kfree_skb(skb);
+	spin_unlock(&kingsun->lock);
+
+	return ret;
+}
+
+/* Receive callback function */
+static void kingsun_rcv_irq(struct urb *urb)
+{
+	struct kingsun_cb *kingsun =3D urb->context;
+	int ret;
+
+	/* in process of stopping, just drop data */
+	if (!netif_running(kingsun->netdev)) {
+		kingsun->receiving =3D 0;
+		return;
+	}
+
+	/* unlink, shutdown, unplug, other nasties */
+	if (urb->status !=3D 0) {
+		err("kingsun_rcv_irq: urb asynchronously failed - %d",
+		    urb->status);
+		kingsun->receiving =3D 0;
+		return;
+	}
+
+	if (urb->actual_length =3D=3D kingsun->max_rx) {
+		__u8 *bytes =3D urb->transfer_buffer;
+		int i;
+
+		/* The very first byte in the buffer indicates the length of
+		   valid data in the read. This byte must be in the range
+		   1..kingsun->max_rx -1 . Values outside this range indicate
+		   an uninitialized Rx buffer when the dongle has just been
+		   plugged in. */
+		if (bytes[0] >=3D 1 && bytes[0] < kingsun->max_rx) {
+			for (i =3D 1; i <=3D bytes[0]; i++) {
+				async_unwrap_char(kingsun->netdev,
+						  &kingsun->stats,
+						  &kingsun->rx_buff, bytes[i]);
+			}
+			kingsun->netdev->last_rx =3D jiffies;
+			do_gettimeofday(&kingsun->rx_time);
+			kingsun->receiving =3D
+				(kingsun->rx_buff.state !=3D OUTSIDE_FRAME)
+				? 1 : 0;
+		}
+	} else if (urb->actual_length > 0) {
+		err("%s(): Unexpected response length, expected %d got %d",
+		    __FUNCTION__, kingsun->max_rx, urb->actual_length);
+	}
+	/* This urb has already been filled in kingsun_net_open */
+	ret =3D usb_submit_urb(urb, GFP_ATOMIC);
+}
+
+/*
+ * Function kingsun_net_open (dev)
+ *
+ *    Network device is taken up. Usually this is done by "ifconfig ir=
da0 up"
+ */
+static int kingsun_net_open(struct net_device *netdev)
+{
+	struct kingsun_cb *kingsun =3D netdev_priv(netdev);
+	int err =3D -ENOMEM;
+	char hwname[16];
+
+	/* At this point, urbs are NULL, and skb is NULL (see kingsun_probe) =
*/
+	kingsun->receiving =3D 0;
+
+	/* Initialize for SIR to copy data directly into skb.  */
+	kingsun->rx_buff.in_frame =3D FALSE;
+	kingsun->rx_buff.state =3D OUTSIDE_FRAME;
+	kingsun->rx_buff.truesize =3D IRDA_SKB_MAX_MTU;
+	kingsun->rx_buff.skb =3D dev_alloc_skb(IRDA_SKB_MAX_MTU);
+	if (!kingsun->rx_buff.skb)
+		goto free_mem;
+
+	skb_reserve(kingsun->rx_buff.skb, 1);
+	kingsun->rx_buff.head =3D kingsun->rx_buff.skb->data;
+	do_gettimeofday(&kingsun->rx_time);
+
+	kingsun->rx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+	if (!kingsun->rx_urb)
+		goto free_mem;
+
+	kingsun->tx_urb =3D usb_alloc_urb(0, GFP_KERNEL);
+	if (!kingsun->tx_urb)
+		goto free_mem;
+
+	/*
+	 * Now that everything should be initialized properly,
+	 * Open new IrLAP layer instance to take care of us...
+	 */
+	sprintf(hwname, "usb#%d", kingsun->usbdev->devnum);
+	kingsun->irlap =3D irlap_open(netdev, &kingsun->qos, hwname);
+	if (!kingsun->irlap) {
+		err("kingsun-sir: irlap_open failed");
+		goto free_mem;
+	}
+
+	/* Start first reception */
+	usb_fill_int_urb(kingsun->rx_urb, kingsun->usbdev,
+			  usb_rcvintpipe(kingsun->usbdev, kingsun->ep_in),
+			  kingsun->in_buf, kingsun->max_rx,
+			  kingsun_rcv_irq, kingsun, 1);
+	kingsun->rx_urb->status =3D 0;
+	err =3D usb_submit_urb(kingsun->rx_urb, GFP_KERNEL);
+	if (err) {
+		err("kingsun-sir: first urb-submit failed: %d", err);
+		goto close_irlap;
+	}
+
+	netif_start_queue(netdev);
+
+	/* Situation at this point:
+	   - all work buffers allocated
+	   - urbs allocated and ready to fill
+	   - max rx packet known (in max_rx)
+	   - unwrap state machine initialized, in state outside of any frame
+	   - receive request in progress
+	   - IrLAP layer started, about to hand over packets to send
+	 */
+
+	return 0;
+
+ close_irlap:
+	irlap_close(kingsun->irlap);
+ free_mem:
+	if (kingsun->tx_urb) {
+		usb_free_urb(kingsun->tx_urb);
+		kingsun->tx_urb =3D NULL;
+	}
+	if (kingsun->rx_urb) {
+		usb_free_urb(kingsun->rx_urb);
+		kingsun->rx_urb =3D NULL;
+	}
+	if (kingsun->rx_buff.skb) {
+		kfree_skb(kingsun->rx_buff.skb);
+		kingsun->rx_buff.skb =3D NULL;
+		kingsun->rx_buff.head =3D NULL;
+	}
+	return err;
+}
+
+/*
+ * Function kingsun_net_close (kingsun)
+ *
+ *    Network device is taken down. Usually this is done by
+ *    "ifconfig irda0 down"
+ */
+static int kingsun_net_close(struct net_device *netdev)
+{
+	struct kingsun_cb *kingsun =3D netdev_priv(netdev);
+
+	/* Stop transmit processing */
+	netif_stop_queue(netdev);
+
+	/* Mop up receive && transmit urb's */
+	usb_kill_urb(kingsun->tx_urb);
+	usb_kill_urb(kingsun->rx_urb);
+
+	usb_free_urb(kingsun->tx_urb);
+	usb_free_urb(kingsun->rx_urb);
+
+	kingsun->tx_urb =3D NULL;
+	kingsun->rx_urb =3D NULL;
+
+	kfree_skb(kingsun->rx_buff.skb);
+	kingsun->rx_buff.skb =3D NULL;
+	kingsun->rx_buff.head =3D NULL;
+	kingsun->rx_buff.in_frame =3D FALSE;
+	kingsun->rx_buff.state =3D OUTSIDE_FRAME;
+	kingsun->receiving =3D 0;
+
+	/* Stop and remove instance of IrLAP */
+	if (kingsun->irlap)
+		irlap_close(kingsun->irlap);
+
+	kingsun->irlap =3D NULL;
+
+	return 0;
+}
+
+/*
+ * IOCTLs : Extra out-of-band network commands...
+ */
+static int kingsun_net_ioctl(struct net_device *netdev, struct ifreq *=
rq,
+			     int cmd)
+{
+	struct if_irda_req *irq =3D (struct if_irda_req *) rq;
+	struct kingsun_cb *kingsun =3D netdev_priv(netdev);
+	int ret =3D 0;
+
+	switch (cmd) {
+	case SIOCSBANDWIDTH: /* Set bandwidth */
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		/* Check if the device is still there */
+		if (netif_device_present(kingsun->netdev))
+			/* No observed commands for speed change */
+			ret =3D -EOPNOTSUPP;
+		break;
+
+	case SIOCSMEDIABUSY: /* Set media busy */
+		if (!capable(CAP_NET_ADMIN))
+			return -EPERM;
+
+		/* Check if the IrDA stack is still there */
+		if (netif_running(kingsun->netdev))
+			irda_device_set_media_busy(kingsun->netdev, TRUE);
+		break;
+
+	case SIOCGRECEIVING:
+		/* Only approximately true */
+		irq->ifr_receiving =3D kingsun->receiving;
+		break;
+
+	default:
+		ret =3D -EOPNOTSUPP;
+	}
+
+	return ret;
+}
+
+/*
+ * Get device stats (for /proc/net/dev and ifconfig)
+ */
+static struct net_device_stats *
+kingsun_net_get_stats(struct net_device *netdev)
+{
+	struct kingsun_cb *kingsun =3D netdev_priv(netdev);
+	return &kingsun->stats;
+}
+
+/*
+ * This routine is called by the USB subsystem for each new device
+ * in the system. We need to check if the device is ours, and in
+ * this case start handling it.
+ */
+static int kingsun_probe(struct usb_interface *intf,
+		      const struct usb_device_id *id)
+{
+	struct usb_host_interface *interface;
+	struct usb_endpoint_descriptor *endpoint;
+
+	struct usb_device *dev =3D interface_to_usbdev(intf);
+	struct kingsun_cb *kingsun =3D NULL;
+	struct net_device *net =3D NULL;
+	int ret =3D -ENOMEM;
+	int pipe, maxp_in, maxp_out;
+	__u8 ep_in;
+	__u8 ep_out;
+
+	/* Check that there really are two interrupt endpoints.
+	   Check based on the one in drivers/usb/input/usbmouse.c
+	 */
+	interface =3D intf->cur_altsetting;
+	if (interface->desc.bNumEndpoints !=3D 2) {
+		err("kingsun-sir: expected 2 endpoints, found %d",
+		    interface->desc.bNumEndpoints);
+		return -ENODEV;
+	}
+	endpoint =3D &interface->endpoint[KINGSUN_EP_IN].desc;
+	if (!usb_endpoint_is_int_in(endpoint)) {
+		err("kingsun-sir: endpoint 0 is not interrupt IN");
+		return -ENODEV;
+	}
+
+	ep_in =3D endpoint->bEndpointAddress;
+	pipe =3D usb_rcvintpipe(dev, ep_in);
+	maxp_in =3D usb_maxpacket(dev, pipe, usb_pipeout(pipe));
+	if (maxp_in > 255 || maxp_in <=3D 1) {
+		err("%s: endpoint 0 has max packet size %d not in range",
+		    __FILE__, maxp_in);
+		return -ENODEV;
+	}
+
+	endpoint =3D &interface->endpoint[KINGSUN_EP_OUT].desc;
+	if (!usb_endpoint_is_int_out(endpoint)) {
+		err("kingsun-sir: endpoint 1 is not interrupt OUT");
+		return -ENODEV;
+	}
+
+	ep_out =3D endpoint->bEndpointAddress;
+	pipe =3D usb_sndintpipe(dev, ep_out);
+	maxp_out =3D usb_maxpacket(dev, pipe, usb_pipeout(pipe));
+
+	/* Allocate network device container. */
+	net =3D alloc_irdadev(sizeof(*kingsun));
+	if(!net)
+		goto err_out1;
+
+	SET_MODULE_OWNER(net);
+	SET_NETDEV_DEV(net, &intf->dev);
+	kingsun =3D netdev_priv(net);
+	kingsun->irlap =3D NULL;
+	kingsun->tx_urb =3D NULL;
+	kingsun->rx_urb =3D NULL;
+	kingsun->ep_in =3D ep_in;
+	kingsun->ep_out =3D ep_out;
+	kingsun->in_buf =3D NULL;
+	kingsun->out_buf =3D NULL;
+	kingsun->max_rx =3D (__u8)maxp_in;
+	kingsun->max_tx =3D (__u8)maxp_out;
+	kingsun->netdev =3D net;
+	kingsun->usbdev =3D dev;
+	kingsun->rx_buff.in_frame =3D FALSE;
+	kingsun->rx_buff.state =3D OUTSIDE_FRAME;
+	kingsun->rx_buff.skb =3D NULL;
+	kingsun->receiving =3D 0;
+	spin_lock_init(&kingsun->lock);
+
+	/* Allocate input buffer */
+	kingsun->in_buf =3D (__u8 *)kmalloc(kingsun->max_rx, GFP_KERNEL);
+	if (!kingsun->in_buf)
+		goto free_mem;
+
+	/* Allocate output buffer */
+	kingsun->out_buf =3D (__u8 *)kmalloc(KINGSUN_FIFO_SIZE, GFP_KERNEL);
+	if (!kingsun->out_buf)
+		goto free_mem;
+
+	printk(KERN_INFO "KingSun/DonShine IRDA/USB found at address %d, "
+		"Vendor: %x, Product: %x\n",
+	       dev->devnum, le16_to_cpu(dev->descriptor.idVendor),
+	       le16_to_cpu(dev->descriptor.idProduct));
+
+	/* Initialize QoS for this device */
+	irda_init_max_qos_capabilies(&kingsun->qos);
+
+	/* That's the Rx capability. */
+	kingsun->qos.baud_rate.bits       &=3D IR_9600;
+	kingsun->qos.min_turn_time.bits   &=3D KINGSUN_MTT;
+	irda_qos_bits_to_value(&kingsun->qos);
+
+	/* Override the network functions we need to use */
+	net->hard_start_xmit =3D kingsun_hard_xmit;
+	net->open            =3D kingsun_net_open;
+	net->stop            =3D kingsun_net_close;
+	net->get_stats	     =3D kingsun_net_get_stats;
+	net->do_ioctl        =3D kingsun_net_ioctl;
+
+	ret =3D register_netdev(net);
+	if (ret !=3D 0)
+		goto free_mem;
+
+	info("IrDA: Registered KingSun/DonShine device %s", net->name);
+
+	usb_set_intfdata(intf, kingsun);
+
+	/* Situation at this point:
+	   - all work buffers allocated
+	   - urbs not allocated, set to NULL
+	   - max rx packet known (in max_rx)
+	   - unwrap state machine (partially) initialized, but skb =3D=3D NUL=
L
+	 */
+
+	return 0;
+
+free_mem:
+	if (kingsun->out_buf) kfree(kingsun->out_buf);
+	if (kingsun->in_buf) kfree(kingsun->in_buf);
+	free_netdev(net);
+err_out1:
+	return ret;
+}
+
+/*
+ * The current device is removed, the USB layer tell us to shut it dow=
n...
+ */
+static void kingsun_disconnect(struct usb_interface *intf)
+{
+	struct kingsun_cb *kingsun =3D usb_get_intfdata(intf);
+
+	if (!kingsun)
+		return;
+
+	unregister_netdev(kingsun->netdev);
+
+	/* Mop up receive && transmit urb's */
+	if (kingsun->tx_urb !=3D NULL) {
+		usb_kill_urb(kingsun->tx_urb);
+		usb_free_urb(kingsun->tx_urb);
+		kingsun->tx_urb =3D NULL;
+	}
+	if (kingsun->rx_urb !=3D NULL) {
+		usb_kill_urb(kingsun->rx_urb);
+		usb_free_urb(kingsun->rx_urb);
+		kingsun->rx_urb =3D NULL;
+	}
+
+	kfree(kingsun->out_buf);
+	kfree(kingsun->in_buf);
+	free_netdev(kingsun->netdev);
+
+	usb_set_intfdata(intf, NULL);
+}
+
+#ifdef CONFIG_PM
+/* USB suspend, so power off the transmitter/receiver */
+static int kingsun_suspend(struct usb_interface *intf, pm_message_t me=
ssage)
+{
+	struct kingsun_cb *kingsun =3D usb_get_intfdata(intf);
+
+	netif_device_detach(kingsun->netdev);
+	if (kingsun->tx_urb !=3D NULL) usb_kill_urb(kingsun->tx_urb);
+	if (kingsun->rx_urb !=3D NULL) usb_kill_urb(kingsun->rx_urb);
+	return 0;
+}
+
+/* Coming out of suspend, so reset hardware */
+static int kingsun_resume(struct usb_interface *intf)
+{
+	struct kingsun_cb *kingsun =3D usb_get_intfdata(intf);
+
+	if (kingsun->rx_urb !=3D NULL)
+		usb_submit_urb(kingsun->rx_urb, GFP_KERNEL);
+	netif_device_attach(kingsun->netdev);
+
+	return 0;
+}
+#endif
+
+/*
+ * USB device callbacks
+ */
+static struct usb_driver irda_driver =3D {
+	.name		=3D "kingsun-sir",
+	.probe		=3D kingsun_probe,
+	.disconnect	=3D kingsun_disconnect,
+	.id_table	=3D dongles,
+#ifdef CONFIG_PM
+	.suspend	=3D kingsun_suspend,
+	.resume		=3D kingsun_resume,
+#endif
+};
+
+/*
+ * Module insertion
+ */
+static int __init kingsun_init(void)
+{
+	return usb_register(&irda_driver);
+}
+module_init(kingsun_init);
+
+/*
+ * Module removal
+ */
+static void __exit kingsun_cleanup(void)
+{
+	/* Deregister the driver and remove all pending instances */
+	usb_deregister(&irda_driver);
+}
+module_exit(kingsun_cleanup);
+
+MODULE_AUTHOR("Alex Villac=EF=BF=BDs Lasso <a_villacis@palosanto.com>"=
);
+MODULE_DESCRIPTION("IrDA-USB Dongle Driver for KingSun/DonShine");
+MODULE_LICENSE("GPL");
--=20
1.5.1.1



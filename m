From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: [RFC] ndo_validate_skb: Let the netdev check a valid skb content
Date: Wed, 23 Dec 2009 20:23:27 +0100
Message-ID: <4B326E2F.2050709@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:54038 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753311AbZLWTXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2009 14:23:32 -0500
Received: from [90.186.6.211] (ip-90-186-6-211.web.vodafone.de [90.186.6.211])
	by post.strato.de (klopstock mo49) (RZmta 22.5)
	with ESMTP id Y01eddlBNJG17T for <netdev@vger.kernel.org>;
	Wed, 23 Dec 2009 20:23:26 +0100 (MET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

the content of the skb data (at least for CAN netdevices) needs to
follow specific conventions for valid CAN frames to be sent on the
medium. Maybe other (non-ethernet?) drivers have similar requirements.

The CAN conventions are checked in can_send() in af_can.c but there
are no(!) checks when using PF_PACKET to send on CAN netdevices.

Of course the invalid frames could be dropped silently in the driver.
But then no feedback (e.g. return value of -EINVAL on write) would be
visible for userspace applications.

To get this feedback and to be able to pass it back to the user, we need
to check in the networking layer whether the frame could pass the netdevice
correctly.

IMO, this could be done in two ways:

    - in dev_queue_xmit() for all protocol families
    - in af_packet.c or other specific protocol families

This patch is a RFC for the integration of the check in dev_queue_xmit().

It calls a driver specific skb validation function, if registered.

There are still some open points in af_packet.c to pass the return value
of dev_queue_xmit() back to the user - but this would be the next step,
after getting your feedback ...

Regards,
Oliver

Signed-off-by: Oliver Hartkopp <oliver@hartkopp.net>
---

diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index 166cc7e..8cdeba0 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -1017,6 +1017,7 @@ static const struct net_device_ops at91_netdev_ops = {
 	.ndo_open	= at91_open,
 	.ndo_stop	= at91_close,
 	.ndo_start_xmit	= at91_start_xmit,
+	.ndo_validate_skb = can_validate_skb,
 };
 
 static int __init at91_can_probe(struct platform_device *pdev)
diff --git a/drivers/net/can/bfin_can.c b/drivers/net/can/bfin_can.c
index 0ec1524..646f326 100644
--- a/drivers/net/can/bfin_can.c
+++ b/drivers/net/can/bfin_can.c
@@ -608,6 +608,7 @@ static const struct net_device_ops bfin_can_netdev_ops = {
 	.ndo_open               = bfin_can_open,
 	.ndo_stop               = bfin_can_close,
 	.ndo_start_xmit         = bfin_can_start_xmit,
+	.ndo_validate_skb       = can_validate_skb,
 };
 
 static int __devinit bfin_can_probe(struct platform_device *pdev)
diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
index 9c5a153..773926a 100644
--- a/drivers/net/can/mcp251x.c
+++ b/drivers/net/can/mcp251x.c
@@ -925,6 +925,7 @@ static const struct net_device_ops mcp251x_netdev_ops = {
 	.ndo_open = mcp251x_open,
 	.ndo_stop = mcp251x_stop,
 	.ndo_start_xmit = mcp251x_hard_start_xmit,
+	.ndo_validate_skb = can_validate_skb,
 };
 
 static int __devinit mcp251x_can_probe(struct spi_device *spi)
diff --git a/drivers/net/can/mscan/mscan.c b/drivers/net/can/mscan/mscan.c
index 07346f8..280448e 100644
--- a/drivers/net/can/mscan/mscan.c
+++ b/drivers/net/can/mscan/mscan.c
@@ -590,6 +590,7 @@ static const struct net_device_ops mscan_netdev_ops = {
        .ndo_open               = mscan_open,
        .ndo_stop               = mscan_close,
        .ndo_start_xmit         = mscan_start_xmit,
+       .ndo_validate_skb       = can_validate_skb,
 };
 
 int register_mscandev(struct net_device *dev, int clock_src)
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sja1000.c
index 542a4f7..a724223 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -582,6 +582,7 @@ static const struct net_device_ops sja1000_netdev_ops = {
        .ndo_open               = sja1000_open,
        .ndo_stop               = sja1000_close,
        .ndo_start_xmit         = sja1000_start_xmit,
+       .ndo_validate_skb       = can_validate_skb,
 };
 
 int register_sja1000dev(struct net_device *dev)
diff --git a/drivers/net/can/ti_hecc.c b/drivers/net/can/ti_hecc.c
index 5c993c2..cd8e4fc 100644
--- a/drivers/net/can/ti_hecc.c
+++ b/drivers/net/can/ti_hecc.c
@@ -850,6 +850,7 @@ static const struct net_device_ops ti_hecc_netdev_ops = {
 	.ndo_open		= ti_hecc_open,
 	.ndo_stop		= ti_hecc_close,
 	.ndo_start_xmit		= ti_hecc_xmit,
+	.ndo_validate_skb	= can_validate_skb,
 };
 
 static int ti_hecc_probe(struct platform_device *pdev)
diff --git a/drivers/net/can/usb/ems_usb.c b/drivers/net/can/usb/ems_usb.c
index efbb05c..03a756a 100644
--- a/drivers/net/can/usb/ems_usb.c
+++ b/drivers/net/can/usb/ems_usb.c
@@ -905,6 +905,7 @@ static const struct net_device_ops ems_usb_netdev_ops = {
 	.ndo_open = ems_usb_open,
 	.ndo_stop = ems_usb_close,
 	.ndo_start_xmit = ems_usb_start_xmit,
+	.ndo_validate_skb = can_validate_skb,
 };
 
 static struct can_bittiming_const ems_usb_bittiming_const = {
diff --git a/drivers/net/can/vcan.c b/drivers/net/can/vcan.c
index 80ac563..cb00b03 100644
--- a/drivers/net/can/vcan.c
+++ b/drivers/net/can/vcan.c
@@ -47,6 +47,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/can.h>
+#include <linux/can/dev.h>
 #include <net/rtnetlink.h>
 
 static __initdata const char banner[] =
@@ -130,6 +131,7 @@ static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
 
 static const struct net_device_ops vcan_netdev_ops = {
 	.ndo_start_xmit = vcan_tx,
+	.ndo_validate_skb = can_validate_skb,
 };
 
 static void vcan_setup(struct net_device *dev)
diff --git a/include/linux/can/dev.h b/include/linux/can/dev.h
index 3db7767..b70d6f3 100644
--- a/include/linux/can/dev.h
+++ b/include/linux/can/dev.h
@@ -77,6 +77,16 @@ void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev,
 void can_get_echo_skb(struct net_device *dev, unsigned int idx);
 void can_free_echo_skb(struct net_device *dev, unsigned int idx);
 
+static inline int can_validate_skb(struct sk_buff *skb)
+{
+	struct can_frame *cf = (struct can_frame *)skb->data;
+
+	if (unlikely(skb->len != sizeof(struct can_frame) || cf->can_dlc > 8))
+		return 1;
+
+	return 0;
+}
+
 struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf);
 struct sk_buff *alloc_can_err_skb(struct net_device *dev,
 				  struct can_frame **cf);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..a3f4794 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -571,6 +571,9 @@ struct netdev_queue {
  * int (*ndo_validate_addr)(struct net_device *dev);
  *	Test if Media Access Control address is valid for the device.
  *
+ * int (*ndo_validate_skb)(struct sk_buff *skb);
+ *	Test if the given skb content is valid for this device.
+ *
  * int (*ndo_do_ioctl)(struct net_device *dev, struct ifreq *ifr, int cmd);
  *	Called when a user request an ioctl which can't be handled by
  *	the generic interface code. If not defined ioctl's return
@@ -633,6 +636,10 @@ struct net_device_ops {
 						       void *addr);
 #define HAVE_VALIDATE_ADDR
 	int			(*ndo_validate_addr)(struct net_device *dev);
+
+#define HAVE_VALIDATE_SKB
+	int			(*ndo_validate_skb)(struct sk_buff *skb);
+
 #define HAVE_PRIVATE_IOCTL
 	int			(*ndo_do_ioctl)(struct net_device *dev,
 					        struct ifreq *ifr, int cmd);
diff --git a/net/core/dev.c b/net/core/dev.c
index be9924f..9de3484 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2002,6 +2002,7 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 int dev_queue_xmit(struct sk_buff *skb)
 {
 	struct net_device *dev = skb->dev;
+	const struct net_device_ops *ops = dev->netdev_ops;
 	struct netdev_queue *txq;
 	struct Qdisc *q;
 	int rc = -ENOMEM;
@@ -2034,6 +2035,14 @@ int dev_queue_xmit(struct sk_buff *skb)
 			goto out_kfree_skb;
 	}
 
+	/* If the device offers a function to validate the skb content, let
+	 * it check the skb and return an error to the caller if it fails.
+	 */ 
+	if (ops->ndo_validate_skb && ops->ndo_validate_skb(skb)) {
+		rc = -EINVAL;
+		goto out_kfree_skb;
+	}
+
 gso:
 	/* Disable soft irqs for various locks below. Also
 	 * stops preemption for RCU.


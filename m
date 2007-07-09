From: Urs Thuermann <urs@isnogud.escape.de>
Subject: Re: [patch 5/7] CAN: Add virtual CAN netdevice driver
Date: 09 Jul 2007 13:37:45 +0200
Message-ID: <ygfodil7qpi.fsf@janus.isnogud.escape.de>
References: <20070622034452.28886.0@janus.isnogud.escape.de>
	<20070622034703.28886.5@janus.isnogud.escape.de>
	<467BAC48.1070700@trash.net> <ygfk5tw41rq.fsf@janus.isnogud.escape.de>
	<467BC2AF.8080901@trash.net> <467D0C97.1000000@hartkopp.net>
	<467D178B.8080503@trash.net> <467D3891.4010906@hartkopp.net>
	<467D4965.40601@trash.net> <467D4D65.2080806@hartkopp.net>
	<467D54AB.5010407@trash.net> <ygfzm2ciemk.fsf@janus.isnogud.escape.de>
	<468BA83A.7070500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Oliver Hartkopp <oliver@hartkopp.net>,
	David Miller <davem@davemloft.net>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	j.hadi123@gmail.com, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:50476 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757770AbXGILkX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2007 07:40:23 -0400
In-Reply-To: <468BA83A.7070500@trash.net>; from Patrick McHardy on Wed, 04 Jul 2007 16:01:30 +0200
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

> > I currently still prefer no default interfaces, since we would get rid
> > of some code.
> 
> 
> Me too, and you don't need to worry about compatibility.

Here is a new version of the vcan driver for you to review.  We now
use the netlink link creation API and no interfaces will be created at
module load time.  The module parameter for the number of interfaces
to be created has been removed.

I have appended the patch at the end of this mail.

We have also made some changes to the rest of the PF_CAN code, here is
the complete list of changes:

* Change vcan network driver to use the new RTNL API.

* Revert our change to use skb->iif instead of skb->cb.  After
  discussion with Patrick and Jamal it turned out, our first
  implementation was correct.
 
* Use skb_tail_pointer() instead of skb->tail directly.

* Minor changes for 64-bit-cleanliness.

* Minor cleanup of #include's

The current patch series can be found at
http://svn.berlios.de/svnroot/repos/socketcan/trunk/patch-series/net-2.6.23

Could you please review this again?  Should we post the whole patch
series to netdev ML again?

Regards,
urs



This patch adds the virtual CAN bus (vcan) network driver.
The vcan device is just a loopback device for CAN frames, no
real CAN hardware is involved.

Signed-Off-By: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
Signed-Off-By: Urs Thuermann <urs.thuermann@volkswagen.de>

---
 drivers/net/Makefile     |    1 
 drivers/net/can/Kconfig  |   25 ++++
 drivers/net/can/Makefile |    5 
 drivers/net/can/vcan.c   |  264 +++++++++++++++++++++++++++++++++++++++++++++++
 net/can/Kconfig          |    3 
 5 files changed, 298 insertions(+)

Index: net-2.6.23/drivers/net/Makefile
===================================================================
--- net-2.6.23.orig/drivers/net/Makefile	2007-07-09 10:41:38.000000000 +0200
+++ net-2.6.23/drivers/net/Makefile	2007-07-09 10:42:01.000000000 +0200
@@ -8,6 +8,7 @@
 obj-$(CONFIG_CHELSIO_T1) += chelsio/
 obj-$(CONFIG_CHELSIO_T3) += cxgb3/
 obj-$(CONFIG_EHEA) += ehea/
+obj-$(CONFIG_CAN) += can/
 obj-$(CONFIG_BONDING) += bonding/
 obj-$(CONFIG_ATL1) += atl1/
 obj-$(CONFIG_GIANFAR) += gianfar_driver.o
Index: net-2.6.23/drivers/net/can/Kconfig
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6.23/drivers/net/can/Kconfig	2007-07-09 10:42:01.000000000 +0200
@@ -0,0 +1,25 @@
+menu "CAN Device Drivers"
+	depends on CAN
+
+config CAN_VCAN
+	tristate "Virtual Local CAN Interface (vcan)"
+ 	depends on CAN
+	default N
+ 	---help---
+	  Similar to the network loopback devices, vcan offers a
+	  virtual local CAN interface.
+
+	  This driver can also be built as a module.  If so, the module
+	  will be called vcan.
+
+config CAN_DEBUG_DEVICES
+	bool "CAN devices debugging messages"
+	depends on CAN
+	default N
+	---help---
+	  Say Y here if you want the CAN device drivers to produce a bunch of
+	  debug messages to the system log.  Select this if you are having
+	  a problem with CAN support and want to see more of what is going
+	  on.
+
+endmenu
Index: net-2.6.23/drivers/net/can/Makefile
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6.23/drivers/net/can/Makefile	2007-07-09 10:42:01.000000000 +0200
@@ -0,0 +1,5 @@
+#
+#  Makefile for the Linux Controller Area Network drivers.
+#
+
+obj-$(CONFIG_CAN_VCAN)		+= vcan.o
Index: net-2.6.23/drivers/net/can/vcan.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-2.6.23/drivers/net/can/vcan.c	2007-07-09 13:22:44.000000000 +0200
@@ -0,0 +1,264 @@
+/*
+ * vcan.c - Virtual CAN interface
+ *
+ * Copyright (c) 2002-2007 Volkswagen Group Electronic Research
+ * All rights reserved.
+ *
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions
+ * are met:
+ * 1. Redistributions of source code must retain the above copyright
+ *    notice, this list of conditions, the following disclaimer and
+ *    the referenced file 'COPYING'.
+ * 2. Redistributions in binary form must reproduce the above copyright
+ *    notice, this list of conditions and the following disclaimer in the
+ *    documentation and/or other materials provided with the distribution.
+ * 3. Neither the name of Volkswagen nor the names of its contributors
+ *    may be used to endorse or promote products derived from this software
+ *    without specific prior written permission.
+ *
+ * Alternatively, provided that this notice is retained in full, this
+ * software may be distributed under the terms of the GNU General
+ * Public License ("GPL") version 2 as distributed in the 'COPYING'
+ * file from the main directory of the linux kernel source.
+ *
+ * The provided data structures and external interfaces from this code
+ * are not restricted to be used by modules with a GPL compatible license.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
+ * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
+ * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
+ * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
+ * OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
+ * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
+ * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
+ * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
+ * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
+ * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
+ * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
+ * DAMAGE.
+ *
+ * Send feedback to <socketcan-users@lists.berlios.de>
+ *
+ */
+
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/can.h>
+#include <net/rtnetlink.h>
+
+static __initdata const char banner[] =
+	KERN_INFO "vcan: Virtual CAN interface driver\n";
+
+MODULE_DESCRIPTION("virtual CAN interface");
+MODULE_LICENSE("Dual BSD/GPL");
+MODULE_AUTHOR("Urs Thuermann <urs.thuermann@volkswagen.de>");
+
+#ifdef CONFIG_CAN_DEBUG_DEVICES
+static int debug = 0;
+module_param(debug, int, S_IRUGO);
+#endif
+
+/* To be moved to linux/can/dev.h */
+#ifdef CONFIG_CAN_DEBUG_DEVICES
+#define DBG(args...)       (debug & 1 ? \
+			       (printk(KERN_DEBUG "vcan %s: ", __func__), \
+				printk(args)) : 0)
+#else
+#define DBG(args...)
+#endif
+
+
+/*
+ * CAN network devices *should* support a local loopback functionality
+ * (see Documentation/networking/can.txt). To test the handling of CAN
+ * interfaces that do not support the loopback both driver types are
+ * implemented inside this vcan driver. In the case that the driver does
+ * not support the loopback the IFF_LOOPBACK remains clear in dev->flags.
+ * This causes the PF_CAN core to perform the loopback as a fallback solution.
+ */
+
+static int loopback = 0; /* vcan default: no loopback, just free the skb */
+module_param(loopback, int, S_IRUGO);
+MODULE_PARM_DESC(loopback, "Loop back sent frames. vcan default: 0 (Off)");
+
+struct vcan_priv {
+	struct net_device *dev;
+	struct list_head list;
+};
+static LIST_HEAD(vcan_devs);
+
+static int vcan_open(struct net_device *dev)
+{
+	DBG("%s: interface up\n", dev->name);
+
+	netif_start_queue(dev);
+	return 0;
+}
+
+static int vcan_stop(struct net_device *dev)
+{
+	DBG("%s: interface down\n", dev->name);
+
+	netif_stop_queue(dev);
+	return 0;
+}
+
+static void vcan_rx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_device_stats *stats = &dev->stats;
+
+	stats->rx_packets++;
+	stats->rx_bytes += skb->len;
+
+	skb->protocol  = htons(ETH_P_CAN);
+	skb->pkt_type  = PACKET_BROADCAST;
+	skb->dev       = dev;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
+
+	DBG("received skbuff on interface %d\n", dev->ifindex);
+
+	netif_rx(skb);
+}
+
+static int vcan_tx(struct sk_buff *skb, struct net_device *dev)
+{
+	struct net_device_stats *stats = &dev->stats;
+	int loop;
+
+	DBG("sending skbuff on interface %s\n", dev->name);
+
+	stats->tx_packets++;
+	stats->tx_bytes += skb->len;
+
+	/* set flag whether this packet has to be looped back */
+	loop = skb->pkt_type == PACKET_LOOPBACK;
+
+	if (!loopback) {
+		/* no loopback handling available inside this driver */
+
+		if (loop) {
+			/*
+			 * only count the packets here, because the
+			 * CAN core already did the loopback for us
+			 */
+			stats->rx_packets++;
+			stats->rx_bytes += skb->len;
+		}
+		kfree_skb(skb);
+		return 0;
+	}
+
+	/* perform standard loopback handling for CAN network interfaces */
+
+	if (loop) {
+		struct sock *srcsk = skb->sk;
+
+		if (atomic_read(&skb->users) != 1) {
+			struct sk_buff *old_skb = skb;
+
+			skb = skb_clone(old_skb, GFP_ATOMIC);
+			DBG(KERN_INFO "%s: %s: freeing old skbuff %p, "
+			    "using new skbuff %p\n",
+			    dev->name, __FUNCTION__, old_skb, skb);
+			kfree_skb(old_skb);
+			if (!skb)
+				return 0;
+		} else
+			skb_orphan(skb);
+
+		/* receive with packet counting */
+		skb->sk = srcsk;
+		vcan_rx(skb, dev);
+	} else {
+		/* no looped packets => no counting */
+		kfree_skb(skb);
+	}
+	return 0;
+}
+
+static void vcan_setup(struct net_device *dev)
+{
+	DBG("dev %s\n", dev->name);
+
+	dev->type              = ARPHRD_CAN;
+	dev->mtu               = sizeof(struct can_frame);
+	dev->hard_header_len   = 0;
+	dev->addr_len          = 0;
+	dev->tx_queue_len      = 0;
+	dev->flags             = IFF_NOARP;
+
+	/* set flags according to driver capabilities */
+	if (loopback)
+		dev->flags |= IFF_LOOPBACK;
+
+	dev->open              = vcan_open;
+	dev->stop              = vcan_stop;
+	dev->hard_start_xmit   = vcan_tx;
+	dev->destructor        = free_netdev;
+
+	SET_MODULE_OWNER(dev);
+}
+
+static int vcan_newlink(struct net_device *dev,
+			struct nlattr *tb[], struct nlattr *data[])
+{
+	struct vcan_priv *priv = netdev_priv(dev);
+	int err;
+
+	err = register_netdevice(dev);
+	if (err < 0)
+		return err;
+
+	priv->dev = dev;
+	list_add_tail(&priv->list, &vcan_devs);
+	return 0;
+}
+
+static void vcan_dellink(struct net_device *dev)
+{
+	struct vcan_priv *priv = netdev_priv(dev);
+
+	list_del(&priv->list);
+	unregister_netdevice(dev);
+}
+
+static struct rtnl_link_ops vcan_link_ops __read_mostly = {
+       .kind           = "vcan",
+       .priv_size      = sizeof(struct vcan_priv),
+       .setup          = vcan_setup,
+       .newlink        = vcan_newlink,
+       .dellink        = vcan_dellink,
+};
+
+static __init int vcan_init_module(void)
+{
+	int err;
+
+	printk(banner);
+
+	if (loopback)
+		printk(KERN_INFO "vcan: enabled loopback on driver level.\n");
+
+	rtnl_lock();
+	err = __rtnl_link_register(&vcan_link_ops);
+	rtnl_unlock();
+	return err;
+}
+
+static __exit void vcan_cleanup_module(void)
+{
+	struct vcan_priv *priv, *n;
+
+	rtnl_lock();
+	list_for_each_entry_safe(priv, n, &vcan_devs, list)
+		vcan_dellink(priv->dev);
+	__rtnl_link_unregister(&vcan_link_ops);
+	rtnl_unlock();
+}
+
+module_init(vcan_init_module);
+module_exit(vcan_cleanup_module);
Index: net-2.6.23/net/can/Kconfig
===================================================================
--- net-2.6.23.orig/net/can/Kconfig	2007-07-09 10:41:58.000000000 +0200
+++ net-2.6.23/net/can/Kconfig	2007-07-09 10:42:01.000000000 +0200
@@ -77,3 +77,6 @@
 	  Say Y here if you want the CAN core to produce a bunch of debug
 	  messages to the system log.  Select this if you are having a
 	  problem with CAN support and want to see more of what is going on.
+
+
+source "drivers/net/can/Kconfig"

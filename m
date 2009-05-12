From: Wolfgang Grandegger <wg@grandegger.com>
Subject: [PATCH v2 3/7] [PATCH 3/8] can: CAN Network device driver and Netlink interface
Date: Tue, 12 May 2009 11:28:00 +0200
Message-ID: <20090512092757.574693100@denx.de>
References: <20090512092757.048938233@denx.de>
Cc: linux-kernel@vger.kernel.org,
	Wolfgang Grandegger <wg@grandegger.com>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:43694 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756808AbZELJ2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 05:28:01 -0400
Content-Disposition: inline; filename=03-driver-interface.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The CAN network device driver interface provides a generic interface to
setup, configure and monitor CAN network devices. It exports a set of
common data structures and functions, which all real CAN network device
drivers should use. Please have a look to the SJA1000 or MSCAN driver
to understand how to use them. The name of the module is can-dev.ko.

Furthermore, it adds a Netlink interface allowing to configure the CAN
device using the program "ip" from the iproute2 utility suite.

For further information please check "Documentation/networking/can.txt"

Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>
---
 drivers/net/can/Kconfig     |   23 +
 drivers/net/can/Makefile    |    5 
 drivers/net/can/dev.c       |  659 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/can/Kbuild    |    1 
 include/linux/can/dev.h     |   70 ++++
 include/linux/can/netlink.h |  113 +++++++
 6 files changed, 871 insertions(+)
 create mode 100644 drivers/net/can/dev.c
 create mode 100644 drivers/net/can/sysfs.c
 create mode 100644 drivers/net/can/sysfs.h
 create mode 100644 include/linux/can/dev.h

Index: net-next-2.6/drivers/net/can/Kconfig
===================================================================
--- net-next-2.6.orig/drivers/net/can/Kconfig	2009-05-12 10:47:10.449721030 +0200
+++ net-next-2.6/drivers/net/can/Kconfig	2009-05-12 10:47:25.061720603 +0200
@@ -12,6 +12,29 @@
 	  This driver can also be built as a module.  If so, the module
 	  will be called vcan.
 
+config CAN_DEV
+	tristate "Platform CAN drivers with Netlink support"
+	depends on CAN
+	default Y
+	---help---
+	  Enables the common framework for platform CAN drivers with Netlink
+	  support. This is the standard library for CAN drivers.
+	  If unsure, say Y.
+
+config CAN_CALC_BITTIMING
+	bool "CAN bit-timing calculation"
+	depends on CAN_DEV
+	default Y
+	---help---
+	  If enabled, CAN bit-timing parameters will be calculated for the
+	  bit-rate specified via Netlink argument "bitrate" when the device
+	  get started. This works fine for the most common CAN controllers
+	  with standard bit-rates but may fail for exotic bit-rates or CAN
+	  source clock frequencies. Disabling saves some space, but then the
+	  bit-timing parameters must be specified directly using the Netlink
+	  arguments "tq", "prop_seg", "phase_seg1", "phase_seg2" and "sjw".
+	  If unsure, say Y.
+
 config CAN_DEBUG_DEVICES
 	bool "CAN devices debugging messages"
 	depends on CAN
Index: net-next-2.6/drivers/net/can/Makefile
===================================================================
--- net-next-2.6.orig/drivers/net/can/Makefile	2009-05-12 10:47:10.449721030 +0200
+++ net-next-2.6/drivers/net/can/Makefile	2009-05-12 10:47:25.061720603 +0200
@@ -3,3 +3,8 @@
 #
 
 obj-$(CONFIG_CAN_VCAN)		+= vcan.o
+
+obj-$(CONFIG_CAN_DEV)		+= can-dev.o
+can-dev-y			:= dev.o
+
+ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
Index: net-next-2.6/drivers/net/can/dev.c
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-next-2.6/drivers/net/can/dev.c	2009-05-12 10:47:25.073720638 +0200
@@ -0,0 +1,659 @@
+/*
+ * Copyright (C) 2005 Marc Kleine-Budde, Pengutronix
+ * Copyright (C) 2006 Andrey Volkov, Varma Electronics
+ * Copyright (C) 2008-2009 Wolfgang Grandegger <wg@grandegger.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the version 2 of the GNU General Public License
+ * as published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/netdevice.h>
+#include <linux/if_arp.h>
+#include <linux/can.h>
+#include <linux/can/dev.h>
+#include <linux/can/netlink.h>
+#include <net/rtnetlink.h>
+
+#define MOD_DESC "CAN device driver interface"
+
+MODULE_DESCRIPTION(MOD_DESC);
+MODULE_LICENSE("GPL v2");
+MODULE_AUTHOR("Wolfgang Grandegger <wg@grandegger.com>");
+
+#ifdef CONFIG_CAN_CALC_BITTIMING
+#define CAN_CALC_MAX_ERROR 50 /* in one-tenth of a percent */
+
+/*
+ * Bit-timing calculation derived from:
+ *
+ * Code based on LinCAN sources and H8S2638 project
+ * Copyright 2004-2006 Pavel Pisa - DCE FELK CVUT cz
+ * Copyright 2005      Stanislav Marek
+ * email: pisa@cmp.felk.cvut.cz
+ *
+ * Calculates proper bit-timing parameters for a specified bit-rate
+ * and sample-point, which can then be used to set the bit-timing
+ * registers of the CAN controller. You can find more information
+ * in the header file linux/can/netlink.h.
+ */
+static int can_update_spt(const struct can_bittiming_const *btc,
+			  int sampl_pt, int tseg, int *tseg1, int *tseg2)
+{
+	*tseg2 = tseg + 1 - (sampl_pt * (tseg + 1)) / 1000;
+	if (*tseg2 < btc->tseg2_min)
+		*tseg2 = btc->tseg2_min;
+	if (*tseg2 > btc->tseg2_max)
+		*tseg2 = btc->tseg2_max;
+	*tseg1 = tseg - *tseg2;
+	if (*tseg1 > btc->tseg1_max) {
+		*tseg1 = btc->tseg1_max;
+		*tseg2 = tseg - *tseg1;
+	}
+	return 1000 * (tseg + 1 - *tseg2) / (tseg + 1);
+}
+
+static int can_calc_bittiming(struct net_device *dev, struct can_bittiming *bt)
+{
+	struct can_priv *priv = netdev_priv(dev);
+	const struct can_bittiming_const *btc = priv->bittiming_const;
+	long rate, best_rate = 0;
+	long best_error = 1000000000, error = 0;
+	int best_tseg = 0, best_brp = 0, brp = 0;
+	int tsegall, tseg = 0, tseg1 = 0, tseg2 = 0;
+	int spt_error = 1000, spt = 0, sampl_pt;
+	u64 v64;
+
+	if (!priv->bittiming_const)
+		return -ENOTSUPP;
+
+	/* Use CIA recommended sample points */
+	if (bt->sample_point) {
+		sampl_pt = bt->sample_point;
+	} else {
+		if (bt->bitrate > 800000)
+			sampl_pt = 750;
+		else if (bt->bitrate > 500000)
+			sampl_pt = 800;
+		else
+			sampl_pt = 875;
+	}
+
+	/* tseg even = round down, odd = round up */
+	for (tseg = (btc->tseg1_max + btc->tseg2_max) * 2 + 1;
+	     tseg >= (btc->tseg1_min + btc->tseg2_min) * 2; tseg--) {
+		tsegall = 1 + tseg / 2;
+		/* Compute all possible tseg choices (tseg=tseg1+tseg2) */
+		brp = priv->clock.freq / (tsegall * bt->bitrate) + tseg % 2;
+		/* chose brp step which is possible in system */
+		brp = (brp / btc->brp_inc) * btc->brp_inc;
+		if ((brp < btc->brp_min) || (brp > btc->brp_max))
+			continue;
+		rate = priv->clock.freq / (brp * tsegall);
+		error = bt->bitrate - rate;
+		/* tseg brp biterror */
+		if (error < 0)
+			error = -error;
+		if (error > best_error)
+			continue;
+		best_error = error;
+		if (error == 0) {
+			spt = can_update_spt(btc, sampl_pt, tseg / 2,
+					     &tseg1, &tseg2);
+			error = sampl_pt - spt;
+			if (error < 0)
+				error = -error;
+			if (error > spt_error)
+				continue;
+			spt_error = error;
+		}
+		best_tseg = tseg / 2;
+		best_brp = brp;
+		best_rate = rate;
+		if (error == 0)
+			break;
+	}
+
+	if (best_error) {
+		/* Error in one-tenth of a percent */
+		error = (best_error * 1000) / bt->bitrate;
+		if (error > CAN_CALC_MAX_ERROR) {
+			dev_err(dev->dev.parent,
+				"bitrate error %ld.%ld%% too high\n",
+				error / 10, error % 10);
+			return -EDOM;
+		} else {
+			dev_warn(dev->dev.parent, "bitrate error %ld.%ld%%\n",
+				 error / 10, error % 10);
+		}
+	}
+
+	/* real sample point */
+	bt->sample_point = can_update_spt(btc, sampl_pt, best_tseg,
+					  &tseg1, &tseg2);
+
+	v64 = (u64)best_brp * 1000000000UL;
+	do_div(v64, priv->clock.freq);
+	bt->tq = (u32)v64;
+	bt->prop_seg = tseg1 / 2;
+	bt->phase_seg1 = tseg1 - bt->prop_seg;
+	bt->phase_seg2 = tseg2;
+	bt->sjw = 1;
+	bt->brp = best_brp;
+	/* real bit-rate */
+	bt->bitrate = priv->clock.freq / (bt->brp * (tseg1 + tseg2 + 1));
+
+	return 0;
+}
+#else /* !CONFIG_CAN_CALC_BITTIMING */
+static int can_calc_bittiming(struct net_device *dev, struct can_bittiming *bt)
+{
+	dev_err(dev->dev.parent, "bit-timing calculation not available\n");
+	return -EINVAL;
+}
+#endif /* CONFIG_CAN_CALC_BITTIMING */
+
+/*
+ * Checks the validity of the specified bit-timing parameters prop_seg,
+ * phase_seg1, phase_seg2 and sjw and tries to determine the bitrate
+ * prescaler value brp. You can find more information in the header
+ * file linux/can/netlink.h.
+ */
+static int can_fixup_bittiming(struct net_device *dev, struct can_bittiming *bt)
+{
+	struct can_priv *priv = netdev_priv(dev);
+	const struct can_bittiming_const *btc = priv->bittiming_const;
+	int tseg1, alltseg;
+	u64 brp64;
+
+	if (!priv->bittiming_const)
+		return -ENOTSUPP;
+
+	tseg1 = bt->prop_seg + bt->phase_seg1;
+	if (!bt->sjw)
+		bt->sjw = 1;
+	if (bt->sjw > btc->sjw_max ||
+	    tseg1 < btc->tseg1_min || tseg1 > btc->tseg1_max ||
+	    bt->phase_seg2 < btc->tseg2_min || bt->phase_seg2 > btc->tseg2_max)
+		return -ERANGE;
+
+	brp64 = (u64)priv->clock.freq * (u64)bt->tq;
+	if (btc->brp_inc > 1)
+		do_div(brp64, btc->brp_inc);
+	brp64 += 500000000UL - 1;
+	do_div(brp64, 1000000000UL); /* the practicable BRP */
+	if (btc->brp_inc > 1)
+		brp64 *= btc->brp_inc;
+	bt->brp = (u32)brp64;
+
+	if (bt->brp < btc->brp_min || bt->brp > btc->brp_max)
+		return -EINVAL;
+
+	alltseg = bt->prop_seg + bt->phase_seg1 + bt->phase_seg2 + 1;
+	bt->bitrate = priv->clock.freq / (bt->brp * alltseg);
+	bt->sample_point = ((tseg1 + 1) * 1000) / alltseg;
+
+	return 0;
+}
+
+int can_get_bittiming(struct net_device *dev, struct can_bittiming *bt)
+{
+	struct can_priv *priv = netdev_priv(dev);
+	int err;
+
+	/* Check if the CAN device has bit-timing parameters */
+	if (priv->bittiming_const) {
+
+		/* Non-expert mode? Check if the bitrate has been pre-defined */
+		if (!bt->tq)
+			/* Determine bit-timing parameters */
+			err = can_calc_bittiming(dev, bt);
+		else
+			/* Check bit-timing params and calculate proper brp */
+			err = can_fixup_bittiming(dev, bt);
+		if (err)
+			return err;
+	}
+
+	return 0;
+}
+
+/*
+ * Local echo of CAN messages
+ *
+ * CAN network devices *should* support a local echo functionality
+ * (see Documentation/networking/can.txt). To test the handling of CAN
+ * interfaces that do not support the local echo both driver types are
+ * implemented. In the case that the driver does not support the echo
+ * the IFF_ECHO remains clear in dev->flags. This causes the PF_CAN core
+ * to perform the echo as a fallback solution.
+ */
+static void can_flush_echo_skb(struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	int i;
+
+	for (i = 0; i < CAN_ECHO_SKB_MAX; i++) {
+		if (priv->echo_skb[i]) {
+			kfree_skb(priv->echo_skb[i]);
+			priv->echo_skb[i] = NULL;
+			stats->tx_dropped++;
+			stats->tx_aborted_errors++;
+		}
+	}
+}
+
+/*
+ * Put the skb on the stack to be looped backed locally lateron
+ *
+ * The function is typically called in the start_xmit function
+ * of the device driver. The driver must protect access to
+ * priv->echo_skb, if necessary.
+ */
+void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int idx)
+{
+	struct can_priv *priv = netdev_priv(dev);
+
+	/* check flag whether this packet has to be looped back */
+	if (!(dev->flags & IFF_ECHO) || skb->pkt_type != PACKET_LOOPBACK) {
+		kfree_skb(skb);
+		return;
+	}
+
+	if (!priv->echo_skb[idx]) {
+		struct sock *srcsk = skb->sk;
+
+		if (atomic_read(&skb->users) != 1) {
+			struct sk_buff *old_skb = skb;
+
+			skb = skb_clone(old_skb, GFP_ATOMIC);
+			kfree_skb(old_skb);
+			if (!skb)
+				return;
+		} else
+			skb_orphan(skb);
+
+		skb->sk = srcsk;
+
+		/* make settings for echo to reduce code in irq context */
+		skb->protocol = htons(ETH_P_CAN);
+		skb->pkt_type = PACKET_BROADCAST;
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->dev = dev;
+
+		/* save this skb for tx interrupt echo handling */
+		priv->echo_skb[idx] = skb;
+	} else {
+		/* locking problem with netif_stop_queue() ?? */
+		dev_err(dev->dev.parent, "%s: BUG! echo_skb is occupied!\n",
+			__func__);
+		kfree_skb(skb);
+	}
+}
+EXPORT_SYMBOL_GPL(can_put_echo_skb);
+
+/*
+ * Get the skb from the stack and loop it back locally
+ *
+ * The function is typically called when the TX done interrupt
+ * is handled in the device driver. The driver must protect
+ * access to priv->echo_skb, if necessary.
+ */
+void can_get_echo_skb(struct net_device *dev, int idx)
+{
+	struct can_priv *priv = netdev_priv(dev);
+
+	if ((dev->flags & IFF_ECHO) && priv->echo_skb[idx]) {
+		netif_rx(priv->echo_skb[idx]);
+		priv->echo_skb[idx] = NULL;
+	}
+}
+EXPORT_SYMBOL_GPL(can_get_echo_skb);
+
+/*
+ * CAN device restart for bus-off recovery
+ */
+int can_restart_now(struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+	struct net_device_stats *stats = &dev->stats;
+	struct sk_buff *skb;
+	struct can_frame *cf;
+	int err;
+
+	/* Synchronize with dev->hard_start_xmit() */
+	netif_tx_lock(dev);
+
+	/* Ensure that no more messages can go out */
+	if (netif_carrier_ok(dev))
+		netif_carrier_off(dev);
+
+	/* Ensure that no more messages can come in */
+	err = priv->do_set_mode(dev, CAN_MODE_STOP);
+	if (err)
+		return err;
+
+	/*  Now it's save to clean up */
+	del_timer_sync(&priv->restart_timer);
+	can_flush_echo_skb(dev);
+
+	dev_dbg(dev->dev.parent, "restarted\n");
+	priv->can_stats.restarts++;
+
+	/* send restart message upstream */
+	skb = dev_alloc_skb(sizeof(struct can_frame));
+	if (skb == NULL)
+		return -ENOMEM;
+	skb->dev = dev;
+	skb->protocol = htons(ETH_P_CAN);
+	cf = (struct can_frame *)skb_put(skb, sizeof(struct can_frame));
+	memset(cf, 0, sizeof(struct can_frame));
+	cf->can_id = CAN_ERR_FLAG | CAN_ERR_RESTARTED;
+	cf->can_dlc = CAN_ERR_DLC;
+
+	netif_rx(skb);
+
+	dev->last_rx = jiffies;
+	stats->rx_packets++;
+	stats->rx_bytes += cf->can_dlc;
+
+	/* Now restart the device */
+	err = priv->do_set_mode(dev, CAN_MODE_START);
+	if (err)
+		return err;
+
+	netif_carrier_on(dev);
+
+	netif_tx_unlock(dev);
+
+	return 0;
+}
+
+static void can_restart_after(unsigned long data)
+{
+	struct net_device *dev = (struct net_device *)data;
+
+	can_restart_now(dev);
+}
+
+/*
+ * CAN bus-off
+ *
+ * This functions should be called when the device goes bus-off to
+ * tell the netif layer that no more packets can be sent or received.
+ * If enabled, a timer is started to trigger bus-off recovery.
+ */
+void can_bus_off(struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+
+	dev_dbg(dev->dev.parent, "bus-off\n");
+
+	netif_carrier_off(dev);
+	priv->can_stats.bus_off++;
+
+	if (priv->restart_ms) {
+		priv->restart_timer.function = can_restart_after;
+		priv->restart_timer.data = (unsigned long)dev;
+		priv->restart_timer.expires =
+			jiffies + (priv->restart_ms * HZ) / 1000;
+		add_timer(&priv->restart_timer);
+	}
+}
+EXPORT_SYMBOL_GPL(can_bus_off);
+
+static void can_setup(struct net_device *dev)
+{
+	dev->type = ARPHRD_CAN;
+	dev->mtu = sizeof(struct can_frame);
+	dev->hard_header_len = 0;
+	dev->addr_len = 0;
+	dev->tx_queue_len = 10;
+
+	/* New-style flags. */
+	dev->flags = IFF_NOARP;
+	dev->features = NETIF_F_NO_CSUM;
+}
+
+/*
+ * Allocate and setup space for the CAN network device
+ */
+struct net_device *alloc_candev(int sizeof_priv)
+{
+	struct net_device *dev;
+	struct can_priv *priv;
+
+	dev = alloc_netdev(sizeof_priv, "can%d", can_setup);
+	if (!dev)
+		return NULL;
+
+	priv = netdev_priv(dev);
+
+	priv->state = CAN_STATE_STOPPED;
+
+	init_timer(&priv->restart_timer);
+
+	return dev;
+}
+EXPORT_SYMBOL_GPL(alloc_candev);
+
+/*
+ * Free space of the CAN network device
+ */
+void free_candev(struct net_device *dev)
+{
+	free_netdev(dev);
+}
+EXPORT_SYMBOL_GPL(free_candev);
+
+/*
+ * Common open function when the device gets opened.
+ *
+ * This function should be called in the open function of the device
+ * driver.
+ */
+int open_candev(struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+
+	if (!priv->bittiming.tq && !priv->bittiming.bitrate) {
+		dev_err(dev->dev.parent, "bit-timing not yet defined\n");
+		return -EINVAL;
+	}
+	return 0;
+}
+EXPORT_SYMBOL(open_candev);
+
+/*
+ * Common close function for cleanup before the device gets closed.
+ *
+ * This function should be called in the close function of the device
+ * driver.
+ */
+void close_candev(struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+
+	del_timer_sync(&priv->restart_timer);
+	can_flush_echo_skb(dev);
+}
+EXPORT_SYMBOL_GPL(close_candev);
+
+/*
+ * CAN netlink interface
+ */
+static const struct nla_policy can_policy[IFLA_CAN_MAX + 1] = {
+	[IFLA_CAN_STATE]	= { .type = NLA_U32 },
+	[IFLA_CAN_CTRLMODE]	= { .len = sizeof(struct can_ctrlmode) },
+	[IFLA_CAN_RESTART_MS]	= { .type = NLA_U32 },
+	[IFLA_CAN_RESTART]	= { .type = NLA_U32 },
+	[IFLA_CAN_BITTIMING]	= { .len = sizeof(struct can_bittiming) },
+	[IFLA_CAN_BITTIMING_CONST]
+				= { .len = sizeof(struct can_bittiming_const) },
+	[IFLA_CAN_CLOCK]	= { .len = sizeof(struct can_clock) },
+};
+
+static int can_changelink(struct net_device *dev,
+			  struct nlattr *tb[], struct nlattr *data[])
+{
+	struct can_priv *priv = netdev_priv(dev);
+	int err;
+
+	/* We need synchronization with dev->stop() */
+	ASSERT_RTNL();
+
+	if (data[IFLA_CAN_CTRLMODE]) {
+		struct can_ctrlmode *cm;
+
+		if (dev->flags & IFF_UP)
+			return -EBUSY;
+		cm = nla_data(data[IFLA_CAN_CTRLMODE]);
+		priv->ctrlmode &= ~cm->mask;
+		priv->ctrlmode |= cm->flags;
+		printk("ctrlmode %#x mask %#x flags %#x\n", priv->ctrlmode,
+		       cm->mask, cm->flags);
+	}
+
+	if (data[IFLA_CAN_BITTIMING]) {
+		struct can_bittiming bt;
+
+		if (dev->flags & IFF_UP)
+			return -EBUSY;
+		memcpy(&bt, nla_data(data[IFLA_CAN_BITTIMING]), sizeof(bt));
+		if ((!bt.bitrate && !bt.tq) || (bt.bitrate && bt.tq))
+			return -EINVAL;
+		err = can_get_bittiming(dev, &bt);
+		if (err)
+			return err;
+		memcpy(&priv->bittiming, &bt, sizeof(bt));
+
+		if (priv->do_set_bittiming) {
+			/* Finally, set the bit-timing registers */
+			err = priv->do_set_bittiming(dev);
+			if (err)
+				return err;
+		}
+	}
+
+	if (data[IFLA_CAN_RESTART_MS])
+		priv->restart_ms = nla_get_u32(data[IFLA_CAN_RESTART_MS]);
+
+	if (data[IFLA_CAN_RESTART]) {
+		if (!(dev->flags & IFF_UP))
+			return -EINVAL;
+		can_restart_now(dev);
+	}
+
+	return 0;
+}
+
+static int can_fill_info(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+	struct can_ctrlmode cm = {.flags = priv->ctrlmode};
+	enum can_state state = priv->state;
+
+	if (priv->do_get_state)
+		priv->do_get_state(dev, &state);
+	NLA_PUT_U32(skb, IFLA_CAN_STATE, state);
+	NLA_PUT(skb, IFLA_CAN_CTRLMODE, sizeof(cm), &cm);
+	NLA_PUT_U32(skb, IFLA_CAN_RESTART_MS, priv->restart_ms);
+	NLA_PUT(skb, IFLA_CAN_BITTIMING,
+		sizeof(priv->bittiming), &priv->bittiming);
+	NLA_PUT(skb, IFLA_CAN_CLOCK, sizeof(cm), &priv->clock);
+	if (priv->bittiming_const)
+		NLA_PUT(skb, IFLA_CAN_BITTIMING_CONST,
+			sizeof(*priv->bittiming_const), priv->bittiming_const);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static int can_fill_xstats(struct sk_buff *skb, const struct net_device *dev)
+{
+	struct can_priv *priv = netdev_priv(dev);
+
+	NLA_PUT(skb, IFLA_INFO_XSTATS,
+		sizeof(priv->can_stats), &priv->can_stats);
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static struct rtnl_link_ops can_link_ops __read_mostly = {
+	.kind		= "can",
+	.maxtype	= IFLA_CAN_MAX,
+	.policy		= can_policy,
+	.setup		= can_setup,
+	.changelink	= can_changelink,
+	.fill_info	= can_fill_info,
+	.fill_xstats	= can_fill_xstats,
+};
+
+/*
+ * Register the CAN network device
+ */
+int register_candev(struct net_device *dev)
+{
+	int err;
+
+	rtnl_lock();
+
+	err = __rtnl_link_register(&can_link_ops);
+	if (err)
+		goto out;
+
+	err = dev_alloc_name(dev, dev->name);
+	if (err >= 0) {
+		dev->rtnl_link_ops = &can_link_ops;
+		err = register_netdevice(dev);
+	}
+
+	if (err < 0)
+		__rtnl_link_unregister(&can_link_ops);
+out:
+	rtnl_unlock();
+
+	return err;
+}
+EXPORT_SYMBOL_GPL(register_candev);
+
+/*
+ * Unregister the CAN network device
+ */
+void unregister_candev(struct net_device *dev)
+{
+	rtnl_link_unregister(&can_link_ops);
+}
+EXPORT_SYMBOL_GPL(unregister_candev);
+
+static __init int can_dev_init(void)
+{
+	printk(KERN_INFO MOD_DESC "\n");
+
+	return 0;
+}
+module_init(can_dev_init);
+
+static __exit void can_dev_exit(void)
+{
+}
+module_exit(can_dev_exit);
+
+MODULE_ALIAS_RTNL_LINK("can");
Index: net-next-2.6/include/linux/can/dev.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-next-2.6/include/linux/can/dev.h	2009-05-12 10:47:25.077720929 +0200
@@ -0,0 +1,70 @@
+/*
+ * linux/can/dev.h
+ *
+ * Definitions for the CAN network device driver interface
+ *
+ * Copyright (C) 2006 Andrey Volkov <avolkov@varma-el.com>
+ *               Varma Electronics Oy
+ *
+ * Copyright (C) 2008 Wolfgang Grandegger <wg@grandegger.com>
+ *
+ * Send feedback to <socketcan-users@lists.berlios.de>
+ */
+
+#ifndef CAN_DEV_H
+#define CAN_DEV_H
+
+#include <linux/can/netlink.h>
+#include <linux/can/error.h>
+
+/*
+ * CAN mode
+ */
+enum can_mode {
+	CAN_MODE_STOP = 0,
+	CAN_MODE_START,
+	CAN_MODE_SLEEP
+};
+
+/*
+ * CAN common private data
+ */
+#define CAN_ECHO_SKB_MAX  4
+
+struct can_priv {
+	struct can_device_stats can_stats;
+
+	struct can_bittiming bittiming;
+	struct can_bittiming_const *bittiming_const;
+	struct can_clock clock;
+
+	enum can_state state;
+	u32 ctrlmode;
+
+	int restart_ms;
+	struct timer_list restart_timer;
+
+	struct sk_buff *echo_skb[CAN_ECHO_SKB_MAX];
+
+	int (*do_set_bittiming)(struct net_device *dev);
+	int (*do_set_mode)(struct net_device *dev, enum can_mode mode);
+	int (*do_get_state)(const struct net_device *dev,
+			    enum can_state *state);
+};
+
+struct net_device *alloc_candev(int sizeof_priv);
+void free_candev(struct net_device *dev);
+
+int open_candev(struct net_device *dev);
+void close_candev(struct net_device *dev);
+
+int register_candev(struct net_device *dev);
+void unregister_candev(struct net_device *dev);
+
+int can_restart_now(struct net_device *dev);
+void can_bus_off(struct net_device *dev);
+
+void can_put_echo_skb(struct sk_buff *skb, struct net_device *dev, int idx);
+void can_get_echo_skb(struct net_device *dev, int idx);
+
+#endif /* CAN_DEV_H */
Index: net-next-2.6/include/linux/can/netlink.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ net-next-2.6/include/linux/can/netlink.h	2009-05-12 10:47:25.079720376 +0200
@@ -0,0 +1,113 @@
+/*
+ * linux/can/netlink.h
+ *
+ * Definitions for the CAN netlink interface
+ *
+ * Copyright (c) 2009 Wolfgang Grandegger <wg@grandegger.com>
+ *
+ * Send feedback to <socketcan-users@lists.berlios.de>
+ *
+ */
+
+#ifndef CAN_NETLINK_H
+#define CAN_NETLINK_H
+
+#include <linux/types.h>
+
+/*
+ * CAN bit-timing parameters
+ *
+ * For futher information, please read chapter "8 BIT TIMING
+ * REQUIREMENTS" of the "Bosch CAN Specification version 2.0"
+ * at http://www.semiconductors.bosch.de/pdf/can2spec.pdf.
+ */
+struct can_bittiming {
+	__u32 bitrate;		/* Bit-rate in bits/second */
+	__u32 sample_point;	/* Sample point in one-tenth of a percent */
+	__u32 tq;		/* Time quanta (TQ) in nanoseconds */
+	__u32 prop_seg;		/* Propagation segment in TQs */
+	__u32 phase_seg1;	/* Phase buffer segment 1 in TQs */
+	__u32 phase_seg2;	/* Phase buffer segment 2 in TQs */
+	__u32 sjw;		/* Synchronisation jump width in TQs */
+	__u32 brp;		/* Bit-rate prescaler */
+};
+
+/*
+ * CAN harware-dependent bit-timing constant
+ *
+ * Used for calculating and checking bit-timing parameters
+ */
+struct can_bittiming_const {
+	char name[16];		/* Name of the CAN controller hardware */
+	__u32 tseg1_min;	/* Time segement 1 = prop_seg + phase_seg1 */
+	__u32 tseg1_max;
+	__u32 tseg2_min;	/* Time segement 2 = phase_seg2 */
+	__u32 tseg2_max;
+	__u32 sjw_max;		/* Synchronisation jump width */
+	__u32 brp_min;		/* Bit-rate prescaler */
+	__u32 brp_max;
+	__u32 brp_inc;
+};
+
+/*
+ * CAN clock parameters
+ */
+struct can_clock {
+	__u32 freq;		/* CAN system clock frequency in Hz */
+};
+
+/*
+ * CAN operational and error states
+ */
+enum can_state {
+	CAN_STATE_ERROR_ACTIVE = 0,	/* RX/TX error count < 96 */
+	CAN_STATE_ERROR_WARNING,	/* RX/TX error count < 128 */
+	CAN_STATE_ERROR_PASSIVE,	/* RX/TX error count < 256 */
+	CAN_STATE_BUS_OFF,		/* RX/TX error count >= 256 */
+	CAN_STATE_STOPPED,		/* Device is stopped */
+	CAN_STATE_SLEEPING,		/* Device is sleeping */
+	CAN_STATE_MAX
+};
+
+/*
+ * CAN controller mode
+ */
+struct can_ctrlmode {
+	__u32 mask;
+	__u32 flags;
+};
+
+#define CAN_CTRLMODE_LOOPBACK	0x1	/* Loopback mode */
+#define CAN_CTRLMODE_LISTENONLY	0x2 	/* Listen-only mode */
+#define CAN_CTRLMODE_3_SAMPLES	0x4	/* Triple sampling mode */
+
+/*
+ * CAN device statistics
+ */
+struct can_device_stats {
+	__u32 bus_error;	/* Bus errors */
+	__u32 error_warning;	/* Changes to error warning state */
+	__u32 error_passive;	/* Changes to error passive state */
+	__u32 bus_off;		/* Changes to bus off state */
+	__u32 arbitration_lost; /* Arbitration lost errors */
+	__u32 restarts;		/* CAN controller re-starts */
+};
+
+/*
+ * CAN netlink interface
+ */
+enum {
+	IFLA_CAN_UNSPEC,
+	IFLA_CAN_BITTIMING,
+	IFLA_CAN_BITTIMING_CONST,
+	IFLA_CAN_CLOCK,
+	IFLA_CAN_STATE,
+	IFLA_CAN_CTRLMODE,
+	IFLA_CAN_RESTART_MS,
+	IFLA_CAN_RESTART,
+	__IFLA_CAN_MAX
+};
+
+#define IFLA_CAN_MAX	(__IFLA_CAN_MAX - 1)
+
+#endif /* CAN_NETLINK_H */
Index: net-next-2.6/include/linux/can/Kbuild
===================================================================
--- net-next-2.6.orig/include/linux/can/Kbuild	2009-05-12 10:47:10.450720893 +0200
+++ net-next-2.6/include/linux/can/Kbuild	2009-05-12 10:47:25.082720803 +0200
@@ -1,3 +1,4 @@
 header-y += raw.h
 header-y += bcm.h
 header-y += error.h
+header-y += netlink.h


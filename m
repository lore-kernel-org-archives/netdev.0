From: "Luis R. Rodriguez" <mcgrof@bombadil.infradead.org>
Subject: [RFC/RFT v3]: compat-wireless for 2.6.32.5 - multiqueue backport
	support
Date: Fri, 22 Jan 2010 19:18:47 -0500
Message-ID: <20100123001847.GD8069@bombadil.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, lrodriguez@atheros.com
To: linux-wireless <linux-wireless@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:60696 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754884Ab0AWASs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jan 2010 19:18:48 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I've updated the tarball now for 2.6.32.5 along with the issue
Johannes spotted. The 2.6.32.5 kernel release has no wireless
driver updates though so just pegging this as 2.6.32.5-rc5.

Here is the tarball and sha1sum:

http://bombadil.infradead.org/~mcgrof/tmp/compat-wireless-2.6.32.5-rc3.tar.bz2

sha1sum: 
c32d63f55eee7d58370013347213087de47d3f06  compat-wireless-2.6.32.5-rc3.tar.bz2

Seems we now just need someone to just test this for 2.6.23.
2.6.23 support is only enabled when using:

./scripts/driver-select ath9k

But it should be easily to compile test with other PCI drivers.
The 2.6.22 port still needs some other work but I don't have
a need to go so far.

=== compat/patches/18-multiqueue.patch ====

Backport multiqueue support for kernels < 2.6.27

The 2.6.23 kernel added some initial multiqueue support.
That release relied on the on the notion of struct
net_device_subqueue attached to the netdevice struct
as an array. The 2.6.27 renamed these to struct netdev_queue,
and enhanced MQ support by providing locks separately onto
each queue. MQ support on 2.6.27 also extended each netdev
to be able to assign a select_queue callback to be used by
core networking for prior to pushing the skb out to the device
driver so that queue selection can be dealt with and
customized internally on the driver.

For kernels 2.6.23..2.6.26 then we backport MQ support by
using the equivalent calls on the struct netdev_queue to
the struct net_device_subqueue. The performance penalty
here is just that all these queues share a common lock
so stateful operations on one queue would imply a delay
on other queues.

For older kernels than 2.6.23 we can only stop all the
queues then and wake them up only if no other queue had
been stopped previously. This means for kernels older
than 2.6.23 there is a performance penalty and congestion
on one queue would imply propagating the same congestion
impact on all the other queues.

The select_queue callback was only added as of 2.6.27 via
commit eae792b7 so for kernels older than 2.6.23 and up
to 2.6.27 we must ensure we do the selection of the queue
once the core networking calls mac80211's dev_hard_start_xmit()
(ndo_start_xmit() callback on newer kernels).

This patch then consists of three parts:

  1) Addresses the lack of select_queue on older kernels than 2.6.27
  2) Extends the backport of net_device_ops for select_queue for kernels >= 2.6.27
  3) Backporting wake/stop queue for older kernels:
	- Handle with net_device_subqueue for >= 2.6.23
	- Treat each queue operation as an aggregate for all queues

Monitor interfaces have their own select_queue -- monitor interfaces
are used for injecting frames so they have their own respective queue
handling, but mac80211 just always sends management frames on VO
queue by using skb_set_queue_mapping(skb, 0) through ieee80211_tx_skb()

--- a/net/mac80211/util.c	2010-01-21 11:22:36.000000000 -0800
+++ b/net/mac80211/util.c	2010-01-21 11:34:13.000000000 -0800
@@ -267,6 +267,18 @@ __le16 ieee80211_ctstoself_duration(stru
 }
 EXPORT_SYMBOL(ieee80211_ctstoself_duration);
 
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,23))
+static bool ieee80211_all_queues_started(struct ieee80211_hw *hw)
+{
+	unsigned int queue;
+
+	for (queue = 0; queue < hw->queues; queue++)
+		if (ieee80211_queue_stopped(hw, queue))
+			return false;
+	return true;
+}
+#endif
+
 static void __ieee80211_wake_queue(struct ieee80211_hw *hw, int queue,
 				   enum queue_stop_reason reason)
 {
@@ -287,7 +299,14 @@ static void __ieee80211_wake_queue(struc
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &local->interfaces, list)
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27))
 		netif_tx_wake_queue(netdev_get_tx_queue(sdata->dev, queue));
+#elif (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,23))
+		netif_start_subqueue(sdata->dev, queue);
+#else
+		if (ieee80211_all_queues_started(hw))
+			netif_wake_queue(sdata->dev);
+#endif
 	rcu_read_unlock();
 }
 
@@ -322,7 +341,13 @@ static void __ieee80211_stop_queue(struc
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(sdata, &local->interfaces, list)
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27))
 		netif_tx_stop_queue(netdev_get_tx_queue(sdata->dev, queue));
+#elif (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,23))
+		netif_stop_subqueue(sdata->dev, queue);
+#else
+		netif_stop_queue(sdata->dev);
+#endif
 	rcu_read_unlock();
 }
 
--- a/net/mac80211/tx.c	2010-01-21 12:13:24.000000000 -0800
+++ b/net/mac80211/tx.c	2010-01-21 12:22:54.000000000 -0800
@@ -1484,6 +1484,10 @@ static void ieee80211_xmit(struct ieee80
 				return;
 			}
 
+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,6,27))
+	/* Older kernels do not have the select_queue callback */
+	skb_set_queue_mapping(skb, ieee80211_select_queue(sdata, skb));
+#endif
 	ieee80211_set_qos_hdr(local, skb);
 	ieee80211_tx(sdata, skb, false);
 	dev_put(sdata->dev);
--- a/net/mac80211/iface.c	2010-01-21 12:26:53.000000000 -0800
+++ b/net/mac80211/iface.c	2010-01-21 12:34:40.000000000 -0800
@@ -644,11 +644,13 @@ static void ieee80211_teardown_sdata(str
 	WARN_ON(flushed);
 }
 
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27))
 static u16 ieee80211_netdev_select_queue(struct net_device *dev,
 					 struct sk_buff *skb)
 {
 	return ieee80211_select_queue(IEEE80211_DEV_TO_SUB_IF(dev), skb);
 }
+#endif
 
 #if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,29))
 static const struct net_device_ops ieee80211_dataif_ops = {
@@ -662,6 +664,7 @@ static const struct net_device_ops ieee8
 	.ndo_select_queue	= ieee80211_netdev_select_queue,
 };
 
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27))
 static u16 ieee80211_monitor_select_queue(struct net_device *dev,
 					  struct sk_buff *skb)
 {
@@ -687,6 +690,7 @@ static u16 ieee80211_monitor_select_queu
 	skb->priority = 0;
 	return ieee80211_downgrade_queue(local, skb);
 }
+#endif
 
 static const struct net_device_ops ieee80211_monitorif_ops = {
 	.ndo_open		= ieee80211_open,
@@ -715,6 +719,9 @@ static void ieee80211_if_setup(struct ne
 	/* we will validate the address ourselves in ->open */
 	dev->validate_addr = NULL;
 #endif
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27))
+	dev->select_queue = ieee80211_netdev_select_queue;
+#endif
 #endif
 	dev->destructor = free_netdev;
 }
@@ -761,6 +768,9 @@ static void ieee80211_setup_sdata(struct
 		sdata->dev->netdev_ops = &ieee80211_monitorif_ops;
 #else
 		sdata->dev->hard_start_xmit = ieee80211_monitor_start_xmit;
+#if (LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,27))
+		sdata->dev->select_queue = ieee80211_monitor_select_queue;
+#endif
 #endif
 		sdata->u.mntr_flags = MONITOR_FLAG_CONTROL |
 				      MONITOR_FLAG_OTHER_BSS;

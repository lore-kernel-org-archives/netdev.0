From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 1/3] vlan: adds vlan_dev_select_queue
Date: Wed, 17 Feb 2010 04:36:08 -0800
Message-ID: <20100217123606.18210.13602.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Vasu Dev <vasu.dev@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:49844
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752609Ab0BQMg1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 07:36:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasu Dev <vasu.dev@intel.com>

This is required to correctly select vlan tx queue for a driver
supporting multi tx queue with ndo_select_queue implemented since
currently selected vlan tx queue is unaligned to selected queue by
ndo_select_queue.

Unaligned vlan tx queue causes thrash with higher vlan tx lock
contention for least fcoe traffic on ixgbe.

Added vlan_dev_select_queue adds only minimal required code from
dev_pick_tx and preserves queue selection for the case ndo_select_queue
is not implemented.

Also updates vlan real_num_tx_queues in case underlying device
queues has changed.

Signed-off-by: Vasu Dev <vasu.dev@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 net/8021q/vlan.c     |    1 +
 net/8021q/vlan_dev.c |   23 +++++++++++++++++++++++
 2 files changed, 24 insertions(+), 0 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 4535122..6c70805 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -378,6 +378,7 @@ static void vlan_transfer_features(struct net_device *dev,
 #if defined(CONFIG_FCOE) || defined(CONFIG_FCOE_MODULE)
 	vlandev->fcoe_ddp_xid = dev->fcoe_ddp_xid;
 #endif
+	vlandev->real_num_tx_queues = dev->real_num_tx_queues;
 
 	if (old_features != vlandev->features)
 		netdev_features_change(vlandev);
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 9e83272..7ec246f 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -26,6 +26,7 @@
 #include <linux/etherdevice.h>
 #include <linux/ethtool.h>
 #include <net/arp.h>
+#include <net/sock.h>
 
 #include "vlan.h"
 #include "vlanproc.h"
@@ -361,6 +362,26 @@ static netdev_tx_t vlan_dev_hwaccel_hard_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
+static u16 vlan_dev_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	struct vlan_dev_info *vlan = vlan_dev_info(dev);
+	const struct net_device_ops *ops = vlan->real_dev->netdev_ops;
+	u16 queue_index;
+
+	if (ops->ndo_select_queue)
+		queue_index = ops->ndo_select_queue(vlan->real_dev, skb);
+	else {
+		queue_index = 0;
+		if (dev->real_num_tx_queues > 1)
+			queue_index = skb_tx_hash(dev, skb);
+
+		if (skb->sk && skb->sk->sk_dst_cache)
+			sk_tx_queue_set(skb->sk, queue_index);
+	}
+
+	return queue_index;
+}
+
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
 	/* TODO: gotta make sure the underlying layer can handle it,
@@ -818,6 +839,7 @@ static const struct ethtool_ops vlan_ethtool_ops = {
 };
 
 static const struct net_device_ops vlan_netdev_ops = {
+	.ndo_select_queue	= vlan_dev_select_queue,
 	.ndo_change_mtu		= vlan_dev_change_mtu,
 	.ndo_init		= vlan_dev_init,
 	.ndo_uninit		= vlan_dev_uninit,
@@ -842,6 +864,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 };
 
 static const struct net_device_ops vlan_netdev_accel_ops = {
+	.ndo_select_queue	= vlan_dev_select_queue,
 	.ndo_change_mtu		= vlan_dev_change_mtu,
 	.ndo_init		= vlan_dev_init,
 	.ndo_uninit		= vlan_dev_uninit,


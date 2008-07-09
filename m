From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 02/08]: vlan: deliver packets received with VLAN acceleration to network taps
Date: Wed,  9 Jul 2008 14:09:48 +0200 (MEST)
Message-ID: <20080709120948.11669.98935.sendpatchset@localhost.localdomain>
References: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58615 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753324AbYGIMJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 08:09:49 -0400
In-Reply-To: <20080709120945.11669.42790.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vlan: deliver packets received with VLAN acceleration to network taps

When VLAN header stripping is used, packets currently bypass packet
sockets (and other network taps) completely. For locally existing
VLANs, they appear directly on the VLAN device, for unknown VLANs
they are silently dropped.

Add a new function netif_nit_deliver() to deliver incoming packets
to all network interface taps and use it in __vlan_hwaccel_rx() to
make VLAN packets visible on the underlying device.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 2150bca3247c0b497a83937005367092bca86530
tree 1a1c894d2d360dd2b90a759485ae0e2e0a441b41
parent 5188944208232be946dbfa41e4e81cd13a5cc63f
author Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 12:38:27 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 09 Jul 2008 12:38:27 +0200

 include/linux/netdevice.h |    1 +
 net/8021q/vlan_core.c     |    4 ++++
 net/core/dev.c            |   27 +++++++++++++++++++++++++++
 3 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 203c550..85c5db8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1152,6 +1152,7 @@ extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
+extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 68df12d..916061f 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -14,6 +14,9 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		return NET_RX_DROP;
 	}
 
+	skb->vlan_tci = vlan_tci;
+	netif_nit_deliver(skb);
+
 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
 	if (skb->dev == NULL) {
 		dev_kfree_skb_any(skb);
@@ -22,6 +25,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
 		return NET_RX_SUCCESS;
 	}
 	skb->dev->last_rx = jiffies;
+	skb->vlan_tci = 0;
 
 	stats = &skb->dev->stats;
 	stats->rx_packets++;
diff --git a/net/core/dev.c b/net/core/dev.c
index a29a359..c3bec22 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2068,6 +2068,33 @@ out:
 }
 #endif
 
+/*
+ * 	netif_tap_deliver - deliver received packets to network taps
+ * 	@skb: buffer
+ *
+ * 	This function is used to deliver incoming packets to network
+ * 	taps. It should be used when the normal netif_receive_skb path
+ * 	is bypassed, for example because of VLAN acceleration.
+ */
+void netif_nit_deliver(struct sk_buff *skb)
+{
+	struct packet_type *ptype;
+
+	if (list_empty(&ptype_all))
+		return;
+
+	skb_reset_network_header(skb);
+	skb_reset_transport_header(skb);
+	skb->mac_len = skb->network_header - skb->mac_header;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(ptype, &ptype_all, list) {
+		if (!ptype->dev || ptype->dev == skb->dev)
+			deliver_skb(skb, ptype, skb->dev);
+	}
+	rcu_read_unlock();
+}
+
 /**
  *	netif_receive_skb - process receive buffer from network
  *	@skb: buffer to process

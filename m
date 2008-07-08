From: Patrick McHardy <kaber@trash.net>
Subject: [RFC PATCH 02/04]: vlan: deliver packets received with VLAN acceleration
 to network taps
Date: Tue, 08 Jul 2008 12:16:03 +0200
Message-ID: <48733E63.1010809@trash.net>
References: <48733E1B.8010501@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040503040208050305090307"
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54898 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753615AbYGHKQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 06:16:06 -0400
Received: from [192.168.0.100] (unknown [78.42.204.165])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by stinky.trash.net (Postfix) with ESMTP id 202CC948DD
	for <netdev@vger.kernel.org>; Tue,  8 Jul 2008 12:16:05 +0200 (MEST)
In-Reply-To: <48733E1B.8010501@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040503040208050305090307
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------040503040208050305090307
Content-Type: text/x-diff;
 name="02.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02.diff"

commit d6e43bdeb617ea0885d682f52dad1e4f05e1cc39
Author: Patrick McHardy <kaber@trash.net>
Date:   Tue Jul 8 11:38:43 2008 +0200

    vlan: deliver packets received with VLAN acceleration to network taps
    
    When VLAN header stripping is used, packets currently bypass packet
    sockets (and other network taps) completely. For locally existing
    VLANs, they appear directly on the VLAN device, for unknown VLANs
    they are silently dropped.
    
    Add a new function netif_nit_deliver() to deliver incoming packets
    to all network interface taps and use it in __vlan_hwaccel_rx() to
    make VLAN packets visible on the underlying device.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e009c6f..d0469eb 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1145,6 +1145,7 @@ extern int		netif_rx(struct sk_buff *skb);
 extern int		netif_rx_ni(struct sk_buff *skb);
 #define HAVE_NETIF_RECEIVE_SKB 1
 extern int		netif_receive_skb(struct sk_buff *skb);
+extern void		netif_nit_deliver(struct sk_buff *skb);
 extern int		dev_valid_name(const char *name);
 extern int		dev_ioctl(struct net *net, unsigned int cmd, void __user *);
 extern int		dev_ethtool(struct net *net, struct ifreq *);
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 2bec74c..9a66e80 100644
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
index 7593393..96f1528 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2060,6 +2060,33 @@ out:
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

--------------040503040208050305090307--

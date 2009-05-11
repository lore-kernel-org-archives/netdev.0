From: Cyrill Gorcunov <gorcunov@openvz.org>
Subject: [RFC 5/5] net: bridge - handle via_phys_dev feature on a bridge level
Date: Mon, 11 May 2009 15:46:44 +0400
Message-ID: <20090511125351.432336750@openvz.org>
References: <20090511114639.440944109@openvz.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, xemul@openvz.org,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.229]:29916 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757760AbZEKMyB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 May 2009 08:54:01 -0400
Received: by rv-out-0506.google.com with SMTP id f9so2140702rvb.1
        for <netdev@vger.kernel.org>; Mon, 11 May 2009 05:54:02 -0700 (PDT)
Content-Disposition: inline; filename=net-br-via-func
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The idea is to use existing routing table instead of
generating new one if the bridge is to be created.

This allow to login on remote machine then create bridge
there and continue working on this machine without
session interrupted (though delay while bridge is learning
still present).

To achive this we introduce via_phys_dev feature which
force to work some real NIC as bridge.

How to use it:
 - Create a new bridge set via_phys_dev in sysfs entry for the bridge
 - Add a bridge port. This port will behave like it's a bridge
   itself, i.e. a packet recieved from network will be handled the same
   way if it was received by bridge device. Any write on this
   device from OS behaves like it is being written to bridge device
   itself too.

Typical session looks like

| ssh@10.10.0.160$ brctl addbr br0
| ssh@10.10.0.160$ ifconfig br0 up
| ssh@10.10.0.160$ echo 1 > /sys/class/net/bridge/br0/via_phys_dev
| ssh@10.10.0.160$ brctl addif br0 eth0
| (...waiting a bit...)
| ssh@10.10.0.160$

Which implies that eth0 is already up and running.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 net/bridge/br.c         |    2 ++
 net/bridge/br_device.c  |   37 +++++++++++++++++++++++++++++++++++++
 net/bridge/br_forward.c |    1 +
 net/bridge/br_input.c   |   14 +++++++++++++-
 net/bridge/br_private.h |    1 +
 5 files changed, 54 insertions(+), 1 deletion(-)

Index: linux-2.6.git/net/bridge/br.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br.c
+++ linux-2.6.git/net/bridge/br.c
@@ -64,6 +64,7 @@ static int __init br_init(void)
 
 	brioctl_set(br_ioctl_deviceless_stub);
 	br_handle_frame_hook = br_handle_frame;
+	br_hard_xmit_hook = br_hard_xmit;
 
 	br_fdb_get_hook = br_fdb_get;
 	br_fdb_put_hook = br_fdb_put;
@@ -99,6 +100,7 @@ static void __exit br_deinit(void)
 	br_fdb_put_hook = NULL;
 
 	br_handle_frame_hook = NULL;
+	br_hard_xmit_hook = NULL;
 	br_fdb_fini();
 }
 
Index: linux-2.6.git/net/bridge/br_device.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_device.c
+++ linux-2.6.git/net/bridge/br_device.c
@@ -32,6 +32,8 @@ int br_dev_xmit(struct sk_buff *skb, str
 	skb_reset_mac_header(skb);
 	skb_pull(skb, ETH_HLEN);
 
+	skb->br_seen = 1;
+
 	if (is_multicast_ether_addr(dest))
 		br_flood_deliver(br, skb);
 	else if ((dst = __br_fdb_get(br, dest)) != NULL)
@@ -42,6 +44,41 @@ int br_dev_xmit(struct sk_buff *skb, str
 	return 0;
 }
 
+int br_hard_xmit(struct sk_buff *skb, struct net_bridge_port *port)
+{
+	struct net_bridge *br = port->br;
+	const unsigned char *dest = skb->data;
+	struct net_bridge_fdb_entry *dst;
+	struct sk_buff *skb2;
+
+	/* forward via master device only */
+	if (!br->via_phys_dev || br->master_dev != port->dev)
+		return 0;
+
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+	if (!skb2) {
+		br->dev->stats.tx_dropped++;
+		return 0;
+	}
+
+	br->dev->stats.tx_packets++;
+	br->dev->stats.tx_bytes += skb->len;
+
+	skb_reset_mac_header(skb2);
+	skb_pull(skb2, ETH_HLEN);
+
+	skb->br_seen = 1;
+
+	if (is_multicast_ether_addr(dest))
+		br_flood_deliver(br, skb2);
+	else if ((dst = __br_fdb_get(br, dest)) != NULL)
+		br_deliver(dst->dst, skb2);
+	else
+		br_flood_deliver(br, skb2);
+
+	return 0;
+}
+
 static int br_dev_open(struct net_device *dev)
 {
 	struct net_bridge *br = netdev_priv(dev);
Index: linux-2.6.git/net/bridge/br_forward.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_forward.c
+++ linux-2.6.git/net/bridge/br_forward.c
@@ -148,5 +148,6 @@ void br_flood_deliver(struct net_bridge 
 /* called under bridge lock */
 void br_flood_forward(struct net_bridge *br, struct sk_buff *skb)
 {
+	skb->br_seen = 1;
 	br_flood(br, skb, __br_forward);
 }
Index: linux-2.6.git/net/bridge/br_input.c
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_input.c
+++ linux-2.6.git/net/bridge/br_input.c
@@ -28,7 +28,15 @@ static void br_pass_frame_up(struct net_
 	brdev->stats.rx_bytes += skb->len;
 
 	indev = skb->dev;
-	skb->dev = brdev;
+
+	if (br->via_phys_dev) {
+		skb->br_seen = 1;
+		if (likely(br->master_dev))
+			skb->dev = br->master_dev;
+		else
+			skb->dev = brdev;
+	} else
+		skb->dev = brdev;
 
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL,
 		netif_receive_skb);
@@ -151,6 +159,10 @@ struct sk_buff *br_handle_frame(struct n
 		}
 		/* fall through */
 	case BR_STATE_LEARNING:
+		/* if we saw this skb earlier just pass it up */
+		if (skb->br_seen)
+			return skb;
+
 		if (!compare_ether_addr(p->br->dev->dev_addr, dest))
 			skb->pkt_type = PACKET_HOST;
 
Index: linux-2.6.git/net/bridge/br_private.h
=====================================================================
--- linux-2.6.git.orig/net/bridge/br_private.h
+++ linux-2.6.git/net/bridge/br_private.h
@@ -144,6 +144,7 @@ static inline int br_is_root_bridge(cons
 /* br_device.c */
 extern void br_dev_setup(struct net_device *dev);
 extern int br_dev_xmit(struct sk_buff *skb, struct net_device *dev);
+extern int br_hard_xmit(struct sk_buff *skb, struct net_bridge_port *port);
 
 /* br_fdb.c */
 extern int br_fdb_init(void);


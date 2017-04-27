From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 6/9] ipvlan: reposition three functions
Date: Thu, 27 Apr 2017 15:51:39 +0100
Message-ID: <20170427145142.15830-7-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:44550 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S937363AbdD0Owq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:46 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move ipvlan_multicast_enqueue, ipvlan_skb_crossing_ns and
ipvlan_mac_hash close to their related siblings.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 80 ++++++++++++++++++++--------------------
 1 file changed, 40 insertions(+), 40 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 54c4e85..81dc3e5 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -88,6 +88,14 @@ void ipvlan_ht_addr_del(struct ipvl_addr *addr)
 	hlist_del_init_rcu(&addr->hlnode);
 }
 
+unsigned int ipvlan_mac_hash(const unsigned char *addr)
+{
+	u32 hash = jhash_1word(__get_unaligned_cpu32(addr + 2),
+			       ipvlan_jhash_secret);
+
+	return hash & IPVLAN_MAC_FILTER_MASK;
+}
+
 struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
 				   const void *iaddr, bool is_v6)
 {
@@ -195,12 +203,16 @@ static inline struct ipvl_addr *ipvlan_get_slave_addr_dst(struct sk_buff *skb,
 	return ipvlan_get_slave_addr(skb, port, true);
 }
 
-unsigned int ipvlan_mac_hash(const unsigned char *addr)
+static void ipvlan_skb_crossing_ns(struct sk_buff *skb, struct net_device *dev)
 {
-	u32 hash = jhash_1word(__get_unaligned_cpu32(addr + 2),
-			       ipvlan_jhash_secret);
+	bool xnet = true;
 
-	return hash & IPVLAN_MAC_FILTER_MASK;
+	if (dev)
+		xnet = !net_eq(dev_net(skb->dev), dev_net(dev));
+
+	skb_scrub_packet(skb, xnet);
+	if (dev)
+		skb->dev = dev;
 }
 
 static void ipvlan_dispatch_multicast(struct ipvl_port *port,
@@ -286,16 +298,33 @@ void ipvlan_process_multicast(struct work_struct *work)
 	}
 }
 
-static void ipvlan_skb_crossing_ns(struct sk_buff *skb, struct net_device *dev)
+static void ipvlan_multicast_enqueue(struct ipvl_port *port,
+				     struct sk_buff *skb, bool tx_pkt)
 {
-	bool xnet = true;
+	if (skb->protocol == htons(ETH_P_PAUSE)) {
+		kfree_skb(skb);
+		return;
+	}
 
-	if (dev)
-		xnet = !net_eq(dev_net(skb->dev), dev_net(dev));
+	/* Record that the deferred packet is from TX or RX path. By
+	 * looking at mac-addresses on packet will lead to erronus decisions.
+	 * (This would be true for a loopback-mode on master device or a
+	 * hair-pin mode of the switch.)
+	 */
+	IPVL_SKB_CB(skb)->tx_pkt = tx_pkt;
 
-	skb_scrub_packet(skb, xnet);
-	if (dev)
-		skb->dev = dev;
+	spin_lock(&port->backlog.lock);
+	if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
+		if (skb->dev)
+			dev_hold(skb->dev);
+		__skb_queue_tail(&port->backlog, skb);
+		spin_unlock(&port->backlog.lock);
+		schedule_work(&port->wq);
+	} else {
+		spin_unlock(&port->backlog.lock);
+		atomic_long_inc(&skb->dev->rx_dropped);
+		kfree_skb(skb);
+	}
 }
 
 static int ipvlan_rcv_int_frame(struct ipvl_addr *addr, struct sk_buff **pskb)
@@ -440,35 +469,6 @@ static int ipvlan_process_l3_outbound(struct sk_buff *skb)
 	return ret;
 }
 
-static void ipvlan_multicast_enqueue(struct ipvl_port *port,
-				     struct sk_buff *skb, bool tx_pkt)
-{
-	if (skb->protocol == htons(ETH_P_PAUSE)) {
-		kfree_skb(skb);
-		return;
-	}
-
-	/* Record that the deferred packet is from TX or RX path. By
-	 * looking at mac-addresses on packet will lead to erronus decisions.
-	 * (This would be true for a loopback-mode on master device or a
-	 * hair-pin mode of the switch.)
-	 */
-	IPVL_SKB_CB(skb)->tx_pkt = tx_pkt;
-
-	spin_lock(&port->backlog.lock);
-	if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
-		if (skb->dev)
-			dev_hold(skb->dev);
-		__skb_queue_tail(&port->backlog, skb);
-		spin_unlock(&port->backlog.lock);
-		schedule_work(&port->wq);
-	} else {
-		spin_unlock(&port->backlog.lock);
-		atomic_long_inc(&skb->dev->rx_dropped);
-		kfree_skb(skb);
-	}
-}
-
 static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
-- 
2.9.3

--------------------------------------------------------------
Intel Research and Development Ireland Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263


This e-mail and any attachments may contain confidential material for the sole
use of the intended recipient(s). Any review or distribution by others is
strictly prohibited. If you are not the intended recipient, please contact the
sender and delete all copies.

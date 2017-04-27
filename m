From: Marco Chiappero <marco.chiappero@intel.com>
Subject: [PATCH net-next 2/9] ipvlan: refactor ipvlan_process_multicast for readability
Date: Thu, 27 Apr 2017 15:51:35 +0100
Message-ID: <20170427145142.15830-3-marco.chiappero@intel.com>
References: <20170427145142.15830-1-marco.chiappero@intel.com>
Cc: "David S . Miller" <davem@davemloft.net>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Marco Chiappero <marco.chiappero@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:49079 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755630AbdD0Owg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 10:52:36 -0400
In-Reply-To: <20170427145142.15830-1-marco.chiappero@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function ipvlan_process_multicast both dequeues and dispatches
packets from/to ipvlan slaves. Decouple these two steps by introducing
ipvlan_dispatch_multicast, in order to reduce indentation and improve
the overall readability.

Signed-off-by: Marco Chiappero <marco.chiappero@intel.com>
Tested-by: Marco Chiappero <marco.chiappero@intel.com>
---
 drivers/net/ipvlan/ipvlan_core.c | 107 +++++++++++++++++++++------------------
 1 file changed, 57 insertions(+), 50 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index 1266f01..fd40c25 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -185,18 +185,69 @@ unsigned int ipvlan_mac_hash(const unsigned char *addr)
 	return hash & IPVLAN_MAC_FILTER_MASK;
 }
 
+static void ipvlan_dispatch_multicast(struct ipvl_port *port,
+				      struct sk_buff *skb, u8 pkt_type,
+				      unsigned int mac_hash)
+{
+	struct ipvl_dev *ipvlan;
+	struct sk_buff *nskb;
+	struct net_device *dev = skb->dev;
+	bool tx_pkt = IPVL_SKB_CB(skb)->tx_pkt;
+	bool consumed = false;
+	unsigned int len;
+	int ret;
+
+	/* dispatch to slaves */
+	rcu_read_lock();
+	list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
+		if (tx_pkt && (ipvlan->dev == skb->dev))
+			continue;
+		if (!test_bit(mac_hash, ipvlan->mac_filters))
+			continue;
+		if (!(ipvlan->dev->flags & IFF_UP))
+			continue;
+		ret = NET_RX_DROP;
+		len = skb->len + ETH_HLEN;
+		nskb = skb_clone(skb, GFP_ATOMIC);
+		local_bh_disable();
+		if (nskb) {
+			consumed = true;
+			nskb->pkt_type = pkt_type;
+			nskb->dev = ipvlan->dev;
+			if (tx_pkt)
+				ret = dev_forward_skb(ipvlan->dev, nskb);
+			else
+				ret = netif_rx(nskb);
+		}
+		ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
+		local_bh_enable();
+	}
+	rcu_read_unlock();
+
+	if (tx_pkt) {
+		/* If the packet originated here, send it out. */
+		skb->dev = port->dev;
+		skb->pkt_type = pkt_type;
+		dev_queue_xmit(skb);
+	} else {
+		if (consumed)
+			consume_skb(skb);
+		else
+			kfree_skb(skb);
+	}
+
+	if (dev)
+		dev_put(dev);
+}
+
 void ipvlan_process_multicast(struct work_struct *work)
 {
 	struct ipvl_port *port = container_of(work, struct ipvl_port, wq);
 	struct ethhdr *ethh;
-	struct ipvl_dev *ipvlan;
-	struct sk_buff *skb, *nskb;
+	struct sk_buff *skb;
 	struct sk_buff_head list;
-	unsigned int len;
 	unsigned int mac_hash;
-	int ret;
 	u8 pkt_type;
-	bool tx_pkt;
 
 	__skb_queue_head_init(&list);
 
@@ -205,11 +256,7 @@ void ipvlan_process_multicast(struct work_struct *work)
 	spin_unlock_bh(&port->backlog.lock);
 
 	while ((skb = __skb_dequeue(&list)) != NULL) {
-		struct net_device *dev = skb->dev;
-		bool consumed = false;
-
 		ethh = eth_hdr(skb);
-		tx_pkt = IPVL_SKB_CB(skb)->tx_pkt;
 		mac_hash = ipvlan_mac_hash(ethh->h_dest);
 
 		if (ether_addr_equal(ethh->h_dest, port->dev->broadcast))
@@ -217,47 +264,7 @@ void ipvlan_process_multicast(struct work_struct *work)
 		else
 			pkt_type = PACKET_MULTICAST;
 
-		rcu_read_lock();
-		list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
-			if (tx_pkt && (ipvlan->dev == skb->dev))
-				continue;
-			if (!test_bit(mac_hash, ipvlan->mac_filters))
-				continue;
-			if (!(ipvlan->dev->flags & IFF_UP))
-				continue;
-			ret = NET_RX_DROP;
-			len = skb->len + ETH_HLEN;
-			nskb = skb_clone(skb, GFP_ATOMIC);
-			local_bh_disable();
-			if (nskb) {
-				consumed = true;
-				nskb->pkt_type = pkt_type;
-				nskb->dev = ipvlan->dev;
-				if (tx_pkt)
-					ret = dev_forward_skb(ipvlan->dev,
-							      nskb);
-				else
-					ret = netif_rx(nskb);
-			}
-			ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS,
-					true);
-			local_bh_enable();
-		}
-		rcu_read_unlock();
-
-		if (tx_pkt) {
-			/* If the packet originated here, send it out. */
-			skb->dev = port->dev;
-			skb->pkt_type = pkt_type;
-			dev_queue_xmit(skb);
-		} else {
-			if (consumed)
-				consume_skb(skb);
-			else
-				kfree_skb(skb);
-		}
-		if (dev)
-			dev_put(dev);
+		ipvlan_dispatch_multicast(port, skb, pkt_type, mac_hash);
 	}
 }
 
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

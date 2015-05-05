From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH next v3 1/2] ipvlan: Defer multicast / broadcast processing to a work-queue
Date: Mon,  4 May 2015 17:06:03 -0700
Message-ID: <1430784363-2109-1-git-send-email-maheshb@google.com>
Cc: Dan Willems <dcbw@redhat.com>, David Miller <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>, Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f201.google.com ([209.85.223.201]:33129 "EHLO
	mail-ie0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750990AbbEEAID (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 20:08:03 -0400
Received: by iebtr6 with SMTP id tr6so12863524ieb.0
        for <netdev@vger.kernel.org>; Mon, 04 May 2015 17:08:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Processing multicast / broadcast in fast path is performance draining
and having more links means more cloning and bringing performance
down further.

Broadcast; in particular, need to be given to all the virtual links.
Earlier tricks of enabling broadcast bit for IPv4 only interfaces are not
really working since it fails autoconf. Which means enabling broadcast
for all the links if protocol specific hacks do not have to be added into
the driver.

This patch defers all (incoming as well as outgoing) multicast traffic to
a work-queue leaving only the unicast traffic in the fast-path. Now if we
need to apply any additional tricks to further reduce the impact of this
(multicast / broadcast) type of traffic, it can be implemented while
processing this work without affecting the fast-path.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/ipvlan/ipvlan.h      |   5 ++
 drivers/net/ipvlan/ipvlan_core.c | 138 ++++++++++++++++++++++++---------------
 drivers/net/ipvlan/ipvlan_main.c |   5 ++
 3 files changed, 96 insertions(+), 52 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
index 54549a6223dd..953a97492fab 100644
--- a/drivers/net/ipvlan/ipvlan.h
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -39,6 +39,8 @@
 #define IPVLAN_MAC_FILTER_SIZE	(1 << IPVLAN_MAC_FILTER_BITS)
 #define IPVLAN_MAC_FILTER_MASK	(IPVLAN_MAC_FILTER_SIZE - 1)
 
+#define IPVLAN_QBACKLOG_LIMIT	1000
+
 typedef enum {
 	IPVL_IPV6 = 0,
 	IPVL_ICMPV6,
@@ -93,6 +95,8 @@ struct ipvl_port {
 	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
 	struct list_head	ipvlans;
 	struct rcu_head		rcu;
+	struct work_struct	wq;
+	struct sk_buff_head	backlog;
 	int			count;
 	u16			mode;
 };
@@ -112,6 +116,7 @@ void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval);
 void ipvlan_init_secret(void);
 unsigned int ipvlan_mac_hash(const unsigned char *addr);
 rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
+void ipvlan_process_multicast(struct work_struct *work);
 int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev);
 void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *addr);
 struct ipvl_addr *ipvlan_find_addr(const struct ipvl_dev *ipvlan,
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index c30b5c300c05..8afbedad620d 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -189,62 +189,69 @@ unsigned int ipvlan_mac_hash(const unsigned char *addr)
 	return hash & IPVLAN_MAC_FILTER_MASK;
 }
 
-static void ipvlan_multicast_frame(struct ipvl_port *port, struct sk_buff *skb,
-				   const struct ipvl_dev *in_dev, bool local)
+void ipvlan_process_multicast(struct work_struct *work)
 {
-	struct ethhdr *eth = eth_hdr(skb);
+	struct ipvl_port *port = container_of(work, struct ipvl_port, wq);
+	struct ethhdr *ethh;
 	struct ipvl_dev *ipvlan;
-	struct sk_buff *nskb;
+	struct sk_buff *skb, *nskb;
+	struct sk_buff_head list;
 	unsigned int len;
 	unsigned int mac_hash;
 	int ret;
+	u8 pkt_type;
+	bool hlocal, dlocal;
 
-	if (skb->protocol == htons(ETH_P_PAUSE))
-		return;
-
-	rcu_read_lock();
-	list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
-		if (local && (ipvlan == in_dev))
-			continue;
+	__skb_queue_head_init(&list);
 
-		mac_hash = ipvlan_mac_hash(eth->h_dest);
-		if (!test_bit(mac_hash, ipvlan->mac_filters))
-			continue;
+	spin_lock_bh(&port->backlog.lock);
+	skb_queue_splice_tail_init(&port->backlog, &list);
+	spin_unlock_bh(&port->backlog.lock);
 
-		ret = NET_RX_DROP;
-		len = skb->len + ETH_HLEN;
-		nskb = skb_clone(skb, GFP_ATOMIC);
-		if (!nskb)
-			goto mcast_acct;
+	while ((skb = __skb_dequeue(&list)) != NULL) {
+		ethh = eth_hdr(skb);
+		hlocal = ether_addr_equal(ethh->h_source, port->dev->dev_addr);
+		mac_hash = ipvlan_mac_hash(ethh->h_dest);
 
-		if (ether_addr_equal(eth->h_dest, ipvlan->phy_dev->broadcast))
-			nskb->pkt_type = PACKET_BROADCAST;
+		if (ether_addr_equal(ethh->h_dest, port->dev->broadcast))
+			pkt_type = PACKET_BROADCAST;
 		else
-			nskb->pkt_type = PACKET_MULTICAST;
-
-		nskb->dev = ipvlan->dev;
-		if (local)
-			ret = dev_forward_skb(ipvlan->dev, nskb);
-		else
-			ret = netif_rx(nskb);
-mcast_acct:
-		ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
-	}
-	rcu_read_unlock();
-
-	/* Locally generated? ...Forward a copy to the main-device as
-	 * well. On the RX side we'll ignore it (wont give it to any
-	 * of the virtual devices.
-	 */
-	if (local) {
-		nskb = skb_clone(skb, GFP_ATOMIC);
-		if (nskb) {
-			if (ether_addr_equal(eth->h_dest, port->dev->broadcast))
-				nskb->pkt_type = PACKET_BROADCAST;
+			pkt_type = PACKET_MULTICAST;
+
+		dlocal = false;
+		rcu_read_lock();
+		list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
+			if (hlocal && (ipvlan->dev == skb->dev)) {
+				dlocal = true;
+				continue;
+			}
+			if (!test_bit(mac_hash, ipvlan->mac_filters))
+				continue;
+
+			ret = NET_RX_DROP;
+			len = skb->len + ETH_HLEN;
+			nskb = skb_clone(skb, GFP_ATOMIC);
+			if (!nskb)
+				goto acct;
+
+			nskb->pkt_type = pkt_type;
+			nskb->dev = ipvlan->dev;
+			if (hlocal)
+				ret = dev_forward_skb(ipvlan->dev, nskb);
 			else
-				nskb->pkt_type = PACKET_MULTICAST;
-
-			dev_forward_skb(port->dev, nskb);
+				ret = netif_rx(nskb);
+acct:
+			ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
+		}
+		rcu_read_unlock();
+
+		if (dlocal) {
+			/* If the packet originated here, send it out. */
+			skb->dev = port->dev;
+			skb->pkt_type = pkt_type;
+			dev_queue_xmit(skb);
+		} else {
+			kfree_skb(skb);
 		}
 	}
 }
@@ -446,6 +453,26 @@ out:
 	return ret;
 }
 
+static void ipvlan_multicast_enqueue(struct ipvl_port *port,
+				     struct sk_buff *skb)
+{
+	if (skb->protocol == htons(ETH_P_PAUSE)) {
+		kfree_skb(skb);
+		return;
+	}
+
+	spin_lock(&port->backlog.lock);
+	if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
+		__skb_queue_tail(&port->backlog, skb);
+		spin_unlock(&port->backlog.lock);
+		schedule_work(&port->wq);
+	} else {
+		spin_unlock(&port->backlog.lock);
+		atomic_long_inc(&skb->dev->rx_dropped);
+		kfree_skb(skb);
+	}
+}
+
 static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device *dev)
 {
 	const struct ipvl_dev *ipvlan = netdev_priv(dev);
@@ -493,11 +520,8 @@ static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device *dev)
 		return dev_forward_skb(ipvlan->phy_dev, skb);
 
 	} else if (is_multicast_ether_addr(eth->h_dest)) {
-		u8 ip_summed = skb->ip_summed;
-
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
-		ipvlan_multicast_frame(ipvlan->port, skb, ipvlan, true);
-		skb->ip_summed = ip_summed;
+		ipvlan_multicast_enqueue(ipvlan->port, skb);
+		return NET_XMIT_SUCCESS;
 	}
 
 	skb->dev = ipvlan->phy_dev;
@@ -581,8 +605,18 @@ static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb,
 	int addr_type;
 
 	if (is_multicast_ether_addr(eth->h_dest)) {
-		if (ipvlan_external_frame(skb, port))
-			ipvlan_multicast_frame(port, skb, NULL, false);
+		if (ipvlan_external_frame(skb, port)) {
+			struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
+
+			/* External frames are queued for device local
+			 * distribution, but a copy is given to master
+			 * straight away to avoid sending duplicates later
+			 * when work-queue processes this frame. This is
+			 * achieved by returning RX_HANDLER_PASS.
+			 */
+			if (nskb)
+				ipvlan_multicast_enqueue(port, nskb);
+		}
 	} else {
 		struct ipvl_addr *addr;
 
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 77b92a0fe557..a16d3017fdc3 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -54,6 +54,9 @@ static int ipvlan_port_create(struct net_device *dev)
 	for (idx = 0; idx < IPVLAN_HASH_SIZE; idx++)
 		INIT_HLIST_HEAD(&port->hlhead[idx]);
 
+	skb_queue_head_init(&port->backlog);
+	INIT_WORK(&port->wq, ipvlan_process_multicast);
+
 	err = netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
 	if (err)
 		goto err;
@@ -72,6 +75,8 @@ static void ipvlan_port_destroy(struct net_device *dev)
 
 	dev->priv_flags &= ~IFF_IPVLAN_MASTER;
 	netdev_rx_handler_unregister(dev);
+	cancel_work_sync(&port->wq);
+	__skb_queue_purge(&port->backlog);
 	kfree_rcu(port, rcu);
 }
 
-- 
2.2.0.rc0.207.ga3a616c

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] ipvlan: fix various issues in
 ipvlan_process_multicast()
Date: Wed, 21 Dec 2016 18:00:24 -0800
Message-ID: <1482372024.8944.79.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1482355800.8944.75.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <maheshb@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33018 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934992AbcLVCA2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 21:00:28 -0500
Received: by mail-pg0-f68.google.com with SMTP id g1so16446017pgn.0
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2016 18:00:27 -0800 (PST)
In-Reply-To: <1482355800.8944.75.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) netif_rx() / dev_forward_skb() should not be called from process
context.

2) ipvlan_count_rx() should be called with preemption disabled.

3) We should check if ipvlan->dev is up before feeding packets
to netif_rx()

4) We need to prevent device from disappearing if some packets
are in the multicast backlog.

5) One kfree_skb() should be a consume_skb() eventually

Fixes: ba35f8588f47 ("ipvlan: Defer multicast / broadcast processing to
a work-queue")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Mahesh Bandewar <maheshb@google.com>
---
v2: did the correct purge in ipvlan_port_destroy()

 drivers/net/ipvlan/ipvlan_core.c |   38 +++++++++++++++++++----------
 drivers/net/ipvlan/ipvlan_main.c |    7 ++++-
 2 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvlan_core.c
index b4e990743e1da0cb3a946f5473d02cce7447bd1a..ea6bc1e12cdf6827a69d8d54d96b4b59106ede96 100644
--- a/drivers/net/ipvlan/ipvlan_core.c
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -207,6 +207,9 @@ void ipvlan_process_multicast(struct work_struct *work)
 	spin_unlock_bh(&port->backlog.lock);
 
 	while ((skb = __skb_dequeue(&list)) != NULL) {
+		struct net_device *dev = skb->dev;
+		bool consumed = false;
+
 		ethh = eth_hdr(skb);
 		hlocal = ether_addr_equal(ethh->h_source, port->dev->dev_addr);
 		mac_hash = ipvlan_mac_hash(ethh->h_dest);
@@ -219,27 +222,29 @@ void ipvlan_process_multicast(struct work_struct *work)
 		dlocal = false;
 		rcu_read_lock();
 		list_for_each_entry_rcu(ipvlan, &port->ipvlans, pnode) {
-			if (hlocal && (ipvlan->dev == skb->dev)) {
+			if (hlocal && (ipvlan->dev == dev)) {
 				dlocal = true;
 				continue;
 			}
 			if (!test_bit(mac_hash, ipvlan->mac_filters))
 				continue;
-
+			if (!(ipvlan->dev->flags & IFF_UP))
+				continue;
 			ret = NET_RX_DROP;
 			len = skb->len + ETH_HLEN;
 			nskb = skb_clone(skb, GFP_ATOMIC);
-			if (!nskb)
-				goto acct;
-
-			nskb->pkt_type = pkt_type;
-			nskb->dev = ipvlan->dev;
-			if (hlocal)
-				ret = dev_forward_skb(ipvlan->dev, nskb);
-			else
-				ret = netif_rx(nskb);
-acct:
+			local_bh_disable();
+			if (nskb) {
+				consumed = true;
+				nskb->pkt_type = pkt_type;
+				nskb->dev = ipvlan->dev;
+				if (hlocal)
+					ret = dev_forward_skb(ipvlan->dev, nskb);
+				else
+					ret = netif_rx(nskb);
+			}
 			ipvlan_count_rx(ipvlan, len, ret == NET_RX_SUCCESS, true);
+			local_bh_enable();
 		}
 		rcu_read_unlock();
 
@@ -249,8 +254,13 @@ void ipvlan_process_multicast(struct work_struct *work)
 			skb->pkt_type = pkt_type;
 			dev_queue_xmit(skb);
 		} else {
-			kfree_skb(skb);
+			if (consumed)
+				consume_skb(skb);
+			else
+				kfree_skb(skb);
 		}
+		if (dev)
+			dev_put(dev);
 	}
 }
 
@@ -479,6 +489,8 @@ static void ipvlan_multicast_enqueue(struct ipvl_port *port,
 
 	spin_lock(&port->backlog.lock);
 	if (skb_queue_len(&port->backlog) < IPVLAN_QBACKLOG_LIMIT) {
+		if (skb->dev)
+			dev_hold(skb->dev);
 		__skb_queue_tail(&port->backlog, skb);
 		spin_unlock(&port->backlog.lock);
 		schedule_work(&port->wq);
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvlan_main.c
index 693ec5b6622233cd3a28c64c11d6abb97585318b..8b0f99300cbc97d8c8b93c3dfa99cd841914c086 100644
--- a/drivers/net/ipvlan/ipvlan_main.c
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -135,6 +135,7 @@ static int ipvlan_port_create(struct net_device *dev)
 static void ipvlan_port_destroy(struct net_device *dev)
 {
 	struct ipvl_port *port = ipvlan_port_get_rtnl(dev);
+	struct sk_buff *skb;
 
 	dev->priv_flags &= ~IFF_IPVLAN_MASTER;
 	if (port->mode == IPVLAN_MODE_L3S) {
@@ -144,7 +145,11 @@ static void ipvlan_port_destroy(struct net_device *dev)
 	}
 	netdev_rx_handler_unregister(dev);
 	cancel_work_sync(&port->wq);
-	__skb_queue_purge(&port->backlog);
+	while ((skb = __skb_dequeue(&port->backlog)) != NULL) {
+		if (skb->dev)
+			dev_put(skb->dev);
+		kfree_skb(skb);
+	}
 	kfree(port);
 }
 

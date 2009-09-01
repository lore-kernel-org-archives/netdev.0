From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] macvlan: Use compare_ether_addr_64bits()
Date: Tue, 01 Sep 2009 17:46:05 +0200
Message-ID: <4A9D41BD.9000406@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:60566 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751687AbZIAPqG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 11:46:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To speedup ether addresses compares, we can use compare_ether_addr_64bits()
(all operands are guaranteed to be at least 8 bytes long)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 99eed9f..1978452 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -54,7 +54,7 @@ static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 	struct hlist_node *n;
 
 	hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[addr[5]], hlist) {
-		if (!compare_ether_addr(vlan->dev->dev_addr, addr))
+		if (!compare_ether_addr_64bits(vlan->dev->dev_addr, addr))
 			return vlan;
 	}
 	return NULL;
@@ -92,7 +92,7 @@ static int macvlan_addr_busy(const struct macvlan_port *port,
 	 * currently in use by the underlying device or
 	 * another macvlan.
 	 */
-	if (memcmp(port->dev->dev_addr, addr, ETH_ALEN) == 0)
+	if (!compare_ether_addr_64bits(port->dev->dev_addr, addr))
 		return 1;
 
 	if (macvlan_hash_lookup(port, addr))
@@ -130,7 +130,7 @@ static void macvlan_broadcast(struct sk_buff *skb,
 			dev->stats.multicast++;
 
 			nskb->dev = dev;
-			if (!compare_ether_addr(eth->h_dest, dev->broadcast))
+			if (!compare_ether_addr_64bits(eth->h_dest, dev->broadcast))
 				nskb->pkt_type = PACKET_BROADCAST;
 			else
 				nskb->pkt_type = PACKET_MULTICAST;

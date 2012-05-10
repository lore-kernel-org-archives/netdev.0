From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] net,drivers/net: Convert compare_ether_addr_64bits to ether_addr_equal_64bits
Date: Wed,  9 May 2012 20:04:04 -0700
Message-ID: <acb363688c8ed729cc61e288605cdb4aa4089149.1336618708.git.joe@perches.com>
References: <cover.1336618707.git.joe@perches.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1336618707.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Use the new bool function ether_addr_equal_64bits to add
some clarity and reduce the likelihood for misuse of
compare_ether_addr_64bits for sorting.

Done via cocci script:

$ cat compare_ether_addr_64bits.cocci
@@
expression a,b;
@@
-	!compare_ether_addr_64bits(a, b)
+	ether_addr_equal_64bits(a, b)

@@
expression a,b;
@@
-	compare_ether_addr_64bits(a, b)
+	!ether_addr_equal_64bits(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal_64bits(a, b) == 0
+	ether_addr_equal_64bits(a, b)

@@
expression a,b;
@@
-	!ether_addr_equal_64bits(a, b) != 0
+	!ether_addr_equal_64bits(a, b)

@@
expression a,b;
@@
-	ether_addr_equal_64bits(a, b) == 0
+	!ether_addr_equal_64bits(a, b)

@@
expression a,b;
@@
-	ether_addr_equal_64bits(a, b) != 0
+	ether_addr_equal_64bits(a, b)

@@
expression a,b;
@@
-	!!ether_addr_equal_64bits(a, b)
+	ether_addr_equal_64bits(a, b)

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/bonding/bond_alb.c |   58 ++++++++++++++++++++--------------------
 drivers/net/macvlan.c          |    7 ++---
 net/ethernet/eth.c             |    5 ++-
 3 files changed, 35 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9abfde4..b4f1b4a 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -332,7 +332,7 @@ static void rlb_update_entry_from_arp(struct bonding *bond, struct arp_pkt *arp)
 	if ((client_info->assigned) &&
 	    (client_info->ip_src == arp->ip_dst) &&
 	    (client_info->ip_dst == arp->ip_src) &&
-	    (compare_ether_addr_64bits(client_info->mac_dst, arp->mac_src))) {
+	    (!ether_addr_equal_64bits(client_info->mac_dst, arp->mac_src))) {
 		/* update the clients MAC address */
 		memcpy(client_info->mac_dst, arp->mac_src, ETH_ALEN);
 		client_info->ntt = 1;
@@ -448,8 +448,8 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 			if (assigned_slave) {
 				rx_hash_table[index].slave = assigned_slave;
-				if (compare_ether_addr_64bits(rx_hash_table[index].mac_dst,
-							      mac_bcast)) {
+				if (!ether_addr_equal_64bits(rx_hash_table[index].mac_dst,
+							     mac_bcast)) {
 					bond_info->rx_hashtbl[index].ntt = 1;
 					bond_info->rx_ntt = 1;
 					/* A slave has been removed from the
@@ -561,7 +561,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if ((client_info->slave == slave) &&
-		    compare_ether_addr_64bits(client_info->mac_dst, mac_bcast)) {
+		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast)) {
 			client_info->ntt = 1;
 			ntt = 1;
 		}
@@ -600,9 +600,9 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		 * unicast mac address.
 		 */
 		if ((client_info->ip_src == src_ip) &&
-		    compare_ether_addr_64bits(client_info->slave->dev->dev_addr,
-			   bond->dev->dev_addr) &&
-		    compare_ether_addr_64bits(client_info->mac_dst, mac_bcast)) {
+		    !ether_addr_equal_64bits(client_info->slave->dev->dev_addr,
+					     bond->dev->dev_addr) &&
+		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast)) {
 			client_info->ntt = 1;
 			bond_info->rx_ntt = 1;
 		}
@@ -629,7 +629,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		if ((client_info->ip_src == arp->ip_src) &&
 		    (client_info->ip_dst == arp->ip_dst)) {
 			/* the entry is already assigned to this client */
-			if (compare_ether_addr_64bits(arp->mac_dst, mac_bcast)) {
+			if (!ether_addr_equal_64bits(arp->mac_dst, mac_bcast)) {
 				/* update mac address from arp */
 				memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
 			}
@@ -664,7 +664,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
 		client_info->slave = assigned_slave;
 
-		if (compare_ether_addr_64bits(client_info->mac_dst, mac_bcast)) {
+		if (!ether_addr_equal_64bits(client_info->mac_dst, mac_bcast)) {
 			client_info->ntt = 1;
 			bond->alb_info.rx_ntt = 1;
 		} else {
@@ -1009,18 +1009,18 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
 	int perm_curr_diff;
 	int perm_bond_diff;
 
-	perm_curr_diff = compare_ether_addr_64bits(slave->perm_hwaddr,
-						   slave->dev->dev_addr);
-	perm_bond_diff = compare_ether_addr_64bits(slave->perm_hwaddr,
-						   bond->dev->dev_addr);
+	perm_curr_diff = !ether_addr_equal_64bits(slave->perm_hwaddr,
+						  slave->dev->dev_addr);
+	perm_bond_diff = !ether_addr_equal_64bits(slave->perm_hwaddr,
+						  bond->dev->dev_addr);
 
 	if (perm_curr_diff && perm_bond_diff) {
 		struct slave *tmp_slave;
 		int i, found = 0;
 
 		bond_for_each_slave(bond, tmp_slave, i) {
-			if (!compare_ether_addr_64bits(slave->perm_hwaddr,
-						       tmp_slave->dev->dev_addr)) {
+			if (ether_addr_equal_64bits(slave->perm_hwaddr,
+						    tmp_slave->dev->dev_addr)) {
 				found = 1;
 				break;
 			}
@@ -1074,10 +1074,10 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	 * check uniqueness of slave's mac address against the other
 	 * slaves in the bond.
 	 */
-	if (compare_ether_addr_64bits(slave->perm_hwaddr, bond->dev->dev_addr)) {
+	if (!ether_addr_equal_64bits(slave->perm_hwaddr, bond->dev->dev_addr)) {
 		bond_for_each_slave(bond, tmp_slave1, i) {
-			if (!compare_ether_addr_64bits(tmp_slave1->dev->dev_addr,
-						       slave->dev->dev_addr)) {
+			if (ether_addr_equal_64bits(tmp_slave1->dev->dev_addr,
+						    slave->dev->dev_addr)) {
 				found = 1;
 				break;
 			}
@@ -1099,8 +1099,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	bond_for_each_slave(bond, tmp_slave1, i) {
 		found = 0;
 		bond_for_each_slave(bond, tmp_slave2, j) {
-			if (!compare_ether_addr_64bits(tmp_slave1->perm_hwaddr,
-						       tmp_slave2->dev->dev_addr)) {
+			if (ether_addr_equal_64bits(tmp_slave1->perm_hwaddr,
+						    tmp_slave2->dev->dev_addr)) {
 				found = 1;
 				break;
 			}
@@ -1115,8 +1115,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 		}
 
 		if (!has_bond_addr) {
-			if (!compare_ether_addr_64bits(tmp_slave1->dev->dev_addr,
-						       bond->dev->dev_addr)) {
+			if (ether_addr_equal_64bits(tmp_slave1->dev->dev_addr,
+						    bond->dev->dev_addr)) {
 
 				has_bond_addr = tmp_slave1;
 			}
@@ -1257,7 +1257,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	case ETH_P_IP: {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if (!compare_ether_addr_64bits(eth_data->h_dest, mac_bcast) ||
+		if (ether_addr_equal_64bits(eth_data->h_dest, mac_bcast) ||
 		    (iph->daddr == ip_bcast) ||
 		    (iph->protocol == IPPROTO_IGMP)) {
 			do_tx_balance = 0;
@@ -1271,7 +1271,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		/* IPv6 doesn't really use broadcast mac address, but leave
 		 * that here just in case.
 		 */
-		if (!compare_ether_addr_64bits(eth_data->h_dest, mac_bcast)) {
+		if (ether_addr_equal_64bits(eth_data->h_dest, mac_bcast)) {
 			do_tx_balance = 0;
 			break;
 		}
@@ -1279,7 +1279,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		/* IPv6 uses all-nodes multicast as an equivalent to
 		 * broadcasts in IPv4.
 		 */
-		if (!compare_ether_addr_64bits(eth_data->h_dest, mac_v6_allmcast)) {
+		if (ether_addr_equal_64bits(eth_data->h_dest, mac_v6_allmcast)) {
 			do_tx_balance = 0;
 			break;
 		}
@@ -1603,8 +1603,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		struct slave *tmp_slave;
 		/* find slave that is holding the bond's mac address */
 		bond_for_each_slave(bond, tmp_slave, i) {
-			if (!compare_ether_addr_64bits(tmp_slave->dev->dev_addr,
-						       bond->dev->dev_addr)) {
+			if (ether_addr_equal_64bits(tmp_slave->dev->dev_addr,
+						    bond->dev->dev_addr)) {
 				swap_slave = tmp_slave;
 				break;
 			}
@@ -1681,8 +1681,8 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	swap_slave = NULL;
 
 	bond_for_each_slave(bond, slave, i) {
-		if (!compare_ether_addr_64bits(slave->dev->dev_addr,
-					       bond_dev->dev_addr)) {
+		if (ether_addr_equal_64bits(slave->dev->dev_addr,
+					    bond_dev->dev_addr)) {
 			swap_slave = slave;
 			break;
 		}
diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 9653ed6..ebacec1 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -57,7 +57,7 @@ static struct macvlan_dev *macvlan_hash_lookup(const struct macvlan_port *port,
 	struct hlist_node *n;
 
 	hlist_for_each_entry_rcu(vlan, n, &port->vlan_hash[addr[5]], hlist) {
-		if (!compare_ether_addr_64bits(vlan->dev->dev_addr, addr))
+		if (ether_addr_equal_64bits(vlan->dev->dev_addr, addr))
 			return vlan;
 	}
 	return NULL;
@@ -96,7 +96,7 @@ static int macvlan_addr_busy(const struct macvlan_port *port,
 	 * currently in use by the underlying device or
 	 * another macvlan.
 	 */
-	if (!compare_ether_addr_64bits(port->dev->dev_addr, addr))
+	if (ether_addr_equal_64bits(port->dev->dev_addr, addr))
 		return 1;
 
 	if (macvlan_hash_lookup(port, addr))
@@ -118,8 +118,7 @@ static int macvlan_broadcast_one(struct sk_buff *skb,
 		return vlan->forward(dev, skb);
 
 	skb->dev = dev;
-	if (!compare_ether_addr_64bits(eth->h_dest,
-				       dev->broadcast))
+	if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
 		skb->pkt_type = PACKET_BROADCAST;
 	else
 		skb->pkt_type = PACKET_MULTICAST;
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 5889a6c..36e5880 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -164,7 +164,7 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	eth = eth_hdr(skb);
 
 	if (unlikely(is_multicast_ether_addr(eth->h_dest))) {
-		if (!compare_ether_addr_64bits(eth->h_dest, dev->broadcast))
+		if (ether_addr_equal_64bits(eth->h_dest, dev->broadcast))
 			skb->pkt_type = PACKET_BROADCAST;
 		else
 			skb->pkt_type = PACKET_MULTICAST;
@@ -179,7 +179,8 @@ __be16 eth_type_trans(struct sk_buff *skb, struct net_device *dev)
 	 */
 
 	else if (1 /*dev->flags&IFF_PROMISC */ ) {
-		if (unlikely(compare_ether_addr_64bits(eth->h_dest, dev->dev_addr)))
+		if (unlikely(!ether_addr_equal_64bits(eth->h_dest,
+						      dev->dev_addr)))
 			skb->pkt_type = PACKET_OTHERHOST;
 	}
 
-- 
1.7.8.111.gad25c.dirty

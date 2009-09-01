From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] bonding: use compare_ether_addr_64bits() in
 ALB
Date: Tue, 01 Sep 2009 18:31:18 +0200
Message-ID: <4A9D4C56.1090804@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58911 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951AbZIAQbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2009 12:31:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We can speedup ether addresses compares using compare_ether_addr_64bits()
instead of memcmp(). We make sure all operands are at least 8 bytes long and
16bits aligned (or better, long word aligned if possible)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 drivers/net/bonding/bond_alb.c |   71 ++++++++++++++++---------------
 drivers/net/bonding/bonding.h  |    2
 2 files changed, 38 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 2108706..9b5936f 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -79,8 +79,15 @@
  */
 #define RLB_PROMISC_TIMEOUT	10*ALB_TIMER_TICKS_PER_SEC
 
-static const u8 mac_bcast[ETH_ALEN] = {0xff,0xff,0xff,0xff,0xff,0xff};
-static const u8 mac_v6_allmcast[ETH_ALEN] = {0x33,0x33,0x00,0x00,0x00,0x01};
+#ifndef __long_aligned
+#define __long_aligned __attribute__((aligned((sizeof(long)))))
+#endif
+static const u8 mac_bcast[ETH_ALEN] __long_aligned = {
+	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
+};
+static const u8 mac_v6_allmcast[ETH_ALEN] __long_aligned = {
+	0x33, 0x33, 0x00, 0x00, 0x00, 0x01
+};
 static const int alb_delta_in_ticks = HZ / ALB_TIMER_TICKS_PER_SEC;
 
 #pragma pack(1)
@@ -460,8 +467,8 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 			if (assigned_slave) {
 				rx_hash_table[index].slave = assigned_slave;
-				if (memcmp(rx_hash_table[index].mac_dst,
-					   mac_bcast, ETH_ALEN)) {
+				if (compare_ether_addr_64bits(rx_hash_table[index].mac_dst,
+							      mac_bcast)) {
 					bond_info->rx_hashtbl[index].ntt = 1;
 					bond_info->rx_ntt = 1;
 					/* A slave has been removed from the
@@ -575,7 +582,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if ((client_info->slave == slave) &&
-		    memcmp(client_info->mac_dst, mac_bcast, ETH_ALEN)) {
+		    compare_ether_addr_64bits(client_info->mac_dst, mac_bcast)) {
 			client_info->ntt = 1;
 			ntt = 1;
 		}
@@ -616,9 +623,9 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		 * unicast mac address.
 		 */
 		if ((client_info->ip_src == src_ip) &&
-		    memcmp(client_info->slave->dev->dev_addr,
-			   bond->dev->dev_addr, ETH_ALEN) &&
-		    memcmp(client_info->mac_dst, mac_bcast, ETH_ALEN)) {
+		    compare_ether_addr_64bits(client_info->slave->dev->dev_addr,
+			   bond->dev->dev_addr) &&
+		    compare_ether_addr_64bits(client_info->mac_dst, mac_bcast)) {
 			client_info->ntt = 1;
 			bond_info->rx_ntt = 1;
 		}
@@ -645,7 +652,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		if ((client_info->ip_src == arp->ip_src) &&
 		    (client_info->ip_dst == arp->ip_dst)) {
 			/* the entry is already assigned to this client */
-			if (memcmp(arp->mac_dst, mac_bcast, ETH_ALEN)) {
+			if (compare_ether_addr_64bits(arp->mac_dst, mac_bcast)) {
 				/* update mac address from arp */
 				memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
 			}
@@ -680,7 +687,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		memcpy(client_info->mac_dst, arp->mac_dst, ETH_ALEN);
 		client_info->slave = assigned_slave;
 
-		if (memcmp(client_info->mac_dst, mac_bcast, ETH_ALEN)) {
+		if (compare_ether_addr_64bits(client_info->mac_dst, mac_bcast)) {
 			client_info->ntt = 1;
 			bond->alb_info.rx_ntt = 1;
 		} else {
@@ -1046,21 +1053,18 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
 	int perm_curr_diff;
 	int perm_bond_diff;
 
-	perm_curr_diff = memcmp(slave->perm_hwaddr,
-				slave->dev->dev_addr,
-				ETH_ALEN);
-	perm_bond_diff = memcmp(slave->perm_hwaddr,
-				bond->dev->dev_addr,
-				ETH_ALEN);
+	perm_curr_diff = compare_ether_addr_64bits(slave->perm_hwaddr,
+						   slave->dev->dev_addr);
+	perm_bond_diff = compare_ether_addr_64bits(slave->perm_hwaddr,
+						   bond->dev->dev_addr);
 
 	if (perm_curr_diff && perm_bond_diff) {
 		struct slave *tmp_slave;
 		int i, found = 0;
 
 		bond_for_each_slave(bond, tmp_slave, i) {
-			if (!memcmp(slave->perm_hwaddr,
-				    tmp_slave->dev->dev_addr,
-				    ETH_ALEN)) {
+			if (!compare_ether_addr_64bits(slave->perm_hwaddr,
+						       tmp_slave->dev->dev_addr)) {
 				found = 1;
 				break;
 			}
@@ -1114,10 +1118,10 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	 * check uniqueness of slave's mac address against the other
 	 * slaves in the bond.
 	 */
-	if (memcmp(slave->perm_hwaddr, bond->dev->dev_addr, ETH_ALEN)) {
+	if (compare_ether_addr_64bits(slave->perm_hwaddr, bond->dev->dev_addr)) {
 		bond_for_each_slave(bond, tmp_slave1, i) {
-			if (!memcmp(tmp_slave1->dev->dev_addr, slave->dev->dev_addr,
-				    ETH_ALEN)) {
+			if (!compare_ether_addr_64bits(tmp_slave1->dev->dev_addr,
+						       slave->dev->dev_addr)) {
 				found = 1;
 				break;
 			}
@@ -1140,9 +1144,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	bond_for_each_slave(bond, tmp_slave1, i) {
 		found = 0;
 		bond_for_each_slave(bond, tmp_slave2, j) {
-			if (!memcmp(tmp_slave1->perm_hwaddr,
-				    tmp_slave2->dev->dev_addr,
-				    ETH_ALEN)) {
+			if (!compare_ether_addr_64bits(tmp_slave1->perm_hwaddr,
+						       tmp_slave2->dev->dev_addr)) {
 				found = 1;
 				break;
 			}
@@ -1157,9 +1160,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 		}
 
 		if (!has_bond_addr) {
-			if (!memcmp(tmp_slave1->dev->dev_addr,
-				    bond->dev->dev_addr,
-				    ETH_ALEN)) {
+			if (!compare_ether_addr_64bits(tmp_slave1->dev->dev_addr,
+						       bond->dev->dev_addr)) {
 
 				has_bond_addr = tmp_slave1;
 			}
@@ -1313,7 +1315,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	case ETH_P_IP: {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if ((memcmp(eth_data->h_dest, mac_bcast, ETH_ALEN) == 0) ||
+		if (!compare_ether_addr_64bits(eth_data->h_dest, mac_bcast) ||
 		    (iph->daddr == ip_bcast) ||
 		    (iph->protocol == IPPROTO_IGMP)) {
 			do_tx_balance = 0;
@@ -1327,7 +1329,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		/* IPv6 doesn't really use broadcast mac address, but leave
 		 * that here just in case.
 		 */
-		if (memcmp(eth_data->h_dest, mac_bcast, ETH_ALEN) == 0) {
+		if (!compare_ether_addr_64bits(eth_data->h_dest, mac_bcast)) {
 			do_tx_balance = 0;
 			break;
 		}
@@ -1335,7 +1337,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		/* IPv6 uses all-nodes multicast as an equivalent to
 		 * broadcasts in IPv4.
 		 */
-		if (memcmp(eth_data->h_dest, mac_v6_allmcast, ETH_ALEN) == 0) {
+		if (!compare_ether_addr_64bits(eth_data->h_dest, mac_v6_allmcast)) {
 			do_tx_balance = 0;
 			break;
 		}
@@ -1660,8 +1662,8 @@ void bond_alb_handle_active_change(struct bonding *bond, struct slave *new_slave
 		struct slave *tmp_slave;
 		/* find slave that is holding the bond's mac address */
 		bond_for_each_slave(bond, tmp_slave, i) {
-			if (!memcmp(tmp_slave->dev->dev_addr,
-				    bond->dev->dev_addr, ETH_ALEN)) {
+			if (!compare_ether_addr_64bits(tmp_slave->dev->dev_addr,
+						       bond->dev->dev_addr)) {
 				swap_slave = tmp_slave;
 				break;
 			}
@@ -1739,7 +1741,8 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	swap_slave = NULL;
 
 	bond_for_each_slave(bond, slave, i) {
-		if (!memcmp(slave->dev->dev_addr, bond_dev->dev_addr, ETH_ALEN)) {
+		if (!compare_ether_addr_64bits(slave->dev->dev_addr,
+					       bond_dev->dev_addr)) {
 			swap_slave = slave;
 			break;
 		}
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 6290a50..6824771 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -163,9 +163,9 @@ struct slave {
 	u32    original_flags;
 	u32    original_mtu;
 	u32    link_failure_count;
+	u8     perm_hwaddr[ETH_ALEN];
 	u16    speed;
 	u8     duplex;
-	u8     perm_hwaddr[ETH_ALEN];
 	struct ad_slave_info ad_info; /* HUGE - better to dynamically alloc */
 	struct tlb_slave_info tlb_info;
 };

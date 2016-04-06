From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH 3/3] bonding: use common broadcast addr checks
Date: Wed,  6 Apr 2016 16:24:35 -0400
Message-ID: <1459974275-24944-3-git-send-email-dbanerje@akamai.com>
References: <1459974275-24944-1-git-send-email-dbanerje@akamai.com>
Cc: linux-kernel@vger.kernel.org,
	Debabrata Banerjee <dbanerje@akamai.com>
To: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1459974275-24944-1-git-send-email-dbanerje@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Replace homegrown broadcast checks with faster defs from etherdevice.h

Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index b7c7027..27238f3 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -45,9 +45,6 @@
 #ifndef __long_aligned
 #define __long_aligned __attribute__((aligned((sizeof(long)))))
 #endif
-static const u8 mac_bcast[ETH_ALEN] __long_aligned = {
-	0xff, 0xff, 0xff, 0xff, 0xff, 0xff
-};
 static const u8 mac_v6_allmcast[ETH_ALEN] __long_aligned = {
 	0x33, 0x33, 0x00, 0x00, 0x00, 0x01
 };
@@ -423,8 +420,8 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 			if (assigned_slave) {
 				rx_hash_table[index].slave = assigned_slave;
-				if (!ether_addr_equal_64bits(rx_hash_table[index].mac_dst,
-							     mac_bcast) &&
+
+				if (!is_broadcast_ether_addr(rx_hash_table[index].mac_dst) &&
 				    !is_zero_ether_addr(rx_hash_table[index].mac_dst)) {
 					bond_info->rx_hashtbl[index].ntt = 1;
 					bond_info->rx_ntt = 1;
@@ -528,7 +525,7 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if ((client_info->slave == slave) &&
-		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast) &&
+		    !is_broadcast_ether_addr(client_info->mac_dst) &&
 		    !is_zero_ether_addr(client_info->mac_dst)) {
 			client_info->ntt = 1;
 			ntt = 1;
@@ -570,7 +567,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		if ((client_info->ip_src == src_ip) &&
 		    !ether_addr_equal_64bits(client_info->slave->dev->dev_addr,
 					     bond->dev->dev_addr) &&
-		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast) &&
+		    !is_broadcast_ether_addr(client_info->mac_dst) &&
 		    !is_zero_ether_addr(client_info->mac_dst)) {
 			client_info->ntt = 1;
 			bond_info->rx_ntt = 1;
@@ -599,7 +596,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		if ((client_info->ip_src == arp->ip_src) &&
 		    (client_info->ip_dst == arp->ip_dst)) {
 			/* the entry is already assigned to this client */
-			if (!ether_addr_equal_64bits(arp->mac_dst, mac_bcast)) {
+			if (!is_broadcast_ether_addr(arp->mac_dst)) {
 				/* update mac address from arp */
 				ether_addr_copy(client_info->mac_dst, arp->mac_dst);
 			}
@@ -647,7 +644,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		ether_addr_copy(client_info->mac_src, arp->mac_src);
 		client_info->slave = assigned_slave;
 
-		if (!ether_addr_equal_64bits(client_info->mac_dst, mac_bcast) &&
+		if (!is_broadcast_ether_addr(client_info->mac_dst) &&
 		    !is_zero_ether_addr(client_info->mac_dst)) {
 			client_info->ntt = 1;
 			bond->alb_info.rx_ntt = 1;
@@ -1386,7 +1383,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	case ETH_P_IP: {
 		const struct iphdr *iph = ip_hdr(skb);
 
-		if (ether_addr_equal_64bits(eth_data->h_dest, mac_bcast) ||
+		if (is_broadcast_ether_addr(eth_data->h_dest) ||
 		    (iph->daddr == ip_bcast) ||
 		    (iph->protocol == IPPROTO_IGMP)) {
 			do_tx_balance = false;
@@ -1400,7 +1397,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		/* IPv6 doesn't really use broadcast mac address, but leave
 		 * that here just in case.
 		 */
-		if (ether_addr_equal_64bits(eth_data->h_dest, mac_bcast)) {
+		if (is_broadcast_ether_addr(eth_data->h_dest)) {
 			do_tx_balance = false;
 			break;
 		}
-- 
2.8.0

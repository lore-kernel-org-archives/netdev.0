From: Debabrata Banerjee <dbanerje@akamai.com>
Subject: [PATCH 2/3] bonding: don't request extraneous rlb updates
Date: Wed,  6 Apr 2016 16:24:34 -0400
Message-ID: <1459974275-24944-2-git-send-email-dbanerje@akamai.com>
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

Don't attempt to send rlb updates for incomplete entries, which can't be
sent anyway.

Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 1b45378..b7c7027 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -424,7 +424,8 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 			if (assigned_slave) {
 				rx_hash_table[index].slave = assigned_slave;
 				if (!ether_addr_equal_64bits(rx_hash_table[index].mac_dst,
-							     mac_bcast)) {
+							     mac_bcast) &&
+				    !is_zero_ether_addr(rx_hash_table[index].mac_dst)) {
 					bond_info->rx_hashtbl[index].ntt = 1;
 					bond_info->rx_ntt = 1;
 					/* A slave has been removed from the
@@ -527,7 +528,8 @@ static void rlb_req_update_slave_clients(struct bonding *bond, struct slave *sla
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if ((client_info->slave == slave) &&
-		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast)) {
+		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast) &&
+		    !is_zero_ether_addr(client_info->mac_dst)) {
 			client_info->ntt = 1;
 			ntt = 1;
 		}
@@ -568,7 +570,8 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		if ((client_info->ip_src == src_ip) &&
 		    !ether_addr_equal_64bits(client_info->slave->dev->dev_addr,
 					     bond->dev->dev_addr) &&
-		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast)) {
+		    !ether_addr_equal_64bits(client_info->mac_dst, mac_bcast) &&
+		    !is_zero_ether_addr(client_info->mac_dst)) {
 			client_info->ntt = 1;
 			bond_info->rx_ntt = 1;
 		}
@@ -644,7 +647,8 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		ether_addr_copy(client_info->mac_src, arp->mac_src);
 		client_info->slave = assigned_slave;
 
-		if (!ether_addr_equal_64bits(client_info->mac_dst, mac_bcast)) {
+		if (!ether_addr_equal_64bits(client_info->mac_dst, mac_bcast) &&
+		    !is_zero_ether_addr(client_info->mac_dst)) {
 			client_info->ntt = 1;
 			bond->alb_info.rx_ntt = 1;
 		} else {
@@ -735,8 +739,10 @@ static void rlb_rebalance(struct bonding *bond)
 		assigned_slave = __rlb_next_rx_slave(bond);
 		if (assigned_slave && (client_info->slave != assigned_slave)) {
 			client_info->slave = assigned_slave;
-			client_info->ntt = 1;
-			ntt = 1;
+			if (!is_zero_ether_addr(client_info->mac_dst)) {
+				client_info->ntt = 1;
+				ntt = 1;
+			}
 		}
 	}
 
-- 
2.8.0

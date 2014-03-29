From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH 2/5] bonding: Reorg bond_alb_xmit code
Date: Fri, 28 Mar 2014 22:29:01 -0700
Message-ID: <1396070941-17602-1-git-send-email-maheshb@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Mahesh Bandewar <maheshb@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:59096 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751113AbaC2F7l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Mar 2014 01:59:41 -0400
Received: by mail-vc0-f201.google.com with SMTP id ik5so827222vcb.0
        for <netdev@vger.kernel.org>; Fri, 28 Mar 2014 22:59:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Separating the actual xmit part from the function in a separate
function that can be used in the tlb_xmit in the next patch. Also
there is no reason do_tx_balance to be an int so changing it to
bool type.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 drivers/net/bonding/bond_alb.c | 79 +++++++++++++++++++++++-------------------
 1 file changed, 44 insertions(+), 35 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9f69e818b000..5cd36016c393 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1347,6 +1347,40 @@ void bond_alb_deinitialize(struct bonding *bond)
 		rlb_deinitialize(bond);
 }
 
+static int bond_do_alb_xmit(struct sk_buff *skb, struct bonding *bond,
+		struct slave *tx_slave)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct ethhdr *eth_data = eth_hdr(skb);
+
+	if (!tx_slave) {
+		/* unbalanced or unassigned, send through primary */
+		tx_slave = rcu_dereference(bond->curr_active_slave);
+		bond_info->unbalanced_load += skb->len;
+	}
+
+	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
+		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
+			ether_addr_copy(eth_data->h_source,
+					tx_slave->dev->dev_addr);
+		}
+
+		bond_dev_queue_xmit(bond, skb, tx_slave->dev);
+		goto out;
+	}
+
+	if (tx_slave) {
+		_lock_tx_hashtbl(bond);
+		__tlb_clear_slave(bond, tx_slave, 0);
+		_unlock_tx_hashtbl(bond);
+	}
+
+	/* no suitable interface, frame not sent */
+	dev_kfree_skb_any(skb);
+out:
+	return NETDEV_TX_OK;
+}
+
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -1355,7 +1389,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	struct slave *tx_slave = NULL;
 	static const __be32 ip_bcast = htonl(0xffffffff);
 	int hash_size = 0;
-	int do_tx_balance = 1;
+	bool do_tx_balance = true;
 	u32 hash_index = 0;
 	const u8 *hash_start = NULL;
 	struct ipv6hdr *ip6hdr;
@@ -1370,7 +1404,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		if (ether_addr_equal_64bits(eth_data->h_dest, mac_bcast) ||
 		    (iph->daddr == ip_bcast) ||
 		    (iph->protocol == IPPROTO_IGMP)) {
-			do_tx_balance = 0;
+			do_tx_balance = false;
 			break;
 		}
 		hash_start = (char *)&(iph->daddr);
@@ -1382,7 +1416,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		 * that here just in case.
 		 */
 		if (ether_addr_equal_64bits(eth_data->h_dest, mac_bcast)) {
-			do_tx_balance = 0;
+			do_tx_balance = false;
 			break;
 		}
 
@@ -1390,7 +1424,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		 * broadcasts in IPv4.
 		 */
 		if (ether_addr_equal_64bits(eth_data->h_dest, mac_v6_allmcast)) {
-			do_tx_balance = 0;
+			do_tx_balance = false;
 			break;
 		}
 
@@ -1400,7 +1434,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		 */
 		ip6hdr = ipv6_hdr(skb);
 		if (ipv6_addr_any(&ip6hdr->saddr)) {
-			do_tx_balance = 0;
+			do_tx_balance = false;
 			break;
 		}
 
@@ -1410,7 +1444,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 	case ETH_P_IPX:
 		if (ipx_hdr(skb)->ipx_checksum != IPX_NO_CHECKSUM) {
 			/* something is wrong with this packet */
-			do_tx_balance = 0;
+			do_tx_balance = false;
 			break;
 		}
 
@@ -1419,7 +1453,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 			 * this family since it has an "ARP" like
 			 * mechanism
 			 */
-			do_tx_balance = 0;
+			do_tx_balance = false;
 			break;
 		}
 
@@ -1427,12 +1461,12 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		hash_size = ETH_ALEN;
 		break;
 	case ETH_P_ARP:
-		do_tx_balance = 0;
+		do_tx_balance = false;
 		if (bond_info->rlb_enabled)
 			tx_slave = rlb_arp_xmit(skb, bond);
 		break;
 	default:
-		do_tx_balance = 0;
+		do_tx_balance = false;
 		break;
 	}
 
@@ -1441,32 +1475,7 @@ int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
 		tx_slave = tlb_choose_channel(bond, hash_index, skb->len);
 	}
 
-	if (!tx_slave) {
-		/* unbalanced or unassigned, send through primary */
-		tx_slave = rcu_dereference(bond->curr_active_slave);
-		bond_info->unbalanced_load += skb->len;
-	}
-
-	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
-		if (tx_slave != rcu_dereference(bond->curr_active_slave)) {
-			ether_addr_copy(eth_data->h_source,
-					tx_slave->dev->dev_addr);
-		}
-
-		bond_dev_queue_xmit(bond, skb, tx_slave->dev);
-		goto out;
-	}
-
-	if (tx_slave) {
-		_lock_tx_hashtbl(bond);
-		__tlb_clear_slave(bond, tx_slave, 0);
-		_unlock_tx_hashtbl(bond);
-	}
-
-	/* no suitable interface, frame not sent */
-	dev_kfree_skb_any(skb);
-out:
-	return NETDEV_TX_OK;
+	return bond_do_alb_xmit(skb, bond, tx_slave);
 }
 
 void bond_alb_monitor(struct work_struct *work)
-- 
1.9.1.423.g4596e3a

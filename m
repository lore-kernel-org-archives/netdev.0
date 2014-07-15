From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 05/12] bonding: convert bond_alb.c to use netdev_printk instead of pr_
Date: Tue, 15 Jul 2014 19:36:02 +0200
Message-ID: <1405445769-15394-6-git-send-email-vfalico@gmail.com>
References: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:25380 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756096AbaGORkn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:40:43 -0400
In-Reply-To: <1405445769-15394-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_alb.c | 34 +++++++++++++++-------------------
 1 file changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 76c0dad..ab0f7d2 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -369,7 +369,7 @@ static int rlb_arp_recv(const struct sk_buff *skb, struct bonding *bond,
 	if (arp->op_code == htons(ARPOP_REPLY)) {
 		/* update rx hash table for this ARP */
 		rlb_update_entry_from_arp(bond, arp);
-		pr_debug("Server received an ARP Reply from client\n");
+		netdev_dbg(bond->dev, "Server received an ARP Reply from client\n");
 	}
 out:
 	return RX_HANDLER_ANOTHER;
@@ -533,8 +533,8 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 				 client_info->slave->dev->dev_addr,
 				 client_info->mac_dst);
 		if (!skb) {
-			pr_err("%s: Error: failed to create an ARP packet\n",
-			       client_info->slave->bond->dev->name);
+			netdev_err(client_info->slave->bond->dev,
+				   "failed to create an ARP packet\n");
 			continue;
 		}
 
@@ -543,8 +543,8 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 		if (client_info->vlan_id) {
 			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), client_info->vlan_id);
 			if (!skb) {
-				pr_err("%s: Error: failed to insert VLAN tag\n",
-				       client_info->slave->bond->dev->name);
+				netdev_err(client_info->slave->bond->dev,
+					   "failed to insert VLAN tag\n");
 				continue;
 			}
 		}
@@ -628,8 +628,7 @@ static void rlb_req_update_subnet_clients(struct bonding *bond, __be32 src_ip)
 		client_info = &(bond_info->rx_hashtbl[hash_index]);
 
 		if (!client_info->slave) {
-			pr_err("%s: Error: found a client with no channel in the client's hash table\n",
-			       bond->dev->name);
+			netdev_err(bond->dev, "found a client with no channel in the client's hash table\n");
 			continue;
 		}
 		/*update all clients using this src_ip, that are not assigned
@@ -765,7 +764,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 		tx_slave = rlb_choose_channel(skb, bond);
 		if (tx_slave)
 			ether_addr_copy(arp->mac_src, tx_slave->dev->dev_addr);
-		pr_debug("Server sent ARP Reply packet\n");
+		netdev_dbg(bond->dev, "Server sent ARP Reply packet\n");
 	} else if (arp->op_code == htons(ARPOP_REQUEST)) {
 		/* Create an entry in the rx_hashtbl for this client as a
 		 * place holder.
@@ -785,7 +784,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 		 * updated with their assigned mac.
 		 */
 		rlb_req_update_subnet_clients(bond, arp->ip_src);
-		pr_debug("Server sent ARP Request packet\n");
+		netdev_dbg(bond->dev, "Server sent ARP Request packet\n");
 	}
 
 	return tx_slave;
@@ -1024,8 +1023,7 @@ static void alb_send_lp_vid(struct slave *slave, u8 mac_addr[],
 	if (vid) {
 		skb = vlan_put_tag(skb, vlan_proto, vid);
 		if (!skb) {
-			pr_err("%s: Error: failed to insert VLAN tag\n",
-			       slave->bond->dev->name);
+			netdev_err(slave->bond->dev, "failed to insert VLAN tag\n");
 			return;
 		}
 	}
@@ -1091,9 +1089,8 @@ static int alb_set_slave_mac_addr(struct slave *slave, u8 addr[])
 	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
 	if (dev_set_mac_address(dev, &s_addr)) {
-		pr_err("%s: Error: dev_set_mac_address of dev %s failed!\n"
-		       "ALB mode requires that the base driver support setting the hw address also when the network device's interface is open\n",
-		       slave->bond->dev->name, dev->name);
+		netdev_err(slave->bond->dev, "dev_set_mac_address of dev %s failed! ALB mode requires that the base driver support setting the hw address also when the network device's interface is open\n",
+			   dev->name);
 		return -EOPNOTSUPP;
 	}
 	return 0;
@@ -1267,13 +1264,12 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	if (free_mac_slave) {
 		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr);
 
-		pr_warn("%s: Warning: the hw address of slave %s is in use by the bond; giving it the hw address of %s\n",
-			bond->dev->name, slave->dev->name,
-			free_mac_slave->dev->name);
+		netdev_warn(bond->dev, "the hw address of slave %s is in use by the bond; giving it the hw address of %s\n",
+			    slave->dev->name, free_mac_slave->dev->name);
 
 	} else if (has_bond_addr) {
-		pr_err("%s: Error: the hw address of slave %s is in use by the bond; couldn't find a slave with a free hw address to give it (this should not have happened)\n",
-		       bond->dev->name, slave->dev->name);
+		netdev_err(bond->dev, "the hw address of slave %s is in use by the bond; couldn't find a slave with a free hw address to give it (this should not have happened)\n",
+			   slave->dev->name);
 		return -EFAULT;
 	}
 
-- 
1.8.4

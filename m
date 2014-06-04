From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [PATCH net-next 3/3] bonding: Support macvlans on top of tlb/rlb mode bonds
Date: Wed,  4 Jun 2014 16:23:38 -0400
Message-ID: <1401913418-31307-4-git-send-email-vyasevic@redhat.com>
References: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	kaber@trash.net, Vlad Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33088 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751242AbaFDUXu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Jun 2014 16:23:50 -0400
In-Reply-To: <1401913418-31307-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To make TLB mode work, the patch allows learning packets
to be sent using mac addresses assigned to macvlan devices,
also taking into an account vlans that may be between the
bond and macvlan device.

To make RLB work, all we have to do is accept ARP packets
for addresses added to the bond dev->uc list.  Since RLB
mode will take care to update the peers directly with
correct mac addresses, learning packets for these addresses
do not have be send to switch.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 drivers/net/bonding/bond_alb.c  | 21 ++++++++++++++++++---
 drivers/net/bonding/bond_main.c |  6 +++---
 drivers/net/bonding/bonding.h   | 24 ++++++++++++++++++++++++
 3 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 7bbbf1c..8da636f 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -755,7 +755,7 @@ static struct slave *rlb_arp_xmit(struct sk_buff *skb, struct bonding *bond)
 	/* Don't modify or load balance ARPs that do not originate locally
 	 * (e.g.,arrive via a bridge).
 	 */
-	if (!bond_slave_has_mac_rcu(bond, arp->mac_src))
+	if (!bond_slave_has_mac_rx(bond, arp->mac_src))
 		return NULL;
 
 	if (arp->op_code == htons(ARPOP_REPLY)) {
@@ -1039,11 +1039,14 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[],
 	struct bonding *bond = bond_get_bond_by_slave(slave);
 	struct net_device *upper;
 	struct list_head *iter;
+	struct bond_vlan_tag tags[BOND_MAX_VLAN_ENCAP];
 
 	/* send untagged */
 	alb_send_lp_vid(slave, mac_addr, 0, 0);
 
-	/* loop through vlans and send one packet for each */
+	/* loop through all devices and see if we need to send a packet
+	 * for that device.
+	 */
 	rcu_read_lock();
 	netdev_for_each_all_upper_dev_rcu(bond->dev, upper, iter) {
 		if (is_vlan_dev(upper) && vlan_get_encap_level(upper) == 0) {
@@ -1059,6 +1062,16 @@ static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[],
 						vlan_dev_vlan_id(upper));
 			}
 		}
+
+		/* If this is a macvlan device, then only send updates
+		 * when strict_match is turned off.
+		 */
+		if (netif_is_macvlan(upper) && !strict_match) {
+			memset(tags, 0, sizeof(tags));
+			bond_verify_device_path(bond->dev, upper, tags);
+			alb_send_lp_vid(slave, upper->dev_addr,
+					tags[0].vlan_proto, tags[0].vlan_id);
+		}
 	}
 	rcu_read_unlock();
 }
@@ -1560,8 +1573,10 @@ void bond_alb_monitor(struct work_struct *work)
 			/* If updating current_active, use all currently
 			 * user mac addreses (!strict_match).  Otherwise, only
 			 * use mac of the slave device.
+			 * In RLB mode, we always use strict matches.
 			 */
-			strict_match = (slave != bond->curr_active_slave);
+			strict_match = (slave != bond->curr_active_slave ||
+					bond_info->rlb_enabled);
 			alb_send_learning_packets(slave, slave->dev->dev_addr,
 						  strict_match);
 		}
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a89bf18..04f35f9 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2206,9 +2206,9 @@ static void bond_arp_send(struct net_device *slave_dev, int arp_op,
  * When the path is validated, collect any vlan information in the
  * path.
  */
-static bool bond_verify_device_path(struct net_device *start_dev,
-				    struct net_device *end_dev,
-				    struct bond_vlan_tag *tags)
+bool bond_verify_device_path(struct net_device *start_dev,
+			     struct net_device *end_dev,
+			     struct bond_vlan_tag *tags)
 {
 	struct net_device *upper;
 	struct list_head  *iter;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index ea64aa2..0b4d9cd 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -516,6 +516,9 @@ void bond_netlink_fini(void);
 struct net_device *bond_option_active_slave_get_rcu(struct bonding *bond);
 struct net_device *bond_option_active_slave_get(struct bonding *bond);
 const char *bond_slave_link_status(s8 link);
+bool bond_verify_device_path(struct net_device *start_dev,
+			     struct net_device *end_dev,
+			     struct bond_vlan_tag *tags);
 
 #ifdef CONFIG_PROC_FS
 void bond_create_proc_entry(struct bonding *bond);
@@ -567,6 +570,27 @@ static inline struct slave *bond_slave_has_mac_rcu(struct bonding *bond,
 	return NULL;
 }
 
+/* Caller must hold rcu_read_lock() for read */
+static inline bool bond_slave_has_mac_rx(struct bonding *bond, const u8 *mac)
+{
+	struct list_head *iter;
+	struct slave *tmp;
+	struct netdev_hw_addr *ha;
+
+	bond_for_each_slave_rcu(bond, tmp, iter)
+		if (ether_addr_equal_64bits(mac, tmp->dev->dev_addr))
+			return true;
+
+	if (netdev_uc_empty(bond->dev))
+		return false;
+
+	netdev_for_each_uc_addr(ha, bond->dev)
+		if (ether_addr_equal_64bits(mac, ha->addr))
+			return true;
+
+	return false;
+}
+
 /* Check if the ip is present in arp ip list, or first free slot if ip == 0
  * Returns -1 if not found, index if found
  */
-- 
1.9.0

From: Shmuel Hen <shmulik.hen@intel.com>
Subject: [PATCH 2/3][bonding][2.6] Add VLAN support in TLB mode
Date: Sun, 8 Feb 2004 18:11:19 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402081811.21053.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-netdev" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: "Jeff Garzik" <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add capability to tag self generated learning packets that are 
required to speed up port selection in the switch after a fail 
over in bonding since some switches will only update their MAC 
tables from tagged packets when VLAN support is turned on. All 
VLAN Id's that have been configured on top of the bond interface 
will be used in cyclic order. 

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |


diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Wed Jan 21 16:56:22 2004
+++ b/drivers/net/bonding/bond_alb.c	Wed Jan 21 16:56:24 2004
@@ -50,6 +50,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_bonding.h>
+#include <linux/if_vlan.h>
 #include <net/ipx.h>
 #include <net/arp.h>
 #include <asm/byteorder.h>
@@ -79,7 +80,7 @@
 
 
 #define TLB_NULL_INDEX		0xffffffff
-#define MAX_LP_RETRY		3
+#define MAX_LP_BURST		3
 
 /* rlb defs */
 #define RLB_HASH_TABLE_SIZE	256
@@ -816,6 +817,7 @@ static void rlb_deinitialize(struct bond
 
 static void alb_send_learning_packets(struct slave *slave, u8 mac_addr[])
 {
+	struct bonding *bond = bond_get_bond_by_slave(slave);
 	struct learning_pkt pkt;
 	int size = sizeof(struct learning_pkt);
 	int i;
@@ -825,7 +827,7 @@ static void alb_send_learning_packets(st
 	memcpy(pkt.mac_src, mac_addr, ETH_ALEN);
 	pkt.type = __constant_htons(ETH_P_LOOP);
 
-	for (i = 0; i < MAX_LP_RETRY; i++) {
+	for (i = 0; i < MAX_LP_BURST; i++) {
 		struct sk_buff *skb;
 		char *data;
 
@@ -843,6 +845,26 @@ static void alb_send_learning_packets(st
 		skb->priority = TC_PRIO_CONTROL;
 		skb->dev = slave->dev;
 
+		if (!list_empty(&bond->vlan_list)) {
+			struct vlan_entry *vlan;
+
+			vlan = bond_next_vlan(bond,
+					      bond->alb_info.current_alb_vlan);
+
+			bond->alb_info.current_alb_vlan = vlan;
+			if (!vlan) {
+				kfree_skb(skb);
+				continue;
+			}
+
+			skb = vlan_put_tag(skb, vlan->vlan_id);
+			if (!skb) {
+				printk(KERN_ERR DRV_NAME
+				       ": Error: failed to insert VLAN tag\n");
+				continue;
+			}
+		}
+
 		dev_queue_xmit(skb);
 	}
 }
@@ -1588,3 +1610,11 @@ int bond_alb_set_mac_address(struct net_
 	return 0;
 }
 
+void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
+{
+	if (bond->alb_info.current_alb_vlan &&
+	    (bond->alb_info.current_alb_vlan->vlan_id == vlan_id)) {
+		bond->alb_info.current_alb_vlan = NULL;
+	}
+}
+
diff -Nuarp a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
--- a/drivers/net/bonding/bond_alb.h	Wed Jan 21 16:56:22 2004
+++ b/drivers/net/bonding/bond_alb.h	Wed Jan 21 16:56:24 2004
@@ -122,6 +122,7 @@ struct alb_bond_info {
 						 * rx traffic should be
 						 * rebalanced
 						 */
+	struct vlan_entry	*current_alb_vlan;
 };
 
 int bond_alb_initialize(struct bonding *bond, int rlb_enabled);
@@ -133,6 +134,6 @@ void bond_alb_handle_active_change(struc
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *bond_dev);
 void bond_alb_monitor(struct bonding *bond);
 int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr);
-
+void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id);
 #endif /* __BOND_ALB_H__ */
 
diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Wed Jan 21 16:56:22 2004
+++ b/drivers/net/bonding/bond_main.c	Wed Jan 21 16:56:24 2004
@@ -676,6 +676,11 @@ static int bond_del_vlan(struct bonding 
 		if (vlan->vlan_id == vlan_id) {
 			list_del(&vlan->vlan_list);
 
+			if ((bond->params.mode == BOND_MODE_TLB) ||
+			    (bond->params.mode == BOND_MODE_ALB)) {
+				bond_alb_clear_vlan(bond, vlan_id);
+			}
+
 			dprintk("removed VLAN ID %d from bond %s\n", vlan_id,
 				bond->dev->name);
 
@@ -731,6 +736,42 @@ static int bond_has_challenged_slaves(st
 }
 
 /**
+ * bond_next_vlan - safely skip to the next item in the vlans list.
+ * @bond: the bond we're working on
+ * @curr: item we're advancing from
+ *
+ * Returns %NULL if list is empty, bond->next_vlan if @curr is %NULL,
+ * or @curr->next otherwise (even if it is @curr itself again).
+ * 
+ * Caller must hold bond->lock
+ */
+struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
+{
+	struct vlan_entry *next, *last;
+
+	if (list_empty(&bond->vlan_list)) {
+		return NULL;
+	}
+
+	if (!curr) {
+		next = list_entry(bond->vlan_list.next,
+				  struct vlan_entry, vlan_list);
+	} else {
+		last = list_entry(bond->vlan_list.prev,
+				  struct vlan_entry, vlan_list);
+		if (last == curr) {
+			next = list_entry(bond->vlan_list.next,
+					  struct vlan_entry, vlan_list);
+		} else {
+			next = list_entry(curr->vlan_list.next,
+					  struct vlan_entry, vlan_list);
+		}
+	}
+
+	return next;
+}
+
+/**
  * bond_dev_queue_xmit - Prepare skb for xmit.
  * 
  * @bond: bond device that got this skb for tx.
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Wed Jan 21 16:56:22 2004
+++ b/drivers/net/bonding/bonding.h	Wed Jan 21 16:56:24 2004
@@ -245,6 +245,7 @@ extern inline void bond_set_slave_active
 	slave->dev->flags &= ~IFF_NOARP;
 }
 
+struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 
 #endif /* _LINUX_BONDING_H */

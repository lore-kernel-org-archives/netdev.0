From: Shmuel Hen <shmulik.hen@intel.com>
Subject: [PATCH 3/3][bonding][2.6] Add VLAN support in ALB mode
Date: Sun, 8 Feb 2004 18:11:28 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402081811.29698.shmulik.hen@intel.com>
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

Add capability to tag self generated ARP packets that are required 
for receive load balancing in bonding. VLAN Id's are saved and used 
each time a new IP connection is established since 8021q currently 
supports IP binding. 

Update module version and comment blocks.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |


diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Wed Jan 21 16:56:26 2004
+++ b/drivers/net/bonding/bond_alb.c	Wed Jan 21 16:56:28 2004
@@ -34,6 +34,9 @@
  *
  * 2003/12/30 - Amir Noam <amir.noam at intel dot com>
  *	- Fixed: Cannot remove and re-enslave the original active slave.
+ *
+ * 2004/01/14 - Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Add capability to tag self generated packets in ALB/TLB modes.
  */
 
 //#define BONDING_DEBUG 1
@@ -499,13 +502,33 @@ static void rlb_update_client(struct rlb
 	}
 
 	for (i = 0; i < RLB_ARP_BURST_SIZE; i++) {
-		arp_send(ARPOP_REPLY, ETH_P_ARP,
-			 client_info->ip_dst,
-			 client_info->slave->dev,
-			 client_info->ip_src,
-			 client_info->mac_dst,
-			 client_info->slave->dev->dev_addr,
-			 client_info->mac_dst);
+		struct sk_buff *skb;
+
+		skb = arp_create(ARPOP_REPLY, ETH_P_ARP,
+				 client_info->ip_dst,
+				 client_info->slave->dev,
+				 client_info->ip_src,
+				 client_info->mac_dst,
+				 client_info->slave->dev->dev_addr,
+				 client_info->mac_dst);
+		if (!skb) {
+			printk(KERN_ERR DRV_NAME
+			       ": Error: failed to create an ARP packet\n");
+			continue;
+		}
+
+		skb->dev = client_info->slave->dev;
+
+		if (client_info->tag) {
+			skb = vlan_put_tag(skb, client_info->vlan_id);
+			if (!skb) {
+				printk(KERN_ERR DRV_NAME
+				       ": Error: failed to insert VLAN tag\n");
+				continue;
+			}
+		}
+
+		arp_xmit(skb);
 	}
 }
 
@@ -604,9 +627,10 @@ static void rlb_req_update_subnet_client
 }
 
 /* Caller must hold both bond and ptr locks for read */
-struct slave *rlb_choose_channel(struct bonding *bond, struct arp_pkt *arp)
+struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bond)
 {
 	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct arp_pkt *arp = (struct arp_pkt *)skb->nh.raw;
 	struct slave *assigned_slave;
 	struct rlb_client_info *client_info;
 	u32 hash_index = 0;
@@ -662,6 +686,15 @@ struct slave *rlb_choose_channel(struct 
 			client_info->ntt = 0;
 		}
 
+		if (!list_empty(&bond->vlan_list)) {
+			unsigned short vlan_id;
+			int res = vlan_get_tag(skb, &vlan_id);
+			if (!res) {
+				client_info->tag = 1;
+				client_info->vlan_id = vlan_id;
+			}
+		}
+
 		if (!client_info->assigned) {
 			u32 prev_tbl_head = bond_info->rx_hashtbl_head;
 			bond_info->rx_hashtbl_head = hash_index;
@@ -692,7 +725,7 @@ static struct slave *rlb_arp_xmit(struct
 		/* the arp must be sent on the selected
 		* rx channel
 		*/
-		tx_slave = rlb_choose_channel(bond, arp);
+		tx_slave = rlb_choose_channel(skb, bond);
 		if (tx_slave) {
 			memcpy(arp->mac_src,tx_slave->dev->dev_addr, ETH_ALEN);
 		}
@@ -703,7 +736,7 @@ static struct slave *rlb_arp_xmit(struct
 		 * When the arp reply is received the entry will be updated
 		 * with the correct unicast address of the client.
 		 */
-		rlb_choose_channel(bond, arp);
+		rlb_choose_channel(skb, bond);
 
 		/* The ARP relpy packets must be delayed so that
 		 * they can cancel out the influence of the ARP request.
@@ -809,6 +842,40 @@ static void rlb_deinitialize(struct bond
 
 	kfree(bond_info->rx_hashtbl);
 	bond_info->rx_hashtbl = NULL;
+	bond_info->rx_hashtbl_head = RLB_NULL_INDEX;
+
+	_unlock_rx_hashtbl(bond);
+}
+
+static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
+{
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	u32 curr_index;
+
+	_lock_rx_hashtbl(bond);
+
+	curr_index = bond_info->rx_hashtbl_head;
+	while (curr_index != RLB_NULL_INDEX) {
+		struct rlb_client_info *curr = &(bond_info->rx_hashtbl[curr_index]);
+		u32 next_index = bond_info->rx_hashtbl[curr_index].next;
+		u32 prev_index = bond_info->rx_hashtbl[curr_index].prev;
+
+		if (curr->tag && (curr->vlan_id == vlan_id)) {
+			if (curr_index == bond_info->rx_hashtbl_head) {
+				bond_info->rx_hashtbl_head = next_index;
+			}
+			if (prev_index != RLB_NULL_INDEX) {
+				bond_info->rx_hashtbl[prev_index].next = next_index;
+			}
+			if (next_index != RLB_NULL_INDEX) {
+				bond_info->rx_hashtbl[next_index].prev = prev_index;
+			}
+
+			rlb_init_table_entry(curr);
+		}
+
+		curr_index = next_index;
+	}
 
 	_unlock_rx_hashtbl(bond);
 }
@@ -1616,5 +1683,9 @@ void bond_alb_clear_vlan(struct bonding 
 	    (bond->alb_info.current_alb_vlan->vlan_id == vlan_id)) {
 		bond->alb_info.current_alb_vlan = NULL;
 	}
+
+	if (bond->alb_info.rlb_enabled) {
+		rlb_clear_vlan(bond, vlan_id);
+	}
 }
 
diff -Nuarp a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
--- a/drivers/net/bonding/bond_alb.h	Wed Jan 21 16:56:26 2004
+++ b/drivers/net/bonding/bond_alb.h	Wed Jan 21 16:56:28 2004
@@ -77,6 +77,8 @@ struct rlb_client_info {
 	u8  assigned;		/* checking whether this entry is assigned */
 	u8  ntt;		/* flag - need to transmit client info */
 	struct slave *slave;	/* the slave assigned to this client */
+	u8 tag;			/* flag - need to tag skb */
+	unsigned short vlan_id;	/* VLAN tag associated with IP address */
 };
 
 struct tlb_slave_info {
diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Wed Jan 21 16:56:26 2004
+++ b/drivers/net/bonding/bond_main.c	Wed Jan 21 16:56:28 2004
@@ -455,12 +455,20 @@
  *
  * 2003/12/30 - Amir Noam <amir.noam at intel dot com>
  *	- Fixed: Cannot remove and re-enslave the original active slave.
- *	- Fixed: Releasing the original active slave causes mac address duplication.
+ *	- Fixed: Releasing the original active slave causes mac address
+ *		 duplication.
  *	- Add support for slaves that use ethtool_ops.
  *	  Set version to 2.5.3.
  *
  * 2004/01/05 - Amir Noam <amir.noam at intel dot com>
  *	- Save bonding parameters per bond instead of using the global values.
+ *	  Set version to 2.5.4.
+ *
+ * 2004/01/14 - Shmulik Hen <shmulik.hen at intel dot com>
+ *	- Enhance VLAN support:
+ *	  * Add support for VLAN hardware acceleration capable slaves.
+ *	  * Add capability to tag self generated packets in ALB/TLB modes.
+ *	  Set version to 2.6.0.
  */
 
 //#define BONDING_DEBUG 1
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Wed Jan 21 16:56:26 2004
+++ b/drivers/net/bonding/bonding.h	Wed Jan 21 16:56:28 2004
@@ -36,8 +36,8 @@
 #include "bond_3ad.h"
 #include "bond_alb.h"
 
-#define DRV_VERSION	"2.5.4"
-#define DRV_RELDATE	"December 30, 2003"
+#define DRV_VERSION	"2.6.0"
+#define DRV_RELDATE	"January 14, 2004"
 #define DRV_NAME	"bonding"
 #define DRV_DESCRIPTION	"Ethernet Channel Bonding Driver"
 

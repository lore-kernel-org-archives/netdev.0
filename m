From: Amir Noam <amir.noam@intel.com>
Subject: [PATCH 6/10] [bonding 2.6] Add support for changing HW address in ALB/TLB modes
Date: Thu, 11 Sep 2003 17:41:35 +0300
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200309111741.35299.amir.noam@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: bonding-devel@lists.sourceforge.net, netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Thu Sep 11 16:48:29 2003
+++ b/drivers/net/bonding/bond_alb.c	Thu Sep 11 16:48:30 2003
@@ -24,10 +24,15 @@
  * 2003/06/25 - Shmulik Hen <shmulik.hen at intel dot com>
  *	- Fixed signed/unsigned calculation errors that caused load sharing
  *	  to collapse to one slave under very heavy UDP Tx stress.
+ *
+ * 2003/08/06 - Amir Noam <amir.noam at intel dot com>
+ *	- Add support for setting bond's MAC address with special
+ *	  handling required for ALB/TLB.
  */
 
 #include <linux/skbuff.h>
 #include <linux/netdevice.h>
+#include <linux/etherdevice.h>
 #include <linux/pkt_sched.h>
 #include <linux/spinlock.h>
 #include <linux/slab.h>
@@ -943,10 +948,11 @@ alb_send_learning_packets(struct slave *
 }
 
 /* hw is a boolean parameter that determines whether we should try and
- * set the hw address of the hw as well as the hw address of the net_device
+ * set the hw address of the device as well as the hw address of the
+ * net_device
  */
 static int
-alb_set_mac_addr(struct slave *slave, u8 addr[], int hw)
+alb_set_slave_mac_addr(struct slave *slave, u8 addr[], int hw)
 {
 	struct net_device *dev = NULL;
 	struct sockaddr s_addr;
@@ -954,16 +960,16 @@ alb_set_mac_addr(struct slave *slave, u8
 	dev = slave->dev;
 
 	if (!hw) {
-		memcpy(dev->dev_addr, addr, ETH_ALEN);
+		memcpy(dev->dev_addr, addr, dev->addr_len);
 		return 0;
 	}
 
 	/* for rlb each slave must have a unique hw mac addresses so that */
 	/* each slave will receive packets destined to a different mac */
-	memcpy(s_addr.sa_data, addr, ETH_ALEN);
+	memcpy(s_addr.sa_data, addr, dev->addr_len);
 	s_addr.sa_family = dev->type;
 	if (dev->set_mac_address(dev, &s_addr)) {
-		printk(KERN_DEBUG "bonding: Error: alb_set_mac_addr:"
+		printk(KERN_DEBUG "bonding: Error: alb_set_slave_mac_addr:"
 				  " dev->set_mac_address of dev %s failed!"
 				  " ALB mode requires that the base driver"
 				  " support setting the hw address also when"
@@ -987,8 +993,8 @@ alb_swap_mac_addr(struct bonding *bond,
 	slaves_state_differ = (SLAVE_IS_OK(slave1) != SLAVE_IS_OK(slave2));
 
 	memcpy(tmp_mac_addr, slave1->dev->dev_addr, ETH_ALEN);
-	alb_set_mac_addr(slave1, slave2->dev->dev_addr, bond->alb_info.rlb_enabled);
-	alb_set_mac_addr(slave2, tmp_mac_addr, bond->alb_info.rlb_enabled);
+	alb_set_slave_mac_addr(slave1, slave2->dev->dev_addr, bond->alb_info.rlb_enabled);
+	alb_set_slave_mac_addr(slave2, tmp_mac_addr, bond->alb_info.rlb_enabled);
 
 	/* fasten the change in the switch */
 	if (SLAVE_IS_OK(slave1)) {
@@ -1153,8 +1159,8 @@ alb_handle_addr_collision_on_attach(stru
 	}
 
 	if (tmp_slave1) {
-		alb_set_mac_addr(slave, tmp_slave1->perm_hwaddr,
-				 bond->alb_info.rlb_enabled);
+		alb_set_slave_mac_addr(slave, tmp_slave1->perm_hwaddr,
+				       bond->alb_info.rlb_enabled);
 
 		printk(KERN_WARNING "bonding: Warning: the hw address "
 		       "of slave %s is in use by the bond; "
@@ -1172,6 +1178,67 @@ alb_handle_addr_collision_on_attach(stru
 	return 0;
 }
 
+/**
+ * alb_set_mac_address
+ * @bond:
+ * @addr:
+ *
+ * In TLB mode all slaves are configured to the bond's hw address, but set
+ * their dev_addr field to different addresses (based on their permanent hw
+ * addresses).
+ *
+ * For each slave, this function sets the interface to the new address and then
+ * changes its dev_addr field to its previous value.
+ * 
+ * Unwinding assumes bond's mac address has not yet changed.
+ */
+static inline int
+alb_set_mac_address(struct bonding *bond, void *addr)
+{
+	struct sockaddr sa;
+	struct slave *slave;
+	char tmp_addr[ETH_ALEN];
+	int error;
+
+	if (bond->alb_info.rlb_enabled) {
+		return 0;
+	}
+
+	slave = bond_get_first_slave(bond);
+	for (; slave; slave = bond_get_next_slave(bond, slave)) {
+		if (slave->dev->set_mac_address == NULL) {
+			error = -EOPNOTSUPP;
+			goto unwind;
+		}
+
+		/* save net_device's current hw address */
+		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
+
+		error = slave->dev->set_mac_address(slave->dev, addr);
+
+		/* restore net_device's hw address */
+		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
+
+		if (error) {
+			goto unwind;
+		}
+	}
+
+	return 0;
+
+unwind:
+	memcpy(sa.sa_data, bond->device->dev_addr, bond->device->addr_len);
+	sa.sa_family = bond->device->type;
+	slave = bond_get_first_slave(bond);
+	for (; slave; slave = bond_get_next_slave(bond, slave)) {
+		memcpy(tmp_addr, slave->dev->dev_addr, ETH_ALEN);
+		slave->dev->set_mac_address(slave->dev, &sa);
+		memcpy(slave->dev->dev_addr, tmp_addr, ETH_ALEN);
+	}
+
+	return error;
+}
+
 /************************ exported alb funcions ************************/
 
 int
@@ -1444,8 +1511,8 @@ bond_alb_init_slave(struct bonding *bond
 {
 	int err = 0;
 
-	err = alb_set_mac_addr(slave, slave->perm_hwaddr,
-				bond->alb_info.rlb_enabled);
+	err = alb_set_slave_mac_addr(slave, slave->perm_hwaddr,
+				     bond->alb_info.rlb_enabled);
 	if (err) {
 		return err;
 	}
@@ -1569,10 +1636,61 @@ bond_alb_assign_current_slave(struct bon
 		alb_swap_mac_addr(bond, swap_slave, new_slave);
 	} else {
 		/* set the new_slave to the bond mac address */
-		alb_set_mac_addr(new_slave, bond->device->dev_addr,
-				 bond->alb_info.rlb_enabled);
+		alb_set_slave_mac_addr(new_slave, bond->device->dev_addr,
+				       bond->alb_info.rlb_enabled);
 		/* fasten bond mac on new current slave */
 		alb_send_learning_packets(new_slave, bond->device->dev_addr);
 	}
+}
+
+int
+bond_alb_set_mac_address(struct net_device *dev, void *addr)
+{
+	struct bonding *bond = dev->priv;
+	struct sockaddr *sa = addr;
+	struct slave *swap_slave = NULL;
+	int error = 0;
+
+	if (!is_valid_ether_addr(sa->sa_data)) {
+		return -EADDRNOTAVAIL;
+	}
+
+	error = alb_set_mac_address(bond, addr);
+	if (error) {
+		return error;
+	}
+
+	memcpy(dev->dev_addr, sa->sa_data, dev->addr_len);
+
+	/* If there is no current_slave there is nothing else to do.
+	 * Otherwise we'll need to pass the new address to it and handle
+	 * duplications.
+	 */
+	if (bond->current_slave == NULL) {
+		return 0;
+	}
+
+	swap_slave = bond_get_first_slave(bond);
+	while (swap_slave) {
+		if (!memcmp(swap_slave->dev->dev_addr, dev->dev_addr, ETH_ALEN)) {
+			break;
+		}
+		swap_slave = bond_get_next_slave(bond, swap_slave);
+	}
+
+	if (swap_slave) {
+		alb_swap_mac_addr(bond, swap_slave, bond->current_slave);
+	} else {
+		alb_set_slave_mac_addr(bond->current_slave, dev->dev_addr,
+				       bond->alb_info.rlb_enabled);
+
+		alb_send_learning_packets(bond->current_slave, dev->dev_addr);
+		if (bond->alb_info.rlb_enabled) {
+			/* inform clients mac address has changed */
+			rlb_req_update_slave_clients(bond, bond->current_slave);
+		}
+	}
+
+	return 0;
 }
 
diff -Nuarp a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
--- a/drivers/net/bonding/bond_alb.h	Thu Sep 11 16:48:29 2003
+++ b/drivers/net/bonding/bond_alb.h	Thu Sep 11 16:48:30 2003
@@ -17,6 +17,13 @@
  *
  * The full GNU General Public License is included in this distribution in the
  * file called LICENSE.
+ *
+ *
+ * Changes:
+ *
+ * 2003/08/06 - Amir Noam <amir.noam at intel dot com>
+ *	- Add support for setting bond's MAC address with special
+ *	  handling required for ALB/TLB.
  */
 
 #ifndef __BOND_ALB_H__
@@ -122,6 +129,7 @@ void bond_alb_handle_link_change(struct 
 void bond_alb_assign_current_slave(struct bonding *bond, struct slave *new_slave);
 int bond_alb_xmit(struct sk_buff *skb, struct net_device *dev);
 void bond_alb_monitor(struct bonding *bond);
+int bond_alb_set_mac_address(struct net_device *dev, void *addr);
 
 #endif /* __BOND_ALB_H__ */
 
diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:29 2003
+++ b/drivers/net/bonding/bond_main.c	Thu Sep 11 16:48:30 2003
@@ -1414,7 +1414,7 @@ static int bond_enslave(struct net_devic
 			 * The application already set the master's
 			 * mac address to that of the first slave
 			 */
-			memcpy(addr.sa_data, master_dev->dev_addr, ETH_ALEN);
+			memcpy(addr.sa_data, master_dev->dev_addr, master_dev->addr_len);
 			addr.sa_family = slave_dev->type;
 			err = slave_dev->set_mac_address(slave_dev, &addr);
 			if (err) {
@@ -1985,12 +1985,12 @@ static int bond_release(struct net_devic
 				"of %s to a different address "
 				"to avoid conflicts.\n",
 				       slave->name,
-				       slave->dev_addr[0],
-				       slave->dev_addr[1],
-				       slave->dev_addr[2],
-				       slave->dev_addr[3],
-				       slave->dev_addr[4],
-				       slave->dev_addr[5],
+				       our_slave->perm_hwaddr[0],
+				       our_slave->perm_hwaddr[1],
+				       our_slave->perm_hwaddr[2],
+				       our_slave->perm_hwaddr[3],
+				       our_slave->perm_hwaddr[4],
+				       our_slave->perm_hwaddr[5],
 				       bond->device->name,
 				       slave->name);
 			}
@@ -3647,12 +3647,15 @@ static int __init bond_init(struct net_d
 	rwlock_init(&bond->lock);
 	rwlock_init(&bond->ptrlock);
 
+	/* Initialize pointers */
 	bond->next = bond->prev = (slave_t *)bond;
 	bond->current_slave = NULL;
 	bond->current_arp_slave = NULL;
 	bond->device = dev;
 
 	/* Initialize the device structure. */
+	dev->set_mac_address = bond_set_mac_address;
+
 	switch (bond_mode) {
 	case BOND_MODE_ACTIVEBACKUP:
 		dev->hard_start_xmit = bond_xmit_activebackup;
@@ -3672,6 +3675,7 @@ static int __init bond_init(struct net_d
 	case BOND_MODE_TLB:
 	case BOND_MODE_ALB:
 		dev->hard_start_xmit = bond_alb_xmit;
+		dev->set_mac_address = bond_alb_set_mac_address;
 		break;
 	default:
 		printk(KERN_ERR "Unknown bonding mode %d\n", bond_mode);
@@ -3684,7 +3688,6 @@ static int __init bond_init(struct net_d
 	dev->set_multicast_list = set_multicast_list;
 	dev->do_ioctl = bond_ioctl;
 	dev->change_mtu = bond_change_mtu;
-	dev->set_mac_address = bond_set_mac_address;
 	dev->tx_queue_len = 0;
 	dev->flags |= IFF_MASTER|IFF_MULTICAST;
 #ifdef CONFIG_NET_FASTROUTE

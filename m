From: Shmuel Hen <shmulik.hen@intel.com>
Subject: [PATCH 1/3][bonding 2.4] Add support for HW accel. slaves
Date: Thu, 19 Feb 2004 12:14:37 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200402191214.39269.shmulik.hen@intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "linux-netdev" <netdev@oss.sgi.com>,
        "bonding-devel" <bonding-devel@lists.sourceforge.net>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, "Jeff Garzik" <jgarzik@pobox.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Now, that 2.4.25 is out, I'm resending the enhancements for VLAN over bonding.
Tested for patch application and compilation against latest netdev-2.4 BK tree
(assuming the previous 3 patches are already applied).

Summary:
Change the bond interface to publish full VLAN hardware acceleration 
offloading capabilities, and add capability in all xmit functions to 
take special care for VLAN HW accel. tagged skb's that are going out 
through a slave that is not offloading capable. 

Add a mechanism to collect and save the VLAN Id's that have been 
added on top of a bond interface, and propagate the register/add/kill 
operations to the slaves. 

Add blocking mechanism to prevent adding VLAN interfaces on top of a 
bond that contains VLAN challenged slaves and to prevent adding VLAN 
challenged slaves to a bond that already has VLAN interfaces on top 
of it. 

Add a section about VLAN to Documentation/networking/bonding.txt and 
also correct some minor spelling/grammer errors.

-- 
| Shmulik Hen   Advanced Network Services  |
| Israel Design Center, Jerusalem          |
| LAN Access Division, Platform Networking |
| Intel Communications Group, Intel corp.  |


diff -Nuarp a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
--- a/Documentation/networking/bonding.txt	Wed Jan 21 16:55:06 2004
+++ b/Documentation/networking/bonding.txt	Wed Jan 21 16:55:08 2004
@@ -31,6 +31,7 @@ Verifying Bond Configuration
 Frequently Asked Questions
 High Availability
 Promiscuous Sniffing notes
+8021q VLAN support
 Limitations
 Resources and Links
 
@@ -140,10 +141,6 @@ probeall bond0 eth0 eth1 bonding
 Be careful not to reference bond0 itself at the end of the line, or modprobe
 will die in an endless recursive loop.
 
-To have device characteristics (such as MTU size) propagate to slave devices,
-set the bond characteristics before enslaving the device.  The characteristics
-are propagated during the enslave process.
-
 If running SNMP agents, the bonding driver should be loaded before any network
 drivers participating in a bond. This requirement is due to the the interface
 index (ipAdEntIfIndex) being associated to the first interface found with a
@@ -601,7 +598,7 @@ Frequently Asked Questions
 	For ethernet cards not supporting MII status, the arp_interval and
         arp_ip_target parameters must be specified for bonding to work
         correctly. If packets have not been sent or received during the
-        specified arp_interval durration, an ARP request is sent to the
+        specified arp_interval duration, an ARP request is sent to the
         targets to generate send and receive traffic. If after this
         interval, either the successful send and/or receive count has not
         incremented, the next slave in the sequence will become the active
@@ -669,16 +666,8 @@ Frequently Asked Questions
 	that will be added.
 
 	To restore your slaves' MAC addresses, you need to detach them
-	from the bond (`ifenslave -d bond0 eth0'), set them down
-	(`ifconfig eth0 down'), unload the drivers (`rmmod 3c59x', for
-	example) and reload them to get the MAC addresses from their
-	eeproms. If the driver is shared by several devices, you need
-	to turn them all down. Another solution is to look for the MAC
-	address at boot time (dmesg or tail /var/log/messages) and to
-	reset it by hand with ifconfig :
-
-	  # ifconfig eth0 down
-	  # ifconfig eth0 hw ether 00:20:40:60:80:A0
+	from the bond (`ifenslave -d bond0 eth0'). The bonding driver will then
+	restore the MAC addresses that the slaves had before they were enslaved.
 
 9.  Which transmit polices can be used?
 
@@ -843,7 +832,7 @@ point of failure" solution.
 
 In this configuration, there is an ISL - Inter Switch Link (could be a trunk),
 several servers (host1, host2 ...) attached to both switches each, and one or
-more ports to the outside world (port3...). One an only one slave on each host
+more ports to the outside world (port3...). One and only one slave on each host
 is active at a time, while all links are still monitored (the system can
 detect a failure of active and backup links).
 
@@ -933,6 +922,41 @@ capacity aggregating; but it works fine 
 just ignore all the warnings it emits.
 
 
+8021q VLAN support
+==================
+
+It is possible to configure VLAN devices over a bond interface using the 8021q
+driver. However, only packets coming from the 8021q driver and passing through
+bonding will be tagged by default. Self generated packets, like bonding's
+learning packets or ARP packets generated by either ALB mode or the ARP
+monitor mechanism, are tagged internally by bonding itself. As a result,
+bonding has to "learn" what VLAN IDs are configured on top of it, and it uses
+those IDs to tag self generated packets.
+
+For simplicity reasons, and to support the use of adapters that can do VLAN
+hardware acceleration offloding, the bonding interface declares itself as
+fully hardware offloaing capable, it gets the add_vid/kill_vid notifications
+to gather the necessary information, and it propagates those actions to the
+slaves.
+In case of mixed adapter types, hardware accelerated tagged packets that should
+go through an adapter that is not offloading capable are "un-accelerated" by the
+bonding driver so the VLAN tag sits in the regular location.
+
+VLAN interfaces *must* be added on top of a bonding interface only after
+enslaving at least one slave. This is because until the first slave is added the
+bonding interface has a HW address of 00:00:00:00:00:00, which will be copied by
+the VLAN interface when it is created.
+
+Notice that a problem would occur if all slaves are released from a bond that
+still has VLAN interfaces on top of it. When later coming to add new slaves, the
+bonding interface would get a HW address from the first slave, which might not
+match that of the VLAN interfaces. It is recommended that either all VLANs are
+removed and then re-added, or to manually set the bonding interface's HW
+address so it matches the VLAN's. (Note: changing a VLAN interface's HW address
+would set the underlying device -- i.e. the bonding interface -- to promiscouos
+mode, which might not be what you want).
+
+
 Limitations
 ===========
 The main limitations are :
diff -Nuarp a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
--- a/drivers/net/bonding/bond_3ad.c	Wed Jan 21 16:55:06 2004
+++ b/drivers/net/bonding/bond_3ad.c	Wed Jan 21 16:55:08 2004
@@ -2362,6 +2362,7 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 	int agg_id;
 	int i;
 	struct ad_info ad_info;
+	int res = 1;
 
 	/* make sure that the slaves list will
 	 * not change during tx
@@ -2369,12 +2370,12 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 	read_lock(&bond->lock);
 
 	if (!BOND_IS_OK(bond)) {
-		goto free_out;
+		goto out;
 	}
 
 	if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		printk(KERN_DEBUG "ERROR: bond_3ad_get_active_agg_info failed\n");
-		goto free_out;
+		goto out;
 	}
 
 	slaves_in_agg = ad_info.ports;
@@ -2383,7 +2384,7 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 	if (slaves_in_agg == 0) {
 		/*the aggregator is empty*/
 		printk(KERN_DEBUG "ERROR: active aggregator is empty\n");
-		goto free_out;
+		goto out;
 	}
 
 	slave_agg_no = (data->h_dest[5]^bond->dev->dev_addr[5]) % slaves_in_agg;
@@ -2401,7 +2402,7 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 
 	if (slave_agg_no >= 0) {
 		printk(KERN_ERR DRV_NAME ": Error: Couldn't find a slave to tx on for aggregator ID %d\n", agg_id);
-		goto free_out;
+		goto out;
 	}
 
 	start_at = slave;
@@ -2414,24 +2415,19 @@ int bond_3ad_xmit_xor(struct sk_buff *sk
 			slave_agg_id = agg->aggregator_identifier;
 		}
 
-		if (SLAVE_IS_OK(slave) && 
-		    agg && (slave_agg_id == agg_id)) {
-			skb->dev = slave->dev;			
-			skb->priority = 1;
-			dev_queue_xmit(skb);
-
-			goto out;
+		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
+			res = bond_dev_queue_xmit(bond, skb, slave->dev);
+			break;
 		}
 	}
 
 out:
+	if (res) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+	}
 	read_unlock(&bond->lock);
 	return 0;
-
-free_out:
-	/* no suitable interface, frame not sent */
-	dev_kfree_skb(skb);
-	goto out;
 }
 
 int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct packet_type* ptype)
diff -Nuarp a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
--- a/drivers/net/bonding/bond_alb.c	Wed Jan 21 16:55:06 2004
+++ b/drivers/net/bonding/bond_alb.c	Wed Jan 21 16:55:08 2004
@@ -1194,6 +1194,7 @@ int bond_alb_xmit(struct sk_buff *skb, s
 	int do_tx_balance = 1;
 	u32 hash_index = 0;
 	u8 *hash_start = NULL;
+	int res = 1;
 
 	/* make sure that the curr_active_slave and the slaves list do
 	 * not change during tx
@@ -1202,7 +1203,7 @@ int bond_alb_xmit(struct sk_buff *skb, s
 	read_lock(&bond->curr_slave_lock);
 
 	if (!BOND_IS_OK(bond)) {
-		goto free_out;
+		goto out;
 	}
 
 	switch (ntohs(skb->protocol)) {
@@ -1267,29 +1268,27 @@ int bond_alb_xmit(struct sk_buff *skb, s
 	}
 
 	if (tx_slave && SLAVE_IS_OK(tx_slave)) {
-		skb->dev = tx_slave->dev;
 		if (tx_slave != bond->curr_active_slave) {
 			memcpy(eth_data->h_source,
 			       tx_slave->dev->dev_addr,
 			       ETH_ALEN);
 		}
-		dev_queue_xmit(skb);
+
+		res = bond_dev_queue_xmit(bond, skb, tx_slave->dev);
 	} else {
-		/* no suitable interface, frame not sent */
 		if (tx_slave) {
 			tlb_clear_slave(bond, tx_slave, 0);
 		}
-		goto free_out;
 	}
 
 out:
+	if (res) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+	}
 	read_unlock(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
 	return 0;
-
-free_out:
-	dev_kfree_skb(skb);
-	goto out;
 }
 
 void bond_alb_monitor(struct bonding *bond)
diff -Nuarp a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
--- a/drivers/net/bonding/bond_main.c	Wed Jan 21 16:55:06 2004
+++ b/drivers/net/bonding/bond_main.c	Wed Jan 21 16:55:08 2004
@@ -502,6 +502,7 @@
 #include <net/arp.h>
 #include <linux/mii.h>
 #include <linux/ethtool.h>
+#include <linux/if_vlan.h>
 #include <linux/if_bonding.h>
 #include "bonding.h"
 #include "bond_3ad.h"
@@ -620,6 +621,330 @@ static const char *bond_mode_name(int mo
 	}
 }
 
+/*---------------------------------- VLAN -----------------------------------*/
+
+/**
+ * bond_add_vlan - add a new vlan id on bond
+ * @bond: bond that got the notification
+ * @vlan_id: the vlan id to add
+ *
+ * Returns -ENOMEM if allocation failed.
+ */
+static int bond_add_vlan(struct bonding *bond, unsigned short vlan_id)
+{
+	struct vlan_entry *vlan;
+
+	dprintk("bond: %s, vlan id %d\n",
+		(bond ? bond->dev->name: "None"), vlan_id);
+
+	vlan = kmalloc(sizeof(struct vlan_entry), GFP_KERNEL);
+	if (!vlan) {
+		return -ENOMEM;
+	}
+
+	INIT_LIST_HEAD(&vlan->vlan_list);
+	vlan->vlan_id = vlan_id;
+
+	write_lock_bh(&bond->lock);
+
+	list_add_tail(&vlan->vlan_list, &bond->vlan_list);
+
+	write_unlock_bh(&bond->lock);
+
+	dprintk("added VLAN ID %d on bond %s\n", vlan_id, bond->dev->name);
+
+	return 0;
+}
+
+/**
+ * bond_del_vlan - delete a vlan id from bond
+ * @bond: bond that got the notification
+ * @vlan_id: the vlan id to delete
+ *
+ * returns -ENODEV if @vlan_id was not found in @bond.
+ */
+static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
+{
+	struct vlan_entry *vlan, *next;
+	int res = -ENODEV;
+
+	dprintk("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
+
+	write_lock_bh(&bond->lock);
+
+	list_for_each_entry_safe(vlan, next, &bond->vlan_list, vlan_list) {
+		if (vlan->vlan_id == vlan_id) {
+			list_del(&vlan->vlan_list);
+
+			dprintk("removed VLAN ID %d from bond %s\n", vlan_id,
+				bond->dev->name);
+
+			kfree(vlan);
+
+			if (list_empty(&bond->vlan_list) &&
+			    (bond->slave_cnt == 0)) {
+				/* Last VLAN removed and no slaves, so
+				 * restore block on adding VLANs. This will
+				 * be removed once new slaves that are not
+				 * VLAN challenged will be added.
+				 */
+				bond->dev->features |= NETIF_F_VLAN_CHALLENGED;
+			}
+
+			res = 0;
+			goto out;
+		}
+	}
+
+	dprintk("couldn't find VLAN ID %d in bond %s\n", vlan_id,
+		bond->dev->name);
+
+out:
+	write_unlock_bh(&bond->lock);
+	return res;
+}
+
+/**
+ * bond_has_challenged_slaves
+ * @bond: the bond we're working on
+ *
+ * Searches the slave list. Returns 1 if a vlan challenged slave
+ * was found, 0 otherwise.
+ *
+ * Assumes bond->lock is held.
+ */
+static int bond_has_challenged_slaves(struct bonding *bond)
+{
+	struct slave *slave;
+	int i;
+
+	bond_for_each_slave(bond, slave, i) {
+		if (slave->dev->features & NETIF_F_VLAN_CHALLENGED) {
+			dprintk("found VLAN challenged slave - %s\n",
+				slave->dev->name);
+			return 1;
+		}
+	}
+
+	dprintk("no VLAN challenged slaves found\n");
+	return 0;
+}
+
+/**
+ * bond_dev_queue_xmit - Prepare skb for xmit.
+ * 
+ * @bond: bond device that got this skb for tx.
+ * @skb: hw accel VLAN tagged skb to transmit
+ * @slave_dev: slave that is supposed to xmit this skbuff
+ * 
+ * When the bond gets an skb to tarnsmit that is
+ * already hardware accelerated VLAN tagged, and it
+ * needs to relay this skb to a slave that is not
+ * hw accel capable, the skb needs to be "unaccelerated",
+ * i.e. strip the hwaccel tag and re-insert it as part
+ * of the payload.
+ * 
+ * Assumption - once a VLAN device is created over the bond device, all
+ * packets are going to be hardware accelerated VLAN tagged since the IP
+ * binding is done over the VLAN device
+ */
+int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev)
+{
+	unsigned short vlan_id;
+	int res;
+
+	if (!list_empty(&bond->vlan_list) &&
+	    !(slave_dev->features & NETIF_F_HW_VLAN_TX)) {
+		res = vlan_get_tag(skb, &vlan_id);
+		if (res) {
+			return -EINVAL;
+		}
+
+		skb->dev = slave_dev;
+		skb = vlan_put_tag(skb, vlan_id);
+		if (!skb) {
+			/* vlan_put_tag() frees the skb in case of error,
+			 * so return success here so the calling functions
+			 * won't attempt to free is again.
+			 */
+			return 0;
+		}
+	} else {
+		skb->dev = slave_dev;
+	}
+
+	skb->priority = 1;
+	dev_queue_xmit(skb);
+
+	return 0;
+}
+
+/*
+ * In the following 3 functions, bond_vlan_rx_register(), bond_vlan_rx_add_vid
+ * and bond_vlan_rx_kill_vid, We don't protect the slave list iteration with a
+ * lock because:
+ * a. This operation is performed in IOCTL context,
+ * b. The operation is protected by the RTNL semaphore in the 8021q code,
+ * c. Holding a lock with BH disabled while directly calling a base driver
+ *    entry point is generally a BAD idea.
+ * 
+ * The design of synchronization/protection for this operation in the 8021q
+ * module is good for one or more VLAN devices over a single physical device
+ * and cannot be extended for a teaming solution like bonding, so there is a
+ * potential race condition here where a net device from the vlan group might
+ * be referenced (either by a base driver or the 8021q code) while it is being
+ * removed from the system. However, it turns out we're not making matters
+ * worse, and if it works for regular VLAN usage it will work here too.
+*/
+
+/**
+ * bond_vlan_rx_register - Propagates registration to slaves
+ * @bond_dev: bonding net device that got called
+ * @grp: vlan group being registered
+ */
+static void bond_vlan_rx_register(struct net_device *bond_dev, struct vlan_group *grp)
+{
+	struct bonding *bond = bond_dev->priv;
+	struct slave *slave;
+	int i;
+
+	bond->vlgrp = grp;
+
+	bond_for_each_slave(bond, slave, i) {
+		struct net_device *slave_dev = slave->dev;
+
+		if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
+		    slave_dev->vlan_rx_register) {
+			slave_dev->vlan_rx_register(slave_dev, grp);
+		}
+	}
+}
+
+/**
+ * bond_vlan_rx_add_vid - Propagates adding an id to slaves
+ * @bond_dev: bonding net device that got called
+ * @vid: vlan id being added
+ */
+static void bond_vlan_rx_add_vid(struct net_device *bond_dev, uint16_t vid)
+{
+	struct bonding *bond = bond_dev->priv;
+	struct slave *slave;
+	int i, res;
+
+	bond_for_each_slave(bond, slave, i) {
+		struct net_device *slave_dev = slave->dev;
+
+		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
+		    slave_dev->vlan_rx_add_vid) {
+			slave_dev->vlan_rx_add_vid(slave_dev, vid);
+		}
+	}
+
+	res = bond_add_vlan(bond, vid);
+	if (res) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Failed to add vlan id %d\n",
+		       bond_dev->name, vid);
+	}
+}
+
+/**
+ * bond_vlan_rx_kill_vid - Propagates deleting an id to slaves
+ * @bond_dev: bonding net device that got called
+ * @vid: vlan id being removed
+ */
+static void bond_vlan_rx_kill_vid(struct net_device *bond_dev, uint16_t vid)
+{
+	struct bonding *bond = bond_dev->priv;
+	struct slave *slave;
+	struct net_device *vlan_dev;
+	int i, res;
+
+	bond_for_each_slave(bond, slave, i) {
+		struct net_device *slave_dev = slave->dev;
+
+		if ((slave_dev->features & NETIF_F_HW_VLAN_FILTER) &&
+		    slave_dev->vlan_rx_kill_vid) {
+			/* Save and then restore vlan_dev in the grp array,
+			 * since the slave's driver might clear it.
+			 */
+			vlan_dev = bond->vlgrp->vlan_devices[vid];
+			slave_dev->vlan_rx_kill_vid(slave_dev, vid);
+			bond->vlgrp->vlan_devices[vid] = vlan_dev;
+		}
+	}
+
+	res = bond_del_vlan(bond, vid);
+	if (res) {
+		printk(KERN_ERR DRV_NAME
+		       ": %s: Failed to remove vlan id %d\n",
+		       bond_dev->name, vid);
+	}
+}
+
+static void bond_add_vlans_on_slave(struct bonding *bond, struct net_device *slave_dev)
+{
+	struct vlan_entry *vlan;
+
+	write_lock_bh(&bond->lock);
+
+	if (list_empty(&bond->vlan_list)) {
+		goto out;
+	}
+
+	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
+	    slave_dev->vlan_rx_register) {
+		slave_dev->vlan_rx_register(slave_dev, bond->vlgrp);
+	}
+
+	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
+	    !(slave_dev->vlan_rx_add_vid)) {
+		goto out;
+	}
+
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		slave_dev->vlan_rx_add_vid(slave_dev, vlan->vlan_id);
+	}
+
+out:
+	write_unlock_bh(&bond->lock);
+}
+
+static void bond_del_vlans_from_slave(struct bonding *bond, struct net_device *slave_dev)
+{
+	struct vlan_entry *vlan;
+	struct net_device *vlan_dev;
+
+	write_lock_bh(&bond->lock);
+
+	if (list_empty(&bond->vlan_list)) {
+		goto out;
+	}
+
+	if (!(slave_dev->features & NETIF_F_HW_VLAN_FILTER) ||
+	    !(slave_dev->vlan_rx_kill_vid)) {
+		goto unreg;
+	}
+
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
+		/* Save and then restore vlan_dev in the grp array,
+		 * since the slave's driver might clear it.
+		 */
+		vlan_dev = bond->vlgrp->vlan_devices[vlan->vlan_id];
+		slave_dev->vlan_rx_kill_vid(slave_dev, vlan->vlan_id);
+		bond->vlgrp->vlan_devices[vlan->vlan_id] = vlan_dev;
+	}
+
+unreg:
+	if ((slave_dev->features & NETIF_F_HW_VLAN_RX) &&
+	    slave_dev->vlan_rx_register) {
+		slave_dev->vlan_rx_register(slave_dev, NULL);
+	}
+
+out:
+	write_unlock_bh(&bond->lock);
+}
+
 /*------------------------------- Link status -------------------------------*/
 
 /*
@@ -1214,6 +1539,7 @@ static int bond_enslave(struct net_devic
 	struct dev_mc_list *dmi;
 	struct sockaddr addr;
 	int link_reporting;
+	int old_features = bond_dev->features;
 	int res = 0;
 
 	if (slave_dev->do_ioctl == NULL) {
@@ -1234,6 +1560,36 @@ static int bond_enslave(struct net_devic
 		return -EBUSY;
 	}
 
+	/* vlan challenged mutual exclusion */
+	/* no need to lock since we're protected by rtnl_lock */
+	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
+		dprintk("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
+		if (!list_empty(&bond->vlan_list)) {
+			printk(KERN_ERR DRV_NAME
+			       ": Error: cannot enslave VLAN "
+			       "challenged slave %s on VLAN enabled "
+			       "bond %s\n", slave_dev->name,
+			       bond_dev->name);
+			return -EPERM;
+		} else {
+			printk(KERN_WARNING DRV_NAME
+			       ": Warning: enslaved VLAN challenged "
+			       "slave %s. Adding VLANs will be blocked as "
+			       "long as %s is part of bond %s\n",
+			       slave_dev->name, slave_dev->name,
+			       bond_dev->name);
+			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
+		}
+	} else {
+		dprintk("%s: ! NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
+		if (bond->slave_cnt == 0) {
+			/* First slave, and it is not VLAN challenged,
+			 * so remove the block of adding VLANs over the bond.
+			 */
+			bond_dev->features &= ~NETIF_F_VLAN_CHALLENGED;
+		}
+	}
+
 	if (app_abi_ver >= 1) {
 		/* The application is using an ABI, which requires the
 		 * slave interface to be closed.
@@ -1242,7 +1598,8 @@ static int bond_enslave(struct net_devic
 			printk(KERN_ERR DRV_NAME
 			       ": Error: %s is up\n",
 			       slave_dev->name);
-			return -EPERM;
+			res = -EPERM;
+			goto err_undo_flags;
 		}
 
 		if (slave_dev->set_mac_address == NULL) {
@@ -1253,7 +1610,8 @@ static int bond_enslave(struct net_devic
 			       "Your kernel likely does not support slave "
 			       "devices.\n");
 
-			return -EOPNOTSUPP;
+			res = -EOPNOTSUPP;
+			goto err_undo_flags;
 		}
 	} else {
 		/* The application is not using an ABI, which requires the
@@ -1263,7 +1621,8 @@ static int bond_enslave(struct net_devic
 			printk(KERN_ERR DRV_NAME
 			       ": Error: %s is not running\n",
 			       slave_dev->name);
-			return -EINVAL;
+			res = -EINVAL;
+			goto err_undo_flags;
 		}
 
 		if ((bond->params.mode == BOND_MODE_8023AD) ||
@@ -1273,13 +1632,15 @@ static int bond_enslave(struct net_devic
 			       ": Error: to use %s mode, you must upgrade "
 			       "ifenslave.\n",
 			       bond_mode_name(bond->params.mode));
-			return -EOPNOTSUPP;
+			res = -EOPNOTSUPP;
+			goto err_undo_flags;
 		}
 	}
 
 	new_slave = kmalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
-		return -ENOMEM;
+		res = -ENOMEM;
+		goto err_undo_flags;
 	}
 
 	memset(new_slave, 0, sizeof(struct slave));
@@ -1368,6 +1729,8 @@ static int bond_enslave(struct net_devic
 		dev_mc_add(slave_dev, lacpdu_multicast, ETH_ALEN, 0);
 	}
 
+	bond_add_vlans_on_slave(bond, slave_dev);
+
 	write_lock_bh(&bond->lock);
 
 	bond_attach_slave(bond, new_slave);
@@ -1576,6 +1939,10 @@ err_restore_mac:
 
 err_free:
 	kfree(new_slave);
+
+err_undo_flags:
+	bond_dev->features = old_features;
+
 	return res;
 }
 
@@ -1689,8 +2056,37 @@ static int bond_release(struct net_devic
 		}
 	}
 
+	if (bond->slave_cnt == 0) {
+		/* if the last slave was removed, zero the mac address
+		 * of the master so it will be set by the application
+		 * to the mac address of the first slave
+		 */
+		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
+
+		if (list_empty(&bond->vlan_list)) {
+			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
+		} else {
+			printk(KERN_WARNING DRV_NAME
+			       ": Warning: clearing HW address of %s while it "
+			       "still has VLANs.\n",
+			       bond_dev->name);
+			printk(KERN_WARNING DRV_NAME
+			       ": When re-adding slaves, make sure the bond's "
+			       "HW address matches its VLANs'.\n");
+		}
+	} else if ((bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
+		   !bond_has_challenged_slaves(bond)) {
+		printk(KERN_INFO DRV_NAME
+		       ": last VLAN challenged slave %s "
+		       "left bond %s. VLAN blocking is removed\n",
+		       slave_dev->name, bond_dev->name);
+		bond_dev->features &= ~NETIF_F_VLAN_CHALLENGED;
+	}
+
 	write_unlock_bh(&bond->lock);
 
+	bond_del_vlans_from_slave(bond, slave_dev);
+
 	/* If the mode USES_PRIMARY, then we should only remove its
 	 * promisc and mc settings if it was the curr_active_slave, but that was
 	 * already taken care of above when we detached the slave
@@ -1732,14 +2128,6 @@ static int bond_release(struct net_devic
 
 	kfree(slave);
 
-	/* if the last slave was removed, zero the mac address
-	 * of the master so it will be set by the application
-	 * to the mac address of the first slave
-	 */
-	if (bond->slave_cnt == 0) {
-		memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
-	}
-
 	return 0;  /* deletion OK */
 }
 
@@ -1788,6 +2176,8 @@ static int bond_release_all(struct net_d
 		 */
 		write_unlock_bh(&bond->lock);
 
+		bond_del_vlans_from_slave(bond, slave_dev);
+
 		/* If the mode USES_PRIMARY, then we should only remove its
 		 * promisc and mc settings if it was the curr_active_slave, but that was
 		 * already taken care of above when we detached the slave
@@ -1838,6 +2228,18 @@ static int bond_release_all(struct net_d
 	 */
 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
+	if (list_empty(&bond->vlan_list)) {
+		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
+	} else {
+		printk(KERN_WARNING DRV_NAME
+		       ": Warning: clearing HW address of %s while it "
+		       "still has VLANs.\n",
+		       bond_dev->name);
+		printk(KERN_WARNING DRV_NAME
+		       ": When re-adding slaves, make sure the bond's "
+		       "HW address matches its VLANs'.\n");
+	}
+
 	printk(KERN_INFO DRV_NAME
 	       ": %s: released all slaves\n",
 	       bond_dev->name);
@@ -3570,11 +3972,12 @@ static int bond_xmit_roundrobin(struct s
 	struct bonding *bond = bond_dev->priv;
 	struct slave *slave, *start_at;
 	int i;
+	int res = 1;
 
 	read_lock(&bond->lock);
 
 	if (!BOND_IS_OK(bond)) {
-		goto free_out;
+		goto out;
 	}
 
 	read_lock(&bond->curr_slave_lock);
@@ -3582,33 +3985,31 @@ static int bond_xmit_roundrobin(struct s
 	read_unlock(&bond->curr_slave_lock);
 
 	if (!slave) {
-		goto free_out;
+		goto out;
 	}
 
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
 		    (slave->state == BOND_STATE_ACTIVE)) {
-			skb->dev = slave->dev;
-			skb->priority = 1;
-			dev_queue_xmit(skb);
+			res = bond_dev_queue_xmit(bond, skb, slave->dev);
 
 			write_lock(&bond->curr_slave_lock);
 			bond->curr_active_slave = slave->next;
 			write_unlock(&bond->curr_slave_lock);
 
-			goto out;
+			break;
 		}
 	}
 
+
 out:
+	if (res) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+	}
 	read_unlock(&bond->lock);
 	return 0;
-
-free_out:
-	/* no suitable interface, frame not sent */
-	dev_kfree_skb(skb);
-	goto out;
 }
 
 /*
@@ -3618,6 +4019,7 @@ free_out:
 static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_dev)
 {
 	struct bonding *bond = bond_dev->priv;
+	int res = 1;
 
 	/* if we are sending arp packets, try to at least
 	   identify our own ip address */
@@ -3634,26 +4036,21 @@ static int bond_xmit_activebackup(struct
 	read_lock(&bond->curr_slave_lock);
 
 	if (!BOND_IS_OK(bond)) {
-		goto free_out;
+		goto out;
 	}
 
 	if (bond->curr_active_slave) { /* one usable interface */
-		skb->dev = bond->curr_active_slave->dev;
-		skb->priority = 1;
-		dev_queue_xmit(skb);
-		goto out;
-	} else {
-		goto free_out;
+		res = bond_dev_queue_xmit(bond, skb, bond->curr_active_slave->dev);
 	}
+
 out:
+	if (res) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+	}
 	read_unlock(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
 	return 0;
-
-free_out:
-	/* no suitable interface, frame not sent */
-	dev_kfree_skb(skb);
-	goto out;
 }
 
 /*
@@ -3668,11 +4065,12 @@ static int bond_xmit_xor(struct sk_buff 
 	struct slave *slave, *start_at;
 	int slave_no;
 	int i;
+	int res = 1;
 
 	read_lock(&bond->lock);
 
 	if (!BOND_IS_OK(bond)) {
-		goto free_out;
+		goto out;
 	}
 
 	slave_no = (data->h_dest[5]^bond_dev->dev_addr[5]) % bond->slave_cnt;
@@ -3690,22 +4088,18 @@ static int bond_xmit_xor(struct sk_buff 
 		if (IS_UP(slave->dev) &&
 		    (slave->link == BOND_LINK_UP) &&
 		    (slave->state == BOND_STATE_ACTIVE)) {
-			skb->dev = slave->dev;
-			skb->priority = 1;
-			dev_queue_xmit(skb);
-
-			goto out;
+			res = bond_dev_queue_xmit(bond, skb, slave->dev);
+			break;
 		}
 	}
 
 out:
+	if (res) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+	}
 	read_unlock(&bond->lock);
 	return 0;
-
-free_out:
-	/* no suitable interface, frame not sent */
-	dev_kfree_skb(skb);
-	goto out;
 }
 
 /*
@@ -3717,11 +4111,12 @@ static int bond_xmit_broadcast(struct sk
 	struct slave *slave, *start_at;
 	struct net_device *tx_dev = NULL;
 	int i;
+	int res = 1;
 
 	read_lock(&bond->lock);
 
 	if (!BOND_IS_OK(bond)) {
-		goto free_out;
+		goto out;
 	}
 
 	read_lock(&bond->curr_slave_lock);
@@ -3729,7 +4124,7 @@ static int bond_xmit_broadcast(struct sk
 	read_unlock(&bond->curr_slave_lock);
 
 	if (!start_at) {
-		goto free_out;
+		goto out;
 	}
 
 	bond_for_each_slave_from(bond, slave, i, start_at) {
@@ -3745,31 +4140,28 @@ static int bond_xmit_broadcast(struct sk
 					continue;
 				}
 
-				skb2->dev = tx_dev;
-				skb2->priority = 1;
-				dev_queue_xmit(skb2);
+				res = bond_dev_queue_xmit(bond, skb2, tx_dev);
+				if (res) {
+					dev_kfree_skb(skb2);
+					continue;
+				}
 			}
 			tx_dev = slave->dev;
 		}
 	}
 
 	if (tx_dev) {
-		skb->dev = tx_dev;
-		skb->priority = 1;
-		dev_queue_xmit(skb);
-	} else {
-		goto free_out;
+		res = bond_dev_queue_xmit(bond, skb, tx_dev);
 	}
 
 out:
+	if (res) {
+		/* no suitable interface, frame not sent */
+		dev_kfree_skb(skb);
+	}
 	/* frame sent to all suitable interfaces */
 	read_unlock(&bond->lock);
 	return 0;
-
-free_out:
-	/* no suitable interface, frame not sent */
-	dev_kfree_skb(skb);
-	goto out;
 }
 
 #ifdef CONFIG_NET_FASTROUTE
@@ -3838,6 +4230,7 @@ static int __init bond_init(struct net_d
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
 	bond->dev = bond_dev;
+	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
 	bond_dev->open = bond_open;
@@ -3858,6 +4251,25 @@ static int __init bond_init(struct net_d
 	bond_dev->tx_queue_len = 0;
 	bond_dev->flags |= IFF_MASTER|IFF_MULTICAST;
 
+	/* At first, we block adding VLANs. That's the only way to
+	 * prevent problems that occur when adding VLANs over an
+	 * empty bond. The block will be removed once non-challenged
+	 * slaves are enslaved.
+	 */
+	bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
+
+	/* By default, we declare the bond to be fully
+	 * VLAN hardware accelerated capable. Special
+	 * care is taken in the various xmit functions
+	 * when there are slaves that are not hw accel
+	 * capable
+	 */
+	bond_dev->vlan_rx_register = bond_vlan_rx_register;
+	bond_dev->vlan_rx_add_vid  = bond_vlan_rx_add_vid;
+	bond_dev->vlan_rx_kill_vid = bond_vlan_rx_kill_vid;
+	bond_dev->features |= (NETIF_F_HW_VLAN_TX |
+			       NETIF_F_HW_VLAN_RX |
+			       NETIF_F_HW_VLAN_FILTER);
 
 #ifdef CONFIG_PROC_FS
 	bond_create_proc_entry(bond);
diff -Nuarp a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
--- a/drivers/net/bonding/bonding.h	Wed Jan 21 16:55:06 2004
+++ b/drivers/net/bonding/bonding.h	Wed Jan 21 16:55:08 2004
@@ -147,6 +147,11 @@ struct bond_params {
 	u32 arp_targets[BOND_MAX_ARP_TARGETS];
 };
 
+struct vlan_entry {
+	struct list_head vlan_list;
+	unsigned short vlan_id;
+};
+
 struct slave {
 	struct net_device *dev; /* first - usefull for panic debug */
 	struct slave *next;
@@ -196,6 +201,8 @@ struct bonding {
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
+	struct   list_head vlan_list;
+	struct   vlan_group *vlgrp;
 };
 
 /**
@@ -238,5 +245,7 @@ extern inline void bond_set_slave_active
 	slave->dev->flags &= ~IFF_NOARP;
 }
 
+int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
+
 #endif /* _LINUX_BONDING_H */
 

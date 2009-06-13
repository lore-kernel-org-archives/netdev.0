From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 5/9] bonding: fix style issues
Date: Fri, 12 Jun 2009 22:02:48 -0700
Message-ID: <20090613050421.921338955@vyatta.com>
References: <20090613050243.100086546@vyatta.com>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net
To: Jay Vosburg <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49238 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753732AbZFMFGS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Jun 2009 01:06:18 -0400
Content-Disposition: inline; filename=bond-trivial.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Resolve some of the complaints from checkpatch, and remove "magic emacs format"
comments, and useless MODULE_SUPPORTED_DEVICE(). But should not
change actual code.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 drivers/net/bonding/bond_main.c  |  633 +++++++++++++++++----------------------
 drivers/net/bonding/bond_sysfs.c |  324 ++++++++++---------
 2 files changed, 460 insertions(+), 497 deletions(-)

--- a/drivers/net/bonding/bond_main.c	2009-06-12 21:45:37.932394640 -0700
+++ b/drivers/net/bonding/bond_main.c	2009-06-12 21:46:22.182394769 -0700
@@ -51,10 +51,10 @@
 #include <linux/ctype.h>
 #include <linux/inet.h>
 #include <linux/bitops.h>
+#include <linux/io.h>
 #include <asm/system.h>
-#include <asm/io.h>
 #include <asm/dma.h>
-#include <asm/uaccess.h>
+#include <linux/uaccess.h>
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
@@ -89,18 +89,18 @@ static int max_bonds	= BOND_DEFAULT_MAX_
 static int num_grat_arp = 1;
 static int num_unsol_na = 1;
 static int miimon	= BOND_LINK_MON_INTERV;
-static int updelay	= 0;
-static int downdelay	= 0;
+static int updelay;
+static int downdelay;
 static int use_carrier	= 1;
-static char *mode	= NULL;
-static char *primary	= NULL;
-static char *lacp_rate	= NULL;
-static char *ad_select  = NULL;
-static char *xmit_hash_policy = NULL;
+static char *mode;
+static char *primary;
+static char *lacp_rate;
+static char *ad_select;
+static char *xmit_hash_policy;
 static int arp_interval = BOND_LINK_ARP_INTERV;
-static char *arp_ip_target[BOND_MAX_ARP_TARGETS] = { NULL, };
-static char *arp_validate = NULL;
-static char *fail_over_mac = NULL;
+static char *arp_ip_target[BOND_MAX_ARP_TARGETS];
+static char *arp_validate;
+static char *fail_over_mac;
 static struct bond_params bonding_defaults;
 
 module_param(max_bonds, int, 0);
@@ -151,14 +151,14 @@ static const char * const version =
 LIST_HEAD(bond_dev_list);
 
 #ifdef CONFIG_PROC_FS
-static struct proc_dir_entry *bond_proc_dir = NULL;
+static struct proc_dir_entry *bond_proc_dir;
 #endif
 
-static __be32 arp_target[BOND_MAX_ARP_TARGETS] = { 0, } ;
-static int arp_ip_count	= 0;
+static __be32 arp_target[BOND_MAX_ARP_TARGETS];
+static int arp_ip_count;
 static int bond_mode	= BOND_MODE_ROUNDROBIN;
-static int xmit_hashtype= BOND_XMIT_POLICY_LAYER2;
-static int lacp_fast	= 0;
+static int xmit_hashtype = BOND_XMIT_POLICY_LAYER2;
+static int lacp_fast;
 
 
 const struct bond_parm_tbl bond_lacp_tbl[] = {
@@ -221,7 +221,7 @@ static const char *bond_mode_name(int mo
 		[BOND_MODE_ACTIVEBACKUP] = "fault-tolerance (active-backup)",
 		[BOND_MODE_XOR] = "load balancing (xor)",
 		[BOND_MODE_BROADCAST] = "fault-tolerance (broadcast)",
-		[BOND_MODE_8023AD]= "IEEE 802.3ad Dynamic link aggregation",
+		[BOND_MODE_8023AD] = "IEEE 802.3ad Dynamic link aggregation",
 		[BOND_MODE_TLB] = "transmit load balancing",
 		[BOND_MODE_ALB] = "adaptive load balancing",
 	};
@@ -246,12 +246,11 @@ static int bond_add_vlan(struct bonding 
 	struct vlan_entry *vlan;
 
 	pr_debug("bond: %s, vlan id %d\n",
-		(bond ? bond->dev->name: "None"), vlan_id);
+		(bond ? bond->dev->name : "None"), vlan_id);
 
 	vlan = kzalloc(sizeof(struct vlan_entry), GFP_KERNEL);
-	if (!vlan) {
+	if (!vlan)
 		return -ENOMEM;
-	}
 
 	INIT_LIST_HEAD(&vlan->vlan_list);
 	vlan->vlan_id = vlan_id;
@@ -351,16 +350,15 @@ static int bond_has_challenged_slaves(st
  *
  * Returns %NULL if list is empty, bond->next_vlan if @curr is %NULL,
  * or @curr->next otherwise (even if it is @curr itself again).
- * 
+ *
  * Caller must hold bond->lock
  */
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
 {
 	struct vlan_entry *next, *last;
 
-	if (list_empty(&bond->vlan_list)) {
+	if (list_empty(&bond->vlan_list))
 		return NULL;
-	}
 
 	if (!curr) {
 		next = list_entry(bond->vlan_list.next,
@@ -382,11 +380,11 @@ struct vlan_entry *bond_next_vlan(struct
 
 /**
  * bond_dev_queue_xmit - Prepare skb for xmit.
- * 
+ *
  * @bond: bond device that got this skb for tx.
  * @skb: hw accel VLAN tagged skb to transmit
  * @slave_dev: slave that is supposed to xmit this skbuff
- * 
+ *
  * When the bond gets an skb to transmit that is
  * already hardware accelerated VLAN tagged, and it
  * needs to relay this skb to a slave that is not
@@ -394,7 +392,8 @@ struct vlan_entry *bond_next_vlan(struct
  * i.e. strip the hwaccel tag and re-insert it as part
  * of the payload.
  */
-int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev)
+int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
+			struct net_device *slave_dev)
 {
 	unsigned short uninitialized_var(vlan_id);
 
@@ -428,7 +427,7 @@ int bond_dev_queue_xmit(struct bonding *
  * b. The operation is protected by the RTNL semaphore in the 8021q code,
  * c. Holding a lock with BH disabled while directly calling a base driver
  *    entry point is generally a BAD idea.
- * 
+ *
  * The design of synchronization/protection for this operation in the 8021q
  * module is good for one or more VLAN devices over a single physical device
  * and cannot be extended for a teaming solution like bonding, so there is a
@@ -443,7 +442,8 @@ int bond_dev_queue_xmit(struct bonding *
  * @bond_dev: bonding net device that got called
  * @grp: vlan group being registered
  */
-static void bond_vlan_rx_register(struct net_device *bond_dev, struct vlan_group *grp)
+static void bond_vlan_rx_register(struct net_device *bond_dev,
+				  struct vlan_group *grp)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
@@ -485,7 +485,7 @@ static void bond_vlan_rx_add_vid(struct 
 
 	res = bond_add_vlan(bond, vid);
 	if (res) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: Failed to add vlan id %d\n",
 		       bond_dev->name, vid);
 	}
@@ -520,7 +520,7 @@ static void bond_vlan_rx_kill_vid(struct
 
 	res = bond_del_vlan(bond, vid);
 	if (res) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: Failed to remove vlan id %d\n",
 		       bond_dev->name, vid);
 	}
@@ -551,7 +551,8 @@ out:
 	write_unlock_bh(&bond->lock);
 }
 
-static void bond_del_vlans_from_slave(struct bonding *bond, struct net_device *slave_dev)
+static void bond_del_vlans_from_slave(struct bonding *bond,
+				      struct net_device *slave_dev)
 {
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
 	struct vlan_entry *vlan;
@@ -673,7 +674,7 @@ static int bond_update_speed_duplex(stru
  * if <dev> supports MII link status reporting, check its link status.
  *
  * We either do MII/ETHTOOL ioctls, or check netif_carrier_ok(),
- * depening upon the setting of the use_carrier parameter.
+ * depending upon the setting of the use_carrier parameter.
  *
  * Return either BMSR_LSTATUS, meaning that the link is up (or we
  * can't tell and just pretend it is), or 0, meaning that the link is
@@ -685,10 +686,11 @@ static int bond_update_speed_duplex(stru
  * It'd be nice if there was a good way to tell if a driver supports
  * netif_carrier, but there really isn't.
  */
-static int bond_check_dev_link(struct bonding *bond, struct net_device *slave_dev, int reporting)
+static int bond_check_dev_link(struct bonding *bond,
+			       struct net_device *slave_dev, int reporting)
 {
 	const struct net_device_ops *slave_ops = slave_dev->netdev_ops;
-	static int (* ioctl)(struct net_device *, struct ifreq *, int);
+	static int (*ioctl)(struct net_device *, struct ifreq *, int);
 	struct ifreq ifr;
 	struct mii_ioctl_data *mii;
 
@@ -706,7 +708,7 @@ static int bond_check_dev_link(struct bo
 		}
 	}
 
-	/* Ethtool can't be used, fallback to MII ioclts. */
+	/* Ethtool can't be used, fallback to MII ioctls. */
 	ioctl = slave_ops->ndo_do_ioctl;
 	if (ioctl) {
 		/* TODO: set pointer to correct ioctl on a per team member */
@@ -726,9 +728,8 @@ static int bond_check_dev_link(struct bo
 		mii = if_mii(&ifr);
 		if (IOCTL(slave_dev, &ifr, SIOCGMIIPHY) == 0) {
 			mii->reg_num = MII_BMSR;
-			if (IOCTL(slave_dev, &ifr, SIOCGMIIREG) == 0) {
-				return (mii->val_out & BMSR_LSTATUS);
-			}
+			if (IOCTL(slave_dev, &ifr, SIOCGMIIREG) == 0)
+				return mii->val_out & BMSR_LSTATUS;
 		}
 	}
 
@@ -738,7 +739,7 @@ static int bond_check_dev_link(struct bo
 	 * cannot report link status).  If not reporting, pretend
 	 * we're ok.
 	 */
-	return (reporting ? -1 : BMSR_LSTATUS);
+	return reporting ? -1 : BMSR_LSTATUS;
 }
 
 /*----------------------------- Multicast list ------------------------------*/
@@ -746,7 +747,8 @@ static int bond_check_dev_link(struct bo
 /*
  * Returns 0 if dmi1 and dmi2 are the same, non-0 otherwise
  */
-static inline int bond_is_dmi_same(struct dev_mc_list *dmi1, struct dev_mc_list *dmi2)
+static inline int bond_is_dmi_same(const struct dev_mc_list *dmi1,
+				   const struct dev_mc_list *dmi2)
 {
 	return memcmp(dmi1->dmi_addr, dmi2->dmi_addr, dmi1->dmi_addrlen) == 0 &&
 			dmi1->dmi_addrlen == dmi2->dmi_addrlen;
@@ -755,14 +757,14 @@ static inline int bond_is_dmi_same(struc
 /*
  * returns dmi entry if found, NULL otherwise
  */
-static struct dev_mc_list *bond_mc_list_find_dmi(struct dev_mc_list *dmi, struct dev_mc_list *mc_list)
+static struct dev_mc_list *bond_mc_list_find_dmi(struct dev_mc_list *dmi,
+						 struct dev_mc_list *mc_list)
 {
 	struct dev_mc_list *idmi;
 
 	for (idmi = mc_list; idmi; idmi = idmi->next) {
-		if (bond_is_dmi_same(dmi, idmi)) {
+		if (bond_is_dmi_same(dmi, idmi))
 			return idmi;
-		}
 	}
 
 	return NULL;
@@ -824,15 +826,14 @@ static void bond_mc_add(struct bonding *
 {
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
-		if (bond->curr_active_slave) {
+		if (bond->curr_active_slave)
 			dev_mc_add(bond->curr_active_slave->dev, addr, alen, 0);
-		}
 	} else {
 		struct slave *slave;
 		int i;
-		bond_for_each_slave(bond, slave, i) {
+
+		bond_for_each_slave(bond, slave, i)
 			dev_mc_add(slave->dev, addr, alen, 0);
-		}
 	}
 }
 
@@ -844,9 +845,9 @@ static void bond_mc_delete(struct bondin
 {
 	if (USES_PRIMARY(bond->params.mode)) {
 		/* write lock already acquired */
-		if (bond->curr_active_slave) {
-			dev_mc_delete(bond->curr_active_slave->dev, addr, alen, 0);
-		}
+		if (bond->curr_active_slave)
+			dev_mc_delete(bond->curr_active_slave->dev, addr,
+				      alen, 0);
 	} else {
 		struct slave *slave;
 		int i;
@@ -870,9 +871,8 @@ static void bond_resend_igmp_join_reques
 	rcu_read_lock();
 	in_dev = __in_dev_get_rcu(bond->dev);
 	if (in_dev) {
-		for (im = in_dev->mc_list; im; im = im->next) {
+		for (im = in_dev->mc_list; im; im = im->next)
 			ip_mc_rejoin_group(im);
-		}
 	}
 
 	rcu_read_unlock();
@@ -891,7 +891,8 @@ static void bond_mc_list_destroy(struct 
 		kfree(dmi);
 		dmi = bond->mc_list;
 	}
-        bond->mc_list = NULL;
+
+	bond->mc_list = NULL;
 }
 
 /*
@@ -924,14 +925,14 @@ static int bond_mc_list_copy(struct dev_
 /*
  * flush all members of flush->mc_list from device dev->mc_list
  */
-static void bond_mc_list_flush(struct net_device *bond_dev, struct net_device *slave_dev)
+static void bond_mc_list_flush(struct net_device *bond_dev,
+			       struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct dev_mc_list *dmi;
 
-	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
+	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next)
 		dev_mc_delete(slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-	}
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		/* del lacpdu mc addr from mc list */
@@ -948,44 +949,40 @@ static void bond_mc_list_flush(struct ne
  * old active slaves (if any) according to the multicast mode, and
  * promiscuous flags unconditionally.
  */
-static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct slave *old_active)
+static void bond_mc_swap(struct bonding *bond, struct slave *new_active,
+			 struct slave *old_active)
 {
 	struct dev_mc_list *dmi;
 
-	if (!USES_PRIMARY(bond->params.mode)) {
+	if (!USES_PRIMARY(bond->params.mode))
 		/* nothing to do -  mc list is already up-to-date on
 		 * all slaves
 		 */
 		return;
-	}
 
 	if (old_active) {
-		if (bond->dev->flags & IFF_PROMISC) {
+		if (bond->dev->flags & IFF_PROMISC)
 			dev_set_promiscuity(old_active->dev, -1);
-		}
 
-		if (bond->dev->flags & IFF_ALLMULTI) {
+		if (bond->dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(old_active->dev, -1);
-		}
 
-		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next) {
-			dev_mc_delete(old_active->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-		}
+		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next)
+			dev_mc_delete(old_active->dev, dmi->dmi_addr,
+				      dmi->dmi_addrlen, 0);
 	}
 
 	if (new_active) {
 		/* FIXME: Signal errors upstream. */
-		if (bond->dev->flags & IFF_PROMISC) {
+		if (bond->dev->flags & IFF_PROMISC)
 			dev_set_promiscuity(new_active->dev, 1);
-		}
 
-		if (bond->dev->flags & IFF_ALLMULTI) {
+		if (bond->dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(new_active->dev, 1);
-		}
 
-		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next) {
-			dev_mc_add(new_active->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-		}
+		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next)
+			dev_mc_add(new_active->dev, dmi->dmi_addr,
+				   dmi->dmi_addrlen, 0);
 		bond_resend_igmp_join_requests(bond);
 	}
 }
@@ -1039,7 +1036,7 @@ static void bond_do_fail_over_mac(struct
 
 		rv = dev_set_mac_address(new_active->dev, &saddr);
 		if (rv) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: Error %d setting MAC of slave %s\n",
 			       bond->dev->name, -rv, new_active->dev->name);
 			goto out;
@@ -1053,7 +1050,7 @@ static void bond_do_fail_over_mac(struct
 
 		rv = dev_set_mac_address(old_active->dev, &saddr);
 		if (rv)
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: Error %d setting MAC of slave %s\n",
 			       bond->dev->name, -rv, new_active->dev->name);
 out:
@@ -1061,7 +1058,7 @@ out:
 		write_lock_bh(&bond->curr_slave_lock);
 		break;
 	default:
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: bond_do_fail_over_mac impossible: bad policy %d\n",
 		       bond->dev->name, bond->params.fail_over_mac);
 		break;
@@ -1086,17 +1083,17 @@ static struct slave *bond_find_best_slav
 	new_active = old_active = bond->curr_active_slave;
 
 	if (!new_active) { /* there were no active slaves left */
-		if (bond->slave_cnt > 0) {  /* found one slave */
+		if (bond->slave_cnt > 0)   /* found one slave */
 			new_active = bond->first_slave;
-		} else {
+		else
 			return NULL; /* still no slave, return NULL */
-		}
 	}
 
-	/* first try the primary link; if arping, a link must tx/rx traffic
-	 * before it can be considered the curr_active_slave - also, we would skip
-	 * slaves between the curr_active_slave and primary_slave that may be up
-	 * and able to arp
+	/*
+	 * first try the primary link; if arping, a link must tx/rx
+	 * traffic before it can be considered the curr_active_slave.
+	 * also, we would skip slaves between the curr_active_slave
+	 * and primary_slave that may be up and able to arp
 	 */
 	if ((bond->primary_slave) &&
 	    (!bond->params.arp_interval) &&
@@ -1144,16 +1141,15 @@ void bond_change_active_slave(struct bon
 {
 	struct slave *old_active = bond->curr_active_slave;
 
-	if (old_active == new_active) {
+	if (old_active == new_active)
 		return;
-	}
 
 	if (new_active) {
 		new_active->jiffies = jiffies;
 
 		if (new_active->link == BOND_LINK_BACK) {
 			if (USES_PRIMARY(bond->params.mode)) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: making interface %s the new "
 				       "active one %d ms earlier.\n",
 				       bond->dev->name, new_active->dev->name,
@@ -1163,15 +1159,14 @@ void bond_change_active_slave(struct bon
 			new_active->delay = 0;
 			new_active->link = BOND_LINK_UP;
 
-			if (bond->params.mode == BOND_MODE_8023AD) {
+			if (bond->params.mode == BOND_MODE_8023AD)
 				bond_3ad_handle_link_change(new_active, BOND_LINK_UP);
-			}
 
 			if (bond_is_lb(bond))
 				bond_alb_handle_link_change(bond, new_active, BOND_LINK_UP);
 		} else {
 			if (USES_PRIMARY(bond->params.mode)) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: making interface %s the new "
 				       "active one.\n",
 				       bond->dev->name, new_active->dev->name);
@@ -1179,9 +1174,8 @@ void bond_change_active_slave(struct bon
 		}
 	}
 
-	if (USES_PRIMARY(bond->params.mode)) {
+	if (USES_PRIMARY(bond->params.mode))
 		bond_mc_swap(bond, new_active, old_active);
-	}
 
 	if (bond_is_lb(bond)) {
 		bond_alb_handle_active_change(bond, new_active);
@@ -1194,9 +1188,8 @@ void bond_change_active_slave(struct bon
 	}
 
 	if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
-		if (old_active) {
+		if (old_active)
 			bond_set_slave_inactive_flags(old_active);
-		}
 
 		if (new_active) {
 			bond_set_slave_active_flags(new_active);
@@ -1226,7 +1219,7 @@ void bond_change_active_slave(struct bon
  * bond_select_active_slave - select a new active slave, if needed
  * @bond: our bonding struct
  *
- * This functions shoud be called when one of the following occurs:
+ * This functions should be called when one of the following occurs:
  * - The old curr_active_slave has been released or lost its link.
  * - The primary_slave has got its link back.
  * - A slave has got its link back and there's no old curr_active_slave.
@@ -1246,11 +1239,11 @@ void bond_select_active_slave(struct bon
 			return;
 
 		if (netif_carrier_ok(bond->dev)) {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: first active interface up!\n",
 			       bond->dev->name);
 		} else {
-			printk(KERN_INFO DRV_NAME ": %s: "
+			pr_info(DRV_NAME ": %s: "
 			       "now running without any active interface !\n",
 			       bond->dev->name);
 		}
@@ -1292,13 +1285,11 @@ static void bond_attach_slave(struct bon
  */
 static void bond_detach_slave(struct bonding *bond, struct slave *slave)
 {
-	if (slave->next) {
+	if (slave->next)
 		slave->next->prev = slave->prev;
-	}
 
-	if (slave->prev) {
+	if (slave->prev)
 		slave->prev->next = slave->next;
-	}
 
 	if (bond->first_slave == slave) { /* slave is the first slave */
 		if (bond->slave_cnt > 1) { /* there are more slave */
@@ -1329,7 +1320,7 @@ static int bond_sethwaddr(struct net_dev
 	(NETIF_F_VLAN_CHALLENGED | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX | \
 	 NETIF_F_HW_VLAN_FILTER)
 
-/* 
+/*
  * Compute the common dev->feature set available to all slaves.  Some
  * feature bits are managed elsewhere, so preserve those feature bits
  * on the master device.
@@ -1397,14 +1388,14 @@ int bond_enslave(struct net_device *bond
 
 	if (!bond->params.use_carrier && slave_dev->ethtool_ops == NULL &&
 		slave_ops->ndo_do_ioctl == NULL) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": %s: Warning: no link monitoring support for %s\n",
 		       bond_dev->name, slave_dev->name);
 	}
 
 	/* bond must be initialized by bond_open() before enslaving */
 	if (!(bond_dev->flags & IFF_UP)) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 			" %s: master_dev is not up in bond_enslave\n",
 			bond_dev->name);
 	}
@@ -1420,14 +1411,14 @@ int bond_enslave(struct net_device *bond
 	if (slave_dev->features & NETIF_F_VLAN_CHALLENGED) {
 		pr_debug("%s: NETIF_F_VLAN_CHALLENGED\n", slave_dev->name);
 		if (!list_empty(&bond->vlan_list)) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: Error: cannot enslave VLAN "
 			       "challenged slave %s on VLAN enabled "
 			       "bond %s\n", bond_dev->name, slave_dev->name,
 			       bond_dev->name);
 			return -EPERM;
 		} else {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: Warning: enslaved VLAN challenged "
 			       "slave %s. Adding VLANs will be blocked as "
 			       "long as %s is part of bond %s\n",
@@ -1447,12 +1438,12 @@ int bond_enslave(struct net_device *bond
 
 	/*
 	 * Old ifenslave binaries are no longer supported.  These can
-	 * be identified with moderate accurary by the state of the slave:
+	 * be identified with moderate accuracy by the state of the slave:
 	 * the current ifenslave will set the interface down prior to
 	 * enslaving it; the old ifenslave will not.
 	 */
 	if ((slave_dev->flags & IFF_UP)) {
-		printk(KERN_ERR DRV_NAME ": %s is up. "
+		pr_err(DRV_NAME ": %s is up. "
 		       "This may be due to an out of date ifenslave.\n",
 		       slave_dev->name);
 		res = -EPERM;
@@ -1470,7 +1461,7 @@ int bond_enslave(struct net_device *bond
 		if (slave_dev->type != ARPHRD_ETHER)
 			bond_setup_by_slave(bond_dev, slave_dev);
 	} else if (bond_dev->type != slave_dev->type) {
-		printk(KERN_ERR DRV_NAME ": %s ether type (%d) is different "
+		pr_err(DRV_NAME ": %s ether type (%d) is different "
 			"from other slaves (%d), can not enslave it.\n",
 			slave_dev->name,
 			slave_dev->type, bond_dev->type);
@@ -1480,14 +1471,14 @@ int bond_enslave(struct net_device *bond
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
 		if (bond->slave_cnt == 0) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: Warning: The first slave device "
 			       "specified does not support setting the MAC "
 			       "address. Setting fail_over_mac to active.",
 			       bond_dev->name);
 			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
 		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 				": %s: Error: The slave device specified "
 				"does not support setting the MAC address, "
 				"but fail_over_mac is not set to active.\n"
@@ -1537,7 +1528,7 @@ int bond_enslave(struct net_device *bond
 	/* open the slave since the application closed it */
 	res = dev_open(slave_dev);
 	if (res) {
-		pr_debug("Openning slave %s failed\n", slave_dev->name);
+		pr_debug("Opening slave %s failed\n", slave_dev->name);
 		goto err_unset_master;
 	}
 
@@ -1549,9 +1540,8 @@ int bond_enslave(struct net_device *bond
 		 * it might fail and we do not want to have to undo everything
 		 */
 		res = bond_alb_init_slave(bond, new_slave);
-		if (res) {
+		if (res)
 			goto err_close;
-		}
 	}
 
 	/* If the mode USES_PRIMARY, then the new slave gets the
@@ -1576,9 +1566,9 @@ int bond_enslave(struct net_device *bond
 
 		netif_addr_lock_bh(bond_dev);
 		/* upload master's mc_list to new slave */
-		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
-			dev_mc_add (slave_dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
-		}
+		for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next)
+			dev_mc_add(slave_dev, dmi->dmi_addr,
+				   dmi->dmi_addrlen, 0);
 		netif_addr_unlock_bh(bond_dev);
 	}
 
@@ -1619,7 +1609,7 @@ int bond_enslave(struct net_device *bond
 			 * supported); thus, we don't need to change
 			 * the messages for netif_carrier.
 			 */
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: Warning: MII and ETHTOOL support not "
 			       "available for interface %s, and "
 			       "arp_interval/arp_ip_target module parameters "
@@ -1628,7 +1618,7 @@ int bond_enslave(struct net_device *bond
 			       bond_dev->name, slave_dev->name);
 		} else if (link_reporting == -1) {
 			/* unable get link status using mii/ethtool */
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: Warning: can't get link status from "
 			       "interface %s; the network driver associated "
 			       "with this interface does not support MII or "
@@ -1660,13 +1650,13 @@ int bond_enslave(struct net_device *bond
 
 	if (bond_update_speed_duplex(new_slave) &&
 	    (new_slave->link != BOND_LINK_DOWN)) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": %s: Warning: failed to get speed and duplex from %s, "
 		       "assumed to be 100Mb/sec and Full.\n",
 		       bond_dev->name, new_slave->dev->name);
 
 		if (bond->params.mode == BOND_MODE_8023AD) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: Warning: Operation of 802.3ad mode requires ETHTOOL "
 			       "support in base driver for proper aggregator "
 			       "selection.\n", bond_dev->name);
@@ -1675,9 +1665,8 @@ int bond_enslave(struct net_device *bond
 
 	if (USES_PRIMARY(bond->params.mode) && bond->params.primary[0]) {
 		/* if there is a primary slave, remember it */
-		if (strcmp(bond->params.primary, new_slave->dev->name) == 0) {
+		if (strcmp(bond->params.primary, new_slave->dev->name) == 0)
 			bond->primary_slave = new_slave;
-		}
 	}
 
 	write_lock_bh(&bond->curr_slave_lock);
@@ -1724,9 +1713,9 @@ int bond_enslave(struct net_device *bond
 		 * anyway (it holds no special properties of the bond device),
 		 * so we can change it without calling change_active_interface()
 		 */
-		if (!bond->curr_active_slave) {
+		if (!bond->curr_active_slave)
 			bond->curr_active_slave = new_slave;
-		}
+
 		break;
 	} /* switch(bond_mode) */
 
@@ -1740,7 +1729,7 @@ int bond_enslave(struct net_device *bond
 	if (res)
 		goto err_close;
 
-	printk(KERN_INFO DRV_NAME
+	pr_info(DRV_NAME
 	       ": %s: enslaving %s as a%s interface with a%s link.\n",
 	       bond_dev->name, slave_dev->name,
 	       new_slave->state == BOND_STATE_ACTIVE ? "n active" : " backup",
@@ -1772,7 +1761,7 @@ err_free:
 
 err_undo_flags:
 	bond_dev->features = old_features;
- 
+
 	return res;
 }
 
@@ -1797,7 +1786,7 @@ int bond_release(struct net_device *bond
 	/* slave is not a slave or master is not master of this slave */
 	if (!(slave_dev->flags & IFF_SLAVE) ||
 	    (slave_dev->master != bond_dev)) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: cannot release %s.\n",
 		       bond_dev->name, slave_dev->name);
 		return -EINVAL;
@@ -1808,7 +1797,7 @@ int bond_release(struct net_device *bond
 	slave = bond_get_slave_by_dev(bond, slave_dev);
 	if (!slave) {
 		/* not a slave of this bond */
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: %s not enslaved\n",
 		       bond_dev->name, slave_dev->name);
 		write_unlock_bh(&bond->lock);
@@ -1819,7 +1808,7 @@ int bond_release(struct net_device *bond
 		mac_addr_differ = memcmp(bond_dev->dev_addr, slave->perm_hwaddr,
 					 ETH_ALEN);
 		if (!mac_addr_differ && (bond->slave_cnt > 1))
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: Warning: the permanent HWaddr of %s - "
 			       "%pM - is still in use by %s. "
 			       "Set the HWaddr of %s to a different address "
@@ -1837,7 +1826,7 @@ int bond_release(struct net_device *bond
 		bond_3ad_unbind_slave(slave);
 	}
 
-	printk(KERN_INFO DRV_NAME
+	pr_info(DRV_NAME
 	       ": %s: releasing %s interface %s\n",
 	       bond_dev->name,
 	       (slave->state == BOND_STATE_ACTIVE)
@@ -1853,13 +1842,11 @@ int bond_release(struct net_device *bond
 
 	bond_compute_features(bond);
 
-	if (bond->primary_slave == slave) {
+	if (bond->primary_slave == slave)
 		bond->primary_slave = NULL;
-	}
 
-	if (oldcurrent == slave) {
+	if (oldcurrent == slave)
 		bond_change_active_slave(bond, NULL);
-	}
 
 	if (bond_is_lb(bond)) {
 		/* Must be called only after the slave has been
@@ -1901,18 +1888,18 @@ int bond_release(struct net_device *bond
 		if (list_empty(&bond->vlan_list)) {
 			bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
 		} else {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: Warning: clearing HW address of %s while it "
 			       "still has VLANs.\n",
 			       bond_dev->name, bond_dev->name);
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": %s: When re-adding slaves, make sure the bond's "
 			       "HW address matches its VLANs'.\n",
 			       bond_dev->name);
 		}
 	} else if ((bond_dev->features & NETIF_F_VLAN_CHALLENGED) &&
 		   !bond_has_challenged_slaves(bond)) {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: last VLAN challenged slave %s "
 		       "left bond %s. VLAN blocking is removed\n",
 		       bond_dev->name, slave_dev->name, bond_dev->name);
@@ -1932,14 +1919,12 @@ int bond_release(struct net_device *bond
 	 */
 	if (!USES_PRIMARY(bond->params.mode)) {
 		/* unset promiscuity level from slave */
-		if (bond_dev->flags & IFF_PROMISC) {
+		if (bond_dev->flags & IFF_PROMISC)
 			dev_set_promiscuity(slave_dev, -1);
-		}
 
 		/* unset allmulti level from slave */
-		if (bond_dev->flags & IFF_ALLMULTI) {
+		if (bond_dev->flags & IFF_ALLMULTI)
 			dev_set_allmulti(slave_dev, -1);
-		}
 
 		/* flush master's mc_list from slave */
 		netif_addr_lock_bh(bond_dev);
@@ -1988,17 +1973,18 @@ static void bond_uninit(struct net_devic
 }
 
 /*
-* First release a slave and than destroy the bond if no more slaves iare left.
+* First release a slave and than destroy the bond if no more slaves are left.
 * Must be under rtnl_lock when this function is called.
 */
-int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev)
+int  bond_release_and_destroy(struct net_device *bond_dev,
+			      struct net_device *slave_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	int ret;
 
 	ret = bond_release(bond_dev, slave_dev);
 	if ((ret == 0) && (bond->slave_cnt == 0)) {
-		printk(KERN_INFO DRV_NAME ": %s: destroying bond %s.\n",
+		pr_info(DRV_NAME ": %s: destroying bond %s.\n",
 		       bond_dev->name, bond_dev->name);
 		unregister_netdevice(bond_dev);
 	}
@@ -2019,9 +2005,8 @@ static int bond_release_all(struct net_d
 
 	netif_carrier_off(bond_dev);
 
-	if (bond->slave_cnt == 0) {
+	if (bond->slave_cnt == 0)
 		goto out;
-	}
 
 	bond->current_arp_slave = NULL;
 	bond->primary_slave = NULL;
@@ -2031,9 +2016,8 @@ static int bond_release_all(struct net_d
 		/* Inform AD package of unbinding of slave
 		 * before slave is detached from the list.
 		 */
-		if (bond->params.mode == BOND_MODE_8023AD) {
+		if (bond->params.mode == BOND_MODE_8023AD)
 			bond_3ad_unbind_slave(slave);
-		}
 
 		slave_dev = slave->dev;
 		bond_detach_slave(bond, slave);
@@ -2062,14 +2046,12 @@ static int bond_release_all(struct net_d
 		 */
 		if (!USES_PRIMARY(bond->params.mode)) {
 			/* unset promiscuity level from slave */
-			if (bond_dev->flags & IFF_PROMISC) {
+			if (bond_dev->flags & IFF_PROMISC)
 				dev_set_promiscuity(slave_dev, -1);
-			}
 
 			/* unset allmulti level from slave */
-			if (bond_dev->flags & IFF_ALLMULTI) {
+			if (bond_dev->flags & IFF_ALLMULTI)
 				dev_set_allmulti(slave_dev, -1);
-			}
 
 			/* flush master's mc_list from slave */
 			netif_addr_lock_bh(bond_dev);
@@ -2104,20 +2086,20 @@ static int bond_release_all(struct net_d
 	 */
 	memset(bond_dev->dev_addr, 0, bond_dev->addr_len);
 
-	if (list_empty(&bond->vlan_list)) {
+	if (list_empty(&bond->vlan_list))
 		bond_dev->features |= NETIF_F_VLAN_CHALLENGED;
-	} else {
-		printk(KERN_WARNING DRV_NAME
+	else {
+		pr_warning(DRV_NAME
 		       ": %s: Warning: clearing HW address of %s while it "
 		       "still has VLANs.\n",
 		       bond_dev->name, bond_dev->name);
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": %s: When re-adding slaves, make sure the bond's "
 		       "HW address matches its VLANs'.\n",
 		       bond_dev->name);
 	}
 
-	printk(KERN_INFO DRV_NAME
+	pr_info(DRV_NAME
 	       ": %s: released all slaves\n",
 	       bond_dev->name);
 
@@ -2135,8 +2117,8 @@ out:
  *  - <slave_dev> is already active.
  *  - The link state of <slave_dev> is not BOND_LINK_UP.
  *  - <slave_dev> is not running.
- * In these cases, this fuction does nothing.
- * In the other cases, currnt_slave pointer is changed and 0 is returned.
+ * In these cases, this function does nothing.
+ * In the other cases, current_slave pointer is changed and 0 is returned.
  */
 static int bond_ioctl_change_active(struct net_device *bond_dev, struct net_device *slave_dev)
 {
@@ -2145,15 +2127,12 @@ static int bond_ioctl_change_active(stru
 	struct slave *new_active = NULL;
 	int res = 0;
 
-	if (!USES_PRIMARY(bond->params.mode)) {
+	if (!USES_PRIMARY(bond->params.mode))
 		return -EINVAL;
-	}
 
 	/* Verify that master_dev is indeed the master of slave_dev */
-	if (!(slave_dev->flags & IFF_SLAVE) ||
-	    (slave_dev->master != bond_dev)) {
+	if (!(slave_dev->flags & IFF_SLAVE) || (slave_dev->master != bond_dev))
 		return -EINVAL;
-	}
 
 	read_lock(&bond->lock);
 
@@ -2178,9 +2157,8 @@ static int bond_ioctl_change_active(stru
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, new_active);
 		write_unlock_bh(&bond->curr_slave_lock);
-	} else {
+	} else
 		res = -EINVAL;
-	}
 
 	read_unlock(&bond->lock);
 
@@ -2249,7 +2227,7 @@ static int bond_miimon_inspect(struct bo
 			slave->link = BOND_LINK_FAIL;
 			slave->delay = bond->params.downdelay;
 			if (slave->delay) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: link status down for %s"
 				       "interface %s, disabling it in %d ms.\n",
 				       bond->dev->name,
@@ -2268,7 +2246,7 @@ static int bond_miimon_inspect(struct bo
 				 */
 				slave->link = BOND_LINK_UP;
 				slave->jiffies = jiffies;
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: link status up again after %d "
 				       "ms for interface %s.\n",
 				       bond->dev->name,
@@ -2295,7 +2273,7 @@ static int bond_miimon_inspect(struct bo
 			slave->delay = bond->params.updelay;
 
 			if (slave->delay) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: link status up for "
 				       "interface %s, enabling it in %d ms.\n",
 				       bond->dev->name, slave->dev->name,
@@ -2307,7 +2285,7 @@ static int bond_miimon_inspect(struct bo
 		case BOND_LINK_BACK:
 			if (!link_state) {
 				slave->link = BOND_LINK_DOWN;
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: link status down again after %d "
 				       "ms for interface %s.\n",
 				       bond->dev->name,
@@ -2361,7 +2339,7 @@ static void bond_miimon_commit(struct bo
 				slave->state = BOND_STATE_BACKUP;
 			}
 
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: link status definitely "
 			       "up for interface %s.\n",
 			       bond->dev->name, slave->dev->name);
@@ -2390,7 +2368,7 @@ static void bond_miimon_commit(struct bo
 			    bond->params.mode == BOND_MODE_8023AD)
 				bond_set_slave_inactive_flags(slave);
 
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: link status definitely down for "
 			       "interface %s, disabling it\n",
 			       bond->dev->name, slave->dev->name);
@@ -2409,7 +2387,7 @@ static void bond_miimon_commit(struct bo
 			continue;
 
 		default:
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: invalid new link %d on slave %s\n",
 			       bond->dev->name, slave->new_link,
 			       slave->dev->name);
@@ -2530,18 +2508,18 @@ static void bond_arp_send(struct net_dev
 
 	pr_debug("arp %d on slave %s: dst %x src %x vid %d\n", arp_op,
 	       slave_dev->name, dest_ip, src_ip, vlan_id);
-	       
+
 	skb = arp_create(arp_op, ETH_P_ARP, dest_ip, slave_dev, src_ip,
 			 NULL, slave_dev->dev_addr, NULL);
 
 	if (!skb) {
-		printk(KERN_ERR DRV_NAME ": ARP packet allocation failed\n");
+		pr_err(DRV_NAME ": ARP packet allocation failed\n");
 		return;
 	}
 	if (vlan_id) {
 		skb = vlan_put_tag(skb, vlan_id);
 		if (!skb) {
-			printk(KERN_ERR DRV_NAME ": failed to insert VLAN tag\n");
+			pr_err(DRV_NAME ": failed to insert VLAN tag\n");
 			return;
 		}
 	}
@@ -2581,7 +2559,7 @@ static void bond_arp_send_all(struct bon
 		rv = ip_route_output_key(&init_net, &rt, &fl);
 		if (rv) {
 			if (net_ratelimit()) {
-				printk(KERN_WARNING DRV_NAME
+				pr_warning(DRV_NAME
 			     ": %s: no route to arp_ip_target %pI4\n",
 				       bond->dev->name, &fl.fl4_dst);
 			}
@@ -2618,7 +2596,7 @@ static void bond_arp_send_all(struct bon
 		}
 
 		if (net_ratelimit()) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 	       ": %s: no path to arp_ip_target %pI4 via rt.dev %s\n",
 			       bond->dev->name, &fl.fl4_dst,
 			       rt->u.dst.dev ? rt->u.dst.dev->name : "NULL");
@@ -2766,13 +2744,11 @@ void bond_loadbalance_arp_mon(struct wor
 
 	delta_in_ticks = msecs_to_jiffies(bond->params.arp_interval);
 
-	if (bond->kill_timers) {
+	if (bond->kill_timers)
 		goto out;
-	}
 
-	if (bond->slave_cnt == 0) {
+	if (bond->slave_cnt == 0)
 		goto re_arm;
-	}
 
 	read_lock(&bond->curr_slave_lock);
 	oldcurrent = bond->curr_active_slave;
@@ -2800,14 +2776,14 @@ void bond_loadbalance_arp_mon(struct wor
 				 * is closed.
 				 */
 				if (!oldcurrent) {
-					printk(KERN_INFO DRV_NAME
+					pr_info(DRV_NAME
 					       ": %s: link status definitely "
 					       "up for interface %s, ",
 					       bond->dev->name,
 					       slave->dev->name);
 					do_failover = 1;
 				} else {
-					printk(KERN_INFO DRV_NAME
+					pr_info(DRV_NAME
 					       ": %s: interface %s is now up\n",
 					       bond->dev->name,
 					       slave->dev->name);
@@ -2826,18 +2802,16 @@ void bond_loadbalance_arp_mon(struct wor
 				slave->link  = BOND_LINK_DOWN;
 				slave->state = BOND_STATE_BACKUP;
 
-				if (slave->link_failure_count < UINT_MAX) {
+				if (slave->link_failure_count < UINT_MAX)
 					slave->link_failure_count++;
-				}
 
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: interface %s is now down.\n",
 				       bond->dev->name,
 				       slave->dev->name);
 
-				if (slave == oldcurrent) {
+				if (slave == oldcurrent)
 					do_failover = 1;
-				}
 			}
 		}
 
@@ -2848,9 +2822,8 @@ void bond_loadbalance_arp_mon(struct wor
 		 * do - all replies will be rx'ed on same link causing slaves
 		 * to be unstable during low/no traffic periods
 		 */
-		if (IS_UP(slave->dev)) {
+		if (IS_UP(slave->dev))
 			bond_arp_send_all(bond, slave);
-		}
 	}
 
 	if (do_failover) {
@@ -2981,7 +2954,7 @@ static void bond_ab_arp_commit(struct bo
 				bond_change_active_slave(bond, slave);
 				bond->current_arp_slave = NULL;
 
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: %s is up and now the "
 				       "active interface\n",
 				       bond->dev->name, slave->dev->name);
@@ -2997,7 +2970,7 @@ static void bond_ab_arp_commit(struct bo
 				bond_set_slave_inactive_flags(slave);
 				bond->current_arp_slave = NULL;
 
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: backup interface %s is now up\n",
 				       bond->dev->name, slave->dev->name);
 			}
@@ -3013,7 +2986,7 @@ static void bond_ab_arp_commit(struct bo
 			slave->link = BOND_LINK_DOWN;
 
 			if (slave == bond->curr_active_slave) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: link status down for active "
 				       "interface %s, disabling it\n",
 				       bond->dev->name, slave->dev->name);
@@ -3032,7 +3005,7 @@ static void bond_ab_arp_commit(struct bo
 				bond->current_arp_slave = NULL;
 
 			} else if (slave->state == BOND_STATE_BACKUP) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: backup interface %s is now down\n",
 				       bond->dev->name, slave->dev->name);
 
@@ -3041,7 +3014,7 @@ static void bond_ab_arp_commit(struct bo
 			break;
 
 		default:
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: impossible: new_link %d on slave %s\n",
 			       bond->dev->name, slave->new_link,
 			       slave->dev->name);
@@ -3075,7 +3048,7 @@ static void bond_ab_arp_probe(struct bon
 	read_lock(&bond->curr_slave_lock);
 
 	if (bond->current_arp_slave && bond->curr_active_slave)
-		printk("PROBE: c_arp %s && cas %s BAD\n",
+		pr_info(DRV_NAME "PROBE: c_arp %s && cas %s BAD\n",
 		       bond->current_arp_slave->dev->name,
 		       bond->curr_active_slave->dev->name);
 
@@ -3125,7 +3098,7 @@ static void bond_ab_arp_probe(struct bon
 
 			bond_set_slave_inactive_flags(slave);
 
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: backup interface %s is now down.\n",
 			       bond->dev->name, slave->dev->name);
 		}
@@ -3175,9 +3148,8 @@ void bond_activebackup_arp_mon(struct wo
 	bond_ab_arp_probe(bond);
 
 re_arm:
-	if (bond->params.arp_interval) {
+	if (bond->params.arp_interval)
 		queue_delayed_work(bond->wq, &bond->arp_work, delta_in_ticks);
-	}
 out:
 	read_unlock(&bond->lock);
 }
@@ -3199,14 +3171,12 @@ static void *bond_info_seq_start(struct 
 	read_lock(&dev_base_lock);
 	read_lock(&bond->lock);
 
-	if (*pos == 0) {
+	if (*pos == 0)
 		return SEQ_START_TOKEN;
-	}
 
 	bond_for_each_slave(bond, slave, i) {
-		if (++off == *pos) {
+		if (++off == *pos)
 			return slave;
-		}
 	}
 
 	return NULL;
@@ -3218,9 +3188,8 @@ static void *bond_info_seq_next(struct s
 	struct slave *slave = v;
 
 	++*pos;
-	if (v == SEQ_START_TOKEN) {
+	if (v == SEQ_START_TOKEN)
 		return bond->first_slave;
-	}
 
 	slave = slave->next;
 
@@ -3283,14 +3252,14 @@ static void bond_info_show_master(struct
 
 
 	/* ARP information */
-	if(bond->params.arp_interval > 0) {
-		int printed=0;
+	if (bond->params.arp_interval > 0) {
+		int printed = 0;
 		seq_printf(seq, "ARP Polling Interval (ms): %d\n",
 				bond->params.arp_interval);
 
 		seq_printf(seq, "ARP IP target/s (n.n.n.n form):");
 
-		for(i = 0; (i < BOND_MAX_ARP_TARGETS) ;i++) {
+		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
 			if (!bond->params.arp_targets[i])
 				break;
 			if (printed)
@@ -3330,7 +3299,8 @@ static void bond_info_show_master(struct
 	}
 }
 
-static void bond_info_show_slave(struct seq_file *seq, const struct slave *slave)
+static void bond_info_show_slave(struct seq_file *seq,
+				 const struct slave *slave)
 {
 	struct bonding *bond = seq->private;
 
@@ -3346,12 +3316,11 @@ static void bond_info_show_slave(struct 
 		const struct aggregator *agg
 			= SLAVE_AD_INFO(slave).port.aggregator;
 
-		if (agg) {
+		if (agg)
 			seq_printf(seq, "Aggregator ID: %d\n",
 				   agg->aggregator_identifier);
-		} else {
+		else
 			seq_puts(seq, "Aggregator ID: N/A\n");
-		}
 	}
 }
 
@@ -3360,9 +3329,8 @@ static int bond_info_seq_show(struct seq
 	if (v == SEQ_START_TOKEN) {
 		seq_printf(seq, "%s\n", version);
 		bond_info_show_master(seq);
-	} else {
+	} else
 		bond_info_show_slave(seq, v);
-	}
 
 	return 0;
 }
@@ -3407,13 +3375,12 @@ static int bond_create_proc_entry(struct
 		bond->proc_entry = proc_create_data(bond_dev->name,
 						    S_IRUGO, bond_proc_dir,
 						    &bond_info_fops, bond);
-		if (bond->proc_entry == NULL) {
-			printk(KERN_WARNING DRV_NAME
+		if (bond->proc_entry == NULL)
+			pr_warning(DRV_NAME
 			       ": Warning: Cannot create /proc/net/%s/%s\n",
 			       DRV_NAME, bond_dev->name);
-		} else {
+		else
 			memcpy(bond->proc_file_name, bond_dev->name, IFNAMSIZ);
-		}
 	}
 
 	return 0;
@@ -3436,7 +3403,7 @@ static void bond_create_proc_dir(void)
 	if (!bond_proc_dir) {
 		bond_proc_dir = proc_mkdir(DRV_NAME, init_net.proc_net);
 		if (!bond_proc_dir)
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 				": Warning: cannot create /proc/net/%s\n",
 				DRV_NAME);
 	}
@@ -3484,13 +3451,14 @@ static int bond_event_changename(struct 
 	bond_remove_proc_entry(bond);
 	bond_create_proc_entry(bond);
 
-        bond_destroy_sysfs_entry(bond);
-        bond_create_sysfs_entry(bond);
+	bond_destroy_sysfs_entry(bond);
+	bond_create_sysfs_entry(bond);
 
 	return NOTIFY_DONE;
 }
 
-static int bond_master_netdev_event(unsigned long event, struct net_device *bond_dev)
+static int bond_master_netdev_event(unsigned long event,
+				    struct net_device *bond_dev)
 {
 	struct bonding *event_bond = netdev_priv(bond_dev);
 
@@ -3507,7 +3475,8 @@ static int bond_master_netdev_event(unsi
 	return NOTIFY_DONE;
 }
 
-static int bond_slave_netdev_event(unsigned long event, struct net_device *slave_dev)
+static int bond_slave_netdev_event(unsigned long event,
+				   struct net_device *slave_dev)
 {
 	struct net_device *bond_dev = slave_dev->master;
 	struct bonding *bond = netdev_priv(bond_dev);
@@ -3585,7 +3554,8 @@ static int bond_slave_netdev_event(unsig
  * locks for us to safely manipulate the slave devices (RTNL lock,
  * dev_probe_lock).
  */
-static int bond_netdev_event(struct notifier_block *this, unsigned long event, void *ptr)
+static int bond_netdev_event(struct notifier_block *this,
+			     unsigned long event, void *ptr)
 {
 	struct net_device *event_dev = (struct net_device *)ptr;
 
@@ -3940,9 +3910,9 @@ static int bond_do_ioctl(struct net_devi
 	switch (cmd) {
 	case SIOCGMIIPHY:
 		mii = if_mii(ifr);
-		if (!mii) {
+		if (!mii)
 			return -EINVAL;
-		}
+
 		mii->phy_id = 0;
 		/* Fall Through */
 	case SIOCGMIIREG:
@@ -3951,18 +3921,18 @@ static int bond_do_ioctl(struct net_devi
 		 * instead of SIOCGMIIPHY.
 		 */
 		mii = if_mii(ifr);
-		if (!mii) {
+		if (!mii)
 			return -EINVAL;
-		}
+
 
 		if (mii->reg_num == 1) {
 			struct bonding *bond = netdev_priv(bond_dev);
 			mii->val_out = 0;
 			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
-			if (netif_carrier_ok(bond->dev)) {
+			if (netif_carrier_ok(bond->dev))
 				mii->val_out = BMSR_LSTATUS;
-			}
+
 			read_unlock(&bond->curr_slave_lock);
 			read_unlock(&bond->lock);
 		}
@@ -3972,32 +3942,26 @@ static int bond_do_ioctl(struct net_devi
 	case SIOCBONDINFOQUERY:
 		u_binfo = (struct ifbond __user *)ifr->ifr_data;
 
-		if (copy_from_user(&k_binfo, u_binfo, sizeof(ifbond))) {
+		if (copy_from_user(&k_binfo, u_binfo, sizeof(ifbond)))
 			return -EFAULT;
-		}
 
 		res = bond_info_query(bond_dev, &k_binfo);
-		if (res == 0) {
-			if (copy_to_user(u_binfo, &k_binfo, sizeof(ifbond))) {
-				return -EFAULT;
-			}
-		}
+		if (res == 0 &&
+		    copy_to_user(u_binfo, &k_binfo, sizeof(ifbond)))
+			return -EFAULT;
 
 		return res;
 	case BOND_SLAVE_INFO_QUERY_OLD:
 	case SIOCBONDSLAVEINFOQUERY:
 		u_sinfo = (struct ifslave __user *)ifr->ifr_data;
 
-		if (copy_from_user(&k_sinfo, u_sinfo, sizeof(ifslave))) {
+		if (copy_from_user(&k_sinfo, u_sinfo, sizeof(ifslave)))
 			return -EFAULT;
-		}
 
 		res = bond_slave_info_query(bond_dev, &k_sinfo);
-		if (res == 0) {
-			if (copy_to_user(u_sinfo, &k_sinfo, sizeof(ifslave))) {
-				return -EFAULT;
-			}
-		}
+		if (res == 0 &&
+		    copy_to_user(u_sinfo, &k_sinfo, sizeof(ifslave)))
+			return -EFAULT;
 
 		return res;
 	default:
@@ -4005,17 +3969,16 @@ static int bond_do_ioctl(struct net_devi
 		break;
 	}
 
-	if (!capable(CAP_NET_ADMIN)) {
+	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
-	}
 
 	slave_dev = dev_get_by_name(&init_net, ifr->ifr_slave);
 
 	pr_debug("slave_dev=%p: \n", slave_dev);
 
-	if (!slave_dev) {
+	if (!slave_dev)
 		res = -ENODEV;
-	} else {
+	else {
 		pr_debug("slave_dev->name=%s: \n", slave_dev->name);
 		switch (cmd) {
 		case BOND_ENSLAVE_OLD:
@@ -4052,30 +4015,30 @@ static void bond_set_multicast_list(stru
 	/*
 	 * Do promisc before checking multicast_mode
 	 */
-	if ((bond_dev->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC)) {
+	if ((bond_dev->flags & IFF_PROMISC) && !(bond->flags & IFF_PROMISC))
 		/*
 		 * FIXME: Need to handle the error when one of the multi-slaves
 		 * encounters error.
 		 */
 		bond_set_promiscuity(bond, 1);
-	}
 
-	if (!(bond_dev->flags & IFF_PROMISC) && (bond->flags & IFF_PROMISC)) {
+
+	if (!(bond_dev->flags & IFF_PROMISC) && (bond->flags & IFF_PROMISC))
 		bond_set_promiscuity(bond, -1);
-	}
+
 
 	/* set allmulti flag to slaves */
-	if ((bond_dev->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI)) {
+	if ((bond_dev->flags & IFF_ALLMULTI) && !(bond->flags & IFF_ALLMULTI))
 		/*
 		 * FIXME: Need to handle the error when one of the multi-slaves
 		 * encounters error.
 		 */
 		bond_set_allmulti(bond, 1);
-	}
 
-	if (!(bond_dev->flags & IFF_ALLMULTI) && (bond->flags & IFF_ALLMULTI)) {
+
+	if (!(bond_dev->flags & IFF_ALLMULTI) && (bond->flags & IFF_ALLMULTI))
 		bond_set_allmulti(bond, -1);
-	}
+
 
 	read_lock(&bond->lock);
 
@@ -4083,16 +4046,14 @@ static void bond_set_multicast_list(stru
 
 	/* looking for addresses to add to slaves' mc list */
 	for (dmi = bond_dev->mc_list; dmi; dmi = dmi->next) {
-		if (!bond_mc_list_find_dmi(dmi, bond->mc_list)) {
+		if (!bond_mc_list_find_dmi(dmi, bond->mc_list))
 			bond_mc_add(bond, dmi->dmi_addr, dmi->dmi_addrlen);
-		}
 	}
 
 	/* looking for addresses to delete from slaves' list */
 	for (dmi = bond->mc_list; dmi; dmi = dmi->next) {
-		if (!bond_mc_list_find_dmi(dmi, bond_dev->mc_list)) {
+		if (!bond_mc_list_find_dmi(dmi, bond_dev->mc_list))
 			bond_mc_delete(bond, dmi->dmi_addr, dmi->dmi_addrlen);
-		}
 	}
 
 	/* save master's multicast list */
@@ -4212,9 +4173,8 @@ static int bond_set_mac_address(struct n
 	if (bond->params.fail_over_mac == BOND_FOM_ACTIVE)
 		return 0;
 
-	if (!is_valid_ether_addr(sa->sa_data)) {
+	if (!is_valid_ether_addr(sa->sa_data))
 		return -EADDRNOTAVAIL;
-	}
 
 	/* Can't hold bond->lock with bh disabled here since
 	 * some base drivers panic. On the other hand we can't
@@ -4285,9 +4245,8 @@ static int bond_xmit_roundrobin(struct s
 
 	read_lock(&bond->lock);
 
-	if (!BOND_IS_OK(bond)) {
+	if (!BOND_IS_OK(bond))
 		goto out;
-	}
 
 	/*
 	 * Concurrent TX may collide on rr_tx_counter; we accept that
@@ -4297,9 +4256,8 @@ static int bond_xmit_roundrobin(struct s
 
 	bond_for_each_slave(bond, slave, i) {
 		slave_no--;
-		if (slave_no < 0) {
+		if (slave_no < 0)
 			break;
-		}
 	}
 
 	start_at = slave;
@@ -4334,9 +4292,8 @@ static int bond_xmit_activebackup(struct
 	read_lock(&bond->lock);
 	read_lock(&bond->curr_slave_lock);
 
-	if (!BOND_IS_OK(bond)) {
+	if (!BOND_IS_OK(bond))
 		goto out;
-	}
 
 	if (!bond->curr_active_slave)
 		goto out;
@@ -4344,10 +4301,10 @@ static int bond_xmit_activebackup(struct
 	res = bond_dev_queue_xmit(bond, skb, bond->curr_active_slave->dev);
 
 out:
-	if (res) {
+	if (res)
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
-	}
+
 	read_unlock(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
 	return 0;
@@ -4368,17 +4325,15 @@ static int bond_xmit_xor(struct sk_buff 
 
 	read_lock(&bond->lock);
 
-	if (!BOND_IS_OK(bond)) {
+	if (!BOND_IS_OK(bond))
 		goto out;
-	}
 
 	slave_no = bond->xmit_hash_policy(skb, bond_dev, bond->slave_cnt);
 
 	bond_for_each_slave(bond, slave, i) {
 		slave_no--;
-		if (slave_no < 0) {
+		if (slave_no < 0)
 			break;
-		}
 	}
 
 	start_at = slave;
@@ -4414,17 +4369,15 @@ static int bond_xmit_broadcast(struct sk
 
 	read_lock(&bond->lock);
 
-	if (!BOND_IS_OK(bond)) {
+	if (!BOND_IS_OK(bond))
 		goto out;
-	}
 
 	read_lock(&bond->curr_slave_lock);
 	start_at = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
 
-	if (!start_at) {
+	if (!start_at)
 		goto out;
-	}
 
 	bond_for_each_slave_from(bond, slave, i, start_at) {
 		if (IS_UP(slave->dev) &&
@@ -4433,7 +4386,7 @@ static int bond_xmit_broadcast(struct sk
 			if (tx_dev) {
 				struct sk_buff *skb2 = skb_clone(skb, GFP_ATOMIC);
 				if (!skb2) {
-					printk(KERN_ERR DRV_NAME
+					pr_err(DRV_NAME
 					       ": %s: Error: bond_xmit_broadcast(): "
 					       "skb_clone() failed\n",
 					       bond_dev->name);
@@ -4450,15 +4403,14 @@ static int bond_xmit_broadcast(struct sk
 		}
 	}
 
-	if (tx_dev) {
+	if (tx_dev)
 		res = bond_dev_queue_xmit(bond, skb, tx_dev);
-	}
 
 out:
-	if (res) {
+	if (res)
 		/* no suitable interface, frame not sent */
 		dev_kfree_skb(skb);
-	}
+
 	/* frame sent to all suitable interfaces */
 	read_unlock(&bond->lock);
 	return 0;
@@ -4502,7 +4454,7 @@ static int bond_start_xmit(struct sk_buf
 		return bond_alb_xmit(skb, dev);
 	default:
 		/* Should never happen, mode already checked */
-		printk(KERN_ERR DRV_NAME ": %s: Error: Unknown bonding mode %d\n",
+		pr_err(DRV_NAME ": %s: Error: Unknown bonding mode %d\n",
 		     dev->name, bond->params.mode);
 		WARN_ON_ONCE(1);
 		dev_kfree_skb(skb);
@@ -4539,7 +4491,7 @@ void bond_set_mode_ops(struct bonding *b
 		break;
 	default:
 		/* Should never happen, mode already checked */
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Error: Unknown bonding mode %d\n",
 		       bond_dev->name,
 		       mode);
@@ -4752,7 +4704,7 @@ static int bond_check_params(struct bond
 	if (mode) {
 		bond_mode = bond_parse_parm(mode, bond_mode_tbl);
 		if (bond_mode == -1) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": Error: Invalid bonding mode \"%s\"\n",
 			       mode == NULL ? "NULL" : mode);
 			return -EINVAL;
@@ -4762,16 +4714,16 @@ static int bond_check_params(struct bond
 	if (xmit_hash_policy) {
 		if ((bond_mode != BOND_MODE_XOR) &&
 		    (bond_mode != BOND_MODE_8023AD)) {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": xor_mode param is irrelevant in mode %s\n",
 			       bond_mode_name(bond_mode));
 		} else {
 			xmit_hashtype = bond_parse_parm(xmit_hash_policy,
 							xmit_hashtype_tbl);
 			if (xmit_hashtype == -1) {
-				printk(KERN_ERR DRV_NAME
-			       	": Error: Invalid xmit_hash_policy \"%s\"\n",
-			       	xmit_hash_policy == NULL ? "NULL" :
+				pr_err(DRV_NAME
+				       ": Error: Invalid xmit_hash_policy \"%s\"\n",
+				       xmit_hash_policy == NULL ? "NULL" :
 				       xmit_hash_policy);
 				return -EINVAL;
 			}
@@ -4780,13 +4732,13 @@ static int bond_check_params(struct bond
 
 	if (lacp_rate) {
 		if (bond_mode != BOND_MODE_8023AD) {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": lacp_rate param is irrelevant in mode %s\n",
 			       bond_mode_name(bond_mode));
 		} else {
 			lacp_fast = bond_parse_parm(lacp_rate, bond_lacp_tbl);
 			if (lacp_fast == -1) {
-				printk(KERN_ERR DRV_NAME
+				pr_err(DRV_NAME
 				       ": Error: Invalid lacp rate \"%s\"\n",
 				       lacp_rate == NULL ? "NULL" : lacp_rate);
 				return -EINVAL;
@@ -4797,14 +4749,14 @@ static int bond_check_params(struct bond
 	if (ad_select) {
 		params->ad_select = bond_parse_parm(ad_select, ad_select_tbl);
 		if (params->ad_select == -1) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": Error: Invalid ad_select \"%s\"\n",
 			       ad_select == NULL ? "NULL" : ad_select);
 			return -EINVAL;
 		}
 
 		if (bond_mode != BOND_MODE_8023AD) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": ad_select param only affects 802.3ad mode\n");
 		}
 	} else {
@@ -4812,7 +4764,7 @@ static int bond_check_params(struct bond
 	}
 
 	if (max_bonds < 0 || max_bonds > INT_MAX) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: max_bonds (%d) not in range %d-%d, so it "
 		       "was reset to BOND_DEFAULT_MAX_BONDS (%d)\n",
 		       max_bonds, 0, INT_MAX, BOND_DEFAULT_MAX_BONDS);
@@ -4820,7 +4772,7 @@ static int bond_check_params(struct bond
 	}
 
 	if (miimon < 0) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: miimon module parameter (%d), "
 		       "not in range 0-%d, so it was reset to %d\n",
 		       miimon, INT_MAX, BOND_LINK_MON_INTERV);
@@ -4828,7 +4780,7 @@ static int bond_check_params(struct bond
 	}
 
 	if (updelay < 0) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: updelay module parameter (%d), "
 		       "not in range 0-%d, so it was reset to 0\n",
 		       updelay, INT_MAX);
@@ -4836,7 +4788,7 @@ static int bond_check_params(struct bond
 	}
 
 	if (downdelay < 0) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: downdelay module parameter (%d), "
 		       "not in range 0-%d, so it was reset to 0\n",
 		       downdelay, INT_MAX);
@@ -4844,7 +4796,7 @@ static int bond_check_params(struct bond
 	}
 
 	if ((use_carrier != 0) && (use_carrier != 1)) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: use_carrier module parameter (%d), "
 		       "not of valid value (0/1), so it was set to 1\n",
 		       use_carrier);
@@ -4852,14 +4804,14 @@ static int bond_check_params(struct bond
 	}
 
 	if (num_grat_arp < 0 || num_grat_arp > 255) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: num_grat_arp (%d) not in range 0-255 so it "
 		       "was reset to 1 \n", num_grat_arp);
 		num_grat_arp = 1;
 	}
 
 	if (num_unsol_na < 0 || num_unsol_na > 255) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: num_unsol_na (%d) not in range 0-255 so it "
 		       "was reset to 1 \n", num_unsol_na);
 		num_unsol_na = 1;
@@ -4868,12 +4820,12 @@ static int bond_check_params(struct bond
 	/* reset values for 802.3ad */
 	if (bond_mode == BOND_MODE_8023AD) {
 		if (!miimon) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: miimon must be specified, "
 			       "otherwise bonding will not detect link "
 			       "failure, speed and duplex which are "
 			       "essential for 802.3ad operation\n");
-			printk(KERN_WARNING "Forcing miimon to 100msec\n");
+			pr_warning("Forcing miimon to 100msec\n");
 			miimon = 100;
 		}
 	}
@@ -4882,12 +4834,12 @@ static int bond_check_params(struct bond
 	if ((bond_mode == BOND_MODE_TLB) ||
 	    (bond_mode == BOND_MODE_ALB)) {
 		if (!miimon) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: miimon must be specified, "
 			       "otherwise bonding will not detect link "
 			       "failure and link speed which are essential "
 			       "for TLB/ALB load balancing\n");
-			printk(KERN_WARNING "Forcing miimon to 100msec\n");
+			pr_warning("Forcing miimon to 100msec\n");
 			miimon = 100;
 		}
 	}
@@ -4907,7 +4859,7 @@ static int bond_check_params(struct bond
 			/* just warn the user the up/down delay will have
 			 * no effect since miimon is zero...
 			 */
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: miimon module parameter not set "
 			       "and updelay (%d) or downdelay (%d) module "
 			       "parameter is set; updelay and downdelay have "
@@ -4917,7 +4869,7 @@ static int bond_check_params(struct bond
 	} else {
 		/* don't allow arp monitoring */
 		if (arp_interval) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: miimon (%d) and arp_interval (%d) "
 			       "can't be used simultaneously, disabling ARP "
 			       "monitoring\n",
@@ -4926,7 +4878,7 @@ static int bond_check_params(struct bond
 		}
 
 		if ((updelay % miimon) != 0) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: updelay (%d) is not a multiple "
 			       "of miimon (%d), updelay rounded to %d ms\n",
 			       updelay, miimon, (updelay / miimon) * miimon);
@@ -4935,7 +4887,7 @@ static int bond_check_params(struct bond
 		updelay /= miimon;
 
 		if ((downdelay % miimon) != 0) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: downdelay (%d) is not a multiple "
 			       "of miimon (%d), downdelay rounded to %d ms\n",
 			       downdelay, miimon,
@@ -4946,7 +4898,7 @@ static int bond_check_params(struct bond
 	}
 
 	if (arp_interval < 0) {
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: arp_interval module parameter (%d) "
 		       ", not in range 0-%d, so it was reset to %d\n",
 		       arp_interval, INT_MAX, BOND_LINK_ARP_INTERV);
@@ -4959,7 +4911,7 @@ static int bond_check_params(struct bond
 		/* not complete check, but should be good enough to
 		   catch mistakes */
 		if (!isdigit(arp_ip_target[arp_ip_count][0])) {
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: bad arp_ip_target module parameter "
 			       "(%s), ARP monitoring will not be performed\n",
 			       arp_ip_target[arp_ip_count]);
@@ -4972,7 +4924,7 @@ static int bond_check_params(struct bond
 
 	if (arp_interval && !arp_ip_count) {
 		/* don't allow arping if no arp_ip_target given... */
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: arp_interval module parameter (%d) "
 		       "specified without providing an arp_ip_target "
 		       "parameter, arp_interval was reset to 0\n",
@@ -4982,12 +4934,12 @@ static int bond_check_params(struct bond
 
 	if (arp_validate) {
 		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
-			printk(KERN_ERR DRV_NAME
-	       ": arp_validate only supported in active-backup mode\n");
+			pr_err(DRV_NAME
+			       ": arp_validate only supported in active-backup mode\n");
 			return -EINVAL;
 		}
 		if (!arp_interval) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": arp_validate requires arp_interval\n");
 			return -EINVAL;
 		}
@@ -4995,7 +4947,7 @@ static int bond_check_params(struct bond
 		arp_validate_value = bond_parse_parm(arp_validate,
 						     arp_validate_tbl);
 		if (arp_validate_value == -1) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": Error: invalid arp_validate \"%s\"\n",
 			       arp_validate == NULL ? "NULL" : arp_validate);
 			return -EINVAL;
@@ -5004,20 +4956,20 @@ static int bond_check_params(struct bond
 		arp_validate_value = 0;
 
 	if (miimon) {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": MII link monitoring set to %d ms\n",
 		       miimon);
 	} else if (arp_interval) {
 		int i;
 
-		printk(KERN_INFO DRV_NAME
-		       ": ARP monitoring set to %d ms, validate %s, with %d target(s):",
+		pr_info(DRV_NAME ": ARP monitoring set to %d ms,"
+		       " validate %s, with %d target(s):",
 		       arp_interval,
 		       arp_validate_tbl[arp_validate_value].modename,
 		       arp_ip_count);
 
 		for (i = 0; i < arp_ip_count; i++)
-			printk (" %s", arp_ip_target[i]);
+			printk(" %s", arp_ip_target[i]);
 
 		printk("\n");
 
@@ -5025,7 +4977,7 @@ static int bond_check_params(struct bond
 		/* miimon and arp_interval not set, we need one so things
 		 * work as expected, see bonding.txt for details
 		 */
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: either miimon or arp_interval and "
 		       "arp_ip_target module parameters must be specified, "
 		       "otherwise bonding will not detect link failures! see "
@@ -5036,7 +4988,7 @@ static int bond_check_params(struct bond
 		/* currently, using a primary only makes sense
 		 * in active backup, TLB or ALB modes
 		 */
-		printk(KERN_WARNING DRV_NAME
+		pr_warning(DRV_NAME
 		       ": Warning: %s primary device specified but has no "
 		       "effect in %s mode\n",
 		       primary, bond_mode_name(bond_mode));
@@ -5047,14 +4999,14 @@ static int bond_check_params(struct bond
 		fail_over_mac_value = bond_parse_parm(fail_over_mac,
 						      fail_over_mac_tbl);
 		if (fail_over_mac_value == -1) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": Error: invalid fail_over_mac \"%s\"\n",
 			       arp_validate == NULL ? "NULL" : arp_validate);
 			return -EINVAL;
 		}
 
 		if (bond_mode != BOND_MODE_ACTIVEBACKUP)
-			printk(KERN_WARNING DRV_NAME
+			pr_warning(DRV_NAME
 			       ": Warning: fail_over_mac only affects "
 			       "active-backup mode.\n");
 	} else {
@@ -5120,9 +5072,8 @@ int bond_create(const char *name)
 	if (name) {
 		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
-				printk(KERN_ERR DRV_NAME
-			       ": cannot add bond %s; it already exists\n",
-				       name);
+				pr_err(DRV_NAME ": cannot add bond %s;"
+				       " it already exists\n", name);
 				res = -EPERM;
 				goto out_rtnl;
 			}
@@ -5131,8 +5082,7 @@ int bond_create(const char *name)
 	bond_dev = alloc_netdev(sizeof(struct bonding), name ? name : "",
 				ether_setup);
 	if (!bond_dev) {
-		printk(KERN_ERR DRV_NAME
-		       ": %s: eek! can't alloc netdev!\n",
+		pr_err(DRV_NAME ": %s: eek! can't alloc netdev!\n",
 		       name);
 		res = -ENOMEM;
 		goto out_rtnl;
@@ -5151,18 +5101,16 @@ int bond_create(const char *name)
 	 */
 
 	res = bond_init(bond_dev);
-	if (res < 0) {
+	if (res < 0)
 		goto out_netdev;
-	}
 
 	bond_set_lockdep_class(bond_dev);
 
 	netif_carrier_off(bond_dev);
 
 	res = register_netdevice(bond_dev);
-	if (res < 0) {
+	if (res < 0)
 		goto out_bond;
-	}
 
 	res = bond_create_sysfs_entry(netdev_priv(bond_dev));
 	if (res < 0)
@@ -5187,12 +5135,11 @@ static int __init bonding_init(void)
 	int i;
 	int res;
 
-	printk(KERN_INFO "%s", version);
+	pr_info("%s", version);
 
 	res = bond_check_params(&bonding_defaults);
-	if (res) {
+	if (res)
 		goto out;
-	}
 
 	bond_create_proc_dir();
 
@@ -5239,13 +5186,3 @@ MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 MODULE_DESCRIPTION(DRV_DESCRIPTION ", v" DRV_VERSION);
 MODULE_AUTHOR("Thomas Davis, tadavis@lbl.gov and many others");
-MODULE_SUPPORTED_DEVICE("most ethernet devices");
-
-/*
- * Local variables:
- *  c-indent-level: 8
- *  c-basic-offset: 8
- *  tab-width: 8
- * End:
- */
-
--- a/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:44:52.148228948 -0700
+++ b/drivers/net/bonding/bond_sysfs.c	2009-06-12 21:46:22.183394245 -0700
@@ -1,4 +1,3 @@
-
 /*
  * Copyright(c) 2004-2005 Intel Corporation. All rights reserved.
  *
@@ -38,7 +37,7 @@
 
 #include "bonding.h"
 
-#define to_dev(obj)	container_of(obj,struct device,kobj)
+#define to_dev(obj)	container_of(obj, struct device, kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
 
 /*---------------------------- Declarations -------------------------------*/
@@ -83,7 +82,8 @@ static ssize_t bonding_show_bonds(struct
  *
  */
 
-static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t count)
+static ssize_t bonding_store_bonds(struct class *cls,
+				   const char *buffer, size_t count)
 {
 	char command[IFNAMSIZ + 1] = {0, };
 	char *ifname;
@@ -97,11 +97,11 @@ static ssize_t bonding_store_bonds(struc
 		goto err_no_cmd;
 
 	if (command[0] == '+') {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 			": %s is being created...\n", ifname);
 		rv = bond_create(ifname);
 		if (rv) {
-			printk(KERN_INFO DRV_NAME ": Bond creation failed.\n");
+			pr_info(DRV_NAME ": Bond creation failed.\n");
 			res = rv;
 		}
 		goto out;
@@ -118,28 +118,28 @@ static ssize_t bonding_store_bonds(struc
 				 */
 				if (atomic_read(&bond->dev->dev.kobj.kref.refcount)
 							> expected_refcount){
-					printk(KERN_INFO DRV_NAME
+					pr_info(DRV_NAME
 						": Unable remove bond %s due to open references.\n",
 						ifname);
 					res = -EPERM;
 					goto out_unlock;
 				}
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
 				unregister_netdevice(bond->dev);
 				goto out_unlock;
 			}
 
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 			": unable to delete non-existent bond %s\n", ifname);
 		res = -ENODEV;
 		goto out_unlock;
 	}
 
 err_no_cmd:
-	printk(KERN_ERR DRV_NAME
-		": no command found in bonding_masters. Use +ifname or -ifname.\n");
+	pr_err(DRV_NAME ": no command found in bonding_masters."
+	       " Use +ifname or -ifname.\n");
 	return -EPERM;
 
 out_unlock:
@@ -155,7 +155,8 @@ out:
 static CLASS_ATTR(bonding_masters,  S_IWUSR | S_IRUGO,
 		  bonding_show_bonds, bonding_store_bonds);
 
-int bond_create_slave_symlinks(struct net_device *master, struct net_device *slave)
+int bond_create_slave_symlinks(struct net_device *master,
+			       struct net_device *slave)
 {
 	char linkname[IFNAMSIZ+7];
 	int ret = 0;
@@ -166,19 +167,20 @@ int bond_create_slave_symlinks(struct ne
 	if (ret)
 		return ret;
 	/* next, create a link from the master to the slave */
-	sprintf(linkname,"slave_%s",slave->name);
+	sprintf(linkname, "slave_%s", slave->name);
 	ret = sysfs_create_link(&(master->dev.kobj), &(slave->dev.kobj),
 				linkname);
 	return ret;
 
 }
 
-void bond_destroy_slave_symlinks(struct net_device *master, struct net_device *slave)
+void bond_destroy_slave_symlinks(struct net_device *master,
+				 struct net_device *slave)
 {
 	char linkname[IFNAMSIZ+7];
 
 	sysfs_remove_link(&(slave->dev.kobj), "master");
-	sprintf(linkname,"slave_%s",slave->name);
+	sprintf(linkname, "slave_%s", slave->name);
 	sysfs_remove_link(&(master->dev.kobj), linkname);
 }
 
@@ -252,7 +254,7 @@ static ssize_t bonding_store_slaves(stru
 		read_lock(&bond->lock);
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
-				printk(KERN_ERR DRV_NAME
+				pr_err(DRV_NAME
 				       ": %s: Interface %s is already enslaved!\n",
 				       bond->dev->name, ifname);
 				ret = -EPERM;
@@ -261,21 +263,20 @@ static ssize_t bonding_store_slaves(stru
 			}
 
 		read_unlock(&bond->lock);
-		printk(KERN_INFO DRV_NAME ": %s: Adding slave %s.\n",
+		pr_info(DRV_NAME ": %s: Adding slave %s.\n",
 		       bond->dev->name, ifname);
 		dev = dev_get_by_name(&init_net, ifname);
 		if (!dev) {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: Interface %s does not exist!\n",
 			       bond->dev->name, ifname);
 			ret = -EPERM;
 			goto out;
-		}
-		else
+		} else
 			dev_put(dev);
 
 		if (dev->flags & IFF_UP) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: Error: Unable to enslave %s "
 			       "because it is already up.\n",
 			       bond->dev->name, dev->name);
@@ -302,9 +303,9 @@ static ssize_t bonding_store_slaves(stru
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0)
 				slave->original_mtu = original_mtu;
-		if (res) {
+		if (res)
 			ret = res;
-		}
+
 		goto out;
 	}
 
@@ -318,7 +319,7 @@ static ssize_t bonding_store_slaves(stru
 				break;
 			}
 		if (dev) {
-			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
+			pr_info(DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
 				res = bond_release(bond->dev, dev);
 			if (res) {
@@ -327,9 +328,9 @@ static ssize_t bonding_store_slaves(stru
 			}
 			/* set the slave MTU to the default */
 			dev_set_mtu(dev, original_mtu);
-		}
-		else {
-			printk(KERN_ERR DRV_NAME ": unable to remove non-existent slave %s for bond %s.\n",
+		} else {
+			pr_err(DRV_NAME ": unable to remove non-existent"
+			       " slave %s for bond %s.\n",
 				ifname, bond->dev->name);
 			ret = -ENODEV;
 		}
@@ -337,7 +338,7 @@ static ssize_t bonding_store_slaves(stru
 	}
 
 err_no_cmd:
-	printk(KERN_ERR DRV_NAME ": no command found in slaves file for bond %s. Use +ifname or -ifname.\n", bond->dev->name);
+	pr_err(DRV_NAME ": no command found in slaves file for bond %s. Use +ifname or -ifname.\n", bond->dev->name);
 	ret = -EPERM;
 
 out:
@@ -345,7 +346,8 @@ out:
 	return ret;
 }
 
-static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves, bonding_store_slaves);
+static DEVICE_ATTR(slaves, S_IRUGO | S_IWUSR, bonding_show_slaves,
+		   bonding_store_slaves);
 
 /*
  * Show and set the bonding mode.  The bond interface must be down to
@@ -369,16 +371,15 @@ static ssize_t bonding_store_mode(struct
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		printk(KERN_ERR DRV_NAME
-		       ": unable to update mode of %s because interface is up.\n",
-		       bond->dev->name);
+		pr_err(DRV_NAME ": unable to update mode of %s"
+		       " because interface is up.\n", bond->dev->name);
 		ret = -EPERM;
 		goto out;
 	}
 
 	new_value = bond_parse_parm(buf, bond_mode_tbl);
 	if (new_value < 0)  {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Ignoring invalid mode value %.*s.\n",
 		       bond->dev->name,
 		       (int)strlen(buf) - 1, buf);
@@ -393,17 +394,19 @@ static ssize_t bonding_store_mode(struct
 
 		bond->params.mode = new_value;
 		bond_set_mode_ops(bond, bond->params.mode);
-		printk(KERN_INFO DRV_NAME ": %s: setting mode to %s (%d).\n",
-			bond->dev->name, bond_mode_tbl[new_value].modename, new_value);
+		pr_info(DRV_NAME ": %s: setting mode to %s (%d).\n",
+		       bond->dev->name, bond_mode_tbl[new_value].modename,
+		       new_value);
 	}
 out:
 	return ret;
 }
-static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR, bonding_show_mode, bonding_store_mode);
+static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR,
+		   bonding_show_mode, bonding_store_mode);
 
 /*
- * Show and set the bonding transmit hash method.  The bond interface must be down to
- * change the xmit hash policy.
+ * Show and set the bonding transmit hash method.
+ * The bond interface must be down to change the xmit hash policy.
  */
 static ssize_t bonding_show_xmit_hash(struct device *d,
 				      struct device_attribute *attr,
@@ -424,7 +427,7 @@ static ssize_t bonding_store_xmit_hash(s
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       "%s: Interface is up. Unable to update xmit policy.\n",
 		       bond->dev->name);
 		ret = -EPERM;
@@ -433,7 +436,7 @@ static ssize_t bonding_store_xmit_hash(s
 
 	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Ignoring invalid xmit hash policy value %.*s.\n",
 		       bond->dev->name,
 		       (int)strlen(buf) - 1, buf);
@@ -442,13 +445,15 @@ static ssize_t bonding_store_xmit_hash(s
 	} else {
 		bond->params.xmit_policy = new_value;
 		bond_set_mode_ops(bond, bond->params.mode);
-		printk(KERN_INFO DRV_NAME ": %s: setting xmit hash policy to %s (%d).\n",
-			bond->dev->name, xmit_hashtype_tbl[new_value].modename, new_value);
+		pr_info(DRV_NAME ": %s: setting xmit hash policy to %s (%d).\n",
+			bond->dev->name,
+			xmit_hashtype_tbl[new_value].modename, new_value);
 	}
 out:
 	return ret;
 }
-static DEVICE_ATTR(xmit_hash_policy, S_IRUGO | S_IWUSR, bonding_show_xmit_hash, bonding_store_xmit_hash);
+static DEVICE_ATTR(xmit_hash_policy, S_IRUGO | S_IWUSR,
+		   bonding_show_xmit_hash, bonding_store_xmit_hash);
 
 /*
  * Show and set arp_validate.
@@ -473,39 +478,41 @@ static ssize_t bonding_store_arp_validat
 
 	new_value = bond_parse_parm(buf, arp_validate_tbl);
 	if (new_value < 0) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Ignoring invalid arp_validate value %s\n",
 		       bond->dev->name, buf);
 		return -EINVAL;
 	}
 	if (new_value && (bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: arp_validate only supported in active-backup mode.\n",
 		       bond->dev->name);
 		return -EINVAL;
 	}
-	printk(KERN_INFO DRV_NAME ": %s: setting arp_validate to %s (%d).\n",
+	pr_info(DRV_NAME ": %s: setting arp_validate to %s (%d).\n",
 	       bond->dev->name, arp_validate_tbl[new_value].modename,
 	       new_value);
 
-	if (!bond->params.arp_validate && new_value) {
+	if (!bond->params.arp_validate && new_value)
 		bond_register_arp(bond);
-	} else if (bond->params.arp_validate && !new_value) {
+	else if (bond->params.arp_validate && !new_value)
 		bond_unregister_arp(bond);
-	}
 
 	bond->params.arp_validate = new_value;
 
 	return count;
 }
 
-static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate, bonding_store_arp_validate);
+static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate,
+		   bonding_store_arp_validate);
 
 /*
  * Show and store fail_over_mac.  User only allowed to change the
  * value when there are no slaves.
  */
-static ssize_t bonding_show_fail_over_mac(struct device *d, struct device_attribute *attr, char *buf)
+static ssize_t bonding_show_fail_over_mac(struct device *d,
+					  struct device_attribute *attr,
+					  char *buf)
 {
 	struct bonding *bond = to_bond(d);
 
@@ -514,13 +521,15 @@ static ssize_t bonding_show_fail_over_ma
 		       bond->params.fail_over_mac);
 }
 
-static ssize_t bonding_store_fail_over_mac(struct device *d, struct device_attribute *attr, const char *buf, size_t count)
+static ssize_t bonding_store_fail_over_mac(struct device *d,
+					   struct device_attribute *attr,
+					   const char *buf, size_t count)
 {
 	int new_value;
 	struct bonding *bond = to_bond(d);
 
 	if (bond->slave_cnt != 0) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
 		return -EPERM;
@@ -528,21 +537,22 @@ static ssize_t bonding_store_fail_over_m
 
 	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
 	if (new_value < 0) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Ignoring invalid fail_over_mac value %s.\n",
 		       bond->dev->name, buf);
 		return -EINVAL;
 	}
 
 	bond->params.fail_over_mac = new_value;
-	printk(KERN_INFO DRV_NAME ": %s: Setting fail_over_mac to %s (%d).\n",
+	pr_info(DRV_NAME ": %s: Setting fail_over_mac to %s (%d).\n",
 	       bond->dev->name, fail_over_mac_tbl[new_value].modename,
 	       new_value);
 
 	return count;
 }
 
-static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR, bonding_show_fail_over_mac, bonding_store_fail_over_mac);
+static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR,
+		   bonding_show_fail_over_mac, bonding_store_fail_over_mac);
 
 /*
  * Show and set the arp timer interval.  There are two tricky bits
@@ -567,28 +577,28 @@ static ssize_t bonding_store_arp_interva
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: no arp_interval value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Invalid arp_interval value %d not in range 1-%d; rejected.\n",
 		       bond->dev->name, new_value, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	}
 
-	printk(KERN_INFO DRV_NAME
+	pr_info(DRV_NAME
 	       ": %s: Setting ARP monitoring interval to %d.\n",
 	       bond->dev->name, new_value);
 	bond->params.arp_interval = new_value;
 	if (bond->params.arp_interval)
 		bond->dev->priv_flags |= IFF_MASTER_ARPMON;
 	if (bond->params.miimon) {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: ARP monitoring cannot be used with MII monitoring. "
 		       "%s Disabling MII monitoring.\n",
 		       bond->dev->name, bond->dev->name);
@@ -599,7 +609,7 @@ static ssize_t bonding_store_arp_interva
 		}
 	}
 	if (!bond->params.arp_targets[0]) {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: ARP monitoring has been set up, "
 		       "but no ARP targets have been specified.\n",
 		       bond->dev->name);
@@ -625,7 +635,8 @@ static ssize_t bonding_store_arp_interva
 out:
 	return ret;
 }
-static DEVICE_ATTR(arp_interval, S_IRUGO | S_IWUSR , bonding_show_arp_interval, bonding_store_arp_interval);
+static DEVICE_ATTR(arp_interval, S_IRUGO | S_IWUSR,
+		   bonding_show_arp_interval, bonding_store_arp_interval);
 
 /*
  * Show and set the arp targets.
@@ -661,7 +672,7 @@ static ssize_t bonding_store_arp_targets
 	/* look for adds */
 	if (buf[0] == '+') {
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: invalid ARP target %pI4 specified for addition\n",
 			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
@@ -670,14 +681,14 @@ static ssize_t bonding_store_arp_targets
 		/* look for an empty slot to put the target in, and check for dupes */
 		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
 			if (targets[i] == newtarget) { /* duplicate */
-				printk(KERN_ERR DRV_NAME
+				pr_err(DRV_NAME
 				       ": %s: ARP target %pI4 is already present\n",
 				       bond->dev->name, &newtarget);
 				ret = -EINVAL;
 				goto out;
 			}
 			if (targets[i] == 0) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: adding ARP target %pI4.\n",
 				       bond->dev->name, &newtarget);
 				done = 1;
@@ -685,17 +696,16 @@ static ssize_t bonding_store_arp_targets
 			}
 		}
 		if (!done) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: ARP target table is full!\n",
 			       bond->dev->name);
 			ret = -EINVAL;
 			goto out;
 		}
 
-	}
-	else if (buf[0] == '-')	{
+	} else if (buf[0] == '-')	{
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
-			printk(KERN_ERR DRV_NAME
+			pr_err(DRV_NAME
 			       ": %s: invalid ARP target %pI4 specified for removal\n",
 			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
@@ -705,7 +715,7 @@ static ssize_t bonding_store_arp_targets
 		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
 			if (targets[i] == newtarget) {
 				int j;
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: removing ARP target %pI4.\n",
 				       bond->dev->name, &newtarget);
 				for (j = i; (j < (BOND_MAX_ARP_TARGETS-1)) && targets[j+1]; j++)
@@ -716,15 +726,15 @@ static ssize_t bonding_store_arp_targets
 			}
 		}
 		if (!done) {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: unable to remove nonexistent ARP target %pI4.\n",
 			       bond->dev->name, &newtarget);
 			ret = -EINVAL;
 			goto out;
 		}
-	}
-	else {
-		printk(KERN_ERR DRV_NAME ": no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
+	} else {
+		pr_err(DRV_NAME ": no command found in arp_ip_targets file"
+		       " for bond %s. Use +<addr> or -<addr>.\n",
 			bond->dev->name);
 		ret = -EPERM;
 		goto out;
@@ -757,7 +767,7 @@ static ssize_t bonding_store_downdelay(s
 	struct bonding *bond = to_bond(d);
 
 	if (!(bond->params.miimon)) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Unable to set down delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		ret = -EPERM;
@@ -765,14 +775,14 @@ static ssize_t bonding_store_downdelay(s
 	}
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: no down delay value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Invalid down delay value %d not in range %d-%d; rejected.\n",
 		       bond->dev->name, new_value, 1, INT_MAX);
 		ret = -EINVAL;
@@ -787,15 +797,17 @@ static ssize_t bonding_store_downdelay(s
 			       bond->params.miimon);
 		}
 		bond->params.downdelay = new_value / bond->params.miimon;
-		printk(KERN_INFO DRV_NAME ": %s: Setting down delay to %d.\n",
-		       bond->dev->name, bond->params.downdelay * bond->params.miimon);
+		pr_info(DRV_NAME ": %s: Setting down delay to %d.\n",
+		       bond->dev->name,
+		       bond->params.downdelay * bond->params.miimon);
 
 	}
 
 out:
 	return ret;
 }
-static DEVICE_ATTR(downdelay, S_IRUGO | S_IWUSR , bonding_show_downdelay, bonding_store_downdelay);
+static DEVICE_ATTR(downdelay, S_IRUGO | S_IWUSR,
+		   bonding_show_downdelay, bonding_store_downdelay);
 
 static ssize_t bonding_show_updelay(struct device *d,
 				    struct device_attribute *attr,
@@ -815,7 +827,7 @@ static ssize_t bonding_store_updelay(str
 	struct bonding *bond = to_bond(d);
 
 	if (!(bond->params.miimon)) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Unable to set up delay as MII monitoring is disabled\n",
 		       bond->dev->name);
 		ret = -EPERM;
@@ -823,14 +835,14 @@ static ssize_t bonding_store_updelay(str
 	}
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: no up delay value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Invalid down delay value %d not in range %d-%d; rejected.\n",
 		       bond->dev->name, new_value, 1, INT_MAX);
 		ret = -EINVAL;
@@ -845,7 +857,7 @@ static ssize_t bonding_store_updelay(str
 			       bond->params.miimon);
 		}
 		bond->params.updelay = new_value / bond->params.miimon;
-		printk(KERN_INFO DRV_NAME ": %s: Setting up delay to %d.\n",
+		pr_info(DRV_NAME ": %s: Setting up delay to %d.\n",
 		       bond->dev->name, bond->params.updelay * bond->params.miimon);
 
 	}
@@ -853,7 +865,8 @@ static ssize_t bonding_store_updelay(str
 out:
 	return ret;
 }
-static DEVICE_ATTR(updelay, S_IRUGO | S_IWUSR , bonding_show_updelay, bonding_store_updelay);
+static DEVICE_ATTR(updelay, S_IRUGO | S_IWUSR,
+		   bonding_show_updelay, bonding_store_updelay);
 
 /*
  * Show and set the LACP interval.  Interface must be down, and the mode
@@ -878,7 +891,7 @@ static ssize_t bonding_store_lacp(struct
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Unable to update LACP rate because interface is up.\n",
 		       bond->dev->name);
 		ret = -EPERM;
@@ -886,7 +899,7 @@ static ssize_t bonding_store_lacp(struct
 	}
 
 	if (bond->params.mode != BOND_MODE_8023AD) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Unable to update LACP rate because bond is not in 802.3ad mode.\n",
 		       bond->dev->name);
 		ret = -EPERM;
@@ -897,19 +910,20 @@ static ssize_t bonding_store_lacp(struct
 
 	if ((new_value == 1) || (new_value == 0)) {
 		bond->params.lacp_fast = new_value;
-		printk(KERN_INFO DRV_NAME
-		       ": %s: Setting LACP rate to %s (%d).\n",
-		       bond->dev->name, bond_lacp_tbl[new_value].modename, new_value);
+		pr_info(DRV_NAME ": %s: Setting LACP rate to %s (%d).\n",
+			bond->dev->name, bond_lacp_tbl[new_value].modename,
+			new_value);
 	} else {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Ignoring invalid LACP rate value %.*s.\n",
-		     	bond->dev->name, (int)strlen(buf) - 1, buf);
+		       bond->dev->name, (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
 	}
 out:
 	return ret;
 }
-static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR, bonding_show_lacp, bonding_store_lacp);
+static DEVICE_ATTR(lacp_rate, S_IRUGO | S_IWUSR,
+		   bonding_show_lacp, bonding_store_lacp);
 
 static ssize_t bonding_show_ad_select(struct device *d,
 				      struct device_attribute *attr,
@@ -931,7 +945,7 @@ static ssize_t bonding_store_ad_select(s
 	struct bonding *bond = to_bond(d);
 
 	if (bond->dev->flags & IFF_UP) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Unable to update ad_select because interface "
 		       "is up.\n", bond->dev->name);
 		ret = -EPERM;
@@ -942,12 +956,12 @@ static ssize_t bonding_store_ad_select(s
 
 	if (new_value != -1) {
 		bond->params.ad_select = new_value;
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: Setting ad_select to %s (%d).\n",
 		       bond->dev->name, ad_select_tbl[new_value].modename,
 		       new_value);
 	} else {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Ignoring invalid ad_select value %.*s.\n",
 		       bond->dev->name, (int)strlen(buf) - 1, buf);
 		ret = -EINVAL;
@@ -955,8 +969,8 @@ static ssize_t bonding_store_ad_select(s
 out:
 	return ret;
 }
-
-static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR, bonding_show_ad_select, bonding_store_ad_select);
+static DEVICE_ATTR(ad_select, S_IRUGO | S_IWUSR,
+		   bonding_show_ad_select, bonding_store_ad_select);
 
 /*
  * Show and set the number of grat ARP to send after a failover event.
@@ -978,14 +992,14 @@ static ssize_t bonding_store_n_grat_arp(
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: no num_grat_arp value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0 || new_value > 255) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Invalid num_grat_arp value %d not in range 0-255; rejected.\n",
 		       bond->dev->name, new_value);
 		ret = -EINVAL;
@@ -996,10 +1010,11 @@ static ssize_t bonding_store_n_grat_arp(
 out:
 	return ret;
 }
-static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR, bonding_show_n_grat_arp, bonding_store_n_grat_arp);
+static DEVICE_ATTR(num_grat_arp, S_IRUGO | S_IWUSR,
+		   bonding_show_n_grat_arp, bonding_store_n_grat_arp);
 
 /*
- * Show and set the number of unsolicted NA's to send after a failover event.
+ * Show and set the number of unsolicited NA's to send after a failover event.
  */
 static ssize_t bonding_show_n_unsol_na(struct device *d,
 				       struct device_attribute *attr,
@@ -1018,25 +1033,26 @@ static ssize_t bonding_store_n_unsol_na(
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: no num_unsol_na value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
+
 	if (new_value < 0 || new_value > 255) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Invalid num_unsol_na value %d not in range 0-255; rejected.\n",
 		       bond->dev->name, new_value);
 		ret = -EINVAL;
 		goto out;
-	} else {
+	} else
 		bond->params.num_unsol_na = new_value;
-	}
 out:
 	return ret;
 }
-static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR, bonding_show_n_unsol_na, bonding_store_n_unsol_na);
+static DEVICE_ATTR(num_unsol_na, S_IRUGO | S_IWUSR,
+		   bonding_show_n_unsol_na, bonding_store_n_unsol_na);
 
 /*
  * Show and set the MII monitor interval.  There are two tricky bits
@@ -1061,37 +1077,37 @@ static ssize_t bonding_store_miimon(stru
 	struct bonding *bond = to_bond(d);
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: no miimon value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
 		goto out;
 	}
 	if (new_value < 0) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: Invalid miimon value %d not in range %d-%d; rejected.\n",
 		       bond->dev->name, new_value, 1, INT_MAX);
 		ret = -EINVAL;
 		goto out;
 	} else {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: Setting MII monitoring interval to %d.\n",
 		       bond->dev->name, new_value);
 		bond->params.miimon = new_value;
-		if(bond->params.updelay)
-			printk(KERN_INFO DRV_NAME
+		if (bond->params.updelay)
+			pr_info(DRV_NAME
 			      ": %s: Note: Updating updelay (to %d) "
 			      "since it is a multiple of the miimon value.\n",
 			      bond->dev->name,
 			      bond->params.updelay * bond->params.miimon);
-		if(bond->params.downdelay)
-			printk(KERN_INFO DRV_NAME
+		if (bond->params.downdelay)
+			pr_info(DRV_NAME
 			      ": %s: Note: Updating downdelay (to %d) "
 			      "since it is a multiple of the miimon value.\n",
 			      bond->dev->name,
 			      bond->params.downdelay * bond->params.miimon);
 		if (bond->params.arp_interval) {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: MII monitoring cannot be used with "
 			       "ARP monitoring. Disabling ARP monitoring...\n",
 			       bond->dev->name);
@@ -1125,7 +1141,8 @@ static ssize_t bonding_store_miimon(stru
 out:
 	return ret;
 }
-static DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR, bonding_show_miimon, bonding_store_miimon);
+static DEVICE_ATTR(miimon, S_IRUGO | S_IWUSR,
+		   bonding_show_miimon, bonding_store_miimon);
 
 /*
  * Show and set the primary slave.  The store function is much
@@ -1161,7 +1178,7 @@ static ssize_t bonding_store_primary(str
 	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: Unable to set primary slave; %s is in mode %d\n",
 		       bond->dev->name, bond->dev->name, bond->params.mode);
 	} else {
@@ -1169,7 +1186,7 @@ static ssize_t bonding_store_primary(str
 			if (strnicmp
 			    (slave->dev->name, buf,
 			     strlen(slave->dev->name)) == 0) {
-				printk(KERN_INFO DRV_NAME
+				pr_info(DRV_NAME
 				       ": %s: Setting %s as primary slave.\n",
 				       bond->dev->name, slave->dev->name);
 				bond->primary_slave = slave;
@@ -1181,13 +1198,13 @@ static ssize_t bonding_store_primary(str
 		/* if we got here, then we didn't match the name of any slave */
 
 		if (strlen(buf) == 0 || buf[0] == '\n') {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: Setting primary slave to None.\n",
 			       bond->dev->name);
 			bond->primary_slave = NULL;
 				bond_select_active_slave(bond);
 		} else {
-			printk(KERN_INFO DRV_NAME
+			pr_info(DRV_NAME
 			       ": %s: Unable to set %.*s as primary slave as it is not a slave.\n",
 			       bond->dev->name, (int)strlen(buf) - 1, buf);
 		}
@@ -1199,7 +1216,8 @@ out:
 
 	return count;
 }
-static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
+static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR,
+		   bonding_show_primary, bonding_store_primary);
 
 /*
  * Show and set the use_carrier flag.
@@ -1222,7 +1240,7 @@ static ssize_t bonding_store_carrier(str
 
 
 	if (sscanf(buf, "%d", &new_value) != 1) {
-		printk(KERN_ERR DRV_NAME
+		pr_err(DRV_NAME
 		       ": %s: no use_carrier value specified.\n",
 		       bond->dev->name);
 		ret = -EINVAL;
@@ -1230,17 +1248,18 @@ static ssize_t bonding_store_carrier(str
 	}
 	if ((new_value == 0) || (new_value == 1)) {
 		bond->params.use_carrier = new_value;
-		printk(KERN_INFO DRV_NAME ": %s: Setting use_carrier to %d.\n",
+		pr_info(DRV_NAME ": %s: Setting use_carrier to %d.\n",
 		       bond->dev->name, new_value);
 	} else {
-		printk(KERN_INFO DRV_NAME
+		pr_info(DRV_NAME
 		       ": %s: Ignoring invalid use_carrier value %d.\n",
 		       bond->dev->name, new_value);
 	}
 out:
 	return count;
 }
-static DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR, bonding_show_carrier, bonding_store_carrier);
+static DEVICE_ATTR(use_carrier, S_IRUGO | S_IWUSR,
+		   bonding_show_carrier, bonding_store_carrier);
 
 
 /*
@@ -1269,8 +1288,8 @@ static ssize_t bonding_store_active_slav
 {
 	int i;
 	struct slave *slave;
-        struct slave *old_active = NULL;
-        struct slave *new_active = NULL;
+	struct slave *old_active = NULL;
+	struct slave *new_active = NULL;
 	struct bonding *bond = to_bond(d);
 
 	if (!rtnl_trylock())
@@ -1278,11 +1297,11 @@ static ssize_t bonding_store_active_slav
 	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
-	if (!USES_PRIMARY(bond->params.mode)) {
-		printk(KERN_INFO DRV_NAME
-		       ": %s: Unable to change active slave; %s is in mode %d\n",
-		       bond->dev->name, bond->dev->name, bond->params.mode);
-	} else {
+	if (!USES_PRIMARY(bond->params.mode))
+		pr_info(DRV_NAME ": %s: Unable to change active slave;"
+			" %s is in mode %d\n",
+			bond->dev->name, bond->dev->name, bond->params.mode);
+	else {
 		bond_for_each_slave(bond, slave, i) {
 			if (strnicmp
 			    (slave->dev->name, buf,
@@ -1321,18 +1340,18 @@ static ssize_t bonding_store_active_slav
 		/* if we got here, then we didn't match the name of any slave */
 
 		if (strlen(buf) == 0 || buf[0] == '\n') {
-			printk(KERN_INFO DRV_NAME
-			       ": %s: Setting active slave to None.\n",
-			       bond->dev->name);
+			pr_info(DRV_NAME
+				": %s: Setting active slave to None.\n",
+				bond->dev->name);
 			bond->primary_slave = NULL;
-				bond_select_active_slave(bond);
+			bond_select_active_slave(bond);
 		} else {
-			printk(KERN_INFO DRV_NAME
-			       ": %s: Unable to set %.*s as active slave as it is not a slave.\n",
-			       bond->dev->name, (int)strlen(buf) - 1, buf);
+			pr_info(DRV_NAME ": %s: Unable to set %.*s"
+				" as active slave as it is not a slave.\n",
+				bond->dev->name, (int)strlen(buf) - 1, buf);
 		}
 	}
-out:
+ out:
 	write_unlock_bh(&bond->curr_slave_lock);
 	read_unlock(&bond->lock);
 	rtnl_unlock();
@@ -1340,7 +1359,8 @@ out:
 	return count;
 
 }
-static DEVICE_ATTR(active_slave, S_IRUGO | S_IWUSR, bonding_show_active_slave, bonding_store_active_slave);
+static DEVICE_ATTR(active_slave, S_IRUGO | S_IWUSR,
+		   bonding_show_active_slave, bonding_store_active_slave);
 
 
 /*
@@ -1357,7 +1377,7 @@ static ssize_t bonding_show_mii_status(s
 	curr = bond->curr_active_slave;
 	read_unlock(&bond->curr_slave_lock);
 
-	return sprintf(buf, "%s\n", (curr) ? "up" : "down");
+	return sprintf(buf, "%s\n", curr ? "up" : "down");
 }
 static DEVICE_ATTR(mii_status, S_IRUGO, bonding_show_mii_status, NULL);
 
@@ -1374,7 +1394,9 @@ static ssize_t bonding_show_ad_aggregato
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.aggregator_id);
+		count = sprintf(buf, "%d\n",
+				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				?  0 : ad_info.aggregator_id);
 	}
 
 	return count;
@@ -1394,7 +1416,9 @@ static ssize_t bonding_show_ad_num_ports
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0: ad_info.ports);
+		count = sprintf(buf, "%d\n",
+				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				?  0 : ad_info.ports);
 	}
 
 	return count;
@@ -1414,7 +1438,9 @@ static ssize_t bonding_show_ad_actor_key
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.actor_key);
+		count = sprintf(buf, "%d\n",
+				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				?  0 : ad_info.actor_key);
 	}
 
 	return count;
@@ -1434,7 +1460,9 @@ static ssize_t bonding_show_ad_partner_k
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		count = sprintf(buf, "%d\n", (bond_3ad_get_active_agg_info(bond, &ad_info)) ?  0 : ad_info.partner_key);
+		count = sprintf(buf, "%d\n",
+				(bond_3ad_get_active_agg_info(bond, &ad_info))
+				?  0 : ad_info.partner_key);
 	}
 
 	return count;
@@ -1454,9 +1482,8 @@ static ssize_t bonding_show_ad_partner_m
 
 	if (bond->params.mode == BOND_MODE_8023AD) {
 		struct ad_info ad_info;
-		if (!bond_3ad_get_active_agg_info(bond, &ad_info)) {
+		if (!bond_3ad_get_active_agg_info(bond, &ad_info))
 			count = sprintf(buf, "%pM\n", ad_info.partner_system);
-		}
 	}
 
 	return count;
@@ -1549,9 +1576,8 @@ int bond_create_sysfs_entry(struct bondi
 	int err;
 
 	err = sysfs_create_group(&(dev->dev.kobj), &bonding_group);
-	if (err) {
+	if (err)
 		printk(KERN_EMERG "eek! didn't create group!\n");
-	}
 
 	if (expected_refcount < 1)
 		expected_refcount = atomic_read(&bond->dev->dev.kobj.kref.refcount);

-- 


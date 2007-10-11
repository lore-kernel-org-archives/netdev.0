From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/6] Convert more locks to _bh, acquire rtnl, for new locking
Date: Wed, 10 Oct 2007 21:14:08 -0700
Message-ID: <11920760533281-git-send-email-fubar@us.ibm.com>
References: <11920760494096-git-send-email-fubar@us.ibm.com>
 <11920760502756-git-send-email-fubar@us.ibm.com>
 <1192076051437-git-send-email-fubar@us.ibm.com>
 <11920760522759-git-send-email-fubar@us.ibm.com>
 <11920760532491-git-send-email-fubar@us.ibm.com>
Cc: andy@greyhouse.net, Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org, jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e34.co.us.ibm.com ([32.97.110.152]:45091 "EHLO
	e34.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751446AbXJKEOR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 00:14:17 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e34.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id l9B4EFiE021314
	for <netdev@vger.kernel.org>; Thu, 11 Oct 2007 00:14:15 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l9B4EEcW355642
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:15 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l9B4EEhc027265
	for <netdev@vger.kernel.org>; Wed, 10 Oct 2007 22:14:14 -0600
In-Reply-To: <11920760532491-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Convert more lock acquisitions to _bh flavor to avoid deadlock
with workqueue activity and add acquisition of RTNL in appropriate places.
Affects ALB mode, as well as core bonding functions and sysfs.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_alb.c   |   16 ++++++++--------
 drivers/net/bonding/bond_main.c  |   18 +++++++++---------
 drivers/net/bonding/bond_sysfs.c |   18 ++++++++++++------
 3 files changed, 29 insertions(+), 23 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index f2e2872..6db5d76 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -128,12 +128,12 @@ static inline u8 _simple_hash(const u8 *hash_start, int hash_size)
 
 static inline void _lock_tx_hashtbl(struct bonding *bond)
 {
-	spin_lock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	spin_lock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
 static inline void _unlock_tx_hashtbl(struct bonding *bond)
 {
-	spin_unlock(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).tx_hashtbl_lock));
 }
 
 /* Caller must hold tx_hashtbl lock */
@@ -305,12 +305,12 @@ static struct slave *tlb_choose_channel(struct bonding *bond, u32 hash_index, u3
 /*********************** rlb specific functions ***************************/
 static inline void _lock_rx_hashtbl(struct bonding *bond)
 {
-	spin_lock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 }
 
 static inline void _unlock_rx_hashtbl(struct bonding *bond)
 {
-	spin_unlock(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
 }
 
 /* when an ARP REPLY is received from a client update its info
@@ -472,13 +472,13 @@ static void rlb_clear_slave(struct bonding *bond, struct slave *slave)
 
 	_unlock_rx_hashtbl(bond);
 
-	write_lock(&bond->curr_slave_lock);
+	write_lock_bh(&bond->curr_slave_lock);
 
 	if (slave != bond->curr_active_slave) {
 		rlb_teach_disabled_mac_on_primary(bond, slave->dev->dev_addr);
 	}
 
-	write_unlock(&bond->curr_slave_lock);
+	write_unlock_bh(&bond->curr_slave_lock);
 }
 
 static void rlb_update_client(struct rlb_client_info *client_info)
@@ -1519,11 +1519,11 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 	/* caller must hold the bond lock for write since the mac addresses
 	 * are compared and may be swapped.
 	 */
-	write_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	res = alb_handle_addr_collision_on_attach(bond, slave);
 
-	write_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	if (res) {
 		return res;
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2bb5b50..5bd1e2e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1955,9 +1955,9 @@ static int bond_info_query(struct net_device *bond_dev, struct ifbond *info)
 	info->bond_mode = bond->params.mode;
 	info->miimon = bond->params.miimon;
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	info->num_slaves = bond->slave_cnt;
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	return 0;
 }
@@ -1972,7 +1972,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 		return -ENODEV;
 	}
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	bond_for_each_slave(bond, slave, i) {
 		if (i == (int)info->slave_id) {
@@ -1981,7 +1981,7 @@ static int bond_slave_info_query(struct net_device *bond_dev, struct ifslave *in
 		}
 	}
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 
 	if (found) {
 		strcpy(info->slave_name, slave->dev->name);
@@ -2965,7 +2965,7 @@ static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
 
 	/* make sure the bond won't be taken away */
 	read_lock(&dev_base_lock);
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 
 	if (*pos == 0) {
 		return SEQ_START_TOKEN;
@@ -2999,7 +2999,7 @@ static void bond_info_seq_stop(struct seq_file *seq, void *v)
 {
 	struct bonding *bond = seq->private;
 
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	read_unlock(&dev_base_lock);
 }
 
@@ -3699,13 +3699,13 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 		if (mii->reg_num == 1) {
 			struct bonding *bond = bond_dev->priv;
 			mii->val_out = 0;
-			read_lock_bh(&bond->lock);
+			read_lock(&bond->lock);
 			read_lock(&bond->curr_slave_lock);
 			if (netif_carrier_ok(bond->dev)) {
 				mii->val_out = BMSR_LSTATUS;
 			}
 			read_unlock(&bond->curr_slave_lock);
-			read_unlock_bh(&bond->lock);
+			read_unlock(&bond->lock);
 		}
 
 		return 0;
@@ -4343,8 +4343,8 @@ static void bond_free_all(void)
 		bond_mc_list_destroy(bond);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
-		bond_deinit(bond_dev);
 		unregister_netdevice(bond_dev);
+		bond_deinit(bond_dev);
 	}
 
 #ifdef CONFIG_PROC_FS
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index cf102e6..ac507d9 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -164,9 +164,9 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 				printk(KERN_INFO DRV_NAME
 					": %s is being deleted...\n",
 					bond->dev->name);
+				unregister_netdevice(bond->dev);
 				bond_deinit(bond->dev);
 		        	bond_destroy_sysfs_entry(bond);
-				unregister_netdevice(bond->dev);
 				rtnl_unlock();
 				goto out;
 			}
@@ -231,7 +231,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 	int i, res = 0;
 	struct bonding *bond = to_bond(d);
 
-	read_lock_bh(&bond->lock);
+	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
@@ -242,7 +242,7 @@ static ssize_t bonding_show_slaves(struct device *d,
 		}
 		res += sprintf(buf + res, "%s ", slave->dev->name);
 	}
-	read_unlock_bh(&bond->lock);
+	read_unlock(&bond->lock);
 	res += sprintf(buf + res, "\n");
 	res++;
 	return res;
@@ -285,18 +285,18 @@ static ssize_t bonding_store_slaves(struct device *d,
 
 		/* Got a slave name in ifname.  Is it already in the list? */
 		found = 0;
-		read_lock_bh(&bond->lock);
+		read_lock(&bond->lock);
 		bond_for_each_slave(bond, slave, i)
 			if (strnicmp(slave->dev->name, ifname, IFNAMSIZ) == 0) {
 				printk(KERN_ERR DRV_NAME
 				       ": %s: Interface %s is already enslaved!\n",
 				       bond->dev->name, ifname);
 				ret = -EPERM;
-				read_unlock_bh(&bond->lock);
+				read_unlock(&bond->lock);
 				goto out;
 			}
 
-		read_unlock_bh(&bond->lock);
+		read_unlock(&bond->lock);
 		printk(KERN_INFO DRV_NAME ": %s: Adding slave %s.\n",
 		       bond->dev->name, ifname);
 		dev = dev_get_by_name(&init_net, ifname);
@@ -1080,6 +1080,9 @@ static ssize_t bonding_store_primary(struct device *d,
 	}
 out:
 	write_unlock_bh(&bond->lock);
+
+	rtnl_unlock();
+
 	return count;
 }
 static DEVICE_ATTR(primary, S_IRUGO | S_IWUSR, bonding_show_primary, bonding_store_primary);
@@ -1137,6 +1140,7 @@ static ssize_t bonding_show_active_slave(struct device *d,
 	struct bonding *bond = to_bond(d);
 	int count;
 
+	rtnl_lock();
 
 	read_lock(&bond->curr_slave_lock);
 	curr = bond->curr_active_slave;
@@ -1216,6 +1220,8 @@ static ssize_t bonding_store_active_slave(struct device *d,
 	}
 out:
 	write_unlock_bh(&bond->lock);
+	rtnl_unlock();
+
 	return count;
 
 }
-- 
1.5.3.1


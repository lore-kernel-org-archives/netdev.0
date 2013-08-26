From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next v1 9/9] bonding: remove vlan_list/current_alb_vlan
Date: Mon, 26 Aug 2013 22:32:42 +0200
Message-ID: <1377549162-7522-10-git-send-email-vfalico@redhat.com>
References: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35901 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752458Ab3HZUcj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Aug 2013 16:32:39 -0400
In-Reply-To: <1377549162-7522-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there are no real users of vlan_list/current_alb_vlan, only the
helpers which maintain them, so remove them.

v1: no change

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c  |    5 --
 drivers/net/bonding/bond_alb.h  |    1 -
 drivers/net/bonding/bond_main.c |  133 +--------------------------------------
 drivers/net/bonding/bonding.h   |    6 --
 4 files changed, 2 insertions(+), 143 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 676d6d6..17e2cef 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1763,11 +1763,6 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 
 void bond_alb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 {
-	if (bond->alb_info.current_alb_vlan &&
-	    (bond->alb_info.current_alb_vlan->vlan_id == vlan_id)) {
-		bond->alb_info.current_alb_vlan = NULL;
-	}
-
 	if (bond->alb_info.rlb_enabled) {
 		rlb_clear_vlan(bond, vlan_id);
 	}
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index e139172..e02c9c5 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -169,7 +169,6 @@ struct alb_bond_info {
 						 * rx traffic should be
 						 * rebalanced
 						 */
-	struct vlan_entry	*current_alb_vlan;
 };
 
 int bond_alb_initialize(struct bonding *bond, int rlb_enabled);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index aaf14a0..3757558 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -283,116 +283,6 @@ const char *bond_mode_name(int mode)
 /*---------------------------------- VLAN -----------------------------------*/
 
 /**
- * bond_add_vlan - add a new vlan id on bond
- * @bond: bond that got the notification
- * @vlan_id: the vlan id to add
- *
- * Returns -ENOMEM if allocation failed.
- */
-static int bond_add_vlan(struct bonding *bond, unsigned short vlan_id)
-{
-	struct vlan_entry *vlan;
-
-	pr_debug("bond: %s, vlan id %d\n",
-		 (bond ? bond->dev->name : "None"), vlan_id);
-
-	vlan = kzalloc(sizeof(struct vlan_entry), GFP_KERNEL);
-	if (!vlan)
-		return -ENOMEM;
-
-	INIT_LIST_HEAD(&vlan->vlan_list);
-	vlan->vlan_id = vlan_id;
-
-	write_lock_bh(&bond->lock);
-
-	list_add_tail(&vlan->vlan_list, &bond->vlan_list);
-
-	write_unlock_bh(&bond->lock);
-
-	pr_debug("added VLAN ID %d on bond %s\n", vlan_id, bond->dev->name);
-
-	return 0;
-}
-
-/**
- * bond_del_vlan - delete a vlan id from bond
- * @bond: bond that got the notification
- * @vlan_id: the vlan id to delete
- *
- * returns -ENODEV if @vlan_id was not found in @bond.
- */
-static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
-{
-	struct vlan_entry *vlan;
-	int res = -ENODEV;
-
-	pr_debug("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
-
-	block_netpoll_tx();
-	write_lock_bh(&bond->lock);
-
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		if (vlan->vlan_id == vlan_id) {
-			list_del(&vlan->vlan_list);
-
-			if (bond_is_lb(bond))
-				bond_alb_clear_vlan(bond, vlan_id);
-
-			pr_debug("removed VLAN ID %d from bond %s\n",
-				 vlan_id, bond->dev->name);
-
-			kfree(vlan);
-
-			res = 0;
-			goto out;
-		}
-	}
-
-	pr_debug("couldn't find VLAN ID %d in bond %s\n",
-		 vlan_id, bond->dev->name);
-
-out:
-	write_unlock_bh(&bond->lock);
-	unblock_netpoll_tx();
-	return res;
-}
-
-/**
- * bond_next_vlan - safely skip to the next item in the vlans list.
- * @bond: the bond we're working on
- * @curr: item we're advancing from
- *
- * Returns %NULL if list is empty, bond->next_vlan if @curr is %NULL,
- * or @curr->next otherwise (even if it is @curr itself again).
- *
- * Caller must hold bond->lock
- */
-struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
-{
-	struct vlan_entry *next, *last;
-
-	if (list_empty(&bond->vlan_list))
-		return NULL;
-
-	if (!curr) {
-		next = list_entry(bond->vlan_list.next,
-				  struct vlan_entry, vlan_list);
-	} else {
-		last = list_entry(bond->vlan_list.prev,
-				  struct vlan_entry, vlan_list);
-		if (last == curr) {
-			next = list_entry(bond->vlan_list.next,
-					  struct vlan_entry, vlan_list);
-		} else {
-			next = list_entry(curr->vlan_list.next,
-					  struct vlan_entry, vlan_list);
-		}
-	}
-
-	return next;
-}
-
-/**
  * bond_dev_queue_xmit - Prepare skb for xmit.
  *
  * @bond: bond device that got this skb for tx.
@@ -451,13 +341,6 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
 			goto unwind;
 	}
 
-	res = bond_add_vlan(bond, vid);
-	if (res) {
-		pr_err("%s: Error: Failed to add vlan id %d\n",
-		       bond_dev->name, vid);
-		goto unwind;
-	}
-
 	return 0;
 
 unwind:
@@ -478,17 +361,12 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave;
-	int res;
 
 	bond_for_each_slave(bond, slave)
 		vlan_vid_del(slave->dev, proto, vid);
 
-	res = bond_del_vlan(bond, vid);
-	if (res) {
-		pr_err("%s: Error: Failed to remove vlan id %d\n",
-		       bond_dev->name, vid);
-		return res;
-	}
+	if (bond_is_lb(bond))
+		bond_alb_clear_vlan(bond, vid);
 
 	return 0;
 }
@@ -4121,7 +3999,6 @@ static void bond_setup(struct net_device *bond_dev)
 
 	/* Initialize pointers */
 	bond->dev = bond_dev;
-	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
 	ether_setup(bond_dev);
@@ -4174,7 +4051,6 @@ static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *tmp_slave;
-	struct vlan_entry *vlan, *tmp;
 
 	bond_netpoll_cleanup(bond_dev);
 
@@ -4186,11 +4062,6 @@ static void bond_uninit(struct net_device *bond_dev)
 	list_del(&bond->bond_list);
 
 	bond_debug_unregister(bond);
-
-	list_for_each_entry_safe(vlan, tmp, &bond->vlan_list, vlan_list) {
-		list_del(&vlan->vlan_list);
-		kfree(vlan);
-	}
 }
 
 /*------------------------- Module initialization ---------------------------*/
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 9392e00..a26b134 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -185,11 +185,6 @@ struct bond_parm_tbl {
 
 #define BOND_MAX_MODENAME_LEN 20
 
-struct vlan_entry {
-	struct list_head vlan_list;
-	unsigned short vlan_id;
-};
-
 struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct list_head list;
@@ -254,7 +249,6 @@ struct bonding {
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
-	struct   list_head vlan_list;
 	struct   workqueue_struct *wq;
 	struct   delayed_work mii_work;
 	struct   delayed_work arp_work;
-- 
1.7.1

From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 6/6] bonding: remove unused bond->vlan_list
Date: Thu,  8 Aug 2013 18:57:59 +0200
Message-ID: <1375981079-2936-7-git-send-email-vfalico@redhat.com>
References: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19049 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965156Ab3HHQ5y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Aug 2013 12:57:54 -0400
In-Reply-To: <1375981079-2936-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

RFC -> v1: No changes.
v1  -> v2: No changes.

There are currently no users of bond->vlan_list (other than the maintaining
functions add/remove) - so remove it and every unneeded helper.

In this patch we remove:
vlan_list from struct bonding
bond_next_vlan - we don't need it anymore
struct vlan_entry - it was a helper struct for bond->vlan_list
some bits from bond_vlan_rx_add/kill_vid() - which were related to
	bond->vlan_list
(de)initialization of vlan_list from bond_setup/uninit
bond_add_vlan - its only scope was to maintain bond->vlan_list

We don't fully remove bond_del_vlan() - bond_alb_clear_vlan() still needs
to be called when a vlan disappears. And we make bond_del_vlan() to not
return anything cause it cannot fail already.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c |  117 +-------------------------------------
 drivers/net/bonding/bonding.h   |    6 --
 2 files changed, 4 insertions(+), 119 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index f536d05..6df818b 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -282,113 +282,24 @@ const char *bond_mode_name(int mode)
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
  * bond_del_vlan - delete a vlan id from bond
  * @bond: bond that got the notification
  * @vlan_id: the vlan id to delete
  *
  * returns -ENODEV if @vlan_id was not found in @bond.
  */
-static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
+static void bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 {
-	struct vlan_entry *vlan;
-	int res = -ENODEV;
-
 	pr_debug("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
 
 	block_netpoll_tx();
 	write_lock_bh(&bond->lock);
 
-	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
-		if (vlan->vlan_id == vlan_id) {
-			list_del(&vlan->vlan_list);
-
-			if (bond_is_lb(bond))
-				bond_alb_clear_vlan(bond, vlan_id);
-
-			pr_debug("removed VLAN ID %d from bond %s\n",
-				 vlan_id, bond->dev->name);
+	if (bond_is_lb(bond))
+		bond_alb_clear_vlan(bond, vlan_id);
 
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
 	write_unlock_bh(&bond->lock);
 	unblock_netpoll_tx();
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
 }
 
 /**
@@ -450,13 +361,6 @@ static int bond_vlan_rx_add_vid(struct net_device *bond_dev,
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
@@ -477,17 +381,11 @@ static int bond_vlan_rx_kill_vid(struct net_device *bond_dev,
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
+	bond_del_vlan(bond, vid);
 
 	return 0;
 }
@@ -4135,7 +4033,6 @@ static void bond_setup(struct net_device *bond_dev)
 
 	/* Initialize pointers */
 	bond->dev = bond_dev;
-	INIT_LIST_HEAD(&bond->vlan_list);
 
 	/* Initialize the device entry points */
 	ether_setup(bond_dev);
@@ -4188,7 +4085,6 @@ static void bond_uninit(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct slave *slave, *tmp_slave;
-	struct vlan_entry *vlan, *tmp;
 
 	bond_netpoll_cleanup(bond_dev);
 
@@ -4200,11 +4096,6 @@ static void bond_uninit(struct net_device *bond_dev)
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
index 9c4539e..bfa33c4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -186,11 +186,6 @@ struct bond_parm_tbl {
 
 #define BOND_MAX_MODENAME_LEN 20
 
-struct vlan_entry {
-	struct list_head vlan_list;
-	unsigned short vlan_id;
-};
-
 struct slave {
 	struct net_device *dev; /* first - useful for panic debug */
 	struct list_head list;
@@ -255,7 +250,6 @@ struct bonding {
 	struct   ad_bond_info ad_info;
 	struct   alb_bond_info alb_info;
 	struct   bond_params params;
-	struct   list_head vlan_list;
 	struct   workqueue_struct *wq;
 	struct   delayed_work mii_work;
 	struct   delayed_work arp_work;
-- 
1.7.1

From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 4/8] bonding: Relax unneeded _safe lists iterations.
Date: Sat, 17 May 2008 21:10:10 -0700
Message-ID: <1211083816660-git-send-email-fubar@us.ibm.com>
References: <12110838143907-git-send-email-fubar@us.ibm.com>
 <12110838151824-git-send-email-fubar@us.ibm.com>
 <12110838151104-git-send-email-fubar@us.ibm.com>
 <12110838162313-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>, Pavel Emelyanov <xemul@openvz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e31.co.us.ibm.com ([32.97.110.149]:39219 "EHLO
	e31.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751411AbYEREKa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 May 2008 00:10:30 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e31.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m4I4ANYM004122
	for <netdev@vger.kernel.org>; Sun, 18 May 2008 00:10:23 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m4I4AI0K073416
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:23 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m4I4AH3x004601
	for <netdev@vger.kernel.org>; Sat, 17 May 2008 22:10:18 -0600
In-Reply-To: <12110838162313-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@openvz.org>

Many places either do not modify the list under the list_for_each_xxx,
or break out of the loop as soon as the first element is removed.

Thus, this _safe iteration just occupies some unneeded .text space
and requires an additional variable.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Acked-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |   31 ++++++++++++++-----------------
 drivers/net/bonding/bond_sysfs.c |    3 +--
 2 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6b12164..5e3b942 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -261,14 +261,14 @@ static int bond_add_vlan(struct bonding *bond, unsigned short vlan_id)
  */
 static int bond_del_vlan(struct bonding *bond, unsigned short vlan_id)
 {
-	struct vlan_entry *vlan, *next;
+	struct vlan_entry *vlan;
 	int res = -ENODEV;
 
 	dprintk("bond: %s, vlan id %d\n", bond->dev->name, vlan_id);
 
 	write_lock_bh(&bond->lock);
 
-	list_for_each_entry_safe(vlan, next, &bond->vlan_list, vlan_list) {
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (vlan->vlan_id == vlan_id) {
 			list_del(&vlan->vlan_list);
 
@@ -2428,7 +2428,7 @@ out:
 
 static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 {
-	struct vlan_entry *vlan, *vlan_next;
+	struct vlan_entry *vlan;
 
 	if (ip == bond->master_ip)
 		return 1;
@@ -2436,8 +2436,7 @@ static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 	if (list_empty(&bond->vlan_list))
 		return 0;
 
-	list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-				 vlan_list) {
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (ip == vlan->vlan_ip)
 			return 1;
 	}
@@ -2479,7 +2478,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
 	int i, vlan_id, rv;
 	__be32 *targets = bond->params.arp_targets;
-	struct vlan_entry *vlan, *vlan_next;
+	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 	struct flowi fl;
 	struct rtable *rt;
@@ -2526,8 +2525,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		}
 
 		vlan_id = 0;
-		list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-					 vlan_list) {
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == rt->u.dst.dev) {
 				vlan_id = vlan->vlan_id;
@@ -3477,13 +3475,13 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 {
 	struct in_ifaddr *ifa = ptr;
 	struct net_device *vlan_dev, *event_dev = ifa->ifa_dev->dev;
-	struct bonding *bond, *bond_next;
-	struct vlan_entry *vlan, *vlan_next;
+	struct bonding *bond;
+	struct vlan_entry *vlan;
 
 	if (dev_net(ifa->ifa_dev->dev) != &init_net)
 		return NOTIFY_DONE;
 
-	list_for_each_entry_safe(bond, bond_next, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
 		if (bond->dev == event_dev) {
 			switch (event) {
 			case NETDEV_UP:
@@ -3500,8 +3498,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 		if (list_empty(&bond->vlan_list))
 			continue;
 
-		list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-					 vlan_list) {
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
 				switch (event) {
@@ -4851,7 +4848,7 @@ static struct lock_class_key bonding_netdev_xmit_lock_key;
 int bond_create(char *name, struct bond_params *params)
 {
 	struct net_device *bond_dev;
-	struct bonding *bond, *nxt;
+	struct bonding *bond;
 	int res;
 
 	rtnl_lock();
@@ -4859,7 +4856,7 @@ int bond_create(char *name, struct bond_params *params)
 
 	/* Check to see if the bond already exists. */
 	if (name) {
-		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
 				printk(KERN_ERR DRV_NAME
 			       ": cannot add bond %s; it already exists\n",
@@ -4931,7 +4928,7 @@ static int __init bonding_init(void)
 {
 	int i;
 	int res;
-	struct bonding *bond, *nxt;
+	struct bonding *bond;
 
 	printk(KERN_INFO "%s", version);
 
@@ -4961,7 +4958,7 @@ static int __init bonding_init(void)
 
 	goto out;
 err:
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
 		bond_work_cancel_all(bond);
 		destroy_workqueue(bond->wq);
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 452a789..1f02857 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -111,7 +111,6 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 	char *ifname;
 	int rv, res = count;
 	struct bonding *bond;
-	struct bonding *nxt;
 
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
@@ -134,7 +133,7 @@ static ssize_t bonding_store_bonds(struct class *cls, const char *buffer, size_t
 		rtnl_lock();
 		down_write(&bonding_rwsem);
 
-		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, ifname, IFNAMSIZ) == 0) {
 				/* check the ref count on the bond's kobject.
 				 * If it's > expected, then there's a file open,
-- 
1.5.2.4


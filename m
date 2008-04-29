From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 6/8][BONDING]: Relax unneeded _safe lists iterations.
Date: Tue, 29 Apr 2008 19:05:09 +0400
Message-ID: <48173925.8070005@openvz.org>
References: <481735F4.30909@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: bonding-devel@lists.sourceforge.net,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:54954 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751631AbYD2PoF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Apr 2008 11:44:05 -0400
In-Reply-To: <481735F4.30909@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Many places either do not modify the list under the list_for_each_xxx,
or break out of the loop as soon as the first element is removed.

Thus, this _safe iteration just occupies some unneeded .text space
and requires an additional variable.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---
 drivers/net/bonding/bond_main.c  |   36 ++++++++++++++++--------------------
 drivers/net/bonding/bond_sysfs.c |    3 +--
 2 files changed, 17 insertions(+), 22 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index c6661a9..8623e47 100644
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
 
 static int bond_has_ip(struct bonding *bond)
 {
-	struct vlan_entry *vlan, *vlan_next;
+	struct vlan_entry *vlan;
 
 	if (bond->master_ip)
 		return 1;
@@ -2436,8 +2436,7 @@ static int bond_has_ip(struct bonding *bond)
 	if (list_empty(&bond->vlan_list))
 		return 0;
 
-	list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-				 vlan_list) {
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (vlan->vlan_ip)
 			return 1;
 	}
@@ -2447,7 +2446,7 @@ static int bond_has_ip(struct bonding *bond)
 
 static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 {
-	struct vlan_entry *vlan, *vlan_next;
+	struct vlan_entry *vlan;
 
 	if (ip == bond->master_ip)
 		return 1;
@@ -2455,8 +2454,7 @@ static int bond_has_this_ip(struct bonding *bond, __be32 ip)
 	if (list_empty(&bond->vlan_list))
 		return 0;
 
-	list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-				 vlan_list) {
+	list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 		if (ip == vlan->vlan_ip)
 			return 1;
 	}
@@ -2498,7 +2496,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 {
 	int i, vlan_id, rv;
 	__be32 *targets = bond->params.arp_targets;
-	struct vlan_entry *vlan, *vlan_next;
+	struct vlan_entry *vlan;
 	struct net_device *vlan_dev;
 	struct flowi fl;
 	struct rtable *rt;
@@ -2545,8 +2543,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		}
 
 		vlan_id = 0;
-		list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-					 vlan_list) {
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == rt->u.dst.dev) {
 				vlan_id = vlan->vlan_id;
@@ -3503,13 +3500,13 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
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
@@ -3526,8 +3523,7 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 		if (list_empty(&bond->vlan_list))
 			continue;
 
-		list_for_each_entry_safe(vlan, vlan_next, &bond->vlan_list,
-					 vlan_list) {
+		list_for_each_entry(vlan, &bond->vlan_list, vlan_list) {
 			vlan_dev = vlan_group_get_device(bond->vlgrp, vlan->vlan_id);
 			if (vlan_dev == event_dev) {
 				switch (event) {
@@ -4877,7 +4873,7 @@ static struct lock_class_key bonding_netdev_xmit_lock_key;
 int bond_create(char *name, struct bond_params *params)
 {
 	struct net_device *bond_dev;
-	struct bonding *bond, *nxt;
+	struct bonding *bond;
 	int res;
 
 	rtnl_lock();
@@ -4885,7 +4881,7 @@ int bond_create(char *name, struct bond_params *params)
 
 	/* Check to see if the bond already exists. */
 	if (name) {
-		list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list)
+		list_for_each_entry(bond, &bond_dev_list, bond_list)
 			if (strnicmp(bond->dev->name, name, IFNAMSIZ) == 0) {
 				printk(KERN_ERR DRV_NAME
 			       ": cannot add bond %s; it already exists\n",
@@ -4962,7 +4958,7 @@ static int __init bonding_init(void)
 {
 	int i;
 	int res;
-	struct bonding *bond, *nxt;
+	struct bonding *bond;
 
 	printk(KERN_INFO "%s", version);
 
@@ -4992,7 +4988,7 @@ static int __init bonding_init(void)
 
 	goto out;
 err:
-	list_for_each_entry_safe(bond, nxt, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bond_dev_list, bond_list) {
 		bond_work_cancel_all(bond);
 		destroy_workqueue(bond->wq);
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 752e43b..8133855 100644
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
1.5.3.4


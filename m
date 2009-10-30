From: "Eric W. Biederman" <ebiederm@xmission.com>
Subject: [PATCH 6/6] bond: Add support for multiple network namespaces
Date: Thu, 29 Oct 2009 17:18:26 -0700
Message-ID: <1256861906-5059-6-git-send-email-ebiederm@xmission.com>
References: <m1tyxhwxah.fsf@fess.ebiederm.org>
Cc: <netdev@vger.kernel.org>, Jay Vosburgh <fubar@us.ibm.com>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:56337 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755586AbZJ3ASp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 20:18:45 -0400
In-Reply-To: <m1tyxhwxah.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric W. Biederman <ebiederm@aristanetworks.com>

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 drivers/net/bonding/bond_3ad.c   |    3 -
 drivers/net/bonding/bond_alb.c   |    3 -
 drivers/net/bonding/bond_ipv6.c  |    7 +--
 drivers/net/bonding/bond_main.c  |  111 +++++++++++++++++++++++++-------------
 drivers/net/bonding/bond_sysfs.c |   19 ++++---
 drivers/net/bonding/bonding.h    |   14 ++++--
 6 files changed, 99 insertions(+), 58 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 3cd8153..1d05819 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2445,9 +2445,6 @@ int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct net_device *dev, struct pac
 	struct slave *slave = NULL;
 	int ret = NET_RX_DROP;
 
-	if (dev_net(dev) != &init_net)
-		goto out;
-
 	if (!(dev->flags & IFF_MASTER))
 		goto out;
 
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 9b5936f..0d30d1e 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -355,9 +355,6 @@ static int rlb_arp_recv(struct sk_buff *skb, struct net_device *bond_dev, struct
 	struct arp_pkt *arp = (struct arp_pkt *)skb->data;
 	int res = NET_RX_DROP;
 
-	if (dev_net(bond_dev) != &init_net)
-		goto out;
-
 	while (bond_dev->priv_flags & IFF_802_1Q_VLAN)
 		bond_dev = vlan_dev_real_dev(bond_dev);
 
diff --git a/drivers/net/bonding/bond_ipv6.c b/drivers/net/bonding/bond_ipv6.c
index 83921ab..b72e1dc 100644
--- a/drivers/net/bonding/bond_ipv6.c
+++ b/drivers/net/bonding/bond_ipv6.c
@@ -25,6 +25,7 @@
 #include <net/ipv6.h>
 #include <net/ndisc.h>
 #include <net/addrconf.h>
+#include <net/netns/generic.h>
 #include "bonding.h"
 
 /*
@@ -152,11 +153,9 @@ static int bond_inet6addr_event(struct notifier_block *this,
 	struct net_device *vlan_dev, *event_dev = ifa->idev->dev;
 	struct bonding *bond;
 	struct vlan_entry *vlan;
+	struct bond_net *bn = net_generic(dev_net(event_dev), bond_net_id);
 
-	if (dev_net(event_dev) != &init_net)
-		return NOTIFY_DONE;
-
-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bn->dev_list, bond_list) {
 		if (bond->dev == event_dev) {
 			switch (event) {
 			case NETDEV_UP:
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 6da2a82..568609e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -75,6 +75,7 @@
 #include <linux/jiffies.h>
 #include <net/route.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
 #include "bonding.h"
 #include "bond_3ad.h"
 #include "bond_alb.h"
@@ -157,11 +158,7 @@ MODULE_PARM_DESC(fail_over_mac, "For active-backup, do not set all slaves to the
 static const char * const version =
 	DRV_DESCRIPTION ": v" DRV_VERSION " (" DRV_RELDATE ")\n";
 
-LIST_HEAD(bond_dev_list);
-
-#ifdef CONFIG_PROC_FS
-static struct proc_dir_entry *bond_proc_dir;
-#endif
+int bond_net_id;
 
 static __be32 arp_target[BOND_MAX_ARP_TARGETS];
 static int arp_ip_count;
@@ -2586,7 +2583,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 		fl.fl4_dst = targets[i];
 		fl.fl4_tos = RTO_ONLINK;
 
-		rv = ip_route_output_key(&init_net, &rt, &fl);
+		rv = ip_route_output_key(dev_net(bond->dev), &rt, &fl);
 		if (rv) {
 			if (net_ratelimit()) {
 				pr_warning(DRV_NAME
@@ -2694,9 +2691,6 @@ static int bond_arp_rcv(struct sk_buff *skb, struct net_device *dev, struct pack
 	unsigned char *arp_ptr;
 	__be32 sip, tip;
 
-	if (dev_net(dev) != &init_net)
-		goto out;
-
 	if (!(dev->priv_flags & IFF_BONDING) || !(dev->flags & IFF_MASTER))
 		goto out;
 
@@ -3359,10 +3353,11 @@ static const struct file_operations bond_info_fops = {
 static void bond_create_proc_entry(struct bonding *bond)
 {
 	struct net_device *bond_dev = bond->dev;
+	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
 
-	if (bond_proc_dir) {
+	if (bn->proc_dir) {
 		bond->proc_entry = proc_create_data(bond_dev->name,
-						    S_IRUGO, bond_proc_dir,
+						    S_IRUGO, bn->proc_dir,
 						    &bond_info_fops, bond);
 		if (bond->proc_entry == NULL)
 			pr_warning(DRV_NAME
@@ -3375,8 +3370,11 @@ static void bond_create_proc_entry(struct bonding *bond)
 
 static void bond_remove_proc_entry(struct bonding *bond)
 {
-	if (bond_proc_dir && bond->proc_entry) {
-		remove_proc_entry(bond->proc_file_name, bond_proc_dir);
+	struct net_device *bond_dev = bond->dev;
+	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
+
+	if (bn->proc_dir && bond->proc_entry) {
+		remove_proc_entry(bond->proc_file_name, bn->proc_dir);
 		memset(bond->proc_file_name, 0, IFNAMSIZ);
 		bond->proc_entry = NULL;
 	}
@@ -3385,11 +3383,11 @@ static void bond_remove_proc_entry(struct bonding *bond)
 /* Create the bonding directory under /proc/net, if doesn't exist yet.
  * Caller must hold rtnl_lock.
  */
-static void bond_create_proc_dir(void)
+static void bond_create_proc_dir(struct bond_net *bn)
 {
-	if (!bond_proc_dir) {
-		bond_proc_dir = proc_mkdir(DRV_NAME, init_net.proc_net);
-		if (!bond_proc_dir)
+	if (!bn->proc_dir) {
+		bn->proc_dir = proc_mkdir(DRV_NAME, bn->net->proc_net);
+		if (!bn->proc_dir)
 			pr_warning(DRV_NAME
 				": Warning: cannot create /proc/net/%s\n",
 				DRV_NAME);
@@ -3399,11 +3397,11 @@ static void bond_create_proc_dir(void)
 /* Destroy the bonding directory under /proc/net, if empty.
  * Caller must hold rtnl_lock.
  */
-static void bond_destroy_proc_dir(void)
+static void bond_destroy_proc_dir(struct bond_net *bn)
 {
-	if (bond_proc_dir) {
-		remove_proc_entry(DRV_NAME, init_net.proc_net);
-		bond_proc_dir = NULL;
+	if (bn->proc_dir) {
+		remove_proc_entry(DRV_NAME, bn->net->proc_net);
+		bn->proc_dir = NULL;
 	}
 }
 
@@ -3417,11 +3415,11 @@ static void bond_remove_proc_entry(struct bonding *bond)
 {
 }
 
-static void bond_create_proc_dir(void)
+static void bond_create_proc_dir(struct bond_net *bn)
 {
 }
 
-static void bond_destroy_proc_dir(void)
+static void bond_destroy_proc_dir(struct bond_net *bn)
 {
 }
 
@@ -3540,9 +3538,6 @@ static int bond_netdev_event(struct notifier_block *this,
 {
 	struct net_device *event_dev = (struct net_device *)ptr;
 
-	if (dev_net(event_dev) != &init_net)
-		return NOTIFY_DONE;
-
 	pr_debug("event_dev: %s, event: %lx\n",
 		(event_dev ? event_dev->name : "None"),
 		event);
@@ -3575,13 +3570,11 @@ static int bond_inetaddr_event(struct notifier_block *this, unsigned long event,
 {
 	struct in_ifaddr *ifa = ptr;
 	struct net_device *vlan_dev, *event_dev = ifa->ifa_dev->dev;
+	struct bond_net *bn = net_generic(dev_net(event_dev), bond_net_id);
 	struct bonding *bond;
 	struct vlan_entry *vlan;
 
-	if (dev_net(ifa->ifa_dev->dev) != &init_net)
-		return NOTIFY_DONE;
-
-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bn->dev_list, bond_list) {
 		if (bond->dev == event_dev) {
 			switch (event) {
 			case NETDEV_UP:
@@ -3950,7 +3943,7 @@ static int bond_do_ioctl(struct net_device *bond_dev, struct ifreq *ifr, int cmd
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	slave_dev = dev_get_by_name(&init_net, ifr->ifr_slave);
+	slave_dev = dev_get_by_name(dev_net(bond_dev), ifr->ifr_slave);
 
 	pr_debug("slave_dev=%p: \n", slave_dev);
 
@@ -5031,6 +5024,7 @@ static void bond_set_lockdep_class(struct net_device *dev)
 static int bond_init(struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct bond_net *bn = net_generic(dev_net(bond_dev), bond_net_id);
 
 	pr_debug("Begin bond_init for %s\n", bond_dev->name);
 
@@ -5043,7 +5037,7 @@ static int bond_init(struct net_device *bond_dev)
 	netif_carrier_off(bond_dev);
 
 	bond_create_proc_entry(bond);
-	list_add_tail(&bond->bond_list, &bond_dev_list);
+	list_add_tail(&bond->bond_list, &bn->dev_list);
 
 	bond_prepare_sysfs_group(bond);
 	return 0;
@@ -5071,7 +5065,7 @@ static struct rtnl_link_ops bond_link_ops __read_mostly = {
  * Caller must NOT hold rtnl_lock; we need to release it here before we
  * set up our sysfs entries.
  */
-int bond_create(const char *name)
+int bond_create(struct net *net, const char *name)
 {
 	struct net_device *bond_dev;
 	int res;
@@ -5087,6 +5081,7 @@ int bond_create(const char *name)
 		goto out;
 	}
 
+	dev_net_set(bond_dev, net);
 	bond_dev->rtnl_link_ops = &bond_link_ops;
 
 	if (!name) {
@@ -5105,6 +5100,46 @@ out_netdev:
 	goto out;
 }
 
+static int bond_net_init(struct net *net)
+{
+	struct bond_net *bn;
+	int err;
+
+	err = -ENOMEM;
+	bn = kzalloc(sizeof(struct bond_net), GFP_KERNEL);
+	if (bn == NULL)
+		goto out;
+
+	bn->net = net;
+	INIT_LIST_HEAD(&bn->dev_list);
+
+	err = net_assign_generic(net, bond_net_id, bn);
+	if (err)
+		goto out_free;
+
+	bond_create_proc_dir(bn);
+out:
+	return err;
+out_free:
+	kfree(bn);
+	goto out;
+}
+
+static void bond_net_exit(struct net *net)
+{
+	struct bond_net *bn;
+
+	bn = net_generic(net, bond_net_id);
+
+	bond_destroy_proc_dir(bn);
+	kfree(bn);
+}
+
+static struct pernet_operations bond_net_ops = {
+	.init = bond_net_init,
+	.exit = bond_net_exit,
+};
+
 static int __init bonding_init(void)
 {
 	int i;
@@ -5116,14 +5151,16 @@ static int __init bonding_init(void)
 	if (res)
 		goto out;
 
-	bond_create_proc_dir();
+	res = register_pernet_gen_subsys(&bond_net_id, &bond_net_ops);
+	if (res)
+		goto out;
 
 	res = rtnl_link_register(&bond_link_ops);
 	if (res)
 		goto err;
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(NULL);
+		res = bond_create(&init_net, NULL);
 		if (res)
 			goto err;
 	}
@@ -5139,7 +5176,7 @@ out:
 	return res;
 err:
 	rtnl_link_unregister(&bond_link_ops);
-	bond_destroy_proc_dir();
+	unregister_pernet_gen_subsys(bond_net_id, &bond_net_ops);
 	goto out;
 
 }
@@ -5153,7 +5190,7 @@ static void __exit bonding_exit(void)
 	bond_destroy_sysfs();
 
 	rtnl_link_unregister(&bond_link_ops);
-	bond_destroy_proc_dir();
+	unregister_pernet_gen_subsys(bond_net_id, &bond_net_ops);
 }
 
 module_init(bonding_init);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index f924a0b..a59094f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -35,6 +35,8 @@
 #include <linux/rtnetlink.h>
 #include <linux/etherdevice.h>
 #include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <linux/nsproxy.h>
 
 #include "bonding.h"
 
@@ -47,12 +49,14 @@
  */
 static ssize_t bonding_show_bonds(struct class *cls, char *buf)
 {
+	struct net *net = current->nsproxy->net_ns;
+	struct bond_net *bn = net_generic(net, bond_net_id);
 	int res = 0;
 	struct bonding *bond;
 
 	rtnl_lock();
 
-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bn->dev_list, bond_list) {
 		if (res > (PAGE_SIZE - IFNAMSIZ)) {
 			/* not enough space for another interface name */
 			if ((PAGE_SIZE - res) > 10)
@@ -69,11 +73,12 @@ static ssize_t bonding_show_bonds(struct class *cls, char *buf)
 	return res;
 }
 
-static struct net_device *bond_get_by_name(const char *ifname)
+static struct net_device *bond_get_by_name(struct net *net, const char *ifname)
 {
+	struct bond_net *bn = net_generic(net, bond_net_id);
 	struct bonding *bond;
 
-	list_for_each_entry(bond, &bond_dev_list, bond_list) {
+	list_for_each_entry(bond, &bn->dev_list, bond_list) {
 		if (strncmp(bond->dev->name, ifname, IFNAMSIZ) == 0)
 			return bond->dev;
 	}
@@ -91,6 +96,7 @@ static struct net_device *bond_get_by_name(const char *ifname)
 static ssize_t bonding_store_bonds(struct class *cls,
 				   const char *buffer, size_t count)
 {
+	struct net *net = current->nsproxy->net_ns;
 	char command[IFNAMSIZ + 1] = {0, };
 	char *ifname;
 	int rv, res = count;
@@ -104,7 +110,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
 	if (command[0] == '+') {
 		pr_info(DRV_NAME
 			": %s is being created...\n", ifname);
-		rv = bond_create(ifname);
+		rv = bond_create(net, ifname);
 		if (rv) {
 			pr_info(DRV_NAME ": Bond creation failed.\n");
 			res = rv;
@@ -113,7 +119,7 @@ static ssize_t bonding_store_bonds(struct class *cls,
 		struct net_device *bond_dev;
 
 		rtnl_lock();
-		bond_dev = bond_get_by_name(ifname);
+		bond_dev = bond_get_by_name(net, ifname);
 		if (bond_dev) {
 			pr_info(DRV_NAME ": %s is being deleted...\n",
 				ifname);
@@ -238,8 +244,7 @@ static ssize_t bonding_store_slaves(struct device *d,
 		/* Got a slave name in ifname.  Is it already in the list? */
 		found = 0;
 
-		/* FIXME: get netns from sysfs object */
-		dev = __dev_get_by_name(&init_net, ifname);
+		dev = __dev_get_by_name(dev_net(bond->dev), ifname);
 		if (!dev) {
 			pr_info(DRV_NAME
 			       ": %s: Interface %s does not exist!\n",
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 013be29..a51ae7d 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -30,8 +30,6 @@
 
 #define BOND_MAX_ARP_TARGETS	16
 
-extern struct list_head bond_dev_list;
-
 #define IS_UP(dev)					   \
 	      ((((dev)->flags & IFF_UP) == IFF_UP)	&& \
 	       netif_running(dev)			&& \
@@ -327,7 +325,7 @@ static inline void bond_unset_master_alb_flags(struct bonding *bond)
 
 struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
-int bond_create(const char *name);
+int bond_create(struct net *net, const char *name);
 int  bond_release_and_destroy(struct net_device *bond_dev, struct net_device *slave_dev);
 int bond_create_sysfs(void);
 void bond_destroy_sysfs(void);
@@ -346,8 +344,16 @@ void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
 void bond_unregister_arp(struct bonding *);
 
+struct bond_net {
+	struct net *		net;	/* Associated network namespace */
+	struct list_head	dev_list;
+#ifdef CONFIG_PROC_FS
+	struct proc_dir_entry *	proc_dir;
+#endif
+};
+
 /* exported from bond_main.c */
-extern struct list_head bond_dev_list;
+extern int bond_net_id;
 extern const struct bond_parm_tbl bond_lacp_tbl[];
 extern const struct bond_parm_tbl bond_mode_tbl[];
 extern const struct bond_parm_tbl xmit_hashtype_tbl[];
-- 
1.6.3.1.54.g99dd.dirty


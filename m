From: Neil Horman <nhorman@tuxdriver.com>
Subject: [PATCH 1/2] net: add network priority cgroup infrastructure (v4)
Date: Tue, 22 Nov 2011 10:10:51 -0500
Message-ID: <1321974652-8318-2-git-send-email-nhorman@tuxdriver.com>
References: <1321476666-8225-1-git-send-email-nhorman@tuxdriver.com>
 <1321974652-8318-1-git-send-email-nhorman@tuxdriver.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Robert Love <robert.w.love@intel.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53161 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757159Ab1KVPLJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 10:11:09 -0500
In-Reply-To: <1321974652-8318-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds in the infrastructure code to create the network priority
cgroup.  The cgroup, in addition to the standard processes file creates two
control files:

1) prioidx - This is a read-only file that exports the index of this cgroup.
This is a value that is both arbitrary and unique to a cgroup in this subsystem,
and is used to index the per-device priority map

2) priomap - This is a writeable file.  On read it reports a table of 2-tuples
<name:priority> where name is the name of a network interface and priority is
indicates the priority assigned to frames egresessing on the named interface and
originating from a pid in this cgroup

This cgroup allows for skb priority to be set prior to a root qdisc getting
selected. This is benenficial for DCB enabled systems, in that it allows for any
application to use dcb configured priorities so without application modification

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
CC: Robert Love <robert.w.love@intel.com>
CC: "David S. Miller" <davem@davemloft.net>
---
 include/linux/cgroup_subsys.h |    8 +
 include/linux/netdevice.h     |    4 +
 include/net/netprio_cgroup.h  |   65 ++++++++
 include/net/sock.h            |    3 +
 net/Kconfig                   |    7 +
 net/core/Makefile             |    1 +
 net/core/dev.c                |   14 ++
 net/core/netprio_cgroup.c     |  344 +++++++++++++++++++++++++++++++++++++++++
 net/core/sock.c               |   22 +++-
 net/socket.c                  |    2 +
 10 files changed, 469 insertions(+), 1 deletions(-)
 create mode 100644 include/net/netprio_cgroup.h
 create mode 100644 net/core/netprio_cgroup.c

diff --git a/include/linux/cgroup_subsys.h b/include/linux/cgroup_subsys.h
index ac663c1..0bd390c 100644
--- a/include/linux/cgroup_subsys.h
+++ b/include/linux/cgroup_subsys.h
@@ -59,8 +59,16 @@ SUBSYS(net_cls)
 SUBSYS(blkio)
 #endif
 
+/* */
+
 #ifdef CONFIG_CGROUP_PERF
 SUBSYS(perf)
 #endif
 
 /* */
+
+#ifdef CONFIG_NETPRIO_CGROUP
+SUBSYS(net_prio)
+#endif
+
+/* */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 0db1f5f..750ea8e 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -50,6 +50,7 @@
 #ifdef CONFIG_DCB
 #include <net/dcbnl.h>
 #endif
+#include <net/netprio_cgroup.h>
 
 struct vlan_group;
 struct netpoll_info;
@@ -1312,6 +1313,9 @@ struct net_device {
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+	struct netprio_map __rcu *priomap;
+#endif
 	/* phy device may attach itself for hardware timestamping */
 	struct phy_device *phydev;
 
diff --git a/include/net/netprio_cgroup.h b/include/net/netprio_cgroup.h
new file mode 100644
index 0000000..8cfeb3c
--- /dev/null
+++ b/include/net/netprio_cgroup.h
@@ -0,0 +1,65 @@
+/*
+ * netprio_cgroup.h			Control Group Priority set 
+ *
+ *
+ * Authors:	Neil Horman <nhorman@tuxdriver.com>
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ */
+
+#ifndef _NETPRIO_CGROUP_H
+#define _NETPRIO_CGROUP_H
+#include <linux/module.h>
+#include <linux/cgroup.h>
+#include <linux/hardirq.h>
+#include <linux/rcupdate.h>
+
+struct cgroup_netprio_state
+{
+	struct cgroup_subsys_state css;
+	u32 prioidx;
+};
+
+struct netprio_map {
+	struct rcu_head rcu;
+	u32 priomap_len;
+	u32 priomap[];
+};
+
+#ifdef CONFIG_CGROUPS
+
+#ifndef CONFIG_NETPRIO_CGROUP
+extern int net_prio_subsys_id;
+#endif
+
+extern void sock_update_netprioidx(struct sock *sk);
+
+static inline struct cgroup_netprio_state
+		*task_netprio_state(struct task_struct *p)
+{
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+	return container_of(task_subsys_state(p, net_prio_subsys_id),
+			    struct cgroup_netprio_state, css);
+#else
+	return NULL;
+#endif
+}
+
+#else
+
+#define sock_update_netprioidx(sk)
+#define skb_update_prio(skb)
+
+static inline struct cgroup_netprio_state
+		*task_netprio_state(struct task_struct *p)
+{
+	return NULL;
+}
+
+#endif
+
+#endif  /* _NET_CLS_CGROUP_H */
diff --git a/include/net/sock.h b/include/net/sock.h
index 5ac682f..87b24aa 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -321,6 +321,9 @@ struct sock {
 	unsigned short		sk_ack_backlog;
 	unsigned short		sk_max_ack_backlog;
 	__u32			sk_priority;
+#ifdef CONFIG_CGROUPS
+	__u32			sk_cgrp_prioidx;
+#endif
 	struct pid		*sk_peer_pid;
 	const struct cred	*sk_peer_cred;
 	long			sk_rcvtimeo;
diff --git a/net/Kconfig b/net/Kconfig
index a073148..63d2c5d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -232,6 +232,13 @@ config XPS
 	depends on SMP && SYSFS && USE_GENERIC_SMP_HELPERS
 	default y
 
+config NETPRIO_CGROUP
+	tristate "Network priority cgroup"
+	depends on CGROUPS
+	---help---
+	  Cgroup subsystem for use in assigning processes to network priorities on
+	  a per-interface basis
+
 config HAVE_BPF_JIT
 	bool
 
diff --git a/net/core/Makefile b/net/core/Makefile
index 0d357b1..3606d40 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -19,3 +19,4 @@ obj-$(CONFIG_FIB_RULES) += fib_rules.o
 obj-$(CONFIG_TRACEPOINTS) += net-traces.o
 obj-$(CONFIG_NET_DROP_MONITOR) += drop_monitor.o
 obj-$(CONFIG_NETWORK_PHY_TIMESTAMPING) += timestamping.o
+obj-$(CONFIG_NETPRIO_CGROUP) += netprio_cgroup.o
diff --git a/net/core/dev.c b/net/core/dev.c
index b7ba81a..373c908 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2456,6 +2456,18 @@ static inline int __dev_xmit_skb(struct sk_buff *skb, struct Qdisc *q,
 	return rc;
 }
 
+#if IS_ENABLED(CONFIG_NETPRIO_CGROUP)
+static void skb_update_prio(struct sk_buff *skb)
+{
+	struct netprio_map *map = rcu_dereference(skb->dev->priomap);
+
+	if ((!skb->priority) && (skb->sk) && map)
+		skb->priority = map->priomap[skb->sk->sk_cgrp_prioidx];
+}
+#else
+#define skb_update_prio(skb)
+#endif
+
 static DEFINE_PER_CPU(int, xmit_recursion);
 #define RECURSION_LIMIT 10
 
@@ -2496,6 +2508,8 @@ int dev_queue_xmit(struct sk_buff *skb)
 	 */
 	rcu_read_lock_bh();
 
+	skb_update_prio(skb);
+
 	txq = dev_pick_tx(dev, skb);
 	q = rcu_dereference_bh(txq->qdisc);
 
diff --git a/net/core/netprio_cgroup.c b/net/core/netprio_cgroup.c
new file mode 100644
index 0000000..72ad0bc
--- /dev/null
+++ b/net/core/netprio_cgroup.c
@@ -0,0 +1,344 @@
+/*
+ * net/core/netprio_cgroup.c	Priority Control Group
+ *
+ *		This program is free software; you can redistribute it and/or
+ *		modify it under the terms of the GNU General Public License
+ *		as published by the Free Software Foundation; either version
+ *		2 of the License, or (at your option) any later version.
+ *
+ * Authors:	Neil Horman <nhorman@tuxdriver.com>
+ */
+
+#include <linux/module.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/string.h>
+#include <linux/errno.h>
+#include <linux/skbuff.h>
+#include <linux/cgroup.h>
+#include <linux/rcupdate.h>
+#include <linux/atomic.h>
+#include <net/rtnetlink.h>
+#include <net/pkt_cls.h>
+#include <net/sock.h>
+#include <net/netprio_cgroup.h>
+
+static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
+					       struct cgroup *cgrp);
+static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp);
+static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp);
+
+struct cgroup_subsys net_prio_subsys = {
+	.name		= "net_prio",
+	.create		= cgrp_create,
+	.destroy	= cgrp_destroy,
+	.populate	= cgrp_populate,
+#ifdef CONFIG_NETPRIO_CGROUP
+	.subsys_id	= net_prio_subsys_id,
+#endif
+	.module		= THIS_MODULE
+};
+
+#define PRIOIDX_SZ 128
+
+static unsigned long prioidx_map[PRIOIDX_SZ];
+static DEFINE_SPINLOCK(prioidx_map_lock);
+static atomic_t max_prioidx = ATOMIC_INIT(0);
+
+static inline struct cgroup_netprio_state *cgrp_netprio_state(struct cgroup *cgrp)
+{
+	return container_of(cgroup_subsys_state(cgrp, net_prio_subsys_id),
+			    struct cgroup_netprio_state, css);
+}
+
+static int get_prioidx(u32 *prio)
+{
+	unsigned long flags;
+	u32 prioidx;
+
+	spin_lock_irqsave(&prioidx_map_lock, flags);
+	prioidx = find_first_zero_bit(prioidx_map, sizeof(unsigned long) * PRIOIDX_SZ);
+	set_bit(prioidx, prioidx_map);
+	spin_unlock_irqrestore(&prioidx_map_lock, flags);
+	if (prioidx == sizeof(unsigned long) * PRIOIDX_SZ)
+		return -ENOSPC;
+
+	atomic_set(&max_prioidx, prioidx);
+	*prio = prioidx;
+	return 0;
+}
+
+static void put_prioidx(u32 idx)
+{
+	unsigned long flags;
+
+	spin_lock_irqsave(&prioidx_map_lock, flags);
+	clear_bit(idx, prioidx_map);
+	spin_unlock_irqrestore(&prioidx_map_lock, flags);
+}
+
+static void extend_netdev_table(struct net_device *dev, u32 new_len)
+{
+	size_t new_size = sizeof(struct netprio_map) +
+			   ((sizeof(u32) * new_len));
+	struct netprio_map *new_priomap = kzalloc(new_size, GFP_KERNEL);
+	struct netprio_map *old_priomap;
+	int i;
+
+	old_priomap  = rtnl_dereference(dev->priomap);
+
+	if (!new_priomap) {
+		printk(KERN_WARNING "Unable to alloc new priomap!\n");
+		return;
+	}
+
+	for (i = 0;
+	     old_priomap && (i < old_priomap->priomap_len);
+	     i++)
+		new_priomap->priomap[i] = old_priomap->priomap[i];
+
+	new_priomap->priomap_len = new_len;
+
+	rcu_assign_pointer(dev->priomap, new_priomap);
+	if (old_priomap)
+		kfree_rcu(old_priomap, rcu);
+}
+
+static void update_netdev_tables(void)
+{
+	struct net_device *dev;
+	u32 max_len = atomic_read(&max_prioidx);
+	struct netprio_map *map;
+
+	rtnl_lock();
+	for_each_netdev(&init_net, dev) {
+		map = rtnl_dereference(dev->priomap);
+		if ((!map) ||
+		    (map->priomap_len < max_len))
+			extend_netdev_table(dev, max_len);
+	}
+	rtnl_unlock();
+}
+
+static struct cgroup_subsys_state *cgrp_create(struct cgroup_subsys *ss,
+						 struct cgroup *cgrp)
+{
+	struct cgroup_netprio_state *cs;
+	int ret;
+
+	cs = kzalloc(sizeof(*cs), GFP_KERNEL);
+	if (!cs)
+		return ERR_PTR(-ENOMEM);
+
+	if (cgrp->parent && cgrp_netprio_state(cgrp->parent)->prioidx) {
+		kfree(cs);
+		return ERR_PTR(-EINVAL);
+	}
+
+	ret = get_prioidx(&cs->prioidx);
+	if (ret != 0) {
+		printk(KERN_WARNING "No space in priority index array\n");
+		kfree(cs);
+		return ERR_PTR(ret);
+	}
+
+	return &cs->css;
+}
+
+static void cgrp_destroy(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	struct cgroup_netprio_state *cs;
+	struct net_device *dev;
+	struct netprio_map *map;
+
+	cs = cgrp_netprio_state(cgrp);
+	rtnl_lock();
+	for_each_netdev(&init_net, dev) {
+		map = rtnl_dereference(dev->priomap);
+		if (map)
+			map->priomap[cs->prioidx] = 0;
+	}
+	rtnl_unlock();
+	put_prioidx(cs->prioidx);
+	kfree(cs);
+}
+
+static u64 read_prioidx(struct cgroup *cgrp, struct cftype *cft)
+{
+	return (u64)cgrp_netprio_state(cgrp)->prioidx;
+}
+
+static int read_priomap(struct cgroup *cont, struct cftype *cft,
+			struct cgroup_map_cb *cb)
+{
+	struct net_device *dev;
+	u32 prioidx = cgrp_netprio_state(cont)->prioidx;
+	u32 priority;
+	struct netprio_map *map;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
+		map = rcu_dereference(dev->priomap);
+		priority = map ? map->priomap[prioidx] : 0;
+		cb->fill(cb, dev->name, priority);
+	}
+	rcu_read_unlock();
+	return 0;
+}
+
+static int write_priomap(struct cgroup *cgrp, struct cftype *cft,
+			 const char *buffer)
+{
+	char *devname = kstrdup(buffer, GFP_KERNEL);
+	int ret = -EINVAL;
+	u32 prioidx = cgrp_netprio_state(cgrp)->prioidx;
+	unsigned long priority;
+	char *priostr;
+	struct net_device *dev;
+	struct netprio_map *map;
+
+	if (!devname)
+		return -ENOMEM;
+
+	/*
+	 * Minimally sized valid priomap string
+	 */
+	if (strlen(devname) < 3)
+		goto out_free_devname;
+
+	priostr = strstr(devname, " ");
+	if (!priostr)
+		goto out_free_devname;
+
+	/*
+	 *Separate the devname from the associated priority
+	 *and advance the priostr poitner to the priority value
+	 */
+	*priostr = '\0';
+	priostr++;
+
+	/*
+	 * If the priostr points to NULL, we're at the end of the passed
+	 * in string, and its not a valid write
+	 */
+	if (*priostr == '\0')
+		goto out_free_devname;
+
+	ret = kstrtoul(priostr, 10, &priority);
+	if (ret < 0)
+		goto out_free_devname;
+
+	ret = -ENODEV;
+
+	dev = dev_get_by_name(&init_net, devname);
+	if (!dev)
+		goto out_free_devname;
+
+	update_netdev_tables();
+	ret = 0;
+	rcu_read_lock();
+	map = rcu_dereference(dev->priomap);
+	if (map)
+		map->priomap[prioidx] = priority;
+	rcu_read_unlock();
+	dev_put(dev);
+
+out_free_devname:
+	kfree(devname);
+	return ret;
+}
+
+static struct cftype ss_files[] = {
+	{
+		.name = "prioidx",
+		.read_u64 = read_prioidx,
+	},
+	{
+		.name = "ifpriomap",
+		.read_map = read_priomap,
+		.write_string = write_priomap,
+	},
+};
+
+static int cgrp_populate(struct cgroup_subsys *ss, struct cgroup *cgrp)
+{
+	return cgroup_add_files(cgrp, ss, ss_files, ARRAY_SIZE(ss_files));
+}
+
+static int netprio_device_event(struct notifier_block *unused,
+				unsigned long event, void *ptr)
+{
+	struct net_device *dev = ptr;
+	struct netprio_map *old;
+	u32 max_len = atomic_read(&max_prioidx);
+
+	/*
+	 * Note this is called with rtnl_lock held so we have update side
+	 * protection on our rcu assignments
+	 */
+
+	switch (event) {
+
+	case NETDEV_REGISTER:
+		if (max_len)
+			extend_netdev_table(dev, max_len);
+		break;
+	case NETDEV_UNREGISTER:
+		old = rtnl_dereference(dev->priomap);
+		rcu_assign_pointer(dev->priomap, NULL);
+		if (old)
+			kfree_rcu(old, rcu);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block netprio_device_notifier = {
+	.notifier_call = netprio_device_event
+};
+
+static int __init init_cgroup_netprio(void)
+{
+	int ret;
+
+	ret = cgroup_load_subsys(&net_prio_subsys);
+	if (ret)
+		goto out;
+#ifndef CONFIG_NETPRIO_CGROUP
+	smp_wmb();
+	net_prio_subsys_id = net_prio_subsys.subsys_id;
+#endif
+
+	register_netdevice_notifier(&netprio_device_notifier);
+
+out:
+	return ret;
+}
+
+static void __exit exit_cgroup_netprio(void)
+{
+	struct netprio_map *old;
+	struct net_device *dev;
+
+	unregister_netdevice_notifier(&netprio_device_notifier);
+
+	cgroup_unload_subsys(&net_prio_subsys);
+
+#ifndef CONFIG_NETPRIO_CGROUP
+	net_prio_subsys_id = -1;
+	synchronize_rcu();
+#endif
+
+	rtnl_lock();
+	for_each_netdev(&init_net, dev) {
+		old = rtnl_dereference(dev->priomap);
+		rcu_assign_pointer(dev->priomap, NULL);
+		if (old)
+			kfree_rcu(old, rcu);
+	}
+	rtnl_unlock();
+}
+
+module_init(init_cgroup_netprio);
+module_exit(exit_cgroup_netprio);
+MODULE_LICENSE("GPL v2");
diff --git a/net/core/sock.c b/net/core/sock.c
index 5a08762..77a4888 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -125,6 +125,7 @@
 #include <net/xfrm.h>
 #include <linux/ipsec.h>
 #include <net/cls_cgroup.h>
+#include <net/netprio_cgroup.h>
 
 #include <linux/filter.h>
 
@@ -221,10 +222,16 @@ __u32 sysctl_rmem_default __read_mostly = SK_RMEM_MAX;
 int sysctl_optmem_max __read_mostly = sizeof(unsigned long)*(2*UIO_MAXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
 
-#if defined(CONFIG_CGROUPS) && !defined(CONFIG_NET_CLS_CGROUP)
+#if defined(CONFIG_CGROUPS)
+#if !defined(CONFIG_NET_CLS_CGROUP)
 int net_cls_subsys_id = -1;
 EXPORT_SYMBOL_GPL(net_cls_subsys_id);
 #endif
+#if !defined(CONFIG_NETPRIO_CGROUP)
+int net_prio_subsys_id = -1;
+EXPORT_SYMBOL_GPL(net_prio_subsys_id);
+#endif
+#endif
 
 static int sock_set_timeout(long *timeo_p, char __user *optval, int optlen)
 {
@@ -1111,6 +1118,18 @@ void sock_update_classid(struct sock *sk)
 		sk->sk_classid = classid;
 }
 EXPORT_SYMBOL(sock_update_classid);
+
+void sock_update_netprioidx(struct sock *sk)
+{
+	struct cgroup_netprio_state *state;
+	if (in_interrupt())
+		return;
+	rcu_read_lock();
+	state = task_netprio_state(current);
+	sk->sk_cgrp_prioidx = state ? state->prioidx : 0;
+	rcu_read_unlock();
+}
+EXPORT_SYMBOL_GPL(sock_update_netprioidx);
 #endif
 
 /**
@@ -1138,6 +1157,7 @@ struct sock *sk_alloc(struct net *net, int family, gfp_t priority,
 		atomic_set(&sk->sk_wmem_alloc, 1);
 
 		sock_update_classid(sk);
+		sock_update_netprioidx(sk);
 	}
 
 	return sk;
diff --git a/net/socket.c b/net/socket.c
index 2877647..108716f 100644
--- a/net/socket.c
+++ b/net/socket.c
@@ -549,6 +549,8 @@ static inline int __sock_sendmsg_nosec(struct kiocb *iocb, struct socket *sock,
 
 	sock_update_classid(sock->sk);
 
+	sock_update_netprioidx(sock->sk);
+
 	si->sock = sock;
 	si->scm = NULL;
 	si->msg = msg;
-- 
1.7.6.4

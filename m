From: Andrey Savochkin <saw@swsoft.com>
Subject: [patch 1/7] net_device list cleanup: core
Date: Mon, 3 Jul 2006 12:18:51 +0400
Message-ID: <20060630150823.A22285@castle.nmd.msu.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kirill Korotaev <dev@openvz.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from castle.nmd.msu.ru ([193.232.112.53]:31496 "HELO
	castle.nmd.msu.ru") by vger.kernel.org with SMTP id S1750766AbWGCQbZ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jul 2006 12:31:25 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Cleanup of net_device list use in net_dev core and IP.
The cleanup consists of
 - converting the to list_head, to make the list double-linked (thus making
   remove operation O(1)), and list walks more readable;
 - introducing of for_each_netdev wrapper over list_for_each.

Signed-off-by: Andrey Savochkin <saw@swsoft.com>
Signed-off-by: Kirill Korotaev <dev@openvz.org>
---
 include/linux/netdevice.h |   29 ++++++++++++++++++++++++++-
 net/core/dev.c            |   48 +++++++++++++++++++++++++---------------------
 net/ipv4/devinet.c        |    6 ++---
 net/ipv6/addrconf.c       |    8 +++----
 net/ipv6/anycast.c        |   10 +++++----
 5 files changed, 68 insertions(+), 33 deletions(-)

--- ./include/linux/netdevice.h.vedevbase-core	Mon Jul  3 15:14:15 2006
+++ ./include/linux/netdevice.h	Mon Jul  3 16:09:11 2006
@@ -290,7 +290,8 @@ struct net_device
 	unsigned long		state;
 
 	struct net_device	*next;
-	
+	struct list_head	dev_list;
+
 	/* The device initialization function. Called only once. */
 	int			(*init)(struct net_device *dev);
 
@@ -558,8 +559,34 @@ struct packet_type {
 
 extern struct net_device		loopback_dev;		/* The loopback */
 extern struct net_device		*dev_base;		/* All devices */
+extern struct list_head			dev_base_head;		/* All devices */
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
+#define for_each_netdev(p)	list_for_each_entry(p, &dev_base_head, dev_list)
+
+/*
+ * When possible, it is preferrable to use for_each_netdev() loop
+ * defined above, rather than first_netdev()/next_netdev() macros.
+ * for_each_netdev() loop makes the intentions clearer, and gives more
+ * flexibility in device list implementation.
+ * While next_netdev() is unavoidable in seq_proc functions,
+ * first_netdev() should be needed quite rarely.
+ */
+#define first_netdev()		({ \
+					list_empty(&dev_base_head) ? NULL : \
+						list_entry(dev_base_head.next, \
+							struct net_device, \
+							dev_list); \
+				 })
+#define next_netdev(dev)	({ \
+					struct list_head *__next; \
+					__next = (dev)->dev_list.next; \
+					__next == &dev_base_head ? NULL : \
+						list_entry(__next, \
+							struct net_device, \
+							dev_list); \
+				 })
+
 extern int 			netdev_boot_setup_check(struct net_device *dev);
 extern unsigned long		netdev_boot_base(const char *prefix, int unit);
 extern struct net_device    *dev_getbyhwaddr(unsigned short type, char *hwaddr);
--- ./net/core/dev.c.vedevbase-core	Mon Jul  3 15:14:19 2006
+++ ./net/core/dev.c	Mon Jul  3 16:09:11 2006
@@ -181,6 +181,9 @@ DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base);
 EXPORT_SYMBOL(dev_base_lock);
 
+LIST_HEAD(dev_base_head);
+EXPORT_SYMBOL(dev_base_head);
+
 #define NETDEV_HASHBITS	8
 static struct hlist_head dev_name_head[1<<NETDEV_HASHBITS];
 static struct hlist_head dev_index_head[1<<NETDEV_HASHBITS];
@@ -575,11 +578,11 @@ struct net_device *dev_getbyhwaddr(unsig
 
 	ASSERT_RTNL();
 
-	for (dev = dev_base; dev; dev = dev->next)
+	for_each_netdev(dev)
 		if (dev->type == type &&
 		    !memcmp(dev->dev_addr, ha, dev->addr_len))
-			break;
-	return dev;
+			return dev;
+	return NULL;
 }
 
 EXPORT_SYMBOL(dev_getbyhwaddr);
@@ -589,14 +592,15 @@ struct net_device *dev_getfirstbyhwtype(
 	struct net_device *dev;
 
 	rtnl_lock();
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		if (dev->type == type) {
 			dev_hold(dev);
-			break;
+			rtnl_unlock();
+			return dev;
 		}
 	}
 	rtnl_unlock();
-	return dev;
+	return NULL;
 }
 
 EXPORT_SYMBOL(dev_getfirstbyhwtype);
@@ -617,14 +621,15 @@ struct net_device * dev_get_by_flags(uns
 	struct net_device *dev;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		if (((dev->flags ^ if_flags) & mask) == 0) {
 			dev_hold(dev);
-			break;
+			read_unlock(&dev_base_lock);
+			return dev;
 		}
 	}
 	read_unlock(&dev_base_lock);
-	return dev;
+	return NULL;
 }
 
 /**
@@ -680,7 +685,7 @@ int dev_alloc_name(struct net_device *de
 		if (!inuse)
 			return -ENOMEM;
 
-		for (d = dev_base; d; d = d->next) {
+		for_each_netdev(d) {
 			if (!sscanf(d->name, name, &i))
 				continue;
 			if (i < 0 || i >= max_netdevices)
@@ -966,7 +971,7 @@ int register_netdevice_notifier(struct n
 	rtnl_lock();
 	err = raw_notifier_chain_register(&netdev_chain, nb);
 	if (!err) {
-		for (dev = dev_base; dev; dev = dev->next) {
+		for_each_netdev(dev) {
 			nb->notifier_call(nb, NETDEV_REGISTER, dev);
 
 			if (dev->flags & IFF_UP) 
@@ -2035,7 +2040,7 @@ static int dev_ifconf(char __user *arg)
 	 */
 
 	total = 0;
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		for (i = 0; i < NPROTO; i++) {
 			if (gifconf_list[i]) {
 				int done;
@@ -2974,6 +2979,7 @@ int register_netdevice(struct net_device
 	write_lock_bh(&dev_base_lock);
 	*dev_tail = dev;
 	dev_tail = &dev->next;
+	list_add_tail(&dev->dev_list, &dev_base_head);
 	hlist_add_head(&dev->name_hlist, head);
 	hlist_add_head(&dev->index_hlist, dev_index_hash(dev->ifindex));
 	dev_hold(dev);
@@ -3271,22 +3277,22 @@ int unregister_netdevice(struct net_devi
 
 	/* And unlink it from device chain. */
 	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
-		if (d == dev) {
-			write_lock_bh(&dev_base_lock);
-			hlist_del(&dev->name_hlist);
-			hlist_del(&dev->index_hlist);
-			if (dev_tail == &dev->next)
-				dev_tail = dp;
-			*dp = d->next;
-			write_unlock_bh(&dev_base_lock);
+		if (d == dev)
 			break;
-		}
 	}
 	if (!d) {
 		printk(KERN_ERR "unregister net_device: '%s' not found\n",
 		       dev->name);
 		return -ENODEV;
 	}
+	write_lock_bh(&dev_base_lock);
+	list_del(&dev->dev_list);
+	hlist_del(&dev->name_hlist);
+	hlist_del(&dev->index_hlist);
+	if (dev_tail == &dev->next)
+		dev_tail = dp;
+	*dp = d->next;
+	write_unlock_bh(&dev_base_lock);
 
 	dev->reg_state = NETREG_UNREGISTERING;
 
--- ./net/ipv4/devinet.c.vedevbase-core	Mon Jul  3 15:14:20 2006
+++ ./net/ipv4/devinet.c	Mon Jul  3 16:09:11 2006
@@ -841,7 +841,7 @@ no_in_dev:
 	 */
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		if ((in_dev = __in_dev_get_rcu(dev)) == NULL)
 			continue;
 
@@ -920,7 +920,7 @@ u32 inet_confirm_addr(const struct net_d
 
 	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		if ((in_dev = __in_dev_get_rcu(dev))) {
 			addr = confirm_addr_indev(in_dev, dst, local, scope);
 			if (addr)
@@ -1170,7 +1170,7 @@ void inet_forward_change(void)
 	ipv4_devconf_dflt.forwarding = on;
 
 	read_lock(&dev_base_lock);
-	for (dev = dev_base; dev; dev = dev->next) {
+	for_each_netdev(dev) {
 		struct in_device *in_dev;
 		rcu_read_lock();
 		in_dev = __in_dev_get_rcu(dev);
--- ./net/ipv6/addrconf.c.vedevbase-core	Mon Jul  3 15:14:22 2006
+++ ./net/ipv6/addrconf.c	Mon Jul  3 16:09:11 2006
@@ -469,7 +469,7 @@ static void addrconf_forward_change(void
 	struct inet6_dev *idev;
 
 	read_lock(&dev_base_lock);
-	for (dev=dev_base; dev; dev=dev->next) {
+	for_each_netdev(dev) {
 		read_lock(&addrconf_lock);
 		idev = __in6_dev_get(dev);
 		if (idev) {
@@ -894,7 +894,7 @@ int ipv6_dev_get_saddr(struct net_device
 	read_lock(&dev_base_lock);
 	read_lock(&addrconf_lock);
 
-	for (dev = dev_base; dev; dev=dev->next) {
+	for_each_netdev(dev) {
 		struct inet6_dev *idev;
 		struct inet6_ifaddr *ifa;
 
@@ -1979,7 +1979,7 @@ static void sit_add_v4_addrs(struct inet
 		return;
 	}
 
-        for (dev = dev_base; dev != NULL; dev = dev->next) {
+	for_each_netdev(dev) {
 		struct in_device * in_dev = __in_dev_get_rtnl(dev);
 		if (in_dev && (dev->flags & IFF_UP)) {
 			struct in_ifaddr * ifa;
@@ -2128,7 +2128,7 @@ static void ip6_tnl_add_linklocal(struct
 			return;
 	}
 	/* then try to inherit it from any device */
-	for (link_dev = dev_base; link_dev; link_dev = link_dev->next) {
+	for_each_netdev(link_dev) {
 		if (!ipv6_inherit_linklocal(idev, link_dev))
 			return;
 	}
--- ./net/ipv6/anycast.c.vedevbase-core	Mon Jul  3 15:14:22 2006
+++ ./net/ipv6/anycast.c	Mon Jul  3 16:09:11 2006
@@ -427,11 +427,13 @@ int ipv6_chk_acast_addr(struct net_devic
 	if (dev)
 		return ipv6_chk_acast_dev(dev, addr);
 	read_lock(&dev_base_lock);
-	for (dev=dev_base; dev; dev=dev->next)
-		if (ipv6_chk_acast_dev(dev, addr))
-			break;
+	for_each_netdev(dev)
+		if (ipv6_chk_acast_dev(dev, addr)) {
+			read_unlock(&dev_base_lock);
+			return 1;
+		}
 	read_unlock(&dev_base_lock);
-	return dev != 0;
+	return 0;
 }
 
 

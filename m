From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (2/4) support large number of network devices -- name hash
Date: Fri, 16 Jan 2004 15:48:14 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116154814.7c7f31ac.shemminger@osdl.org>
References: <20040116154652.04dd3324.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040116154652.04dd3324.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Add a hash list to speed lookup's of network device name
used in dev_alloc_name and by other protocols.
Keep a tail pointer as well to allow quick append to the end
of the device singly linked device list.

Note: Uses 8bits for hash and the filename hash function

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Fri Jan 16 14:20:47 2004
+++ b/include/linux/netdevice.h	Fri Jan 16 14:20:47 2004
@@ -375,6 +375,8 @@
 	atomic_t		refcnt;
 	/* delayed register/unregister */
 	struct list_head	todo_list;
+	/* device name hash chain */
+	struct hlist_node	name_hlist;
 
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=0,
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Fri Jan 16 14:20:47 2004
+++ b/net/core/dev.c	Fri Jan 16 14:20:47 2004
@@ -180,11 +180,22 @@
  * semaphore held.
  */
 struct net_device *dev_base;
+struct net_device **dev_tail = &dev_base;
 rwlock_t dev_base_lock = RW_LOCK_UNLOCKED;
 
 EXPORT_SYMBOL(dev_base);
 EXPORT_SYMBOL(dev_base_lock);
 
+#define NETDEV_HASHBITS	8
+static struct hlist_head dev_name_head[1<<NETDEV_HASHBITS];
+
+static inline struct hlist_head *dev_name_hash(const char *name)
+{
+	size_t len = min(strlen(name),(size_t)(IFNAMSIZ-1));
+	unsigned hash = full_name_hash(name, len);
+	return &dev_name_head[hash & ((1<<NETDEV_HASHBITS)-1)];
+}
+
 /*
  *	Our notifier list
  */
@@ -444,12 +455,15 @@
 
 struct net_device *__dev_get_by_name(const char *name)
 {
-	struct net_device *dev;
+	struct hlist_node *p;
 
-	for (dev = dev_base; dev; dev = dev->next)
+	hlist_for_each(p, dev_name_hash(name)) {
+		struct net_device *dev
+			= hlist_entry(p, struct net_device, name_hlist);
 		if (!strncmp(dev->name, name, IFNAMSIZ))
-			break;
-	return dev;
+			return dev;
+	}
+	return NULL;
 }
 
 /**
@@ -730,6 +744,9 @@
 	else
 		strlcpy(dev->name, newname, IFNAMSIZ);
 
+	hlist_del(&dev->name_hlist);
+	hlist_add_head(&dev->name_hlist, dev_name_hash(dev->name));
+
 	class_device_rename(&dev->class_dev, dev->name);
 	notifier_call_chain(&netdev_chain, NETDEV_CHANGENAME, dev);
 	return 0;
@@ -2718,7 +2735,8 @@
 
 int register_netdevice(struct net_device *dev)
 {
-	struct net_device *d, **dp;
+	struct hlist_head *head;
+	struct hlist_node *p;
 	int ret;
 
 	BUG_ON(dev_boot_phase);
@@ -2759,13 +2777,17 @@
 	if (dev->iflink == -1)
 		dev->iflink = dev->ifindex;
 
-	/* Check for existence, and append to tail of chain */
-	ret = -EEXIST;
-	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
-		if (d == dev || !strcmp(d->name, dev->name))
-			goto out_err;
-	}
-	
+	/* Check for existence of name */
+	head = dev_name_hash(dev->name);
+	hlist_for_each(p, head) {
+		struct net_device *d
+			= hlist_entry(p, struct net_device, name_hlist);
+		if (!strncmp(d->name, dev->name, IFNAMSIZ)) {
+			ret = -EEXIST;
+ 			goto out_err;
+		}
+ 	}
+
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
 	    !(dev->features & (NETIF_F_IP_CSUM |
@@ -2794,7 +2816,9 @@
 	dev->next = NULL;
 	dev_init_scheduler(dev);
 	write_lock_bh(&dev_base_lock);
-	*dp = dev;
+	*dev_tail = dev;
+	dev_tail = &dev->next;
+	hlist_add_head(&dev->name_hlist, head);
 	dev_hold(dev);
 	dev->reg_state = NETREG_REGISTERING;
 	write_unlock_bh(&dev_base_lock);
@@ -3016,6 +3040,9 @@
 	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
 		if (d == dev) {
 			write_lock_bh(&dev_base_lock);
+			hlist_del(&dev->name_hlist);
+			if (dev_tail == &dev->next)
+				dev_tail = dp;
 			*dp = d->next;
 			write_unlock_bh(&dev_base_lock);
 			break;
@@ -3091,6 +3118,9 @@
 	INIT_LIST_HEAD(&ptype_all);
 	for (i = 0; i < 16; i++) 
 		INIT_LIST_HEAD(&ptype_base[i]);
+
+	for (i = 0; i < ARRAY_SIZE(dev_name_head); i++)
+		INIT_HLIST_HEAD(&dev_name_head[i]);
 
 	/*
 	 *	Initialise the packet receive queues.

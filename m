From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] (3/4) support large number of network devices -- hash
 ifindex
Date: Fri, 16 Jan 2004 15:49:15 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040116154915.7a6b1fb6.shemminger@osdl.org>
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

Add an additional hash chain to keep track of network devices
by index.  This gets used during route manipulation and when
allocating a unique ifindex.

diff -Nru a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h	Fri Jan 16 09:27:12 2004
+++ b/include/linux/netdevice.h	Fri Jan 16 09:27:12 2004
@@ -377,6 +377,8 @@
 	struct list_head	todo_list;
 	/* device name hash chain */
 	struct hlist_node	name_hlist;
+	/* device index hash chain */
+	struct hlist_node	index_hlist;
 
 	/* register/unregister state machine */
 	enum { NETREG_UNINITIALIZED=0,
diff -Nru a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c	Fri Jan 16 09:27:12 2004
+++ b/net/core/dev.c	Fri Jan 16 09:27:12 2004
@@ -188,6 +188,7 @@
 
 #define NETDEV_HASHBITS	8
 static struct hlist_head dev_name_head[1<<NETDEV_HASHBITS];
+static struct hlist_head dev_index_head[1<<NETDEV_HASHBITS];
 
 static inline struct hlist_head *dev_name_hash(const char *name)
 {
@@ -196,6 +197,11 @@
 	return &dev_name_head[hash & ((1<<NETDEV_HASHBITS)-1)];
 }
 
+static inline struct hlist_head *dev_index_hash(int ifindex)
+{
+	return &dev_index_head[ifindex & ((1<<NETDEV_HASHBITS)-1)];
+}
+
 /*
  *	Our notifier list
  */
@@ -531,12 +537,15 @@
 
 struct net_device *__dev_get_by_index(int ifindex)
 {
-	struct net_device *dev;
+	struct hlist_node *p;
 
-	for (dev = dev_base; dev; dev = dev->next)
+	hlist_for_each(p, dev_index_hash(ifindex)) {
+		struct net_device *dev
+			= hlist_entry(p, struct net_device, index_hlist);
 		if (dev->ifindex == ifindex)
-			break;
-	return dev;
+			return dev;
+	}
+	return NULL;
 }
 
 
@@ -2819,6 +2828,7 @@
 	*dev_tail = dev;
 	dev_tail = &dev->next;
 	hlist_add_head(&dev->name_hlist, head);
+	hlist_add_head(&dev->index_hlist, dev_index_hash(dev->ifindex));
 	dev_hold(dev);
 	dev->reg_state = NETREG_REGISTERING;
 	write_unlock_bh(&dev_base_lock);
@@ -3041,6 +3051,7 @@
 		if (d == dev) {
 			write_lock_bh(&dev_base_lock);
 			hlist_del(&dev->name_hlist);
+			hlist_del(&dev->index_hlist);
 			if (dev_tail == &dev->next)
 				dev_tail = dp;
 			*dp = d->next;
@@ -3121,6 +3132,9 @@
 
 	for (i = 0; i < ARRAY_SIZE(dev_name_head); i++)
 		INIT_HLIST_HEAD(&dev_name_head[i]);
+
+	for (i = 0; i < ARRAY_SIZE(dev_index_head); i++)
+		INIT_HLIST_HEAD(&dev_index_head[i]);
 
 	/*
 	 *	Initialise the packet receive queues.

From: Octavian Purdila <opurdila@ixiacom.com>
Subject: [RFC PATCH] net: persistent device name bitmaps for faster name allocation
Date: Sat, 21 Nov 2009 02:37:25 +0200
Message-ID: <200911210237.25855.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:18863 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753214AbZKUAk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Nov 2009 19:40:28 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch solves the current scalability issues of dev_name_alloc() by
making the device name bitmap persistent. It is based on an idea
suggested by Stephen Hemminger.

$ time insmod /lib/modules/dummy.ko numdummies=8000

Without the patch           With the patch

real    0m 43.43s           real    0m 0.52s
user    0m 0.00s            user    0m 0.00s
sys     0m 43.43s           sys     0m 0.52s

For each format string (e.g. eth%d) we maintain a device name
bitmap. The bitmap starts by allocating one page and can grow up to
MAX_DEV_NAME_ORDER.

There is also a limit to the number of bitmaps (MAX_DEV_NAME_BITMAPS).
If this limit is reached while trying to allocate a new bitmap we free
the last used one.

The device name bitmaps are stored in a rbtree on a per namespace
basis.

Open issue: Stephen suggested to register "a VM notifier hook" that
could be used to dump the trees in case of memory pressure.

However, I was only able to find the OOM notifier, and I don't know if
that would be as useful as a real memory pressure event. Any hints?

Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>
---
 include/net/net_namespace.h |    1 +
 net/core/dev.c              |  293 +++++++++++++++++++++++++++++++++++++++----
 2 files changed, 269 insertions(+), 25 deletions(-)

diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 0addd45..2da2a09 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -56,6 +56,7 @@ struct net {
 	struct list_head 	dev_base_head;
 	struct hlist_head 	*dev_name_head;
 	struct hlist_head	*dev_index_head;
+	struct rb_root		dev_name_bitmaps;
 
 	/* core fib_rules */
 	struct list_head	rules_ops;
diff --git a/net/core/dev.c b/net/core/dev.c
index 9977288..9e8f909 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -205,6 +205,202 @@ static inline struct hlist_head *dev_index_hash(struct net *net, int ifindex)
 	return &net->dev_index_head[ifindex & (NETDEV_HASHENTRIES - 1)];
 }
 
+/* For fast name allocation we maintain a bitmap of used devices, one for each
+ * format string (e.g. eth%d) */
+struct dev_name_bitmap {
+	char fmt[IFNAMSIZ];
+	unsigned long *data;
+	int size;
+	struct rb_node rb_node;
+	struct list_head list;
+	struct net *net;
+};
+
+#define MAX_DEV_NAME_BITMAPS 10
+#define MAX_DEV_NAME_ORDER 4
+
+static int dev_name_bitmap_count;
+/* List of all device name bitmaps, sorted by how often they are used. Last
+ * bitmap used is last. */
+static LIST_HEAD(dev_name_bitmap_list);
+
+static void kill_dev_name_bitmap(int no)
+{
+	struct dev_name_bitmap *b, *aux;
+	int i = 0;
+
+	list_for_each_entry_safe(b, aux, &dev_name_bitmap_list, list) {
+		if (i++ >= no)
+			return;
+		list_del(&b->list);
+		rb_erase(&b->rb_node, &b->net->dev_name_bitmaps);
+		free_pages((unsigned long)b->data, get_order(b->size/8));
+		dev_name_bitmap_count--;
+		kfree(b);
+	}
+}
+
+/**
+ *	get_dev_name_fmt - returns the format string from a device name
+ *	@name: the device name (e.g. eth0)
+ *	@fmt: the format string which coresponds to the device name (e.g. eth%d)
+ *
+ *	If the name contains multiple digit runs then the format string will be
+ *	be based on the last one. For example, the format string for eth0a12
+ *	will be eth0a%d.
+ */
+static int get_dev_name_fmt(const char *name, char *fmt)
+{
+	int i = 0, last_run_end = -1, last_run_start = -1;
+	char digit[IFNAMSIZ] = { 0, }, c;
+
+	while ((c = name[i++])) {
+		if (c >= '0' && c <= '9')
+			digit[i] = 1;
+	}
+
+	/* find the last digit */
+	for (i = IFNAMSIZ-1; i >= 0; i--)
+		if (digit[i]) {
+			last_run_end = i;
+			break;
+		}
+
+	/* make sure we have space for %d\0 */
+	if (last_run_end < 0 || last_run_start >= IFNAMSIZ - 3)
+		return -EINVAL;
+
+	/* find the first digit of the last digit run */
+	for (i = last_run_end; i >= 0; i--)
+		if (!digit[i]) {
+			last_run_start = i;
+			break;
+		}
+
+	if (last_run_start < 0)
+		return -EINVAL;
+
+	memcpy(fmt, name, last_run_start);
+	memcpy(&fmt[last_run_start], "%d", sizeof("%d"));
+
+	return 0;
+}
+
+static struct dev_name_bitmap *get_name_bitmap(struct net *net, const char *fmt)
+{
+	struct rb_node *i = net->dev_name_bitmaps.rb_node;
+
+	while (i) {
+		struct dev_name_bitmap *b;
+		int cmp;
+
+		b = rb_entry(i, struct dev_name_bitmap, rb_node);
+		cmp = strcmp(fmt, b->fmt);
+
+		if (cmp < 0)
+			i = i->rb_left;
+		else if (cmp > 0)
+			i = i->rb_right;
+		else
+			return b;
+	}
+
+	return NULL;
+}
+
+static int grow_name_bitmap(struct dev_name_bitmap *b, int size)
+{
+	unsigned long *data;
+	int order = get_order(size/8 + size%8);
+
+	if (order > MAX_DEV_NAME_ORDER)
+		return -EDQUOT;
+
+	size = (1<<order)*PAGE_SIZE*8;
+	if (size < b->size)
+		return 0;
+
+	data = (unsigned long *)__get_free_pages(GFP_ATOMIC, order);
+	if (!data)
+		return -ENOMEM;
+
+	memcpy(data, b->data, b->size/8);
+	memset((char *)data + b->size/8, 0, size/8 - b->size/8);
+
+	if (b->size)
+		free_pages((unsigned long)b->data, get_order(b->size/8));
+	b->size = size;
+	b->data = data;
+
+	return 0;
+}
+
+static void fill_name_bitmap(struct dev_name_bitmap *b, int order)
+{
+	struct net_device *d;
+	char buf[IFNAMSIZ];
+	int i;
+
+	for_each_netdev(b->net, d) {
+		if (!sscanf(d->name, b->fmt, &i))
+			continue;
+
+		/*  avoid cases where sscanf is not exact inverse of printf */
+		snprintf(buf, IFNAMSIZ, b->fmt, i);
+		if (!strncmp(buf, d->name, IFNAMSIZ))
+			continue;
+
+		if (i < 0)
+			continue;
+
+		if (i >= b->size && grow_name_bitmap(b, i))
+			continue;
+
+		set_bit(i, b->data);
+	}
+}
+
+static void update_name_bitmap(struct net *net, const char *name, bool set)
+{
+	struct dev_name_bitmap *b = NULL;
+	char fmt[IFNAMSIZ], tmp[IFNAMSIZ];
+	int i;
+
+	if (get_dev_name_fmt(name, fmt))
+		return;
+
+	b = get_name_bitmap(net, fmt);
+	if (!b || sscanf(name, fmt, &i) != 1 ||
+	    snprintf(tmp, IFNAMSIZ, fmt, i) == 0 ||
+	    strcmp(tmp, name) != 0)
+		return;
+
+	if (i > b->size && grow_name_bitmap(b, i))
+		return;
+
+	if (set)
+		set_bit(i, b->data);
+	else
+		clear_bit(i, b->data);
+
+	list_del(&b->list);
+	list_add_tail(&b->list, &dev_name_bitmap_list);
+}
+
+static inline void list_dev_name(struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+
+	update_name_bitmap(net, dev->name, 1);
+	hlist_add_head_rcu(&dev->name_hlist, dev_name_hash(net, dev->name));
+}
+
+static inline void unlist_dev_name(struct net_device *dev, const char *name)
+{
+	hlist_del_rcu(&dev->name_hlist);
+	update_name_bitmap(dev_net(dev), name, 0);
+}
+
 /* Device list insertion */
 static int list_netdevice(struct net_device *dev)
 {
@@ -214,7 +410,7 @@ static int list_netdevice(struct net_device *dev)
 
 	write_lock_bh(&dev_base_lock);
 	list_add_tail_rcu(&dev->dev_list, &net->dev_base_head);
-	hlist_add_head_rcu(&dev->name_hlist, dev_name_hash(net, dev->name));
+	list_dev_name(dev);
 	hlist_add_head_rcu(&dev->index_hlist,
 			   dev_index_hash(net, dev->ifindex));
 	write_unlock_bh(&dev_base_lock);
@@ -231,7 +427,7 @@ static void unlist_netdevice(struct net_device *dev)
 	/* Unlink dev from the device chain */
 	write_lock_bh(&dev_base_lock);
 	list_del_rcu(&dev->dev_list);
-	hlist_del_rcu(&dev->name_hlist);
+	unlist_dev_name(dev, dev->name);
 	hlist_del_rcu(&dev->index_hlist);
 	write_unlock_bh(&dev_base_lock);
 }
@@ -839,6 +1035,55 @@ int dev_valid_name(const char *name)
 }
 EXPORT_SYMBOL(dev_valid_name);
 
+static struct dev_name_bitmap *new_name_bitmap(struct net *net, const char *fmt)
+{
+	struct rb_node **p = &net->dev_name_bitmaps.rb_node, *parent = NULL;
+	struct dev_name_bitmap *b;
+
+	if (dev_name_bitmap_count == MAX_DEV_NAME_BITMAPS - 1)
+		kill_dev_name_bitmap(1);
+
+	b = kmalloc(sizeof(*b), GFP_ATOMIC);
+	if (!b)
+		return NULL;
+
+	strcpy(b->fmt, fmt);
+	b->size = 0;
+	b->net = net;
+
+	if (grow_name_bitmap(b, 8*PAGE_SIZE)) {
+		kfree(b);
+		return NULL;
+	}
+
+	fill_name_bitmap(b, 0);
+
+	list_add_tail(&b->list, &dev_name_bitmap_list);
+
+	while (*p) {
+		struct dev_name_bitmap *cmp_b;
+		int cmp;
+
+		parent = *p;
+		cmp_b = rb_entry(parent, struct dev_name_bitmap, rb_node);
+		cmp = strcmp(b->fmt, cmp_b->fmt);
+
+		if (cmp < 0)
+			p = &(*p)->rb_left;
+		else if (cmp > 0)
+			p = &(*p)->rb_right;
+		else
+			BUG();
+	}
+	rb_link_node(&b->rb_node, parent, p);
+	rb_insert_color(&b->rb_node, &net->dev_name_bitmaps);
+
+	dev_name_bitmap_count++;
+
+	return b;
+}
+
+
 /**
  *	__dev_alloc_name - allocate a name for a device
  *	@net: network namespace to allocate the device name in
@@ -856,14 +1101,13 @@ EXPORT_SYMBOL(dev_valid_name);
 
 static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 {
-	int i = 0;
+	int i = 0, retry;
 	const char *p;
-	const int max_netdevices = 8*PAGE_SIZE;
-	unsigned long *inuse;
-	struct net_device *d;
 
 	p = strnchr(name, IFNAMSIZ-1, '%');
 	if (p) {
+		struct dev_name_bitmap *b;
+
 		/*
 		 * Verify the string as this thing may have come from
 		 * the user.  There must be either one "%d" and no other "%"
@@ -872,25 +1116,23 @@ static int __dev_alloc_name(struct net *net, const char *name, char *buf)
 		if (p[1] != 'd' || strchr(p + 2, '%'))
 			return -EINVAL;
 
-		/* Use one page as a bit array of possible slots */
-		inuse = (unsigned long *) get_zeroed_page(GFP_ATOMIC);
-		if (!inuse)
-			return -ENOMEM;
-
-		for_each_netdev(net, d) {
-			if (!sscanf(d->name, name, &i))
-				continue;
-			if (i < 0 || i >= max_netdevices)
-				continue;
-
-			/*  avoid cases where sscanf is not exact inverse of printf */
-			snprintf(buf, IFNAMSIZ, name, i);
-			if (!strncmp(buf, d->name, IFNAMSIZ))
-				set_bit(i, inuse);
+		b = get_name_bitmap(net, name);
+		if (!b) {
+			b = new_name_bitmap(net, name);
+			if (!b)
+				return -ENOMEM;
 		}
 
-		i = find_first_zero_bit(inuse, max_netdevices);
-		free_page((unsigned long) inuse);
+		do {
+			retry = 0;
+			i = find_first_zero_bit(b->data, b->size);
+			if (i == b->size) {
+				int err = grow_name_bitmap(b, i + 1);
+				if (err)
+					return err;
+				retry = 1;
+			}
+		} while (retry);
 	}
 
 	if (buf != name)
@@ -994,13 +1236,13 @@ rollback:
 	}
 
 	write_lock_bh(&dev_base_lock);
-	hlist_del(&dev->name_hlist);
+	unlist_dev_name(dev, oldname);
 	write_unlock_bh(&dev_base_lock);
 
 	synchronize_rcu();
 
 	write_lock_bh(&dev_base_lock);
-	hlist_add_head_rcu(&dev->name_hlist, dev_name_hash(net, dev->name));
+	list_dev_name(dev);
 	write_unlock_bh(&dev_base_lock);
 
 	ret = call_netdevice_notifiers(NETDEV_CHANGENAME, dev);
@@ -5655,6 +5897,7 @@ static struct hlist_head *netdev_create_hash(void)
 static int __net_init netdev_init(struct net *net)
 {
 	INIT_LIST_HEAD(&net->dev_base_head);
+	net->dev_name_bitmaps = RB_ROOT;
 
 	net->dev_name_head = netdev_create_hash();
 	if (net->dev_name_head == NULL)
-- 
1.5.6.5


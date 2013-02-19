From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH] net: move procfs code to net/core/net-procfs.c
Date: Tue, 19 Feb 2013 13:20:33 +0800
Message-ID: <1361251233-25914-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:63275 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751769Ab3BSFUp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 00:20:45 -0500
Received: by mail-pa0-f50.google.com with SMTP id fa11so3242129pad.9
        for <netdev@vger.kernel.org>; Mon, 18 Feb 2013 21:20:45 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>

Similar to net/core/net-sysfs.c, group procfs code to
a single unit.

Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/netdevice.h |   36 ++++-
 net/core/Makefile         |    1 +
 net/core/dev.c            |  384 +-----------------------------------------
 net/core/dev_addr_lists.c |   74 --------
 net/core/net-procfs.c     |  414 +++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 450 insertions(+), 459 deletions(-)
 create mode 100644 net/core/net-procfs.c

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 920361b..f111b4f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2692,9 +2692,9 @@ extern void		net_enable_timestamp(void);
 extern void		net_disable_timestamp(void);
 
 #ifdef CONFIG_PROC_FS
-extern void *dev_seq_start(struct seq_file *seq, loff_t *pos);
-extern void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos);
-extern void dev_seq_stop(struct seq_file *seq, void *v);
+extern int __init dev_proc_init(void);
+#else
+#define dev_proc_init() 0
 #endif
 
 extern int netdev_class_create_file(struct class_attribute *class_attr);
@@ -2896,4 +2896,34 @@ do {								\
 })
 #endif
 
+/*
+ *	The list of packet types we will receive (as opposed to discard)
+ *	and the routines to invoke.
+ *
+ *	Why 16. Because with 16 the only overlap we get on a hash of the
+ *	low nibble of the protocol value is RARP/SNAP/X.25.
+ *
+ *      NOTE:  That is no longer true with the addition of VLAN tags.  Not
+ *             sure which should go first, but I bet it won't make much
+ *             difference if we are running VLANs.  The good news is that
+ *             this protocol won't be in the list unless compiled in, so
+ *             the average user (w/out VLANs) will not be adversely affected.
+ *             --BLG
+ *
+ *		0800	IP
+ *		8100    802.1Q VLAN
+ *		0001	802.3
+ *		0002	AX.25
+ *		0004	802.2
+ *		8035	RARP
+ *		0005	SNAP
+ *		0805	X.25
+ *		0806	ARP
+ *		8137	IPX
+ *		0009	Localtalk
+ *		86DD	IPv6
+ */
+#define PTYPE_HASH_SIZE	(16)
+#define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
+
 #endif	/* _LINUX_NETDEVICE_H */
diff --git a/net/core/Makefile b/net/core/Makefile
index 0c5e361..b33b996 100644
--- a/net/core/Makefile
+++ b/net/core/Makefile
@@ -13,6 +13,7 @@ obj-y		     += dev.o ethtool.o dev_addr_lists.o dst.o netevent.o \
 
 obj-$(CONFIG_XFRM) += flow.o
 obj-y += net-sysfs.o
+obj-$(CONFIG_PROC_FS) += net-procfs.o
 obj-$(CONFIG_NET_PKTGEN) += pktgen.o
 obj-$(CONFIG_NETPOLL) += netpoll.o
 obj-$(CONFIG_NET_DMA) += user_dma.o
diff --git a/net/core/dev.c b/net/core/dev.c
index decf55f..8d9ddb0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -97,8 +97,6 @@
 #include <net/net_namespace.h>
 #include <net/sock.h>
 #include <linux/rtnetlink.h>
-#include <linux/proc_fs.h>
-#include <linux/seq_file.h>
 #include <linux/stat.h>
 #include <net/dst.h>
 #include <net/pkt_sched.h>
@@ -110,7 +108,6 @@
 #include <linux/netpoll.h>
 #include <linux/rcupdate.h>
 #include <linux/delay.h>
-#include <net/wext.h>
 #include <net/iw_handler.h>
 #include <asm/current.h>
 #include <linux/audit.h>
@@ -141,41 +138,10 @@
 /* This should be increased if a protocol with a bigger head is added. */
 #define GRO_MAX_HEAD (MAX_HEADER + 128)
 
-/*
- *	The list of packet types we will receive (as opposed to discard)
- *	and the routines to invoke.
- *
- *	Why 16. Because with 16 the only overlap we get on a hash of the
- *	low nibble of the protocol value is RARP/SNAP/X.25.
- *
- *      NOTE:  That is no longer true with the addition of VLAN tags.  Not
- *             sure which should go first, but I bet it won't make much
- *             difference if we are running VLANs.  The good news is that
- *             this protocol won't be in the list unless compiled in, so
- *             the average user (w/out VLANs) will not be adversely affected.
- *             --BLG
- *
- *		0800	IP
- *		8100    802.1Q VLAN
- *		0001	802.3
- *		0002	AX.25
- *		0004	802.2
- *		8035	RARP
- *		0005	SNAP
- *		0805	X.25
- *		0806	ARP
- *		8137	IPX
- *		0009	Localtalk
- *		86DD	IPv6
- */
-
-#define PTYPE_HASH_SIZE	(16)
-#define PTYPE_HASH_MASK	(PTYPE_HASH_SIZE - 1)
-
 static DEFINE_SPINLOCK(ptype_lock);
 static DEFINE_SPINLOCK(offload_lock);
-static struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
-static struct list_head ptype_all __read_mostly;	/* Taps */
+struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
+struct list_head ptype_all __read_mostly;	/* Taps */
 static struct list_head offload_base __read_mostly;
 
 /*
@@ -4217,352 +4183,6 @@ softnet_break:
 	goto out;
 }
 
-#ifdef CONFIG_PROC_FS
-
-#define BUCKET_SPACE (32 - NETDEV_HASHBITS - 1)
-
-#define get_bucket(x) ((x) >> BUCKET_SPACE)
-#define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
-#define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
-
-static inline struct net_device *dev_from_same_bucket(struct seq_file *seq, loff_t *pos)
-{
-	struct net *net = seq_file_net(seq);
-	struct net_device *dev;
-	struct hlist_node *p;
-	struct hlist_head *h;
-	unsigned int count = 0, offset = get_offset(*pos);
-
-	h = &net->dev_name_head[get_bucket(*pos)];
-	hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
-		if (++count == offset)
-			return dev;
-	}
-
-	return NULL;
-}
-
-static inline struct net_device *dev_from_bucket(struct seq_file *seq, loff_t *pos)
-{
-	struct net_device *dev;
-	unsigned int bucket;
-
-	do {
-		dev = dev_from_same_bucket(seq, pos);
-		if (dev)
-			return dev;
-
-		bucket = get_bucket(*pos) + 1;
-		*pos = set_bucket_offset(bucket, 1);
-	} while (bucket < NETDEV_HASHENTRIES);
-
-	return NULL;
-}
-
-/*
- *	This is invoked by the /proc filesystem handler to display a device
- *	in detail.
- */
-void *dev_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-{
-	rcu_read_lock();
-	if (!*pos)
-		return SEQ_START_TOKEN;
-
-	if (get_bucket(*pos) >= NETDEV_HASHENTRIES)
-		return NULL;
-
-	return dev_from_bucket(seq, pos);
-}
-
-void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	++*pos;
-	return dev_from_bucket(seq, pos);
-}
-
-void dev_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU)
-{
-	rcu_read_unlock();
-}
-
-static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
-{
-	struct rtnl_link_stats64 temp;
-	const struct rtnl_link_stats64 *stats = dev_get_stats(dev, &temp);
-
-	seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %5llu %10llu %9llu "
-		   "%8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
-		   dev->name, stats->rx_bytes, stats->rx_packets,
-		   stats->rx_errors,
-		   stats->rx_dropped + stats->rx_missed_errors,
-		   stats->rx_fifo_errors,
-		   stats->rx_length_errors + stats->rx_over_errors +
-		    stats->rx_crc_errors + stats->rx_frame_errors,
-		   stats->rx_compressed, stats->multicast,
-		   stats->tx_bytes, stats->tx_packets,
-		   stats->tx_errors, stats->tx_dropped,
-		   stats->tx_fifo_errors, stats->collisions,
-		   stats->tx_carrier_errors +
-		    stats->tx_aborted_errors +
-		    stats->tx_window_errors +
-		    stats->tx_heartbeat_errors,
-		   stats->tx_compressed);
-}
-
-/*
- *	Called from the PROCfs module. This now uses the new arbitrary sized
- *	/proc/net interface to create /proc/net/dev
- */
-static int dev_seq_show(struct seq_file *seq, void *v)
-{
-	if (v == SEQ_START_TOKEN)
-		seq_puts(seq, "Inter-|   Receive                            "
-			      "                    |  Transmit\n"
-			      " face |bytes    packets errs drop fifo frame "
-			      "compressed multicast|bytes    packets errs "
-			      "drop fifo colls carrier compressed\n");
-	else
-		dev_seq_printf_stats(seq, v);
-	return 0;
-}
-
-static struct softnet_data *softnet_get_online(loff_t *pos)
-{
-	struct softnet_data *sd = NULL;
-
-	while (*pos < nr_cpu_ids)
-		if (cpu_online(*pos)) {
-			sd = &per_cpu(softnet_data, *pos);
-			break;
-		} else
-			++*pos;
-	return sd;
-}
-
-static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
-{
-	return softnet_get_online(pos);
-}
-
-static void *softnet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	++*pos;
-	return softnet_get_online(pos);
-}
-
-static void softnet_seq_stop(struct seq_file *seq, void *v)
-{
-}
-
-static int softnet_seq_show(struct seq_file *seq, void *v)
-{
-	struct softnet_data *sd = v;
-
-	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
-		   sd->processed, sd->dropped, sd->time_squeeze, 0,
-		   0, 0, 0, 0, /* was fastroute */
-		   sd->cpu_collision, sd->received_rps);
-	return 0;
-}
-
-static const struct seq_operations dev_seq_ops = {
-	.start = dev_seq_start,
-	.next  = dev_seq_next,
-	.stop  = dev_seq_stop,
-	.show  = dev_seq_show,
-};
-
-static int dev_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &dev_seq_ops,
-			    sizeof(struct seq_net_private));
-}
-
-static const struct file_operations dev_seq_fops = {
-	.owner	 = THIS_MODULE,
-	.open    = dev_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release_net,
-};
-
-static const struct seq_operations softnet_seq_ops = {
-	.start = softnet_seq_start,
-	.next  = softnet_seq_next,
-	.stop  = softnet_seq_stop,
-	.show  = softnet_seq_show,
-};
-
-static int softnet_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open(file, &softnet_seq_ops);
-}
-
-static const struct file_operations softnet_seq_fops = {
-	.owner	 = THIS_MODULE,
-	.open    = softnet_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release,
-};
-
-static void *ptype_get_idx(loff_t pos)
-{
-	struct packet_type *pt = NULL;
-	loff_t i = 0;
-	int t;
-
-	list_for_each_entry_rcu(pt, &ptype_all, list) {
-		if (i == pos)
-			return pt;
-		++i;
-	}
-
-	for (t = 0; t < PTYPE_HASH_SIZE; t++) {
-		list_for_each_entry_rcu(pt, &ptype_base[t], list) {
-			if (i == pos)
-				return pt;
-			++i;
-		}
-	}
-	return NULL;
-}
-
-static void *ptype_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(RCU)
-{
-	rcu_read_lock();
-	return *pos ? ptype_get_idx(*pos - 1) : SEQ_START_TOKEN;
-}
-
-static void *ptype_seq_next(struct seq_file *seq, void *v, loff_t *pos)
-{
-	struct packet_type *pt;
-	struct list_head *nxt;
-	int hash;
-
-	++*pos;
-	if (v == SEQ_START_TOKEN)
-		return ptype_get_idx(0);
-
-	pt = v;
-	nxt = pt->list.next;
-	if (pt->type == htons(ETH_P_ALL)) {
-		if (nxt != &ptype_all)
-			goto found;
-		hash = 0;
-		nxt = ptype_base[0].next;
-	} else
-		hash = ntohs(pt->type) & PTYPE_HASH_MASK;
-
-	while (nxt == &ptype_base[hash]) {
-		if (++hash >= PTYPE_HASH_SIZE)
-			return NULL;
-		nxt = ptype_base[hash].next;
-	}
-found:
-	return list_entry(nxt, struct packet_type, list);
-}
-
-static void ptype_seq_stop(struct seq_file *seq, void *v)
-	__releases(RCU)
-{
-	rcu_read_unlock();
-}
-
-static int ptype_seq_show(struct seq_file *seq, void *v)
-{
-	struct packet_type *pt = v;
-
-	if (v == SEQ_START_TOKEN)
-		seq_puts(seq, "Type Device      Function\n");
-	else if (pt->dev == NULL || dev_net(pt->dev) == seq_file_net(seq)) {
-		if (pt->type == htons(ETH_P_ALL))
-			seq_puts(seq, "ALL ");
-		else
-			seq_printf(seq, "%04x", ntohs(pt->type));
-
-		seq_printf(seq, " %-8s %pF\n",
-			   pt->dev ? pt->dev->name : "", pt->func);
-	}
-
-	return 0;
-}
-
-static const struct seq_operations ptype_seq_ops = {
-	.start = ptype_seq_start,
-	.next  = ptype_seq_next,
-	.stop  = ptype_seq_stop,
-	.show  = ptype_seq_show,
-};
-
-static int ptype_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &ptype_seq_ops,
-			sizeof(struct seq_net_private));
-}
-
-static const struct file_operations ptype_seq_fops = {
-	.owner	 = THIS_MODULE,
-	.open    = ptype_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release_net,
-};
-
-
-static int __net_init dev_proc_net_init(struct net *net)
-{
-	int rc = -ENOMEM;
-
-	if (!proc_create("dev", S_IRUGO, net->proc_net, &dev_seq_fops))
-		goto out;
-	if (!proc_create("softnet_stat", S_IRUGO, net->proc_net,
-			 &softnet_seq_fops))
-		goto out_dev;
-	if (!proc_create("ptype", S_IRUGO, net->proc_net, &ptype_seq_fops))
-		goto out_softnet;
-
-	if (wext_proc_init(net))
-		goto out_ptype;
-	rc = 0;
-out:
-	return rc;
-out_ptype:
-	remove_proc_entry("ptype", net->proc_net);
-out_softnet:
-	remove_proc_entry("softnet_stat", net->proc_net);
-out_dev:
-	remove_proc_entry("dev", net->proc_net);
-	goto out;
-}
-
-static void __net_exit dev_proc_net_exit(struct net *net)
-{
-	wext_proc_exit(net);
-
-	remove_proc_entry("ptype", net->proc_net);
-	remove_proc_entry("softnet_stat", net->proc_net);
-	remove_proc_entry("dev", net->proc_net);
-}
-
-static struct pernet_operations __net_initdata dev_proc_ops = {
-	.init = dev_proc_net_init,
-	.exit = dev_proc_net_exit,
-};
-
-static int __init dev_proc_init(void)
-{
-	return register_pernet_subsys(&dev_proc_ops);
-}
-#else
-#define dev_proc_init() 0
-#endif	/* CONFIG_PROC_FS */
-
-
 struct netdev_upper {
 	struct net_device *dev;
 	bool master;
diff --git a/net/core/dev_addr_lists.c b/net/core/dev_addr_lists.c
index 8956252..bd2eb9d 100644
--- a/net/core/dev_addr_lists.c
+++ b/net/core/dev_addr_lists.c
@@ -15,7 +15,6 @@
 #include <linux/rtnetlink.h>
 #include <linux/export.h>
 #include <linux/list.h>
-#include <linux/proc_fs.h>
 
 /*
  * General list handling functions
@@ -727,76 +726,3 @@ void dev_mc_init(struct net_device *dev)
 	__hw_addr_init(&dev->mc);
 }
 EXPORT_SYMBOL(dev_mc_init);
-
-#ifdef CONFIG_PROC_FS
-#include <linux/seq_file.h>
-
-static int dev_mc_seq_show(struct seq_file *seq, void *v)
-{
-	struct netdev_hw_addr *ha;
-	struct net_device *dev = v;
-
-	if (v == SEQ_START_TOKEN)
-		return 0;
-
-	netif_addr_lock_bh(dev);
-	netdev_for_each_mc_addr(ha, dev) {
-		int i;
-
-		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
-			   dev->name, ha->refcount, ha->global_use);
-
-		for (i = 0; i < dev->addr_len; i++)
-			seq_printf(seq, "%02x", ha->addr[i]);
-
-		seq_putc(seq, '\n');
-	}
-	netif_addr_unlock_bh(dev);
-	return 0;
-}
-
-static const struct seq_operations dev_mc_seq_ops = {
-	.start = dev_seq_start,
-	.next  = dev_seq_next,
-	.stop  = dev_seq_stop,
-	.show  = dev_mc_seq_show,
-};
-
-static int dev_mc_seq_open(struct inode *inode, struct file *file)
-{
-	return seq_open_net(inode, file, &dev_mc_seq_ops,
-			    sizeof(struct seq_net_private));
-}
-
-static const struct file_operations dev_mc_seq_fops = {
-	.owner	 = THIS_MODULE,
-	.open    = dev_mc_seq_open,
-	.read    = seq_read,
-	.llseek  = seq_lseek,
-	.release = seq_release_net,
-};
-
-#endif
-
-static int __net_init dev_mc_net_init(struct net *net)
-{
-	if (!proc_create("dev_mcast", 0, net->proc_net, &dev_mc_seq_fops))
-		return -ENOMEM;
-	return 0;
-}
-
-static void __net_exit dev_mc_net_exit(struct net *net)
-{
-	remove_proc_entry("dev_mcast", net->proc_net);
-}
-
-static struct pernet_operations __net_initdata dev_mc_net_ops = {
-	.init = dev_mc_net_init,
-	.exit = dev_mc_net_exit,
-};
-
-void __init dev_mcast_init(void)
-{
-	register_pernet_subsys(&dev_mc_net_ops);
-}
-
diff --git a/net/core/net-procfs.c b/net/core/net-procfs.c
new file mode 100644
index 0000000..ac87066
--- /dev/null
+++ b/net/core/net-procfs.c
@@ -0,0 +1,414 @@
+#include <linux/netdevice.h>
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+#include <net/wext.h>
+
+#define BUCKET_SPACE (32 - NETDEV_HASHBITS - 1)
+
+#define get_bucket(x) ((x) >> BUCKET_SPACE)
+#define get_offset(x) ((x) & ((1 << BUCKET_SPACE) - 1))
+#define set_bucket_offset(b, o) ((b) << BUCKET_SPACE | (o))
+
+extern struct list_head ptype_all __read_mostly;
+extern struct list_head ptype_base[PTYPE_HASH_SIZE] __read_mostly;
+
+static inline struct net_device *dev_from_same_bucket(struct seq_file *seq, loff_t *pos)
+{
+	struct net *net = seq_file_net(seq);
+	struct net_device *dev;
+	struct hlist_node *p;
+	struct hlist_head *h;
+	unsigned int count = 0, offset = get_offset(*pos);
+
+	h = &net->dev_name_head[get_bucket(*pos)];
+	hlist_for_each_entry_rcu(dev, p, h, name_hlist) {
+		if (++count == offset)
+			return dev;
+	}
+
+	return NULL;
+}
+
+static inline struct net_device *dev_from_bucket(struct seq_file *seq, loff_t *pos)
+{
+	struct net_device *dev;
+	unsigned int bucket;
+
+	do {
+		dev = dev_from_same_bucket(seq, pos);
+		if (dev)
+			return dev;
+
+		bucket = get_bucket(*pos) + 1;
+		*pos = set_bucket_offset(bucket, 1);
+	} while (bucket < NETDEV_HASHENTRIES);
+
+	return NULL;
+}
+
+/*
+ *	This is invoked by the /proc filesystem handler to display a device
+ *	in detail.
+ */
+static void *dev_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
+{
+	rcu_read_lock();
+	if (!*pos)
+		return SEQ_START_TOKEN;
+
+	if (get_bucket(*pos) >= NETDEV_HASHENTRIES)
+		return NULL;
+
+	return dev_from_bucket(seq, pos);
+}
+
+static void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return dev_from_bucket(seq, pos);
+}
+
+static void dev_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
+{
+	rcu_read_unlock();
+}
+
+static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
+{
+	struct rtnl_link_stats64 temp;
+	const struct rtnl_link_stats64 *stats = dev_get_stats(dev, &temp);
+
+	seq_printf(seq, "%6s: %7llu %7llu %4llu %4llu %4llu %5llu %10llu %9llu "
+		   "%8llu %7llu %4llu %4llu %4llu %5llu %7llu %10llu\n",
+		   dev->name, stats->rx_bytes, stats->rx_packets,
+		   stats->rx_errors,
+		   stats->rx_dropped + stats->rx_missed_errors,
+		   stats->rx_fifo_errors,
+		   stats->rx_length_errors + stats->rx_over_errors +
+		    stats->rx_crc_errors + stats->rx_frame_errors,
+		   stats->rx_compressed, stats->multicast,
+		   stats->tx_bytes, stats->tx_packets,
+		   stats->tx_errors, stats->tx_dropped,
+		   stats->tx_fifo_errors, stats->collisions,
+		   stats->tx_carrier_errors +
+		    stats->tx_aborted_errors +
+		    stats->tx_window_errors +
+		    stats->tx_heartbeat_errors,
+		   stats->tx_compressed);
+}
+
+/*
+ *	Called from the PROCfs module. This now uses the new arbitrary sized
+ *	/proc/net interface to create /proc/net/dev
+ */
+static int dev_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "Inter-|   Receive                            "
+			      "                    |  Transmit\n"
+			      " face |bytes    packets errs drop fifo frame "
+			      "compressed multicast|bytes    packets errs "
+			      "drop fifo colls carrier compressed\n");
+	else
+		dev_seq_printf_stats(seq, v);
+	return 0;
+}
+
+static struct softnet_data *softnet_get_online(loff_t *pos)
+{
+	struct softnet_data *sd = NULL;
+
+	while (*pos < nr_cpu_ids)
+		if (cpu_online(*pos)) {
+			sd = &per_cpu(softnet_data, *pos);
+			break;
+		} else
+			++*pos;
+	return sd;
+}
+
+static void *softnet_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	return softnet_get_online(pos);
+}
+
+static void *softnet_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	++*pos;
+	return softnet_get_online(pos);
+}
+
+static void softnet_seq_stop(struct seq_file *seq, void *v)
+{
+}
+
+static int softnet_seq_show(struct seq_file *seq, void *v)
+{
+	struct softnet_data *sd = v;
+
+	seq_printf(seq, "%08x %08x %08x %08x %08x %08x %08x %08x %08x %08x\n",
+		   sd->processed, sd->dropped, sd->time_squeeze, 0,
+		   0, 0, 0, 0, /* was fastroute */
+		   sd->cpu_collision, sd->received_rps);
+	return 0;
+}
+
+static const struct seq_operations dev_seq_ops = {
+	.start = dev_seq_start,
+	.next  = dev_seq_next,
+	.stop  = dev_seq_stop,
+	.show  = dev_seq_show,
+};
+
+static int dev_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &dev_seq_ops,
+			    sizeof(struct seq_net_private));
+}
+
+static const struct file_operations dev_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = dev_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_net,
+};
+
+static const struct seq_operations softnet_seq_ops = {
+	.start = softnet_seq_start,
+	.next  = softnet_seq_next,
+	.stop  = softnet_seq_stop,
+	.show  = softnet_seq_show,
+};
+
+static int softnet_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &softnet_seq_ops);
+}
+
+static const struct file_operations softnet_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = softnet_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+static void *ptype_get_idx(loff_t pos)
+{
+	struct packet_type *pt = NULL;
+	loff_t i = 0;
+	int t;
+
+	list_for_each_entry_rcu(pt, &ptype_all, list) {
+		if (i == pos)
+			return pt;
+		++i;
+	}
+
+	for (t = 0; t < PTYPE_HASH_SIZE; t++) {
+		list_for_each_entry_rcu(pt, &ptype_base[t], list) {
+			if (i == pos)
+				return pt;
+			++i;
+		}
+	}
+	return NULL;
+}
+
+static void *ptype_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(RCU)
+{
+	rcu_read_lock();
+	return *pos ? ptype_get_idx(*pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *ptype_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct packet_type *pt;
+	struct list_head *nxt;
+	int hash;
+
+	++*pos;
+	if (v == SEQ_START_TOKEN)
+		return ptype_get_idx(0);
+
+	pt = v;
+	nxt = pt->list.next;
+	if (pt->type == htons(ETH_P_ALL)) {
+		if (nxt != &ptype_all)
+			goto found;
+		hash = 0;
+		nxt = ptype_base[0].next;
+	} else
+		hash = ntohs(pt->type) & PTYPE_HASH_MASK;
+
+	while (nxt == &ptype_base[hash]) {
+		if (++hash >= PTYPE_HASH_SIZE)
+			return NULL;
+		nxt = ptype_base[hash].next;
+	}
+found:
+	return list_entry(nxt, struct packet_type, list);
+}
+
+static void ptype_seq_stop(struct seq_file *seq, void *v)
+	__releases(RCU)
+{
+	rcu_read_unlock();
+}
+
+static int ptype_seq_show(struct seq_file *seq, void *v)
+{
+	struct packet_type *pt = v;
+
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "Type Device      Function\n");
+	else if (pt->dev == NULL || dev_net(pt->dev) == seq_file_net(seq)) {
+		if (pt->type == htons(ETH_P_ALL))
+			seq_puts(seq, "ALL ");
+		else
+			seq_printf(seq, "%04x", ntohs(pt->type));
+
+		seq_printf(seq, " %-8s %pF\n",
+			   pt->dev ? pt->dev->name : "", pt->func);
+	}
+
+	return 0;
+}
+
+static const struct seq_operations ptype_seq_ops = {
+	.start = ptype_seq_start,
+	.next  = ptype_seq_next,
+	.stop  = ptype_seq_stop,
+	.show  = ptype_seq_show,
+};
+
+static int ptype_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &ptype_seq_ops,
+			sizeof(struct seq_net_private));
+}
+
+static const struct file_operations ptype_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ptype_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_net,
+};
+
+
+static int __net_init dev_proc_net_init(struct net *net)
+{
+	int rc = -ENOMEM;
+
+	if (!proc_create("dev", S_IRUGO, net->proc_net, &dev_seq_fops))
+		goto out;
+	if (!proc_create("softnet_stat", S_IRUGO, net->proc_net,
+			 &softnet_seq_fops))
+		goto out_dev;
+	if (!proc_create("ptype", S_IRUGO, net->proc_net, &ptype_seq_fops))
+		goto out_softnet;
+
+	if (wext_proc_init(net))
+		goto out_ptype;
+	rc = 0;
+out:
+	return rc;
+out_ptype:
+	remove_proc_entry("ptype", net->proc_net);
+out_softnet:
+	remove_proc_entry("softnet_stat", net->proc_net);
+out_dev:
+	remove_proc_entry("dev", net->proc_net);
+	goto out;
+}
+
+static void __net_exit dev_proc_net_exit(struct net *net)
+{
+	wext_proc_exit(net);
+
+	remove_proc_entry("ptype", net->proc_net);
+	remove_proc_entry("softnet_stat", net->proc_net);
+	remove_proc_entry("dev", net->proc_net);
+}
+
+static struct pernet_operations __net_initdata dev_proc_ops = {
+	.init = dev_proc_net_init,
+	.exit = dev_proc_net_exit,
+};
+
+int __init dev_proc_init(void)
+{
+	return register_pernet_subsys(&dev_proc_ops);
+}
+
+static int dev_mc_seq_show(struct seq_file *seq, void *v)
+{
+	struct netdev_hw_addr *ha;
+	struct net_device *dev = v;
+
+	if (v == SEQ_START_TOKEN)
+		return 0;
+
+	netif_addr_lock_bh(dev);
+	netdev_for_each_mc_addr(ha, dev) {
+		int i;
+
+		seq_printf(seq, "%-4d %-15s %-5d %-5d ", dev->ifindex,
+			   dev->name, ha->refcount, ha->global_use);
+
+		for (i = 0; i < dev->addr_len; i++)
+			seq_printf(seq, "%02x", ha->addr[i]);
+
+		seq_putc(seq, '\n');
+	}
+	netif_addr_unlock_bh(dev);
+	return 0;
+}
+
+static const struct seq_operations dev_mc_seq_ops = {
+	.start = dev_seq_start,
+	.next  = dev_seq_next,
+	.stop  = dev_seq_stop,
+	.show  = dev_mc_seq_show,
+};
+
+static int dev_mc_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open_net(inode, file, &dev_mc_seq_ops,
+			    sizeof(struct seq_net_private));
+}
+
+static const struct file_operations dev_mc_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = dev_mc_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release_net,
+};
+
+static int __net_init dev_mc_net_init(struct net *net)
+{
+	if (!proc_create("dev_mcast", 0, net->proc_net, &dev_mc_seq_fops))
+		return -ENOMEM;
+	return 0;
+}
+
+static void __net_exit dev_mc_net_exit(struct net *net)
+{
+	remove_proc_entry("dev_mcast", net->proc_net);
+}
+
+static struct pernet_operations __net_initdata dev_mc_net_ops = {
+	.init = dev_mc_net_init,
+	.exit = dev_mc_net_exit,
+};
+
+void __init dev_mcast_init(void)
+{
+	register_pernet_subsys(&dev_mc_net_ops);
+}
-- 
1.7.7.6

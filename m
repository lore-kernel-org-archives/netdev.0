From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: [PATCH net-next-2.6] can: Speed up CAN frame receiption by using
	ml_priv
Date: Fri, 25 Dec 2009 17:47:47 +0100
Message-ID: <4B34ECB3.4010607@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Urs Thuermann <urs-5sm3ckEb1NlYFmeL5InDC7NAH6kLmebB@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Urs,

this patch removes the hlist that contains the CAN receiver filter lists.
It uses the 'midlayer private' pointer ml_priv and links the filters directly
to the CAN netdevice, which allows to omit the walk through the complete CAN
devices hlist for each received CAN frame.

This patch is tested and does not remove any locking.

Can you please check, if it would be ok for net-next-2.6 for you?

Thanks,
Oliver

Signed-off-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
---

 af_can.c |  118 ++++++++++++++++++---------------------------------------------
 af_can.h |    4 --
 proc.c   |   93 ++++++++++++++++++++++++++++++++-----------------
 3 files changed, 96 insertions(+), 119 deletions(-)


diff --git a/net/can/af_can.c b/net/can/af_can.c
index 51adc4c..bc18b08 100644
--- a/net/can/af_can.c
+++ b/net/can/af_can.c
@@ -77,8 +77,8 @@ static int stats_timer __read_mostly = 1;
 module_param(stats_timer, int, S_IRUGO);
 MODULE_PARM_DESC(stats_timer, "enable timer for statistics (default:on)");
 
-HLIST_HEAD(can_rx_dev_list);
-static struct dev_rcv_lists can_rx_alldev_list;
+/* receive filters subscribed for 'all' CAN devices */
+struct dev_rcv_lists can_rx_alldev_list;
 static DEFINE_SPINLOCK(can_rcvlists_lock);
 
 static struct kmem_cache *rcv_cache __read_mostly;
@@ -292,28 +292,10 @@ EXPORT_SYMBOL(can_send);
 
 static struct dev_rcv_lists *find_dev_rcv_lists(struct net_device *dev)
 {
-	struct dev_rcv_lists *d = NULL;
-	struct hlist_node *n;
-
-	/*
-	 * find receive list for this device
-	 *
-	 * The hlist_for_each_entry*() macros curse through the list
-	 * using the pointer variable n and set d to the containing
-	 * struct in each list iteration.  Therefore, after list
-	 * iteration, d is unmodified when the list is empty, and it
-	 * points to last list element, when the list is non-empty
-	 * but no match in the loop body is found.  I.e. d is *not*
-	 * NULL when no match is found.  We can, however, use the
-	 * cursor variable n to decide if a match was found.
-	 */
-
-	hlist_for_each_entry_rcu(d, n, &can_rx_dev_list, list) {
-		if (d->dev == dev)
-			break;
-	}
-
-	return n ? d : NULL;
+	if (!dev)
+		return &can_rx_alldev_list;
+	else
+		return (struct dev_rcv_lists *)dev->ml_priv;
 }
 
 /**
@@ -468,16 +450,6 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
 EXPORT_SYMBOL(can_rx_register);
 
 /*
- * can_rx_delete_device - rcu callback for dev_rcv_lists structure removal
- */
-static void can_rx_delete_device(struct rcu_head *rp)
-{
-	struct dev_rcv_lists *d = container_of(rp, struct dev_rcv_lists, rcu);
-
-	kfree(d);
-}
-
-/*
  * can_rx_delete_receiver - rcu callback for single receiver entry removal
  */
 static void can_rx_delete_receiver(struct rcu_head *rp)
@@ -541,7 +513,6 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 		       "dev %s, id %03X, mask %03X\n",
 		       DNAME(dev), can_id, mask);
 		r = NULL;
-		d = NULL;
 		goto out;
 	}
 
@@ -552,10 +523,10 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 		can_pstats.rcv_entries--;
 
 	/* remove device structure requested by NETDEV_UNREGISTER */
-	if (d->remove_on_zero_entries && !d->entries)
-		hlist_del_rcu(&d->list);
-	else
-		d = NULL;
+	if (d->remove_on_zero_entries && !d->entries) {
+		kfree(d);
+		dev->ml_priv = NULL;
+	}
 
  out:
 	spin_unlock(&can_rcvlists_lock);
@@ -563,10 +534,6 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
 	/* schedule the receiver item for deletion */
 	if (r)
 		call_rcu(&r->rcu, can_rx_delete_receiver);
-
-	/* schedule the device structure for deletion */
-	if (d)
-		call_rcu(&d->rcu, can_rx_delete_device);
 }
 EXPORT_SYMBOL(can_rx_unregister);
 
@@ -780,48 +747,35 @@ static int can_notifier(struct notifier_block *nb, unsigned long msg,
 
 	case NETDEV_REGISTER:
 
-		/*
-		 * create new dev_rcv_lists for this device
-		 *
-		 * N.B. zeroing the struct is the correct initialization
-		 * for the embedded hlist_head structs.
-		 * Another list type, e.g. list_head, would require
-		 * explicit initialization.
-		 */
-
+		/* create new dev_rcv_lists for this device */
 		d = kzalloc(sizeof(*d), GFP_KERNEL);
 		if (!d) {
 			printk(KERN_ERR
 			       "can: allocation of receive list failed\n");
 			return NOTIFY_DONE;
 		}
-		d->dev = dev;
-
-		spin_lock(&can_rcvlists_lock);
-		hlist_add_head_rcu(&d->list, &can_rx_dev_list);
-		spin_unlock(&can_rcvlists_lock);
+		BUG_ON(dev->ml_priv);
+		dev->ml_priv = d;
 
 		break;
 
 	case NETDEV_UNREGISTER:
 		spin_lock(&can_rcvlists_lock);
 
-		d = find_dev_rcv_lists(dev);
+		d = dev->ml_priv;
 		if (d) {
-			if (d->entries) {
+			if (d->entries)
 				d->remove_on_zero_entries = 1;
-				d = NULL;
-			} else
-				hlist_del_rcu(&d->list);
+			else {
+				kfree(d);
+				dev->ml_priv = NULL;
+			}
 		} else
 			printk(KERN_ERR "can: notifier: receive list not "
 			       "found for dev %s\n", dev->name);
 
 		spin_unlock(&can_rcvlists_lock);
 
-		if (d)
-			call_rcu(&d->rcu, can_rx_delete_device);
-
 		break;
 	}
 
@@ -853,21 +807,13 @@ static __init int can_init(void)
 {
 	printk(banner);
 
+	memset(&can_rx_alldev_list, 0, sizeof(can_rx_alldev_list));
+
 	rcv_cache = kmem_cache_create("can_receiver", sizeof(struct receiver),
 				      0, 0, NULL);
 	if (!rcv_cache)
 		return -ENOMEM;
 
-	/*
-	 * Insert can_rx_alldev_list for reception on all devices.
-	 * This struct is zero initialized which is correct for the
-	 * embedded hlist heads, the dev pointer, and the entries counter.
-	 */
-
-	spin_lock(&can_rcvlists_lock);
-	hlist_add_head_rcu(&can_rx_alldev_list.list, &can_rx_dev_list);
-	spin_unlock(&can_rcvlists_lock);
-
 	if (stats_timer) {
 		/* the statistics are updated every second (timer triggered) */
 		setup_timer(&can_stattimer, can_stat_update, 0);
@@ -887,8 +833,7 @@ static __init int can_init(void)
 
 static __exit void can_exit(void)
 {
-	struct dev_rcv_lists *d;
-	struct hlist_node *n, *next;
+	struct net_device *dev;
 
 	if (stats_timer)
 		del_timer(&can_stattimer);
@@ -900,14 +845,19 @@ static __exit void can_exit(void)
 	unregister_netdevice_notifier(&can_netdev_notifier);
 	sock_unregister(PF_CAN);
 
-	/* remove can_rx_dev_list */
-	spin_lock(&can_rcvlists_lock);
-	hlist_del(&can_rx_alldev_list.list);
-	hlist_for_each_entry_safe(d, n, next, &can_rx_dev_list, list) {
-		hlist_del(&d->list);
-		kfree(d);
+	/* remove created dev_rcv_lists from still registered CAN devices */
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
+		if (dev->type == ARPHRD_CAN && dev->ml_priv){
+
+			struct dev_rcv_lists *d = dev->ml_priv;
+
+			BUG_ON(d->entries);
+			kfree(d);
+			dev->ml_priv = NULL;
+		}
 	}
-	spin_unlock(&can_rcvlists_lock);
+	rcu_read_unlock();
 
 	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 
diff --git a/net/can/af_can.h b/net/can/af_can.h
index 18f91e3..34253b8 100644
--- a/net/can/af_can.h
+++ b/net/can/af_can.h
@@ -63,10 +63,8 @@ struct receiver {
 
 enum { RX_ERR, RX_ALL, RX_FIL, RX_INV, RX_EFF, RX_MAX };
 
+/* per device receive filters linked at dev->ml_priv */
 struct dev_rcv_lists {
-	struct hlist_node list;
-	struct rcu_head rcu;
-	struct net_device *dev;
 	struct hlist_head rx[RX_MAX];
 	struct hlist_head rx_sff[0x800];
 	int remove_on_zero_entries;
diff --git a/net/can/proc.c b/net/can/proc.c
index 9b9ad29..f4265cc 100644
--- a/net/can/proc.c
+++ b/net/can/proc.c
@@ -45,6 +45,7 @@
 #include <linux/proc_fs.h>
 #include <linux/list.h>
 #include <linux/rcupdate.h>
+#include <linux/if_arp.h>
 #include <linux/can/core.h>
 
 #include "af_can.h"
@@ -84,6 +85,9 @@ static const char rx_list_name[][8] = {
 	[RX_EFF] = "rx_eff",
 };
 
+/* receive filters subscribed for 'all' CAN devices */
+extern struct dev_rcv_lists can_rx_alldev_list;
+
 /*
  * af_can statistics stuff
  */
@@ -190,10 +194,6 @@ void can_stat_update(unsigned long data)
 
 /*
  * proc read functions
- *
- * From known use-cases we expect about 10 entries in a receive list to be
- * printed in the proc_fs. So PAGE_SIZE is definitely enough space here.
- *
  */
 
 static void can_print_rcvlist(struct seq_file *m, struct hlist_head *rx_list,
@@ -202,7 +202,6 @@ static void can_print_rcvlist(struct seq_file *m, struct hlist_head *rx_list,
 	struct receiver *r;
 	struct hlist_node *n;
 
-	rcu_read_lock();
 	hlist_for_each_entry_rcu(r, n, rx_list, list) {
 		char *fmt = (r->can_id & CAN_EFF_FLAG)?
 			"   %-5s  %08X  %08x  %08x  %08x  %8ld  %s\n" :
@@ -212,7 +211,6 @@ static void can_print_rcvlist(struct seq_file *m, struct hlist_head *rx_list,
 				(unsigned long)r->func, (unsigned long)r->data,
 				r->matches, r->ident);
 	}
-	rcu_read_unlock();
 }
 
 static void can_print_recv_banner(struct seq_file *m)
@@ -346,24 +344,39 @@ static const struct file_operations can_version_proc_fops = {
 	.release	= single_release,
 };
 
+static inline void can_rcvlist_proc_show_one(struct seq_file *m, int idx,
+					     struct net_device *dev,
+					     struct dev_rcv_lists *d)
+{
+	if (!hlist_empty(&d->rx[idx])) {
+		can_print_recv_banner(m);
+		can_print_rcvlist(m, &d->rx[idx], dev);
+	} else
+		seq_printf(m, "  (%s: no entry)\n", DNAME(dev));
+
+}
+
 static int can_rcvlist_proc_show(struct seq_file *m, void *v)
 {
 	/* double cast to prevent GCC warning */
 	int idx = (int)(long)m->private;
+	struct net_device *dev;
 	struct dev_rcv_lists *d;
-	struct hlist_node *n;
 
 	seq_printf(m, "\nreceive list '%s':\n", rx_list_name[idx]);
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &can_rx_dev_list, list) {
 
-		if (!hlist_empty(&d->rx[idx])) {
-			can_print_recv_banner(m);
-			can_print_rcvlist(m, &d->rx[idx], d->dev);
-		} else
-			seq_printf(m, "  (%s: no entry)\n", DNAME(d->dev));
+	/* receive list for 'all' CAN devices (dev == NULL) */
+	d = &can_rx_alldev_list;
+	can_rcvlist_proc_show_one(m, idx, NULL, d);
+
+	/* receive list for registered CAN devices */
+	for_each_netdev_rcu(&init_net, dev) {
+		if (dev->type == ARPHRD_CAN && dev->ml_priv)
+			can_rcvlist_proc_show_one(m, idx, dev, dev->ml_priv);
 	}
+
 	rcu_read_unlock();
 
 	seq_putc(m, '\n');
@@ -383,34 +396,50 @@ static const struct file_operations can_rcvlist_proc_fops = {
 	.release	= single_release,
 };
 
+static inline void can_rcvlist_sff_proc_show_one(struct seq_file *m,
+						 struct net_device *dev,
+						 struct dev_rcv_lists *d)
+{
+	int i;
+	int all_empty = 1;
+
+	/* check wether at least one list is non-empty */
+	for (i = 0; i < 0x800; i++)
+		if (!hlist_empty(&d->rx_sff[i])) {
+			all_empty = 0;
+			break;
+		}
+
+	if (!all_empty) {
+		can_print_recv_banner(m);
+		for (i = 0; i < 0x800; i++) {
+			if (!hlist_empty(&d->rx_sff[i]))
+				can_print_rcvlist(m, &d->rx_sff[i], dev);
+		}
+	} else
+		seq_printf(m, "  (%s: no entry)\n", DNAME(dev));
+}
+
 static int can_rcvlist_sff_proc_show(struct seq_file *m, void *v)
 {
+	struct net_device *dev;
 	struct dev_rcv_lists *d;
-	struct hlist_node *n;
 
 	/* RX_SFF */
 	seq_puts(m, "\nreceive list 'rx_sff':\n");
 
 	rcu_read_lock();
-	hlist_for_each_entry_rcu(d, n, &can_rx_dev_list, list) {
-		int i, all_empty = 1;
-		/* check wether at least one list is non-empty */
-		for (i = 0; i < 0x800; i++)
-			if (!hlist_empty(&d->rx_sff[i])) {
-				all_empty = 0;
-				break;
-			}
-
-		if (!all_empty) {
-			can_print_recv_banner(m);
-			for (i = 0; i < 0x800; i++) {
-				if (!hlist_empty(&d->rx_sff[i]))
-					can_print_rcvlist(m, &d->rx_sff[i],
-							  d->dev);
-			}
-		} else
-			seq_printf(m, "  (%s: no entry)\n", DNAME(d->dev));
+
+	/* sff receive list for 'all' CAN devices (dev == NULL) */
+	d = &can_rx_alldev_list;
+	can_rcvlist_sff_proc_show_one(m, NULL, d);
+
+	/* sff receive list for registered CAN devices */
+	for_each_netdev_rcu(&init_net, dev) {
+		if (dev->type == ARPHRD_CAN && dev->ml_priv)
+			can_rcvlist_sff_proc_show_one(m, dev, dev->ml_priv);
 	}
+
 	rcu_read_unlock();
 
 	seq_putc(m, '\n');

From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] Update bpqether for 2.6
Date: Mon, 11 Aug 2003 16:22:05 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030811162205.78b2029f.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-hams@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, Joerg Reuter <jreuter@yaina.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch fixes several issues with drivers/net/hamradio/bpqether.c in 2.6.0-test3.

1. Fix encapsulation of net_device structure relative to private data (bpqdev)
2. Convert from single-linked list to the list macros.
3. Convert to using seq_file for the /proc interface
4. Fix up locking by switching to RCU and the rtnl semaphore supplied
   by the network layer.
5. Fix removal cases of ethernet device and bpqether device to work
   without deadlock.
6. Get rid of MOD_INC/MOD_DEC
7. Get rid of bogus check_devices method of cleanup, just cleanup correctly
   when device changes state.

Tested with load/unload and ether load/unload on SMP.
Don't have real BPQ hardware to interact with, but didn't change the data flow
path.

diff -Nru a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
--- a/drivers/net/hamradio/bpqether.c	Mon Aug 11 15:57:14 2003
+++ b/drivers/net/hamradio/bpqether.c	Mon Aug 11 15:57:14 2003
@@ -75,6 +75,7 @@
 #include <linux/interrupt.h>
 #include <linux/notifier.h>
 #include <linux/proc_fs.h>
+#include <linux/seq_file.h>
 #include <linux/stat.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
@@ -99,7 +100,7 @@
 
 static int bpq_rcv(struct sk_buff *, struct net_device *, struct packet_type *);
 static int bpq_device_event(struct notifier_block *, unsigned long, void *);
-static char *bpq_print_ethaddr(unsigned char *);
+static const char *bpq_print_ethaddr(const unsigned char *);
 
 static struct packet_type bpq_packet_type = {
 	.type	= __constant_htons(ETH_P_BPQ),
@@ -113,15 +114,16 @@
 
 #define MAXBPQDEV 100
 
-static struct bpqdev {
-	struct bpqdev *next;
-	char   ethname[14];		/* ether device name */
-	struct net_device *ethdev;		/* link to ethernet device */
-	struct net_device axdev;		/* bpq device (bpq#) */
+struct bpqdev {
+	struct list_head bpq_list;	/* list of bpq devices chain */
+	struct net_device *ethdev;	/* link to ethernet device */
+	struct net_device *axdev;	/* bpq device (bpq#) */
 	struct net_device_stats stats;	/* some statistics */
 	char   dest_addr[6];		/* ether destination address */
 	char   acpt_addr[6];		/* accept ether frames from this address only */
-} *bpq_devices;
+};
+
+static LIST_HEAD(bpq_devices);
 
 
 /* ------------------------------------------------------------------------ */
@@ -139,15 +141,16 @@
 
 /*
  *	Get the BPQ device for the ethernet device
+ * need to hold bqp_lock at least for read
  */
 static inline struct net_device *bpq_get_ax25_dev(struct net_device *dev)
 {
 	struct bpqdev *bpq;
 
-	for (bpq = bpq_devices; bpq != NULL; bpq = bpq->next)
+	list_for_each_entry(bpq, &bpq_devices, bpq_list) {
 		if (bpq->ethdev == dev)
-			return &bpq->axdev;
-
+			return bpq->axdev;
+	}
 	return NULL;
 }
 
@@ -159,50 +162,6 @@
 	);
 }
 
-static spinlock_t bpq_lock = SPIN_LOCK_UNLOCKED;
-
-/*
- *	Sanity check: remove all devices that ceased to exists and
- *	return '1' if the given BPQ device was affected.
- */
-static int bpq_check_devices(struct net_device *dev)
-{
-	struct bpqdev *bpq, *bpq_prev, *bpq_next;
-	int result = 0;
-	unsigned long flags;
-
-	spin_lock_irqsave(&bpq_lock, flags);
-
-	bpq_prev = NULL;
-
-	for (bpq = bpq_devices; bpq != NULL; bpq = bpq_next) {
-		bpq_next = bpq->next;
-		if (!dev_get(bpq->ethname)) {
-			if (bpq_prev)
-				bpq_prev->next = bpq->next;
-			else
-				bpq_devices = bpq->next;
-
-			if (&bpq->axdev == dev)
-				result = 1;
-
-			/* We should be locked, call 
-			 * unregister_netdevice directly 
-			 */
-
-			unregister_netdevice(&bpq->axdev);
-			kfree(bpq);
-		}
-		else
-			bpq_prev = bpq;
-	}
-
-	spin_unlock_irqrestore(&bpq_lock, flags);
-
-	return result;
-}
-
-
 /* ------------------------------------------------------------------------ */
 
 
@@ -218,12 +177,11 @@
 
 	skb->sk = NULL;		/* Initially we don't know who it's for */
 
+	rcu_read_lock();
 	dev = bpq_get_ax25_dev(dev);
 
-	if (dev == NULL || !netif_running(dev)) {
-		kfree_skb(skb);
-		return 0;
-	}
+	if (dev == NULL || !netif_running(dev)) 
+		goto drop;
 
 	/*
 	 * if we want to accept frames from just one ethernet device
@@ -234,8 +192,7 @@
 
 	if (!(bpq->acpt_addr[0] & 0x01) && memcmp(eth->h_source, bpq->acpt_addr, ETH_ALEN)) {
 		printk(KERN_DEBUG "bpqether: wrong dest %s\n", bpq_print_ethaddr(eth->h_source));
-		kfree_skb(skb);
-		return 0;
+		goto drop;
 	}
 
 	len = skb->data[0] + skb->data[1] * 256 - 5;
@@ -256,8 +213,15 @@
 
 	netif_rx(skb);
 	dev->last_rx = jiffies;
+ unlock:
+
+	rcu_read_unlock();
 
 	return 0;
+ drop:
+	kfree_skb(skb);
+	goto unlock;
+
 }
 
 /*
@@ -275,7 +239,6 @@
 	 * is down, the ethernet device may have gone.
 	 */
 	if (!netif_running(dev)) {
-		bpq_check_devices(dev);
 		kfree_skb(skb);
 		return -ENODEV;
 	}
@@ -400,11 +363,6 @@
  */
 static int bpq_open(struct net_device *dev)
 {
-	if (bpq_check_devices(dev))
-		return -ENODEV;		/* oops, it's gone */
-	
-	MOD_INC_USE_COUNT;
-
 	netif_start_queue(dev);
 	return 0;
 }
@@ -412,15 +370,6 @@
 static int bpq_close(struct net_device *dev)
 {
 	netif_stop_queue(dev);
-	MOD_DEC_USE_COUNT;
-	return 0;
-}
-
-/*
- * currently unused
- */
-static int bpq_dev_init(struct net_device *dev)
-{
 	return 0;
 }
 
@@ -431,7 +380,7 @@
 /*
  *	Proc filesystem
  */
-static char * bpq_print_ethaddr(unsigned char *e)
+static const char * bpq_print_ethaddr(const unsigned char *e)
 {
 	static char buf[18];
 
@@ -441,98 +390,92 @@
 	return buf;
 }
 
-static int bpq_get_info(char *buffer, char **start, off_t offset, int length)
+#define BPQ_PROC_START ((void *)1)
+
+static void *bpq_seq_start(struct seq_file *seq, loff_t *pos)
 {
+	int i = 1;
 	struct bpqdev *bpqdev;
-	int len     = 0;
-	off_t pos   = 0;
-	off_t begin = 0;
-	unsigned long flags;
-
-	spin_lock_irqsave(&bpq_lock, flags);
-
-	len += sprintf(buffer, "dev   ether      destination        accept from\n");
-
-	for (bpqdev = bpq_devices; bpqdev != NULL; bpqdev = bpqdev->next) {
-		len += sprintf(buffer + len, "%-5s %-10s %s  ",
-			bpqdev->axdev.name, bpqdev->ethname,
-			bpq_print_ethaddr(bpqdev->dest_addr));
-
-		len += sprintf(buffer + len, "%s\n",
-			(bpqdev->acpt_addr[0] & 0x01) ? "*" : bpq_print_ethaddr(bpqdev->acpt_addr));
 
-		pos = begin + len;
+	rcu_read_lock();
 
-		if (pos < offset) {
-			len   = 0;
-			begin = pos;
-		}
-
-		if (pos > offset + length)
-			break;
+	if (*pos == 0)
+		return BPQ_PROC_START;
+	
+	list_for_each_entry(bpqdev, &bpq_devices, bpq_list) {
+		if (i == *pos)
+			return bpqdev;
 	}
+	return NULL;
+}
 
-	spin_unlock_irqrestore(&bpq_lock, flags);
+static void *bpq_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct list_head *p;
 
-	*start = buffer + (offset - begin);
-	len   -= (offset - begin);
+	++*pos;
 
-	if (len > length) len = length;
+	if (v == BPQ_PROC_START)
+		p = bpq_devices.next;
+	else
+		p = ((struct bpqdev *)v)->bpq_list.next;
 
-	return len;
+	return (p == &bpq_devices) ? NULL 
+		: list_entry(p, struct bpqdev, bpq_list);
 }
 
-
-/* ------------------------------------------------------------------------ */
-
-
-/*
- *	Setup a new device.
- */
-static int bpq_new_device(struct net_device *dev)
+static void bpq_seq_stop(struct seq_file *seq, void *v)
 {
-	int k;
-	struct bpqdev *bpq, *bpq2;
-	unsigned long flags;
+	rcu_read_unlock();
+}
 
-	if ((bpq = kmalloc(sizeof(struct bpqdev), GFP_KERNEL)) == NULL)
-		return -ENOMEM;
 
-	memset(bpq, 0, sizeof(struct bpqdev));
+static int bpq_seq_show(struct seq_file *seq, void *v)
+{
+	if (v == BPQ_PROC_START)
+		seq_puts(seq, 
+			 "dev   ether      destination        accept from\n");
+	else {
+		const struct bpqdev *bpqdev = v;
 
-	bpq->ethdev = dev;
+		seq_printf(seq, "%-5s %-10s %s  ",
+			bpqdev->axdev->name, bpqdev->ethdev->name,
+			bpq_print_ethaddr(bpqdev->dest_addr));
 
-	bpq->ethname[sizeof(bpq->ethname)-1] = '\0';
-	strncpy(bpq->ethname, dev->name, sizeof(bpq->ethname)-1);
+		seq_printf(seq, "%s\n",
+			(bpqdev->acpt_addr[0] & 0x01) ? "*" 
+			   : bpq_print_ethaddr(bpqdev->acpt_addr));
 
-	memcpy(bpq->dest_addr, bcast_addr, sizeof(bpq_eth_addr));
-	memcpy(bpq->acpt_addr, bcast_addr, sizeof(bpq_eth_addr));
-
-	dev = &bpq->axdev;
+	}
+	return 0;
+}
 
-	for (k = 0; k < MAXBPQDEV; k++) {
-		struct net_device *odev;
+static struct seq_operations bpq_seqops = {
+	.start = bpq_seq_start,
+	.next = bpq_seq_next,
+	.stop = bpq_seq_stop,
+	.show = bpq_seq_show,
+};
 
-		sprintf(dev->name, "bpq%d", k);
+static int bpq_info_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &bpq_seqops);
+}
 
-		if ((odev = __dev_get_by_name(dev->name)) == NULL || bpq_check_devices(odev))
-			break;
-	}
+static struct file_operations bpq_info_fops = {
+	.owner = THIS_MODULE,
+	.open = bpq_info_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
 
-	if (k == MAXBPQDEV) {
-		kfree(bpq);
-		return -ENODEV;
-	}
 
-	dev->priv = (void *)bpq;	/* pointer back */
-	dev->init = bpq_dev_init;
+/* ------------------------------------------------------------------------ */
 
-	/* We should be locked, call register_netdevice() directly. */
 
-	if (register_netdevice(dev) != 0) {
-		kfree(bpq);
-                return -EIO;
-        }
+static void bpq_setup(struct net_device *dev)
+{
 
 	dev->hard_start_xmit = bpq_xmit;
 	dev->open	     = bpq_open;
@@ -540,6 +483,7 @@
 	dev->set_mac_address = bpq_set_mac_address;
 	dev->get_stats	     = bpq_get_stats;
 	dev->do_ioctl	     = bpq_ioctl;
+	dev->destructor	     =  (void (*)(struct net_device *)) kfree;
 
 	memcpy(dev->broadcast, ax25_bcast, AX25_ADDR_LEN);
 	memcpy(dev->dev_addr,  ax25_defaddr, AX25_ADDR_LEN);
@@ -556,20 +500,59 @@
 	dev->mtu             = AX25_DEF_PACLEN;
 	dev->addr_len        = AX25_ADDR_LEN;
 
-	spin_lock_irqsave(&bpq_lock, flags);
+}
 
-	if (bpq_devices == NULL) {
-		bpq_devices = bpq;
-	} else {
-		for (bpq2 = bpq_devices; bpq2->next != NULL; bpq2 = bpq2->next);
-		bpq2->next = bpq;
-	}
+/*
+ *	Setup a new device.
+ */
+static int bpq_new_device(struct net_device *edev)
+{
+	int err;
+	struct net_device *ndev;
+	struct bpqdev *bpq;
+
+	ndev = alloc_netdev(sizeof(struct bpqdev), "bpq%d",
+			   bpq_setup);
+	if (!ndev)
+		return -ENOMEM;
+
+		
+	bpq = ndev->priv;
+	dev_hold(edev);
+	bpq->ethdev = edev;
+	bpq->axdev = ndev;
 
-	spin_unlock_irqrestore(&bpq_lock, flags);
+	memcpy(bpq->dest_addr, bcast_addr, sizeof(bpq_eth_addr));
+	memcpy(bpq->acpt_addr, bcast_addr, sizeof(bpq_eth_addr));
+
+	err = dev_alloc_name(ndev, ndev->name);
+	if (err < 0) 
+		goto error;
+
+	err = register_netdevice(ndev);
+	if (err)
+		goto error;
 
+	/* List protected by RTNL */
+	list_add_rcu(&bpq->bpq_list, &bpq_devices);
 	return 0;
+
+ error:
+	dev_put(edev);
+	kfree(ndev);
+	return err;
+	
 }
 
+static void bpq_free_device(struct net_device *ndev)
+{
+	struct bpqdev *bpq = ndev->priv;
+
+	dev_put(bpq->ethdev);
+	list_del_rcu(&bpq->bpq_list);
+
+	unregister_netdevice(ndev);
+}
 
 /*
  *	Handle device status changes.
@@ -581,21 +564,23 @@
 	if (!dev_is_ethdev(dev))
 		return NOTIFY_DONE;
 
-	bpq_check_devices(NULL);
-
 	switch (event) {
-		case NETDEV_UP:		/* new ethernet device -> new BPQ interface */
-			if (bpq_get_ax25_dev(dev) == NULL)
-				bpq_new_device(dev);
-			break;
-
-		case NETDEV_DOWN:	/* ethernet device closed -> close BPQ interface */
-			if ((dev = bpq_get_ax25_dev(dev)) != NULL)
-				dev_close(dev);
-			break;
+	case NETDEV_UP:		/* new ethernet device -> new BPQ interface */
+		if (bpq_get_ax25_dev(dev) == NULL)
+			bpq_new_device(dev);
+		break;
 
-		default:
-			break;
+	case NETDEV_DOWN:	/* ethernet device closed -> close BPQ interface */
+		if ((dev = bpq_get_ax25_dev(dev)) != NULL)
+			dev_close(dev);
+		break;
+
+	case NETDEV_UNREGISTER:	/* ethernet device removed -> free BPQ interface */
+		if ((dev = bpq_get_ax25_dev(dev)) != NULL)
+			bpq_free_device(dev);
+		break;
+	default:
+		break;
 	}
 
 	return NOTIFY_DONE;
@@ -618,7 +603,7 @@
 
 	printk(banner);
 
-	if (!proc_net_create("bpqether", 0, bpq_get_info)) {
+	if (!proc_net_fops_create("bpqether", S_IRUGO, &bpq_info_fops)) {
 		printk(KERN_ERR
 			"bpq: cannot create /proc/net/bpqether entry.\n");
 		unregister_netdevice_notifier(&bpq_dev_notifier);
@@ -626,15 +611,15 @@
 		return -ENOENT;
 	}
 
-	read_lock_bh(&dev_base_lock);
+	rtnl_lock();
 	for (dev = dev_base; dev != NULL; dev = dev->next) {
-		if (dev_is_ethdev(dev)) {
-			read_unlock_bh(&dev_base_lock);
-			bpq_new_device(dev);
-			read_lock_bh(&dev_base_lock);
+		if (dev_is_ethdev(dev) && bpq_new_device(dev)) {
+			printk(KERN_ERR
+			       "bpq: cannot setup dev for '%s'\n",
+			       dev->name);
 		}
 	}
-	read_unlock_bh(&dev_base_lock);
+	rtnl_unlock();
 	return 0;
 }
 
@@ -648,8 +633,12 @@
 
 	proc_net_remove("bpqether");
 
-	for (bpq = bpq_devices; bpq != NULL; bpq = bpq->next)
-		unregister_netdev(&bpq->axdev);
+	rtnl_lock();
+	while (!list_empty(&bpq_devices)) {
+		bpq = list_entry(bpq_devices.next, struct bpqdev, bpq_list);
+		bpq_free_device(bpq->axdev);
+	}
+	rtnl_unlock();
 }
 
 MODULE_AUTHOR("Joerg Reuter DL1BKE <jreuter@yaina.de>");

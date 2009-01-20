From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH 4/5] net: ppp_generic - introduce net-namespace functionality v2
Date: Tue, 20 Jan 2009 14:14:55 +0000 (UTC)
Message-ID: <4975dc12.1438560a.5c3c.403b__11458.48691599$1232460973$gmane$org@mx.google.com>
References: <20090120140510.228815074@gmail.com>>
Cc: Paul Mackerras <paulus@samba.org>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: davem@davemloft.net, jchapman@katalix.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	devel@openvz.org, xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:18268 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758989AbZATONl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 09:13:41 -0500
Date: Thu, 01 Jan 1970 03:00:04 +0300
Content-Disposition: inline; filename=net-ppp-generic-namespace-v2
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Each namespace contains ppp channels and units separately
  with appropriate locks

CC: Paul Mackerras <paulus@samba.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 drivers/net/ppp_generic.c   |  275 +++++++++++++++++++++++++++++++-------------
 include/linux/ppp_channel.h |    4 
 2 files changed, 202 insertions(+), 77 deletions(-)

Index: linux-2.6.git/drivers/net/ppp_generic.c
===================================================================
--- linux-2.6.git.orig/drivers/net/ppp_generic.c
+++ linux-2.6.git/drivers/net/ppp_generic.c
@@ -49,6 +49,10 @@
 #include <net/slhc_vj.h>
 #include <asm/atomic.h>
 
+#include <linux/nsproxy.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+
 #define PPP_VERSION	"2.4.2"
 
 /*
@@ -131,6 +135,7 @@ struct ppp {
 	struct sock_filter *active_filter;/* filter for pkts to reset idle */
 	unsigned pass_len, active_len;
 #endif /* CONFIG_PPP_FILTER */
+	struct net	*ppp_net;	/* the net we belong to */
 };
 
 /*
@@ -155,6 +160,7 @@ struct channel {
 	struct rw_semaphore chan_sem;	/* protects `chan' during chan ioctl */
 	spinlock_t	downl;		/* protects `chan', file.xq dequeue */
 	struct ppp	*ppp;		/* ppp unit we're connected to */
+	struct net	*chan_net;	/* the net channel belongs to */
 	struct list_head clist;		/* link in list of channels per unit */
 	rwlock_t	upl;		/* protects `ppp' */
 #ifdef CONFIG_PPP_MULTILINK
@@ -173,26 +179,35 @@ struct channel {
  * channel.downl.
  */
 
-/*
- * all_ppp_mutex protects the all_ppp_units mapping.
- * It also ensures that finding a ppp unit in the all_ppp_units map
- * and updating its file.refcnt field is atomic.
- */
-static DEFINE_MUTEX(all_ppp_mutex);
 static atomic_t ppp_unit_count = ATOMIC_INIT(0);
-static DEFINE_IDR(ppp_units_idr);
-
-/*
- * all_channels_lock protects all_channels and last_channel_index,
- * and the atomicity of find a channel and updating its file.refcnt
- * field.
- */
-static DEFINE_SPINLOCK(all_channels_lock);
-static LIST_HEAD(all_channels);
-static LIST_HEAD(new_channels);
-static int last_channel_index;
 static atomic_t channel_count = ATOMIC_INIT(0);
 
+/* per-net private data for this module */
+static unsigned int ppp_net_id;
+struct ppp_net {
+	/* units to ppp mapping */
+	struct idr units_idr;
+
+	/*
+	 * all_ppp_mutex protects the units_idr mapping.
+	 * It also ensures that finding a ppp unit in the units_idr
+	 * map and updating its file.refcnt field is atomic.
+	 */
+	struct mutex all_ppp_mutex;
+
+	/* channels */
+	struct list_head all_channels;
+	struct list_head new_channels;
+	int last_channel_index;
+
+	/*
+	 * all_channels_lock protects all_channels and
+	 * last_channel_index, and the atomicity of find
+	 * a channel and updating its file.refcnt field.
+	 */
+	spinlock_t all_channels_lock;
+};
+
 /* Get the PPP protocol number from a skb */
 #define PPP_PROTO(skb)	(((skb)->data[0] << 8) + (skb)->data[1])
 
@@ -216,8 +231,8 @@ static atomic_t channel_count = ATOMIC_I
 #define seq_after(a, b)		((s32)((a) - (b)) > 0)
 
 /* Prototypes. */
-static int ppp_unattached_ioctl(struct ppp_file *pf, struct file *file,
-				unsigned int cmd, unsigned long arg);
+static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
+			struct file *file, unsigned int cmd, unsigned long arg);
 static void ppp_xmit_process(struct ppp *ppp);
 static void ppp_send_frame(struct ppp *ppp, struct sk_buff *skb);
 static void ppp_push(struct ppp *ppp);
@@ -240,12 +255,12 @@ static void ppp_ccp_peek(struct ppp *ppp
 static void ppp_ccp_closed(struct ppp *ppp);
 static struct compressor *find_compressor(int type);
 static void ppp_get_stats(struct ppp *ppp, struct ppp_stats *st);
-static struct ppp *ppp_create_interface(int unit, int *retp);
+static struct ppp *ppp_create_interface(struct net *net, int unit, int *retp);
 static void init_ppp_file(struct ppp_file *pf, int kind);
 static void ppp_shutdown_interface(struct ppp *ppp);
 static void ppp_destroy_interface(struct ppp *ppp);
-static struct ppp *ppp_find_unit(int unit);
-static struct channel *ppp_find_channel(int unit);
+static struct ppp *ppp_find_unit(struct ppp_net *pn, int unit);
+static struct channel *ppp_find_channel(struct ppp_net *pn, int unit);
 static int ppp_connect_channel(struct channel *pch, int unit);
 static int ppp_disconnect_channel(struct channel *pch);
 static void ppp_destroy_channel(struct channel *pch);
@@ -256,6 +271,14 @@ static void *unit_find(struct idr *p, in
 
 static struct class *ppp_class;
 
+/* per net-namespace data */
+static inline struct ppp_net *ppp_pernet(struct net *net)
+{
+	BUG_ON(!net);
+
+	return net_generic(net, ppp_net_id);
+}
+
 /* Translates a PPP protocol number to a NP index (NP == network protocol) */
 static inline int proto_to_npindex(int proto)
 {
@@ -544,7 +567,8 @@ static long ppp_ioctl(struct file *file,
 	int __user *p = argp;
 
 	if (!pf)
-		return ppp_unattached_ioctl(pf, file, cmd, arg);
+		return ppp_unattached_ioctl(current->nsproxy->net_ns,
+					pf, file, cmd, arg);
 
 	if (cmd == PPPIOCDETACH) {
 		/*
@@ -763,12 +787,13 @@ static long ppp_ioctl(struct file *file,
 	return err;
 }
 
-static int ppp_unattached_ioctl(struct ppp_file *pf, struct file *file,
-				unsigned int cmd, unsigned long arg)
+static int ppp_unattached_ioctl(struct net *net, struct ppp_file *pf,
+			struct file *file, unsigned int cmd, unsigned long arg)
 {
 	int unit, err = -EFAULT;
 	struct ppp *ppp;
 	struct channel *chan;
+	struct ppp_net *pn;
 	int __user *p = (int __user *)arg;
 
 	lock_kernel();
@@ -777,7 +802,7 @@ static int ppp_unattached_ioctl(struct p
 		/* Create a new ppp unit */
 		if (get_user(unit, p))
 			break;
-		ppp = ppp_create_interface(unit, &err);
+		ppp = ppp_create_interface(net, unit, &err);
 		if (!ppp)
 			break;
 		file->private_data = &ppp->file;
@@ -792,29 +817,31 @@ static int ppp_unattached_ioctl(struct p
 		/* Attach to an existing ppp unit */
 		if (get_user(unit, p))
 			break;
-		mutex_lock(&all_ppp_mutex);
 		err = -ENXIO;
-		ppp = ppp_find_unit(unit);
+		pn = ppp_pernet(net);
+		mutex_lock(&pn->all_ppp_mutex);
+		ppp = ppp_find_unit(pn, unit);
 		if (ppp) {
 			atomic_inc(&ppp->file.refcnt);
 			file->private_data = &ppp->file;
 			err = 0;
 		}
-		mutex_unlock(&all_ppp_mutex);
+		mutex_unlock(&pn->all_ppp_mutex);
 		break;
 
 	case PPPIOCATTCHAN:
 		if (get_user(unit, p))
 			break;
-		spin_lock_bh(&all_channels_lock);
 		err = -ENXIO;
-		chan = ppp_find_channel(unit);
+		pn = ppp_pernet(net);
+		spin_lock_bh(&pn->all_channels_lock);
+		chan = ppp_find_channel(pn, unit);
 		if (chan) {
 			atomic_inc(&chan->file.refcnt);
 			file->private_data = &chan->file;
 			err = 0;
 		}
-		spin_unlock_bh(&all_channels_lock);
+		spin_unlock_bh(&pn->all_channels_lock);
 		break;
 
 	default:
@@ -834,6 +861,51 @@ static const struct file_operations ppp_
 	.release	= ppp_release
 };
 
+static __net_init int ppp_init_net(struct net *net)
+{
+	struct ppp_net *pn;
+	int err;
+
+	pn = kzalloc(sizeof(*pn), GFP_KERNEL);
+	if (!pn)
+		return -ENOMEM;
+
+	idr_init(&pn->units_idr);
+	mutex_init(&pn->all_ppp_mutex);
+
+	INIT_LIST_HEAD(&pn->all_channels);
+	INIT_LIST_HEAD(&pn->new_channels);
+
+	spin_lock_init(&pn->all_channels_lock);
+
+	err = net_assign_generic(net, ppp_net_id, pn);
+	if (err) {
+		kfree(pn);
+		return err;
+	}
+
+	return 0;
+}
+
+static __net_exit void ppp_exit_net(struct net *net)
+{
+	struct ppp_net *pn;
+
+	pn = net_generic(net, ppp_net_id);
+	idr_destroy(&pn->units_idr);
+	/*
+	 * if someone has cached our net then
+	 * further net_generic call will return NULL
+	 */
+	net_assign_generic(net, ppp_net_id, NULL);
+	kfree(pn);
+}
+
+static __net_initdata struct pernet_operations ppp_net_ops = {
+	.init = ppp_init_net,
+	.exit = ppp_exit_net,
+};
+
 #define PPP_MAJOR	108
 
 /* Called at boot time if ppp is compiled into the kernel,
@@ -843,25 +915,36 @@ static int __init ppp_init(void)
 	int err;
 
 	printk(KERN_INFO "PPP generic driver version " PPP_VERSION "\n");
-	err = register_chrdev(PPP_MAJOR, "ppp", &ppp_device_fops);
-	if (!err) {
-		ppp_class = class_create(THIS_MODULE, "ppp");
-		if (IS_ERR(ppp_class)) {
-			err = PTR_ERR(ppp_class);
-			goto out_chrdev;
-		}
-		device_create(ppp_class, NULL, MKDEV(PPP_MAJOR, 0), NULL,
-			      "ppp");
+
+	err = register_pernet_gen_device(&ppp_net_id, &ppp_net_ops);
+	if (err) {
+		printk(KERN_ERR "failed to register PPP pernet device (%d)\n", err);
+		goto out;
 	}
 
-out:
-	if (err)
+	err = register_chrdev(PPP_MAJOR, "ppp", &ppp_device_fops);
+	if (err) {
 		printk(KERN_ERR "failed to register PPP device (%d)\n", err);
-	return err;
+		goto out_net;
+	}
+
+	ppp_class = class_create(THIS_MODULE, "ppp");
+	if (IS_ERR(ppp_class)) {
+		err = PTR_ERR(ppp_class);
+		goto out_chrdev;
+	}
+
+	/* not a big deal if we fail here :-) */
+	device_create(ppp_class, NULL, MKDEV(PPP_MAJOR, 0), NULL, "ppp");
+
+	return 0;
 
 out_chrdev:
 	unregister_chrdev(PPP_MAJOR, "ppp");
-	goto out;
+out_net:
+	unregister_pernet_gen_device(ppp_net_id, &ppp_net_ops);
+out:
+	return err;
 }
 
 /*
@@ -969,6 +1052,7 @@ static void ppp_setup(struct net_device 
 	dev->tx_queue_len = 3;
 	dev->type = ARPHRD_PPP;
 	dev->flags = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+	dev->features |= NETIF_F_NETNS_LOCAL;
 }
 
 /*
@@ -1986,19 +2070,27 @@ ppp_mp_reconstruct(struct ppp *ppp)
  * Channel interface.
  */
 
-/*
- * Create a new, unattached ppp channel.
- */
-int
-ppp_register_channel(struct ppp_channel *chan)
+/* Create a new, unattached ppp channel. */
+int ppp_register_channel(struct ppp_channel *chan)
+{
+	return ppp_register_net_channel(current->nsproxy->net_ns, chan);
+}
+
+/* Create a new, unattached ppp channel for specified net. */
+int ppp_register_net_channel(struct net *net, struct ppp_channel *chan)
 {
 	struct channel *pch;
+	struct ppp_net *pn;
 
 	pch = kzalloc(sizeof(struct channel), GFP_KERNEL);
 	if (!pch)
 		return -ENOMEM;
+
+	pn = ppp_pernet(net);
+
 	pch->ppp = NULL;
 	pch->chan = chan;
+	pch->chan_net = net;
 	chan->ppp = pch;
 	init_ppp_file(&pch->file, CHANNEL);
 	pch->file.hdrlen = chan->hdrlen;
@@ -2008,11 +2100,13 @@ ppp_register_channel(struct ppp_channel 
 	init_rwsem(&pch->chan_sem);
 	spin_lock_init(&pch->downl);
 	rwlock_init(&pch->upl);
-	spin_lock_bh(&all_channels_lock);
-	pch->file.index = ++last_channel_index;
-	list_add(&pch->list, &new_channels);
+
+	spin_lock_bh(&pn->all_channels_lock);
+	pch->file.index = ++pn->last_channel_index;
+	list_add(&pch->list, &pn->new_channels);
 	atomic_inc(&channel_count);
-	spin_unlock_bh(&all_channels_lock);
+	spin_unlock_bh(&pn->all_channels_lock);
+
 	return 0;
 }
 
@@ -2053,9 +2147,11 @@ void
 ppp_unregister_channel(struct ppp_channel *chan)
 {
 	struct channel *pch = chan->ppp;
+	struct ppp_net *pn;
 
 	if (!pch)
 		return;		/* should never happen */
+
 	chan->ppp = NULL;
 
 	/*
@@ -2068,9 +2164,12 @@ ppp_unregister_channel(struct ppp_channe
 	spin_unlock_bh(&pch->downl);
 	up_write(&pch->chan_sem);
 	ppp_disconnect_channel(pch);
-	spin_lock_bh(&all_channels_lock);
+
+	pn = ppp_pernet(pch->chan_net);
+	spin_lock_bh(&pn->all_channels_lock);
 	list_del(&pch->list);
-	spin_unlock_bh(&all_channels_lock);
+	spin_unlock_bh(&pn->all_channels_lock);
+
 	pch->file.dead = 1;
 	wake_up_interruptible(&pch->file.rwait);
 	if (atomic_dec_and_test(&pch->file.refcnt))
@@ -2395,9 +2494,10 @@ ppp_get_stats(struct ppp *ppp, struct pp
  * unit == -1 means allocate a new number.
  */
 static struct ppp *
-ppp_create_interface(int unit, int *retp)
+ppp_create_interface(struct net *net, int unit, int *retp)
 {
 	struct ppp *ppp;
+	struct ppp_net *pn;
 	struct net_device *dev = NULL;
 	int ret = -ENOMEM;
 	int i;
@@ -2406,6 +2506,8 @@ ppp_create_interface(int unit, int *retp
 	if (!dev)
 		goto out1;
 
+	pn = ppp_pernet(net);
+
 	ppp = netdev_priv(dev);
 	ppp->dev = dev;
 	ppp->mru = PPP_MRU;
@@ -2421,17 +2523,23 @@ ppp_create_interface(int unit, int *retp
 	skb_queue_head_init(&ppp->mrq);
 #endif /* CONFIG_PPP_MULTILINK */
 
+	/*
+	 * drum roll: don't forget to set
+	 * the net device is belong to
+	 */
+	dev_net_set(dev, net);
+
 	ret = -EEXIST;
-	mutex_lock(&all_ppp_mutex);
+	mutex_lock(&pn->all_ppp_mutex);
 
 	if (unit < 0) {
-		unit = unit_get(&ppp_units_idr, ppp);
+		unit = unit_get(&pn->units_idr, ppp);
 		if (unit < 0) {
 			*retp = unit;
 			goto out2;
 		}
 	} else {
-		if (unit_find(&ppp_units_idr, unit))
+		if (unit_find(&pn->units_idr, unit))
 			goto out2; /* unit already exists */
 		/*
 		 * if caller need a specified unit number
@@ -2442,7 +2550,7 @@ ppp_create_interface(int unit, int *retp
 		 * fair but at least pppd will ask us to allocate
 		 * new unit in this case so user is happy :)
 		 */
-		unit = unit_set(&ppp_units_idr, ppp, unit);
+		unit = unit_set(&pn->units_idr, ppp, unit);
 		if (unit < 0)
 			goto out2;
 	}
@@ -2453,20 +2561,22 @@ ppp_create_interface(int unit, int *retp
 
 	ret = register_netdev(dev);
 	if (ret != 0) {
-		unit_put(&ppp_units_idr, unit);
+		unit_put(&pn->units_idr, unit);
 		printk(KERN_ERR "PPP: couldn't register device %s (%d)\n",
 		       dev->name, ret);
 		goto out2;
 	}
 
+	ppp->ppp_net = net;
+
 	atomic_inc(&ppp_unit_count);
-	mutex_unlock(&all_ppp_mutex);
+	mutex_unlock(&pn->all_ppp_mutex);
 
 	*retp = 0;
 	return ppp;
 
 out2:
-	mutex_unlock(&all_ppp_mutex);
+	mutex_unlock(&pn->all_ppp_mutex);
 	free_netdev(dev);
 out1:
 	*retp = ret;
@@ -2492,7 +2602,11 @@ init_ppp_file(struct ppp_file *pf, int k
  */
 static void ppp_shutdown_interface(struct ppp *ppp)
 {
-	mutex_lock(&all_ppp_mutex);
+	struct ppp_net *pn;
+
+	pn = ppp_pernet(ppp->ppp_net);
+	mutex_lock(&pn->all_ppp_mutex);
+
 	/* This will call dev_close() for us. */
 	ppp_lock(ppp);
 	if (!ppp->closing) {
@@ -2502,11 +2616,12 @@ static void ppp_shutdown_interface(struc
 	} else
 		ppp_unlock(ppp);
 
-	unit_put(&ppp_units_idr, ppp->file.index);
+	unit_put(&pn->units_idr, ppp->file.index);
 	ppp->file.dead = 1;
 	ppp->owner = NULL;
 	wake_up_interruptible(&ppp->file.rwait);
-	mutex_unlock(&all_ppp_mutex);
+
+	mutex_unlock(&pn->all_ppp_mutex);
 }
 
 /*
@@ -2554,9 +2669,9 @@ static void ppp_destroy_interface(struct
  * The caller should have locked the all_ppp_mutex.
  */
 static struct ppp *
-ppp_find_unit(int unit)
+ppp_find_unit(struct ppp_net *pn, int unit)
 {
-	return unit_find(&ppp_units_idr, unit);
+	return unit_find(&pn->units_idr, unit);
 }
 
 /*
@@ -2568,20 +2683,22 @@ ppp_find_unit(int unit)
  * when we have a lot of channels in use.
  */
 static struct channel *
-ppp_find_channel(int unit)
+ppp_find_channel(struct ppp_net *pn, int unit)
 {
 	struct channel *pch;
 
-	list_for_each_entry(pch, &new_channels, list) {
+	list_for_each_entry(pch, &pn->new_channels, list) {
 		if (pch->file.index == unit) {
-			list_move(&pch->list, &all_channels);
+			list_move(&pch->list, &pn->all_channels);
 			return pch;
 		}
 	}
-	list_for_each_entry(pch, &all_channels, list) {
+
+	list_for_each_entry(pch, &pn->all_channels, list) {
 		if (pch->file.index == unit)
 			return pch;
 	}
+
 	return NULL;
 }
 
@@ -2592,11 +2709,14 @@ static int
 ppp_connect_channel(struct channel *pch, int unit)
 {
 	struct ppp *ppp;
+	struct ppp_net *pn;
 	int ret = -ENXIO;
 	int hdrlen;
 
-	mutex_lock(&all_ppp_mutex);
-	ppp = ppp_find_unit(unit);
+	pn = ppp_pernet(pch->chan_net);
+
+	mutex_lock(&pn->all_ppp_mutex);
+	ppp = ppp_find_unit(pn, unit);
 	if (!ppp)
 		goto out;
 	write_lock_bh(&pch->upl);
@@ -2620,7 +2740,7 @@ ppp_connect_channel(struct channel *pch,
  outl:
 	write_unlock_bh(&pch->upl);
  out:
-	mutex_unlock(&all_ppp_mutex);
+	mutex_unlock(&pn->all_ppp_mutex);
 	return ret;
 }
 
@@ -2677,7 +2797,7 @@ static void __exit ppp_cleanup(void)
 	unregister_chrdev(PPP_MAJOR, "ppp");
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
-	idr_destroy(&ppp_units_idr);
+	unregister_pernet_gen_device(ppp_net_id, &ppp_net_ops);
 }
 
 /*
@@ -2743,6 +2863,7 @@ static void *unit_find(struct idr *p, in
 module_init(ppp_init);
 module_exit(ppp_cleanup);
 
+EXPORT_SYMBOL(ppp_register_net_channel);
 EXPORT_SYMBOL(ppp_register_channel);
 EXPORT_SYMBOL(ppp_unregister_channel);
 EXPORT_SYMBOL(ppp_channel_index);
Index: linux-2.6.git/include/linux/ppp_channel.h
===================================================================
--- linux-2.6.git.orig/include/linux/ppp_channel.h
+++ linux-2.6.git/include/linux/ppp_channel.h
@@ -22,6 +22,7 @@
 #include <linux/list.h>
 #include <linux/skbuff.h>
 #include <linux/poll.h>
+#include <net/net_namespace.h>
 
 struct ppp_channel;
 
@@ -56,6 +57,9 @@ extern void ppp_input(struct ppp_channel
    that we may have missed a packet. */
 extern void ppp_input_error(struct ppp_channel *, int code);
 
+/* Attach a channel to a given PPP unit in specified net. */
+extern int ppp_register_net_channel(struct net *, struct ppp_channel *);
+
 /* Attach a channel to a given PPP unit. */
 extern int ppp_register_channel(struct ppp_channel *);
 

-- 

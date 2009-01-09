From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [RFC 4/4] net: ppp_generic - introduce net-namespace functionality
Date: Fri, 09 Jan 2009 22:51:58 +0300
Message-ID: <4967accd.0305560a.3553.ffffd187@mx.google.com>
References: <20090109195154.320495476@gmail.com>>
Cc: gorcunov@gmail.com, devel@openvz.org, xemul@openvz.org,
	Paul Mackerras <paulus@samba.org>,
	Cyrill Gorcunov <gorcunov@openvz.org>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:24240 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755330AbZAIUAQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 15:00:16 -0500
Content-Disposition: inline; filename=net-ppp-generic-namespace
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Each namespace contain ppp channels and units separately
  with appropriate locks

CC: Paul Mackerras <paulus@samba.org>
Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
---
 drivers/net/ppp_generic.c |  242 +++++++++++++++++++++++++++++++++-------------
 1 file changed, 175 insertions(+), 67 deletions(-)

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
@@ -89,6 +93,8 @@ struct ppp_file {
 #define PF_TO_PPP(pf)		PF_TO_X(pf, struct ppp)
 #define PF_TO_CHANNEL(pf)	PF_TO_X(pf, struct channel)
 
+struct ppp_net;
+
 /*
  * Data structure describing one ppp unit.
  * A ppp unit corresponds to a ppp network interface device
@@ -131,6 +137,7 @@ struct ppp {
 	struct sock_filter *active_filter;/* filter for pkts to reset idle */
 	unsigned pass_len, active_len;
 #endif /* CONFIG_PPP_FILTER */
+	struct net	*ppp_net;	/* the net we belong to */
 };
 
 /*
@@ -173,25 +180,36 @@ struct channel {
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
+static atomic_t channel_count = ATOMIC_INIT(0);
 
 /*
- * all_channels_lock protects all_channels and last_channel_index,
- * and the atomicity of find a channel and updating its file.refcnt
- * field.
+ * per net-namespace data for this module
  */
-static DEFINE_SPINLOCK(all_channels_lock);
-static LIST_HEAD(all_channels);
-static LIST_HEAD(new_channels);
-static int last_channel_index;
-static atomic_t channel_count = ATOMIC_INIT(0);
+static unsigned int ppp_net_id;
+struct ppp_net {
+	/* units to ppp mapping */
+	struct idr units_idr;
+
+	/* channels */
+	struct list_head all_channels;
+	struct list_head new_channels;
+	int last_channel_index;
+
+	/*
+	 * all_ppp_mutex protects the units_idr mapping.
+	 * It also ensures that finding a ppp unit in the units_idr
+	 * map and updating its file.refcnt field is atomic.
+	 */
+	struct mutex all_ppp_mutex;
+
+	/*
+	 * all_channels_lock protects all_channels and
+	 * last_channel_index, and the atomicity of find
+	 * a channel and updating its file.refcnt field.
+	 */
+	spinlock_t all_channels_lock;
+};
 
 /* Get the PPP protocol number from a skb */
 #define PPP_PROTO(skb)	(((skb)->data[0] << 8) + (skb)->data[1])
@@ -240,21 +258,28 @@ static void ppp_ccp_peek(struct ppp *ppp
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
+static struct channel *ppp_find_channel(struct net *net, int unit);
 static int ppp_connect_channel(struct channel *pch, int unit);
 static int ppp_disconnect_channel(struct channel *pch);
 static void ppp_destroy_channel(struct channel *pch);
-static int unit_get(struct idr *p, void *ptr);
-static void unit_put(struct idr *p, int n);
-static void *unit_find(struct idr *p, int n);
+static int unit_get(struct net *net, void *ptr);
+static void unit_put(struct net *net, int n);
+static void *unit_find(struct net *net, int n);
 
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
@@ -343,6 +368,7 @@ static int ppp_open(struct inode *inode,
 	 */
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
+
 	return 0;
 }
 
@@ -768,6 +794,7 @@ static int ppp_unattached_ioctl(struct p
 	int unit, err = -EFAULT;
 	struct ppp *ppp;
 	struct channel *chan;
+	struct ppp_net *pn;
 	int __user *p = (int __user *)arg;
 
 	lock_kernel();
@@ -776,7 +803,7 @@ static int ppp_unattached_ioctl(struct p
 		/* Create a new ppp unit */
 		if (get_user(unit, p))
 			break;
-		ppp = ppp_create_interface(unit, &err);
+		ppp = ppp_create_interface(current->nsproxy->net_ns, unit, &err);
 		if (!ppp)
 			break;
 		file->private_data = &ppp->file;
@@ -791,29 +818,31 @@ static int ppp_unattached_ioctl(struct p
 		/* Attach to an existing ppp unit */
 		if (get_user(unit, p))
 			break;
-		mutex_lock(&all_ppp_mutex);
+		pn = ppp_pernet(current->nsproxy->net_ns);
+		mutex_lock(&pn->all_ppp_mutex);
 		err = -ENXIO;
-		ppp = ppp_find_unit(unit);
+		ppp = unit_find(current->nsproxy->net_ns, unit);
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
+		pn = ppp_pernet(current->nsproxy->net_ns);
+		spin_lock_bh(&pn->all_channels_lock);
 		err = -ENXIO;
-		chan = ppp_find_channel(unit);
+		chan = ppp_find_channel(current->nsproxy->net_ns, unit);
 		if (chan) {
 			atomic_inc(&chan->file.refcnt);
 			file->private_data = &chan->file;
 			err = 0;
 		}
-		spin_unlock_bh(&all_channels_lock);
+		spin_unlock_bh(&pn->all_channels_lock);
 		break;
 
 	default:
@@ -833,6 +862,54 @@ static const struct file_operations ppp_
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
+
+	INIT_LIST_HEAD(&pn->all_channels);
+	INIT_LIST_HEAD(&pn->new_channels);
+
+	mutex_init(&pn->all_ppp_mutex);
+	spin_lock_init(&pn->all_channels_lock);
+
+	err = net_assign_generic(net, ppp_net_id, pn);
+	if (err) {
+		kfree(pn);
+		return err;
+	}
+
+	try_module_get(THIS_MODULE);
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
+
+	module_put(THIS_MODULE);
+}
+
+static __net_initdata struct pernet_operations ppp_net_ops = {
+	.init = ppp_init_net,
+	.exit = ppp_exit_net,
+};
+
 #define PPP_MAJOR	108
 
 /* Called at boot time if ppp is compiled into the kernel,
@@ -1992,10 +2069,14 @@ int
 ppp_register_channel(struct ppp_channel *chan)
 {
 	struct channel *pch;
+	struct ppp_net *pn;
 
 	pch = kzalloc(sizeof(struct channel), GFP_KERNEL);
 	if (!pch)
 		return -ENOMEM;
+
+	pn = ppp_pernet(current->nsproxy->net_ns);
+
 	pch->ppp = NULL;
 	pch->chan = chan;
 	chan->ppp = pch;
@@ -2007,11 +2088,11 @@ ppp_register_channel(struct ppp_channel 
 	init_rwsem(&pch->chan_sem);
 	spin_lock_init(&pch->downl);
 	rwlock_init(&pch->upl);
-	spin_lock_bh(&all_channels_lock);
-	pch->file.index = ++last_channel_index;
-	list_add(&pch->list, &new_channels);
+	spin_lock_bh(&pn->all_channels_lock);
+	pch->file.index = ++pn->last_channel_index;
+	list_add(&pch->list, &pn->new_channels);
 	atomic_inc(&channel_count);
-	spin_unlock_bh(&all_channels_lock);
+	spin_unlock_bh(&pn->all_channels_lock);
 	return 0;
 }
 
@@ -2052,11 +2133,17 @@ void
 ppp_unregister_channel(struct ppp_channel *chan)
 {
 	struct channel *pch = chan->ppp;
+	struct ppp_net *pn;
 
 	if (!pch)
 		return;		/* should never happen */
 	chan->ppp = NULL;
 
+	if (pch->ppp->ppp_net)
+		pn = ppp_pernet(pch->ppp->ppp_net);
+	else
+		pn = ppp_pernet(current->nsproxy->net_ns);
+
 	/*
 	 * This ensures that we have returned from any calls into the
 	 * the channel's start_xmit or ioctl routine before we proceed.
@@ -2067,9 +2154,9 @@ ppp_unregister_channel(struct ppp_channe
 	spin_unlock_bh(&pch->downl);
 	up_write(&pch->chan_sem);
 	ppp_disconnect_channel(pch);
-	spin_lock_bh(&all_channels_lock);
+	spin_lock_bh(&pn->all_channels_lock);
 	list_del(&pch->list);
-	spin_unlock_bh(&all_channels_lock);
+	spin_unlock_bh(&pn->all_channels_lock);
 	pch->file.dead = 1;
 	wake_up_interruptible(&pch->file.rwait);
 	if (atomic_dec_and_test(&pch->file.refcnt))
@@ -2394,10 +2481,11 @@ ppp_get_stats(struct ppp *ppp, struct pp
  * unit == -1 means allocate a new number.
  */
 static struct ppp *
-ppp_create_interface(int unit, int *retp)
+ppp_create_interface(struct net *net, int unit, int *retp)
 {
 	struct ppp *ppp;
-	struct net_device *dev = NULL;
+	struct net_device *dev;
+	struct ppp_net *pn;
 	int ret = -ENOMEM;
 	int i;
 
@@ -2408,6 +2496,7 @@ ppp_create_interface(int unit, int *retp
 	ppp = netdev_priv(dev);
 	ppp->dev = dev;
 	ppp->mru = PPP_MRU;
+	ppp->ppp_net = net;
 	init_ppp_file(&ppp->file, INTERFACE);
 	ppp->file.hdrlen = PPP_HDRLEN - 2;	/* don't count proto bytes */
 	for (i = 0; i < NUM_NP; ++i)
@@ -2421,19 +2510,21 @@ ppp_create_interface(int unit, int *retp
 #endif /* CONFIG_PPP_MULTILINK */
 
 	ret = -EEXIST;
-	mutex_lock(&all_ppp_mutex);
+
+	pn = ppp_pernet(net);
+	mutex_lock(&pn->all_ppp_mutex);
 
 	if (unit < 0) {
-		unit = unit_get(&ppp_units_idr, ppp);
+		unit = unit_get(net, ppp);
 		if (unit < 0) {
 			*retp = unit;
 			goto out2;
 		}
 	} else {
-		if (unit_find(&ppp_units_idr, unit))
+		if (unit_find(net, unit))
 			goto out2; /* unit already exists */
 		else {
-			/* darn, someone is cheating us? */
+			/* darn, someone is cheatting us? */
 			*retp = -EINVAL;
 			goto out2;
 		}
@@ -2445,20 +2536,20 @@ ppp_create_interface(int unit, int *retp
 
 	ret = register_netdev(dev);
 	if (ret != 0) {
-		unit_put(&ppp_units_idr, unit);
+		unit_put(net, unit);
 		printk(KERN_ERR "PPP: couldn't register device %s (%d)\n",
 		       dev->name, ret);
 		goto out2;
 	}
 
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
@@ -2484,7 +2575,9 @@ init_ppp_file(struct ppp_file *pf, int k
  */
 static void ppp_shutdown_interface(struct ppp *ppp)
 {
-	mutex_lock(&all_ppp_mutex);
+	struct ppp_net *pn = ppp_pernet(ppp->ppp_net);
+
+	mutex_lock(&pn->all_ppp_mutex);
 	/* This will call dev_close() for us. */
 	ppp_lock(ppp);
 	if (!ppp->closing) {
@@ -2494,11 +2587,11 @@ static void ppp_shutdown_interface(struc
 	} else
 		ppp_unlock(ppp);
 
-	unit_put(&ppp_units_idr, ppp->file.index);
+	unit_put(ppp->ppp_net, ppp->file.index);
 	ppp->file.dead = 1;
 	ppp->owner = NULL;
 	wake_up_interruptible(&ppp->file.rwait);
-	mutex_unlock(&all_ppp_mutex);
+	mutex_unlock(&pn->all_ppp_mutex);
 }
 
 /*
@@ -2542,16 +2635,6 @@ static void ppp_destroy_interface(struct
 }
 
 /*
- * Locate an existing ppp unit.
- * The caller should have locked the all_ppp_mutex.
- */
-static struct ppp *
-ppp_find_unit(int unit)
-{
-	return unit_find(&ppp_units_idr, unit);
-}
-
-/*
  * Locate an existing ppp channel.
  * The caller should have locked the all_channels_lock.
  * First we look in the new_channels list, then in the
@@ -2560,20 +2643,25 @@ ppp_find_unit(int unit)
  * when we have a lot of channels in use.
  */
 static struct channel *
-ppp_find_channel(int unit)
+ppp_find_channel(struct net *net, int unit)
 {
 	struct channel *pch;
+	struct ppp_net *pn;
 
-	list_for_each_entry(pch, &new_channels, list) {
+	pn = ppp_pernet(net);
+
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
 
@@ -2584,11 +2672,14 @@ static int
 ppp_connect_channel(struct channel *pch, int unit)
 {
 	struct ppp *ppp;
+	struct ppp_net *pn;
 	int ret = -ENXIO;
 	int hdrlen;
 
-	mutex_lock(&all_ppp_mutex);
-	ppp = ppp_find_unit(unit);
+	pn = ppp_pernet(current->nsproxy->net_ns);
+
+	mutex_lock(&pn->all_ppp_mutex);
+	ppp = unit_find(current->nsproxy->net_ns, unit);
 	if (!ppp)
 		goto out;
 	write_lock_bh(&pch->upl);
@@ -2612,7 +2703,7 @@ ppp_connect_channel(struct channel *pch,
  outl:
 	write_unlock_bh(&pch->upl);
  out:
-	mutex_unlock(&all_ppp_mutex);
+	mutex_unlock(&pn->all_ppp_mutex);
 	return ret;
 }
 
@@ -2669,7 +2760,7 @@ static void __exit ppp_cleanup(void)
 	unregister_chrdev(PPP_MAJOR, "ppp");
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
-	idr_destroy(&ppp_units_idr);
+	unregister_pernet_gen_device(ppp_net_id, &ppp_net_ops);
 }
 
 /*
@@ -2678,9 +2769,14 @@ static void __exit ppp_cleanup(void)
  */
 
 /* get new free unit number and associate pointer with it */
-static int unit_get(struct idr *p, void *ptr)
+static int unit_get(struct net *net, void *ptr)
 {
 	int unit, err;
+	struct ppp_net *pn;
+	struct idr *p;
+
+	pn = ppp_pernet(net);
+	p = &pn->units_idr;
 
 again:
 	if (idr_pre_get(p, GFP_KERNEL) == 0) {
@@ -2696,14 +2792,26 @@ again:
 }
 
 /* put unit number back to a pool */
-static void unit_put(struct idr *p, int n)
+static void unit_put(struct net *net, int n)
 {
+	struct ppp_net *pn;
+	struct idr *p;
+
+	pn = ppp_pernet(net);
+	p = &pn->units_idr;
+
 	idr_remove(p, n);
 }
 
 /* get pointer associated with the number */
-static void *unit_find(struct idr *p, int n)
+static void *unit_find(struct net *net, int n)
 {
+	struct ppp_net *pn;
+	struct idr *p;
+
+	pn = ppp_pernet(net);
+	p = &pn->units_idr;
+
 	return idr_find(p, n);
 }
 

-- 

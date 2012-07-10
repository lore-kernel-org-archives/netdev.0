From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [RFC PATCH v2 net-next] Re: [RFC PATCH] ppp: add support for L2 multihop / tunnel switching
Date: Mon, 9 Jul 2012 23:27:10 -0400
Message-ID: <20120710032710.GQ19462@kvack.org>
References: <20120708214930.GI19462@kvack.org> <4FFAC5EF.6030003@katalix.com> <20120709141511.GL19462@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-ppp@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:35625 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753075Ab2GJD1N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Jul 2012 23:27:13 -0400
Content-Disposition: inline
In-Reply-To: <20120709141511.GL19462@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello all,

Here is v2 of the PPP multihop patch.  This version adds a notifier hook to 
make sure that the multihop reference is dropped when the multihop target 
gets unregistered, ensuring that the references are properly dropped witout 
leaking the devices.

		-ben

Not-yet-signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
 drivers/net/ppp/ppp_generic.c |  119 ++++++++++++++++++++++++++++++++++++++++--
 include/linux/if_ether.h      |    1 
 include/linux/ppp-ioctl.h     |    1 
 3 files changed, 118 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 5c05572..6dc7eff 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -121,6 +121,7 @@ struct ppp {
 	unsigned long	last_xmit;	/* jiffies when last pkt sent 9c */
 	unsigned long	last_recv;	/* jiffies when last pkt rcvd a0 */
 	struct net_device *dev;		/* network interface device a4 */
+	struct net_device *multihop_if;	/* if to forward incoming frames to */
 	int		closing;	/* is device closing down? a8 */
 #ifdef CONFIG_PPP_MULTILINK
 	int		nxchan;		/* next channel to send something on */
@@ -272,6 +273,7 @@ static void unit_put(struct idr *p, int n);
 static void *unit_find(struct idr *p, int n);
 
 static struct class *ppp_class;
+static const struct net_device_ops ppp_netdev_ops;
 
 /* per net-namespace data */
 static inline struct ppp_net *ppp_pernet(struct net *net)
@@ -380,8 +382,9 @@ static int ppp_release(struct inode *unused, struct file *file)
 		file->private_data = NULL;
 		if (pf->kind == INTERFACE) {
 			ppp = PF_TO_PPP(pf);
-			if (file == ppp->owner)
+			if (file == ppp->owner) {
 				ppp_shutdown_interface(ppp);
+			}
 		}
 		if (atomic_dec_and_test(&pf->refcnt)) {
 			switch (pf->kind) {
@@ -553,6 +556,41 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 }
 #endif /* CONFIG_PPP_FILTER */
 
+static int ppp_multihop_event(struct notifier_block *this, unsigned long event,
+			      void *ptr)
+{
+	struct net_device *event_dev = (struct net_device *)ptr;
+	struct net_device *master = event_dev->master;
+	struct ppp *ppp;
+
+	if (event_dev->netdev_ops != &ppp_netdev_ops)
+		return NOTIFY_DONE;
+	if (!master || (master->netdev_ops != &ppp_netdev_ops))
+		return NOTIFY_DONE;
+
+	ppp = netdev_priv(master);
+
+	switch (event) {
+	case NETDEV_UNREGISTER:
+		ppp_lock(ppp);
+		BUG_ON(ppp->multihop_if != event_dev);
+		ppp->multihop_if = NULL;
+		netdev_set_master(event_dev, NULL);
+		ppp_unlock(ppp);
+		dev_put(event_dev);
+		break;
+
+	default:
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block ppp_multihop_notifier = {
+	.notifier_call = ppp_multihop_event,
+};
+
 static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 {
 	struct ppp_file *pf = file->private_data;
@@ -738,6 +776,46 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 		err = 0;
 		break;
 
+	case PPPIOCSMULTIHOP_IF:
+	{
+		struct net_device *multihop_if;
+		if (get_user(val, p))
+			break;
+		rtnl_lock();
+		ppp_lock(ppp);
+		err = 0;
+		multihop_if = ppp->multihop_if;
+		if (multihop_if && (val == -1)) {
+			ppp->multihop_if = NULL;
+			BUG_ON(multihop_if->master != ppp->dev);
+			netdev_set_master(multihop_if, NULL);
+			goto out_multihop;
+		}
+		err = -EBUSY;
+		multihop_if = NULL;
+		if (ppp->multihop_if)
+			goto out_multihop;
+		multihop_if = dev_get_by_index(&init_net, val);
+		err = -ENOENT;
+		if (!multihop_if)
+			goto out_multihop;
+		err = -EINVAL;
+		if (multihop_if->netdev_ops != &ppp_netdev_ops)
+			goto out_multihop;
+		err = netdev_set_master(multihop_if, ppp->dev);
+		if (err)
+			goto out_multihop;
+		ppp->multihop_if = multihop_if;
+		multihop_if = NULL;
+		err = 0;
+out_multihop:
+		ppp_unlock(ppp);
+		rtnl_unlock();
+		if (multihop_if)
+			dev_put(multihop_if);
+		break;
+	}
+
 #ifdef CONFIG_PPP_FILTER
 	case PPPIOCSPASS:
 	{
@@ -901,6 +979,7 @@ static int __init ppp_init(void)
 
 	pr_info("PPP generic driver version " PPP_VERSION "\n");
 
+	register_netdevice_notifier(&ppp_multihop_notifier);
 	err = register_pernet_device(&ppp_net_ops);
 	if (err) {
 		pr_err("failed to register PPP pernet device (%d)\n", err);
@@ -942,6 +1021,9 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	int npi, proto;
 	unsigned char *pp;
 
+	if (skb->protocol == htons(ETH_P_PPP))
+		goto queue;
+
 	npi = ethertype_to_npindex(ntohs(skb->protocol));
 	if (npi < 0)
 		goto outf;
@@ -968,6 +1050,7 @@ ppp_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	proto = npindex_to_proto[npi];
 	put_unaligned_be16(proto, pp);
 
+queue:
 	skb_queue_tail(&ppp->file.xq, skb);
 	ppp_xmit_process(ppp);
 	return NETDEV_TX_OK;
@@ -1131,6 +1214,9 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 	int len;
 	unsigned char *cp;
 
+	if (skb->protocol == htons(ETH_P_PPP))
+		goto xmit;
+
 	if (proto < 0x8000) {
 #ifdef CONFIG_PPP_FILTER
 		/* check if we should pass this packet */
@@ -1228,6 +1314,7 @@ ppp_send_frame(struct ppp *ppp, struct sk_buff *skb)
 		return;
 	}
 
+xmit:
 	ppp->xmit_pending = skb;
 	ppp_push(ppp);
 	return;
@@ -1259,7 +1346,8 @@ ppp_push(struct ppp *ppp)
 		return;
 	}
 
-	if ((ppp->flags & SC_MULTILINK) == 0) {
+	if (((ppp->flags & SC_MULTILINK) == 0) ||
+	    (skb->protocol == htons(ETH_P_PPP))) {
 		/* not doing multilink: send it down the first channel */
 		list = list->next;
 		pch = list_entry(list, struct channel, clist);
@@ -1599,6 +1687,14 @@ ppp_input(struct ppp_channel *chan, struct sk_buff *skb)
 		goto done;
 	}
 
+	if (pch->ppp && pch->ppp->multihop_if) {
+		skb->protocol = htons(ETH_P_PPP);
+		skb->dev = pch->ppp->multihop_if;
+		skb->ip_summed = CHECKSUM_NONE;
+		dev_queue_xmit(skb);
+		goto done;
+	}
+
 	proto = PPP_PROTO(skb);
 	if (!pch->ppp || proto >= 0xc000 || proto == PPP_CCPFRAG) {
 		/* put it on the channel queue */
@@ -2709,18 +2805,28 @@ static void ppp_shutdown_interface(struct ppp *ppp)
 {
 	struct ppp_net *pn;
 
+	rtnl_lock();
 	pn = ppp_pernet(ppp->ppp_net);
 	mutex_lock(&pn->all_ppp_mutex);
 
 	/* This will call dev_close() for us. */
 	ppp_lock(ppp);
 	if (!ppp->closing) {
+		struct net_device *multihop_if = ppp->multihop_if;
 		ppp->closing = 1;
+		ppp->multihop_if = NULL;
 		ppp_unlock(ppp);
+		if (multihop_if)
+			netdev_set_master(multihop_if, NULL);
+		rtnl_unlock();
 		unregister_netdev(ppp->dev);
 		unit_put(&pn->units_idr, ppp->file.index);
-	} else
+		if (multihop_if)
+			dev_put(multihop_if);
+	} else {
 		ppp_unlock(ppp);
+		rtnl_unlock();
+	}
 
 	ppp->file.dead = 1;
 	ppp->owner = NULL;
@@ -2764,6 +2870,12 @@ static void ppp_destroy_interface(struct ppp *ppp)
 #endif /* CONFIG_PPP_FILTER */
 
 	kfree_skb(ppp->xmit_pending);
+	if (ppp->multihop_if) {
+		struct net_device *multihop_if = ppp->multihop_if;
+		ppp->multihop_if = NULL;
+		netdev_set_master(multihop_if, NULL);
+		dev_put(multihop_if);
+	}
 
 	free_netdev(ppp->dev);
 }
@@ -2901,6 +3013,7 @@ static void __exit ppp_cleanup(void)
 	device_destroy(ppp_class, MKDEV(PPP_MAJOR, 0));
 	class_destroy(ppp_class);
 	unregister_pernet_device(&ppp_net_ops);
+	unregister_netdevice_notifier(&ppp_multihop_notifier);
 }
 
 /*
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 167ce5b..fe47a70 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -120,6 +120,7 @@
 #define ETH_P_PHONET	0x00F5		/* Nokia Phonet frames          */
 #define ETH_P_IEEE802154 0x00F6		/* IEEE802.15.4 frame		*/
 #define ETH_P_CAIF	0x00F7		/* ST-Ericsson CAIF protocol	*/
+#define ETH_P_PPP	0x00F8		/* Dummy type for PPP multihop	*/
 
 /*
  *	This is an Ethernet frame header.
diff --git a/include/linux/ppp-ioctl.h b/include/linux/ppp-ioctl.h
index 2d9a885..5571375 100644
--- a/include/linux/ppp-ioctl.h
+++ b/include/linux/ppp-ioctl.h
@@ -81,6 +81,7 @@ struct pppol2tp_ioc_stats {
  * Ioctl definitions.
  */
 
+#define	PPPIOCSMULTIHOP_IF	_IOWR('t', 91, int) /* set multihop if */
 #define	PPPIOCGFLAGS	_IOR('t', 90, int)	/* get configuration flags */
 #define	PPPIOCSFLAGS	_IOW('t', 89, int)	/* set configuration flags */
 #define	PPPIOCGASYNCMAP	_IOR('t', 88, int)	/* get async map */

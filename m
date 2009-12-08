From: Joe Perches <joe@perches.com>
Subject: [PATCH 01/20] net/atm: Convert printk to pr_<level>
Date: Mon,  7 Dec 2009 21:56:57 -0800
Message-ID: <ad18b13cc88db7b8aecdc08f1efd776305fad8a9.1260251570.git.joe@perches.com>
References: <cover.1260251570.git.joe@perches.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1039 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932358AbZLHF5L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2009 00:57:11 -0500
In-Reply-To: <cover.1260251570.git.joe@perches.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add #define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
Remove function names from output
Use single line pr_debug instead of broken multiple uses without newline

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/atm/br2684.c    |   18 +++---
 net/atm/clip.c      |   60 ++++++++--------
 net/atm/common.c    |   52 ++++++++------
 net/atm/ioctl.c     |    7 +-
 net/atm/lec.c       |  192 ++++++++++++++++++++++-----------------------------
 net/atm/mpc.c       |    4 +-
 net/atm/mpoa_proc.c |    3 +-
 net/atm/pppoatm.c   |   17 +++--
 net/atm/raw.c       |    5 +-
 net/atm/resources.c |   12 +--
 net/atm/signaling.c |   19 +++---
 net/atm/svc.c       |   13 ++--
 12 files changed, 190 insertions(+), 212 deletions(-)

diff --git a/net/atm/br2684.c b/net/atm/br2684.c
index 26a646d..188addf 100644
--- a/net/atm/br2684.c
+++ b/net/atm/br2684.c
@@ -6,6 +6,8 @@
  *          Eric Kinzie, 2006-2007, US Naval Research Laboratory
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/kernel.h>
@@ -148,7 +150,7 @@ static void br2684_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct br2684_vcc *brvcc = BR2684_VCC(vcc);
 	struct net_device *net_dev = skb->dev;
 
-	pr_debug("br2684_pop(vcc %p ; net_dev %p )\n", vcc, net_dev);
+	pr_debug("(vcc %p ; net_dev %p )\n", vcc, net_dev);
 	brvcc->old_pop(vcc, skb);
 
 	if (!net_dev)
@@ -244,7 +246,7 @@ static netdev_tx_t br2684_start_xmit(struct sk_buff *skb,
 	struct br2684_dev *brdev = BRPRIV(dev);
 	struct br2684_vcc *brvcc;
 
-	pr_debug("br2684_start_xmit, skb_dst(skb)=%p\n", skb_dst(skb));
+	pr_debug("skb_dst(skb)=%p\n", skb_dst(skb));
 	read_lock(&devs_lock);
 	brvcc = pick_outgoing_vcc(skb, brdev);
 	if (brvcc == NULL) {
@@ -352,7 +354,7 @@ static void br2684_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 	struct net_device *net_dev = brvcc->device;
 	struct br2684_dev *brdev = BRPRIV(net_dev);
 
-	pr_debug("br2684_push\n");
+	pr_debug("\n");
 
 	if (unlikely(skb == NULL)) {
 		/* skb==NULL means VCC is being destroyed */
@@ -479,8 +481,7 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 	write_lock_irq(&devs_lock);
 	net_dev = br2684_find_dev(&be.ifspec);
 	if (net_dev == NULL) {
-		printk(KERN_ERR
-		       "br2684: tried to attach to non-existant device\n");
+		pr_err("tried to attach to non-existant device\n");
 		err = -ENXIO;
 		goto error;
 	}
@@ -503,8 +504,7 @@ static int br2684_regvcc(struct atm_vcc *atmvcc, void __user * arg)
 		err = -EINVAL;
 		goto error;
 	}
-	pr_debug("br2684_regvcc vcc=%p, encaps=%d, brvcc=%p\n", atmvcc,
-		 be.encaps, brvcc);
+	pr_debug("vcc=%p, encaps=%d, brvcc=%p\n", atmvcc, be.encaps, brvcc);
 	if (list_empty(&brdev->brvccs) && !brdev->mac_was_set) {
 		unsigned char *esi = atmvcc->dev->esi;
 		if (esi[0] | esi[1] | esi[2] | esi[3] | esi[4] | esi[5])
@@ -590,7 +590,7 @@ static int br2684_create(void __user * arg)
 	struct atm_newif_br2684 ni;
 	enum br2684_payload payload;
 
-	pr_debug("br2684_create\n");
+	pr_debug("\n");
 
 	if (copy_from_user(&ni, arg, sizeof ni)) {
 		return -EFAULT;
@@ -619,7 +619,7 @@ static int br2684_create(void __user * arg)
 	/* open, stop, do_ioctl ? */
 	err = register_netdev(netdev);
 	if (err < 0) {
-		printk(KERN_ERR "br2684_create: register_netdev failed\n");
+		pr_err("register_netdev failed\n");
 		free_netdev(netdev);
 		return err;
 	}
diff --git a/net/atm/clip.c b/net/atm/clip.c
index 64629c3..d7939fd 100644
--- a/net/atm/clip.c
+++ b/net/atm/clip.c
@@ -2,6 +2,8 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
+
 #include <linux/string.h>
 #include <linux/errno.h>
 #include <linux/kernel.h> /* for UINT_MAX */
@@ -51,7 +53,7 @@ static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 	struct atmarp_ctrl *ctrl;
 	struct sk_buff *skb;
 
-	pr_debug("to_atmarpd(%d)\n", type);
+	pr_debug("(%d)\n", type);
 	if (!atmarpd)
 		return -EUNATCH;
 	skb = alloc_skb(sizeof(struct atmarp_ctrl),GFP_ATOMIC);
@@ -71,8 +73,7 @@ static int to_atmarpd(enum atmarp_ctrl_type type, int itf, __be32 ip)
 
 static void link_vcc(struct clip_vcc *clip_vcc, struct atmarp_entry *entry)
 {
-	pr_debug("link_vcc %p to entry %p (neigh %p)\n", clip_vcc, entry,
-		entry->neigh);
+	pr_debug("%p to entry %p (neigh %p)\n", clip_vcc, entry, entry->neigh);
 	clip_vcc->entry = entry;
 	clip_vcc->xoff = 0;	/* @@@ may overrun buffer by one packet */
 	clip_vcc->next = entry->vccs;
@@ -86,7 +87,7 @@ static void unlink_clip_vcc(struct clip_vcc *clip_vcc)
 	struct clip_vcc **walk;
 
 	if (!entry) {
-		printk(KERN_CRIT "!clip_vcc->entry (clip_vcc %p)\n", clip_vcc);
+		pr_crit("!clip_vcc->entry (clip_vcc %p)\n", clip_vcc);
 		return;
 	}
 	netif_tx_lock_bh(entry->neigh->dev);	/* block clip_start_xmit() */
@@ -106,12 +107,10 @@ static void unlink_clip_vcc(struct clip_vcc *clip_vcc)
 			error = neigh_update(entry->neigh, NULL, NUD_NONE,
 					     NEIGH_UPDATE_F_ADMIN);
 			if (error)
-				printk(KERN_CRIT "unlink_clip_vcc: "
-				       "neigh_update failed with %d\n", error);
+				pr_crit("neigh_update failed with %d\n", error);
 			goto out;
 		}
-	printk(KERN_CRIT "ATMARP: unlink_clip_vcc failed (entry %p, vcc "
-	       "0x%p)\n", entry, clip_vcc);
+	pr_crit("ATMARP: failed (entry %p, vcc 0x%p)\n", entry, clip_vcc);
       out:
 	netif_tx_unlock_bh(entry->neigh->dev);
 }
@@ -127,7 +126,7 @@ static int neigh_check_cb(struct neighbour *n)
 
 		if (cv->idle_timeout && time_after(jiffies, exp)) {
 			pr_debug("releasing vcc %p->%p of entry %p\n",
-				cv, cv->vcc, entry);
+				 cv, cv->vcc, entry);
 			vcc_release_async(cv->vcc, -ETIMEDOUT);
 		}
 	}
@@ -139,7 +138,7 @@ static int neigh_check_cb(struct neighbour *n)
 		struct sk_buff *skb;
 
 		pr_debug("destruction postponed with ref %d\n",
-			atomic_read(&n->refcnt));
+			 atomic_read(&n->refcnt));
 
 		while ((skb = skb_dequeue(&n->arp_queue)) != NULL)
 			dev_kfree_skb(skb);
@@ -163,7 +162,7 @@ static int clip_arp_rcv(struct sk_buff *skb)
 {
 	struct atm_vcc *vcc;
 
-	pr_debug("clip_arp_rcv\n");
+	pr_debug("\n");
 	vcc = ATM_SKB(skb)->vcc;
 	if (!vcc || !atm_charge(vcc, skb->truesize)) {
 		dev_kfree_skb_any(skb);
@@ -188,7 +187,7 @@ static void clip_push(struct atm_vcc *vcc, struct sk_buff *skb)
 {
 	struct clip_vcc *clip_vcc = CLIP_VCC(vcc);
 
-	pr_debug("clip push\n");
+	pr_debug("\n");
 	if (!skb) {
 		pr_debug("removing VCC %p\n", clip_vcc);
 		if (clip_vcc->entry)
@@ -239,7 +238,7 @@ static void clip_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 	int old;
 	unsigned long flags;
 
-	pr_debug("clip_pop(vcc %p)\n", vcc);
+	pr_debug("(vcc %p)\n", vcc);
 	clip_vcc->old_pop(vcc, skb);
 	/* skb->dev == NULL in outbound ARP packets */
 	if (!dev)
@@ -255,7 +254,7 @@ static void clip_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 
 static void clip_neigh_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
-	pr_debug("clip_neigh_solicit (neigh %p, skb %p)\n", neigh, skb);
+	pr_debug("(neigh %p, skb %p)\n", neigh, skb);
 	to_atmarpd(act_need, PRIV(neigh->dev)->number, NEIGH2ENTRY(neigh)->ip);
 }
 
@@ -284,7 +283,7 @@ static int clip_constructor(struct neighbour *neigh)
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
 
-	pr_debug("clip_constructor (neigh %p, entry %p)\n", neigh, entry);
+	pr_debug("(neigh %p, entry %p)\n", neigh, entry);
 	neigh->type = inet_addr_type(&init_net, entry->ip);
 	if (neigh->type != RTN_UNICAST)
 		return -EINVAL;
@@ -369,9 +368,9 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	int old;
 	unsigned long flags;
 
-	pr_debug("clip_start_xmit (skb %p)\n", skb);
+	pr_debug("(skb %p)\n", skb);
 	if (!skb_dst(skb)) {
-		printk(KERN_ERR "clip_start_xmit: skb_dst(skb) == NULL\n");
+		pr_err("skb_dst(skb) == NULL\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
@@ -385,7 +384,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 			return 0;
 		}
 #endif
-		printk(KERN_ERR "clip_start_xmit: NO NEIGHBOUR !\n");
+		pr_err("NO NEIGHBOUR !\n");
 		dev_kfree_skb(skb);
 		dev->stats.tx_dropped++;
 		return NETDEV_TX_OK;
@@ -421,7 +420,7 @@ static netdev_tx_t clip_start_xmit(struct sk_buff *skb,
 	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, vcc, vcc->dev);
 	old = xchg(&entry->vccs->xoff, 1);	/* assume XOFF ... */
 	if (old) {
-		printk(KERN_WARNING "clip_start_xmit: XOFF->XOFF transition\n");
+		pr_warning("XOFF->XOFF transition\n");
 		return NETDEV_TX_OK;
 	}
 	dev->stats.tx_packets++;
@@ -456,7 +455,7 @@ static int clip_mkip(struct atm_vcc *vcc, int timeout)
 	clip_vcc = kmalloc(sizeof(struct clip_vcc), GFP_KERNEL);
 	if (!clip_vcc)
 		return -ENOMEM;
-	pr_debug("mkip clip_vcc %p vcc %p\n", clip_vcc, vcc);
+	pr_debug("%p vcc %p\n", clip_vcc, vcc);
 	clip_vcc->vcc = vcc;
 	vcc->user_back = clip_vcc;
 	set_bit(ATM_VF_IS_CLIP, &vcc->flags);
@@ -506,16 +505,16 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	struct rtable *rt;
 
 	if (vcc->push != clip_push) {
-		printk(KERN_WARNING "clip_setentry: non-CLIP VCC\n");
+		pr_warning("non-CLIP VCC\n");
 		return -EBADF;
 	}
 	clip_vcc = CLIP_VCC(vcc);
 	if (!ip) {
 		if (!clip_vcc->entry) {
-			printk(KERN_ERR "hiding hidden ATMARP entry\n");
+			pr_err("hiding hidden ATMARP entry\n");
 			return 0;
 		}
-		pr_debug("setentry: remove\n");
+		pr_debug("remove\n");
 		unlink_clip_vcc(clip_vcc);
 		return 0;
 	}
@@ -529,9 +528,9 @@ static int clip_setentry(struct atm_vcc *vcc, __be32 ip)
 	entry = NEIGH2ENTRY(neigh);
 	if (entry != clip_vcc->entry) {
 		if (!clip_vcc->entry)
-			pr_debug("setentry: add\n");
+			pr_debug("add\n");
 		else {
-			pr_debug("setentry: update\n");
+			pr_debug("update\n");
 			unlink_clip_vcc(clip_vcc);
 		}
 		link_vcc(clip_vcc, entry);
@@ -614,16 +613,16 @@ static int clip_device_event(struct notifier_block *this, unsigned long event,
 
 	switch (event) {
 	case NETDEV_UP:
-		pr_debug("clip_device_event NETDEV_UP\n");
+		pr_debug("NETDEV_UP\n");
 		to_atmarpd(act_up, PRIV(dev)->number, 0);
 		break;
 	case NETDEV_GOING_DOWN:
-		pr_debug("clip_device_event NETDEV_DOWN\n");
+		pr_debug("NETDEV_DOWN\n");
 		to_atmarpd(act_down, PRIV(dev)->number, 0);
 		break;
 	case NETDEV_CHANGE:
 	case NETDEV_CHANGEMTU:
-		pr_debug("clip_device_event NETDEV_CHANGE*\n");
+		pr_debug("NETDEV_CHANGE*\n");
 		to_atmarpd(act_change, PRIV(dev)->number, 0);
 		break;
 	}
@@ -660,7 +659,7 @@ static struct notifier_block clip_inet_notifier = {
 
 static void atmarpd_close(struct atm_vcc *vcc)
 {
-	pr_debug("atmarpd_close\n");
+	pr_debug("\n");
 
 	rtnl_lock();
 	atmarpd = NULL;
@@ -950,8 +949,7 @@ static int __init atm_clip_init(void)
 
 		p = proc_create("arp", S_IRUGO, atm_proc_root, &arp_seq_fops);
 		if (!p) {
-			printk(KERN_ERR "Unable to initialize "
-			       "/proc/net/atm/arp\n");
+			pr_err("Unable to initialize /proc/net/atm/arp\n");
 			atm_clip_exit_noproc();
 			return -ENOMEM;
 		}
diff --git a/net/atm/common.c b/net/atm/common.c
index d61e051..17f7e5f 100644
--- a/net/atm/common.c
+++ b/net/atm/common.c
@@ -2,6 +2,7 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
 #include <linux/module.h>
 #include <linux/kmod.h>
@@ -64,8 +65,7 @@ static struct sk_buff *alloc_tx(struct atm_vcc *vcc,unsigned int size)
 
 	if (sk_wmem_alloc_get(sk) && !atm_may_send(vcc, size)) {
 		pr_debug("Sorry: wmem_alloc = %d, size = %d, sndbuf = %d\n",
-			sk_wmem_alloc_get(sk), size,
-			sk->sk_sndbuf);
+			 sk_wmem_alloc_get(sk), size, sk->sk_sndbuf);
 		return NULL;
 	}
 	while (!(skb = alloc_skb(size, GFP_KERNEL)))
@@ -249,8 +249,7 @@ static int adjust_tp(struct atm_trafprm *tp,unsigned char aal)
 			max_sdu = ATM_MAX_AAL34_PDU;
 			break;
 		default:
-			printk(KERN_WARNING "ATM: AAL problems ... "
-			    "(%d)\n",aal);
+			pr_warning("AAL problems ... (%d)\n", aal);
 			/* fall through */
 		case ATM_AAL5:
 			max_sdu = ATM_MAX_AAL5_PDU;
@@ -385,11 +384,17 @@ static int __vcc_connect(struct atm_vcc *vcc, struct atm_dev *dev, short vpi,
 	if (!error) error = adjust_tp(&vcc->qos.rxtp,vcc->qos.aal);
 	if (error)
 		goto fail;
-	pr_debug("VCC %d.%d, AAL %d\n",vpi,vci,vcc->qos.aal);
-	pr_debug("  TX: %d, PCR %d..%d, SDU %d\n",vcc->qos.txtp.traffic_class,
-	    vcc->qos.txtp.min_pcr,vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu);
-	pr_debug("  RX: %d, PCR %d..%d, SDU %d\n",vcc->qos.rxtp.traffic_class,
-	    vcc->qos.rxtp.min_pcr,vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu);
+	pr_debug("VCC %d.%d, AAL %d\n", vpi, vci, vcc->qos.aal);
+	pr_debug("  TX: %d, PCR %d..%d, SDU %d\n",
+		 vcc->qos.txtp.traffic_class,
+		 vcc->qos.txtp.min_pcr,
+		 vcc->qos.txtp.max_pcr,
+		 vcc->qos.txtp.max_sdu);
+	pr_debug("  RX: %d, PCR %d..%d, SDU %d\n",
+		 vcc->qos.rxtp.traffic_class,
+		 vcc->qos.rxtp.min_pcr,
+		 vcc->qos.rxtp.max_pcr,
+		 vcc->qos.rxtp.max_sdu);
 
 	if (dev->ops->open) {
 		if ((error = dev->ops->open(vcc)))
@@ -413,7 +418,7 @@ int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	pr_debug("vcc_connect (vpi %d, vci %d)\n",vpi,vci);
+	pr_debug("(vpi %d, vci %d)\n", vpi, vci);
 	if (sock->state == SS_CONNECTED)
 		return -EISCONN;
 	if (sock->state != SS_UNCONNECTED)
@@ -426,14 +431,15 @@ int vcc_connect(struct socket *sock, int itf, short vpi, int vci)
 	else
 		if (test_bit(ATM_VF_PARTIAL,&vcc->flags))
 			return -EINVAL;
-	pr_debug("vcc_connect (TX: cl %d,bw %d-%d,sdu %d; "
-	    "RX: cl %d,bw %d-%d,sdu %d,AAL %s%d)\n",
-	    vcc->qos.txtp.traffic_class,vcc->qos.txtp.min_pcr,
-	    vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu,
-	    vcc->qos.rxtp.traffic_class,vcc->qos.rxtp.min_pcr,
-	    vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu,
-	    vcc->qos.aal == ATM_AAL5 ? "" : vcc->qos.aal == ATM_AAL0 ? "" :
-	    " ??? code ",vcc->qos.aal == ATM_AAL0 ? 0 : vcc->qos.aal);
+	pr_debug("(TX: cl %d,bw %d-%d,sdu %d; "
+		 "RX: cl %d,bw %d-%d,sdu %d,AAL %s%d)\n",
+		 vcc->qos.txtp.traffic_class, vcc->qos.txtp.min_pcr,
+		 vcc->qos.txtp.max_pcr, vcc->qos.txtp.max_sdu,
+		 vcc->qos.rxtp.traffic_class, vcc->qos.rxtp.min_pcr,
+		 vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu,
+		 vcc->qos.aal == ATM_AAL5 ? "" :
+		 vcc->qos.aal == ATM_AAL0 ? "" : " ??? code ",
+		 vcc->qos.aal == ATM_AAL0 ? 0 : vcc->qos.aal);
 	if (!test_bit(ATM_VF_HASQOS, &vcc->flags))
 		return -EBADFD;
 	if (vcc->qos.txtp.traffic_class == ATM_ANYCLASS ||
@@ -497,7 +503,7 @@ int vcc_recvmsg(struct kiocb *iocb, struct socket *sock, struct msghdr *msg,
 	if (error)
 		return error;
 	sock_recv_ts_and_drops(msg, sk, skb);
-	pr_debug("RcvM %d -= %d\n", atomic_read(&sk->sk_rmem_alloc), skb->truesize);
+	pr_debug("%d -= %d\n", atomic_read(&sk->sk_rmem_alloc), skb->truesize);
 	atm_return(vcc, skb->truesize);
 	skb_free_datagram(sk, skb);
 	return copied;
@@ -772,19 +778,19 @@ static int __init atm_init(void)
 		goto out;
 
 	if ((error = atmpvc_init()) < 0) {
-		printk(KERN_ERR "atmpvc_init() failed with %d\n", error);
+		pr_err("atmpvc_init() failed with %d\n", error);
 		goto out_unregister_vcc_proto;
 	}
 	if ((error = atmsvc_init()) < 0) {
-		printk(KERN_ERR "atmsvc_init() failed with %d\n", error);
+		pr_err("atmsvc_init() failed with %d\n", error);
 		goto out_atmpvc_exit;
 	}
 	if ((error = atm_proc_init()) < 0) {
-		printk(KERN_ERR "atm_proc_init() failed with %d\n",error);
+		pr_err("atm_proc_init() failed with %d\n", error);
 		goto out_atmsvc_exit;
 	}
 	if ((error = atm_sysfs_init()) < 0) {
-		printk(KERN_ERR "atm_sysfs_init() failed with %d\n",error);
+		pr_err("atm_sysfs_init() failed with %d\n", error);
 		goto out_atmproc_exit;
 	}
 out:
diff --git a/net/atm/ioctl.c b/net/atm/ioctl.c
index 2ea4099..b75afba 100644
--- a/net/atm/ioctl.c
+++ b/net/atm/ioctl.c
@@ -3,6 +3,7 @@
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 /* 2003 John Levon  <levon@movementarian.org> */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
 #include <linux/module.h>
 #include <linux/kmod.h>
@@ -97,8 +98,8 @@ static int do_vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg
 			goto done;
 		case ATM_SETSC:
 			if (net_ratelimit())
-				printk(KERN_WARNING "ATM_SETSC is obsolete; used by %s:%d\n",
-				       current->comm, task_pid_nr(current));
+				pr_warning("ATM_SETSC is obsolete; used by %s:%d\n",
+					   current->comm, task_pid_nr(current));
 			error = 0;
 			goto done;
 		case ATMSIGD_CTRL:
@@ -123,7 +124,7 @@ static int do_vcc_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg
 			   to think about it at all. dwmw2. */
 			if (compat) {
 				if (net_ratelimit())
-					printk(KERN_WARNING "32-bit task cannot be atmsigd\n");
+					pr_warning("32-bit task cannot be atmsigd\n");
 				error = -EINVAL;
 				goto done;
 			}
diff --git a/net/atm/lec.c b/net/atm/lec.c
index b2d6445..31eab00 100644
--- a/net/atm/lec.c
+++ b/net/atm/lec.c
@@ -4,6 +4,8 @@
  * Marko Kiiskila <mkiiskila@yahoo.com>
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
+
 #include <linux/kernel.h>
 #include <linux/bitops.h>
 #include <linux/capability.h>
@@ -243,7 +245,7 @@ lec_send(struct atm_vcc *vcc, struct sk_buff *skb)
 
 static void lec_tx_timeout(struct net_device *dev)
 {
-	printk(KERN_INFO "%s: tx timeout\n", dev->name);
+	pr_info("%s\n", dev->name);
 	dev->trans_start = jiffies;
 	netif_wake_queue(dev);
 }
@@ -267,7 +269,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	int i = 0;
 #endif /* DUMP_PACKETS >0 */
 
-	pr_debug("lec_start_xmit called\n");
+	pr_debug("called\n");
 	if (!priv->lecd) {
 		printk("%s:No lecd attached\n", dev->name);
 		dev->stats.tx_errors++;
@@ -277,8 +279,8 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	}
 
 	pr_debug("skbuff head:%lx data:%lx tail:%lx end:%lx\n",
-		(long)skb->head, (long)skb->data, (long)skb_tail_pointer(skb),
-		(long)skb_end_pointer(skb));
+		 (long)skb->head, (long)skb->data, (long)skb_tail_pointer(skb),
+		 (long)skb_end_pointer(skb));
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 	if (memcmp(skb->data, bridge_ula_lec, sizeof(bridge_ula_lec)) == 0)
 		lec_handle_bridge(skb, dev);
@@ -287,7 +289,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 	/* Make sure we have room for lec_id */
 	if (skb_headroom(skb) < 2) {
 
-		pr_debug("lec_start_xmit: reallocating skb\n");
+		pr_debug("reallocating skb\n");
 		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
 		kfree_skb(skb);
 		if (skb2 == NULL)
@@ -368,19 +370,16 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 #endif
 	entry = NULL;
 	vcc = lec_arp_resolve(priv, dst, is_rdesc, &entry);
-	pr_debug("%s:vcc:%p vcc_flags:%lx, entry:%p\n", dev->name,
-		vcc, vcc ? vcc->flags : 0, entry);
+	pr_debug("%s:vcc:%p vcc_flags:%lx, entry:%p\n",
+		 dev->name, vcc, vcc ? vcc->flags : 0, entry);
 	if (!vcc || !test_bit(ATM_VF_READY, &vcc->flags)) {
 		if (entry && (entry->tx_wait.qlen < LEC_UNRES_QUE_LEN)) {
-			pr_debug("%s:lec_start_xmit: queuing packet, ",
-				dev->name);
-			pr_debug("MAC address %pM\n", lec_h->h_dest);
+			pr_debug("%s:queuing packet, MAC address %pM\n",
+				 dev->name, lec_h->h_dest);
 			skb_queue_tail(&entry->tx_wait, skb);
 		} else {
-			pr_debug
-			    ("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ",
-			     dev->name);
-			pr_debug("MAC address %pM\n", lec_h->h_dest);
+			pr_debug("%s:tx queue full or no arp entry, dropping, MAC address: %pM\n",
+				 dev->name, lec_h->h_dest);
 			dev->stats.tx_dropped++;
 			dev_kfree_skb(skb);
 		}
@@ -391,8 +390,7 @@ static netdev_tx_t lec_start_xmit(struct sk_buff *skb,
 #endif /* DUMP_PACKETS > 0 */
 
 	while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
-		pr_debug("lec.c: emptying tx queue, ");
-		pr_debug("MAC address %pM\n", lec_h->h_dest);
+		pr_debug("emptying tx queue, MAC address %pM\n", lec_h->h_dest);
 		lec_send(vcc, skb2);
 	}
 
@@ -478,10 +476,10 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 			       mesg->content.normal.atm_addr,
 			       mesg->content.normal.flag,
 			       mesg->content.normal.targetless_le_arp);
-		pr_debug("lec: in l_arp_update\n");
+		pr_debug("in l_arp_update\n");
 		if (mesg->sizeoftlvs != 0) {	/* LANE2 3.1.5 */
-			pr_debug("lec: LANE2 3.1.5, got tlvs, size %d\n",
-				mesg->sizeoftlvs);
+			pr_debug("LANE2 3.1.5, got tlvs, size %d\n",
+				 mesg->sizeoftlvs);
 			lane2_associate_ind(dev, mesg->content.normal.mac_addr,
 					    tmp, mesg->sizeoftlvs);
 		}
@@ -532,9 +530,8 @@ static int lec_atm_send(struct atm_vcc *vcc, struct sk_buff *skb)
 				struct sk_buff *skb2;
 				struct sock *sk;
 
-				pr_debug
-				    ("%s: entry found, responding to zeppelin\n",
-				     dev->name);
+				pr_debug("%s: entry found, responding to zeppelin\n",
+					 dev->name);
 				skb2 =
 				    alloc_skb(sizeof(struct atmlec_msg),
 					      GFP_ATOMIC);
@@ -634,7 +631,7 @@ send_to_lecd(struct lec_priv *priv, atmlec_msg_type type,
 	sk->sk_data_ready(sk, skb->len);
 
 	if (data != NULL) {
-		pr_debug("lec: about to send %d bytes of data\n", data->len);
+		pr_debug("about to send %d bytes of data\n", data->len);
 		atm_force_charge(priv->lecd, data->truesize);
 		skb_queue_tail(&sk->sk_receive_queue, data);
 		sk->sk_data_ready(sk, skb->len);
@@ -700,35 +697,27 @@ static void lec_push(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct lec_priv *priv = netdev_priv(dev);
 
 #if DUMP_PACKETS >0
-	int i = 0;
-	char buf[300];
-
-	printk("%s: lec_push vcc vpi:%d vci:%d\n", dev->name,
-	       vcc->vpi, vcc->vci);
+	printk(KERN_DEBUG "%s: vcc vpi:%d vci:%d\n",
+	       dev->name, vcc->vpi, vcc->vci);
 #endif
 	if (!skb) {
 		pr_debug("%s: null skb\n", dev->name);
 		lec_vcc_close(priv, vcc);
 		return;
 	}
-#if DUMP_PACKETS > 0
-	printk("%s: rcv datalen:%ld lecid:%4.4x\n", dev->name,
-	       skb->len, priv->lecid);
 #if DUMP_PACKETS >= 2
-	for (i = 0; i < skb->len && i < 99; i++) {
-		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
-	}
+#define MAX_SKB_DUMP 99
 #elif DUMP_PACKETS >= 1
-	for (i = 0; i < skb->len && i < 30; i++) {
-		sprintf(buf + i * 3, "%2.2x ", 0xff & skb->data[i]);
-	}
-#endif /* DUMP_PACKETS >= 1 */
-	if (i == skb->len)
-		printk("%s\n", buf);
-	else
-		printk("%s...\n", buf);
+#define MAX_SKB_DUMP 30
+#endif
+#if DUMP_PACKETS > 0
+	printk(KERN_DEBUG "%s: rcv datalen:%ld lecid:%4.4x\n",
+	       dev->name, skb->len, priv->lecid);
+	print_hex_dump(KERN_DEBUG, "", DUMP_OFFSET, 16, 1,
+		       skb->data, min(MAX_SKB_DUMP, skb->len), true);
 #endif /* DUMP_PACKETS > 0 */
-	if (memcmp(skb->data, lec_ctrl_magic, 4) == 0) {	/* Control frame, to daemon */
+	if (memcmp(skb->data, lec_ctrl_magic, 4) == 0) {
+				/* Control frame, to daemon */
 		struct sock *sk = sk_atm(vcc);
 
 		pr_debug("%s: To daemon\n", dev->name);
@@ -809,7 +798,7 @@ static void lec_pop(struct atm_vcc *vcc, struct sk_buff *skb)
 	struct net_device *dev = skb->dev;
 
 	if (vpriv == NULL) {
-		printk("lec_pop(): vpriv = NULL!?!?!?\n");
+		pr_info("vpriv = NULL!?!?!?\n");
 		return;
 	}
 
@@ -830,11 +819,8 @@ static int lec_vcc_attach(struct atm_vcc *vcc, void __user *arg)
 
 	/* Lecd must be up in this case */
 	bytes_left = copy_from_user(&ioc_data, arg, sizeof(struct atmlec_ioc));
-	if (bytes_left != 0) {
-		printk
-		    ("lec: lec_vcc_attach, copy from user failed for %d bytes\n",
-		     bytes_left);
-	}
+	if (bytes_left != 0)
+		pr_info("copy from user failed for %d bytes\n", bytes_left);
 	if (ioc_data.dev_num < 0 || ioc_data.dev_num >= MAX_LEC_ITF ||
 	    !dev_lec[ioc_data.dev_num])
 		return -EINVAL;
@@ -1207,7 +1193,7 @@ static int __init lane_module_init(void)
 
 	p = proc_create("lec", S_IRUGO, atm_proc_root, &lec_seq_fops);
 	if (!p) {
-		printk(KERN_ERR "Unable to initialize /proc/net/atm/lec\n");
+		pr_err("Unable to initialize /proc/net/atm/lec\n");
 		return -ENOMEM;
 	}
 #endif
@@ -1389,7 +1375,7 @@ static void lane2_associate_ind(struct net_device *dev, const u8 *mac_addr,
 #if 0
 #define pr_debug(format,args...)
 /*
-#define pr_debug printk
+  #define pr_debug printk
 */
 #endif
 #define DEBUG_ARP_TABLE 0
@@ -1458,10 +1444,7 @@ lec_arp_add(struct lec_priv *priv, struct lec_arp_table *entry)
 	tmp = &priv->lec_arp_tables[HASH(entry->mac_addr[ETH_ALEN - 1])];
 	hlist_add_head(&entry->next, tmp);
 
-	pr_debug("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-		0xff & entry->mac_addr[0], 0xff & entry->mac_addr[1],
-		0xff & entry->mac_addr[2], 0xff & entry->mac_addr[3],
-		0xff & entry->mac_addr[4], 0xff & entry->mac_addr[5]);
+	pr_debug("Added entry:%pM\n", entry->mac_addr);
 }
 
 /*
@@ -1500,10 +1483,7 @@ lec_arp_remove(struct lec_priv *priv, struct lec_arp_table *to_remove)
 	}
 	skb_queue_purge(&to_remove->tx_wait);	/* FIXME: good place for this? */
 
-	pr_debug("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-		0xff & to_remove->mac_addr[0], 0xff & to_remove->mac_addr[1],
-		0xff & to_remove->mac_addr[2], 0xff & to_remove->mac_addr[3],
-		0xff & to_remove->mac_addr[4], 0xff & to_remove->mac_addr[5]);
+	pr_debug("Removed entry:%pM\n", to_remove->mac_addr);
 	return 0;
 }
 
@@ -1722,9 +1702,7 @@ static struct lec_arp_table *lec_arp_find(struct lec_priv *priv,
 	struct hlist_head *head;
 	struct lec_arp_table *entry;
 
-	pr_debug("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
-		mac_addr[0] & 0xff, mac_addr[1] & 0xff, mac_addr[2] & 0xff,
-		mac_addr[3] & 0xff, mac_addr[4] & 0xff, mac_addr[5] & 0xff);
+	pr_debug("%pM\n", mac_addr);
 
 	head = &priv->lec_arp_tables[HASH(mac_addr[ETH_ALEN - 1])];
 	hlist_for_each_entry(entry, node, head, next) {
@@ -1763,7 +1741,7 @@ static void lec_arp_expire_arp(unsigned long data)
 
 	entry = (struct lec_arp_table *)data;
 
-	pr_debug("lec_arp_expire_arp\n");
+	pr_debug("\n");
 	if (entry->status == ESI_ARP_PENDING) {
 		if (entry->no_tries <= entry->priv->max_retry_count) {
 			if (entry->is_rdesc)
@@ -1787,10 +1765,10 @@ static void lec_arp_expire_vcc(unsigned long data)
 
 	del_timer(&to_remove->timer);
 
-	pr_debug("LEC_ARP %p %p: lec_arp_expire_vcc vpi:%d vci:%d\n",
-		to_remove, priv,
-		to_remove->vcc ? to_remove->recv_vcc->vpi : 0,
-		to_remove->vcc ? to_remove->recv_vcc->vci : 0);
+	pr_debug("%p %p: vpi:%d vci:%d\n",
+		 to_remove, priv,
+		 to_remove->vcc ? to_remove->recv_vcc->vpi : 0,
+		 to_remove->vcc ? to_remove->recv_vcc->vci : 0);
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	hlist_del(&to_remove->next);
@@ -1827,7 +1805,7 @@ static void lec_arp_check_expire(struct work_struct *work)
 	unsigned long time_to_check;
 	int i;
 
-	pr_debug("lec_arp_check_expire %p\n", priv);
+	pr_debug("%p\n", priv);
 	now = jiffies;
 restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
@@ -1840,12 +1818,12 @@ restart:
 				time_to_check = priv->aging_time;
 
 			pr_debug("About to expire: %lx - %lx > %lx\n",
-				now, entry->last_used, time_to_check);
+				 now, entry->last_used, time_to_check);
 			if (time_after(now, entry->last_used + time_to_check)
 			    && !(entry->flags & LEC_PERMANENT_FLAG)
 			    && !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
 				/* Remove entry */
-				pr_debug("LEC:Entry timed out\n");
+				pr_debug("Entry timed out\n");
 				lec_arp_remove(priv, entry);
 				lec_arp_put(entry);
 			} else {
@@ -1942,7 +1920,7 @@ static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
 		    entry->packets_flooded <
 		    priv->maximum_unknown_frame_count) {
 			entry->packets_flooded++;
-			pr_debug("LEC_ARP: Flooding..\n");
+			pr_debug("Flooding..\n");
 			found = priv->mcast_vcc;
 			goto out;
 		}
@@ -1953,13 +1931,13 @@ static struct atm_vcc *lec_arp_resolve(struct lec_priv *priv,
 		 */
 		lec_arp_hold(entry);
 		*ret_entry = entry;
-		pr_debug("lec: entry->status %d entry->vcc %p\n", entry->status,
-			entry->vcc);
+		pr_debug("entry->status %d entry->vcc %p\n", entry->status,
+			 entry->vcc);
 		found = NULL;
 	} else {
 		/* No matching entry was found */
 		entry = make_entry(priv, mac_to_find);
-		pr_debug("LEC_ARP: Making entry\n");
+		pr_debug("Making entry\n");
 		if (!entry) {
 			found = priv->mcast_vcc;
 			goto out;
@@ -1996,7 +1974,7 @@ lec_addr_delete(struct lec_priv *priv, const unsigned char *atm_addr,
 	struct lec_arp_table *entry;
 	int i;
 
-	pr_debug("lec_addr_delete\n");
+	pr_debug("\n");
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
 		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
@@ -2027,10 +2005,8 @@ lec_arp_update(struct lec_priv *priv, const unsigned char *mac_addr,
 	struct lec_arp_table *entry, *tmp;
 	int i;
 
-	pr_debug("lec:%s", (targetless_le_arp) ? "targetless " : " ");
-	pr_debug("lec_arp_update mac:%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
-		mac_addr[0], mac_addr[1], mac_addr[2], mac_addr[3],
-		mac_addr[4], mac_addr[5]);
+	pr_debug("%smac:%pM\n",
+		 (targetless_le_arp) ? "targetless " : "", mac_addr);
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	entry = lec_arp_find(priv, mac_addr);
@@ -2157,19 +2133,17 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 		 * Vcc which we don't want to make default vcc,
 		 * attach it anyway.
 		 */
-		pr_debug
-		    ("LEC_ARP:Attaching data direct, not default: "
-		     "%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
-		     ioc_data->atm_addr[0], ioc_data->atm_addr[1],
-		     ioc_data->atm_addr[2], ioc_data->atm_addr[3],
-		     ioc_data->atm_addr[4], ioc_data->atm_addr[5],
-		     ioc_data->atm_addr[6], ioc_data->atm_addr[7],
-		     ioc_data->atm_addr[8], ioc_data->atm_addr[9],
-		     ioc_data->atm_addr[10], ioc_data->atm_addr[11],
-		     ioc_data->atm_addr[12], ioc_data->atm_addr[13],
-		     ioc_data->atm_addr[14], ioc_data->atm_addr[15],
-		     ioc_data->atm_addr[16], ioc_data->atm_addr[17],
-		     ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
+		pr_debug("LEC_ARP:Attaching data direct, not default: %2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
+			 ioc_data->atm_addr[0], ioc_data->atm_addr[1],
+			 ioc_data->atm_addr[2], ioc_data->atm_addr[3],
+			 ioc_data->atm_addr[4], ioc_data->atm_addr[5],
+			 ioc_data->atm_addr[6], ioc_data->atm_addr[7],
+			 ioc_data->atm_addr[8], ioc_data->atm_addr[9],
+			 ioc_data->atm_addr[10], ioc_data->atm_addr[11],
+			 ioc_data->atm_addr[12], ioc_data->atm_addr[13],
+			 ioc_data->atm_addr[14], ioc_data->atm_addr[15],
+			 ioc_data->atm_addr[16], ioc_data->atm_addr[17],
+			 ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
 		entry = make_entry(priv, bus_mac);
 		if (entry == NULL)
 			goto out;
@@ -2185,19 +2159,17 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 		dump_arp_table(priv);
 		goto out;
 	}
-	pr_debug
-	    ("LEC_ARP:Attaching data direct, default: "
-	     "%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
-	     ioc_data->atm_addr[0], ioc_data->atm_addr[1],
-	     ioc_data->atm_addr[2], ioc_data->atm_addr[3],
-	     ioc_data->atm_addr[4], ioc_data->atm_addr[5],
-	     ioc_data->atm_addr[6], ioc_data->atm_addr[7],
-	     ioc_data->atm_addr[8], ioc_data->atm_addr[9],
-	     ioc_data->atm_addr[10], ioc_data->atm_addr[11],
-	     ioc_data->atm_addr[12], ioc_data->atm_addr[13],
-	     ioc_data->atm_addr[14], ioc_data->atm_addr[15],
-	     ioc_data->atm_addr[16], ioc_data->atm_addr[17],
-	     ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
+	pr_debug("LEC_ARP:Attaching data direct, default: %2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
+		 ioc_data->atm_addr[0], ioc_data->atm_addr[1],
+		 ioc_data->atm_addr[2], ioc_data->atm_addr[3],
+		 ioc_data->atm_addr[4], ioc_data->atm_addr[5],
+		 ioc_data->atm_addr[6], ioc_data->atm_addr[7],
+		 ioc_data->atm_addr[8], ioc_data->atm_addr[9],
+		 ioc_data->atm_addr[10], ioc_data->atm_addr[11],
+		 ioc_data->atm_addr[12], ioc_data->atm_addr[13],
+		 ioc_data->atm_addr[14], ioc_data->atm_addr[15],
+		 ioc_data->atm_addr[16], ioc_data->atm_addr[17],
+		 ioc_data->atm_addr[18], ioc_data->atm_addr[19]);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
 		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
 			if (memcmp
@@ -2205,9 +2177,9 @@ lec_vcc_added(struct lec_priv *priv, const struct atmlec_ioc *ioc_data,
 			     ATM_ESA_LEN) == 0) {
 				pr_debug("LEC_ARP: Attaching data direct\n");
 				pr_debug("Currently -> Vcc: %d, Rvcc:%d\n",
-					entry->vcc ? entry->vcc->vci : 0,
-					entry->recv_vcc ? entry->recv_vcc->
-					vci : 0);
+					 entry->vcc ? entry->vcc->vci : 0,
+					 entry->recv_vcc ? entry->recv_vcc->
+					 vci : 0);
 				found_entry = 1;
 				del_timer(&entry->timer);
 				entry->vcc = vcc;
@@ -2279,7 +2251,7 @@ static void lec_flush_complete(struct lec_priv *priv, unsigned long tran_id)
 	struct lec_arp_table *entry;
 	int i;
 
-	pr_debug("LEC:lec_flush_complete %lx\n", tran_id);
+	pr_debug("%lx\n", tran_id);
 restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
@@ -2320,7 +2292,7 @@ lec_set_flush_tran_id(struct lec_priv *priv,
 			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)) {
 				entry->flush_tran_id = tran_id;
 				pr_debug("Set flush transaction id to %lx for %p\n",
-					tran_id, entry);
+					 tran_id, entry);
 			}
 		}
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
diff --git a/net/atm/mpc.c b/net/atm/mpc.c
index 38a6cb0..3c45aef 100644
--- a/net/atm/mpc.c
+++ b/net/atm/mpc.c
@@ -1,3 +1,5 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
+
 #include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/timer.h>
@@ -1447,7 +1449,7 @@ static __init int atm_mpoa_init(void)
 	register_atm_ioctl(&atm_ioctl_ops);
 
 	if (mpc_proc_init() != 0)
-		printk(KERN_INFO "mpoa: failed to initialize /proc/mpoa\n");
+		pr_info("failed to initialize /proc/mpoa\n");
 
 	printk("mpc.c: " __DATE__ " " __TIME__ " initialized\n");
 
diff --git a/net/atm/mpoa_proc.c b/net/atm/mpoa_proc.c
index 1a0f5cc..0603ab4 100644
--- a/net/atm/mpoa_proc.c
+++ b/net/atm/mpoa_proc.c
@@ -1,3 +1,4 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
 #ifdef CONFIG_PROC_FS
 #include <linux/errno.h>
@@ -278,7 +279,7 @@ int mpc_proc_init(void)
 
 	p = proc_create(STAT_FILE_NAME, 0, atm_proc_root, &mpc_file_operations);
 	if (!p) {
-		printk(KERN_ERR "Unable to initialize /proc/atm/%s\n", STAT_FILE_NAME);
+		pr_err("Unable to initialize /proc/atm/%s\n", STAT_FILE_NAME);
 		return -ENOMEM;
 	}
 	return 0;
diff --git a/net/atm/pppoatm.c b/net/atm/pppoatm.c
index 0af84cd..62db6d7 100644
--- a/net/atm/pppoatm.c
+++ b/net/atm/pppoatm.c
@@ -33,6 +33,8 @@
  * These hooks are not yet available in ppp_generic
  */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
+
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
@@ -132,7 +134,7 @@ static void pppoatm_unassign_vcc(struct atm_vcc *atmvcc)
 static void pppoatm_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
-	pr_debug("pppoatm push\n");
+	pr_debug("\n");
 	if (skb == NULL) {			/* VCC was closed */
 		pr_debug("removing ATMPPP VCC %p\n", pvcc);
 		pppoatm_unassign_vcc(atmvcc);
@@ -165,10 +167,9 @@ static void pppoatm_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 			pvcc->chan.mtu += LLC_LEN;
 			break;
 		}
-		pr_debug("Couldn't autodetect yet "
-		    "(skb: %02X %02X %02X %02X %02X %02X)\n",
-		    skb->data[0], skb->data[1], skb->data[2],
-		    skb->data[3], skb->data[4], skb->data[5]);
+		pr_debug("Couldn't autodetect yet (skb: %02X %02X %02X %02X %02X %02X)\n",
+			 skb->data[0], skb->data[1], skb->data[2],
+			 skb->data[3], skb->data[4], skb->data[5]);
 		goto error;
 	case e_vc:
 		break;
@@ -194,7 +195,7 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
-	pr_debug("pppoatm_send (skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
+	pr_debug("(skb=0x%p, vcc=0x%p)\n", skb, pvcc->atmvcc);
 	if (skb->data[0] == '\0' && (pvcc->flags & SC_COMP_PROT))
 		(void) skb_pull(skb, 1);
 	switch (pvcc->encaps) {		/* LLC encapsulation needed */
@@ -226,8 +227,8 @@ static int pppoatm_send(struct ppp_channel *chan, struct sk_buff *skb)
 
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
-	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, ATM_SKB(skb)->vcc,
-	    ATM_SKB(skb)->vcc->dev);
+	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n",
+		 skb, ATM_SKB(skb)->vcc, ATM_SKB(skb)->vcc->dev);
 	return ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
 	    ? DROP_PACKET : 1;
     nospace:
diff --git a/net/atm/raw.c b/net/atm/raw.c
index cbfcc71..fb8a949 100644
--- a/net/atm/raw.c
+++ b/net/atm/raw.c
@@ -2,6 +2,7 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
 #include <linux/module.h>
 #include <linux/atmdev.h>
@@ -32,8 +33,8 @@ static void atm_pop_raw(struct atm_vcc *vcc,struct sk_buff *skb)
 {
 	struct sock *sk = sk_atm(vcc);
 
-	pr_debug("APopR (%d) %d -= %d\n", vcc->vci,
-		sk_wmem_alloc_get(sk), skb->truesize);
+	pr_debug("(%d) %d -= %d\n",
+		 vcc->vci, sk_wmem_alloc_get(sk), skb->truesize);
 	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
 	sk->sk_write_space(sk);
diff --git a/net/atm/resources.c b/net/atm/resources.c
index 56b7322..0d4c0ee 100644
--- a/net/atm/resources.c
+++ b/net/atm/resources.c
@@ -7,6 +7,7 @@
  * 2002/01 - don't free the whole struct sock on sk->destruct time,
  * 	     use the default destruct function initialized by sock_init_data */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
 #include <linux/ctype.h>
 #include <linux/string.h>
@@ -79,8 +80,7 @@ struct atm_dev *atm_dev_register(const char *type, const struct atmdev_ops *ops,
 
 	dev = __alloc_atm_dev(type);
 	if (!dev) {
-		printk(KERN_ERR "atm_dev_register: no space for dev %s\n",
-		    type);
+		pr_err("no space for dev %s\n", type);
 		return NULL;
 	}
 	mutex_lock(&atm_dev_mutex);
@@ -109,16 +109,12 @@ struct atm_dev *atm_dev_register(const char *type, const struct atmdev_ops *ops,
 	atomic_set(&dev->refcnt, 1);
 
 	if (atm_proc_dev_register(dev) < 0) {
-		printk(KERN_ERR "atm_dev_register: "
-		       "atm_proc_dev_register failed for dev %s\n",
-		       type);
+		pr_err("atm_proc_dev_register failed for dev %s\n", type);
 		goto out_fail;
 	}
 
 	if (atm_register_sysfs(dev) < 0) {
-		printk(KERN_ERR "atm_dev_register: "
-		       "atm_register_sysfs failed for dev %s\n",
-		       type);
+		pr_err("atm_register_sysfs failed for dev %s\n", type);
 		atm_proc_dev_deregister(dev);
 		goto out_fail;
 	}
diff --git a/net/atm/signaling.c b/net/atm/signaling.c
index 2299214..28df4ed 100644
--- a/net/atm/signaling.c
+++ b/net/atm/signaling.c
@@ -2,6 +2,7 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
 #include <linux/errno.h>	/* error codes */
 #include <linux/kernel.h>	/* printk */
@@ -37,14 +38,14 @@ static void sigd_put_skb(struct sk_buff *skb)
 	add_wait_queue(&sigd_sleep,&wait);
 	while (!sigd) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
-		pr_debug("atmsvc: waiting for signaling demon...\n");
+		pr_debug("atmsvc: waiting for signaling daemon...\n");
 		schedule();
 	}
 	current->state = TASK_RUNNING;
 	remove_wait_queue(&sigd_sleep,&wait);
 #else
 	if (!sigd) {
-		pr_debug("atmsvc: no signaling demon\n");
+		pr_debug("atmsvc: no signaling daemon\n");
 		kfree_skb(skb);
 		return;
 	}
@@ -90,8 +91,7 @@ static int sigd_send(struct atm_vcc *vcc,struct sk_buff *skb)
 	msg = (struct atmsvc_msg *) skb->data;
 	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	vcc = *(struct atm_vcc **) &msg->vcc;
-	pr_debug("sigd_send %d (0x%lx)\n",(int) msg->type,
-	  (unsigned long) vcc);
+	pr_debug("%d (0x%lx)\n", (int)msg->type, (unsigned long)vcc);
 	sk = sk_atm(vcc);
 
 	switch (msg->type) {
@@ -150,8 +150,7 @@ as_indicate_complete:
 			clear_bit(ATM_VF_WAITING, &vcc->flags);
 			break;
 		default:
-			printk(KERN_ALERT "sigd_send: bad message type %d\n",
-			    (int) msg->type);
+			pr_alert("bad message type %d\n", (int)msg->type);
 			return -EINVAL;
 	}
 	sk->sk_state_change(sk);
@@ -169,7 +168,7 @@ void sigd_enq2(struct atm_vcc *vcc,enum atmsvc_msg_type type,
 	struct atmsvc_msg *msg;
 	static unsigned session = 0;
 
-	pr_debug("sigd_enq %d (0x%p)\n",(int) type,vcc);
+	pr_debug("%d (0x%p)\n", (int)type, vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg),GFP_KERNEL)))
 		schedule();
 	msg = (struct atmsvc_msg *) skb_put(skb,sizeof(struct atmsvc_msg));
@@ -219,10 +218,10 @@ static void sigd_close(struct atm_vcc *vcc)
 	struct sock *s;
 	int i;
 
-	pr_debug("sigd_close\n");
+	pr_debug("\n");
 	sigd = NULL;
 	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
-		printk(KERN_ERR "sigd_close: closing with requests pending\n");
+		pr_err("closing with requests pending\n");
 	skb_queue_purge(&sk_atm(vcc)->sk_receive_queue);
 
 	read_lock(&vcc_sklist_lock);
@@ -256,7 +255,7 @@ static struct atm_dev sigd_dev = {
 int sigd_attach(struct atm_vcc *vcc)
 {
 	if (sigd) return -EADDRINUSE;
-	pr_debug("sigd_attach\n");
+	pr_debug("\n");
 	sigd = vcc;
 	vcc->dev = &sigd_dev;
 	vcc_insert_socket(sk_atm(vcc));
diff --git a/net/atm/svc.c b/net/atm/svc.c
index 66e1d9b..251ddbc 100644
--- a/net/atm/svc.c
+++ b/net/atm/svc.c
@@ -2,6 +2,7 @@
 
 /* Written 1995-2000 by Werner Almesberger, EPFL LRC/ICA */
 
+#define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
 
 #include <linux/string.h>
 #include <linux/net.h>		/* struct socket, struct proto_ops */
@@ -46,7 +47,7 @@ static void svc_disconnect(struct atm_vcc *vcc)
 	struct sk_buff *skb;
 	struct sock *sk = sk_atm(vcc);
 
-	pr_debug("svc_disconnect %p\n",vcc);
+	pr_debug("%p\n",vcc);
 	if (test_bit(ATM_VF_REGIS,&vcc->flags)) {
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc,as_close,NULL,NULL,NULL);
@@ -76,7 +77,7 @@ static int svc_release(struct socket *sock)
 
 	if (sk)  {
 		vcc = ATM_SD(sock);
-		pr_debug("svc_release %p\n", vcc);
+		pr_debug("%p\n", vcc);
 		clear_bit(ATM_VF_READY, &vcc->flags);
 		/* VCC pointer is used as a reference, so we must not free it
 		   (thereby subjecting it to re-use) before all pending connections
@@ -153,7 +154,7 @@ static int svc_connect(struct socket *sock,struct sockaddr *sockaddr,
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	pr_debug("svc_connect %p\n",vcc);
+	pr_debug("%p\n",vcc);
 	lock_sock(sk);
 	if (sockaddr_len != sizeof(struct sockaddr_atmsvc)) {
 		error = -EINVAL;
@@ -286,7 +287,7 @@ static int svc_listen(struct socket *sock,int backlog)
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	pr_debug("svc_listen %p\n",vcc);
+	pr_debug("%p\n", vcc);
 	lock_sock(sk);
 	/* let server handle listen on unbound sockets */
 	if (test_bit(ATM_VF_SESSION,&vcc->flags)) {
@@ -336,7 +337,7 @@ static int svc_accept(struct socket *sock,struct socket *newsock,int flags)
 
 	new_vcc = ATM_SD(newsock);
 
-	pr_debug("svc_accept %p -> %p\n",old_vcc,new_vcc);
+	pr_debug("%p -> %p\n", old_vcc, new_vcc);
 	while (1) {
 		DEFINE_WAIT(wait);
 
@@ -540,7 +541,7 @@ static int svc_addparty(struct socket *sock, struct sockaddr *sockaddr,
 		error = -EINPROGRESS;
 		goto out;
 	}
-	pr_debug("svc_addparty added wait queue\n");
+	pr_debug("added wait queue\n");
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
-- 
1.6.6.rc0.57.gad7a


From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] atm: replace DPRINTK() with pr_debug
Date: Fri, 17 Aug 2007 18:31:31 -0700
Message-ID: <20070817183131.05c3a9fb@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-atm-general@lists.sourceforge.net, netdev@vger.kernel.org
To: chas williams <chas@cmf.nrl.navy.mil>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43029 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751975AbXHRBcD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Aug 2007 21:32:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Get rid of using DPRINTK macro in ATM and use pr_debug (in kernel.h).
Using the standard macro is cleaner and forces code to check for bad arguments
and formatting.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/atm/clip.c	2007-08-17 15:05:49.000000000 -0400
+++ b/net/atm/clip.c	2007-08-17 15:06:26.000000000 -0400
@@ -40,14 +40,6 @@
 #include "resources.h"
 #include <net/atmclip.h>
 
-
-#if 0
-#define DPRINTK(format,args...) printk(format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
-
 static struct net_device *clip_devs;
 static struct atm_vcc *atmarpd;
 static struct neigh_table clip_tbl;
@@ -59,7 +51,7 @@ static int to_atmarpd(enum atmarp_ctrl_t
 	struct atmarp_ctrl *ctrl;
 	struct sk_buff *skb;
 
-	DPRINTK("to_atmarpd(%d)\n", type);
+	pr_debug("to_atmarpd(%d)\n", type);
 	if (!atmarpd)
 		return -EUNATCH;
 	skb = alloc_skb(sizeof(struct atmarp_ctrl),GFP_ATOMIC);
@@ -79,7 +71,7 @@ static int to_atmarpd(enum atmarp_ctrl_t
 
 static void link_vcc(struct clip_vcc *clip_vcc, struct atmarp_entry *entry)
 {
-	DPRINTK("link_vcc %p to entry %p (neigh %p)\n", clip_vcc, entry,
+	pr_debug("link_vcc %p to entry %p (neigh %p)\n", clip_vcc, entry,
 		entry->neigh);
 	clip_vcc->entry = entry;
 	clip_vcc->xoff = 0;	/* @@@ may overrun buffer by one packet */
@@ -134,7 +126,7 @@ static int neigh_check_cb(struct neighbo
 		unsigned long exp = cv->last_use + cv->idle_timeout;
 
 		if (cv->idle_timeout && time_after(jiffies, exp)) {
-			DPRINTK("releasing vcc %p->%p of entry %p\n",
+			pr_debug("releasing vcc %p->%p of entry %p\n",
 				cv, cv->vcc, entry);
 			vcc_release_async(cv->vcc, -ETIMEDOUT);
 		}
@@ -146,7 +138,7 @@ static int neigh_check_cb(struct neighbo
 	if (atomic_read(&n->refcnt) > 1) {
 		struct sk_buff *skb;
 
-		DPRINTK("destruction postponed with ref %d\n",
+		pr_debug("destruction postponed with ref %d\n",
 			atomic_read(&n->refcnt));
 
 		while ((skb = skb_dequeue(&n->arp_queue)) != NULL)
@@ -155,7 +147,7 @@ static int neigh_check_cb(struct neighbo
 		return 0;
 	}
 
-	DPRINTK("expired neigh %p\n", n);
+	pr_debug("expired neigh %p\n", n);
 	return 1;
 }
 
@@ -171,14 +163,14 @@ static int clip_arp_rcv(struct sk_buff *
 {
 	struct atm_vcc *vcc;
 
-	DPRINTK("clip_arp_rcv\n");
+	pr_debug("clip_arp_rcv\n");
 	vcc = ATM_SKB(skb)->vcc;
 	if (!vcc || !atm_charge(vcc, skb->truesize)) {
 		dev_kfree_skb_any(skb);
 		return 0;
 	}
-	DPRINTK("pushing to %p\n", vcc);
-	DPRINTK("using %p\n", CLIP_VCC(vcc)->old_push);
+	pr_debug("pushing to %p\n", vcc);
+	pr_debug("using %p\n", CLIP_VCC(vcc)->old_push);
 	CLIP_VCC(vcc)->old_push(vcc, skb);
 	return 0;
 }
@@ -196,9 +188,9 @@ static void clip_push(struct atm_vcc *vc
 {
 	struct clip_vcc *clip_vcc = CLIP_VCC(vcc);
 
-	DPRINTK("clip push\n");
+	pr_debug("clip push\n");
 	if (!skb) {
-		DPRINTK("removing VCC %p\n", clip_vcc);
+		pr_debug("removing VCC %p\n", clip_vcc);
 		if (clip_vcc->entry)
 			unlink_clip_vcc(clip_vcc);
 		clip_vcc->old_push(vcc, NULL);	/* pass on the bad news */
@@ -247,7 +239,7 @@ static void clip_pop(struct atm_vcc *vcc
 	int old;
 	unsigned long flags;
 
-	DPRINTK("clip_pop(vcc %p)\n", vcc);
+	pr_debug("clip_pop(vcc %p)\n", vcc);
 	clip_vcc->old_pop(vcc, skb);
 	/* skb->dev == NULL in outbound ARP packets */
 	if (!dev)
@@ -263,7 +255,7 @@ static void clip_pop(struct atm_vcc *vcc
 
 static void clip_neigh_solicit(struct neighbour *neigh, struct sk_buff *skb)
 {
-	DPRINTK("clip_neigh_solicit (neigh %p, skb %p)\n", neigh, skb);
+	pr_debug("clip_neigh_solicit (neigh %p, skb %p)\n", neigh, skb);
 	to_atmarpd(act_need, PRIV(neigh->dev)->number, NEIGH2ENTRY(neigh)->ip);
 }
 
@@ -292,7 +284,7 @@ static int clip_constructor(struct neigh
 	struct in_device *in_dev;
 	struct neigh_parms *parms;
 
-	DPRINTK("clip_constructor (neigh %p, entry %p)\n", neigh, entry);
+	pr_debug("clip_constructor (neigh %p, entry %p)\n", neigh, entry);
 	neigh->type = inet_addr_type(entry->ip);
 	if (neigh->type != RTN_UNICAST)
 		return -EINVAL;
@@ -376,7 +368,7 @@ static int clip_start_xmit(struct sk_buf
 	int old;
 	unsigned long flags;
 
-	DPRINTK("clip_start_xmit (skb %p)\n", skb);
+	pr_debug("clip_start_xmit (skb %p)\n", skb);
 	if (!skb->dst) {
 		printk(KERN_ERR "clip_start_xmit: skb->dst == NULL\n");
 		dev_kfree_skb(skb);
@@ -412,9 +404,9 @@ static int clip_start_xmit(struct sk_buf
 		}
 		return 0;
 	}
-	DPRINTK("neigh %p, vccs %p\n", entry, entry->vccs);
+	pr_debug("neigh %p, vccs %p\n", entry, entry->vccs);
 	ATM_SKB(skb)->vcc = vcc = entry->vccs->vcc;
-	DPRINTK("using neighbour %p, vcc %p\n", skb->dst->neighbour, vcc);
+	pr_debug("using neighbour %p, vcc %p\n", skb->dst->neighbour, vcc);
 	if (entry->vccs->encap) {
 		void *here;
 
@@ -425,7 +417,7 @@ static int clip_start_xmit(struct sk_buf
 	atomic_add(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = vcc->atm_options;
 	entry->vccs->last_use = jiffies;
-	DPRINTK("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, vcc, vcc->dev);
+	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, vcc, vcc->dev);
 	old = xchg(&entry->vccs->xoff, 1);	/* assume XOFF ... */
 	if (old) {
 		printk(KERN_WARNING "clip_start_xmit: XOFF->XOFF transition\n");
@@ -468,7 +460,7 @@ static int clip_mkip(struct atm_vcc *vcc
 	clip_vcc = kmalloc(sizeof(struct clip_vcc), GFP_KERNEL);
 	if (!clip_vcc)
 		return -ENOMEM;
-	DPRINTK("mkip clip_vcc %p vcc %p\n", clip_vcc, vcc);
+	pr_debug("mkip clip_vcc %p vcc %p\n", clip_vcc, vcc);
 	clip_vcc->vcc = vcc;
 	vcc->user_back = clip_vcc;
 	set_bit(ATM_VF_IS_CLIP, &vcc->flags);
@@ -538,7 +530,7 @@ static int clip_setentry(struct atm_vcc 
 			printk(KERN_ERR "hiding hidden ATMARP entry\n");
 			return 0;
 		}
-		DPRINTK("setentry: remove\n");
+		pr_debug("setentry: remove\n");
 		unlink_clip_vcc(clip_vcc);
 		return 0;
 	}
@@ -552,9 +544,9 @@ static int clip_setentry(struct atm_vcc 
 	entry = NEIGH2ENTRY(neigh);
 	if (entry != clip_vcc->entry) {
 		if (!clip_vcc->entry)
-			DPRINTK("setentry: add\n");
+			pr_debug("setentry: add\n");
 		else {
-			DPRINTK("setentry: update\n");
+			pr_debug("setentry: update\n");
 			unlink_clip_vcc(clip_vcc);
 		}
 		link_vcc(clip_vcc, entry);
@@ -611,7 +603,7 @@ static int clip_create(int number)
 	}
 	clip_priv->next = clip_devs;
 	clip_devs = dev;
-	DPRINTK("registered (net:%s)\n", dev->name);
+	pr_debug("registered (net:%s)\n", dev->name);
 	return number;
 }
 
@@ -631,16 +623,16 @@ static int clip_device_event(struct noti
 
 	switch (event) {
 	case NETDEV_UP:
-		DPRINTK("clip_device_event NETDEV_UP\n");
+		pr_debug("clip_device_event NETDEV_UP\n");
 		to_atmarpd(act_up, PRIV(dev)->number, 0);
 		break;
 	case NETDEV_GOING_DOWN:
-		DPRINTK("clip_device_event NETDEV_DOWN\n");
+		pr_debug("clip_device_event NETDEV_DOWN\n");
 		to_atmarpd(act_down, PRIV(dev)->number, 0);
 		break;
 	case NETDEV_CHANGE:
 	case NETDEV_CHANGEMTU:
-		DPRINTK("clip_device_event NETDEV_CHANGE*\n");
+		pr_debug("clip_device_event NETDEV_CHANGE*\n");
 		to_atmarpd(act_change, PRIV(dev)->number, 0);
 		break;
 	}
@@ -681,14 +673,14 @@ static struct notifier_block clip_inet_n
 
 static void atmarpd_close(struct atm_vcc *vcc)
 {
-	DPRINTK("atmarpd_close\n");
+	pr_debug("atmarpd_close\n");
 
 	rtnl_lock();
 	atmarpd = NULL;
 	skb_queue_purge(&sk_atm(vcc)->sk_receive_queue);
 	rtnl_unlock();
 
-	DPRINTK("(done)\n");
+	pr_debug("(done)\n");
 	module_put(THIS_MODULE);
 }
 
--- a/net/atm/br2684.c	2007-08-17 15:06:14.000000000 -0400
+++ b/net/atm/br2684.c	2007-08-17 15:07:22.000000000 -0400
@@ -24,12 +24,6 @@ Author: Marcell GAL, 2000, XDSL Ltd, Hun
 
 #include "common.h"
 
-#ifdef DEBUG
-#define DPRINTK(format, args...) printk(KERN_DEBUG "br2684: " format, ##args)
-#else
-#define DPRINTK(format, args...)
-#endif
-
 #ifdef SKB_DEBUG
 static void skb_debug(const struct sk_buff *skb)
 {
@@ -162,7 +156,7 @@ static int br2684_xmit_vcc(struct sk_buf
 	skb_debug(skb);
 
 	ATM_SKB(skb)->vcc = atmvcc = brvcc->atmvcc;
-	DPRINTK("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
+	pr_debug("atm_skb(%p)->vcc(%p)->dev(%p)\n", skb, atmvcc, atmvcc->dev);
 	if (!atm_may_send(atmvcc, skb->truesize)) {
 		/* we free this here for now, because we cannot know in a higher
 			layer whether the skb point it supplied wasn't freed yet.
@@ -191,11 +185,11 @@ static int br2684_start_xmit(struct sk_b
 	struct br2684_dev *brdev = BRPRIV(dev);
 	struct br2684_vcc *brvcc;
 
-	DPRINTK("br2684_start_xmit, skb->dst=%p\n", skb->dst);
+	pr_debug("br2684_start_xmit, skb->dst=%p\n", skb->dst);
 	read_lock(&devs_lock);
 	brvcc = pick_outgoing_vcc(skb, brdev);
 	if (brvcc == NULL) {
-		DPRINTK("no vcc attached to dev %s\n", dev->name);
+		pr_debug("no vcc attached to dev %s\n", dev->name);
 		brdev->stats.tx_errors++;
 		brdev->stats.tx_carrier_errors++;
 		/* netif_stop_queue(dev); */
@@ -221,7 +215,7 @@ static int br2684_start_xmit(struct sk_b
 
 static struct net_device_stats *br2684_get_stats(struct net_device *dev)
 {
-	DPRINTK("br2684_get_stats\n");
+	pr_debug("br2684_get_stats\n");
 	return &BRPRIV(dev)->stats;
 }
 
@@ -290,7 +284,7 @@ packet_fails_filter(__be16 type, struct 
 
 static void br2684_close_vcc(struct br2684_vcc *brvcc)
 {
-	DPRINTK("removing VCC %p from dev %p\n", brvcc, brvcc->device);
+	pr_debug("removing VCC %p from dev %p\n", brvcc, brvcc->device);
 	write_lock_irq(&devs_lock);
 	list_del(&brvcc->brvccs);
 	write_unlock_irq(&devs_lock);
@@ -308,7 +302,7 @@ static void br2684_push(struct atm_vcc *
 	struct br2684_dev *brdev = BRPRIV(net_dev);
 	int plen = sizeof(llc_oui_pid_pad) + ETH_HLEN;
 
-	DPRINTK("br2684_push\n");
+	pr_debug("br2684_push\n");
 
 	if (unlikely(skb == NULL)) {
 		/* skb==NULL means VCC is being destroyed */
@@ -325,7 +319,7 @@ static void br2684_push(struct atm_vcc *
 
 	skb_debug(skb);
 	atm_return(atmvcc, skb->truesize);
-	DPRINTK("skb from brdev %p\n", brdev);
+	pr_debug("skb from brdev %p\n", brdev);
 	if (brvcc->encaps == e_llc) {
 		/* let us waste some time for checking the encapsulation.
 		   Note, that only 7 char is checked so frames with a valid FCS
@@ -366,7 +360,7 @@ static void br2684_push(struct atm_vcc *
 #endif /* CONFIG_ATM_BR2684_IPFILTER */
 	skb->dev = net_dev;
 	ATM_SKB(skb)->vcc = atmvcc;	/* needed ? */
-	DPRINTK("received packet's protocol: %x\n", ntohs(skb->protocol));
+	pr_debug("received packet's protocol: %x\n", ntohs(skb->protocol));
 	skb_debug(skb);
 	if (unlikely(!(net_dev->flags & IFF_UP))) {
 		/* sigh, interface is down */
@@ -424,7 +418,7 @@ Note: we do not have explicit unassign, 
 		err = -EINVAL;
 		goto error;
 	}
-	DPRINTK("br2684_regvcc vcc=%p, encaps=%d, brvcc=%p\n", atmvcc, be.encaps,
+	pr_debug("br2684_regvcc vcc=%p, encaps=%d, brvcc=%p\n", atmvcc, be.encaps,
 		brvcc);
 	if (list_empty(&brdev->brvccs) && !brdev->mac_was_set) {
 		unsigned char *esi = atmvcc->dev->esi;
@@ -496,7 +490,7 @@ static int br2684_create(void __user *ar
 	struct br2684_dev *brdev;
 	struct atm_newif_br2684 ni;
 
-	DPRINTK("br2684_create\n");
+	pr_debug("br2684_create\n");
 
 	if (copy_from_user(&ni, arg, sizeof ni)) {
 		return -EFAULT;
@@ -513,7 +507,7 @@ static int br2684_create(void __user *ar
 
 	brdev = BRPRIV(netdev);
 
-	DPRINTK("registered netdev %s\n", netdev->name);
+	pr_debug("registered netdev %s\n", netdev->name);
 	/* open, stop, do_ioctl ? */
 	err = register_netdev(netdev);
 	if (err < 0) {
--- a/net/atm/common.c	2007-08-06 04:26:48.000000000 -0400
+++ b/net/atm/common.c	2007-08-17 15:08:31.000000000 -0400
@@ -30,13 +30,6 @@
 #include "addr.h"		/* address registry */
 #include "signaling.h"		/* for WAITING and sigd_attach */
 
-
-#if 0
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
 struct hlist_head vcc_hash[VCC_HTABLE_SIZE];
 DEFINE_RWLOCK(vcc_sklist_lock);
 
@@ -70,13 +63,13 @@ static struct sk_buff *alloc_tx(struct a
 	struct sock *sk = sk_atm(vcc);
 
 	if (atomic_read(&sk->sk_wmem_alloc) && !atm_may_send(vcc, size)) {
-		DPRINTK("Sorry: wmem_alloc = %d, size = %d, sndbuf = %d\n",
+		pr_debug("Sorry: wmem_alloc = %d, size = %d, sndbuf = %d\n",
 			atomic_read(&sk->sk_wmem_alloc), size,
 			sk->sk_sndbuf);
 		return NULL;
 	}
 	while (!(skb = alloc_skb(size,GFP_KERNEL))) schedule();
-	DPRINTK("AlTx %d += %d\n", atomic_read(&sk->sk_wmem_alloc),
+	pr_debug("AlTx %d += %d\n", atomic_read(&sk->sk_wmem_alloc),
 		skb->truesize);
 	atomic_add(skb->truesize, &sk->sk_wmem_alloc);
 	return skb;
@@ -392,10 +385,10 @@ static int __vcc_connect(struct atm_vcc 
 	if (!error) error = adjust_tp(&vcc->qos.rxtp,vcc->qos.aal);
 	if (error)
 		goto fail;
-	DPRINTK("VCC %d.%d, AAL %d\n",vpi,vci,vcc->qos.aal);
-	DPRINTK("  TX: %d, PCR %d..%d, SDU %d\n",vcc->qos.txtp.traffic_class,
+	pr_debug("VCC %d.%d, AAL %d\n",vpi,vci,vcc->qos.aal);
+	pr_debug("  TX: %d, PCR %d..%d, SDU %d\n",vcc->qos.txtp.traffic_class,
 	    vcc->qos.txtp.min_pcr,vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu);
-	DPRINTK("  RX: %d, PCR %d..%d, SDU %d\n",vcc->qos.rxtp.traffic_class,
+	pr_debug("  RX: %d, PCR %d..%d, SDU %d\n",vcc->qos.rxtp.traffic_class,
 	    vcc->qos.rxtp.min_pcr,vcc->qos.rxtp.max_pcr,vcc->qos.rxtp.max_sdu);
 
 	if (dev->ops->open) {
@@ -420,7 +413,7 @@ int vcc_connect(struct socket *sock, int
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	DPRINTK("vcc_connect (vpi %d, vci %d)\n",vpi,vci);
+	pr_debug("vcc_connect (vpi %d, vci %d)\n",vpi,vci);
 	if (sock->state == SS_CONNECTED)
 		return -EISCONN;
 	if (sock->state != SS_UNCONNECTED)
@@ -433,7 +426,7 @@ int vcc_connect(struct socket *sock, int
 	else
 		if (test_bit(ATM_VF_PARTIAL,&vcc->flags))
 			return -EINVAL;
-	DPRINTK("vcc_connect (TX: cl %d,bw %d-%d,sdu %d; "
+	pr_debug("vcc_connect (TX: cl %d,bw %d-%d,sdu %d; "
 	    "RX: cl %d,bw %d-%d,sdu %d,AAL %s%d)\n",
 	    vcc->qos.txtp.traffic_class,vcc->qos.txtp.min_pcr,
 	    vcc->qos.txtp.max_pcr,vcc->qos.txtp.max_sdu,
@@ -504,7 +497,7 @@ int vcc_recvmsg(struct kiocb *iocb, stru
 	if (error)
 		return error;
 	sock_recv_timestamp(msg, sk, skb);
-	DPRINTK("RcvM %d -= %d\n", atomic_read(&sk->rmem_alloc), skb->truesize);
+	pr_debug("RcvM %d -= %d\n", atomic_read(&sk->rmem_alloc), skb->truesize);
 	atm_return(vcc, skb->truesize);
 	skb_free_datagram(sk, skb);
 	return copied;
--- a/net/atm/lec.c	2007-08-06 04:26:48.000000000 -0400
+++ b/net/atm/lec.c	2007-08-17 15:08:48.000000000 -0400
@@ -49,12 +49,6 @@ static unsigned char bridge_ula_lec[] = 
 #include "lec_arpc.h"
 #include "resources.h"
 
-#if 0
-#define DPRINTK printk
-#else
-#define DPRINTK(format,args...)
-#endif
-
 #define DUMP_PACKETS 0		/*
 				 * 0 = None,
 				 * 1 = 30 first bytes
@@ -274,7 +268,7 @@ static int lec_start_xmit(struct sk_buff
 	int i = 0;
 #endif /* DUMP_PACKETS >0 */
 
-	DPRINTK("lec_start_xmit called\n");
+	pr_debug("lec_start_xmit called\n");
 	if (!priv->lecd) {
 		printk("%s:No lecd attached\n", dev->name);
 		priv->stats.tx_errors++;
@@ -282,7 +276,7 @@ static int lec_start_xmit(struct sk_buff
 		return -EUNATCH;
 	}
 
-	DPRINTK("skbuff head:%lx data:%lx tail:%lx end:%lx\n",
+	pr_debug("skbuff head:%lx data:%lx tail:%lx end:%lx\n",
 		(long)skb->head, (long)skb->data, (long)skb_tail_pointer(skb),
 		(long)skb_end_pointer(skb));
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
@@ -293,7 +287,7 @@ static int lec_start_xmit(struct sk_buff
 	/* Make sure we have room for lec_id */
 	if (skb_headroom(skb) < 2) {
 
-		DPRINTK("lec_start_xmit: reallocating skb\n");
+		pr_debug("lec_start_xmit: reallocating skb\n");
 		skb2 = skb_realloc_headroom(skb, LEC_HEADER_LEN);
 		kfree_skb(skb);
 		if (skb2 == NULL)
@@ -374,22 +368,22 @@ static int lec_start_xmit(struct sk_buff
 #endif
 	entry = NULL;
 	vcc = lec_arp_resolve(priv, dst, is_rdesc, &entry);
-	DPRINTK("%s:vcc:%p vcc_flags:%x, entry:%p\n", dev->name,
+	pr_debug("%s:vcc:%p vcc_flags:%x, entry:%p\n", dev->name,
 		vcc, vcc ? vcc->flags : 0, entry);
 	if (!vcc || !test_bit(ATM_VF_READY, &vcc->flags)) {
 		if (entry && (entry->tx_wait.qlen < LEC_UNRES_QUE_LEN)) {
-			DPRINTK("%s:lec_start_xmit: queuing packet, ",
+			pr_debug("%s:lec_start_xmit: queuing packet, ",
 				dev->name);
-			DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
+			pr_debug("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
 				lec_h->h_dest[0], lec_h->h_dest[1],
 				lec_h->h_dest[2], lec_h->h_dest[3],
 				lec_h->h_dest[4], lec_h->h_dest[5]);
 			skb_queue_tail(&entry->tx_wait, skb);
 		} else {
-			DPRINTK
+			pr_debug
 			    ("%s:lec_start_xmit: tx queue full or no arp entry, dropping, ",
 			     dev->name);
-			DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
+			pr_debug("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
 				lec_h->h_dest[0], lec_h->h_dest[1],
 				lec_h->h_dest[2], lec_h->h_dest[3],
 				lec_h->h_dest[4], lec_h->h_dest[5]);
@@ -403,8 +397,8 @@ static int lec_start_xmit(struct sk_buff
 #endif /* DUMP_PACKETS > 0 */
 
 	while (entry && (skb2 = skb_dequeue(&entry->tx_wait))) {
-		DPRINTK("lec.c: emptying tx queue, ");
-		DPRINTK("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
+		pr_debug("lec.c: emptying tx queue, ");
+		pr_debug("MAC address 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
 			lec_h->h_dest[0], lec_h->h_dest[1], lec_h->h_dest[2],
 			lec_h->h_dest[3], lec_h->h_dest[4], lec_h->h_dest[5]);
 		lec_send(vcc, skb2, priv);
@@ -465,7 +459,7 @@ static int lec_atm_send(struct atm_vcc *
 	mesg = (struct atmlec_msg *)skb->data;
 	tmp = skb->data;
 	tmp += sizeof(struct atmlec_msg);
-	DPRINTK("%s: msg from zeppelin:%d\n", dev->name, mesg->type);
+	pr_debug("%s: msg from zeppelin:%d\n", dev->name, mesg->type);
 	switch (mesg->type) {
 	case l_set_mac_addr:
 		for (i = 0; i < 6; i++) {
@@ -501,9 +495,9 @@ static int lec_atm_send(struct atm_vcc *
 			       mesg->content.normal.atm_addr,
 			       mesg->content.normal.flag,
 			       mesg->content.normal.targetless_le_arp);
-		DPRINTK("lec: in l_arp_update\n");
+		pr_debug("lec: in l_arp_update\n");
 		if (mesg->sizeoftlvs != 0) {	/* LANE2 3.1.5 */
-			DPRINTK("lec: LANE2 3.1.5, got tlvs, size %d\n",
+			pr_debug("lec: LANE2 3.1.5, got tlvs, size %d\n",
 				mesg->sizeoftlvs);
 			lane2_associate_ind(dev, mesg->content.normal.mac_addr,
 					    tmp, mesg->sizeoftlvs);
@@ -545,7 +539,7 @@ static int lec_atm_send(struct atm_vcc *
 		{
 			struct net_bridge_fdb_entry *f;
 
-			DPRINTK
+			pr_debug
 			    ("%s: bridge zeppelin asks about 0x%02x:%02x:%02x:%02x:%02x:%02x\n",
 			     dev->name, mesg->content.proxy.mac_addr[0],
 			     mesg->content.proxy.mac_addr[1],
@@ -565,7 +559,7 @@ static int lec_atm_send(struct atm_vcc *
 				struct sk_buff *skb2;
 				struct sock *sk;
 
-				DPRINTK
+				pr_debug
 				    ("%s: entry found, responding to zeppelin\n",
 				     dev->name);
 				skb2 =
@@ -671,7 +665,7 @@ send_to_lecd(struct lec_priv *priv, atml
 	sk->sk_data_ready(sk, skb->len);
 
 	if (data != NULL) {
-		DPRINTK("lec: about to send %d bytes of data\n", data->len);
+		pr_debug("lec: about to send %d bytes of data\n", data->len);
 		atm_force_charge(priv->lecd, data->truesize);
 		skb_queue_tail(&sk->sk_receive_queue, data);
 		sk->sk_data_ready(sk, skb->len);
@@ -743,7 +737,7 @@ static void lec_push(struct atm_vcc *vcc
 	       vcc->vpi, vcc->vci);
 #endif
 	if (!skb) {
-		DPRINTK("%s: null skb\n", dev->name);
+		pr_debug("%s: null skb\n", dev->name);
 		lec_vcc_close(priv, vcc);
 		return;
 	}
@@ -767,7 +761,7 @@ static void lec_push(struct atm_vcc *vcc
 	if (memcmp(skb->data, lec_ctrl_magic, 4) == 0) {	/* Control frame, to daemon */
 		struct sock *sk = sk_atm(vcc);
 
-		DPRINTK("%s: To daemon\n", dev->name);
+		pr_debug("%s: To daemon\n", dev->name);
 		skb_queue_tail(&sk->sk_receive_queue, skb);
 		sk->sk_data_ready(sk, skb->len);
 	} else {		/* Data frame, queue to protocol handlers */
@@ -781,7 +775,7 @@ static void lec_push(struct atm_vcc *vcc
 			 * Probably looping back, or if lecd is missing,
 			 * lecd has gone down
 			 */
-			DPRINTK("Ignoring frame...\n");
+			pr_debug("Ignoring frame...\n");
 			dev_kfree_skb(skb);
 			return;
 		}
@@ -1443,9 +1437,9 @@ static void lane2_associate_ind(struct n
 #include <net/route.h>
 
 #if 0
-#define DPRINTK(format,args...)
+#define pr_debug(format,args...)
 /*
-#define DPRINTK printk
+#define pr_debug printk
 */
 #endif
 #define DEBUG_ARP_TABLE 0
@@ -1514,7 +1508,7 @@ lec_arp_add(struct lec_priv *priv, struc
 	tmp = &priv->lec_arp_tables[HASH(entry->mac_addr[ETH_ALEN - 1])];
 	hlist_add_head(&entry->next, tmp);
 
-	DPRINTK("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
+	pr_debug("LEC_ARP: Added entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
 		0xff & entry->mac_addr[0], 0xff & entry->mac_addr[1],
 		0xff & entry->mac_addr[2], 0xff & entry->mac_addr[3],
 		0xff & entry->mac_addr[4], 0xff & entry->mac_addr[5]);
@@ -1556,7 +1550,7 @@ lec_arp_remove(struct lec_priv *priv, st
 	}
 	skb_queue_purge(&to_remove->tx_wait);	/* FIXME: good place for this? */
 
-	DPRINTK("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
+	pr_debug("LEC_ARP: Removed entry:%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
 		0xff & to_remove->mac_addr[0], 0xff & to_remove->mac_addr[1],
 		0xff & to_remove->mac_addr[2], 0xff & to_remove->mac_addr[3],
 		0xff & to_remove->mac_addr[4], 0xff & to_remove->mac_addr[5]);
@@ -1778,7 +1772,7 @@ static struct lec_arp_table *lec_arp_fin
 	struct hlist_head *head;
 	struct lec_arp_table *entry;
 
-	DPRINTK("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
+	pr_debug("LEC_ARP: lec_arp_find :%2.2x %2.2x %2.2x %2.2x %2.2x %2.2x\n",
 		mac_addr[0] & 0xff, mac_addr[1] & 0xff, mac_addr[2] & 0xff,
 		mac_addr[3] & 0xff, mac_addr[4] & 0xff, mac_addr[5] & 0xff);
 
@@ -1820,7 +1814,7 @@ static void lec_arp_expire_arp(unsigned 
 
 	entry = (struct lec_arp_table *)data;
 
-	DPRINTK("lec_arp_expire_arp\n");
+	pr_debug("lec_arp_expire_arp\n");
 	if (entry->status == ESI_ARP_PENDING) {
 		if (entry->no_tries <= entry->priv->max_retry_count) {
 			if (entry->is_rdesc)
@@ -1844,7 +1838,7 @@ static void lec_arp_expire_vcc(unsigned 
 
 	del_timer(&to_remove->timer);
 
-	DPRINTK("LEC_ARP %p %p: lec_arp_expire_vcc vpi:%d vci:%d\n",
+	pr_debug("LEC_ARP %p %p: lec_arp_expire_vcc vpi:%d vci:%d\n",
 		to_remove, priv,
 		to_remove->vcc ? to_remove->recv_vcc->vpi : 0,
 		to_remove->vcc ? to_remove->recv_vcc->vci : 0);
@@ -1884,7 +1878,7 @@ static void lec_arp_check_expire(struct 
 	unsigned long time_to_check;
 	int i;
 
-	DPRINTK("lec_arp_check_expire %p\n", priv);
+	pr_debug("lec_arp_check_expire %p\n", priv);
 	now = jiffies;
 restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
@@ -1896,13 +1890,13 @@ restart:
 			else
 				time_to_check = priv->aging_time;
 
-			DPRINTK("About to expire: %lx - %lx > %lx\n",
+			pr_debug("About to expire: %lx - %lx > %lx\n",
 				now, entry->last_used, time_to_check);
 			if (time_after(now, entry->last_used + time_to_check)
 			    && !(entry->flags & LEC_PERMANENT_FLAG)
 			    && !(entry->mac_addr[0] & 0x01)) {	/* LANE2: 7.1.20 */
 				/* Remove entry */
-				DPRINTK("LEC:Entry timed out\n");
+				pr_debug("LEC:Entry timed out\n");
 				lec_arp_remove(priv, entry);
 				lec_arp_put(entry);
 			} else {
@@ -2000,7 +1994,7 @@ static struct atm_vcc *lec_arp_resolve(s
 		    entry->packets_flooded <
 		    priv->maximum_unknown_frame_count) {
 			entry->packets_flooded++;
-			DPRINTK("LEC_ARP: Flooding..\n");
+			pr_debug("LEC_ARP: Flooding..\n");
 			found = priv->mcast_vcc;
 			goto out;
 		}
@@ -2011,13 +2005,13 @@ static struct atm_vcc *lec_arp_resolve(s
 		 */
 		lec_arp_hold(entry);
 		*ret_entry = entry;
-		DPRINTK("lec: entry->status %d entry->vcc %p\n", entry->status,
+		pr_debug("lec: entry->status %d entry->vcc %p\n", entry->status,
 			entry->vcc);
 		found = NULL;
 	} else {
 		/* No matching entry was found */
 		entry = make_entry(priv, mac_to_find);
-		DPRINTK("LEC_ARP: Making entry\n");
+		pr_debug("LEC_ARP: Making entry\n");
 		if (!entry) {
 			found = priv->mcast_vcc;
 			goto out;
@@ -2054,7 +2048,7 @@ lec_addr_delete(struct lec_priv *priv, u
 	struct lec_arp_table *entry;
 	int i;
 
-	DPRINTK("lec_addr_delete\n");
+	pr_debug("lec_addr_delete\n");
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
 		hlist_for_each_entry_safe(entry, node, next, &priv->lec_arp_tables[i], next) {
@@ -2085,8 +2079,8 @@ lec_arp_update(struct lec_priv *priv, un
 	struct lec_arp_table *entry, *tmp;
 	int i;
 
-	DPRINTK("lec:%s", (targetless_le_arp) ? "targetless " : " ");
-	DPRINTK("lec_arp_update mac:%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
+	pr_debug("lec:%s", (targetless_le_arp) ? "targetless " : " ");
+	pr_debug("lec_arp_update mac:%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
 		mac_addr[0], mac_addr[1], mac_addr[2], mac_addr[3],
 		mac_addr[4], mac_addr[5]);
 
@@ -2123,7 +2117,7 @@ lec_arp_update(struct lec_priv *priv, un
 					entry->flags |= LEC_REMOTE_FLAG;
 				else
 					entry->flags &= ~LEC_REMOTE_FLAG;
-				DPRINTK("After update\n");
+				pr_debug("After update\n");
 				dump_arp_table(priv);
 				goto out;
 			}
@@ -2167,7 +2161,7 @@ lec_arp_update(struct lec_priv *priv, un
 		entry->status = ESI_VC_PENDING;
 		send_to_lecd(priv, l_svc_setup, entry->mac_addr, atm_addr, NULL);
 	}
-	DPRINTK("After update2\n");
+	pr_debug("After update2\n");
 	dump_arp_table(priv);
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
@@ -2190,7 +2184,7 @@ lec_vcc_added(struct lec_priv *priv, str
 	if (ioc_data->receive == 2) {
 		/* Vcc for Multicast Forward. No timer, LANEv2 7.1.20 and 2.3.5.3 */
 
-		DPRINTK("LEC_ARP: Attaching mcast forward\n");
+		pr_debug("LEC_ARP: Attaching mcast forward\n");
 #if 0
 		entry = lec_arp_find(priv, bus_mac);
 		if (!entry) {
@@ -2215,7 +2209,7 @@ lec_vcc_added(struct lec_priv *priv, str
 		 * Vcc which we don't want to make default vcc,
 		 * attach it anyway.
 		 */
-		DPRINTK
+		pr_debug
 		    ("LEC_ARP:Attaching data direct, not default: "
 		     "%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
 		     ioc_data->atm_addr[0], ioc_data->atm_addr[1],
@@ -2243,7 +2237,7 @@ lec_vcc_added(struct lec_priv *priv, str
 		dump_arp_table(priv);
 		goto out;
 	}
-	DPRINTK
+	pr_debug
 	    ("LEC_ARP:Attaching data direct, default: "
 	     "%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x%2.2x\n",
 	     ioc_data->atm_addr[0], ioc_data->atm_addr[1],
@@ -2261,8 +2255,8 @@ lec_vcc_added(struct lec_priv *priv, str
 			if (memcmp
 			    (ioc_data->atm_addr, entry->atm_addr,
 			     ATM_ESA_LEN) == 0) {
-				DPRINTK("LEC_ARP: Attaching data direct\n");
-				DPRINTK("Currently -> Vcc: %d, Rvcc:%d\n",
+				pr_debug("LEC_ARP: Attaching data direct\n");
+				pr_debug("Currently -> Vcc: %d, Rvcc:%d\n",
 					entry->vcc ? entry->vcc->vci : 0,
 					entry->recv_vcc ? entry->recv_vcc->
 					vci : 0);
@@ -2304,7 +2298,7 @@ lec_vcc_added(struct lec_priv *priv, str
 		}
 	}
 	if (found_entry) {
-		DPRINTK("After vcc was added\n");
+		pr_debug("After vcc was added\n");
 		dump_arp_table(priv);
 		goto out;
 	}
@@ -2324,7 +2318,7 @@ lec_vcc_added(struct lec_priv *priv, str
 	entry->timer.expires = jiffies + priv->vcc_timeout_period;
 	entry->timer.function = lec_arp_expire_vcc;
 	add_timer(&entry->timer);
-	DPRINTK("After vcc was added\n");
+	pr_debug("After vcc was added\n");
 	dump_arp_table(priv);
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
@@ -2337,7 +2331,7 @@ static void lec_flush_complete(struct le
 	struct lec_arp_table *entry;
 	int i;
 
-	DPRINTK("LEC:lec_flush_complete %lx\n", tran_id);
+	pr_debug("LEC:lec_flush_complete %lx\n", tran_id);
 restart:
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
 	for (i = 0; i < LEC_ARP_TABLE_SIZE; i++) {
@@ -2354,7 +2348,7 @@ restart:
 				entry->last_used = jiffies;
 				entry->status = ESI_FORWARD_DIRECT;
 				lec_arp_put(entry);
-				DPRINTK("LEC_ARP: Flushed\n");
+				pr_debug("LEC_ARP: Flushed\n");
 				goto restart;
 			}
 		}
@@ -2377,7 +2371,7 @@ lec_set_flush_tran_id(struct lec_priv *p
 		hlist_for_each_entry(entry, node, &priv->lec_arp_tables[i], next) {
 			if (!memcmp(atm_addr, entry->atm_addr, ATM_ESA_LEN)) {
 				entry->flush_tran_id = tran_id;
-				DPRINTK("Set flush transaction id to %lx for %p\n",
+				pr_debug("Set flush transaction id to %lx for %p\n",
 					tran_id, entry);
 			}
 		}
@@ -2428,7 +2422,7 @@ static void lec_vcc_close(struct lec_pri
 	struct lec_arp_table *entry;
 	int i;
 
-	DPRINTK("LEC_ARP: lec_vcc_close vpi:%d vci:%d\n", vcc->vpi, vcc->vci);
+	pr_debug("LEC_ARP: lec_vcc_close vpi:%d vci:%d\n", vcc->vpi, vcc->vci);
 	dump_arp_table(priv);
 
 	spin_lock_irqsave(&priv->lec_arp_lock, flags);
@@ -2511,7 +2505,7 @@ lec_arp_check_empties(struct lec_priv *p
 			goto out;
 		}
 	}
-	DPRINTK("LEC_ARP: Arp_check_empties: entry not found!\n");
+	pr_debug("LEC_ARP: Arp_check_empties: entry not found!\n");
 out:
 	spin_unlock_irqrestore(&priv->lec_arp_lock, flags);
 }
--- a/net/atm/pppoatm.c	2007-08-06 04:26:48.000000000 -0400
+++ b/net/atm/pppoatm.c	2007-08-17 15:09:26.000000000 -0400
@@ -46,13 +46,6 @@
 
 #include "common.h"
 
-#if 0
-#define DPRINTK(format, args...) \
-	printk(KERN_DEBUG "pppoatm: " format, ##args)
-#else
-#define DPRINTK(format, args...)
-#endif
-
 enum pppoatm_encaps {
 	e_autodetect = PPPOATM_ENCAPS_AUTODETECT,
 	e_vc = PPPOATM_ENCAPS_VC,
@@ -139,9 +132,9 @@ static void pppoatm_unassign_vcc(struct 
 static void pppoatm_push(struct atm_vcc *atmvcc, struct sk_buff *skb)
 {
 	struct pppoatm_vcc *pvcc = atmvcc_to_pvcc(atmvcc);
-	DPRINTK("pppoatm push\n");
+	pr_debug("pppoatm push\n");
 	if (skb == NULL) {			/* VCC was closed */
-		DPRINTK("removing ATMPPP VCC %p\n", pvcc);
+		pr_debug("removing ATMPPP VCC %p\n", pvcc);
 		pppoatm_unassign_vcc(atmvcc);
 		atmvcc->push(atmvcc, NULL);	/* Pass along bad news */
 		return;
@@ -172,7 +165,7 @@ static void pppoatm_push(struct atm_vcc 
 			pvcc->chan.mtu += LLC_LEN;
 			break;
 		}
-		DPRINTK("(unit %d): Couldn't autodetect yet "
+		pr_debug("(unit %d): Couldn't autodetect yet "
 		    "(skb: %02X %02X %02X %02X %02X %02X)\n",
 		    pvcc->chan.unit,
 		    skb->data[0], skb->data[1], skb->data[2],
@@ -202,7 +195,7 @@ static int pppoatm_send(struct ppp_chann
 {
 	struct pppoatm_vcc *pvcc = chan_to_pvcc(chan);
 	ATM_SKB(skb)->vcc = pvcc->atmvcc;
-	DPRINTK("(unit %d): pppoatm_send (skb=0x%p, vcc=0x%p)\n",
+	pr_debug("(unit %d): pppoatm_send (skb=0x%p, vcc=0x%p)\n",
 	    pvcc->chan.unit, skb, pvcc->atmvcc);
 	if (skb->data[0] == '\0' && (pvcc->flags & SC_COMP_PROT))
 		(void) skb_pull(skb, 1);
@@ -228,7 +221,7 @@ static int pppoatm_send(struct ppp_chann
 			goto nospace;
 		break;
 	case e_autodetect:
-		DPRINTK("(unit %d): Trying to send without setting encaps!\n",
+		pr_debug("(unit %d): Trying to send without setting encaps!\n",
 		    pvcc->chan.unit);
 		kfree_skb(skb);
 		return 1;
@@ -236,7 +229,7 @@ static int pppoatm_send(struct ppp_chann
 
 	atomic_add(skb->truesize, &sk_atm(ATM_SKB(skb)->vcc)->sk_wmem_alloc);
 	ATM_SKB(skb)->atm_options = ATM_SKB(skb)->vcc->atm_options;
-	DPRINTK("(unit %d): atm_skb(%p)->vcc(%p)->dev(%p)\n",
+	pr_debug("(unit %d): atm_skb(%p)->vcc(%p)->dev(%p)\n",
 	    pvcc->chan.unit, skb, ATM_SKB(skb)->vcc,
 	    ATM_SKB(skb)->vcc->dev);
 	return ATM_SKB(skb)->vcc->send(ATM_SKB(skb)->vcc, skb)
--- a/net/atm/raw.c	2007-08-06 04:26:48.000000000 -0400
+++ b/net/atm/raw.c	2007-08-17 15:09:41.000000000 -0400
@@ -13,14 +13,6 @@
 #include "common.h"
 #include "protocols.h"
 
-
-#if 0
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
-
 /*
  * SKB == NULL indicates that the link is being closed
  */
@@ -40,7 +32,7 @@ static void atm_pop_raw(struct atm_vcc *
 {
 	struct sock *sk = sk_atm(vcc);
 
-	DPRINTK("APopR (%d) %d -= %d\n", vcc->vci, sk->sk_wmem_alloc,
+	pr_debug("APopR (%d) %d -= %d\n", vcc->vci, sk->sk_wmem_alloc,
 		skb->truesize);
 	atomic_sub(skb->truesize, &sk->sk_wmem_alloc);
 	dev_kfree_skb_any(skb);
--- a/net/atm/signaling.c	2007-08-17 15:06:24.000000000 -0400
+++ b/net/atm/signaling.c	2007-08-17 15:10:02.000000000 -0400
@@ -23,13 +23,6 @@
 				   Danger: may cause nasty hangs if the demon
 				   crashes. */
 
-#if 0
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
-
 struct atm_vcc *sigd = NULL;
 #ifdef WAIT_FOR_DEMON
 static DECLARE_WAIT_QUEUE_HEAD(sigd_sleep);
@@ -44,14 +37,14 @@ static void sigd_put_skb(struct sk_buff 
 	add_wait_queue(&sigd_sleep,&wait);
 	while (!sigd) {
 		set_current_state(TASK_UNINTERRUPTIBLE);
-		DPRINTK("atmsvc: waiting for signaling demon...\n");
+		pr_debug("atmsvc: waiting for signaling demon...\n");
 		schedule();
 	}
 	current->state = TASK_RUNNING;
 	remove_wait_queue(&sigd_sleep,&wait);
 #else
 	if (!sigd) {
-		DPRINTK("atmsvc: no signaling demon\n");
+		pr_debug("atmsvc: no signaling demon\n");
 		kfree_skb(skb);
 		return;
 	}
@@ -96,7 +89,7 @@ static int sigd_send(struct atm_vcc *vcc
 
 	msg = (struct atmsvc_msg *) skb->data;
 	atomic_sub(skb->truesize, &sk_atm(vcc)->sk_wmem_alloc);
-	DPRINTK("sigd_send %d (0x%lx)\n",(int) msg->type,
+	pr_debug("sigd_send %d (0x%lx)\n",(int) msg->type,
 	  (unsigned long) msg->vcc);
 	vcc = *(struct atm_vcc **) &msg->vcc;
 	sk = sk_atm(vcc);
@@ -130,7 +123,7 @@ static int sigd_send(struct atm_vcc *vcc
 		case as_indicate:
 			vcc = *(struct atm_vcc **) &msg->listen_vcc;
 			sk = sk_atm(vcc);
-			DPRINTK("as_indicate!!!\n");
+			pr_debug("as_indicate!!!\n");
 			lock_sock(sk);
 			if (sk_acceptq_is_full(sk)) {
 				sigd_enq(NULL,as_reject,vcc,NULL,NULL);
@@ -139,7 +132,7 @@ static int sigd_send(struct atm_vcc *vcc
 			}
 			sk->sk_ack_backlog++;
 			skb_queue_tail(&sk->sk_receive_queue, skb);
-			DPRINTK("waking sk->sk_sleep 0x%p\n", sk->sk_sleep);
+			pr_debug("waking sk->sk_sleep 0x%p\n", sk->sk_sleep);
 			sk->sk_state_change(sk);
 as_indicate_complete:
 			release_sock(sk);
@@ -176,7 +169,7 @@ void sigd_enq2(struct atm_vcc *vcc,enum 
 	struct atmsvc_msg *msg;
 	static unsigned session = 0;
 
-	DPRINTK("sigd_enq %d (0x%p)\n",(int) type,vcc);
+	pr_debug("sigd_enq %d (0x%p)\n",(int) type,vcc);
 	while (!(skb = alloc_skb(sizeof(struct atmsvc_msg),GFP_KERNEL)))
 		schedule();
 	msg = (struct atmsvc_msg *) skb_put(skb,sizeof(struct atmsvc_msg));
@@ -226,7 +219,7 @@ static void sigd_close(struct atm_vcc *v
 	struct sock *s;
 	int i;
 
-	DPRINTK("sigd_close\n");
+	pr_debug("sigd_close\n");
 	sigd = NULL;
 	if (skb_peek(&sk_atm(vcc)->sk_receive_queue))
 		printk(KERN_ERR "sigd_close: closing with requests pending\n");
@@ -260,7 +253,7 @@ static struct atm_dev sigd_dev = {
 int sigd_attach(struct atm_vcc *vcc)
 {
 	if (sigd) return -EADDRINUSE;
-	DPRINTK("sigd_attach\n");
+	pr_debug("sigd_attach\n");
 	sigd = vcc;
 	vcc->dev = &sigd_dev;
 	vcc_insert_socket(sk_atm(vcc));
--- a/net/atm/svc.c	2007-08-06 04:26:48.000000000 -0400
+++ b/net/atm/svc.c	2007-08-17 15:09:11.000000000 -0400
@@ -25,17 +25,8 @@
 #include "signaling.h"
 #include "addr.h"
 
-
-#if 0
-#define DPRINTK(format,args...) printk(KERN_DEBUG format,##args)
-#else
-#define DPRINTK(format,args...)
-#endif
-
-
 static int svc_create(struct socket *sock,int protocol);
 
-
 /*
  * Note: since all this is still nicely synchronized with the signaling demon,
  *       there's no need to protect sleep loops with clis. If signaling is
@@ -55,7 +46,7 @@ static void svc_disconnect(struct atm_vc
 	struct sk_buff *skb;
 	struct sock *sk = sk_atm(vcc);
 
-	DPRINTK("svc_disconnect %p\n",vcc);
+	pr_debug("svc_disconnect %p\n",vcc);
 	if (test_bit(ATM_VF_REGIS,&vcc->flags)) {
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_UNINTERRUPTIBLE);
 		sigd_enq(vcc,as_close,NULL,NULL,NULL);
@@ -69,7 +60,7 @@ static void svc_disconnect(struct atm_vc
 	   as_indicate has been answered */
 	while ((skb = skb_dequeue(&sk->sk_receive_queue)) != NULL) {
 		atm_return(vcc, skb->truesize);
-		DPRINTK("LISTEN REL\n");
+		pr_debug("LISTEN REL\n");
 		sigd_enq2(NULL,as_reject,vcc,NULL,NULL,&vcc->qos,0);
 		dev_kfree_skb(skb);
 	}
@@ -85,7 +76,7 @@ static int svc_release(struct socket *so
 
 	if (sk)  {
 		vcc = ATM_SD(sock);
-		DPRINTK("svc_release %p\n", vcc);
+		pr_debug("svc_release %p\n", vcc);
 		clear_bit(ATM_VF_READY, &vcc->flags);
 		/* VCC pointer is used as a reference, so we must not free it
 		   (thereby subjecting it to re-use) before all pending connections
@@ -162,7 +153,7 @@ static int svc_connect(struct socket *so
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	DPRINTK("svc_connect %p\n",vcc);
+	pr_debug("svc_connect %p\n",vcc);
 	lock_sock(sk);
 	if (sockaddr_len != sizeof(struct sockaddr_atmsvc)) {
 		error = -EINVAL;
@@ -224,7 +215,7 @@ static int svc_connect(struct socket *so
 				prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);
 				continue;
 			}
-			DPRINTK("*ABORT*\n");
+			pr_debug("*ABORT*\n");
 			/*
 			 * This is tricky:
 			 *   Kernel ---close--> Demon
@@ -295,7 +286,7 @@ static int svc_listen(struct socket *soc
 	struct atm_vcc *vcc = ATM_SD(sock);
 	int error;
 
-	DPRINTK("svc_listen %p\n",vcc);
+	pr_debug("svc_listen %p\n",vcc);
 	lock_sock(sk);
 	/* let server handle listen on unbound sockets */
 	if (test_bit(ATM_VF_SESSION,&vcc->flags)) {
@@ -341,7 +332,7 @@ static int svc_accept(struct socket *soc
 
 	new_vcc = ATM_SD(newsock);
 
-	DPRINTK("svc_accept %p -> %p\n",old_vcc,new_vcc);
+	pr_debug("svc_accept %p -> %p\n",old_vcc,new_vcc);
 	while (1) {
 		DEFINE_WAIT(wait);
 
@@ -545,7 +536,7 @@ static int svc_addparty(struct socket *s
 		error = -EINPROGRESS;
 		goto out;
 	}
-	DPRINTK("svc_addparty added wait queue\n");
+	pr_debug("svc_addparty added wait queue\n");
 	while (test_bit(ATM_VF_WAITING, &vcc->flags) && sigd) {
 		schedule();
 		prepare_to_wait(sk->sk_sleep, &wait, TASK_INTERRUPTIBLE);

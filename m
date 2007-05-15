From: jamal <hadi@cyberus.ca>
Subject: [WIP] [PATCH] WAS Re: [RFC] New driver API to speed up small
	packets xmits
Date: Tue, 15 May 2007 18:17:47 -0400
Message-ID: <1179267467.4080.33.camel@localhost>
References: <adahcqdpz1p.fsf@cisco.com>
	 <OFF5654BB8.74EC8DCB-ON872572DC.00752079-882572DC.00756B23@us.ibm.com>
	 <20070515.143207.80029051.davem@davemloft.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-mvXijHHzJZLbciUMnjlg"
Cc: xma@us.ibm.com, rdreier@cisco.com, ak@suse.de, krkumar2@in.ibm.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org,
	ashwin.chaugule@celunite.com,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Gagan Arneja <gagan@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.229]:11894 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755873AbXEOWRx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2007 18:17:53 -0400
Received: by wx-out-0506.google.com with SMTP id h31so2092648wxd
        for <netdev@vger.kernel.org>; Tue, 15 May 2007 15:17:52 -0700 (PDT)
In-Reply-To: <20070515.143207.80029051.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-mvXijHHzJZLbciUMnjlg
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, 2007-15-05 at 14:32 -0700, David Miller wrote:
>  An efficient qdisc-->driver
> transfer during netif_wake_queue() could help solve some of that,
> as is being discussed here.

Ok, heres the approach i discussed at netconf.
It needs net-2.6 and the patch i posted earlier to clean up
qdisc_restart() [1].
I havent ported over all the bits from 2.6.18,  but this works.
Krishna and i have colluded privately on working together. I just need
to reproduce the patches, so here is the core.
A lot of the code in the core could be aggragated later - right now i am
worried about correctness.
I will post a patch for tun device in a few minutes
that i use to test on my laptop (i need to remove some debugs) to show
an example.
I also plan to post a patch for e1000 - but that will take more
than a few minutes.
the e1000 driver has changed quiet a bit since 2.6.18, so it is
consuming.

What does a driver need to do to get batched-to?

1) On initialization (probe probably)
 a) set NETIF_F_BTX in its dev->features at startup
 i.e dev->features |= NETIF_F_BTX
 b) initialize the batch queue i.e something like
skb_queue_head_init(&dev->blist);
c) set dev->xmit_win to something reasonable like
maybe half the DMA ring size or tx_queuelen

2) create a new method for batch txmit.
This loops on dev->blist and stashes onto hardware.
All return codes like NETDEV_TX_OK etc still apply.

3) set the dev->xmit_win which provides hints on how much
data to send from the core to the driver. Some suggestions:
a)on doing a netif_stop, set it to 1
b)on netif_wake_queue set it to the max available space

Of course, to work, all this requires that the driver to have a
threshold for waking up tx path; like  drivers such as e1000 or tg3 do
in order to invoke netif_wake_queue (example look at TX_WAKE_THRESHOLD
usage in e1000).


feedback welcome (preferably in the form of patches).

Anyone with a really nice tool to measure CPU improvement will help
a great deal in quantifying things. As i have said earlier, I never saw
any throughput improvement. But like T/GSO it may be just CPU savings
(as was suggested at netconf).

cheers,
jamal
[1] http://marc.info/?l=linux-netdev&m=117914954911959&w=2


--=-mvXijHHzJZLbciUMnjlg
Content-Disposition: attachment; filename=batch0
Content-Type: text/x-patch; name=batch0; charset=us-ascii
Content-Transfer-Encoding: 7bit

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index f671cd2..7205748 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -325,6 +325,7 @@ struct net_device
 #define NETIF_F_VLAN_CHALLENGED	1024	/* Device cannot handle VLAN packets */
 #define NETIF_F_GSO		2048	/* Enable software GSO. */
 #define NETIF_F_LLTX		4096	/* LockLess TX */
+#define NETIF_F_BTX		8192	/* Capable of batch tx */
 
 	/* Segmentation offload features */
 #define NETIF_F_GSO_SHIFT	16
@@ -450,6 +451,11 @@ struct net_device
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+	int			(*hard_batch_xmit) (struct sk_buff_head *list,
+						    struct net_device *dev);
+	int			(*hard_prep_xmit) (struct sk_buff *skb,
+						    struct net_device *dev);
+	int			xmit_win;
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -466,6 +472,10 @@ struct net_device
 	struct list_head	todo_list;
 	/* device index hash chain */
 	struct hlist_node	index_hlist;
+	/*XXX: Fix eventually to not allocate if device not
+	 *batch capable
+	*/
+	struct sk_buff_head	blist;
 
 	struct net_device	*link_watch_next;
 
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index ed80054..61fa301 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -85,10 +85,12 @@ static inline int
 do_dev_requeue(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
 {
 
-	if (unlikely(skb->next))
-		dev->gso_skb = skb;
-	else
-		q->ops->requeue(skb, q);
+	if (skb) {
+		if (unlikely(skb->next))
+			dev->gso_skb = skb;
+		else
+			q->ops->requeue(skb, q);
+	}
 	/* XXX: Could netif_schedule fail? Or is that fact we are
 	 * requeueing imply the hardware path is closed
 	 * and even if we fail, some interupt will wake us
@@ -116,7 +118,10 @@ tx_islocked(struct sk_buff *skb, struct net_device *dev, struct Qdisc *q)
 	int ret = handle_dev_cpu_collision(dev);
 
 	if (ret == SCHED_TX_DROP) {
-		kfree_skb(skb);
+		if (skb) /* we are not batching */
+			kfree_skb(skb);
+		else if (!skb_queue_empty(&dev->blist))
+			skb_queue_purge(&dev->blist);
 		return qdisc_qlen(q);
 	}
 
@@ -195,10 +200,99 @@ static inline int qdisc_restart(struct net_device *dev)
 	return do_dev_requeue(skb, dev, q);
 }
 
+static int try_get_tx_pkts(struct net_device *dev, struct Qdisc *q, int count)
+{
+	struct sk_buff *skb;
+	struct sk_buff_head *skbs = &dev->blist;
+	int tdq = count;
+
+	/* 
+	 * very unlikely, but who knows ..
+	 * If this happens we dont try to grab more pkts
+	 */
+	if (!skb_queue_empty(&dev->blist))
+		return skb_queue_len(&dev->blist);
+
+	if (dev->gso_skb) {
+		count--;
+		__skb_queue_head(skbs, dev->gso_skb);
+		dev->gso_skb = NULL;
+	}
+
+	while (count) {
+		skb = q->dequeue(q);
+		if (!skb)
+			break;
+		count--;
+		__skb_queue_head(skbs, skb);
+	}
+
+	return tdq - count;
+}
+
+static inline int try_tx_pkts(struct net_device *dev)
+{
+
+	return dev->hard_batch_xmit(&dev->blist, dev);
+
+}
+
+/* same comments as in qdisc_restart apply;
+ * at some point use shared code with qdisc_restart*/
+int batch_qdisc_restart(struct net_device *dev)
+{
+	struct Qdisc *q = dev->qdisc;
+	unsigned lockless = (dev->features & NETIF_F_LLTX);
+	int count = dev->xmit_win;
+	int ret = 0;
+
+	ret = try_get_tx_pkts(dev, q, count);
+
+	if (ret == 0)
+		return qdisc_qlen(q);
+
+	/* we have packets to send! */
+	if (!lockless) {
+		if (!netif_tx_trylock(dev))
+			return tx_islocked(NULL, dev, q);
+	}
+
+	/* all clear .. */
+	spin_unlock(&dev->queue_lock);
+
+	ret = NETDEV_TX_BUSY;
+	if (!netif_queue_stopped(dev))
+		ret = try_tx_pkts(dev);
+
+	if (!lockless)
+		netif_tx_unlock(dev);
+
+	spin_lock(&dev->queue_lock);
+
+	q = dev->qdisc;
+
+	/* most likely result, packet went ok */
+	if (ret == NETDEV_TX_OK)
+		return qdisc_qlen(q);
+	/* only for lockless drivers .. */
+	if (ret == NETDEV_TX_LOCKED && lockless)
+		return tx_islocked(NULL, dev, q);
+
+	if (unlikely(ret != NETDEV_TX_BUSY && net_ratelimit()))
+		printk(KERN_WARNING " BUG %s code %d qlen %d\n",
+		       dev->name, ret, q->q.qlen);
+
+	return do_dev_requeue(NULL, dev, q);
+}
+
 void __qdisc_run(struct net_device *dev)
 {
+	unsigned batching = (dev->features & NETIF_F_BTX);
+
 	do {
-		if (!qdisc_restart(dev))
+		if (!batching && !qdisc_restart(dev))
+			break;
+		else if (!batch_qdisc_restart(dev))
 			break;
 	} while (!netif_queue_stopped(dev));
 

--=-mvXijHHzJZLbciUMnjlg--


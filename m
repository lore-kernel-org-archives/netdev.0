From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/9 Rev3] [core] Add skb_blist & hard_start_xmit_batch
Date: Wed, 08 Aug 2007 15:01:35 +0530
Message-ID: <20070808093135.15396.29687.sendpatchset@localhost.localdomain>
References: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Cc: jagana@us.ibm.com, Robert.Olsson@data.slu.se, rick.jones2@hp.com,
	herbert@gondor.apana.org.au, gaagaan@gmail.com,
	kumarkr@linux.ibm.com, rdreier@cisco.com,
	peter.p.waskiewicz.jr@intel.com, mcarlson@broadcom.com,
	jeff@garzik.org, general@lists.openfabrics.org, mchan@broadcom.com,
	tgraf@suug.ch, hadi@cyberus.ca, netdev@vger.kernel.org,
	Krishna Kumar <krkumar2@in.ibm.com>, xma@us.ibm.com
To: johnpol@2ka.mipt.ru, sri@us.ibm.com,
	shemminger@linux-foundation.org, kaber@trash.net,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausmtp05.au.ibm.com ([202.81.18.154]:55257 "EHLO
	ausmtp05.au.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbXHHJay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Aug 2007 05:30:54 -0400
Received: from sd0109e.au.ibm.com (d23rh905.au.ibm.com [202.81.18.225])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l789Wtxj1781966
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:32:56 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0109e.au.ibm.com (8.13.8/8.13.8/NCO v8.4) with ESMTP id l789Y1KK091890
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:34:01 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l789UPkI020765
	for <netdev@vger.kernel.org>; Wed, 8 Aug 2007 19:30:28 +1000
In-Reply-To: <20070808093114.15396.22797.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce skb_blist and hard_start_xmit_batch API, handle driver's usage
of the new API, and add support routines.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 include/linux/netdevice.h |    8 +++
 net/core/dev.c            |   98 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 106 insertions(+)

diff -ruNp ORG/include/linux/netdevice.h NEW/include/linux/netdevice.h
--- ORG/include/linux/netdevice.h	2007-08-06 08:25:37.000000000 +0530
+++ NEW/include/linux/netdevice.h	2007-08-07 13:11:19.000000000 +0530
@@ -456,6 +456,9 @@ struct net_device
 	/* Partially transmitted GSO packet. */
 	struct sk_buff		*gso_skb;
 
+	/* List of batch skbs (optional, used if driver supports batching API */
+	struct sk_buff_head	*skb_blist;
+
 	/* ingress path synchronizer */
 	spinlock_t		ingress_lock;
 	struct Qdisc		*qdisc_ingress;
@@ -472,6 +475,9 @@ struct net_device
 	void			*priv;	/* pointer to private data	*/
 	int			(*hard_start_xmit) (struct sk_buff *skb,
 						    struct net_device *dev);
+	int			(*hard_start_xmit_batch) (struct net_device
+							  *dev);
+
 	/* These may be needed for future network-power-down code. */
 	unsigned long		trans_start;	/* Time (in jiffies) of last Tx	*/
 
@@ -832,6 +838,8 @@ extern int		dev_set_mac_address(struct n
 					    struct sockaddr *);
 extern int		dev_hard_start_xmit(struct sk_buff *skb,
 					    struct net_device *dev);
+extern int		dev_add_skb_to_blist(struct sk_buff *skb,
+					     struct net_device *dev);
 
 extern void		dev_init(void);
 
diff -ruNp ORG/net/core/dev.c NEW/net/core/dev.c
--- ORG/net/core/dev.c	2007-08-06 08:25:40.000000000 +0530
+++ NEW/net/core/dev.c	2007-08-07 13:11:19.000000000 +0530
@@ -897,6 +897,55 @@ void netdev_state_change(struct net_devi
 	}
 }
 
+static void free_batching(struct net_device *dev)
+{
+	if (dev->skb_blist) {
+		if (!skb_queue_empty(dev->skb_blist))
+			skb_queue_purge(dev->skb_blist);
+		kfree(dev->skb_blist);
+		dev->skb_blist = NULL;
+	}
+}
+
+int dev_change_tx_batch_skb(struct net_device *dev, unsigned long new_batch_skb)
+{
+	int ret = 0;
+	struct sk_buff_head *blist;
+
+	if (!dev->hard_start_xmit_batch) {
+		/* Driver doesn't support batching skb API */
+		ret = -ENOTSUPP;
+		goto out;
+	}
+
+	/* Handle invalid argument */
+	if (new_batch_skb < 0) {
+		ret = -EINVAL;
+		goto out;
+	}
+
+	/* Check if new value is same as the current */
+	if (!!dev->skb_blist == !!new_batch_skb)
+		goto out;
+
+	if (new_batch_skb &&
+	    (blist = kmalloc(sizeof *blist, GFP_KERNEL)) == NULL) {
+		ret = -ENOMEM;
+		goto out;
+	}
+
+	spin_lock(&dev->queue_lock);
+	if (new_batch_skb) {
+		skb_queue_head_init(blist);
+		dev->skb_blist = blist;
+	} else
+		free_batching(dev);
+	spin_unlock(&dev->queue_lock);
+
+out:
+	return ret;
+}
+
 /**
  *	dev_load 	- load a network module
  *	@name: name of interface
@@ -1459,6 +1508,45 @@ static int dev_gso_segment(struct sk_buf
 	return 0;
 }
 
+/*
+ * Add skb (skbs in case segmentation is required) to dev->skb_blist. We are
+ * holding QDISC RUNNING bit, so no one else can add to this list. Also, skbs
+ * are dequeued from this list when we call the driver, so the list is safe
+ * from simultaneous deletes too.
+ *
+ * Returns count of successful skb(s) added to skb_blist.
+ */
+int dev_add_skb_to_blist(struct sk_buff *skb, struct net_device *dev)
+{
+	if (!list_empty(&ptype_all))
+		dev_queue_xmit_nit(skb, dev);
+
+	if (netif_needs_gso(dev, skb)) {
+		if (unlikely(dev_gso_segment(skb))) {
+			kfree(skb);
+			return 0;
+		}
+
+		if (skb->next) {
+			int count = 0;
+
+			do {
+				struct sk_buff *nskb = skb->next;
+
+				skb->next = nskb->next;
+				__skb_queue_tail(dev->skb_blist, nskb);
+				count++;
+			} while (skb->next);
+
+			skb->destructor = DEV_GSO_CB(skb)->destructor;
+			kfree_skb(skb);
+			return count;
+		}
+	}
+	__skb_queue_tail(dev->skb_blist, skb);
+	return 1;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (likely(!skb->next)) {
@@ -3446,6 +3535,13 @@ int register_netdevice(struct net_device
 		}
 	}
 
+	if (dev->hard_start_xmit_batch) {
+		/* Driver supports batching skb API */
+		dev->skb_blist = kmalloc(sizeof *dev->skb_blist, GFP_KERNEL);
+		if (dev->skb_blist)
+			skb_queue_head_init(dev->skb_blist);
+	}
+
 	/*
 	 *	nil rebuild_header routine,
 	 *	that should be never called and used as just bug trap.
@@ -3787,6 +3882,9 @@ void unregister_netdevice(struct net_dev
 
 	synchronize_net();
 
+	/* Deallocate batching structure */
+	free_batching(dev);
+
 	/* Shutdown queueing discipline. */
 	dev_shutdown(dev);
 

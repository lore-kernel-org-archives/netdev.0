From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [ofa-general] [PATCH 03/12 -Rev2] dev.c changes.
Date: Sun, 22 Jul 2007 14:35:25 +0530
Message-ID: <20070722090525.7787.10432.sendpatchset@K50wks273871wss.in.ibm.com>
References: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
Cc: johnpol@2ka.mipt.ru, Robert.Olsson@data.slu.se,
	peter.p.waskiewicz.jr@intel.com, herbert@gondor.apana.org.au,
	gaagaan@gmail.com, kumarkr@linux.ibm.com, mcarlson@broadcom.com,
	jagana@us.ibm.com, general@lists.openfabrics.org,
	netdev@vger.kernel.org, tgraf@suug.ch, jeff@garzik.org,
	hadi@cyberus.ca, kaber@trash.net, mchan@broadcom.com, sri@us.ibm.com
To: davem@davemloft.net, rdreier@cisco.com
Return-path: <general-bounces@lists.openfabrics.org>
In-Reply-To: <20070722090457.7787.4601.sendpatchset@K50wks273871wss.in.ibm.com>
List-Unsubscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=unsubscribe>
List-Archive: <http://lists.openfabrics.org/pipermail/general>
List-Post: <mailto:general@lists.openfabrics.org>
List-Help: <mailto:general-request@lists.openfabrics.org?subject=help>
List-Subscribe: <http://lists.openfabrics.org/cgi-bin/mailman/listinfo/general>,
	<mailto:general-request@lists.openfabrics.org?subject=subscribe>
Sender: general-bounces@lists.openfabrics.org
Errors-To: general-bounces@lists.openfabrics.org
List-Id: netdev.vger.kernel.org

diff -ruNp org/net/core/dev.c rev2/net/core/dev.c
--- org/net/core/dev.c	2007-07-20 07:49:28.000000000 +0530
+++ rev2/net/core/dev.c	2007-07-21 23:08:33.000000000 +0530
@@ -875,6 +875,48 @@ void netdev_state_change(struct net_devi
 	}
 }
 
+/*
+ * dev_change_tx_batching - Enable or disable batching for a driver that
+ * supports batching.
+ */
+int dev_change_tx_batching(struct net_device *dev, unsigned long new_batch_skb)
+{
+	int ret;
+
+	if (!dev->hard_start_xmit_batch) {
+		/* Driver doesn't support skb batching */
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
+	ret = 0;
+
+	/* Check if new value is same as the current */
+	if (!!(dev->features & NETIF_F_BATCH_ON) == !!new_batch_skb)
+		goto out;
+
+	spin_lock(&dev->queue_lock);
+	if (new_batch_skb) {
+		dev->features |= NETIF_F_BATCH_ON;
+		dev->tx_queue_len >>= 1;
+	} else {
+		if (!skb_queue_empty(&dev->skb_blist))
+			skb_queue_purge(&dev->skb_blist);
+		dev->features &= ~NETIF_F_BATCH_ON;
+		dev->tx_queue_len <<= 1;
+	}
+	spin_unlock(&dev->queue_lock);
+
+out:
+	return ret;
+}
+
 /**
  *	dev_load 	- load a network module
  *	@name: name of interface
@@ -1414,6 +1456,45 @@ static int dev_gso_segment(struct sk_buf
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
+				__skb_queue_tail(&dev->skb_blist, nskb);
+				count++;
+			} while (skb->next);
+
+			skb->destructor = DEV_GSO_CB(skb)->destructor;
+			kfree_skb(skb);
+			return count;
+		}
+	}
+	__skb_queue_tail(&dev->skb_blist, skb);
+	return 1;
+}
+
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (likely(!skb->next)) {
@@ -3397,6 +3483,12 @@ int register_netdevice(struct net_device
 		}
 	}
 
+	if (dev->hard_start_xmit_batch) {
+		dev->features |= NETIF_F_BATCH_ON;
+		skb_queue_head_init(&dev->skb_blist);
+		dev->tx_queue_len >>= 1;
+	}
+
 	/*
 	 *	nil rebuild_header routine,
 	 *	that should be never called and used as just bug trap.

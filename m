From: =?UTF-8?q?Sjur=20Br=C3=A6ndeland?= <sjur.brandeland@stericsson.com>
Subject: [PATCH net-next 2/4] caif-hsi: robust frame aggregation for HSI
Date: Thu, 12 Apr 2012 20:27:25 +0200
Message-ID: <1334255247-3372-3-git-send-email-sjur.brandeland@stericsson.com>
References: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Cc: sjurbren@gmail.com,
	Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:64652 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934093Ab2DLS1j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Apr 2012 14:27:39 -0400
Received: by mail-lb0-f174.google.com with SMTP id gm6so1843188lbb.19
        for <netdev@vger.kernel.org>; Thu, 12 Apr 2012 11:27:38 -0700 (PDT)
In-Reply-To: <1334255247-3372-1-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>

Implement aggregation algorithm, combining more data into a single
HSI transfer. 4 different traffic categories are supported:
 1. TC_PRIO_CONTROL .. TC_PRIO_MAX (CTL)
 2. TC_PRIO_INTERACTIVE            (VO)
 3. TC_PRIO_INTERACTIVE_BULK       (VI)
 4. TC_PRIO_BESTEFFORT, TC_PRIO_BULK, TC_PRIO_FILLER (BEBK)

Signed-off-by: Dmitry Tarnyagin <dmitry.tarnyagin@stericsson.com>
---
 drivers/net/caif/caif_hsi.c |  243 +++++++++++++++++++++++++++++++++----------
 include/net/caif/caif_hsi.h |   19 +++-
 2 files changed, 205 insertions(+), 57 deletions(-)

diff --git a/drivers/net/caif/caif_hsi.c b/drivers/net/caif/caif_hsi.c
index 9c1c8cd..9849a23 100644
--- a/drivers/net/caif/caif_hsi.c
+++ b/drivers/net/caif/caif_hsi.c
@@ -19,6 +19,7 @@
 #include <linux/if_arp.h>
 #include <linux/timer.h>
 #include <linux/rtnetlink.h>
+#include <linux/pkt_sched.h>
 #include <net/caif/caif_layer.h>
 #include <net/caif/caif_hsi.h>
 
@@ -34,6 +35,10 @@ static int inactivity_timeout = 1000;
 module_param(inactivity_timeout, int, S_IRUGO | S_IWUSR);
 MODULE_PARM_DESC(inactivity_timeout, "Inactivity timeout on HSI, ms.");
 
+static int aggregation_timeout = 1;
+module_param(aggregation_timeout, int, S_IRUGO | S_IWUSR);
+MODULE_PARM_DESC(aggregation_timeout, "Aggregation timeout on HSI, ms.");
+
 /*
  * HSI padding options.
  * Warning: must be a base of 2 (& operation used) and can not be zero !
@@ -86,24 +91,84 @@ static void cfhsi_inactivity_tout(unsigned long arg)
 		queue_work(cfhsi->wq, &cfhsi->wake_down_work);
 }
 
+static void cfhsi_update_aggregation_stats(struct cfhsi *cfhsi,
+					   const struct sk_buff *skb,
+					   int direction)
+{
+	struct caif_payload_info *info;
+	int hpad, tpad, len;
+
+	info = (struct caif_payload_info *)&skb->cb;
+	hpad = 1 + PAD_POW2((info->hdr_len + 1), hsi_head_align);
+	tpad = PAD_POW2((skb->len + hpad), hsi_tail_align);
+	len = skb->len + hpad + tpad;
+
+	if (direction > 0)
+		cfhsi->aggregation_len += len;
+	else if (direction < 0)
+		cfhsi->aggregation_len -= len;
+}
+
+static bool cfhsi_can_send_aggregate(struct cfhsi *cfhsi)
+{
+	int i;
+
+	if (cfhsi->aggregation_timeout < 0)
+		return true;
+
+	for (i = 0; i < CFHSI_PRIO_BEBK; ++i) {
+		if (cfhsi->qhead[i].qlen)
+			return true;
+	}
+
+	/* TODO: Use aggregation_len instead */
+	if (cfhsi->qhead[CFHSI_PRIO_BEBK].qlen >= CFHSI_MAX_PKTS)
+		return true;
+
+	return false;
+}
+
+static struct sk_buff *cfhsi_dequeue(struct cfhsi *cfhsi)
+{
+	struct sk_buff *skb;
+	int i;
+
+	for (i = 0; i < CFHSI_PRIO_LAST; ++i) {
+		skb = skb_dequeue(&cfhsi->qhead[i]);
+		if (skb)
+			break;
+	}
+
+	return skb;
+}
+
+static int cfhsi_tx_queue_len(struct cfhsi *cfhsi)
+{
+	int i, len = 0;
+	for (i = 0; i < CFHSI_PRIO_LAST; ++i)
+		len += skb_queue_len(&cfhsi->qhead[i]);
+	return len;
+}
+
 static void cfhsi_abort_tx(struct cfhsi *cfhsi)
 {
 	struct sk_buff *skb;
 
 	for (;;) {
 		spin_lock_bh(&cfhsi->lock);
-		skb = skb_dequeue(&cfhsi->qhead);
+		skb = cfhsi_dequeue(cfhsi);
 		if (!skb)
 			break;
 
 		cfhsi->ndev->stats.tx_errors++;
 		cfhsi->ndev->stats.tx_dropped++;
+		cfhsi_update_aggregation_stats(cfhsi, skb, -1);
 		spin_unlock_bh(&cfhsi->lock);
 		kfree_skb(skb);
 	}
 	cfhsi->tx_state = CFHSI_TX_STATE_IDLE;
 	if (!test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
-		mod_timer(&cfhsi->timer,
+		mod_timer(&cfhsi->inactivity_timer,
 			jiffies + cfhsi->inactivity_timeout);
 	spin_unlock_bh(&cfhsi->lock);
 }
@@ -169,7 +234,7 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 	struct sk_buff *skb;
 	u8 *pfrm = desc->emb_frm + CFHSI_MAX_EMB_FRM_SZ;
 
-	skb = skb_dequeue(&cfhsi->qhead);
+	skb = cfhsi_dequeue(cfhsi);
 	if (!skb)
 		return 0;
 
@@ -196,11 +261,16 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 			pemb += hpad;
 
 			/* Update network statistics. */
+			spin_lock_bh(&cfhsi->lock);
 			cfhsi->ndev->stats.tx_packets++;
 			cfhsi->ndev->stats.tx_bytes += skb->len;
+			cfhsi_update_aggregation_stats(cfhsi, skb, -1);
+			spin_unlock_bh(&cfhsi->lock);
 
 			/* Copy in embedded CAIF frame. */
 			skb_copy_bits(skb, 0, pemb, skb->len);
+
+			/* Consume the SKB */
 			consume_skb(skb);
 			skb = NULL;
 		}
@@ -214,7 +284,7 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 		int tpad = 0;
 
 		if (!skb)
-			skb = skb_dequeue(&cfhsi->qhead);
+			skb = cfhsi_dequeue(cfhsi);
 
 		if (!skb)
 			break;
@@ -233,8 +303,11 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 		pfrm += hpad;
 
 		/* Update network statistics. */
+		spin_lock_bh(&cfhsi->lock);
 		cfhsi->ndev->stats.tx_packets++;
 		cfhsi->ndev->stats.tx_bytes += skb->len;
+		cfhsi_update_aggregation_stats(cfhsi, skb, -1);
+		spin_unlock_bh(&cfhsi->lock);
 
 		/* Copy in CAIF frame. */
 		skb_copy_bits(skb, 0, pfrm, skb->len);
@@ -244,6 +317,8 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 
 		/* Update frame pointer. */
 		pfrm += skb->len + tpad;
+
+		/* Consume the SKB */
 		consume_skb(skb);
 		skb = NULL;
 
@@ -258,8 +333,7 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 	}
 
 	/* Check if we can piggy-back another descriptor. */
-	skb = skb_peek(&cfhsi->qhead);
-	if (skb)
+	if (cfhsi_can_send_aggregate(cfhsi))
 		desc->header |= CFHSI_PIGGY_DESC;
 	else
 		desc->header &= ~CFHSI_PIGGY_DESC;
@@ -267,61 +341,71 @@ static int cfhsi_tx_frm(struct cfhsi_desc *desc, struct cfhsi *cfhsi)
 	return CFHSI_DESC_SZ + pld_len;
 }
 
-static void cfhsi_tx_done(struct cfhsi *cfhsi)
+static void cfhsi_start_tx(struct cfhsi *cfhsi)
 {
-	struct cfhsi_desc *desc = NULL;
-	int len = 0;
-	int res;
+	struct cfhsi_desc *desc = (struct cfhsi_desc *)cfhsi->tx_buf;
+	int len, res;
 
 	dev_dbg(&cfhsi->ndev->dev, "%s.\n", __func__);
 
 	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
 		return;
 
-	desc = (struct cfhsi_desc *)cfhsi->tx_buf;
-
 	do {
-		/*
-		 * Send flow on if flow off has been previously signalled
-		 * and number of packets is below low water mark.
-		 */
-		spin_lock_bh(&cfhsi->lock);
-		if (cfhsi->flow_off_sent &&
-				cfhsi->qhead.qlen <= cfhsi->q_low_mark &&
-				cfhsi->cfdev.flowctrl) {
-
-			cfhsi->flow_off_sent = 0;
-			cfhsi->cfdev.flowctrl(cfhsi->ndev, ON);
-		}
-		spin_unlock_bh(&cfhsi->lock);
-
 		/* Create HSI frame. */
-		do {
-			len = cfhsi_tx_frm(desc, cfhsi);
-			if (!len) {
-				spin_lock_bh(&cfhsi->lock);
-				if (unlikely(skb_peek(&cfhsi->qhead))) {
-					spin_unlock_bh(&cfhsi->lock);
-					continue;
-				}
-				cfhsi->tx_state = CFHSI_TX_STATE_IDLE;
-				/* Start inactivity timer. */
-				mod_timer(&cfhsi->timer,
-					jiffies + cfhsi->inactivity_timeout);
+		len = cfhsi_tx_frm(desc, cfhsi);
+		if (!len) {
+			spin_lock_bh(&cfhsi->lock);
+			if (unlikely(cfhsi_tx_queue_len(cfhsi))) {
 				spin_unlock_bh(&cfhsi->lock);
-				goto done;
+				res = -EAGAIN;
+				continue;
 			}
-		} while (!len);
+			cfhsi->tx_state = CFHSI_TX_STATE_IDLE;
+			/* Start inactivity timer. */
+			mod_timer(&cfhsi->inactivity_timer,
+				jiffies + cfhsi->inactivity_timeout);
+			spin_unlock_bh(&cfhsi->lock);
+			break;
+		}
 
 		/* Set up new transfer. */
 		res = cfhsi->dev->cfhsi_tx(cfhsi->tx_buf, len, cfhsi->dev);
-		if (WARN_ON(res < 0)) {
+		if (WARN_ON(res < 0))
 			dev_err(&cfhsi->ndev->dev, "%s: TX error %d.\n",
 				__func__, res);
-		}
 	} while (res < 0);
+}
+
+static void cfhsi_tx_done(struct cfhsi *cfhsi)
+{
+	dev_dbg(&cfhsi->ndev->dev, "%s.\n", __func__);
+
+	if (test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))
+		return;
+
+	/*
+	 * Send flow on if flow off has been previously signalled
+	 * and number of packets is below low water mark.
+	 */
+	spin_lock_bh(&cfhsi->lock);
+	if (cfhsi->flow_off_sent &&
+			cfhsi_tx_queue_len(cfhsi) <= cfhsi->q_low_mark &&
+			cfhsi->cfdev.flowctrl) {
+
+		cfhsi->flow_off_sent = 0;
+		cfhsi->cfdev.flowctrl(cfhsi->ndev, ON);
+	}
+
+	if (cfhsi_can_send_aggregate(cfhsi)) {
+		spin_unlock_bh(&cfhsi->lock);
+		cfhsi_start_tx(cfhsi);
+	} else {
+		mod_timer(&cfhsi->aggregation_timer,
+			jiffies + cfhsi->aggregation_timeout);
+		spin_unlock_bh(&cfhsi->lock);
+	}
 
-done:
 	return;
 }
 
@@ -560,7 +644,7 @@ static void cfhsi_rx_done(struct cfhsi *cfhsi)
 
 	/* Update inactivity timer if pending. */
 	spin_lock_bh(&cfhsi->lock);
-	mod_timer_pending(&cfhsi->timer,
+	mod_timer_pending(&cfhsi->inactivity_timer,
 			jiffies + cfhsi->inactivity_timeout);
 	spin_unlock_bh(&cfhsi->lock);
 
@@ -793,12 +877,12 @@ wake_ack:
 
 	spin_lock_bh(&cfhsi->lock);
 
-	/* Resume transmit if queue is not empty. */
-	if (!skb_peek(&cfhsi->qhead)) {
+	/* Resume transmit if queues are not empty. */
+	if (!cfhsi_tx_queue_len(cfhsi)) {
 		dev_dbg(&cfhsi->ndev->dev, "%s: Peer wake, start timer.\n",
 			__func__);
 		/* Start inactivity timer. */
-		mod_timer(&cfhsi->timer,
+		mod_timer(&cfhsi->inactivity_timer,
 				jiffies + cfhsi->inactivity_timeout);
 		spin_unlock_bh(&cfhsi->lock);
 		return;
@@ -934,20 +1018,53 @@ static void cfhsi_wake_down_cb(struct cfhsi_drv *drv)
 	wake_up_interruptible(&cfhsi->wake_down_wait);
 }
 
+static void cfhsi_aggregation_tout(unsigned long arg)
+{
+	struct cfhsi *cfhsi = (struct cfhsi *)arg;
+
+	dev_dbg(&cfhsi->ndev->dev, "%s.\n",
+		__func__);
+
+	cfhsi_start_tx(cfhsi);
+}
+
 static int cfhsi_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct cfhsi *cfhsi = NULL;
 	int start_xfer = 0;
 	int timer_active;
+	int prio;
 
 	if (!dev)
 		return -EINVAL;
 
 	cfhsi = netdev_priv(dev);
 
+	switch (skb->priority) {
+	case TC_PRIO_BESTEFFORT:
+	case TC_PRIO_FILLER:
+	case TC_PRIO_BULK:
+		prio = CFHSI_PRIO_BEBK;
+		break;
+	case TC_PRIO_INTERACTIVE_BULK:
+		prio = CFHSI_PRIO_VI;
+		break;
+	case TC_PRIO_INTERACTIVE:
+		prio = CFHSI_PRIO_VO;
+		break;
+	case TC_PRIO_CONTROL:
+	default:
+		prio = CFHSI_PRIO_CTL;
+		break;
+	}
+
 	spin_lock_bh(&cfhsi->lock);
 
-	skb_queue_tail(&cfhsi->qhead, skb);
+	/* Update aggregation statistics  */
+	cfhsi_update_aggregation_stats(cfhsi, skb, 1);
+
+	/* Queue the SKB */
+	skb_queue_tail(&cfhsi->qhead[prio], skb);
 
 	/* Sanity check; xmit should not be called after unregister_netdev */
 	if (WARN_ON(test_bit(CFHSI_SHUTDOWN, &cfhsi->bits))) {
@@ -958,7 +1075,7 @@ static int cfhsi_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Send flow off if number of packets is above high water mark. */
 	if (!cfhsi->flow_off_sent &&
-		cfhsi->qhead.qlen > cfhsi->q_high_mark &&
+		cfhsi_tx_queue_len(cfhsi) > cfhsi->q_high_mark &&
 		cfhsi->cfdev.flowctrl) {
 		cfhsi->flow_off_sent = 1;
 		cfhsi->cfdev.flowctrl(cfhsi->ndev, OFF);
@@ -970,12 +1087,18 @@ static int cfhsi_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	if (!start_xfer) {
+		/* Send aggregate if it is possible */
+		bool aggregate_ready =
+			cfhsi_can_send_aggregate(cfhsi) &&
+			del_timer(&cfhsi->aggregation_timer) > 0;
 		spin_unlock_bh(&cfhsi->lock);
+		if (aggregate_ready)
+			cfhsi_start_tx(cfhsi);
 		return 0;
 	}
 
 	/* Delete inactivity timer if started. */
-	timer_active = del_timer_sync(&cfhsi->timer);
+	timer_active = del_timer_sync(&cfhsi->inactivity_timer);
 
 	spin_unlock_bh(&cfhsi->lock);
 
@@ -1026,6 +1149,7 @@ static const struct net_device_ops cfhsi_ops = {
 
 static void cfhsi_setup(struct net_device *dev)
 {
+	int i;
 	struct cfhsi *cfhsi = netdev_priv(dev);
 	dev->features = 0;
 	dev->netdev_ops = &cfhsi_ops;
@@ -1034,7 +1158,8 @@ static void cfhsi_setup(struct net_device *dev)
 	dev->mtu = CFHSI_MAX_CAIF_FRAME_SZ;
 	dev->tx_queue_len = 0;
 	dev->destructor = free_netdev;
-	skb_queue_head_init(&cfhsi->qhead);
+	for (i = 0; i < CFHSI_PRIO_LAST; ++i)
+		skb_queue_head_init(&cfhsi->qhead[i]);
 	cfhsi->cfdev.link_select = CAIF_LINK_HIGH_BANDW;
 	cfhsi->cfdev.use_frag = false;
 	cfhsi->cfdev.use_stx = false;
@@ -1111,6 +1236,9 @@ int cfhsi_probe(struct platform_device *pdev)
 		cfhsi->inactivity_timeout = NEXT_TIMER_MAX_DELTA;
 	}
 
+	/* Initialize aggregation timeout */
+	cfhsi->aggregation_timeout = aggregation_timeout;
+
 	/* Initialize recieve vaiables. */
 	cfhsi->rx_ptr = cfhsi->rx_buf;
 	cfhsi->rx_len = CFHSI_DESC_SZ;
@@ -1150,13 +1278,17 @@ int cfhsi_probe(struct platform_device *pdev)
 	init_waitqueue_head(&cfhsi->flush_fifo_wait);
 
 	/* Setup the inactivity timer. */
-	init_timer(&cfhsi->timer);
-	cfhsi->timer.data = (unsigned long)cfhsi;
-	cfhsi->timer.function = cfhsi_inactivity_tout;
+	init_timer(&cfhsi->inactivity_timer);
+	cfhsi->inactivity_timer.data = (unsigned long)cfhsi;
+	cfhsi->inactivity_timer.function = cfhsi_inactivity_tout;
 	/* Setup the slowpath RX timer. */
 	init_timer(&cfhsi->rx_slowpath_timer);
 	cfhsi->rx_slowpath_timer.data = (unsigned long)cfhsi;
 	cfhsi->rx_slowpath_timer.function = cfhsi_rx_slowpath;
+	/* Setup the aggregation timer. */
+	init_timer(&cfhsi->aggregation_timer);
+	cfhsi->aggregation_timer.data = (unsigned long)cfhsi;
+	cfhsi->aggregation_timer.function = cfhsi_aggregation_tout;
 
 	/* Add CAIF HSI device to list. */
 	spin_lock(&cfhsi_list_lock);
@@ -1222,8 +1354,9 @@ static void cfhsi_shutdown(struct cfhsi *cfhsi)
 	flush_workqueue(cfhsi->wq);
 
 	/* Delete timers if pending */
-	del_timer_sync(&cfhsi->timer);
+	del_timer_sync(&cfhsi->inactivity_timer);
 	del_timer_sync(&cfhsi->rx_slowpath_timer);
+	del_timer_sync(&cfhsi->aggregation_timer);
 
 	/* Cancel pending RX request (if any) */
 	cfhsi->dev->cfhsi_rx_cancel(cfhsi->dev);
diff --git a/include/net/caif/caif_hsi.h b/include/net/caif/caif_hsi.h
index 6db8ecf..439dadc 100644
--- a/include/net/caif/caif_hsi.h
+++ b/include/net/caif/caif_hsi.h
@@ -123,12 +123,21 @@ struct cfhsi_rx_state {
 	bool piggy_desc;
 };
 
+/* Priority mapping */
+enum {
+	CFHSI_PRIO_CTL = 0,
+	CFHSI_PRIO_VI,
+	CFHSI_PRIO_VO,
+	CFHSI_PRIO_BEBK,
+	CFHSI_PRIO_LAST,
+};
+
 /* Structure implemented by CAIF HSI drivers. */
 struct cfhsi {
 	struct caif_dev_common cfdev;
 	struct net_device *ndev;
 	struct platform_device *pdev;
-	struct sk_buff_head qhead;
+	struct sk_buff_head qhead[CFHSI_PRIO_LAST];
 	struct cfhsi_drv drv;
 	struct cfhsi_dev *dev;
 	int tx_state;
@@ -151,8 +160,14 @@ struct cfhsi {
 	wait_queue_head_t wake_up_wait;
 	wait_queue_head_t wake_down_wait;
 	wait_queue_head_t flush_fifo_wait;
-	struct timer_list timer;
+	struct timer_list inactivity_timer;
 	struct timer_list rx_slowpath_timer;
+
+	/* TX aggregation */
+	unsigned long aggregation_timeout;
+	int aggregation_len;
+	struct timer_list aggregation_timer;
+
 	unsigned long bits;
 };
 
-- 
1.7.5.4

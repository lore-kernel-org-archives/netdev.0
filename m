From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 2/2] net: ethernet: ti: cpts: fix tx timestamping timeout
Date: Fri, 21 Jul 2017 18:49:43 -0500
Message-ID: <20170721234943.3841-3-grygorii.strashko@ti.com>
References: <20170721234943.3841-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, Wingman Kwok <w-kwok2@ti.com>,
        Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170721234943.3841-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the low speed Ethernet connection CPDMA notification about packet
processing can be received before CPTS TX timestamp event, which is set
when packet actually left CPSW while cpdma notification is sent when packet
pushed in CPSW fifo.  As result, when connection is slow and CPU is fast
enough TX timestamping is not working properly.

Fix it, by introducing TX SKB queue to store PTP SKBs for which Ethernet
Transmit Event hasn't been received yet and then re-check this queue
with new Ethernet Transmit Events by scheduling CPTS overflow
work more often (every 1 jiffies) until TX SKB queue is not empty.

Side effect of this change is:
 - User space tools require to take into account possible delay in TX
timestamp processing (for example ptp4l works with tx_timestamp_timeout=400
under net traffic and tx_timestamp_timeout=25 in idle).

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 93 +++++++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/ti/cpts.h |  1 +
 2 files changed, 88 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 6a520ae..746dd1d 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -31,9 +31,18 @@
 
 #include "cpts.h"
 
+#define CPTS_SKB_TX_WORK_TIMEOUT 1 /* jiffies */
+
+struct cpts_skb_cb_data {
+	unsigned long tmo;
+};
+
 #define cpts_read32(c, r)	readl_relaxed(&c->reg->r)
 #define cpts_write32(c, v, r)	writel_relaxed(v, &c->reg->r)
 
+static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
+		      u16 ts_seqid, u8 ts_msgtype);
+
 static int event_expired(struct cpts_event *event)
 {
 	return time_after(jiffies, event->tmo);
@@ -77,6 +86,47 @@ static int cpts_purge_events(struct cpts *cpts)
 	return removed ? 0 : -1;
 }
 
+static bool cpts_match_tx_ts(struct cpts *cpts, struct cpts_event *event)
+{
+	struct sk_buff *skb, *tmp;
+	u16 seqid;
+	u8 mtype;
+	bool found = false;
+
+	mtype = (event->high >> MESSAGE_TYPE_SHIFT) & MESSAGE_TYPE_MASK;
+	seqid = (event->high >> SEQUENCE_ID_SHIFT) & SEQUENCE_ID_MASK;
+
+	/* no need to grab txq.lock as access is always done under cpts->lock */
+	skb_queue_walk_safe(&cpts->txq, skb, tmp) {
+		struct skb_shared_hwtstamps ssh;
+		unsigned int class = ptp_classify_raw(skb);
+		struct cpts_skb_cb_data *skb_cb =
+					(struct cpts_skb_cb_data *)skb->cb;
+
+		if (cpts_match(skb, class, seqid, mtype)) {
+			u64 ns = timecounter_cyc2time(&cpts->tc, event->low);
+
+			memset(&ssh, 0, sizeof(ssh));
+			ssh.hwtstamp = ns_to_ktime(ns);
+			skb_tstamp_tx(skb, &ssh);
+			found = true;
+			__skb_unlink(skb, &cpts->txq);
+			dev_consume_skb_any(skb);
+			dev_dbg(cpts->dev, "match tx timestamp mtype %u seqid %04x\n",
+				mtype, seqid);
+		} else if (time_after(jiffies, skb_cb->tmo)) {
+			/* timeout any expired skbs over 1s */
+			dev_dbg(cpts->dev,
+				"expiring tx timestamp mtype %u seqid %04x\n",
+				mtype, seqid);
+			__skb_unlink(skb, &cpts->txq);
+			dev_consume_skb_any(skb);
+		}
+	}
+
+	return found;
+}
+
 /*
  * Returns zero if matching event type was found.
  */
@@ -101,9 +151,15 @@ static int cpts_fifo_read(struct cpts *cpts, int match)
 		event->low = lo;
 		type = event_type(event);
 		switch (type) {
+		case CPTS_EV_TX:
+			if (cpts_match_tx_ts(cpts, event)) {
+				/* if the new event matches an existing skb,
+				 * then don't queue it
+				 */
+				break;
+			}
 		case CPTS_EV_PUSH:
 		case CPTS_EV_RX:
-		case CPTS_EV_TX:
 			list_del_init(&event->list);
 			list_add_tail(&event->list, &cpts->events);
 			break;
@@ -240,13 +296,20 @@ static struct ptp_clock_info cpts_info = {
 
 static void cpts_overflow_check(struct kthread_work *work)
 {
-	struct timespec64 ts;
 	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
+	unsigned long delay = cpts->ov_check_period;
+	struct timespec64 ts;
+	unsigned long flags;
+
+	spin_lock_irqsave(&cpts->lock, flags);
+	ts = ns_to_timespec64(timecounter_read(&cpts->tc));
+
+	if (!skb_queue_empty(&cpts->txq))
+		delay = CPTS_SKB_TX_WORK_TIMEOUT;
+	spin_unlock_irqrestore(&cpts->lock, flags);
 
-	cpts_ptp_gettime(&cpts->info, &ts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
-	kthread_queue_delayed_work(cpts->kworker, &cpts->overflow_work,
-				   cpts->ov_check_period);
+	kthread_queue_delayed_work(cpts->kworker, &cpts->overflow_work, delay);
 }
 
 static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
@@ -300,7 +363,7 @@ static u64 cpts_find_ts(struct cpts *cpts, struct sk_buff *skb, int ev_type)
 		return 0;
 
 	spin_lock_irqsave(&cpts->lock, flags);
-	cpts_fifo_read(cpts, CPTS_EV_PUSH);
+	cpts_fifo_read(cpts, -1);
 	list_for_each_safe(this, next, &cpts->events) {
 		event = list_entry(this, struct cpts_event, list);
 		if (event_expired(event)) {
@@ -318,6 +381,20 @@ static u64 cpts_find_ts(struct cpts *cpts, struct sk_buff *skb, int ev_type)
 			break;
 		}
 	}
+
+	if (ev_type == CPTS_EV_TX && !ns) {
+		struct cpts_skb_cb_data *skb_cb =
+				(struct cpts_skb_cb_data *)skb->cb;
+		/* Not found, add frame to queue for processing later.
+		 * The periodic FIFO check will handle this.
+		 */
+		skb_get(skb);
+		/* get the timestamp for timeouts */
+		skb_cb->tmo = jiffies + msecs_to_jiffies(100);
+		__skb_queue_tail(&cpts->txq, skb);
+		kthread_mod_delayed_work(cpts->kworker,
+					 &cpts->overflow_work, 0);
+	}
 	spin_unlock_irqrestore(&cpts->lock, flags);
 
 	return ns;
@@ -359,6 +436,7 @@ int cpts_register(struct cpts *cpts)
 {
 	int err, i;
 
+	skb_queue_head_init(&cpts->txq);
 	INIT_LIST_HEAD(&cpts->events);
 	INIT_LIST_HEAD(&cpts->pool);
 	for (i = 0; i < CPTS_MAX_EVENTS; i++)
@@ -402,6 +480,9 @@ void cpts_unregister(struct cpts *cpts)
 	cpts_write32(cpts, 0, int_enable);
 	cpts_write32(cpts, 0, control);
 
+	/* Drop all packet */
+	skb_queue_purge(&cpts->txq);
+
 	clk_disable(cpts->refclk);
 }
 EXPORT_SYMBOL_GPL(cpts_unregister);
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index e8128e8..e94b829 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -128,6 +128,7 @@ struct cpts {
 	unsigned long ov_check_period;
 	struct kthread_worker *kworker;
 	struct kthread_delayed_work overflow_work;
+	struct sk_buff_head txq;
 };
 
 void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-- 
2.10.1

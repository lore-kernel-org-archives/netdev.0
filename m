From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [RFC/RFT PATCH 2/4] net: ethernat: ti: cpts: enable irq
Date: Tue, 13 Jun 2017 18:16:21 -0500
Message-ID: <20170613231623.28353-3-grygorii.strashko@ti.com>
References: <20170613231623.28353-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>, <linux-omap@vger.kernel.org>,
        <ivan.khoronzhuk@linaro.org>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Sekhar Nori <nsekhar@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170613231623.28353-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are two reasons for this change:
1) enabling of HW_TS_PUSH events as suggested by Richard Cochran and
discussed in [1]
2) fixing an TX timestamping miss issue which happens with low speed
ethernet connections and was reproduced on am57xx and am335x boards.
Issue description: With the low Ethernet connection speed CPDMA notification
about packet processing can be received before CPTS TX timestamp event,
which is sent when packet actually left CPSW while cpdma notification is
sent when packet pushed in CPSW fifo.  As result, when connection is slow
and CPU is fast enough TX timestamp can be missed and not working properly.

This patch converts CPTS driver to use IRQ instead of polling in the
following way:

 - CPTS_EV_PUSH: CPTS_EV_PUSH is used to get current CPTS counter value and
triggered from PTP callbacks and cpts_overflow_check() work. With this
change current CPTS counter value will be read in IRQ handler and saved in
CPTS context "cur_timestamp" field. The compeltion event will be signalled to the
requestor. The timecounter->read() will just read saved value. Access to
the "cur_timestamp" is protected by mutex "ptp_clk_mutex".

cpts_get_time:
  reinit_completion(&cpts->ts_push_complete);
  cpts_write32(cpts, TS_PUSH, ts_push);
  wait_for_completion_interruptible_timeout(&cpts->ts_push_complete, HZ);
  ns = timecounter_read(&cpts->tc);

cpts_irq:
  case CPTS_EV_PUSH:
	cpts->cur_timestamp = lo;
	complete(&cpts->ts_push_complete);

- CPTS_EV_TX: signals when CPTS timestamp is ready for valid TX PTP
packets. The TX timestamp is requested from cpts_tx_timestamp() which is
called for each transmitted packet from NAPI cpsw_tx_poll() callback. With
this change, CPTS event queue will be checked for existing CPTS_EV_TX
event, corresponding to the current TX packet, and if event is not found - packet
will be placed in CPTS TX packet queue for later processing. CPTS TX packet
queue will be processed from hi-priority cpts_ts_work() work which is scheduled
as from cpts_tx_timestamp() as from CPTS IRQ handler when CPTS_EV_TX event
is received.

cpts_tx_timestamp:
 check if packet is PTP packet
 try to find corresponding CPTS_EV_TX event
   if found: report timestamp
   if not found: put packet in TX queue, schedule cpts_ts_work()

cpts_irq:
 case CPTS_EV_TX:
     put event in CPTS event queue
     schedule cpts_ts_work()

cpts_ts_work:
   for each packet in  CPTS TX packet queue
       try to find corresponding CPTS_EV_TX event
       if found: report timestamp
       if timeout: drop packet

- CPTS_EV_RX: signals when CPTS timestamp is ready for valid RX PTP
packets. The RX timestamp is requested from cpts_rx_timestamp() which is
called for each received packet from NAPI cpsw_rx_poll() callback. With
this change, CPTS event queue will be checked for existing CPTS_EV_RX
event, corresponding to the current RX packet, and if event is not found - packet
will be placed in CPTS RX packet queue for later processing. CPTS RX packet
queue will be processed from hi-priority cpts_ts_work() work which is scheduled
as from cpts_rx_timestamp() as from CPTS IRQ handler when CPTS_EV_RX event
is received. cpts_rx_timestamp() has been updated to return failure in case
of RX timestamp processing delaying and, in such cases, caller of
cpts_rx_timestamp() should not call netif_receive_skb().

cpts_rx_timestamp:
 check if packet is PTP packet
 try to find corresponding CPTS_EV_RX event
   if found: report timestamp, return success
   if not found: put packet in RX queue, schedule cpts_ts_work(),
                 return failure

cpts_irq:
 case CPTS_EV_RX:
     put event in CPTS event queue
     schedule cpts_ts_work()

cpts_ts_work:
   for each packet in  CPTS RX packet queue
       try to find corresponding CPTS_EV_RX event
       if found: add timestamp and report packet netif_receive_skb()
       if timeout: drop packet

there are some statistic added in cpsw_get_strings() for debug purposes.

User space tools (like ptp4l) might require to take into account possible
delay in timestamp reception (for example ptp4l works with
tx_timestamp_timeout=100) as TX timestamp genaration can be delayed till
cpts_ts_work() executuion.

[1] https://www.mail-archive.com/netdev@vger.kernel.org/msg141466.html

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c |  42 ++++-
 drivers/net/ethernet/ti/cpts.c | 364 +++++++++++++++++++++++++++++------------
 drivers/net/ethernet/ti/cpts.h |  18 +-
 3 files changed, 314 insertions(+), 110 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index b6a0d92..f845926 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -143,7 +143,7 @@ do {								\
 #define cpsw_slave_index(cpsw, priv)				\
 		((cpsw->data.dual_emac) ? priv->emac_port :	\
 		cpsw->data.active_slave)
-#define IRQ_NUM			2
+#define IRQ_NUM			3
 #define CPSW_MAX_QUEUES		8
 #define CPSW_CPDMA_DESCS_POOL_SIZE_DEFAULT 256
 
@@ -730,12 +730,13 @@ static void cpsw_rx_handler(void *token, int len, int status)
 	if (new_skb) {
 		skb_copy_queue_mapping(new_skb, skb);
 		skb_put(skb, len);
-		cpts_rx_timestamp(cpsw->cpts, skb);
+		ret = cpts_rx_timestamp(cpsw->cpts, skb);
 		skb->protocol = eth_type_trans(skb, ndev);
-		netif_receive_skb(skb);
 		ndev->stats.rx_bytes += len;
 		ndev->stats.rx_packets++;
 		kmemleak_not_leak(new_skb);
+		if (!ret)
+			netif_receive_skb(skb);
 	} else {
 		ndev->stats.rx_dropped++;
 		new_skb = skb;
@@ -873,6 +874,14 @@ static irqreturn_t cpsw_rx_interrupt(int irq, void *dev_id)
 	return IRQ_HANDLED;
 }
 
+static irqreturn_t cpsw_misc_interrupt(int irq, void *dev_id)
+{
+	struct cpsw_common *cpsw = dev_id;
+
+	cpdma_ctlr_eoi(cpsw->dma, CPDMA_EOI_MISC);
+	return IRQ_HANDLED;
+}
+
 static int cpsw_tx_poll(struct napi_struct *napi_tx, int budget)
 {
 	u32			ch_map;
@@ -1194,6 +1203,9 @@ static void cpsw_get_strings(struct net_device *ndev, u32 stringset, u8 *data)
 
 		cpsw_add_ch_strings(&p, cpsw->rx_ch_num, 1);
 		cpsw_add_ch_strings(&p, cpsw->tx_ch_num, 0);
+		dev_err(cpsw->dev, "cpts stats: tx_tmo:%d event_tmo:%d, fail_rx:%d\n",
+			cpsw->cpts->tx_tmo, cpsw->cpts->event_tmo,
+			cpsw->cpts->fail_rx);
 		break;
 	}
 }
@@ -2879,7 +2891,7 @@ static int cpsw_probe(struct platform_device *pdev)
 	u32 slave_offset, sliver_offset, slave_size;
 	struct cpsw_common		*cpsw;
 	int ret = 0, i;
-	int irq;
+	int irq, misc_irq;
 
 	cpsw = devm_kzalloc(&pdev->dev, sizeof(struct cpsw_common), GFP_KERNEL);
 	if (!cpsw)
@@ -2981,6 +2993,13 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_dt_ret;
 	}
 
+	/* get misc irq*/
+	misc_irq = platform_get_irq(pdev, 3);
+	if (misc_irq < 0) {
+		ret = misc_irq;
+		goto clean_dt_ret;
+	}
+
 	memset(&dma_params, 0, sizeof(dma_params));
 	memset(&ale_params, 0, sizeof(ale_params));
 
@@ -3069,7 +3088,8 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_dma_ret;
 	}
 
-	cpsw->cpts = cpts_create(cpsw->dev, cpts_regs, cpsw->dev->of_node);
+	cpsw->cpts = cpts_create(cpsw->dev, cpts_regs, cpsw->dev->of_node,
+				 misc_irq);
 	if (IS_ERR(cpsw->cpts)) {
 		ret = PTR_ERR(cpsw->cpts);
 		goto clean_ale_ret;
@@ -3127,6 +3147,18 @@ static int cpsw_probe(struct platform_device *pdev)
 		goto clean_ale_ret;
 	}
 
+	cpsw->irqs_table[2] = misc_irq;
+	ret = devm_request_irq(&pdev->dev, misc_irq, cpsw_misc_interrupt,
+			       IRQF_ONESHOT | IRQF_SHARED,
+			       dev_name(&pdev->dev), cpsw);
+	if (ret < 0) {
+		dev_err(priv->dev, "error attaching misc irq (%d)\n", ret);
+		goto clean_ale_ret;
+	}
+
+	/* Enable misc CPTS evnt_pend IRQ */
+	writel(0x10, &cpsw->wr_regs->misc_en);
+
 	ndev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 
 	ndev->netdev_ops = &cpsw_netdev_ops;
diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index f35d950..25191e9 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -31,6 +31,11 @@
 
 #include "cpts.h"
 
+struct cpts_skb_cb_data {
+	u32 skb_mtype_seqid;
+	unsigned long tmo;
+};
+
 #define cpts_read32(c, r)	readl_relaxed(&c->reg->r)
 #define cpts_write32(c, v, r)	writel_relaxed(v, &c->reg->r)
 
@@ -68,121 +73,77 @@ static int cpts_purge_events(struct cpts *cpts)
 		if (event_expired(event)) {
 			list_del_init(&event->list);
 			list_add(&event->list, &cpts->pool);
+			cpts->event_tmo++;
+			dev_dbg(cpts->dev, "purge: event tmo:: high:%08X low:%08x\n",
+				event->high, event->low);
 			++removed;
 		}
 	}
 
 	if (removed)
-		pr_debug("cpts: event pool cleaned up %d\n", removed);
+		dev_dbg(cpts->dev, "event pool cleaned up %d\n", removed);
 	return removed ? 0 : -1;
 }
 
-/*
- * Returns zero if matching event type was found.
- */
-static int cpts_fifo_read(struct cpts *cpts, int match)
+static u64 cpts_systim_read_irq(const struct cyclecounter *cc)
 {
-	int i, type = -1;
-	u32 hi, lo;
-	struct cpts_event *event;
-
-	for (i = 0; i < CPTS_FIFO_DEPTH; i++) {
-		if (cpts_fifo_pop(cpts, &hi, &lo))
-			break;
+	u64 val;
+	unsigned long flags;
+	struct cpts *cpts = container_of(cc, struct cpts, cc);
 
-		if (list_empty(&cpts->pool) && cpts_purge_events(cpts)) {
-			pr_err("cpts: event pool empty\n");
-			return -1;
-		}
+	spin_lock_irqsave(&cpts->lock, flags);
+	val = cpts->cur_timestamp;
+	spin_unlock_irqrestore(&cpts->lock, flags);
 
-		event = list_first_entry(&cpts->pool, struct cpts_event, list);
-		event->tmo = jiffies + 2;
-		event->high = hi;
-		event->low = lo;
-		type = event_type(event);
-		switch (type) {
-		case CPTS_EV_PUSH:
-		case CPTS_EV_RX:
-		case CPTS_EV_TX:
-			list_del_init(&event->list);
-			list_add_tail(&event->list, &cpts->events);
-			break;
-		case CPTS_EV_ROLL:
-		case CPTS_EV_HALF:
-		case CPTS_EV_HW:
-			break;
-		default:
-			pr_err("cpts: unknown event type\n");
-			break;
-		}
-		if (type == match)
-			break;
-	}
-	return type == match ? 0 : -1;
+	return val;
 }
 
-static u64 cpts_systim_read(const struct cyclecounter *cc)
+/* PTP clock operations */
+
+static void cpts_ptp_update_time(struct cpts *cpts)
 {
-	u64 val = 0;
-	struct cpts_event *event;
-	struct list_head *this, *next;
-	struct cpts *cpts = container_of(cc, struct cpts, cc);
+	reinit_completion(&cpts->ts_push_complete);
 
 	cpts_write32(cpts, TS_PUSH, ts_push);
-	if (cpts_fifo_read(cpts, CPTS_EV_PUSH))
-		pr_err("cpts: unable to obtain a time stamp\n");
-
-	list_for_each_safe(this, next, &cpts->events) {
-		event = list_entry(this, struct cpts_event, list);
-		if (event_type(event) == CPTS_EV_PUSH) {
-			list_del_init(&event->list);
-			list_add(&event->list, &cpts->pool);
-			val = event->low;
-			break;
-		}
-	}
-
-	return val;
+	wait_for_completion_interruptible_timeout(&cpts->ts_push_complete, HZ);
 }
 
-/* PTP clock operations */
-
 static int cpts_ptp_adjfreq(struct ptp_clock_info *ptp, s32 ppb)
 {
 	u64 adj;
 	u32 diff, mult;
 	int neg_adj = 0;
-	unsigned long flags;
 	struct cpts *cpts = container_of(ptp, struct cpts, info);
 
 	if (ppb < 0) {
 		neg_adj = 1;
 		ppb = -ppb;
 	}
+
+	mutex_lock(&cpts->ptp_clk_mutex);
+
 	mult = cpts->cc_mult;
 	adj = mult;
 	adj *= ppb;
 	diff = div_u64(adj, 1000000000ULL);
 
-	spin_lock_irqsave(&cpts->lock, flags);
+	cpts_ptp_update_time(cpts);
 
 	timecounter_read(&cpts->tc);
 
 	cpts->cc.mult = neg_adj ? mult - diff : mult + diff;
-
-	spin_unlock_irqrestore(&cpts->lock, flags);
+	mutex_unlock(&cpts->ptp_clk_mutex);
 
 	return 0;
 }
 
 static int cpts_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 {
-	unsigned long flags;
 	struct cpts *cpts = container_of(ptp, struct cpts, info);
 
-	spin_lock_irqsave(&cpts->lock, flags);
+	mutex_lock(&cpts->ptp_clk_mutex);
 	timecounter_adjtime(&cpts->tc, delta);
-	spin_unlock_irqrestore(&cpts->lock, flags);
+	mutex_unlock(&cpts->ptp_clk_mutex);
 
 	return 0;
 }
@@ -190,14 +151,15 @@ static int cpts_ptp_adjtime(struct ptp_clock_info *ptp, s64 delta)
 static int cpts_ptp_gettime(struct ptp_clock_info *ptp, struct timespec64 *ts)
 {
 	u64 ns;
-	unsigned long flags;
 	struct cpts *cpts = container_of(ptp, struct cpts, info);
 
-	spin_lock_irqsave(&cpts->lock, flags);
+	mutex_lock(&cpts->ptp_clk_mutex);
+	cpts_ptp_update_time(cpts);
+
 	ns = timecounter_read(&cpts->tc);
-	spin_unlock_irqrestore(&cpts->lock, flags);
 
 	*ts = ns_to_timespec64(ns);
+	mutex_unlock(&cpts->ptp_clk_mutex);
 
 	return 0;
 }
@@ -206,14 +168,15 @@ static int cpts_ptp_settime(struct ptp_clock_info *ptp,
 			    const struct timespec64 *ts)
 {
 	u64 ns;
-	unsigned long flags;
 	struct cpts *cpts = container_of(ptp, struct cpts, info);
 
+	mutex_lock(&cpts->ptp_clk_mutex);
 	ns = timespec64_to_ns(ts);
 
-	spin_lock_irqsave(&cpts->lock, flags);
+	cpts_ptp_update_time(cpts);
+
 	timecounter_init(&cpts->tc, &cpts->cc, ns);
-	spin_unlock_irqrestore(&cpts->lock, flags);
+	mutex_unlock(&cpts->ptp_clk_mutex);
 
 	return 0;
 }
@@ -242,19 +205,89 @@ static void cpts_overflow_check(struct work_struct *work)
 {
 	struct timespec64 ts;
 	struct cpts *cpts = container_of(work, struct cpts, overflow_work.work);
+	struct timespec64 ts;
+	unsigned long flags;
 
 	cpts_ptp_gettime(&cpts->info, &ts);
 	pr_debug("cpts overflow check at %lld.%09lu\n", ts.tv_sec, ts.tv_nsec);
 	queue_delayed_work(cpts->workwq, &cpts->overflow_work,
 			   cpts->ov_check_period);
+
+	spin_lock_irqsave(&cpts->lock, flags);
+	cpts_purge_events(cpts);
+	spin_unlock_irqrestore(&cpts->lock, flags);
+
+	queue_work(cpts->workwq, &cpts->ts_work);
 }
 
-static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
-		      u16 ts_seqid, u8 ts_msgtype)
+static irqreturn_t cpts_misc_interrupt(int irq, void *dev_id)
 {
-	u16 *seqid;
-	unsigned int offset = 0;
+	struct cpts *cpts = dev_id;
+	unsigned long flags;
+	int i, type = -1;
+	u32 hi, lo;
+	struct cpts_event *event;
+	bool wake = false;
+
+	spin_lock_irqsave(&cpts->lock, flags);
+
+	for (i = 0; i < CPTS_FIFO_DEPTH; i++) {
+		if (cpts_fifo_pop(cpts, &hi, &lo))
+			break;
+
+		if (list_empty(&cpts->pool) && cpts_purge_events(cpts)) {
+			dev_err(cpts->dev, "event pool empty\n");
+			spin_unlock_irqrestore(&cpts->lock, flags);
+			return IRQ_HANDLED;
+		}
+
+		event = list_first_entry(&cpts->pool, struct cpts_event, list);
+		event->high = hi;
+		event->low = lo;
+		type = event_type(event);
+		dev_dbg(cpts->dev, "CPTS_EV: %d high:%08X low:%08x\n",
+			type, event->high, event->low);
+		switch (type) {
+		case CPTS_EV_PUSH:
+			cpts->cur_timestamp = lo;
+			complete(&cpts->ts_push_complete);
+			break;
+		case CPTS_EV_TX:
+		case CPTS_EV_RX:
+			event->tmo = jiffies + msecs_to_jiffies(1000);
+			event->timestamp = timecounter_cyc2time(&cpts->tc,
+								event->low);
+			list_del_init(&event->list);
+			list_add_tail(&event->list, &cpts->events);
+
+			wake = true;
+			break;
+		case CPTS_EV_ROLL:
+		case CPTS_EV_HALF:
+		case CPTS_EV_HW:
+			break;
+		default:
+			dev_err(cpts->dev, "unknown event type\n");
+			break;
+		}
+	}
+
+	spin_unlock_irqrestore(&cpts->lock, flags);
+	if (wake)
+		queue_work(cpts->workwq, &cpts->ts_work);
+
+	return IRQ_HANDLED;
+}
+
+static int cpts_skb_get_mtype_seqid(struct sk_buff *skb, u32 *mtype_seqid)
+{
+	unsigned int ptp_class = ptp_classify_raw(skb);
 	u8 *msgtype, *data = skb->data;
+	unsigned int offset = 0;
+	u16 *seqid;
+
+	if (ptp_class == PTP_CLASS_NONE)
+		return 0;
 
 	if (ptp_class & PTP_CLASS_VLAN)
 		offset += VLAN_HLEN;
@@ -282,37 +315,38 @@ static int cpts_match(struct sk_buff *skb, unsigned int ptp_class,
 		msgtype = data + offset;
 
 	seqid = (u16 *)(data + offset + OFF_PTP_SEQUENCE_ID);
+	*mtype_seqid = (*msgtype & MESSAGE_TYPE_MASK) << MESSAGE_TYPE_SHIFT;
+	*mtype_seqid |= (ntohs(*seqid) & SEQUENCE_ID_MASK) << SEQUENCE_ID_SHIFT;
 
-	return (ts_msgtype == (*msgtype & 0xf) && ts_seqid == ntohs(*seqid));
+	return 1;
 }
 
-static u64 cpts_find_ts(struct cpts *cpts, struct sk_buff *skb, int ev_type)
+static u64 cpts_find_ts(struct cpts *cpts, u32 skb_mtype_seqid)
 {
 	u64 ns = 0;
 	struct cpts_event *event;
 	struct list_head *this, *next;
-	unsigned int class = ptp_classify_raw(skb);
 	unsigned long flags;
-	u16 seqid;
-	u8 mtype;
-
-	if (class == PTP_CLASS_NONE)
-		return 0;
+	u32 mtype_seqid;
 
 	spin_lock_irqsave(&cpts->lock, flags);
-	cpts_fifo_read(cpts, CPTS_EV_PUSH);
 	list_for_each_safe(this, next, &cpts->events) {
 		event = list_entry(this, struct cpts_event, list);
 		if (event_expired(event)) {
 			list_del_init(&event->list);
 			list_add(&event->list, &cpts->pool);
+			cpts->event_tmo++;
+			dev_dbg(cpts->dev, "%s: event tmo: high:%08X low:%08x\n",
+				__func__, event->high, event->low);
 			continue;
 		}
-		mtype = (event->high >> MESSAGE_TYPE_SHIFT) & MESSAGE_TYPE_MASK;
-		seqid = (event->high >> SEQUENCE_ID_SHIFT) & SEQUENCE_ID_MASK;
-		if (ev_type == event_type(event) &&
-		    cpts_match(skb, class, seqid, mtype)) {
-			ns = timecounter_cyc2time(&cpts->tc, event->low);
+		mtype_seqid = event->high &
+			      ((MESSAGE_TYPE_MASK << MESSAGE_TYPE_SHIFT) |
+			       (SEQUENCE_ID_MASK << SEQUENCE_ID_SHIFT) |
+			       (EVENT_TYPE_MASK << EVENT_TYPE_SHIFT));
+
+		if (mtype_seqid == skb_mtype_seqid) {
+			ns = event->timestamp;
 			list_del_init(&event->list);
 			list_add(&event->list, &cpts->pool);
 			break;
@@ -323,32 +357,136 @@ static u64 cpts_find_ts(struct cpts *cpts, struct sk_buff *skb, int ev_type)
 	return ns;
 }
 
-void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
+static void cpts_ts_work(struct work_struct *work)
 {
-	u64 ns;
+	struct cpts *cpts = container_of(work, struct cpts, ts_work);
+	struct sk_buff *skb, *tmp;
+	struct sk_buff_head tempq;
+
+	spin_lock_bh(&cpts->txq.lock);
+	skb_queue_walk_safe(&cpts->txq, skb, tmp) {
+		struct skb_shared_hwtstamps ssh;
+		u64 ns;
+		struct cpts_skb_cb_data *skb_cb =
+			(struct cpts_skb_cb_data *)skb->cb;
+
+		ns = cpts_find_ts(cpts, skb_cb->skb_mtype_seqid);
+		if (ns) {
+			__skb_unlink(skb, &cpts->txq);
+			memset(&ssh, 0, sizeof(ssh));
+			ssh.hwtstamp = ns_to_ktime(ns);
+			skb->tstamp = 0;
+			skb_tstamp_tx(skb, &ssh);
+			consume_skb(skb);
+		} else if (time_after(jiffies, skb_cb->tmo)) {
+			/* timeout any expired skbs over 1s */
+			dev_err(cpts->dev,
+				"expiring tx timestamp mtype seqid %08x\n",
+				skb_cb->skb_mtype_seqid);
+			__skb_unlink(skb, &cpts->txq);
+			kfree_skb(skb);
+			cpts->tx_tmo++;
+		}
+	}
+	spin_unlock_bh(&cpts->txq.lock);
+
+	__skb_queue_head_init(&tempq);
+	spin_lock_bh(&cpts->rxq.lock);
+	skb_queue_walk_safe(&cpts->rxq, skb, tmp) {
+		struct skb_shared_hwtstamps *ssh;
+		u64 ns;
+		struct cpts_skb_cb_data *skb_cb =
+			(struct cpts_skb_cb_data *)skb->cb;
+
+		ns = cpts_find_ts(cpts, skb_cb->skb_mtype_seqid);
+		if (ns) {
+			__skb_unlink(skb, &cpts->rxq);
+			ssh = skb_hwtstamps(skb);
+			memset(ssh, 0, sizeof(*ssh));
+			ssh->hwtstamp = ns_to_ktime(ns);
+			__skb_queue_tail(&tempq, skb);
+		} else if (time_after(jiffies, skb_cb->tmo)) {
+			/* timeout any expired skbs over 1s */
+			dev_err(cpts->dev,
+				"expiring rx timestamp mtype seqid %08x\n",
+				skb_cb->skb_mtype_seqid);
+			__skb_unlink(skb, &cpts->rxq);
+			__skb_queue_tail(&tempq, skb);
+			cpts->fail_rx++;
+		}
+	}
+	spin_unlock_bh(&cpts->rxq.lock);
+
+	local_bh_disable();
+	while ((skb = __skb_dequeue(&tempq)))
+		netif_receive_skb(skb);
+	local_bh_enable();
+}
+
+int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
+{
+	struct cpts_skb_cb_data *skb_cb = (struct cpts_skb_cb_data *)skb->cb;
 	struct skb_shared_hwtstamps *ssh;
+	int ret;
+	u64 ns;
 
 	if (!cpts->rx_enable)
-		return;
-	ns = cpts_find_ts(cpts, skb, CPTS_EV_RX);
-	if (!ns)
-		return;
+		return 0;
+
+	ret = cpts_skb_get_mtype_seqid(skb, &skb_cb->skb_mtype_seqid);
+	if (!ret)
+		return 0;
+
+	skb_cb->skb_mtype_seqid |= (CPTS_EV_RX << EVENT_TYPE_SHIFT);
+
+	dev_dbg(cpts->dev, "%s mtype seqid %08x\n",
+		__func__, skb_cb->skb_mtype_seqid);
+
+	ns = cpts_find_ts(cpts, skb_cb->skb_mtype_seqid);
+	if (!ns) {
+		skb_cb->tmo = jiffies + msecs_to_jiffies(1000);
+		skb_queue_tail(&cpts->rxq, skb);
+		queue_work(cpts->workwq, &cpts->ts_work);
+		dev_dbg(cpts->dev, "%s push skb\n", __func__);
+		return 1;
+	}
+
 	ssh = skb_hwtstamps(skb);
 	memset(ssh, 0, sizeof(*ssh));
 	ssh->hwtstamp = ns_to_ktime(ns);
+	return 0;
 }
 EXPORT_SYMBOL_GPL(cpts_rx_timestamp);
 
 void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
-	u64 ns;
+	struct cpts_skb_cb_data *skb_cb = (struct cpts_skb_cb_data *)skb->cb;
 	struct skb_shared_hwtstamps ssh;
+	int ret;
+	u64 ns;
 
 	if (!(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
 		return;
-	ns = cpts_find_ts(cpts, skb, CPTS_EV_TX);
-	if (!ns)
+
+	ret = cpts_skb_get_mtype_seqid(skb, &skb_cb->skb_mtype_seqid);
+	if (!ret)
+		return;
+
+	skb_cb->skb_mtype_seqid |= (CPTS_EV_TX << EVENT_TYPE_SHIFT);
+
+	dev_dbg(cpts->dev, "%s mtype seqid %08x\n",
+		__func__, skb_cb->skb_mtype_seqid);
+
+	ns = cpts_find_ts(cpts, skb_cb->skb_mtype_seqid);
+	if (!ns) {
+		skb_get(skb);
+		skb_cb->tmo = jiffies + msecs_to_jiffies(1000);
+		skb_queue_tail(&cpts->txq, skb);
+		queue_work(cpts->workwq, &cpts->ts_work);
+		dev_dbg(cpts->dev, "%s skb push\n", __func__);
 		return;
+	}
+
 	memset(&ssh, 0, sizeof(ssh));
 	ssh.hwtstamp = ns_to_ktime(ns);
 	skb_tstamp_tx(skb, &ssh);
@@ -359,6 +497,9 @@ int cpts_register(struct cpts *cpts)
 {
 	int err, i;
 
+	skb_queue_head_init(&cpts->txq);
+	skb_queue_head_init(&cpts->rxq);
+
 	INIT_LIST_HEAD(&cpts->events);
 	INIT_LIST_HEAD(&cpts->pool);
 	for (i = 0; i < CPTS_MAX_EVENTS; i++)
@@ -369,6 +510,7 @@ int cpts_register(struct cpts *cpts)
 	cpts_write32(cpts, CPTS_EN, control);
 	cpts_write32(cpts, TS_PEND_EN, int_enable);
 
+	cpts_ptp_update_time(cpts);
 	timecounter_init(&cpts->tc, &cpts->cc, ktime_to_ns(ktime_get_real()));
 
 	cpts->clock = ptp_clock_register(&cpts->info, cpts->dev);
@@ -401,6 +543,11 @@ void cpts_unregister(struct cpts *cpts)
 
 	cpts_write32(cpts, 0, int_enable);
 	cpts_write32(cpts, 0, control);
+	cancel_work_sync(&cpts->ts_work);
+
+	/* Drop all packet */
+	skb_queue_purge(&cpts->txq);
+	skb_queue_purge(&cpts->rxq);
 
 	clk_disable(cpts->refclk);
 }
@@ -466,7 +613,7 @@ static int cpts_of_parse(struct cpts *cpts, struct device_node *node)
 }
 
 struct cpts *cpts_create(struct device *dev, void __iomem *regs,
-			 struct device_node *node)
+			 struct device_node *node, int irq)
 {
 	struct cpts *cpts;
 	int ret;
@@ -477,13 +624,17 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 
 	cpts->dev = dev;
 	cpts->reg = (struct cpsw_cpts __iomem *)regs;
+	cpts->irq = irq;
 	spin_lock_init(&cpts->lock);
+	mutex_init(&cpts->ptp_clk_mutex);
 	INIT_DELAYED_WORK(&cpts->overflow_work, cpts_overflow_check);
 	cpts->workwq = alloc_ordered_workqueue("cpts_ptp",
 					       WQ_MEM_RECLAIM | WQ_HIGHPRI);
 	if (!cpts->workwq)
 		return ERR_PTR(-ENOMEM);
 
+	INIT_WORK(&cpts->ts_work, cpts_ts_work);
+	init_completion(&cpts->ts_push_complete);
 
 	ret = cpts_of_parse(cpts, node);
 	if (ret)
@@ -497,7 +648,7 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 
 	clk_prepare(cpts->refclk);
 
-	cpts->cc.read = cpts_systim_read;
+	cpts->cc.read = cpts_systim_read_irq;
 	cpts->cc.mask = CLOCKSOURCE_MASK(32);
 	cpts->info = cpts_info;
 
@@ -507,6 +658,13 @@ struct cpts *cpts_create(struct device *dev, void __iomem *regs,
 	 */
 	cpts->cc_mult = cpts->cc.mult;
 
+	ret = devm_request_irq(dev, irq, cpts_misc_interrupt,
+			       IRQF_ONESHOT | IRQF_SHARED, dev_name(dev), cpts);
+	if (ret < 0) {
+		dev_err(dev, "error attaching irq (%d)\n", ret);
+		return ERR_PTR(ret);
+	}
+
 	return cpts;
 }
 EXPORT_SYMBOL_GPL(cpts_create);
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index 3eae01c..28a7cdb 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -105,6 +105,7 @@ struct cpts_event {
 	unsigned long tmo;
 	u32 high;
 	u32 low;
+	u64 timestamp;
 };
 
 struct cpts {
@@ -126,14 +127,27 @@ struct cpts {
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
 	unsigned long ov_check_period;
 	struct workqueue_struct *workwq;
+	struct mutex ptp_clk_mutex; /* sync PTP interface with works */
+
+	int irq;
+	u64 cur_timestamp;
+	struct completion	ts_push_complete;
+
+	u32 tx_tmo;
+	u32 event_tmo;
+	u32 fail_rx;
+
+	struct work_struct ts_work;
+	struct sk_buff_head txq;
+	struct sk_buff_head rxq;
 };
 
-void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
+int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 int cpts_register(struct cpts *cpts);
 void cpts_unregister(struct cpts *cpts);
 struct cpts *cpts_create(struct device *dev, void __iomem *regs,
-			 struct device_node *node);
+			 struct device_node *node, int irq);
 void cpts_release(struct cpts *cpts);
 
 static inline void cpts_rx_enable(struct cpts *cpts, int enable)
-- 
2.10.1

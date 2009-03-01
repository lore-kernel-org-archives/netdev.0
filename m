From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax/i2400m: implement RX reorder support
Date: Sun,  1 Mar 2009 01:42:54 -0800
Message-ID: <1235900574-15319-8-git-send-email-inaky@linux.intel.com>
References: <1235900574-15319-1-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-2-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-3-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-4-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-5-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-6-git-send-email-inaky@linux.intel.com>
 <1235900574-15319-7-git-send-email-inaky@linux.intel.com>
Cc: netdev@vger.kernel.org
To: wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 076-076-148-181.pdx.net ([76.76.148.181]:33367 "EHLO
	inaky-mobl3" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753317AbZCAJm7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 1 Mar 2009 04:42:59 -0500
In-Reply-To: <1235900574-15319-7-git-send-email-inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow the device to give the driver RX data with reorder information.

When that is done, the device will indicate the driver if a packet has
to be held in a (sorted) queue. It will also tell the driver when held
packets have to be released to the OS.

This is done to improve the WiMAX-protocol level retransmission
support when missing frames are detected.

The code docs provide details about the implementation.

In general, this just hooks into the RX path in rx.c; if a packet with
the reorder bit in the RX header is detected, the reorder information
in the header is extracted and one of the four main reorder operations
are executed. In one case (queue) no packet will be delivered to the
networking stack, just queued, whereas in the others (reset, update_ws
and queue_update_ws), queued packet might be delivered depending on
the window start for the specific queue.

The modifications to files other than rx.c are:

- control.c: during device initialization, enable reordering support
  if the rx_reorder_disabled module parameter is not enabled

- driver.c: expose a rx_reorder_disable module parameter and call
  i2400m_rx_setup/release() to initialize/shutdown RX reorder
  support.

- i2400m.h: introduce members in 'struct i2400m' needed for
  implementing reorder support.

- linux/i2400m.h: introduce TLVs, commands and constant definitions
  related to RX reorder

Last but not least, the rx reorder code includes an small circular log
where the last N reorder operations are recorded to be displayed in
case of inconsistency. Otherwise diagnosing issues would be almost
impossible.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/control.c |   14 +
 drivers/net/wimax/i2400m/driver.c  |   11 +
 drivers/net/wimax/i2400m/i2400m.h  |   19 +-
 drivers/net/wimax/i2400m/rx.c      |  677 ++++++++++++++++++++++++++++++++++--
 include/linux/wimax/i2400m.h       |   32 ++-
 5 files changed, 723 insertions(+), 30 deletions(-)

diff --git a/drivers/net/wimax/i2400m/control.c b/drivers/net/wimax/i2400m/control.c
index 4073c3e..b3cadb6 100644
--- a/drivers/net/wimax/i2400m/control.c
+++ b/drivers/net/wimax/i2400m/control.c
@@ -1312,10 +1312,12 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 	struct i2400m_tlv_config_idle_parameters idle_params;
 	struct i2400m_tlv_config_idle_timeout idle_timeout;
 	struct i2400m_tlv_config_d2h_data_format df;
+	struct i2400m_tlv_config_dl_host_reorder dlhr;
 	const struct i2400m_tlv_hdr *args[9];
 	unsigned argc = 0;
 
 	d_fnstart(3, dev, "(i2400m %p)\n", i2400m);
+	/* Disable idle mode? (enabled by default) */
 	if (i2400m_idle_mode_disabled) {
 		if (i2400m_le_v1_3(i2400m)) {
 			idle_params.hdr.type =
@@ -1335,12 +1337,24 @@ int i2400m_dev_initialize(struct i2400m *i2400m)
 		}
 	}
 	if (i2400m_ge_v1_4(i2400m)) {
+		/* Enable extended RX data format? */
 		df.hdr.type =
 			cpu_to_le16(I2400M_TLV_CONFIG_D2H_DATA_FORMAT);
 		df.hdr.length = cpu_to_le16(
 			sizeof(df) - sizeof(df.hdr));
 		df.format = 1;
 		args[argc++] = &df.hdr;
+
+		/* Enable RX data reordering?
+		 * (switch flipped in rx.c:i2400m_rx_setup() after fw upload) */
+		if (i2400m->rx_reorder) {
+			dlhr.hdr.type =
+				cpu_to_le16(I2400M_TLV_CONFIG_DL_HOST_REORDER);
+			dlhr.hdr.length = cpu_to_le16(
+				sizeof(dlhr) - sizeof(dlhr.hdr));
+			dlhr.reorder = 1;
+			args[argc++] = &dlhr.hdr;
+		}
 	}
 	result = i2400m_set_init_config(i2400m, args, argc);
 	if (result < 0)
diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index e4f1ce5..07a54ba 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -76,6 +76,11 @@ MODULE_PARM_DESC(idle_mode_disabled,
 		 "If true, the device will not enable idle mode negotiation "
 		 "with the base station (when connected) to save power.");
 
+int i2400m_rx_reorder_disabled;	/* 0 (rx reorder enabled) by default */
+module_param_named(rx_reorder_disabled, i2400m_rx_reorder_disabled, int, 0644);
+MODULE_PARM_DESC(rx_reorder_disabled,
+		 "If true, RX reordering will be disabled.");
+
 /**
  * i2400m_queue_work - schedule work on a i2400m's queue
  *
@@ -396,6 +401,9 @@ retry:
 	result = i2400m_tx_setup(i2400m);
 	if (result < 0)
 		goto error_tx_setup;
+	result = i2400m_rx_setup(i2400m);
+	if (result < 0)
+		goto error_rx_setup;
 	result = i2400m->bus_dev_start(i2400m);
 	if (result < 0)
 		goto error_bus_dev_start;
@@ -430,6 +438,8 @@ error_fw_check:
 error_create_workqueue:
 	i2400m->bus_dev_stop(i2400m);
 error_bus_dev_start:
+	i2400m_rx_release(i2400m);
+error_rx_setup:
 	i2400m_tx_release(i2400m);
 error_tx_setup:
 error_bootstrap:
@@ -477,6 +487,7 @@ void __i2400m_dev_stop(struct i2400m *i2400m)
 	i2400m->ready = 0;
 	destroy_workqueue(i2400m->work_queue);
 	i2400m->bus_dev_stop(i2400m);
+	i2400m_rx_release(i2400m);
 	i2400m_tx_release(i2400m);
 	wimax_state_change(wimax_dev, WIMAX_ST_DOWN);
 	d_fnend(3, dev, "(i2400m %p) = 0\n", i2400m);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 125c305..3ae2df3 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -174,6 +174,7 @@ enum i2400m_reset_type {
 };
 
 struct i2400m_reset_ctx;
+struct i2400m_roq;
 
 /**
  * struct i2400m - descriptor for an Intel 2400m
@@ -257,6 +258,9 @@ struct i2400m_reset_ctx;
  *     force this to be the first field so that we can get from
  *     netdev_priv() the right pointer.
  *
+ * @rx_reorder: 1 if RX reordering is enabled; this can only be
+ *     set at probe time.
+ *
  * @state: device's state (as reported by it)
  *
  * @state_wq: waitqueue that is woken up whenever the state changes
@@ -313,6 +317,12 @@ struct i2400m_reset_ctx;
  *
  * @rx_size_max: buggest RX message received.
  *
+ * @rx_roq: RX ReOrder queues. (fw >= v1.4) When packets are received
+ *     out of order, the device will ask the driver to hold certain
+ *     packets until the ones that are received out of order can be
+ *     delivered. Then the driver can release them to the host. See
+ *     drivers/net/i2400m/rx.c for details.
+ *
  * @init_mutex: Mutex used for serializing the device bringup
  *     sequence; this way if the device reboots in the middle, we
  *     don't try to do a bringup again while we are tearing down the
@@ -377,6 +387,7 @@ struct i2400m {
 	unsigned boot_mode:1;		/* is the device in boot mode? */
 	unsigned sboot:1;		/* signed or unsigned fw boot */
 	unsigned ready:1;		/* all probing steps done */
+	unsigned rx_reorder:1;		/* RX reorder is enabled */
 	u8 trace_msg_from_user;		/* echo rx msgs to 'trace' pipe */
 					/* typed u8 so debugfs/u8 can tweak */
 	enum i2400m_system_state state;
@@ -405,10 +416,11 @@ struct i2400m {
 	unsigned tx_pl_num, tx_pl_max, tx_pl_min,
 		tx_num, tx_size_acc, tx_size_min, tx_size_max;
 
-	/* RX stats */
+	/* RX stuff */
 	spinlock_t rx_lock;		/* protect RX state */
 	unsigned rx_pl_num, rx_pl_max, rx_pl_min,
 		rx_num, rx_size_acc, rx_size_min, rx_size_max;
+	struct i2400m_roq *rx_roq;	/* not under rx_lock! */
 
 	struct mutex msg_mutex;		/* serialize command execution */
 	struct completion msg_completion;
@@ -442,6 +454,7 @@ void i2400m_init(struct i2400m *i2400m)
 	wimax_dev_init(&i2400m->wimax_dev);
 
 	i2400m->boot_mode = 1;
+	i2400m->rx_reorder = 1;
 	init_waitqueue_head(&i2400m->state_wq);
 
 	spin_lock_init(&i2400m->tx_lock);
@@ -591,6 +604,9 @@ extern int i2400m_tx_setup(struct i2400m *);
 extern void i2400m_wake_tx_work(struct work_struct *);
 extern void i2400m_tx_release(struct i2400m *);
 
+extern int i2400m_rx_setup(struct i2400m *);
+extern void i2400m_rx_release(struct i2400m *);
+
 extern void i2400m_net_rx(struct i2400m *, struct sk_buff *, unsigned,
 			  const void *, int);
 extern void i2400m_net_erx(struct i2400m *, struct sk_buff *,
@@ -788,6 +804,7 @@ void __i2400m_msleep(unsigned ms)
 /* Module parameters */
 
 extern int i2400m_idle_mode_disabled;
+extern int i2400m_rx_reorder_disabled;
 
 
 #endif /* #ifndef __I2400M_H__ */
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index cd52506..02419bf 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -39,7 +39,7 @@
  *  - Use skb_clone(), break up processing in chunks
  *  - Split transport/device specific
  *  - Make buffer size dynamic to exert less memory pressure
- *
+ *  - RX reorder support
  *
  * This handles the RX path.
  *
@@ -77,14 +77,42 @@
  * In firmware >= 1.4, RX packets have an extended header (16
  * bytes). This header conveys information for management of host
  * reordering of packets (the device offloads storage of the packets
- * for reordering to the host).
- *
- * Currently this information is not used as the current code doesn't
- * enable host reordering.
+ * for reordering to the host). Read below for more information.
  *
  * The header is used as dummy space to emulate an ethernet header and
  * thus be able to act as an ethernet device without having to reallocate.
  *
+ * DATA RX REORDERING
+ *
+ * Starting in firmware v1.4, the device can deliver packets for
+ * delivery with special reordering information; this allows it to
+ * more effectively do packet management when some frames were lost in
+ * the radio traffic.
+ *
+ * Thus, for RX packets that come out of order, the device gives the
+ * driver enough information to queue them properly and then at some
+ * point, the signal to deliver the whole (or part) of the queued
+ * packets to the networking stack. There are 16 such queues.
+ *
+ * This only happens when a packet comes in with the "need reorder"
+ * flag set in the RX header. When such bit is set, the following
+ * operations might be indicated:
+ *
+ *  - reset queue: send all queued packets to the OS
+ *
+ *  - queue: queue a packet
+ *
+ *  - update ws: update the queue's window start and deliver queued
+ *    packets that meet the criteria
+ *
+ *  - queue & update ws: queue a packet, update the window start and
+ *    deliver queued packets that meet the criteria
+ *
+ * (delivery criteria: the packet's [normalized] sequence number is
+ * lower than the new [normalized] window start).
+ *
+ * See the i2400m_roq_*() functions for details.
+ *
  * ROADMAP
  *
  * i2400m_rx
@@ -94,6 +122,17 @@
  *     i2400m_net_rx
  *     i2400m_rx_edata
  *       i2400m_net_erx
+ *       i2400m_roq_reset
+ *         i2400m_net_erx
+ *       i2400m_roq_queue
+ *         __i2400m_roq_queue
+ *       i2400m_roq_update_ws
+ *         __i2400m_roq_update_ws
+ *           i2400m_net_erx
+ *       i2400m_roq_queue_update_ws
+ *         __i2400m_roq_queue
+ *         __i2400m_roq_update_ws
+ *           i2400m_net_erx
  *     i2400m_rx_ctl
  *       i2400m_msg_size_check
  *       i2400m_report_hook_work    [in a workqueue]
@@ -330,6 +369,469 @@ error_check:
 	return;
 }
 
+
+/*
+ * Reorder queue data stored on skb->cb while the skb is queued in the
+ * reorder queues.
+ */
+struct i2400m_roq_data {
+	unsigned sn;		/* Serial number for the skb */
+	enum i2400m_cs cs;	/* packet type for the skb */
+};
+
+
+/*
+ * ReOrder Queue
+ *
+ * @ws: Window Start; sequence number where the current window start
+ *     is for this queue
+ * @queue: the skb queue itself
+ * @log: circular ring buffer used to log information about the
+ *     reorder process in this queue that can be displayed in case of
+ *     error to help diagnose it.
+ *
+ * This is the head for a list of skbs. In the skb->cb member of the
+ * skb when queued here contains a 'struct i2400m_roq_data' were we
+ * store the sequence number (sn) and the cs (packet type) coming from
+ * the RX payload header from the device.
+ */
+struct i2400m_roq
+{
+	unsigned ws;
+	struct sk_buff_head queue;
+	struct i2400m_roq_log *log;
+};
+
+
+static
+void __i2400m_roq_init(struct i2400m_roq *roq)
+{
+	roq->ws = 0;
+	skb_queue_head_init(&roq->queue);
+}
+
+
+static
+unsigned __i2400m_roq_index(struct i2400m *i2400m, struct i2400m_roq *roq)
+{
+	return ((unsigned long) roq - (unsigned long) i2400m->rx_roq)
+		/ sizeof(*roq);
+}
+
+
+/*
+ * Normalize a sequence number based on the queue's window start
+ *
+ * nsn = (sn - ws) % 2048
+ *
+ * Note that if @sn < @roq->ws, we still need a positive number; %'s
+ * sign is implementation specific, so we normalize it by adding 2048
+ * to bring it to be positive.
+ */
+static
+unsigned __i2400m_roq_nsn(struct i2400m_roq *roq, unsigned sn)
+{
+	int r;
+	r =  ((int) sn - (int) roq->ws) % 2048;
+	if (r < 0)
+		r += 2048;
+	return r;
+}
+
+
+/*
+ * Circular buffer to keep the last N reorder operations
+ *
+ * In case something fails, dumb then to try to come up with what
+ * happened.
+ */
+enum {
+	I2400M_ROQ_LOG_LENGTH = 32,
+};
+
+struct i2400m_roq_log {
+	struct i2400m_roq_log_entry {
+		enum i2400m_ro_type type;
+		unsigned ws, count, sn, nsn, new_ws;
+	} entry[I2400M_ROQ_LOG_LENGTH];
+	unsigned in, out;
+};
+
+
+/* Print a log entry */
+static
+void i2400m_roq_log_entry_print(struct i2400m *i2400m, unsigned index,
+				unsigned e_index,
+				struct i2400m_roq_log_entry *e)
+{
+	struct device *dev = i2400m_dev(i2400m);
+
+	switch(e->type) {
+	case I2400M_RO_TYPE_RESET:
+		dev_err(dev, "q#%d reset           ws %u cnt %u sn %u/%u"
+			" - new nws %u\n",
+			index, e->ws, e->count, e->sn, e->nsn, e->new_ws);
+		break;
+	case I2400M_RO_TYPE_PACKET:
+		dev_err(dev, "q#%d queue           ws %u cnt %u sn %u/%u\n",
+			index, e->ws, e->count, e->sn, e->nsn);
+		break;
+	case I2400M_RO_TYPE_WS:
+		dev_err(dev, "q#%d update_ws       ws %u cnt %u sn %u/%u"
+			" - new nws %u\n",
+			index, e->ws, e->count, e->sn, e->nsn, e->new_ws);
+		break;
+	case I2400M_RO_TYPE_PACKET_WS:
+		dev_err(dev, "q#%d queue_update_ws ws %u cnt %u sn %u/%u"
+			" - new nws %u\n",
+			index, e->ws, e->count, e->sn, e->nsn, e->new_ws);
+		break;
+	default:
+		dev_err(dev, "q#%d BUG? entry %u - unknown type %u\n",
+			index, e_index, e->type);
+		break;
+	}
+}
+
+
+static
+void i2400m_roq_log_add(struct i2400m *i2400m,
+			struct i2400m_roq *roq, enum i2400m_ro_type type,
+			unsigned ws, unsigned count, unsigned sn,
+			unsigned nsn, unsigned new_ws)
+{
+	struct i2400m_roq_log_entry *e;
+	unsigned cnt_idx;
+	int index = __i2400m_roq_index(i2400m, roq);
+
+	/* if we run out of space, we eat from the end */
+	if (roq->log->in - roq->log->out == I2400M_ROQ_LOG_LENGTH)
+		roq->log->out++;
+	cnt_idx = roq->log->in++ % I2400M_ROQ_LOG_LENGTH;
+	e = &roq->log->entry[cnt_idx];
+
+	e->type = type;
+	e->ws = ws;
+	e->count = count;
+	e->sn = sn;
+	e->nsn = nsn;
+	e->new_ws = new_ws;
+
+	if (d_test(1))
+		i2400m_roq_log_entry_print(i2400m, index, cnt_idx, e);
+}
+
+
+/* Dump all the entries in the FIFO and reinitialize it */
+static
+void i2400m_roq_log_dump(struct i2400m *i2400m, struct i2400m_roq *roq)
+{
+	unsigned cnt, cnt_idx;
+	struct i2400m_roq_log_entry *e;
+	int index = __i2400m_roq_index(i2400m, roq);
+
+	BUG_ON(roq->log->out > roq->log->in);
+	for (cnt = roq->log->out; cnt < roq->log->in; cnt++) {
+		cnt_idx = cnt % I2400M_ROQ_LOG_LENGTH;
+		e = &roq->log->entry[cnt_idx];
+		i2400m_roq_log_entry_print(i2400m, index, cnt_idx, e);
+		memset(e, 0, sizeof(*e));
+	}
+	roq->log->in = roq->log->out = 0;
+}
+
+
+/*
+ * Backbone for the queuing of an skb (by normalized sequence number)
+ *
+ * @i2400m: device descriptor
+ * @roq: reorder queue where to add
+ * @skb: the skb to add
+ * @sn: the sequence number of the skb
+ * @nsn: the normalized sequence number of the skb (pre-computed by the
+ *     caller from the @sn and @roq->ws).
+ *
+ * We try first a couple of quick cases:
+ *
+ *   - the queue is empty
+ *   - the skb would be appended to the queue
+ *
+ * These will be the most common operations.
+ *
+ * If these fail, then we have to do a sorted insertion in the queue,
+ * which is the slowest path.
+ *
+ * We don't have to acquire a reference count as we are going to own it.
+ */
+static
+void __i2400m_roq_queue(struct i2400m *i2400m, struct i2400m_roq *roq,
+			struct sk_buff *skb, unsigned sn, unsigned nsn)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	struct sk_buff *skb_itr;
+	struct i2400m_roq_data *roq_data_itr, *roq_data;
+	unsigned nsn_itr;
+
+	d_fnstart(4, dev, "(i2400m %p roq %p skb %p sn %u nsn %u)\n",
+		  i2400m, roq, skb, sn, nsn);
+
+	roq_data = (struct i2400m_roq_data *) &skb->cb;
+	BUILD_BUG_ON(sizeof(*roq_data) > sizeof(skb->cb));
+	roq_data->sn = sn;
+	d_printf(3, dev, "ERX: roq %p [ws %u] nsn %d sn %u\n",
+		 roq, roq->ws, nsn, roq_data->sn);
+
+	/* Queues will be empty on not-so-bad environments, so try
+	 * that first */
+	if (skb_queue_empty(&roq->queue)) {
+		d_printf(2, dev, "ERX: roq %p - first one\n", roq);
+		__skb_queue_head(&roq->queue, skb);
+		goto out;
+	}
+	/* Now try append, as most of the operations will be that */
+	skb_itr = skb_peek_tail(&roq->queue);
+	roq_data_itr = (struct i2400m_roq_data *) &skb_itr->cb;
+	nsn_itr = __i2400m_roq_nsn(roq, roq_data_itr->sn);
+	/* NSN bounds assumed correct (checked when it was queued) */
+	if (nsn >= nsn_itr) {
+		d_printf(2, dev, "ERX: roq %p - appended after %p (nsn %d sn %u)\n",
+			 roq, skb_itr, nsn_itr, roq_data_itr->sn);
+		__skb_queue_tail(&roq->queue, skb);
+		goto out;
+	}
+	/* None of the fast paths option worked. Iterate to find the
+	 * right spot where to insert the packet; we know the queue is
+	 * not empty, so we are not the first ones; we also know we
+	 * are not going to be the last ones. The list is sorted, so
+	 * we have to insert before the the first guy with an nsn_itr
+	 * greater that our nsn. */
+	skb_queue_walk(&roq->queue, skb_itr) {
+		roq_data_itr = (struct i2400m_roq_data *) &skb_itr->cb;
+		nsn_itr = __i2400m_roq_nsn(roq, roq_data_itr->sn);
+		/* NSN bounds assumed correct (checked when it was queued) */
+		if (nsn_itr > nsn) {
+			d_printf(2, dev, "ERX: roq %p - queued before %p "
+				 "(nsn %d sn %u)\n", roq, skb_itr, nsn_itr,
+				 roq_data_itr->sn);
+			__skb_queue_before(&roq->queue, skb_itr, skb);
+			goto out;
+		}
+	}
+	/* If we get here, that is VERY bad -- print info to help
+	 * diagnose and crash it */
+	dev_err(dev, "SW BUG? failed to insert packet\n");
+	dev_err(dev, "ERX: roq %p [ws %u] skb %p nsn %d sn %u\n",
+		roq, roq->ws, skb, nsn, roq_data->sn);
+	skb_queue_walk(&roq->queue, skb_itr) {
+		roq_data_itr = (struct i2400m_roq_data *) &skb_itr->cb;
+		nsn_itr = __i2400m_roq_nsn(roq, roq_data_itr->sn);
+		/* NSN bounds assumed correct (checked when it was queued) */
+		dev_err(dev, "ERX: roq %p skb_itr %p nsn %d sn %u\n",
+			roq, skb_itr, nsn_itr, roq_data_itr->sn);
+	}
+	BUG();
+out:
+	d_fnend(4, dev, "(i2400m %p roq %p skb %p sn %u nsn %d) = void\n",
+		i2400m, roq, skb, sn, nsn);
+	return;
+}
+
+
+/*
+ * Backbone for the update window start operation
+ *
+ * @i2400m: device descriptor
+ * @roq: Reorder queue
+ * @sn: New sequence number
+ *
+ * Updates the window start of a queue; when doing so, it must deliver
+ * to the networking stack all the queued skb's whose normalized
+ * sequence number is lower than the new normalized window start.
+ */
+static
+unsigned __i2400m_roq_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
+				unsigned sn)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	struct sk_buff *skb_itr, *tmp_itr;
+	struct i2400m_roq_data *roq_data_itr;
+	unsigned new_nws, nsn_itr;
+
+	new_nws = __i2400m_roq_nsn(roq, sn);
+	if (unlikely(new_nws >= 1024) && d_test(1)) {
+		dev_err(dev, "SW BUG? __update_ws new_nws %u (sn %u ws %u)\n",
+			new_nws, sn, roq->ws);
+		WARN_ON(1);
+		i2400m_roq_log_dump(i2400m, roq);
+	}
+	skb_queue_walk_safe(&roq->queue, skb_itr, tmp_itr) {
+		roq_data_itr = (struct i2400m_roq_data *) &skb_itr->cb;
+		nsn_itr = __i2400m_roq_nsn(roq, roq_data_itr->sn);
+		/* NSN bounds assumed correct (checked when it was queued) */
+		if (nsn_itr < new_nws) {
+			d_printf(2, dev, "ERX: roq %p - release skb %p "
+				 "(nsn %u/%u new nws %u)\n",
+				 roq, skb_itr, nsn_itr, roq_data_itr->sn,
+				 new_nws);
+			__skb_unlink(skb_itr, &roq->queue);
+			i2400m_net_erx(i2400m, skb_itr, roq_data_itr->cs);
+		}
+		else
+			break;	/* rest of packets all nsn_itr > nws */
+	}
+	roq->ws = sn;
+	return new_nws;
+}
+
+
+/*
+ * Reset a queue
+ *
+ * @i2400m: device descriptor
+ * @cin: Queue Index
+ *
+ * Deliver all the packets and reset the window-start to zero. Name is
+ * kind of misleading.
+ */
+static
+void i2400m_roq_reset(struct i2400m *i2400m, struct i2400m_roq *roq)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	struct sk_buff *skb_itr, *tmp_itr;
+	struct i2400m_roq_data *roq_data_itr;
+
+	d_fnstart(2, dev, "(i2400m %p roq %p)\n", i2400m, roq);
+	i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_RESET,
+			     roq->ws, skb_queue_len(&roq->queue),
+			     ~0, ~0, 0);
+	skb_queue_walk_safe(&roq->queue, skb_itr, tmp_itr) {
+		roq_data_itr = (struct i2400m_roq_data *) &skb_itr->cb;
+		d_printf(2, dev, "ERX: roq %p - release skb %p (sn %u)\n",
+			 roq, skb_itr, roq_data_itr->sn);
+		__skb_unlink(skb_itr, &roq->queue);
+		i2400m_net_erx(i2400m, skb_itr, roq_data_itr->cs);
+	}
+	roq->ws = 0;
+	d_fnend(2, dev, "(i2400m %p roq %p) = void\n", i2400m, roq);
+	return;
+}
+
+
+/*
+ * Queue a packet
+ *
+ * @i2400m: device descriptor
+ * @cin: Queue Index
+ * @skb: containing the packet data
+ * @fbn: First block number of the packet in @skb
+ * @lbn: Last block number of the packet in @skb
+ *
+ * The hardware is asking the driver to queue a packet for later
+ * delivery to the networking stack.
+ */
+static
+void i2400m_roq_queue(struct i2400m *i2400m, struct i2400m_roq *roq,
+		      struct sk_buff * skb, unsigned lbn)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	unsigned nsn, len;
+
+	d_fnstart(2, dev, "(i2400m %p roq %p skb %p lbn %u) = void\n",
+		  i2400m, roq, skb, lbn);
+	len = skb_queue_len(&roq->queue);
+	nsn = __i2400m_roq_nsn(roq, lbn);
+	if (unlikely(nsn >= 1024)) {
+		dev_err(dev, "SW BUG? queue nsn %d (lbn %u ws %u)\n",
+			nsn, lbn, roq->ws);
+		i2400m_roq_log_dump(i2400m, roq);
+		i2400m->bus_reset(i2400m, I2400M_RT_WARM);
+	} else {
+		__i2400m_roq_queue(i2400m, roq, skb, lbn, nsn);
+		i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_PACKET,
+				     roq->ws, len, lbn, nsn, ~0);
+	}
+	d_fnend(2, dev, "(i2400m %p roq %p skb %p lbn %u) = void\n",
+		i2400m, roq, skb, lbn);
+	return;
+}
+
+
+/*
+ * Update the window start in a reorder queue and deliver all skbs
+ * with a lower window start
+ *
+ * @i2400m: device descriptor
+ * @roq: Reorder queue
+ * @sn: New sequence number
+ */
+static
+void i2400m_roq_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
+			  unsigned sn)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	unsigned old_ws, nsn, len;
+
+	d_fnstart(2, dev, "(i2400m %p roq %p sn %u)\n", i2400m, roq, sn);
+	old_ws = roq->ws;
+	len = skb_queue_len(&roq->queue);
+	nsn = __i2400m_roq_update_ws(i2400m, roq, sn);
+	i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_WS,
+			     old_ws, len, sn, nsn, roq->ws);
+	d_fnstart(2, dev, "(i2400m %p roq %p sn %u) = void\n", i2400m, roq, sn);
+	return;
+}
+
+
+/*
+ * Queue a packet and update the window start
+ *
+ * @i2400m: device descriptor
+ * @cin: Queue Index
+ * @skb: containing the packet data
+ * @fbn: First block number of the packet in @skb
+ * @sn: Last block number of the packet in @skb
+ *
+ * Note that unlike i2400m_roq_update_ws(), which sets the new window
+ * start to @sn, in here we'll set it to @sn + 1.
+ */
+static
+void i2400m_roq_queue_update_ws(struct i2400m *i2400m, struct i2400m_roq *roq,
+				struct sk_buff * skb, unsigned sn)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	unsigned nsn, old_ws, len;
+
+	d_fnstart(2, dev, "(i2400m %p roq %p skb %p sn %u)\n",
+		  i2400m, roq, skb, sn);
+	len = skb_queue_len(&roq->queue);
+	nsn = __i2400m_roq_nsn(roq, sn);
+	old_ws = roq->ws;
+	if (unlikely(nsn >= 1024)) {
+		dev_err(dev, "SW BUG? queue_update_ws nsn %u (sn %u ws %u)\n",
+			nsn, sn, roq->ws);
+		i2400m_roq_log_dump(i2400m, roq);
+		i2400m->bus_reset(i2400m, I2400M_RT_WARM);
+	} else {
+		/* if the queue is empty, don't bother as we'd queue
+		 * it and inmediately unqueue it -- just deliver it */
+		if (len == 0) {
+			struct i2400m_roq_data *roq_data;
+			roq_data = (struct i2400m_roq_data *) &skb->cb;
+			i2400m_net_erx(i2400m, skb, roq_data->cs);
+		}
+		else {
+			__i2400m_roq_queue(i2400m, roq, skb, sn, nsn);
+			__i2400m_roq_update_ws(i2400m, roq, sn + 1);
+		}
+		i2400m_roq_log_add(i2400m, roq, I2400M_RO_TYPE_PACKET_WS,
+				   old_ws, len, sn, nsn, roq->ws);
+	}
+	d_fnend(2, dev, "(i2400m %p roq %p skb %p sn %u) = void\n",
+		i2400m, roq, skb, sn);
+	return;
+}
+
+
 /*
  * Receive and send up an extended data packet
  *
@@ -347,6 +849,28 @@ error_check:
  * having to copy packets around.
  *
  * This function handles said path.
+ *
+ *
+ * Receive and send up an extended data packet that requires no reordering
+ *
+ * @i2400m: device descriptor
+ * @skb_rx: skb that contains the extended data packet
+ * @single_last: 1 if the payload is the only one or the last one of
+ *     the skb.
+ * @payload: pointer to the packet's data (past the actual extended
+ *     data payload header).
+ * @size: size of the payload
+ *
+ * Pass over to the networking stack a data packet that might have
+ * reordering requirements.
+ *
+ * This needs to the decide if the skb in which the packet is
+ * contained can be reused or if it needs to be cloned. Then it has to
+ * be trimmed in the edges so that the beginning is the space for eth
+ * header and then pass it to i2400m_net_erx() for the stack
+ *
+ * Assumes the caller has verified the sanity of the payload (size,
+ * etc) already.
  */
 static
 void i2400m_rx_edata(struct i2400m *i2400m, struct sk_buff *skb_rx,
@@ -357,53 +881,86 @@ void i2400m_rx_edata(struct i2400m *i2400m, struct sk_buff *skb_rx,
 	struct net_device *net_dev = i2400m->wimax_dev.net_dev;
 	struct sk_buff *skb;
 	enum i2400m_cs cs;
-	unsigned reorder_needed;
+	u32 reorder;
+	unsigned ro_needed, ro_type, ro_cin, ro_sn;
+	struct i2400m_roq *roq;
+	struct i2400m_roq_data *roq_data;
 
-	d_fnstart(4, dev, "(i2400m %p skb_rx %p single %u payload %p "
+	BUILD_BUG_ON(ETH_HLEN > sizeof(*hdr));
+
+	d_fnstart(2, dev, "(i2400m %p skb_rx %p single %u payload %p "
 		  "size %zu)\n", i2400m, skb_rx, single_last, payload, size);
 	if (size < sizeof(*hdr)) {
 		dev_err(dev, "ERX: HW BUG? message with short header (%zu "
 			"vs %zu bytes expected)\n", size, sizeof(*hdr));
 		goto error;
 	}
-	reorder_needed = le32_to_cpu(hdr->reorder & I2400M_REORDER_NEEDED);
-	cs = hdr->cs;
-	if (reorder_needed) {
-		dev_err(dev, "ERX: HW BUG? reorder needed, it was disabled\n");
-		goto error;
-	}
-	/* ok, so now decide if we want to clone or reuse the skb,
-	 * pull and trim it so the beginning is the space for the eth
-	 * header and pass it to i2400m_net_erx() for the stack */
+
 	if (single_last) {
 		skb = skb_get(skb_rx);
-		d_printf(3, dev, "ERX: reusing single payload skb %p\n", skb);
+		d_printf(3, dev, "ERX: skb %p reusing\n", skb);
 	} else {
 		skb = skb_clone(skb_rx, GFP_KERNEL);
-		d_printf(3, dev, "ERX: cloning %p\n", skb);
 		if (skb == NULL) {
 			dev_err(dev, "ERX: no memory to clone skb\n");
 			net_dev->stats.rx_dropped++;
 			goto error_skb_clone;
 		}
+		d_printf(3, dev, "ERX: skb %p cloned from %p\n", skb, skb_rx);
 	}
 	/* now we have to pull and trim so that the skb points to the
 	 * beginning of the IP packet; the netdev part will add the
-	 * ethernet header as needed. */
-	BUILD_BUG_ON(ETH_HLEN > sizeof(*hdr));
+	 * ethernet header as needed - we know there is enough space
+	 * because we checked in i2400m_rx_edata(). */
 	skb_pull(skb, payload + sizeof(*hdr) - (void *) skb->data);
-	skb_trim(skb, (void *) skb_end_pointer(skb) - payload + sizeof(*hdr));
-	i2400m_net_erx(i2400m, skb, cs);
+	skb_trim(skb, (void *) skb_end_pointer(skb) - payload - sizeof(*hdr));
+
+	reorder = le32_to_cpu(hdr->reorder);
+	ro_needed = reorder & I2400M_RO_NEEDED;
+	cs = hdr->cs;
+	if (ro_needed) {
+		ro_type = (reorder >> I2400M_RO_TYPE_SHIFT) & I2400M_RO_TYPE;
+		ro_cin = (reorder >> I2400M_RO_CIN_SHIFT) & I2400M_RO_CIN;
+		ro_sn = (reorder >> I2400M_RO_SN_SHIFT) & I2400M_RO_SN;
+
+		roq = &i2400m->rx_roq[ro_cin];
+		roq_data = (struct i2400m_roq_data *) &skb->cb;
+		roq_data->sn = ro_sn;
+		roq_data->cs = cs;
+		d_printf(2, dev, "ERX: reorder needed: "
+			 "type %u cin %u [ws %u] sn %u/%u len %zuB\n",
+			 ro_type, ro_cin, roq->ws, ro_sn,
+			 __i2400m_roq_nsn(roq, ro_sn), size);
+		d_dump(2, dev, payload, size);
+		switch(ro_type) {
+		case I2400M_RO_TYPE_RESET:
+			i2400m_roq_reset(i2400m, roq);
+			kfree_skb(skb);	/* no data here */
+			break;
+		case I2400M_RO_TYPE_PACKET:
+			i2400m_roq_queue(i2400m, roq, skb, ro_sn);
+			break;
+		case I2400M_RO_TYPE_WS:
+			i2400m_roq_update_ws(i2400m, roq, ro_sn);
+			kfree_skb(skb);	/* no data here */
+			break;
+		case I2400M_RO_TYPE_PACKET_WS:
+			i2400m_roq_queue_update_ws(i2400m, roq, skb, ro_sn);
+			break;
+		default:
+			dev_err(dev, "HW BUG? unknown reorder type %u\n", ro_type);
+		}
+	}
+	else
+		i2400m_net_erx(i2400m, skb, cs);
 error_skb_clone:
 error:
-	d_fnend(4, dev, "(i2400m %p skb_rx %p single %u payload %p "
+	d_fnend(2, dev, "(i2400m %p skb_rx %p single %u payload %p "
 		"size %zu) = void\n", i2400m, skb_rx, single_last, payload, size);
 	return;
 }
 
 
-
-
 /*
  * Act on a received payload
  *
@@ -632,3 +1189,73 @@ error_msg_hdr_check:
 	return result;
 }
 EXPORT_SYMBOL_GPL(i2400m_rx);
+
+
+/*
+ * Initialize the RX queue and infrastructure
+ *
+ * This sets up all the RX reordering infrastructures, which will not
+ * be used if reordering is not enabled or if the firmware does not
+ * support it. The device is told to do reordering in
+ * i2400m_dev_initialize(), where it also looks at the value of the
+ * i2400m->rx_reorder switch before taking a decission.
+ *
+ * Note we allocate the roq queues in one chunk and the actual logging
+ * support for it (logging) in another one and then we setup the
+ * pointers from the first to the last.
+ */
+int i2400m_rx_setup(struct i2400m *i2400m)
+{
+	int result = 0;
+	struct device *dev = i2400m_dev(i2400m);
+
+	i2400m->rx_reorder = i2400m_rx_reorder_disabled? 0 : 1;
+	if (i2400m->rx_reorder) {
+		unsigned itr;
+		size_t size;
+		struct i2400m_roq_log *rd;
+
+		result = -ENOMEM;
+
+		size = sizeof(i2400m->rx_roq[0]) * (I2400M_RO_CIN + 1);
+		i2400m->rx_roq = kzalloc(size, GFP_KERNEL);
+		if (i2400m->rx_roq == NULL) {
+			dev_err(dev, "RX: cannot allocate %zu bytes for "
+				"reorder queues\n", size);
+			goto error_roq_alloc;
+		}
+
+		size = sizeof(*i2400m->rx_roq[0].log) * (I2400M_RO_CIN + 1);
+		rd = kzalloc(size, GFP_KERNEL);
+		if (rd == NULL) {
+			dev_err(dev, "RX: cannot allocate %zu bytes for "
+				"reorder queues log areas\n", size);
+			result = -ENOMEM;
+			goto error_roq_log_alloc;
+		}
+
+		for(itr = 0; itr < I2400M_RO_CIN + 1; itr++) {
+			__i2400m_roq_init(&i2400m->rx_roq[itr]);
+			i2400m->rx_roq[itr].log = &rd[itr];
+		}
+	}
+	return 0;
+
+error_roq_log_alloc:
+	kfree(i2400m->rx_roq);
+error_roq_alloc:
+	return result;
+}
+
+
+/* Tear down the RX queue and infrastructure */
+void i2400m_rx_release(struct i2400m *i2400m)
+{
+	if (i2400m->rx_reorder) {
+		unsigned itr;
+		for(itr = 0; itr < I2400M_RO_CIN + 1; itr++)
+			__skb_queue_purge(&i2400m->rx_roq[itr].queue);
+		kfree(i2400m->rx_roq[0].log);
+		kfree(i2400m->rx_roq);
+	}
+}
diff --git a/include/linux/wimax/i2400m.h b/include/linux/wimax/i2400m.h
index ad36e07..d5148a7 100644
--- a/include/linux/wimax/i2400m.h
+++ b/include/linux/wimax/i2400m.h
@@ -225,15 +225,16 @@ struct i2400m_pl_data_hdr {
 /*
  * Payload for an extended data packet
  *
- * New in v1.4
+ * New in fw v1.4
  *
+ * @reorder: if this payload has to be reorder or not (and how)
  * @cs: the type of data in the packet, as defined per (802.16e
  *     T11.13.19.1). Currently only 2 (IPv4 packet) supported.
  *
  * This is prefixed to each and every INCOMING DATA packet.
  */
 struct i2400m_pl_edata_hdr {
-	__le32 reorder;
+	__le32 reorder;		/* bits defined in i2400m_ro */
 	__u8 cs;
 	__u8 reserved[11];
 } __attribute__((packed));
@@ -243,8 +244,23 @@ enum i2400m_cs {
 	I2400M_CS_IPV4 = 2,
 };
 
-enum i2400m_reorder {
-	I2400M_REORDER_NEEDED     = 0x01,
+enum i2400m_ro {
+	I2400M_RO_NEEDED     = 0x01,
+	I2400M_RO_TYPE       = 0x03,
+	I2400M_RO_TYPE_SHIFT = 1,
+	I2400M_RO_CIN        = 0x0f,
+	I2400M_RO_CIN_SHIFT  = 4,
+	I2400M_RO_FBN        = 0x07ff,
+	I2400M_RO_FBN_SHIFT  = 8,
+	I2400M_RO_SN         = 0x07ff,
+	I2400M_RO_SN_SHIFT   = 21,
+};
+
+enum i2400m_ro_type {
+	I2400M_RO_TYPE_RESET = 0,
+	I2400M_RO_TYPE_PACKET,
+	I2400M_RO_TYPE_WS,
+	I2400M_RO_TYPE_PACKET_WS,
 };
 
 
@@ -410,6 +426,7 @@ enum i2400m_tlv {
 	I2400M_TLV_CONFIG_IDLE_PARAMETERS = 601,
 	I2400M_TLV_CONFIG_IDLE_TIMEOUT = 611,
 	I2400M_TLV_CONFIG_D2H_DATA_FORMAT = 614,
+	I2400M_TLV_CONFIG_DL_HOST_REORDER = 615,
 };
 
 
@@ -553,5 +570,12 @@ struct i2400m_tlv_config_d2h_data_format {
 	__u8 reserved[3];
 } __attribute__((packed));
 
+/* New in v1.4 */
+struct i2400m_tlv_config_dl_host_reorder {
+	struct i2400m_tlv_hdr hdr;
+	__u8 reorder; 		/* 0 disabled, 1 enabled */
+	__u8 reserved[3];
+} __attribute__((packed));
+
 
 #endif /* #ifndef __LINUX__WIMAX__I2400M_H__ */
-- 
1.5.6.5


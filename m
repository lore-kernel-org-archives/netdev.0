From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 10/13] wimax/i2400m: queue device's report until the driver is ready for them
Date: Wed,  4 Nov 2009 13:40:05 -0800
Message-ID: <a0beba21c3e2dff9a31739f1660ba3ff8c7150a7.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45636 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932776AbZKDVmN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:13 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The i2400m might start sending reports to the driver before it is done
setting up all the infrastructure needed for handling them.

Currently we were just dropping them when the driver wasn't ready and
that is bad in certain situations, as the sync between the driver's
idea of the device's state and the device's state dissapears.

This changes that by implementing a queue for handling
reports. Incoming reports are appended to it and a workstruct is woken
to process the list of queued reports.

When the device is not yet ready to handle them, the workstruct is not
woken, but at soon as the device becomes ready again, the queue is
processed.

As a consequence of this, i2400m_queue_work() is no longer used, and
thus removed.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 drivers/net/wimax/i2400m/driver.c |   74 +------------------
 drivers/net/wimax/i2400m/i2400m.h |   14 +++-
 drivers/net/wimax/i2400m/rx.c     |  142 +++++++++++++++++++++++++++++--------
 3 files changed, 128 insertions(+), 102 deletions(-)

diff --git a/drivers/net/wimax/i2400m/driver.c b/drivers/net/wimax/i2400m/driver.c
index 9b78e05..42102eb 100644
--- a/drivers/net/wimax/i2400m/driver.c
+++ b/drivers/net/wimax/i2400m/driver.c
@@ -128,76 +128,6 @@ struct i2400m_work *__i2400m_work_setup(
 }
 
 
-/**
- * i2400m_queue_work - schedule work on a i2400m's queue
- *
- * @i2400m: device descriptor
- *
- * @fn: function to run to execute work. It gets passed a 'struct
- *     work_struct' that is wrapped in a 'struct i2400m_work'. Once
- *     done, you have to (1) i2400m_put(i2400m_work->i2400m) and then
- *     (2) kfree(i2400m_work).
- *
- * @gfp_flags: GFP flags for memory allocation.
- *
- * @pl: pointer to a payload buffer that you want to pass to the _work
- *     function. Use this to pack (for example) a struct with extra
- *     arguments.
- *
- * @pl_size: size of the payload buffer.
- *
- * We do this quite often, so this just saves typing; allocate a
- * wrapper for a i2400m, get a ref to it, pack arguments and launch
- * the work.
- *
- * A usual workflow is:
- *
- * struct my_work_args {
- *         void *something;
- *         int whatever;
- * };
- * ...
- *
- * struct my_work_args my_args = {
- *         .something = FOO,
- *         .whaetever = BLAH
- * };
- * i2400m_queue_work(i2400m, 1, my_work_function, GFP_KERNEL,
- *                   &args, sizeof(args))
- *
- * And now the work function can unpack the arguments and call the
- * real function (or do the job itself):
- *
- * static
- * void my_work_fn((struct work_struct *ws)
- * {
- *         struct i2400m_work *iw =
- *	           container_of(ws, struct i2400m_work, ws);
- *	   struct my_work_args *my_args = (void *) iw->pl;
- *
- *	   my_work(iw->i2400m, my_args->something, my_args->whatevert);
- * }
- */
-int i2400m_queue_work(struct i2400m *i2400m,
-		      void (*fn)(struct work_struct *), gfp_t gfp_flags,
-		      const void *pl, size_t pl_size)
-{
-	int result;
-	struct i2400m_work *iw;
-
-	BUG_ON(i2400m->work_queue == NULL);
-	result = -ENOMEM;
-	iw = __i2400m_work_setup(i2400m, fn, gfp_flags, pl, pl_size);
-	if (iw != NULL) {
-		result = queue_work(i2400m->work_queue, &iw->ws);
-		if (WARN_ON(result == 0))
-			result = -ENXIO;
-	}
-	return result;
-}
-EXPORT_SYMBOL_GPL(i2400m_queue_work);
-
-
 /*
  * Schedule i2400m's specific work on the system's queue.
  *
@@ -459,6 +389,8 @@ retry:
 		goto error_bus_dev_start;
 	i2400m->ready = 1;
 	wmb();		/* see i2400m->ready's documentation  */
+	/* process pending reports from the device */
+	queue_work(i2400m->work_queue, &i2400m->rx_report_ws);
 	result = i2400m_firmware_check(i2400m);	/* fw versions ok? */
 	if (result < 0)
 		goto error_fw_check;
@@ -868,6 +800,8 @@ void i2400m_init(struct i2400m *i2400m)
 	spin_lock_init(&i2400m->rx_lock);
 	i2400m->rx_pl_min = UINT_MAX;
 	i2400m->rx_size_min = UINT_MAX;
+	INIT_LIST_HEAD(&i2400m->rx_reports);
+	INIT_WORK(&i2400m->rx_report_ws, i2400m_report_hook_work);
 
 	mutex_init(&i2400m->msg_mutex);
 	init_completion(&i2400m->msg_completion);
diff --git a/drivers/net/wimax/i2400m/i2400m.h b/drivers/net/wimax/i2400m/i2400m.h
index 4f8815d..55bca43 100644
--- a/drivers/net/wimax/i2400m/i2400m.h
+++ b/drivers/net/wimax/i2400m/i2400m.h
@@ -421,6 +421,13 @@ struct i2400m_barker_db;
  *     delivered. Then the driver can release them to the host. See
  *     drivers/net/i2400m/rx.c for details.
  *
+ * @rx_reports: reports received from the device that couldn't be
+ *     processed because the driver wasn't still ready; when ready,
+ *     they are pulled from here and chewed.
+ *
+ * @rx_reports_ws: Work struct used to kick a scan of the RX reports
+ *     list and to process each.
+ *
  * @src_mac_addr: MAC address used to make ethernet packets be coming
  *     from. This is generated at i2400m_setup() time and used during
  *     the life cycle of the instance. See i2400m_fake_eth_header().
@@ -548,6 +555,8 @@ struct i2400m {
 		rx_num, rx_size_acc, rx_size_min, rx_size_max;
 	struct i2400m_roq *rx_roq;	/* not under rx_lock! */
 	u8 src_mac_addr[ETH_HLEN];
+	struct list_head rx_reports;	/* under rx_lock! */
+	struct work_struct rx_report_ws;
 
 	struct mutex msg_mutex;		/* serialize command execution */
 	struct completion msg_completion;
@@ -830,9 +839,7 @@ struct i2400m_work {
 	size_t pl_size;
 	u8 pl[0];
 };
-extern int i2400m_queue_work(struct i2400m *,
-			     void (*)(struct work_struct *), gfp_t,
-			     const void *, size_t);
+
 extern int i2400m_schedule_work(struct i2400m *,
 				void (*)(struct work_struct *), gfp_t,
 				const void *, size_t);
@@ -847,6 +854,7 @@ extern void i2400m_msg_ack_hook(struct i2400m *,
 				const struct i2400m_l3l4_hdr *, size_t);
 extern void i2400m_report_hook(struct i2400m *,
 			       const struct i2400m_l3l4_hdr *, size_t);
+extern void i2400m_report_hook_work(struct work_struct *);
 extern int i2400m_cmd_enter_powersave(struct i2400m *);
 extern int i2400m_cmd_get_state(struct i2400m *);
 extern int i2400m_cmd_exit_idle(struct i2400m *);
diff --git a/drivers/net/wimax/i2400m/rx.c b/drivers/net/wimax/i2400m/rx.c
index 82c200a..64a44ca 100644
--- a/drivers/net/wimax/i2400m/rx.c
+++ b/drivers/net/wimax/i2400m/rx.c
@@ -158,29 +158,104 @@ struct i2400m_report_hook_args {
 	struct sk_buff *skb_rx;
 	const struct i2400m_l3l4_hdr *l3l4_hdr;
 	size_t size;
+	struct list_head list_node;
 };
 
 
 /*
  * Execute i2400m_report_hook in a workqueue
  *
- * Unpacks arguments from the deferred call, executes it and then
- * drops the references.
+ * Goes over the list of queued reports in i2400m->rx_reports and
+ * processes them.
  *
- * Obvious NOTE: References are needed because we are a separate
- *     thread; otherwise the buffer changes under us because it is
- *     released by the original caller.
+ * NOTE: refcounts on i2400m are not needed because we flush the
+ *     workqueue this runs on (i2400m->work_queue) before destroying
+ *     i2400m.
  */
-static
 void i2400m_report_hook_work(struct work_struct *ws)
 {
-	struct i2400m_work *iw =
-		container_of(ws, struct i2400m_work, ws);
-	struct i2400m_report_hook_args *args = (void *) iw->pl;
-	i2400m_report_hook(iw->i2400m, args->l3l4_hdr, args->size);
-	kfree_skb(args->skb_rx);
-	i2400m_put(iw->i2400m);
-	kfree(iw);
+	struct i2400m *i2400m = container_of(ws, struct i2400m, rx_report_ws);
+	struct device *dev = i2400m_dev(i2400m);
+	struct i2400m_report_hook_args *args, *args_next;
+	LIST_HEAD(list);
+	unsigned long flags;
+
+	while (1) {
+		spin_lock_irqsave(&i2400m->rx_lock, flags);
+		list_splice_init(&i2400m->rx_reports, &list);
+		spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+		if (list_empty(&list))
+			break;
+		else
+			d_printf(1, dev, "processing queued reports\n");
+		list_for_each_entry_safe(args, args_next, &list, list_node) {
+			d_printf(2, dev, "processing queued report %p\n", args);
+			i2400m_report_hook(i2400m, args->l3l4_hdr, args->size);
+			kfree_skb(args->skb_rx);
+			list_del(&args->list_node);
+			kfree(args);
+		}
+	}
+}
+
+
+/*
+ * Flush the list of queued reports
+ */
+static
+void i2400m_report_hook_flush(struct i2400m *i2400m)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	struct i2400m_report_hook_args *args, *args_next;
+	LIST_HEAD(list);
+	unsigned long flags;
+
+	d_printf(1, dev, "flushing queued reports\n");
+	spin_lock_irqsave(&i2400m->rx_lock, flags);
+	list_splice_init(&i2400m->rx_reports, &list);
+	spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+	list_for_each_entry_safe(args, args_next, &list, list_node) {
+		d_printf(2, dev, "flushing queued report %p\n", args);
+		kfree_skb(args->skb_rx);
+		list_del(&args->list_node);
+		kfree(args);
+	}
+}
+
+
+/*
+ * Queue a report for later processing
+ *
+ * @i2400m: device descriptor
+ * @skb_rx: skb that contains the payload (for reference counting)
+ * @l3l4_hdr: pointer to the control
+ * @size: size of the message
+ */
+static
+void i2400m_report_hook_queue(struct i2400m *i2400m, struct sk_buff *skb_rx,
+			      const void *l3l4_hdr, size_t size)
+{
+	struct device *dev = i2400m_dev(i2400m);
+	unsigned long flags;
+	struct i2400m_report_hook_args *args;
+
+	args = kzalloc(sizeof(*args), GFP_NOIO);
+	if (args) {
+		args->skb_rx = skb_get(skb_rx);
+		args->l3l4_hdr = l3l4_hdr;
+		args->size = size;
+		spin_lock_irqsave(&i2400m->rx_lock, flags);
+		list_add_tail(&args->list_node, &i2400m->rx_reports);
+		spin_unlock_irqrestore(&i2400m->rx_lock, flags);
+		d_printf(2, dev, "queued report %p\n", args);
+		rmb();		/* see i2400m->ready's documentation  */
+		if (likely(i2400m->ready))	/* only send if up */
+			queue_work(i2400m->work_queue, &i2400m->rx_report_ws);
+	} else  {
+		if (printk_ratelimit())
+			dev_err(dev, "%s:%u: Can't allocate %zu B\n",
+				__func__, __LINE__, sizeof(*args));
+	}
 }
 
 
@@ -294,22 +369,29 @@ void i2400m_rx_ctl(struct i2400m *i2400m, struct sk_buff *skb_rx,
 		 msg_type, size);
 	d_dump(2, dev, l3l4_hdr, size);
 	if (msg_type & I2400M_MT_REPORT_MASK) {
-		/* These hooks have to be ran serialized; as well, the
-		 * handling might force the execution of commands, and
-		 * that might cause reentrancy issues with
-		 * bus-specific subdrivers and workqueues. So we run
-		 * it in a separate workqueue. */
-		struct i2400m_report_hook_args args = {
-			.skb_rx = skb_rx,
-			.l3l4_hdr = l3l4_hdr,
-			.size = size
-		};
-		rmb();		/* see i2400m->ready's documentation  */
-		if (likely(i2400m->ready)) {	/* only send if up */
-			skb_get(skb_rx);
-			i2400m_queue_work(i2400m, i2400m_report_hook_work,
-					  GFP_KERNEL, &args, sizeof(args));
-		}
+		/*
+		 * Process each report
+		 *
+		 * - has to be ran serialized as well
+		 *
+		 * - the handling might force the execution of
+		 *   commands. That might cause reentrancy issues with
+		 *   bus-specific subdrivers and workqueues, so the we
+		 *   run it in a separate workqueue.
+		 *
+		 * - when the driver is not yet ready to handle them,
+		 *   they are queued and at some point the queue is
+		 *   restarted [NOTE: we can't queue SKBs directly, as
+		 *   this might be a piece of a SKB, not the whole
+		 *   thing, and this is cheaper than cloning the
+		 *   SKB].
+		 *
+		 * Note we don't do refcounting for the device
+		 * structure; this is because before destroying
+		 * 'i2400m', we make sure to flush the
+		 * i2400m->work_queue, so there are no issues.
+		 */
+		i2400m_report_hook_queue(i2400m, skb_rx, l3l4_hdr, size);
 		if (unlikely(i2400m->trace_msg_from_user))
 			wimax_msg(&i2400m->wimax_dev, "echo",
 				  l3l4_hdr, size, GFP_KERNEL);
@@ -1281,4 +1363,6 @@ void i2400m_rx_release(struct i2400m *i2400m)
 		kfree(i2400m->rx_roq[0].log);
 		kfree(i2400m->rx_roq);
 	}
+	/* at this point, nothing can be received... */
+	i2400m_report_hook_flush(i2400m);
 }
-- 
1.6.2.5


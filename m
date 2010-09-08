From: frank.blaschka@de.ibm.com
Subject: [patch 1/4] [PATCH] qdio: extend API to allow polling
Date: Wed, 08 Sep 2010 09:14:39 +0200
Message-ID: <20100908071601.097250895@de.ibm.com>
References: <20100908071438.085729717@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Jan Glauber <jang@linux.vnet.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:37623 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755136Ab0IHHQE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 03:16:04 -0400
Content-Disposition: inline; filename=101-napi-qdio.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Glauber <jang@linux.vnet.ibm.com>

Extend the qdio API to allow polling in the upper-layer driver. This
is needed by qeth to use NAPI.

To use the new interface the upper-layer driver must specify the
queue_start_poll(). This callback is used to signal the upper-layer
driver that is has initiative and must process the inbound queue by
calling qdio_get_next_buffers(). If the upper-layer driver wants to
stop polling it calls qdio_start_irq().

Since adapter interrupts are not completely stoppable qdio implements
a software bit QDIO_QUEUE_IRQS_DISABLED to safely disable interrupts for an
input queue.

The old interface is preserved and will be used as is by zfcp.

Signed-off-by: Jan Glauber <jang@linux.vnet.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 arch/s390/include/asm/qdio.h    |   13 ++-
 drivers/s390/cio/qdio.h         |   29 ++++++++
 drivers/s390/cio/qdio_debug.c   |   33 +++------
 drivers/s390/cio/qdio_main.c    |  138 +++++++++++++++++++++++++++++++++++++++-
 drivers/s390/cio/qdio_setup.c   |    1 
 drivers/s390/cio/qdio_thinint.c |   66 +++++++++++--------
 drivers/s390/scsi/zfcp_qdio.c   |    6 -
 7 files changed, 225 insertions(+), 61 deletions(-)

diff -urpN linux-2.6/arch/s390/include/asm/qdio.h linux-2.6-patched/arch/s390/include/asm/qdio.h
--- linux-2.6/arch/s390/include/asm/qdio.h	2010-09-07 09:57:16.000000000 +0200
+++ linux-2.6-patched/arch/s390/include/asm/qdio.h	2010-09-07 09:57:23.000000000 +0200
@@ -360,6 +360,7 @@ struct qdio_initialize {
 	unsigned int no_output_qs;
 	qdio_handler_t *input_handler;
 	qdio_handler_t *output_handler;
+	void (*queue_start_poll) (struct ccw_device *, int, unsigned long);
 	unsigned long int_parm;
 	void **input_sbal_addr_array;
 	void **output_sbal_addr_array;
@@ -377,11 +378,13 @@ struct qdio_initialize {
 extern int qdio_allocate(struct qdio_initialize *);
 extern int qdio_establish(struct qdio_initialize *);
 extern int qdio_activate(struct ccw_device *);
-
-extern int do_QDIO(struct ccw_device *cdev, unsigned int callflags,
-		   int q_nr, unsigned int bufnr, unsigned int count);
-extern int qdio_shutdown(struct ccw_device*, int);
+extern int do_QDIO(struct ccw_device *, unsigned int, int, unsigned int,
+		   unsigned int);
+extern int qdio_start_irq(struct ccw_device *, int);
+extern int qdio_stop_irq(struct ccw_device *, int);
+extern int qdio_get_next_buffers(struct ccw_device *, int, int *, int *);
+extern int qdio_shutdown(struct ccw_device *, int);
 extern int qdio_free(struct ccw_device *);
-extern int qdio_get_ssqd_desc(struct ccw_device *dev, struct qdio_ssqd_desc*);
+extern int qdio_get_ssqd_desc(struct ccw_device *, struct qdio_ssqd_desc *);
 
 #endif /* __QDIO_H__ */
diff -urpN linux-2.6/drivers/s390/cio/qdio_debug.c linux-2.6-patched/drivers/s390/cio/qdio_debug.c
--- linux-2.6/drivers/s390/cio/qdio_debug.c	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/cio/qdio_debug.c	2010-09-07 09:57:23.000000000 +0200
@@ -56,9 +56,16 @@ static int qstat_show(struct seq_file *m
 
 	seq_printf(m, "DSCI: %d   nr_used: %d\n",
 		   *(u32 *)q->irq_ptr->dsci, atomic_read(&q->nr_buf_used));
-	seq_printf(m, "ftc: %d  last_move: %d\n", q->first_to_check, q->last_move);
-	seq_printf(m, "polling: %d  ack start: %d  ack count: %d\n",
-		   q->u.in.polling, q->u.in.ack_start, q->u.in.ack_count);
+	seq_printf(m, "ftc: %d  last_move: %d\n",
+		   q->first_to_check, q->last_move);
+	if (q->is_input_q) {
+		seq_printf(m, "polling: %d  ack start: %d  ack count: %d\n",
+			   q->u.in.polling, q->u.in.ack_start,
+			   q->u.in.ack_count);
+		seq_printf(m, "IRQs disabled: %u\n",
+			   test_bit(QDIO_QUEUE_IRQS_DISABLED,
+			   &q->u.in.queue_irq_state));
+	}
 	seq_printf(m, "SBAL states:\n");
 	seq_printf(m, "|0      |8      |16     |24     |32     |40     |48     |56  63|\n");
 
@@ -113,22 +120,6 @@ static int qstat_show(struct seq_file *m
 	return 0;
 }
 
-static ssize_t qstat_seq_write(struct file *file, const char __user *buf,
-			       size_t count, loff_t *off)
-{
-	struct seq_file *seq = file->private_data;
-	struct qdio_q *q = seq->private;
-
-	if (!q)
-		return 0;
-	if (q->is_input_q)
-		xchg(q->irq_ptr->dsci, 1);
-	local_bh_disable();
-	tasklet_schedule(&q->tasklet);
-	local_bh_enable();
-	return count;
-}
-
 static int qstat_seq_open(struct inode *inode, struct file *filp)
 {
 	return single_open(filp, qstat_show,
@@ -139,7 +130,6 @@ static const struct file_operations debu
 	.owner	 = THIS_MODULE,
 	.open	 = qstat_seq_open,
 	.read	 = seq_read,
-	.write	 = qstat_seq_write,
 	.llseek  = seq_lseek,
 	.release = single_release,
 };
@@ -166,7 +156,8 @@ static char *qperf_names[] = {
 	"QEBSM eqbs",
 	"QEBSM eqbs partial",
 	"QEBSM sqbs",
-	"QEBSM sqbs partial"
+	"QEBSM sqbs partial",
+	"Discarded interrupts"
 };
 
 static int qperf_show(struct seq_file *m, void *v)
diff -urpN linux-2.6/drivers/s390/cio/qdio.h linux-2.6-patched/drivers/s390/cio/qdio.h
--- linux-2.6/drivers/s390/cio/qdio.h	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/cio/qdio.h	2010-09-07 09:57:23.000000000 +0200
@@ -208,6 +208,7 @@ struct qdio_dev_perf_stat {
 	unsigned int eqbs_partial;
 	unsigned int sqbs;
 	unsigned int sqbs_partial;
+	unsigned int int_discarded;
 } ____cacheline_aligned;
 
 struct qdio_queue_perf_stat {
@@ -222,6 +223,10 @@ struct qdio_queue_perf_stat {
 	unsigned int nr_sbal_total;
 };
 
+enum qdio_queue_irq_states {
+	QDIO_QUEUE_IRQS_DISABLED,
+};
+
 struct qdio_input_q {
 	/* input buffer acknowledgement flag */
 	int polling;
@@ -231,6 +236,10 @@ struct qdio_input_q {
 	int ack_count;
 	/* last time of noticing incoming data */
 	u64 timestamp;
+	/* upper-layer polling flag */
+	unsigned long queue_irq_state;
+	/* callback to start upper-layer polling */
+	void (*queue_start_poll) (struct ccw_device *, int, unsigned long);
 };
 
 struct qdio_output_q {
@@ -399,6 +408,26 @@ static inline int multicast_outbound(str
 #define sub_buf(bufnr, dec) \
 	((bufnr - dec) & QDIO_MAX_BUFFERS_MASK)
 
+#define queue_irqs_enabled(q)			\
+	(test_bit(QDIO_QUEUE_IRQS_DISABLED, &q->u.in.queue_irq_state) == 0)
+#define queue_irqs_disabled(q)			\
+	(test_bit(QDIO_QUEUE_IRQS_DISABLED, &q->u.in.queue_irq_state) != 0)
+
+#define TIQDIO_SHARED_IND		63
+
+/* device state change indicators */
+struct indicator_t {
+	u32 ind;	/* u32 because of compare-and-swap performance */
+	atomic_t count; /* use count, 0 or 1 for non-shared indicators */
+};
+
+extern struct indicator_t *q_indicators;
+
+static inline int shared_ind(struct qdio_irq *irq_ptr)
+{
+	return irq_ptr->dsci == &q_indicators[TIQDIO_SHARED_IND].ind;
+}
+
 /* prototypes for thin interrupt */
 void qdio_setup_thinint(struct qdio_irq *irq_ptr);
 int qdio_establish_thinint(struct qdio_irq *irq_ptr);
diff -urpN linux-2.6/drivers/s390/cio/qdio_main.c linux-2.6-patched/drivers/s390/cio/qdio_main.c
--- linux-2.6/drivers/s390/cio/qdio_main.c	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/cio/qdio_main.c	2010-09-07 09:57:23.000000000 +0200
@@ -884,8 +884,19 @@ static void qdio_int_handler_pci(struct
 	if (unlikely(irq_ptr->state == QDIO_IRQ_STATE_STOPPED))
 		return;
 
-	for_each_input_queue(irq_ptr, q, i)
-		tasklet_schedule(&q->tasklet);
+	for_each_input_queue(irq_ptr, q, i) {
+		if (q->u.in.queue_start_poll) {
+			/* skip if polling is enabled or already in work */
+			if (test_and_set_bit(QDIO_QUEUE_IRQS_DISABLED,
+				     &q->u.in.queue_irq_state)) {
+				qperf_inc(q, int_discarded);
+				continue;
+			}
+			q->u.in.queue_start_poll(q->irq_ptr->cdev, q->nr,
+						 q->irq_ptr->int_parm);
+		} else
+			tasklet_schedule(&q->tasklet);
+	}
 
 	if (!(irq_ptr->qib.ac & QIB_AC_OUTBOUND_PCI_SUPPORTED))
 		return;
@@ -1519,6 +1530,129 @@ int do_QDIO(struct ccw_device *cdev, uns
 }
 EXPORT_SYMBOL_GPL(do_QDIO);
 
+/**
+ * qdio_start_irq - process input buffers
+ * @cdev: associated ccw_device for the qdio subchannel
+ * @nr: input queue number
+ *
+ * Return codes
+ *   0 - success
+ *   1 - irqs not started since new data is available
+ */
+int qdio_start_irq(struct ccw_device *cdev, int nr)
+{
+	struct qdio_q *q;
+	struct qdio_irq *irq_ptr = cdev->private->qdio_data;
+
+	if (!irq_ptr)
+		return -ENODEV;
+	q = irq_ptr->input_qs[nr];
+
+	WARN_ON(queue_irqs_enabled(q));
+
+	if (!shared_ind(q->irq_ptr))
+		xchg(q->irq_ptr->dsci, 0);
+
+	qdio_stop_polling(q);
+	clear_bit(QDIO_QUEUE_IRQS_DISABLED, &q->u.in.queue_irq_state);
+
+	/*
+	 * We need to check again to not lose initiative after
+	 * resetting the ACK state.
+	 */
+	if (!shared_ind(q->irq_ptr) && *q->irq_ptr->dsci)
+		goto rescan;
+	if (!qdio_inbound_q_done(q))
+		goto rescan;
+	return 0;
+
+rescan:
+	if (test_and_set_bit(QDIO_QUEUE_IRQS_DISABLED,
+			     &q->u.in.queue_irq_state))
+		return 0;
+	else
+		return 1;
+
+}
+EXPORT_SYMBOL(qdio_start_irq);
+
+/**
+ * qdio_get_next_buffers - process input buffers
+ * @cdev: associated ccw_device for the qdio subchannel
+ * @nr: input queue number
+ * @bufnr: first filled buffer number
+ * @error: buffers are in error state
+ *
+ * Return codes
+ *   < 0 - error
+ *   = 0 - no new buffers found
+ *   > 0 - number of processed buffers
+ */
+int qdio_get_next_buffers(struct ccw_device *cdev, int nr, int *bufnr,
+			  int *error)
+{
+	struct qdio_q *q;
+	int start, end;
+	struct qdio_irq *irq_ptr = cdev->private->qdio_data;
+
+	if (!irq_ptr)
+		return -ENODEV;
+	q = irq_ptr->input_qs[nr];
+	WARN_ON(queue_irqs_enabled(q));
+
+	qdio_sync_after_thinint(q);
+
+	/*
+	 * The interrupt could be caused by a PCI request. Check the
+	 * PCI capable outbound queues.
+	 */
+	qdio_check_outbound_after_thinint(q);
+
+	if (!qdio_inbound_q_moved(q))
+		return 0;
+
+	/* Note: upper-layer MUST stop processing immediately here ... */
+	if (unlikely(q->irq_ptr->state != QDIO_IRQ_STATE_ACTIVE))
+		return -EIO;
+
+	start = q->first_to_kick;
+	end = q->first_to_check;
+	*bufnr = start;
+	*error = q->qdio_error;
+
+	/* for the next time */
+	q->first_to_kick = end;
+	q->qdio_error = 0;
+	return sub_buf(end, start);
+}
+EXPORT_SYMBOL(qdio_get_next_buffers);
+
+/**
+ * qdio_stop_irq - disable interrupt processing for the device
+ * @cdev: associated ccw_device for the qdio subchannel
+ * @nr: input queue number
+ *
+ * Return codes
+ *   0 - interrupts were already disabled
+ *   1 - interrupts successfully disabled
+ */
+int qdio_stop_irq(struct ccw_device *cdev, int nr)
+{
+	struct qdio_q *q;
+	struct qdio_irq *irq_ptr = cdev->private->qdio_data;
+
+	if (!irq_ptr)
+		return -ENODEV;
+	q = irq_ptr->input_qs[nr];
+
+	if (test_and_set_bit(QDIO_QUEUE_IRQS_DISABLED,
+			     &q->u.in.queue_irq_state))
+		return 0;
+	else
+		return 1;
+}
+EXPORT_SYMBOL(qdio_stop_irq);
+
 static int __init init_QDIO(void)
 {
 	int rc;
diff -urpN linux-2.6/drivers/s390/cio/qdio_setup.c linux-2.6-patched/drivers/s390/cio/qdio_setup.c
--- linux-2.6/drivers/s390/cio/qdio_setup.c	2010-09-07 09:57:18.000000000 +0200
+++ linux-2.6-patched/drivers/s390/cio/qdio_setup.c	2010-09-07 09:57:23.000000000 +0200
@@ -161,6 +161,7 @@ static void setup_queues(struct qdio_irq
 		setup_queues_misc(q, irq_ptr, qdio_init->input_handler, i);
 
 		q->is_input_q = 1;
+		q->u.in.queue_start_poll = qdio_init->queue_start_poll;
 		setup_storage_lists(q, irq_ptr, input_sbal_array, i);
 		input_sbal_array += QDIO_MAX_BUFFERS_PER_Q;
 
diff -urpN linux-2.6/drivers/s390/cio/qdio_thinint.c linux-2.6-patched/drivers/s390/cio/qdio_thinint.c
--- linux-2.6/drivers/s390/cio/qdio_thinint.c	2010-08-02 00:11:14.000000000 +0200
+++ linux-2.6-patched/drivers/s390/cio/qdio_thinint.c	2010-09-07 09:57:23.000000000 +0200
@@ -25,24 +25,20 @@
  */
 #define TIQDIO_NR_NONSHARED_IND		63
 #define TIQDIO_NR_INDICATORS		(TIQDIO_NR_NONSHARED_IND + 1)
-#define TIQDIO_SHARED_IND		63
 
 /* list of thin interrupt input queues */
 static LIST_HEAD(tiq_list);
 DEFINE_MUTEX(tiq_list_lock);
 
 /* adapter local summary indicator */
-static unsigned char *tiqdio_alsi;
+static u8 *tiqdio_alsi;
 
-/* device state change indicators */
-struct indicator_t {
-	u32 ind;	/* u32 because of compare-and-swap performance */
-	atomic_t count; /* use count, 0 or 1 for non-shared indicators */
-};
-static struct indicator_t *q_indicators;
+struct indicator_t *q_indicators;
 
 static int css_qdio_omit_svs;
 
+static u64 last_ai_time;
+
 static inline unsigned long do_clear_global_summary(void)
 {
 	register unsigned long __fn asm("1") = 3;
@@ -116,59 +112,73 @@ void tiqdio_remove_input_queues(struct q
 	}
 }
 
-static inline int shared_ind(struct qdio_irq *irq_ptr)
+static inline int shared_ind_used(void)
 {
-	return irq_ptr->dsci == &q_indicators[TIQDIO_SHARED_IND].ind;
+	return atomic_read(&q_indicators[TIQDIO_SHARED_IND].count);
 }
 
 /**
  * tiqdio_thinint_handler - thin interrupt handler for qdio
- * @ind: pointer to adapter local summary indicator
- * @drv_data: NULL
+ * @alsi: pointer to adapter local summary indicator
+ * @data: NULL
  */
-static void tiqdio_thinint_handler(void *ind, void *drv_data)
+static void tiqdio_thinint_handler(void *alsi, void *data)
 {
 	struct qdio_q *q;
 
+	last_ai_time = S390_lowcore.int_clock;
+
 	/*
 	 * SVS only when needed: issue SVS to benefit from iqdio interrupt
-	 * avoidance (SVS clears adapter interrupt suppression overwrite)
+	 * avoidance (SVS clears adapter interrupt suppression overwrite).
 	 */
 	if (!css_qdio_omit_svs)
 		do_clear_global_summary();
 
-	/*
-	 * reset local summary indicator (tiqdio_alsi) to stop adapter
-	 * interrupts for now
-	 */
-	xchg((u8 *)ind, 0);
+	/* reset local summary indicator */
+	if (shared_ind_used())
+		xchg(tiqdio_alsi, 0);
 
 	/* protect tiq_list entries, only changed in activate or shutdown */
 	rcu_read_lock();
 
 	/* check for work on all inbound thinint queues */
-	list_for_each_entry_rcu(q, &tiq_list, entry)
+	list_for_each_entry_rcu(q, &tiq_list, entry) {
+
 		/* only process queues from changed sets */
-		if (*q->irq_ptr->dsci) {
-			qperf_inc(q, adapter_int);
+		if (!*q->irq_ptr->dsci)
+			continue;
 
+		if (q->u.in.queue_start_poll) {
+			/* skip if polling is enabled or already in work */
+			if (test_and_set_bit(QDIO_QUEUE_IRQS_DISABLED,
+					     &q->u.in.queue_irq_state)) {
+				qperf_inc(q, int_discarded);
+				continue;
+			}
+
+			/* avoid dsci clear here, done after processing */
+			q->u.in.queue_start_poll(q->irq_ptr->cdev, q->nr,
+						 q->irq_ptr->int_parm);
+		} else {
 			/* only clear it if the indicator is non-shared */
 			if (!shared_ind(q->irq_ptr))
 				xchg(q->irq_ptr->dsci, 0);
 			/*
-			 * don't call inbound processing directly since
-			 * that could starve other thinint queues
+			 * Call inbound processing but not directly
+			 * since that could starve other thinint queues.
 			 */
 			tasklet_schedule(&q->tasklet);
 		}
-
+		qperf_inc(q, adapter_int);
+	}
 	rcu_read_unlock();
 
 	/*
-	 * if we used the shared indicator clear it now after all queues
-	 * were processed
+	 * If the shared indicator was used clear it now after all queues
+	 * were processed.
 	 */
-	if (atomic_read(&q_indicators[TIQDIO_SHARED_IND].count)) {
+	if (shared_ind_used()) {
 		xchg(&q_indicators[TIQDIO_SHARED_IND].ind, 0);
 
 		/* prevent racing */
diff -urpN linux-2.6/drivers/s390/scsi/zfcp_qdio.c linux-2.6-patched/drivers/s390/scsi/zfcp_qdio.c
--- linux-2.6/drivers/s390/scsi/zfcp_qdio.c	2010-09-07 09:57:18.000000000 +0200
+++ linux-2.6-patched/drivers/s390/scsi/zfcp_qdio.c	2010-09-07 09:57:23.000000000 +0200
@@ -277,16 +277,12 @@ int zfcp_qdio_send(struct zfcp_qdio *qdi
 static void zfcp_qdio_setup_init_data(struct qdio_initialize *id,
 				      struct zfcp_qdio *qdio)
 {
-
+	memset(id, 0, sizeof(*id));
 	id->cdev = qdio->adapter->ccw_device;
 	id->q_format = QDIO_ZFCP_QFMT;
 	memcpy(id->adapter_name, dev_name(&id->cdev->dev), 8);
 	ASCEBC(id->adapter_name, 8);
 	id->qib_rflags = QIB_RFLAGS_ENABLE_DATA_DIV;
-	id->qib_param_field_format = 0;
-	id->qib_param_field = NULL;
-	id->input_slib_elements = NULL;
-	id->output_slib_elements = NULL;
 	id->no_input_qs = 1;
 	id->no_output_qs = 1;
 	id->input_handler = zfcp_qdio_int_resp;


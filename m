From: Frank Pavlic <fpavlic@de.ibm.com>
Subject: [PATCH 2/5] s390: free skbs in finite amount of time in qeth
Date: Mon, 30 Apr 2007 17:42:06 +0200
Message-ID: <20070430154206.GB23666@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:42978 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423422AbXD3Pmm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2007 11:42:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

Free sent skbs in some finite amount of time. Affected are
asynchronous queue of Hipersockets devices and the output
queues of all eth-devices respectively.
     
Signed-off-by: Ursula Braun <braunu@de.ibm.com>
Signed-off-by: Frank Pavlic <fpavlic@de.ibm.com>
---
 drivers/s390/cio/qdio.c      |   37 +++++++++++++++++++++++++++----------
 drivers/s390/cio/qdio.h      |    4 +++-
 drivers/s390/net/qeth_main.c |   14 ++++++++------
 include/asm-s390/qdio.h      |    1 +
 4 files changed, 39 insertions(+), 17 deletions(-)

diff --git a/drivers/s390/cio/qdio.c b/drivers/s390/cio/qdio.c
index 05fac07..06bae6a 100644
--- a/drivers/s390/cio/qdio.c
+++ b/drivers/s390/cio/qdio.c
@@ -978,18 +978,25 @@ __qdio_outbound_processing(struct qdio_q *q)
 	if (qdio_has_outbound_q_moved(q))
 		qdio_kick_outbound_handler(q);
 
-	if (q->is_iqdio_q) {
+	if (q->queue_type == QDIO_ZFCP_QFMT) {
+		if ((!q->hydra_gives_outbound_pcis) &&
+		    (!qdio_is_outbound_q_done(q)))
+			qdio_mark_q(q);
+	}
+	else if (((!q->is_iqdio_q) && (!q->is_pci_out)) ||
+		 (q->queue_type == QDIO_IQDIO_QFMT_ASYNCH)) {
 		/* 
-		 * for asynchronous queues, we better check, if the sent
-		 * buffer is already switched from PRIMED to EMPTY.
+		 * make sure buffer switch from PRIMED to EMPTY is noticed
+		 * and outbound_handler is called
 		 */
-		if ((q->queue_type == QDIO_IQDIO_QFMT_ASYNCH) &&
-		    !qdio_is_outbound_q_done(q))
-			qdio_mark_q(q);
-
-	} else if (!q->hydra_gives_outbound_pcis)
-		if (!qdio_is_outbound_q_done(q))
-			qdio_mark_q(q);
+		if (qdio_is_outbound_q_done(q)) {
+			del_timer(&q->timer);
+		} else {
+			if (!timer_pending(&q->timer))
+				mod_timer(&q->timer, jiffies +
+					  QDIO_FORCE_CHECK_TIMEOUT);
+		}
+	}
 
 	qdio_release_q(q);
 }
@@ -1830,6 +1837,7 @@ qdio_fill_qs(struct qdio_irq *irq_ptr, struct ccw_device *cdev,
 			q->queue_type = QDIO_IQDIO_QFMT_ASYNCH;
 		q->int_parm=int_parm;
 		q->is_input_q=0;
+		q->is_pci_out = 0;
 		q->schid = irq_ptr->schid;
 		q->cdev = cdev;
 		q->irq_ptr = irq_ptr;
@@ -1842,6 +1850,10 @@ qdio_fill_qs(struct qdio_irq *irq_ptr, struct ccw_device *cdev,
 		q->tasklet.data=(unsigned long)q;
 		q->tasklet.func=(void(*)(unsigned long))
 			&qdio_outbound_processing;
+		q->timer.function=(void(*)(unsigned long))
+			&qdio_outbound_processing;
+		q->timer.data = (long)q;
+		init_timer(&q->timer);
 
 		atomic_set(&q->busy_siga_counter,0);
 		q->timing.busy_start=0;
@@ -2648,6 +2660,7 @@ qdio_shutdown(struct ccw_device *cdev, int how)
 
 	for (i=0;i<irq_ptr->no_output_qs;i++) {
 		tasklet_kill(&irq_ptr->output_qs[i]->tasklet);
+		del_timer(&irq_ptr->output_qs[i]->timer);
 		wait_event_interruptible_timeout(cdev->private->wait_q,
 						 !atomic_read(&irq_ptr->
 							      output_qs[i]->
@@ -3477,6 +3490,10 @@ do_qdio_handle_outbound(struct qdio_q *q, unsigned int callflags,
 		}
 		return;
 	}
+	if (callflags & QDIO_FLAG_PCI_OUT)
+		q->is_pci_out = 1;
+	else
+		q->is_pci_out = 0;
 	if (q->is_iqdio_q) {
 		/* one siga for every sbal */
 		while (count--)
diff --git a/drivers/s390/cio/qdio.h b/drivers/s390/cio/qdio.h
index ec9af72..6d0bcd2 100644
--- a/drivers/s390/cio/qdio.h
+++ b/drivers/s390/cio/qdio.h
@@ -60,6 +60,7 @@
 #define QDIO_ACTIVATE_TIMEOUT ((5*HZ)>>10)
 #define QDIO_CLEANUP_CLEAR_TIMEOUT (20*HZ)
 #define QDIO_CLEANUP_HALT_TIMEOUT (10*HZ)
+#define QDIO_FORCE_CHECK_TIMEOUT (10*HZ)
 
 enum qdio_irq_states {
 	QDIO_IRQ_STATE_INACTIVE,
@@ -489,8 +490,8 @@ struct qdio_q {
 
 	void *irq_ptr;
 
-#ifdef QDIO_USE_TIMERS_FOR_POLLING
 	struct timer_list timer;
+#ifdef QDIO_USE_TIMERS_FOR_POLLING
 	atomic_t timer_already_set;
 	spinlock_t timer_lock;
 #else /* QDIO_USE_TIMERS_FOR_POLLING */
@@ -536,6 +537,7 @@ struct qdio_q {
 	} timing;
 	atomic_t busy_siga_counter;
         unsigned int queue_type;
+	unsigned int is_pci_out;
 
 	/* leave this member at the end. won't be cleared in qdio_fill_qs */
 	struct slib *slib; /* a page is allocated under this pointer,
diff --git a/drivers/s390/net/qeth_main.c b/drivers/s390/net/qeth_main.c
index 54839fa..e0eb113 100644
--- a/drivers/s390/net/qeth_main.c
+++ b/drivers/s390/net/qeth_main.c
@@ -2749,6 +2749,7 @@ qeth_flush_buffers(struct qeth_qdio_out_q *queue, int under_int,
 	struct qeth_qdio_out_buffer *buf;
 	int rc;
 	int i;
+	unsigned int qdio_flags;
 
 	QETH_DBF_TEXT(trace, 6, "flushbuf");
 
@@ -2792,13 +2793,13 @@ qeth_flush_buffers(struct qeth_qdio_out_q *queue, int under_int,
 		queue->card->perf_stats.outbound_do_qdio_start_time =
 			qeth_get_micros();
 	}
+	qdio_flags = QDIO_FLAG_SYNC_OUTPUT;
 	if (under_int)
-		rc = do_QDIO(CARD_DDEV(queue->card),
-			     QDIO_FLAG_SYNC_OUTPUT | QDIO_FLAG_UNDER_INTERRUPT,
-			     queue->queue_no, index, count, NULL);
-	else
-		rc = do_QDIO(CARD_DDEV(queue->card), QDIO_FLAG_SYNC_OUTPUT,
-			     queue->queue_no, index, count, NULL);
+		qdio_flags |= QDIO_FLAG_UNDER_INTERRUPT;
+	if (atomic_read(&queue->set_pci_flags_count))
+		qdio_flags |= QDIO_FLAG_PCI_OUT;
+	rc = do_QDIO(CARD_DDEV(queue->card), qdio_flags,
+		     queue->queue_no, index, count, NULL);
 	if (queue->card->options.performance_stats)
 		queue->card->perf_stats.outbound_do_qdio_time +=
 			qeth_get_micros() -
@@ -8431,6 +8432,7 @@ __qeth_reboot_event_card(struct device *dev, void *data)
 	card = (struct qeth_card *) dev->driver_data;
 	qeth_clear_ip_list(card, 0, 0);
 	qeth_qdio_clear_card(card, 0);
+	qeth_clear_qdio_buffers(card);
 	return 0;
 }
 
diff --git a/include/asm-s390/qdio.h b/include/asm-s390/qdio.h
index 127f72e..74db1dc 100644
--- a/include/asm-s390/qdio.h
+++ b/include/asm-s390/qdio.h
@@ -120,6 +120,7 @@ extern unsigned long qdio_get_status(int irq);
 #define QDIO_FLAG_NO_INPUT_INTERRUPT_CONTEXT 0x08 /* no effect on
 						     adapter interrupts */
 #define QDIO_FLAG_DONT_SIGA 0x10
+#define QDIO_FLAG_PCI_OUT   0x20
 
 extern int do_QDIO(struct ccw_device*, unsigned int flags, 
 		   unsigned int queue_number,
-- 
1.5.1.2


From: frank.blaschka@de.ibm.com
Subject: [patch 04/11] [PATCH] qeth: Fold qeth_trace debug area
Date: Tue, 22 Jun 2010 10:57:05 +0200
Message-ID: <20100622085807.389893000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Carsten Otte <cotte@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:41953 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758954Ab0FVI6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:10 -0400
Content-Disposition: inline; filename=604-qeth-trace-debug.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Carsten Otte <cotte@de.ibm.com>

This patch removes the qeth_trace debug area. All relevant data is logged into
either qeth_setup or into each card's own debug area. Superfluous information
(such as the card number when logging into the card's own debug area) is
removed without replacement.

Signed-off-by: Carsten Otte <cotte@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |  210 ++++++++++++++++-------------------
 drivers/s390/net/qeth_l2_main.c   |   94 +++++++--------
 drivers/s390/net/qeth_l3_main.c   |  226 +++++++++++++++++++-------------------
 4 files changed, 259 insertions(+), 272 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core.h linux-2.6-patched/drivers/s390/net/qeth_core.h
--- linux-2.6/drivers/s390/net/qeth_core.h	2010-06-22 08:54:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core.h	2010-06-22 08:54:59.000000000 +0200
@@ -41,7 +41,6 @@
 enum qeth_dbf_names {
 	QETH_DBF_SETUP,
 	QETH_DBF_QERR,
-	QETH_DBF_TRACE,
 	QETH_DBF_MSG,
 	QETH_DBF_SENSE,
 	QETH_DBF_MISC,
diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:59.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:54:59.000000000 +0200
@@ -34,8 +34,6 @@ struct qeth_dbf_info qeth_dbf[QETH_DBF_I
 				8, 1,   8, 5, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_QERR]  = {"qeth_qerr",
 				2, 1,   8, 2, &debug_hex_ascii_view, NULL},
-	[QETH_DBF_TRACE] = {"qeth_trace",
-				4, 1,   8, 3, &debug_hex_ascii_view, NULL},
 	[QETH_DBF_MSG]   = {"qeth_msg",
 				8, 1, 128, 3, &debug_sprintf_view,   NULL},
 	[QETH_DBF_SENSE] = {"qeth_sense",
@@ -232,7 +230,7 @@ void qeth_clear_working_pool_list(struct
 {
 	struct qeth_buffer_pool_entry *pool_entry, *tmp;
 
-	QETH_DBF_TEXT(TRACE, 5, "clwrklst");
+	QETH_CARD_TEXT(card, 5, "clwrklst");
 	list_for_each_entry_safe(pool_entry, tmp,
 			    &card->qdio.in_buf_pool.entry_list, list){
 			list_del(&pool_entry->list);
@@ -246,7 +244,7 @@ static int qeth_alloc_buffer_pool(struct
 	void *ptr;
 	int i, j;
 
-	QETH_DBF_TEXT(TRACE, 5, "alocpool");
+	QETH_CARD_TEXT(card, 5, "alocpool");
 	for (i = 0; i < card->qdio.init_pool.buf_count; ++i) {
 		pool_entry = kmalloc(sizeof(*pool_entry), GFP_KERNEL);
 		if (!pool_entry) {
@@ -273,7 +271,7 @@ static int qeth_alloc_buffer_pool(struct
 
 int qeth_realloc_buffer_pool(struct qeth_card *card, int bufcnt)
 {
-	QETH_DBF_TEXT(TRACE, 2, "realcbp");
+	QETH_CARD_TEXT(card, 2, "realcbp");
 
 	if ((card->state != CARD_STATE_DOWN) &&
 	    (card->state != CARD_STATE_RECOVER))
@@ -293,7 +291,7 @@ static int qeth_issue_next_read(struct q
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(TRACE, 5, "issnxrd");
+	QETH_CARD_TEXT(card, 5, "issnxrd");
 	if (card->read.state != CH_STATE_UP)
 		return -EIO;
 	iob = qeth_get_buffer(&card->read);
@@ -305,7 +303,7 @@ static int qeth_issue_next_read(struct q
 		return -ENOMEM;
 	}
 	qeth_setup_ccw(&card->read, iob->data, QETH_BUFSIZE);
-	QETH_DBF_TEXT(TRACE, 6, "noirqpnd");
+	QETH_CARD_TEXT(card, 6, "noirqpnd");
 	rc = ccw_device_start(card->read.ccwdev, &card->read.ccw,
 			      (addr_t) iob, 0, 0);
 	if (rc) {
@@ -364,7 +362,7 @@ static struct qeth_ipa_cmd *qeth_check_i
 {
 	struct qeth_ipa_cmd *cmd = NULL;
 
-	QETH_DBF_TEXT(TRACE, 5, "chkipad");
+	QETH_CARD_TEXT(card, 5, "chkipad");
 	if (IS_IPA(iob->data)) {
 		cmd = (struct qeth_ipa_cmd *) PDU_ENCAPSULATION(iob->data);
 		if (IS_IPA_REPLY(cmd)) {
@@ -400,10 +398,10 @@ static struct qeth_ipa_cmd *qeth_check_i
 			case IPA_CMD_MODCCID:
 				return cmd;
 			case IPA_CMD_REGISTER_LOCAL_ADDR:
-				QETH_DBF_TEXT(TRACE, 3, "irla");
+				QETH_CARD_TEXT(card, 3, "irla");
 				break;
 			case IPA_CMD_UNREGISTER_LOCAL_ADDR:
-				QETH_DBF_TEXT(TRACE, 3, "urla");
+				QETH_CARD_TEXT(card, 3, "urla");
 				break;
 			default:
 				QETH_DBF_MESSAGE(2, "Received data is IPA "
@@ -420,7 +418,7 @@ void qeth_clear_ipacmd_list(struct qeth_
 	struct qeth_reply *reply, *r;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(TRACE, 4, "clipalst");
+	QETH_CARD_TEXT(card, 4, "clipalst");
 
 	spin_lock_irqsave(&card->lock, flags);
 	list_for_each_entry_safe(reply, r, &card->cmd_waiter_list, list) {
@@ -448,9 +446,9 @@ static int qeth_check_idx_response(struc
 			   buffer[4],
 			   ((buffer[4] == 0x22) ?
 			    " -- try another portname" : ""));
-		QETH_DBF_TEXT(TRACE, 2, "ckidxres");
-		QETH_DBF_TEXT(TRACE, 2, " idxterm");
-		QETH_DBF_TEXT_(TRACE, 2, "  rc%d", -EIO);
+		QETH_CARD_TEXT(card, 2, "ckidxres");
+		QETH_CARD_TEXT(card, 2, " idxterm");
+		QETH_CARD_TEXT_(card, 2, "  rc%d", -EIO);
 		if (buffer[4] == 0xf6) {
 			dev_err(&card->gdev->dev,
 			"The qeth device is not configured "
@@ -467,8 +465,8 @@ static void qeth_setup_ccw(struct qeth_c
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(TRACE, 4, "setupccw");
 	card = CARD_FROM_CDEV(channel->ccwdev);
+	QETH_CARD_TEXT(card, 4, "setupccw");
 	if (channel == &card->read)
 		memcpy(&channel->ccw, READ_CCW, sizeof(struct ccw1));
 	else
@@ -481,7 +479,7 @@ static struct qeth_cmd_buffer *__qeth_ge
 {
 	__u8 index;
 
-	QETH_DBF_TEXT(TRACE, 6, "getbuff");
+	QETH_CARD_TEXT(CARD_FROM_CDEV(channel->ccwdev), 6, "getbuff");
 	index = channel->io_buf_no;
 	do {
 		if (channel->iob[index].state == BUF_STATE_FREE) {
@@ -502,7 +500,7 @@ void qeth_release_buffer(struct qeth_cha
 {
 	unsigned long flags;
 
-	QETH_DBF_TEXT(TRACE, 6, "relbuff");
+	QETH_CARD_TEXT(CARD_FROM_CDEV(channel->ccwdev), 6, "relbuff");
 	spin_lock_irqsave(&channel->iob_lock, flags);
 	memset(iob->data, 0, QETH_BUFSIZE);
 	iob->state = BUF_STATE_FREE;
@@ -553,9 +551,8 @@ static void qeth_send_control_data_cb(st
 	int keep_reply;
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 4, "sndctlcb");
-
 	card = CARD_FROM_CDEV(channel->ccwdev);
+	QETH_CARD_TEXT(card, 4, "sndctlcb");
 	rc = qeth_check_idx_response(card, iob->data);
 	switch (rc) {
 	case 0:
@@ -722,7 +719,7 @@ EXPORT_SYMBOL_GPL(qeth_do_run_thread);
 
 void qeth_schedule_recovery(struct qeth_card *card)
 {
-	QETH_DBF_TEXT(TRACE, 2, "startrec");
+	QETH_CARD_TEXT(card, 2, "startrec");
 	if (qeth_set_thread_start_bit(card, QETH_RECOVER_THREAD) == 0)
 		schedule_work(&card->kernel_thread_starter);
 }
@@ -732,15 +729,17 @@ static int qeth_get_problem(struct ccw_d
 {
 	int dstat, cstat;
 	char *sense;
+	struct qeth_card *card;
 
 	sense = (char *) irb->ecw;
 	cstat = irb->scsw.cmd.cstat;
 	dstat = irb->scsw.cmd.dstat;
+	card = CARD_FROM_CDEV(cdev);
 
 	if (cstat & (SCHN_STAT_CHN_CTRL_CHK | SCHN_STAT_INTF_CTRL_CHK |
 		     SCHN_STAT_CHN_DATA_CHK | SCHN_STAT_CHAIN_CHECK |
 		     SCHN_STAT_PROT_CHECK | SCHN_STAT_PROG_CHECK)) {
-		QETH_DBF_TEXT(TRACE, 2, "CGENCHK");
+		QETH_CARD_TEXT(card, 2, "CGENCHK");
 		dev_warn(&cdev->dev, "The qeth device driver "
 			"failed to recover an error on the device\n");
 		QETH_DBF_MESSAGE(2, "%s check on device dstat=x%x, cstat=x%x\n",
@@ -753,23 +752,23 @@ static int qeth_get_problem(struct ccw_d
 	if (dstat & DEV_STAT_UNIT_CHECK) {
 		if (sense[SENSE_RESETTING_EVENT_BYTE] &
 		    SENSE_RESETTING_EVENT_FLAG) {
-			QETH_DBF_TEXT(TRACE, 2, "REVIND");
+			QETH_CARD_TEXT(card, 2, "REVIND");
 			return 1;
 		}
 		if (sense[SENSE_COMMAND_REJECT_BYTE] &
 		    SENSE_COMMAND_REJECT_FLAG) {
-			QETH_DBF_TEXT(TRACE, 2, "CMDREJi");
+			QETH_CARD_TEXT(card, 2, "CMDREJi");
 			return 1;
 		}
 		if ((sense[2] == 0xaf) && (sense[3] == 0xfe)) {
-			QETH_DBF_TEXT(TRACE, 2, "AFFE");
+			QETH_CARD_TEXT(card, 2, "AFFE");
 			return 1;
 		}
 		if ((!sense[0]) && (!sense[1]) && (!sense[2]) && (!sense[3])) {
-			QETH_DBF_TEXT(TRACE, 2, "ZEROSEN");
+			QETH_CARD_TEXT(card, 2, "ZEROSEN");
 			return 0;
 		}
-		QETH_DBF_TEXT(TRACE, 2, "DGENCHK");
+		QETH_CARD_TEXT(card, 2, "DGENCHK");
 			return 1;
 	}
 	return 0;
@@ -778,6 +777,10 @@ static int qeth_get_problem(struct ccw_d
 static long __qeth_check_irb_error(struct ccw_device *cdev,
 		unsigned long intparm, struct irb *irb)
 {
+	struct qeth_card *card;
+
+	card = CARD_FROM_CDEV(cdev);
+
 	if (!IS_ERR(irb))
 		return 0;
 
@@ -785,17 +788,15 @@ static long __qeth_check_irb_error(struc
 	case -EIO:
 		QETH_DBF_MESSAGE(2, "%s i/o-error on device\n",
 			dev_name(&cdev->dev));
-		QETH_DBF_TEXT(TRACE, 2, "ckirberr");
-		QETH_DBF_TEXT_(TRACE, 2, "  rc%d", -EIO);
+		QETH_CARD_TEXT(card, 2, "ckirberr");
+		QETH_CARD_TEXT_(card, 2, "  rc%d", -EIO);
 		break;
 	case -ETIMEDOUT:
 		dev_warn(&cdev->dev, "A hardware operation timed out"
 			" on the device\n");
-		QETH_DBF_TEXT(TRACE, 2, "ckirberr");
-		QETH_DBF_TEXT_(TRACE, 2, "  rc%d", -ETIMEDOUT);
+		QETH_CARD_TEXT(card, 2, "ckirberr");
+		QETH_CARD_TEXT_(card, 2, "  rc%d", -ETIMEDOUT);
 		if (intparm == QETH_RCD_PARM) {
-			struct qeth_card *card = CARD_FROM_CDEV(cdev);
-
 			if (card && (card->data.ccwdev == cdev)) {
 				card->data.state = CH_STATE_DOWN;
 				wake_up(&card->wait_q);
@@ -805,8 +806,8 @@ static long __qeth_check_irb_error(struc
 	default:
 		QETH_DBF_MESSAGE(2, "%s unknown error %ld on device\n",
 			dev_name(&cdev->dev), PTR_ERR(irb));
-		QETH_DBF_TEXT(TRACE, 2, "ckirberr");
-		QETH_DBF_TEXT(TRACE, 2, "  rc???");
+		QETH_CARD_TEXT(card, 2, "ckirberr");
+		QETH_CARD_TEXT(card, 2, "  rc???");
 	}
 	return PTR_ERR(irb);
 }
@@ -822,8 +823,6 @@ static void qeth_irq(struct ccw_device *
 	struct qeth_cmd_buffer *iob;
 	__u8 index;
 
-	QETH_DBF_TEXT(TRACE, 5, "irq");
-
 	if (__qeth_check_irb_error(cdev, intparm, irb))
 		return;
 	cstat = irb->scsw.cmd.cstat;
@@ -833,15 +832,17 @@ static void qeth_irq(struct ccw_device *
 	if (!card)
 		return;
 
+	QETH_CARD_TEXT(card, 5, "irq");
+
 	if (card->read.ccwdev == cdev) {
 		channel = &card->read;
-		QETH_DBF_TEXT(TRACE, 5, "read");
+		QETH_CARD_TEXT(card, 5, "read");
 	} else if (card->write.ccwdev == cdev) {
 		channel = &card->write;
-		QETH_DBF_TEXT(TRACE, 5, "write");
+		QETH_CARD_TEXT(card, 5, "write");
 	} else {
 		channel = &card->data;
-		QETH_DBF_TEXT(TRACE, 5, "data");
+		QETH_CARD_TEXT(card, 5, "data");
 	}
 	atomic_set(&channel->irq_pending, 0);
 
@@ -857,12 +858,12 @@ static void qeth_irq(struct ccw_device *
 		goto out;
 
 	if (intparm == QETH_CLEAR_CHANNEL_PARM) {
-		QETH_DBF_TEXT(TRACE, 6, "clrchpar");
+		QETH_CARD_TEXT(card, 6, "clrchpar");
 		/* we don't have to handle this further */
 		intparm = 0;
 	}
 	if (intparm == QETH_HALT_CHANNEL_PARM) {
-		QETH_DBF_TEXT(TRACE, 6, "hltchpar");
+		QETH_CARD_TEXT(card, 6, "hltchpar");
 		/* we don't have to handle this further */
 		intparm = 0;
 	}
@@ -963,7 +964,7 @@ void qeth_clear_qdio_buffers(struct qeth
 {
 	int i, j;
 
-	QETH_DBF_TEXT(TRACE, 2, "clearqdbf");
+	QETH_CARD_TEXT(card, 2, "clearqdbf");
 	/* clear outbound buffers to free skbs */
 	for (i = 0; i < card->qdio.no_out_queues; ++i)
 		if (card->qdio.out_qs[i]) {
@@ -978,7 +979,7 @@ static void qeth_free_buffer_pool(struct
 {
 	struct qeth_buffer_pool_entry *pool_entry, *tmp;
 	int i = 0;
-	QETH_DBF_TEXT(TRACE, 5, "freepool");
+	QETH_CARD_TEXT(card, 5, "freepool");
 	list_for_each_entry_safe(pool_entry, tmp,
 				 &card->qdio.init_pool.entry_list, init_list){
 		for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i)
@@ -992,7 +993,6 @@ static void qeth_free_qdio_buffers(struc
 {
 	int i, j;
 
-	QETH_DBF_TEXT(TRACE, 2, "freeqdbf");
 	if (atomic_xchg(&card->qdio.state, QETH_QDIO_UNINITIALIZED) ==
 		QETH_QDIO_UNINITIALIZED)
 		return;
@@ -1089,7 +1089,7 @@ static int qeth_do_start_thread(struct q
 	int rc = 0;
 
 	spin_lock_irqsave(&card->thread_mask_lock, flags);
-	QETH_DBF_TEXT_(TRACE, 4, "  %02x%02x%02x",
+	QETH_CARD_TEXT_(card, 4, "  %02x%02x%02x",
 			(u8) card->thread_start_mask,
 			(u8) card->thread_allowed_mask,
 			(u8) card->thread_running_mask);
@@ -1102,7 +1102,7 @@ static void qeth_start_kernel_thread(str
 {
 	struct qeth_card *card = container_of(work, struct qeth_card,
 					kernel_thread_starter);
-	QETH_DBF_TEXT(TRACE , 2, "strthrd");
+	QETH_CARD_TEXT(card , 2, "strthrd");
 
 	if (card->read.state != CH_STATE_UP &&
 	    card->write.state != CH_STATE_UP)
@@ -1229,8 +1229,8 @@ static int qeth_clear_channel(struct qet
 	struct qeth_card *card;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "clearch");
 	card = CARD_FROM_CDEV(channel->ccwdev);
+	QETH_CARD_TEXT(card, 3, "clearch");
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	rc = ccw_device_clear(channel->ccwdev, QETH_CLEAR_CHANNEL_PARM);
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
@@ -1253,8 +1253,8 @@ static int qeth_halt_channel(struct qeth
 	struct qeth_card *card;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "haltch");
 	card = CARD_FROM_CDEV(channel->ccwdev);
+	QETH_CARD_TEXT(card, 3, "haltch");
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	rc = ccw_device_halt(channel->ccwdev, QETH_HALT_CHANNEL_PARM);
 	spin_unlock_irqrestore(get_ccwdev_lock(channel->ccwdev), flags);
@@ -1274,7 +1274,7 @@ static int qeth_halt_channels(struct qet
 {
 	int rc1 = 0, rc2 = 0, rc3 = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "haltchs");
+	QETH_CARD_TEXT(card, 3, "haltchs");
 	rc1 = qeth_halt_channel(&card->read);
 	rc2 = qeth_halt_channel(&card->write);
 	rc3 = qeth_halt_channel(&card->data);
@@ -1289,7 +1289,7 @@ static int qeth_clear_channels(struct qe
 {
 	int rc1 = 0, rc2 = 0, rc3 = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "clearchs");
+	QETH_CARD_TEXT(card, 3, "clearchs");
 	rc1 = qeth_clear_channel(&card->read);
 	rc2 = qeth_clear_channel(&card->write);
 	rc3 = qeth_clear_channel(&card->data);
@@ -1304,8 +1304,7 @@ static int qeth_clear_halt_card(struct q
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "clhacrd");
-	QETH_DBF_HEX(TRACE, 3, &card, sizeof(void *));
+	QETH_CARD_TEXT(card, 3, "clhacrd");
 
 	if (halt)
 		rc = qeth_halt_channels(card);
@@ -1318,7 +1317,7 @@ int qeth_qdio_clear_card(struct qeth_car
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "qdioclr");
+	QETH_CARD_TEXT(card, 3, "qdioclr");
 	switch (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_ESTABLISHED,
 		QETH_QDIO_CLEANING)) {
 	case QETH_QDIO_ESTABLISHED:
@@ -1329,7 +1328,7 @@ int qeth_qdio_clear_card(struct qeth_car
 			rc = qdio_shutdown(CARD_DDEV(card),
 				QDIO_FLAG_CLEANUP_USING_CLEAR);
 		if (rc)
-			QETH_DBF_TEXT_(TRACE, 3, "1err%d", rc);
+			QETH_CARD_TEXT_(card, 3, "1err%d", rc);
 		qdio_free(CARD_DDEV(card));
 		atomic_set(&card->qdio.state, QETH_QDIO_ALLOCATED);
 		break;
@@ -1340,7 +1339,7 @@ int qeth_qdio_clear_card(struct qeth_car
 	}
 	rc = qeth_clear_halt_card(card, use_halt);
 	if (rc)
-		QETH_DBF_TEXT_(TRACE, 3, "2err%d", rc);
+		QETH_CARD_TEXT_(card, 3, "2err%d", rc);
 	card->state = CARD_STATE_DOWN;
 	return rc;
 }
@@ -1705,7 +1704,7 @@ int qeth_send_control_data(struct qeth_c
 	unsigned long timeout, event_timeout;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 2, "sendctl");
+	QETH_CARD_TEXT(card, 2, "sendctl");
 
 	reply = qeth_alloc_reply(card);
 	if (!reply) {
@@ -1732,7 +1731,7 @@ int qeth_send_control_data(struct qeth_c
 		event_timeout = QETH_TIMEOUT;
 	timeout = jiffies + event_timeout;
 
-	QETH_DBF_TEXT(TRACE, 6, "noirqpnd");
+	QETH_CARD_TEXT(card, 6, "noirqpnd");
 	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
 	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
 			      (addr_t) iob, 0, 0);
@@ -1741,7 +1740,7 @@ int qeth_send_control_data(struct qeth_c
 		QETH_DBF_MESSAGE(2, "%s qeth_send_control_data: "
 			"ccw_device_start rc = %i\n",
 			dev_name(&card->write.ccwdev->dev), rc);
-		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
+		QETH_CARD_TEXT_(card, 2, " err%d", rc);
 		spin_lock_irqsave(&card->lock, flags);
 		list_del_init(&reply->list);
 		qeth_put_reply(reply);
@@ -2335,7 +2334,7 @@ static void qeth_initialize_working_pool
 {
 	struct qeth_buffer_pool_entry *entry;
 
-	QETH_DBF_TEXT(TRACE, 5, "inwrklst");
+	QETH_CARD_TEXT(card, 5, "inwrklst");
 
 	list_for_each_entry(entry,
 			    &card->qdio.init_pool.entry_list, init_list) {
@@ -2522,7 +2521,7 @@ int qeth_send_ipa_cmd(struct qeth_card *
 	int rc;
 	char prot_type;
 
-	QETH_DBF_TEXT(TRACE, 4, "sendipa");
+	QETH_CARD_TEXT(card, 4, "sendipa");
 
 	if (card->options.layer2)
 		if (card->info.type == QETH_CARD_TYPE_OSN)
@@ -2582,7 +2581,7 @@ int qeth_default_setadapterparms_cb(stru
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "defadpcb");
+	QETH_CARD_TEXT(card, 4, "defadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code == 0)
@@ -2597,7 +2596,7 @@ static int qeth_query_setadapterparms_cb
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 3, "quyadpcb");
+	QETH_CARD_TEXT(card, 3, "quyadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->data.setadapterparms.data.query_cmds_supp.lan_type & 0x7f) {
@@ -2633,7 +2632,7 @@ int qeth_query_setadapterparms(struct qe
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(TRACE, 3, "queryadp");
+	QETH_CARD_TEXT(card, 3, "queryadp");
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_COMMANDS_SUPPORTED,
 				   sizeof(struct qeth_ipacmd_setadpparms));
 	rc = qeth_send_ipa_cmd(card, iob, qeth_query_setadapterparms_cb, NULL);
@@ -2645,7 +2644,7 @@ int qeth_check_qdio_errors(struct qeth_c
 		unsigned int qdio_error, const char *dbftext)
 {
 	if (qdio_error) {
-		QETH_DBF_TEXT(TRACE, 2, dbftext);
+		QETH_CARD_TEXT(card, 2, dbftext);
 		QETH_DBF_TEXT(QERR, 2, dbftext);
 		QETH_DBF_TEXT_(QERR, 2, " F15=%02X",
 			       buf->element[15].flags & 0xff);
@@ -2717,8 +2716,7 @@ void qeth_queue_input_buffer(struct qeth
 		if (rc) {
 			dev_warn(&card->gdev->dev,
 				"QDIO reported an error, rc=%i\n", rc);
-			QETH_DBF_TEXT(TRACE, 2, "qinberr");
-			QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
+			QETH_CARD_TEXT(card, 2, "qinberr");
 		}
 		queue->next_buf_to_init = (queue->next_buf_to_init + count) %
 					  QDIO_MAX_BUFFERS_PER_Q;
@@ -2731,7 +2729,7 @@ static int qeth_handle_send_error(struct
 {
 	int sbalf15 = buffer->buffer->element[15].flags & 0xff;
 
-	QETH_DBF_TEXT(TRACE, 6, "hdsnderr");
+	QETH_CARD_TEXT(card, 6, "hdsnderr");
 	if (card->info.type == QETH_CARD_TYPE_IQD) {
 		if (sbalf15 == 0) {
 			qdio_err = 0;
@@ -2747,9 +2745,8 @@ static int qeth_handle_send_error(struct
 	if ((sbalf15 >= 15) && (sbalf15 <= 31))
 		return QETH_SEND_ERROR_RETRY;
 
-	QETH_DBF_TEXT(TRACE, 1, "lnkfail");
-	QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
-	QETH_DBF_TEXT_(TRACE, 1, "%04x %02x",
+	QETH_CARD_TEXT(card, 1, "lnkfail");
+	QETH_CARD_TEXT_(card, 1, "%04x %02x",
 		       (u16)qdio_err, (u8)sbalf15);
 	return QETH_SEND_ERROR_LINK_FAILURE;
 }
@@ -2764,7 +2761,7 @@ static void qeth_switch_to_packing_if_ne
 		if (atomic_read(&queue->used_buffers)
 		    >= QETH_HIGH_WATERMARK_PACK){
 			/* switch non-PACKING -> PACKING */
-			QETH_DBF_TEXT(TRACE, 6, "np->pack");
+			QETH_CARD_TEXT(queue->card, 6, "np->pack");
 			if (queue->card->options.performance_stats)
 				queue->card->perf_stats.sc_dp_p++;
 			queue->do_pack = 1;
@@ -2787,7 +2784,7 @@ static int qeth_switch_to_nonpacking_if_
 		if (atomic_read(&queue->used_buffers)
 		    <= QETH_LOW_WATERMARK_PACK) {
 			/* switch PACKING -> non-PACKING */
-			QETH_DBF_TEXT(TRACE, 6, "pack->np");
+			QETH_CARD_TEXT(queue->card, 6, "pack->np");
 			if (queue->card->options.performance_stats)
 				queue->card->perf_stats.sc_p_dp++;
 			queue->do_pack = 0;
@@ -2896,9 +2893,8 @@ static void qeth_flush_buffers(struct qe
 		/* ignore temporary SIGA errors without busy condition */
 		if (rc == QDIO_ERROR_SIGA_TARGET)
 			return;
-		QETH_DBF_TEXT(TRACE, 2, "flushbuf");
-		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
-		QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_DDEV_ID(queue->card));
+		QETH_CARD_TEXT(queue->card, 2, "flushbuf");
+		QETH_CARD_TEXT_(queue->card, 2, " err%d", rc);
 
 		/* this must not happen under normal circumstances. if it
 		 * happens something is really wrong -> recover */
@@ -2960,10 +2956,9 @@ void qeth_qdio_output_handler(struct ccw
 	int i;
 	unsigned qeth_send_err;
 
-	QETH_DBF_TEXT(TRACE, 6, "qdouhdl");
+	QETH_CARD_TEXT(card, 6, "qdouhdl");
 	if (qdio_error & QDIO_ERROR_ACTIVATE_CHECK_CONDITION) {
-		QETH_DBF_TEXT(TRACE, 2, "achkcond");
-		QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
+		QETH_CARD_TEXT(card, 2, "achkcond");
 		netif_stop_queue(card->dev);
 		qeth_schedule_recovery(card);
 		return;
@@ -3145,12 +3140,12 @@ static inline int qeth_fill_buffer(struc
 					(int *)&buf->next_element_to_fill);
 
 	if (!queue->do_pack) {
-		QETH_DBF_TEXT(TRACE, 6, "fillbfnp");
+		QETH_CARD_TEXT(queue->card, 6, "fillbfnp");
 		/* set state to PRIMED -> will be flushed */
 		atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
 		flush_cnt = 1;
 	} else {
-		QETH_DBF_TEXT(TRACE, 6, "fillbfpa");
+		QETH_CARD_TEXT(queue->card, 6, "fillbfpa");
 		if (queue->card->options.performance_stats)
 			queue->card->perf_stats.skbs_sent_pack++;
 		if (buf->next_element_to_fill >=
@@ -3312,14 +3307,14 @@ static int qeth_setadp_promisc_mode_cb(s
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_ipacmd_setadpparms *setparms;
 
-	QETH_DBF_TEXT(TRACE, 4, "prmadpcb");
+	QETH_CARD_TEXT(card, 4, "prmadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	setparms = &(cmd->data.setadapterparms);
 
 	qeth_default_setadapterparms_cb(card, reply, (unsigned long)cmd);
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(TRACE, 4, "prmrc%2.2x", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "prmrc%2.2x", cmd->hdr.return_code);
 		setparms->data.mode = SET_PROMISC_MODE_OFF;
 	}
 	card->info.promisc_mode = setparms->data.mode;
@@ -3333,7 +3328,7 @@ void qeth_setadp_promisc_mode(struct qet
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "setprom");
+	QETH_CARD_TEXT(card, 4, "setprom");
 
 	if (((dev->flags & IFF_PROMISC) &&
 	     (card->info.promisc_mode == SET_PROMISC_MODE_ON)) ||
@@ -3343,7 +3338,7 @@ void qeth_setadp_promisc_mode(struct qet
 	mode = SET_PROMISC_MODE_OFF;
 	if (dev->flags & IFF_PROMISC)
 		mode = SET_PROMISC_MODE_ON;
-	QETH_DBF_TEXT_(TRACE, 4, "mode:%x", mode);
+	QETH_CARD_TEXT_(card, 4, "mode:%x", mode);
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_PROMISC_MODE,
 			sizeof(struct qeth_ipacmd_setadpparms));
@@ -3360,9 +3355,9 @@ int qeth_change_mtu(struct net_device *d
 
 	card = dev->ml_priv;
 
-	QETH_DBF_TEXT(TRACE, 4, "chgmtu");
+	QETH_CARD_TEXT(card, 4, "chgmtu");
 	sprintf(dbf_text, "%8x", new_mtu);
-	QETH_DBF_TEXT(TRACE, 4, dbf_text);
+	QETH_CARD_TEXT(card, 4, dbf_text);
 
 	if (new_mtu < 64)
 		return -EINVAL;
@@ -3382,7 +3377,7 @@ struct net_device_stats *qeth_get_stats(
 
 	card = dev->ml_priv;
 
-	QETH_DBF_TEXT(TRACE, 5, "getstat");
+	QETH_CARD_TEXT(card, 5, "getstat");
 
 	return &card->stats;
 }
@@ -3393,7 +3388,7 @@ static int qeth_setadpparms_change_macad
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "chgmaccb");
+	QETH_CARD_TEXT(card, 4, "chgmaccb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (!card->options.layer2 ||
@@ -3413,7 +3408,7 @@ int qeth_setadpparms_change_macaddr(stru
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "chgmac");
+	QETH_CARD_TEXT(card, 4, "chgmac");
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_ALTER_MAC_ADDRESS,
 				   sizeof(struct qeth_ipacmd_setadpparms));
@@ -3435,7 +3430,7 @@ static int qeth_setadpparms_set_access_c
 	struct qeth_set_access_ctrl *access_ctrl_req;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 4, "setaccb");
+	QETH_CARD_TEXT(card, 4, "setaccb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	access_ctrl_req = &cmd->data.setadapterparms.data.set_access_ctrl;
@@ -3533,7 +3528,7 @@ static int qeth_setadpparms_set_access_c
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_set_access_ctrl *access_ctrl_req;
 
-	QETH_DBF_TEXT(TRACE, 4, "setacctl");
+	QETH_CARD_TEXT(card, 4, "setacctl");
 
 	QETH_DBF_TEXT_(SETUP, 2, "setacctl");
 	QETH_DBF_TEXT_(SETUP, 2, "%s", card->gdev->dev.kobj.name);
@@ -3555,7 +3550,7 @@ int qeth_set_access_ctrl_online(struct q
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 4, "setactlo");
+	QETH_CARD_TEXT(card, 4, "setactlo");
 
 	if ((card->info.type == QETH_CARD_TYPE_OSD ||
 	     card->info.type == QETH_CARD_TYPE_OSX) &&
@@ -3583,8 +3578,8 @@ void qeth_tx_timeout(struct net_device *
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(TRACE, 4, "txtimeo");
 	card = dev->ml_priv;
+	QETH_CARD_TEXT(card, 4, "txtimeo");
 	card->stats.tx_errors++;
 	qeth_schedule_recovery(card);
 }
@@ -3663,7 +3658,7 @@ static int qeth_send_ipa_snmp_cmd(struct
 {
 	u16 s1, s2;
 
-	QETH_DBF_TEXT(TRACE, 4, "sendsnmp");
+	QETH_CARD_TEXT(card, 4, "sendsnmp");
 
 	memcpy(iob->data, IPA_PDU_HEADER, IPA_PDU_HEADER_SIZE);
 	memcpy(QETH_IPA_CMD_DEST_ADDR(iob->data),
@@ -3688,7 +3683,7 @@ static int qeth_snmp_command_cb(struct q
 	unsigned char *data;
 	__u16 data_len;
 
-	QETH_DBF_TEXT(TRACE, 3, "snpcmdcb");
+	QETH_CARD_TEXT(card, 3, "snpcmdcb");
 
 	cmd = (struct qeth_ipa_cmd *) sdata;
 	data = (unsigned char *)((char *)cmd - reply->offset);
@@ -3696,13 +3691,13 @@ static int qeth_snmp_command_cb(struct q
 	snmp = &cmd->data.setadapterparms.data.snmp;
 
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(TRACE, 4, "scer1%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "scer1%i", cmd->hdr.return_code);
 		return 0;
 	}
 	if (cmd->data.setadapterparms.hdr.return_code) {
 		cmd->hdr.return_code =
 			cmd->data.setadapterparms.hdr.return_code;
-		QETH_DBF_TEXT_(TRACE, 4, "scer2%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "scer2%i", cmd->hdr.return_code);
 		return 0;
 	}
 	data_len = *((__u16 *)QETH_IPA_PDU_LEN_PDU1(data));
@@ -3713,13 +3708,13 @@ static int qeth_snmp_command_cb(struct q
 
 	/* check if there is enough room in userspace */
 	if ((qinfo->udata_len - qinfo->udata_offset) < data_len) {
-		QETH_DBF_TEXT_(TRACE, 4, "scer3%i", -ENOMEM);
+		QETH_CARD_TEXT_(card, 4, "scer3%i", -ENOMEM);
 		cmd->hdr.return_code = -ENOMEM;
 		return 0;
 	}
-	QETH_DBF_TEXT_(TRACE, 4, "snore%i",
+	QETH_CARD_TEXT_(card, 4, "snore%i",
 		       cmd->data.setadapterparms.hdr.used_total);
-	QETH_DBF_TEXT_(TRACE, 4, "sseqn%i",
+	QETH_CARD_TEXT_(card, 4, "sseqn%i",
 		cmd->data.setadapterparms.hdr.seq_no);
 	/*copy entries to user buffer*/
 	if (cmd->data.setadapterparms.hdr.seq_no == 1) {
@@ -3733,9 +3728,9 @@ static int qeth_snmp_command_cb(struct q
 	}
 	qinfo->udata_offset += data_len;
 	/* check if all replies received ... */
-		QETH_DBF_TEXT_(TRACE, 4, "srtot%i",
+		QETH_CARD_TEXT_(card, 4, "srtot%i",
 			       cmd->data.setadapterparms.hdr.used_total);
-		QETH_DBF_TEXT_(TRACE, 4, "srseq%i",
+		QETH_CARD_TEXT_(card, 4, "srseq%i",
 			       cmd->data.setadapterparms.hdr.seq_no);
 	if (cmd->data.setadapterparms.hdr.seq_no <
 	    cmd->data.setadapterparms.hdr.used_total)
@@ -3752,7 +3747,7 @@ int qeth_snmp_command(struct qeth_card *
 	struct qeth_arp_query_info qinfo = {0, };
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "snmpcmd");
+	QETH_CARD_TEXT(card, 3, "snmpcmd");
 
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
@@ -3766,7 +3761,7 @@ int qeth_snmp_command(struct qeth_card *
 		return -EFAULT;
 	ureq = kmalloc(req_len+sizeof(struct qeth_snmp_ureq_hdr), GFP_KERNEL);
 	if (!ureq) {
-		QETH_DBF_TEXT(TRACE, 2, "snmpnome");
+		QETH_CARD_TEXT(card, 2, "snmpnome");
 		return -ENOMEM;
 	}
 	if (copy_from_user(ureq, udata,
@@ -4120,9 +4115,7 @@ struct sk_buff *qeth_core_get_next_skb(s
 		skb_len -= data_len;
 		if (skb_len) {
 			if (qeth_is_last_sbale(element)) {
-				QETH_DBF_TEXT(TRACE, 4, "unexeob");
-				QETH_DBF_TEXT_(TRACE, 4, "%s",
-					CARD_BUS_ID(card));
+				QETH_CARD_TEXT(card, 4, "unexeob");
 				QETH_DBF_TEXT(QERR, 2, "unexeob");
 				QETH_DBF_TEXT_(QERR, 2, "%s",
 					CARD_BUS_ID(card));
@@ -4147,8 +4140,7 @@ struct sk_buff *qeth_core_get_next_skb(s
 	return skb;
 no_mem:
 	if (net_ratelimit()) {
-		QETH_DBF_TEXT(TRACE, 2, "noskbmem");
-		QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
+		QETH_CARD_TEXT(card, 2, "noskbmem");
 	}
 	card->stats.rx_dropped++;
 	return NULL;
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2010-06-22 08:54:43.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2010-06-22 08:54:59.000000000 +0200
@@ -79,7 +79,7 @@ static int qeth_l2_do_ioctl(struct net_d
 		rc = -EOPNOTSUPP;
 	}
 	if (rc)
-		QETH_DBF_TEXT_(TRACE, 2, "ioce%d", rc);
+		QETH_CARD_TEXT_(card, 2, "ioce%d", rc);
 	return rc;
 }
 
@@ -130,7 +130,7 @@ static int qeth_l2_send_setgroupmac_cb(s
 	struct qeth_ipa_cmd *cmd;
 	__u8 *mac;
 
-	QETH_DBF_TEXT(TRACE, 2, "L2Sgmacb");
+	QETH_CARD_TEXT(card, 2, "L2Sgmacb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	/* MAC already registered, needed in couple/uncouple case */
@@ -147,7 +147,7 @@ static int qeth_l2_send_setgroupmac_cb(s
 
 static int qeth_l2_send_setgroupmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(TRACE, 2, "L2Sgmac");
+	QETH_CARD_TEXT(card, 2, "L2Sgmac");
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETGMAC,
 					  qeth_l2_send_setgroupmac_cb);
 }
@@ -159,7 +159,7 @@ static int qeth_l2_send_delgroupmac_cb(s
 	struct qeth_ipa_cmd *cmd;
 	__u8 *mac;
 
-	QETH_DBF_TEXT(TRACE, 2, "L2Dgmacb");
+	QETH_CARD_TEXT(card, 2, "L2Dgmacb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	if (cmd->hdr.return_code)
@@ -170,7 +170,7 @@ static int qeth_l2_send_delgroupmac_cb(s
 
 static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(TRACE, 2, "L2Dgmac");
+	QETH_CARD_TEXT(card, 2, "L2Dgmac");
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELGMAC,
 					  qeth_l2_send_delgroupmac_cb);
 }
@@ -262,15 +262,14 @@ static int qeth_l2_send_setdelvlan_cb(st
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 2, "L2sdvcb");
+	QETH_CARD_TEXT(card, 2, "L2sdvcb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
 		QETH_DBF_MESSAGE(2, "Error in processing VLAN %i on %s: 0x%x. "
 			  "Continuing\n", cmd->data.setdelvlan.vlan_id,
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
-		QETH_DBF_TEXT_(TRACE, 2, "L2VL%4x", cmd->hdr.command);
-		QETH_DBF_TEXT_(TRACE, 2, "L2%s", CARD_BUS_ID(card));
-		QETH_DBF_TEXT_(TRACE, 2, "err%d", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 2, "L2VL%4x", cmd->hdr.command);
+		QETH_CARD_TEXT_(card, 2, "err%d", cmd->hdr.return_code);
 	}
 	return 0;
 }
@@ -281,7 +280,7 @@ static int qeth_l2_send_setdelvlan(struc
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT_(TRACE, 4, "L2sdv%x", ipacmd);
+	QETH_CARD_TEXT_(card, 4, "L2sdv%x", ipacmd);
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelvlan.vlan_id = i;
@@ -292,7 +291,7 @@ static int qeth_l2_send_setdelvlan(struc
 static void qeth_l2_process_vlans(struct qeth_card *card, int clear)
 {
 	struct qeth_vlan_vid *id;
-	QETH_DBF_TEXT(TRACE, 3, "L2prcvln");
+	QETH_CARD_TEXT(card, 3, "L2prcvln");
 	spin_lock_bh(&card->vlanlock);
 	list_for_each_entry(id, &card->vid_list, list) {
 		if (clear)
@@ -310,13 +309,13 @@ static void qeth_l2_vlan_rx_add_vid(stru
 	struct qeth_card *card = dev->ml_priv;
 	struct qeth_vlan_vid *id;
 
-	QETH_DBF_TEXT_(TRACE, 4, "aid:%d", vid);
+	QETH_CARD_TEXT_(card, 4, "aid:%d", vid);
 	if (card->info.type == QETH_CARD_TYPE_OSM) {
-		QETH_DBF_TEXT(TRACE, 3, "aidOSM");
+		QETH_CARD_TEXT(card, 3, "aidOSM");
 		return;
 	}
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
-		QETH_DBF_TEXT(TRACE, 3, "aidREC");
+		QETH_CARD_TEXT(card, 3, "aidREC");
 		return;
 	}
 	id = kmalloc(sizeof(struct qeth_vlan_vid), GFP_ATOMIC);
@@ -334,13 +333,13 @@ static void qeth_l2_vlan_rx_kill_vid(str
 	struct qeth_vlan_vid *id, *tmpid = NULL;
 	struct qeth_card *card = dev->ml_priv;
 
-	QETH_DBF_TEXT_(TRACE, 4, "kid:%d", vid);
+	QETH_CARD_TEXT_(card, 4, "kid:%d", vid);
 	if (card->info.type == QETH_CARD_TYPE_OSM) {
-		QETH_DBF_TEXT(TRACE, 3, "kidOSM");
+		QETH_CARD_TEXT(card, 3, "kidOSM");
 		return;
 	}
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
-		QETH_DBF_TEXT(TRACE, 3, "kidREC");
+		QETH_CARD_TEXT(card, 3, "kidREC");
 		return;
 	}
 	spin_lock_bh(&card->vlanlock);
@@ -456,7 +455,7 @@ static void qeth_l2_process_inbound_buff
 			/* else unknown */
 		default:
 			dev_kfree_skb_any(skb);
-			QETH_DBF_TEXT(TRACE, 3, "inbunkno");
+			QETH_CARD_TEXT(card, 3, "inbunkno");
 			QETH_DBF_HEX(CTRL, 3, hdr, QETH_DBF_CTRL_LEN);
 			continue;
 		}
@@ -474,7 +473,7 @@ static int qeth_l2_send_setdelmac(struct
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(TRACE, 2, "L2sdmac");
+	QETH_CARD_TEXT(card, 2, "L2sdmac");
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
@@ -488,10 +487,10 @@ static int qeth_l2_send_setmac_cb(struct
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 2, "L2Smaccb");
+	QETH_CARD_TEXT(card, 2, "L2Smaccb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(TRACE, 2, "L2er%x", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 2, "L2er%x", cmd->hdr.return_code);
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
 		switch (cmd->hdr.return_code) {
 		case IPA_RC_L2_DUP_MAC:
@@ -523,7 +522,7 @@ static int qeth_l2_send_setmac_cb(struct
 
 static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(TRACE, 2, "L2Setmac");
+	QETH_CARD_TEXT(card, 2, "L2Setmac");
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC,
 					  qeth_l2_send_setmac_cb);
 }
@@ -534,10 +533,10 @@ static int qeth_l2_send_delmac_cb(struct
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 2, "L2Dmaccb");
+	QETH_CARD_TEXT(card, 2, "L2Dmaccb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(TRACE, 2, "err%d", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 2, "err%d", cmd->hdr.return_code);
 		cmd->hdr.return_code = -EIO;
 		return 0;
 	}
@@ -548,7 +547,7 @@ static int qeth_l2_send_delmac_cb(struct
 
 static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(TRACE, 2, "L2Delmac");
+	QETH_CARD_TEXT(card, 2, "L2Delmac");
 	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
 		return 0;
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC,
@@ -594,23 +593,22 @@ static int qeth_l2_set_mac_address(struc
 	struct qeth_card *card = dev->ml_priv;
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "setmac");
+	QETH_CARD_TEXT(card, 3, "setmac");
 
 	if (qeth_l2_verify_dev(dev) != QETH_REAL_CARD) {
-		QETH_DBF_TEXT(TRACE, 3, "setmcINV");
+		QETH_CARD_TEXT(card, 3, "setmcINV");
 		return -EOPNOTSUPP;
 	}
 
 	if (card->info.type == QETH_CARD_TYPE_OSN ||
 	    card->info.type == QETH_CARD_TYPE_OSM ||
 	    card->info.type == QETH_CARD_TYPE_OSX) {
-		QETH_DBF_TEXT(TRACE, 3, "setmcTYP");
+		QETH_CARD_TEXT(card, 3, "setmcTYP");
 		return -EOPNOTSUPP;
 	}
-	QETH_DBF_TEXT_(TRACE, 3, "%s", CARD_BUS_ID(card));
-	QETH_DBF_HEX(TRACE, 3, addr->sa_data, OSA_ADDR_LEN);
+	QETH_CARD_HEX(card, 3, addr->sa_data, OSA_ADDR_LEN);
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
-		QETH_DBF_TEXT(TRACE, 3, "setmcREC");
+		QETH_CARD_TEXT(card, 3, "setmcREC");
 		return -ERESTARTSYS;
 	}
 	rc = qeth_l2_send_delmac(card, &card->dev->dev_addr[0]);
@@ -627,7 +625,7 @@ static void qeth_l2_set_multicast_list(s
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		return ;
 
-	QETH_DBF_TEXT(TRACE, 3, "setmulti");
+	QETH_CARD_TEXT(card, 3, "setmulti");
 	if (qeth_threads_running(card, QETH_RECOVER_THREAD) &&
 	    (card->state != CARD_STATE_UP))
 		return;
@@ -771,11 +769,10 @@ static void qeth_l2_qdio_input_handler(s
 		card->perf_stats.inbound_start_time = qeth_get_micros();
 	}
 	if (qdio_err & QDIO_ERROR_ACTIVATE_CHECK_CONDITION) {
-		QETH_DBF_TEXT(TRACE, 1, "qdinchk");
-		QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
-		QETH_DBF_TEXT_(TRACE, 1, "%04X%04X", first_element,
+		QETH_CARD_TEXT(card, 1, "qdinchk");
+		QETH_CARD_TEXT_(card, 1, "%04X%04X", first_element,
 				count);
-		QETH_DBF_TEXT_(TRACE, 1, "%04X", queue);
+		QETH_CARD_TEXT_(card, 1, "%04X", queue);
 		qeth_schedule_recovery(card);
 		return;
 	}
@@ -799,13 +796,13 @@ static int qeth_l2_open(struct net_devic
 {
 	struct qeth_card *card = dev->ml_priv;
 
-	QETH_DBF_TEXT(TRACE, 4, "qethopen");
+	QETH_CARD_TEXT(card, 4, "qethopen");
 	if (card->state != CARD_STATE_SOFTSETUP)
 		return -ENODEV;
 
 	if ((card->info.type != QETH_CARD_TYPE_OSN) &&
 	     (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))) {
-		QETH_DBF_TEXT(TRACE, 4, "nomacadr");
+		QETH_CARD_TEXT(card, 4, "nomacadr");
 		return -EPERM;
 	}
 	card->data.state = CH_STATE_UP;
@@ -822,7 +819,7 @@ static int qeth_l2_stop(struct net_devic
 {
 	struct qeth_card *card = dev->ml_priv;
 
-	QETH_DBF_TEXT(TRACE, 4, "qethstop");
+	QETH_CARD_TEXT(card, 4, "qethstop");
 	netif_tx_disable(dev);
 	if (card->state == CARD_STATE_UP)
 		card->state = CARD_STATE_SOFTSETUP;
@@ -1074,11 +1071,10 @@ static int qeth_l2_recover(void *ptr)
 	int rc = 0;
 
 	card = (struct qeth_card *) ptr;
-	QETH_DBF_TEXT(TRACE, 2, "recover1");
-	QETH_DBF_HEX(TRACE, 2, &card, sizeof(void *));
+	QETH_CARD_TEXT(card, 2, "recover1");
 	if (!qeth_do_run_thread(card, QETH_RECOVER_THREAD))
 		return 0;
-	QETH_DBF_TEXT(TRACE, 2, "recover2");
+	QETH_CARD_TEXT(card, 2, "recover2");
 	dev_warn(&card->gdev->dev,
 		"A recovery process has been started for the device\n");
 	card->use_hard_stop = 1;
@@ -1181,12 +1177,12 @@ static int qeth_osn_send_control_data(st
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 5, "osndctrd");
+	QETH_CARD_TEXT(card, 5, "osndctrd");
 
 	wait_event(card->wait_q,
 		   atomic_cmpxchg(&card->write.irq_pending, 0, 1) == 0);
 	qeth_prepare_control_data(card, len, iob);
-	QETH_DBF_TEXT(TRACE, 6, "osnoirqp");
+	QETH_CARD_TEXT(card, 6, "osnoirqp");
 	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
 	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
 			      (addr_t) iob, 0, 0);
@@ -1194,7 +1190,7 @@ static int qeth_osn_send_control_data(st
 	if (rc) {
 		QETH_DBF_MESSAGE(2, "qeth_osn_send_control_data: "
 			   "ccw_device_start rc = %i\n", rc);
-		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
+		QETH_CARD_TEXT_(card, 2, " err%d", rc);
 		qeth_release_buffer(iob->channel, iob);
 		atomic_set(&card->write.irq_pending, 0);
 		wake_up(&card->wait_q);
@@ -1207,7 +1203,7 @@ static int qeth_osn_send_ipa_cmd(struct 
 {
 	u16 s1, s2;
 
-	QETH_DBF_TEXT(TRACE, 4, "osndipa");
+	QETH_CARD_TEXT(card, 4, "osndipa");
 
 	qeth_prepare_ipa_cmd(card, iob, QETH_PROT_OSN2);
 	s1 = (u16)(IPA_PDU_HEADER_SIZE + data_len);
@@ -1225,12 +1221,12 @@ int qeth_osn_assist(struct net_device *d
 	struct qeth_card *card;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 2, "osnsdmc");
 	if (!dev)
 		return -ENODEV;
 	card = dev->ml_priv;
 	if (!card)
 		return -ENODEV;
+	QETH_CARD_TEXT(card, 2, "osnsdmc");
 	if ((card->state != CARD_STATE_UP) &&
 	    (card->state != CARD_STATE_SOFTSETUP))
 		return -ENODEV;
@@ -1247,13 +1243,13 @@ int qeth_osn_register(unsigned char *rea
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(TRACE, 2, "osnreg");
 	*dev = qeth_l2_netdev_by_devno(read_dev_no);
 	if (*dev == NULL)
 		return -ENODEV;
 	card = (*dev)->ml_priv;
 	if (!card)
 		return -ENODEV;
+	QETH_CARD_TEXT(card, 2, "osnreg");
 	if ((assist_cb == NULL) || (data_cb == NULL))
 		return -EINVAL;
 	card->osn_info.assist_cb = assist_cb;
@@ -1266,12 +1262,12 @@ void qeth_osn_deregister(struct net_devi
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(TRACE, 2, "osndereg");
 	if (!dev)
 		return;
 	card = dev->ml_priv;
 	if (!card)
 		return;
+	QETH_CARD_TEXT(card, 2, "osndereg");
 	card->osn_info.assist_cb = NULL;
 	card->osn_info.data_cb = NULL;
 	return;
diff -urpN linux-2.6/drivers/s390/net/qeth_l3_main.c linux-2.6-patched/drivers/s390/net/qeth_l3_main.c
--- linux-2.6/drivers/s390/net/qeth_l3_main.c	2010-06-22 08:54:43.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l3_main.c	2010-06-22 08:54:59.000000000 +0200
@@ -287,7 +287,7 @@ static int __qeth_l3_insert_ip_todo(stru
 				addr->users += add ? 1 : -1;
 			if (add && (addr->type == QETH_IP_TYPE_NORMAL) &&
 			    qeth_l3_is_addr_covered_by_ipato(card, addr)) {
-				QETH_DBF_TEXT(TRACE, 2, "tkovaddr");
+				QETH_CARD_TEXT(card, 2, "tkovaddr");
 				addr->set_flags |= QETH_IPA_SETIP_TAKEOVER_FLAG;
 			}
 			list_add_tail(&addr->entry, card->ip_tbd_list);
@@ -301,13 +301,13 @@ static int qeth_l3_delete_ip(struct qeth
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 4, "delip");
+	QETH_CARD_TEXT(card, 4, "delip");
 
 	if (addr->proto == QETH_PROT_IPV4)
-		QETH_DBF_HEX(TRACE, 4, &addr->u.a4.addr, 4);
+		QETH_CARD_HEX(card, 4, &addr->u.a4.addr, 4);
 	else {
-		QETH_DBF_HEX(TRACE, 4, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(TRACE, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_CARD_HEX(card, 4, &addr->u.a6.addr, 8);
+		QETH_CARD_HEX(card, 4, ((char *)&addr->u.a6.addr) + 8, 8);
 	}
 	spin_lock_irqsave(&card->ip_lock, flags);
 	rc = __qeth_l3_insert_ip_todo(card, addr, 0);
@@ -320,12 +320,12 @@ static int qeth_l3_add_ip(struct qeth_ca
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 4, "addip");
+	QETH_CARD_TEXT(card, 4, "addip");
 	if (addr->proto == QETH_PROT_IPV4)
-		QETH_DBF_HEX(TRACE, 4, &addr->u.a4.addr, 4);
+		QETH_CARD_HEX(card, 4, &addr->u.a4.addr, 4);
 	else {
-		QETH_DBF_HEX(TRACE, 4, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(TRACE, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_CARD_HEX(card, 4, &addr->u.a6.addr, 8);
+		QETH_CARD_HEX(card, 4, ((char *)&addr->u.a6.addr) + 8, 8);
 	}
 	spin_lock_irqsave(&card->ip_lock, flags);
 	rc = __qeth_l3_insert_ip_todo(card, addr, 1);
@@ -353,10 +353,10 @@ static void qeth_l3_delete_mc_addresses(
 	struct qeth_ipaddr *iptodo;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(TRACE, 4, "delmc");
+	QETH_CARD_TEXT(card, 4, "delmc");
 	iptodo = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
 	if (!iptodo) {
-		QETH_DBF_TEXT(TRACE, 2, "dmcnomem");
+		QETH_CARD_TEXT(card, 2, "dmcnomem");
 		return;
 	}
 	iptodo->type = QETH_IP_TYPE_DEL_ALL_MC;
@@ -457,8 +457,8 @@ static void qeth_l3_set_ip_addr_list(str
 	unsigned long flags;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 2, "sdiplist");
-	QETH_DBF_HEX(TRACE, 2, &card, sizeof(void *));
+	QETH_CARD_TEXT(card, 2, "sdiplist");
+	QETH_CARD_HEX(card, 2, &card, sizeof(void *));
 
 	if (card->options.sniffer)
 		return;
@@ -466,7 +466,7 @@ static void qeth_l3_set_ip_addr_list(str
 	tbd_list = card->ip_tbd_list;
 	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_ATOMIC);
 	if (!card->ip_tbd_list) {
-		QETH_DBF_TEXT(TRACE, 0, "silnomem");
+		QETH_CARD_TEXT(card, 0, "silnomem");
 		card->ip_tbd_list = tbd_list;
 		spin_unlock_irqrestore(&card->ip_lock, flags);
 		return;
@@ -517,7 +517,7 @@ static void qeth_l3_clear_ip_list(struct
 	struct qeth_ipaddr *addr, *tmp;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(TRACE, 4, "clearip");
+	QETH_CARD_TEXT(card, 4, "clearip");
 	if (recover && card->options.sniffer)
 		return;
 	spin_lock_irqsave(&card->ip_lock, flags);
@@ -577,7 +577,7 @@ static int qeth_l3_send_setdelmc(struct 
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "setdelmc");
+	QETH_CARD_TEXT(card, 4, "setdelmc");
 
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -615,8 +615,8 @@ static int qeth_l3_send_setdelip(struct 
 	struct qeth_ipa_cmd *cmd;
 	__u8 netmask[16];
 
-	QETH_DBF_TEXT(TRACE, 4, "setdelip");
-	QETH_DBF_TEXT_(TRACE, 4, "flags%02X", flags);
+	QETH_CARD_TEXT(card, 4, "setdelip");
+	QETH_CARD_TEXT_(card, 4, "flags%02X", flags);
 
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -645,7 +645,7 @@ static int qeth_l3_send_setrouting(struc
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(TRACE, 4, "setroutg");
+	QETH_CARD_TEXT(card, 4, "setroutg");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETRTG, prot);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setrtg.type = (type);
@@ -689,7 +689,7 @@ int qeth_l3_setrouting_v4(struct qeth_ca
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "setrtg4");
+	QETH_CARD_TEXT(card, 3, "setrtg4");
 
 	qeth_l3_correct_routing_type(card, &card->options.route4.type,
 				  QETH_PROT_IPV4);
@@ -709,7 +709,7 @@ int qeth_l3_setrouting_v6(struct qeth_ca
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "setrtg6");
+	QETH_CARD_TEXT(card, 3, "setrtg6");
 #ifdef CONFIG_QETH_IPV6
 
 	if (!qeth_is_supported(card, IPA_IPV6))
@@ -753,7 +753,7 @@ int qeth_l3_add_ipato_entry(struct qeth_
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 2, "addipato");
+	QETH_CARD_TEXT(card, 2, "addipato");
 	spin_lock_irqsave(&card->ip_lock, flags);
 	list_for_each_entry(ipatoe, &card->ipato.entries, entry) {
 		if (ipatoe->proto != new->proto)
@@ -778,7 +778,7 @@ void qeth_l3_del_ipato_entry(struct qeth
 	struct qeth_ipato_entry *ipatoe, *tmp;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(TRACE, 2, "delipato");
+	QETH_CARD_TEXT(card, 2, "delipato");
 	spin_lock_irqsave(&card->ip_lock, flags);
 	list_for_each_entry_safe(ipatoe, tmp, &card->ipato.entries, entry) {
 		if (ipatoe->proto != proto)
@@ -806,11 +806,11 @@ int qeth_l3_add_vipa(struct qeth_card *c
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(TRACE, 2, "addvipa4");
+			QETH_CARD_TEXT(card, 2, "addvipa4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(TRACE, 2, "addvipa6");
+			QETH_CARD_TEXT(card, 2, "addvipa6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -841,11 +841,11 @@ void qeth_l3_del_vipa(struct qeth_card *
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(TRACE, 2, "delvipa4");
+			QETH_CARD_TEXT(card, 2, "delvipa4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(TRACE, 2, "delvipa6");
+			QETH_CARD_TEXT(card, 2, "delvipa6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -870,11 +870,11 @@ int qeth_l3_add_rxip(struct qeth_card *c
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(TRACE, 2, "addrxip4");
+			QETH_CARD_TEXT(card, 2, "addrxip4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(TRACE, 2, "addrxip6");
+			QETH_CARD_TEXT(card, 2, "addrxip6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -905,11 +905,11 @@ void qeth_l3_del_rxip(struct qeth_card *
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(TRACE, 2, "addrxip4");
+			QETH_CARD_TEXT(card, 2, "addrxip4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(TRACE, 2, "addrxip6");
+			QETH_CARD_TEXT(card, 2, "addrxip6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -929,15 +929,15 @@ static int qeth_l3_register_addr_entry(s
 	int cnt = 3;
 
 	if (addr->proto == QETH_PROT_IPV4) {
-		QETH_DBF_TEXT(TRACE, 2, "setaddr4");
-		QETH_DBF_HEX(TRACE, 3, &addr->u.a4.addr, sizeof(int));
+		QETH_CARD_TEXT(card, 2, "setaddr4");
+		QETH_CARD_HEX(card, 3, &addr->u.a4.addr, sizeof(int));
 	} else if (addr->proto == QETH_PROT_IPV6) {
-		QETH_DBF_TEXT(TRACE, 2, "setaddr6");
-		QETH_DBF_HEX(TRACE, 3, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(TRACE, 3, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_CARD_TEXT(card, 2, "setaddr6");
+		QETH_CARD_HEX(card, 3, &addr->u.a6.addr, 8);
+		QETH_CARD_HEX(card, 3, ((char *)&addr->u.a6.addr) + 8, 8);
 	} else {
-		QETH_DBF_TEXT(TRACE, 2, "setaddr?");
-		QETH_DBF_HEX(TRACE, 3, addr, sizeof(struct qeth_ipaddr));
+		QETH_CARD_TEXT(card, 2, "setaddr?");
+		QETH_CARD_HEX(card, 3, addr, sizeof(struct qeth_ipaddr));
 	}
 	do {
 		if (addr->is_multicast)
@@ -946,10 +946,10 @@ static int qeth_l3_register_addr_entry(s
 			rc = qeth_l3_send_setdelip(card, addr, IPA_CMD_SETIP,
 					addr->set_flags);
 		if (rc)
-			QETH_DBF_TEXT(TRACE, 2, "failed");
+			QETH_CARD_TEXT(card, 2, "failed");
 	} while ((--cnt > 0) && rc);
 	if (rc) {
-		QETH_DBF_TEXT(TRACE, 2, "FAILED");
+		QETH_CARD_TEXT(card, 2, "FAILED");
 		qeth_l3_ipaddr_to_string(addr->proto, (u8 *)&addr->u, buf);
 		dev_warn(&card->gdev->dev,
 			"Registering IP address %s failed\n", buf);
@@ -963,15 +963,15 @@ static int qeth_l3_deregister_addr_entry
 	int rc = 0;
 
 	if (addr->proto == QETH_PROT_IPV4) {
-		QETH_DBF_TEXT(TRACE, 2, "deladdr4");
-		QETH_DBF_HEX(TRACE, 3, &addr->u.a4.addr, sizeof(int));
+		QETH_CARD_TEXT(card, 2, "deladdr4");
+		QETH_CARD_HEX(card, 3, &addr->u.a4.addr, sizeof(int));
 	} else if (addr->proto == QETH_PROT_IPV6) {
-		QETH_DBF_TEXT(TRACE, 2, "deladdr6");
-		QETH_DBF_HEX(TRACE, 3, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(TRACE, 3, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_CARD_TEXT(card, 2, "deladdr6");
+		QETH_CARD_HEX(card, 3, &addr->u.a6.addr, 8);
+		QETH_CARD_HEX(card, 3, ((char *)&addr->u.a6.addr) + 8, 8);
 	} else {
-		QETH_DBF_TEXT(TRACE, 2, "deladdr?");
-		QETH_DBF_HEX(TRACE, 3, addr, sizeof(struct qeth_ipaddr));
+		QETH_CARD_TEXT(card, 2, "deladdr?");
+		QETH_CARD_HEX(card, 3, addr, sizeof(struct qeth_ipaddr));
 	}
 	if (addr->is_multicast)
 		rc = qeth_l3_send_setdelmc(card, addr, IPA_CMD_DELIPM);
@@ -979,7 +979,7 @@ static int qeth_l3_deregister_addr_entry
 		rc = qeth_l3_send_setdelip(card, addr, IPA_CMD_DELIP,
 					addr->del_flags);
 	if (rc)
-		QETH_DBF_TEXT(TRACE, 2, "failed");
+		QETH_CARD_TEXT(card, 2, "failed");
 
 	return rc;
 }
@@ -1012,7 +1012,7 @@ static int qeth_l3_send_setadp_mode(stru
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "adpmode");
+	QETH_CARD_TEXT(card, 4, "adpmode");
 
 	iob = qeth_get_adapter_cmd(card, command,
 				   sizeof(struct qeth_ipacmd_setadpparms));
@@ -1027,7 +1027,7 @@ static int qeth_l3_setadapter_hstr(struc
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 4, "adphstr");
+	QETH_CARD_TEXT(card, 4, "adphstr");
 
 	if (qeth_adp_supported(card, IPA_SETADP_SET_BROADCAST_MODE)) {
 		rc = qeth_l3_send_setadp_mode(card,
@@ -1093,7 +1093,7 @@ static int qeth_l3_default_setassparms_c
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "defadpcb");
+	QETH_CARD_TEXT(card, 4, "defadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code == 0) {
@@ -1106,13 +1106,13 @@ static int qeth_l3_default_setassparms_c
 	if (cmd->data.setassparms.hdr.assist_no == IPA_INBOUND_CHECKSUM &&
 	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
 		card->info.csum_mask = cmd->data.setassparms.data.flags_32bit;
-		QETH_DBF_TEXT_(TRACE, 3, "csum:%d", card->info.csum_mask);
+		QETH_CARD_TEXT_(card, 3, "csum:%d", card->info.csum_mask);
 	}
 	if (cmd->data.setassparms.hdr.assist_no == IPA_OUTBOUND_CHECKSUM &&
 	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
 		card->info.tx_csum_mask =
 			cmd->data.setassparms.data.flags_32bit;
-		QETH_DBF_TEXT_(TRACE, 3, "tcsu:%d", card->info.tx_csum_mask);
+		QETH_CARD_TEXT_(card, 3, "tcsu:%d", card->info.tx_csum_mask);
 	}
 
 	return 0;
@@ -1125,7 +1125,7 @@ static struct qeth_cmd_buffer *qeth_l3_g
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "getasscm");
+	QETH_CARD_TEXT(card, 4, "getasscm");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETASSPARMS, prot);
 
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -1147,7 +1147,7 @@ static int qeth_l3_send_setassparms(stru
 	int rc;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 4, "sendassp");
+	QETH_CARD_TEXT(card, 4, "sendassp");
 
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	if (len <= sizeof(__u32))
@@ -1166,7 +1166,7 @@ static int qeth_l3_send_simple_setasspar
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(TRACE, 4, "simassp6");
+	QETH_CARD_TEXT(card, 4, "simassp6");
 	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
 				       0, QETH_PROT_IPV6);
 	rc = qeth_l3_send_setassparms(card, iob, 0, 0,
@@ -1182,7 +1182,7 @@ static int qeth_l3_send_simple_setasspar
 	int length = 0;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(TRACE, 4, "simassp4");
+	QETH_CARD_TEXT(card, 4, "simassp4");
 	if (data)
 		length = sizeof(__u32);
 	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
@@ -1196,7 +1196,7 @@ static int qeth_l3_start_ipa_arp_process
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "ipaarp");
+	QETH_CARD_TEXT(card, 3, "ipaarp");
 
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
 		dev_info(&card->gdev->dev,
@@ -1218,7 +1218,7 @@ static int qeth_l3_start_ipa_ip_fragment
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "ipaipfrg");
+	QETH_CARD_TEXT(card, 3, "ipaipfrg");
 
 	if (!qeth_is_supported(card, IPA_IP_FRAGMENTATION)) {
 		dev_info(&card->gdev->dev,
@@ -1243,7 +1243,7 @@ static int qeth_l3_start_ipa_source_mac(
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "stsrcmac");
+	QETH_CARD_TEXT(card, 3, "stsrcmac");
 
 	if (!qeth_is_supported(card, IPA_SOURCE_MAC)) {
 		dev_info(&card->gdev->dev,
@@ -1265,7 +1265,7 @@ static int qeth_l3_start_ipa_vlan(struct
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "strtvlan");
+	QETH_CARD_TEXT(card, 3, "strtvlan");
 
 	if (!qeth_is_supported(card, IPA_FULL_VLAN)) {
 		dev_info(&card->gdev->dev,
@@ -1289,7 +1289,7 @@ static int qeth_l3_start_ipa_multicast(s
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "stmcast");
+	QETH_CARD_TEXT(card, 3, "stmcast");
 
 	if (!qeth_is_supported(card, IPA_MULTICASTING)) {
 		dev_info(&card->gdev->dev,
@@ -1349,7 +1349,7 @@ static int qeth_l3_softsetup_ipv6(struct
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "softipv6");
+	QETH_CARD_TEXT(card, 3, "softipv6");
 
 	if (card->info.type == QETH_CARD_TYPE_IQD)
 		goto out;
@@ -1395,7 +1395,7 @@ static int qeth_l3_start_ipa_ipv6(struct
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "strtipv6");
+	QETH_CARD_TEXT(card, 3, "strtipv6");
 
 	if (!qeth_is_supported(card, IPA_IPV6)) {
 		dev_info(&card->gdev->dev,
@@ -1412,7 +1412,7 @@ static int qeth_l3_start_ipa_broadcast(s
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "stbrdcst");
+	QETH_CARD_TEXT(card, 3, "stbrdcst");
 	card->info.broadcast_capable = 0;
 	if (!qeth_is_supported(card, IPA_FILTERING)) {
 		dev_info(&card->gdev->dev,
@@ -1512,7 +1512,7 @@ static int qeth_l3_start_ipa_checksum(st
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(TRACE, 3, "strtcsum");
+	QETH_CARD_TEXT(card, 3, "strtcsum");
 
 	if (card->options.checksum_type == NO_CHECKSUMMING) {
 		dev_info(&card->gdev->dev,
@@ -1569,7 +1569,7 @@ static int qeth_l3_start_ipa_tso(struct 
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "sttso");
+	QETH_CARD_TEXT(card, 3, "sttso");
 
 	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
 		dev_info(&card->gdev->dev,
@@ -1596,7 +1596,7 @@ static int qeth_l3_start_ipa_tso(struct 
 
 static int qeth_l3_start_ipassists(struct qeth_card *card)
 {
-	QETH_DBF_TEXT(TRACE, 3, "strtipas");
+	QETH_CARD_TEXT(card, 3, "strtipas");
 
 	qeth_set_access_ctrl_online(card);	/* go on*/
 	qeth_l3_start_ipa_arp_processing(card);	/* go on*/
@@ -1619,7 +1619,7 @@ static int qeth_l3_put_unique_id(struct 
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(TRACE, 2, "puniqeid");
+	QETH_CARD_TEXT(card, 2, "puniqeid");
 
 	if ((card->info.unique_id & UNIQUE_ID_NOT_BY_CARD) ==
 		UNIQUE_ID_NOT_BY_CARD)
@@ -1723,7 +1723,7 @@ qeth_diags_trace_cb(struct qeth_card *ca
 	cmd = (struct qeth_ipa_cmd *)data;
 	rc = cmd->hdr.return_code;
 	if (rc)
-		QETH_DBF_TEXT_(TRACE, 2, "dxter%x", rc);
+		QETH_CARD_TEXT_(card, 2, "dxter%x", rc);
 	switch (cmd->data.diagass.action) {
 	case QETH_DIAGS_CMD_TRACE_QUERY:
 		break;
@@ -1800,7 +1800,7 @@ static void qeth_l3_add_mc(struct qeth_c
 	struct ip_mc_list *im4;
 	char buf[MAX_ADDR_LEN];
 
-	QETH_DBF_TEXT(TRACE, 4, "addmc");
+	QETH_CARD_TEXT(card, 4, "addmc");
 	for (im4 = in4_dev->mc_list; im4; im4 = im4->next) {
 		qeth_l3_get_mac_for_ipm(im4->multiaddr, buf, in4_dev->dev);
 		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
@@ -1820,7 +1820,7 @@ static void qeth_l3_add_vlan_mc(struct q
 	struct vlan_group *vg;
 	int i;
 
-	QETH_DBF_TEXT(TRACE, 4, "addmcvl");
+	QETH_CARD_TEXT(card, 4, "addmcvl");
 	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
 		return;
 
@@ -1844,7 +1844,7 @@ static void qeth_l3_add_multicast_ipv4(s
 {
 	struct in_device *in4_dev;
 
-	QETH_DBF_TEXT(TRACE, 4, "chkmcv4");
+	QETH_CARD_TEXT(card, 4, "chkmcv4");
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		return;
@@ -1862,7 +1862,7 @@ static void qeth_l3_add_mc6(struct qeth_
 	struct ifmcaddr6 *im6;
 	char buf[MAX_ADDR_LEN];
 
-	QETH_DBF_TEXT(TRACE, 4, "addmc6");
+	QETH_CARD_TEXT(card, 4, "addmc6");
 	for (im6 = in6_dev->mc_list; im6 != NULL; im6 = im6->next) {
 		ndisc_mc_map(&im6->mca_addr, buf, in6_dev->dev, 0);
 		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
@@ -1883,7 +1883,7 @@ static void qeth_l3_add_vlan_mc6(struct 
 	struct vlan_group *vg;
 	int i;
 
-	QETH_DBF_TEXT(TRACE, 4, "admc6vl");
+	QETH_CARD_TEXT(card, 4, "admc6vl");
 	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
 		return;
 
@@ -1907,7 +1907,7 @@ static void qeth_l3_add_multicast_ipv6(s
 {
 	struct inet6_dev *in6_dev;
 
-	QETH_DBF_TEXT(TRACE, 4, "chkmcv6");
+	QETH_CARD_TEXT(card, 4, "chkmcv6");
 	if (!qeth_is_supported(card, IPA_IPV6))
 		return ;
 	in6_dev = in6_dev_get(card->dev);
@@ -1928,7 +1928,7 @@ static void qeth_l3_free_vlan_addresses4
 	struct in_ifaddr *ifa;
 	struct qeth_ipaddr *addr;
 
-	QETH_DBF_TEXT(TRACE, 4, "frvaddr4");
+	QETH_CARD_TEXT(card, 4, "frvaddr4");
 
 	in_dev = in_dev_get(vlan_group_get_device(card->vlangrp, vid));
 	if (!in_dev)
@@ -1954,7 +1954,7 @@ static void qeth_l3_free_vlan_addresses6
 	struct inet6_ifaddr *ifa;
 	struct qeth_ipaddr *addr;
 
-	QETH_DBF_TEXT(TRACE, 4, "frvaddr6");
+	QETH_CARD_TEXT(card, 4, "frvaddr6");
 
 	in6_dev = in6_dev_get(vlan_group_get_device(card->vlangrp, vid));
 	if (!in6_dev)
@@ -1989,7 +1989,7 @@ static void qeth_l3_vlan_rx_register(str
 	struct qeth_card *card = dev->ml_priv;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(TRACE, 4, "vlanreg");
+	QETH_CARD_TEXT(card, 4, "vlanreg");
 	spin_lock_irqsave(&card->vlanlock, flags);
 	card->vlangrp = grp;
 	spin_unlock_irqrestore(&card->vlanlock, flags);
@@ -2005,9 +2005,9 @@ static void qeth_l3_vlan_rx_kill_vid(str
 	struct qeth_card *card = dev->ml_priv;
 	unsigned long flags;
 
-	QETH_DBF_TEXT_(TRACE, 4, "kid:%d", vid);
+	QETH_CARD_TEXT_(card, 4, "kid:%d", vid);
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
-		QETH_DBF_TEXT(TRACE, 3, "kidREC");
+		QETH_CARD_TEXT(card, 3, "kidREC");
 		return;
 	}
 	spin_lock_irqsave(&card->vlanlock, flags);
@@ -2162,7 +2162,7 @@ static void qeth_l3_process_inbound_buff
 			break;
 		default:
 			dev_kfree_skb_any(skb);
-			QETH_DBF_TEXT(TRACE, 3, "inbunkno");
+			QETH_CARD_TEXT(card, 3, "inbunkno");
 			QETH_DBF_HEX(CTRL, 3, hdr, QETH_DBF_CTRL_LEN);
 			continue;
 		}
@@ -2229,7 +2229,8 @@ static struct qeth_card *qeth_l3_get_car
 		card = vlan_dev_real_dev(dev)->ml_priv;
 	if (card && card->options.layer2)
 		card = NULL;
-	QETH_DBF_TEXT_(TRACE, 4, "%d", rc);
+	if (card)
+		QETH_CARD_TEXT_(card, 4, "%d", rc);
 	return card ;
 }
 
@@ -2307,10 +2308,10 @@ qeth_l3_handle_promisc_mode(struct qeth_
 	} else if (card->options.sniffer &&	/* HiperSockets trace */
 		   qeth_adp_supported(card, IPA_SETADP_SET_DIAG_ASSIST)) {
 		if (dev->flags & IFF_PROMISC) {
-			QETH_DBF_TEXT(TRACE, 3, "+promisc");
+			QETH_CARD_TEXT(card, 3, "+promisc");
 			qeth_diags_trace(card, QETH_DIAGS_CMD_TRACE_ENABLE);
 		} else {
-			QETH_DBF_TEXT(TRACE, 3, "-promisc");
+			QETH_CARD_TEXT(card, 3, "-promisc");
 			qeth_diags_trace(card, QETH_DIAGS_CMD_TRACE_DISABLE);
 		}
 	}
@@ -2320,7 +2321,7 @@ static void qeth_l3_set_multicast_list(s
 {
 	struct qeth_card *card = dev->ml_priv;
 
-	QETH_DBF_TEXT(TRACE, 3, "setmulti");
+	QETH_CARD_TEXT(card, 3, "setmulti");
 	if (qeth_threads_running(card, QETH_RECOVER_THREAD) &&
 	    (card->state != CARD_STATE_UP))
 		return;
@@ -2365,7 +2366,7 @@ static int qeth_l3_arp_set_no_entries(st
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "arpstnoe");
+	QETH_CARD_TEXT(card, 3, "arpstnoe");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2417,17 +2418,17 @@ static int qeth_l3_arp_query_cb(struct q
 	int uentry_size;
 	int i;
 
-	QETH_DBF_TEXT(TRACE, 4, "arpquecb");
+	QETH_CARD_TEXT(card, 4, "arpquecb");
 
 	qinfo = (struct qeth_arp_query_info *) reply->param;
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(TRACE, 4, "qaer1%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "qaer1%i", cmd->hdr.return_code);
 		return 0;
 	}
 	if (cmd->data.setassparms.hdr.return_code) {
 		cmd->hdr.return_code = cmd->data.setassparms.hdr.return_code;
-		QETH_DBF_TEXT_(TRACE, 4, "qaer2%i", cmd->hdr.return_code);
+		QETH_CARD_TEXT_(card, 4, "qaer2%i", cmd->hdr.return_code);
 		return 0;
 	}
 	qdata = &cmd->data.setassparms.data.query_arp;
@@ -2449,14 +2450,14 @@ static int qeth_l3_arp_query_cb(struct q
 	/* check if there is enough room in userspace */
 	if ((qinfo->udata_len - qinfo->udata_offset) <
 			qdata->no_entries * uentry_size){
-		QETH_DBF_TEXT_(TRACE, 4, "qaer3%i", -ENOMEM);
+		QETH_CARD_TEXT_(card, 4, "qaer3%i", -ENOMEM);
 		cmd->hdr.return_code = -ENOMEM;
 		goto out_error;
 	}
-	QETH_DBF_TEXT_(TRACE, 4, "anore%i",
+	QETH_CARD_TEXT_(card, 4, "anore%i",
 		       cmd->data.setassparms.hdr.number_of_replies);
-	QETH_DBF_TEXT_(TRACE, 4, "aseqn%i", cmd->data.setassparms.hdr.seq_no);
-	QETH_DBF_TEXT_(TRACE, 4, "anoen%i", qdata->no_entries);
+	QETH_CARD_TEXT_(card, 4, "aseqn%i", cmd->data.setassparms.hdr.seq_no);
+	QETH_CARD_TEXT_(card, 4, "anoen%i", qdata->no_entries);
 
 	if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES) {
 		/* strip off "media specific information" */
@@ -2492,7 +2493,7 @@ static int qeth_l3_send_ipa_arp_cmd(stru
 			unsigned long),
 		void *reply_param)
 {
-	QETH_DBF_TEXT(TRACE, 4, "sendarp");
+	QETH_CARD_TEXT(card, 4, "sendarp");
 
 	memcpy(iob->data, IPA_PDU_HEADER, IPA_PDU_HEADER_SIZE);
 	memcpy(QETH_IPA_CMD_DEST_ADDR(iob->data),
@@ -2508,7 +2509,7 @@ static int qeth_l3_arp_query(struct qeth
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "arpquery");
+	QETH_CARD_TEXT(card, 3, "arpquery");
 
 	if (!qeth_is_supported(card,/*IPA_QUERY_ARP_ADDR_INFO*/
 			       IPA_ARP_PROCESSING)) {
@@ -2551,7 +2552,7 @@ static int qeth_l3_arp_add_entry(struct 
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "arpadent");
+	QETH_CARD_TEXT(card, 3, "arpadent");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2590,7 +2591,7 @@ static int qeth_l3_arp_remove_entry(stru
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 3, "arprment");
+	QETH_CARD_TEXT(card, 3, "arprment");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2626,7 +2627,7 @@ static int qeth_l3_arp_flush_cache(struc
 	int rc;
 	int tmp;
 
-	QETH_DBF_TEXT(TRACE, 3, "arpflush");
+	QETH_CARD_TEXT(card, 3, "arpflush");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2734,7 +2735,7 @@ static int qeth_l3_do_ioctl(struct net_d
 		rc = -EOPNOTSUPP;
 	}
 	if (rc)
-		QETH_DBF_TEXT_(TRACE, 2, "ioce%d", rc);
+		QETH_CARD_TEXT_(card, 2, "ioce%d", rc);
 	return rc;
 }
 
@@ -3103,7 +3104,7 @@ static int qeth_l3_open(struct net_devic
 {
 	struct qeth_card *card = dev->ml_priv;
 
-	QETH_DBF_TEXT(TRACE, 4, "qethopen");
+	QETH_CARD_TEXT(card, 4, "qethopen");
 	if (card->state != CARD_STATE_SOFTSETUP)
 		return -ENODEV;
 	card->data.state = CH_STATE_UP;
@@ -3119,7 +3120,7 @@ static int qeth_l3_stop(struct net_devic
 {
 	struct qeth_card *card = dev->ml_priv;
 
-	QETH_DBF_TEXT(TRACE, 4, "qethstop");
+	QETH_CARD_TEXT(card, 4, "qethstop");
 	netif_tx_disable(dev);
 	if (card->state == CARD_STATE_UP)
 		card->state = CARD_STATE_SOFTSETUP;
@@ -3312,11 +3313,10 @@ static void qeth_l3_qdio_input_handler(s
 		card->perf_stats.inbound_start_time = qeth_get_micros();
 	}
 	if (qdio_err & QDIO_ERROR_ACTIVATE_CHECK_CONDITION) {
-		QETH_DBF_TEXT(TRACE, 1, "qdinchk");
-		QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
-		QETH_DBF_TEXT_(TRACE, 1, "%04X%04X",
+		QETH_CARD_TEXT(card, 1, "qdinchk");
+		QETH_CARD_TEXT_(card, 1, "%04X%04X",
 				first_element, count);
-		QETH_DBF_TEXT_(TRACE, 1, "%04X", queue);
+		QETH_CARD_TEXT_(card, 1, "%04X", queue);
 		qeth_schedule_recovery(card);
 		return;
 	}
@@ -3522,11 +3522,11 @@ static int qeth_l3_recover(void *ptr)
 	int rc = 0;
 
 	card = (struct qeth_card *) ptr;
-	QETH_DBF_TEXT(TRACE, 2, "recover1");
-	QETH_DBF_HEX(TRACE, 2, &card, sizeof(void *));
+	QETH_CARD_TEXT(card, 2, "recover1");
+	QETH_CARD_HEX(card, 2, &card, sizeof(void *));
 	if (!qeth_do_run_thread(card, QETH_RECOVER_THREAD))
 		return 0;
-	QETH_DBF_TEXT(TRACE, 2, "recover2");
+	QETH_CARD_TEXT(card, 2, "recover2");
 	dev_warn(&card->gdev->dev,
 		"A recovery process has been started for the device\n");
 	card->use_hard_stop = 1;
@@ -3624,8 +3624,8 @@ static int qeth_l3_ip_event(struct notif
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
-	QETH_DBF_TEXT(TRACE, 3, "ipevent");
 	card = qeth_l3_get_card_from_dev(dev);
+	QETH_CARD_TEXT(card, 3, "ipevent");
 	if (!card)
 		return NOTIFY_DONE;
 
@@ -3671,11 +3671,11 @@ static int qeth_l3_ip6_event(struct noti
 	struct qeth_ipaddr *addr;
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(TRACE, 3, "ip6event");
 
 	card = qeth_l3_get_card_from_dev(dev);
 	if (!card)
 		return NOTIFY_DONE;
+	QETH_CARD_TEXT(card, 3, "ip6event");
 	if (!qeth_is_supported(card, IPA_IPV6))
 		return NOTIFY_DONE;
 
@@ -3714,7 +3714,7 @@ static int qeth_l3_register_notifiers(vo
 {
 	int rc;
 
-	QETH_DBF_TEXT(TRACE, 5, "regnotif");
+	QETH_DBF_TEXT(SETUP, 5, "regnotif");
 	rc = register_inetaddr_notifier(&qeth_l3_ip_notifier);
 	if (rc)
 		return rc;
@@ -3733,7 +3733,7 @@ static int qeth_l3_register_notifiers(vo
 static void qeth_l3_unregister_notifiers(void)
 {
 
-	QETH_DBF_TEXT(TRACE, 5, "unregnot");
+	QETH_DBF_TEXT(SETUP, 5, "unregnot");
 	BUG_ON(unregister_inetaddr_notifier(&qeth_l3_ip_notifier));
 #ifdef CONFIG_QETH_IPV6
 	BUG_ON(unregister_inet6addr_notifier(&qeth_l3_ip6_notifier));


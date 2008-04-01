From: frank.blaschka@de.ibm.com
Subject: [patch 6/8] qeth: improving debug message handling
Date: Tue, 01 Apr 2008 10:26:58 +0200
Message-ID: <20080401082744.285435000@de.ibm.com>
References: <20080401082652.754871000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Peter Tiedemann <ptiedem@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:21000 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755436AbYDAI1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 04:27:48 -0400
Content-Disposition: inline; filename=06-qeth_debug_msg.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Tiedemann <ptiedem@de.ibm.com>

Improving debug message handling, moving ipa into messages from kernel
to dbf, some cleanups and typo fixes.

Signed-off-by: Peter Tiedemann <ptiedem@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |   93 ++----
 drivers/s390/net/qeth_core_main.c |  577 +++++++++++++++++---------------------
 drivers/s390/net/qeth_core_mpc.c  |    2 
 drivers/s390/net/qeth_core_offl.c |   60 +--
 drivers/s390/net/qeth_l2_main.c   |  143 ++++-----
 drivers/s390/net/qeth_l3.h        |   11 
 drivers/s390/net/qeth_l3_main.c   |  282 +++++++++---------
 7 files changed, 543 insertions(+), 625 deletions(-)

Index: git_davem-2.6.26/drivers/s390/net/qeth_core.h
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core.h	2008-03-31 11:25:28.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_core.h	2008-03-31 13:21:22.000000000 +0200
@@ -34,59 +34,53 @@
 
 #include "qeth_core_mpc.h"
 
+#define KMSG_COMPONENT "qeth"
+
 /**
  * Debug Facility stuff
  */
-#define QETH_DBF_SETUP_NAME "qeth_setup"
-#define QETH_DBF_SETUP_LEN 8
-#define QETH_DBF_SETUP_PAGES 8
-#define QETH_DBF_SETUP_NR_AREAS 1
-#define QETH_DBF_SETUP_LEVEL 5
-
-#define QETH_DBF_MISC_NAME "qeth_misc"
-#define QETH_DBF_MISC_LEN 128
-#define QETH_DBF_MISC_PAGES 2
-#define QETH_DBF_MISC_NR_AREAS 1
-#define QETH_DBF_MISC_LEVEL 2
-
-#define QETH_DBF_DATA_NAME "qeth_data"
-#define QETH_DBF_DATA_LEN 96
-#define QETH_DBF_DATA_PAGES 8
-#define QETH_DBF_DATA_NR_AREAS 1
-#define QETH_DBF_DATA_LEVEL 2
-
-#define QETH_DBF_CONTROL_NAME "qeth_control"
-#define QETH_DBF_CONTROL_LEN 256
-#define QETH_DBF_CONTROL_PAGES 8
-#define QETH_DBF_CONTROL_NR_AREAS 1
-#define QETH_DBF_CONTROL_LEVEL 5
-
-#define QETH_DBF_TRACE_NAME "qeth_trace"
-#define QETH_DBF_TRACE_LEN 8
-#define QETH_DBF_TRACE_PAGES 4
-#define QETH_DBF_TRACE_NR_AREAS 1
-#define QETH_DBF_TRACE_LEVEL 3
-
-#define QETH_DBF_SENSE_NAME "qeth_sense"
-#define QETH_DBF_SENSE_LEN 64
-#define QETH_DBF_SENSE_PAGES 2
-#define QETH_DBF_SENSE_NR_AREAS 1
-#define QETH_DBF_SENSE_LEVEL 2
-
-#define QETH_DBF_QERR_NAME "qeth_qerr"
-#define QETH_DBF_QERR_LEN 8
-#define QETH_DBF_QERR_PAGES 2
-#define QETH_DBF_QERR_NR_AREAS 1
-#define QETH_DBF_QERR_LEVEL 2
+enum qeth_dbf_names {
+	QETH_DBF_SETUP,
+	QETH_DBF_QERR,
+	QETH_DBF_TRACE,
+	QETH_DBF_MSG,
+	QETH_DBF_SENSE,
+	QETH_DBF_MISC,
+	QETH_DBF_CTRL,
+	QETH_DBF_INFOS	/* must be last element */
+};
+
+struct qeth_dbf_info {
+	char name[DEBUG_MAX_NAME_LEN];
+	int pages;
+	int areas;
+	int len;
+	int level;
+	struct debug_view *view;
+	debug_info_t *id;
+};
+
+#define QETH_DBF_CTRL_LEN 256
 
 #define QETH_DBF_TEXT(name, level, text) \
-	do { \
-		debug_text_event(qeth_dbf_##name, level, text); \
-	} while (0)
+	debug_text_event(qeth_dbf[QETH_DBF_##name].id, level, text)
 
 #define QETH_DBF_HEX(name, level, addr, len) \
+	debug_event(qeth_dbf[QETH_DBF_##name].id, level, (void *)(addr), len)
+
+#define QETH_DBF_MESSAGE(level, text...) \
+	debug_sprintf_event(qeth_dbf[QETH_DBF_MSG].id, level, text)
+
+#define QETH_DBF_TEXT_(name, level, text...) \
 	do { \
-		debug_event(qeth_dbf_##name, level, (void *)(addr), len); \
+		if (qeth_dbf_passes(qeth_dbf[QETH_DBF_##name].id, level)) { \
+			char *dbf_txt_buf = \
+				get_cpu_var(QETH_DBF_TXT_BUF); \
+			sprintf(dbf_txt_buf, text); \
+			debug_text_event(qeth_dbf[QETH_DBF_##name].id, \
+					level, dbf_txt_buf); \
+			put_cpu_var(QETH_DBF_TXT_BUF); \
+		} \
 	} while (0)
 
 /* Allow to sort out low debug levels early to avoid wasted sprints */
@@ -826,13 +820,8 @@
 
 /* exports for qeth discipline device drivers */
 extern struct qeth_card_list_struct qeth_core_card_list;
-extern debug_info_t *qeth_dbf_setup;
-extern debug_info_t *qeth_dbf_data;
-extern debug_info_t *qeth_dbf_misc;
-extern debug_info_t *qeth_dbf_control;
-extern debug_info_t *qeth_dbf_trace;
-extern debug_info_t *qeth_dbf_sense;
-extern debug_info_t *qeth_dbf_qerr;
+
+extern struct qeth_dbf_info qeth_dbf[QETH_DBF_INFOS];
 
 void qeth_set_allowed_threads(struct qeth_card *, unsigned long , int);
 int qeth_threads_running(struct qeth_card *, unsigned long);
Index: git_davem-2.6.26/drivers/s390/net/qeth_core_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_main.c	2008-03-31 11:25:35.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_main.c	2008-03-31 13:21:07.000000000 +0200
@@ -26,38 +26,35 @@
 #include "qeth_core.h"
 #include "qeth_core_offl.h"
 
-#define QETH_DBF_TEXT_(name, level, text...) \
-	do { \
-		if (qeth_dbf_passes(qeth_dbf_##name, level)) { \
-			char *dbf_txt_buf = \
-				get_cpu_var(qeth_core_dbf_txt_buf); \
-			sprintf(dbf_txt_buf, text); \
-			debug_text_event(qeth_dbf_##name, level, dbf_txt_buf); \
-			put_cpu_var(qeth_core_dbf_txt_buf); \
-		} \
-	} while (0)
+static DEFINE_PER_CPU(char[256], qeth_core_dbf_txt_buf);
+#define QETH_DBF_TXT_BUF qeth_core_dbf_txt_buf
+
+struct qeth_dbf_info qeth_dbf[QETH_DBF_INFOS] = {
+	/* define dbf - Name, Pages, Areas, Maxlen, Level, View, Handle */
+	/*                   N  P  A    M  L  V                      H  */
+	[QETH_DBF_SETUP] = {"qeth_setup",
+				8, 1,   8, 5, &debug_hex_ascii_view, NULL},
+	[QETH_DBF_QERR]  = {"qeth_qerr",
+				2, 1,   8, 2, &debug_hex_ascii_view, NULL},
+	[QETH_DBF_TRACE] = {"qeth_trace",
+				4, 1,   8, 3, &debug_hex_ascii_view, NULL},
+	[QETH_DBF_MSG]   = {"qeth_msg",
+				8, 1, 128, 3, &debug_sprintf_view,   NULL},
+	[QETH_DBF_SENSE] = {"qeth_sense",
+				2, 1,  64, 2, &debug_hex_ascii_view, NULL},
+	[QETH_DBF_MISC]	 = {"qeth_misc",
+				2, 1, 256, 2, &debug_hex_ascii_view, NULL},
+	[QETH_DBF_CTRL]  = {"qeth_control",
+		8, 1, QETH_DBF_CTRL_LEN, 5, &debug_hex_ascii_view, NULL},
+};
+EXPORT_SYMBOL_GPL(qeth_dbf);
 
 struct qeth_card_list_struct qeth_core_card_list;
 EXPORT_SYMBOL_GPL(qeth_core_card_list);
-debug_info_t *qeth_dbf_setup;
-EXPORT_SYMBOL_GPL(qeth_dbf_setup);
-debug_info_t *qeth_dbf_data;
-EXPORT_SYMBOL_GPL(qeth_dbf_data);
-debug_info_t *qeth_dbf_misc;
-EXPORT_SYMBOL_GPL(qeth_dbf_misc);
-debug_info_t *qeth_dbf_control;
-EXPORT_SYMBOL_GPL(qeth_dbf_control);
-debug_info_t *qeth_dbf_trace;
-EXPORT_SYMBOL_GPL(qeth_dbf_trace);
-debug_info_t *qeth_dbf_sense;
-EXPORT_SYMBOL_GPL(qeth_dbf_sense);
-debug_info_t *qeth_dbf_qerr;
-EXPORT_SYMBOL_GPL(qeth_dbf_qerr);
 
 static struct device *qeth_core_root_dev;
 static unsigned int known_devices[][10] = QETH_MODELLIST_ARRAY;
 static struct lock_class_key qdio_out_skb_queue_key;
-static DEFINE_PER_CPU(char[256], qeth_core_dbf_txt_buf);
 
 static void qeth_send_control_data_cb(struct qeth_channel *,
 			struct qeth_cmd_buffer *);
@@ -219,7 +216,7 @@
 {
 	struct qeth_buffer_pool_entry *pool_entry, *tmp;
 
-	QETH_DBF_TEXT(trace, 5, "clwrklst");
+	QETH_DBF_TEXT(TRACE, 5, "clwrklst");
 	list_for_each_entry_safe(pool_entry, tmp,
 			    &card->qdio.in_buf_pool.entry_list, list){
 			list_del(&pool_entry->list);
@@ -233,7 +230,7 @@
 	void *ptr;
 	int i, j;
 
-	QETH_DBF_TEXT(trace, 5, "alocpool");
+	QETH_DBF_TEXT(TRACE, 5, "alocpool");
 	for (i = 0; i < card->qdio.init_pool.buf_count; ++i) {
 		pool_entry = kmalloc(sizeof(*pool_entry), GFP_KERNEL);
 		if (!pool_entry) {
@@ -260,7 +257,7 @@
 
 int qeth_realloc_buffer_pool(struct qeth_card *card, int bufcnt)
 {
-	QETH_DBF_TEXT(trace, 2, "realcbp");
+	QETH_DBF_TEXT(TRACE, 2, "realcbp");
 
 	if ((card->state != CARD_STATE_DOWN) &&
 	    (card->state != CARD_STATE_RECOVER))
@@ -321,7 +318,7 @@
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(trace, 5, "issnxrd");
+	QETH_DBF_TEXT(TRACE, 5, "issnxrd");
 	if (card->read.state != CH_STATE_UP)
 		return -EIO;
 	iob = qeth_get_buffer(&card->read);
@@ -330,7 +327,7 @@
 		return -ENOMEM;
 	}
 	qeth_setup_ccw(&card->read, iob->data, QETH_BUFSIZE);
-	QETH_DBF_TEXT(trace, 6, "noirqpnd");
+	QETH_DBF_TEXT(TRACE, 6, "noirqpnd");
 	rc = ccw_device_start(card->read.ccwdev, &card->read.ccw,
 			      (addr_t) iob, 0, 0);
 	if (rc) {
@@ -368,19 +365,19 @@
 		kfree(reply);
 }
 
-static void qeth_issue_ipa_msg(struct qeth_ipa_cmd *cmd,
+static void qeth_issue_ipa_msg(struct qeth_ipa_cmd *cmd, int rc,
 		struct qeth_card *card)
 {
-	int rc;
-	int com;
 	char *ipa_name;
-
-	com = cmd->hdr.command;
-	rc  = cmd->hdr.return_code;
+	int com = cmd->hdr.command;
 	ipa_name = qeth_get_ipa_cmd_name(com);
-
-	PRINT_ERR("%s(x%X) for %s returned x%X \"%s\"\n", ipa_name, com,
-		   QETH_CARD_IFNAME(card), rc, qeth_get_ipa_msg(rc));
+	if (rc)
+		QETH_DBF_MESSAGE(2, "IPA: %s(x%X) for %s returned x%X \"%s\"\n",
+				ipa_name, com, QETH_CARD_IFNAME(card),
+					rc, qeth_get_ipa_msg(rc));
+	else
+		QETH_DBF_MESSAGE(5, "IPA: %s(x%X) for %s succeeded\n",
+				ipa_name, com, QETH_CARD_IFNAME(card));
 }
 
 static struct qeth_ipa_cmd *qeth_check_ipa_data(struct qeth_card *card,
@@ -388,14 +385,14 @@
 {
 	struct qeth_ipa_cmd *cmd = NULL;
 
-	QETH_DBF_TEXT(trace, 5, "chkipad");
+	QETH_DBF_TEXT(TRACE, 5, "chkipad");
 	if (IS_IPA(iob->data)) {
 		cmd = (struct qeth_ipa_cmd *) PDU_ENCAPSULATION(iob->data);
 		if (IS_IPA_REPLY(cmd)) {
-			if (cmd->hdr.return_code &&
-			    (cmd->hdr.command < IPA_CMD_SETCCID ||
-			     cmd->hdr.command > IPA_CMD_MODCCID))
-				qeth_issue_ipa_msg(cmd, card);
+			if (cmd->hdr.command < IPA_CMD_SETCCID ||
+			    cmd->hdr.command > IPA_CMD_MODCCID)
+				qeth_issue_ipa_msg(cmd,
+						cmd->hdr.return_code, card);
 			return cmd;
 		} else {
 			switch (cmd->hdr.command) {
@@ -423,10 +420,10 @@
 			case IPA_CMD_MODCCID:
 				return cmd;
 			case IPA_CMD_REGISTER_LOCAL_ADDR:
-				QETH_DBF_TEXT(trace, 3, "irla");
+				QETH_DBF_TEXT(TRACE, 3, "irla");
 				break;
 			case IPA_CMD_UNREGISTER_LOCAL_ADDR:
-				QETH_DBF_TEXT(trace, 3, "urla");
+				QETH_DBF_TEXT(TRACE, 3, "urla");
 				break;
 			default:
 				PRINT_WARN("Received data is IPA "
@@ -443,7 +440,7 @@
 	struct qeth_reply *reply, *r;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(trace, 4, "clipalst");
+	QETH_DBF_TEXT(TRACE, 4, "clipalst");
 
 	spin_lock_irqsave(&card->lock, flags);
 	list_for_each_entry_safe(reply, r, &card->cmd_waiter_list, list) {
@@ -463,16 +460,16 @@
 	if (!buffer)
 		return 0;
 
-	QETH_DBF_HEX(control, 2, buffer, QETH_DBF_CONTROL_LEN);
+	QETH_DBF_HEX(CTRL, 2, buffer, QETH_DBF_CTRL_LEN);
 	if ((buffer[2] & 0xc0) == 0xc0) {
 		PRINT_WARN("received an IDX TERMINATE "
 			   "with cause code 0x%02x%s\n",
 			   buffer[4],
 			   ((buffer[4] == 0x22) ?
 			    " -- try another portname" : ""));
-		QETH_DBF_TEXT(trace, 2, "ckidxres");
-		QETH_DBF_TEXT(trace, 2, " idxterm");
-		QETH_DBF_TEXT_(trace, 2, "  rc%d", -EIO);
+		QETH_DBF_TEXT(TRACE, 2, "ckidxres");
+		QETH_DBF_TEXT(TRACE, 2, " idxterm");
+		QETH_DBF_TEXT_(TRACE, 2, "  rc%d", -EIO);
 		return -EIO;
 	}
 	return 0;
@@ -483,7 +480,7 @@
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(trace, 4, "setupccw");
+	QETH_DBF_TEXT(TRACE, 4, "setupccw");
 	card = CARD_FROM_CDEV(channel->ccwdev);
 	if (channel == &card->read)
 		memcpy(&channel->ccw, READ_CCW, sizeof(struct ccw1));
@@ -497,7 +494,7 @@
 {
 	__u8 index;
 
-	QETH_DBF_TEXT(trace, 6, "getbuff");
+	QETH_DBF_TEXT(TRACE, 6, "getbuff");
 	index = channel->io_buf_no;
 	do {
 		if (channel->iob[index].state == BUF_STATE_FREE) {
@@ -518,7 +515,7 @@
 {
 	unsigned long flags;
 
-	QETH_DBF_TEXT(trace, 6, "relbuff");
+	QETH_DBF_TEXT(TRACE, 6, "relbuff");
 	spin_lock_irqsave(&channel->iob_lock, flags);
 	memset(iob->data, 0, QETH_BUFSIZE);
 	iob->state = BUF_STATE_FREE;
@@ -568,7 +565,7 @@
 	unsigned long flags;
 	int keep_reply;
 
-	QETH_DBF_TEXT(trace, 4, "sndctlcb");
+	QETH_DBF_TEXT(TRACE, 4, "sndctlcb");
 
 	card = CARD_FROM_CDEV(channel->ccwdev);
 	if (qeth_check_idx_response(iob->data)) {
@@ -638,7 +635,7 @@
 {
 	int cnt;
 
-	QETH_DBF_TEXT(setup, 2, "setupch");
+	QETH_DBF_TEXT(SETUP, 2, "setupch");
 	for (cnt = 0; cnt < QETH_CMD_BUFFER_NO; cnt++) {
 		channel->iob[cnt].data = (char *)
 			kmalloc(QETH_BUFSIZE, GFP_DMA|GFP_KERNEL);
@@ -732,7 +729,7 @@
 
 void qeth_schedule_recovery(struct qeth_card *card)
 {
-	QETH_DBF_TEXT(trace, 2, "startrec");
+	QETH_DBF_TEXT(TRACE, 2, "startrec");
 	if (qeth_set_thread_start_bit(card, QETH_RECOVER_THREAD) == 0)
 		schedule_work(&card->kernel_thread_starter);
 }
@@ -750,7 +747,7 @@
 	if (cstat & (SCHN_STAT_CHN_CTRL_CHK | SCHN_STAT_INTF_CTRL_CHK |
 		     SCHN_STAT_CHN_DATA_CHK | SCHN_STAT_CHAIN_CHECK |
 		     SCHN_STAT_PROT_CHECK | SCHN_STAT_PROG_CHECK)) {
-		QETH_DBF_TEXT(trace, 2, "CGENCHK");
+		QETH_DBF_TEXT(TRACE, 2, "CGENCHK");
 		PRINT_WARN("check on device %s, dstat=x%x, cstat=x%x ",
 			   cdev->dev.bus_id, dstat, cstat);
 		print_hex_dump(KERN_WARNING, "qeth: irb ", DUMP_PREFIX_OFFSET,
@@ -761,23 +758,23 @@
 	if (dstat & DEV_STAT_UNIT_CHECK) {
 		if (sense[SENSE_RESETTING_EVENT_BYTE] &
 		    SENSE_RESETTING_EVENT_FLAG) {
-			QETH_DBF_TEXT(trace, 2, "REVIND");
+			QETH_DBF_TEXT(TRACE, 2, "REVIND");
 			return 1;
 		}
 		if (sense[SENSE_COMMAND_REJECT_BYTE] &
 		    SENSE_COMMAND_REJECT_FLAG) {
-			QETH_DBF_TEXT(trace, 2, "CMDREJi");
+			QETH_DBF_TEXT(TRACE, 2, "CMDREJi");
 			return 0;
 		}
 		if ((sense[2] == 0xaf) && (sense[3] == 0xfe)) {
-			QETH_DBF_TEXT(trace, 2, "AFFE");
+			QETH_DBF_TEXT(TRACE, 2, "AFFE");
 			return 1;
 		}
 		if ((!sense[0]) && (!sense[1]) && (!sense[2]) && (!sense[3])) {
-			QETH_DBF_TEXT(trace, 2, "ZEROSEN");
+			QETH_DBF_TEXT(TRACE, 2, "ZEROSEN");
 			return 0;
 		}
-		QETH_DBF_TEXT(trace, 2, "DGENCHK");
+		QETH_DBF_TEXT(TRACE, 2, "DGENCHK");
 			return 1;
 	}
 	return 0;
@@ -792,13 +789,13 @@
 	switch (PTR_ERR(irb)) {
 	case -EIO:
 		PRINT_WARN("i/o-error on device %s\n", cdev->dev.bus_id);
-		QETH_DBF_TEXT(trace, 2, "ckirberr");
-		QETH_DBF_TEXT_(trace, 2, "  rc%d", -EIO);
+		QETH_DBF_TEXT(TRACE, 2, "ckirberr");
+		QETH_DBF_TEXT_(TRACE, 2, "  rc%d", -EIO);
 		break;
 	case -ETIMEDOUT:
 		PRINT_WARN("timeout on device %s\n", cdev->dev.bus_id);
-		QETH_DBF_TEXT(trace, 2, "ckirberr");
-		QETH_DBF_TEXT_(trace, 2, "  rc%d", -ETIMEDOUT);
+		QETH_DBF_TEXT(TRACE, 2, "ckirberr");
+		QETH_DBF_TEXT_(TRACE, 2, "  rc%d", -ETIMEDOUT);
 		if (intparm == QETH_RCD_PARM) {
 			struct qeth_card *card = CARD_FROM_CDEV(cdev);
 
@@ -811,8 +808,8 @@
 	default:
 		PRINT_WARN("unknown error %ld on device %s\n", PTR_ERR(irb),
 			   cdev->dev.bus_id);
-		QETH_DBF_TEXT(trace, 2, "ckirberr");
-		QETH_DBF_TEXT(trace, 2, "  rc???");
+		QETH_DBF_TEXT(TRACE, 2, "ckirberr");
+		QETH_DBF_TEXT(TRACE, 2, "  rc???");
 	}
 	return PTR_ERR(irb);
 }
@@ -828,7 +825,7 @@
 	struct qeth_cmd_buffer *iob;
 	__u8 index;
 
-	QETH_DBF_TEXT(trace, 5, "irq");
+	QETH_DBF_TEXT(TRACE, 5, "irq");
 
 	if (__qeth_check_irb_error(cdev, intparm, irb))
 		return;
@@ -841,13 +838,13 @@
 
 	if (card->read.ccwdev == cdev) {
 		channel = &card->read;
-		QETH_DBF_TEXT(trace, 5, "read");
+		QETH_DBF_TEXT(TRACE, 5, "read");
 	} else if (card->write.ccwdev == cdev) {
 		channel = &card->write;
-		QETH_DBF_TEXT(trace, 5, "write");
+		QETH_DBF_TEXT(TRACE, 5, "write");
 	} else {
 		channel = &card->data;
-		QETH_DBF_TEXT(trace, 5, "data");
+		QETH_DBF_TEXT(TRACE, 5, "data");
 	}
 	atomic_set(&channel->irq_pending, 0);
 
@@ -863,12 +860,12 @@
 		goto out;
 
 	if (intparm == QETH_CLEAR_CHANNEL_PARM) {
-		QETH_DBF_TEXT(trace, 6, "clrchpar");
+		QETH_DBF_TEXT(TRACE, 6, "clrchpar");
 		/* we don't have to handle this further */
 		intparm = 0;
 	}
 	if (intparm == QETH_HALT_CHANNEL_PARM) {
-		QETH_DBF_TEXT(trace, 6, "hltchpar");
+		QETH_DBF_TEXT(TRACE, 6, "hltchpar");
 		/* we don't have to handle this further */
 		intparm = 0;
 	}
@@ -954,7 +951,7 @@
 {
 	int i, j;
 
-	QETH_DBF_TEXT(trace, 2, "clearqdbf");
+	QETH_DBF_TEXT(TRACE, 2, "clearqdbf");
 	/* clear outbound buffers to free skbs */
 	for (i = 0; i < card->qdio.no_out_queues; ++i)
 		if (card->qdio.out_qs[i]) {
@@ -969,7 +966,7 @@
 {
 	struct qeth_buffer_pool_entry *pool_entry, *tmp;
 	int i = 0;
-	QETH_DBF_TEXT(trace, 5, "freepool");
+	QETH_DBF_TEXT(TRACE, 5, "freepool");
 	list_for_each_entry_safe(pool_entry, tmp,
 				 &card->qdio.init_pool.entry_list, init_list){
 		for (i = 0; i < QETH_MAX_BUFFER_ELEMENTS(card); ++i)
@@ -983,7 +980,7 @@
 {
 	int i, j;
 
-	QETH_DBF_TEXT(trace, 2, "freeqdbf");
+	QETH_DBF_TEXT(TRACE, 2, "freeqdbf");
 	if (atomic_xchg(&card->qdio.state, QETH_QDIO_UNINITIALIZED) ==
 		QETH_QDIO_UNINITIALIZED)
 		return;
@@ -1008,7 +1005,7 @@
 {
 	int cnt;
 
-	QETH_DBF_TEXT(setup, 2, "freech");
+	QETH_DBF_TEXT(SETUP, 2, "freech");
 	for (cnt = 0; cnt < QETH_CMD_BUFFER_NO; cnt++)
 		kfree(channel->iob[cnt].data);
 }
@@ -1028,7 +1025,7 @@
 		u8 chpp;
 	} *chp_dsc;
 
-	QETH_DBF_TEXT(setup, 2, "chk_1920");
+	QETH_DBF_TEXT(SETUP, 2, "chk_1920");
 
 	ccwdev = card->data.ccwdev;
 	chp_dsc = (struct channelPath_dsc *)ccw_device_get_chp_desc(ccwdev, 0);
@@ -1037,13 +1034,13 @@
 		single_queue = ((chp_dsc->chpp & 0x02) == 0x02);
 		kfree(chp_dsc);
 	}
-	QETH_DBF_TEXT_(setup, 2, "rc:%x", single_queue);
+	QETH_DBF_TEXT_(SETUP, 2, "rc:%x", single_queue);
 	return single_queue;
 }
 
 static void qeth_init_qdio_info(struct qeth_card *card)
 {
-	QETH_DBF_TEXT(setup, 4, "intqdinf");
+	QETH_DBF_TEXT(SETUP, 4, "intqdinf");
 	atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
 	/* inbound */
 	card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
@@ -1073,7 +1070,7 @@
 	int rc = 0;
 
 	spin_lock_irqsave(&card->thread_mask_lock, flags);
-	QETH_DBF_TEXT_(trace, 4, "  %02x%02x%02x",
+	QETH_DBF_TEXT_(TRACE, 4, "  %02x%02x%02x",
 			(u8) card->thread_start_mask,
 			(u8) card->thread_allowed_mask,
 			(u8) card->thread_running_mask);
@@ -1086,7 +1083,7 @@
 {
 	struct qeth_card *card = container_of(work, struct qeth_card,
 					kernel_thread_starter);
-	QETH_DBF_TEXT(trace , 2, "strthrd");
+	QETH_DBF_TEXT(TRACE , 2, "strthrd");
 
 	if (card->read.state != CH_STATE_UP &&
 	    card->write.state != CH_STATE_UP)
@@ -1099,8 +1096,8 @@
 static int qeth_setup_card(struct qeth_card *card)
 {
 
-	QETH_DBF_TEXT(setup, 2, "setupcrd");
-	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 2, "setupcrd");
+	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	card->read.state  = CH_STATE_DOWN;
 	card->write.state = CH_STATE_DOWN;
@@ -1122,7 +1119,7 @@
 	INIT_LIST_HEAD(&card->ip_list);
 	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_KERNEL);
 	if (!card->ip_tbd_list) {
-		QETH_DBF_TEXT(setup, 0, "iptbdnom");
+		QETH_DBF_TEXT(SETUP, 0, "iptbdnom");
 		return -ENOMEM;
 	}
 	INIT_LIST_HEAD(card->ip_tbd_list);
@@ -1144,11 +1141,11 @@
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(setup, 2, "alloccrd");
+	QETH_DBF_TEXT(SETUP, 2, "alloccrd");
 	card = kzalloc(sizeof(struct qeth_card), GFP_DMA|GFP_KERNEL);
 	if (!card)
 		return NULL;
-	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 	if (qeth_setup_channel(&card->read)) {
 		kfree(card);
 		return NULL;
@@ -1166,7 +1163,7 @@
 {
 	int i = 0;
 
-	QETH_DBF_TEXT(setup, 2, "detcdtyp");
+	QETH_DBF_TEXT(SETUP, 2, "detcdtyp");
 
 	card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
 	card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
@@ -1197,7 +1194,7 @@
 	struct qeth_card *card;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "clearch");
+	QETH_DBF_TEXT(TRACE, 3, "clearch");
 	card = CARD_FROM_CDEV(channel->ccwdev);
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	rc = ccw_device_clear(channel->ccwdev, QETH_CLEAR_CHANNEL_PARM);
@@ -1221,7 +1218,7 @@
 	struct qeth_card *card;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "haltch");
+	QETH_DBF_TEXT(TRACE, 3, "haltch");
 	card = CARD_FROM_CDEV(channel->ccwdev);
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	rc = ccw_device_halt(channel->ccwdev, QETH_HALT_CHANNEL_PARM);
@@ -1242,7 +1239,7 @@
 {
 	int rc1 = 0, rc2 = 0, rc3 = 0;
 
-	QETH_DBF_TEXT(trace, 3, "haltchs");
+	QETH_DBF_TEXT(TRACE, 3, "haltchs");
 	rc1 = qeth_halt_channel(&card->read);
 	rc2 = qeth_halt_channel(&card->write);
 	rc3 = qeth_halt_channel(&card->data);
@@ -1257,7 +1254,7 @@
 {
 	int rc1 = 0, rc2 = 0, rc3 = 0;
 
-	QETH_DBF_TEXT(trace, 3, "clearchs");
+	QETH_DBF_TEXT(TRACE, 3, "clearchs");
 	rc1 = qeth_clear_channel(&card->read);
 	rc2 = qeth_clear_channel(&card->write);
 	rc3 = qeth_clear_channel(&card->data);
@@ -1272,8 +1269,8 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "clhacrd");
-	QETH_DBF_HEX(trace, 3, &card, sizeof(void *));
+	QETH_DBF_TEXT(TRACE, 3, "clhacrd");
+	QETH_DBF_HEX(TRACE, 3, &card, sizeof(void *));
 
 	if (halt)
 		rc = qeth_halt_channels(card);
@@ -1286,7 +1283,7 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "qdioclr");
+	QETH_DBF_TEXT(TRACE, 3, "qdioclr");
 	switch (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_ESTABLISHED,
 		QETH_QDIO_CLEANING)) {
 	case QETH_QDIO_ESTABLISHED:
@@ -1297,7 +1294,7 @@
 			rc = qdio_cleanup(CARD_DDEV(card),
 				QDIO_FLAG_CLEANUP_USING_CLEAR);
 		if (rc)
-			QETH_DBF_TEXT_(trace, 3, "1err%d", rc);
+			QETH_DBF_TEXT_(TRACE, 3, "1err%d", rc);
 		atomic_set(&card->qdio.state, QETH_QDIO_ALLOCATED);
 		break;
 	case QETH_QDIO_CLEANING:
@@ -1307,7 +1304,7 @@
 	}
 	rc = qeth_clear_halt_card(card, use_halt);
 	if (rc)
-		QETH_DBF_TEXT_(trace, 3, "2err%d", rc);
+		QETH_DBF_TEXT_(TRACE, 3, "2err%d", rc);
 	card->state = CARD_STATE_DOWN;
 	return rc;
 }
@@ -1367,7 +1364,7 @@
 	char *prcd;
 	int rc;
 
-	QETH_DBF_TEXT(setup, 2, "getunit");
+	QETH_DBF_TEXT(SETUP, 2, "getunit");
 	rc = qeth_read_conf_data(card, (void **) &prcd, &length);
 	if (rc) {
 		PRINT_ERR("qeth_read_conf_data for device %s returned %i\n",
@@ -1428,7 +1425,7 @@
 	int rc;
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(setup, 2, "idxanswr");
+	QETH_DBF_TEXT(SETUP, 2, "idxanswr");
 	card = CARD_FROM_CDEV(channel->ccwdev);
 	iob = qeth_get_buffer(channel);
 	iob->callback = idx_reply_cb;
@@ -1438,7 +1435,7 @@
 
 	wait_event(card->wait_q,
 		   atomic_cmpxchg(&channel->irq_pending, 0, 1) == 0);
-	QETH_DBF_TEXT(setup, 6, "noirqpnd");
+	QETH_DBF_TEXT(SETUP, 6, "noirqpnd");
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	rc = ccw_device_start(channel->ccwdev,
 			      &channel->ccw, (addr_t) iob, 0, 0);
@@ -1446,7 +1443,7 @@
 
 	if (rc) {
 		PRINT_ERR("Error2 in activating channel rc=%d\n", rc);
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		atomic_set(&channel->irq_pending, 0);
 		wake_up(&card->wait_q);
 		return rc;
@@ -1457,7 +1454,7 @@
 		return rc;
 	if (channel->state != CH_STATE_UP) {
 		rc = -ETIME;
-		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
 		qeth_clear_cmd_buffers(channel);
 	} else
 		rc = 0;
@@ -1477,7 +1474,7 @@
 
 	card = CARD_FROM_CDEV(channel->ccwdev);
 
-	QETH_DBF_TEXT(setup, 2, "idxactch");
+	QETH_DBF_TEXT(SETUP, 2, "idxactch");
 
 	iob = qeth_get_buffer(channel);
 	iob->callback = idx_reply_cb;
@@ -1507,7 +1504,7 @@
 
 	wait_event(card->wait_q,
 		   atomic_cmpxchg(&channel->irq_pending, 0, 1) == 0);
-	QETH_DBF_TEXT(setup, 6, "noirqpnd");
+	QETH_DBF_TEXT(SETUP, 6, "noirqpnd");
 	spin_lock_irqsave(get_ccwdev_lock(channel->ccwdev), flags);
 	rc = ccw_device_start(channel->ccwdev,
 			      &channel->ccw, (addr_t) iob, 0, 0);
@@ -1515,7 +1512,7 @@
 
 	if (rc) {
 		PRINT_ERR("Error1 in activating channel. rc=%d\n", rc);
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		atomic_set(&channel->irq_pending, 0);
 		wake_up(&card->wait_q);
 		return rc;
@@ -1526,7 +1523,7 @@
 		return rc;
 	if (channel->state != CH_STATE_ACTIVATING) {
 		PRINT_WARN("IDX activate timed out!\n");
-		QETH_DBF_TEXT_(setup, 2, "2err%d", -ETIME);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", -ETIME);
 		qeth_clear_cmd_buffers(channel);
 		return -ETIME;
 	}
@@ -1548,7 +1545,7 @@
 	struct qeth_card *card;
 	__u16 temp;
 
-	QETH_DBF_TEXT(setup , 2, "idxwrcb");
+	QETH_DBF_TEXT(SETUP , 2, "idxwrcb");
 
 	if (channel->state == CH_STATE_DOWN) {
 		channel->state = CH_STATE_ACTIVATING;
@@ -1585,7 +1582,7 @@
 	struct qeth_card *card;
 	__u16 temp;
 
-	QETH_DBF_TEXT(setup , 2, "idxrdcb");
+	QETH_DBF_TEXT(SETUP , 2, "idxrdcb");
 	if (channel->state == CH_STATE_DOWN) {
 		channel->state = CH_STATE_ACTIVATING;
 		goto out;
@@ -1645,7 +1642,7 @@
 	card->seqno.pdu_hdr++;
 	memcpy(QETH_PDU_HEADER_ACK_SEQ_NO(iob->data),
 	       &card->seqno.pdu_hdr_ack, QETH_SEQ_NO_LENGTH);
-	QETH_DBF_HEX(control, 2, iob->data, QETH_DBF_CONTROL_LEN);
+	QETH_DBF_HEX(CTRL, 2, iob->data, QETH_DBF_CTRL_LEN);
 }
 EXPORT_SYMBOL_GPL(qeth_prepare_control_data);
 
@@ -1660,11 +1657,11 @@
 	struct qeth_reply *reply = NULL;
 	unsigned long timeout;
 
-	QETH_DBF_TEXT(trace, 2, "sendctl");
+	QETH_DBF_TEXT(TRACE, 2, "sendctl");
 
 	reply = qeth_alloc_reply(card);
 	if (!reply) {
-		PRINT_WARN("Could no alloc qeth_reply!\n");
+		PRINT_WARN("Could not alloc qeth_reply!\n");
 		return -ENOMEM;
 	}
 	reply->callback = reply_cb;
@@ -1677,7 +1674,7 @@
 	spin_lock_irqsave(&card->lock, flags);
 	list_add_tail(&reply->list, &card->cmd_waiter_list);
 	spin_unlock_irqrestore(&card->lock, flags);
-	QETH_DBF_HEX(control, 2, iob->data, QETH_DBF_CONTROL_LEN);
+	QETH_DBF_HEX(CTRL, 2, iob->data, QETH_DBF_CTRL_LEN);
 
 	while (atomic_cmpxchg(&card->write.irq_pending, 0, 1)) ;
 	qeth_prepare_control_data(card, len, iob);
@@ -1687,7 +1684,7 @@
 	else
 		timeout = jiffies + QETH_TIMEOUT;
 
-	QETH_DBF_TEXT(trace, 6, "noirqpnd");
+	QETH_DBF_TEXT(TRACE, 6, "noirqpnd");
 	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
 	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
 			      (addr_t) iob, 0, 0);
@@ -1695,7 +1692,7 @@
 	if (rc) {
 		PRINT_WARN("qeth_send_control_data: "
 			   "ccw_device_start rc = %i\n", rc);
-		QETH_DBF_TEXT_(trace, 2, " err%d", rc);
+		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
 		spin_lock_irqsave(&card->lock, flags);
 		list_del_init(&reply->list);
 		qeth_put_reply(reply);
@@ -1727,13 +1724,13 @@
 {
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(setup, 2, "cmenblcb");
+	QETH_DBF_TEXT(SETUP, 2, "cmenblcb");
 
 	iob = (struct qeth_cmd_buffer *) data;
 	memcpy(&card->token.cm_filter_r,
 	       QETH_CM_ENABLE_RESP_FILTER_TOKEN(iob->data),
 	       QETH_MPC_TOKEN_LENGTH);
-	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 	return 0;
 }
 
@@ -1742,7 +1739,7 @@
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(setup, 2, "cmenable");
+	QETH_DBF_TEXT(SETUP, 2, "cmenable");
 
 	iob = qeth_wait_for_buffer(&card->write);
 	memcpy(iob->data, CM_ENABLE, CM_ENABLE_SIZE);
@@ -1762,13 +1759,13 @@
 
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(setup, 2, "cmsetpcb");
+	QETH_DBF_TEXT(SETUP, 2, "cmsetpcb");
 
 	iob = (struct qeth_cmd_buffer *) data;
 	memcpy(&card->token.cm_connection_r,
 	       QETH_CM_SETUP_RESP_DEST_ADDR(iob->data),
 	       QETH_MPC_TOKEN_LENGTH);
-	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 	return 0;
 }
 
@@ -1777,7 +1774,7 @@
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(setup, 2, "cmsetup");
+	QETH_DBF_TEXT(SETUP, 2, "cmsetup");
 
 	iob = qeth_wait_for_buffer(&card->write);
 	memcpy(iob->data, CM_SETUP, CM_SETUP_SIZE);
@@ -1878,7 +1875,7 @@
 	__u8 link_type;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(setup, 2, "ulpenacb");
+	QETH_DBF_TEXT(SETUP, 2, "ulpenacb");
 
 	iob = (struct qeth_cmd_buffer *) data;
 	memcpy(&card->token.ulp_filter_r,
@@ -1889,7 +1886,7 @@
 		mtu = qeth_get_mtu_outof_framesize(framesize);
 		if (!mtu) {
 			iob->rc = -EINVAL;
-			QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+			QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 			return 0;
 		}
 		card->info.max_mtu = mtu;
@@ -1908,7 +1905,7 @@
 		card->info.link_type = link_type;
 	} else
 		card->info.link_type = 0;
-	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 	return 0;
 }
 
@@ -1919,7 +1916,7 @@
 	struct qeth_cmd_buffer *iob;
 
 	/*FIXME: trace view callbacks*/
-	QETH_DBF_TEXT(setup, 2, "ulpenabl");
+	QETH_DBF_TEXT(SETUP, 2, "ulpenabl");
 
 	iob = qeth_wait_for_buffer(&card->write);
 	memcpy(iob->data, ULP_ENABLE, ULP_ENABLE_SIZE);
@@ -1952,13 +1949,13 @@
 {
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(setup, 2, "ulpstpcb");
+	QETH_DBF_TEXT(SETUP, 2, "ulpstpcb");
 
 	iob = (struct qeth_cmd_buffer *) data;
 	memcpy(&card->token.ulp_connection_r,
 	       QETH_ULP_SETUP_RESP_CONNECTION_TOKEN(iob->data),
 	       QETH_MPC_TOKEN_LENGTH);
-	QETH_DBF_TEXT_(setup, 2, "  rc%d", iob->rc);
+	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 	return 0;
 }
 
@@ -1969,7 +1966,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct ccw_dev_id dev_id;
 
-	QETH_DBF_TEXT(setup, 2, "ulpsetup");
+	QETH_DBF_TEXT(SETUP, 2, "ulpsetup");
 
 	iob = qeth_wait_for_buffer(&card->write);
 	memcpy(iob->data, ULP_SETUP, ULP_SETUP_SIZE);
@@ -1994,7 +1991,7 @@
 {
 	int i, j;
 
-	QETH_DBF_TEXT(setup, 2, "allcqdbf");
+	QETH_DBF_TEXT(SETUP, 2, "allcqdbf");
 
 	if (atomic_cmpxchg(&card->qdio.state, QETH_QDIO_UNINITIALIZED,
 		QETH_QDIO_ALLOCATED) != QETH_QDIO_UNINITIALIZED)
@@ -2004,8 +2001,8 @@
 				  GFP_KERNEL);
 	if (!card->qdio.in_q)
 		goto out_nomem;
-	QETH_DBF_TEXT(setup, 2, "inq");
-	QETH_DBF_HEX(setup, 2, &card->qdio.in_q, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 2, "inq");
+	QETH_DBF_HEX(SETUP, 2, &card->qdio.in_q, sizeof(void *));
 	memset(card->qdio.in_q, 0, sizeof(struct qeth_qdio_q));
 	/* give inbound qeth_qdio_buffers their qdio_buffers */
 	for (i = 0; i < QDIO_MAX_BUFFERS_PER_Q; ++i)
@@ -2025,8 +2022,8 @@
 					       GFP_KERNEL);
 		if (!card->qdio.out_qs[i])
 			goto out_freeoutq;
-		QETH_DBF_TEXT_(setup, 2, "outq %i", i);
-		QETH_DBF_HEX(setup, 2, &card->qdio.out_qs[i], sizeof(void *));
+		QETH_DBF_TEXT_(SETUP, 2, "outq %i", i);
+		QETH_DBF_HEX(SETUP, 2, &card->qdio.out_qs[i], sizeof(void *));
 		memset(card->qdio.out_qs[i], 0, sizeof(struct qeth_qdio_out_q));
 		card->qdio.out_qs[i]->queue_no = i;
 		/* give outbound qeth_qdio_buffers their qdio_buffers */
@@ -2086,7 +2083,7 @@
 
 static int qeth_qdio_activate(struct qeth_card *card)
 {
-	QETH_DBF_TEXT(setup, 3, "qdioact");
+	QETH_DBF_TEXT(SETUP, 3, "qdioact");
 	return qdio_activate(CARD_DDEV(card), 0);
 }
 
@@ -2095,7 +2092,7 @@
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(setup, 2, "dmact");
+	QETH_DBF_TEXT(SETUP, 2, "dmact");
 
 	iob = qeth_wait_for_buffer(&card->write);
 	memcpy(iob->data, DM_ACT, DM_ACT_SIZE);
@@ -2112,52 +2109,52 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(setup, 2, "mpcinit");
+	QETH_DBF_TEXT(SETUP, 2, "mpcinit");
 
 	rc = qeth_issue_next_read(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return rc;
 	}
 	rc = qeth_cm_enable(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		goto out_qdio;
 	}
 	rc = qeth_cm_setup(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
 		goto out_qdio;
 	}
 	rc = qeth_ulp_enable(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "4err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "4err%d", rc);
 		goto out_qdio;
 	}
 	rc = qeth_ulp_setup(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
 		goto out_qdio;
 	}
 	rc = qeth_alloc_qdio_buffers(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
 		goto out_qdio;
 	}
 	rc = qeth_qdio_establish(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "6err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
 		qeth_free_qdio_buffers(card);
 		goto out_qdio;
 	}
 	rc = qeth_qdio_activate(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "7err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "7err%d", rc);
 		goto out_qdio;
 	}
 	rc = qeth_dm_act(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "8err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "8err%d", rc);
 		goto out_qdio;
 	}
 
@@ -2261,7 +2258,7 @@
 void qeth_put_buffer_pool_entry(struct qeth_card *card,
 		struct qeth_buffer_pool_entry *entry)
 {
-	QETH_DBF_TEXT(trace, 6, "ptbfplen");
+	QETH_DBF_TEXT(TRACE, 6, "ptbfplen");
 	list_add_tail(&entry->list, &card->qdio.in_buf_pool.entry_list);
 }
 EXPORT_SYMBOL_GPL(qeth_put_buffer_pool_entry);
@@ -2270,7 +2267,7 @@
 {
 	struct qeth_buffer_pool_entry *entry;
 
-	QETH_DBF_TEXT(trace, 5, "inwrklst");
+	QETH_DBF_TEXT(TRACE, 5, "inwrklst");
 
 	list_for_each_entry(entry,
 			    &card->qdio.init_pool.entry_list, init_list) {
@@ -2359,7 +2356,7 @@
 	int i, j;
 	int rc;
 
-	QETH_DBF_TEXT(setup, 2, "initqdqs");
+	QETH_DBF_TEXT(SETUP, 2, "initqdqs");
 
 	/* inbound queue */
 	memset(card->qdio.in_q->qdio_bufs, 0,
@@ -2373,12 +2370,12 @@
 	rc = do_QDIO(CARD_DDEV(card), QDIO_FLAG_SYNC_INPUT, 0, 0,
 		     card->qdio.in_buf_pool.buf_count - 1, NULL);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return rc;
 	}
 	rc = qdio_synchronize(CARD_DDEV(card), QDIO_FLAG_SYNC_INPUT, 0);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		return rc;
 	}
 	/* outbound queue */
@@ -2462,11 +2459,8 @@
 {
 	int rc;
 	char prot_type;
-	int cmd;
-	cmd = ((struct qeth_ipa_cmd *)
-		(iob->data+IPA_PDU_HEADER_SIZE))->hdr.command;
 
-	QETH_DBF_TEXT(trace, 4, "sendipa");
+	QETH_DBF_TEXT(TRACE, 4, "sendipa");
 
 	if (card->options.layer2)
 		if (card->info.type == QETH_CARD_TYPE_OSN)
@@ -2476,14 +2470,8 @@
 	else
 		prot_type = QETH_PROT_TCPIP;
 	qeth_prepare_ipa_cmd(card, iob, prot_type);
-	rc = qeth_send_control_data(card, IPA_CMD_LENGTH, iob,
-				    reply_cb, reply_param);
-	if (rc != 0) {
-		char *ipa_cmd_name;
-		ipa_cmd_name = qeth_get_ipa_cmd_name(cmd);
-		PRINT_ERR("%s %s(%x) returned %s(%x)\n", __FUNCTION__,
-			ipa_cmd_name, cmd, qeth_get_ipa_msg(rc), rc);
-	}
+	rc = qeth_send_control_data(card, IPA_CMD_LENGTH,
+						iob, reply_cb, reply_param);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(qeth_send_ipa_cmd);
@@ -2504,7 +2492,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(setup, 2, "strtlan");
+	QETH_DBF_TEXT(SETUP, 2, "strtlan");
 
 	rc = qeth_send_startstoplan(card, IPA_CMD_STARTLAN, 0);
 	return rc;
@@ -2520,7 +2508,7 @@
 	 * TCP/IP (we!) never issue a STOPLAN
 	 * is this right ?!?
 	 */
-	QETH_DBF_TEXT(setup, 2, "stoplan");
+	QETH_DBF_TEXT(SETUP, 2, "stoplan");
 
 	rc = qeth_send_startstoplan(card, IPA_CMD_STOPLAN, 0);
 	return rc;
@@ -2532,7 +2520,7 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "defadpcb");
+	QETH_DBF_TEXT(TRACE, 4, "defadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code == 0)
@@ -2547,7 +2535,7 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 3, "quyadpcb");
+	QETH_DBF_TEXT(TRACE, 3, "quyadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->data.setadapterparms.data.query_cmds_supp.lan_type & 0x7f)
@@ -2581,7 +2569,7 @@
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(trace, 3, "queryadp");
+	QETH_DBF_TEXT(TRACE, 3, "queryadp");
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_COMMANDS_SUPPORTED,
 				   sizeof(struct qeth_ipacmd_setadpparms));
 	rc = qeth_send_ipa_cmd(card, iob, qeth_query_setadapterparms_cb, NULL);
@@ -2593,14 +2581,14 @@
 		unsigned int siga_error, const char *dbftext)
 {
 	if (qdio_error || siga_error) {
-		QETH_DBF_TEXT(trace, 2, dbftext);
-		QETH_DBF_TEXT(qerr, 2, dbftext);
-		QETH_DBF_TEXT_(qerr, 2, " F15=%02X",
+		QETH_DBF_TEXT(TRACE, 2, dbftext);
+		QETH_DBF_TEXT(QERR, 2, dbftext);
+		QETH_DBF_TEXT_(QERR, 2, " F15=%02X",
 			       buf->element[15].flags & 0xff);
-		QETH_DBF_TEXT_(qerr, 2, " F14=%02X",
+		QETH_DBF_TEXT_(QERR, 2, " F14=%02X",
 			       buf->element[14].flags & 0xff);
-		QETH_DBF_TEXT_(qerr, 2, " qerr=%X", qdio_error);
-		QETH_DBF_TEXT_(qerr, 2, " serr=%X", siga_error);
+		QETH_DBF_TEXT_(QERR, 2, " qerr=%X", qdio_error);
+		QETH_DBF_TEXT_(QERR, 2, " serr=%X", siga_error);
 		return 1;
 	}
 	return 0;
@@ -2615,7 +2603,7 @@
 	int rc;
 	int newcount = 0;
 
-	QETH_DBF_TEXT(trace, 6, "queinbuf");
+	QETH_DBF_TEXT(TRACE, 6, "queinbuf");
 	count = (index < queue->next_buf_to_init)?
 		card->qdio.in_buf_pool.buf_count -
 		(queue->next_buf_to_init - index) :
@@ -2671,8 +2659,8 @@
 			PRINT_WARN("qeth_queue_input_buffer's do_QDIO "
 				   "return %i (device %s).\n",
 				   rc, CARD_DDEV_ID(card));
-			QETH_DBF_TEXT(trace, 2, "qinberr");
-			QETH_DBF_TEXT_(trace, 2, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT(TRACE, 2, "qinberr");
+			QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
 		}
 		queue->next_buf_to_init = (queue->next_buf_to_init + count) %
 					  QDIO_MAX_BUFFERS_PER_Q;
@@ -2687,22 +2675,22 @@
 	int sbalf15 = buffer->buffer->element[15].flags & 0xff;
 	int cc = siga_err & 3;
 
-	QETH_DBF_TEXT(trace, 6, "hdsnderr");
+	QETH_DBF_TEXT(TRACE, 6, "hdsnderr");
 	qeth_check_qdio_errors(buffer->buffer, qdio_err, siga_err, "qouterr");
 	switch (cc) {
 	case 0:
 		if (qdio_err) {
-			QETH_DBF_TEXT(trace, 1, "lnkfail");
-			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
-			QETH_DBF_TEXT_(trace, 1, "%04x %02x",
+			QETH_DBF_TEXT(TRACE, 1, "lnkfail");
+			QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(TRACE, 1, "%04x %02x",
 				       (u16)qdio_err, (u8)sbalf15);
 			return QETH_SEND_ERROR_LINK_FAILURE;
 		}
 		return QETH_SEND_ERROR_NONE;
 	case 2:
 		if (siga_err & QDIO_SIGA_ERROR_B_BIT_SET) {
-			QETH_DBF_TEXT(trace, 1, "SIGAcc2B");
-			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT(TRACE, 1, "SIGAcc2B");
+			QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
 			return QETH_SEND_ERROR_KICK_IT;
 		}
 		if ((sbalf15 >= 15) && (sbalf15 <= 31))
@@ -2710,13 +2698,13 @@
 		return QETH_SEND_ERROR_LINK_FAILURE;
 		/* look at qdio_error and sbalf 15 */
 	case 1:
-		QETH_DBF_TEXT(trace, 1, "SIGAcc1");
-		QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+		QETH_DBF_TEXT(TRACE, 1, "SIGAcc1");
+		QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
 		return QETH_SEND_ERROR_LINK_FAILURE;
 	case 3:
 	default:
-		QETH_DBF_TEXT(trace, 1, "SIGAcc3");
-		QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
+		QETH_DBF_TEXT(TRACE, 1, "SIGAcc3");
+		QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
 		return QETH_SEND_ERROR_KICK_IT;
 	}
 }
@@ -2731,7 +2719,7 @@
 		if (atomic_read(&queue->used_buffers)
 		    >= QETH_HIGH_WATERMARK_PACK){
 			/* switch non-PACKING -> PACKING */
-			QETH_DBF_TEXT(trace, 6, "np->pack");
+			QETH_DBF_TEXT(TRACE, 6, "np->pack");
 			if (queue->card->options.performance_stats)
 				queue->card->perf_stats.sc_dp_p++;
 			queue->do_pack = 1;
@@ -2754,7 +2742,7 @@
 		if (atomic_read(&queue->used_buffers)
 		    <= QETH_LOW_WATERMARK_PACK) {
 			/* switch PACKING -> non-PACKING */
-			QETH_DBF_TEXT(trace, 6, "pack->np");
+			QETH_DBF_TEXT(TRACE, 6, "pack->np");
 			if (queue->card->options.performance_stats)
 				queue->card->perf_stats.sc_p_dp++;
 			queue->do_pack = 0;
@@ -2804,7 +2792,7 @@
 	int i;
 	unsigned int qdio_flags;
 
-	QETH_DBF_TEXT(trace, 6, "flushbuf");
+	QETH_DBF_TEXT(TRACE, 6, "flushbuf");
 
 	for (i = index; i < index + count; ++i) {
 		buf = &queue->bufs[i % QDIO_MAX_BUFFERS_PER_Q];
@@ -2858,9 +2846,9 @@
 			qeth_get_micros() -
 			queue->card->perf_stats.outbound_do_qdio_start_time;
 	if (rc) {
-		QETH_DBF_TEXT(trace, 2, "flushbuf");
-		QETH_DBF_TEXT_(trace, 2, " err%d", rc);
-		QETH_DBF_TEXT_(trace, 2, "%s", CARD_DDEV_ID(queue->card));
+		QETH_DBF_TEXT(TRACE, 2, "flushbuf");
+		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
+		QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_DDEV_ID(queue->card));
 		queue->card->stats.tx_errors += count;
 		/* this must not happen under normal circumstances. if it
 		 * happens something is really wrong -> recover */
@@ -2922,12 +2910,12 @@
 	struct qeth_qdio_out_buffer *buffer;
 	int i;
 
-	QETH_DBF_TEXT(trace, 6, "qdouhdl");
+	QETH_DBF_TEXT(TRACE, 6, "qdouhdl");
 	if (status & QDIO_STATUS_LOOK_FOR_ERROR) {
 		if (status & QDIO_STATUS_ACTIVATE_CHECK_CONDITION) {
-			QETH_DBF_TEXT(trace, 2, "achkcond");
-			QETH_DBF_TEXT_(trace, 2, "%s", CARD_BUS_ID(card));
-			QETH_DBF_TEXT_(trace, 2, "%08x", status);
+			QETH_DBF_TEXT(TRACE, 2, "achkcond");
+			QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(TRACE, 2, "%08x", status);
 			netif_stop_queue(card->dev);
 			qeth_schedule_recovery(card);
 			return;
@@ -3075,7 +3063,7 @@
 {
 	struct sk_buff *new_skb;
 
-	QETH_DBF_TEXT(trace, 6, "prepskb");
+	QETH_DBF_TEXT(TRACE, 6, "prepskb");
 
 	new_skb = qeth_realloc_headroom(card, skb,
 			sizeof(struct qeth_hdr));
@@ -3162,7 +3150,7 @@
 	struct qeth_hdr_tso *hdr;
 	int flush_cnt = 0, hdr_len, large_send = 0;
 
-	QETH_DBF_TEXT(trace, 6, "qdfillbf");
+	QETH_DBF_TEXT(TRACE, 6, "qdfillbf");
 
 	buffer = buf->buffer;
 	atomic_inc(&skb->users);
@@ -3191,12 +3179,12 @@
 					(int *)&buf->next_element_to_fill);
 
 	if (!queue->do_pack) {
-		QETH_DBF_TEXT(trace, 6, "fillbfnp");
+		QETH_DBF_TEXT(TRACE, 6, "fillbfnp");
 		/* set state to PRIMED -> will be flushed */
 		atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
 		flush_cnt = 1;
 	} else {
-		QETH_DBF_TEXT(trace, 6, "fillbfpa");
+		QETH_DBF_TEXT(TRACE, 6, "fillbfpa");
 		if (queue->card->options.performance_stats)
 			queue->card->perf_stats.skbs_sent_pack++;
 		if (buf->next_element_to_fill >=
@@ -3222,7 +3210,7 @@
 	int flush_cnt = 0;
 	int index;
 
-	QETH_DBF_TEXT(trace, 6, "dosndpfa");
+	QETH_DBF_TEXT(TRACE, 6, "dosndpfa");
 
 	/* spin until we get the queue ... */
 	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
@@ -3275,7 +3263,7 @@
 	int tmp;
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 6, "dosndpkt");
+	QETH_DBF_TEXT(TRACE, 6, "dosndpkt");
 
 	/* spin until we get the queue ... */
 	while (atomic_cmpxchg(&queue->state, QETH_OUT_Q_UNLOCKED,
@@ -3382,14 +3370,14 @@
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_ipacmd_setadpparms *setparms;
 
-	QETH_DBF_TEXT(trace, 4, "prmadpcb");
+	QETH_DBF_TEXT(TRACE, 4, "prmadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	setparms = &(cmd->data.setadapterparms);
 
 	qeth_default_setadapterparms_cb(card, reply, (unsigned long)cmd);
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(trace, 4, "prmrc%2.2x", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 4, "prmrc%2.2x", cmd->hdr.return_code);
 		setparms->data.mode = SET_PROMISC_MODE_OFF;
 	}
 	card->info.promisc_mode = setparms->data.mode;
@@ -3403,7 +3391,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "setprom");
+	QETH_DBF_TEXT(TRACE, 4, "setprom");
 
 	if (((dev->flags & IFF_PROMISC) &&
 	     (card->info.promisc_mode == SET_PROMISC_MODE_ON)) ||
@@ -3413,7 +3401,7 @@
 	mode = SET_PROMISC_MODE_OFF;
 	if (dev->flags & IFF_PROMISC)
 		mode = SET_PROMISC_MODE_ON;
-	QETH_DBF_TEXT_(trace, 4, "mode:%x", mode);
+	QETH_DBF_TEXT_(TRACE, 4, "mode:%x", mode);
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_PROMISC_MODE,
 			sizeof(struct qeth_ipacmd_setadpparms));
@@ -3430,9 +3418,9 @@
 
 	card = netdev_priv(dev);
 
-	QETH_DBF_TEXT(trace, 4, "chgmtu");
+	QETH_DBF_TEXT(TRACE, 4, "chgmtu");
 	sprintf(dbf_text, "%8x", new_mtu);
-	QETH_DBF_TEXT(trace, 4, dbf_text);
+	QETH_DBF_TEXT(TRACE, 4, dbf_text);
 
 	if (new_mtu < 64)
 		return -EINVAL;
@@ -3452,7 +3440,7 @@
 
 	card = netdev_priv(dev);
 
-	QETH_DBF_TEXT(trace, 5, "getstat");
+	QETH_DBF_TEXT(TRACE, 5, "getstat");
 
 	return &card->stats;
 }
@@ -3463,7 +3451,7 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "chgmaccb");
+	QETH_DBF_TEXT(TRACE, 4, "chgmaccb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (!card->options.layer2 ||
@@ -3483,7 +3471,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "chgmac");
+	QETH_DBF_TEXT(TRACE, 4, "chgmac");
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_ALTER_MAC_ADDRESS,
 				   sizeof(struct qeth_ipacmd_setadpparms));
@@ -3581,7 +3569,7 @@
 {
 	u16 s1, s2;
 
-	QETH_DBF_TEXT(trace, 4, "sendsnmp");
+	QETH_DBF_TEXT(TRACE, 4, "sendsnmp");
 
 	memcpy(iob->data, IPA_PDU_HEADER, IPA_PDU_HEADER_SIZE);
 	memcpy(QETH_IPA_CMD_DEST_ADDR(iob->data),
@@ -3606,7 +3594,7 @@
 	unsigned char *data;
 	__u16 data_len;
 
-	QETH_DBF_TEXT(trace, 3, "snpcmdcb");
+	QETH_DBF_TEXT(TRACE, 3, "snpcmdcb");
 
 	cmd = (struct qeth_ipa_cmd *) sdata;
 	data = (unsigned char *)((char *)cmd - reply->offset);
@@ -3614,13 +3602,13 @@
 	snmp = &cmd->data.setadapterparms.data.snmp;
 
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(trace, 4, "scer1%i", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 4, "scer1%i", cmd->hdr.return_code);
 		return 0;
 	}
 	if (cmd->data.setadapterparms.hdr.return_code) {
 		cmd->hdr.return_code =
 			cmd->data.setadapterparms.hdr.return_code;
-		QETH_DBF_TEXT_(trace, 4, "scer2%i", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 4, "scer2%i", cmd->hdr.return_code);
 		return 0;
 	}
 	data_len = *((__u16 *)QETH_IPA_PDU_LEN_PDU1(data));
@@ -3631,13 +3619,13 @@
 
 	/* check if there is enough room in userspace */
 	if ((qinfo->udata_len - qinfo->udata_offset) < data_len) {
-		QETH_DBF_TEXT_(trace, 4, "scer3%i", -ENOMEM);
+		QETH_DBF_TEXT_(TRACE, 4, "scer3%i", -ENOMEM);
 		cmd->hdr.return_code = -ENOMEM;
 		return 0;
 	}
-	QETH_DBF_TEXT_(trace, 4, "snore%i",
+	QETH_DBF_TEXT_(TRACE, 4, "snore%i",
 		       cmd->data.setadapterparms.hdr.used_total);
-	QETH_DBF_TEXT_(trace, 4, "sseqn%i",
+	QETH_DBF_TEXT_(TRACE, 4, "sseqn%i",
 		cmd->data.setadapterparms.hdr.seq_no);
 	/*copy entries to user buffer*/
 	if (cmd->data.setadapterparms.hdr.seq_no == 1) {
@@ -3651,9 +3639,9 @@
 	}
 	qinfo->udata_offset += data_len;
 	/* check if all replies received ... */
-		QETH_DBF_TEXT_(trace, 4, "srtot%i",
+		QETH_DBF_TEXT_(TRACE, 4, "srtot%i",
 			       cmd->data.setadapterparms.hdr.used_total);
-		QETH_DBF_TEXT_(trace, 4, "srseq%i",
+		QETH_DBF_TEXT_(TRACE, 4, "srseq%i",
 			       cmd->data.setadapterparms.hdr.seq_no);
 	if (cmd->data.setadapterparms.hdr.seq_no <
 	    cmd->data.setadapterparms.hdr.used_total)
@@ -3670,7 +3658,7 @@
 	struct qeth_arp_query_info qinfo = {0, };
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "snmpcmd");
+	QETH_DBF_TEXT(TRACE, 3, "snmpcmd");
 
 	if (card->info.guestlan)
 		return -EOPNOTSUPP;
@@ -3686,7 +3674,7 @@
 		return -EFAULT;
 	ureq = kmalloc(req_len+sizeof(struct qeth_snmp_ureq_hdr), GFP_KERNEL);
 	if (!ureq) {
-		QETH_DBF_TEXT(trace, 2, "snmpnome");
+		QETH_DBF_TEXT(TRACE, 2, "snmpnome");
 		return -ENOMEM;
 	}
 	if (copy_from_user(ureq, udata,
@@ -3741,7 +3729,7 @@
 	int i, j, k;
 	int rc = 0;
 
-	QETH_DBF_TEXT(setup, 2, "qdioest");
+	QETH_DBF_TEXT(SETUP, 2, "qdioest");
 
 	qib_param_field = kzalloc(QDIO_MAX_BUFFERS_PER_Q * sizeof(char),
 			      GFP_KERNEL);
@@ -3810,8 +3798,8 @@
 static void qeth_core_free_card(struct qeth_card *card)
 {
 
-	QETH_DBF_TEXT(setup, 2, "freecrd");
-	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 2, "freecrd");
+	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 	qeth_clean_channel(&card->read);
 	qeth_clean_channel(&card->write);
 	if (card->dev)
@@ -3868,7 +3856,7 @@
 	int mpno;
 	int rc;
 
-	QETH_DBF_TEXT(setup, 2, "hrdsetup");
+	QETH_DBF_TEXT(SETUP, 2, "hrdsetup");
 	atomic_set(&card->force_alloc_skb, 0);
 retry:
 	if (retries < 3) {
@@ -3882,10 +3870,10 @@
 	}
 	rc = qeth_qdio_clear_card(card, card->info.type != QETH_CARD_TYPE_IQD);
 	if (rc == -ERESTARTSYS) {
-		QETH_DBF_TEXT(setup, 2, "break1");
+		QETH_DBF_TEXT(SETUP, 2, "break1");
 		return rc;
 	} else if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		if (--retries < 0)
 			goto out;
 		else
@@ -3894,7 +3882,7 @@
 
 	rc = qeth_get_unitaddr(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		return rc;
 	}
 
@@ -3909,10 +3897,10 @@
 	qeth_init_func_level(card);
 	rc = qeth_idx_activate_channel(&card->read, qeth_idx_read_cb);
 	if (rc == -ERESTARTSYS) {
-		QETH_DBF_TEXT(setup, 2, "break2");
+		QETH_DBF_TEXT(SETUP, 2, "break2");
 		return rc;
 	} else if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
 		if (--retries < 0)
 			goto out;
 		else
@@ -3920,10 +3908,10 @@
 	}
 	rc = qeth_idx_activate_channel(&card->write, qeth_idx_write_cb);
 	if (rc == -ERESTARTSYS) {
-		QETH_DBF_TEXT(setup, 2, "break3");
+		QETH_DBF_TEXT(SETUP, 2, "break3");
 		return rc;
 	} else if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "4err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "4err%d", rc);
 		if (--retries < 0)
 			goto out;
 		else
@@ -3931,7 +3919,7 @@
 	}
 	rc = qeth_mpc_initialize(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
 		goto out;
 	}
 	return 0;
@@ -3992,7 +3980,7 @@
 	int use_rx_sg = 0;
 	int frag = 0;
 
-	QETH_DBF_TEXT(trace, 6, "nextskb");
+	QETH_DBF_TEXT(TRACE, 6, "nextskb");
 	/* qeth_hdr must not cross element boundaries */
 	if (element->length < offset + sizeof(struct qeth_hdr)) {
 		if (qeth_is_last_sbale(element))
@@ -4048,13 +4036,13 @@
 		skb_len -= data_len;
 		if (skb_len) {
 			if (qeth_is_last_sbale(element)) {
-				QETH_DBF_TEXT(trace, 4, "unexeob");
-				QETH_DBF_TEXT_(trace, 4, "%s",
+				QETH_DBF_TEXT(TRACE, 4, "unexeob");
+				QETH_DBF_TEXT_(TRACE, 4, "%s",
 					CARD_BUS_ID(card));
-				QETH_DBF_TEXT(qerr, 2, "unexeob");
-				QETH_DBF_TEXT_(qerr, 2, "%s",
+				QETH_DBF_TEXT(QERR, 2, "unexeob");
+				QETH_DBF_TEXT_(QERR, 2, "%s",
 					CARD_BUS_ID(card));
-				QETH_DBF_HEX(misc, 4, buffer, sizeof(*buffer));
+				QETH_DBF_HEX(MISC, 4, buffer, sizeof(*buffer));
 				dev_kfree_skb_any(skb);
 				card->stats.rx_errors++;
 				return NULL;
@@ -4077,8 +4065,8 @@
 	if (net_ratelimit()) {
 		PRINT_WARN("No memory for packet received on %s.\n",
 			   QETH_CARD_IFNAME(card));
-		QETH_DBF_TEXT(trace, 2, "noskbmem");
-		QETH_DBF_TEXT_(trace, 2, "%s", CARD_BUS_ID(card));
+		QETH_DBF_TEXT(TRACE, 2, "noskbmem");
+		QETH_DBF_TEXT_(TRACE, 2, "%s", CARD_BUS_ID(card));
 	}
 	card->stats.rx_dropped++;
 	return NULL;
@@ -4087,80 +4075,39 @@
 
 static void qeth_unregister_dbf_views(void)
 {
-	if (qeth_dbf_setup)
-		debug_unregister(qeth_dbf_setup);
-	if (qeth_dbf_qerr)
-		debug_unregister(qeth_dbf_qerr);
-	if (qeth_dbf_sense)
-		debug_unregister(qeth_dbf_sense);
-	if (qeth_dbf_misc)
-		debug_unregister(qeth_dbf_misc);
-	if (qeth_dbf_data)
-		debug_unregister(qeth_dbf_data);
-	if (qeth_dbf_control)
-		debug_unregister(qeth_dbf_control);
-	if (qeth_dbf_trace)
-		debug_unregister(qeth_dbf_trace);
+	int x;
+	for (x = 0; x < QETH_DBF_INFOS; x++) {
+		debug_unregister(qeth_dbf[x].id);
+		qeth_dbf[x].id = NULL;
+	}
 }
 
 static int qeth_register_dbf_views(void)
 {
-	qeth_dbf_setup = debug_register(QETH_DBF_SETUP_NAME,
-					QETH_DBF_SETUP_PAGES,
-					QETH_DBF_SETUP_NR_AREAS,
-					QETH_DBF_SETUP_LEN);
-	qeth_dbf_misc = debug_register(QETH_DBF_MISC_NAME,
-				       QETH_DBF_MISC_PAGES,
-				       QETH_DBF_MISC_NR_AREAS,
-				       QETH_DBF_MISC_LEN);
-	qeth_dbf_data = debug_register(QETH_DBF_DATA_NAME,
-				       QETH_DBF_DATA_PAGES,
-				       QETH_DBF_DATA_NR_AREAS,
-				       QETH_DBF_DATA_LEN);
-	qeth_dbf_control = debug_register(QETH_DBF_CONTROL_NAME,
-					  QETH_DBF_CONTROL_PAGES,
-					  QETH_DBF_CONTROL_NR_AREAS,
-					  QETH_DBF_CONTROL_LEN);
-	qeth_dbf_sense = debug_register(QETH_DBF_SENSE_NAME,
-					QETH_DBF_SENSE_PAGES,
-					QETH_DBF_SENSE_NR_AREAS,
-					QETH_DBF_SENSE_LEN);
-	qeth_dbf_qerr = debug_register(QETH_DBF_QERR_NAME,
-				       QETH_DBF_QERR_PAGES,
-				       QETH_DBF_QERR_NR_AREAS,
-				       QETH_DBF_QERR_LEN);
-	qeth_dbf_trace = debug_register(QETH_DBF_TRACE_NAME,
-					QETH_DBF_TRACE_PAGES,
-					QETH_DBF_TRACE_NR_AREAS,
-					QETH_DBF_TRACE_LEN);
-
-	if ((qeth_dbf_setup == NULL) || (qeth_dbf_misc == NULL)    ||
-	    (qeth_dbf_data == NULL)  || (qeth_dbf_control == NULL) ||
-	    (qeth_dbf_sense == NULL) || (qeth_dbf_qerr == NULL)    ||
-	    (qeth_dbf_trace == NULL)) {
-		qeth_unregister_dbf_views();
-		return -ENOMEM;
-	}
-	debug_register_view(qeth_dbf_setup, &debug_hex_ascii_view);
-	debug_set_level(qeth_dbf_setup, QETH_DBF_SETUP_LEVEL);
-
-	debug_register_view(qeth_dbf_misc, &debug_hex_ascii_view);
-	debug_set_level(qeth_dbf_misc, QETH_DBF_MISC_LEVEL);
-
-	debug_register_view(qeth_dbf_data, &debug_hex_ascii_view);
-	debug_set_level(qeth_dbf_data, QETH_DBF_DATA_LEVEL);
-
-	debug_register_view(qeth_dbf_control, &debug_hex_ascii_view);
-	debug_set_level(qeth_dbf_control, QETH_DBF_CONTROL_LEVEL);
+	int ret;
+	int x;
 
-	debug_register_view(qeth_dbf_sense, &debug_hex_ascii_view);
-	debug_set_level(qeth_dbf_sense, QETH_DBF_SENSE_LEVEL);
+	for (x = 0; x < QETH_DBF_INFOS; x++) {
+		/* register the areas */
+		qeth_dbf[x].id = debug_register(qeth_dbf[x].name,
+						qeth_dbf[x].pages,
+						qeth_dbf[x].areas,
+						qeth_dbf[x].len);
+		if (qeth_dbf[x].id == NULL) {
+			qeth_unregister_dbf_views();
+			return -ENOMEM;
+		}
 
-	debug_register_view(qeth_dbf_qerr, &debug_hex_ascii_view);
-	debug_set_level(qeth_dbf_qerr, QETH_DBF_QERR_LEVEL);
+		/* register a view */
+		ret = debug_register_view(qeth_dbf[x].id, qeth_dbf[x].view);
+		if (ret) {
+			qeth_unregister_dbf_views();
+			return ret;
+		}
 
-	debug_register_view(qeth_dbf_trace, &debug_hex_ascii_view);
-	debug_set_level(qeth_dbf_trace, QETH_DBF_TRACE_LEVEL);
+		/* set a passing level */
+		debug_set_level(qeth_dbf[x].id, qeth_dbf[x].level);
+	}
 
 	return 0;
 }
@@ -4205,17 +4152,17 @@
 	int rc;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(setup, 2, "probedev");
+	QETH_DBF_TEXT(SETUP, 2, "probedev");
 
 	dev = &gdev->dev;
 	if (!get_device(dev))
 		return -ENODEV;
 
-	QETH_DBF_TEXT_(setup, 2, "%s", gdev->dev.bus_id);
+	QETH_DBF_TEXT_(SETUP, 2, "%s", gdev->dev.bus_id);
 
 	card = qeth_alloc_card();
 	if (!card) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", -ENOMEM);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", -ENOMEM);
 		rc = -ENOMEM;
 		goto err_dev;
 	}
@@ -4231,12 +4178,12 @@
 	rc = qeth_determine_card_type(card);
 	if (rc) {
 		PRINT_WARN("%s: not a valid card type\n", __func__);
-		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
 		goto err_card;
 	}
 	rc = qeth_setup_card(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		goto err_card;
 	}
 
Index: git_davem-2.6.26/drivers/s390/net/qeth_core_mpc.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_mpc.c	2008-03-31 11:25:35.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_mpc.c	2008-03-31 11:25:35.000000000 +0200
@@ -230,7 +230,7 @@
 	{IPA_CMD_STARTLAN,	"startlan"},
 	{IPA_CMD_STOPLAN,	"stoplan"},
 	{IPA_CMD_SETVMAC,	"setvmac"},
-	{IPA_CMD_DELVMAC,	"delvmca"},
+	{IPA_CMD_DELVMAC,	"delvmac"},
 	{IPA_CMD_SETGMAC,	"setgmac"},
 	{IPA_CMD_DELGMAC,	"delgmac"},
 	{IPA_CMD_SETVLAN,	"setvlan"},
Index: git_davem-2.6.26/drivers/s390/net/qeth_core_offl.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_core_offl.c	2008-03-31 11:25:28.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_core_offl.c	2008-03-31 11:25:35.000000000 +0200
@@ -31,7 +31,7 @@
 	int skbs_in_buffer;
 	int buffers_needed = 0;
 
-	QETH_DBF_TEXT(trace, 5, "eddpcbfc");
+	QETH_DBF_TEXT(TRACE, 5, "eddpcbfc");
 	while (elements_needed > 0) {
 		buffers_needed++;
 		if (atomic_read(&queue->bufs[index].state) !=
@@ -51,7 +51,7 @@
 {
 	int i;
 
-	QETH_DBF_TEXT(trace, 5, "eddpfctx");
+	QETH_DBF_TEXT(TRACE, 5, "eddpfctx");
 	for (i = 0; i < ctx->num_pages; ++i)
 		free_page((unsigned long)ctx->pages[i]);
 	kfree(ctx->pages);
@@ -76,7 +76,7 @@
 {
 	struct qeth_eddp_context_reference *ref;
 
-	QETH_DBF_TEXT(trace, 6, "eddprctx");
+	QETH_DBF_TEXT(TRACE, 6, "eddprctx");
 	while (!list_empty(&buf->ctx_list)) {
 		ref = list_entry(buf->ctx_list.next,
 				 struct qeth_eddp_context_reference, list);
@@ -91,7 +91,7 @@
 {
 	struct qeth_eddp_context_reference *ref;
 
-	QETH_DBF_TEXT(trace, 6, "eddprfcx");
+	QETH_DBF_TEXT(TRACE, 6, "eddprfcx");
 	ref = kmalloc(sizeof(struct qeth_eddp_context_reference), GFP_ATOMIC);
 	if (ref == NULL)
 		return -ENOMEM;
@@ -112,7 +112,7 @@
 	int must_refcnt = 1;
 	int i;
 
-	QETH_DBF_TEXT(trace, 5, "eddpfibu");
+	QETH_DBF_TEXT(TRACE, 5, "eddpfibu");
 	while (elements > 0) {
 		buf = &queue->bufs[index];
 		if (atomic_read(&buf->state) != QETH_QDIO_BUF_EMPTY) {
@@ -166,7 +166,7 @@
 	}
 out_check:
 	if (!queue->do_pack) {
-		QETH_DBF_TEXT(trace, 6, "fillbfnp");
+		QETH_DBF_TEXT(TRACE, 6, "fillbfnp");
 		/* set state to PRIMED -> will be flushed */
 		if (buf->next_element_to_fill > 0) {
 			atomic_set(&buf->state, QETH_QDIO_BUF_PRIMED);
@@ -175,7 +175,7 @@
 	} else {
 		if (queue->card->options.performance_stats)
 			queue->card->perf_stats.skbs_sent_pack++;
-		QETH_DBF_TEXT(trace, 6, "fillbfpa");
+		QETH_DBF_TEXT(TRACE, 6, "fillbfpa");
 		if (buf->next_element_to_fill >=
 				QETH_MAX_BUFFER_ELEMENTS(queue->card)) {
 			/*
@@ -199,7 +199,7 @@
 	int pkt_len;
 	struct qeth_eddp_element *element;
 
-	QETH_DBF_TEXT(trace, 5, "eddpcrsh");
+	QETH_DBF_TEXT(TRACE, 5, "eddpcrsh");
 	page = ctx->pages[ctx->offset >> PAGE_SHIFT];
 	page_offset = ctx->offset % PAGE_SIZE;
 	element = &ctx->elements[ctx->num_elements];
@@ -257,7 +257,7 @@
 	int copy_len;
 	u8 *src;
 
-	QETH_DBF_TEXT(trace, 5, "eddpcdtc");
+	QETH_DBF_TEXT(TRACE, 5, "eddpcdtc");
 	if (skb_shinfo(eddp->skb)->nr_frags == 0) {
 		skb_copy_from_linear_data_offset(eddp->skb, eddp->skb_offset,
 						 dst, len);
@@ -305,7 +305,7 @@
 	struct qeth_eddp_element *element;
 	int first_lap = 1;
 
-	QETH_DBF_TEXT(trace, 5, "eddpcsdt");
+	QETH_DBF_TEXT(TRACE, 5, "eddpcsdt");
 	page = ctx->pages[ctx->offset >> PAGE_SHIFT];
 	page_offset = ctx->offset % PAGE_SIZE;
 	element = &ctx->elements[ctx->num_elements];
@@ -346,7 +346,7 @@
 {
 	__wsum phcsum; /* pseudo header checksum */
 
-	QETH_DBF_TEXT(trace, 5, "eddpckt4");
+	QETH_DBF_TEXT(TRACE, 5, "eddpckt4");
 	eddp->th.tcp.h.check = 0;
 	/* compute pseudo header checksum */
 	phcsum = csum_tcpudp_nofold(eddp->nh.ip4.h.saddr, eddp->nh.ip4.h.daddr,
@@ -361,7 +361,7 @@
 	__be32 proto;
 	__wsum phcsum; /* pseudo header checksum */
 
-	QETH_DBF_TEXT(trace, 5, "eddpckt6");
+	QETH_DBF_TEXT(TRACE, 5, "eddpckt6");
 	eddp->th.tcp.h.check = 0;
 	/* compute pseudo header checksum */
 	phcsum = csum_partial((u8 *)&eddp->nh.ip6.h.saddr,
@@ -378,7 +378,7 @@
 {
 	struct qeth_eddp_data *eddp;
 
-	QETH_DBF_TEXT(trace, 5, "eddpcrda");
+	QETH_DBF_TEXT(TRACE, 5, "eddpcrda");
 	eddp = kzalloc(sizeof(struct qeth_eddp_data), GFP_ATOMIC);
 	if (eddp) {
 		eddp->nhl = nhl;
@@ -398,7 +398,7 @@
 	int data_len;
 	__wsum hcsum;
 
-	QETH_DBF_TEXT(trace, 5, "eddpftcp");
+	QETH_DBF_TEXT(TRACE, 5, "eddpftcp");
 	eddp->skb_offset = sizeof(struct qeth_hdr) + eddp->nhl + eddp->thl;
 	if (eddp->qh.hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
 		eddp->skb_offset += sizeof(struct ethhdr);
@@ -457,7 +457,7 @@
 {
 	struct qeth_eddp_data *eddp = NULL;
 
-	QETH_DBF_TEXT(trace, 5, "eddpficx");
+	QETH_DBF_TEXT(TRACE, 5, "eddpficx");
 	/* create our segmentation headers and copy original headers */
 	if (skb->protocol == htons(ETH_P_IP))
 		eddp = qeth_eddp_create_eddp_data(qhdr,
@@ -473,7 +473,7 @@
 						  tcp_hdrlen(skb));
 
 	if (eddp == NULL) {
-		QETH_DBF_TEXT(trace, 2, "eddpfcnm");
+		QETH_DBF_TEXT(TRACE, 2, "eddpfcnm");
 		return -ENOMEM;
 	}
 	if (qhdr->hdr.l2.id == QETH_HEADER_TYPE_LAYER2) {
@@ -499,7 +499,7 @@
 {
 	int skbs_per_page;
 
-	QETH_DBF_TEXT(trace, 5, "eddpcanp");
+	QETH_DBF_TEXT(TRACE, 5, "eddpcanp");
 	/* can we put multiple skbs in one page? */
 	skbs_per_page = PAGE_SIZE / (skb_shinfo(skb)->gso_size + hdr_len);
 	if (skbs_per_page > 1) {
@@ -524,30 +524,30 @@
 	u8 *addr;
 	int i;
 
-	QETH_DBF_TEXT(trace, 5, "creddpcg");
+	QETH_DBF_TEXT(TRACE, 5, "creddpcg");
 	/* create the context and allocate pages */
 	ctx = kzalloc(sizeof(struct qeth_eddp_context), GFP_ATOMIC);
 	if (ctx == NULL) {
-		QETH_DBF_TEXT(trace, 2, "ceddpcn1");
+		QETH_DBF_TEXT(TRACE, 2, "ceddpcn1");
 		return NULL;
 	}
 	ctx->type = QETH_LARGE_SEND_EDDP;
 	qeth_eddp_calc_num_pages(ctx, skb, hdr_len);
 	if (ctx->elements_per_skb > QETH_MAX_BUFFER_ELEMENTS(card)) {
-		QETH_DBF_TEXT(trace, 2, "ceddpcis");
+		QETH_DBF_TEXT(TRACE, 2, "ceddpcis");
 		kfree(ctx);
 		return NULL;
 	}
 	ctx->pages = kcalloc(ctx->num_pages, sizeof(u8 *), GFP_ATOMIC);
 	if (ctx->pages == NULL) {
-		QETH_DBF_TEXT(trace, 2, "ceddpcn2");
+		QETH_DBF_TEXT(TRACE, 2, "ceddpcn2");
 		kfree(ctx);
 		return NULL;
 	}
 	for (i = 0; i < ctx->num_pages; ++i) {
 		addr = (u8 *)get_zeroed_page(GFP_ATOMIC);
 		if (addr == NULL) {
-			QETH_DBF_TEXT(trace, 2, "ceddpcn3");
+			QETH_DBF_TEXT(TRACE, 2, "ceddpcn3");
 			ctx->num_pages = i;
 			qeth_eddp_free_context(ctx);
 			return NULL;
@@ -557,7 +557,7 @@
 	ctx->elements = kcalloc(ctx->num_elements,
 				sizeof(struct qeth_eddp_element), GFP_ATOMIC);
 	if (ctx->elements == NULL) {
-		QETH_DBF_TEXT(trace, 2, "ceddpcn4");
+		QETH_DBF_TEXT(TRACE, 2, "ceddpcn4");
 		qeth_eddp_free_context(ctx);
 		return NULL;
 	}
@@ -573,7 +573,7 @@
 {
 	struct qeth_eddp_context *ctx = NULL;
 
-	QETH_DBF_TEXT(trace, 5, "creddpct");
+	QETH_DBF_TEXT(TRACE, 5, "creddpct");
 	if (skb->protocol == htons(ETH_P_IP))
 		ctx = qeth_eddp_create_context_generic(card, skb,
 						(sizeof(struct qeth_hdr) +
@@ -584,14 +584,14 @@
 			sizeof(struct qeth_hdr) + sizeof(struct ipv6hdr) +
 			tcp_hdrlen(skb));
 	else
-		QETH_DBF_TEXT(trace, 2, "cetcpinv");
+		QETH_DBF_TEXT(TRACE, 2, "cetcpinv");
 
 	if (ctx == NULL) {
-		QETH_DBF_TEXT(trace, 2, "creddpnl");
+		QETH_DBF_TEXT(TRACE, 2, "creddpnl");
 		return NULL;
 	}
 	if (qeth_eddp_fill_context_tcp(ctx, skb, qhdr)) {
-		QETH_DBF_TEXT(trace, 2, "ceddptfe");
+		QETH_DBF_TEXT(TRACE, 2, "ceddptfe");
 		qeth_eddp_free_context(ctx);
 		return NULL;
 	}
@@ -603,12 +603,12 @@
 		struct sk_buff *skb, struct qeth_hdr *qhdr,
 		unsigned char sk_protocol)
 {
-	QETH_DBF_TEXT(trace, 5, "creddpc");
+	QETH_DBF_TEXT(TRACE, 5, "creddpc");
 	switch (sk_protocol) {
 	case IPPROTO_TCP:
 		return qeth_eddp_create_context_tcp(card, skb, qhdr);
 	default:
-		QETH_DBF_TEXT(trace, 2, "eddpinvp");
+		QETH_DBF_TEXT(TRACE, 2, "eddpinvp");
 	}
 	return NULL;
 }
@@ -622,7 +622,7 @@
 	struct iphdr *iph = ip_hdr(skb);
 	struct ipv6hdr *ip6h = ipv6_hdr(skb);
 
-	QETH_DBF_TEXT(trace, 5, "tsofhdr");
+	QETH_DBF_TEXT(TRACE, 5, "tsofhdr");
 
 	/*fix header to TSO values ...*/
 	hdr->hdr.hdr.l3.id = QETH_HEADER_TYPE_TSO;
Index: git_davem-2.6.26/drivers/s390/net/qeth_l2_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_l2_main.c	2008-03-31 11:25:35.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_l2_main.c	2008-03-31 11:25:35.000000000 +0200
@@ -22,16 +22,7 @@
 #include "qeth_core.h"
 #include "qeth_core_offl.h"
 
-#define QETH_DBF_TEXT_(name, level, text...) \
-	do { \
-		if (qeth_dbf_passes(qeth_dbf_##name, level)) { \
-			char *dbf_txt_buf = get_cpu_var(qeth_l2_dbf_txt_buf); \
-			sprintf(dbf_txt_buf, text); \
-			debug_text_event(qeth_dbf_##name, level, dbf_txt_buf); \
-			put_cpu_var(qeth_l2_dbf_txt_buf); \
-		} \
-	} while (0)
-
+#define QETH_DBF_TXT_BUF qeth_l2_dbf_txt_buf
 static DEFINE_PER_CPU(char[256], qeth_l2_dbf_txt_buf);
 
 static int qeth_l2_set_offline(struct ccwgroup_device *);
@@ -87,7 +78,7 @@
 		rc = -EOPNOTSUPP;
 	}
 	if (rc)
-		QETH_DBF_TEXT_(trace, 2, "ioce%d", rc);
+		QETH_DBF_TEXT_(TRACE, 2, "ioce%d", rc);
 	return rc;
 }
 
@@ -141,7 +132,7 @@
 	struct qeth_ipa_cmd *cmd;
 	__u8 *mac;
 
-	QETH_DBF_TEXT(trace, 2, "L2Sgmacb");
+	QETH_DBF_TEXT(TRACE, 2, "L2Sgmacb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	/* MAC already registered, needed in couple/uncouple case */
@@ -162,7 +153,7 @@
 
 static int qeth_l2_send_setgroupmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(trace, 2, "L2Sgmac");
+	QETH_DBF_TEXT(TRACE, 2, "L2Sgmac");
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETGMAC,
 					  qeth_l2_send_setgroupmac_cb);
 }
@@ -174,7 +165,7 @@
 	struct qeth_ipa_cmd *cmd;
 	__u8 *mac;
 
-	QETH_DBF_TEXT(trace, 2, "L2Dgmacb");
+	QETH_DBF_TEXT(TRACE, 2, "L2Dgmacb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	mac = &cmd->data.setdelmac.mac[0];
 	if (cmd->hdr.return_code)
@@ -187,7 +178,7 @@
 
 static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(trace, 2, "L2Dgmac");
+	QETH_DBF_TEXT(TRACE, 2, "L2Dgmac");
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELGMAC,
 					  qeth_l2_send_delgroupmac_cb);
 }
@@ -289,15 +280,15 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 2, "L2sdvcb");
+	QETH_DBF_TEXT(TRACE, 2, "L2sdvcb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
 		PRINT_ERR("Error in processing VLAN %i on %s: 0x%x. "
 			  "Continuing\n", cmd->data.setdelvlan.vlan_id,
 			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
-		QETH_DBF_TEXT_(trace, 2, "L2VL%4x", cmd->hdr.command);
-		QETH_DBF_TEXT_(trace, 2, "L2%s", CARD_BUS_ID(card));
-		QETH_DBF_TEXT_(trace, 2, "err%d", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 2, "L2VL%4x", cmd->hdr.command);
+		QETH_DBF_TEXT_(TRACE, 2, "L2%s", CARD_BUS_ID(card));
+		QETH_DBF_TEXT_(TRACE, 2, "err%d", cmd->hdr.return_code);
 	}
 	return 0;
 }
@@ -308,7 +299,7 @@
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT_(trace, 4, "L2sdv%x", ipacmd);
+	QETH_DBF_TEXT_(TRACE, 4, "L2sdv%x", ipacmd);
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelvlan.vlan_id = i;
@@ -319,7 +310,7 @@
 static void qeth_l2_process_vlans(struct qeth_card *card, int clear)
 {
 	struct qeth_vlan_vid *id;
-	QETH_DBF_TEXT(trace, 3, "L2prcvln");
+	QETH_DBF_TEXT(TRACE, 3, "L2prcvln");
 	spin_lock_bh(&card->vlanlock);
 	list_for_each_entry(id, &card->vid_list, list) {
 		if (clear)
@@ -337,7 +328,7 @@
 	struct qeth_card *card = netdev_priv(dev);
 	struct qeth_vlan_vid *id;
 
-	QETH_DBF_TEXT_(trace, 4, "aid:%d", vid);
+	QETH_DBF_TEXT_(TRACE, 4, "aid:%d", vid);
 	id = kmalloc(sizeof(struct qeth_vlan_vid), GFP_ATOMIC);
 	if (id) {
 		id->vid = vid;
@@ -355,7 +346,7 @@
 	struct qeth_vlan_vid *id, *tmpid = NULL;
 	struct qeth_card *card = netdev_priv(dev);
 
-	QETH_DBF_TEXT_(trace, 4, "kid:%d", vid);
+	QETH_DBF_TEXT_(TRACE, 4, "kid:%d", vid);
 	spin_lock_bh(&card->vlanlock);
 	list_for_each_entry(id, &card->vid_list, list) {
 		if (id->vid == vid) {
@@ -376,8 +367,8 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(setup , 2, "stopcard");
-	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP , 2, "stopcard");
+	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, 0, 1);
 	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
@@ -396,7 +387,7 @@
 		if (!card->use_hard_stop) {
 			__u8 *mac = &card->dev->dev_addr[0];
 			rc = qeth_l2_send_delmac(card, mac);
-			QETH_DBF_TEXT_(setup, 2, "Lerr%d", rc);
+			QETH_DBF_TEXT_(SETUP, 2, "Lerr%d", rc);
 		}
 		card->state = CARD_STATE_SOFTSETUP;
 	}
@@ -465,8 +456,8 @@
 			break;
 		default:
 			dev_kfree_skb_any(skb);
-			QETH_DBF_TEXT(trace, 3, "inbunkno");
-			QETH_DBF_HEX(control, 3, hdr, QETH_DBF_CONTROL_LEN);
+			QETH_DBF_TEXT(TRACE, 3, "inbunkno");
+			QETH_DBF_HEX(CTRL, 3, hdr, QETH_DBF_CTRL_LEN);
 			continue;
 		}
 		card->dev->last_rx = jiffies;
@@ -484,7 +475,7 @@
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(trace, 2, "L2sdmac");
+	QETH_DBF_TEXT(TRACE, 2, "L2sdmac");
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
@@ -498,10 +489,10 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 2, "L2Smaccb");
+	QETH_DBF_TEXT(TRACE, 2, "L2Smaccb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(trace, 2, "L2er%x", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 2, "L2er%x", cmd->hdr.return_code);
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
 		cmd->hdr.return_code = -EIO;
 	} else {
@@ -520,7 +511,7 @@
 
 static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(trace, 2, "L2Setmac");
+	QETH_DBF_TEXT(TRACE, 2, "L2Setmac");
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC,
 					  qeth_l2_send_setmac_cb);
 }
@@ -531,10 +522,10 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 2, "L2Dmaccb");
+	QETH_DBF_TEXT(TRACE, 2, "L2Dmaccb");
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(trace, 2, "err%d", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 2, "err%d", cmd->hdr.return_code);
 		cmd->hdr.return_code = -EIO;
 		return 0;
 	}
@@ -545,7 +536,7 @@
 
 static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_DBF_TEXT(trace, 2, "L2Delmac");
+	QETH_DBF_TEXT(TRACE, 2, "L2Delmac");
 	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
 		return 0;
 	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC,
@@ -557,8 +548,8 @@
 	int rc = 0;
 	char vendor_pre[] = {0x02, 0x00, 0x00};
 
-	QETH_DBF_TEXT(setup, 2, "doL2init");
-	QETH_DBF_TEXT_(setup, 2, "doL2%s", CARD_BUS_ID(card));
+	QETH_DBF_TEXT(SETUP, 2, "doL2init");
+	QETH_DBF_TEXT_(SETUP, 2, "doL2%s", CARD_BUS_ID(card));
 
 	rc = qeth_query_setadapterparms(card);
 	if (rc) {
@@ -572,10 +563,10 @@
 			PRINT_WARN("couldn't get MAC address on "
 			   "device %s: x%x\n",
 			   CARD_BUS_ID(card), rc);
-			QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+			QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 			return rc;
 		}
-		QETH_DBF_HEX(setup, 2, card->dev->dev_addr, OSA_ADDR_LEN);
+		QETH_DBF_HEX(SETUP, 2, card->dev->dev_addr, OSA_ADDR_LEN);
 	} else {
 		random_ether_addr(card->dev->dev_addr);
 		memcpy(card->dev->dev_addr, vendor_pre, 3);
@@ -589,21 +580,21 @@
 	struct qeth_card *card = netdev_priv(dev);
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "setmac");
+	QETH_DBF_TEXT(TRACE, 3, "setmac");
 
 	if (qeth_l2_verify_dev(dev) != QETH_REAL_CARD) {
-		QETH_DBF_TEXT(trace, 3, "setmcINV");
+		QETH_DBF_TEXT(TRACE, 3, "setmcINV");
 		return -EOPNOTSUPP;
 	}
 
 	if (card->info.type == QETH_CARD_TYPE_OSN) {
 		PRINT_WARN("Setting MAC address on %s is not supported.\n",
 			   dev->name);
-		QETH_DBF_TEXT(trace, 3, "setmcOSN");
+		QETH_DBF_TEXT(TRACE, 3, "setmcOSN");
 		return -EOPNOTSUPP;
 	}
-	QETH_DBF_TEXT_(trace, 3, "%s", CARD_BUS_ID(card));
-	QETH_DBF_HEX(trace, 3, addr->sa_data, OSA_ADDR_LEN);
+	QETH_DBF_TEXT_(TRACE, 3, "%s", CARD_BUS_ID(card));
+	QETH_DBF_HEX(TRACE, 3, addr->sa_data, OSA_ADDR_LEN);
 	rc = qeth_l2_send_delmac(card, &card->dev->dev_addr[0]);
 	if (!rc)
 		rc = qeth_l2_send_setmac(card, addr->sa_data);
@@ -618,7 +609,7 @@
 	if (card->info.type == QETH_CARD_TYPE_OSN)
 		return ;
 
-	QETH_DBF_TEXT(trace, 3, "setmulti");
+	QETH_DBF_TEXT(TRACE, 3, "setmulti");
 	qeth_l2_del_all_mc(card);
 	spin_lock_bh(&card->mclock);
 	for (dm = dev->mc_list; dm; dm = dm->next)
@@ -644,7 +635,7 @@
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
 
-	QETH_DBF_TEXT(trace, 6, "l2xmit");
+	QETH_DBF_TEXT(TRACE, 6, "l2xmit");
 
 	if ((card->state != CARD_STATE_UP) || !card->lan_online) {
 		card->stats.tx_carrier_errors++;
@@ -756,7 +747,7 @@
 	int index;
 	int i;
 
-	QETH_DBF_TEXT(trace, 6, "qdinput");
+	QETH_DBF_TEXT(TRACE, 6, "qdinput");
 	card = (struct qeth_card *) card_ptr;
 	net_dev = card->dev;
 	if (card->options.performance_stats) {
@@ -765,11 +756,11 @@
 	}
 	if (status & QDIO_STATUS_LOOK_FOR_ERROR) {
 		if (status & QDIO_STATUS_ACTIVATE_CHECK_CONDITION) {
-			QETH_DBF_TEXT(trace, 1, "qdinchk");
-			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
-			QETH_DBF_TEXT_(trace, 1, "%04X%04X", first_element,
+			QETH_DBF_TEXT(TRACE, 1, "qdinchk");
+			QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(TRACE, 1, "%04X%04X", first_element,
 					count);
-			QETH_DBF_TEXT_(trace, 1, "%04X%04X", queue, status);
+			QETH_DBF_TEXT_(TRACE, 1, "%04X%04X", queue, status);
 			qeth_schedule_recovery(card);
 			return;
 		}
@@ -794,13 +785,13 @@
 {
 	struct qeth_card *card = netdev_priv(dev);
 
-	QETH_DBF_TEXT(trace, 4, "qethopen");
+	QETH_DBF_TEXT(TRACE, 4, "qethopen");
 	if (card->state != CARD_STATE_SOFTSETUP)
 		return -ENODEV;
 
 	if ((card->info.type != QETH_CARD_TYPE_OSN) &&
 	     (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))) {
-		QETH_DBF_TEXT(trace, 4, "nomacadr");
+		QETH_DBF_TEXT(TRACE, 4, "nomacadr");
 		return -EPERM;
 	}
 	card->data.state = CH_STATE_UP;
@@ -818,7 +809,7 @@
 {
 	struct qeth_card *card = netdev_priv(dev);
 
-	QETH_DBF_TEXT(trace, 4, "qethstop");
+	QETH_DBF_TEXT(TRACE, 4, "qethstop");
 	netif_tx_disable(dev);
 	card->dev->flags &= ~IFF_UP;
 	if (card->state == CARD_STATE_UP)
@@ -934,8 +925,8 @@
 	enum qeth_card_states recover_flag;
 
 	BUG_ON(!card);
-	QETH_DBF_TEXT(setup, 2, "setonlin");
-	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 2, "setonlin");
+	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
 	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
@@ -947,23 +938,23 @@
 	recover_flag = card->state;
 	rc = ccw_device_set_online(CARD_RDEV(card));
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return -EIO;
 	}
 	rc = ccw_device_set_online(CARD_WDEV(card));
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return -EIO;
 	}
 	rc = ccw_device_set_online(CARD_DDEV(card));
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return -EIO;
 	}
 
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		goto out_remove;
 	}
 
@@ -977,11 +968,11 @@
 	qeth_print_status_message(card);
 
 	/* softsetup */
-	QETH_DBF_TEXT(setup, 2, "softsetp");
+	QETH_DBF_TEXT(SETUP, 2, "softsetp");
 
 	rc = qeth_send_startlan(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		if (rc == 0xe080) {
 			PRINT_WARN("LAN on card %s if offline! "
 				   "Waiting for STARTLAN from card.\n",
@@ -1001,7 +992,7 @@
 
 	rc = qeth_init_qdio_queues(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "6err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
 		goto out_remove;
 	}
 	card->state = CARD_STATE_SOFTSETUP;
@@ -1048,8 +1039,8 @@
 	int rc = 0, rc2 = 0, rc3 = 0;
 	enum qeth_card_states recover_flag;
 
-	QETH_DBF_TEXT(setup, 3, "setoffl");
-	QETH_DBF_HEX(setup, 3, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 3, "setoffl");
+	QETH_DBF_HEX(SETUP, 3, &card, sizeof(void *));
 
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
@@ -1065,7 +1056,7 @@
 	if (!rc)
 		rc = (rc2) ? rc2 : rc3;
 	if (rc)
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 	if (recover_flag == CARD_STATE_UP)
 		card->state = CARD_STATE_RECOVER;
 	/* let user_space know that device is offline */
@@ -1084,11 +1075,11 @@
 	int rc = 0;
 
 	card = (struct qeth_card *) ptr;
-	QETH_DBF_TEXT(trace, 2, "recover1");
-	QETH_DBF_HEX(trace, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(TRACE, 2, "recover1");
+	QETH_DBF_HEX(TRACE, 2, &card, sizeof(void *));
 	if (!qeth_do_run_thread(card, QETH_RECOVER_THREAD))
 		return 0;
-	QETH_DBF_TEXT(trace, 2, "recover2");
+	QETH_DBF_TEXT(TRACE, 2, "recover2");
 	PRINT_WARN("Recovery of device %s started ...\n",
 		   CARD_BUS_ID(card));
 	card->use_hard_stop = 1;
@@ -1139,12 +1130,12 @@
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 5, "osndctrd");
+	QETH_DBF_TEXT(TRACE, 5, "osndctrd");
 
 	wait_event(card->wait_q,
 		   atomic_cmpxchg(&card->write.irq_pending, 0, 1) == 0);
 	qeth_prepare_control_data(card, len, iob);
-	QETH_DBF_TEXT(trace, 6, "osnoirqp");
+	QETH_DBF_TEXT(TRACE, 6, "osnoirqp");
 	spin_lock_irqsave(get_ccwdev_lock(card->write.ccwdev), flags);
 	rc = ccw_device_start(card->write.ccwdev, &card->write.ccw,
 			      (addr_t) iob, 0, 0);
@@ -1152,7 +1143,7 @@
 	if (rc) {
 		PRINT_WARN("qeth_osn_send_control_data: "
 			   "ccw_device_start rc = %i\n", rc);
-		QETH_DBF_TEXT_(trace, 2, " err%d", rc);
+		QETH_DBF_TEXT_(TRACE, 2, " err%d", rc);
 		qeth_release_buffer(iob->channel, iob);
 		atomic_set(&card->write.irq_pending, 0);
 		wake_up(&card->wait_q);
@@ -1165,7 +1156,7 @@
 {
 	u16 s1, s2;
 
-	QETH_DBF_TEXT(trace, 4, "osndipa");
+	QETH_DBF_TEXT(TRACE, 4, "osndipa");
 
 	qeth_prepare_ipa_cmd(card, iob, QETH_PROT_OSN2);
 	s1 = (u16)(IPA_PDU_HEADER_SIZE + data_len);
@@ -1183,7 +1174,7 @@
 	struct qeth_card *card;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 2, "osnsdmc");
+	QETH_DBF_TEXT(TRACE, 2, "osnsdmc");
 	if (!dev)
 		return -ENODEV;
 	card = netdev_priv(dev);
@@ -1205,7 +1196,7 @@
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(trace, 2, "osnreg");
+	QETH_DBF_TEXT(TRACE, 2, "osnreg");
 	*dev = qeth_l2_netdev_by_devno(read_dev_no);
 	if (*dev == NULL)
 		return -ENODEV;
@@ -1224,7 +1215,7 @@
 {
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(trace, 2, "osndereg");
+	QETH_DBF_TEXT(TRACE, 2, "osndereg");
 	if (!dev)
 		return;
 	card = netdev_priv(dev);
Index: git_davem-2.6.26/drivers/s390/net/qeth_l3.h
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_l3.h	2008-03-31 11:25:28.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_l3.h	2008-03-31 11:25:35.000000000 +0200
@@ -13,16 +13,7 @@
 
 #include "qeth_core.h"
 
-#define QETH_DBF_TEXT_(name, level, text...) \
-	do { \
-		if (qeth_dbf_passes(qeth_dbf_##name, level)) { \
-			char *dbf_txt_buf = get_cpu_var(qeth_l3_dbf_txt_buf); \
-			sprintf(dbf_txt_buf, text); \
-			debug_text_event(qeth_dbf_##name, level, dbf_txt_buf); \
-			put_cpu_var(qeth_l3_dbf_txt_buf); \
-		} \
-	} while (0)
-
+#define QETH_DBF_TXT_BUF qeth_l3_dbf_txt_buf
 DECLARE_PER_CPU(char[256], qeth_l3_dbf_txt_buf);
 
 struct qeth_ipaddr {
Index: git_davem-2.6.26/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_davem-2.6.26.orig/drivers/s390/net/qeth_l3_main.c	2008-03-31 11:25:35.000000000 +0200
+++ git_davem-2.6.26/drivers/s390/net/qeth_l3_main.c	2008-03-31 13:21:04.000000000 +0200
@@ -259,7 +259,7 @@
 				addr->users += add ? 1 : -1;
 			if (add && (addr->type == QETH_IP_TYPE_NORMAL) &&
 			    qeth_l3_is_addr_covered_by_ipato(card, addr)) {
-				QETH_DBF_TEXT(trace, 2, "tkovaddr");
+				QETH_DBF_TEXT(TRACE, 2, "tkovaddr");
 				addr->set_flags |= QETH_IPA_SETIP_TAKEOVER_FLAG;
 			}
 			list_add_tail(&addr->entry, card->ip_tbd_list);
@@ -273,13 +273,13 @@
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 4, "delip");
+	QETH_DBF_TEXT(TRACE, 4, "delip");
 
 	if (addr->proto == QETH_PROT_IPV4)
-		QETH_DBF_HEX(trace, 4, &addr->u.a4.addr, 4);
+		QETH_DBF_HEX(TRACE, 4, &addr->u.a4.addr, 4);
 	else {
-		QETH_DBF_HEX(trace, 4, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(trace, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_DBF_HEX(TRACE, 4, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(TRACE, 4, ((char *)&addr->u.a6.addr) + 8, 8);
 	}
 	spin_lock_irqsave(&card->ip_lock, flags);
 	rc = __qeth_l3_insert_ip_todo(card, addr, 0);
@@ -292,12 +292,12 @@
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 4, "addip");
+	QETH_DBF_TEXT(TRACE, 4, "addip");
 	if (addr->proto == QETH_PROT_IPV4)
-		QETH_DBF_HEX(trace, 4, &addr->u.a4.addr, 4);
+		QETH_DBF_HEX(TRACE, 4, &addr->u.a4.addr, 4);
 	else {
-		QETH_DBF_HEX(trace, 4, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(trace, 4, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_DBF_HEX(TRACE, 4, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(TRACE, 4, ((char *)&addr->u.a6.addr) + 8, 8);
 	}
 	spin_lock_irqsave(&card->ip_lock, flags);
 	rc = __qeth_l3_insert_ip_todo(card, addr, 1);
@@ -326,10 +326,10 @@
 	struct qeth_ipaddr *iptodo;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(trace, 4, "delmc");
+	QETH_DBF_TEXT(TRACE, 4, "delmc");
 	iptodo = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
 	if (!iptodo) {
-		QETH_DBF_TEXT(trace, 2, "dmcnomem");
+		QETH_DBF_TEXT(TRACE, 2, "dmcnomem");
 		return;
 	}
 	iptodo->type = QETH_IP_TYPE_DEL_ALL_MC;
@@ -430,14 +430,14 @@
 	unsigned long flags;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 2, "sdiplist");
-	QETH_DBF_HEX(trace, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(TRACE, 2, "sdiplist");
+	QETH_DBF_HEX(TRACE, 2, &card, sizeof(void *));
 
 	spin_lock_irqsave(&card->ip_lock, flags);
 	tbd_list = card->ip_tbd_list;
 	card->ip_tbd_list = kmalloc(sizeof(struct list_head), GFP_ATOMIC);
 	if (!card->ip_tbd_list) {
-		QETH_DBF_TEXT(trace, 0, "silnomem");
+		QETH_DBF_TEXT(TRACE, 0, "silnomem");
 		card->ip_tbd_list = tbd_list;
 		spin_unlock_irqrestore(&card->ip_lock, flags);
 		return;
@@ -488,7 +488,7 @@
 	struct qeth_ipaddr *addr, *tmp;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(trace, 4, "clearip");
+	QETH_DBF_TEXT(TRACE, 4, "clearip");
 	spin_lock_irqsave(&card->ip_lock, flags);
 	/* clear todo list */
 	list_for_each_entry_safe(addr, tmp, card->ip_tbd_list, entry) {
@@ -546,7 +546,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "setdelmc");
+	QETH_DBF_TEXT(TRACE, 4, "setdelmc");
 
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -584,8 +584,8 @@
 	struct qeth_ipa_cmd *cmd;
 	__u8 netmask[16];
 
-	QETH_DBF_TEXT(trace, 4, "setdelip");
-	QETH_DBF_TEXT_(trace, 4, "flags%02X", flags);
+	QETH_DBF_TEXT(TRACE, 4, "setdelip");
+	QETH_DBF_TEXT_(TRACE, 4, "flags%02X", flags);
 
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -614,7 +614,7 @@
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(trace, 4, "setroutg");
+	QETH_DBF_TEXT(TRACE, 4, "setroutg");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETRTG, prot);
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setrtg.type = (type);
@@ -667,7 +667,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "setrtg4");
+	QETH_DBF_TEXT(TRACE, 3, "setrtg4");
 
 	qeth_l3_correct_routing_type(card, &card->options.route4.type,
 				  QETH_PROT_IPV4);
@@ -687,7 +687,7 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "setrtg6");
+	QETH_DBF_TEXT(TRACE, 3, "setrtg6");
 #ifdef CONFIG_QETH_IPV6
 
 	if (!qeth_is_supported(card, IPA_IPV6))
@@ -731,7 +731,7 @@
 	unsigned long flags;
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 2, "addipato");
+	QETH_DBF_TEXT(TRACE, 2, "addipato");
 	spin_lock_irqsave(&card->ip_lock, flags);
 	list_for_each_entry(ipatoe, &card->ipato.entries, entry) {
 		if (ipatoe->proto != new->proto)
@@ -757,7 +757,7 @@
 	struct qeth_ipato_entry *ipatoe, *tmp;
 	unsigned long flags;
 
-	QETH_DBF_TEXT(trace, 2, "delipato");
+	QETH_DBF_TEXT(TRACE, 2, "delipato");
 	spin_lock_irqsave(&card->ip_lock, flags);
 	list_for_each_entry_safe(ipatoe, tmp, &card->ipato.entries, entry) {
 		if (ipatoe->proto != proto)
@@ -785,11 +785,11 @@
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(trace, 2, "addvipa4");
+			QETH_DBF_TEXT(TRACE, 2, "addvipa4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(trace, 2, "addvipa6");
+			QETH_DBF_TEXT(TRACE, 2, "addvipa6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -821,11 +821,11 @@
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(trace, 2, "delvipa4");
+			QETH_DBF_TEXT(TRACE, 2, "delvipa4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(trace, 2, "delvipa6");
+			QETH_DBF_TEXT(TRACE, 2, "delvipa6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -850,11 +850,11 @@
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(trace, 2, "addrxip4");
+			QETH_DBF_TEXT(TRACE, 2, "addrxip4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(trace, 2, "addrxip6");
+			QETH_DBF_TEXT(TRACE, 2, "addrxip6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -886,11 +886,11 @@
 	ipaddr = qeth_l3_get_addr_buffer(proto);
 	if (ipaddr) {
 		if (proto == QETH_PROT_IPV4) {
-			QETH_DBF_TEXT(trace, 2, "addrxip4");
+			QETH_DBF_TEXT(TRACE, 2, "addrxip4");
 			memcpy(&ipaddr->u.a4.addr, addr, 4);
 			ipaddr->u.a4.mask = 0;
 		} else if (proto == QETH_PROT_IPV6) {
-			QETH_DBF_TEXT(trace, 2, "addrxip6");
+			QETH_DBF_TEXT(TRACE, 2, "addrxip6");
 			memcpy(&ipaddr->u.a6.addr, addr, 16);
 			ipaddr->u.a6.pfxlen = 0;
 		}
@@ -910,15 +910,15 @@
 	int cnt = 3;
 
 	if (addr->proto == QETH_PROT_IPV4) {
-		QETH_DBF_TEXT(trace, 2, "setaddr4");
-		QETH_DBF_HEX(trace, 3, &addr->u.a4.addr, sizeof(int));
+		QETH_DBF_TEXT(TRACE, 2, "setaddr4");
+		QETH_DBF_HEX(TRACE, 3, &addr->u.a4.addr, sizeof(int));
 	} else if (addr->proto == QETH_PROT_IPV6) {
-		QETH_DBF_TEXT(trace, 2, "setaddr6");
-		QETH_DBF_HEX(trace, 3, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(trace, 3, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_DBF_TEXT(TRACE, 2, "setaddr6");
+		QETH_DBF_HEX(TRACE, 3, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(TRACE, 3, ((char *)&addr->u.a6.addr) + 8, 8);
 	} else {
-		QETH_DBF_TEXT(trace, 2, "setaddr?");
-		QETH_DBF_HEX(trace, 3, addr, sizeof(struct qeth_ipaddr));
+		QETH_DBF_TEXT(TRACE, 2, "setaddr?");
+		QETH_DBF_HEX(TRACE, 3, addr, sizeof(struct qeth_ipaddr));
 	}
 	do {
 		if (addr->is_multicast)
@@ -927,10 +927,10 @@
 			rc = qeth_l3_send_setdelip(card, addr, IPA_CMD_SETIP,
 					addr->set_flags);
 		if (rc)
-			QETH_DBF_TEXT(trace, 2, "failed");
+			QETH_DBF_TEXT(TRACE, 2, "failed");
 	} while ((--cnt > 0) && rc);
 	if (rc) {
-		QETH_DBF_TEXT(trace, 2, "FAILED");
+		QETH_DBF_TEXT(TRACE, 2, "FAILED");
 		qeth_l3_ipaddr_to_string(addr->proto, (u8 *)&addr->u, buf);
 		PRINT_WARN("Could not register IP address %s (rc=0x%x/%d)\n",
 			   buf, rc, rc);
@@ -944,15 +944,15 @@
 	int rc = 0;
 
 	if (addr->proto == QETH_PROT_IPV4) {
-		QETH_DBF_TEXT(trace, 2, "deladdr4");
-		QETH_DBF_HEX(trace, 3, &addr->u.a4.addr, sizeof(int));
+		QETH_DBF_TEXT(TRACE, 2, "deladdr4");
+		QETH_DBF_HEX(TRACE, 3, &addr->u.a4.addr, sizeof(int));
 	} else if (addr->proto == QETH_PROT_IPV6) {
-		QETH_DBF_TEXT(trace, 2, "deladdr6");
-		QETH_DBF_HEX(trace, 3, &addr->u.a6.addr, 8);
-		QETH_DBF_HEX(trace, 3, ((char *)&addr->u.a6.addr) + 8, 8);
+		QETH_DBF_TEXT(TRACE, 2, "deladdr6");
+		QETH_DBF_HEX(TRACE, 3, &addr->u.a6.addr, 8);
+		QETH_DBF_HEX(TRACE, 3, ((char *)&addr->u.a6.addr) + 8, 8);
 	} else {
-		QETH_DBF_TEXT(trace, 2, "deladdr?");
-		QETH_DBF_HEX(trace, 3, addr, sizeof(struct qeth_ipaddr));
+		QETH_DBF_TEXT(TRACE, 2, "deladdr?");
+		QETH_DBF_HEX(TRACE, 3, addr, sizeof(struct qeth_ipaddr));
 	}
 	if (addr->is_multicast)
 		rc = qeth_l3_send_setdelmc(card, addr, IPA_CMD_DELIPM);
@@ -960,7 +960,7 @@
 		rc = qeth_l3_send_setdelip(card, addr, IPA_CMD_DELIP,
 					addr->del_flags);
 	if (rc) {
-		QETH_DBF_TEXT(trace, 2, "failed");
+		QETH_DBF_TEXT(TRACE, 2, "failed");
 		/* TODO: re-activate this warning as soon as we have a
 		 * clean mirco code
 		qeth_ipaddr_to_string(addr->proto, (u8 *)&addr->u, buf);
@@ -1000,7 +1000,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "adpmode");
+	QETH_DBF_TEXT(TRACE, 4, "adpmode");
 
 	iob = qeth_get_adapter_cmd(card, command,
 				   sizeof(struct qeth_ipacmd_setadpparms));
@@ -1015,7 +1015,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 4, "adphstr");
+	QETH_DBF_TEXT(TRACE, 4, "adphstr");
 
 	if (qeth_adp_supported(card, IPA_SETADP_SET_BROADCAST_MODE)) {
 		rc = qeth_l3_send_setadp_mode(card,
@@ -1048,13 +1048,13 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(setup, 2, "setadprm");
+	QETH_DBF_TEXT(SETUP, 2, "setadprm");
 
 	if (!qeth_is_supported(card, IPA_SETADAPTERPARMS)) {
 		PRINT_WARN("set adapter parameters not supported "
 			   "on device %s.\n",
 			   CARD_BUS_ID(card));
-		QETH_DBF_TEXT(setup, 2, " notsupp");
+		QETH_DBF_TEXT(SETUP, 2, " notsupp");
 		return 0;
 	}
 	rc = qeth_query_setadapterparms(card);
@@ -1083,7 +1083,7 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "defadpcb");
+	QETH_DBF_TEXT(TRACE, 4, "defadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code == 0) {
@@ -1096,7 +1096,7 @@
 	if (cmd->data.setassparms.hdr.assist_no == IPA_INBOUND_CHECKSUM &&
 	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
 		card->info.csum_mask = cmd->data.setassparms.data.flags_32bit;
-		QETH_DBF_TEXT_(trace, 3, "csum:%d", card->info.csum_mask);
+		QETH_DBF_TEXT_(TRACE, 3, "csum:%d", card->info.csum_mask);
 	}
 	return 0;
 }
@@ -1108,7 +1108,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "getasscm");
+	QETH_DBF_TEXT(TRACE, 4, "getasscm");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETASSPARMS, prot);
 
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
@@ -1130,7 +1130,7 @@
 	int rc;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 4, "sendassp");
+	QETH_DBF_TEXT(TRACE, 4, "sendassp");
 
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	if (len <= sizeof(__u32))
@@ -1149,7 +1149,7 @@
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(trace, 4, "simassp6");
+	QETH_DBF_TEXT(TRACE, 4, "simassp6");
 	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
 				       0, QETH_PROT_IPV6);
 	rc = qeth_l3_send_setassparms(card, iob, 0, 0,
@@ -1165,7 +1165,7 @@
 	int length = 0;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT(trace, 4, "simassp4");
+	QETH_DBF_TEXT(TRACE, 4, "simassp4");
 	if (data)
 		length = sizeof(__u32);
 	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
@@ -1179,7 +1179,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "ipaarp");
+	QETH_DBF_TEXT(TRACE, 3, "ipaarp");
 
 	if (!qeth_is_supported(card, IPA_ARP_PROCESSING)) {
 		PRINT_WARN("ARP processing not supported "
@@ -1200,7 +1200,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "ipaipfrg");
+	QETH_DBF_TEXT(TRACE, 3, "ipaipfrg");
 
 	if (!qeth_is_supported(card, IPA_IP_FRAGMENTATION)) {
 		PRINT_INFO("Hardware IP fragmentation not supported on %s\n",
@@ -1223,7 +1223,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "stsrcmac");
+	QETH_DBF_TEXT(TRACE, 3, "stsrcmac");
 
 	if (!card->options.fake_ll)
 		return -EOPNOTSUPP;
@@ -1247,7 +1247,7 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "strtvlan");
+	QETH_DBF_TEXT(TRACE, 3, "strtvlan");
 
 	if (!qeth_is_supported(card, IPA_FULL_VLAN)) {
 		PRINT_WARN("VLAN not supported on %s\n",
@@ -1271,7 +1271,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "stmcast");
+	QETH_DBF_TEXT(TRACE, 3, "stmcast");
 
 	if (!qeth_is_supported(card, IPA_MULTICASTING)) {
 		PRINT_WARN("Multicast not supported on %s\n",
@@ -1297,7 +1297,7 @@
 {
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(setup, 2, "qipasscb");
+	QETH_DBF_TEXT(SETUP, 2, "qipasscb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.prot_version == QETH_PROT_IPV4) {
@@ -1307,9 +1307,9 @@
 		card->options.ipa6.supported_funcs = cmd->hdr.ipa_supported;
 		card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
 	}
-	QETH_DBF_TEXT(setup, 2, "suppenbl");
-	QETH_DBF_TEXT_(setup, 2, "%x", cmd->hdr.ipa_supported);
-	QETH_DBF_TEXT_(setup, 2, "%x", cmd->hdr.ipa_enabled);
+	QETH_DBF_TEXT(SETUP, 2, "suppenbl");
+	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_supported);
+	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_enabled);
 	return 0;
 }
 
@@ -1319,7 +1319,7 @@
 	int rc;
 	struct qeth_cmd_buffer *iob;
 
-	QETH_DBF_TEXT_(setup, 2, "qipassi%i", prot);
+	QETH_DBF_TEXT_(SETUP, 2, "qipassi%i", prot);
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_QIPASSIST, prot);
 	rc = qeth_send_ipa_cmd(card, iob, qeth_l3_query_ipassists_cb, NULL);
 	return rc;
@@ -1330,7 +1330,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "softipv6");
+	QETH_DBF_TEXT(TRACE, 3, "softipv6");
 
 	if (card->info.type == QETH_CARD_TYPE_IQD)
 		goto out;
@@ -1375,7 +1375,7 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "strtipv6");
+	QETH_DBF_TEXT(TRACE, 3, "strtipv6");
 
 	if (!qeth_is_supported(card, IPA_IPV6)) {
 		PRINT_WARN("IPv6 not supported on %s\n",
@@ -1392,7 +1392,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "stbrdcst");
+	QETH_DBF_TEXT(TRACE, 3, "stbrdcst");
 	card->info.broadcast_capable = 0;
 	if (!qeth_is_supported(card, IPA_FILTERING)) {
 		PRINT_WARN("Broadcast not supported on %s\n",
@@ -1462,7 +1462,7 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(trace, 3, "strtcsum");
+	QETH_DBF_TEXT(TRACE, 3, "strtcsum");
 
 	if (card->options.checksum_type == NO_CHECKSUMMING) {
 		PRINT_WARN("Using no checksumming on %s.\n",
@@ -1493,7 +1493,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "sttso");
+	QETH_DBF_TEXT(TRACE, 3, "sttso");
 
 	if (!qeth_is_supported(card, IPA_OUTBOUND_TSO)) {
 		PRINT_WARN("Outbound TSO not supported on %s\n",
@@ -1518,7 +1518,7 @@
 
 static int qeth_l3_start_ipassists(struct qeth_card *card)
 {
-	QETH_DBF_TEXT(trace, 3, "strtipas");
+	QETH_DBF_TEXT(TRACE, 3, "strtipas");
 	qeth_l3_start_ipa_arp_processing(card);	/* go on*/
 	qeth_l3_start_ipa_ip_fragmentation(card);	/* go on*/
 	qeth_l3_start_ipa_source_mac(card);	/* go on*/
@@ -1538,7 +1538,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(trace, 2, "puniqeid");
+	QETH_DBF_TEXT(TRACE, 2, "puniqeid");
 
 	if ((card->info.unique_id & UNIQUE_ID_NOT_BY_CARD) ==
 		UNIQUE_ID_NOT_BY_CARD)
@@ -1575,7 +1575,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(setup, 2, "hsrmac");
+	QETH_DBF_TEXT(SETUP, 2, "hsrmac");
 
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_CREATE_ADDR,
 				     QETH_PROT_IPV6);
@@ -1616,7 +1616,7 @@
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	QETH_DBF_TEXT(setup, 2, "guniqeid");
+	QETH_DBF_TEXT(SETUP, 2, "guniqeid");
 
 	if (!qeth_is_supported(card, IPA_IPV6)) {
 		card->info.unique_id =  UNIQUE_ID_IF_CREATE_ADDR_FAILED |
@@ -1649,7 +1649,7 @@
 	struct ip_mc_list *im4;
 	char buf[MAX_ADDR_LEN];
 
-	QETH_DBF_TEXT(trace, 4, "addmc");
+	QETH_DBF_TEXT(TRACE, 4, "addmc");
 	for (im4 = in4_dev->mc_list; im4; im4 = im4->next) {
 		qeth_l3_get_mac_for_ipm(im4->multiaddr, buf, in4_dev->dev);
 		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV4);
@@ -1669,7 +1669,7 @@
 	struct vlan_group *vg;
 	int i;
 
-	QETH_DBF_TEXT(trace, 4, "addmcvl");
+	QETH_DBF_TEXT(TRACE, 4, "addmcvl");
 	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
 		return;
 
@@ -1693,7 +1693,7 @@
 {
 	struct in_device *in4_dev;
 
-	QETH_DBF_TEXT(trace, 4, "chkmcv4");
+	QETH_DBF_TEXT(TRACE, 4, "chkmcv4");
 	in4_dev = in_dev_get(card->dev);
 	if (in4_dev == NULL)
 		return;
@@ -1711,7 +1711,7 @@
 	struct ifmcaddr6 *im6;
 	char buf[MAX_ADDR_LEN];
 
-	QETH_DBF_TEXT(trace, 4, "addmc6");
+	QETH_DBF_TEXT(TRACE, 4, "addmc6");
 	for (im6 = in6_dev->mc_list; im6 != NULL; im6 = im6->next) {
 		ndisc_mc_map(&im6->mca_addr, buf, in6_dev->dev, 0);
 		ipm = qeth_l3_get_addr_buffer(QETH_PROT_IPV6);
@@ -1732,7 +1732,7 @@
 	struct vlan_group *vg;
 	int i;
 
-	QETH_DBF_TEXT(trace, 4, "admc6vl");
+	QETH_DBF_TEXT(TRACE, 4, "admc6vl");
 	if (!qeth_is_supported(card, IPA_FULL_VLAN) || (card->vlangrp == NULL))
 		return;
 
@@ -1756,7 +1756,7 @@
 {
 	struct inet6_dev *in6_dev;
 
-	QETH_DBF_TEXT(trace, 4, "chkmcv6");
+	QETH_DBF_TEXT(TRACE, 4, "chkmcv6");
 	if (!qeth_is_supported(card, IPA_IPV6))
 		return ;
 	in6_dev = in6_dev_get(card->dev);
@@ -1777,7 +1777,7 @@
 	struct in_ifaddr *ifa;
 	struct qeth_ipaddr *addr;
 
-	QETH_DBF_TEXT(trace, 4, "frvaddr4");
+	QETH_DBF_TEXT(TRACE, 4, "frvaddr4");
 
 	in_dev = in_dev_get(vlan_group_get_device(card->vlangrp, vid));
 	if (!in_dev)
@@ -1803,7 +1803,7 @@
 	struct inet6_ifaddr *ifa;
 	struct qeth_ipaddr *addr;
 
-	QETH_DBF_TEXT(trace, 4, "frvaddr6");
+	QETH_DBF_TEXT(TRACE, 4, "frvaddr6");
 
 	in6_dev = in6_dev_get(vlan_group_get_device(card->vlangrp, vid));
 	if (!in6_dev)
@@ -1838,7 +1838,7 @@
 	struct qeth_card *card = netdev_priv(dev);
 	unsigned long flags;
 
-	QETH_DBF_TEXT(trace, 4, "vlanreg");
+	QETH_DBF_TEXT(TRACE, 4, "vlanreg");
 	spin_lock_irqsave(&card->vlanlock, flags);
 	card->vlangrp = grp;
 	spin_unlock_irqrestore(&card->vlanlock, flags);
@@ -1876,7 +1876,7 @@
 	struct qeth_card *card = netdev_priv(dev);
 	unsigned long flags;
 
-	QETH_DBF_TEXT_(trace, 4, "kid:%d", vid);
+	QETH_DBF_TEXT_(TRACE, 4, "kid:%d", vid);
 	spin_lock_irqsave(&card->vlanlock, flags);
 	/* unregister IP addresses of vlan device */
 	qeth_l3_free_vlan_addresses(card, vid);
@@ -2006,8 +2006,8 @@
 			break;
 		default:
 			dev_kfree_skb_any(skb);
-			QETH_DBF_TEXT(trace, 3, "inbunkno");
-			QETH_DBF_HEX(control, 3, hdr, QETH_DBF_CONTROL_LEN);
+			QETH_DBF_TEXT(TRACE, 3, "inbunkno");
+			QETH_DBF_HEX(CTRL, 3, hdr, QETH_DBF_CTRL_LEN);
 			continue;
 		}
 
@@ -2074,7 +2074,7 @@
 		card = netdev_priv(vlan_dev_info(dev)->real_dev);
 	if (card->options.layer2)
 		card = NULL;
-	QETH_DBF_TEXT_(trace, 4, "%d", rc);
+	QETH_DBF_TEXT_(TRACE, 4, "%d", rc);
 	return card ;
 }
 
@@ -2082,8 +2082,8 @@
 {
 	int rc = 0;
 
-	QETH_DBF_TEXT(setup, 2, "stopcard");
-	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 2, "stopcard");
+	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, 0, 1);
 	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD))
@@ -2096,7 +2096,7 @@
 		if (!card->use_hard_stop) {
 			rc = qeth_send_stoplan(card);
 			if (rc)
-				QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+				QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		}
 		card->state = CARD_STATE_SOFTSETUP;
 	}
@@ -2110,7 +2110,7 @@
 		    (card->info.type != QETH_CARD_TYPE_IQD)) {
 			rc = qeth_l3_put_unique_id(card);
 			if (rc)
-				QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+				QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		}
 		qeth_qdio_clear_card(card, 0);
 		qeth_clear_qdio_buffers(card);
@@ -2129,7 +2129,7 @@
 {
 	struct qeth_card *card = netdev_priv(dev);
 
-	QETH_DBF_TEXT(trace, 3, "setmulti");
+	QETH_DBF_TEXT(TRACE, 3, "setmulti");
 	qeth_l3_delete_mc_addresses(card);
 	qeth_l3_add_multicast_ipv4(card);
 #ifdef CONFIG_QETH_IPV6
@@ -2169,7 +2169,7 @@
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "arpstnoe");
+	QETH_DBF_TEXT(TRACE, 3, "arpstnoe");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2223,17 +2223,17 @@
 	int uentry_size;
 	int i;
 
-	QETH_DBF_TEXT(trace, 4, "arpquecb");
+	QETH_DBF_TEXT(TRACE, 4, "arpquecb");
 
 	qinfo = (struct qeth_arp_query_info *) reply->param;
 	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		QETH_DBF_TEXT_(trace, 4, "qaer1%i", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 4, "qaer1%i", cmd->hdr.return_code);
 		return 0;
 	}
 	if (cmd->data.setassparms.hdr.return_code) {
 		cmd->hdr.return_code = cmd->data.setassparms.hdr.return_code;
-		QETH_DBF_TEXT_(trace, 4, "qaer2%i", cmd->hdr.return_code);
+		QETH_DBF_TEXT_(TRACE, 4, "qaer2%i", cmd->hdr.return_code);
 		return 0;
 	}
 	qdata = &cmd->data.setassparms.data.query_arp;
@@ -2255,17 +2255,17 @@
 	/* check if there is enough room in userspace */
 	if ((qinfo->udata_len - qinfo->udata_offset) <
 			qdata->no_entries * uentry_size){
-		QETH_DBF_TEXT_(trace, 4, "qaer3%i", -ENOMEM);
+		QETH_DBF_TEXT_(TRACE, 4, "qaer3%i", -ENOMEM);
 		cmd->hdr.return_code = -ENOMEM;
 		PRINT_WARN("query ARP user space buffer is too small for "
 			   "the returned number of ARP entries. "
 			   "Aborting query!\n");
 		goto out_error;
 	}
-	QETH_DBF_TEXT_(trace, 4, "anore%i",
+	QETH_DBF_TEXT_(TRACE, 4, "anore%i",
 		       cmd->data.setassparms.hdr.number_of_replies);
-	QETH_DBF_TEXT_(trace, 4, "aseqn%i", cmd->data.setassparms.hdr.seq_no);
-	QETH_DBF_TEXT_(trace, 4, "anoen%i", qdata->no_entries);
+	QETH_DBF_TEXT_(TRACE, 4, "aseqn%i", cmd->data.setassparms.hdr.seq_no);
+	QETH_DBF_TEXT_(TRACE, 4, "anoen%i", qdata->no_entries);
 
 	if (qinfo->mask_bits & QETH_QARP_STRIP_ENTRIES) {
 		/* strip off "media specific information" */
@@ -2301,7 +2301,7 @@
 			unsigned long),
 		void *reply_param)
 {
-	QETH_DBF_TEXT(trace, 4, "sendarp");
+	QETH_DBF_TEXT(TRACE, 4, "sendarp");
 
 	memcpy(iob->data, IPA_PDU_HEADER, IPA_PDU_HEADER_SIZE);
 	memcpy(QETH_IPA_CMD_DEST_ADDR(iob->data),
@@ -2317,7 +2317,7 @@
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "arpquery");
+	QETH_DBF_TEXT(TRACE, 3, "arpquery");
 
 	if (!qeth_is_supported(card,/*IPA_QUERY_ARP_ADDR_INFO*/
 			       IPA_ARP_PROCESSING)) {
@@ -2362,7 +2362,7 @@
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "arpadent");
+	QETH_DBF_TEXT(TRACE, 3, "arpadent");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2404,7 +2404,7 @@
 	int tmp;
 	int rc;
 
-	QETH_DBF_TEXT(trace, 3, "arprment");
+	QETH_DBF_TEXT(TRACE, 3, "arprment");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2443,7 +2443,7 @@
 	int rc;
 	int tmp;
 
-	QETH_DBF_TEXT(trace, 3, "arpflush");
+	QETH_DBF_TEXT(TRACE, 3, "arpflush");
 
 	/*
 	 * currently GuestLAN only supports the ARP assist function
@@ -2552,14 +2552,14 @@
 		rc = -EOPNOTSUPP;
 	}
 	if (rc)
-		QETH_DBF_TEXT_(trace, 2, "ioce%d", rc);
+		QETH_DBF_TEXT_(TRACE, 2, "ioce%d", rc);
 	return rc;
 }
 
 static void qeth_l3_fill_header(struct qeth_card *card, struct qeth_hdr *hdr,
 		struct sk_buff *skb, int ipv, int cast_type)
 {
-	QETH_DBF_TEXT(trace, 6, "fillhdr");
+	QETH_DBF_TEXT(TRACE, 6, "fillhdr");
 
 	memset(hdr, 0, sizeof(struct qeth_hdr));
 	hdr->hdr.l3.id = QETH_HEADER_TYPE_LAYER3;
@@ -2638,7 +2638,7 @@
 	enum qeth_large_send_types large_send = QETH_LARGE_SEND_NO;
 	struct qeth_eddp_context *ctx = NULL;
 
-	QETH_DBF_TEXT(trace, 6, "l3xmit");
+	QETH_DBF_TEXT(TRACE, 6, "l3xmit");
 
 	if ((card->info.type == QETH_CARD_TYPE_IQD) &&
 	    (skb->protocol != htons(ETH_P_IPV6)) &&
@@ -2799,7 +2799,7 @@
 {
 	struct qeth_card *card = netdev_priv(dev);
 
-	QETH_DBF_TEXT(trace, 4, "qethopen");
+	QETH_DBF_TEXT(TRACE, 4, "qethopen");
 	if (card->state != CARD_STATE_SOFTSETUP)
 		return -ENODEV;
 	card->data.state = CH_STATE_UP;
@@ -2816,7 +2816,7 @@
 {
 	struct qeth_card *card = netdev_priv(dev);
 
-	QETH_DBF_TEXT(trace, 4, "qethstop");
+	QETH_DBF_TEXT(TRACE, 4, "qethstop");
 	netif_tx_disable(dev);
 	card->dev->flags &= ~IFF_UP;
 	if (card->state == CARD_STATE_UP)
@@ -2982,7 +2982,7 @@
 	int index;
 	int i;
 
-	QETH_DBF_TEXT(trace, 6, "qdinput");
+	QETH_DBF_TEXT(TRACE, 6, "qdinput");
 	card = (struct qeth_card *) card_ptr;
 	net_dev = card->dev;
 	if (card->options.performance_stats) {
@@ -2991,11 +2991,11 @@
 	}
 	if (status & QDIO_STATUS_LOOK_FOR_ERROR) {
 		if (status & QDIO_STATUS_ACTIVATE_CHECK_CONDITION) {
-			QETH_DBF_TEXT(trace, 1, "qdinchk");
-			QETH_DBF_TEXT_(trace, 1, "%s", CARD_BUS_ID(card));
-			QETH_DBF_TEXT_(trace, 1, "%04X%04X",
+			QETH_DBF_TEXT(TRACE, 1, "qdinchk");
+			QETH_DBF_TEXT_(TRACE, 1, "%s", CARD_BUS_ID(card));
+			QETH_DBF_TEXT_(TRACE, 1, "%04X%04X",
 					first_element, count);
-			QETH_DBF_TEXT_(trace, 1, "%04X%04X", queue, status);
+			QETH_DBF_TEXT_(TRACE, 1, "%04X%04X", queue, status);
 			qeth_schedule_recovery(card);
 			return;
 		}
@@ -3059,8 +3059,8 @@
 	enum qeth_card_states recover_flag;
 
 	BUG_ON(!card);
-	QETH_DBF_TEXT(setup, 2, "setonlin");
-	QETH_DBF_HEX(setup, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 2, "setonlin");
+	QETH_DBF_HEX(SETUP, 2, &card, sizeof(void *));
 
 	qeth_set_allowed_threads(card, QETH_RECOVER_THREAD, 1);
 	if (qeth_wait_for_threads(card, ~QETH_RECOVER_THREAD)) {
@@ -3072,23 +3072,23 @@
 	recover_flag = card->state;
 	rc = ccw_device_set_online(CARD_RDEV(card));
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return -EIO;
 	}
 	rc = ccw_device_set_online(CARD_WDEV(card));
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return -EIO;
 	}
 	rc = ccw_device_set_online(CARD_DDEV(card));
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		return -EIO;
 	}
 
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 		goto out_remove;
 	}
 
@@ -3101,11 +3101,11 @@
 	qeth_print_status_message(card);
 
 	/* softsetup */
-	QETH_DBF_TEXT(setup, 2, "softsetp");
+	QETH_DBF_TEXT(SETUP, 2, "softsetp");
 
 	rc = qeth_send_startlan(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 		if (rc == 0xe080) {
 			PRINT_WARN("LAN on card %s if offline! "
 				   "Waiting for STARTLAN from card.\n",
@@ -3119,21 +3119,21 @@
 
 	rc = qeth_l3_setadapter_parms(card);
 	if (rc)
-		QETH_DBF_TEXT_(setup, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 	rc = qeth_l3_start_ipassists(card);
 	if (rc)
-		QETH_DBF_TEXT_(setup, 2, "3err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
 	rc = qeth_l3_setrouting_v4(card);
 	if (rc)
-		QETH_DBF_TEXT_(setup, 2, "4err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "4err%d", rc);
 	rc = qeth_l3_setrouting_v6(card);
 	if (rc)
-		QETH_DBF_TEXT_(setup, 2, "5err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
 	netif_tx_disable(card->dev);
 
 	rc = qeth_init_qdio_queues(card);
 	if (rc) {
-		QETH_DBF_TEXT_(setup, 2, "6err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
 		goto out_remove;
 	}
 	card->state = CARD_STATE_SOFTSETUP;
@@ -3172,8 +3172,8 @@
 	int rc = 0, rc2 = 0, rc3 = 0;
 	enum qeth_card_states recover_flag;
 
-	QETH_DBF_TEXT(setup, 3, "setoffl");
-	QETH_DBF_HEX(setup, 3, &card, sizeof(void *));
+	QETH_DBF_TEXT(SETUP, 3, "setoffl");
+	QETH_DBF_HEX(SETUP, 3, &card, sizeof(void *));
 
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
@@ -3189,7 +3189,7 @@
 	if (!rc)
 		rc = (rc2) ? rc2 : rc3;
 	if (rc)
-		QETH_DBF_TEXT_(setup, 2, "1err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
 	if (recover_flag == CARD_STATE_UP)
 		card->state = CARD_STATE_RECOVER;
 	/* let user_space know that device is offline */
@@ -3208,11 +3208,11 @@
 	int rc = 0;
 
 	card = (struct qeth_card *) ptr;
-	QETH_DBF_TEXT(trace, 2, "recover1");
-	QETH_DBF_HEX(trace, 2, &card, sizeof(void *));
+	QETH_DBF_TEXT(TRACE, 2, "recover1");
+	QETH_DBF_HEX(TRACE, 2, &card, sizeof(void *));
 	if (!qeth_do_run_thread(card, QETH_RECOVER_THREAD))
 		return 0;
-	QETH_DBF_TEXT(trace, 2, "recover2");
+	QETH_DBF_TEXT(TRACE, 2, "recover2");
 	PRINT_WARN("Recovery of device %s started ...\n",
 		   CARD_BUS_ID(card));
 	card->use_hard_stop = 1;
@@ -3258,7 +3258,7 @@
 	if (dev_net(dev) != &init_net)
 		return NOTIFY_DONE;
 
-	QETH_DBF_TEXT(trace, 3, "ipevent");
+	QETH_DBF_TEXT(TRACE, 3, "ipevent");
 	card = qeth_l3_get_card_from_dev(dev);
 	if (!card)
 		return NOTIFY_DONE;
@@ -3305,7 +3305,7 @@
 	struct qeth_ipaddr *addr;
 	struct qeth_card *card;
 
-	QETH_DBF_TEXT(trace, 3, "ip6event");
+	QETH_DBF_TEXT(TRACE, 3, "ip6event");
 
 	card = qeth_l3_get_card_from_dev(dev);
 	if (!card)
@@ -3348,7 +3348,7 @@
 {
 	int rc;
 
-	QETH_DBF_TEXT(trace, 5, "regnotif");
+	QETH_DBF_TEXT(TRACE, 5, "regnotif");
 	rc = register_inetaddr_notifier(&qeth_l3_ip_notifier);
 	if (rc)
 		return rc;
@@ -3367,7 +3367,7 @@
 static void qeth_l3_unregister_notifiers(void)
 {
 
-	QETH_DBF_TEXT(trace, 5, "unregnot");
+	QETH_DBF_TEXT(TRACE, 5, "unregnot");
 	BUG_ON(unregister_inetaddr_notifier(&qeth_l3_ip_notifier));
 #ifdef CONFIG_QETH_IPV6
 	BUG_ON(unregister_inet6addr_notifier(&qeth_l3_ip6_notifier));

-- 

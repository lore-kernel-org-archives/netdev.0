From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH 1/6] qeth: qeth_core_main make local functions static
Date: Tue, 21 Oct 2014 17:15:26 +0200
Message-ID: <1413904531-55663-2-git-send-email-blaschka@linux.vnet.ibm.com>
References: <1413904531-55663-1-git-send-email-blaschka@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Thomas Richter <tmricht@linux.vnet.ibm.com>,
	Frank Blaschka <blaschka@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:54740 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755620AbaJUPPo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2014 11:15:44 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Tue, 21 Oct 2014 16:15:43 +0100
In-Reply-To: <1413904531-55663-1-git-send-email-blaschka@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

This patch makes some global functions static and removes
the prototypes from the header file.
Also function qeth_query_card_info is not exported anymore,
there is no external user for it, this function should never
have been exported in the first place.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <blaschka@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      | 16 ----------------
 drivers/s390/net/qeth_core_main.c | 18 +++++++++++++++---
 2 files changed, 15 insertions(+), 19 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index e7646ce..7a8bb9f 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -380,11 +380,6 @@ enum qeth_header_ids {
 #define QETH_HDR_EXT_CSUM_TRANSP_REQ  0x20
 #define QETH_HDR_EXT_UDP	      0x40 /*bit off for TCP*/
 
-static inline int qeth_is_last_sbale(struct qdio_buffer_element *sbale)
-{
-	return (sbale->eflags & SBAL_EFLAGS_LAST_ENTRY);
-}
-
 enum qeth_qdio_buffer_states {
 	/*
 	 * inbound: read out by driver; owned by hardware in order to be filled
@@ -843,13 +838,6 @@ struct qeth_trap_id {
 /*some helper functions*/
 #define QETH_CARD_IFNAME(card) (((card)->dev)? (card)->dev->name : "")
 
-static inline struct qeth_card *CARD_FROM_CDEV(struct ccw_device *cdev)
-{
-	struct qeth_card *card = dev_get_drvdata(&((struct ccwgroup_device *)
-		dev_get_drvdata(&cdev->dev))->dev);
-	return card;
-}
-
 static inline int qeth_get_micros(void)
 {
 	return (int) (get_tod_clock() >> 12);
@@ -894,7 +882,6 @@ const char *qeth_get_cardname_short(struct qeth_card *);
 int qeth_realloc_buffer_pool(struct qeth_card *, int);
 int qeth_core_load_discipline(struct qeth_card *, enum qeth_discipline_id);
 void qeth_core_free_discipline(struct qeth_card *);
-void qeth_buffer_reclaim_work(struct work_struct *);
 
 /* exports for qeth discipline device drivers */
 extern struct qeth_card_list_struct qeth_core_card_list;
@@ -913,7 +900,6 @@ int qeth_core_hardsetup_card(struct qeth_card *);
 void qeth_print_status_message(struct qeth_card *);
 int qeth_init_qdio_queues(struct qeth_card *);
 int qeth_send_startlan(struct qeth_card *);
-int qeth_send_stoplan(struct qeth_card *);
 int qeth_send_ipa_cmd(struct qeth_card *, struct qeth_cmd_buffer *,
 		  int (*reply_cb)
 		  (struct qeth_card *, struct qeth_reply *, unsigned long),
@@ -954,8 +940,6 @@ int qeth_snmp_command(struct qeth_card *, char __user *);
 int qeth_query_oat_command(struct qeth_card *, char __user *);
 int qeth_query_switch_attributes(struct qeth_card *card,
 				  struct qeth_switch_info *sw_info);
-int qeth_query_card_info(struct qeth_card *card,
-	struct carrier_info *carrier_info);
 int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
 	int (*reply_cb)(struct qeth_card *, struct qeth_reply*, unsigned long),
 	void *reply_param);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index fd22c81..098bb0f 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -718,6 +718,13 @@ static int qeth_check_idx_response(struct qeth_card *card,
 	return 0;
 }
 
+static struct qeth_card *CARD_FROM_CDEV(struct ccw_device *cdev)
+{
+	struct qeth_card *card = dev_get_drvdata(&((struct ccwgroup_device *)
+		dev_get_drvdata(&cdev->dev))->dev);
+	return card;
+}
+
 static void qeth_setup_ccw(struct qeth_channel *channel, unsigned char *iob,
 		__u32 len)
 {
@@ -1431,6 +1438,7 @@ static void qeth_start_kernel_thread(struct work_struct *work)
 	}
 }
 
+static void qeth_buffer_reclaim_work(struct work_struct *);
 static int qeth_setup_card(struct qeth_card *card)
 {
 
@@ -3232,7 +3240,7 @@ int qeth_check_qdio_errors(struct qeth_card *card, struct qdio_buffer *buf,
 }
 EXPORT_SYMBOL_GPL(qeth_check_qdio_errors);
 
-void qeth_buffer_reclaim_work(struct work_struct *work)
+static void qeth_buffer_reclaim_work(struct work_struct *work)
 {
 	struct qeth_card *card = container_of(work, struct qeth_card,
 		buffer_reclaim_work.work);
@@ -4717,7 +4725,7 @@ static int qeth_query_card_info_cb(struct qeth_card *card,
 	return 0;
 }
 
-int qeth_query_card_info(struct qeth_card *card,
+static int qeth_query_card_info(struct qeth_card *card,
 				struct carrier_info *carrier_info)
 {
 	struct qeth_cmd_buffer *iob;
@@ -4730,7 +4738,6 @@ int qeth_query_card_info(struct qeth_card *card,
 	return qeth_send_ipa_cmd(card, iob, qeth_query_card_info_cb,
 					(void *)carrier_info);
 }
-EXPORT_SYMBOL_GPL(qeth_query_card_info);
 
 static inline int qeth_get_qdio_q_format(struct qeth_card *card)
 {
@@ -5113,6 +5120,11 @@ static inline int qeth_create_skb_frag(struct qeth_qdio_buffer *qethbuffer,
 	return 0;
 }
 
+static inline int qeth_is_last_sbale(struct qdio_buffer_element *sbale)
+{
+	return (sbale->eflags & SBAL_EFLAGS_LAST_ENTRY);
+}
+
 struct sk_buff *qeth_core_get_next_skb(struct qeth_card *card,
 		struct qeth_qdio_buffer *qethbuffer,
 		struct qdio_buffer_element **__element, int *__offset,
-- 
1.8.5.5

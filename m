From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH net] qeth: fix build of s390 allmodconfig
Date: Wed, 29 Jan 2014 09:23:48 +0100
Message-ID: <20140129082348.GA34455@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:35111 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbaA2IXx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 03:23:53 -0500
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <blaschka@linux.vnet.ibm.com>;
	Wed, 29 Jan 2014 08:23:51 -0000
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

commit 949efd1c "qeth: bridgeport support - basic control" broke
s390 allmodconfig. This patch fixes this by eliminating one of the
cross-module calls, and by making two other calls via function
pointers in the qeth_discipline structure.

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reported-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 drivers/s390/net/qeth_core.h      |    5 +---
 drivers/s390/net/qeth_core_main.c |   18 +++++-----------
 drivers/s390/net/qeth_l2_main.c   |   41 ++++++++++++++++++++++++++++++++------
 drivers/s390/net/qeth_l3_main.c   |    8 +++++++
 4 files changed, 51 insertions(+), 21 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -738,6 +738,8 @@ struct qeth_discipline {
 	int (*freeze)(struct ccwgroup_device *);
 	int (*thaw) (struct ccwgroup_device *);
 	int (*restore)(struct ccwgroup_device *);
+	int (*control_event_handler)(struct qeth_card *card,
+					struct qeth_ipa_cmd *cmd);
 };
 
 struct qeth_vlan_vid {
@@ -948,13 +950,10 @@ int qeth_query_card_info(struct qeth_car
 int qeth_send_control_data(struct qeth_card *, int, struct qeth_cmd_buffer *,
 	int (*reply_cb)(struct qeth_card *, struct qeth_reply*, unsigned long),
 	void *reply_param);
-void qeth_bridge_state_change(struct qeth_card *card, struct qeth_ipa_cmd *cmd);
-void qeth_bridgeport_query_support(struct qeth_card *card);
 int qeth_bridgeport_query_ports(struct qeth_card *card,
 	enum qeth_sbp_roles *role, enum qeth_sbp_states *state);
 int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role);
 int qeth_bridgeport_an_set(struct qeth_card *card, int enable);
-void qeth_bridge_host_event(struct qeth_card *card, struct qeth_ipa_cmd *cmd);
 int qeth_get_priority_queue(struct qeth_card *, struct sk_buff *, int, int);
 int qeth_get_elements_no(struct qeth_card *, struct sk_buff *, int);
 int qeth_get_elements_for_frags(struct sk_buff *);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -69,6 +69,7 @@ static void qeth_clear_output_buffer(str
 static int qeth_init_qdio_out_buf(struct qeth_qdio_out_q *, int);
 
 struct workqueue_struct *qeth_wq;
+EXPORT_SYMBOL_GPL(qeth_wq);
 
 static void qeth_close_dev_handler(struct work_struct *work)
 {
@@ -616,15 +617,12 @@ static struct qeth_ipa_cmd *qeth_check_i
 				qeth_schedule_recovery(card);
 				return NULL;
 			case IPA_CMD_SETBRIDGEPORT:
-				if (cmd->data.sbp.hdr.command_code ==
-					IPA_SBP_BRIDGE_PORT_STATE_CHANGE) {
-					qeth_bridge_state_change(card, cmd);
-					return NULL;
-				} else
-					return cmd;
 			case IPA_CMD_ADDRESS_CHANGE_NOTIF:
-				qeth_bridge_host_event(card, cmd);
-				return NULL;
+				if (card->discipline->control_event_handler
+								(card, cmd))
+					return cmd;
+				else
+					return NULL;
 			case IPA_CMD_MODCCID:
 				return cmd;
 			case IPA_CMD_REGISTER_LOCAL_ADDR:
@@ -4973,10 +4971,6 @@ retriable:
 		qeth_query_setadapterparms(card);
 	if (qeth_adp_supported(card, IPA_SETADP_SET_DIAG_ASSIST))
 		qeth_query_setdiagass(card);
-	qeth_bridgeport_query_support(card);
-	if (card->options.sbp.supported_funcs)
-		dev_info(&card->gdev->dev,
-		"The device represents a HiperSockets Bridge Capable Port\n");
 	return 0;
 out:
 	dev_warn(&card->gdev->dev, "The qeth device driver failed to recover "
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -33,6 +33,11 @@ static int qeth_l2_send_setdelmac(struct
 					    unsigned long));
 static void qeth_l2_set_multicast_list(struct net_device *);
 static int qeth_l2_recover(void *);
+static void qeth_bridgeport_query_support(struct qeth_card *card);
+static void qeth_bridge_state_change(struct qeth_card *card,
+					struct qeth_ipa_cmd *cmd);
+static void qeth_bridge_host_event(struct qeth_card *card,
+					struct qeth_ipa_cmd *cmd);
 
 static int qeth_l2_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
@@ -989,6 +994,10 @@ static int __qeth_l2_set_online(struct c
 		rc = -ENODEV;
 		goto out_remove;
 	}
+	qeth_bridgeport_query_support(card);
+	if (card->options.sbp.supported_funcs)
+		dev_info(&card->gdev->dev,
+		"The device represents a HiperSockets Bridge Capable Port\n");
 	qeth_trace_features(card);
 
 	if (!card->dev && qeth_l2_setup_netdev(card)) {
@@ -1233,6 +1242,26 @@ out:
 	return rc;
 }
 
+/* Returns zero if the command is successfully "consumed" */
+static int qeth_l2_control_event(struct qeth_card *card,
+					struct qeth_ipa_cmd *cmd)
+{
+	switch (cmd->hdr.command) {
+	case IPA_CMD_SETBRIDGEPORT:
+		if (cmd->data.sbp.hdr.command_code ==
+				IPA_SBP_BRIDGE_PORT_STATE_CHANGE) {
+			qeth_bridge_state_change(card, cmd);
+			return 0;
+		} else
+			return 1;
+	case IPA_CMD_ADDRESS_CHANGE_NOTIF:
+		qeth_bridge_host_event(card, cmd);
+		return 0;
+	default:
+		return 1;
+	}
+}
+
 struct qeth_discipline qeth_l2_discipline = {
 	.start_poll = qeth_qdio_start_poll,
 	.input_handler = (qdio_handler_t *) qeth_qdio_input_handler,
@@ -1246,6 +1275,7 @@ struct qeth_discipline qeth_l2_disciplin
 	.freeze = qeth_l2_pm_suspend,
 	.thaw = qeth_l2_pm_resume,
 	.restore = qeth_l2_pm_resume,
+	.control_event_handler = qeth_l2_control_event,
 };
 EXPORT_SYMBOL_GPL(qeth_l2_discipline);
 
@@ -1463,7 +1493,8 @@ static void qeth_bridge_state_change_wor
 	kfree(data);
 }
 
-void qeth_bridge_state_change(struct qeth_card *card, struct qeth_ipa_cmd *cmd)
+static void qeth_bridge_state_change(struct qeth_card *card,
+					struct qeth_ipa_cmd *cmd)
 {
 	struct qeth_sbp_state_change *qports =
 		 &cmd->data.sbp.data.state_change;
@@ -1488,7 +1519,6 @@ void qeth_bridge_state_change(struct qet
 			sizeof(struct qeth_sbp_state_change) + extrasize);
 	queue_work(qeth_wq, &data->worker);
 }
-EXPORT_SYMBOL(qeth_bridge_state_change);
 
 struct qeth_bridge_host_data {
 	struct work_struct worker;
@@ -1528,7 +1558,8 @@ static void qeth_bridge_host_event_worke
 	kfree(data);
 }
 
-void qeth_bridge_host_event(struct qeth_card *card, struct qeth_ipa_cmd *cmd)
+static void qeth_bridge_host_event(struct qeth_card *card,
+					struct qeth_ipa_cmd *cmd)
 {
 	struct qeth_ipacmd_addr_change *hostevs =
 		 &cmd->data.addrchange;
@@ -1560,7 +1591,6 @@ void qeth_bridge_host_event(struct qeth_
 			sizeof(struct qeth_ipacmd_addr_change) + extrasize);
 	queue_work(qeth_wq, &data->worker);
 }
-EXPORT_SYMBOL(qeth_bridge_host_event);
 
 /* SETBRIDGEPORT support; sending commands */
 
@@ -1683,7 +1713,7 @@ static int qeth_bridgeport_query_support
  * Sets bitmask of supported setbridgeport subfunctions in the qeth_card
  * strucutre: card->options.sbp.supported_funcs.
  */
-void qeth_bridgeport_query_support(struct qeth_card *card)
+static void qeth_bridgeport_query_support(struct qeth_card *card)
 {
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
@@ -1709,7 +1739,6 @@ void qeth_bridgeport_query_support(struc
 	}
 	card->options.sbp.supported_funcs = cbctl.data.supported;
 }
-EXPORT_SYMBOL_GPL(qeth_bridgeport_query_support);
 
 static int qeth_bridgeport_query_ports_cb(struct qeth_card *card,
 	struct qeth_reply *reply, unsigned long data)
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3593,6 +3593,13 @@ out:
 	return rc;
 }
 
+/* Returns zero if the command is successfully "consumed" */
+static int qeth_l3_control_event(struct qeth_card *card,
+					struct qeth_ipa_cmd *cmd)
+{
+	return 1;
+}
+
 struct qeth_discipline qeth_l3_discipline = {
 	.start_poll = qeth_qdio_start_poll,
 	.input_handler = (qdio_handler_t *) qeth_qdio_input_handler,
@@ -3606,6 +3613,7 @@ struct qeth_discipline qeth_l3_disciplin
 	.freeze = qeth_l3_pm_suspend,
 	.thaw = qeth_l3_pm_resume,
 	.restore = qeth_l3_pm_resume,
+	.control_event_handler = qeth_l3_control_event,
 };
 EXPORT_SYMBOL_GPL(qeth_l3_discipline);
 

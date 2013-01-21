From: frank.blaschka@de.ibm.com
Subject: [patch 3/6] [PATCH] qeth: Support VEPA mode
Date: Mon, 21 Jan 2013 13:30:20 +0100
Message-ID: <20130121123037.424824363@de.ibm.com>
References: <20130121123017.240686588@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp10.uk.ibm.com ([195.75.94.106]:50594 "EHLO
	e06smtp10.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753547Ab3AUMam (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jan 2013 07:30:42 -0500
Received: from /spool/local
	by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Mon, 21 Jan 2013 12:30:05 -0000
Content-Disposition: inline; filename=602-qeth-vepa-mode.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

The existing port isolation mode 'forward' will now verify that the adjacent
switch port supports the required reflective relay (RR) mode. This patch adds
the required error handling for the cases where enabling port isolation mode
'forward' can now fail.
Furthermore, once established, we never fall back from one of the port
isolation modes to a non-isolated mode without further user-interaction.
This includes cases where the isolation mode was enabled successfully, but
ceases to work e.g. due to configuration changes at the switch port.
Finally, configuring an isolation mode with the device being offline
will make onlining the device fail permanently upon errors encountered until
either errors are resolved or the isolation mode is changed by the user to a
different mode.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    5 +
 drivers/s390/net/qeth_core_main.c |  135 +++++++++++++++++++++++---------------
 drivers/s390/net/qeth_core_mpc.c  |    1 
 drivers/s390/net/qeth_core_mpc.h  |    5 +
 drivers/s390/net/qeth_core_sys.c  |    3 
 drivers/s390/net/qeth_l2_main.c   |   16 ++--
 drivers/s390/net/qeth_l3_main.c   |   14 +--
 7 files changed, 112 insertions(+), 67 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -678,6 +678,7 @@ struct qeth_card_options {
 	int performance_stats;
 	int rx_sg_cb;
 	enum qeth_ipa_isolation_modes isolation;
+	enum qeth_ipa_isolation_modes prev_isolation;
 	int sniffer;
 	enum qeth_cq cq;
 	char hsuid[9];
@@ -789,6 +790,7 @@ struct qeth_card {
 	struct qeth_rx rx;
 	struct delayed_work buffer_reclaim_work;
 	int reclaim_index;
+	struct work_struct close_dev_work;
 };
 
 struct qeth_card_list_struct {
@@ -925,12 +927,13 @@ void qeth_core_get_strings(struct net_de
 void qeth_core_get_drvinfo(struct net_device *, struct ethtool_drvinfo *);
 void qeth_dbf_longtext(debug_info_t *id, int level, char *text, ...);
 int qeth_core_ethtool_get_settings(struct net_device *, struct ethtool_cmd *);
-int qeth_set_access_ctrl_online(struct qeth_card *card);
+int qeth_set_access_ctrl_online(struct qeth_card *card, int fallback);
 int qeth_hdr_chk_and_bounce(struct sk_buff *, int);
 int qeth_configure_cq(struct qeth_card *, enum qeth_cq);
 int qeth_hw_trap(struct qeth_card *, enum qeth_diags_trap_action);
 int qeth_query_ipassists(struct qeth_card *, enum qeth_prot_versions prot);
 void qeth_trace_features(struct qeth_card *);
+void qeth_close_dev(struct qeth_card *);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -68,6 +68,27 @@ static void qeth_clear_output_buffer(str
 		enum qeth_qdio_buffer_states newbufstate);
 static int qeth_init_qdio_out_buf(struct qeth_qdio_out_q *, int);
 
+static struct workqueue_struct *qeth_wq;
+
+static void qeth_close_dev_handler(struct work_struct *work)
+{
+	struct qeth_card *card;
+
+	card = container_of(work, struct qeth_card, close_dev_work);
+	QETH_CARD_TEXT(card, 2, "cldevhdl");
+	rtnl_lock();
+	dev_close(card->dev);
+	rtnl_unlock();
+	ccwgroup_set_offline(card->gdev);
+}
+
+void qeth_close_dev(struct qeth_card *card)
+{
+	QETH_CARD_TEXT(card, 2, "cldevsubm");
+	queue_work(qeth_wq, &card->close_dev_work);
+}
+EXPORT_SYMBOL_GPL(qeth_close_dev);
+
 static inline const char *qeth_get_cardname(struct qeth_card *card)
 {
 	if (card->info.guestlan) {
@@ -542,11 +563,23 @@ static struct qeth_ipa_cmd *qeth_check_i
 		} else {
 			switch (cmd->hdr.command) {
 			case IPA_CMD_STOPLAN:
-				dev_warn(&card->gdev->dev,
+				if (cmd->hdr.return_code ==
+						IPA_RC_VEPA_TO_VEB_TRANSITION) {
+					dev_err(&card->gdev->dev,
+					   "Interface %s is down because the "
+					   "adjacent port is no longer in "
+					   "reflective relay mode\n",
+					   QETH_CARD_IFNAME(card));
+					qeth_close_dev(card);
+				} else {
+					dev_warn(&card->gdev->dev,
 					   "The link for interface %s on CHPID"
 					   " 0x%X failed\n",
 					   QETH_CARD_IFNAME(card),
 					   card->info.chpid);
+					qeth_issue_ipa_msg(cmd,
+						cmd->hdr.return_code, card);
+				}
 				card->lan_online = 0;
 				if (card->dev && netif_carrier_ok(card->dev))
 					netif_carrier_off(card->dev);
@@ -1416,6 +1449,7 @@ static int qeth_setup_card(struct qeth_c
 	/* init QDIO stuff */
 	qeth_init_qdio_info(card);
 	INIT_DELAYED_WORK(&card->buffer_reclaim_work, qeth_buffer_reclaim_work);
+	INIT_WORK(&card->close_dev_work, qeth_close_dev_handler);
 	return 0;
 }
 
@@ -4057,6 +4091,7 @@ static int qeth_setadpparms_set_access_c
 {
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_set_access_ctrl *access_ctrl_req;
+	int fallback = *(int *)reply->param;
 
 	QETH_CARD_TEXT(card, 4, "setaccb");
 
@@ -4066,12 +4101,14 @@ static int qeth_setadpparms_set_access_c
 	QETH_DBF_TEXT_(SETUP, 2, "%s", card->gdev->dev.kobj.name);
 	QETH_DBF_TEXT_(SETUP, 2, "rc=%d",
 		cmd->data.setadapterparms.hdr.return_code);
+	if (cmd->data.setadapterparms.hdr.return_code !=
+						SET_ACCESS_CTRL_RC_SUCCESS)
+		QETH_DBF_MESSAGE(3, "ERR:SET_ACCESS_CTRL(%s,%d)==%d\n",
+				card->gdev->dev.kobj.name,
+				access_ctrl_req->subcmd_code,
+				cmd->data.setadapterparms.hdr.return_code);
 	switch (cmd->data.setadapterparms.hdr.return_code) {
 	case SET_ACCESS_CTRL_RC_SUCCESS:
-	case SET_ACCESS_CTRL_RC_ALREADY_NOT_ISOLATED:
-	case SET_ACCESS_CTRL_RC_ALREADY_ISOLATED:
-	{
-		card->options.isolation = access_ctrl_req->subcmd_code;
 		if (card->options.isolation == ISOLATION_MODE_NONE) {
 			dev_info(&card->gdev->dev,
 			    "QDIO data connection isolation is deactivated\n");
@@ -4079,72 +4116,64 @@ static int qeth_setadpparms_set_access_c
 			dev_info(&card->gdev->dev,
 			    "QDIO data connection isolation is activated\n");
 		}
-		QETH_DBF_MESSAGE(3, "OK:SET_ACCESS_CTRL(%s, %d)==%d\n",
-			card->gdev->dev.kobj.name,
-			access_ctrl_req->subcmd_code,
-			cmd->data.setadapterparms.hdr.return_code);
 		break;
-	}
+	case SET_ACCESS_CTRL_RC_ALREADY_NOT_ISOLATED:
+		QETH_DBF_MESSAGE(2, "%s QDIO data connection isolation already "
+				"deactivated\n", dev_name(&card->gdev->dev));
+		if (fallback)
+			card->options.isolation = card->options.prev_isolation;
+		break;
+	case SET_ACCESS_CTRL_RC_ALREADY_ISOLATED:
+		QETH_DBF_MESSAGE(2, "%s QDIO data connection isolation already"
+				" activated\n", dev_name(&card->gdev->dev));
+		if (fallback)
+			card->options.isolation = card->options.prev_isolation;
+		break;
 	case SET_ACCESS_CTRL_RC_NOT_SUPPORTED:
-	{
-		QETH_DBF_MESSAGE(3, "ERR:SET_ACCESS_CTRL(%s,%d)==%d\n",
-			card->gdev->dev.kobj.name,
-			access_ctrl_req->subcmd_code,
-			cmd->data.setadapterparms.hdr.return_code);
 		dev_err(&card->gdev->dev, "Adapter does not "
 			"support QDIO data connection isolation\n");
-
-		/* ensure isolation mode is "none" */
-		card->options.isolation = ISOLATION_MODE_NONE;
 		break;
-	}
 	case SET_ACCESS_CTRL_RC_NONE_SHARED_ADAPTER:
-	{
-		QETH_DBF_MESSAGE(3, "ERR:SET_ACCESS_MODE(%s,%d)==%d\n",
-			card->gdev->dev.kobj.name,
-			access_ctrl_req->subcmd_code,
-			cmd->data.setadapterparms.hdr.return_code);
 		dev_err(&card->gdev->dev,
 			"Adapter is dedicated. "
 			"QDIO data connection isolation not supported\n");
-
-		/* ensure isolation mode is "none" */
-		card->options.isolation = ISOLATION_MODE_NONE;
+		if (fallback)
+			card->options.isolation = card->options.prev_isolation;
 		break;
-	}
 	case SET_ACCESS_CTRL_RC_ACTIVE_CHECKSUM_OFF:
-	{
-		QETH_DBF_MESSAGE(3, "ERR:SET_ACCESS_MODE(%s,%d)==%d\n",
-			card->gdev->dev.kobj.name,
-			access_ctrl_req->subcmd_code,
-			cmd->data.setadapterparms.hdr.return_code);
 		dev_err(&card->gdev->dev,
 			"TSO does not permit QDIO data connection isolation\n");
-
-		/* ensure isolation mode is "none" */
-		card->options.isolation = ISOLATION_MODE_NONE;
+		if (fallback)
+			card->options.isolation = card->options.prev_isolation;
+		break;
+	case SET_ACCESS_CTRL_RC_REFLREL_UNSUPPORTED:
+		dev_err(&card->gdev->dev, "The adjacent switch port does not "
+			"support reflective relay mode\n");
+		if (fallback)
+			card->options.isolation = card->options.prev_isolation;
+		break;
+	case SET_ACCESS_CTRL_RC_REFLREL_FAILED:
+		dev_err(&card->gdev->dev, "The reflective relay mode cannot be "
+					"enabled at the adjacent switch port");
+		if (fallback)
+			card->options.isolation = card->options.prev_isolation;
+		break;
+	case SET_ACCESS_CTRL_RC_REFLREL_DEACT_FAILED:
+		dev_warn(&card->gdev->dev, "Turning off reflective relay mode "
+					"at the adjacent switch failed\n");
 		break;
-	}
 	default:
-	{
 		/* this should never happen */
-		QETH_DBF_MESSAGE(3, "ERR:SET_ACCESS_MODE(%s,%d)==%d"
-			"==UNKNOWN\n",
-			card->gdev->dev.kobj.name,
-			access_ctrl_req->subcmd_code,
-			cmd->data.setadapterparms.hdr.return_code);
-
-		/* ensure isolation mode is "none" */
-		card->options.isolation = ISOLATION_MODE_NONE;
+		if (fallback)
+			card->options.isolation = card->options.prev_isolation;
 		break;
 	}
-	}
 	qeth_default_setadapterparms_cb(card, reply, (unsigned long) cmd);
 	return 0;
 }
 
 static int qeth_setadpparms_set_access_ctrl(struct qeth_card *card,
-		enum qeth_ipa_isolation_modes isolation)
+		enum qeth_ipa_isolation_modes isolation, int fallback)
 {
 	int rc;
 	struct qeth_cmd_buffer *iob;
@@ -4164,12 +4193,12 @@ static int qeth_setadpparms_set_access_c
 	access_ctrl_req->subcmd_code = isolation;
 
 	rc = qeth_send_ipa_cmd(card, iob, qeth_setadpparms_set_access_ctrl_cb,
-			       NULL);
+			       &fallback);
 	QETH_DBF_TEXT_(SETUP, 2, "rc=%d", rc);
 	return rc;
 }
 
-int qeth_set_access_ctrl_online(struct qeth_card *card)
+int qeth_set_access_ctrl_online(struct qeth_card *card, int fallback)
 {
 	int rc = 0;
 
@@ -4179,12 +4208,13 @@ int qeth_set_access_ctrl_online(struct q
 	     card->info.type == QETH_CARD_TYPE_OSX) &&
 	     qeth_adp_supported(card, IPA_SETADP_SET_ACCESS_CONTROL)) {
 		rc = qeth_setadpparms_set_access_ctrl(card,
-			card->options.isolation);
+			card->options.isolation, fallback);
 		if (rc) {
 			QETH_DBF_MESSAGE(3,
 				"IPA(SET_ACCESS_CTRL,%s,%d) sent failed\n",
 				card->gdev->dev.kobj.name,
 				rc);
+			rc = -EOPNOTSUPP;
 		}
 	} else if (card->options.isolation != ISOLATION_MODE_NONE) {
 		card->options.isolation = ISOLATION_MODE_NONE;
@@ -5552,6 +5582,8 @@ static int __init qeth_core_init(void)
 	rwlock_init(&qeth_core_card_list.rwlock);
 	mutex_init(&qeth_mod_mutex);
 
+	qeth_wq = create_singlethread_workqueue("qeth_wq");
+
 	rc = qeth_register_dbf_views();
 	if (rc)
 		goto out_err;
@@ -5598,6 +5630,7 @@ out_err:
 
 static void __exit qeth_core_exit(void)
 {
+	destroy_workqueue(qeth_wq);
 	ccwgroup_driver_unregister(&qeth_core_ccwgroup_driver);
 	ccw_driver_unregister(&qeth_ccw_driver);
 	kmem_cache_destroy(qeth_qdio_outbuf_cache);
--- a/drivers/s390/net/qeth_core_mpc.c
+++ b/drivers/s390/net/qeth_core_mpc.c
@@ -204,6 +204,7 @@ static struct ipa_rc_msg qeth_ipa_rc_msg
 	{IPA_RC_INVALID_SETRTG_INDICATOR, "Invalid SETRTG indicator"},
 	{IPA_RC_MC_ADDR_ALREADY_DEFINED, "Multicast address already defined"},
 	{IPA_RC_LAN_OFFLINE,		"STRTLAN_LAN_DISABLED - LAN offline"},
+	{IPA_RC_VEPA_TO_VEB_TRANSITION,	"Adj. switch disabled port mode RR"},
 	{IPA_RC_INVALID_IP_VERSION2,	"Invalid IP version"},
 	{IPA_RC_ENOMEM,			"Memory problem"},
 	{IPA_RC_FFFF,			"Unknown Error"}
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -177,6 +177,7 @@ enum qeth_ipa_return_codes {
 	IPA_RC_INVALID_SETRTG_INDICATOR	= 0xe012,
 	IPA_RC_MC_ADDR_ALREADY_DEFINED	= 0xe013,
 	IPA_RC_LAN_OFFLINE		= 0xe080,
+	IPA_RC_VEPA_TO_VEB_TRANSITION	= 0xe090,
 	IPA_RC_INVALID_IP_VERSION2	= 0xf001,
 	IPA_RC_ENOMEM			= 0xfffe,
 	IPA_RC_FFFF			= 0xffff
@@ -269,6 +270,9 @@ enum qeth_ipa_set_access_mode_rc {
 	SET_ACCESS_CTRL_RC_ALREADY_ISOLATED	= 0x0010,
 	SET_ACCESS_CTRL_RC_NONE_SHARED_ADAPTER	= 0x0014,
 	SET_ACCESS_CTRL_RC_ACTIVE_CHECKSUM_OFF	= 0x0018,
+	SET_ACCESS_CTRL_RC_REFLREL_UNSUPPORTED	= 0x0022,
+	SET_ACCESS_CTRL_RC_REFLREL_FAILED	= 0x0024,
+	SET_ACCESS_CTRL_RC_REFLREL_DEACT_FAILED	= 0x0028,
 };
 
 
@@ -386,6 +390,7 @@ struct qeth_snmp_ureq {
 /* SET_ACCESS_CONTROL: same format for request and reply */
 struct qeth_set_access_ctrl {
 	__u32 subcmd_code;
+	__u8 reserved[8];
 } __attribute__((packed));
 
 struct qeth_query_oat {
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -513,10 +513,11 @@ static ssize_t qeth_dev_isolation_store(
 	rc = count;
 
 	/* defer IP assist if device is offline (until discipline->set_online)*/
+	card->options.prev_isolation = card->options.isolation;
 	card->options.isolation = isolation;
 	if (card->state == CARD_STATE_SOFTSETUP ||
 	    card->state == CARD_STATE_UP) {
-		int ipa_rc = qeth_set_access_ctrl_online(card);
+		int ipa_rc = qeth_set_access_ctrl_online(card, 1);
 		if (ipa_rc != 0)
 			rc = ipa_rc;
 	}
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1025,9 +1025,14 @@ static int __qeth_l2_set_online(struct c
 
 contin:
 	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
-	    (card->info.type == QETH_CARD_TYPE_OSX))
+	    (card->info.type == QETH_CARD_TYPE_OSX)) {
 		/* configure isolation level */
-		qeth_set_access_ctrl_online(card);
+		rc = qeth_set_access_ctrl_online(card, 0);
+		if (rc) {
+			rc = -ENODEV;
+			goto out_remove;
+		}
+	}
 
 	if (card->info.type != QETH_CARD_TYPE_OSN &&
 	    card->info.type != QETH_CARD_TYPE_OSM)
@@ -1144,12 +1149,9 @@ static int qeth_l2_recover(void *ptr)
 		dev_info(&card->gdev->dev,
 			"Device successfully recovered!\n");
 	else {
-		if (rtnl_trylock()) {
-			dev_close(card->dev);
-			rtnl_unlock();
-			dev_warn(&card->gdev->dev, "The qeth device driver "
+		qeth_close_dev(card);
+		dev_warn(&card->gdev->dev, "The qeth device driver "
 				"failed to recover an error on the device\n");
-		}
 	}
 	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
 	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1449,7 +1449,8 @@ static int qeth_l3_start_ipassists(struc
 {
 	QETH_CARD_TEXT(card, 3, "strtipas");
 
-	qeth_set_access_ctrl_online(card);	/* go on*/
+	if (qeth_set_access_ctrl_online(card, 0))
+		return -EIO;
 	qeth_l3_start_ipa_arp_processing(card);	/* go on*/
 	qeth_l3_start_ipa_ip_fragmentation(card);	/* go on*/
 	qeth_l3_start_ipa_source_mac(card);	/* go on*/
@@ -3388,8 +3389,10 @@ contin:
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
 	if (!card->options.sniffer) {
 		rc = qeth_l3_start_ipassists(card);
-		if (rc)
+		if (rc) {
 			QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
+			goto out_remove;
+		}
 		rc = qeth_l3_setrouting_v4(card);
 		if (rc)
 			QETH_DBF_TEXT_(SETUP, 2, "4err%d", rc);
@@ -3511,12 +3514,9 @@ static int qeth_l3_recover(void *ptr)
 		dev_info(&card->gdev->dev,
 			"Device successfully recovered!\n");
 	else {
-		if (rtnl_trylock()) {
-			dev_close(card->dev);
-			rtnl_unlock();
-			dev_warn(&card->gdev->dev, "The qeth device driver "
+		qeth_close_dev(card);
+		dev_warn(&card->gdev->dev, "The qeth device driver "
 				"failed to recover an error on the device\n");
-		}
 	}
 	qeth_clear_thread_start_bit(card, QETH_RECOVER_THREAD);
 	qeth_clear_thread_running_bit(card, QETH_RECOVER_THREAD);

From: frank.blaschka@de.ibm.com
Subject: [patch 2/2] [PATCH] qeth: support the new OSA CHPID types OSX and OSM
Date: Mon, 17 May 2010 09:15:14 +0200
Message-ID: <20100517071552.254870000@de.ibm.com>
References: <20100517071512.118564000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.de.ibm.com ([195.212.17.163]:44077 "EHLO
	mtagate3.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752163Ab0EQHPz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 May 2010 03:15:55 -0400
Content-Disposition: inline; filename=611-qeth-osx-osm.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

The qeth driver is enabled to support the new OSA CHPID types OSX
and OSM.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core.h      |   28 ++--
 drivers/s390/net/qeth_core_main.c |  224 ++++++++++++++++++++++++--------------
 drivers/s390/net/qeth_core_mpc.h  |   10 +
 drivers/s390/net/qeth_core_sys.c  |    3 
 drivers/s390/net/qeth_l2_main.c   |   34 ++++-
 drivers/s390/net/qeth_l3_main.c   |    6 -
 6 files changed, 194 insertions(+), 111 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -179,25 +179,23 @@ static inline int qeth_is_ipa_enabled(st
 	 ((prot == QETH_PROT_IPV6) ? \
 		qeth_is_enabled6(c, f) : qeth_is_enabled(c, f))
 
-#define QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT 0x0101
-#define QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT 0x0101
+#define QETH_IDX_FUNC_LEVEL_OSD		 0x0101
 #define QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT 0x4108
 #define QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT 0x5108
 
 #define QETH_MODELLIST_ARRAY \
-	{{0x1731, 0x01, 0x1732, 0x01, QETH_CARD_TYPE_OSAE, 1, \
-	QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT, \
-	QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT, \
-	QETH_MAX_QUEUES, 0}, \
-	{0x1731, 0x05, 0x1732, 0x05, QETH_CARD_TYPE_IQD, 0, \
-	QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT, \
-	QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT, \
-	QETH_MAX_QUEUES, 0x103}, \
-	{0x1731, 0x06, 0x1732, 0x06, QETH_CARD_TYPE_OSN, 0, \
-	QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT, \
-	QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT, \
-	QETH_MAX_QUEUES, 0}, \
-	{0, 0, 0, 0, 0, 0, 0, 0, 0} }
+	{{0x1731, 0x01, 0x1732, QETH_CARD_TYPE_OSD, QETH_MAX_QUEUES, 0}, \
+	 {0x1731, 0x05, 0x1732, QETH_CARD_TYPE_IQD, QETH_MAX_QUEUES, 0x103}, \
+	 {0x1731, 0x06, 0x1732, QETH_CARD_TYPE_OSN, QETH_MAX_QUEUES, 0}, \
+	 {0x1731, 0x02, 0x1732, QETH_CARD_TYPE_OSM, QETH_MAX_QUEUES, 0}, \
+	 {0x1731, 0x02, 0x1732, QETH_CARD_TYPE_OSX, QETH_MAX_QUEUES, 0}, \
+	 {0, 0, 0, 0, 0, 0} }
+#define QETH_CU_TYPE_IND	0
+#define QETH_CU_MODEL_IND	1
+#define QETH_DEV_TYPE_IND	2
+#define QETH_DEV_MODEL_IND	3
+#define QETH_QUEUE_NO_IND	4
+#define QETH_MULTICAST_IND	5
 
 #define QETH_REAL_CARD		1
 #define QETH_VLAN_CARD		2
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -53,7 +53,7 @@ struct kmem_cache *qeth_core_header_cach
 EXPORT_SYMBOL_GPL(qeth_core_header_cache);
 
 static struct device *qeth_core_root_dev;
-static unsigned int known_devices[][10] = QETH_MODELLIST_ARRAY;
+static unsigned int known_devices[][6] = QETH_MODELLIST_ARRAY;
 static struct lock_class_key qdio_out_skb_queue_key;
 
 static void qeth_send_control_data_cb(struct qeth_channel *,
@@ -111,21 +111,29 @@ static inline const char *qeth_get_cardn
 {
 	if (card->info.guestlan) {
 		switch (card->info.type) {
-		case QETH_CARD_TYPE_OSAE:
+		case QETH_CARD_TYPE_OSD:
 			return " Guest LAN QDIO";
 		case QETH_CARD_TYPE_IQD:
 			return " Guest LAN Hiper";
+		case QETH_CARD_TYPE_OSM:
+			return " Guest LAN QDIO - OSM";
+		case QETH_CARD_TYPE_OSX:
+			return " Guest LAN QDIO - OSX";
 		default:
 			return " unknown";
 		}
 	} else {
 		switch (card->info.type) {
-		case QETH_CARD_TYPE_OSAE:
+		case QETH_CARD_TYPE_OSD:
 			return " OSD Express";
 		case QETH_CARD_TYPE_IQD:
 			return " HiperSockets";
 		case QETH_CARD_TYPE_OSN:
 			return " OSN QDIO";
+		case QETH_CARD_TYPE_OSM:
+			return " OSM QDIO";
+		case QETH_CARD_TYPE_OSX:
+			return " OSX QDIO";
 		default:
 			return " unknown";
 		}
@@ -138,16 +146,20 @@ const char *qeth_get_cardname_short(stru
 {
 	if (card->info.guestlan) {
 		switch (card->info.type) {
-		case QETH_CARD_TYPE_OSAE:
+		case QETH_CARD_TYPE_OSD:
 			return "GuestLAN QDIO";
 		case QETH_CARD_TYPE_IQD:
 			return "GuestLAN Hiper";
+		case QETH_CARD_TYPE_OSM:
+			return "GuestLAN OSM";
+		case QETH_CARD_TYPE_OSX:
+			return "GuestLAN OSX";
 		default:
 			return "unknown";
 		}
 	} else {
 		switch (card->info.type) {
-		case QETH_CARD_TYPE_OSAE:
+		case QETH_CARD_TYPE_OSD:
 			switch (card->info.link_type) {
 			case QETH_LINK_TYPE_FAST_ETH:
 				return "OSD_100";
@@ -172,6 +184,10 @@ const char *qeth_get_cardname_short(stru
 			return "HiperSockets";
 		case QETH_CARD_TYPE_OSN:
 			return "OSN";
+		case QETH_CARD_TYPE_OSM:
+			return "OSM_1000";
+		case QETH_CARD_TYPE_OSX:
+			return "OSX_10GIG";
 		default:
 			return "unknown";
 		}
@@ -419,7 +435,8 @@ void qeth_clear_ipacmd_list(struct qeth_
 }
 EXPORT_SYMBOL_GPL(qeth_clear_ipacmd_list);
 
-static int qeth_check_idx_response(unsigned char *buffer)
+static int qeth_check_idx_response(struct qeth_card *card,
+	unsigned char *buffer)
 {
 	if (!buffer)
 		return 0;
@@ -434,6 +451,12 @@ static int qeth_check_idx_response(unsig
 		QETH_DBF_TEXT(TRACE, 2, "ckidxres");
 		QETH_DBF_TEXT(TRACE, 2, " idxterm");
 		QETH_DBF_TEXT_(TRACE, 2, "  rc%d", -EIO);
+		if (buffer[4] == 0xf6) {
+			dev_err(&card->gdev->dev,
+			"The qeth device is not configured "
+			"for the OSI layer required by z/VM\n");
+			return -EPERM;
+		}
 		return -EIO;
 	}
 	return 0;
@@ -528,18 +551,19 @@ static void qeth_send_control_data_cb(st
 	struct qeth_ipa_cmd *cmd;
 	unsigned long flags;
 	int keep_reply;
+	int rc = 0;
 
 	QETH_DBF_TEXT(TRACE, 4, "sndctlcb");
 
 	card = CARD_FROM_CDEV(channel->ccwdev);
-	if (qeth_check_idx_response(iob->data)) {
+	rc = qeth_check_idx_response(card, iob->data);
+	switch (rc) {
+	case 0:
+		break;
+	case -EIO:
 		qeth_clear_ipacmd_list(card);
-		if (((iob->data[2] & 0xc0) == 0xc0) && iob->data[4] == 0xf6)
-			dev_err(&card->gdev->dev,
-				"The qeth device is not configured "
-				"for the OSI layer required by z/VM\n");
-		else
-			qeth_schedule_recovery(card);
+		qeth_schedule_recovery(card);
+	default:
 		goto out;
 	}
 
@@ -719,7 +743,7 @@ static int qeth_get_problem(struct ccw_d
 		QETH_DBF_TEXT(TRACE, 2, "CGENCHK");
 		dev_warn(&cdev->dev, "The qeth device driver "
 			"failed to recover an error on the device\n");
-		QETH_DBF_MESSAGE(2, "%s check on device dstat=x%x, cstat=x%x ",
+		QETH_DBF_MESSAGE(2, "%s check on device dstat=x%x, cstat=x%x\n",
 			dev_name(&cdev->dev), dstat, cstat);
 		print_hex_dump(KERN_WARNING, "qeth: irb ", DUMP_PREFIX_OFFSET,
 				16, 1, irb, 64, 1);
@@ -998,9 +1022,8 @@ static void qeth_clean_channel(struct qe
 		kfree(channel->iob[cnt].data);
 }
 
-static int qeth_is_1920_device(struct qeth_card *card)
+static void qeth_get_channel_path_desc(struct qeth_card *card)
 {
-	int single_queue = 0;
 	struct ccw_device *ccwdev;
 	struct channelPath_dsc {
 		u8 flags;
@@ -1013,17 +1036,25 @@ static int qeth_is_1920_device(struct qe
 		u8 chpp;
 	} *chp_dsc;
 
-	QETH_DBF_TEXT(SETUP, 2, "chk_1920");
+	QETH_DBF_TEXT(SETUP, 2, "chp_desc");
 
 	ccwdev = card->data.ccwdev;
 	chp_dsc = (struct channelPath_dsc *)ccw_device_get_chp_desc(ccwdev, 0);
 	if (chp_dsc != NULL) {
 		/* CHPP field bit 6 == 1 -> single queue */
-		single_queue = ((chp_dsc->chpp & 0x02) == 0x02);
+		if ((chp_dsc->chpp & 0x02) == 0x02)
+			card->qdio.no_out_queues = 1;
+		card->info.func_level = 0x4100 + chp_dsc->desc;
 		kfree(chp_dsc);
 	}
-	QETH_DBF_TEXT_(SETUP, 2, "rc:%x", single_queue);
-	return single_queue;
+	if (card->qdio.no_out_queues == 1) {
+		card->qdio.default_out_queue = 0;
+		dev_info(&card->gdev->dev,
+			"Priority Queueing not supported\n");
+	}
+	QETH_DBF_TEXT_(SETUP, 2, "nr:%x", card->qdio.no_out_queues);
+	QETH_DBF_TEXT_(SETUP, 2, "lvl:%02x", card->info.func_level);
+	return;
 }
 
 static void qeth_init_qdio_info(struct qeth_card *card)
@@ -1171,18 +1202,17 @@ static int qeth_determine_card_type(stru
 
 	card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
 	card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
-	while (known_devices[i][4]) {
-		if ((CARD_RDEV(card)->id.dev_type == known_devices[i][2]) &&
-		    (CARD_RDEV(card)->id.dev_model == known_devices[i][3])) {
-			card->info.type = known_devices[i][4];
-			card->qdio.no_out_queues = known_devices[i][8];
-			card->info.is_multicast_different = known_devices[i][9];
-			if (qeth_is_1920_device(card)) {
-				dev_info(&card->gdev->dev,
-					"Priority Queueing not supported\n");
-				card->qdio.no_out_queues = 1;
-				card->qdio.default_out_queue = 0;
-			}
+	while (known_devices[i][QETH_DEV_MODEL_IND]) {
+		if ((CARD_RDEV(card)->id.dev_type ==
+				known_devices[i][QETH_DEV_TYPE_IND]) &&
+		    (CARD_RDEV(card)->id.dev_model ==
+				known_devices[i][QETH_DEV_MODEL_IND])) {
+			card->info.type = known_devices[i][QETH_DEV_MODEL_IND];
+			card->qdio.no_out_queues =
+				known_devices[i][QETH_QUEUE_NO_IND];
+			card->info.is_multicast_different =
+				known_devices[i][QETH_MULTICAST_IND];
+			qeth_get_channel_path_desc(card);
 			return 0;
 		}
 		i++;
@@ -1399,22 +1429,20 @@ static void qeth_init_tokens(struct qeth
 
 static void qeth_init_func_level(struct qeth_card *card)
 {
-	if (card->ipato.enabled) {
-		if (card->info.type == QETH_CARD_TYPE_IQD)
-				card->info.func_level =
-					QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT;
-		else
-				card->info.func_level =
-					QETH_IDX_FUNC_LEVEL_OSAE_ENA_IPAT;
-	} else {
-		if (card->info.type == QETH_CARD_TYPE_IQD)
-		/*FIXME:why do we have same values for  dis and ena for
-		  osae??? */
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_IQD:
+		if (card->ipato.enabled)
 			card->info.func_level =
-				QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT;
+				QETH_IDX_FUNC_LEVEL_IQD_ENA_IPAT;
 		else
 			card->info.func_level =
-				QETH_IDX_FUNC_LEVEL_OSAE_DIS_IPAT;
+				QETH_IDX_FUNC_LEVEL_IQD_DIS_IPAT;
+		break;
+	case QETH_CARD_TYPE_OSD:
+		card->info.func_level = QETH_IDX_FUNC_LEVEL_OSD;
+		break;
+	default:
+		break;
 	}
 }
 
@@ -1561,7 +1589,7 @@ static void qeth_idx_write_cb(struct qet
 	card = CARD_FROM_CDEV(channel->ccwdev);
 
 	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
-		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == QETH_IDX_ACT_ERR_EXCL)
 			dev_err(&card->write.ccwdev->dev,
 				"The adapter is used exclusively by another "
 				"host\n");
@@ -1597,27 +1625,35 @@ static void qeth_idx_read_cb(struct qeth
 	}
 
 	card = CARD_FROM_CDEV(channel->ccwdev);
-	if (qeth_check_idx_response(iob->data))
+	if (qeth_check_idx_response(card, iob->data))
 			goto out;
 
 	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
-		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+		switch (QETH_IDX_ACT_CAUSE_CODE(iob->data)) {
+		case QETH_IDX_ACT_ERR_EXCL:
 			dev_err(&card->write.ccwdev->dev,
 				"The adapter is used exclusively by another "
 				"host\n");
-		else
+			break;
+		case QETH_IDX_ACT_ERR_AUTH:
+			dev_err(&card->read.ccwdev->dev,
+				"Setting the device online failed because of "
+				"insufficient LPAR authorization\n");
+			break;
+		default:
 			QETH_DBF_MESSAGE(2, "%s IDX_ACTIVATE on read channel:"
 				" negative reply\n",
 				dev_name(&card->read.ccwdev->dev));
+		}
 		goto out;
 	}
 
 /**
- * temporary fix for microcode bug
- * to revert it,replace OR by AND
- */
+ *  * temporary fix for microcode bug
+ *   * to revert it,replace OR by AND
+ *    */
 	if ((!QETH_IDX_NO_PORTNAME_REQUIRED(iob->data)) ||
-	     (card->info.type == QETH_CARD_TYPE_OSAE))
+	     (card->info.type == QETH_CARD_TYPE_OSD))
 		card->info.portname_required = 1;
 
 	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
@@ -1826,7 +1862,7 @@ static inline int qeth_get_initial_mtu_f
 		return 1500;
 	case QETH_CARD_TYPE_IQD:
 		return card->info.max_mtu;
-	case QETH_CARD_TYPE_OSAE:
+	case QETH_CARD_TYPE_OSD:
 		switch (card->info.link_type) {
 		case QETH_LINK_TYPE_HSTR:
 		case QETH_LINK_TYPE_LANE_TR:
@@ -1834,6 +1870,9 @@ static inline int qeth_get_initial_mtu_f
 		default:
 			return 1492;
 		}
+	case QETH_CARD_TYPE_OSM:
+	case QETH_CARD_TYPE_OSX:
+		return 1492;
 	default:
 		return 1500;
 	}
@@ -1844,8 +1883,10 @@ static inline int qeth_get_max_mtu_for_c
 	switch (cardtype) {
 
 	case QETH_CARD_TYPE_UNKNOWN:
-	case QETH_CARD_TYPE_OSAE:
+	case QETH_CARD_TYPE_OSD:
 	case QETH_CARD_TYPE_OSN:
+	case QETH_CARD_TYPE_OSM:
+	case QETH_CARD_TYPE_OSX:
 		return 61440;
 	case QETH_CARD_TYPE_IQD:
 		return 57344;
@@ -1883,7 +1924,9 @@ static inline int qeth_get_mtu_outof_fra
 static inline int qeth_mtu_is_valid(struct qeth_card *card, int mtu)
 {
 	switch (card->info.type) {
-	case QETH_CARD_TYPE_OSAE:
+	case QETH_CARD_TYPE_OSD:
+	case QETH_CARD_TYPE_OSM:
+	case QETH_CARD_TYPE_OSX:
 		return ((mtu >= 576) && (mtu <= 61440));
 	case QETH_CARD_TYPE_IQD:
 		return ((mtu >= 576) &&
@@ -1934,6 +1977,7 @@ static int qeth_ulp_enable_cb(struct qet
 		card->info.link_type = link_type;
 	} else
 		card->info.link_type = 0;
+	QETH_DBF_TEXT_(SETUP, 2, "link%d", link_type);
 	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 	return 0;
 }
@@ -2246,7 +2290,9 @@ static void qeth_print_status_no_portnam
 void qeth_print_status_message(struct qeth_card *card)
 {
 	switch (card->info.type) {
-	case QETH_CARD_TYPE_OSAE:
+	case QETH_CARD_TYPE_OSD:
+	case QETH_CARD_TYPE_OSM:
+	case QETH_CARD_TYPE_OSX:
 		/* VM will use a non-zero first character
 		 * to indicate a HiperSockets like reporting
 		 * of the level OSA sets the first character to zero
@@ -2553,9 +2599,11 @@ static int qeth_query_setadapterparms_cb
 	QETH_DBF_TEXT(TRACE, 3, "quyadpcb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
-	if (cmd->data.setadapterparms.data.query_cmds_supp.lan_type & 0x7f)
+	if (cmd->data.setadapterparms.data.query_cmds_supp.lan_type & 0x7f) {
 		card->info.link_type =
 		      cmd->data.setadapterparms.data.query_cmds_supp.lan_type;
+		QETH_DBF_TEXT_(SETUP, 2, "lnk %d", card->info.link_type);
+	}
 	card->options.adp.supported_funcs =
 		cmd->data.setadapterparms.data.query_cmds_supp.supported_cmds;
 	return qeth_default_setadapterparms_cb(card, reply, (unsigned long)cmd);
@@ -2945,7 +2993,8 @@ EXPORT_SYMBOL_GPL(qeth_qdio_output_handl
 int qeth_get_priority_queue(struct qeth_card *card, struct sk_buff *skb,
 			int ipv, int cast_type)
 {
-	if (!ipv && (card->info.type == QETH_CARD_TYPE_OSAE))
+	if (!ipv && (card->info.type == QETH_CARD_TYPE_OSD ||
+		     card->info.type == QETH_CARD_TYPE_OSX))
 		return card->qdio.default_out_queue;
 	switch (card->qdio.no_out_queues) {
 	case 4:
@@ -3507,13 +3556,14 @@ int qeth_set_access_ctrl_online(struct q
 
 	QETH_DBF_TEXT(TRACE, 4, "setactlo");
 
-	if (card->info.type == QETH_CARD_TYPE_OSAE &&
-	    qeth_adp_supported(card, IPA_SETADP_SET_ACCESS_CONTROL)) {
+	if ((card->info.type == QETH_CARD_TYPE_OSD ||
+	     card->info.type == QETH_CARD_TYPE_OSX) &&
+	     qeth_adp_supported(card, IPA_SETADP_SET_ACCESS_CONTROL)) {
 		rc = qeth_setadpparms_set_access_ctrl(card,
 			card->options.isolation);
 		if (rc) {
 			QETH_DBF_MESSAGE(3,
-				"IPA(SET_ACCESS_CTRL,%s,%d) sent failed",
+				"IPA(SET_ACCESS_CTRL,%s,%d) sent failed\n",
 				card->gdev->dev.kobj.name,
 				rc);
 		}
@@ -3845,9 +3895,16 @@ static void qeth_core_free_card(struct q
 }
 
 static struct ccw_device_id qeth_ids[] = {
-	{CCW_DEVICE(0x1731, 0x01), .driver_info = QETH_CARD_TYPE_OSAE},
-	{CCW_DEVICE(0x1731, 0x05), .driver_info = QETH_CARD_TYPE_IQD},
-	{CCW_DEVICE(0x1731, 0x06), .driver_info = QETH_CARD_TYPE_OSN},
+	{CCW_DEVICE_DEVTYPE(0x1731, 0x01, 0x1732, 0x01),
+					.driver_info = QETH_CARD_TYPE_OSD},
+	{CCW_DEVICE_DEVTYPE(0x1731, 0x05, 0x1732, 0x05),
+					.driver_info = QETH_CARD_TYPE_IQD},
+	{CCW_DEVICE_DEVTYPE(0x1731, 0x06, 0x1732, 0x06),
+					.driver_info = QETH_CARD_TYPE_OSN},
+	{CCW_DEVICE_DEVTYPE(0x1731, 0x02, 0x1732, 0x03),
+					.driver_info = QETH_CARD_TYPE_OSM},
+	{CCW_DEVICE_DEVTYPE(0x1731, 0x02, 0x1732, 0x02),
+					.driver_info = QETH_CARD_TYPE_OSX},
 	{},
 };
 MODULE_DEVICE_TABLE(ccw, qeth_ids);
@@ -4251,25 +4308,25 @@ static int qeth_core_probe_device(struct
 		goto err_card;
 	}
 
-	if (card->info.type == QETH_CARD_TYPE_OSN) {
+	if (card->info.type == QETH_CARD_TYPE_OSN)
 		rc = qeth_core_create_osn_attributes(dev);
-		if (rc)
-			goto err_card;
+	else
+		rc = qeth_core_create_device_attributes(dev);
+	if (rc)
+		goto err_card;
+	switch (card->info.type) {
+	case QETH_CARD_TYPE_OSN:
+	case QETH_CARD_TYPE_OSM:
 		rc = qeth_core_load_discipline(card, QETH_DISCIPLINE_LAYER2);
-		if (rc) {
-			qeth_core_remove_osn_attributes(dev);
-			goto err_card;
-		}
+		if (rc)
+			goto err_attr;
 		rc = card->discipline.ccwgdriver->probe(card->gdev);
-		if (rc) {
-			qeth_core_free_discipline(card);
-			qeth_core_remove_osn_attributes(dev);
-			goto err_card;
-		}
-	} else {
-		rc = qeth_core_create_device_attributes(dev);
 		if (rc)
-			goto err_card;
+			goto err_disc;
+	case QETH_CARD_TYPE_OSD:
+	case QETH_CARD_TYPE_OSX:
+	default:
+		break;
 	}
 
 	write_lock_irqsave(&qeth_core_card_list.rwlock, flags);
@@ -4279,6 +4336,13 @@ static int qeth_core_probe_device(struct
 	qeth_determine_capabilities(card);
 	return 0;
 
+err_disc:
+	qeth_core_free_discipline(card);
+err_attr:
+	if (card->info.type == QETH_CARD_TYPE_OSN)
+		qeth_core_remove_osn_attributes(dev);
+	else
+		qeth_core_remove_device_attributes(dev);
 err_card:
 	qeth_core_free_card(card);
 err_dev:
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -48,9 +48,11 @@ extern unsigned char IPA_PDU_HEADER[];
 
 enum qeth_card_types {
 	QETH_CARD_TYPE_UNKNOWN = 0,
-	QETH_CARD_TYPE_OSAE    = 10,
-	QETH_CARD_TYPE_IQD     = 1234,
-	QETH_CARD_TYPE_OSN     = 11,
+	QETH_CARD_TYPE_OSD     = 1,
+	QETH_CARD_TYPE_IQD     = 5,
+	QETH_CARD_TYPE_OSN     = 6,
+	QETH_CARD_TYPE_OSM     = 3,
+	QETH_CARD_TYPE_OSX     = 2,
 };
 
 #define QETH_MPC_DIFINFO_LEN_INDICATES_LINK_TYPE 0x18
@@ -614,6 +616,8 @@ extern unsigned char IDX_ACTIVATE_WRITE[
 #define QETH_IS_IDX_ACT_POS_REPLY(buffer) (((buffer)[0x08] & 3) == 2)
 #define QETH_IDX_REPLY_LEVEL(buffer) (buffer + 0x12)
 #define QETH_IDX_ACT_CAUSE_CODE(buffer) (buffer)[0x09]
+#define QETH_IDX_ACT_ERR_EXCL	0x19
+#define QETH_IDX_ACT_ERR_AUTH	0x1E
 
 #define PDU_ENCAPSULATION(buffer) \
 	(buffer + *(buffer + (*(buffer + 0x0b)) + \
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -490,7 +490,8 @@ static ssize_t qeth_dev_isolation_store(
 
 	mutex_lock(&card->conf_mutex);
 	/* check for unknown, too, in case we do not yet know who we are */
-	if (card->info.type != QETH_CARD_TYPE_OSAE &&
+	if (card->info.type != QETH_CARD_TYPE_OSD &&
+	    card->info.type != QETH_CARD_TYPE_OSX &&
 	    card->info.type != QETH_CARD_TYPE_UNKNOWN) {
 		rc = -EOPNOTSUPP;
 		dev_err(&card->gdev->dev, "Adapter does not "
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -56,7 +56,9 @@ static int qeth_l2_do_ioctl(struct net_d
 		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
 		break;
 	case SIOC_QETH_GET_CARD_TYPE:
-		if ((card->info.type == QETH_CARD_TYPE_OSAE) &&
+		if ((card->info.type == QETH_CARD_TYPE_OSD ||
+		     card->info.type == QETH_CARD_TYPE_OSM ||
+		     card->info.type == QETH_CARD_TYPE_OSX) &&
 		    !card->info.guestlan)
 			return 1;
 		return 0;
@@ -309,6 +311,10 @@ static void qeth_l2_vlan_rx_add_vid(stru
 	struct qeth_vlan_vid *id;
 
 	QETH_DBF_TEXT_(TRACE, 4, "aid:%d", vid);
+	if (card->info.type == QETH_CARD_TYPE_OSM) {
+		QETH_DBF_TEXT(TRACE, 3, "aidOSM");
+		return;
+	}
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
 		QETH_DBF_TEXT(TRACE, 3, "aidREC");
 		return;
@@ -329,6 +335,10 @@ static void qeth_l2_vlan_rx_kill_vid(str
 	struct qeth_card *card = dev->ml_priv;
 
 	QETH_DBF_TEXT_(TRACE, 4, "kid:%d", vid);
+	if (card->info.type == QETH_CARD_TYPE_OSM) {
+		QETH_DBF_TEXT(TRACE, 3, "kidOSM");
+		return;
+	}
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
 		QETH_DBF_TEXT(TRACE, 3, "kidREC");
 		return;
@@ -559,8 +569,10 @@ static int qeth_l2_request_initial_mac(s
 			"device %s: x%x\n", CARD_BUS_ID(card), rc);
 	}
 
-	if ((card->info.type == QETH_CARD_TYPE_IQD) || 
-	    (card->info.guestlan)) {
+	if (card->info.type == QETH_CARD_TYPE_IQD ||
+	    card->info.type == QETH_CARD_TYPE_OSM ||
+	    card->info.type == QETH_CARD_TYPE_OSX ||
+	    card->info.guestlan) {
 		rc = qeth_setadpparms_change_macaddr(card);
 		if (rc) {
 			QETH_DBF_MESSAGE(2, "couldn't get MAC address on "
@@ -589,8 +601,10 @@ static int qeth_l2_set_mac_address(struc
 		return -EOPNOTSUPP;
 	}
 
-	if (card->info.type == QETH_CARD_TYPE_OSN) {
-		QETH_DBF_TEXT(TRACE, 3, "setmcOSN");
+	if (card->info.type == QETH_CARD_TYPE_OSN ||
+	    card->info.type == QETH_CARD_TYPE_OSM ||
+	    card->info.type == QETH_CARD_TYPE_OSX) {
+		QETH_DBF_TEXT(TRACE, 3, "setmcTYP");
 		return -EOPNOTSUPP;
 	}
 	QETH_DBF_TEXT_(TRACE, 3, "%s", CARD_BUS_ID(card));
@@ -885,9 +899,6 @@ static const struct net_device_ops qeth_
 static int qeth_l2_setup_netdev(struct qeth_card *card)
 {
 	switch (card->info.type) {
-	case QETH_CARD_TYPE_OSAE:
-		card->dev = alloc_etherdev(0);
-		break;
 	case QETH_CARD_TYPE_IQD:
 		card->dev = alloc_netdev(0, "hsi%d", ether_setup);
 		break;
@@ -964,11 +975,14 @@ static int __qeth_l2_set_online(struct c
 	} else
 		card->lan_online = 1;
 
-	if (card->info.type != QETH_CARD_TYPE_OSN) {
+	if ((card->info.type == QETH_CARD_TYPE_OSD) ||
+	    (card->info.type == QETH_CARD_TYPE_OSX))
 		/* configure isolation level */
 		qeth_set_access_ctrl_online(card);
+
+	if (card->info.type != QETH_CARD_TYPE_OSN &&
+	    card->info.type != QETH_CARD_TYPE_OSM)
 		qeth_l2_process_vlans(card, 0);
-	}
 
 	netif_tx_disable(card->dev);
 
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -2711,7 +2711,8 @@ static int qeth_l3_do_ioctl(struct net_d
 		rc = qeth_snmp_command(card, rq->ifr_ifru.ifru_data);
 		break;
 	case SIOC_QETH_GET_CARD_TYPE:
-		if ((card->info.type == QETH_CARD_TYPE_OSAE) &&
+		if ((card->info.type == QETH_CARD_TYPE_OSD ||
+		     card->info.type == QETH_CARD_TYPE_OSX) &&
 		    !card->info.guestlan)
 			return 1;
 		return 0;
@@ -3248,7 +3249,8 @@ static const struct net_device_ops qeth_
 
 static int qeth_l3_setup_netdev(struct qeth_card *card)
 {
-	if (card->info.type == QETH_CARD_TYPE_OSAE) {
+	if (card->info.type == QETH_CARD_TYPE_OSD ||
+	    card->info.type == QETH_CARD_TYPE_OSX) {
 		if ((card->info.link_type == QETH_LINK_TYPE_LANE_TR) ||
 		    (card->info.link_type == QETH_LINK_TYPE_HSTR)) {
 #ifdef CONFIG_TR


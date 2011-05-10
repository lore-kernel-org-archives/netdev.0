From: frank.blaschka@de.ibm.com
Subject: [patch 2/9] [PATCH] qeth: add OSA concurrent hardware trap
Date: Tue, 10 May 2011 13:50:15 +0200
Message-ID: <20110510115047.221293799@de.ibm.com>
References: <20110510115013.363974020@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([194.196.100.163]:55160 "EHLO
	mtagate3.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754274Ab1EJLuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 07:50:50 -0400
Content-Disposition: inline; filename=601-qeth-hardware-trap.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

This patch improves FFDC (first failure data capture) by requesting
a hardware trace in case the device driver, the hardware or a user
detects an error.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_core.h      |   18 ++++
 drivers/s390/net/qeth_core_main.c |  148 ++++++++++++++++++++++++++++++++++++++
 drivers/s390/net/qeth_core_mpc.h  |    9 ++
 drivers/s390/net/qeth_core_sys.c  |   61 +++++++++++++++
 drivers/s390/net/qeth_l2_main.c   |   16 ++++
 drivers/s390/net/qeth_l3_main.c   |   53 ++++---------
 6 files changed, 268 insertions(+), 37 deletions(-)
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -631,6 +631,8 @@ struct qeth_card_info {
 	__u32 csum_mask;
 	__u32 tx_csum_mask;
 	enum qeth_ipa_promisc_modes promisc_mode;
+	__u32 diagass_support;
+	__u32 hwtrap;
 };
 
 struct qeth_card_options {
@@ -752,6 +754,14 @@ struct qeth_card_list_struct {
 	rwlock_t rwlock;
 };
 
+struct qeth_trap_id {
+	__u16 lparnr;
+	char vmname[8];
+	__u8 chpid;
+	__u8 ssid;
+	__u16 devno;
+} __packed;
+
 /*some helper functions*/
 #define QETH_CARD_IFNAME(card) (((card)->dev)? (card)->dev->name : "")
 
@@ -786,6 +796,12 @@ static inline void qeth_put_buffer_pool_
 	list_add_tail(&entry->list, &card->qdio.in_buf_pool.entry_list);
 }
 
+static inline int qeth_is_diagass_supported(struct qeth_card *card,
+		enum qeth_diags_cmds cmd)
+{
+	return card->info.diagass_support & (__u32)cmd;
+}
+
 extern struct ccwgroup_driver qeth_l2_ccwgroup_driver;
 extern struct ccwgroup_driver qeth_l3_ccwgroup_driver;
 const char *qeth_get_cardname_short(struct qeth_card *);
@@ -871,6 +887,8 @@ void qeth_dbf_longtext(debug_info_t *id,
 int qeth_core_ethtool_get_settings(struct net_device *, struct ethtool_cmd *);
 int qeth_set_access_ctrl_online(struct qeth_card *card);
 int qeth_hdr_chk_and_bounce(struct sk_buff *, int);
+int qeth_hw_trap(struct qeth_card *, enum qeth_diags_trap_action);
+int qeth_query_ipassists(struct qeth_card *, enum qeth_prot_versions prot);
 
 /* exports for OSN */
 int qeth_osn_assist(struct net_device *, void *, int);
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -24,6 +24,7 @@
 
 #include <asm/ebcdic.h>
 #include <asm/io.h>
+#include <asm/sysinfo.h>
 
 #include "qeth_core.h"
 
@@ -349,6 +350,8 @@ static struct qeth_ipa_cmd *qeth_check_i
 					   card->info.chpid);
 				netif_carrier_on(card->dev);
 				card->lan_online = 1;
+				if (card->info.hwtrap)
+					card->info.hwtrap = 2;
 				qeth_schedule_recovery(card);
 				return NULL;
 			case IPA_CMD_MODCCID:
@@ -2573,6 +2576,142 @@ int qeth_query_setadapterparms(struct qe
 }
 EXPORT_SYMBOL_GPL(qeth_query_setadapterparms);
 
+static int qeth_query_ipassists_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(SETUP, 2, "qipasscb");
+
+	cmd = (struct qeth_ipa_cmd *) data;
+	if (cmd->hdr.prot_version == QETH_PROT_IPV4) {
+		card->options.ipa4.supported_funcs = cmd->hdr.ipa_supported;
+		card->options.ipa4.enabled_funcs = cmd->hdr.ipa_enabled;
+	} else {
+		card->options.ipa6.supported_funcs = cmd->hdr.ipa_supported;
+		card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
+	}
+	QETH_DBF_TEXT(SETUP, 2, "suppenbl");
+	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_supported);
+	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_enabled);
+	return 0;
+}
+
+int qeth_query_ipassists(struct qeth_card *card, enum qeth_prot_versions prot)
+{
+	int rc;
+	struct qeth_cmd_buffer *iob;
+
+	QETH_DBF_TEXT_(SETUP, 2, "qipassi%i", prot);
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_QIPASSIST, prot);
+	rc = qeth_send_ipa_cmd(card, iob, qeth_query_ipassists_cb, NULL);
+	return rc;
+}
+EXPORT_SYMBOL_GPL(qeth_query_ipassists);
+
+static int qeth_query_setdiagass_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	__u16 rc;
+
+	cmd = (struct qeth_ipa_cmd *)data;
+	rc = cmd->hdr.return_code;
+	if (rc)
+		QETH_CARD_TEXT_(card, 2, "diagq:%x", rc);
+	else
+		card->info.diagass_support = cmd->data.diagass.ext;
+	return 0;
+}
+
+static int qeth_query_setdiagass(struct qeth_card *card)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd    *cmd;
+
+	QETH_DBF_TEXT(SETUP, 2, "qdiagass");
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SET_DIAG_ASS, 0);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.diagass.subcmd_len = 16;
+	cmd->data.diagass.subcmd = QETH_DIAGS_CMD_QUERY;
+	return qeth_send_ipa_cmd(card, iob, qeth_query_setdiagass_cb, NULL);
+}
+
+static void qeth_get_trap_id(struct qeth_card *card, struct qeth_trap_id *tid)
+{
+	unsigned long info = get_zeroed_page(GFP_KERNEL);
+	struct sysinfo_2_2_2 *info222 = (struct sysinfo_2_2_2 *)info;
+	struct sysinfo_3_2_2 *info322 = (struct sysinfo_3_2_2 *)info;
+	struct ccw_dev_id ccwid;
+	int level, rc;
+
+	tid->chpid = card->info.chpid;
+	ccw_device_get_id(CARD_RDEV(card), &ccwid);
+	tid->ssid = ccwid.ssid;
+	tid->devno = ccwid.devno;
+	if (!info)
+		return;
+
+	rc = stsi(NULL, 0, 0, 0);
+	if (rc == -ENOSYS)
+		level = rc;
+	else
+		level = (((unsigned int) rc) >> 28);
+
+	if ((level >= 2) && (stsi(info222, 2, 2, 2) != -ENOSYS))
+		tid->lparnr = info222->lpar_number;
+
+	if ((level >= 3) && (stsi(info322, 3, 2, 2) != -ENOSYS)) {
+		EBCASC(info322->vm[0].name, sizeof(info322->vm[0].name));
+		memcpy(tid->vmname, info322->vm[0].name, sizeof(tid->vmname));
+	}
+	free_page(info);
+	return;
+}
+
+static int qeth_hw_trap_cb(struct qeth_card *card,
+		struct qeth_reply *reply, unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd;
+	__u16 rc;
+
+	cmd = (struct qeth_ipa_cmd *)data;
+	rc = cmd->hdr.return_code;
+	if (rc)
+		QETH_CARD_TEXT_(card, 2, "trapc:%x", rc);
+	return 0;
+}
+
+int qeth_hw_trap(struct qeth_card *card, enum qeth_diags_trap_action action)
+{
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	QETH_DBF_TEXT(SETUP, 2, "diagtrap");
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SET_DIAG_ASS, 0);
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.diagass.subcmd_len = 80;
+	cmd->data.diagass.subcmd = QETH_DIAGS_CMD_TRAP;
+	cmd->data.diagass.type = 1;
+	cmd->data.diagass.action = action;
+	switch (action) {
+	case QETH_DIAGS_TRAP_ARM:
+		cmd->data.diagass.options = 0x0003;
+		cmd->data.diagass.ext = 0x00010000 +
+			sizeof(struct qeth_trap_id);
+		qeth_get_trap_id(card,
+			(struct qeth_trap_id *)cmd->data.diagass.cdata);
+		break;
+	case QETH_DIAGS_TRAP_DISARM:
+		cmd->data.diagass.options = 0x0001;
+		break;
+	case QETH_DIAGS_TRAP_CAPTURE:
+		break;
+	}
+	return qeth_send_ipa_cmd(card, iob, qeth_hw_trap_cb, NULL);
+}
+EXPORT_SYMBOL_GPL(qeth_hw_trap);
+
 int qeth_check_qdio_errors(struct qeth_card *card, struct qdio_buffer *buf,
 		unsigned int qdio_error, const char *dbftext)
 {
@@ -3983,6 +4122,15 @@ retriable:
 		QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
 		goto out;
 	}
+
+	card->options.ipa4.supported_funcs = 0;
+	card->options.adp.supported_funcs = 0;
+	card->info.diagass_support = 0;
+	qeth_query_ipassists(card, QETH_PROT_IPV4);
+	if (qeth_is_supported(card, IPA_SETADAPTERPARMS))
+		qeth_query_setadapterparms(card);
+	if (qeth_adp_supported(card, IPA_SETADP_SET_DIAG_ASSIST))
+		qeth_query_setdiagass(card);
 	return 0;
 out:
 	dev_warn(&card->gdev->dev, "The qeth device driver failed to recover "
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -448,6 +448,12 @@ enum qeth_diags_trace_cmds {
 	QETH_DIAGS_CMD_TRACE_QUERY	= 0x0010,
 };
 
+enum qeth_diags_trap_action {
+	QETH_DIAGS_TRAP_ARM	= 0x01,
+	QETH_DIAGS_TRAP_DISARM	= 0x02,
+	QETH_DIAGS_TRAP_CAPTURE = 0x04,
+};
+
 struct qeth_ipacmd_diagass {
 	__u32  host_tod2;
 	__u32:32;
@@ -457,7 +463,8 @@ struct qeth_ipacmd_diagass {
 	__u8   type;
 	__u8   action;
 	__u16  options;
-	__u32:32;
+	__u32  ext;
+	__u8   cdata[64];
 } __attribute__ ((packed));
 
 /* Header for each IPA command */
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -530,6 +530,66 @@ out:
 static DEVICE_ATTR(isolation, 0644, qeth_dev_isolation_show,
 		   qeth_dev_isolation_store);
 
+static ssize_t qeth_hw_trap_show(struct device *dev,
+				struct device_attribute *attr, char *buf)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+
+	if (!card)
+		return -EINVAL;
+	if (card->info.hwtrap)
+		return snprintf(buf, 5, "arm\n");
+	else
+		return snprintf(buf, 8, "disarm\n");
+}
+
+static ssize_t qeth_hw_trap_store(struct device *dev,
+		struct device_attribute *attr, const char *buf, size_t count)
+{
+	struct qeth_card *card = dev_get_drvdata(dev);
+	int rc = 0;
+	char *tmp, *curtoken;
+	int state = 0;
+	curtoken = (char *)buf;
+
+	if (!card)
+		return -EINVAL;
+
+	mutex_lock(&card->conf_mutex);
+	if (card->state == CARD_STATE_SOFTSETUP || card->state == CARD_STATE_UP)
+		state = 1;
+	tmp = strsep(&curtoken, "\n");
+
+	if (!strcmp(tmp, "arm") && !card->info.hwtrap) {
+		if (state) {
+			if (qeth_is_diagass_supported(card,
+			    QETH_DIAGS_CMD_TRAP)) {
+				rc = qeth_hw_trap(card, QETH_DIAGS_TRAP_ARM);
+				if (!rc)
+					card->info.hwtrap = 1;
+			} else
+				rc = -EINVAL;
+		} else
+			card->info.hwtrap = 1;
+	} else if (!strcmp(tmp, "disarm") && card->info.hwtrap) {
+		if (state) {
+			rc = qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
+			if (!rc)
+				card->info.hwtrap = 0;
+		} else
+			card->info.hwtrap = 0;
+	} else if (!strcmp(tmp, "trap") && state && card->info.hwtrap)
+		rc = qeth_hw_trap(card, QETH_DIAGS_TRAP_CAPTURE);
+	else
+		rc = -EINVAL;
+
+	mutex_unlock(&card->conf_mutex);
+	return rc ? rc : count;
+}
+
+static DEVICE_ATTR(hw_trap, 0644, qeth_hw_trap_show,
+		   qeth_hw_trap_store);
+
 static ssize_t qeth_dev_blkt_show(char *buf, struct qeth_card *card, int value)
 {
 
@@ -653,6 +713,7 @@ static struct attribute *qeth_device_att
 	&dev_attr_performance_stats.attr,
 	&dev_attr_layer2.attr,
 	&dev_attr_isolation.attr,
+	&dev_attr_hw_trap.attr,
 	NULL,
 };
 
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -876,6 +876,7 @@ static int qeth_l2_probe_device(struct c
 	INIT_LIST_HEAD(&card->vid_list);
 	INIT_LIST_HEAD(&card->mc_list);
 	card->options.layer2 = 1;
+	card->info.hwtrap = 0;
 	card->discipline.start_poll = qeth_qdio_start_poll;
 	card->discipline.input_handler = (qdio_handler_t *)
 		qeth_qdio_input_handler;
@@ -994,6 +995,13 @@ static int __qeth_l2_set_online(struct c
 	if (card->info.type != QETH_CARD_TYPE_OSN)
 		qeth_l2_send_setmac(card, &card->dev->dev_addr[0]);
 
+	if (qeth_is_diagass_supported(card, QETH_DIAGS_CMD_TRAP)) {
+		if (card->info.hwtrap &&
+		    qeth_hw_trap(card, QETH_DIAGS_TRAP_ARM))
+			card->info.hwtrap = 0;
+	} else
+		card->info.hwtrap = 0;
+
 	card->state = CARD_STATE_HARDSETUP;
 	memset(&card->rx, 0, sizeof(struct qeth_rx));
 	qeth_print_status_message(card);
@@ -1092,6 +1100,10 @@ static int __qeth_l2_set_offline(struct
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
 	recover_flag = card->state;
+	if ((!recovery_mode && card->info.hwtrap) || card->info.hwtrap == 2) {
+		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
+		card->info.hwtrap = 1;
+	}
 	qeth_l2_stop_card(card, recovery_mode);
 	rc  = ccw_device_set_offline(CARD_DDEV(card));
 	rc2 = ccw_device_set_offline(CARD_WDEV(card));
@@ -1157,6 +1169,8 @@ static void __exit qeth_l2_exit(void)
 static void qeth_l2_shutdown(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	if ((gdev->state == CCWGROUP_ONLINE) && card->info.hwtrap)
+		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
 	qeth_qdio_clear_card(card, 0);
 	qeth_clear_qdio_buffers(card);
 }
@@ -1172,6 +1186,8 @@ static int qeth_l2_pm_suspend(struct ccw
 	if (gdev->state == CCWGROUP_OFFLINE)
 		return 0;
 	if (card->state == CARD_STATE_UP) {
+		if (card->info.hwtrap)
+			qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
 		__qeth_l2_set_offline(card->gdev, 1);
 	} else
 		__qeth_l2_set_offline(card->gdev, 0);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1277,39 +1277,6 @@ static int qeth_l3_start_ipa_multicast(s
 	return rc;
 }
 
-static int qeth_l3_query_ipassists_cb(struct qeth_card *card,
-		struct qeth_reply *reply, unsigned long data)
-{
-	struct qeth_ipa_cmd *cmd;
-
-	QETH_DBF_TEXT(SETUP, 2, "qipasscb");
-
-	cmd = (struct qeth_ipa_cmd *) data;
-	if (cmd->hdr.prot_version == QETH_PROT_IPV4) {
-		card->options.ipa4.supported_funcs = cmd->hdr.ipa_supported;
-		card->options.ipa4.enabled_funcs = cmd->hdr.ipa_enabled;
-	} else {
-		card->options.ipa6.supported_funcs = cmd->hdr.ipa_supported;
-		card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
-	}
-	QETH_DBF_TEXT(SETUP, 2, "suppenbl");
-	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_supported);
-	QETH_DBF_TEXT_(SETUP, 2, "%x", cmd->hdr.ipa_enabled);
-	return 0;
-}
-
-static int qeth_l3_query_ipassists(struct qeth_card *card,
-				enum qeth_prot_versions prot)
-{
-	int rc;
-	struct qeth_cmd_buffer *iob;
-
-	QETH_DBF_TEXT_(SETUP, 2, "qipassi%i", prot);
-	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_QIPASSIST, prot);
-	rc = qeth_send_ipa_cmd(card, iob, qeth_l3_query_ipassists_cb, NULL);
-	return rc;
-}
-
 #ifdef CONFIG_QETH_IPV6
 static int qeth_l3_softsetup_ipv6(struct qeth_card *card)
 {
@@ -1320,7 +1287,7 @@ static int qeth_l3_softsetup_ipv6(struct
 	if (card->info.type == QETH_CARD_TYPE_IQD)
 		goto out;
 
-	rc = qeth_l3_query_ipassists(card, QETH_PROT_IPV6);
+	rc = qeth_query_ipassists(card, QETH_PROT_IPV6);
 	if (rc) {
 		dev_err(&card->gdev->dev,
 			"Activating IPv6 support for %s failed\n",
@@ -3364,6 +3331,7 @@ static int qeth_l3_probe_device(struct c
 
 	qeth_l3_create_device_attributes(&gdev->dev);
 	card->options.layer2 = 0;
+	card->info.hwtrap = 0;
 	card->discipline.start_poll = qeth_qdio_start_poll;
 	card->discipline.input_handler = (qdio_handler_t *)
 		qeth_qdio_input_handler;
@@ -3415,13 +3383,18 @@ static int __qeth_l3_set_online(struct c
 		goto out_remove;
 	}
 
-	qeth_l3_query_ipassists(card, QETH_PROT_IPV4);
-
 	if (!card->dev && qeth_l3_setup_netdev(card)) {
 		rc = -ENODEV;
 		goto out_remove;
 	}
 
+	if (qeth_is_diagass_supported(card, QETH_DIAGS_CMD_TRAP)) {
+		if (card->info.hwtrap &&
+		    qeth_hw_trap(card, QETH_DIAGS_TRAP_ARM))
+			card->info.hwtrap = 0;
+	} else
+		card->info.hwtrap = 0;
+
 	card->state = CARD_STATE_HARDSETUP;
 	memset(&card->rx, 0, sizeof(struct qeth_rx));
 	qeth_print_status_message(card);
@@ -3523,6 +3496,10 @@ static int __qeth_l3_set_offline(struct
 	if (card->dev && netif_carrier_ok(card->dev))
 		netif_carrier_off(card->dev);
 	recover_flag = card->state;
+	if ((!recovery_mode && card->info.hwtrap) || card->info.hwtrap == 2) {
+		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
+		card->info.hwtrap = 1;
+	}
 	qeth_l3_stop_card(card, recovery_mode);
 	rc  = ccw_device_set_offline(CARD_DDEV(card));
 	rc2 = ccw_device_set_offline(CARD_WDEV(card));
@@ -3578,6 +3555,8 @@ static int qeth_l3_recover(void *ptr)
 static void qeth_l3_shutdown(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
+	if ((gdev->state == CCWGROUP_ONLINE) && card->info.hwtrap)
+		qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
 	qeth_qdio_clear_card(card, 0);
 	qeth_clear_qdio_buffers(card);
 }
@@ -3593,6 +3572,8 @@ static int qeth_l3_pm_suspend(struct ccw
 	if (gdev->state == CCWGROUP_OFFLINE)
 		return 0;
 	if (card->state == CARD_STATE_UP) {
+		if (card->info.hwtrap)
+			qeth_hw_trap(card, QETH_DIAGS_TRAP_DISARM);
 		__qeth_l3_set_offline(card->gdev, 1);
 	} else
 		__qeth_l3_set_offline(card->gdev, 0);


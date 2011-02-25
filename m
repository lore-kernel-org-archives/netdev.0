From: frank.blaschka@de.ibm.com
Subject: [patch 1/1] [PATCH] qeth: remove needless IPA-commands in offline
Date: Fri, 25 Feb 2011 13:32:09 +0100
Message-ID: <20110225123342.680650926@de.ibm.com>
References: <20110225123208.764828326@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate5.uk.ibm.com ([194.196.100.165]:44665 "EHLO
	mtagate5.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429Ab1BYMds (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 07:33:48 -0500
Content-Disposition: inline; filename=602-needless-ipa-commands.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If a qeth device is set offline, data and control subchannels are
cleared, which means removal of all IP Assist Primitive settings
implicitly. There is no need to delete those settings explicitly.
This patch removes all IP Assist invocations from offline.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---


 drivers/s390/net/qeth_core.h      |    1 
 drivers/s390/net/qeth_core_main.c |   52 ++++++++++-------------------------
 drivers/s390/net/qeth_l2_main.c   |   45 +++++++++----------------------
 drivers/s390/net/qeth_l3_main.c   |   55 ++------------------------------------
 4 files changed, 33 insertions(+), 120 deletions(-)
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -741,7 +741,6 @@ struct qeth_card {
 	/* QDIO buffer handling */
 	struct qeth_qdio_info qdio;
 	struct qeth_perf_stats perf_stats;
-	int use_hard_stop;
 	int read_or_write_problem;
 	struct qeth_osn_info osn_info;
 	struct qeth_discipline discipline;
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -302,12 +302,15 @@ static void qeth_issue_ipa_msg(struct qe
 	int com = cmd->hdr.command;
 	ipa_name = qeth_get_ipa_cmd_name(com);
 	if (rc)
-		QETH_DBF_MESSAGE(2, "IPA: %s(x%X) for %s returned x%X \"%s\"\n",
-				ipa_name, com, QETH_CARD_IFNAME(card),
-					rc, qeth_get_ipa_msg(rc));
+		QETH_DBF_MESSAGE(2, "IPA: %s(x%X) for %s/%s returned "
+				"x%X \"%s\"\n",
+				ipa_name, com, dev_name(&card->gdev->dev),
+				QETH_CARD_IFNAME(card), rc,
+				qeth_get_ipa_msg(rc));
 	else
-		QETH_DBF_MESSAGE(5, "IPA: %s(x%X) for %s succeeded\n",
-				ipa_name, com, QETH_CARD_IFNAME(card));
+		QETH_DBF_MESSAGE(5, "IPA: %s(x%X) for %s/%s succeeded\n",
+				ipa_name, com, dev_name(&card->gdev->dev),
+				QETH_CARD_IFNAME(card));
 }
 
 static struct qeth_ipa_cmd *qeth_check_ipa_data(struct qeth_card *card,
@@ -1083,7 +1086,6 @@ static int qeth_setup_card(struct qeth_c
 	card->data.state  = CH_STATE_DOWN;
 	card->state = CARD_STATE_DOWN;
 	card->lan_online = 0;
-	card->use_hard_stop = 0;
 	card->read_or_write_problem = 0;
 	card->dev = NULL;
 	spin_lock_init(&card->vlanlock);
@@ -1732,20 +1734,22 @@ int qeth_send_control_data(struct qeth_c
 		};
 	}
 
+	if (reply->rc == -EIO)
+		goto error;
 	rc = reply->rc;
 	qeth_put_reply(reply);
 	return rc;
 
 time_err:
+	reply->rc = -ETIME;
 	spin_lock_irqsave(&reply->card->lock, flags);
 	list_del_init(&reply->list);
 	spin_unlock_irqrestore(&reply->card->lock, flags);
-	reply->rc = -ETIME;
 	atomic_inc(&reply->received);
+error:
 	atomic_set(&card->write.irq_pending, 0);
 	qeth_release_buffer(iob->channel, iob);
 	card->write.buf_no = (card->write.buf_no + 1) % QETH_CMD_BUFFER_NO;
-	wake_up(&reply->wait_q);
 	rc = reply->rc;
 	qeth_put_reply(reply);
 	return rc;
@@ -2490,45 +2494,19 @@ int qeth_send_ipa_cmd(struct qeth_card *
 }
 EXPORT_SYMBOL_GPL(qeth_send_ipa_cmd);
 
-static int qeth_send_startstoplan(struct qeth_card *card,
-		enum qeth_ipa_cmds ipacmd, enum qeth_prot_versions prot)
-{
-	int rc;
-	struct qeth_cmd_buffer *iob;
-
-	iob = qeth_get_ipacmd_buffer(card, ipacmd, prot);
-	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
-
-	return rc;
-}
-
 int qeth_send_startlan(struct qeth_card *card)
 {
 	int rc;
+	struct qeth_cmd_buffer *iob;
 
 	QETH_DBF_TEXT(SETUP, 2, "strtlan");
 
-	rc = qeth_send_startstoplan(card, IPA_CMD_STARTLAN, 0);
+	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_STARTLAN, 0);
+	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(qeth_send_startlan);
 
-int qeth_send_stoplan(struct qeth_card *card)
-{
-	int rc = 0;
-
-	/*
-	 * TODO: according to the IPA format document page 14,
-	 * TCP/IP (we!) never issue a STOPLAN
-	 * is this right ?!?
-	 */
-	QETH_DBF_TEXT(SETUP, 2, "stoplan");
-
-	rc = qeth_send_startstoplan(card, IPA_CMD_STOPLAN, 0);
-	return rc;
-}
-EXPORT_SYMBOL_GPL(qeth_send_stoplan);
-
 int qeth_default_setadapterparms_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
 {
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -202,17 +202,19 @@ static void qeth_l2_add_mc(struct qeth_c
 		kfree(mc);
 }
 
-static void qeth_l2_del_all_mc(struct qeth_card *card)
+static void qeth_l2_del_all_mc(struct qeth_card *card, int del)
 {
 	struct qeth_mc_mac *mc, *tmp;
 
 	spin_lock_bh(&card->mclock);
 	list_for_each_entry_safe(mc, tmp, &card->mc_list, list) {
-		if (mc->is_vmac)
-			qeth_l2_send_setdelmac(card, mc->mc_addr,
+		if (del) {
+			if (mc->is_vmac)
+				qeth_l2_send_setdelmac(card, mc->mc_addr,
 					IPA_CMD_DELVMAC, NULL);
-		else
-			qeth_l2_send_delgroupmac(card, mc->mc_addr);
+			else
+				qeth_l2_send_delgroupmac(card, mc->mc_addr);
+		}
 		list_del(&mc->list);
 		kfree(mc);
 	}
@@ -288,18 +290,13 @@ static int qeth_l2_send_setdelvlan(struc
 				 qeth_l2_send_setdelvlan_cb, NULL);
 }
 
-static void qeth_l2_process_vlans(struct qeth_card *card, int clear)
+static void qeth_l2_process_vlans(struct qeth_card *card)
 {
 	struct qeth_vlan_vid *id;
 	QETH_CARD_TEXT(card, 3, "L2prcvln");
 	spin_lock_bh(&card->vlanlock);
 	list_for_each_entry(id, &card->vid_list, list) {
-		if (clear)
-			qeth_l2_send_setdelvlan(card, id->vid,
-				IPA_CMD_DELVLAN);
-		else
-			qeth_l2_send_setdelvlan(card, id->vid,
-				IPA_CMD_SETVLAN);
+		qeth_l2_send_setdelvlan(card, id->vid, IPA_CMD_SETVLAN);
 	}
 	spin_unlock_bh(&card->vlanlock);
 }
@@ -379,19 +376,11 @@ static int qeth_l2_stop_card(struct qeth
 			dev_close(card->dev);
 			rtnl_unlock();
 		}
-		if (!card->use_hard_stop ||
-			recovery_mode) {
-			__u8 *mac = &card->dev->dev_addr[0];
-			rc = qeth_l2_send_delmac(card, mac);
-			QETH_DBF_TEXT_(SETUP, 2, "Lerr%d", rc);
-		}
+		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
 		card->state = CARD_STATE_SOFTSETUP;
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
-		qeth_l2_process_vlans(card, 1);
-		if (!card->use_hard_stop ||
-			recovery_mode)
-			qeth_l2_del_all_mc(card);
+		qeth_l2_del_all_mc(card, 0);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;
 	}
@@ -405,7 +394,6 @@ static int qeth_l2_stop_card(struct qeth
 		qeth_clear_cmd_buffers(&card->read);
 		qeth_clear_cmd_buffers(&card->write);
 	}
-	card->use_hard_stop = 0;
 	return rc;
 }
 
@@ -705,7 +693,7 @@ static void qeth_l2_set_multicast_list(s
 	if (qeth_threads_running(card, QETH_RECOVER_THREAD) &&
 	    (card->state != CARD_STATE_UP))
 		return;
-	qeth_l2_del_all_mc(card);
+	qeth_l2_del_all_mc(card, 1);
 	spin_lock_bh(&card->mclock);
 	netdev_for_each_mc_addr(ha, dev)
 		qeth_l2_add_mc(card, ha->addr, 0);
@@ -907,10 +895,8 @@ static void qeth_l2_remove_device(struct
 	qeth_set_allowed_threads(card, 0, 1);
 	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
 
-	if (cgdev->state == CCWGROUP_ONLINE) {
-		card->use_hard_stop = 1;
+	if (cgdev->state == CCWGROUP_ONLINE)
 		qeth_l2_set_offline(cgdev);
-	}
 
 	if (card->dev) {
 		unregister_netdev(card->dev);
@@ -1040,7 +1026,7 @@ contin:
 
 	if (card->info.type != QETH_CARD_TYPE_OSN &&
 	    card->info.type != QETH_CARD_TYPE_OSM)
-		qeth_l2_process_vlans(card, 0);
+		qeth_l2_process_vlans(card);
 
 	netif_tx_disable(card->dev);
 
@@ -1076,7 +1062,6 @@ contin:
 	return 0;
 
 out_remove:
-	card->use_hard_stop = 1;
 	qeth_l2_stop_card(card, 0);
 	ccw_device_set_offline(CARD_DDEV(card));
 	ccw_device_set_offline(CARD_WDEV(card));
@@ -1144,7 +1129,6 @@ static int qeth_l2_recover(void *ptr)
 	QETH_CARD_TEXT(card, 2, "recover2");
 	dev_warn(&card->gdev->dev,
 		"A recovery process has been started for the device\n");
-	card->use_hard_stop = 1;
 	__qeth_l2_set_offline(card->gdev, 1);
 	rc = __qeth_l2_set_online(card->gdev, 1);
 	if (!rc)
@@ -1191,7 +1175,6 @@ static int qeth_l2_pm_suspend(struct ccw
 	if (gdev->state == CCWGROUP_OFFLINE)
 		return 0;
 	if (card->state == CARD_STATE_UP) {
-		card->use_hard_stop = 1;
 		__qeth_l2_set_offline(card->gdev, 1);
 	} else
 		__qeth_l2_set_offline(card->gdev, 0);
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -510,8 +510,7 @@ static void qeth_l3_set_ip_addr_list(str
 	kfree(tbd_list);
 }
 
-static void qeth_l3_clear_ip_list(struct qeth_card *card, int clean,
-					int recover)
+static void qeth_l3_clear_ip_list(struct qeth_card *card, int recover)
 {
 	struct qeth_ipaddr *addr, *tmp;
 	unsigned long flags;
@@ -530,11 +529,6 @@ static void qeth_l3_clear_ip_list(struct
 		addr = list_entry(card->ip_list.next,
 				  struct qeth_ipaddr, entry);
 		list_del_init(&addr->entry);
-		if (clean) {
-			spin_unlock_irqrestore(&card->ip_lock, flags);
-			qeth_l3_deregister_addr_entry(card, addr);
-			spin_lock_irqsave(&card->ip_lock, flags);
-		}
 		if (!recover || addr->is_multicast) {
 			kfree(addr);
 			continue;
@@ -1611,29 +1605,6 @@ static int qeth_l3_start_ipassists(struc
 	return 0;
 }
 
-static int qeth_l3_put_unique_id(struct qeth_card *card)
-{
-
-	int rc = 0;
-	struct qeth_cmd_buffer *iob;
-	struct qeth_ipa_cmd *cmd;
-
-	QETH_CARD_TEXT(card, 2, "puniqeid");
-
-	if ((card->info.unique_id & UNIQUE_ID_NOT_BY_CARD) ==
-		UNIQUE_ID_NOT_BY_CARD)
-		return -1;
-	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_DESTROY_ADDR,
-				     QETH_PROT_IPV6);
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	*((__u16 *) &cmd->data.create_destroy_addr.unique_id[6]) =
-				card->info.unique_id;
-	memcpy(&cmd->data.create_destroy_addr.unique_id[0],
-	       card->dev->dev_addr, OSA_ADDR_LEN);
-	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
-	return rc;
-}
-
 static int qeth_l3_iqd_read_initial_mac_cb(struct qeth_card *card,
 		struct qeth_reply *reply, unsigned long data)
 {
@@ -2324,25 +2295,14 @@ static int qeth_l3_stop_card(struct qeth
 			dev_close(card->dev);
 			rtnl_unlock();
 		}
-		if (!card->use_hard_stop) {
-			rc = qeth_send_stoplan(card);
-			if (rc)
-				QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
-		}
 		card->state = CARD_STATE_SOFTSETUP;
 	}
 	if (card->state == CARD_STATE_SOFTSETUP) {
-		qeth_l3_clear_ip_list(card, !card->use_hard_stop, 1);
+		qeth_l3_clear_ip_list(card, 1);
 		qeth_clear_ipacmd_list(card);
 		card->state = CARD_STATE_HARDSETUP;
 	}
 	if (card->state == CARD_STATE_HARDSETUP) {
-		if (!card->use_hard_stop &&
-		    (card->info.type != QETH_CARD_TYPE_IQD)) {
-			rc = qeth_l3_put_unique_id(card);
-			if (rc)
-				QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
-		}
 		qeth_qdio_clear_card(card, 0);
 		qeth_clear_qdio_buffers(card);
 		qeth_clear_working_pool_list(card);
@@ -2352,7 +2312,6 @@ static int qeth_l3_stop_card(struct qeth
 		qeth_clear_cmd_buffers(&card->read);
 		qeth_clear_cmd_buffers(&card->write);
 	}
-	card->use_hard_stop = 0;
 	return rc;
 }
 
@@ -3483,17 +3442,15 @@ static void qeth_l3_remove_device(struct
 	qeth_set_allowed_threads(card, 0, 1);
 	wait_event(card->wait_q, qeth_threads_running(card, 0xffffffff) == 0);
 
-	if (cgdev->state == CCWGROUP_ONLINE) {
-		card->use_hard_stop = 1;
+	if (cgdev->state == CCWGROUP_ONLINE)
 		qeth_l3_set_offline(cgdev);
-	}
 
 	if (card->dev) {
 		unregister_netdev(card->dev);
 		card->dev = NULL;
 	}
 
-	qeth_l3_clear_ip_list(card, 0, 0);
+	qeth_l3_clear_ip_list(card, 0);
 	qeth_l3_clear_ipato_list(card);
 	return;
 }
@@ -3594,7 +3551,6 @@ contin:
 	mutex_unlock(&card->discipline_mutex);
 	return 0;
 out_remove:
-	card->use_hard_stop = 1;
 	qeth_l3_stop_card(card, 0);
 	ccw_device_set_offline(CARD_DDEV(card));
 	ccw_device_set_offline(CARD_WDEV(card));
@@ -3663,7 +3619,6 @@ static int qeth_l3_recover(void *ptr)
 	QETH_CARD_TEXT(card, 2, "recover2");
 	dev_warn(&card->gdev->dev,
 		"A recovery process has been started for the device\n");
-	card->use_hard_stop = 1;
 	__qeth_l3_set_offline(card->gdev, 1);
 	rc = __qeth_l3_set_online(card->gdev, 1);
 	if (!rc)
@@ -3684,7 +3639,6 @@ static int qeth_l3_recover(void *ptr)
 static void qeth_l3_shutdown(struct ccwgroup_device *gdev)
 {
 	struct qeth_card *card = dev_get_drvdata(&gdev->dev);
-	qeth_l3_clear_ip_list(card, 0, 0);
 	qeth_qdio_clear_card(card, 0);
 	qeth_clear_qdio_buffers(card);
 }
@@ -3700,7 +3654,6 @@ static int qeth_l3_pm_suspend(struct ccw
 	if (gdev->state == CCWGROUP_OFFLINE)
 		return 0;
 	if (card->state == CARD_STATE_UP) {
-		card->use_hard_stop = 1;
 		__qeth_l3_set_offline(card->gdev, 1);
 	} else
 		__qeth_l3_set_offline(card->gdev, 0);


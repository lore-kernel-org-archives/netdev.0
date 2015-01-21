From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 2/2] 390/qeth: Fix locking warning during qeth device setup
Date: Wed, 21 Jan 2015 13:39:10 +0100
Message-ID: <1421843950-58220-3-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1421843950-58220-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Thomas Richter <tmricht@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp16.uk.ibm.com ([195.75.94.112]:33766 "EHLO
	e06smtp16.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbbAUMjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:39:42 -0500
Received: from /spool/local
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 21 Jan 2015 12:39:40 -0000
In-Reply-To: <1421843950-58220-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

Do not wait for channel command buffers in IPA commands.
The potential wait could be done while holding a spin lock and causes
in recent kernels such a bug if kernel lock debugging is enabled:

kernel: BUG: sleeping function called from invalid context at drivers/s390/net/qeth_core_main.c:
794
kernel: in_atomic(): 1, irqs_disabled(): 0, pid: 2031, name: NetworkManager
kernel: 2 locks held by NetworkManager/2031:
kernel:  #0:  (rtnl_mutex){+.+.+.}, at: [<00000000006e0d7a>] rtnetlink_rcv+0x32/0x50
kernel:  #1:  (_xmit_ETHER){+.....}, at: [<00000000006cfe90>] dev_set_rx_mode+0x30/0x50
kernel: CPU: 0 PID: 2031 Comm: NetworkManager Not tainted 3.18.0-rc5-next-20141124 #1
kernel:        00000000275fb1f0 00000000275fb280 0000000000000002 0000000000000000
               00000000275fb320 00000000275fb298 00000000275fb298 00000000007e326a
               0000000000000000 000000000099ce2c 00000000009b4988 000000000000000b
               00000000275fb2e0 00000000275fb280 0000000000000000 0000000000000000
               0000000000000000 00000000001129c8 00000000275fb280 00000000275fb2e0
kernel: Call Trace:
kernel: ([<00000000001128b0>] show_trace+0xf8/0x158)
kernel:  [<000000000011297a>] show_stack+0x6a/0xe8
kernel:  [<00000000007e995a>] dump_stack+0x82/0xb0
kernel:  [<000000000017d668>] ___might_sleep+0x170/0x228
kernel:  [<000003ff80026f0e>] qeth_wait_for_buffer+0x36/0xd0 [qeth]
kernel:  [<000003ff80026fe2>] qeth_get_ipacmd_buffer+0x3a/0xc0 [qeth]
kernel:  [<000003ff80105078>] qeth_l3_send_setdelmc+0x58/0xf8 [qeth_l3]
kernel:  [<000003ff8010b1fe>] qeth_l3_set_ip_addr_list+0x2c6/0x848 [qeth_l3]
kernel:  [<000003ff8010bbb4>] qeth_l3_set_multicast_list+0x434/0xc48 [qeth_l3]
kernel:  [<00000000006cfe9a>] dev_set_rx_mode+0x3a/0x50
kernel:  [<00000000006cff90>] __dev_open+0xe0/0x140
kernel:  [<00000000006d02a0>] __dev_change_flags+0xa0/0x178
kernel:  [<00000000006d03a8>] dev_change_flags+0x30/0x70
kernel:  [<00000000006e14ee>] do_setlink+0x346/0x9a0
...

The device driver has plenty of command buffers available
per channel for channel command communication.
In the extremely rare case when there is no command buffer
available, return a NULL pointer and issue a warning
in the kernel log. The caller handles the case when
a NULL pointer is encountered and returns an error.

In the case the wait for command buffer is possible
(because no lock is held as in the OSN case), still wait
until a channel command buffer is available.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reviewed-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 81 ++++++++++++++++++++++++++++++++-------
 drivers/s390/net/qeth_l2_main.c   | 35 ++++++++++++-----
 drivers/s390/net/qeth_l3_main.c   | 50 ++++++++++++++++++------
 3 files changed, 132 insertions(+), 34 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index e2fbfff..642c77c 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1784,6 +1784,8 @@ static int qeth_idx_activate_get_answer(struct qeth_channel *channel,
 	QETH_DBF_TEXT(SETUP, 2, "idxanswr");
 	card = CARD_FROM_CDEV(channel->ccwdev);
 	iob = qeth_get_buffer(channel);
+	if (!iob)
+		return -ENOMEM;
 	iob->callback = idx_reply_cb;
 	memcpy(&channel->ccw, READ_CCW, sizeof(struct ccw1));
 	channel->ccw.count = QETH_BUFSIZE;
@@ -1834,6 +1836,8 @@ static int qeth_idx_activate_channel(struct qeth_channel *channel,
 	QETH_DBF_TEXT(SETUP, 2, "idxactch");
 
 	iob = qeth_get_buffer(channel);
+	if (!iob)
+		return -ENOMEM;
 	iob->callback = idx_reply_cb;
 	memcpy(&channel->ccw, WRITE_CCW, sizeof(struct ccw1));
 	channel->ccw.count = IDX_ACTIVATE_SIZE;
@@ -2940,9 +2944,16 @@ struct qeth_cmd_buffer *qeth_get_ipacmd_buffer(struct qeth_card *card,
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 
-	iob = qeth_wait_for_buffer(&card->write);
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	qeth_fill_ipacmd_header(card, cmd, ipacmd, prot);
+	iob = qeth_get_buffer(&card->write);
+	if (iob) {
+		cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+		qeth_fill_ipacmd_header(card, cmd, ipacmd, prot);
+	} else {
+		dev_warn(&card->gdev->dev,
+			 "The qeth driver ran out of channel command buffers\n");
+		QETH_DBF_MESSAGE(1, "%s The qeth driver ran out of channel command buffers",
+				 dev_name(&card->gdev->dev));
+	}
 
 	return iob;
 }
@@ -3000,6 +3011,8 @@ int qeth_send_startlan(struct qeth_card *card)
 	QETH_DBF_TEXT(SETUP, 2, "strtlan");
 
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_STARTLAN, 0);
+	if (!iob)
+		return -ENOMEM;
 	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
 	return rc;
 }
@@ -3045,11 +3058,13 @@ static struct qeth_cmd_buffer *qeth_get_adapter_cmd(struct qeth_card *card,
 
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETADAPTERPARMS,
 				     QETH_PROT_IPV4);
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	cmd->data.setadapterparms.hdr.cmdlength = cmdlen;
-	cmd->data.setadapterparms.hdr.command_code = command;
-	cmd->data.setadapterparms.hdr.used_total = 1;
-	cmd->data.setadapterparms.hdr.seq_no = 1;
+	if (iob) {
+		cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+		cmd->data.setadapterparms.hdr.cmdlength = cmdlen;
+		cmd->data.setadapterparms.hdr.command_code = command;
+		cmd->data.setadapterparms.hdr.used_total = 1;
+		cmd->data.setadapterparms.hdr.seq_no = 1;
+	}
 
 	return iob;
 }
@@ -3062,6 +3077,8 @@ int qeth_query_setadapterparms(struct qeth_card *card)
 	QETH_CARD_TEXT(card, 3, "queryadp");
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_COMMANDS_SUPPORTED,
 				   sizeof(struct qeth_ipacmd_setadpparms));
+	if (!iob)
+		return -ENOMEM;
 	rc = qeth_send_ipa_cmd(card, iob, qeth_query_setadapterparms_cb, NULL);
 	return rc;
 }
@@ -3112,6 +3129,8 @@ int qeth_query_ipassists(struct qeth_card *card, enum qeth_prot_versions prot)
 
 	QETH_DBF_TEXT_(SETUP, 2, "qipassi%i", prot);
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_QIPASSIST, prot);
+	if (!iob)
+		return -ENOMEM;
 	rc = qeth_send_ipa_cmd(card, iob, qeth_query_ipassists_cb, NULL);
 	return rc;
 }
@@ -3151,6 +3170,8 @@ int qeth_query_switch_attributes(struct qeth_card *card,
 		return -ENOMEDIUM;
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_SWITCH_ATTRIBUTES,
 				sizeof(struct qeth_ipacmd_setadpparms_hdr));
+	if (!iob)
+		return -ENOMEM;
 	return qeth_send_ipa_cmd(card, iob,
 				qeth_query_switch_attributes_cb, sw_info);
 }
@@ -3178,6 +3199,8 @@ static int qeth_query_setdiagass(struct qeth_card *card)
 
 	QETH_DBF_TEXT(SETUP, 2, "qdiagass");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SET_DIAG_ASS, 0);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.diagass.subcmd_len = 16;
 	cmd->data.diagass.subcmd = QETH_DIAGS_CMD_QUERY;
@@ -3229,6 +3252,8 @@ int qeth_hw_trap(struct qeth_card *card, enum qeth_diags_trap_action action)
 
 	QETH_DBF_TEXT(SETUP, 2, "diagtrap");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SET_DIAG_ASS, 0);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.diagass.subcmd_len = 80;
 	cmd->data.diagass.subcmd = QETH_DIAGS_CMD_TRAP;
@@ -4194,6 +4219,8 @@ void qeth_setadp_promisc_mode(struct qeth_card *card)
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_PROMISC_MODE,
 			sizeof(struct qeth_ipacmd_setadpparms));
+	if (!iob)
+		return;
 	cmd = (struct qeth_ipa_cmd *)(iob->data + IPA_PDU_HEADER_SIZE);
 	cmd->data.setadapterparms.data.mode = mode;
 	qeth_send_ipa_cmd(card, iob, qeth_setadp_promisc_mode_cb, NULL);
@@ -4264,6 +4291,8 @@ int qeth_setadpparms_change_macaddr(struct qeth_card *card)
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_ALTER_MAC_ADDRESS,
 				   sizeof(struct qeth_ipacmd_setadpparms));
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setadapterparms.data.change_addr.cmd = CHANGE_ADDR_READ_MAC;
 	cmd->data.setadapterparms.data.change_addr.addr_size = OSA_ADDR_LEN;
@@ -4377,6 +4406,8 @@ static int qeth_setadpparms_set_access_ctrl(struct qeth_card *card,
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_ACCESS_CONTROL,
 				   sizeof(struct qeth_ipacmd_setadpparms_hdr) +
 				   sizeof(struct qeth_set_access_ctrl));
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	access_ctrl_req = &cmd->data.setadapterparms.data.set_access_ctrl;
 	access_ctrl_req->subcmd_code = isolation;
@@ -4620,6 +4651,10 @@ int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_SET_SNMP_CONTROL,
 				   QETH_SNMP_SETADP_CMDLENGTH + req_len);
+	if (!iob) {
+		rc = -ENOMEM;
+		goto out;
+	}
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	memcpy(&cmd->data.setadapterparms.data.snmp, &ureq->cmd, req_len);
 	rc = qeth_send_ipa_snmp_cmd(card, iob, QETH_SETADP_BASE_LEN + req_len,
@@ -4631,7 +4666,7 @@ int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 		if (copy_to_user(udata, qinfo.udata, qinfo.udata_len))
 			rc = -EFAULT;
 	}
-
+out:
 	kfree(ureq);
 	kfree(qinfo.udata);
 	return rc;
@@ -4702,6 +4737,10 @@ int qeth_query_oat_command(struct qeth_card *card, char __user *udata)
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_OAT,
 				   sizeof(struct qeth_ipacmd_setadpparms_hdr) +
 				   sizeof(struct qeth_query_oat));
+	if (!iob) {
+		rc = -ENOMEM;
+		goto out_free;
+	}
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	oat_req = &cmd->data.setadapterparms.data.query_oat;
 	oat_req->subcmd_code = oat_data.command;
@@ -4767,6 +4806,8 @@ static int qeth_query_card_info(struct qeth_card *card,
 		return -EOPNOTSUPP;
 	iob = qeth_get_adapter_cmd(card, IPA_SETADP_QUERY_CARD_INFO,
 		sizeof(struct qeth_ipacmd_setadpparms_hdr));
+	if (!iob)
+		return -ENOMEM;
 	return qeth_send_ipa_cmd(card, iob, qeth_query_card_info_cb,
 					(void *)carrier_info);
 }
@@ -5092,11 +5133,23 @@ retriable:
 	card->options.adp.supported_funcs = 0;
 	card->options.sbp.supported_funcs = 0;
 	card->info.diagass_support = 0;
-	qeth_query_ipassists(card, QETH_PROT_IPV4);
-	if (qeth_is_supported(card, IPA_SETADAPTERPARMS))
-		qeth_query_setadapterparms(card);
-	if (qeth_adp_supported(card, IPA_SETADP_SET_DIAG_ASSIST))
-		qeth_query_setdiagass(card);
+	rc = qeth_query_ipassists(card, QETH_PROT_IPV4);
+	if (rc == -ENOMEM)
+		goto out;
+	if (qeth_is_supported(card, IPA_SETADAPTERPARMS)) {
+		rc = qeth_query_setadapterparms(card);
+		if (rc < 0) {
+			QETH_DBF_TEXT_(SETUP, 2, "6err%d", rc);
+			goto out;
+		}
+	}
+	if (qeth_adp_supported(card, IPA_SETADP_SET_DIAG_ASSIST)) {
+		rc = qeth_query_setdiagass(card);
+		if (rc < 0) {
+			QETH_DBF_TEXT_(SETUP, 2, "7err%d", rc);
+			goto out;
+		}
+	}
 	return 0;
 out:
 	dev_warn(&card->gdev->dev, "The qeth device driver failed to recover "
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index b7b9d5c..ce87ae7 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -132,7 +132,7 @@ static int qeth_setdel_makerc(struct qeth_card *card, int retcode)
 	int rc;
 
 	if (retcode)
-		QETH_CARD_TEXT_(card, 2, "err%d", retcode);
+		QETH_CARD_TEXT_(card, 2, "err%04x", retcode);
 	switch (retcode) {
 	case IPA_RC_SUCCESS:
 		rc = 0;
@@ -154,6 +154,9 @@ static int qeth_setdel_makerc(struct qeth_card *card, int retcode)
 	case IPA_RC_L2_MAC_NOT_FOUND:
 		rc = -ENOENT;
 		break;
+	case -ENOMEM:
+		rc = -ENOMEM;
+		break;
 	default:
 		rc = -EIO;
 		break;
@@ -301,6 +304,8 @@ static int qeth_l2_send_setdelvlan(struct qeth_card *card, __u16 i,
 
 	QETH_CARD_TEXT_(card, 4, "L2sdv%x", ipacmd);
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelvlan.vlan_id = i;
 	return qeth_send_ipa_cmd(card, iob,
@@ -323,6 +328,7 @@ static int qeth_l2_vlan_rx_add_vid(struct net_device *dev,
 {
 	struct qeth_card *card = dev->ml_priv;
 	struct qeth_vlan_vid *id;
+	int rc;
 
 	QETH_CARD_TEXT_(card, 4, "aid:%d", vid);
 	if (!vid)
@@ -338,7 +344,11 @@ static int qeth_l2_vlan_rx_add_vid(struct net_device *dev,
 	id = kmalloc(sizeof(struct qeth_vlan_vid), GFP_ATOMIC);
 	if (id) {
 		id->vid = vid;
-		qeth_l2_send_setdelvlan(card, vid, IPA_CMD_SETVLAN);
+		rc = qeth_l2_send_setdelvlan(card, vid, IPA_CMD_SETVLAN);
+		if (rc) {
+			kfree(id);
+			return rc;
+		}
 		spin_lock_bh(&card->vlanlock);
 		list_add_tail(&id->list, &card->vid_list);
 		spin_unlock_bh(&card->vlanlock);
@@ -353,6 +363,7 @@ static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev,
 {
 	struct qeth_vlan_vid *id, *tmpid = NULL;
 	struct qeth_card *card = dev->ml_priv;
+	int rc = 0;
 
 	QETH_CARD_TEXT_(card, 4, "kid:%d", vid);
 	if (card->info.type == QETH_CARD_TYPE_OSM) {
@@ -373,11 +384,11 @@ static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev,
 	}
 	spin_unlock_bh(&card->vlanlock);
 	if (tmpid) {
-		qeth_l2_send_setdelvlan(card, vid, IPA_CMD_DELVLAN);
+		rc = qeth_l2_send_setdelvlan(card, vid, IPA_CMD_DELVLAN);
 		kfree(tmpid);
 	}
 	qeth_l2_set_multicast_list(card->dev);
-	return 0;
+	return rc;
 }
 
 static int qeth_l2_stop_card(struct qeth_card *card, int recovery_mode)
@@ -556,6 +567,8 @@ static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
 
 	QETH_CARD_TEXT(card, 2, "L2sdmac");
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, QETH_PROT_IPV4);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
 	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
@@ -630,7 +643,7 @@ static int qeth_l2_request_initial_mac(struct qeth_card *card)
 		if (rc) {
 			QETH_DBF_MESSAGE(2, "couldn't get MAC address on "
 				"device %s: x%x\n", CARD_BUS_ID(card), rc);
-			QETH_DBF_TEXT_(SETUP, 2, "1err%d", rc);
+			QETH_DBF_TEXT_(SETUP, 2, "1err%04x", rc);
 			return rc;
 		}
 		QETH_DBF_HEX(SETUP, 2, card->dev->dev_addr, OSA_ADDR_LEN);
@@ -975,7 +988,7 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	recover_flag = card->state;
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%04x", rc);
 		rc = -ENODEV;
 		goto out_remove;
 	}
@@ -1709,6 +1722,8 @@ static void qeth_bridgeport_query_support(struct qeth_card *card)
 
 	QETH_CARD_TEXT(card, 2, "brqsuppo");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETBRIDGEPORT, 0);
+	if (!iob)
+		return;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.sbp.hdr.cmdlength =
 		sizeof(struct qeth_ipacmd_sbp_hdr) +
@@ -1784,6 +1799,8 @@ int qeth_bridgeport_query_ports(struct qeth_card *card,
 	if (!(card->options.sbp.supported_funcs & IPA_SBP_QUERY_BRIDGE_PORTS))
 		return -EOPNOTSUPP;
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETBRIDGEPORT, 0);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.sbp.hdr.cmdlength =
 		sizeof(struct qeth_ipacmd_sbp_hdr);
@@ -1796,9 +1813,7 @@ int qeth_bridgeport_query_ports(struct qeth_card *card,
 	if (rc)
 		return rc;
 	rc = qeth_bridgeport_makerc(card, &cbctl, IPA_SBP_QUERY_BRIDGE_PORTS);
-	if (rc)
-		return rc;
-	return 0;
+	return rc;
 }
 EXPORT_SYMBOL_GPL(qeth_bridgeport_query_ports);
 
@@ -1852,6 +1867,8 @@ int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role)
 	if (!(card->options.sbp.supported_funcs & setcmd))
 		return -EOPNOTSUPP;
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETBRIDGEPORT, 0);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.sbp.hdr.cmdlength = cmdlength;
 	cmd->data.sbp.hdr.command_code = setcmd;
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 625227ad..e2a0ee8 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -549,6 +549,8 @@ static int qeth_l3_send_setdelmc(struct qeth_card *card,
 	QETH_CARD_TEXT(card, 4, "setdelmc");
 
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	memcpy(&cmd->data.setdelipm.mac, addr->mac, OSA_ADDR_LEN);
 	if (addr->proto == QETH_PROT_IPV6)
@@ -588,6 +590,8 @@ static int qeth_l3_send_setdelip(struct qeth_card *card,
 	QETH_CARD_TEXT_(card, 4, "flags%02X", flags);
 
 	iob = qeth_get_ipacmd_buffer(card, ipacmd, addr->proto);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	if (addr->proto == QETH_PROT_IPV6) {
 		memcpy(cmd->data.setdelip6.ip_addr, &addr->u.a6.addr,
@@ -616,6 +620,8 @@ static int qeth_l3_send_setrouting(struct qeth_card *card,
 
 	QETH_CARD_TEXT(card, 4, "setroutg");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETRTG, prot);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setrtg.type = (type);
 	rc = qeth_send_ipa_cmd(card, iob, NULL, NULL);
@@ -1049,12 +1055,14 @@ static struct qeth_cmd_buffer *qeth_l3_get_setassparms_cmd(
 	QETH_CARD_TEXT(card, 4, "getasscm");
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SETASSPARMS, prot);
 
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	cmd->data.setassparms.hdr.assist_no = ipa_func;
-	cmd->data.setassparms.hdr.length = 8 + len;
-	cmd->data.setassparms.hdr.command_code = cmd_code;
-	cmd->data.setassparms.hdr.return_code = 0;
-	cmd->data.setassparms.hdr.seq_no = 0;
+	if (iob) {
+		cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+		cmd->data.setassparms.hdr.assist_no = ipa_func;
+		cmd->data.setassparms.hdr.length = 8 + len;
+		cmd->data.setassparms.hdr.command_code = cmd_code;
+		cmd->data.setassparms.hdr.return_code = 0;
+		cmd->data.setassparms.hdr.seq_no = 0;
+	}
 
 	return iob;
 }
@@ -1090,6 +1098,8 @@ static int qeth_l3_send_simple_setassparms_ipv6(struct qeth_card *card,
 	QETH_CARD_TEXT(card, 4, "simassp6");
 	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
 				       0, QETH_PROT_IPV6);
+	if (!iob)
+		return -ENOMEM;
 	rc = qeth_l3_send_setassparms(card, iob, 0, 0,
 				   qeth_l3_default_setassparms_cb, NULL);
 	return rc;
@@ -1108,6 +1118,8 @@ static int qeth_l3_send_simple_setassparms(struct qeth_card *card,
 		length = sizeof(__u32);
 	iob = qeth_l3_get_setassparms_cmd(card, ipa_func, cmd_code,
 				       length, QETH_PROT_IPV4);
+	if (!iob)
+		return -ENOMEM;
 	rc = qeth_l3_send_setassparms(card, iob, length, data,
 				   qeth_l3_default_setassparms_cb, NULL);
 	return rc;
@@ -1494,6 +1506,8 @@ static int qeth_l3_iqd_read_initial_mac(struct qeth_card *card)
 
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_CREATE_ADDR,
 				     QETH_PROT_IPV6);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	*((__u16 *) &cmd->data.create_destroy_addr.unique_id[6]) =
 			card->info.unique_id;
@@ -1537,6 +1551,8 @@ static int qeth_l3_get_unique_id(struct qeth_card *card)
 
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_CREATE_ADDR,
 				     QETH_PROT_IPV6);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	*((__u16 *) &cmd->data.create_destroy_addr.unique_id[6]) =
 			card->info.unique_id;
@@ -1611,6 +1627,8 @@ qeth_diags_trace(struct qeth_card *card, enum qeth_diags_trace_cmds diags_cmd)
 	QETH_DBF_TEXT(SETUP, 2, "diagtrac");
 
 	iob = qeth_get_ipacmd_buffer(card, IPA_CMD_SET_DIAG_ASS, 0);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.diagass.subcmd_len = 16;
 	cmd->data.diagass.subcmd = QETH_DIAGS_CMD_TRACE;
@@ -2442,6 +2460,8 @@ static int qeth_l3_query_arp_cache_info(struct qeth_card *card,
 			IPA_CMD_ASS_ARP_QUERY_INFO,
 			sizeof(struct qeth_arp_query_data) - sizeof(char),
 			prot);
+	if (!iob)
+		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setassparms.data.query_arp.request_bits = 0x000F;
 	cmd->data.setassparms.data.query_arp.reply_bits = 0;
@@ -2535,6 +2555,8 @@ static int qeth_l3_arp_add_entry(struct qeth_card *card,
 				       IPA_CMD_ASS_ARP_ADD_ENTRY,
 				       sizeof(struct qeth_arp_cache_entry),
 				       QETH_PROT_IPV4);
+	if (!iob)
+		return -ENOMEM;
 	rc = qeth_l3_send_setassparms(card, iob,
 				   sizeof(struct qeth_arp_cache_entry),
 				   (unsigned long) entry,
@@ -2574,6 +2596,8 @@ static int qeth_l3_arp_remove_entry(struct qeth_card *card,
 				       IPA_CMD_ASS_ARP_REMOVE_ENTRY,
 				       12,
 				       QETH_PROT_IPV4);
+	if (!iob)
+		return -ENOMEM;
 	rc = qeth_l3_send_setassparms(card, iob,
 				   12, (unsigned long)buf,
 				   qeth_l3_default_setassparms_cb, NULL);
@@ -3262,6 +3286,8 @@ static const struct net_device_ops qeth_l3_osa_netdev_ops = {
 
 static int qeth_l3_setup_netdev(struct qeth_card *card)
 {
+	int rc;
+
 	if (card->info.type == QETH_CARD_TYPE_OSD ||
 	    card->info.type == QETH_CARD_TYPE_OSX) {
 		if ((card->info.link_type == QETH_LINK_TYPE_LANE_TR) ||
@@ -3293,7 +3319,9 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 			return -ENODEV;
 		card->dev->flags |= IFF_NOARP;
 		card->dev->netdev_ops = &qeth_l3_netdev_ops;
-		qeth_l3_iqd_read_initial_mac(card);
+		rc = qeth_l3_iqd_read_initial_mac(card);
+		if (rc)
+			return rc;
 		if (card->options.hsuid[0])
 			memcpy(card->dev->perm_addr, card->options.hsuid, 9);
 	} else
@@ -3360,7 +3388,7 @@ static int __qeth_l3_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 	recover_flag = card->state;
 	rc = qeth_core_hardsetup_card(card);
 	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%04x", rc);
 		rc = -ENODEV;
 		goto out_remove;
 	}
@@ -3401,7 +3429,7 @@ static int __qeth_l3_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 contin:
 	rc = qeth_l3_setadapter_parms(card);
 	if (rc)
-		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
+		QETH_DBF_TEXT_(SETUP, 2, "2err%04x", rc);
 	if (!card->options.sniffer) {
 		rc = qeth_l3_start_ipassists(card);
 		if (rc) {
@@ -3410,10 +3438,10 @@ contin:
 		}
 		rc = qeth_l3_setrouting_v4(card);
 		if (rc)
-			QETH_DBF_TEXT_(SETUP, 2, "4err%d", rc);
+			QETH_DBF_TEXT_(SETUP, 2, "4err%04x", rc);
 		rc = qeth_l3_setrouting_v6(card);
 		if (rc)
-			QETH_DBF_TEXT_(SETUP, 2, "5err%d", rc);
+			QETH_DBF_TEXT_(SETUP, 2, "5err%04x", rc);
 	}
 	netif_tx_disable(card->dev);
 
-- 
2.1.4

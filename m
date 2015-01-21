From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/2] qeth: clean up error handling
Date: Wed, 21 Jan 2015 13:39:09 +0100
Message-ID: <1421843950-58220-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1421843950-58220-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Eugene Crosser <Eugene.Crosser@ru.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp15.uk.ibm.com ([195.75.94.111]:56335 "EHLO
	e06smtp15.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462AbbAUMjf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Jan 2015 07:39:35 -0500
Received: from /spool/local
	by e06smtp15.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Wed, 21 Jan 2015 12:39:33 -0000
In-Reply-To: <1421843950-58220-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eugene Crosser <Eugene.Crosser@ru.ibm.com>

In the functions that are registering and unregistering MAC
addresses in the qeth-handled hardware, remove callback functions
that are unnesessary, as only the return code is analyzed.
Translate hardware response codes to semi-standard 'errno'-like
codes for readability.

Add kernel-doc description to the internal API function
qeth_send_control_data().

Signed-off-by: Eugene Crosser <Eugene.Crosser@ru.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Reviewed-by: Thomas-Mich Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |  36 +++++++-
 drivers/s390/net/qeth_l2_main.c   | 187 +++++++++++++++++---------------------
 2 files changed, 117 insertions(+), 106 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index f407e37..e2fbfff 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2021,10 +2021,36 @@ void qeth_prepare_control_data(struct qeth_card *card, int len,
 }
 EXPORT_SYMBOL_GPL(qeth_prepare_control_data);
 
+/**
+ * qeth_send_control_data() -	send control command to the card
+ * @card:			qeth_card structure pointer
+ * @len:			size of the command buffer
+ * @iob:			qeth_cmd_buffer pointer
+ * @reply_cb:			callback function pointer
+ * @cb_card:			pointer to the qeth_card structure
+ * @cb_reply:			pointer to the qeth_reply structure
+ * @cb_cmd:			pointer to the original iob for non-IPA
+ *				commands, or to the qeth_ipa_cmd structure
+ *				for the IPA commands.
+ * @reply_param:		private pointer passed to the callback
+ *
+ * Returns the value of the `return_code' field of the response
+ * block returned from the hardware, or other error indication.
+ * Value of zero indicates successful execution of the command.
+ *
+ * Callback function gets called one or more times, with cb_cmd
+ * pointing to the response returned by the hardware. Callback
+ * function must return non-zero if more reply blocks are expected,
+ * and zero if the last or only reply block is received. Callback
+ * function can get the value of the reply_param pointer from the
+ * field 'param' of the structure qeth_reply.
+ */
+
 int qeth_send_control_data(struct qeth_card *card, int len,
 		struct qeth_cmd_buffer *iob,
-		int (*reply_cb)(struct qeth_card *, struct qeth_reply *,
-			unsigned long),
+		int (*reply_cb)(struct qeth_card *cb_card,
+				struct qeth_reply *cb_reply,
+				unsigned long cb_cmd),
 		void *reply_param)
 {
 	int rc;
@@ -2932,6 +2958,12 @@ void qeth_prepare_ipa_cmd(struct qeth_card *card, struct qeth_cmd_buffer *iob,
 }
 EXPORT_SYMBOL_GPL(qeth_prepare_ipa_cmd);
 
+/**
+ * qeth_send_ipa_cmd() - send an IPA command
+ *
+ * See qeth_send_control_data() for explanation of the arguments.
+ */
+
 int qeth_send_ipa_cmd(struct qeth_card *card, struct qeth_cmd_buffer *iob,
 		int (*reply_cb)(struct qeth_card *, struct qeth_reply*,
 			unsigned long),
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index d02cd1a..b7b9d5c 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -27,10 +27,7 @@ static int qeth_l2_set_offline(struct ccwgroup_device *);
 static int qeth_l2_stop(struct net_device *);
 static int qeth_l2_send_delmac(struct qeth_card *, __u8 *);
 static int qeth_l2_send_setdelmac(struct qeth_card *, __u8 *,
-			   enum qeth_ipa_cmds,
-			   int (*reply_cb) (struct qeth_card *,
-					    struct qeth_reply*,
-					    unsigned long));
+			   enum qeth_ipa_cmds);
 static void qeth_l2_set_multicast_list(struct net_device *);
 static int qeth_l2_recover(void *);
 static void qeth_bridgeport_query_support(struct qeth_card *card);
@@ -130,56 +127,68 @@ static struct net_device *qeth_l2_netdev_by_devno(unsigned char *read_dev_no)
 	return ndev;
 }
 
-static int qeth_l2_send_setgroupmac_cb(struct qeth_card *card,
-				struct qeth_reply *reply,
-				unsigned long data)
+static int qeth_setdel_makerc(struct qeth_card *card, int retcode)
 {
-	struct qeth_ipa_cmd *cmd;
-	__u8 *mac;
+	int rc;
 
-	QETH_CARD_TEXT(card, 2, "L2Sgmacb");
-	cmd = (struct qeth_ipa_cmd *) data;
-	mac = &cmd->data.setdelmac.mac[0];
-	/* MAC already registered, needed in couple/uncouple case */
-	if (cmd->hdr.return_code ==  IPA_RC_L2_DUP_MAC) {
-		QETH_DBF_MESSAGE(2, "Group MAC %pM already existing on %s \n",
-			  mac, QETH_CARD_IFNAME(card));
-		cmd->hdr.return_code = 0;
+	if (retcode)
+		QETH_CARD_TEXT_(card, 2, "err%d", retcode);
+	switch (retcode) {
+	case IPA_RC_SUCCESS:
+		rc = 0;
+		break;
+	case IPA_RC_L2_UNSUPPORTED_CMD:
+		rc = -ENOSYS;
+		break;
+	case IPA_RC_L2_ADDR_TABLE_FULL:
+		rc = -ENOSPC;
+		break;
+	case IPA_RC_L2_DUP_MAC:
+	case IPA_RC_L2_DUP_LAYER3_MAC:
+		rc = -EEXIST;
+		break;
+	case IPA_RC_L2_MAC_NOT_AUTH_BY_HYP:
+	case IPA_RC_L2_MAC_NOT_AUTH_BY_ADP:
+		rc = -EPERM;
+		break;
+	case IPA_RC_L2_MAC_NOT_FOUND:
+		rc = -ENOENT;
+		break;
+	default:
+		rc = -EIO;
+		break;
 	}
-	if (cmd->hdr.return_code)
-		QETH_DBF_MESSAGE(2, "Could not set group MAC %pM on %s: %x\n",
-			  mac, QETH_CARD_IFNAME(card), cmd->hdr.return_code);
-	return 0;
+	return rc;
 }
 
 static int qeth_l2_send_setgroupmac(struct qeth_card *card, __u8 *mac)
 {
-	QETH_CARD_TEXT(card, 2, "L2Sgmac");
-	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETGMAC,
-					  qeth_l2_send_setgroupmac_cb);
-}
-
-static int qeth_l2_send_delgroupmac_cb(struct qeth_card *card,
-				struct qeth_reply *reply,
-				unsigned long data)
-{
-	struct qeth_ipa_cmd *cmd;
-	__u8 *mac;
+	int rc;
 
-	QETH_CARD_TEXT(card, 2, "L2Dgmacb");
-	cmd = (struct qeth_ipa_cmd *) data;
-	mac = &cmd->data.setdelmac.mac[0];
-	if (cmd->hdr.return_code)
-		QETH_DBF_MESSAGE(2, "Could not delete group MAC %pM on %s: %x\n",
-			  mac, QETH_CARD_IFNAME(card), cmd->hdr.return_code);
-	return 0;
+	QETH_CARD_TEXT(card, 2, "L2Sgmac");
+	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
+					IPA_CMD_SETGMAC));
+	if (rc == -EEXIST)
+		QETH_DBF_MESSAGE(2, "Group MAC %pM already existing on %s\n",
+			mac, QETH_CARD_IFNAME(card));
+	else if (rc)
+		QETH_DBF_MESSAGE(2, "Could not set group MAC %pM on %s: %d\n",
+			mac, QETH_CARD_IFNAME(card), rc);
+	return rc;
 }
 
 static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
 {
+	int rc;
+
 	QETH_CARD_TEXT(card, 2, "L2Dgmac");
-	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELGMAC,
-					  qeth_l2_send_delgroupmac_cb);
+	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
+					IPA_CMD_DELGMAC));
+	if (rc)
+		QETH_DBF_MESSAGE(2,
+			"Could not delete group MAC %pM on %s: %d\n",
+			mac, QETH_CARD_IFNAME(card), rc);
+	return rc;
 }
 
 static void qeth_l2_add_mc(struct qeth_card *card, __u8 *mac, int vmac)
@@ -197,10 +206,11 @@ static void qeth_l2_add_mc(struct qeth_card *card, __u8 *mac, int vmac)
 	mc->is_vmac = vmac;
 
 	if (vmac) {
-		rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC,
-					NULL);
+		rc = qeth_setdel_makerc(card,
+			qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC));
 	} else {
-		rc = qeth_l2_send_setgroupmac(card, mac);
+		rc = qeth_setdel_makerc(card,
+			qeth_l2_send_setgroupmac(card, mac));
 	}
 
 	if (!rc)
@@ -218,7 +228,7 @@ static void qeth_l2_del_all_mc(struct qeth_card *card, int del)
 		if (del) {
 			if (mc->is_vmac)
 				qeth_l2_send_setdelmac(card, mc->mc_addr,
-					IPA_CMD_DELVMAC, NULL);
+					IPA_CMD_DELVMAC);
 			else
 				qeth_l2_send_delgroupmac(card, mc->mc_addr);
 		}
@@ -539,10 +549,7 @@ out:
 }
 
 static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
-			   enum qeth_ipa_cmds ipacmd,
-			   int (*reply_cb) (struct qeth_card *,
-					    struct qeth_reply*,
-					    unsigned long))
+			   enum qeth_ipa_cmds ipacmd)
 {
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
@@ -552,78 +559,50 @@ static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
 	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
-	return qeth_send_ipa_cmd(card, iob, reply_cb, NULL);
+	return qeth_send_ipa_cmd(card, iob, NULL, NULL);
 }
 
-static int qeth_l2_send_setmac_cb(struct qeth_card *card,
-			   struct qeth_reply *reply,
-			   unsigned long data)
+static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
 {
-	struct qeth_ipa_cmd *cmd;
+	int rc;
 
-	QETH_CARD_TEXT(card, 2, "L2Smaccb");
-	cmd = (struct qeth_ipa_cmd *) data;
-	if (cmd->hdr.return_code) {
-		QETH_CARD_TEXT_(card, 2, "L2er%x", cmd->hdr.return_code);
+	QETH_CARD_TEXT(card, 2, "L2Setmac");
+	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
+					IPA_CMD_SETVMAC));
+	if (rc == 0) {
+		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
+		memcpy(card->dev->dev_addr, mac, OSA_ADDR_LEN);
+		dev_info(&card->gdev->dev,
+			"MAC address %pM successfully registered on device %s\n",
+			card->dev->dev_addr, card->dev->name);
+	} else {
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
-		switch (cmd->hdr.return_code) {
-		case IPA_RC_L2_DUP_MAC:
-		case IPA_RC_L2_DUP_LAYER3_MAC:
+		switch (rc) {
+		case -EEXIST:
 			dev_warn(&card->gdev->dev,
-				"MAC address %pM already exists\n",
-				cmd->data.setdelmac.mac);
+				"MAC address %pM already exists\n", mac);
 			break;
-		case IPA_RC_L2_MAC_NOT_AUTH_BY_HYP:
-		case IPA_RC_L2_MAC_NOT_AUTH_BY_ADP:
+		case -EPERM:
 			dev_warn(&card->gdev->dev,
-				"MAC address %pM is not authorized\n",
-				cmd->data.setdelmac.mac);
-			break;
-		default:
+				"MAC address %pM is not authorized\n", mac);
 			break;
 		}
-	} else {
-		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
-		memcpy(card->dev->dev_addr, cmd->data.setdelmac.mac,
-		       OSA_ADDR_LEN);
-		dev_info(&card->gdev->dev,
-			"MAC address %pM successfully registered on device %s\n",
-			card->dev->dev_addr, card->dev->name);
 	}
-	return 0;
-}
-
-static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
-{
-	QETH_CARD_TEXT(card, 2, "L2Setmac");
-	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC,
-					  qeth_l2_send_setmac_cb);
-}
-
-static int qeth_l2_send_delmac_cb(struct qeth_card *card,
-			   struct qeth_reply *reply,
-			   unsigned long data)
-{
-	struct qeth_ipa_cmd *cmd;
-
-	QETH_CARD_TEXT(card, 2, "L2Dmaccb");
-	cmd = (struct qeth_ipa_cmd *) data;
-	if (cmd->hdr.return_code) {
-		QETH_CARD_TEXT_(card, 2, "err%d", cmd->hdr.return_code);
-		return 0;
-	}
-	card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
-
-	return 0;
+	return rc;
 }
 
 static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
 {
+	int rc;
+
 	QETH_CARD_TEXT(card, 2, "L2Delmac");
 	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
 		return 0;
-	return qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC,
-					  qeth_l2_send_delmac_cb);
+	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
+					IPA_CMD_DELVMAC));
+	if (rc == 0)
+		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
+	return rc;
 }
 
 static int qeth_l2_request_initial_mac(struct qeth_card *card)
@@ -687,7 +666,7 @@ static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
 		return -ERESTARTSYS;
 	}
 	rc = qeth_l2_send_delmac(card, &card->dev->dev_addr[0]);
-	if (!rc || (rc == IPA_RC_L2_MAC_NOT_FOUND))
+	if (!rc || (rc == -ENOENT))
 		rc = qeth_l2_send_setmac(card, addr->sa_data);
 	return rc ? -EINVAL : 0;
 }
-- 
2.1.4

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 09/12] s390/qeth: extract bridgeport cmd builder
Date: Tue, 15 Aug 2017 17:02:47 +0200
Message-ID: <20170815150250.67158-10-jwi@linux.vnet.ibm.com>
References: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:45960 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1752670AbdHOPDO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 11:03:14 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v7FExMrc042294
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:14 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2cbrdmwmyj-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 11:03:13 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 15 Aug 2017 16:03:11 +0100
In-Reply-To: <20170815150250.67158-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Consolidation of duplicated code, no functional change.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 62 +++++++++++++++++------------------------
 1 file changed, 26 insertions(+), 36 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 368fb85d8851..438a7f29e99f 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1724,11 +1724,26 @@ static int qeth_bridgeport_makerc(struct qeth_card *card,
 	return rc;
 }
 
-static inline int ipa_cmd_sbp(struct qeth_card *card)
+static struct qeth_cmd_buffer *qeth_sbp_build_cmd(struct qeth_card *card,
+						  enum qeth_ipa_sbp_cmd sbp_cmd,
+						  unsigned int cmd_length)
 {
-	return (card->info.type == QETH_CARD_TYPE_IQD) ?
-		IPA_CMD_SETBRIDGEPORT_IQD :
-		IPA_CMD_SETBRIDGEPORT_OSA;
+	enum qeth_ipa_cmds ipa_cmd = (card->info.type == QETH_CARD_TYPE_IQD) ?
+					IPA_CMD_SETBRIDGEPORT_IQD :
+					IPA_CMD_SETBRIDGEPORT_OSA;
+	struct qeth_cmd_buffer *iob;
+	struct qeth_ipa_cmd *cmd;
+
+	iob = qeth_get_ipacmd_buffer(card, ipa_cmd, 0);
+	if (!iob)
+		return iob;
+	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
+	cmd->data.sbp.hdr.cmdlength = sizeof(struct qeth_ipacmd_sbp_hdr) +
+				      cmd_length;
+	cmd->data.sbp.hdr.command_code = sbp_cmd;
+	cmd->data.sbp.hdr.used_total = 1;
+	cmd->data.sbp.hdr.seq_no = 1;
+	return iob;
 }
 
 static int qeth_bridgeport_query_support_cb(struct qeth_card *card,
@@ -1758,21 +1773,13 @@ static int qeth_bridgeport_query_support_cb(struct qeth_card *card,
 static void qeth_bridgeport_query_support(struct qeth_card *card)
 {
 	struct qeth_cmd_buffer *iob;
-	struct qeth_ipa_cmd *cmd;
 	struct _qeth_sbp_cbctl cbctl;
 
 	QETH_CARD_TEXT(card, 2, "brqsuppo");
-	iob = qeth_get_ipacmd_buffer(card, ipa_cmd_sbp(card), 0);
+	iob = qeth_sbp_build_cmd(card, IPA_SBP_QUERY_COMMANDS_SUPPORTED,
+				 sizeof(struct qeth_sbp_query_cmds_supp));
 	if (!iob)
 		return;
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	cmd->data.sbp.hdr.cmdlength =
-		sizeof(struct qeth_ipacmd_sbp_hdr) +
-		sizeof(struct qeth_sbp_query_cmds_supp);
-	cmd->data.sbp.hdr.command_code =
-		IPA_SBP_QUERY_COMMANDS_SUPPORTED;
-	cmd->data.sbp.hdr.used_total = 1;
-	cmd->data.sbp.hdr.seq_no = 1;
 	if (qeth_send_ipa_cmd(card, iob, qeth_bridgeport_query_support_cb,
 							(void *)&cbctl) ||
 	    qeth_bridgeport_makerc(card, &cbctl,
@@ -1826,7 +1833,6 @@ int qeth_bridgeport_query_ports(struct qeth_card *card,
 {
 	int rc = 0;
 	struct qeth_cmd_buffer *iob;
-	struct qeth_ipa_cmd *cmd;
 	struct _qeth_sbp_cbctl cbctl = {
 		.data = {
 			.qports = {
@@ -1839,16 +1845,9 @@ int qeth_bridgeport_query_ports(struct qeth_card *card,
 	QETH_CARD_TEXT(card, 2, "brqports");
 	if (!(card->options.sbp.supported_funcs & IPA_SBP_QUERY_BRIDGE_PORTS))
 		return -EOPNOTSUPP;
-	iob = qeth_get_ipacmd_buffer(card, ipa_cmd_sbp(card), 0);
+	iob = qeth_sbp_build_cmd(card, IPA_SBP_QUERY_BRIDGE_PORTS, 0);
 	if (!iob)
 		return -ENOMEM;
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	cmd->data.sbp.hdr.cmdlength =
-		sizeof(struct qeth_ipacmd_sbp_hdr);
-	cmd->data.sbp.hdr.command_code =
-		IPA_SBP_QUERY_BRIDGE_PORTS;
-	cmd->data.sbp.hdr.used_total = 1;
-	cmd->data.sbp.hdr.seq_no = 1;
 	rc = qeth_send_ipa_cmd(card, iob, qeth_bridgeport_query_ports_cb,
 				(void *)&cbctl);
 	if (rc < 0)
@@ -1880,7 +1879,6 @@ int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role)
 	int rc = 0;
 	int cmdlength;
 	struct qeth_cmd_buffer *iob;
-	struct qeth_ipa_cmd *cmd;
 	struct _qeth_sbp_cbctl cbctl;
 	enum qeth_ipa_sbp_cmd setcmd;
 
@@ -1888,32 +1886,24 @@ int qeth_bridgeport_setrole(struct qeth_card *card, enum qeth_sbp_roles role)
 	switch (role) {
 	case QETH_SBP_ROLE_NONE:
 		setcmd = IPA_SBP_RESET_BRIDGE_PORT_ROLE;
-		cmdlength =  sizeof(struct qeth_ipacmd_sbp_hdr) +
-			sizeof(struct qeth_sbp_reset_role);
+		cmdlength = sizeof(struct qeth_sbp_reset_role);
 		break;
 	case QETH_SBP_ROLE_PRIMARY:
 		setcmd = IPA_SBP_SET_PRIMARY_BRIDGE_PORT;
-		cmdlength =  sizeof(struct qeth_ipacmd_sbp_hdr) +
-			sizeof(struct qeth_sbp_set_primary);
+		cmdlength = sizeof(struct qeth_sbp_set_primary);
 		break;
 	case QETH_SBP_ROLE_SECONDARY:
 		setcmd = IPA_SBP_SET_SECONDARY_BRIDGE_PORT;
-		cmdlength =  sizeof(struct qeth_ipacmd_sbp_hdr) +
-			sizeof(struct qeth_sbp_set_secondary);
+		cmdlength = sizeof(struct qeth_sbp_set_secondary);
 		break;
 	default:
 		return -EINVAL;
 	}
 	if (!(card->options.sbp.supported_funcs & setcmd))
 		return -EOPNOTSUPP;
-	iob = qeth_get_ipacmd_buffer(card, ipa_cmd_sbp(card), 0);
+	iob = qeth_sbp_build_cmd(card, setcmd, cmdlength);
 	if (!iob)
 		return -ENOMEM;
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	cmd->data.sbp.hdr.cmdlength = cmdlength;
-	cmd->data.sbp.hdr.command_code = setcmd;
-	cmd->data.sbp.hdr.used_total = 1;
-	cmd->data.sbp.hdr.seq_no = 1;
 	rc = qeth_send_ipa_cmd(card, iob, qeth_bridgeport_set_cb,
 				(void *)&cbctl);
 	if (rc < 0)
-- 
2.11.2

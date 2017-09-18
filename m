From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 7/9] s390/qeth: translate SETVLAN/DELVLAN errors
Date: Mon, 18 Sep 2017 21:18:20 +0200
Message-ID: <20170918191822.65142-8-jwi@linux.vnet.ibm.com>
References: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:46815 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750772AbdIRTUZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 15:20:25 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v8IJKPj3038436
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:25 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2d2hwt8mg5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 15:20:21 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Mon, 18 Sep 2017 20:19:29 +0100
In-Reply-To: <20170918191822.65142-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Properly return any error encountered during VLAN processing to the
the caller.
Resulting change in behaviour: if SETVLAN fails while registering a
new VLAN ID, the stack no longer creates the corresponding vlan device.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_mpc.h |  1 +
 drivers/s390/net/qeth_l2_main.c  | 47 ++++++++++++++++++++++++++++++----------
 2 files changed, 36 insertions(+), 12 deletions(-)

diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 2f1f0da3d089..6a7654df6e78 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -166,6 +166,7 @@ enum qeth_ipa_return_codes {
 	IPA_RC_L2_INVALID_VLAN_ID	= 0x2015,
 	IPA_RC_L2_DUP_VLAN_ID		= 0x2016,
 	IPA_RC_L2_VLAN_ID_NOT_FOUND	= 0x2017,
+	IPA_RC_L2_VLAN_ID_NOT_ALLOWED	= 0x2050,
 	IPA_RC_VNICC_VNICBP		= 0x20B0,
 	IPA_RC_SBP_OSA_NOT_CONFIGURED	= 0x2B0C,
 	IPA_RC_SBP_OSA_OS_MISMATCH	= 0x2B10,
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 009de7248cc7..7b61c2ef4c74 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -78,7 +78,7 @@ static struct net_device *qeth_l2_netdev_by_devno(unsigned char *read_dev_no)
 	return ndev;
 }
 
-static int qeth_setdel_makerc(struct qeth_card *card, int retcode)
+static int qeth_setdelmac_makerc(struct qeth_card *card, int retcode)
 {
 	int rc;
 
@@ -128,8 +128,8 @@ static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
 	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
-	return qeth_setdel_makerc(card, qeth_send_ipa_cmd(card, iob,
-					NULL, NULL));
+	return qeth_setdelmac_makerc(card, qeth_send_ipa_cmd(card, iob,
+					   NULL, NULL));
 }
 
 static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
@@ -289,17 +289,40 @@ static void qeth_l2_fill_header(struct qeth_hdr *hdr, struct sk_buff *skb,
 	}
 }
 
+static int qeth_setdelvlan_makerc(struct qeth_card *card, int retcode)
+{
+	if (retcode)
+		QETH_CARD_TEXT_(card, 2, "err%04x", retcode);
+
+	switch (retcode) {
+	case IPA_RC_SUCCESS:
+		return 0;
+	case IPA_RC_L2_INVALID_VLAN_ID:
+		return -EINVAL;
+	case IPA_RC_L2_DUP_VLAN_ID:
+		return -EEXIST;
+	case IPA_RC_L2_VLAN_ID_NOT_FOUND:
+		return -ENOENT;
+	case IPA_RC_L2_VLAN_ID_NOT_ALLOWED:
+		return -EPERM;
+	case -ENOMEM:
+		return -ENOMEM;
+	default:
+		return -EIO;
+	}
+}
+
 static int qeth_l2_send_setdelvlan_cb(struct qeth_card *card,
-			struct qeth_reply *reply, unsigned long data)
+				      struct qeth_reply *reply,
+				      unsigned long data)
 {
-	struct qeth_ipa_cmd *cmd;
+	struct qeth_ipa_cmd *cmd = (struct qeth_ipa_cmd *) data;
 
 	QETH_CARD_TEXT(card, 2, "L2sdvcb");
-	cmd = (struct qeth_ipa_cmd *) data;
 	if (cmd->hdr.return_code) {
-		QETH_DBF_MESSAGE(2, "Error in processing VLAN %i on %s: 0x%x. "
-			  "Continuing\n", cmd->data.setdelvlan.vlan_id,
-			  QETH_CARD_IFNAME(card), cmd->hdr.return_code);
+		QETH_DBF_MESSAGE(2, "Error in processing VLAN %i on %s: 0x%x.\n",
+				 cmd->data.setdelvlan.vlan_id,
+				 QETH_CARD_IFNAME(card), cmd->hdr.return_code);
 		QETH_CARD_TEXT_(card, 2, "L2VL%4x", cmd->hdr.command);
 		QETH_CARD_TEXT_(card, 2, "err%d", cmd->hdr.return_code);
 	}
@@ -307,7 +330,7 @@ static int qeth_l2_send_setdelvlan_cb(struct qeth_card *card,
 }
 
 static int qeth_l2_send_setdelvlan(struct qeth_card *card, __u16 i,
-				enum qeth_ipa_cmds ipacmd)
+				   enum qeth_ipa_cmds ipacmd)
 {
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_cmd_buffer *iob;
@@ -318,8 +341,8 @@ static int qeth_l2_send_setdelvlan(struct qeth_card *card, __u16 i,
 		return -ENOMEM;
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelvlan.vlan_id = i;
-	return qeth_send_ipa_cmd(card, iob,
-				 qeth_l2_send_setdelvlan_cb, NULL);
+	return qeth_setdelvlan_makerc(card, qeth_send_ipa_cmd(card, iob,
+					    qeth_l2_send_setdelvlan_cb, NULL));
 }
 
 static void qeth_l2_process_vlans(struct qeth_card *card)
-- 
2.13.5

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 01/12] s390/qeth: rework RX/TX checksum offload
Date: Thu, 12 Jan 2017 15:48:32 +0100
Message-ID: <20170112144843.33463-2-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:60310 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750733AbdALOtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:06 -0500
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEmnw2103147
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:54 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27wrw71xyq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:54 -0500
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:48:52 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

Rework the RX/TX checksum offloading command sequence to use
the provided function call back mechanims to return card
data to the device driver.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  2 -
 drivers/s390/net/qeth_core_main.c | 96 ++++++++++++++++++++++++++-------------
 drivers/s390/net/qeth_core_mpc.h  |  7 +++
 3 files changed, 72 insertions(+), 33 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 6d4b68c4..41e4665 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -674,8 +674,6 @@ struct qeth_card_info {
 	int broadcast_capable;
 	int unique_id;
 	struct qeth_card_blkt blkt;
-	__u32 csum_mask;
-	__u32 tx_csum_mask;
 	enum qeth_ipa_promisc_modes promisc_mode;
 	__u32 diagass_support;
 	__u32 hwtrap;
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index e335583..5ab80ea 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -5289,18 +5289,6 @@ int qeth_setassparms_cb(struct qeth_card *card,
 		if (cmd->hdr.prot_version == QETH_PROT_IPV6)
 			card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
 	}
-	if (cmd->data.setassparms.hdr.assist_no == IPA_INBOUND_CHECKSUM &&
-	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
-		card->info.csum_mask = cmd->data.setassparms.data.flags_32bit;
-		QETH_CARD_TEXT_(card, 3, "csum:%d", card->info.csum_mask);
-	}
-	if (cmd->data.setassparms.hdr.assist_no == IPA_OUTBOUND_CHECKSUM &&
-	    cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
-		card->info.tx_csum_mask =
-			cmd->data.setassparms.data.flags_32bit;
-		QETH_CARD_TEXT_(card, 3, "tcsu:%d", card->info.tx_csum_mask);
-	}
-
 	return 0;
 }
 EXPORT_SYMBOL_GPL(qeth_setassparms_cb);
@@ -6060,23 +6048,78 @@ int qeth_core_ethtool_get_settings(struct net_device *netdev,
 }
 EXPORT_SYMBOL_GPL(qeth_core_ethtool_get_settings);
 
+/* Callback to handle checksum offload command reply from OSA card.
+ * Verify that required features have been enabled on the card.
+ * Return error in hdr->return_code as this value is checked by caller.
+ *
+ * Always returns zero to indicate no further messages from the OSA card.
+ */
+static int qeth_ipa_checksum_run_cmd_cb(struct qeth_card *card,
+					struct qeth_reply *reply,
+					unsigned long data)
+{
+	struct qeth_ipa_cmd *cmd = (struct qeth_ipa_cmd *) data;
+	struct qeth_checksum_cmd *chksum_cb =
+				(struct qeth_checksum_cmd *)reply->param;
+
+	QETH_CARD_TEXT(card, 4, "chkdoccb");
+	if (cmd->hdr.return_code)
+		return 0;
+
+	memset(chksum_cb, 0, sizeof(*chksum_cb));
+	if (cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_START) {
+		chksum_cb->supported =
+				cmd->data.setassparms.data.chksum.supported;
+		QETH_CARD_TEXT_(card, 3, "strt:%x", chksum_cb->supported);
+	}
+	if (cmd->data.setassparms.hdr.command_code == IPA_CMD_ASS_ENABLE) {
+		chksum_cb->supported =
+				cmd->data.setassparms.data.chksum.supported;
+		chksum_cb->enabled =
+				cmd->data.setassparms.data.chksum.enabled;
+		QETH_CARD_TEXT_(card, 3, "supp:%x", chksum_cb->supported);
+		QETH_CARD_TEXT_(card, 3, "enab:%x", chksum_cb->enabled);
+	}
+	return 0;
+}
+
+/* Send command to OSA card and check results. */
+static int qeth_ipa_checksum_run_cmd(struct qeth_card *card,
+				     enum qeth_ipa_funcs ipa_func,
+				     __u16 cmd_code, long data,
+				     struct qeth_checksum_cmd *chksum_cb)
+{
+	struct qeth_cmd_buffer *iob;
+	int rc = -ENOMEM;
+
+	QETH_CARD_TEXT(card, 4, "chkdocmd");
+	iob = qeth_get_setassparms_cmd(card, ipa_func, cmd_code,
+				       sizeof(__u32), QETH_PROT_IPV4);
+	if (iob)
+		rc = qeth_send_setassparms(card, iob, sizeof(__u32), data,
+					   qeth_ipa_checksum_run_cmd_cb,
+					   chksum_cb);
+	return rc;
+}
+
 static int qeth_send_checksum_on(struct qeth_card *card, int cstype)
 {
-	long rxtx_arg;
+	struct qeth_checksum_cmd chksum_cb;
 	int rc;
 
-	rc = qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_START, 0);
+	rc = qeth_ipa_checksum_run_cmd(card, cstype, IPA_CMD_ASS_START, 0,
+				       &chksum_cb);
 	if (rc) {
+		qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_STOP, 0);
 		dev_warn(&card->gdev->dev,
 			 "Starting HW checksumming for %s failed, using SW checksumming\n",
 			 QETH_CARD_IFNAME(card));
 		return rc;
 	}
-	rxtx_arg = (cstype == IPA_OUTBOUND_CHECKSUM) ? card->info.tx_csum_mask
-						     : card->info.csum_mask;
-	rc = qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_ENABLE,
-					  rxtx_arg);
+	rc = qeth_ipa_checksum_run_cmd(card, cstype, IPA_CMD_ASS_ENABLE,
+				       chksum_cb.supported, &chksum_cb);
 	if (rc) {
+		qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_STOP, 0);
 		dev_warn(&card->gdev->dev,
 			 "Enabling HW checksumming for %s failed, using SW checksumming\n",
 			 QETH_CARD_IFNAME(card));
@@ -6090,19 +6133,10 @@ static int qeth_send_checksum_on(struct qeth_card *card, int cstype)
 
 static int qeth_set_ipa_csum(struct qeth_card *card, int on, int cstype)
 {
-	int rc;
-
-	if (on) {
-		rc = qeth_send_checksum_on(card, cstype);
-		if (rc)
-			return -EIO;
-	} else {
-		rc = qeth_send_simple_setassparms(card, cstype,
-						  IPA_CMD_ASS_STOP, 0);
-		if (rc)
-			return -EIO;
-	}
-	return 0;
+	int rc = (on) ? qeth_send_checksum_on(card, cstype)
+		      : qeth_send_simple_setassparms(card, cstype,
+						     IPA_CMD_ASS_STOP, 0);
+	return rc ? -EIO : 0;
 }
 
 static int qeth_set_ipa_tso(struct qeth_card *card, int on)
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 6cccc9a..f54ea72 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -352,11 +352,18 @@ struct qeth_arp_query_info {
 	char *udata;
 };
 
+/* IPA Assist checksum offload reply layout. */
+struct qeth_checksum_cmd {
+	__u32 supported;
+	__u32 enabled;
+} __packed;
+
 /* SETASSPARMS IPA Command: */
 struct qeth_ipacmd_setassparms {
 	struct qeth_ipacmd_setassparms_hdr hdr;
 	union {
 		__u32 flags_32bit;
+		struct qeth_checksum_cmd chksum;
 		struct qeth_arp_cache_entry add_arp_entry;
 		struct qeth_arp_query_data query_arp;
 		__u8 ip[16];
-- 
2.8.4

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 02/13] s390/qeth: test RX/TX checksum offload reply
Date: Wed, 11 Jan 2017 12:55:49 +0100
Message-ID: <20170111115600.4524-3-ubraun@linux.vnet.ibm.com>
References: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        stable@vger.kernel.org, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40920 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934327AbdAKL4J (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 06:56:09 -0500
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0BBroHI012367
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 06:56:09 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27wkk71eee-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 06:56:08 -0500
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Wed, 11 Jan 2017 11:56:07 -0000
In-Reply-To: <20170111115600.4524-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

Turning on receive and/or transmit checksum offload support
on the OSA card requires 2 commands:
1. start command which replies with available features
2. enable command to turn on selected features.

The current version does not check the reply of the start
command and simply uses the returned value to enable
offload features. When the start command returns zero, this
leads to a situation where no checksum offload
is turned on by the hardware. Even worse no error
indication is returned. The Linux kernel assumes
the OSA card performs RX/TX checksum offload, but the hardware
does not perform any checksum verification at all.

This patch checks the return of the start and enable
command responses from the hardware and turns off
checksum offloading if the commands fails or does not
respond with the correct bit setting.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 13 +++++++++++++
 drivers/s390/net/qeth_core_mpc.h  | 10 ++++++++++
 2 files changed, 23 insertions(+)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 5ab80ea..49b813f 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6104,11 +6104,19 @@ static int qeth_ipa_checksum_run_cmd(struct qeth_card *card,
 
 static int qeth_send_checksum_on(struct qeth_card *card, int cstype)
 {
+	const __u32 required_features = QETH_IPA_CHECKSUM_IP_HDR |
+					QETH_IPA_CHECKSUM_UDP |
+					QETH_IPA_CHECKSUM_TCP;
 	struct qeth_checksum_cmd chksum_cb;
 	int rc;
 
 	rc = qeth_ipa_checksum_run_cmd(card, cstype, IPA_CMD_ASS_START, 0,
 				       &chksum_cb);
+	if (!rc) {
+		if ((required_features & chksum_cb.supported) !=
+		    required_features)
+			rc = -EIO;
+	}
 	if (rc) {
 		qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_STOP, 0);
 		dev_warn(&card->gdev->dev,
@@ -6118,6 +6126,11 @@ static int qeth_send_checksum_on(struct qeth_card *card, int cstype)
 	}
 	rc = qeth_ipa_checksum_run_cmd(card, cstype, IPA_CMD_ASS_ENABLE,
 				       chksum_cb.supported, &chksum_cb);
+	if (!rc) {
+		if ((required_features & chksum_cb.enabled) !=
+		    required_features)
+			rc = -EIO;
+	}
 	if (rc) {
 		qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_STOP, 0);
 		dev_warn(&card->gdev->dev,
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index f54ea72..bc69d0a 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -352,6 +352,16 @@ struct qeth_arp_query_info {
 	char *udata;
 };
 
+/* IPA set assist segmentation bit definitions for receive and
+ * transmit checksum offloading.
+ */
+enum qeth_ipa_checksum_bits {
+	QETH_IPA_CHECKSUM_IP_HDR	= 0x0002,
+	QETH_IPA_CHECKSUM_UDP		= 0x0008,
+	QETH_IPA_CHECKSUM_TCP		= 0x0010,
+	QETH_IPA_CHECKSUM_LP2LP		= 0x0020
+};
+
 /* IPA Assist checksum offload reply layout. */
 struct qeth_checksum_cmd {
 	__u32 supported;
-- 
2.8.4

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 08/12] s390/qeth: consolidate errno translation
Date: Thu, 12 Jan 2017 15:48:39 +0100
Message-ID: <20170112144843.33463-9-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52831 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750793AbdALOtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:06 -0500
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEn4E6085348
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:05 -0500
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 27x80nhqr3-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:49:05 -0500
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:49:01 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>

Consolidate errno handling for MAC management: Instead of doing this in every
caller, do it in one place.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Suggested-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 38fae10..074fc62 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -170,8 +170,7 @@ static int qeth_l2_send_setgroupmac(struct qeth_card *card, __u8 *mac)
 	int rc;
 
 	QETH_CARD_TEXT(card, 2, "L2Sgmac");
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_SETGMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETGMAC);
 	if (rc == -EEXIST)
 		QETH_DBF_MESSAGE(2, "Group MAC %pM already existing on %s\n",
 			mac, QETH_CARD_IFNAME(card));
@@ -186,8 +185,7 @@ static int qeth_l2_send_delgroupmac(struct qeth_card *card, __u8 *mac)
 	int rc;
 
 	QETH_CARD_TEXT(card, 2, "L2Dgmac");
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_DELGMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELGMAC);
 	if (rc)
 		QETH_DBF_MESSAGE(2,
 			"Could not delete group MAC %pM on %s: %d\n",
@@ -206,9 +204,8 @@ static int qeth_l2_write_mac(struct qeth_card *card, struct qeth_mac *mac)
 	int rc;
 
 	if (mac->is_uc) {
-		rc = qeth_setdel_makerc(card,
-				qeth_l2_send_setdelmac(card, mac->mac_addr,
-						IPA_CMD_SETVMAC));
+		rc = qeth_l2_send_setdelmac(card, mac->mac_addr,
+						IPA_CMD_SETVMAC);
 	} else {
 		rc = qeth_l2_send_setgroupmac(card, mac->mac_addr);
 	}
@@ -582,7 +579,8 @@ static int qeth_l2_send_setdelmac(struct qeth_card *card, __u8 *mac,
 	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
 	cmd->data.setdelmac.mac_length = OSA_ADDR_LEN;
 	memcpy(&cmd->data.setdelmac.mac, mac, OSA_ADDR_LEN);
-	return qeth_send_ipa_cmd(card, iob, NULL, NULL);
+	return qeth_setdel_makerc(card, qeth_send_ipa_cmd(card, iob,
+					NULL, NULL));
 }
 
 static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
@@ -590,8 +588,7 @@ static int qeth_l2_send_setmac(struct qeth_card *card, __u8 *mac)
 	int rc;
 
 	QETH_CARD_TEXT(card, 2, "L2Setmac");
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_SETVMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_SETVMAC);
 	if (rc == 0) {
 		card->info.mac_bits |= QETH_LAYER2_MAC_REGISTERED;
 		memcpy(card->dev->dev_addr, mac, OSA_ADDR_LEN);
@@ -621,8 +618,7 @@ static int qeth_l2_send_delmac(struct qeth_card *card, __u8 *mac)
 	QETH_CARD_TEXT(card, 2, "L2Delmac");
 	if (!(card->info.mac_bits & QETH_LAYER2_MAC_REGISTERED))
 		return 0;
-	rc = qeth_setdel_makerc(card, qeth_l2_send_setdelmac(card, mac,
-					IPA_CMD_DELVMAC));
+	rc = qeth_l2_send_setdelmac(card, mac, IPA_CMD_DELVMAC);
 	if (rc == 0)
 		card->info.mac_bits &= ~QETH_LAYER2_MAC_REGISTERED;
 	return rc;
-- 
2.8.4

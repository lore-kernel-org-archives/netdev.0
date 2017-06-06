From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/9] s390/qeth: remove support for IPA_IP_FRAGMENTATION
Date: Tue,  6 Jun 2017 14:33:42 +0200
Message-ID: <20170606123350.13781-2-jwi@linux.vnet.ibm.com>
References: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54100 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751305AbdFFMeA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Jun 2017 08:34:00 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v56CXjdF020983
        for <netdev@vger.kernel.org>; Tue, 6 Jun 2017 08:33:59 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2awvdprda5-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 06 Jun 2017 08:33:59 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Tue, 6 Jun 2017 13:33:58 +0100
In-Reply-To: <20170606123350.13781-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This Assist was never actually implemented in any hardware, so just
remove the leftovers.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c |  3 +--
 drivers/s390/net/qeth_core_mpc.h  |  2 +-
 drivers/s390/net/qeth_l3_main.c   | 26 --------------------------
 3 files changed, 2 insertions(+), 29 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index fc6d85f2b38d..dba7d00715e3 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4199,8 +4199,7 @@ int qeth_change_mtu(struct net_device *dev, int new_mtu)
 	sprintf(dbf_text, "%8x", new_mtu);
 	QETH_CARD_TEXT(card, 4, dbf_text);
 
-	if ((!qeth_is_supported(card, IPA_IP_FRAGMENTATION)) &&
-	    (!qeth_mtu_is_valid(card, new_mtu)))
+	if (!qeth_mtu_is_valid(card, new_mtu))
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 4accb0a61ce0..45bbea2843bf 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -192,7 +192,7 @@ enum qeth_ipa_funcs {
 	IPA_ARP_PROCESSING      = 0x00000001L,
 	IPA_INBOUND_CHECKSUM    = 0x00000002L,
 	IPA_OUTBOUND_CHECKSUM   = 0x00000004L,
-	IPA_IP_FRAGMENTATION    = 0x00000008L,
+	/* RESERVED		= 0x00000008L,*/
 	IPA_FILTERING           = 0x00000010L,
 	IPA_IPV6                = 0x00000020L,
 	IPA_MULTICASTING        = 0x00000040L,
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index d8df1e635163..ac8310fe2fb0 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -956,31 +956,6 @@ static int qeth_l3_start_ipa_arp_processing(struct qeth_card *card)
 	return rc;
 }
 
-static int qeth_l3_start_ipa_ip_fragmentation(struct qeth_card *card)
-{
-	int rc;
-
-	QETH_CARD_TEXT(card, 3, "ipaipfrg");
-
-	if (!qeth_is_supported(card, IPA_IP_FRAGMENTATION)) {
-		dev_info(&card->gdev->dev,
-			"Hardware IP fragmentation not supported on %s\n",
-			QETH_CARD_IFNAME(card));
-		return  -EOPNOTSUPP;
-	}
-
-	rc = qeth_send_simple_setassparms(card, IPA_IP_FRAGMENTATION,
-					  IPA_CMD_ASS_START, 0);
-	if (rc) {
-		dev_warn(&card->gdev->dev,
-			"Starting IP fragmentation support for %s failed\n",
-			QETH_CARD_IFNAME(card));
-	} else
-		dev_info(&card->gdev->dev,
-			"Hardware IP fragmentation enabled \n");
-	return rc;
-}
-
 static int qeth_l3_start_ipa_source_mac(struct qeth_card *card)
 {
 	int rc;
@@ -1171,7 +1146,6 @@ static int qeth_l3_start_ipassists(struct qeth_card *card)
 	if (qeth_set_access_ctrl_online(card, 0))
 		return -EIO;
 	qeth_l3_start_ipa_arp_processing(card);	/* go on*/
-	qeth_l3_start_ipa_ip_fragmentation(card);	/* go on*/
 	qeth_l3_start_ipa_source_mac(card);	/* go on*/
 	qeth_l3_start_ipa_vlan(card);		/* go on*/
 	qeth_l3_start_ipa_multicast(card);		/* go on*/
-- 
2.11.2

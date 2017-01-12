From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH RESEND net-next 03/12] s390/qeth: display warning for OSA3 RX/TX checksum offloading
Date: Thu, 12 Jan 2017 15:48:34 +0100
Message-ID: <20170112144843.33463-4-ubraun@linux.vnet.ibm.com>
References: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:41265 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750768AbdALOtG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2017 09:49:06 -0500
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id v0CEmrac139988
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:57 -0500
Received: from e06smtp09.uk.ibm.com (e06smtp09.uk.ibm.com [195.75.94.105])
        by mx0a-001b2d01.pphosted.com with ESMTP id 27x7xg1urh-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2017 09:48:57 -0500
Received: from localhost
        by e06smtp09.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 12 Jan 2017 14:48:54 -0000
In-Reply-To: <20170112144843.33463-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

When RX/TX checksum offloading is turned on and the adapter is
an OSA 3 card in layer 3 mode, the checksum offloading is only
performed when both peers use different adapters. If both peers
share an OSA 3 card, communication is a memory copy and
checksum offloading is not performed.

This patch adds a warning to inform the administrator.

OSA 3 in layer 2 mode does not offer the RX/TX checksum
offload feature.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Reviewed-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 49b813f..ca8309f 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6116,6 +6116,11 @@ static int qeth_send_checksum_on(struct qeth_card *card, int cstype)
 		if ((required_features & chksum_cb.supported) !=
 		    required_features)
 			rc = -EIO;
+		else if (!(QETH_IPA_CHECKSUM_LP2LP & chksum_cb.supported) &&
+			 cstype == IPA_INBOUND_CHECKSUM)
+			dev_warn(&card->gdev->dev,
+				 "Hardware checksumming is performed only if %s and its peer use different OSA Express 3 ports\n",
+				 QETH_CARD_IFNAME(card));
 	}
 	if (rc) {
 		qeth_send_simple_setassparms(card, cstype, IPA_CMD_ASS_STOP, 0);
-- 
2.8.4

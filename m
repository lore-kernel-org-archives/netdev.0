From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 08/13] s390/qeth: no VLAN support on OSM
Date: Wed, 18 Oct 2017 17:40:20 +0200
Message-ID: <20171018154025.73630-9-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40390 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750964AbdJRPlD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:41:03 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFemIX133315
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:41:02 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp6ugt5j6-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:51 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:48 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of silently discarding VLAN registration requests on OSM,
just indicate that this card type doesn't support VLAN.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 87aa8c2ab5b0..d2537c09126d 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -348,10 +348,6 @@ static int qeth_l2_vlan_rx_add_vid(struct net_device *dev,
 	QETH_CARD_TEXT_(card, 4, "aid:%d", vid);
 	if (!vid)
 		return 0;
-	if (card->info.type == QETH_CARD_TYPE_OSM) {
-		QETH_CARD_TEXT(card, 3, "aidOSM");
-		return 0;
-	}
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
 		QETH_CARD_TEXT(card, 3, "aidREC");
 		return 0;
@@ -381,10 +377,6 @@ static int qeth_l2_vlan_rx_kill_vid(struct net_device *dev,
 	int rc = 0;
 
 	QETH_CARD_TEXT_(card, 4, "kid:%d", vid);
-	if (card->info.type == QETH_CARD_TYPE_OSM) {
-		QETH_CARD_TEXT(card, 3, "kidOSM");
-		return 0;
-	}
 	if (qeth_wait_for_threads(card, QETH_RECOVER_THREAD)) {
 		QETH_CARD_TEXT(card, 3, "kidREC");
 		return 0;
@@ -1010,7 +1002,11 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	} else {
 		card->dev->ethtool_ops = &qeth_l2_ethtool_ops;
 	}
-	card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
+
+	if (card->info.type == QETH_CARD_TYPE_OSM)
+		card->dev->features |= NETIF_F_VLAN_CHALLENGED;
+	else
+		card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	if (card->info.type == QETH_CARD_TYPE_OSD && !card->info.guestlan) {
 		card->dev->hw_features = NETIF_F_SG;
 		card->dev->vlan_features = NETIF_F_SG;
@@ -1120,8 +1116,7 @@ static int __qeth_l2_set_online(struct ccwgroup_device *gdev, int recovery_mode)
 			goto out_remove;
 	}
 
-	if (card->info.type != QETH_CARD_TYPE_OSN &&
-	    card->info.type != QETH_CARD_TYPE_OSM)
+	if (card->info.type != QETH_CARD_TYPE_OSN)
 		qeth_l2_process_vlans(card);
 
 	netif_tx_disable(card->dev);
-- 
2.13.5

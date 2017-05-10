From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net 3/4] s390/qeth: avoid null pointer dereference on OSN
Date: Wed, 10 May 2017 19:07:53 +0200
Message-ID: <20170510170754.53922-4-jwi@linux.vnet.ibm.com>
References: <20170510170754.53922-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:49733 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753968AbdEJRI0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 10 May 2017 13:08:26 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v4AH3esj026384
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:08:20 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2aby8qyfry-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 10 May 2017 13:08:20 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 10 May 2017 18:08:17 +0100
In-Reply-To: <20170510170754.53922-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Access card->dev only after checking whether's its valid.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Reviewed-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 04666fe231aa..bd2df62a5cdf 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -965,7 +965,6 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	case QETH_CARD_TYPE_OSN:
 		card->dev = alloc_netdev(0, "osn%d", NET_NAME_UNKNOWN,
 					 ether_setup);
-		card->dev->flags |= IFF_NOARP;
 		break;
 	default:
 		card->dev = alloc_etherdev(0);
@@ -980,9 +979,12 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	card->dev->min_mtu = 64;
 	card->dev->max_mtu = ETH_MAX_MTU;
 	card->dev->netdev_ops = &qeth_l2_netdev_ops;
-	card->dev->ethtool_ops =
-		(card->info.type != QETH_CARD_TYPE_OSN) ?
-		&qeth_l2_ethtool_ops : &qeth_l2_osn_ops;
+	if (card->info.type == QETH_CARD_TYPE_OSN) {
+		card->dev->ethtool_ops = &qeth_l2_osn_ops;
+		card->dev->flags |= IFF_NOARP;
+	} else {
+		card->dev->ethtool_ops = &qeth_l2_ethtool_ops;
+	}
 	card->dev->features |= NETIF_F_HW_VLAN_CTAG_FILTER;
 	if (card->info.type == QETH_CARD_TYPE_OSD && !card->info.guestlan) {
 		card->dev->hw_features = NETIF_F_SG;
-- 
2.10.2

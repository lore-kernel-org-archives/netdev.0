From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 5/7] qeth: do not limit number of gso segments
Date: Thu, 15 Sep 2016 14:39:25 +0200
Message-ID: <20160915123927.86579-6-ubraun@linux.vnet.ibm.com>
References: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:51720 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934250AbcIOMjk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:39:40 -0400
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FCX8fq086421
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:39 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25fr7xuw9r-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:39 -0400
Received: from localhost
        by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 15 Sep 2016 13:39:36 +0100
In-Reply-To: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To reduce the need of skb_linearize() calls, gso_max_segs of qeth
net_devices had been limited according to the maximum number of qdio SBAL
elements. But a gso segment cannot be larger than the mtu-size, while an
SBAL element can contain up to 4096 bytes. The gso_max_segs limitation
limits the maximum packet size given to the qeth driver. Performance
measurements with tso-enabled qeth network interfaces and mtu-size 1500
showed, that the disadvantage of smaller packets is much more severe than
the advantage of fewer skb_linearize() calls.
This patch gets rid of the gso_max_segs limitations in the qeth driver.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 1 -
 drivers/s390/net/qeth_l3_main.c | 1 -
 2 files changed, 2 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 54fd891..2081c18 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1131,7 +1131,6 @@ static int qeth_l2_setup_netdev(struct qeth_card *card)
 	qeth_l2_request_initial_mac(card);
 	card->dev->gso_max_size = (QETH_MAX_BUFFER_ELEMENTS(card) - 1) *
 				  PAGE_SIZE;
-	card->dev->gso_max_segs = (QETH_MAX_BUFFER_ELEMENTS(card) - 1);
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	netif_napi_add(card->dev, &card->napi, qeth_l2_poll, QETH_NAPI_WEIGHT);
 	netif_carrier_off(card->dev);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 4ba82e1..0cbbc80 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3148,7 +3148,6 @@ static int qeth_l3_setup_netdev(struct qeth_card *card)
 	netif_keep_dst(card->dev);
 	card->dev->gso_max_size = (QETH_MAX_BUFFER_ELEMENTS(card) - 1) *
 				  PAGE_SIZE;
-	card->dev->gso_max_segs = (QETH_MAX_BUFFER_ELEMENTS(card) - 1);
 
 	SET_NETDEV_DEV(card->dev, &card->gdev->dev);
 	netif_napi_add(card->dev, &card->napi, qeth_l3_poll, QETH_NAPI_WEIGHT);
-- 
2.8.4

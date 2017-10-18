From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 07/13] s390/qeth: don't verify device when setting MAC address
Date: Wed, 18 Oct 2017 17:40:19 +0200
Message-ID: <20171018154025.73630-8-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:41156 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751889AbdJRPkt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:49 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdXW3147303
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:49 -0400
Received: from e06smtp12.uk.ibm.com (e06smtp12.uk.ibm.com [195.75.94.108])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp6squ778-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:48 -0400
Received: from localhost
        by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:45 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There's no reason why l2_set_mac_address() should ever be called for
a netdevice that's not owned by qeth. It's certainly not required for
VLAN devices, which have their own netdev_ops.

Also:
1) we don't do such validation for any of the other netdev_ops routines.
2) the code in question clearly has never been actually exercised;
   it's broken. After determining that the device is not owned
   by qeth, it would still use dev->ml_priv to write a qeth trace entry.

Remove the check, and its helper that walked the global card list.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l2_main.c | 23 -----------------------
 1 file changed, 23 deletions(-)

diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 7b61c2ef4c74..87aa8c2ab5b0 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -38,24 +38,6 @@ static void qeth_l2_vnicc_init(struct qeth_card *card);
 static bool qeth_l2_vnicc_recover_timeout(struct qeth_card *card, u32 vnicc,
 					  u32 *timeout);
 
-static int qeth_l2_verify_dev(struct net_device *dev)
-{
-	struct qeth_card *card;
-	unsigned long flags;
-	int rc = 0;
-
-	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
-	list_for_each_entry(card, &qeth_core_card_list.list, list) {
-		if (card->dev == dev) {
-			rc = QETH_REAL_CARD;
-			break;
-		}
-	}
-	read_unlock_irqrestore(&qeth_core_card_list.rwlock, flags);
-
-	return rc;
-}
-
 static struct net_device *qeth_l2_netdev_by_devno(unsigned char *read_dev_no)
 {
 	struct qeth_card *card;
@@ -568,11 +550,6 @@ static int qeth_l2_set_mac_address(struct net_device *dev, void *p)
 
 	QETH_CARD_TEXT(card, 3, "setmac");
 
-	if (qeth_l2_verify_dev(dev) != QETH_REAL_CARD) {
-		QETH_CARD_TEXT(card, 3, "setmcINV");
-		return -EOPNOTSUPP;
-	}
-
 	if (card->info.type == QETH_CARD_TYPE_OSN ||
 	    card->info.type == QETH_CARD_TYPE_OSM ||
 	    card->info.type == QETH_CARD_TYPE_OSX) {
-- 
2.13.5

From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 3/7] s390/qeth: allow hsuid configuration in DOWN state
Date: Thu, 15 Sep 2016 14:39:23 +0200
Message-ID: <20160915123927.86579-4-ubraun@linux.vnet.ibm.com>
References: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:53666 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934042AbcIOMjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:39:39 -0400
Received: from pps.filterd (m0098414.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FCXAVd130835
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:39 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25fnnxk8g0-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:38 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 15 Sep 2016 13:39:36 +0100
In-Reply-To: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The qeth IP address mapping logic has been reworked recently. It
causes now problems to specify qeth sysfs attribute "hsuid" in DOWN
state, which is allowed. Postpone registering or deregistering of
IP-addresses in this case.

Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
Reviewed-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 22 +++++++++++++++++-----
 1 file changed, 17 insertions(+), 5 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 2f51271..4ba82e1 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -257,6 +257,11 @@ int qeth_l3_delete_ip(struct qeth_card *card, struct qeth_ipaddr *tmp_addr)
 	if (addr->in_progress)
 		return -EINPROGRESS;
 
+	if (!qeth_card_hw_is_reachable(card)) {
+		addr->disp_flag = QETH_DISP_ADDR_DELETE;
+		return 0;
+	}
+
 	rc = qeth_l3_deregister_addr_entry(card, addr);
 
 	hash_del(&addr->hnode);
@@ -296,6 +301,11 @@ int qeth_l3_add_ip(struct qeth_card *card, struct qeth_ipaddr *tmp_addr)
 		hash_add(card->ip_htable, &addr->hnode,
 				qeth_l3_ipaddr_hash(addr));
 
+		if (!qeth_card_hw_is_reachable(card)) {
+			addr->disp_flag = QETH_DISP_ADDR_ADD;
+			return 0;
+		}
+
 		/* qeth_l3_register_addr_entry can go to sleep
 		 * if we add a IPV4 addr. It is caused by the reason
 		 * that SETIP ipa cmd starts ARP staff for IPV4 addr.
@@ -390,12 +400,16 @@ static void qeth_l3_recover_ip(struct qeth_card *card)
 	int i;
 	int rc;
 
-	QETH_CARD_TEXT(card, 4, "recoverip");
+	QETH_CARD_TEXT(card, 4, "recovrip");
 
 	spin_lock_bh(&card->ip_lock);
 
 	hash_for_each_safe(card->ip_htable, i, tmp, addr, hnode) {
-		if (addr->disp_flag == QETH_DISP_ADDR_ADD) {
+		if (addr->disp_flag == QETH_DISP_ADDR_DELETE) {
+			qeth_l3_deregister_addr_entry(card, addr);
+			hash_del(&addr->hnode);
+			kfree(addr);
+		} else if (addr->disp_flag == QETH_DISP_ADDR_ADD) {
 			if (addr->proto == QETH_PROT_IPV4) {
 				addr->in_progress = 1;
 				spin_unlock_bh(&card->ip_lock);
@@ -407,10 +421,8 @@ static void qeth_l3_recover_ip(struct qeth_card *card)
 
 			if (!rc) {
 				addr->disp_flag = QETH_DISP_ADDR_DO_NOTHING;
-				if (addr->ref_counter < 1) {
+				if (addr->ref_counter < 1)
 					qeth_l3_delete_ip(card, addr);
-					kfree(addr);
-				}
 			} else {
 				hash_del(&addr->hnode);
 				kfree(addr);
-- 
2.8.4

From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 03/13] s390/qeth: remove duplicated device matching
Date: Wed, 18 Oct 2017 17:40:15 +0200
Message-ID: <20171018154025.73630-4-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:52728 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751619AbdJRPkn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:43 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdbED092620
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:43 -0400
Received: from e06smtp10.uk.ibm.com (e06smtp10.uk.ibm.com [195.75.94.106])
        by mx0b-001b2d01.pphosted.com with ESMTP id 2dp4ukmmbq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:43 -0400
Received: from localhost
        by e06smtp10.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:41 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With commit "s390/ccwgroup: tie a ccwgroup driver to its ccw driver",
the ccwgroup core now ensures that a qeth group device only consists of
ccw devices which are supported by qeth. Therefore remove qeth's
internal device matching, and use .driver_info to determine the card
type.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      | 14 --------------
 drivers/s390/net/qeth_core_main.c | 40 ++++++++-------------------------------
 drivers/s390/net/qeth_core_mpc.h  |  1 -
 drivers/s390/net/qeth_core_sys.c  |  4 +---
 4 files changed, 9 insertions(+), 50 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 3b6aa0c48221..dbdf09a1299a 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -231,20 +231,6 @@ static inline int qeth_is_ipa_enabled(struct qeth_ipa_info *ipa,
 #define QETH_IDX_FUNC_LEVEL_OSD		 0x0101
 #define QETH_IDX_FUNC_LEVEL_IQD		 0x4108
 
-#define QETH_MODELLIST_ARRAY \
-	{{0x1731, 0x01, 0x1732, QETH_CARD_TYPE_OSD, QETH_MAX_QUEUES, 0}, \
-	 {0x1731, 0x05, 0x1732, QETH_CARD_TYPE_IQD, QETH_MAX_QUEUES, 0x103}, \
-	 {0x1731, 0x06, 0x1732, QETH_CARD_TYPE_OSN, QETH_MAX_QUEUES, 0}, \
-	 {0x1731, 0x02, 0x1732, QETH_CARD_TYPE_OSM, QETH_MAX_QUEUES, 0}, \
-	 {0x1731, 0x02, 0x1732, QETH_CARD_TYPE_OSX, QETH_MAX_QUEUES, 0}, \
-	 {0, 0, 0, 0, 0, 0} }
-#define QETH_CU_TYPE_IND	0
-#define QETH_CU_MODEL_IND	1
-#define QETH_DEV_TYPE_IND	2
-#define QETH_DEV_MODEL_IND	3
-#define QETH_QUEUE_NO_IND	4
-#define QETH_MULTICAST_IND	5
-
 #define QETH_REAL_CARD		1
 #define QETH_VLAN_CARD		2
 #define QETH_BUFSIZE		4096
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index e10e5b8d476c..735b03cae727 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -52,7 +52,6 @@ EXPORT_SYMBOL_GPL(qeth_core_header_cache);
 static struct kmem_cache *qeth_qdio_outbuf_cache;
 
 static struct device *qeth_core_root_dev;
-static unsigned int known_devices[][6] = QETH_MODELLIST_ARRAY;
 static struct lock_class_key qdio_out_skb_queue_key;
 static struct mutex qeth_mod_mutex;
 
@@ -1386,6 +1385,7 @@ static void qeth_init_qdio_info(struct qeth_card *card)
 	QETH_DBF_TEXT(SETUP, 4, "intqdinf");
 	atomic_set(&card->qdio.state, QETH_QDIO_UNINITIALIZED);
 	/* inbound */
+	card->qdio.no_in_queues = 1;
 	card->qdio.in_buf_size = QETH_IN_BUF_SIZE_DEFAULT;
 	if (card->info.type == QETH_CARD_TYPE_IQD)
 		card->qdio.init_pool.buf_count = QETH_IN_BUF_COUNT_HSDEFAULT;
@@ -1519,34 +1519,17 @@ static struct qeth_card *qeth_alloc_card(void)
 	return NULL;
 }
 
-static int qeth_determine_card_type(struct qeth_card *card)
+static void qeth_determine_card_type(struct qeth_card *card)
 {
-	int i = 0;
-
 	QETH_DBF_TEXT(SETUP, 2, "detcdtyp");
 
 	card->qdio.do_prio_queueing = QETH_PRIOQ_DEFAULT;
 	card->qdio.default_out_queue = QETH_DEFAULT_QUEUE;
-	while (known_devices[i][QETH_DEV_MODEL_IND]) {
-		if ((CARD_RDEV(card)->id.dev_type ==
-				known_devices[i][QETH_DEV_TYPE_IND]) &&
-		    (CARD_RDEV(card)->id.dev_model ==
-				known_devices[i][QETH_DEV_MODEL_IND])) {
-			card->info.type = known_devices[i][QETH_DEV_MODEL_IND];
-			card->qdio.no_out_queues =
-				known_devices[i][QETH_QUEUE_NO_IND];
-			card->qdio.no_in_queues = 1;
-			card->info.is_multicast_different =
-				known_devices[i][QETH_MULTICAST_IND];
-			qeth_update_from_chp_desc(card);
-			return 0;
-		}
-		i++;
-	}
-	card->info.type = QETH_CARD_TYPE_UNKNOWN;
-	dev_err(&card->gdev->dev, "The adapter hardware is of an "
-		"unknown type\n");
-	return -ENOENT;
+	card->info.type = CARD_RDEV(card)->id.driver_info;
+	card->qdio.no_out_queues = QETH_MAX_QUEUES;
+	if (card->info.type == QETH_CARD_TYPE_IQD)
+		card->info.is_multicast_different = 0x0103;
+	qeth_update_from_chp_desc(card);
 }
 
 static int qeth_clear_channel(struct qeth_channel *channel)
@@ -2233,8 +2216,6 @@ static int qeth_cm_setup(struct qeth_card *card)
 static int qeth_get_initial_mtu_for_card(struct qeth_card *card)
 {
 	switch (card->info.type) {
-	case QETH_CARD_TYPE_UNKNOWN:
-		return 1500;
 	case QETH_CARD_TYPE_IQD:
 		return card->info.max_mtu;
 	case QETH_CARD_TYPE_OSD:
@@ -2279,7 +2260,6 @@ static int qeth_mtu_is_valid(struct qeth_card *card, int mtu)
 		return ((mtu >= 576) &&
 			(mtu <= card->info.max_mtu));
 	case QETH_CARD_TYPE_OSN:
-	case QETH_CARD_TYPE_UNKNOWN:
 	default:
 		return 1;
 	}
@@ -5724,11 +5704,7 @@ static int qeth_core_probe_device(struct ccwgroup_device *gdev)
 	gdev->cdev[1]->handler = qeth_irq;
 	gdev->cdev[2]->handler = qeth_irq;
 
-	rc = qeth_determine_card_type(card);
-	if (rc) {
-		QETH_DBF_TEXT_(SETUP, 2, "3err%d", rc);
-		goto err_card;
-	}
+	qeth_determine_card_type(card);
 	rc = qeth_setup_card(card);
 	if (rc) {
 		QETH_DBF_TEXT_(SETUP, 2, "2err%d", rc);
diff --git a/drivers/s390/net/qeth_core_mpc.h b/drivers/s390/net/qeth_core_mpc.h
index 6a7654df6e78..413f0f268b17 100644
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -44,7 +44,6 @@ extern unsigned char IPA_PDU_HEADER[];
 #define IPA_CMD_PRIM_VERSION_NO 0x01
 
 enum qeth_card_types {
-	QETH_CARD_TYPE_UNKNOWN = 0,
 	QETH_CARD_TYPE_OSD     = 1,
 	QETH_CARD_TYPE_IQD     = 5,
 	QETH_CARD_TYPE_OSN     = 6,
diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index d1ee9e30c68b..b22ed2a57acd 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -475,10 +475,8 @@ static ssize_t qeth_dev_isolation_store(struct device *dev,
 		return -EINVAL;
 
 	mutex_lock(&card->conf_mutex);
-	/* check for unknown, too, in case we do not yet know who we are */
 	if (card->info.type != QETH_CARD_TYPE_OSD &&
-	    card->info.type != QETH_CARD_TYPE_OSX &&
-	    card->info.type != QETH_CARD_TYPE_UNKNOWN) {
+	    card->info.type != QETH_CARD_TYPE_OSX) {
 		rc = -EOPNOTSUPP;
 		dev_err(&card->gdev->dev, "Adapter does not "
 			"support QDIO data connection isolation\n");
-- 
2.13.5

From: frank.blaschka@de.ibm.com
Subject: [patch 2/5] qeth: Use ccw_device_get_id().
Date: Fri, 06 Jun 2008 12:37:45 +0200
Message-ID: <20080606103828.316913000@de.ibm.com>
References: <20080606103743.638691000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Cornelia Huck <cornelia.huck@de.ibm.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.de.ibm.com ([195.212.29.153]:45546 "EHLO
	mtagate4.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754279AbYFFKif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 06:38:35 -0400
Content-Disposition: inline; filename=601-qeth-getid.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cornelia Huck <cornelia.huck@de.ibm.com>

Get the devno from the ccw device via ccw_device_get_id() instead
of parsing the bus_id.

Signed-off-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Martin Schwidefsky <schwidefsky@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   11 +++--------
 drivers/s390/net/qeth_l2_main.c   |   11 ++++-------
 2 files changed, 7 insertions(+), 15 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2008-06-06 10:53:00.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2008-06-06 10:53:12.000000000 +0200
@@ -1407,12 +1407,6 @@ static void qeth_init_func_level(struct 
 	}
 }
 
-static inline __u16 qeth_raw_devno_from_bus_id(char *id)
-{
-	id += (strlen(id) - 4);
-	return (__u16) simple_strtoul(id, &id, 16);
-}
-
 static int qeth_idx_activate_get_answer(struct qeth_channel *channel,
 		void (*idx_reply_cb)(struct qeth_channel *,
 			struct qeth_cmd_buffer *))
@@ -1468,6 +1462,7 @@ static int qeth_idx_activate_channel(str
 	__u16 temp;
 	__u8 tmp;
 	int rc;
+	struct ccw_dev_id temp_devid;
 
 	card = CARD_FROM_CDEV(channel->ccwdev);
 
@@ -1494,8 +1489,8 @@ static int qeth_idx_activate_channel(str
 	       &card->token.issuer_rm_w, QETH_MPC_TOKEN_LENGTH);
 	memcpy(QETH_IDX_ACT_FUNC_LEVEL(iob->data),
 	       &card->info.func_level, sizeof(__u16));
-	temp = qeth_raw_devno_from_bus_id(CARD_DDEV_ID(card));
-	memcpy(QETH_IDX_ACT_QDIO_DEV_CUA(iob->data), &temp, 2);
+	ccw_device_get_id(CARD_DDEV(card), &temp_devid);
+	memcpy(QETH_IDX_ACT_QDIO_DEV_CUA(iob->data), &temp_devid.devno, 2);
 	temp = (card->info.cula << 8) + card->info.unit_addr2;
 	memcpy(QETH_IDX_ACT_QDIO_DEV_REALADDR(iob->data), &temp, 2);
 
diff -urpN linux-2.6/drivers/s390/net/qeth_l2_main.c linux-2.6-patched/drivers/s390/net/qeth_l2_main.c
--- linux-2.6/drivers/s390/net/qeth_l2_main.c	2008-06-06 10:52:45.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_l2_main.c	2008-06-06 10:53:12.000000000 +0200
@@ -101,19 +101,16 @@ static struct net_device *qeth_l2_netdev
 {
 	struct qeth_card *card;
 	struct net_device *ndev;
-	unsigned char *readno;
-	__u16 temp_dev_no, card_dev_no;
-	char *endp;
+	__u16 temp_dev_no;
 	unsigned long flags;
+	struct ccw_dev_id read_devid;
 
 	ndev = NULL;
 	memcpy(&temp_dev_no, read_dev_no, 2);
 	read_lock_irqsave(&qeth_core_card_list.rwlock, flags);
 	list_for_each_entry(card, &qeth_core_card_list.list, list) {
-		readno = CARD_RDEV_ID(card);
-		readno += (strlen(readno) - 4);
-		card_dev_no = simple_strtoul(readno, &endp, 16);
-		if (card_dev_no == temp_dev_no) {
+		ccw_device_get_id(CARD_RDEV(card), &read_devid);
+		if (read_devid.devno == temp_dev_no) {
 			ndev = card->dev;
 			break;
 		}

-- 

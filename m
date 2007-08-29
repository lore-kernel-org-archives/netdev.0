From: Ursula Braun <braunu@de.ibm.com>
Subject: [patch 6/7] s390: provide specific message for OSA-adapters exclusively used
Date: Wed, 29 Aug 2007 11:26:57 +0200
Message-ID: <20070829101857.309170000@linux.vnet.ibm.com>
References: <20070829092651.411517000@linux.vnet.ibm.com>
Cc: frank.blaschka@de.ibm.com
To: jgarzik@pobox.com, netdev@vger.kernel.org,
	linux-s390@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.29.151]:33607 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932341AbXH2KTA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Aug 2007 06:19:00 -0400
Content-Disposition: inline; filename=710-qeth-exclusive.diff
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <braunu@de.ibm.com>

Exclusive usage of OSA-cards has been introduced. Even though Linux
does not make use of it, qeth should be prepared to receive a bad RC
for some initialization steps. A meaningful message is now given,
if an OSA-device is set online, even though the OSA-adapter is already
exclusively used by another host.

Signed-off-by: Ursula Braun <braunu@de.ibm.com>
---

 drivers/s390/net/qeth_main.c |   28 +++++++++++++++++++---------
 drivers/s390/net/qeth_mpc.h  |    1 +
 2 files changed, 20 insertions(+), 9 deletions(-)

Index: linux-2.6-uschi/drivers/s390/net/qeth_main.c
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_main.c
+++ linux-2.6-uschi/drivers/s390/net/qeth_main.c
@@ -1541,16 +1541,21 @@ qeth_idx_write_cb(struct qeth_channel *c
 	card = CARD_FROM_CDEV(channel->ccwdev);
 
 	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
-		PRINT_ERR("IDX_ACTIVATE on write channel device %s: negative "
-			  "reply\n", CARD_WDEV_ID(card));
+		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+			PRINT_ERR("IDX_ACTIVATE on write channel device %s: "
+				"adapter exclusively used by another host\n",
+				CARD_WDEV_ID(card));
+		else
+			PRINT_ERR("IDX_ACTIVATE on write channel device %s: "
+				"negative reply\n", CARD_WDEV_ID(card));
 		goto out;
 	}
 	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
 	if ((temp & ~0x0100) != qeth_peer_func_level(card->info.func_level)) {
 		PRINT_WARN("IDX_ACTIVATE on write channel device %s: "
-			   "function level mismatch "
-			   "(sent: 0x%x, received: 0x%x)\n",
-			   CARD_WDEV_ID(card), card->info.func_level, temp);
+			"function level mismatch "
+			"(sent: 0x%x, received: 0x%x)\n",
+			CARD_WDEV_ID(card), card->info.func_level, temp);
 		goto out;
 	}
 	channel->state = CH_STATE_UP;
@@ -1596,8 +1601,13 @@ qeth_idx_read_cb(struct qeth_channel *ch
 			goto out;
 	}
 	if (!(QETH_IS_IDX_ACT_POS_REPLY(iob->data))) {
-		PRINT_ERR("IDX_ACTIVATE on read channel device %s: negative "
-			  "reply\n", CARD_RDEV_ID(card));
+		if (QETH_IDX_ACT_CAUSE_CODE(iob->data) == 0x19)
+			PRINT_ERR("IDX_ACTIVATE on read channel device %s: "
+				"adapter exclusively used by another host\n",
+				CARD_RDEV_ID(card));
+		else
+			PRINT_ERR("IDX_ACTIVATE on read channel device %s: "
+				"negative reply\n", CARD_RDEV_ID(card));
 		goto out;
 	}
 
@@ -1612,8 +1622,8 @@ qeth_idx_read_cb(struct qeth_channel *ch
 	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
 	if (temp != qeth_peer_func_level(card->info.func_level)) {
 		PRINT_WARN("IDX_ACTIVATE on read channel device %s: function "
-			   "level mismatch (sent: 0x%x, received: 0x%x)\n",
-			   CARD_RDEV_ID(card), card->info.func_level, temp);
+			"level mismatch (sent: 0x%x, received: 0x%x)\n",
+			CARD_RDEV_ID(card), card->info.func_level, temp);
 		goto out;
 	}
 	memcpy(&card->token.issuer_rm_r,
Index: linux-2.6-uschi/drivers/s390/net/qeth_mpc.h
===================================================================
--- linux-2.6-uschi.orig/drivers/s390/net/qeth_mpc.h
+++ linux-2.6-uschi/drivers/s390/net/qeth_mpc.h
@@ -565,6 +565,7 @@ extern unsigned char IDX_ACTIVATE_WRITE[
 #define QETH_IDX_ACT_QDIO_DEV_REALADDR(buffer) (buffer+0x20)
 #define QETH_IS_IDX_ACT_POS_REPLY(buffer) (((buffer)[0x08]&3)==2)
 #define QETH_IDX_REPLY_LEVEL(buffer) (buffer+0x12)
+#define QETH_IDX_ACT_CAUSE_CODE(buffer) (buffer)[0x09]
 
 #define PDU_ENCAPSULATION(buffer) \
 	(buffer + *(buffer + (*(buffer+0x0b)) + \

-- 

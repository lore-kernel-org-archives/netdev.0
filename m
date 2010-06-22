From: frank.blaschka@de.ibm.com
Subject: [patch 11/11] [PATCH] qeth: handle missing z/VM authorization of OSX
Date: Tue, 22 Jun 2010 10:57:12 +0200
Message-ID: <20100622085808.316402000@de.ibm.com>
References: <20100622085701.772508000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.17.161]:47803 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758964Ab0FVI6K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jun 2010 04:58:10 -0400
Content-Disposition: inline; filename=611-qeth-osx-auth.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

For z/VM guest operating systems, OSX CHPIDs can only be used, if
LPAR and z/VM userID are explicitly authorized through the Service
Element. Issue a message if this SE-authorization is missing.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |    8 ++++++--
 drivers/s390/net/qeth_core_mpc.h  |    5 +++--
 2 files changed, 9 insertions(+), 4 deletions(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:02.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-06-22 08:55:02.000000000 +0200
@@ -512,6 +512,7 @@ static void qeth_send_control_data_cb(st
 	case -EIO:
 		qeth_clear_ipacmd_list(card);
 		qeth_schedule_recovery(card);
+		/* fall through */
 	default:
 		goto out;
 	}
@@ -1588,15 +1589,18 @@ static void qeth_idx_read_cb(struct qeth
 				"host\n");
 			break;
 		case QETH_IDX_ACT_ERR_AUTH:
+		case QETH_IDX_ACT_ERR_AUTH_USER:
 			dev_err(&card->read.ccwdev->dev,
 				"Setting the device online failed because of "
-				"insufficient LPAR authorization\n");
+				"insufficient authorization\n");
 			break;
 		default:
 			QETH_DBF_MESSAGE(2, "%s IDX_ACTIVATE on read channel:"
 				" negative reply\n",
 				dev_name(&card->read.ccwdev->dev));
 		}
+		QETH_CARD_TEXT_(card, 2, "idxread%c",
+			QETH_IDX_ACT_CAUSE_CODE(iob->data));
 		goto out;
 	}
 
@@ -1929,7 +1933,7 @@ static int qeth_ulp_enable_cb(struct qet
 		card->info.link_type = link_type;
 	} else
 		card->info.link_type = 0;
-	QETH_DBF_TEXT_(SETUP, 2, "link%d", link_type);
+	QETH_DBF_TEXT_(SETUP, 2, "link%d", card->info.link_type);
 	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
 	return 0;
 }
diff -urpN linux-2.6/drivers/s390/net/qeth_core_mpc.h linux-2.6-patched/drivers/s390/net/qeth_core_mpc.h
--- linux-2.6/drivers/s390/net/qeth_core_mpc.h	2010-06-22 08:54:43.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_mpc.h	2010-06-22 08:55:02.000000000 +0200
@@ -616,8 +616,9 @@ extern unsigned char IDX_ACTIVATE_WRITE[
 #define QETH_IS_IDX_ACT_POS_REPLY(buffer) (((buffer)[0x08] & 3) == 2)
 #define QETH_IDX_REPLY_LEVEL(buffer) (buffer + 0x12)
 #define QETH_IDX_ACT_CAUSE_CODE(buffer) (buffer)[0x09]
-#define QETH_IDX_ACT_ERR_EXCL	0x19
-#define QETH_IDX_ACT_ERR_AUTH	0x1E
+#define QETH_IDX_ACT_ERR_EXCL		0x19
+#define QETH_IDX_ACT_ERR_AUTH		0x1E
+#define QETH_IDX_ACT_ERR_AUTH_USER	0x20
 
 #define PDU_ENCAPSULATION(buffer) \
 	(buffer + *(buffer + (*(buffer + 0x0b)) + \


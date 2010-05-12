From: frank.blaschka@de.ibm.com
Subject: [patch 2/3] [PATCH] qeth: new message if OLM limit is reached
Date: Wed, 12 May 2010 07:34:46 +0200
Message-ID: <20100512053528.603997000@de.ibm.com>
References: <20100512053444.035939000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.17.167]:42223 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751529Ab0ELFfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 May 2010 01:35:31 -0400
Content-Disposition: inline; filename=602-qeth-olm-limit-msg.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

z/OS may activate Optimized Latency Mode (OLM) for a connection
through an OSA Express3 adapter, which reduces the number of
allowed concurrent connections, if adapter is used in shared mode.
Create a meaningful message, if activation of an OSA-connection fails
due to an active OLM-connection on the shared OSA-adapter.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_core_main.c |   10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff -urpN linux-2.6/drivers/s390/net/qeth_core_main.c linux-2.6-patched/drivers/s390/net/qeth_core_main.c
--- linux-2.6/drivers/s390/net/qeth_core_main.c	2010-05-11 22:10:12.000000000 +0200
+++ linux-2.6-patched/drivers/s390/net/qeth_core_main.c	2010-05-11 22:10:34.000000000 +0200
@@ -1976,6 +1976,7 @@ static int qeth_ulp_setup_cb(struct qeth
 		unsigned long data)
 {
 	struct qeth_cmd_buffer *iob;
+	int rc = 0;
 
 	QETH_DBF_TEXT(SETUP, 2, "ulpstpcb");
 
@@ -1983,8 +1984,15 @@ static int qeth_ulp_setup_cb(struct qeth
 	memcpy(&card->token.ulp_connection_r,
 	       QETH_ULP_SETUP_RESP_CONNECTION_TOKEN(iob->data),
 	       QETH_MPC_TOKEN_LENGTH);
+	if (!strncmp("00S", QETH_ULP_SETUP_RESP_CONNECTION_TOKEN(iob->data),
+		     3)) {
+		QETH_DBF_TEXT(SETUP, 2, "olmlimit");
+		dev_err(&card->gdev->dev, "A connection could not be "
+			"established because of an OLM limit\n");
+		rc = -EMLINK;
+	}
 	QETH_DBF_TEXT_(SETUP, 2, "  rc%d", iob->rc);
-	return 0;
+	return rc;
 }
 
 static int qeth_ulp_setup(struct qeth_card *card)


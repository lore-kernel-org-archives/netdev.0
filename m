From: frank.blaschka@de.ibm.com
Subject: [patch 3/5] [PATCH] qeth: set promisc off after trace disabling failure
Date: Tue, 09 Mar 2010 07:36:55 +0100
Message-ID: <20100309063936.711944000@de.ibm.com>
References: <20100309063652.706791000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Ursula Braun <ursula.braun@de.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:57777 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752100Ab0CIGji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Mar 2010 01:39:38 -0500
Content-Disposition: inline; filename=603-qeth-promisc-off.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

If HiperSockets Network Traffic Analyzer is switched off, but trace
disabling fails somehow, the qeth driver does not switch off its 
promisc mode status. A following sniffer reactivation fails, since
qeth does not see a need to reenable tracing.
At the same time the code analyzing results of trace commands is
restructured.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3_main.c |   56 +++++++++++++++++++++-------------------
 1 file changed, 30 insertions(+), 26 deletions(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1691,39 +1691,43 @@ qeth_diags_trace_cb(struct qeth_card *ca
 
 	cmd = (struct qeth_ipa_cmd *)data;
 	rc = cmd->hdr.return_code;
-	if (rc) {
+	if (rc)
 		QETH_DBF_TEXT_(TRACE, 2, "dxter%x", rc);
-		if (cmd->data.diagass.action == QETH_DIAGS_CMD_TRACE_ENABLE) {
-			switch (rc) {
-			case IPA_RC_HARDWARE_AUTH_ERROR:
-				dev_warn(&card->gdev->dev, "The device is not "
-					"authorized to run as a HiperSockets "
-					"network traffic analyzer\n");
-				break;
-			case IPA_RC_TRACE_ALREADY_ACTIVE:
-				dev_warn(&card->gdev->dev, "A HiperSockets "
-					"network traffic analyzer is already "
-					"active in the HiperSockets LAN\n");
-				break;
-			default:
-				break;
-			}
-		}
-		return 0;
-	}
-
 	switch (cmd->data.diagass.action) {
 	case QETH_DIAGS_CMD_TRACE_QUERY:
 		break;
 	case QETH_DIAGS_CMD_TRACE_DISABLE:
-		card->info.promisc_mode = SET_PROMISC_MODE_OFF;
-		dev_info(&card->gdev->dev, "The HiperSockets network traffic "
-			"analyzer is deactivated\n");
+		switch (rc) {
+		case 0:
+		case IPA_RC_INVALID_SUBCMD:
+			card->info.promisc_mode = SET_PROMISC_MODE_OFF;
+			dev_info(&card->gdev->dev, "The HiperSockets network "
+				"traffic analyzer is deactivated\n");
+			break;
+		default:
+			break;
+		}
 		break;
 	case QETH_DIAGS_CMD_TRACE_ENABLE:
-		card->info.promisc_mode = SET_PROMISC_MODE_ON;
-		dev_info(&card->gdev->dev, "The HiperSockets network traffic "
-			"analyzer is activated\n");
+		switch (rc) {
+		case 0:
+			card->info.promisc_mode = SET_PROMISC_MODE_ON;
+			dev_info(&card->gdev->dev, "The HiperSockets network "
+				"traffic analyzer is activated\n");
+			break;
+		case IPA_RC_HARDWARE_AUTH_ERROR:
+			dev_warn(&card->gdev->dev, "The device is not "
+				"authorized to run as a HiperSockets network "
+				"traffic analyzer\n");
+			break;
+		case IPA_RC_TRACE_ALREADY_ACTIVE:
+			dev_warn(&card->gdev->dev, "A HiperSockets "
+				"network traffic analyzer is already "
+				"active in the HiperSockets LAN\n");
+			break;
+		default:
+			break;
+		}
 		break;
 	default:
 		QETH_DBF_MESSAGE(2, "Unknown sniffer action (0x%04x) on %s\n",


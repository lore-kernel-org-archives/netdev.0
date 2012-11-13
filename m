From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] [PATCH] qeth: Fix IPA_CMD_QIPASSIST return code handling
Date: Tue, 13 Nov 2012 10:05:16 +0100
Message-ID: <20121113090529.950069848@de.ibm.com>
References: <20121113090515.223638702@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	Stefan Raspl <raspl@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:52983 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753670Ab2KMJFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2012 04:05:36 -0500
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Tue, 13 Nov 2012 09:05:34 -0000
Content-Disposition: inline; filename=600-qeth-ip-qipassist-rc.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Raspl <raspl@linux.vnet.ibm.com>

Return codes of IPA_CMD_QIPASSIST are not checked, especially the ones which
indicate that the command is not supported. As a result, the device driver
would not enable all available features on older card generations.
This patch adds proper checking and sets the bare minimum in the supported
functions flags to avoid follow-on errors.

Signed-off-by: Stefan Raspl <raspl@linux.vnet.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 24 ++++++++++++++++++++++--
 drivers/s390/net/qeth_l2_main.c   | 11 +++++++----
 2 files changed, 29 insertions(+), 6 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 3e25d31..4d6ba00 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -2942,13 +2942,33 @@ static int qeth_query_ipassists_cb(struct qeth_card *card,
 	QETH_DBF_TEXT(SETUP, 2, "qipasscb");
 
 	cmd = (struct qeth_ipa_cmd *) data;
+
+	switch (cmd->hdr.return_code) {
+	case IPA_RC_NOTSUPP:
+	case IPA_RC_L2_UNSUPPORTED_CMD:
+		QETH_DBF_TEXT(SETUP, 2, "ipaunsup");
+		card->options.ipa4.supported_funcs |= IPA_SETADAPTERPARMS;
+		card->options.ipa6.supported_funcs |= IPA_SETADAPTERPARMS;
+		return -0;
+	default:
+		if (cmd->hdr.return_code) {
+			QETH_DBF_MESSAGE(1, "%s IPA_CMD_QIPASSIST: Unhandled "
+						"rc=%d\n",
+						dev_name(&card->gdev->dev),
+						cmd->hdr.return_code);
+			return 0;
+		}
+	}
+
 	if (cmd->hdr.prot_version == QETH_PROT_IPV4) {
 		card->options.ipa4.supported_funcs = cmd->hdr.ipa_supported;
 		card->options.ipa4.enabled_funcs = cmd->hdr.ipa_enabled;
-	} else {
+	} else if (cmd->hdr.prot_version == QETH_PROT_IPV6) {
 		card->options.ipa6.supported_funcs = cmd->hdr.ipa_supported;
 		card->options.ipa6.enabled_funcs = cmd->hdr.ipa_enabled;
-	}
+	} else
+		QETH_DBF_MESSAGE(1, "%s IPA_CMD_QIPASSIST: Flawed LIC detected"
+					"\n", dev_name(&card->gdev->dev));
 	QETH_DBF_TEXT(SETUP, 2, "suppenbl");
 	QETH_DBF_TEXT_(SETUP, 2, "%08x", (__u32)cmd->hdr.ipa_supported);
 	QETH_DBF_TEXT_(SETUP, 2, "%08x", (__u32)cmd->hdr.ipa_enabled);
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index e67e025..84e8f1d 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -626,10 +626,13 @@ static int qeth_l2_request_initial_mac(struct qeth_card *card)
 	QETH_DBF_TEXT(SETUP, 2, "doL2init");
 	QETH_DBF_TEXT_(SETUP, 2, "doL2%s", CARD_BUS_ID(card));
 
-	rc = qeth_query_setadapterparms(card);
-	if (rc) {
-		QETH_DBF_MESSAGE(2, "could not query adapter parameters on "
-			"device %s: x%x\n", CARD_BUS_ID(card), rc);
+	if (qeth_is_supported(card, IPA_SETADAPTERPARMS)) {
+		rc = qeth_query_setadapterparms(card);
+		if (rc) {
+			QETH_DBF_MESSAGE(2, "could not query adapter "
+				"parameters on device %s: x%x\n",
+				CARD_BUS_ID(card), rc);
+		}
 	}
 
 	if (card->info.type == QETH_CARD_TYPE_IQD ||

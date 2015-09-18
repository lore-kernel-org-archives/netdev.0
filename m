From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next V2 3/5] qeth: move OSA portname into deprecated status
Date: Fri, 18 Sep 2015 16:06:50 +0200
Message-ID: <1442585212-58347-4-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp14.uk.ibm.com ([195.75.94.110]:45210 "EHLO
	e06smtp14.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753948AbbIROHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 10:07:06 -0400
Received: from /spool/local
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Fri, 18 Sep 2015 15:07:04 +0100
In-Reply-To: <1442585212-58347-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ursula Braun <ursula.braun@de.ibm.com>

An OSA-Express port name was required to identify a shared OSA port.
All operating system instances that shared the port had to use the
same port name. This requirement no longer applies.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  2 --
 drivers/s390/net/qeth_core_main.c | 63 +++++----------------------------------
 drivers/s390/net/qeth_core_sys.c  | 43 +++-----------------------
 3 files changed, 11 insertions(+), 97 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index ba974a2..283d6e6 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -663,9 +663,7 @@ struct qeth_card_info {
 	char mcl_level[QETH_MCL_LENGTH + 1];
 	int guestlan;
 	int mac_bits;
-	int portname_required;
 	int portno;
-	char portname[9];
 	enum qeth_card_types type;
 	enum qeth_link_types link_type;
 	int is_multicast_different;
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 5e20fba..cd39a02 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1982,14 +1982,6 @@ static void qeth_idx_read_cb(struct qeth_channel *channel,
 		goto out;
 	}
 
-/**
- *  * temporary fix for microcode bug
- *   * to revert it,replace OR by AND
- *    */
-	if ((!QETH_IDX_NO_PORTNAME_REQUIRED(iob->data)) ||
-	     (card->info.type == QETH_CARD_TYPE_OSD))
-		card->info.portname_required = 1;
-
 	memcpy(&temp, QETH_IDX_ACT_FUNC_LEVEL(iob->data), 2);
 	if (temp != qeth_peer_func_level(card->info.func_level)) {
 		QETH_DBF_MESSAGE(2, "%s IDX_ACTIVATE on read channel: function "
@@ -2360,8 +2352,6 @@ static int qeth_ulp_enable(struct qeth_card *card)
 	       &card->token.cm_connection_r, QETH_MPC_TOKEN_LENGTH);
 	memcpy(QETH_ULP_ENABLE_FILTER_TOKEN(iob->data),
 	       &card->token.ulp_filter_w, QETH_MPC_TOKEN_LENGTH);
-	memcpy(QETH_ULP_ENABLE_PORTNAME_AND_LL(iob->data),
-	       card->info.portname, 9);
 	rc = qeth_send_control_data(card, ULP_ENABLE_SIZE, iob,
 				    qeth_ulp_enable_cb, NULL);
 	return rc;
@@ -2680,48 +2670,6 @@ out_qdio:
 	return rc;
 }
 
-static void qeth_print_status_with_portname(struct qeth_card *card)
-{
-	char dbf_text[15];
-	int i;
-
-	sprintf(dbf_text, "%s", card->info.portname + 1);
-	for (i = 0; i < 8; i++)
-		dbf_text[i] =
-			(char) _ebcasc[(__u8) dbf_text[i]];
-	dbf_text[8] = 0;
-	dev_info(&card->gdev->dev, "Device is a%s card%s%s%s\n"
-	       "with link type %s (portname: %s)\n",
-	       qeth_get_cardname(card),
-	       (card->info.mcl_level[0]) ? " (level: " : "",
-	       (card->info.mcl_level[0]) ? card->info.mcl_level : "",
-	       (card->info.mcl_level[0]) ? ")" : "",
-	       qeth_get_cardname_short(card),
-	       dbf_text);
-
-}
-
-static void qeth_print_status_no_portname(struct qeth_card *card)
-{
-	if (card->info.portname[0])
-		dev_info(&card->gdev->dev, "Device is a%s "
-		       "card%s%s%s\nwith link type %s "
-		       "(no portname needed by interface).\n",
-		       qeth_get_cardname(card),
-		       (card->info.mcl_level[0]) ? " (level: " : "",
-		       (card->info.mcl_level[0]) ? card->info.mcl_level : "",
-		       (card->info.mcl_level[0]) ? ")" : "",
-		       qeth_get_cardname_short(card));
-	else
-		dev_info(&card->gdev->dev, "Device is a%s "
-		       "card%s%s%s\nwith link type %s.\n",
-		       qeth_get_cardname(card),
-		       (card->info.mcl_level[0]) ? " (level: " : "",
-		       (card->info.mcl_level[0]) ? card->info.mcl_level : "",
-		       (card->info.mcl_level[0]) ? ")" : "",
-		       qeth_get_cardname_short(card));
-}
-
 void qeth_print_status_message(struct qeth_card *card)
 {
 	switch (card->info.type) {
@@ -2758,10 +2706,13 @@ void qeth_print_status_message(struct qeth_card *card)
 	default:
 		memset(&card->info.mcl_level[0], 0, QETH_MCL_LENGTH + 1);
 	}
-	if (card->info.portname_required)
-		qeth_print_status_with_portname(card);
-	else
-		qeth_print_status_no_portname(card);
+	dev_info(&card->gdev->dev,
+		 "Device is a%s card%s%s%s\nwith link type %s.\n",
+		 qeth_get_cardname(card),
+		 (card->info.mcl_level[0]) ? " (level: " : "",
+		 (card->info.mcl_level[0]) ? card->info.mcl_level : "",
+		 (card->info.mcl_level[0]) ? ")" : "",
+		 qeth_get_cardname_short(card));
 }
 EXPORT_SYMBOL_GPL(qeth_print_status_message);
 
diff --git a/drivers/s390/net/qeth_core_sys.c b/drivers/s390/net/qeth_core_sys.c
index 423bec5..e6e5b96 100644
--- a/drivers/s390/net/qeth_core_sys.c
+++ b/drivers/s390/net/qeth_core_sys.c
@@ -153,52 +153,17 @@ static DEVICE_ATTR(portno, 0644, qeth_dev_portno_show, qeth_dev_portno_store);
 static ssize_t qeth_dev_portname_show(struct device *dev,
 				struct device_attribute *attr, char *buf)
 {
-	struct qeth_card *card = dev_get_drvdata(dev);
-	char portname[9] = {0, };
-
-	if (!card)
-		return -EINVAL;
-
-	if (card->info.portname_required) {
-		memcpy(portname, card->info.portname + 1, 8);
-		EBCASC(portname, 8);
-		return sprintf(buf, "%s\n", portname);
-	} else
-		return sprintf(buf, "no portname required\n");
+	return sprintf(buf, "no portname required\n");
 }
 
 static ssize_t qeth_dev_portname_store(struct device *dev,
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
-	char *tmp;
-	int i, rc = 0;
-
-	if (!card)
-		return -EINVAL;
-
-	mutex_lock(&card->conf_mutex);
-	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER)) {
-		rc = -EPERM;
-		goto out;
-	}
 
-	tmp = strsep((char **) &buf, "\n");
-	if ((strlen(tmp) > 8) || (strlen(tmp) == 0)) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	card->info.portname[0] = strlen(tmp);
-	/* for beauty reasons */
-	for (i = 1; i < 9; i++)
-		card->info.portname[i] = ' ';
-	strcpy(card->info.portname + 1, tmp);
-	ASCEBC(card->info.portname + 1, 8);
-out:
-	mutex_unlock(&card->conf_mutex);
-	return rc ? rc : count;
+	dev_warn_once(&card->gdev->dev,
+		      "portname is deprecated and is ignored\n");
+	return count;
 }
 
 static DEVICE_ATTR(portname, 0644, qeth_dev_portname_show,
-- 
2.3.8

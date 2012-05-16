From: frank.blaschka@de.ibm.com
Subject: [patch 1/2] [PATCH] qeth: remove token ring part 2
Date: Wed, 16 May 2012 13:28:25 +0200
Message-ID: <20120516112915.515805833@de.ibm.com>
References: <20120516112824.602200177@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp17.uk.ibm.com ([195.75.94.113]:44843 "EHLO
	e06smtp17.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S967417Ab2EPL3V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 07:29:21 -0400
Received: from /spool/local
	by e06smtp17.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <frank.blaschka@de.ibm.com>;
	Wed, 16 May 2012 12:29:19 +0100
Content-Disposition: inline; filename=qeth_l3_rem_tr.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Commit 1abd2296b4a1ee7b6a883541c3ede52042a09521 starts removing
token ring from qeth_l3. This patch removes the rest of token
ring related code from the driver.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_core.h      |    2 
 drivers/s390/net/qeth_core_main.c |    2 
 drivers/s390/net/qeth_core_mpc.h  |   10 ---
 drivers/s390/net/qeth_l3_main.c   |   55 ------------------
 drivers/s390/net/qeth_l3_sys.c    |  112 --------------------------------------
 5 files changed, 181 deletions(-)

--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -674,8 +674,6 @@ struct qeth_card_options {
 	struct qeth_ipa_info adp; /*Adapter parameters*/
 	struct qeth_routing_info route6;
 	struct qeth_ipa_info ipa6;
-	int broadcast_mode;
-	int macaddr_mode;
 	int fake_broadcast;
 	int add_hhlen;
 	int layer2;
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -1329,8 +1329,6 @@ static void qeth_set_intial_options(stru
 {
 	card->options.route4.type = NO_ROUTER;
 	card->options.route6.type = NO_ROUTER;
-	card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
-	card->options.macaddr_mode = QETH_TR_MACADDR_NONCANONICAL;
 	card->options.fake_broadcast = 0;
 	card->options.add_hhlen = DEFAULT_ADD_HHLEN;
 	card->options.performance_stats = 0;
--- a/drivers/s390/net/qeth_core_mpc.h
+++ b/drivers/s390/net/qeth_core_mpc.h
@@ -70,16 +70,6 @@ enum qeth_link_types {
 	QETH_LINK_TYPE_ATM_NATIVE   = 0x90,
 };
 
-enum qeth_tr_macaddr_modes {
-	QETH_TR_MACADDR_NONCANONICAL = 0,
-	QETH_TR_MACADDR_CANONICAL    = 1,
-};
-
-enum qeth_tr_broadcast_modes {
-	QETH_TR_BROADCAST_ALLRINGS = 0,
-	QETH_TR_BROADCAST_LOCAL    = 1,
-};
-
 /*
  * Routing stuff
  */
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -976,57 +976,6 @@ static inline u8 qeth_l3_get_qeth_hdr_fl
 	return ct | QETH_CAST_UNICAST;
 }
 
-static int qeth_l3_send_setadp_mode(struct qeth_card *card, __u32 command,
-					__u32 mode)
-{
-	int rc;
-	struct qeth_cmd_buffer *iob;
-	struct qeth_ipa_cmd *cmd;
-
-	QETH_CARD_TEXT(card, 4, "adpmode");
-
-	iob = qeth_get_adapter_cmd(card, command,
-				   sizeof(struct qeth_ipacmd_setadpparms));
-	cmd = (struct qeth_ipa_cmd *)(iob->data+IPA_PDU_HEADER_SIZE);
-	cmd->data.setadapterparms.data.mode = mode;
-	rc = qeth_send_ipa_cmd(card, iob, qeth_default_setadapterparms_cb,
-			       NULL);
-	return rc;
-}
-
-static int qeth_l3_setadapter_hstr(struct qeth_card *card)
-{
-	int rc;
-
-	QETH_CARD_TEXT(card, 4, "adphstr");
-
-	if (qeth_adp_supported(card, IPA_SETADP_SET_BROADCAST_MODE)) {
-		rc = qeth_l3_send_setadp_mode(card,
-					IPA_SETADP_SET_BROADCAST_MODE,
-					card->options.broadcast_mode);
-		if (rc)
-			QETH_DBF_MESSAGE(2, "couldn't set broadcast mode on "
-				   "device %s: x%x\n",
-				   CARD_BUS_ID(card), rc);
-		rc = qeth_l3_send_setadp_mode(card,
-					IPA_SETADP_ALTER_MAC_ADDRESS,
-					card->options.macaddr_mode);
-		if (rc)
-			QETH_DBF_MESSAGE(2, "couldn't set macaddr mode on "
-				   "device %s: x%x\n", CARD_BUS_ID(card), rc);
-		return rc;
-	}
-	if (card->options.broadcast_mode == QETH_TR_BROADCAST_LOCAL)
-		QETH_DBF_MESSAGE(2, "set adapter parameters not available "
-			   "to set broadcast mode, using ALLRINGS "
-			   "on device %s:\n", CARD_BUS_ID(card));
-	if (card->options.macaddr_mode == QETH_TR_MACADDR_CANONICAL)
-		QETH_DBF_MESSAGE(2, "set adapter parameters not available "
-			   "to set macaddr mode, using NONCANONICAL "
-			   "on device %s:\n", CARD_BUS_ID(card));
-	return 0;
-}
-
 static int qeth_l3_setadapter_parms(struct qeth_card *card)
 {
 	int rc;
@@ -1052,10 +1001,6 @@ static int qeth_l3_setadapter_parms(stru
 				" address failed\n");
 	}
 
-	if ((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
-	    (card->info.link_type == QETH_LINK_TYPE_LANE_TR))
-		rc = qeth_l3_setadapter_hstr(card);
-
 	return rc;
 }
 
--- a/drivers/s390/net/qeth_l3_sys.c
+++ b/drivers/s390/net/qeth_l3_sys.c
@@ -175,116 +175,6 @@ out:
 static DEVICE_ATTR(fake_broadcast, 0644, qeth_l3_dev_fake_broadcast_show,
 		   qeth_l3_dev_fake_broadcast_store);
 
-static ssize_t qeth_l3_dev_broadcast_mode_show(struct device *dev,
-				struct device_attribute *attr, char *buf)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-
-	if (!card)
-		return -EINVAL;
-
-	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
-	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR)))
-		return sprintf(buf, "n/a\n");
-
-	return sprintf(buf, "%s\n", (card->options.broadcast_mode ==
-				     QETH_TR_BROADCAST_ALLRINGS)?
-		       "all rings":"local");
-}
-
-static ssize_t qeth_l3_dev_broadcast_mode_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t count)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-	char *tmp;
-	int rc = 0;
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
-
-	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
-	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	tmp = strsep((char **) &buf, "\n");
-
-	if (!strcmp(tmp, "local"))
-		card->options.broadcast_mode = QETH_TR_BROADCAST_LOCAL;
-	else if (!strcmp(tmp, "all_rings"))
-		card->options.broadcast_mode = QETH_TR_BROADCAST_ALLRINGS;
-	else
-		rc = -EINVAL;
-out:
-	mutex_unlock(&card->conf_mutex);
-	return rc ? rc : count;
-}
-
-static DEVICE_ATTR(broadcast_mode, 0644, qeth_l3_dev_broadcast_mode_show,
-		   qeth_l3_dev_broadcast_mode_store);
-
-static ssize_t qeth_l3_dev_canonical_macaddr_show(struct device *dev,
-				struct device_attribute *attr, char *buf)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
-
-	if (!card)
-		return -EINVAL;
-
-	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
-	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR)))
-		return sprintf(buf, "n/a\n");
-
-	return sprintf(buf, "%i\n", (card->options.macaddr_mode ==
-				     QETH_TR_MACADDR_CANONICAL)? 1:0);
-}
-
-static ssize_t qeth_l3_dev_canonical_macaddr_store(struct device *dev,
-		struct device_attribute *attr, const char *buf, size_t count)
-{
-	struct qeth_card *card = dev_get_drvdata(dev);
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
-
-	if (!((card->info.link_type == QETH_LINK_TYPE_HSTR) ||
-	      (card->info.link_type == QETH_LINK_TYPE_LANE_TR))) {
-		rc = -EINVAL;
-		goto out;
-	}
-
-	i = simple_strtoul(buf, &tmp, 16);
-	if ((i == 0) || (i == 1))
-		card->options.macaddr_mode = i?
-			QETH_TR_MACADDR_CANONICAL :
-			QETH_TR_MACADDR_NONCANONICAL;
-	else
-		rc = -EINVAL;
-out:
-	mutex_unlock(&card->conf_mutex);
-	return rc ? rc : count;
-}
-
-static DEVICE_ATTR(canonical_macaddr, 0644, qeth_l3_dev_canonical_macaddr_show,
-		   qeth_l3_dev_canonical_macaddr_store);
-
 static ssize_t qeth_l3_dev_sniffer_show(struct device *dev,
 		struct device_attribute *attr, char *buf)
 {
@@ -458,8 +348,6 @@ static struct attribute *qeth_l3_device_
 	&dev_attr_route4.attr,
 	&dev_attr_route6.attr,
 	&dev_attr_fake_broadcast.attr,
-	&dev_attr_broadcast_mode.attr,
-	&dev_attr_canonical_macaddr.attr,
 	&dev_attr_sniffer.attr,
 	&dev_attr_hsuid.attr,
 	NULL,

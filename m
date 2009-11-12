From: frank.blaschka@de.ibm.com
Subject: [patch 5/5] [PATCH] qeth: allow dynamic change of rx checksumming
Date: Thu, 12 Nov 2009 11:11:45 +0100
Message-ID: <20091112101301.253816000@de.ibm.com>
References: <20091112101140.882313000@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.de.ibm.com ([195.212.17.166]:38529 "EHLO
	mtagate6.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752343AbZKLKM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Nov 2009 05:12:56 -0500
Content-Disposition: inline; filename=610-qeth-rx-checksum.diff
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

Technically there is no need to set the card offline to change
RX checksumming. Get rid of this stupid limitation.

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---

 drivers/s390/net/qeth_l3.h      |    1 
 drivers/s390/net/qeth_l3_main.c |   44 +++++++++++++++++++++++++++-------------
 drivers/s390/net/qeth_l3_sys.c  |   19 +++++++++--------
 3 files changed, 41 insertions(+), 23 deletions(-)

Index: git_net-next/drivers/s390/net/qeth_l3.h
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3.h
+++ git_net-next/drivers/s390/net/qeth_l3.h
@@ -61,5 +61,6 @@ int qeth_l3_add_rxip(struct qeth_card *,
 void qeth_l3_del_rxip(struct qeth_card *card, enum qeth_prot_versions,
 			const u8 *);
 int qeth_l3_set_large_send(struct qeth_card *, enum qeth_large_send_types);
+int qeth_l3_set_rx_csum(struct qeth_card *, enum qeth_checksum_types);
 
 #endif /* __QETH_L3_H__ */
Index: git_net-next/drivers/s390/net/qeth_l3_main.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3_main.c
+++ git_net-next/drivers/s390/net/qeth_l3_main.c
@@ -1465,6 +1465,35 @@ static int qeth_l3_send_checksum_command
 	return 0;
 }
 
+int qeth_l3_set_rx_csum(struct qeth_card *card,
+	enum qeth_checksum_types csum_type)
+{
+	int rc = 0;
+
+	if (card->options.checksum_type == HW_CHECKSUMMING) {
+		if ((csum_type != HW_CHECKSUMMING) &&
+			(card->state != CARD_STATE_DOWN)) {
+			rc = qeth_l3_send_simple_setassparms(card,
+				IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
+			if (rc)
+				return -EIO;
+		}
+	} else {
+		if (csum_type == HW_CHECKSUMMING) {
+			if (card->state != CARD_STATE_DOWN) {
+				if (!qeth_is_supported(card,
+				    IPA_INBOUND_CHECKSUM))
+					return -EPERM;
+				rc = qeth_l3_send_checksum_command(card);
+				if (rc)
+					return -EIO;
+			}
+		}
+	}
+	card->options.checksum_type = csum_type;
+	return rc;
+}
+
 static int qeth_l3_start_ipa_checksum(struct qeth_card *card)
 {
 	int rc = 0;
@@ -2954,27 +2983,14 @@ static u32 qeth_l3_ethtool_get_rx_csum(s
 static int qeth_l3_ethtool_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct qeth_card *card = dev->ml_priv;
-	enum qeth_card_states old_state;
 	enum qeth_checksum_types csum_type;
 
-	if ((card->state != CARD_STATE_UP) &&
-	    (card->state != CARD_STATE_DOWN))
-		return -EPERM;
-
 	if (data)
 		csum_type = HW_CHECKSUMMING;
 	else
 		csum_type = SW_CHECKSUMMING;
 
-	if (card->options.checksum_type != csum_type) {
-		old_state = card->state;
-		if (card->state == CARD_STATE_UP)
-			__qeth_l3_set_offline(card->gdev, 1);
-		card->options.checksum_type = csum_type;
-		if (old_state == CARD_STATE_UP)
-			__qeth_l3_set_online(card->gdev, 1);
-	}
-	return 0;
+	return qeth_l3_set_rx_csum(card, csum_type);
 }
 
 static int qeth_l3_ethtool_set_tso(struct net_device *dev, u32 data)
Index: git_net-next/drivers/s390/net/qeth_l3_sys.c
===================================================================
--- git_net-next.orig/drivers/s390/net/qeth_l3_sys.c
+++ git_net-next/drivers/s390/net/qeth_l3_sys.c
@@ -293,25 +293,26 @@ static ssize_t qeth_l3_dev_checksum_stor
 		struct device_attribute *attr, const char *buf, size_t count)
 {
 	struct qeth_card *card = dev_get_drvdata(dev);
+	enum qeth_checksum_types csum_type;
 	char *tmp;
+	int rc;
 
 	if (!card)
 		return -EINVAL;
 
-	if ((card->state != CARD_STATE_DOWN) &&
-	    (card->state != CARD_STATE_RECOVER))
-		return -EPERM;
-
 	tmp = strsep((char **) &buf, "\n");
 	if (!strcmp(tmp, "sw_checksumming"))
-		card->options.checksum_type = SW_CHECKSUMMING;
+		csum_type = SW_CHECKSUMMING;
 	else if (!strcmp(tmp, "hw_checksumming"))
-		card->options.checksum_type = HW_CHECKSUMMING;
+		csum_type = HW_CHECKSUMMING;
 	else if (!strcmp(tmp, "no_checksumming"))
-		card->options.checksum_type = NO_CHECKSUMMING;
-	else {
+		csum_type = NO_CHECKSUMMING;
+	else
 		return -EINVAL;
-	}
+
+	rc = qeth_l3_set_rx_csum(card, csum_type);
+	if (rc)
+		return rc;
 	return count;
 }
 


From: frank.blaschka@de.ibm.com
Subject: [patch 1/1] qeth: use ndo_set_features callback for initial setup and recovery
Date: Wed, 18 May 2011 15:28:35 +0200
Message-ID: <20110518132905.064355130@de.ibm.com>
References: <20110518132834.728225299@de.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate6.uk.ibm.com ([194.196.100.166]:46516 "EHLO
	mtagate6.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756255Ab1ERN3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 09:29:07 -0400
Content-Disposition: inline; filename=qeth_fix_hw_feature.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Frank Blaschka <frank.blaschka@de.ibm.com>

This patch uses the ndo_set_features callback during normal device
startup or recovery to turn on hardware RX checksum. Patch was done
with much help from Michal Miroslaw, thx!!!

Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c |   77 ++++++++++++----------------------------
 1 file changed, 25 insertions(+), 52 deletions(-)

--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1417,63 +1417,33 @@ int qeth_l3_set_rx_csum(struct qeth_card
 	int rc = 0;
 
 	if (on) {
-		if (card->state != CARD_STATE_DOWN) {
-			if (!qeth_is_supported(card,
-				    IPA_INBOUND_CHECKSUM))
-					return -EPERM;
-			rc = qeth_l3_send_checksum_command(card);
-			if (rc)
-				return -EIO;
-		}
-		card->dev->features |= NETIF_F_RXCSUM;
+		rc = qeth_l3_send_checksum_command(card);
+		if (rc)
+			return -EIO;
+		dev_info(&card->gdev->dev,
+			"HW Checksumming (inbound) enabled\n");
 	} else {
-		if (card->state != CARD_STATE_DOWN) {
-			rc = qeth_l3_send_simple_setassparms(card,
-				IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
-			if (rc)
-				return -EIO;
-		}
-		card->dev->features &= ~NETIF_F_RXCSUM;
+		rc = qeth_l3_send_simple_setassparms(card,
+			IPA_INBOUND_CHECKSUM, IPA_CMD_ASS_STOP, 0);
+		if (rc)
+			return -EIO;
 	}
 
-	return rc;
+	return 0;
 }
 
 static int qeth_l3_start_ipa_checksum(struct qeth_card *card)
 {
-	int rc = 0;
-
 	QETH_CARD_TEXT(card, 3, "strtcsum");
 
 	if (card->dev->features & NETIF_F_RXCSUM) {
-		/* hw may have changed during offline or recovery */
-		if (!qeth_is_supported(card, IPA_INBOUND_CHECKSUM)) {
-			dev_info(&card->gdev->dev,
-			"Inbound HW Checksumming not "
-			"supported on %s,\ncontinuing "
-			"using Inbound SW Checksumming\n",
-			QETH_CARD_IFNAME(card));
-			goto update_feature;
-		}
-
-		rc = qeth_l3_send_checksum_command(card);
-		if (!rc)
-			dev_info(&card->gdev->dev,
-			"HW Checksumming (inbound) enabled\n");
-		else
-			goto update_feature;
-	} else
-		dev_info(&card->gdev->dev,
-			"Using SW checksumming on %s.\n",
-			QETH_CARD_IFNAME(card));
+		rtnl_lock();
+		/* force set_features call */
+		card->dev->features &= ~NETIF_F_RXCSUM;
+		netdev_update_features(card->dev);
+		rtnl_unlock();
+	}
 	return 0;
-
-update_feature:
-	rtnl_lock();
-	card->dev->features &= ~NETIF_F_RXCSUM;
-	netdev_update_features(card->dev);
-	rtnl_unlock();
-	return rc;
 }
 
 static int qeth_l3_start_ipa_tx_checksum(struct qeth_card *card)
@@ -3196,17 +3166,20 @@ static int qeth_l3_set_features(struct n
 {
 	struct qeth_card *card = dev->ml_priv;
 	u32 changed = dev->features ^ features;
-	int on;
+	int err;
 
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
 
-	if (features & NETIF_F_RXCSUM)
-		on = 1;
-	else
-		on = 0;
+	if (card->state == CARD_STATE_DOWN ||
+	    card->state == CARD_STATE_RECOVER)
+		return 0;
+
+	err = qeth_l3_set_rx_csum(card, features & NETIF_F_RXCSUM);
+	if (err)
+		dev->features = features ^ NETIF_F_RXCSUM;
 
-	return qeth_l3_set_rx_csum(card, on);
+	return err;
 }
 
 static const struct ethtool_ops qeth_l3_ethtool_ops = {


From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 11/13] qeth: improve set_features error handling
Date: Thu, 16 Jun 2016 16:19:01 +0200
Message-ID: <1466086743-55484-12-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	utz.bacher@de.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:31729 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754547AbcFPOTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 10:19:41 -0400
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GEIwsd070759
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:36 -0400
Received: from e06smtp16.uk.ibm.com (e06smtp16.uk.ibm.com [195.75.94.112])
	by mx0a-001b2d01.pphosted.com with ESMTP id 23kq6y8pbh-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:19:36 -0400
Received: from localhost
	by e06smtp16.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Thu, 16 Jun 2016 15:19:34 +0100
In-Reply-To: <1466086743-55484-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

The function set_features is called to configure network device features
on the hardware. If errors occur, the network device features should
reflect the changed hardware state and the function should return an
error in order to notify the user.

In case of an error, the current implementation does not necessarily
save the changed hardware state in the network device features before an
error is returned.

This patch improves error handling by saving features, that could be
changed, to the network device features before returning an error. If
the device is not running, an additional check in fix_features removes
features, that require hardware changes, before they are passed to
set_features. Thus, the corresponding check was removed in set_features.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core_main.c | 38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 19a6ee0..44d3200 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6125,27 +6125,38 @@ static int qeth_set_ipa_tso(struct qeth_card *card, int on)
 int qeth_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct qeth_card *card = dev->ml_priv;
-	netdev_features_t changed = card->dev->features ^ features;
+	netdev_features_t changed = dev->features ^ features;
 	int rc = 0;
 
 	QETH_DBF_TEXT(SETUP, 2, "setfeat");
 	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
 
-	if (card->state == CARD_STATE_DOWN ||
-	    card->state == CARD_STATE_RECOVER)
-		return 0;
-
-	if ((changed & NETIF_F_IP_CSUM))
+	if ((changed & NETIF_F_IP_CSUM)) {
 		rc = qeth_set_ipa_csum(card,
 				       features & NETIF_F_IP_CSUM ? 1 : 0,
 				       IPA_OUTBOUND_CHECKSUM);
-	if ((changed & NETIF_F_RXCSUM))
-		rc |= qeth_set_ipa_csum(card,
+		if (rc)
+			changed ^= NETIF_F_IP_CSUM;
+	}
+	if ((changed & NETIF_F_RXCSUM)) {
+		rc = qeth_set_ipa_csum(card,
 					features & NETIF_F_RXCSUM ? 1 : 0,
 					IPA_INBOUND_CHECKSUM);
-	if ((changed & NETIF_F_TSO))
-		rc |= qeth_set_ipa_tso(card, features & NETIF_F_TSO ? 1 : 0);
-	return rc ? -EIO : 0;
+		if (rc)
+			changed ^= NETIF_F_RXCSUM;
+	}
+	if ((changed & NETIF_F_TSO)) {
+		rc = qeth_set_ipa_tso(card, features & NETIF_F_TSO ? 1 : 0);
+		if (rc)
+			changed ^= NETIF_F_TSO;
+	}
+
+	/* everything changed successfully? */
+	if ((dev->features ^ features) == changed)
+		return 0;
+	/* something went wrong. save changed features and return error */
+	dev->features ^= changed;
+	return -EIO;
 }
 EXPORT_SYMBOL_GPL(qeth_set_features);
 
@@ -6164,6 +6175,11 @@ netdev_features_t qeth_fix_features(struct net_device *dev,
 		dev_info(&card->gdev->dev, "Outbound TSO not supported on %s\n",
 			 QETH_CARD_IFNAME(card));
 	}
+	/* if the card isn't up, remove features that require hw changes */
+	if (card->state == CARD_STATE_DOWN ||
+	    card->state == CARD_STATE_RECOVER)
+		features = features & ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
+					NETIF_F_TSO);
 	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
 	return features;
 }
-- 
2.6.6

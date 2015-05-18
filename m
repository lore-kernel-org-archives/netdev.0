From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net-next 1/8] qeth: fix rx checksum offload handling
Date: Mon, 18 May 2015 14:27:52 +0200
Message-ID: <1431952079-6847-2-git-send-email-ubraun@linux.vnet.ibm.com>
References: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
	ursula.braun@de.ibm.com, ubraun@linux.vnet.ibm.com,
	Thomas Richter <tmricht@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e06smtp12.uk.ibm.com ([195.75.94.108]:39756 "EHLO
	e06smtp12.uk.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753939AbbERM2T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:28:19 -0400
Received: from /spool/local
	by e06smtp12.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
	Mon, 18 May 2015 13:28:17 +0100
In-Reply-To: <1431952079-6847-1-git-send-email-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Richter <tmricht@linux.vnet.ibm.com>

ethtool is used to change some device driver features
such as RX/TX hardware checksum offloading.
The qeth device driver callback function to
turn on/off RX hardware check sum handling never changes
the hardware configuration.
The NETIF_F_RXCSUM bit is cleared when the feature bitset
type netdev_features_t(64bit) is assigned to 32 a bit
variable.

This patch fixes the NETIF_F_RXCSUM handling.
Also there is no need to manipulate the device's features
bit set as this is done by the caller when no error occurs.

Signed-off-by: Thomas Richter <tmricht@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
---
 drivers/s390/net/qeth_l3_main.c | 9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 04e42c6..70eb2f6 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3198,8 +3198,7 @@ static int qeth_l3_set_features(struct net_device *dev,
 	netdev_features_t features)
 {
 	struct qeth_card *card = dev->ml_priv;
-	u32 changed = dev->features ^ features;
-	int err;
+	netdev_features_t changed = dev->features ^ features;
 
 	if (!(changed & NETIF_F_RXCSUM))
 		return 0;
@@ -3208,11 +3207,7 @@ static int qeth_l3_set_features(struct net_device *dev,
 	    card->state == CARD_STATE_RECOVER)
 		return 0;
 
-	err = qeth_l3_set_rx_csum(card, features & NETIF_F_RXCSUM);
-	if (err)
-		dev->features = features ^ NETIF_F_RXCSUM;
-
-	return err;
+	return qeth_l3_set_rx_csum(card, features & NETIF_F_RXCSUM ? 1 : 0);
 }
 
 static const struct ethtool_ops qeth_l3_ethtool_ops = {
-- 
2.3.7

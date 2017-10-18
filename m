From: Julian Wiedmann <jwi@linux.vnet.ibm.com>
Subject: [PATCH net-next 01/13] s390/qeth: rely on kernel for feature recovery
Date: Wed, 18 Oct 2017 17:40:13 +0200
Message-ID: <20171018154025.73630-2-jwi@linux.vnet.ibm.com>
References: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Cc: <netdev@vger.kernel.org>, <linux-s390@vger.kernel.org>,
        Martin Schwidefsky <schwidefsky@de.ibm.com>,
        Heiko Carstens <heiko.carstens@de.ibm.com>,
        Stefan Raspl <raspl@linux.vnet.ibm.com>,
        Ursula Braun <ubraun@linux.vnet.ibm.com>,
        Julian Wiedmann <jwi@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:40084 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751854AbdJRPkm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 11:40:42 -0400
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.21/8.16.0.21) with SMTP id v9IFdXKW147310
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:41 -0400
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
        by mx0a-001b2d01.pphosted.com with ESMTP id 2dp6squ72j-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 11:40:41 -0400
Received: from localhost
        by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <jwi@linux.vnet.ibm.com>;
        Wed, 18 Oct 2017 16:40:39 +0100
In-Reply-To: <20171018154025.73630-1-jwi@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When recovering a device, qeth needs to re-run the IPA commands that
enable all previously active HW features.
Instead of duplicating qeth_set_features(), let netdev_update_features()
recover the missing HW features from dev->wanted_features.

Signed-off-by: Julian Wiedmann <jwi@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  2 +-
 drivers/s390/net/qeth_core_main.c | 40 ++++++++++++++++++---------------------
 2 files changed, 19 insertions(+), 23 deletions(-)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index 91fcadbede80..3b6aa0c48221 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -998,7 +998,7 @@ struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *,
 						 __u16, __u16,
 						 enum qeth_prot_versions);
 int qeth_set_features(struct net_device *, netdev_features_t);
-int qeth_recover_features(struct net_device *);
+void qeth_recover_features(struct net_device *dev);
 netdev_features_t qeth_fix_features(struct net_device *, netdev_features_t);
 int qeth_vm_request_mac(struct qeth_card *card);
 int qeth_push_hdr(struct sk_buff *skb, struct qeth_hdr **hdr, unsigned int len);
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 68e118f1202e..e10e5b8d476c 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6403,32 +6403,29 @@ static int qeth_set_ipa_tso(struct qeth_card *card, int on)
 	return rc;
 }
 
-/* try to restore device features on a device after recovery */
-int qeth_recover_features(struct net_device *dev)
+#define QETH_HW_FEATURES (NETIF_F_RXCSUM | NETIF_F_IP_CSUM | NETIF_F_TSO)
+
+/**
+ * qeth_recover_features() - Restore device features after recovery
+ * @dev:	the recovering net_device
+ *
+ * Caller must hold rtnl lock.
+ */
+void qeth_recover_features(struct net_device *dev)
 {
+	netdev_features_t features = dev->features;
 	struct qeth_card *card = dev->ml_priv;
-	netdev_features_t recover = dev->features;
-
-	if (recover & NETIF_F_IP_CSUM) {
-		if (qeth_set_ipa_csum(card, 1, IPA_OUTBOUND_CHECKSUM))
-			recover ^= NETIF_F_IP_CSUM;
-	}
-	if (recover & NETIF_F_RXCSUM) {
-		if (qeth_set_ipa_csum(card, 1, IPA_INBOUND_CHECKSUM))
-			recover ^= NETIF_F_RXCSUM;
-	}
-	if (recover & NETIF_F_TSO) {
-		if (qeth_set_ipa_tso(card, 1))
-			recover ^= NETIF_F_TSO;
-	}
 
-	if (recover == dev->features)
-		return 0;
+	/* force-off any feature that needs an IPA sequence.
+	 * netdev_update_features() will restart them.
+	 */
+	dev->features &= ~QETH_HW_FEATURES;
+	netdev_update_features(dev);
 
+	if (features == dev->features)
+		return;
 	dev_warn(&card->gdev->dev,
 		 "Device recovery failed to restore all offload features\n");
-	dev->features = recover;
-	return -EIO;
 }
 EXPORT_SYMBOL_GPL(qeth_recover_features);
 
@@ -6485,8 +6482,7 @@ netdev_features_t qeth_fix_features(struct net_device *dev,
 	/* if the card isn't up, remove features that require hw changes */
 	if (card->state == CARD_STATE_DOWN ||
 	    card->state == CARD_STATE_RECOVER)
-		features = features & ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
-					NETIF_F_TSO);
+		features &= ~QETH_HW_FEATURES;
 	QETH_DBF_HEX(SETUP, 2, &features, sizeof(features));
 	return features;
 }
-- 
2.13.5

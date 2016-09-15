From: Ursula Braun <ubraun@linux.vnet.ibm.com>
Subject: [PATCH net 1/7] qeth: restore device features after recovery
Date: Thu, 15 Sep 2016 14:39:21 +0200
Message-ID: <20160915123927.86579-2-ubraun@linux.vnet.ibm.com>
References: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Cc: netdev@vger.kernel.org, linux-s390@vger.kernel.org,
        schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
        ubraun@linux.vnet.ibm.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-001b2d01.pphosted.com ([148.163.156.1]:40925 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934075AbcIOMjj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Sep 2016 08:39:39 -0400
Received: from pps.filterd (m0098409.ppops.net [127.0.0.1])
        by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8FCX8GC057053
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:39 -0400
Received: from e06smtp06.uk.ibm.com (e06smtp06.uk.ibm.com [195.75.94.102])
        by mx0a-001b2d01.pphosted.com with ESMTP id 25fqtrmxtm-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 15 Sep 2016 08:39:38 -0400
Received: from localhost
        by e06smtp06.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <ubraun@linux.vnet.ibm.com>;
        Thu, 15 Sep 2016 13:39:36 +0100
In-Reply-To: <20160915123927.86579-1-ubraun@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hans Wippel <hwippel@linux.vnet.ibm.com>

After device recovery, only a basic set of network device features is
enabled on the device. If features like checksum offloading or TSO were
enabled by the user before the recovery, this results in a mismatch
between the network device features, that the kernel assumes to be
enabled on the device, and the features actually enabled on the device.

This patch tries to restore previously set features, that require
changes on the device, after the recovery of a device. In case of an
error, the network device's features are changed to contain only the
features that are actually turned on.

Signed-off-by: Hans Wippel <hwippel@linux.vnet.ibm.com>
Signed-off-by: Ursula Braun <ubraun@linux.vnet.ibm.com>
---
 drivers/s390/net/qeth_core.h      |  1 +
 drivers/s390/net/qeth_core_main.c | 29 +++++++++++++++++++++++++++++
 drivers/s390/net/qeth_l2_main.c   |  3 +++
 drivers/s390/net/qeth_l3_main.c   |  1 +
 4 files changed, 34 insertions(+)

diff --git a/drivers/s390/net/qeth_core.h b/drivers/s390/net/qeth_core.h
index bf40063..6d4b68c4 100644
--- a/drivers/s390/net/qeth_core.h
+++ b/drivers/s390/net/qeth_core.h
@@ -999,6 +999,7 @@ struct qeth_cmd_buffer *qeth_get_setassparms_cmd(struct qeth_card *,
 						 __u16, __u16,
 						 enum qeth_prot_versions);
 int qeth_set_features(struct net_device *, netdev_features_t);
+int qeth_recover_features(struct net_device *);
 netdev_features_t qeth_fix_features(struct net_device *, netdev_features_t);
 
 /* exports for OSN */
diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index 7dba6c8..6ad5a14 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -6131,6 +6131,35 @@ static int qeth_set_ipa_tso(struct qeth_card *card, int on)
 	return rc;
 }
 
+/* try to restore device features on a device after recovery */
+int qeth_recover_features(struct net_device *dev)
+{
+	struct qeth_card *card = dev->ml_priv;
+	netdev_features_t recover = dev->features;
+
+	if (recover & NETIF_F_IP_CSUM) {
+		if (qeth_set_ipa_csum(card, 1, IPA_OUTBOUND_CHECKSUM))
+			recover ^= NETIF_F_IP_CSUM;
+	}
+	if (recover & NETIF_F_RXCSUM) {
+		if (qeth_set_ipa_csum(card, 1, IPA_INBOUND_CHECKSUM))
+			recover ^= NETIF_F_RXCSUM;
+	}
+	if (recover & NETIF_F_TSO) {
+		if (qeth_set_ipa_tso(card, 1))
+			recover ^= NETIF_F_TSO;
+	}
+
+	if (recover == dev->features)
+		return 0;
+
+	dev_warn(&card->gdev->dev,
+		 "Device recovery failed to restore all offload features\n");
+	dev->features = recover;
+	return -EIO;
+}
+EXPORT_SYMBOL_GPL(qeth_recover_features);
+
 int qeth_set_features(struct net_device *dev, netdev_features_t features)
 {
 	struct qeth_card *card = dev->ml_priv;
diff --git a/drivers/s390/net/qeth_l2_main.c b/drivers/s390/net/qeth_l2_main.c
index 7bc20c5..54fd891 100644
--- a/drivers/s390/net/qeth_l2_main.c
+++ b/drivers/s390/net/qeth_l2_main.c
@@ -1246,6 +1246,9 @@ contin:
 		}
 		/* this also sets saved unicast addresses */
 		qeth_l2_set_rx_mode(card->dev);
+		rtnl_lock();
+		qeth_recover_features(card->dev);
+		rtnl_unlock();
 	}
 	/* let user_space know that device is online */
 	kobject_uevent(&gdev->dev.kobj, KOBJ_CHANGE);
diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index 7293466..2f51271 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -3269,6 +3269,7 @@ contin:
 		else
 			dev_open(card->dev);
 		qeth_l3_set_multicast_list(card->dev);
+		qeth_recover_features(card->dev);
 		rtnl_unlock();
 	}
 	qeth_trace_features(card);
-- 
2.8.4

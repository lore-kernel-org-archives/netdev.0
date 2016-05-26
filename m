From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net 2/8] qede: Reload on GRO changes
Date: Thu, 26 May 2016 11:01:18 +0300
Message-ID: <1464249684-976-3-git-send-email-Yuval.Mintz@qlogic.com>
References: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:60328 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753242AbcEZIBj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 04:01:39 -0400
In-Reply-To: <1464249684-976-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since driver is using a FW-based GRO implementation, this has some
effects on its ability to cope with GRO enablement/disablement.
As a result, driver must perform an inner-reload as a result of a state
change in the offload configuration of said feature.

[Failure to do so means network stack would continue to receive
aggregated packets even though user requested the feature to be disabled].

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_main.c | 24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index 3bb1428..5d00d14 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2091,6 +2091,29 @@ static void qede_vlan_mark_nonconfigured(struct qede_dev *edev)
 	edev->accept_any_vlan = false;
 }
 
+int qede_set_features(struct net_device *dev, netdev_features_t features)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	netdev_features_t changes = features ^ dev->features;
+	bool need_reload = false;
+
+	/* No action needed if hardware GRO is disabled during driver load */
+	if (changes & NETIF_F_GRO) {
+		if (dev->features & NETIF_F_GRO)
+			need_reload = !edev->gro_disable;
+		else
+			need_reload = edev->gro_disable;
+	}
+
+	if (need_reload && netif_running(edev->ndev)) {
+		dev->features = features;
+		qede_reload(edev, NULL, NULL);
+		return 1;
+	}
+
+	return 0;
+}
+
 #ifdef CONFIG_QEDE_VXLAN
 static void qede_add_vxlan_port(struct net_device *dev,
 				sa_family_t sa_family, __be16 port)
@@ -2175,6 +2198,7 @@ static const struct net_device_ops qede_netdev_ops = {
 #endif
 	.ndo_vlan_rx_add_vid = qede_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid = qede_vlan_rx_kill_vid,
+	.ndo_set_features = qede_set_features,
 	.ndo_get_stats64 = qede_get_stats64,
 #ifdef CONFIG_QED_SRIOV
 	.ndo_set_vf_link_state = qede_set_vf_link_state,
-- 
1.9.3

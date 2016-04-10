From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH 3/4] qede: add Rx flow hash/indirection support.
Date: Sun, 10 Apr 2016 12:43:01 +0300
Message-ID: <1460281382-13656-4-git-send-email-Yuval.Mintz@qlogic.com>
References: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:37921 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752485AbcDJJnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Apr 2016 05:43:19 -0400
In-Reply-To: <1460281382-13656-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>

Adds support for the following via ethtool:
  - UDP configuration of RSS based on 2-tuple/4-tuple.
  - RSS hash key.
  - RSS indirection table.

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede.h         |   4 +
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 237 +++++++++++++++++++++++-
 drivers/net/ethernet/qlogic/qede/qede_main.c    |  52 +++++-
 3 files changed, 283 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qede/qede.h b/drivers/net/ethernet/qlogic/qede/qede.h
index e0a696a..80dbb73 100644
--- a/drivers/net/ethernet/qlogic/qede/qede.h
+++ b/drivers/net/ethernet/qlogic/qede/qede.h
@@ -154,6 +154,10 @@ struct qede_dev {
 	      SKB_DATA_ALIGN(sizeof(struct skb_shared_info)))
 
 	struct qede_stats		stats;
+#define QEDE_RSS_INDIR_INITED	BIT(0)
+#define QEDE_RSS_KEY_INITED	BIT(1)
+#define QEDE_RSS_CAPS_INITED	BIT(2)
+	u32 rss_params_inited; /* bit-field to track initialized rss params */
 	struct qed_update_vport_rss_params	rss_params;
 	u16			q_num_rx_buffers; /* Must be a power of two */
 	u16			q_num_tx_buffers; /* Must be a power of two */
diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index c49dc10..f0982f1 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -569,6 +569,236 @@ static int qede_set_phys_id(struct net_device *dev,
 	return 0;
 }
 
+static int qede_get_rss_flags(struct qede_dev *edev, struct ethtool_rxnfc *info)
+{
+	info->data = RXH_IP_SRC | RXH_IP_DST;
+
+	switch (info->flow_type) {
+	case TCP_V4_FLOW:
+	case TCP_V6_FLOW:
+		info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		break;
+	case UDP_V4_FLOW:
+		if (edev->rss_params.rss_caps & QED_RSS_IPV4_UDP)
+			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		break;
+	case UDP_V6_FLOW:
+		if (edev->rss_params.rss_caps & QED_RSS_IPV6_UDP)
+			info->data |= RXH_L4_B_0_1 | RXH_L4_B_2_3;
+		break;
+	case IPV4_FLOW:
+	case IPV6_FLOW:
+		break;
+	default:
+		info->data = 0;
+		break;
+	}
+
+	return 0;
+}
+
+static int qede_get_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info,
+			  u32 *rules __always_unused)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	switch (info->cmd) {
+	case ETHTOOL_GRXRINGS:
+		info->data = edev->num_rss;
+		return 0;
+	case ETHTOOL_GRXFH:
+		return qede_get_rss_flags(edev, info);
+	default:
+		DP_ERR(edev, "Command parameters not supported\n");
+		return -EOPNOTSUPP;
+	}
+}
+
+static int qede_set_rss_flags(struct qede_dev *edev, struct ethtool_rxnfc *info)
+{
+	struct qed_update_vport_params vport_update_params;
+	u8 set_caps = 0, clr_caps = 0;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG,
+		   "Set rss flags command parameters: flow type = %d, data = %llu\n",
+		   info->flow_type, info->data);
+
+	switch (info->flow_type) {
+	case TCP_V4_FLOW:
+	case TCP_V6_FLOW:
+		/* For TCP only 4-tuple hash is supported */
+		if (info->data ^ (RXH_IP_SRC | RXH_IP_DST |
+				  RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+			DP_INFO(edev, "Command parameters not supported\n");
+			return -EINVAL;
+		}
+		return 0;
+	case UDP_V4_FLOW:
+		/* For UDP either 2-tuple hash or 4-tuple hash is supported */
+		if (info->data == (RXH_IP_SRC | RXH_IP_DST |
+				   RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+			set_caps = QED_RSS_IPV4_UDP;
+			DP_VERBOSE(edev, QED_MSG_DEBUG,
+				   "UDP 4-tuple enabled\n");
+		} else if (info->data == (RXH_IP_SRC | RXH_IP_DST)) {
+			clr_caps = QED_RSS_IPV4_UDP;
+			DP_VERBOSE(edev, QED_MSG_DEBUG,
+				   "UDP 4-tuple disabled\n");
+		} else {
+			return -EINVAL;
+		}
+		break;
+	case UDP_V6_FLOW:
+		/* For UDP either 2-tuple hash or 4-tuple hash is supported */
+		if (info->data == (RXH_IP_SRC | RXH_IP_DST |
+				   RXH_L4_B_0_1 | RXH_L4_B_2_3)) {
+			set_caps = QED_RSS_IPV6_UDP;
+			DP_VERBOSE(edev, QED_MSG_DEBUG,
+				   "UDP 4-tuple enabled\n");
+		} else if (info->data == (RXH_IP_SRC | RXH_IP_DST)) {
+			clr_caps = QED_RSS_IPV6_UDP;
+			DP_VERBOSE(edev, QED_MSG_DEBUG,
+				   "UDP 4-tuple disabled\n");
+		} else {
+			return -EINVAL;
+		}
+		break;
+	case IPV4_FLOW:
+	case IPV6_FLOW:
+		/* For IP only 2-tuple hash is supported */
+		if (info->data ^ (RXH_IP_SRC | RXH_IP_DST)) {
+			DP_INFO(edev, "Command parameters not supported\n");
+			return -EINVAL;
+		}
+		return 0;
+	case SCTP_V4_FLOW:
+	case AH_ESP_V4_FLOW:
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+	case SCTP_V6_FLOW:
+	case AH_ESP_V6_FLOW:
+	case AH_V6_FLOW:
+	case ESP_V6_FLOW:
+	case IP_USER_FLOW:
+	case ETHER_FLOW:
+		/* RSS is not supported for these protocols */
+		if (info->data) {
+			DP_INFO(edev, "Command parameters not supported\n");
+			return -EINVAL;
+		}
+		return 0;
+	default:
+		return -EINVAL;
+	}
+
+	/* No action is needed if there is no change in the rss capability */
+	if (edev->rss_params.rss_caps == ((edev->rss_params.rss_caps &
+					   ~clr_caps) | set_caps))
+		return 0;
+
+	/* Update internal configuration */
+	edev->rss_params.rss_caps = (edev->rss_params.rss_caps & ~clr_caps) |
+				    set_caps;
+	edev->rss_params_inited |= QEDE_RSS_CAPS_INITED;
+
+	/* Re-configure if possible */
+	if (netif_running(edev->ndev)) {
+		memset(&vport_update_params, 0, sizeof(vport_update_params));
+		vport_update_params.update_rss_flg = 1;
+		vport_update_params.vport_id = 0;
+		memcpy(&vport_update_params.rss_params, &edev->rss_params,
+		       sizeof(vport_update_params.rss_params));
+		return edev->ops->vport_update(edev->cdev,
+					       &vport_update_params);
+	}
+
+	return 0;
+}
+
+static int qede_set_rxnfc(struct net_device *dev, struct ethtool_rxnfc *info)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	switch (info->cmd) {
+	case ETHTOOL_SRXFH:
+		return qede_set_rss_flags(edev, info);
+	default:
+		DP_INFO(edev, "Command parameters not supported\n");
+		return -EOPNOTSUPP;
+	}
+}
+
+static u32 qede_get_rxfh_indir_size(struct net_device *dev)
+{
+	return QED_RSS_IND_TABLE_SIZE;
+}
+
+static u32 qede_get_rxfh_key_size(struct net_device *dev)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	return sizeof(edev->rss_params.rss_key);
+}
+
+static int qede_get_rxfh(struct net_device *dev, u32 *indir, u8 *key, u8 *hfunc)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	int i;
+
+	if (hfunc)
+		*hfunc = ETH_RSS_HASH_TOP;
+
+	if (!indir)
+		return 0;
+
+	for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++)
+		indir[i] = edev->rss_params.rss_ind_table[i];
+
+	if (key)
+		memcpy(key, edev->rss_params.rss_key,
+		       qede_get_rxfh_key_size(dev));
+
+	return 0;
+}
+
+static int qede_set_rxfh(struct net_device *dev, const u32 *indir,
+			 const u8 *key, const u8 hfunc)
+{
+	struct qed_update_vport_params vport_update_params;
+	struct qede_dev *edev = netdev_priv(dev);
+	int i;
+
+	if (hfunc != ETH_RSS_HASH_NO_CHANGE && hfunc != ETH_RSS_HASH_TOP)
+		return -EOPNOTSUPP;
+
+	if (!indir && !key)
+		return 0;
+
+	if (indir) {
+		for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++)
+			edev->rss_params.rss_ind_table[i] = indir[i];
+		edev->rss_params_inited |= QEDE_RSS_INDIR_INITED;
+	}
+
+	if (key) {
+		memcpy(&edev->rss_params.rss_key, key,
+		       qede_get_rxfh_key_size(dev));
+		edev->rss_params_inited |= QEDE_RSS_KEY_INITED;
+	}
+
+	if (netif_running(edev->ndev)) {
+		memset(&vport_update_params, 0, sizeof(vport_update_params));
+		vport_update_params.update_rss_flg = 1;
+		vport_update_params.vport_id = 0;
+		memcpy(&vport_update_params.rss_params, &edev->rss_params,
+		       sizeof(vport_update_params.rss_params));
+		return edev->ops->vport_update(edev->cdev,
+					       &vport_update_params);
+	}
+
+	return 0;
+}
+
 static const struct ethtool_ops qede_ethtool_ops = {
 	.get_settings = qede_get_settings,
 	.set_settings = qede_set_settings,
@@ -585,7 +815,12 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.set_phys_id = qede_set_phys_id,
 	.get_ethtool_stats = qede_get_ethtool_stats,
 	.get_sset_count = qede_get_sset_count,
-
+	.get_rxnfc = qede_get_rxnfc,
+	.set_rxnfc = qede_set_rxnfc,
+	.get_rxfh_indir_size = qede_get_rxfh_indir_size,
+	.get_rxfh_key_size = qede_get_rxfh_key_size,
+	.get_rxfh = qede_get_rxfh,
+	.set_rxfh = qede_set_rxfh,
 	.get_channels = qede_get_channels,
 	.set_channels = qede_set_channels,
 };
diff --git a/drivers/net/ethernet/qlogic/qede/qede_main.c b/drivers/net/ethernet/qlogic/qede/qede_main.c
index a55d93e..457caad 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_main.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_main.c
@@ -2826,10 +2826,10 @@ static int qede_start_queues(struct qede_dev *edev)
 	int rc, tc, i;
 	int vlan_removal_en = 1;
 	struct qed_dev *cdev = edev->cdev;
-	struct qed_update_vport_rss_params *rss_params = &edev->rss_params;
 	struct qed_update_vport_params vport_update_params;
 	struct qed_queue_start_common_params q_params;
 	struct qed_start_vport_params start = {0};
+	bool reset_rss_indir = false;
 
 	if (!edev->num_rss) {
 		DP_ERR(edev,
@@ -2924,16 +2924,50 @@ static int qede_start_queues(struct qede_dev *edev)
 	/* Fill struct with RSS params */
 	if (QEDE_RSS_CNT(edev) > 1) {
 		vport_update_params.update_rss_flg = 1;
-		for (i = 0; i < 128; i++)
-			rss_params->rss_ind_table[i] =
-			ethtool_rxfh_indir_default(i, QEDE_RSS_CNT(edev));
-		netdev_rss_key_fill(rss_params->rss_key,
-				    sizeof(rss_params->rss_key));
+
+		/* Need to validate current RSS config uses valid entries */
+		for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
+			if (edev->rss_params.rss_ind_table[i] >=
+			    edev->num_rss) {
+				reset_rss_indir = true;
+				break;
+			}
+		}
+
+		if (!(edev->rss_params_inited & QEDE_RSS_INDIR_INITED) ||
+		    reset_rss_indir) {
+			u16 val;
+
+			for (i = 0; i < QED_RSS_IND_TABLE_SIZE; i++) {
+				u16 indir_val;
+
+				val = QEDE_RSS_CNT(edev);
+				indir_val = ethtool_rxfh_indir_default(i, val);
+				edev->rss_params.rss_ind_table[i] = indir_val;
+			}
+			edev->rss_params_inited |= QEDE_RSS_INDIR_INITED;
+		}
+
+		if (!(edev->rss_params_inited & QEDE_RSS_KEY_INITED)) {
+			netdev_rss_key_fill(edev->rss_params.rss_key,
+					    sizeof(edev->rss_params.rss_key));
+			edev->rss_params_inited |= QEDE_RSS_KEY_INITED;
+		}
+
+		if (!(edev->rss_params_inited & QEDE_RSS_CAPS_INITED)) {
+			edev->rss_params.rss_caps = QED_RSS_IPV4 |
+						    QED_RSS_IPV6 |
+						    QED_RSS_IPV4_TCP |
+						    QED_RSS_IPV6_TCP;
+			edev->rss_params_inited |= QEDE_RSS_CAPS_INITED;
+		}
+
+		memcpy(&vport_update_params.rss_params, &edev->rss_params,
+		       sizeof(vport_update_params.rss_params));
 	} else {
-		memset(rss_params, 0, sizeof(*rss_params));
+		memset(&vport_update_params.rss_params, 0,
+		       sizeof(vport_update_params.rss_params));
 	}
-	memcpy(&vport_update_params.rss_params, rss_params,
-	       sizeof(*rss_params));
 
 	rc = edev->ops->vport_update(cdev, &vport_update_params);
 	if (rc) {
-- 
1.9.3

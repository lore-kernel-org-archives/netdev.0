From: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Subject: [PATCH net-next 2/2] qede: Add support for coalescing config read/update.
Date: Tue, 21 Jun 2016 09:36:22 -0400
Message-ID: <1466516182-24442-3-git-send-email-sudarsana.kalluru@qlogic.com>
References: <1466516182-24442-1-git-send-email-sudarsana.kalluru@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@qlogic.com>,
	<sudarsana.kalluru@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:22157 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751139AbcFUPIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 11:08:52 -0400
In-Reply-To: <1466516182-24442-1-git-send-email-sudarsana.kalluru@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Sudarsana Reddy Kalluru <sudarsana.kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 53 +++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 6836d44..6228482 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -426,6 +426,57 @@ static u32 qede_get_link(struct net_device *dev)
 	return current_link.link_up;
 }
 
+static int qede_get_coalesce(struct net_device *dev,
+			     struct ethtool_coalesce *coal)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+
+	memset(coal, 0, sizeof(struct ethtool_coalesce));
+	edev->ops->common->get_coalesce(edev->cdev,
+					(u16 *)&coal->rx_coalesce_usecs,
+					(u16 *)&coal->tx_coalesce_usecs);
+
+	return 0;
+}
+
+static int qede_set_coalesce(struct net_device *dev,
+			     struct ethtool_coalesce *coal)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	int i, rc = 0;
+	u16 rxc, txc;
+	u8 sb_id;
+
+	if (!netif_running(dev)) {
+		DP_INFO(edev, "Interface is down\n");
+		return -EINVAL;
+	}
+
+	if (coal->rx_coalesce_usecs > QED_COALESCE_MAX ||
+	    coal->tx_coalesce_usecs > QED_COALESCE_MAX) {
+		DP_INFO(edev,
+			"Can't support requested %s coalesce value [max supported value %d]\n",
+			coal->rx_coalesce_usecs > QED_COALESCE_MAX ? "rx"
+								   : "tx",
+			QED_COALESCE_MAX);
+		return -EINVAL;
+	}
+
+	rxc = (u16)coal->rx_coalesce_usecs;
+	txc = (u16)coal->tx_coalesce_usecs;
+	for_each_rss(i) {
+		sb_id = edev->fp_array[i].sb_info->igu_sb_id;
+		rc = edev->ops->common->set_coalesce(edev->cdev, rxc, txc,
+						     (u8)i, sb_id);
+		if (rc) {
+			DP_INFO(edev, "Set coalesce error, rc = %d\n", rc);
+			return rc;
+		}
+	}
+
+	return rc;
+}
+
 static void qede_get_ringparam(struct net_device *dev,
 			       struct ethtool_ringparam *ering)
 {
@@ -1139,6 +1190,8 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.set_msglevel = qede_set_msglevel,
 	.nway_reset = qede_nway_reset,
 	.get_link = qede_get_link,
+	.get_coalesce = qede_get_coalesce,
+	.set_coalesce = qede_set_coalesce,
 	.get_ringparam = qede_get_ringparam,
 	.set_ringparam = qede_set_ringparam,
 	.get_pauseparam = qede_get_pauseparam,
-- 
1.8.3.1

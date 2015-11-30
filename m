From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next 6/6] qede: Add support for {get, set}_pauseparam
Date: Mon, 30 Nov 2015 12:25:06 +0200
Message-ID: <1448879106-12321-7-git-send-email-Yuval.Mintz@qlogic.com>
References: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <Ariel.Elior@qlogic.com>, <Sudarsana.Kalluru@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:48384 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752670AbbK3K01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2015 05:26:27 -0500
In-Reply-To: <1448879106-12321-1-git-send-email-Yuval.Mintz@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>

Signed-off-by: Sudarsana Kalluru <Sudarsana.Kalluru@qlogic.com>
Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 60 +++++++++++++++++++++++++
 1 file changed, 60 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index 9b0bf12..e442b85 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -399,6 +399,64 @@ static int qede_set_ringparam(struct net_device *dev,
 	return 0;
 }
 
+static void qede_get_pauseparam(struct net_device *dev,
+				struct ethtool_pauseparam *epause)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_output current_link;
+
+	memset(&current_link, 0, sizeof(current_link));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+
+	if (current_link.pause_config & QED_LINK_PAUSE_AUTONEG_ENABLE)
+		epause->autoneg = true;
+	if (current_link.pause_config & QED_LINK_PAUSE_RX_ENABLE)
+		epause->rx_pause = true;
+	if (current_link.pause_config & QED_LINK_PAUSE_TX_ENABLE)
+		epause->tx_pause = true;
+
+	DP_VERBOSE(edev, QED_MSG_DEBUG,
+		   "ethtool_pauseparam: cmd %d  autoneg %d  rx_pause %d  tx_pause %d\n",
+		   epause->cmd, epause->autoneg, epause->rx_pause,
+		   epause->tx_pause);
+}
+
+static int qede_set_pauseparam(struct net_device *dev,
+			       struct ethtool_pauseparam *epause)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_params params;
+	struct qed_link_output current_link;
+
+	if (!edev->dev_info.common.is_mf) {
+		DP_INFO(edev,
+			"Pause parameters can not be updated in non-default mode\n");
+		return -EOPNOTSUPP;
+	}
+
+	memset(&current_link, 0, sizeof(current_link));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+
+	memset(&params, 0, sizeof(params));
+	params.override_flags |= QED_LINK_OVERRIDE_PAUSE_CONFIG;
+	if (epause->autoneg) {
+		if (!(current_link.supported_caps & SUPPORTED_Autoneg)) {
+			DP_INFO(edev, "autoneg not supported\n");
+			return -EINVAL;
+		}
+		params.pause_config |= QED_LINK_PAUSE_AUTONEG_ENABLE;
+	}
+	if (epause->rx_pause)
+		params.pause_config |= QED_LINK_PAUSE_RX_ENABLE;
+	if (epause->tx_pause)
+		params.pause_config |= QED_LINK_PAUSE_TX_ENABLE;
+
+	params.link_up = true;
+	edev->ops->common->set_link(edev->cdev, &params);
+
+	return 0;
+}
+
 static void qede_update_mtu(struct qede_dev *edev, union qede_reload_args *args)
 {
 	edev->ndev->mtu = args->mtu;
@@ -521,6 +579,8 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_link = qede_get_link,
 	.get_ringparam = qede_get_ringparam,
 	.set_ringparam = qede_set_ringparam,
+	.get_pauseparam = qede_get_pauseparam,
+	.set_pauseparam = qede_set_pauseparam,
 	.get_strings = qede_get_strings,
 	.set_phys_id = qede_set_phys_id,
 	.get_ethtool_stats = qede_get_ethtool_stats,
-- 
1.9.3

From: Manish Chopra <manish.chopra@cavium.com>
Subject: [PATCH net-next 4/7] qede: Add ethtool support for Energy efficient ethernet.
Date: Fri, 30 Jun 2017 02:39:43 -0700
Message-ID: <20170630093946.18497-5-manish.chopra@cavium.com>
References: <20170630093946.18497-1-manish.chopra@cavium.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Yuval.Mintz@cavium.com>,
        <rahul.verma@cavium.com>, <sudarsana.kalluru@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0080.outbound.protection.outlook.com ([104.47.41.80]:52064
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751796AbdF3JkD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 30 Jun 2017 05:40:03 -0400
In-Reply-To: <20170630093946.18497-1-manish.chopra@cavium.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sudarsana Reddy Kalluru <sudarsana.kalluru@cavium.com>

The patch adds ethtool callback implementations for querying/configuring
the Energy Efficient Ethernet (EEE) parameters.

Signed-off-by: Sudarsana Reddy Kalluru <Sudarsana.Kalluru@cavium.com>
Signed-off-by: Yuval Mintz <yuval.mintz@cavium.com>
---
 drivers/net/ethernet/qlogic/qede/qede_ethtool.c | 84 +++++++++++++++++++++++++
 1 file changed, 84 insertions(+)

diff --git a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
index e31266d..55fa2ef 100644
--- a/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
+++ b/drivers/net/ethernet/qlogic/qede/qede_ethtool.c
@@ -1631,6 +1631,87 @@ static int qede_get_tunable(struct net_device *dev,
 	return 0;
 }
 
+static int qede_get_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_output current_link;
+
+	memset(&current_link, 0, sizeof(current_link));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+
+	if (!current_link.eee_supported) {
+		DP_INFO(edev, "EEE is not supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	if (current_link.eee.adv_caps & QED_EEE_1G_ADV)
+		edata->advertised = ADVERTISED_1000baseT_Full;
+	if (current_link.eee.adv_caps & QED_EEE_10G_ADV)
+		edata->advertised |= ADVERTISED_10000baseT_Full;
+	if (current_link.sup_caps & QED_EEE_1G_ADV)
+		edata->supported = ADVERTISED_1000baseT_Full;
+	if (current_link.sup_caps & QED_EEE_10G_ADV)
+		edata->supported |= ADVERTISED_10000baseT_Full;
+	if (current_link.eee.lp_adv_caps & QED_EEE_1G_ADV)
+		edata->lp_advertised = ADVERTISED_1000baseT_Full;
+	if (current_link.eee.lp_adv_caps & QED_EEE_10G_ADV)
+		edata->lp_advertised |= ADVERTISED_10000baseT_Full;
+
+	edata->tx_lpi_timer = current_link.eee.tx_lpi_timer;
+	edata->eee_enabled = current_link.eee.enable;
+	edata->tx_lpi_enabled = current_link.eee.tx_lpi_enable;
+	edata->eee_active = current_link.eee_active;
+
+	return 0;
+}
+
+static int qede_set_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct qede_dev *edev = netdev_priv(dev);
+	struct qed_link_output current_link;
+	struct qed_link_params params;
+
+	if (!edev->ops->common->can_link_change(edev->cdev)) {
+		DP_INFO(edev, "Link settings are not allowed to be changed\n");
+		return -EOPNOTSUPP;
+	}
+
+	memset(&current_link, 0, sizeof(current_link));
+	edev->ops->common->get_link(edev->cdev, &current_link);
+
+	if (!current_link.eee_supported) {
+		DP_INFO(edev, "EEE is not supported\n");
+		return -EOPNOTSUPP;
+	}
+
+	memset(&params, 0, sizeof(params));
+	params.override_flags |= QED_LINK_OVERRIDE_EEE_CONFIG;
+
+	if (!(edata->advertised & (ADVERTISED_1000baseT_Full |
+				   ADVERTISED_10000baseT_Full)) ||
+	    ((edata->advertised & (ADVERTISED_1000baseT_Full |
+				   ADVERTISED_10000baseT_Full)) !=
+	     edata->advertised)) {
+		DP_VERBOSE(edev, QED_MSG_DEBUG,
+			   "Invalid advertised capabilities %d\n",
+			   edata->advertised);
+		return -EINVAL;
+	}
+
+	if (edata->advertised & ADVERTISED_1000baseT_Full)
+		params.eee.adv_caps = QED_EEE_1G_ADV;
+	if (edata->advertised & ADVERTISED_10000baseT_Full)
+		params.eee.adv_caps |= QED_EEE_10G_ADV;
+	params.eee.enable = edata->eee_enabled;
+	params.eee.tx_lpi_enable = edata->tx_lpi_enabled;
+	params.eee.tx_lpi_timer = edata->tx_lpi_timer;
+
+	params.link_up = true;
+	edev->ops->common->set_link(edev->cdev, &params);
+
+	return 0;
+}
+
 static const struct ethtool_ops qede_ethtool_ops = {
 	.get_link_ksettings = qede_get_link_ksettings,
 	.set_link_ksettings = qede_set_link_ksettings,
@@ -1664,6 +1745,9 @@ static const struct ethtool_ops qede_ethtool_ops = {
 	.get_channels = qede_get_channels,
 	.set_channels = qede_set_channels,
 	.self_test = qede_self_test,
+	.get_eee = qede_get_eee,
+	.set_eee = qede_set_eee,
+
 	.get_tunable = qede_get_tunable,
 	.set_tunable = qede_set_tunable,
 };
-- 
2.7.2

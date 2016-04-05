From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH net-next 05/10] bnxt_en: Add get_eee() and set_eee() ethtool support.
Date: Tue,  5 Apr 2016 04:22:37 -0400
Message-ID: <1459844562-24576-6-git-send-email-michael.chan@broadcom.com>
References: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:13135 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757434AbcDEIWo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 04:22:44 -0400
In-Reply-To: <1459844562-24576-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow users to get|set EEE parameters.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c | 73 +++++++++++++++++++++++
 1 file changed, 73 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
index 14f0520..3d5c64f 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt_ethtool.c
@@ -1379,6 +1379,77 @@ static int bnxt_set_eeprom(struct net_device *dev,
 				eeprom->len);
 }
 
+static int bnxt_set_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct bnxt *bp = netdev_priv(dev);
+	struct ethtool_eee *eee = &bp->eee;
+	struct bnxt_link_info *link_info = &bp->link_info;
+	u32 advertising =
+		 _bnxt_fw_to_ethtool_adv_spds(link_info->advertising, 0);
+	int rc = 0;
+
+	if (BNXT_VF(bp))
+		return 0;
+
+	if (!(bp->flags & BNXT_FLAG_EEE_CAP))
+		return -EOPNOTSUPP;
+
+	if (!edata->eee_enabled)
+		goto eee_ok;
+
+	if (!(link_info->autoneg & BNXT_AUTONEG_SPEED)) {
+		netdev_warn(dev, "EEE requires autoneg\n");
+		return -EINVAL;
+	}
+	if (edata->tx_lpi_enabled) {
+		if (bp->lpi_tmr_hi && (edata->tx_lpi_timer > bp->lpi_tmr_hi ||
+				       edata->tx_lpi_timer < bp->lpi_tmr_lo)) {
+			netdev_warn(dev, "Valid LPI timer range is %d and %d microsecs\n",
+				    bp->lpi_tmr_lo, bp->lpi_tmr_hi);
+			return -EINVAL;
+		} else if (!bp->lpi_tmr_hi) {
+			edata->tx_lpi_timer = eee->tx_lpi_timer;
+		}
+	}
+	if (!edata->advertised) {
+		edata->advertised = advertising & eee->supported;
+	} else if (edata->advertised & ~advertising) {
+		netdev_warn(dev, "EEE advertised %x must be a subset of autoneg advertised speeds %x\n",
+			    edata->advertised, advertising);
+		return -EINVAL;
+	}
+
+	eee->advertised = edata->advertised;
+	eee->tx_lpi_enabled = edata->tx_lpi_enabled;
+	eee->tx_lpi_timer = edata->tx_lpi_timer;
+eee_ok:
+	eee->eee_enabled = edata->eee_enabled;
+
+	if (netif_running(dev))
+		rc = bnxt_hwrm_set_link_setting(bp, false, true);
+
+	return rc;
+}
+
+static int bnxt_get_eee(struct net_device *dev, struct ethtool_eee *edata)
+{
+	struct bnxt *bp = netdev_priv(dev);
+
+	if (!(bp->flags & BNXT_FLAG_EEE_CAP))
+		return -EOPNOTSUPP;
+
+	*edata = bp->eee;
+	if (!bp->eee.eee_enabled) {
+		edata->advertised = 0;
+		edata->tx_lpi_enabled = 0;
+	}
+
+	if (!bp->eee.eee_active)
+		edata->lp_advertised = 0;
+
+	return 0;
+}
+
 const struct ethtool_ops bnxt_ethtool_ops = {
 	.get_settings		= bnxt_get_settings,
 	.set_settings		= bnxt_set_settings,
@@ -1407,4 +1478,6 @@ const struct ethtool_ops bnxt_ethtool_ops = {
 	.get_eeprom             = bnxt_get_eeprom,
 	.set_eeprom		= bnxt_set_eeprom,
 	.get_link		= bnxt_get_link,
+	.get_eee		= bnxt_get_eee,
+	.set_eee		= bnxt_set_eee,
 };
-- 
1.8.3.1

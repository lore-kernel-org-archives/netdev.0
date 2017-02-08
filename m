From: Timur Tabi <timur@codeaurora.org>
Subject: [PATCH 2/2] net: qcom/emac: add ethtool support for setting ring parameters
Date: Wed,  8 Feb 2017 15:49:28 -0600
Message-ID: <1486590568-31398-3-git-send-email-timur@codeaurora.org>
References: <1486590568-31398-1-git-send-email-timur@codeaurora.org>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:35956 "EHLO
        smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751307AbdBHVzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 16:55:48 -0500
In-Reply-To: <1486590568-31398-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Implement the set_ringparam method, which allows the user to specify
the size of the TX and RX descriptor rings.  The values are constrained
to the limits of the hardware.

Since the driver does not use separate queues for mini or jumbo frames,
attempts to set those values are rejected.

If the interface is already running when the setting is changed, then
the interface is reset.

Signed-off-by: Timur Tabi <timur@codeaurora.org>
---
 drivers/net/ethernet/qualcomm/emac/emac-ethtool.c | 24 +++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
index abb9df5..a3e2292 100644
--- a/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
+++ b/drivers/net/ethernet/qualcomm/emac/emac-ethtool.c
@@ -145,6 +145,29 @@ static void emac_get_ringparam(struct net_device *netdev,
 	ring->tx_pending = adpt->tx_desc_cnt;
 }
 
+static int emac_set_ringparam(struct net_device *netdev,
+			      struct ethtool_ringparam *ring)
+{
+	struct emac_adapter *adpt = netdev_priv(netdev);
+
+	/* We don't have separate queues/rings for small/large frames, so
+	 * reject any attempt to specify those values separately.
+	 */
+	if (ring->rx_mini_pending || ring->rx_jumbo_pending)
+		return -EINVAL;
+
+	adpt->tx_desc_cnt =
+		clamp_val(ring->tx_pending, EMAC_MIN_TX_DESCS, EMAC_MAX_TX_DESCS);
+
+	adpt->rx_desc_cnt =
+		clamp_val(ring->rx_pending, EMAC_MIN_RX_DESCS, EMAC_MAX_RX_DESCS);
+
+	if (netif_running(netdev))
+		return emac_reinit_locked(adpt);
+
+	return 0;
+}
+
 static void emac_get_pauseparam(struct net_device *netdev,
 				struct ethtool_pauseparam *pause)
 {
@@ -219,6 +242,7 @@ static int emac_get_regs_len(struct net_device *netdev)
 	.get_ethtool_stats = emac_get_ethtool_stats,
 
 	.get_ringparam = emac_get_ringparam,
+	.set_ringparam = emac_set_ringparam,
 
 	.get_pauseparam = emac_get_pauseparam,
 	.set_pauseparam = emac_set_pauseparam,
-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.

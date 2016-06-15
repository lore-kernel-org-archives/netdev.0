From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 14/17] sfc: VLAN filters must only be created if the
 firmware supports this.
Date: Wed, 15 Jun 2016 17:51:07 +0100
Message-ID: <6ec99ce0-ba94-e60f-9e71-57d660cb97dc@solarflare.com>
References: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: <linux-net-drivers@solarflare.com>, <netdev@vger.kernel.org>,
	<davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:52850 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932820AbcFOQw1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 12:52:27 -0400
In-Reply-To: <4daf4ef4-7a8b-4a16-c640-04275298abad@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin Habets <mhabets@solarflare.com>

If it is not supported we simply disable the feature.

For the feature to work we need firmware filter support for
OUTER_VID + LOC_MAC and for OUTER_VID + LOC_MAC_IG.
The low-latency firmware can match on OUTER_VID + LOC_MAC but not on
OUTER_VID + LOC_MAC_IG.
For the capture packet firmware it is the other way around.
Only the full-feature variant can match on both combinations.

Incorporates a fix by Andrew Rybchenko <Andrew.Rybchenko@oktetlabs.ru>
in the net_dev->[hw_]features handling.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 13 +++++++++++++
 drivers/net/ethernet/sfc/net_driver.h | 12 ++++++++++++
 2 files changed, 25 insertions(+)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index 626054d..353ceef 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3977,6 +3977,7 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 	MCDI_DECLARE_BUF(inbuf, MC_CMD_GET_PARSER_DISP_INFO_IN_LEN);
 	MCDI_DECLARE_BUF(outbuf, MC_CMD_GET_PARSER_DISP_INFO_OUT_LENMAX);
 	struct efx_ef10_nic_data *nic_data = efx->nic_data;
+	struct net_device *net_dev = efx->net_dev;
 	unsigned int pd_match_pri, pd_match_count;
 	struct efx_ef10_filter_table *table;
 	struct efx_ef10_vlan *vlan;
@@ -4026,6 +4027,18 @@ static int efx_ef10_filter_table_probe(struct efx_nic *efx)
 		}
 	}
 
+	if ((efx_supported_features(efx) & NETIF_F_HW_VLAN_CTAG_FILTER) &&
+	    !(efx_ef10_filter_match_supported(table,
+		(EFX_FILTER_MATCH_OUTER_VID | EFX_FILTER_MATCH_LOC_MAC)) &&
+	      efx_ef10_filter_match_supported(table,
+		(EFX_FILTER_MATCH_OUTER_VID | EFX_FILTER_MATCH_LOC_MAC_IG)))) {
+		netif_info(efx, probe, net_dev,
+			   "VLAN filters are not supported in this firmware variant\n");
+		net_dev->features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+		efx->fixed_features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+		net_dev->hw_features &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+	}
+
 	table->entry = vzalloc(HUNT_FILTER_TBL_ROWS * sizeof(*table->entry));
 	if (!table->entry) {
 		rc = -ENOMEM;
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 7613f79..9ff062a 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -1524,4 +1524,16 @@ static inline void efx_xmit_hwtstamp_pending(struct sk_buff *skb)
 	skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 }
 
+/* Get all supported features.
+ * If a feature is not fixed, it is present in hw_features.
+ * If a feature is fixed, it does not present in hw_features, but
+ * always in features.
+ */
+static inline netdev_features_t efx_supported_features(const struct efx_nic *efx)
+{
+	const struct net_device *net_dev = efx->net_dev;
+
+	return net_dev->features | net_dev->hw_features;
+}
+
 #endif /* EFX_NET_DRIVER_H */

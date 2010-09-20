From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 5/8] sfc: Implement the ethtool RX n-tuple
 control functions
Date: Mon, 20 Sep 2010 19:43:42 +0100
Message-ID: <1285008222.2282.108.camel@achroite.uk.solarflarecom.com>
References: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:7251 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754285Ab0ITSnp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:43:45 -0400
In-Reply-To: <1285008056.2282.103.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c |  118 ++++++++++++++++++++++++++++++++++++++++++++-
 drivers/net/sfc/falcon.c  |    2 +-
 drivers/net/sfc/siena.c   |    2 +-
 3 files changed, 118 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 7f735d8..1b2570c 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -15,6 +15,7 @@
 #include "workarounds.h"
 #include "selftest.h"
 #include "efx.h"
+#include "filter.h"
 #include "nic.h"
 #include "spi.h"
 #include "mdio_10g.h"
@@ -551,9 +552,22 @@ static u32 efx_ethtool_get_rx_csum(struct net_device *net_dev)
 static int efx_ethtool_set_flags(struct net_device *net_dev, u32 data)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	u32 supported = efx->type->offload_features & ETH_FLAG_RXHASH;
+	u32 supported = (efx->type->offload_features &
+			 (ETH_FLAG_RXHASH | ETH_FLAG_NTUPLE));
+	int rc;
+
+	rc = ethtool_op_set_flags(net_dev, data, supported);
+	if (rc)
+		return rc;
+
+	if (!(data & ETH_FLAG_NTUPLE)) {
+		efx_filter_table_clear(efx, EFX_FILTER_TABLE_RX_IP,
+				       EFX_FILTER_PRI_MANUAL);
+		efx_filter_table_clear(efx, EFX_FILTER_TABLE_RX_MAC,
+				       EFX_FILTER_PRI_MANUAL);
+	}
 
-	return ethtool_op_set_flags(net_dev, data, supported);
+	return 0;
 }
 
 static void efx_ethtool_self_test(struct net_device *net_dev,
@@ -955,6 +969,105 @@ efx_ethtool_get_rxnfc(struct net_device *net_dev,
 	}
 }
 
+static int efx_ethtool_set_rx_ntuple(struct net_device *net_dev,
+				     struct ethtool_rx_ntuple *ntuple)
+{
+	struct efx_nic *efx = netdev_priv(net_dev);
+	struct ethtool_tcpip4_spec *ip_entry = &ntuple->fs.h_u.tcp_ip4_spec;
+	struct ethtool_tcpip4_spec *ip_mask = &ntuple->fs.m_u.tcp_ip4_spec;
+	struct ethhdr *mac_entry = &ntuple->fs.h_u.ether_spec;
+	struct ethhdr *mac_mask = &ntuple->fs.m_u.ether_spec;
+	struct efx_filter_spec filter;
+
+	/* Range-check action */
+	if (ntuple->fs.action < ETHTOOL_RXNTUPLE_ACTION_CLEAR ||
+	    ntuple->fs.action >= (s32)efx->n_rx_channels)
+		return -EINVAL;
+
+	if (~ntuple->fs.data_mask)
+		return -EINVAL;
+
+	switch (ntuple->fs.flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+		/* Must match all of destination, */
+		if (ip_mask->ip4dst | ip_mask->pdst)
+			return -EINVAL;
+		/* all or none of source, */
+		if ((ip_mask->ip4src | ip_mask->psrc) &&
+		    ((__force u32)~ip_mask->ip4src |
+		     (__force u16)~ip_mask->psrc))
+			return -EINVAL;
+		/* and nothing else */
+		if ((u8)~ip_mask->tos | (u16)~ntuple->fs.vlan_tag_mask)
+			return -EINVAL;
+		break;
+	case ETHER_FLOW:
+		/* Must match all of destination, */
+		if (!is_zero_ether_addr(mac_mask->h_dest))
+			return -EINVAL;
+		/* all or none of VID, */
+		if (ntuple->fs.vlan_tag_mask != 0xf000 &&
+		    ntuple->fs.vlan_tag_mask != 0xffff)
+			return -EINVAL;
+		/* and nothing else */
+		if (!is_broadcast_ether_addr(mac_mask->h_source) ||
+		    mac_mask->h_proto != htons(0xffff))
+			return -EINVAL;
+		break;
+	default:
+		return -EINVAL;
+	}
+
+	filter.priority = EFX_FILTER_PRI_MANUAL;
+	filter.flags = 0;
+
+	switch (ntuple->fs.flow_type) {
+	case TCP_V4_FLOW:
+		if (!ip_mask->ip4src)
+			efx_filter_set_rx_tcp_full(&filter,
+						   htonl(ip_entry->ip4src),
+						   htons(ip_entry->psrc),
+						   htonl(ip_entry->ip4dst),
+						   htons(ip_entry->pdst));
+		else
+			efx_filter_set_rx_tcp_wild(&filter,
+						   htonl(ip_entry->ip4dst),
+						   htons(ip_entry->pdst));
+		break;
+	case UDP_V4_FLOW:
+		if (!ip_mask->ip4src)
+			efx_filter_set_rx_udp_full(&filter,
+						   htonl(ip_entry->ip4src),
+						   htons(ip_entry->psrc),
+						   htonl(ip_entry->ip4dst),
+						   htons(ip_entry->pdst));
+		else
+			efx_filter_set_rx_udp_wild(&filter,
+						   htonl(ip_entry->ip4dst),
+						   htons(ip_entry->pdst));
+		break;
+	case ETHER_FLOW:
+		if (ntuple->fs.vlan_tag_mask == 0xf000)
+			efx_filter_set_rx_mac_full(&filter,
+						   ntuple->fs.vlan_tag & 0xfff,
+						   mac_entry->h_dest);
+		else
+			efx_filter_set_rx_mac_wild(&filter, mac_entry->h_dest);
+		break;
+	}
+
+	if (ntuple->fs.action == ETHTOOL_RXNTUPLE_ACTION_CLEAR) {
+		return efx_filter_remove_filter(efx, &filter);
+	} else {
+		if (ntuple->fs.action == ETHTOOL_RXNTUPLE_ACTION_DROP)
+			filter.dmaq_id = 0xfff;
+		else
+			filter.dmaq_id = ntuple->fs.action;
+		return efx_filter_insert_filter(efx, &filter, true);
+	}
+}
+
 static int efx_ethtool_get_rxfh_indir(struct net_device *net_dev,
 				      struct ethtool_rxfh_indir *indir)
 {
@@ -1033,6 +1146,7 @@ const struct ethtool_ops efx_ethtool_ops = {
 	.set_wol                = efx_ethtool_set_wol,
 	.reset			= efx_ethtool_reset,
 	.get_rxnfc		= efx_ethtool_get_rxnfc,
+	.set_rx_ntuple		= efx_ethtool_set_rx_ntuple,
 	.get_rxfh_indir		= efx_ethtool_get_rxfh_indir,
 	.set_rxfh_indir		= efx_ethtool_set_rxfh_indir,
 };
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b4d8efe..b398a41 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -1874,7 +1874,7 @@ struct efx_nic_type falcon_b0_nic_type = {
 				   * channels */
 	.tx_dc_base = 0x130000,
 	.rx_dc_base = 0x100000,
-	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH,
+	.offload_features = NETIF_F_IP_CSUM | NETIF_F_RXHASH | NETIF_F_NTUPLE,
 	.reset_world_flags = ETH_RESET_IRQ,
 };
 
diff --git a/drivers/net/sfc/siena.c b/drivers/net/sfc/siena.c
index 9f53680..2115f95 100644
--- a/drivers/net/sfc/siena.c
+++ b/drivers/net/sfc/siena.c
@@ -651,6 +651,6 @@ struct efx_nic_type siena_a0_nic_type = {
 	.tx_dc_base = 0x88000,
 	.rx_dc_base = 0x68000,
 	.offload_features = (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-			     NETIF_F_RXHASH),
+			     NETIF_F_RXHASH | NETIF_F_NTUPLE),
 	.reset_world_flags = ETH_RESET_MGMT << ETH_RESET_SHARED_SHIFT,
 };
-- 
1.7.2.1



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


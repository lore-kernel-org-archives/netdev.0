From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 1/7] amd-xgbe: Add additional stats to be
 reported via ethtool
Date: Tue, 12 May 2015 14:22:36 -0500
Message-ID: <20150512192236.14091.67784.stgit@tlendack-t1.amdoffice.net>
References: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1bbn0109.outbound.protection.outlook.com ([157.56.111.109]:15136
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753472AbbELTWl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2015 15:22:41 -0400
In-Reply-To: <20150512192229.14091.34354.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add additional/extended statistics beyond what is provided by the
hardware to be reported via ethtool. The new stats focus on the
calls into ndo_start_xmit and the napi_poll routine.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c     |   12 +++++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c |    8 ++++++++
 drivers/net/ethernet/amd/xgbe/xgbe.h         |    6 ++++++
 3 files changed, 23 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 21d9497..6f593a5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1533,6 +1533,8 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 				  packet->tcp_payload_len);
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, TCPHDRLEN,
 				  packet->tcp_header_len / 4);
+
+		pdata->ext_stats.tx_tso_packets++;
 	} else {
 		/* Enable CRC and Pad Insertion */
 		XGMAC_SET_BITS_LE(rdesc->desc3, TX_NORMAL_DESC3, CPC, 0);
@@ -1618,11 +1620,12 @@ static void xgbe_dev_xmit(struct xgbe_channel *channel)
 
 static int xgbe_dev_read(struct xgbe_channel *channel)
 {
+	struct xgbe_prv_data *pdata = channel->pdata;
 	struct xgbe_ring *ring = channel->rx_ring;
 	struct xgbe_ring_data *rdata;
 	struct xgbe_ring_desc *rdesc;
 	struct xgbe_packet_data *packet = &ring->packet_data;
-	struct net_device *netdev = channel->pdata->netdev;
+	struct net_device *netdev = pdata->netdev;
 	unsigned int err, etlt, l34t;
 
 	DBGPR("-->xgbe_dev_read: cur = %d\n", ring->cur);
@@ -1661,9 +1664,12 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 			       CONTEXT_NEXT, 1);
 
 	/* Get the header length */
-	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, FD))
+	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, FD)) {
 		rdata->rx.hdr_len = XGMAC_GET_BITS_LE(rdesc->desc2,
 						      RX_NORMAL_DESC2, HL);
+		if (rdata->rx.hdr_len)
+			pdata->ext_stats.rx_split_header_packets++;
+	}
 
 	/* Get the RSS hash */
 	if (XGMAC_GET_BITS_LE(rdesc->desc3, RX_NORMAL_DESC3, RSV)) {
@@ -1700,7 +1706,7 @@ static int xgbe_dev_read(struct xgbe_channel *channel)
 		       INCOMPLETE, 0);
 
 	/* Set checksum done indicator as appropriate */
-	if (channel->pdata->netdev->features & NETIF_F_RXCSUM)
+	if (netdev->features & NETIF_F_RXCSUM)
 		XGMAC_SET_BITS(packet->attributes, RX_PACKET_ATTRIBUTES,
 			       CSUM_DONE, 1);
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
index 5f149e8..95baa86 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-ethtool.c
@@ -133,6 +133,12 @@ struct xgbe_stats {
 	  offsetof(struct xgbe_prv_data, mmc_stats._var),	\
 	}
 
+#define XGMAC_EXT_STAT(_string, _var)				\
+	{ _string,						\
+	  FIELD_SIZEOF(struct xgbe_ext_stats, _var),		\
+	  offsetof(struct xgbe_prv_data, ext_stats._var),	\
+	}
+
 static const struct xgbe_stats xgbe_gstring_stats[] = {
 	XGMAC_MMC_STAT("tx_bytes", txoctetcount_gb),
 	XGMAC_MMC_STAT("tx_packets", txframecount_gb),
@@ -140,6 +146,7 @@ static const struct xgbe_stats xgbe_gstring_stats[] = {
 	XGMAC_MMC_STAT("tx_broadcast_packets", txbroadcastframes_gb),
 	XGMAC_MMC_STAT("tx_multicast_packets", txmulticastframes_gb),
 	XGMAC_MMC_STAT("tx_vlan_packets", txvlanframes_g),
+	XGMAC_EXT_STAT("tx_tso_packets", tx_tso_packets),
 	XGMAC_MMC_STAT("tx_64_byte_packets", tx64octets_gb),
 	XGMAC_MMC_STAT("tx_65_to_127_byte_packets", tx65to127octets_gb),
 	XGMAC_MMC_STAT("tx_128_to_255_byte_packets", tx128to255octets_gb),
@@ -171,6 +178,7 @@ static const struct xgbe_stats xgbe_gstring_stats[] = {
 	XGMAC_MMC_STAT("rx_fifo_overflow_errors", rxfifooverflow),
 	XGMAC_MMC_STAT("rx_watchdog_errors", rxwatchdogerror),
 	XGMAC_MMC_STAT("rx_pause_frames", rxpauseframes),
+	XGMAC_EXT_STAT("rx_split_header_packets", rx_split_header_packets),
 };
 
 #define XGBE_STATS_COUNT	ARRAY_SIZE(xgbe_gstring_stats)
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index e62dfa2..ef3d1e5 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -492,6 +492,11 @@ struct xgbe_mmc_stats {
 	u64 rxwatchdogerror;
 };
 
+struct xgbe_ext_stats {
+	u64 tx_tso_packets;
+	u64 rx_split_header_packets;
+};
+
 struct xgbe_hw_if {
 	int (*tx_complete)(struct xgbe_ring_desc *);
 
@@ -750,6 +755,7 @@ struct xgbe_prv_data {
 	netdev_features_t netdev_features;
 	struct napi_struct napi;
 	struct xgbe_mmc_stats mmc_stats;
+	struct xgbe_ext_stats ext_stats;
 
 	/* Filtering support */
 	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];

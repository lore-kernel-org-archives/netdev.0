From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 1/6] sfc: process RX event inner checksum flags
Date: Wed, 8 Feb 2017 16:50:40 +0000
Message-ID: <56e1b3a9-aeb9-9938-28f2-388f3135538a@solarflare.com>
References: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:35372 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753651AbdBHRDr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 12:03:47 -0500
In-Reply-To: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Add support for RX checksum offload of encapsulated packets. This
 essentially just means paying attention to the inner checksum flags
 in the RX event, and if *either* checksum flag indicates a fail then
 don't tell the kernel that checksum offload was successful.
Also, count these checksum errors and export the counts to ethtool -S.

Test the most common "good" case of RX events with a single bitmask
 instead of a series of ifs.  Move the more specific error checking
 in to a separate function for clarity, and don't use unlikely() there
 since we know at least one of the bits is bad.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/bitfield.h   |   3 +
 drivers/net/ethernet/sfc/ef10.c       | 123 ++++++++++++++++++++++++++++++----
 drivers/net/ethernet/sfc/ethtool.c    |   5 ++
 drivers/net/ethernet/sfc/net_driver.h |  19 ++++--
 4 files changed, 131 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/sfc/bitfield.h b/drivers/net/ethernet/sfc/bitfield.h
index 17d83f3..41ad07d 100644
--- a/drivers/net/ethernet/sfc/bitfield.h
+++ b/drivers/net/ethernet/sfc/bitfield.h
@@ -433,6 +433,9 @@ typedef union efx_oword {
 		(oword).u64[1] = (from).u64[1] & (mask).u64[1];	\
 	} while (0)
 
+#define EFX_AND_QWORD(qword, from, mask)			\
+		(qword).u64[0] = (from).u64[0] & (mask).u64[0]
+
 #define EFX_OR_OWORD(oword, from, mask)				\
 	do {							\
 		(oword).u64[0] = (from).u64[0] | (mask).u64[0];	\
diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index dec0c80..fd1008d 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3154,13 +3154,103 @@ static void efx_ef10_handle_rx_abort(struct efx_rx_queue *rx_queue)
 	++efx_rx_queue_channel(rx_queue)->n_rx_nodesc_trunc;
 }
 
+static u16 efx_ef10_handle_rx_event_errors(struct efx_channel *channel,
+					   unsigned int n_packets,
+					   unsigned int rx_encap_hdr,
+					   unsigned int rx_l3_class,
+					   unsigned int rx_l4_class,
+					   const efx_qword_t *event)
+{
+	struct efx_nic *efx = channel->efx;
+
+	if (EFX_QWORD_FIELD(*event, ESF_DZ_RX_ECRC_ERR)) {
+		if (!efx->loopback_selftest)
+			channel->n_rx_eth_crc_err += n_packets;
+		return EFX_RX_PKT_DISCARD;
+	}
+	if (EFX_QWORD_FIELD(*event, ESF_DZ_RX_IPCKSUM_ERR)) {
+		if (unlikely(rx_encap_hdr != ESE_EZ_ENCAP_HDR_VXLAN &&
+			     rx_l3_class != ESE_DZ_L3_CLASS_IP4 &&
+			     rx_l3_class != ESE_DZ_L3_CLASS_IP4_FRAG &&
+			     rx_l3_class != ESE_DZ_L3_CLASS_IP6 &&
+			     rx_l3_class != ESE_DZ_L3_CLASS_IP6_FRAG))
+			netdev_WARN(efx->net_dev,
+				    "invalid class for RX_IPCKSUM_ERR: event="
+				    EFX_QWORD_FMT "\n",
+				    EFX_QWORD_VAL(*event));
+		if (!efx->loopback_selftest)
+			*(rx_encap_hdr ?
+			  &channel->n_rx_outer_ip_hdr_chksum_err :
+			  &channel->n_rx_ip_hdr_chksum_err) += n_packets;
+		return 0;
+	}
+	if (EFX_QWORD_FIELD(*event, ESF_DZ_RX_TCPUDP_CKSUM_ERR)) {
+		if (unlikely(rx_encap_hdr != ESE_EZ_ENCAP_HDR_VXLAN &&
+			     ((rx_l3_class != ESE_DZ_L3_CLASS_IP4 &&
+			       rx_l3_class != ESE_DZ_L3_CLASS_IP6) ||
+			      (rx_l4_class != ESE_DZ_L4_CLASS_TCP &&
+			       rx_l4_class != ESE_DZ_L4_CLASS_UDP))))
+			netdev_WARN(efx->net_dev,
+				    "invalid class for RX_TCPUDP_CKSUM_ERR: event="
+				    EFX_QWORD_FMT "\n",
+				    EFX_QWORD_VAL(*event));
+		if (!efx->loopback_selftest)
+			*(rx_encap_hdr ?
+			  &channel->n_rx_outer_tcp_udp_chksum_err :
+			  &channel->n_rx_tcp_udp_chksum_err) += n_packets;
+		return 0;
+	}
+	if (EFX_QWORD_FIELD(*event, ESF_EZ_RX_IP_INNER_CHKSUM_ERR)) {
+		if (unlikely(!rx_encap_hdr))
+			netdev_WARN(efx->net_dev,
+				    "invalid encapsulation type for RX_IP_INNER_CHKSUM_ERR: event="
+				    EFX_QWORD_FMT "\n",
+				    EFX_QWORD_VAL(*event));
+		else if (unlikely(rx_l3_class != ESE_DZ_L3_CLASS_IP4 &&
+				  rx_l3_class != ESE_DZ_L3_CLASS_IP4_FRAG &&
+				  rx_l3_class != ESE_DZ_L3_CLASS_IP6 &&
+				  rx_l3_class != ESE_DZ_L3_CLASS_IP6_FRAG))
+			netdev_WARN(efx->net_dev,
+				    "invalid class for RX_IP_INNER_CHKSUM_ERR: event="
+				    EFX_QWORD_FMT "\n",
+				    EFX_QWORD_VAL(*event));
+		if (!efx->loopback_selftest)
+			channel->n_rx_inner_ip_hdr_chksum_err += n_packets;
+		return 0;
+	}
+	if (EFX_QWORD_FIELD(*event, ESF_EZ_RX_TCP_UDP_INNER_CHKSUM_ERR)) {
+		if (unlikely(!rx_encap_hdr))
+			netdev_WARN(efx->net_dev,
+				    "invalid encapsulation type for RX_TCP_UDP_INNER_CHKSUM_ERR: event="
+				    EFX_QWORD_FMT "\n",
+				    EFX_QWORD_VAL(*event));
+		else if (unlikely((rx_l3_class != ESE_DZ_L3_CLASS_IP4 &&
+				   rx_l3_class != ESE_DZ_L3_CLASS_IP6) ||
+				  (rx_l4_class != ESE_DZ_L4_CLASS_TCP &&
+				   rx_l4_class != ESE_DZ_L4_CLASS_UDP)))
+			netdev_WARN(efx->net_dev,
+				    "invalid class for RX_TCP_UDP_INNER_CHKSUM_ERR: event="
+				    EFX_QWORD_FMT "\n",
+				    EFX_QWORD_VAL(*event));
+		if (!efx->loopback_selftest)
+			channel->n_rx_inner_tcp_udp_chksum_err += n_packets;
+		return 0;
+	}
+
+	WARN_ON(1); /* No error bits were recognised */
+	return 0;
+}
+
 static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 				    const efx_qword_t *event)
 {
-	unsigned int rx_bytes, next_ptr_lbits, rx_queue_label, rx_l4_class;
+	unsigned int rx_bytes, next_ptr_lbits, rx_queue_label;
+	unsigned int rx_l3_class, rx_l4_class, rx_encap_hdr;
 	unsigned int n_descs, n_packets, i;
 	struct efx_nic *efx = channel->efx;
+	struct efx_ef10_nic_data *nic_data = efx->nic_data;
 	struct efx_rx_queue *rx_queue;
+	efx_qword_t errors;
 	bool rx_cont;
 	u16 flags = 0;
 
@@ -3171,8 +3261,14 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 	rx_bytes = EFX_QWORD_FIELD(*event, ESF_DZ_RX_BYTES);
 	next_ptr_lbits = EFX_QWORD_FIELD(*event, ESF_DZ_RX_DSC_PTR_LBITS);
 	rx_queue_label = EFX_QWORD_FIELD(*event, ESF_DZ_RX_QLABEL);
+	rx_l3_class = EFX_QWORD_FIELD(*event, ESF_DZ_RX_L3_CLASS);
 	rx_l4_class = EFX_QWORD_FIELD(*event, ESF_DZ_RX_L4_CLASS);
 	rx_cont = EFX_QWORD_FIELD(*event, ESF_DZ_RX_CONT);
+	rx_encap_hdr =
+		nic_data->datapath_caps &
+			(1 << MC_CMD_GET_CAPABILITIES_OUT_VXLAN_NVGRE_LBN) ?
+		EFX_QWORD_FIELD(*event, ESF_EZ_RX_ENCAP_HDR) :
+		ESE_EZ_ENCAP_HDR_NONE;
 
 	if (EFX_QWORD_FIELD(*event, ESF_DZ_RX_DROP_EVENT))
 		netdev_WARN(efx->net_dev, "saw RX_DROP_EVENT: event="
@@ -3232,17 +3328,20 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 		n_packets = 1;
 	}
 
-	if (unlikely(EFX_QWORD_FIELD(*event, ESF_DZ_RX_ECRC_ERR)))
-		flags |= EFX_RX_PKT_DISCARD;
-
-	if (unlikely(EFX_QWORD_FIELD(*event, ESF_DZ_RX_IPCKSUM_ERR))) {
-		channel->n_rx_ip_hdr_chksum_err += n_packets;
-	} else if (unlikely(EFX_QWORD_FIELD(*event,
-					    ESF_DZ_RX_TCPUDP_CKSUM_ERR))) {
-		channel->n_rx_tcp_udp_chksum_err += n_packets;
-	} else if (rx_l4_class == ESE_DZ_L4_CLASS_TCP ||
-		   rx_l4_class == ESE_DZ_L4_CLASS_UDP) {
-		flags |= EFX_RX_PKT_CSUMMED;
+	EFX_POPULATE_QWORD_5(errors, ESF_DZ_RX_ECRC_ERR, 1,
+				     ESF_DZ_RX_IPCKSUM_ERR, 1,
+				     ESF_DZ_RX_TCPUDP_CKSUM_ERR, 1,
+				     ESF_EZ_RX_IP_INNER_CHKSUM_ERR, 1,
+				     ESF_EZ_RX_TCP_UDP_INNER_CHKSUM_ERR, 1);
+	EFX_AND_QWORD(errors, *event, errors);
+	if (unlikely(!EFX_QWORD_IS_ZERO(errors))) {
+		flags |= efx_ef10_handle_rx_event_errors(channel, n_packets,
+							 rx_l3_class, rx_l4_class,
+							 rx_encap_hdr, event);
+	} else {
+		if (rx_l4_class == ESE_DZ_L4_CLASS_TCP ||
+		    rx_l4_class == ESE_DZ_L4_CLASS_UDP)
+			flags |= EFX_RX_PKT_CSUMMED;
 	}
 
 	if (rx_l4_class == ESE_DZ_L4_CLASS_TCP)
diff --git a/drivers/net/ethernet/sfc/ethtool.c b/drivers/net/ethernet/sfc/ethtool.c
index adddf70..3747b56 100644
--- a/drivers/net/ethernet/sfc/ethtool.c
+++ b/drivers/net/ethernet/sfc/ethtool.c
@@ -77,6 +77,11 @@ static const struct efx_sw_stat_desc efx_sw_stat_desc[] = {
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tobe_disc),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_ip_hdr_chksum_err),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tcp_udp_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_inner_ip_hdr_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_inner_tcp_udp_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_outer_ip_hdr_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_outer_tcp_udp_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_eth_crc_err),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_mcast_mismatch),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_frm_trunc),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_merge_events),
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 73810d2..3b15110 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -469,13 +469,18 @@ struct efx_channel {
 	u32 *rps_flow_id;
 #endif
 
-	unsigned n_rx_tobe_disc;
-	unsigned n_rx_ip_hdr_chksum_err;
-	unsigned n_rx_tcp_udp_chksum_err;
-	unsigned n_rx_mcast_mismatch;
-	unsigned n_rx_frm_trunc;
-	unsigned n_rx_overlength;
-	unsigned n_skbuff_leaks;
+	unsigned int n_rx_tobe_disc;
+	unsigned int n_rx_ip_hdr_chksum_err;
+	unsigned int n_rx_tcp_udp_chksum_err;
+	unsigned int n_rx_outer_ip_hdr_chksum_err;
+	unsigned int n_rx_outer_tcp_udp_chksum_err;
+	unsigned int n_rx_inner_ip_hdr_chksum_err;
+	unsigned int n_rx_inner_tcp_udp_chksum_err;
+	unsigned int n_rx_eth_crc_err;
+	unsigned int n_rx_mcast_mismatch;
+	unsigned int n_rx_frm_trunc;
+	unsigned int n_rx_overlength;
+	unsigned int n_skbuff_leaks;
 	unsigned int n_rx_nodesc_trunc;
 	unsigned int n_rx_merge_events;
 	unsigned int n_rx_merge_packets;

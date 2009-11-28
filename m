From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 12/12] sfc: Clean up RX event handling
Date: Sat, 28 Nov 2009 15:36:29 +0000
Message-ID: <1259422589.3709.13.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:59195 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752499AbZK1Pg0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Nov 2009 10:36:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add 'likely' hint to test of rx_checksum_enabled.
Don't count IP fragments; the IP stack can do that.
Do count non-matching multicast packets.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/ethtool.c    |    1 +
 drivers/net/sfc/falcon.c     |   11 +++++------
 drivers/net/sfc/net_driver.h |    4 ++--
 3 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index b3d0485..8b91cd2 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -153,6 +153,7 @@ static struct efx_ethtool_stat efx_ethtool_stats[] = {
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tobe_disc),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_ip_hdr_chksum_err),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_tcp_udp_chksum_err),
+	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_mcast_mismatch),
 	EFX_ETHTOOL_UINT_CHANNEL_STAT(rx_frm_trunc),
 };
 
diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index 2096753..b2509fc 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -734,7 +734,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	bool rx_ev_tcp_udp_chksum_err, rx_ev_eth_crc_err;
 	bool rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
 	bool rx_ev_other_err, rx_ev_pause_frm;
-	bool rx_ev_ip_frag_err, rx_ev_hdr_type, rx_ev_mcast_pkt;
+	bool rx_ev_hdr_type, rx_ev_mcast_pkt;
 	unsigned rx_ev_pkt_type;
 
 	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_HDR_TYPE);
@@ -743,7 +743,6 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	rx_ev_pkt_type = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_PKT_TYPE);
 	rx_ev_buf_owner_id_err = EFX_QWORD_FIELD(*event,
 						 FSF_AZ_RX_EV_BUF_OWNER_ID_ERR);
-	rx_ev_ip_frag_err = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_IP_FRAG_ERR);
 	rx_ev_ip_hdr_chksum_err = EFX_QWORD_FIELD(*event,
 						  FSF_AZ_RX_EV_IP_HDR_CHKSUM_ERR);
 	rx_ev_tcp_udp_chksum_err = EFX_QWORD_FIELD(*event,
@@ -771,8 +770,6 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 		else if (rx_ev_tcp_udp_chksum_err)
 			++rx_queue->channel->n_rx_tcp_udp_chksum_err;
 	}
-	if (rx_ev_ip_frag_err)
-		++rx_queue->channel->n_rx_ip_frag_err;
 
 	/* The frame must be discarded if any of these are true. */
 	*discard = (rx_ev_eth_crc_err | rx_ev_frm_trunc | rx_ev_drib_nib |
@@ -855,7 +852,7 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 		 * UDP/IPv4, then we can rely on the hardware checksum.
 		 */
 		checksummed =
-			efx->rx_checksum_enabled &&
+			likely(efx->rx_checksum_enabled) &&
 			(rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_TCP ||
 			 rx_ev_hdr_type == FSE_AB_RX_EV_HDR_TYPE_IPV4_UDP);
 	} else {
@@ -870,8 +867,10 @@ static void falcon_handle_rx_event(struct efx_channel *channel,
 		unsigned int rx_ev_mcast_hash_match =
 			EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_MCAST_HASH_MATCH);
 
-		if (unlikely(!rx_ev_mcast_hash_match))
+		if (unlikely(!rx_ev_mcast_hash_match)) {
+			++channel->n_rx_mcast_mismatch;
 			discard = true;
+		}
 	}
 
 	channel->irq_mod_score += 2;
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index 90f6a2a..320ae7d 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -350,9 +350,9 @@ enum efx_rx_alloc_method {
  * @rx_alloc_push_pages: RX allocation method currently in use for pushing
  *	descriptors
  * @n_rx_tobe_disc: Count of RX_TOBE_DISC errors
- * @n_rx_ip_frag_err: Count of RX IP fragment errors
  * @n_rx_ip_hdr_chksum_err: Count of RX IP header checksum errors
  * @n_rx_tcp_udp_chksum_err: Count of RX TCP and UDP checksum errors
+ * @n_rx_mcast_mismatch: Count of unmatched multicast frames
  * @n_rx_frm_trunc: Count of RX_FRM_TRUNC errors
  * @n_rx_overlength: Count of RX_OVERLENGTH errors
  * @n_skbuff_leaks: Count of skbuffs leaked due to RX overrun
@@ -380,9 +380,9 @@ struct efx_channel {
 	int rx_alloc_push_pages;
 
 	unsigned n_rx_tobe_disc;
-	unsigned n_rx_ip_frag_err;
 	unsigned n_rx_ip_hdr_chksum_err;
 	unsigned n_rx_tcp_udp_chksum_err;
+	unsigned n_rx_mcast_mismatch;
 	unsigned n_rx_frm_trunc;
 	unsigned n_rx_overlength;
 	unsigned n_skbuff_leaks;
-- 
1.6.5.3



-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6 1/6] sfc: Move test of rx_checksum_enabled
 from nic.c to rx.c
Date: Sun, 03 Apr 2011 20:50:37 +0100
Message-ID: <1301860237.2935.24.camel@localhost>
References: <1301859889.2935.23.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:9782 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549Ab1DCTuk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 15:50:40 -0400
In-Reply-To: <1301859889.2935.23.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is preparation for using the generic netdev features interface,
and should have no effect in itself.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/nic.c |    6 ++----
 drivers/net/sfc/rx.c  |    3 +++
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/sfc/nic.c b/drivers/net/sfc/nic.c
index e839661..2594f39 100644
--- a/drivers/net/sfc/nic.c
+++ b/drivers/net/sfc/nic.c
@@ -850,7 +850,6 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 	unsigned expected_ptr;
 	bool rx_ev_pkt_ok, discard = false, checksummed;
 	struct efx_rx_queue *rx_queue;
-	struct efx_nic *efx = channel->efx;
 
 	/* Basic packet information */
 	rx_ev_byte_cnt = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_BYTE_CNT);
@@ -873,9 +872,8 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 		 * UDP/IP, then we can rely on the hardware checksum.
 		 */
 		checksummed =
-			likely(efx->rx_checksum_enabled) &&
-			(rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP ||
-			 rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP);
+			rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP ||
+			rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP;
 	} else {
 		efx_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok, &discard);
 		checksummed = false;
diff --git a/drivers/net/sfc/rx.c b/drivers/net/sfc/rx.c
index c0fdb59..fb402c5 100644
--- a/drivers/net/sfc/rx.c
+++ b/drivers/net/sfc/rx.c
@@ -605,6 +605,9 @@ void __efx_rx_packet(struct efx_channel *channel,
 		skb_record_rx_queue(skb, channel->channel);
 	}
 
+	if (unlikely(!efx->rx_checksum_enabled))
+		checksummed = false;
+
 	if (likely(checksummed || rx_buf->is_page)) {
 		efx_rx_packet_gro(channel, rx_buf, eh, checksummed);
 		return;
-- 
1.5.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


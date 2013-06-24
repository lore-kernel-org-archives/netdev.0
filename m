From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 6/9] sfc: Define and set RX buffer flag for packets
 parsed as TCP
Date: Mon, 24 Jun 2013 21:14:24 +0100
Message-ID: <1372104864.1896.35.camel@bwh-desktop.uk.level5networks.com>
References: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17323 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750745Ab3FXUO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 16:14:28 -0400
In-Reply-To: <1372104708.1896.29.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This will be useful for shortcutting some software packet parsing.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 drivers/net/ethernet/sfc/nic.c        | 19 ++++++++++++++-----
 2 files changed, 15 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 2dec48b..f4c7e6b 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -243,6 +243,7 @@ struct efx_rx_buffer {
 #define EFX_RX_BUF_LAST_IN_PAGE	0x0001
 #define EFX_RX_PKT_CSUMMED	0x0002
 #define EFX_RX_PKT_DISCARD	0x0004
+#define EFX_RX_PKT_TCP		0x0040
 
 /**
  * struct efx_rx_page_state - Page-based rx buffer state
diff --git a/drivers/net/ethernet/sfc/nic.c b/drivers/net/ethernet/sfc/nic.c
index 39432d3..f2b864c 100644
--- a/drivers/net/ethernet/sfc/nic.c
+++ b/drivers/net/ethernet/sfc/nic.c
@@ -1080,12 +1080,21 @@ efx_handle_rx_event(struct efx_channel *channel, const efx_qword_t *event)
 	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, FSF_AZ_RX_EV_HDR_TYPE);
 
 	if (likely(rx_ev_pkt_ok)) {
-		/* If packet is marked as OK and packet type is TCP/IP or
-		 * UDP/IP, then we can rely on the hardware checksum.
+		/* If packet is marked as OK then we can rely on the
+		 * hardware checksum and classification.
 		 */
-		flags = (rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP ||
-			 rx_ev_hdr_type == FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP) ?
-			EFX_RX_PKT_CSUMMED : 0;
+		flags = 0;
+		switch (rx_ev_hdr_type) {
+		case FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_TCP:
+			flags |= EFX_RX_PKT_TCP;
+			/* fall through */
+		case FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_UDP:
+			flags |= EFX_RX_PKT_CSUMMED;
+			/* fall through */
+		case FSE_CZ_RX_EV_HDR_TYPE_IPV4V6_OTHER:
+		case FSE_AZ_RX_EV_HDR_TYPE_OTHER:
+			break;
+		}
 	} else {
 		flags = efx_handle_rx_not_ok(rx_queue, event);
 	}


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

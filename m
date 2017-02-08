From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 2/6] sfc: set csum_level for encapsulated packets
Date: Wed, 8 Feb 2017 16:51:02 +0000
Message-ID: <2d3d1808-bf59-5007-33af-cf038a8a8738@solarflare.com>
References: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:60868 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752682AbdBHQ6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:58:31 -0500
In-Reply-To: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Cooper <jcooper@solarflare.com>

Set the csum_level for encapsulated packets where the encapsulation
 type, l3 class and l4 class are sets that need it.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 drivers/net/ethernet/sfc/ef10.c       | 23 ++++++++++++++++++++---
 drivers/net/ethernet/sfc/net_driver.h |  1 +
 drivers/net/ethernet/sfc/rx.c         |  5 ++++-
 3 files changed, 25 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/sfc/ef10.c b/drivers/net/ethernet/sfc/ef10.c
index fd1008d..c738b11 100644
--- a/drivers/net/ethernet/sfc/ef10.c
+++ b/drivers/net/ethernet/sfc/ef10.c
@@ -3339,9 +3339,26 @@ static int efx_ef10_handle_rx_event(struct efx_channel *channel,
 							 rx_l3_class, rx_l4_class,
 							 rx_encap_hdr, event);
 	} else {
-		if (rx_l4_class == ESE_DZ_L4_CLASS_TCP ||
-		    rx_l4_class == ESE_DZ_L4_CLASS_UDP)
-			flags |= EFX_RX_PKT_CSUMMED;
+		bool tcpudp = rx_l4_class == ESE_DZ_L4_CLASS_TCP ||
+			      rx_l4_class == ESE_DZ_L4_CLASS_UDP;
+
+		switch (rx_encap_hdr) {
+		case ESE_EZ_ENCAP_HDR_VXLAN: /* VxLAN or GENEVE */
+			flags |= EFX_RX_PKT_CSUMMED; /* outer UDP csum */
+			if (tcpudp)
+				flags |= EFX_RX_PKT_CSUM_LEVEL; /* inner L4 */
+			break;
+		case ESE_EZ_ENCAP_HDR_GRE:
+		case ESE_EZ_ENCAP_HDR_NONE:
+			if (tcpudp)
+				flags |= EFX_RX_PKT_CSUMMED;
+			break;
+		default:
+			netdev_WARN(efx->net_dev,
+				    "unknown encapsulation type: event="
+				    EFX_QWORD_FMT "\n",
+				    EFX_QWORD_VAL(*event));
+		}
 	}
 
 	if (rx_l4_class == ESE_DZ_L4_CLASS_TCP)
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 3b15110..e64e933 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -307,6 +307,7 @@ struct efx_rx_buffer {
 #define EFX_RX_PKT_DISCARD	0x0004
 #define EFX_RX_PKT_TCP		0x0040
 #define EFX_RX_PKT_PREFIX_LEN	0x0080	/* length is in prefix only */
+#define EFX_RX_PKT_CSUM_LEVEL	0x0200
 
 /**
  * struct efx_rx_page_state - Page-based rx buffer state
diff --git a/drivers/net/ethernet/sfc/rx.c b/drivers/net/ethernet/sfc/rx.c
index 31587f4..42443f4 100644
--- a/drivers/net/ethernet/sfc/rx.c
+++ b/drivers/net/ethernet/sfc/rx.c
@@ -434,6 +434,7 @@ efx_rx_packet_gro(struct efx_channel *channel, struct efx_rx_buffer *rx_buf,
 			     PKT_HASH_TYPE_L3);
 	skb->ip_summed = ((rx_buf->flags & EFX_RX_PKT_CSUMMED) ?
 			  CHECKSUM_UNNECESSARY : CHECKSUM_NONE);
+	skb->csum_level = !!(rx_buf->flags & EFX_RX_PKT_CSUM_LEVEL);
 
 	for (;;) {
 		skb_fill_page_desc(skb, skb_shinfo(skb)->nr_frags,
@@ -621,8 +622,10 @@ static void efx_rx_deliver(struct efx_channel *channel, u8 *eh,
 
 	/* Set the SKB flags */
 	skb_checksum_none_assert(skb);
-	if (likely(rx_buf->flags & EFX_RX_PKT_CSUMMED))
+	if (likely(rx_buf->flags & EFX_RX_PKT_CSUMMED)) {
 		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		skb->csum_level = !!(rx_buf->flags & EFX_RX_PKT_CSUM_LEVEL);
+	}
 
 	efx_rx_skb_attach_timestamp(channel, skb);
 

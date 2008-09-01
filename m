From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH 07/52] sfc: Remove mistaken hardware workaround
Date: Mon, 1 Sep 2008 12:46:03 +0100
Message-ID: <20080901114602.GA7908@solarflare.com>
References: <20080901111621.GT7908@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:34271 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752144AbYIALqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2008 07:46:07 -0400
Content-Disposition: inline
In-Reply-To: <20080901111621.GT7908@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We believed that some valid SNAP frames were being marked as invalid.
In fact this is not the case and no workaround is needed.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/sfc/falcon.c      |   65 ++--------------------------------------
 drivers/net/sfc/workarounds.h |    2 -
 2 files changed, 4 insertions(+), 63 deletions(-)

diff --git a/drivers/net/sfc/falcon.c b/drivers/net/sfc/falcon.c
index b73f1ea..f575322 100644
--- a/drivers/net/sfc/falcon.c
+++ b/drivers/net/sfc/falcon.c
@@ -848,31 +848,11 @@ static inline void falcon_handle_tx_event(struct efx_channel *channel,
 	}
 }
 
-/* Check received packet's destination MAC address. */
-static int check_dest_mac(struct efx_rx_queue *rx_queue,
-			  const efx_qword_t *event)
-{
-	struct efx_rx_buffer *rx_buf;
-	struct efx_nic *efx = rx_queue->efx;
-	int rx_ev_desc_ptr;
-	struct ethhdr *eh;
-
-	if (efx->promiscuous)
-		return 1;
-
-	rx_ev_desc_ptr = EFX_QWORD_FIELD(*event, RX_EV_DESC_PTR);
-	rx_buf = efx_rx_buffer(rx_queue, rx_ev_desc_ptr);
-	eh = (struct ethhdr *)rx_buf->data;
-	if (memcmp(eh->h_dest, efx->net_dev->dev_addr, ETH_ALEN))
-		return 0;
-	return 1;
-}
-
 /* Detect errors included in the rx_evt_pkt_ok bit. */
 static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 				    const efx_qword_t *event,
 				    unsigned *rx_ev_pkt_ok,
-				    int *discard, int byte_count)
+				    int *discard)
 {
 	struct efx_nic *efx = rx_queue->efx;
 	unsigned rx_ev_buf_owner_id_err, rx_ev_ip_hdr_chksum_err;
@@ -880,7 +860,6 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 	unsigned rx_ev_frm_trunc, rx_ev_drib_nib, rx_ev_tobe_disc;
 	unsigned rx_ev_pkt_type, rx_ev_other_err, rx_ev_pause_frm;
 	unsigned rx_ev_ip_frag_err, rx_ev_hdr_type, rx_ev_mcast_pkt;
-	int snap, non_ip;
 
 	rx_ev_hdr_type = EFX_QWORD_FIELD(*event, RX_EV_HDR_TYPE);
 	rx_ev_mcast_pkt = EFX_QWORD_FIELD(*event, RX_EV_MCAST_PKT);
@@ -904,41 +883,6 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 			   rx_ev_buf_owner_id_err | rx_ev_eth_crc_err |
 			   rx_ev_frm_trunc | rx_ev_ip_hdr_chksum_err);
 
-	snap = (rx_ev_pkt_type == RX_EV_PKT_TYPE_LLC_DECODE) ||
-		(rx_ev_pkt_type == RX_EV_PKT_TYPE_VLAN_LLC_DECODE);
-	non_ip = (rx_ev_hdr_type == RX_EV_HDR_TYPE_NON_IP_DECODE);
-
-	/* SFC bug 5475/8970: The Falcon XMAC incorrectly calculates the
-	 * length field of an LLC frame, which sets TOBE_DISC. We could set
-	 * PASS_LEN_ERR, but we want the MAC to filter out short frames (to
-	 * protect the RX block).
-	 *
-	 * bug5475 - LLC/SNAP: Falcon identifies SNAP packets.
-	 * bug8970 - LLC/noSNAP: Falcon does not provide an LLC flag.
-	 *                       LLC can't encapsulate IP, so by definition
-	 *                       these packets are NON_IP.
-	 *
-	 * Unicast mismatch will also cause TOBE_DISC, so the driver needs
-	 * to check this.
-	 */
-	if (EFX_WORKAROUND_5475(efx) && rx_ev_tobe_disc && (snap || non_ip)) {
-		/* If all the other flags are zero then we can state the
-		 * entire packet is ok, which will flag to the kernel not
-		 * to recalculate checksums.
-		 */
-		if (!(non_ip | rx_ev_other_err | rx_ev_pause_frm))
-			*rx_ev_pkt_ok = 1;
-
-		rx_ev_tobe_disc = 0;
-
-		/* TOBE_DISC is set for unicast mismatch.  But given that
-		 * we can't trust TOBE_DISC here, we must validate the dest
-		 * MAC address ourselves.
-		 */
-		if (!rx_ev_mcast_pkt && !check_dest_mac(rx_queue, event))
-			rx_ev_tobe_disc = 1;
-	}
-
 	/* Count errors that are not in MAC stats. */
 	if (rx_ev_frm_trunc)
 		++rx_queue->channel->n_rx_frm_trunc;
@@ -962,7 +906,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 #ifdef EFX_ENABLE_DEBUG
 	if (rx_ev_other_err) {
 		EFX_INFO_RL(efx, " RX queue %d unexpected RX event "
-			    EFX_QWORD_FMT "%s%s%s%s%s%s%s%s%s\n",
+			    EFX_QWORD_FMT "%s%s%s%s%s%s%s%s\n",
 			    rx_queue->queue, EFX_QWORD_VAL(*event),
 			    rx_ev_buf_owner_id_err ? " [OWNER_ID_ERR]" : "",
 			    rx_ev_ip_hdr_chksum_err ?
@@ -973,8 +917,7 @@ static void falcon_handle_rx_not_ok(struct efx_rx_queue *rx_queue,
 			    rx_ev_frm_trunc ? " [FRM_TRUNC]" : "",
 			    rx_ev_drib_nib ? " [DRIB_NIB]" : "",
 			    rx_ev_tobe_disc ? " [TOBE_DISC]" : "",
-			    rx_ev_pause_frm ? " [PAUSE]" : "",
-			    snap ? " [SNAP/LLC]" : "");
+			    rx_ev_pause_frm ? " [PAUSE]" : "");
 	}
 #endif
 
@@ -1041,7 +984,7 @@ static inline int falcon_handle_rx_event(struct efx_channel *channel,
 		checksummed = RX_EV_HDR_TYPE_HAS_CHECKSUMS(rx_ev_hdr_type);
 	} else {
 		falcon_handle_rx_not_ok(rx_queue, event, &rx_ev_pkt_ok,
-					&discard, rx_ev_byte_cnt);
+					&discard);
 		checksummed = 0;
 	}
 
diff --git a/drivers/net/sfc/workarounds.h b/drivers/net/sfc/workarounds.h
index 35ab19c..a824f59 100644
--- a/drivers/net/sfc/workarounds.h
+++ b/drivers/net/sfc/workarounds.h
@@ -20,8 +20,6 @@
 
 /* XAUI resets if link not detected */
 #define EFX_WORKAROUND_5147 EFX_WORKAROUND_ALWAYS
-/* SNAP frames have TOBE_DISC set */
-#define EFX_WORKAROUND_5475 EFX_WORKAROUND_ALWAYS
 /* RX PCIe double split performance issue */
 #define EFX_WORKAROUND_7575 EFX_WORKAROUND_ALWAYS
 /* TX pkt parser problem with <= 16 byte TXes */
-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


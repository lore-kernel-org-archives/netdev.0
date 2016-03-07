From: Michael Chan <michael.chan@broadcom.com>
Subject: [PATCH v2 net-next 6/8] bnxt_en: Include some hardware port statistics in ndo_get_stats64().
Date: Mon,  7 Mar 2016 15:38:46 -0500
Message-ID: <1457383128-28645-7-git-send-email-michael.chan@broadcom.com>
References: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 5520-maca-inet1-outside.broadcom.com ([216.31.211.11]:60074
	"EHLO mail-irv-18.broadcom.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753634AbcCGUiu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 15:38:50 -0500
In-Reply-To: <1457383128-28645-1-git-send-email-michael.chan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Include some of the port error counters (e.g. crc) in ->ndo_get_stats64()
for the PF device.

Signed-off-by: Michael Chan <michael.chan@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnxt/bnxt.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnxt/bnxt.c b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
index c5e812a..18a14a5 100644
--- a/drivers/net/ethernet/broadcom/bnxt/bnxt.c
+++ b/drivers/net/ethernet/broadcom/bnxt/bnxt.c
@@ -4934,6 +4934,22 @@ bnxt_get_stats64(struct net_device *dev, struct rtnl_link_stats64 *stats)
 		stats->tx_dropped += le64_to_cpu(hw_stats->tx_drop_pkts);
 	}
 
+	if (bp->flags & BNXT_FLAG_PORT_STATS) {
+		struct rx_port_stats *rx = bp->hw_rx_port_stats;
+		struct tx_port_stats *tx = bp->hw_tx_port_stats;
+
+		stats->rx_crc_errors = le64_to_cpu(rx->rx_fcs_err_frames);
+		stats->rx_frame_errors = le64_to_cpu(rx->rx_align_err_frames);
+		stats->rx_length_errors = le64_to_cpu(rx->rx_undrsz_frames) +
+					  le64_to_cpu(rx->rx_ovrsz_frames) +
+					  le64_to_cpu(rx->rx_runt_frames);
+		stats->rx_errors = le64_to_cpu(rx->rx_false_carrier_frames) +
+				   le64_to_cpu(rx->rx_jbr_frames);
+		stats->collisions = le64_to_cpu(tx->tx_total_collisions);
+		stats->tx_fifo_errors = le64_to_cpu(tx->tx_fifo_underruns);
+		stats->tx_errors = le64_to_cpu(tx->tx_err);
+	}
+
 	return stats;
 }
 
-- 
1.8.3.1

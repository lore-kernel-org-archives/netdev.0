From: Willy Tarreau <w@1wt.eu>
Subject: [PATCH 01/13] net: mvneta: increase the 64-bit rx/tx stats out of the hot path
Date: Thu, 16 Jan 2014 08:20:07 +0100
Message-ID: <1389856819-6503-2-git-send-email-w@1wt.eu>
References: <1389856819-6503-1-git-send-email-w@1wt.eu>
Cc: netdev@vger.kernel.org, Willy Tarreau <w@1wt.eu>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55453 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910AbaAPHUg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Jan 2014 02:20:36 -0500
In-Reply-To: <1389856819-6503-1-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Better count packets and bytes in the stack and on 32 bit then
accumulate them at the end for once. This saves two memory writes
and two memory barriers per packet. The incoming packet rate was
increased by 4.7% on the Openblocks AX3 thanks to this.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
Reviewed-by: Eric Dumazet <edumazet@google.com>
Tested-by: Arnaud Ebalard <arno@natisbad.org>
Signed-off-by: Willy Tarreau <w@1wt.eu>
---
 drivers/net/ethernet/marvell/mvneta.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index d5f0d72..baa85af 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -1391,6 +1391,8 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 {
 	struct net_device *dev = pp->dev;
 	int rx_done, rx_filled;
+	u32 rcvd_pkts = 0;
+	u32 rcvd_bytes = 0;
 
 	/* Get number of received packets */
 	rx_done = mvneta_rxq_busy_desc_num_get(pp, rxq);
@@ -1428,10 +1430,8 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 
 		rx_bytes = rx_desc->data_size -
 			(ETH_FCS_LEN + MVNETA_MH_SIZE);
-		u64_stats_update_begin(&pp->rx_stats.syncp);
-		pp->rx_stats.packets++;
-		pp->rx_stats.bytes += rx_bytes;
-		u64_stats_update_end(&pp->rx_stats.syncp);
+		rcvd_pkts++;
+		rcvd_bytes += rx_bytes;
 
 		/* Linux processing */
 		skb_reserve(skb, MVNETA_MH_SIZE);
@@ -1452,6 +1452,13 @@ static int mvneta_rx(struct mvneta_port *pp, int rx_todo,
 		}
 	}
 
+	if (rcvd_pkts) {
+		u64_stats_update_begin(&pp->rx_stats.syncp);
+		pp->rx_stats.packets += rcvd_pkts;
+		pp->rx_stats.bytes   += rcvd_bytes;
+		u64_stats_update_end(&pp->rx_stats.syncp);
+	}
+
 	/* Update rxq management counters */
 	mvneta_rxq_desc_num_update(pp, rxq, rx_done, rx_filled);
 
-- 
1.7.12.2.21.g234cd45.dirty

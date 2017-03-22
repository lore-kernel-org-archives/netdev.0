From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 13/15] nfp: flush xmit_more on error paths
Date: Tue, 21 Mar 2017 17:59:19 -0700
Message-ID: <20170322005921.10965-14-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:33489 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758582AbdCVBIm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:08:42 -0400
Received: by mail-pg0-f51.google.com with SMTP id n190so101337238pga.0
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:08:35 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of ring full or DMA mapping error remember to flush xmit_more
delayed kicks.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 255294b8bc5f..d35eeba86bac 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -759,6 +759,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 		nn_dp_warn(dp, "TX ring %d busy. wrp=%u rdp=%u\n",
 			   qidx, tx_ring->wr_p, tx_ring->rd_p);
 		netif_tx_stop_queue(nd_q);
+		nfp_net_tx_xmit_more_flush(tx_ring);
 		u64_stats_update_begin(&r_vec->tx_sync);
 		r_vec->tx_busy++;
 		u64_stats_update_end(&r_vec->tx_sync);
@@ -867,6 +868,7 @@ static int nfp_net_tx(struct sk_buff *skb, struct net_device *netdev)
 	tx_ring->txbufs[wr_idx].fidx = -2;
 err_free:
 	nn_dp_warn(dp, "Failed to map DMA TX buffer\n");
+	nfp_net_tx_xmit_more_flush(tx_ring);
 	u64_stats_update_begin(&r_vec->tx_sync);
 	r_vec->tx_errors++;
 	u64_stats_update_end(&r_vec->tx_sync);
-- 
2.11.0

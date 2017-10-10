From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 1/2] nfp: fix ethtool stats gather retry
Date: Tue, 10 Oct 2017 09:16:22 -0700
Message-ID: <20171010161623.23838-2-jakub.kicinski@netronome.com>
References: <20171010161623.23838-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:49094 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932191AbdJJQQf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 12:16:35 -0400
Received: by mail-pf0-f176.google.com with SMTP id b79so5440329pfk.5
        for <netdev@vger.kernel.org>; Tue, 10 Oct 2017 09:16:34 -0700 (PDT)
In-Reply-To: <20171010161623.23838-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The while loop fetching 64 bit ethtool statistics may have
to retry multiple times, it shouldn't modify the outside state.

Fixes: 4c3523623dc0 ("net: add driver for Netronome NFP4000/NFP6000 NIC VFs")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 07969f06df10..dc016dfec64d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -464,7 +464,7 @@ static u64 *nfp_vnic_get_sw_stats(struct net_device *netdev, u64 *data)
 
 		do {
 			start = u64_stats_fetch_begin(&nn->r_vecs[i].rx_sync);
-			*data++ = nn->r_vecs[i].rx_pkts;
+			data[0] = nn->r_vecs[i].rx_pkts;
 			tmp[0] = nn->r_vecs[i].hw_csum_rx_ok;
 			tmp[1] = nn->r_vecs[i].hw_csum_rx_inner_ok;
 			tmp[2] = nn->r_vecs[i].hw_csum_rx_error;
@@ -472,14 +472,16 @@ static u64 *nfp_vnic_get_sw_stats(struct net_device *netdev, u64 *data)
 
 		do {
 			start = u64_stats_fetch_begin(&nn->r_vecs[i].tx_sync);
-			*data++ = nn->r_vecs[i].tx_pkts;
-			*data++ = nn->r_vecs[i].tx_busy;
+			data[1] = nn->r_vecs[i].tx_pkts;
+			data[2] = nn->r_vecs[i].tx_busy;
 			tmp[3] = nn->r_vecs[i].hw_csum_tx;
 			tmp[4] = nn->r_vecs[i].hw_csum_tx_inner;
 			tmp[5] = nn->r_vecs[i].tx_gather;
 			tmp[6] = nn->r_vecs[i].tx_lso;
 		} while (u64_stats_fetch_retry(&nn->r_vecs[i].tx_sync, start));
 
+		data += 3;
+
 		for (j = 0; j < NN_ET_RVEC_GATHER_STATS; j++)
 			gathered_stats[j] += tmp[j];
 	}
-- 
2.14.1

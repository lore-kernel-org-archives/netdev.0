From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 05/12] nfp: add helper for printing ethtool strings
Date: Fri, 18 Aug 2017 15:48:15 -0700
Message-ID: <20170818224822.8409-6-jakub.kicinski@netronome.com>
References: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:32820 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751609AbdHRWt2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 18:49:28 -0400
Received: by mail-pg0-f42.google.com with SMTP id t3so44444998pgt.0
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 15:49:27 -0700 (PDT)
In-Reply-To: <20170818224822.8409-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a helper for printing ethtool strings and advancing the
pointer correctly.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   | 65 +++++++++++-----------
 1 file changed, 32 insertions(+), 33 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 1753bfbc8b47..ba1c28b8791b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -335,53 +335,52 @@ static int nfp_net_set_ringparam(struct net_device *netdev,
 	return nfp_net_set_ring_size(nn, rxd_cnt, txd_cnt);
 }
 
+static __printf(2, 3) u8 *nfp_pr_et(u8 *data, const char *fmt, ...)
+{
+	va_list args;
+
+	va_start(args, fmt);
+	vsnprintf(data, ETH_GSTRING_LEN, fmt, args);
+	va_end(args);
+
+	return data + ETH_GSTRING_LEN;
+}
+
 static void nfp_net_get_strings(struct net_device *netdev,
 				u32 stringset, u8 *data)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
-	u8 *p = data;
 	int i;
 
 	switch (stringset) {
 	case ETH_SS_STATS:
-		for (i = 0; i < NN_ET_GLOBAL_STATS_LEN; i++) {
-			memcpy(p, nfp_net_et_stats[i].name, ETH_GSTRING_LEN);
-			p += ETH_GSTRING_LEN;
-		}
+		for (i = 0; i < NN_ET_GLOBAL_STATS_LEN; i++)
+			data = nfp_pr_et(data, nfp_net_et_stats[i].name);
+
 		for (i = 0; i < nn->dp.num_r_vecs; i++) {
-			sprintf(p, "rvec_%u_rx_pkts", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "rvec_%u_tx_pkts", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "rvec_%u_tx_busy", i);
-			p += ETH_GSTRING_LEN;
+			data = nfp_pr_et(data, "rvec_%u_rx_pkts", i);
+			data = nfp_pr_et(data, "rvec_%u_tx_pkts", i);
+			data = nfp_pr_et(data, "rvec_%u_tx_busy", i);
 		}
-		strncpy(p, "hw_rx_csum_ok", ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-		strncpy(p, "hw_rx_csum_inner_ok", ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-		strncpy(p, "hw_rx_csum_err", ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-		strncpy(p, "hw_tx_csum", ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-		strncpy(p, "hw_tx_inner_csum", ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-		strncpy(p, "tx_gather", ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
-		strncpy(p, "tx_lso", ETH_GSTRING_LEN);
-		p += ETH_GSTRING_LEN;
+
+		data = nfp_pr_et(data, "hw_rx_csum_ok");
+		data = nfp_pr_et(data, "hw_rx_csum_inner_ok");
+		data = nfp_pr_et(data, "hw_rx_csum_err");
+		data = nfp_pr_et(data, "hw_tx_csum");
+		data = nfp_pr_et(data, "hw_tx_inner_csum");
+		data = nfp_pr_et(data, "tx_gather");
+		data = nfp_pr_et(data, "tx_lso");
+
 		for (i = 0; i < nn->dp.num_tx_rings; i++) {
-			sprintf(p, "txq_%u_pkts", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "txq_%u_bytes", i);
-			p += ETH_GSTRING_LEN;
+			data = nfp_pr_et(data, "txq_%u_pkts", i);
+			data = nfp_pr_et(data, "txq_%u_bytes", i);
 		}
+
 		for (i = 0; i < nn->dp.num_rx_rings; i++) {
-			sprintf(p, "rxq_%u_pkts", i);
-			p += ETH_GSTRING_LEN;
-			sprintf(p, "rxq_%u_bytes", i);
-			p += ETH_GSTRING_LEN;
+			data = nfp_pr_et(data, "rxq_%u_pkts", i);
+			data = nfp_pr_et(data, "rxq_%u_bytes", i);
 		}
+
 		break;
 	}
 }
-- 
2.11.0

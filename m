From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 06/13] nfp: use dp to carry mtu at reconfig time
Date: Fri, 10 Mar 2017 10:38:32 -0800
Message-ID: <20170310183839.39568-7-jakub.kicinski@netronome.com>
References: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35109 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755449AbdCJSje (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 13:39:34 -0500
Received: by mail-pf0-f181.google.com with SMTP id j5so44843530pfb.2
        for <netdev@vger.kernel.org>; Fri, 10 Mar 2017 10:39:33 -0800 (PST)
In-Reply-To: <20170310183839.39568-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the mtu member from ring set to data path struct.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  4 +++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 23 +++++++++++-----------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  2 --
 3 files changed, 15 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index ab5865b955dd..84774c281b61 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -452,6 +452,7 @@ struct nfp_stat_pair {
  * @num_tx_rings:	Currently configured number of TX rings
  * @num_stack_tx_rings:	Number of TX rings used by the stack (not XDP)
  * @num_rx_rings:	Currently configured number of RX rings
+ * @mtu:		Device MTU
  */
 struct nfp_net_dp {
 	struct device *dev;
@@ -484,6 +485,8 @@ struct nfp_net_dp {
 	unsigned int num_tx_rings;
 	unsigned int num_stack_tx_rings;
 	unsigned int num_rx_rings;
+
+	unsigned int mtu;
 };
 
 /**
@@ -610,7 +613,6 @@ struct nfp_net {
 
 struct nfp_net_ring_set {
 	unsigned int n_rings;
-	unsigned int mtu;
 	unsigned int dcnt;
 	void *rings;
 };
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 92d4c2991a85..862e86cb5688 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1099,7 +1099,7 @@ static void nfp_net_tx_timeout(struct net_device *netdev)
 /* Receive processing
  */
 static unsigned int
-nfp_net_calc_fl_bufsz(struct nfp_net_dp *dp, unsigned int mtu)
+nfp_net_calc_fl_bufsz(struct nfp_net_dp *dp)
 {
 	unsigned int fl_bufsz;
 
@@ -1108,7 +1108,7 @@ nfp_net_calc_fl_bufsz(struct nfp_net_dp *dp, unsigned int mtu)
 		fl_bufsz += NFP_NET_MAX_PREPEND;
 	else
 		fl_bufsz += dp->rx_offset;
-	fl_bufsz += ETH_HLEN + VLAN_HLEN * 2 + mtu;
+	fl_bufsz += ETH_HLEN + VLAN_HLEN * 2 + dp->mtu;
 
 	fl_bufsz = SKB_DATA_ALIGN(fl_bufsz);
 	fl_bufsz += SKB_DATA_ALIGN(sizeof(struct skb_shared_info));
@@ -1935,12 +1935,13 @@ nfp_net_rx_ring_set_swap(struct nfp_net *nn, struct nfp_net_dp *dp,
 	struct nfp_net_dp new_dp = *dp;
 
 	dp->fl_bufsz = nn->dp.fl_bufsz;
-	s->mtu = nn->dp.netdev->mtu;
+	dp->mtu = nn->dp.netdev->mtu;
 	s->dcnt = nn->dp.rxd_cnt;
 	s->rings = nn->dp.rx_rings;
 	s->n_rings = nn->dp.num_rx_rings;
 
-	nn->dp.netdev->mtu = new.mtu;
+	nn->dp.mtu = new_dp.mtu;
+	nn->dp.netdev->mtu = new_dp.mtu;
 	nn->dp.fl_bufsz = new_dp.fl_bufsz;
 	nn->dp.rxd_cnt = new.dcnt;
 	nn->dp.rx_rings = new.rings;
@@ -2255,7 +2256,6 @@ static int nfp_net_netdev_open(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	struct nfp_net_ring_set rx = {
 		.n_rings = nn->dp.num_rx_rings,
-		.mtu = nn->dp.netdev->mtu,
 		.dcnt = nn->dp.rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
@@ -2466,6 +2466,8 @@ static void nfp_net_dp_swap(struct nfp_net *nn, struct nfp_net_dp *dp)
 
 	*dp = nn->dp;
 	nn->dp = new_dp;
+
+	nn->dp.netdev->mtu = new_dp.mtu;
 }
 
 static int
@@ -2554,7 +2556,6 @@ nfp_net_ring_reconfig_down(struct nfp_net *nn, struct nfp_net_dp *dp,
 {
 	nfp_net_dp_swap(nn, dp);
 
-	nn->dp.netdev->mtu = rx ? rx->mtu : nn->dp.netdev->mtu;
 	nn->dp.rxd_cnt = rx ? rx->dcnt : nn->dp.rxd_cnt;
 	nn->dp.txd_cnt = tx ? tx->dcnt : nn->dp.txd_cnt;
 	nn->dp.num_rx_rings = rx ? rx->n_rings : nn->dp.num_rx_rings;
@@ -2572,8 +2573,7 @@ nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
 {
 	int r, err;
 
-	dp->fl_bufsz = nfp_net_calc_fl_bufsz(dp,
-					     rx ? rx->mtu : nn->dp.netdev->mtu);
+	dp->fl_bufsz = nfp_net_calc_fl_bufsz(dp);
 
 	dp->num_stack_tx_rings = tx ? tx->n_rings : dp->num_tx_rings;
 	if (*xdp_prog)
@@ -2659,7 +2659,6 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	struct nfp_net *nn = netdev_priv(netdev);
 	struct nfp_net_ring_set rx = {
 		.n_rings = nn->dp.num_rx_rings,
-		.mtu = new_mtu,
 		.dcnt = nn->dp.rxd_cnt,
 	};
 	struct nfp_net_dp *dp;
@@ -2668,6 +2667,8 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 	if (!dp)
 		return -ENOMEM;
 
+	dp->mtu = new_mtu;
+
 	return nfp_net_ring_reconfig(nn, dp, &nn->dp.xdp_prog, &rx, NULL);
 }
 
@@ -2988,7 +2989,6 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 {
 	struct nfp_net_ring_set rx = {
 		.n_rings = nn->dp.num_rx_rings,
-		.mtu = nn->dp.netdev->mtu,
 		.dcnt = nn->dp.rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
@@ -3263,7 +3263,8 @@ int nfp_net_netdev_init(struct net_device *netdev)
 		netdev->mtu = nn->max_mtu;
 	else
 		netdev->mtu = NFP_NET_DEFAULT_MTU;
-	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp, netdev->mtu);
+	nn->dp.mtu = netdev->mtu;
+	nn->dp.fl_bufsz = nfp_net_calc_fl_bufsz(&nn->dp);
 
 	/* Advertise/enable offloads based on capabilities
 	 *
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 326ccd74a4bf..eccb01f3659f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -189,7 +189,6 @@ static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
 	struct nfp_net_ring_set rx = {
 		.n_rings = nn->dp.num_rx_rings,
-		.mtu = nn->dp.netdev->mtu,
 		.dcnt = rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
@@ -770,7 +769,6 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 	struct nfp_net_ring_set *reconfig_rx = NULL, *reconfig_tx = NULL;
 	struct nfp_net_ring_set rx = {
 		.n_rings = total_rx,
-		.mtu = nn->dp.netdev->mtu,
 		.dcnt = nn->dp.rxd_cnt,
 	};
 	struct nfp_net_ring_set tx = {
-- 
2.11.0

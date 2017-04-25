From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 3/4] nfp: make use of extended ack message reporting
Date: Tue, 25 Apr 2017 01:06:43 -0700
Message-ID: <20170425080644.122536-4-jakub.kicinski@netronome.com>
References: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:34644 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1176420AbdDYIIQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 04:08:16 -0400
Received: by mail-pg0-f41.google.com with SMTP id v1so13129807pgv.1
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2017 01:08:16 -0700 (PDT)
In-Reply-To: <20170425080644.122536-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Try to carry error messages to the user via the netlink extended
ack message attribute.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  3 ++-
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 22 +++++++++++++---------
 .../net/ethernet/netronome/nfp/nfp_net_ethtool.c   |  4 ++--
 3 files changed, 17 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 8f20fdef0754..48b4a2742233 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -816,7 +816,8 @@ nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 		    unsigned int n);
 
 struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
-int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new);
+int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new,
+			  struct netlink_ext_ack *extack);
 
 bool nfp_net_link_changed_read_clear(struct nfp_net *nn);
 int nfp_net_refresh_eth_port(struct nfp_net *nn);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 8a9b74305493..ff66898375cc 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2496,24 +2496,27 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn)
 	return new;
 }
 
-static int nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp)
+static int
+nfp_net_check_config(struct nfp_net *nn, struct nfp_net_dp *dp,
+		     struct netlink_ext_ack *extack)
 {
 	/* XDP-enabled tests */
 	if (!dp->xdp_prog)
 		return 0;
 	if (dp->fl_bufsz > PAGE_SIZE) {
-		nn_warn(nn, "MTU too large w/ XDP enabled\n");
+		NL_SET_ERR_MSG(extack, "MTU too large w/ XDP enabled");
 		return -EINVAL;
 	}
 	if (dp->num_tx_rings > nn->max_tx_rings) {
-		nn_warn(nn, "Insufficient number of TX rings w/ XDP enabled\n");
+		NL_SET_ERR_MSG(extack, "Insufficient number of TX rings w/ XDP enabled");
 		return -EINVAL;
 	}
 
 	return 0;
 }
 
-int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp)
+int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
+			  struct netlink_ext_ack *extack)
 {
 	int r, err;
 
@@ -2525,7 +2528,7 @@ int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp)
 
 	dp->num_r_vecs = max(dp->num_rx_rings, dp->num_stack_tx_rings);
 
-	err = nfp_net_check_config(nn, dp);
+	err = nfp_net_check_config(nn, dp, extack);
 	if (err)
 		goto exit_free_dp;
 
@@ -2600,7 +2603,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 
 	dp->mtu = new_mtu;
 
-	return nfp_net_ring_reconfig(nn, dp);
+	return nfp_net_ring_reconfig(nn, dp, NULL);
 }
 
 static void nfp_net_stat64(struct net_device *netdev,
@@ -2916,9 +2919,10 @@ static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
 	return ret;
 }
 
-static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
+static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
 {
 	struct bpf_prog *old_prog = nn->dp.xdp_prog;
+	struct bpf_prog *prog = xdp->prog;
 	struct nfp_net_dp *dp;
 	int err;
 
@@ -2945,7 +2949,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 		dp->rx_dma_off = 0;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, dp);
+	err = nfp_net_ring_reconfig(nn, dp, xdp->extack);
 	if (err)
 		return err;
 
@@ -2963,7 +2967,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
-		return nfp_net_xdp_setup(nn, xdp->prog);
+		return nfp_net_xdp_setup(nn, xdp);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!nn->dp.xdp_prog;
 		return 0;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index 6e27d1281425..4d41639b9b03 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
@@ -309,7 +309,7 @@ static int nfp_net_set_ring_size(struct nfp_net *nn, u32 rxd_cnt, u32 txd_cnt)
 	dp->rxd_cnt = rxd_cnt;
 	dp->txd_cnt = txd_cnt;
 
-	return nfp_net_ring_reconfig(nn, dp);
+	return nfp_net_ring_reconfig(nn, dp, NULL);
 }
 
 static int nfp_net_set_ringparam(struct net_device *netdev,
@@ -880,7 +880,7 @@ static int nfp_net_set_num_rings(struct nfp_net *nn, unsigned int total_rx,
 	if (dp->xdp_prog)
 		dp->num_tx_rings += total_rx;
 
-	return nfp_net_ring_reconfig(nn, dp);
+	return nfp_net_ring_reconfig(nn, dp, NULL);
 }
 
 static int nfp_net_set_channels(struct net_device *netdev,
-- 
2.11.0

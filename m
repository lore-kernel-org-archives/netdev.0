From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/4] nfp: make use of extended ack message reporting
Date: Sun, 30 Apr 2017 21:46:47 -0700
Message-ID: <20170501044648.13022-4-jakub.kicinski@netronome.com>
References: <20170501044648.13022-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, johannes@sipsolutions.net,
        dsa@cumulusnetworks.com, daniel@iogearbox.net,
        alexei.starovoitov@gmail.com, bblanco@gmail.com,
        john.fastabend@gmail.com, kubakici@wp.pl,
        oss-drivers@netronome.com, brouer@redhat.com, jhs@mojatatu.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:33126 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1951839AbdEAErR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 00:47:17 -0400
Received: by mail-pf0-f176.google.com with SMTP id q20so17390257pfg.0
        for <netdev@vger.kernel.org>; Sun, 30 Apr 2017 21:47:17 -0700 (PDT)
In-Reply-To: <20170501044648.13022-1-jakub.kicinski@netronome.com>
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
index 38b41fdeaa8f..fcf81b3be830 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -818,7 +818,8 @@ nfp_net_irqs_assign(struct nfp_net *nn, struct msix_entry *irq_entries,
 		    unsigned int n);
 
 struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn);
-int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new);
+int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *new,
+			  struct netlink_ext_ack *extack);
 
 bool nfp_net_link_changed_read_clear(struct nfp_net *nn);
 int nfp_net_refresh_eth_port(struct nfp_net *nn);
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index b9f3548bb65f..db20376260f5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2524,24 +2524,27 @@ struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn)
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
+		NL_MOD_TRY_SET_ERR_MSG(extack, "MTU too large w/ XDP enabled");
 		return -EINVAL;
 	}
 	if (dp->num_tx_rings > nn->max_tx_rings) {
-		nn_warn(nn, "Insufficient number of TX rings w/ XDP enabled\n");
+		NL_MOD_TRY_SET_ERR_MSG(extack, "Insufficient number of TX rings w/ XDP enabled");
 		return -EINVAL;
 	}
 
 	return 0;
 }
 
-int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp)
+int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp,
+			  struct netlink_ext_ack *extack)
 {
 	int r, err;
 
@@ -2553,7 +2556,7 @@ int nfp_net_ring_reconfig(struct nfp_net *nn, struct nfp_net_dp *dp)
 
 	dp->num_r_vecs = max(dp->num_rx_rings, dp->num_stack_tx_rings);
 
-	err = nfp_net_check_config(nn, dp);
+	err = nfp_net_check_config(nn, dp, extack);
 	if (err)
 		goto exit_free_dp;
 
@@ -2628,7 +2631,7 @@ static int nfp_net_change_mtu(struct net_device *netdev, int new_mtu)
 
 	dp->mtu = new_mtu;
 
-	return nfp_net_ring_reconfig(nn, dp);
+	return nfp_net_ring_reconfig(nn, dp, NULL);
 }
 
 static void nfp_net_stat64(struct net_device *netdev,
@@ -2944,9 +2947,10 @@ static int nfp_net_xdp_offload(struct nfp_net *nn, struct bpf_prog *prog)
 	return ret;
 }
 
-static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
+static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
 {
 	struct bpf_prog *old_prog = nn->dp.xdp_prog;
+	struct bpf_prog *prog = xdp->prog;
 	struct nfp_net_dp *dp;
 	int err;
 
@@ -2969,7 +2973,7 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog)
 	dp->rx_dma_off = prog ? XDP_PACKET_HEADROOM - nn->dp.rx_offset : 0;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, dp);
+	err = nfp_net_ring_reconfig(nn, dp, xdp->extack);
 	if (err)
 		return err;
 
@@ -2987,7 +2991,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
-		return nfp_net_xdp_setup(nn, xdp->prog);
+		return nfp_net_xdp_setup(nn, xdp);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!nn->dp.xdp_prog;
 		return 0;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c b/drivers/net/ethernet/netronome/nfp/nfp_net_ethtool.c
index a704efd4e314..abbb47e60cc3 100644
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

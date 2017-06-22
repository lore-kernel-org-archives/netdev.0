From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 5/8] nfp: bpf: release the reference on offloaded programs
Date: Wed, 21 Jun 2017 18:25:07 -0700
Message-ID: <20170622012510.5286-6-jakub.kicinski@netronome.com>
References: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kafai@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:36734 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752132AbdFVB0B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 21:26:01 -0400
Received: by mail-pg0-f50.google.com with SMTP id u62so1182979pgb.3
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 18:26:00 -0700 (PDT)
In-Reply-To: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xdp_prog member of the adapter's data path structure is used
for XDP in driver mode.  In case a XDP program is loaded with in
HW-only mode, we need to store it somewhere else.  Add a new XDP
prog pointer in the main structure and use that when we need to
know whether any XDP program is loaded, not only a driver mode
one.  Only release our reference on adapter free instead of
immediately after netdev unregister to allow offload to be disabled
first.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h       |  2 ++
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 34 +++++++++-------------
 2 files changed, 15 insertions(+), 21 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 7952fbfb94d6..b7446793106d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -542,6 +542,7 @@ struct nfp_net_dp {
  * @rss_key:            RSS secret key
  * @rss_itbl:           RSS indirection table
  * @xdp_flags:		Flags with which XDP prog was loaded
+ * @xdp_prog:		XDP prog (for ctrl path, both DRV and HW modes)
  * @max_r_vecs:		Number of allocated interrupt vectors for RX/TX
  * @max_tx_rings:       Maximum number of TX rings supported by the Firmware
  * @max_rx_rings:       Maximum number of RX rings supported by the Firmware
@@ -592,6 +593,7 @@ struct nfp_net {
 	u8 rss_itbl[NFP_NET_CFG_RSS_ITBL_SZ];
 
 	u32 xdp_flags;
+	struct bpf_prog *xdp_prog;
 
 	unsigned int max_tx_rings;
 	unsigned int max_rx_rings;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 9563615cf4b7..35b4530a7e02 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3278,15 +3278,10 @@ static int
 nfp_net_xdp_setup_drv(struct nfp_net *nn, struct bpf_prog *prog,
 		      struct netlink_ext_ack *extack)
 {
-	struct bpf_prog *old_prog = nn->dp.xdp_prog;
 	struct nfp_net_dp *dp;
-	int err;
 
-	if (!prog && !nn->dp.xdp_prog)
-		return 0;
-	if (prog && nn->dp.xdp_prog) {
-		prog = xchg(&nn->dp.xdp_prog, prog);
-		bpf_prog_put(prog);
+	if (!prog == !nn->dp.xdp_prog) {
+		WRITE_ONCE(nn->dp.xdp_prog, prog);
 		return 0;
 	}
 
@@ -3300,14 +3295,7 @@ nfp_net_xdp_setup_drv(struct nfp_net *nn, struct bpf_prog *prog,
 	dp->rx_dma_off = prog ? XDP_PACKET_HEADROOM - nn->dp.rx_offset : 0;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, dp, extack);
-	if (err)
-		return err;
-
-	if (old_prog)
-		bpf_prog_put(old_prog);
-
-	return 0;
+	return nfp_net_ring_reconfig(nn, dp, extack);
 }
 
 static int
@@ -3317,7 +3305,7 @@ nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 	struct bpf_prog *offload_prog;
 	int err;
 
-	if (nn->dp.xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
+	if (nn->xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
 		return -EBUSY;
 
 	offload_prog = flags & XDP_FLAGS_DRV_MODE ? NULL : prog;
@@ -3327,6 +3315,10 @@ nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 		return err;
 
 	nfp_app_xdp_offload(nn->app, nn, offload_prog);
+
+	if (nn->xdp_prog)
+		bpf_prog_put(nn->xdp_prog);
+	nn->xdp_prog = prog;
 	nn->xdp_flags = flags;
 
 	return 0;
@@ -3341,8 +3333,8 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 		return nfp_net_xdp_setup(nn, xdp->prog, xdp->flags,
 					 xdp->extack);
 	case XDP_QUERY_PROG:
-		xdp->prog_attached = !!nn->dp.xdp_prog;
-		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
+		xdp->prog_attached = !!nn->xdp_prog;
+		xdp->prog_id = nn->xdp_prog ? nn->xdp_prog->aux->id : 0;
 		return 0;
 	default:
 		return -EINVAL;
@@ -3500,6 +3492,9 @@ struct nfp_net *nfp_net_alloc(struct pci_dev *pdev, bool needs_netdev,
  */
 void nfp_net_free(struct nfp_net *nn)
 {
+	if (nn->xdp_prog)
+		bpf_prog_put(nn->xdp_prog);
+
 	if (nn->dp.netdev)
 		free_netdev(nn->dp.netdev);
 	else
@@ -3757,7 +3752,4 @@ void nfp_net_clean(struct nfp_net *nn)
 		return;
 
 	unregister_netdev(nn->dp.netdev);
-
-	if (nn->dp.xdp_prog)
-		bpf_prog_put(nn->dp.xdp_prog);
 }
-- 
2.11.0

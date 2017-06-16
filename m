From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 5/8] nfp: bpf: take a reference on offloaded programs
Date: Fri, 16 Jun 2017 16:57:43 -0700
Message-ID: <20170616235746.16337-6-jakub.kicinski@netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33481 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752158AbdFPX62 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:28 -0400
Received: by mail-pg0-f49.google.com with SMTP id f185so26350714pgc.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:28 -0700 (PDT)
In-Reply-To: <20170616235746.16337-1-jakub.kicinski@netronome.com>
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
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  2 ++
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 20 ++++++++++----------
 2 files changed, 12 insertions(+), 10 deletions(-)

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
index 9563615cf4b7..68648e312129 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3278,7 +3278,6 @@ static int
 nfp_net_xdp_setup_drv(struct nfp_net *nn, struct bpf_prog *prog,
 		      struct netlink_ext_ack *extack)
 {
-	struct bpf_prog *old_prog = nn->dp.xdp_prog;
 	struct nfp_net_dp *dp;
 	int err;
 
@@ -3304,9 +3303,6 @@ nfp_net_xdp_setup_drv(struct nfp_net *nn, struct bpf_prog *prog,
 	if (err)
 		return err;
 
-	if (old_prog)
-		bpf_prog_put(old_prog);
-
 	return 0;
 }
 
@@ -3317,7 +3313,7 @@ nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 	struct bpf_prog *offload_prog;
 	int err;
 
-	if (nn->dp.xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
+	if (nn->xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
 		return -EBUSY;
 
 	offload_prog = flags & XDP_FLAGS_DRV_MODE ? NULL : prog;
@@ -3327,6 +3323,10 @@ nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 		return err;
 
 	nfp_app_xdp_offload(nn->app, nn, offload_prog);
+
+	if (nn->xdp_prog)
+		bpf_prog_put(nn->xdp_prog);
+	nn->xdp_prog = prog;
 	nn->xdp_flags = flags;
 
 	return 0;
@@ -3341,8 +3341,8 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
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
@@ -3500,6 +3500,9 @@ struct nfp_net *nfp_net_alloc(struct pci_dev *pdev, bool needs_netdev,
  */
 void nfp_net_free(struct nfp_net *nn)
 {
+	if (nn->xdp_prog)
+		bpf_prog_put(nn->xdp_prog);
+
 	if (nn->dp.netdev)
 		free_netdev(nn->dp.netdev);
 	else
@@ -3757,7 +3760,4 @@ void nfp_net_clean(struct nfp_net *nn)
 		return;
 
 	unregister_netdev(nn->dp.netdev);
-
-	if (nn->dp.xdp_prog)
-		bpf_prog_put(nn->dp.xdp_prog);
 }
-- 
2.11.0

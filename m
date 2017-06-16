From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 3/8] nfp: xdp: move driver XDP setup into a separate function
Date: Fri, 16 Jun 2017 16:57:41 -0700
Message-ID: <20170616235746.16337-4-jakub.kicinski@netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33477 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751711AbdFPX61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:27 -0400
Received: by mail-pg0-f49.google.com with SMTP id f185so26350528pgc.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:26 -0700 (PDT)
In-Reply-To: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation of XDP offload flags move the driver setup into
a function.  Otherwise the number of conditions in one function
would make it slightly hard to follow.  The offload handler may
now be called with NULL prog, even if no offload is currently
active, but that's fine, offload code can handle that.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 23 +++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2bdddd1ae666..f2188b9c3628 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3274,10 +3274,11 @@ static void nfp_net_del_vxlan_port(struct net_device *netdev,
 		nfp_net_set_vxlan_port(nn, idx, 0);
 }
 
-static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
+static int
+nfp_net_xdp_setup_drv(struct nfp_net *nn, struct bpf_prog *prog,
+		      struct netlink_ext_ack *extack)
 {
 	struct bpf_prog *old_prog = nn->dp.xdp_prog;
-	struct bpf_prog *prog = xdp->prog;
 	struct nfp_net_dp *dp;
 	int err;
 
@@ -3286,7 +3287,6 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
 	if (prog && nn->dp.xdp_prog) {
 		prog = xchg(&nn->dp.xdp_prog, prog);
 		bpf_prog_put(prog);
-		nfp_app_xdp_offload(nn->app, nn, nn->dp.xdp_prog);
 		return 0;
 	}
 
@@ -3300,13 +3300,26 @@ static int nfp_net_xdp_setup(struct nfp_net *nn, struct netdev_xdp *xdp)
 	dp->rx_dma_off = prog ? XDP_PACKET_HEADROOM - nn->dp.rx_offset : 0;
 
 	/* We need RX reconfig to remap the buffers (BIDIR vs FROM_DEV) */
-	err = nfp_net_ring_reconfig(nn, dp, xdp->extack);
+	err = nfp_net_ring_reconfig(nn, dp, extack);
 	if (err)
 		return err;
 
 	if (old_prog)
 		bpf_prog_put(old_prog);
 
+	return 0;
+}
+
+static int
+nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog,
+		  struct netlink_ext_ack *extack)
+{
+	int err;
+
+	err = nfp_net_xdp_setup_drv(nn, prog, extack);
+	if (err)
+		return err;
+
 	nfp_app_xdp_offload(nn->app, nn, nn->dp.xdp_prog);
 
 	return 0;
@@ -3318,7 +3331,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
-		return nfp_net_xdp_setup(nn, xdp);
+		return nfp_net_xdp_setup(nn, xdp->prog, xdp->extack);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!nn->dp.xdp_prog;
 		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
-- 
2.11.0

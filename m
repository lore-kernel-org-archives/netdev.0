From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 4/8] nfp: bpf: don't offload XDP programs in DRV_MODE
Date: Fri, 16 Jun 2017 16:57:42 -0700
Message-ID: <20170616235746.16337-5-jakub.kicinski@netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33479 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752143AbdFPX61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:27 -0400
Received: by mail-pg0-f46.google.com with SMTP id f185so26350628pgc.0
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:27 -0700 (PDT)
In-Reply-To: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

DRV_MODE means that user space wants the program to be run in
the driver.  Do not try to offload.  Only offload if no mode
flags have been specified.

Remember what the mode is when the program is installed and refuse
new setup requests if there is already a program loaded in a
different mode.  This should leave it open for us to implement
simultaneous loading of two programs - one in the drv path and
another to the NIC later.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        |  3 +++
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 14 +++++++++++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 02fd8d4e253c..7952fbfb94d6 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -541,6 +541,7 @@ struct nfp_net_dp {
  * @rss_cfg:            RSS configuration
  * @rss_key:            RSS secret key
  * @rss_itbl:           RSS indirection table
+ * @xdp_flags:		Flags with which XDP prog was loaded
  * @max_r_vecs:		Number of allocated interrupt vectors for RX/TX
  * @max_tx_rings:       Maximum number of TX rings supported by the Firmware
  * @max_rx_rings:       Maximum number of RX rings supported by the Firmware
@@ -590,6 +591,8 @@ struct nfp_net {
 	u8 rss_key[NFP_NET_CFG_RSS_KEY_SZ];
 	u8 rss_itbl[NFP_NET_CFG_RSS_ITBL_SZ];
 
+	u32 xdp_flags;
+
 	unsigned int max_tx_rings;
 	unsigned int max_rx_rings;
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index f2188b9c3628..9563615cf4b7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3311,16 +3311,23 @@ nfp_net_xdp_setup_drv(struct nfp_net *nn, struct bpf_prog *prog,
 }
 
 static int
-nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog,
+nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 		  struct netlink_ext_ack *extack)
 {
+	struct bpf_prog *offload_prog;
 	int err;
 
+	if (nn->dp.xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
+		return -EBUSY;
+
+	offload_prog = flags & XDP_FLAGS_DRV_MODE ? NULL : prog;
+
 	err = nfp_net_xdp_setup_drv(nn, prog, extack);
 	if (err)
 		return err;
 
-	nfp_app_xdp_offload(nn->app, nn, nn->dp.xdp_prog);
+	nfp_app_xdp_offload(nn->app, nn, offload_prog);
+	nn->xdp_flags = flags;
 
 	return 0;
 }
@@ -3331,7 +3338,8 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
-		return nfp_net_xdp_setup(nn, xdp->prog, xdp->extack);
+		return nfp_net_xdp_setup(nn, xdp->prog, xdp->flags,
+					 xdp->extack);
 	case XDP_QUERY_PROG:
 		xdp->prog_attached = !!nn->dp.xdp_prog;
 		xdp->prog_id = nn->dp.xdp_prog ? nn->dp.xdp_prog->aux->id : 0;
-- 
2.11.0

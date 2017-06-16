From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC net-next 6/8] nfp: bpf: add support for XDP_FLAGS_HW_MODE
Date: Fri, 16 Jun 2017 16:57:44 -0700
Message-ID: <20170616235746.16337-7-jakub.kicinski@netronome.com>
References: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Cc: davem@davemloft.net, kafai@fb.com, daniel@iogearbox.net,
        netoptimizer@brouer.com, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36140 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdFPX63 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Jun 2017 19:58:29 -0400
Received: by mail-pg0-f47.google.com with SMTP id u62so7097109pgb.3
        for <netdev@vger.kernel.org>; Fri, 16 Jun 2017 16:58:29 -0700 (PDT)
In-Reply-To: <20170616235746.16337-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respect the XDP_FLAGS_HW_MODE.  When it's set install the program
on the NIC and skip enabling XDP in the driver.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 68648e312129..c5903b6e58c5 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3310,19 +3310,22 @@ static int
 nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 		  struct netlink_ext_ack *extack)
 {
-	struct bpf_prog *offload_prog;
+	struct bpf_prog *drv_prog, *offload_prog;
 	int err;
 
 	if (nn->xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
 		return -EBUSY;
 
+	drv_prog     = flags & XDP_FLAGS_HW_MODE  ? NULL : prog;
 	offload_prog = flags & XDP_FLAGS_DRV_MODE ? NULL : prog;
 
-	err = nfp_net_xdp_setup_drv(nn, prog, extack);
+	err = nfp_net_xdp_setup_drv(nn, drv_prog, extack);
 	if (err)
 		return err;
 
-	nfp_app_xdp_offload(nn->app, nn, offload_prog);
+	err = nfp_app_xdp_offload(nn->app, nn, offload_prog);
+	if (err && flags & XDP_FLAGS_HW_MODE)
+		return err;
 
 	if (nn->xdp_prog)
 		bpf_prog_put(nn->xdp_prog);
@@ -3338,6 +3341,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
+	case XDP_SETUP_PROG_HW:
 		return nfp_net_xdp_setup(nn, xdp->prog, xdp->flags,
 					 xdp->extack);
 	case XDP_QUERY_PROG:
-- 
2.11.0

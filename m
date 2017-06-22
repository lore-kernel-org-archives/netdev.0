From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 6/8] nfp: bpf: add support for XDP_FLAGS_HW_MODE
Date: Wed, 21 Jun 2017 18:25:08 -0700
Message-ID: <20170622012510.5286-7-jakub.kicinski@netronome.com>
References: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kafai@fb.com, daniel@iogearbox.net,
        davem@davemloft.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:35428 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752017AbdFVB0C (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Jun 2017 21:26:02 -0400
Received: by mail-pg0-f43.google.com with SMTP id 132so1195349pgb.2
        for <netdev@vger.kernel.org>; Wed, 21 Jun 2017 18:26:01 -0700 (PDT)
In-Reply-To: <20170622012510.5286-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Respect the XDP_FLAGS_HW_MODE.  When it's set install the program
on the NIC and skip enabling XDP in the driver.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 13 ++++++++++---
 1 file changed, 10 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 35b4530a7e02..c9fc1df1823e 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3302,19 +3302,25 @@ static int
 nfp_net_xdp_setup(struct nfp_net *nn, struct bpf_prog *prog, u32 flags,
 		  struct netlink_ext_ack *extack)
 {
-	struct bpf_prog *offload_prog;
+	struct bpf_prog *drv_prog, *offload_prog;
 	int err;
 
 	if (nn->xdp_prog && (flags ^ nn->xdp_flags) & XDP_FLAGS_MODES)
 		return -EBUSY;
 
+	/* Load both when no flags set to allow easy activation of driver path
+	 * when program is replaced by one which can't be offloaded.
+	 */
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
@@ -3330,6 +3336,7 @@ static int nfp_net_xdp(struct net_device *netdev, struct netdev_xdp *xdp)
 
 	switch (xdp->command) {
 	case XDP_SETUP_PROG:
+	case XDP_SETUP_PROG_HW:
 		return nfp_net_xdp_setup(nn, xdp->prog, xdp->flags,
 					 xdp->extack);
 	case XDP_QUERY_PROG:
-- 
2.11.0

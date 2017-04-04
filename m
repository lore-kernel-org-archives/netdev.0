From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net] nfp: fix potential use after free on xdp prog
Date: Tue,  4 Apr 2017 15:56:55 -0700
Message-ID: <20170404225655.31119-1-jakub.kicinski@netronome.com>
Cc: kubakici@wp.pl, oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:34308 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754913AbdDDW5b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 18:57:31 -0400
Received: by mail-pg0-f48.google.com with SMTP id 21so165022220pgg.1
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 15:57:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We should unregister the net_device first, before we give back
our reference on xdp_prog.  Otherwise xdp_prog may be freed
before .ndo_stop() disabled the datapath.  Found by code inspection.

Fixes: ecd63a0217d5 ("nfp: add XDP support in the driver")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
Just a heads up - this will cause a merge conflict since nn->netdev
member got moved to nn->dp.netdev in net-next.

 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 9179a99563af..a41377e26c07 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -3275,9 +3275,10 @@ void nfp_net_netdev_clean(struct net_device *netdev)
 {
 	struct nfp_net *nn = netdev_priv(netdev);
 
+	unregister_netdev(nn->netdev);
+
 	if (nn->xdp_prog)
 		bpf_prog_put(nn->xdp_prog);
 	if (nn->bpf_offload_xdp)
 		nfp_net_xdp_offload(nn, NULL);
-	unregister_netdev(nn->netdev);
 }
-- 
2.11.0

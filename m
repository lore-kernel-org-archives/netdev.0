From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 15/15] nfp: disable FW on reconfiguration errors
Date: Tue, 21 Mar 2017 17:59:21 -0700
Message-ID: <20170322005921.10965-16-jakub.kicinski@netronome.com>
References: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, kubakici@wp.pl,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35807 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756711AbdCVBH0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Mar 2017 21:07:26 -0400
Received: by mail-pg0-f48.google.com with SMTP id t143so35480006pgb.2
        for <netdev@vger.kernel.org>; Tue, 21 Mar 2017 18:07:25 -0700 (PDT)
In-Reply-To: <20170322005921.10965-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we no longer need to keep the FW enabled for .ndo_close()
to work we can always stop FW after reconfiguration failure.
This seems to make most FWs more resilient to faults (at least
in error injection scenarios).

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    | 29 ++++++++--------------
 1 file changed, 11 insertions(+), 18 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index e12353a7c83c..8f2da128ce0f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -2127,7 +2127,11 @@ nfp_net_tx_ring_hw_cfg_write(struct nfp_net *nn,
 	nn_writeb(nn, NFP_NET_CFG_TXR_VEC(idx), tx_ring->r_vec->irq_entry);
 }
 
-static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
+/**
+ * nfp_net_set_config_and_enable() - Write control BAR and enable NFP
+ * @nn:      NFP Net device to reconfigure
+ */
+static int nfp_net_set_config_and_enable(struct nfp_net *nn)
 {
 	u32 new_ctrl, update = 0;
 	unsigned int r;
@@ -2176,6 +2180,10 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 
 	nn_writel(nn, NFP_NET_CFG_CTRL, new_ctrl);
 	err = nfp_net_reconfig(nn, update);
+	if (err) {
+		nfp_net_clear_config_and_disable(nn);
+		return err;
+	}
 
 	nn->dp.ctrl = new_ctrl;
 
@@ -2191,22 +2199,7 @@ static int __nfp_net_set_config_and_enable(struct nfp_net *nn)
 		udp_tunnel_get_rx_info(nn->dp.netdev);
 	}
 
-	return err;
-}
-
-/**
- * nfp_net_set_config_and_enable() - Write control BAR and enable NFP
- * @nn:      NFP Net device to reconfigure
- */
-static int nfp_net_set_config_and_enable(struct nfp_net *nn)
-{
-	int err;
-
-	err = __nfp_net_set_config_and_enable(nn);
-	if (err)
-		nfp_net_clear_config_and_disable(nn);
-
-	return err;
+	return 0;
 }
 
 /**
@@ -2447,7 +2440,7 @@ static int nfp_net_dp_swap_enable(struct nfp_net *nn, struct nfp_net_dp *dp)
 			return err;
 	}
 
-	return __nfp_net_set_config_and_enable(nn);
+	return nfp_net_set_config_and_enable(nn);
 }
 
 struct nfp_net_dp *nfp_net_clone_dp(struct nfp_net *nn)
-- 
2.11.0

From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [PATCH net] nfp: double free on error in probe
Date: Tue, 29 Aug 2017 22:15:16 +0300
Message-ID: <20170829190855.fabfktv2dg57x3gs@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Simon Horman <simon.horman@netronome.com>,
        oss-drivers@netronome.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:45166 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751215AbdH2TQL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 15:16:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Both the nfp_net_pf_app_start() and the nfp_net_pci_probe() functions
call nfp_net_pf_app_stop_ctrl(pf) so there is a double free.  The free
should be done from the probe function because it's allocated there so
I have removed the call from nfp_net_pf_app_start().

Fixes: 02082701b974 ("nfp: create control vNICs and wire up rx/tx")
Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index d55f6c5ed1be..7c22cc4654b7 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -458,7 +458,7 @@ static int nfp_net_pf_app_start(struct nfp_pf *pf)
 
 	err = nfp_app_start(pf->app, pf->ctrl_vnic);
 	if (err)
-		goto err_ctrl_stop;
+		return err;
 
 	if (pf->num_vfs) {
 		err = nfp_app_sriov_enable(pf->app, pf->num_vfs);
@@ -470,8 +470,6 @@ static int nfp_net_pf_app_start(struct nfp_pf *pf)
 
 err_app_stop:
 	nfp_app_stop(pf->app);
-err_ctrl_stop:
-	nfp_net_pf_app_stop_ctrl(pf);
 	return err;
 }
 

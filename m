From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/6] nfp: move the start/stop app callbacks back
Date: Sat,  2 Sep 2017 18:26:02 -0700
Message-ID: <20170903012605.7435-4-jakub.kicinski@netronome.com>
References: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:32884 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752959AbdICB0Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 2 Sep 2017 21:26:16 -0400
Received: by mail-pf0-f169.google.com with SMTP id n73so9572532pfj.0
        for <netdev@vger.kernel.org>; Sat, 02 Sep 2017 18:26:16 -0700 (PDT)
In-Reply-To: <20170903012605.7435-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since representors are now created with a separate callback
start/stop app callbacks can be moved again to their original
location.  They are intended to app-specific init/clean up
over the control channel.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 26 ++++++++++-------------
 1 file changed, 11 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index f2a1a4e2ce8b..5abb9ba31e7d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -469,10 +469,14 @@ static int nfp_net_pf_app_start(struct nfp_pf *pf)
 {
 	int err;
 
-	err = nfp_app_start(pf->app, pf->ctrl_vnic);
+	err = nfp_net_pf_app_start_ctrl(pf);
 	if (err)
 		return err;
 
+	err = nfp_app_start(pf->app, pf->ctrl_vnic);
+	if (err)
+		goto err_ctrl_stop;
+
 	if (pf->num_vfs) {
 		err = nfp_app_sriov_enable(pf->app, pf->num_vfs);
 		if (err)
@@ -483,6 +487,8 @@ static int nfp_net_pf_app_start(struct nfp_pf *pf)
 
 err_app_stop:
 	nfp_app_stop(pf->app);
+err_ctrl_stop:
+	nfp_net_pf_app_stop_ctrl(pf);
 	return err;
 }
 
@@ -491,6 +497,7 @@ static void nfp_net_pf_app_stop(struct nfp_pf *pf)
 	if (pf->num_vfs)
 		nfp_app_sriov_disable(pf->app);
 	nfp_app_stop(pf->app);
+	nfp_net_pf_app_stop_ctrl(pf);
 }
 
 static void nfp_net_pci_unmap_mem(struct nfp_pf *pf)
@@ -582,7 +589,7 @@ static int nfp_net_pci_map_mem(struct nfp_pf *pf)
 
 static void nfp_net_pci_remove_finish(struct nfp_pf *pf)
 {
-	nfp_net_pf_app_stop_ctrl(pf);
+	nfp_net_pf_app_stop(pf);
 	/* stop app first, to avoid double free of ctrl vNIC's ddir */
 	nfp_net_debugfs_dir_clean(&pf->ddir);
 
@@ -713,7 +720,6 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 {
 	struct nfp_net_fw_version fw_ver;
 	u8 __iomem *ctrl_bar, *qc_bar;
-	struct nfp_net *nn;
 	int stride;
 	int err;
 
@@ -790,7 +796,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	if (err)
 		goto err_free_vnics;
 
-	err = nfp_net_pf_app_start_ctrl(pf);
+	err = nfp_net_pf_app_start(pf);
 	if (err)
 		goto err_free_irqs;
 
@@ -798,20 +804,12 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	if (err)
 		goto err_stop_app;
 
-	err = nfp_net_pf_app_start(pf);
-	if (err)
-		goto err_clean_vnics;
-
 	mutex_unlock(&pf->lock);
 
 	return 0;
 
-err_clean_vnics:
-	list_for_each_entry(nn, &pf->vnics, vnic_list)
-		if (nfp_net_is_data_vnic(nn))
-			nfp_net_pf_clean_vnic(pf, nn);
 err_stop_app:
-	nfp_net_pf_app_stop_ctrl(pf);
+	nfp_net_pf_app_stop(pf);
 err_free_irqs:
 	nfp_net_pf_free_irqs(pf);
 err_free_vnics:
@@ -835,8 +833,6 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 	if (list_empty(&pf->vnics))
 		goto out;
 
-	nfp_net_pf_app_stop(pf);
-
 	list_for_each_entry(nn, &pf->vnics, vnic_list)
 		if (nfp_net_is_data_vnic(nn))
 			nfp_net_pf_clean_vnic(pf, nn);
-- 
2.14.1

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net 2/3] nfp: make sure representors are destroyed before their lower netdev
Date: Tue, 22 Aug 2017 23:22:43 -0700
Message-ID: <20170823062244.26580-3-jakub.kicinski@netronome.com>
References: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:32862 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751988AbdHWGWw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 02:22:52 -0400
Received: by mail-pg0-f44.google.com with SMTP id t3so3900087pgt.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 23:22:52 -0700 (PDT)
In-Reply-To: <20170823062244.26580-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

App start/stop callbacks can perform application initialization.
Unfortunately, flower app started using them for creating and
destroying representors.  This can lead to a situation where
lower vNIC netdev is destroyed while representors still try
to pass traffic.  This will most likely lead to a NULL-dereference
on the lower netdev TX path.

Move the start/stop callbacks, so that representors are created/
destroyed when vNICs are fully initialized.

Fixes: 5de73ee46704 ("nfp: general representor implementation")
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 22 ++++++++++++++--------
 1 file changed, 14 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 5797dbf2b507..1aca4e57bf41 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -456,10 +456,6 @@ static int nfp_net_pf_app_start(struct nfp_pf *pf)
 {
 	int err;
 
-	err = nfp_net_pf_app_start_ctrl(pf);
-	if (err)
-		return err;
-
 	err = nfp_app_start(pf->app, pf->ctrl_vnic);
 	if (err)
 		goto err_ctrl_stop;
@@ -484,7 +480,6 @@ static void nfp_net_pf_app_stop(struct nfp_pf *pf)
 	if (pf->num_vfs)
 		nfp_app_sriov_disable(pf->app);
 	nfp_app_stop(pf->app);
-	nfp_net_pf_app_stop_ctrl(pf);
 }
 
 static void nfp_net_pci_unmap_mem(struct nfp_pf *pf)
@@ -559,7 +554,7 @@ static int nfp_net_pci_map_mem(struct nfp_pf *pf)
 
 static void nfp_net_pci_remove_finish(struct nfp_pf *pf)
 {
-	nfp_net_pf_app_stop(pf);
+	nfp_net_pf_app_stop_ctrl(pf);
 	/* stop app first, to avoid double free of ctrl vNIC's ddir */
 	nfp_net_debugfs_dir_clean(&pf->ddir);
 
@@ -690,6 +685,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 {
 	struct nfp_net_fw_version fw_ver;
 	u8 __iomem *ctrl_bar, *qc_bar;
+	struct nfp_net *nn;
 	int stride;
 	int err;
 
@@ -766,7 +762,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	if (err)
 		goto err_free_vnics;
 
-	err = nfp_net_pf_app_start(pf);
+	err = nfp_net_pf_app_start_ctrl(pf);
 	if (err)
 		goto err_free_irqs;
 
@@ -774,12 +770,20 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 	if (err)
 		goto err_stop_app;
 
+	err = nfp_net_pf_app_start(pf);
+	if (err)
+		goto err_clean_vnics;
+
 	mutex_unlock(&pf->lock);
 
 	return 0;
 
+err_clean_vnics:
+	list_for_each_entry(nn, &pf->vnics, vnic_list)
+		if (nfp_net_is_data_vnic(nn))
+			nfp_net_pf_clean_vnic(pf, nn);
 err_stop_app:
-	nfp_net_pf_app_stop(pf);
+	nfp_net_pf_app_stop_ctrl(pf);
 err_free_irqs:
 	nfp_net_pf_free_irqs(pf);
 err_free_vnics:
@@ -803,6 +807,8 @@ void nfp_net_pci_remove(struct nfp_pf *pf)
 	if (list_empty(&pf->vnics))
 		goto out;
 
+	nfp_net_pf_app_stop(pf);
+
 	list_for_each_entry(nn, &pf->vnics, vnic_list)
 		if (nfp_net_is_data_vnic(nn))
 			nfp_net_pf_clean_vnic(pf, nn);
-- 
2.11.0

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 12/16] nfp: don't clutter init code passing fw_ver around
Date: Mon,  5 Jun 2017 17:01:53 -0700
Message-ID: <20170606000157.17556-13-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33300 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdFFAC0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:26 -0400
Received: by mail-pf0-f181.google.com with SMTP id 83so32352692pfr.0
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:26 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reading fw version from the BAR is trivial.  Don't pass it around
through layers of init functions, simply read it again where needed.

This commit has the side effect of each vNIC having the exact NFD
version from its own control memory, rather than all data vNICs
assuming the version of the first one.  This should not result in
user-visible changes, though.  Capabilities of data vNICs of trival
apps are identical.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 2a3b6deae607..82172665e023 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -277,8 +277,7 @@ static void nfp_net_pf_free_vnics(struct nfp_pf *pf)
 static struct nfp_net *
 nfp_net_pf_alloc_vnic(struct nfp_pf *pf, bool needs_netdev,
 		      void __iomem *ctrl_bar, void __iomem *qc_bar,
-		      int stride, struct nfp_net_fw_version *fw_ver,
-		      unsigned int eth_id)
+		      int stride, unsigned int eth_id)
 {
 	u32 tx_base, rx_base, n_tx_rings, n_rx_rings;
 	struct nfp_net *nn;
@@ -295,7 +294,7 @@ nfp_net_pf_alloc_vnic(struct nfp_pf *pf, bool needs_netdev,
 		return nn;
 
 	nn->app = pf->app;
-	nn->fw_ver = *fw_ver;
+	nfp_net_get_fw_version(&nn->fw_ver, ctrl_bar);
 	nn->dp.ctrl_bar = ctrl_bar;
 	nn->tx_bar = qc_bar + tx_base * NFP_QCP_QUEUE_ADDR_SZ;
 	nn->rx_bar = qc_bar + rx_base * NFP_QCP_QUEUE_ADDR_SZ;
@@ -350,8 +349,7 @@ nfp_net_pf_init_vnic(struct nfp_pf *pf, struct nfp_net *nn, unsigned int id)
 
 static int
 nfp_net_pf_alloc_vnics(struct nfp_pf *pf, void __iomem *ctrl_bar,
-		       void __iomem *qc_bar, int stride,
-		       struct nfp_net_fw_version *fw_ver)
+		       void __iomem *qc_bar, int stride)
 {
 	struct nfp_net *nn;
 	unsigned int i;
@@ -359,7 +357,7 @@ nfp_net_pf_alloc_vnics(struct nfp_pf *pf, void __iomem *ctrl_bar,
 
 	for (i = 0; i < pf->max_data_vnics; i++) {
 		nn = nfp_net_pf_alloc_vnic(pf, true, ctrl_bar, qc_bar,
-					   stride, fw_ver, i);
+					   stride, i);
 		if (IS_ERR(nn)) {
 			err = PTR_ERR(nn);
 			goto err_free_prev;
@@ -395,15 +393,14 @@ static void nfp_net_pf_clean_vnic(struct nfp_pf *pf, struct nfp_net *nn)
 
 static int
 nfp_net_pf_spawn_vnics(struct nfp_pf *pf,
-		       void __iomem *ctrl_bar, void __iomem *qc_bar, int stride,
-		       struct nfp_net_fw_version *fw_ver)
+		       void __iomem *ctrl_bar, void __iomem *qc_bar, int stride)
 {
 	unsigned int id, wanted_irqs, num_irqs, vnics_left, irqs_left;
 	struct nfp_net *nn;
 	int err;
 
 	/* Allocate the vnics and do basic init */
-	err = nfp_net_pf_alloc_vnics(pf, ctrl_bar, qc_bar, stride, fw_ver);
+	err = nfp_net_pf_alloc_vnics(pf, ctrl_bar, qc_bar, stride);
 	if (err)
 		return err;
 
@@ -694,7 +691,7 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 
 	pf->ddir = nfp_net_debugfs_device_add(pf->pdev);
 
-	err = nfp_net_pf_spawn_vnics(pf, ctrl_bar, qc_bar, stride, &fw_ver);
+	err = nfp_net_pf_spawn_vnics(pf, ctrl_bar, qc_bar, stride);
 	if (err)
 		goto err_clean_ddir;
 
-- 
2.11.0

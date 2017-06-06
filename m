From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 10/16] nfp: make vNIC ctrl memory mapping function reusable
Date: Mon,  5 Jun 2017 17:01:51 -0700
Message-ID: <20170606000157.17556-11-jakub.kicinski@netronome.com>
References: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34257 "EHLO
        mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751314AbdFFACe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 5 Jun 2017 20:02:34 -0400
Received: by mail-pf0-f180.google.com with SMTP id 9so89898874pfj.1
        for <netdev@vger.kernel.org>; Mon, 05 Jun 2017 17:02:29 -0700 (PDT)
In-Reply-To: <20170606000157.17556-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will soon need to map control vNIC PCI memory as well as data vNIC
memory.  Make the function for mapping areas pointed to by an RTsym
reusable.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 55 ++++++++++++-----------
 1 file changed, 28 insertions(+), 27 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index dd2a99fca716..3644b12d93db 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -248,40 +248,37 @@ nfp_net_pf_total_qcs(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	return max_qc - min_qc;
 }
 
-static u8 __iomem *nfp_net_pf_map_ctrl_bar(struct nfp_pf *pf)
+static u8 __iomem *
+nfp_net_pf_map_rtsym(struct nfp_pf *pf, const char *name, const char *sym_fmt,
+		     unsigned int min_size, struct nfp_cpp_area **area)
 {
-	const struct nfp_rtsym *ctrl_sym;
-	u8 __iomem *ctrl_bar;
+	const struct nfp_rtsym *sym;
 	char pf_symbol[256];
+	u8 __iomem *mem;
 
-	snprintf(pf_symbol, sizeof(pf_symbol), "_pf%u_net_bar0",
+	snprintf(pf_symbol, sizeof(pf_symbol), sym_fmt,
 		 nfp_cppcore_pcie_unit(pf->cpp));
 
-	ctrl_sym = nfp_rtsym_lookup(pf->cpp, pf_symbol);
-	if (!ctrl_sym) {
-		dev_err(&pf->pdev->dev,
-			"Failed to find PF BAR0 symbol %s\n", pf_symbol);
-		return NULL;
+	sym = nfp_rtsym_lookup(pf->cpp, pf_symbol);
+	if (!sym) {
+		nfp_err(pf->cpp, "Failed to find PF symbol %s\n", pf_symbol);
+		return (u8 __iomem *)ERR_PTR(-ENOENT);
 	}
 
-	if (ctrl_sym->size < pf->max_data_vnics * NFP_PF_CSR_SLICE_SIZE) {
-		dev_err(&pf->pdev->dev,
-			"PF BAR0 too small to contain %d vNICs\n",
-			pf->max_data_vnics);
-		return NULL;
+	if (sym->size < min_size) {
+		nfp_err(pf->cpp, "PF symbol %s too small\n", pf_symbol);
+		return (u8 __iomem *)ERR_PTR(-EINVAL);
 	}
 
-	ctrl_bar = nfp_net_map_area(pf->cpp, "net.ctrl",
-				    ctrl_sym->domain, ctrl_sym->target,
-				    ctrl_sym->addr, ctrl_sym->size,
-				    &pf->data_vnic_bar);
-	if (IS_ERR(ctrl_bar)) {
-		dev_err(&pf->pdev->dev, "Failed to map PF BAR0: %ld\n",
-			PTR_ERR(ctrl_bar));
-		return NULL;
+	mem = nfp_net_map_area(pf->cpp, name, sym->domain, sym->target,
+			       sym->addr, sym->size, area);
+	if (IS_ERR(mem)) {
+		nfp_err(pf->cpp, "Failed to map PF symbol %s: %ld\n",
+			pf_symbol, PTR_ERR(mem));
+		return mem;
 	}
 
-	return ctrl_bar;
+	return mem;
 }
 
 static void nfp_net_pf_free_vnic(struct nfp_pf *pf, struct nfp_net *nn)
@@ -662,10 +659,10 @@ int nfp_net_refresh_eth_port(struct nfp_port *port)
  */
 int nfp_net_pci_probe(struct nfp_pf *pf)
 {
+	u32 ctrl_bar_sz, tx_area_sz, rx_area_sz;
 	u8 __iomem *ctrl_bar, *tx_bar, *rx_bar;
 	u32 total_tx_qcs, total_rx_qcs;
 	struct nfp_net_fw_version fw_ver;
-	u32 tx_area_sz, rx_area_sz;
 	u32 start_q;
 	int stride;
 	int err;
@@ -685,9 +682,13 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 		goto err_unlock;
 	}
 
-	ctrl_bar = nfp_net_pf_map_ctrl_bar(pf);
-	if (!ctrl_bar) {
-		err = pf->fw_loaded ? -EINVAL : -EPROBE_DEFER;
+	ctrl_bar_sz = pf->max_data_vnics * NFP_PF_CSR_SLICE_SIZE;
+	ctrl_bar = nfp_net_pf_map_rtsym(pf, "net.ctrl", "_pf%d_net_bar0",
+					ctrl_bar_sz, &pf->data_vnic_bar);
+	if (IS_ERR(ctrl_bar)) {
+		err = PTR_ERR(ctrl_bar);
+		if (!pf->fw_loaded && err == -ENOENT)
+			err = -EPROBE_DEFER;
 		goto err_unlock;
 	}
 
-- 
2.11.0

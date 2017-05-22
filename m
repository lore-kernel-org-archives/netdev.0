From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 06/13] nfp: disallow mixing vNICs with and without NSP port entry
Date: Mon, 22 May 2017 10:59:27 -0700
Message-ID: <20170522175934.27447-7-jakub.kicinski@netronome.com>
References: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:36443 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760915AbdEVSBI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 22 May 2017 14:01:08 -0400
Received: by mail-pf0-f172.google.com with SMTP id m17so89350199pfg.3
        for <netdev@vger.kernel.org>; Mon, 22 May 2017 11:01:08 -0700 (PDT)
In-Reply-To: <20170522175934.27447-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only support core NIC apps which have vNICs for each physical port/
split and no representors right now.  Enforce that either each vNIC has
a NSP eth_table entry or if NSP port table is not available none do.

One scenario this will prevent from happening is user force-loading
wrong firmware file if FW app requires different firmwares per media
config.

While at it move some code to nfp_net_pf_alloc_vnic() to make it
counter-match nfp_net_pf_free_vnic() better.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 52 ++++++++++++++---------
 1 file changed, 32 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 1281e9019e92..8f267b1534e2 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -289,7 +289,7 @@ static struct nfp_net *
 nfp_net_pf_alloc_vnic(struct nfp_pf *pf, void __iomem *ctrl_bar,
 		      void __iomem *tx_bar, void __iomem *rx_bar,
 		      int stride, struct nfp_net_fw_version *fw_ver,
-		      struct nfp_eth_table_port *eth_port)
+		      unsigned int eth_id)
 {
 	u32 n_tx_rings, n_rx_rings;
 	struct nfp_net *nn;
@@ -310,7 +310,10 @@ nfp_net_pf_alloc_vnic(struct nfp_pf *pf, void __iomem *ctrl_bar,
 	nn->dp.is_vf = 0;
 	nn->stride_rx = stride;
 	nn->stride_tx = stride;
-	nn->eth_port = eth_port;
+	nn->eth_port = nfp_net_find_port(pf->eth_tbl, eth_id);
+
+	pf->num_vnics++;
+	list_add_tail(&nn->vnic_list, &pf->vnics);
 
 	return nn;
 }
@@ -346,11 +349,16 @@ nfp_net_pf_alloc_vnics(struct nfp_pf *pf, void __iomem *ctrl_bar,
 		       int stride, struct nfp_net_fw_version *fw_ver)
 {
 	u32 prev_tx_base, prev_rx_base, tgt_tx_base, tgt_rx_base;
-	struct nfp_eth_table_port *eth_port;
 	struct nfp_net *nn;
 	unsigned int i;
 	int err;
 
+	if (pf->eth_tbl && pf->max_data_vnics != pf->eth_tbl->count) {
+		nfp_err(pf->cpp, "ETH entries don't match vNICs (%d vs %d)\n",
+			pf->max_data_vnics, pf->eth_tbl->count);
+		return -EINVAL;
+	}
+
 	prev_tx_base = readl(ctrl_bar + NFP_NET_CFG_START_TXQ);
 	prev_rx_base = readl(ctrl_bar + NFP_NET_CFG_START_RXQ);
 
@@ -362,21 +370,26 @@ nfp_net_pf_alloc_vnics(struct nfp_pf *pf, void __iomem *ctrl_bar,
 		prev_tx_base = tgt_tx_base;
 		prev_rx_base = tgt_rx_base;
 
-		eth_port = nfp_net_find_port(pf->eth_tbl, i);
-		if (eth_port && eth_port->override_changed) {
-			nfp_warn(pf->cpp, "Config changed for port #%d, reboot required before port will be operational\n", i);
-		} else {
-			nn = nfp_net_pf_alloc_vnic(pf, ctrl_bar, tx_bar, rx_bar,
-						   stride, fw_ver, eth_port);
-			if (IS_ERR(nn)) {
-				err = PTR_ERR(nn);
-				goto err_free_prev;
-			}
-			list_add_tail(&nn->vnic_list, &pf->vnics);
-			pf->num_vnics++;
+		nn = nfp_net_pf_alloc_vnic(pf, ctrl_bar, tx_bar, rx_bar,
+					   stride, fw_ver, i);
+		if (IS_ERR(nn)) {
+			err = PTR_ERR(nn);
+			goto err_free_prev;
 		}
 
 		ctrl_bar += NFP_PF_CSR_SLICE_SIZE;
+
+		/* Check if vNIC has external port associated and cfg is OK */
+		if (pf->eth_tbl && !nn->eth_port) {
+			nfp_err(pf->cpp, "NSP port entries don't match vNICs (no entry for port #%d)\n", i);
+			err = -EINVAL;
+			goto err_free_prev;
+		}
+		if (nn->eth_port && nn->eth_port->override_changed) {
+			nfp_warn(pf->cpp, "Config changed for port #%d, reboot required before port will be operational\n", i);
+			nfp_net_pf_free_vnic(pf, nn);
+			continue;
+		}
 	}
 
 	if (list_empty(&pf->vnics))
@@ -517,6 +530,9 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 			continue;
 		nn->eth_port = nfp_net_find_port(eth_table,
 						 nn->eth_port->eth_index);
+		if (!nn->eth_port)
+			nfp_err(pf->cpp,
+				"Warning: port disappeared after reconfig\n");
 	}
 	rtnl_unlock();
 
@@ -524,11 +540,7 @@ static void nfp_net_refresh_vnics(struct work_struct *work)
 	pf->eth_tbl = eth_table;
 
 	list_for_each_entry_safe(nn, next, &pf->vnics, vnic_list) {
-		if (!nn->eth_port) {
-			nfp_warn(pf->cpp, "Warning: port not present after reconfig\n");
-			continue;
-		}
-		if (!nn->eth_port->override_changed)
+		if (nn->eth_port && !nn->eth_port->override_changed)
 			continue;
 
 		nn_warn(nn, "Port config changed, unregistering. Reboot required before port will be operational again.\n");
-- 
2.11.0

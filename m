From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/9] nfp: turn reading PCIe RTsym parameters into a helper
Date: Wed, 31 May 2017 08:06:45 -0700
Message-ID: <20170531150651.16873-4-jakub.kicinski@netronome.com>
References: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:34484 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751187AbdEaPLu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 11:11:50 -0400
Received: by mail-pg0-f49.google.com with SMTP id u28so9280384pgn.1
        for <netdev@vger.kernel.org>; Wed, 31 May 2017 08:11:49 -0700 (PDT)
In-Reply-To: <20170531150651.16873-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Turn the function to read number of ports into a generic helper.
While at it make sure we propagate all errors other than -ENOENT.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c | 24 ++++++++++++++++-------
 1 file changed, 17 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 388759e047d8..55a4a334cf6b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -191,26 +191,32 @@ nfp_net_find_port(struct nfp_eth_table *eth_tbl, unsigned int id)
 	return NULL;
 }
 
-static unsigned int nfp_net_pf_get_num_ports(struct nfp_pf *pf)
+static int
+nfp_net_pf_rtsym_read_optional(struct nfp_pf *pf, const char *format,
+			       unsigned int default_val)
 {
 	char name[256];
 	int err = 0;
 	u64 val;
 
-	snprintf(name, sizeof(name), "nfd_cfg_pf%u_num_ports",
-		 nfp_cppcore_pcie_unit(pf->cpp));
+	snprintf(name, sizeof(name), format, nfp_cppcore_pcie_unit(pf->cpp));
 
 	val = nfp_rtsym_read_le(pf->cpp, name, &err);
-	/* Default to one port/vNIC */
 	if (err) {
-		if (err != -ENOENT)
-			nfp_err(pf->cpp, "Unable to read adapter vNIC count\n");
-		val = 1;
+		if (err == -ENOENT)
+			return default_val;
+		nfp_err(pf->cpp, "Unable to read symbol %s\n", name);
+		return err;
 	}
 
 	return val;
 }
 
+static int nfp_net_pf_get_num_ports(struct nfp_pf *pf)
+{
+	return nfp_net_pf_rtsym_read_optional(pf, "nfd_cfg_pf%u_num_ports", 1);
+}
+
 static unsigned int
 nfp_net_pf_total_qcs(struct nfp_pf *pf, void __iomem *ctrl_bar,
 		     unsigned int stride, u32 start_off, u32 num_off)
@@ -675,6 +681,10 @@ int nfp_net_pci_probe(struct nfp_pf *pf)
 
 	mutex_lock(&pf->lock);
 	pf->max_data_vnics = nfp_net_pf_get_num_ports(pf);
+	if ((int)pf->max_data_vnics < 0) {
+		err = pf->max_data_vnics;
+		goto err_unlock;
+	}
 
 	ctrl_bar = nfp_net_pf_map_ctrl_bar(pf);
 	if (!ctrl_bar) {
-- 
2.11.0

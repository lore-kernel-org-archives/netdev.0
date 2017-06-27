From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 03/14] nfp: add helper for mapping runtime symbols
Date: Tue, 27 Jun 2017 00:50:17 -0700
Message-ID: <20170627075028.4009-4-jakub.kicinski@netronome.com>
References: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f42.google.com ([74.125.83.42]:33469 "EHLO
        mail-pg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752364AbdF0HvJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 03:51:09 -0400
Received: by mail-pg0-f42.google.com with SMTP id f127so12011505pgc.0
        for <netdev@vger.kernel.org>; Tue, 27 Jun 2017 00:51:09 -0700 (PDT)
In-Reply-To: <20170627075028.4009-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move most of the helper for mapping RTsyms from nfp_net_main.c
to nfpcore.  Use the new helper directly for mapping MAC statistics,
since they don't need to include the PCIe interface ID in the symbol
name.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net_main.c  | 36 +++++-----------------
 .../net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h  |  4 +++
 .../net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c | 27 ++++++++++++++++
 3 files changed, 39 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
index 16ee904db0cd..93d6ea183956 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_main.c
@@ -174,31 +174,12 @@ static u8 __iomem *
 nfp_net_pf_map_rtsym(struct nfp_pf *pf, const char *name, const char *sym_fmt,
 		     unsigned int min_size, struct nfp_cpp_area **area)
 {
-	const struct nfp_rtsym *sym;
 	char pf_symbol[256];
-	u8 __iomem *mem;
 
 	snprintf(pf_symbol, sizeof(pf_symbol), sym_fmt,
 		 nfp_cppcore_pcie_unit(pf->cpp));
 
-	sym = nfp_rtsym_lookup(pf->rtbl, pf_symbol);
-	if (!sym)
-		return (u8 __iomem *)ERR_PTR(-ENOENT);
-
-	if (sym->size < min_size) {
-		nfp_err(pf->cpp, "PF symbol %s too small\n", pf_symbol);
-		return (u8 __iomem *)ERR_PTR(-EINVAL);
-	}
-
-	mem = nfp_cpp_map_area(pf->cpp, name, sym->domain, sym->target,
-			       sym->addr, sym->size, area);
-	if (IS_ERR(mem)) {
-		nfp_err(pf->cpp, "Failed to map PF symbol %s: %ld\n",
-			pf_symbol, PTR_ERR(mem));
-		return mem;
-	}
-
-	return mem;
+	return nfp_rtsym_map(pf->rtbl, pf_symbol, name, min_size, area);
 }
 
 static void nfp_net_pf_free_vnic(struct nfp_pf *pf, struct nfp_net *nn)
@@ -528,23 +509,22 @@ static void nfp_net_pci_unmap_mem(struct nfp_pf *pf)
 
 static int nfp_net_pci_map_mem(struct nfp_pf *pf)
 {
-	u32 ctrl_bar_sz;
 	u8 __iomem *mem;
+	u32 min_size;
 	int err;
 
-	ctrl_bar_sz = pf->max_data_vnics * NFP_PF_CSR_SLICE_SIZE;
+	min_size = pf->max_data_vnics * NFP_PF_CSR_SLICE_SIZE;
 	mem = nfp_net_pf_map_rtsym(pf, "net.ctrl", "_pf%d_net_bar0",
-				   ctrl_bar_sz, &pf->data_vnic_bar);
+				   min_size, &pf->data_vnic_bar);
 	if (IS_ERR(mem)) {
 		nfp_err(pf->cpp, "Failed to find data vNIC memory symbol\n");
 		return PTR_ERR(mem);
 	}
 
-	pf->mac_stats_mem = nfp_net_pf_map_rtsym(pf, "net.macstats",
-						 "_mac_stats",
-						 NFP_MAC_STATS_SIZE *
-						 (pf->eth_tbl->max_index + 1),
-						 &pf->mac_stats_bar);
+	min_size =  NFP_MAC_STATS_SIZE * (pf->eth_tbl->max_index + 1);
+	pf->mac_stats_mem = nfp_rtsym_map(pf->rtbl, "_mac_stats",
+					  "net.macstats", min_size,
+					  &pf->mac_stats_bar);
 	if (IS_ERR(pf->mac_stats_mem)) {
 		if (PTR_ERR(pf->mac_stats_mem) != -ENOENT) {
 			err = PTR_ERR(pf->mac_stats_mem);
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
index d27d29782a12..c9724fb7ea4b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
@@ -97,7 +97,11 @@ int nfp_rtsym_count(struct nfp_rtsym_table *rtbl);
 const struct nfp_rtsym *nfp_rtsym_get(struct nfp_rtsym_table *rtbl, int idx);
 const struct nfp_rtsym *
 nfp_rtsym_lookup(struct nfp_rtsym_table *rtbl, const char *name);
+
 u64 nfp_rtsym_read_le(struct nfp_rtsym_table *rtbl, const char *name,
 		      int *error);
+u8 __iomem *
+nfp_rtsym_map(struct nfp_rtsym_table *rtbl, const char *name, const char *id,
+	      unsigned int min_size, struct nfp_cpp_area **area);
 
 #endif /* NFP_NFFW_H */
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
index 203f9cbae0fb..ecda474ac7c3 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
@@ -289,3 +289,30 @@ u64 nfp_rtsym_read_le(struct nfp_rtsym_table *rtbl, const char *name,
 		return ~0ULL;
 	return val;
 }
+
+u8 __iomem *
+nfp_rtsym_map(struct nfp_rtsym_table *rtbl, const char *name, const char *id,
+	      unsigned int min_size, struct nfp_cpp_area **area)
+{
+	const struct nfp_rtsym *sym;
+	u8 __iomem *mem;
+
+	sym = nfp_rtsym_lookup(rtbl, name);
+	if (!sym)
+		return (u8 __iomem *)ERR_PTR(-ENOENT);
+
+	if (sym->size < min_size) {
+		nfp_err(rtbl->cpp, "Symbol %s too small\n", name);
+		return (u8 __iomem *)ERR_PTR(-EINVAL);
+	}
+
+	mem = nfp_cpp_map_area(rtbl->cpp, id, sym->domain, sym->target,
+			       sym->addr, sym->size, area);
+	if (IS_ERR(mem)) {
+		nfp_err(rtbl->cpp, "Failed to map symbol %s: %ld\n",
+			name, PTR_ERR(mem));
+		return mem;
+	}
+
+	return mem;
+}
-- 
2.11.0

From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/5] nfp: keep MIP object around
Date: Thu,  8 Jun 2017 20:56:13 -0700
Message-ID: <20170609035614.12691-5-jakub.kicinski@netronome.com>
References: <20170609035614.12691-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:33009 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751511AbdFID55 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Jun 2017 23:57:57 -0400
Received: by mail-pf0-f169.google.com with SMTP id 83so23936068pfr.0
        for <netdev@vger.kernel.org>; Thu, 08 Jun 2017 20:57:57 -0700 (PDT)
In-Reply-To: <20170609035614.12691-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Microcode Information Page contains some useful information, like
application firmware build name.  Keep it around, similar to RTSym
and HWInfo.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c          |  5 ++++-
 drivers/net/ethernet/netronome/nfp/nfp_main.h          |  3 +++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h  |  2 ++
 drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c | 16 +++++++++++++---
 4 files changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 94211e245257..4e59dcb78c36 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -375,7 +375,8 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_devlink_unreg;
 
-	pf->rtbl = nfp_rtsym_table_read(pf->cpp);
+	pf->mip = nfp_mip_open(pf->cpp);
+	pf->rtbl = __nfp_rtsym_table_read(pf->cpp, pf->mip);
 
 	err = nfp_pcie_sriov_read_nfd_limit(pf);
 	if (err)
@@ -399,6 +400,7 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	pci_sriov_set_totalvfs(pf->pdev, 0);
 err_fw_unload:
 	kfree(pf->rtbl);
+	nfp_mip_close(pf->mip);
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
 	kfree(pf->eth_tbl);
@@ -437,6 +439,7 @@ static void nfp_pci_remove(struct pci_dev *pdev)
 	devlink_unregister(devlink);
 
 	kfree(pf->rtbl);
+	nfp_mip_close(pf->mip);
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
 
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index 041643807f7e..88724f8d0dcd 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -55,6 +55,7 @@ struct nfp_cpp;
 struct nfp_cpp_area;
 struct nfp_eth_table;
 struct nfp_hwinfo;
+struct nfp_mip;
 struct nfp_net;
 struct nfp_nsp_identify;
 struct nfp_rtsym_table;
@@ -72,6 +73,7 @@ struct nfp_rtsym_table;
  * @num_vfs:		Number of SR-IOV VFs enabled
  * @fw_loaded:		Is the firmware loaded?
  * @ctrl_vnic:		Pointer to the control vNIC if available
+ * @mip:		MIP handle
  * @rtbl:		RTsym table
  * @hwinfo:		HWInfo table
  * @eth_tbl:		NSP ETH table
@@ -105,6 +107,7 @@ struct nfp_pf {
 
 	struct nfp_net *ctrl_vnic;
 
+	const struct nfp_mip *mip;
 	struct nfp_rtsym_table *rtbl;
 	struct nfp_hwinfo *hwinfo;
 	struct nfp_eth_table *eth_tbl;
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
index f845cf5dd762..c7266baec0eb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_nffw.h
@@ -90,6 +90,8 @@ struct nfp_rtsym {
 struct nfp_rtsym_table;
 
 struct nfp_rtsym_table *nfp_rtsym_table_read(struct nfp_cpp *cpp);
+struct nfp_rtsym_table *
+__nfp_rtsym_table_read(struct nfp_cpp *cpp, const struct nfp_mip *mip);
 int nfp_rtsym_count(struct nfp_rtsym_table *rtbl);
 const struct nfp_rtsym *nfp_rtsym_get(struct nfp_rtsym_table *rtbl, int idx);
 const struct nfp_rtsym *
diff --git a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
index ef3566163cb0..203f9cbae0fb 100644
--- a/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
+++ b/drivers/net/ethernet/netronome/nfp/nfpcore/nfp_rtsym.c
@@ -109,21 +109,31 @@ nfp_rtsym_sw_entry_init(struct nfp_rtsym_table *cache, u32 strtab_size,
 
 struct nfp_rtsym_table *nfp_rtsym_table_read(struct nfp_cpp *cpp)
 {
+	struct nfp_rtsym_table *rtbl;
+	const struct nfp_mip *mip;
+
+	mip = nfp_mip_open(cpp);
+	rtbl = __nfp_rtsym_table_read(cpp, mip);
+	nfp_mip_close(mip);
+
+	return rtbl;
+}
+
+struct nfp_rtsym_table *
+__nfp_rtsym_table_read(struct nfp_cpp *cpp, const struct nfp_mip *mip)
+{
 	const u32 dram = NFP_CPP_ID(NFP_CPP_TARGET_MU, NFP_CPP_ACTION_RW, 0) |
 		NFP_ISL_EMEM0;
 	u32 strtab_addr, symtab_addr, strtab_size, symtab_size;
 	struct nfp_rtsym_entry *rtsymtab;
 	struct nfp_rtsym_table *cache;
-	const struct nfp_mip *mip;
 	int err, n, size;
 
-	mip = nfp_mip_open(cpp);
 	if (!mip)
 		return NULL;
 
 	nfp_mip_strtab(mip, &strtab_addr, &strtab_size);
 	nfp_mip_symtab(mip, &symtab_addr, &symtab_size);
-	nfp_mip_close(mip);
 
 	if (!symtab_size || !strtab_size || symtab_size % sizeof(*rtsymtab))
 		return NULL;
-- 
2.11.0

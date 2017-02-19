From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 7/7] nfp: allow application firmware to limit number of SR-IOV VFs
Date: Sun, 19 Feb 2017 11:58:14 -0800
Message-ID: <20170219195814.40471-8-jakub.kicinski@netronome.com>
References: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        kubakici@wp.pl, Jakub Kicinski <jakub.kicinski@netronome.com>,
        Yuval Mintz <yuval.mintz@cavium.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:32812 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbdBST60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 14:58:26 -0500
Received: by mail-pg0-f48.google.com with SMTP id a123so8125474pgc.0
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 11:58:26 -0800 (PST)
In-Reply-To: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some application firmware projects may choose to limit the number
of VFs available below what is specified in PCI capability to be
able to reuse the PCIe interface resources.  There may also be
projects which use cases don't require SR-IOV support at all and
therefore don't want to spend time implementing/testing it.

Check nfd_vf_cfg_max_vfs firmware symbol to see if application
firmware is reporting how many VFs it supports.  This mechanism
is an opt-in, if symbol is not present we will only look at the
PCI capability values.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
CC: Yuval Mintz <yuval.mintz@cavium.com>

 drivers/net/ethernet/netronome/nfp/nfp_main.c | 25 +++++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_main.h |  2 ++
 2 files changed, 27 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 8cda6b0e7e32..dedac720fb29 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -47,6 +47,7 @@
 
 #include "nfpcore/nfp.h"
 #include "nfpcore/nfp_cpp.h"
+#include "nfpcore/nfp_nffw.h"
 #include "nfpcore/nfp_nsp_eth.h"
 
 #include "nfpcore/nfp6000_pcie.h"
@@ -70,12 +71,34 @@ static const struct pci_device_id nfp_pci_device_ids[] = {
 };
 MODULE_DEVICE_TABLE(pci, nfp_pci_device_ids);
 
+static void nfp_pcie_sriov_read_nfd_limit(struct nfp_pf *pf)
+{
+#ifdef CONFIG_PCI_IOV
+	int err;
+
+	pf->limit_vfs = nfp_rtsym_read_le(pf->cpp, "nfd_vf_cfg_max_vfs", &err);
+	if (!err)
+		return;
+
+	pf->limit_vfs = ~0;
+	/* Allow any setting for backwards compatibility if symbol not found */
+	if (err != -ENOENT)
+		nfp_warn(pf->cpp, "Warning: VF limit read failed: %d\n", err);
+#endif
+}
+
 static int nfp_pcie_sriov_enable(struct pci_dev *pdev, int num_vfs)
 {
 #ifdef CONFIG_PCI_IOV
 	struct nfp_pf *pf = pci_get_drvdata(pdev);
 	int err;
 
+	if (num_vfs > pf->limit_vfs) {
+		nfp_info(pf->cpp, "Firmware limits number of VFs to %u\n",
+			 pf->limit_vfs);
+		return -EINVAL;
+	}
+
 	err = pci_enable_sriov(pdev, num_vfs);
 	if (err) {
 		dev_warn(&pdev->dev, "Failed to enable PCI sriov: %d\n", err);
@@ -333,6 +356,8 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 	if (err)
 		goto err_cpp_free;
 
+	nfp_pcie_sriov_read_nfd_limit(pf);
+
 	err = nfp_net_pci_probe(pf);
 	if (err)
 		goto err_fw_unload;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.h b/drivers/net/ethernet/netronome/nfp/nfp_main.h
index 6c40fa322da3..39105d0435e9 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.h
@@ -59,6 +59,7 @@ struct nfp_eth_table;
  * @tx_area:		Pointer to the CPP area for the TX queues
  * @rx_area:		Pointer to the CPP area for the FL/RX queues
  * @irq_entries:	Array of MSI-X entries for all ports
+ * @limit_vfs:		Number of VFs supported by firmware (~0 for PCI limit)
  * @num_vfs:		Number of SR-IOV VFs enabled
  * @fw_loaded:		Is the firmware loaded?
  * @eth_tbl:		NSP ETH table
@@ -77,6 +78,7 @@ struct nfp_pf {
 
 	struct msix_entry *irq_entries;
 
+	unsigned int limit_vfs;
 	unsigned int num_vfs;
 
 	bool fw_loaded;
-- 
2.11.0

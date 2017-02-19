From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 1/7] nfp: refactor NSP initialization and add error message
Date: Sun, 19 Feb 2017 11:58:08 -0800
Message-ID: <20170219195814.40471-2-jakub.kicinski@netronome.com>
References: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, dinan.gunawardena@netronome.com,
        kubakici@wp.pl, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f179.google.com ([209.85.192.179]:35540 "EHLO
        mail-pf0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751792AbdBST60 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Feb 2017 14:58:26 -0500
Received: by mail-pf0-f179.google.com with SMTP id 68so12978222pfx.2
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 11:58:26 -0800 (PST)
In-Reply-To: <20170219195814.40471-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When acquiring NSP communication resource fails user is left with
"probe failed with error -2" PCI code message but no info on what
caused the problem.  Some development boards may not have NSP FW
in the flash image.  Help users with a more verbouse message.

While at it move the whole NSP init to a separate function to keep
.probe() callback nice and simple.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 59 ++++++++++++++++-----------
 1 file changed, 36 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index db52b6a53c6f..ca2c464c15df 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -228,6 +228,40 @@ nfp_fw_load(struct pci_dev *pdev, struct nfp_pf *pf, struct nfp_nsp *nsp)
 	return err < 0 ? err : 1;
 }
 
+static int nfp_nsp_init(struct pci_dev *pdev, struct nfp_pf *pf)
+{
+	struct nfp_nsp *nsp;
+	int err;
+
+	nsp = nfp_nsp_open(pf->cpp);
+	if (IS_ERR(nsp)) {
+		err = PTR_ERR(nsp);
+		dev_err(&pdev->dev, "Failed to access the NSP: %d\n", err);
+		return err;
+	}
+
+	err = nfp_nsp_wait(nsp);
+	if (err < 0)
+		goto exit_close_nsp;
+
+	pf->eth_tbl = __nfp_eth_read_ports(pf->cpp, nsp);
+
+	err = nfp_fw_load(pdev, pf, nsp);
+	if (err < 0) {
+		kfree(pf->eth_tbl);
+		dev_err(&pdev->dev, "Failed to load FW\n");
+		goto exit_close_nsp;
+	}
+
+	pf->fw_loaded = !!err;
+	err = 0;
+
+exit_close_nsp:
+	nfp_nsp_close(nsp);
+
+	return err;
+}
+
 static void nfp_fw_unload(struct nfp_pf *pf)
 {
 	struct nfp_nsp *nsp;
@@ -251,7 +285,6 @@ static void nfp_fw_unload(struct nfp_pf *pf)
 static int nfp_pci_probe(struct pci_dev *pdev,
 			 const struct pci_device_id *pci_id)
 {
-	struct nfp_nsp *nsp;
 	struct nfp_pf *pf;
 	int err;
 
@@ -289,28 +322,9 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 		goto err_disable_msix;
 	}
 
-	nsp = nfp_nsp_open(pf->cpp);
-	if (IS_ERR(nsp)) {
-		err = PTR_ERR(nsp);
-		goto err_cpp_free;
-	}
-
-	err = nfp_nsp_wait(nsp);
-	if (err < 0) {
-		nfp_nsp_close(nsp);
+	err = nfp_nsp_init(pdev, pf);
+	if (err)
 		goto err_cpp_free;
-	}
-
-	pf->eth_tbl = __nfp_eth_read_ports(pf->cpp, nsp);
-
-	err = nfp_fw_load(pdev, pf, nsp);
-	nfp_nsp_close(nsp);
-	if (err < 0) {
-		dev_err(&pdev->dev, "Failed to load FW\n");
-		goto err_eth_tbl_free;
-	}
-
-	pf->fw_loaded = !!err;
 
 	err = nfp_net_pci_probe(pf);
 	if (err)
@@ -321,7 +335,6 @@ static int nfp_pci_probe(struct pci_dev *pdev,
 err_fw_unload:
 	if (pf->fw_loaded)
 		nfp_fw_unload(pf);
-err_eth_tbl_free:
 	kfree(pf->eth_tbl);
 err_cpp_free:
 	nfp_cpp_free(pf->cpp);
-- 
2.11.0

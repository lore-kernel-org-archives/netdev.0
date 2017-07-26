From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 3/3] nfp: only use direct firmware requests
Date: Wed, 26 Jul 2017 11:09:48 -0700
Message-ID: <20170726180948.3220-4-jakub.kicinski@netronome.com>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:36992 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751427AbdGZSMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:12:34 -0400
Received: by mail-pg0-f49.google.com with SMTP id y129so87368116pgy.4
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:12:34 -0700 (PDT)
In-Reply-To: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

request_firmware() will fallback to user space helper and may cause
long delays when driver is loaded if udev doesn't correctly handle
FW requests.  Since we never really made use of the user space
helper functionality switch to the simpler request_firmware_direct()
call.  The side effect of this change is that no warning will be
printed when the FW image does not exists.  To help users figure
out which FW file is missing print a info message when we request
each file.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 42 +++++++++++++++++----------
 1 file changed, 26 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index 13d056da0765..dd769eceb33d 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -174,6 +174,21 @@ static int nfp_pcie_sriov_configure(struct pci_dev *pdev, int num_vfs)
 		return nfp_pcie_sriov_enable(pdev, num_vfs);
 }
 
+static const struct firmware *
+nfp_net_fw_request(struct pci_dev *pdev, struct nfp_pf *pf, const char *name)
+{
+	const struct firmware *fw = NULL;
+	int err;
+
+	err = request_firmware_direct(&fw, name, &pdev->dev);
+	nfp_info(pf->cpp, "  %s: %s\n",
+		 name, err ? "not found" : "found, loading...");
+	if (err)
+		return NULL;
+
+	return fw;
+}
+
 /**
  * nfp_net_fw_find() - Find the correct firmware image for netdev mode
  * @pdev:	PCI Device structure
@@ -184,29 +199,30 @@ static int nfp_pcie_sriov_configure(struct pci_dev *pdev, int num_vfs)
 static const struct firmware *
 nfp_net_fw_find(struct pci_dev *pdev, struct nfp_pf *pf)
 {
-	const struct firmware *fw = NULL;
 	struct nfp_eth_table_port *port;
+	const struct firmware *fw;
 	const char *fw_model;
 	char fw_name[256];
 	const u8 *serial;
-	int spc, err = 0;
 	u16 interface;
-	int i, j;
+	int spc, i, j;
+
+	nfp_info(pf->cpp, "Looking for firmware file in order of priority:\n");
 
 	/* First try to find a firmware image specific for this device */
 	interface = nfp_cpp_interface(pf->cpp);
 	nfp_cpp_serial(pf->cpp, &serial);
 	sprintf(fw_name, "netronome/serial-%pMF-%02hhx-%02hhx.nffw",
 		serial, interface >> 8, interface & 0xff);
-	err = request_firmware_direct(&fw, fw_name, &pdev->dev);
-	if (!err)
-		goto done;
+	fw = nfp_net_fw_request(pdev, pf, fw_name);
+	if (fw)
+		return fw;
 
 	/* Then try the PCI name */
 	sprintf(fw_name, "netronome/pci-%s.nffw", pci_name(pdev));
-	err = request_firmware_direct(&fw, fw_name, &pdev->dev);
-	if (!err)
-		goto done;
+	fw = nfp_net_fw_request(pdev, pf, fw_name);
+	if (fw)
+		return fw;
 
 	/* Finally try the card type and media */
 	if (!pf->eth_tbl) {
@@ -241,13 +257,7 @@ nfp_net_fw_find(struct pci_dev *pdev, struct nfp_pf *pf)
 	if (spc <= 0)
 		return NULL;
 
-	err = request_firmware(&fw, fw_name, &pdev->dev);
-	if (err)
-		return NULL;
-done:
-	dev_info(&pdev->dev, "Loading FW image: %s\n", fw_name);
-
-	return fw;
+	return nfp_net_fw_request(pdev, pf, fw_name);
 }
 
 /**
-- 
2.11.0

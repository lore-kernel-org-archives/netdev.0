From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 2/3] nfp: look for firmware image by device serial number and PCI name
Date: Wed, 26 Jul 2017 11:09:47 -0700
Message-ID: <20170726180948.3220-3-jakub.kicinski@netronome.com>
References: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:33731 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751103AbdGZSMe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Jul 2017 14:12:34 -0400
Received: by mail-pg0-f52.google.com with SMTP id b8so10822912pgn.0
        for <netdev@vger.kernel.org>; Wed, 26 Jul 2017 11:12:34 -0700 (PDT)
In-Reply-To: <20170726180948.3220-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We generally look up firmware by card type, but that doesn't allow
users who have more than one card of the same type in their system
to select firmware per adapter.

Unfortunately user space firmware helper seems fraught with
difficulties and to be on its way out.  In particular support for
handling firmware uevents have been dropped from systemd and most
distributions don't enable the FW fallback by default any more.

To allow users selecting firmware for a particular device look up
firmware names by serial and pci_name().  Use the direct lookup to
disable generating uevents when enabled in Kconfig and not print
any warnings to logs if adapter-specific files are missing.  Users
can place in /lib/firmware/netronome files named:

pci-${pci_name}.nffw
serial-${serial}.nffw

to target a specific card.  E.g.:

pci-0000:04:00.0.nffw
pci-0000:82:00.0.nffw
serial-00-aa-bb-11-22-33-10-ff.nffw

We use the full serial number including the interface id, as it
appears in lspci output (bytes separated by '-').

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_main.c | 20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_main.c b/drivers/net/ethernet/netronome/nfp/nfp_main.c
index d67969d3e484..13d056da0765 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_main.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_main.c
@@ -188,9 +188,27 @@ nfp_net_fw_find(struct pci_dev *pdev, struct nfp_pf *pf)
 	struct nfp_eth_table_port *port;
 	const char *fw_model;
 	char fw_name[256];
+	const u8 *serial;
 	int spc, err = 0;
+	u16 interface;
 	int i, j;
 
+	/* First try to find a firmware image specific for this device */
+	interface = nfp_cpp_interface(pf->cpp);
+	nfp_cpp_serial(pf->cpp, &serial);
+	sprintf(fw_name, "netronome/serial-%pMF-%02hhx-%02hhx.nffw",
+		serial, interface >> 8, interface & 0xff);
+	err = request_firmware_direct(&fw, fw_name, &pdev->dev);
+	if (!err)
+		goto done;
+
+	/* Then try the PCI name */
+	sprintf(fw_name, "netronome/pci-%s.nffw", pci_name(pdev));
+	err = request_firmware_direct(&fw, fw_name, &pdev->dev);
+	if (!err)
+		goto done;
+
+	/* Finally try the card type and media */
 	if (!pf->eth_tbl) {
 		dev_err(&pdev->dev, "Error: can't identify media config\n");
 		return NULL;
@@ -226,7 +244,7 @@ nfp_net_fw_find(struct pci_dev *pdev, struct nfp_pf *pf)
 	err = request_firmware(&fw, fw_name, &pdev->dev);
 	if (err)
 		return NULL;
-
+done:
 	dev_info(&pdev->dev, "Loading FW image: %s\n", fw_name);
 
 	return fw;
-- 
2.11.0

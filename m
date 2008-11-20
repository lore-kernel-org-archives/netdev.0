From: Andreas Petlund <apetlund@simula.no>
Subject: Re: pci: Added quirk to disable msi for MCP55 NIC on Asus P5N32-SLI
 Premium
Date: Thu, 20 Nov 2008 15:32:28 +0100
Message-ID: <492574FC.2090701@simula.no>
References: <20081119.141318.89771247.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:48112 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754865AbYKTOcd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 09:32:33 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1L3Aa7-0007mf-Gc
	for netdev@vger.kernel.org; Thu, 20 Nov 2008 15:32:31 +0100
In-Reply-To: <20081119.141318.89771247.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> You can't start calling dmi_*() routines in drivers/pci/quirks.c without
> including linux/dmi.h there, otherwise it doesn't build on some platforms:
> 
> drivers/pci/quirks.c: In function 'nvenet_msi_disable':
> drivers/pci/quirks.c:1837: error: implicit declaration of function 'dmi_name_in_vendors'
> make[1]: *** [drivers/pci/quirks.o] Error 1

Here is an updated version with the missing include.


Signed-off-by: Andreas Petlund <andreas@petlund.no>
---
 drivers/pci/quirks.c |   17 +++++++++++++++++
 1 files changed, 17 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 5049a47..5f4f85f 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -22,6 +22,7 @@
 #include <linux/delay.h>
 #include <linux/acpi.h>
 #include <linux/kallsyms.h>
+#include <linux/dmi.h>
 #include "pci.h"
 
 int isa_dma_bridge_buggy;
@@ -1828,6 +1829,22 @@ DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_SERVERWORKS,
 			 PCI_DEVICE_ID_SERVERWORKS_HT1000_PXB,
 			 ht_enable_msi_mapping);
 
+/* The P5N32-SLI Premium motherboard from Asus has a problem with msi
+ * for the MCP55 NIC. It is not yet determined whether the msi problem
+ * also affects other devices. As for now, turn off msi for this device.
+ */
+static void __devinit nvenet_msi_disable(struct pci_dev *dev)
+{
+	if (dmi_name_in_vendors("P5N32-SLI PREMIUM")) {
+		dev_info(&dev->dev,
+			 "Disabling msi for MCP55 NIC on P5N32-SLI Premium\n");
+		dev->no_msi = 1;
+	}
+}
+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_NVIDIA,
+			PCI_DEVICE_ID_NVIDIA_NVENET_15,
+			nvenet_msi_disable);
+
 static void __devinit nv_msi_ht_cap_quirk(struct pci_dev *dev)
 {
 	struct pci_dev *host_bridge;
-- 
1.5.6.3


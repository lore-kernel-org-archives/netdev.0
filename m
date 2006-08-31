From: Brice Goglin <brice@myri.com>
Subject: [PATCH] myri10ge: improve firmware selection
Date: Thu, 31 Aug 2006 01:32:59 -0400
Message-ID: <44F6748B.4020001@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from h-66-166-126-70.lsanca54.covad.net ([66.166.126.70]:22776 "EHLO
	myri.com") by vger.kernel.org with ESMTP id S1751238AbWHaFd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 01:33:27 -0400
To: Jeff Garzik <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff,

Here's a patch to improve the selection on the myri10ge firmware.
Please apply to #upstream for 2.6.19.

The patch actually raises two concerns:
* We might want to add a generic PCI function to get the PCIe link width since
  some other drivers (at least ipath) do the same. But we probably do not want
  to add a new function for every PCIe capability. I will probably look at it
  and discuss it on linux-pci in the future.
* As requested during the submission, the PCI ids of chipsets that are known to
  provided aligned completion are defined in the myri10ge code. If we keep adding
  new ones, it might become better to move them to pciids.h.
  But, this sort of quirk to detect these chipsets are very specific to our NIC,
  I don't think it is worth moving it to the PCI core until somebody else really
  needs it.

Thanks,
Brice



From: Brice Goglin <brice@myri.com>

[PATCH] myri10ge: improve firmware selection

Improve the firmware selection by adding 2 cases where we should use the
optimized firmware:
* when the actual PCIe link width is lower than 8x.
* when the board is plugged to one of the new Intel PCIe chipsets that
  are known to provide aligned PCIe completions.

Signed-off-by: Brice Goglin <brice@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |   35 ++++++++++++++++++++++++++++-------
 1 file changed, 28 insertions(+), 7 deletions(-)

Index: linux-mm/drivers/net/myri10ge/myri10ge.c
===================================================================
--- linux-mm.orig/drivers/net/myri10ge/myri10ge.c	2006-08-26 23:34:49.000000000 -0400
+++ linux-mm/drivers/net/myri10ge/myri10ge.c	2006-08-31 00:49:35.000000000 -0400
@@ -2410,6 +2410,8 @@
  */
 
 #define PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE	0x0132
+#define PCI_DEVICE_ID_INTEL_E5000_PCIE23 0x25f7
+#define PCI_DEVICE_ID_INTEL_E5000_PCIE47 0x25fa
 
 static void myri10ge_select_firmware(struct myri10ge_priv *mgp)
 {
@@ -2419,15 +2421,34 @@
 	mgp->fw_name = myri10ge_fw_unaligned;
 
 	if (myri10ge_force_firmware == 0) {
+		int link_width, exp_cap;
+		u16 lnk;
+
+		exp_cap = pci_find_capability(mgp->pdev, PCI_CAP_ID_EXP);
+		pci_read_config_word(mgp->pdev, exp_cap + PCI_EXP_LNKSTA, &lnk);
+		link_width = (lnk >> 4) & 0x3f;
+
 		myri10ge_enable_ecrc(mgp);
 
-		/* Check to see if the upstream bridge is known to
-		 * provide aligned completions */
-		if (bridge
-		    /* ServerWorks HT2000/HT1000 */
-		    && bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
-		    && bridge->device ==
-		    PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE) {
+		/* Check to see if Link is less than 8 or if the
+		 * upstream bridge is known to provide aligned
+		 * completions */
+		if (link_width < 8) {
+			dev_info(&mgp->pdev->dev, "PCIE x%d Link\n",
+				 link_width);
+			mgp->tx.boundary = 4096;
+			mgp->fw_name = myri10ge_fw_aligned;
+		} else if (bridge &&
+			   /* ServerWorks HT2000/HT1000 */
+			   ((bridge->vendor == PCI_VENDOR_ID_SERVERWORKS
+			     && bridge->device ==
+			     PCI_DEVICE_ID_SERVERWORKS_HT2000_PCIE)
+			    /* All Intel E5000 PCIE ports */
+			    || (bridge->vendor == PCI_VENDOR_ID_INTEL
+				&& bridge->device >=
+				PCI_DEVICE_ID_INTEL_E5000_PCIE23
+				&& bridge->device <=
+				PCI_DEVICE_ID_INTEL_E5000_PCIE47))) {
 			dev_info(&mgp->pdev->dev,
 				 "Assuming aligned completions (0x%x:0x%x)\n",
 				 bridge->vendor, bridge->device);



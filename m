From: Andreas Petlund <apetlund@simula.no>
Subject: [PATCH] pci: Added quirk to disable msi for MCP55 NIC on Asus P5N32-SLI
 Premium
Date: Fri, 14 Nov 2008 11:02:01 +0100
Message-ID: <491D4C99.3070208@simula.no>
References: <037FCE6B-850E-4A88-B4C3-B856B306377E@petlund.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-forward2.uio.no ([129.240.10.71]:36424 "EHLO
	mail-forward2.uio.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751040AbYKNKlK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 05:41:10 -0500
Received: from exim by mail-out2.uio.no with local-bsmtp (Exim 4.69)
	(envelope-from <apetlund@simula.no>)
	id 1L0vV4-0001Hz-HR
	for netdev@vger.kernel.org; Fri, 14 Nov 2008 11:02:02 +0100
In-Reply-To: <037FCE6B-850E-4A88-B4C3-B856B306377E@petlund.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Petlund wrote:
> I have a machine with an Asus motherboard (P5N32-SLI Premium - NVidia 
> MCP55 chipset) where the forcedeth module does not work with msi. This 
> seems to bother quite some people ( see 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/136836 ).
>
> Reading various forum posts makes me inclined to believe this is a 
> firmware problem, but Asus have no fix with their latest BIOS-upgrade 
> (and I am starting to believe that we will never see one as the last 
> update came in March this year).
>
> Is it an option to workaround this problem using a hardware-specific 
> quirk that disables msi/msix for the device, or will that affect a lot 
> of users that have no issues with this? On my system the NIC 
> identifies as "cb84". I don't know if this is a common factor for all 
> who has this problem, or only for my motherboard.
> Maybe the benefit of making it work with all MCP55-NICs is worth 
> disabling msi/msix also for unaffected ones?
>
> Does anybody have alternative suggestions?
>
This patch detects the known affected motherboard and disables msi for 
the MCP55 NIC devices, allowing normal netwrk operation without manually 
having to reload forcedeth module with msi=0 and msix=0.

Signed-off-by: Andreas Petlund <andreas@petlund.no>
---
 drivers/pci/quirks.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/drivers/pci/quirks.c b/drivers/pci/quirks.c
index 5049a47..1bbd912 100644
--- a/drivers/pci/quirks.c
+++ b/drivers/pci/quirks.c
@@ -1828,6 +1828,22 @@ DECLARE_PCI_FIXUP_HEADER(PCI_VENDOR_ID_SERVERWORKS,
                         PCI_DEVICE_ID_SERVERWORKS_HT1000_PXB,
                         ht_enable_msi_mapping);
 
+/* The P5N32-SLI Premium motherboard from Asus has a problem with msi
+ * for the MCP55 NIC. It is not yet determined whether the msi problem
+ * also affects other devices. As for now, turn off msi for this device.
+ */
+static void __devinit nvenet_msi_disable(struct pci_dev *dev)
+{
+       if (dmi_name_in_vendors("P5N32-SLI PREMIUM")) {
+               dev_info(&dev->dev,
+                        "Disabling msi for MCP55 NIC on P5N32-SLI 
Premium\n");
+               dev->no_msi = 1;
+       }
+}
+DECLARE_PCI_FIXUP_EARLY(PCI_VENDOR_ID_NVIDIA,
+                       PCI_DEVICE_ID_NVIDIA_NVENET_15,
+                       nvenet_msi_disable);
+
 static void __devinit nv_msi_ht_cap_quirk(struct pci_dev *dev)
 {
        struct pci_dev *host_bridge;
--

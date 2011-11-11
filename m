From: Todd Broch <tbroch@chromium.org>
Subject: [PATCH] r8169: add module param for control of ASPM  disable
Date: Fri, 11 Nov 2011 15:05:55 -0800
Message-ID: <1321052755-15368-1-git-send-email-tbroch@chromium.org>
Cc: netdev@vger.kernel.org, Todd Broch <tbroch@chromium.org>
To: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:53643 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753445Ab1KKXGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Nov 2011 18:06:09 -0500
Received: by yenr9 with SMTP id r9so3640192yen.19
        for <netdev@vger.kernel.org>; Fri, 11 Nov 2011 15:06:08 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ASPM has been disabled in this driver by default as its been
implicated in stability issues on at least one platform.  This CL adds
a  module parameter to allow control of ASPM disable.  The default
value is to enable ASPM again as its provides signficant (200mW) power
savings on the platform I tested.

Signed-off-by: Todd Broch <tbroch@chromium.org>
---
 drivers/net/r8169.c |   12 ++++++++++--
 1 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5f838ef..05769fa0 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -671,6 +671,10 @@ struct rtl8169_private {
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN);
 };
 
+static int aspm_disable = 0;
+module_param(aspm_disable, bool, 0444);
+MODULE_PARM_DESC(aspm_disable, "Disable ASPM completely.");
+
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param(use_dac, int, 0);
@@ -3291,8 +3295,12 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	/* disable ASPM completely as that cause random device stop working
 	 * problems as well as full system hangs for some PCIe devices users */
-	pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S | PCIE_LINK_STATE_L1 |
-				     PCIE_LINK_STATE_CLKPM);
+	if (aspm_disable) {
+		pci_disable_link_state(pdev, PCIE_LINK_STATE_L0S |
+				       PCIE_LINK_STATE_L1 |
+				       PCIE_LINK_STATE_CLKPM);
+		dprintk("ASPM disabled");
+	}
 
 	/* enable device (incl. PCI PM wakeup and hotplug setup) */
 	rc = pci_enable_device(pdev);
-- 
1.7.3.1

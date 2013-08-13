From: Li Zhang <zhlcindy@gmail.com>
Subject: [PATCH 1/1] net/e1000e: Avoid kernel crash during shutdown
Date: Tue, 13 Aug 2013 14:27:07 +0800
Message-ID: <1376375227-24274-1-git-send-email-zhlcindy@gmail.com>
Cc: shangw@linux.vnet.ibm.com
To: jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:65183 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755438Ab3HMG1e (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 02:27:34 -0400
Received: by mail-pd0-f181.google.com with SMTP id g10so4417546pdj.40
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 23:27:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While doing shutdown on the PCI device, the corresponding callback
function e1000e_shutdown() is trying to clear those correctable
errors on the upstream P2P bridge. Unfortunately, we don't have
the upstream P2P bridge under some cases (e.g. PCI-passthrou for
KVM on Power). That leads to kernel crash eventually.

The patch adds one more check on that to avoid kernel crash.

Signed-off-by: Li Zhang <zhlcindy@gmail.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 77f81cb..232b2e8 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -5999,11 +5999,18 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool runtime)
 	 * correctable error when the MAC transitions from D0 to D3.  To
 	 * prevent this we need to mask off the correctable errors on the
 	 * downstream port of the pci-e switch.
+	 *
+	 * We don't have the associated upstream bridge while assigning
+	 * the PCI device into guest. For example, the KVM on power is
+	 * one of the cases.
 	 */
 	if (adapter->flags & FLAG_IS_QUAD_PORT) {
 		struct pci_dev *us_dev = pdev->bus->self;
 		u16 devctl;
 
+		if (!us_dev)
+			return 0;
+
 		pcie_capability_read_word(us_dev, PCI_EXP_DEVCTL, &devctl);
 		pcie_capability_write_word(us_dev, PCI_EXP_DEVCTL,
 					   (devctl & ~PCI_EXP_DEVCTL_CERE));
-- 
1.8.1.4

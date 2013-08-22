From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 14/15] e1000e: Avoid kernel crash during shutdown
Date: Thu, 22 Aug 2013 02:49:50 -0700
Message-ID: <1377164991-27988-15-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Li Zhang <zhlcindy@gmail.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:54080 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861Ab3HVJuG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 05:50:06 -0400
In-Reply-To: <1377164991-27988-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li Zhang <zhlcindy@gmail.com>

While doing shutdown on the PCI device, the corresponding callback
function e1000e_shutdown() is trying to clear those correctable
errors on the upstream P2P bridge. Unfortunately, we don't have
the upstream P2P bridge under some cases (e.g. PCI-passthrou for
KVM on Power). That leads to kernel crash eventually.

The patch adds one more check on that to avoid kernel crash.

Signed-off-by: Li Zhang <zhlcindy@gmail.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 59c0c54..e87e9b0 100644
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
1.8.3.1

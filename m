From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH] ixgbe: Use pci_wake_from_d3() instead of multiple
	pci_enable_wake()
Date: Wed, 29 Apr 2009 00:18:52 -0700
Message-ID: <20090429071852.6130.6565.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:47499
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751019AbZD2HTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 03:19:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

We were calling pci_enable_wake() twice in a row for both D3_hot
and D3_cold.  This replaces those calls with a call to pci_wake_from_d3()
to avoid issues with PCI PM vs ordering constraints.

Signed-off-by: Don Skidmore <donald.c.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   17 ++++++-----------
 1 files changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 5020f11..01a8826 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3738,8 +3738,7 @@ static int ixgbe_resume(struct pci_dev *pdev)
 	}
 	pci_set_master(pdev);
 
-	pci_enable_wake(pdev, PCI_D3hot, 0);
-	pci_enable_wake(pdev, PCI_D3cold, 0);
+	pci_wake_from_d3(pdev, false);
 
 	err = ixgbe_init_interrupt_scheme(adapter);
 	if (err) {
@@ -3813,13 +3812,10 @@ static int __ixgbe_shutdown(struct pci_dev *pdev, bool *enable_wake)
 		IXGBE_WRITE_REG(hw, IXGBE_WUFC, 0);
 	}
 
-	if (wufc && hw->mac.type == ixgbe_mac_82599EB) {
-		pci_enable_wake(pdev, PCI_D3hot, 1);
-		pci_enable_wake(pdev, PCI_D3cold, 1);
-	} else {
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
-	}
+	if (wufc && hw->mac.type == ixgbe_mac_82599EB)
+		pci_wake_from_d3(pdev, true);
+	else
+		pci_wake_from_d3(pdev, false);
 
 	*enable_wake = !!wufc;
 
@@ -5101,8 +5097,7 @@ static pci_ers_result_t ixgbe_io_slot_reset(struct pci_dev *pdev)
 		pci_set_master(pdev);
 		pci_restore_state(pdev);
 
-		pci_enable_wake(pdev, PCI_D3hot, 0);
-		pci_enable_wake(pdev, PCI_D3cold, 0);
+		pci_wake_from_d3(pdev, false);
 
 		ixgbe_reset(adapter);
 		IXGBE_WRITE_REG(&adapter->hw, IXGBE_WUS, ~0);


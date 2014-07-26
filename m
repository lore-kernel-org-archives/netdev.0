From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 12/12] e1000e: Fix Runtime PM blocks EEE link negotiation in S5
Date: Fri, 25 Jul 2014 21:45:22 -0700
Message-ID: <1406349922-9883-13-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: David Ertman <david.m.ertman@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:28061 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751085AbaGZEpd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 26 Jul 2014 00:45:33 -0400
In-Reply-To: <1406349922-9883-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ertman <david.m.ertman@intel.com>

Adding a function, and associated calls, to flush writes to (read) the LPIC
MAC register before entering the shutdown flow.  This fixes the problem
of the PHY never negotiating a 100M link (if both sides of the link support
EEE and 100M link) when Runtime PM is enabled.

Signed-off-by: Dave Ertman <david.m.ertman@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 26 ++++++++++++++++++++++++++
 1 file changed, 26 insertions(+)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 1ce0d74..65c3aef 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -6033,6 +6033,28 @@ release:
 	return retval;
 }
 
+static void e1000e_flush_lpic(struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 ret_val;
+
+	pm_runtime_get_sync(netdev->dev.parent);
+
+	ret_val = hw->phy.ops.acquire(hw);
+	if (ret_val)
+		goto fl_out;
+
+	pr_info("EEE TX LPI TIMER: %08X\n",
+		er32(LPIC) >> E1000_LPIC_LPIET_SHIFT);
+
+	hw->phy.ops.release(hw);
+
+fl_out:
+	pm_runtime_put_sync(netdev->dev.parent);
+}
+
 static int e1000e_pm_freeze(struct device *dev)
 {
 	struct net_device *netdev = pci_get_drvdata(to_pci_dev(dev));
@@ -6333,6 +6355,8 @@ static int e1000e_pm_suspend(struct device *dev)
 {
 	struct pci_dev *pdev = to_pci_dev(dev);
 
+	e1000e_flush_lpic(pdev);
+
 	e1000e_pm_freeze(dev);
 
 	return __e1000_shutdown(pdev, false);
@@ -6416,6 +6440,8 @@ static int e1000e_pm_runtime_suspend(struct device *dev)
 
 static void e1000_shutdown(struct pci_dev *pdev)
 {
+	e1000e_flush_lpic(pdev);
+
 	e1000e_pm_freeze(&pdev->dev);
 
 	__e1000_shutdown(pdev, false);
-- 
1.9.3

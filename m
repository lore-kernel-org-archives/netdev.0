From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 5/8] ixgbe: Fix FW init/release, make this code a function
Date: Fri, 01 Feb 2008 15:59:04 -0800
Message-ID: <20080201235904.31474.33045.stgit@localhost.localdomain>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:16738 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760610AbYBAX7f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 18:59:35 -0500
In-Reply-To: <20080201235841.31474.49421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

A gap was left in the FW release/grab code in up/down path. Fix
it by making the release/grab code a function and calling it in
appropriate locations.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   38 ++++++++++++++++++++++++++++----------
 1 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index b4c9c77..c814d9b 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -87,6 +87,25 @@ MODULE_VERSION(DRV_VERSION);
 
 #define DEFAULT_DEBUG_LEVEL_SHIFT 3
 
+static void ixgbe_release_hw_control(struct ixgbe_adapter *adapter)
+{
+	u32 ctrl_ext;
+
+	/* Let firmware take over control of h/w */
+	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
+			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+}
+
+static void ixgbe_get_hw_control(struct ixgbe_adapter *adapter)
+{
+	u32 ctrl_ext;
+
+	/* Let firmware know the driver has taken over */
+	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
+	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
+			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
+}
 
 #ifdef DEBUG
 /**
@@ -1204,6 +1223,8 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 	u32 txdctl, rxdctl, mhadd;
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 
+	ixgbe_get_hw_control(adapter);
+
 	if (adapter->flags & (IXGBE_FLAG_MSIX_ENABLED |
 			      IXGBE_FLAG_MSI_ENABLED)) {
 		if (adapter->flags & IXGBE_FLAG_MSIX_ENABLED) {
@@ -1490,6 +1511,8 @@ static int ixgbe_suspend(struct pci_dev *pdev, pm_message_t state)
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
 
+	ixgbe_release_hw_control(adapter);
+
 	pci_disable_device(pdev);
 
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -1891,14 +1914,8 @@ static int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	int err;
-	u32 ctrl_ext;
 	u32 num_rx_queues = adapter->num_rx_queues;
 
-	/* Let firmware know the driver has taken over */
-	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext | IXGBE_CTRL_EXT_DRV_LOAD);
-
 try_intr_reinit:
 	/* allocate transmit descriptors */
 	err = ixgbe_setup_all_tx_resources(adapter);
@@ -1949,6 +1966,7 @@ try_intr_reinit:
 	return 0;
 
 err_up:
+	ixgbe_release_hw_control(adapter);
 	ixgbe_free_irq(adapter);
 err_req_irq:
 	ixgbe_free_all_rx_resources(adapter);
@@ -1974,7 +1992,6 @@ err_setup_tx:
 static int ixgbe_close(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
-	u32 ctrl_ext;
 
 	ixgbe_down(adapter);
 	ixgbe_free_irq(adapter);
@@ -1982,9 +1999,7 @@ static int ixgbe_close(struct net_device *netdev)
 	ixgbe_free_all_tx_resources(adapter);
 	ixgbe_free_all_rx_resources(adapter);
 
-	ctrl_ext = IXGBE_READ_REG(&adapter->hw, IXGBE_CTRL_EXT);
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_CTRL_EXT,
-			ctrl_ext & ~IXGBE_CTRL_EXT_DRV_LOAD);
+	ixgbe_release_hw_control(adapter);
 
 	return 0;
 }
@@ -2749,6 +2764,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 	return 0;
 
 err_register:
+	ixgbe_release_hw_control(adapter);
 err_hw_init:
 err_sw_init:
 err_eeprom:
@@ -2784,6 +2800,8 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 
 	unregister_netdev(netdev);
 
+	ixgbe_release_hw_control(adapter);
+
 	kfree(adapter->tx_ring);
 	kfree(adapter->rx_ring);
 


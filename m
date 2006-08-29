From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 24/26] ixgb: Add PCI Error recovery callbacks
Date: Tue, 29 Aug 2006 09:45:08 -0700
Message-ID: <20060829164507.6872.90994.stgit@gitlost.site>
References: <20060829164153.6872.1713.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, akpm@osdl.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:60426 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S965098AbWH2Qgy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 12:36:54 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060829164153.6872.1713.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Adds PCI Error recovery callbacks to the Intel 10-gigabit ethernet ixgb
device driver.  Lightly tested, works.

"Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:

Both pci_disable_device and ixgb_down would access the device.  It doesn't
follow Documentation/pci-error-recovery.txt that error_detected shouldn't do
any access to the device.

Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb_main.c |  112 ++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 111 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index a5da48a..abca75f 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -118,15 +118,26 @@ static void ixgb_restore_vlan(struct ixg
 static void ixgb_netpoll(struct net_device *dev);
 #endif
 
-/* Exported from other modules */
+static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
+	                     enum pci_channel_state state);
+static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev);
+static void ixgb_io_resume (struct pci_dev *pdev);
 
+/* Exported from other modules */
 extern void ixgb_check_options(struct ixgb_adapter *adapter);
 
+static struct pci_error_handlers ixgb_err_handler = {
+	.error_detected = ixgb_io_error_detected,
+	.slot_reset = ixgb_io_slot_reset,
+	.resume = ixgb_io_resume,
+};
+
 static struct pci_driver ixgb_driver = {
 	.name     = ixgb_driver_name,
 	.id_table = ixgb_pci_tbl,
 	.probe    = ixgb_probe,
 	.remove   = __devexit_p(ixgb_remove),
+	.err_handler = &ixgb_err_handler
 };
 
 MODULE_AUTHOR("Intel Corporation, <linux.nics@intel.com>");
@@ -1550,6 +1561,11 @@ void
 ixgb_update_stats(struct ixgb_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+
+	/* Prevent stats update while adapter is being reset */
+	if (pdev->error_state && pdev->error_state != pci_channel_io_normal)
+		return;
 
 	if((netdev->flags & IFF_PROMISC) || (netdev->flags & IFF_ALLMULTI) ||
 	   (netdev->mc_count > IXGB_MAX_NUM_MULTICAST_ADDRESSES)) {
@@ -2205,4 +2221,98 @@ static void ixgb_netpoll(struct net_devi
 }
 #endif
 
+/**
+ * ixgb_io_error_detected() - called when PCI error is detected
+ * @pdev    pointer to pci device with error
+ * @state   pci channel state after error
+ *
+ * This callback is called by the PCI subsystem whenever
+ * a PCI bus error is detected.
+ */
+static pci_ers_result_t ixgb_io_error_detected (struct pci_dev *pdev,
+			             enum pci_channel_state state)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgb_adapter *adapter = netdev->priv;
+
+	if(netif_running(netdev))
+		ixgb_down(adapter, TRUE);
+
+	pci_disable_device(pdev);
+
+	/* Request a slot reset. */
+	return PCI_ERS_RESULT_NEED_RESET;
+}
+
+/**
+ * ixgb_io_slot_reset - called after the pci bus has been reset.
+ * @pdev    pointer to pci device with error
+ *
+ * This callback is called after the PCI buss has been reset.
+ * Basically, this tries to restart the card from scratch.
+ * This is a shortened version of the device probe/discovery code,
+ * it resembles the first-half of the ixgb_probe() routine.
+ */
+static pci_ers_result_t ixgb_io_slot_reset (struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgb_adapter *adapter = netdev->priv;
+
+	if(pci_enable_device(pdev)) {
+		DPRINTK(PROBE, ERR, "Cannot re-enable PCI device after reset.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	/* Perform card reset only on one instance of the card */
+	if (0 != PCI_FUNC (pdev->devfn))
+		return PCI_ERS_RESULT_RECOVERED;
+
+	pci_set_master(pdev);
+
+	netif_carrier_off(netdev);
+	netif_stop_queue(netdev);
+	ixgb_reset(adapter);
+
+	/* Make sure the EEPROM is good */
+	if(!ixgb_validate_eeprom_checksum(&adapter->hw)) {
+		DPRINTK(PROBE, ERR, "After reset, the EEPROM checksum is not valid.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+	ixgb_get_ee_mac_addr(&adapter->hw, netdev->dev_addr);
+	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
+
+	if(!is_valid_ether_addr(netdev->perm_addr)) {
+		DPRINTK(PROBE, ERR, "After reset, invalid MAC address.\n");
+		return PCI_ERS_RESULT_DISCONNECT;
+	}
+
+	return PCI_ERS_RESULT_RECOVERED;
+}
+
+/**
+ * ixgb_io_resume - called when its OK to resume normal operations
+ * @pdev    pointer to pci device with error
+ *
+ * The error recovery driver tells us that its OK to resume
+ * normal operation. Implementation resembles the second-half
+ * of the ixgb_probe() routine.
+ */
+static void ixgb_io_resume (struct pci_dev *pdev)
+{
+	struct net_device *netdev = pci_get_drvdata(pdev);
+	struct ixgb_adapter *adapter = netdev->priv;
+
+	pci_set_master(pdev);
+
+	if(netif_running(netdev)) {
+		if(ixgb_up(adapter)) {
+			printk ("ixgb: can't bring device back up after reset\n");
+			return;
+		}
+	}
+
+	netif_device_attach(netdev);
+	mod_timer(&adapter->watchdog_timer, jiffies);
+}
+
 /* ixgb_main.c */



---
Auke Kok <auke-jan.h.kok@intel.com>

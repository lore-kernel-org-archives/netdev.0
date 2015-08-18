From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 13/15] igb: make sure SR-IOV init uses the right number of queues
Date: Tue, 18 Aug 2015 14:09:20 -0700
Message-ID: <1439932162-1995-14-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Todd Fujinaka <todd.fujinaka@intel.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:52395 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753433AbbHRVJ0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2015 17:09:26 -0400
In-Reply-To: <1439932162-1995-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Todd Fujinaka <todd.fujinaka@intel.com>

Recent changes to igb_probe_vfs() could lead to the PF holding onto all
of the queues. Reorder igb_probe_vfs() to be before
gb_init_queue_configuration() and add some more error checking.

Signed-off-by: Todd Fujinaka <todd.fujinaka@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/igb/igb_main.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 1ebdb46..1902ef8 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -179,6 +179,8 @@ static void igb_check_vf_rate_limit(struct igb_adapter *);
 #ifdef CONFIG_PCI_IOV
 static int igb_vf_configure(struct igb_adapter *adapter, int vf);
 static int igb_pci_enable_sriov(struct pci_dev *dev, int num_vfs);
+static int igb_disable_sriov(struct pci_dev *dev);
+static int igb_pci_disable_sriov(struct pci_dev *dev);
 #endif
 
 #ifdef CONFIG_PM
@@ -2651,6 +2653,9 @@ err_eeprom:
 err_sw_init:
 	kfree(adapter->shadow_vfta);
 	igb_clear_interrupt_scheme(adapter);
+#ifdef CONFIG_PCI_IOV
+	igb_disable_sriov(pdev);
+#endif
 	pci_iounmap(pdev, hw->hw_addr);
 err_ioremap:
 	free_netdev(netdev);
@@ -2981,6 +2986,8 @@ static int igb_sw_init(struct igb_adapter *adapter)
 	}
 #endif /* CONFIG_PCI_IOV */
 
+	igb_probe_vfs(adapter);
+
 	igb_init_queue_configuration(adapter);
 
 	/* Setup and initialize a copy of the hw vlan table array */
@@ -2993,8 +3000,6 @@ static int igb_sw_init(struct igb_adapter *adapter)
 		return -ENOMEM;
 	}
 
-	igb_probe_vfs(adapter);
-
 	/* Explicitly disable IRQ since the NIC can be in any state. */
 	igb_irq_disable(adapter);
 
-- 
2.4.3

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 1/4] netxen: minor suspend resume fixes
Date: Tue,  8 Dec 2009 22:40:54 -0800
Message-ID: <1260340857-11487-2-git-send-email-amit.salecha@qlogic.com>
References: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, dhananjay.phadke@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:53135 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1755511AbZLIGkv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Dec 2009 01:40:51 -0500
In-Reply-To: <1260340857-11487-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

o pci device should be disable at the end and it should be enable first.
o Interface should be attached(netif_device_attach()) irrespective
  of its state.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic_main.c |   16 +++++++++-------
 1 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f499684..6a51ca3 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -1446,14 +1446,14 @@ static int __netxen_nic_shutdown(struct pci_dev *pdev)
 		pci_enable_wake(pdev, PCI_D3hot, 1);
 	}
 
-	pci_disable_device(pdev);
-
 	return 0;
 }
 static void netxen_nic_shutdown(struct pci_dev *pdev)
 {
 	if (__netxen_nic_shutdown(pdev))
 		return;
+
+	pci_disable_device(pdev);
 }
 #ifdef CONFIG_PM
 static int
@@ -1466,6 +1466,8 @@ netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
 		return retval;
 
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+
+	pci_disable_device(pdev);
 	return 0;
 }
 
@@ -1476,13 +1478,14 @@ netxen_nic_resume(struct pci_dev *pdev)
 	struct net_device *netdev = adapter->netdev;
 	int err;
 
-	pci_set_power_state(pdev, PCI_D0);
-	pci_restore_state(pdev);
-
 	err = pci_enable_device(pdev);
 	if (err)
 		return err;
 
+	pci_set_power_state(pdev, PCI_D0);
+	pci_set_master(pdev);
+	pci_restore_state(pdev);
+
 	adapter->ahw.crb_win = -1;
 	adapter->ahw.ocm_win = -1;
 
@@ -1501,11 +1504,10 @@ netxen_nic_resume(struct pci_dev *pdev)
 		if (err)
 			goto err_out_detach;
 
-		netif_device_attach(netdev);
-
 		netxen_config_indev_addr(netdev, NETDEV_UP);
 	}
 
+	netif_device_attach(netdev);
 	netxen_schedule_work(adapter, netxen_fw_poll_work, FW_POLL_DELAY);
 	return 0;
 
-- 
1.6.0.2


From: Dhananjay Phadke <dhananjay@netxen.com>
Subject: [PATCH NEXT 4/5] netxen: implement pci driver shutdown
Date: Sun, 23 Aug 2009 11:35:12 -0700
Message-ID: <1251052513-27618-4-git-send-email-dhananjay@netxen.com>
References: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Cc: netdev@vger.kernel.org, Amit Kumar Salecha <amit@qlogic.com>
To: davem@davemloft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from nat-1.pathscale.com ([198.186.3.73]:19506 "HELO unm84.unmin.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with SMTP
	id S933710AbZHWSfN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Aug 2009 14:35:13 -0400
In-Reply-To: <1251052513-27618-1-git-send-email-dhananjay@netxen.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amit Kumar Salecha <amit@qlogic.com>

Implement pci driver shutdown functionality, this helps
quiescing all PCI transaction before chipset is reset.

Amit Kumar Salecha <amit@qlogic.com>
Signed-off-by: Dhananjay Phadke <dhananjay@netxen.com>
---
 drivers/net/netxen/netxen_nic_main.c |   38 ++++++++++++++++++++++++++-------
 1 files changed, 30 insertions(+), 8 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index f618e7c..794c19b 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -922,6 +922,8 @@ netxen_nic_down(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netxen_p3_free_mac_list(adapter);
 
+	adapter->set_promisc(adapter, NETXEN_NIU_NON_PROMISC_MODE);
+
 	netxen_napi_disable(adapter);
 
 	netxen_release_tx_buffers(adapter);
@@ -1288,14 +1290,11 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	free_netdev(netdev);
 }
-
-#ifdef CONFIG_PM
-static int
-netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
+static int __netxen_nic_shutdown(struct pci_dev *pdev)
 {
-
 	struct netxen_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev = adapter->netdev;
+	int retval;
 
 	netif_device_detach(netdev);
 
@@ -1307,7 +1306,12 @@ netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
 
 	netxen_nic_detach(adapter);
 
-	pci_save_state(pdev);
+	if (adapter->portnum == 0)
+		netxen_free_dummy_dma(adapter);
+
+	retval = pci_save_state(pdev);
+	if (retval)
+		return retval;
 
 	if (netxen_nic_wol_supported(adapter)) {
 		pci_enable_wake(pdev, PCI_D3cold, 1);
@@ -1315,10 +1319,27 @@ netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
 	}
 
 	pci_disable_device(pdev);
-	pci_set_power_state(pdev, pci_choose_state(pdev, state));
 
 	return 0;
 }
+static void netxen_nic_shutdown(struct pci_dev *pdev)
+{
+	if (__netxen_nic_shutdown(pdev))
+		return;
+}
+#ifdef CONFIG_PM
+static int
+netxen_nic_suspend(struct pci_dev *pdev, pm_message_t state)
+{
+	int retval;
+
+	retval = __netxen_nic_shutdown(pdev);
+	if (retval)
+		return retval;
+
+	pci_set_power_state(pdev, pci_choose_state(pdev, state));
+	return 0;
+}
 
 static int
 netxen_nic_resume(struct pci_dev *pdev)
@@ -2068,8 +2089,9 @@ static struct pci_driver netxen_driver = {
 	.remove = __devexit_p(netxen_nic_remove),
 #ifdef CONFIG_PM
 	.suspend = netxen_nic_suspend,
-	.resume = netxen_nic_resume
+	.resume = netxen_nic_resume,
 #endif
+	.shutdown = netxen_nic_shutdown
 };
 
 static int __init netxen_init_module(void)
-- 
1.6.0.2


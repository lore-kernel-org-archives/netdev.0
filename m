From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 12/15] be2net: fix be_suspend/resume/shutdown
Date: Fri, 11 Feb 2011 17:38:03 -0600
Message-ID: <20110211233803.GA18474@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51244 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758096Ab1BKXiZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:38:25 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	> call pci msix disable in be_suspend
	> call pci msix enable in be_resume
	> stop worker thread in be_suspend
	> start worker thread in be_resume
	> stop worker thread in be_shutdown

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 824d420..7e83c06 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -3023,6 +3023,7 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev =  adapter->netdev;
 
+	cancel_delayed_work_sync(&adapter->work);
 	if (adapter->wol)
 		be_setup_wol(adapter, true);
 
@@ -3035,6 +3036,7 @@ static int be_suspend(struct pci_dev *pdev, pm_message_t state)
 	be_cmd_get_flow_control(adapter, &adapter->tx_fc, &adapter->rx_fc);
 	be_clear(adapter);
 
+	be_msix_disable(adapter);
 	pci_save_state(pdev);
 	pci_disable_device(pdev);
 	pci_set_power_state(pdev, pci_choose_state(pdev, state));
@@ -3056,6 +3058,7 @@ static int be_resume(struct pci_dev *pdev)
 	pci_set_power_state(pdev, 0);
 	pci_restore_state(pdev);
 
+	be_msix_enable(adapter);
 	/* tell fw we're ready to fire cmds */
 	status = be_cmd_fw_init(adapter);
 	if (status)
@@ -3071,6 +3074,8 @@ static int be_resume(struct pci_dev *pdev)
 
 	if (adapter->wol)
 		be_setup_wol(adapter, false);
+
+	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 }
 
@@ -3082,6 +3087,9 @@ static void be_shutdown(struct pci_dev *pdev)
 	struct be_adapter *adapter = pci_get_drvdata(pdev);
 	struct net_device *netdev =  adapter->netdev;
 
+	if (netif_running(netdev))
+		cancel_delayed_work_sync(&adapter->work);
+
 	netif_device_detach(netdev);
 
 	be_cmd_reset_function(adapter);
-- 
1.7.1


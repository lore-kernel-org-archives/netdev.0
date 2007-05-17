From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH] ixgb: don't print error if pci_enable_msi() fails, cleanup minor leak
Date: Thu, 17 May 2007 15:29:07 -0700
Message-ID: <20070517222906.25352.31886.stgit@localhost.localdomain>
Content-Type: text/plain; charset=utf-8; format=fixed
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jesse.brandeburg@intel.com, john.ronciak@intel.com,
	jeffrey.t.kirsher@intel.com, cebbert@redhat.com, hpa@zytor.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:44027 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754630AbXEQW3I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 18:29:08 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Auke Kok <auke-jan.h.kok@intel.com>

pci_enable_msi calls can fail for normal operational reasons. Driver
should not print an error message in that case. Fix a leak that leaves
msi enabled if pci_request_irq fails. We can remove CONFIG_PCI_MSI
ifdefs alltogether

Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgb/ixgb.h      |    2 --
 drivers/net/ixgb/ixgb_main.c |   36 +++++++++++++++---------------------
 2 files changed, 15 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ixgb/ixgb.h b/drivers/net/ixgb/ixgb.h
index c8e9086..3569d5b 100644
--- a/drivers/net/ixgb/ixgb.h
+++ b/drivers/net/ixgb/ixgb.h
@@ -193,8 +193,6 @@ struct ixgb_adapter {
 	u16 msg_enable;
 	struct ixgb_hw_stats stats;
 	uint32_t alloc_rx_buff_failed;
-#ifdef CONFIG_PCI_MSI
 	boolean_t have_msi;
-#endif
 };
 #endif /* _IXGB_H_ */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index 6d2b059..991c883 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -227,7 +227,7 @@ int
 ixgb_up(struct ixgb_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	int err;
+	int err, irq_flags = IRQF_SHARED;
 	int max_frame = netdev->mtu + ENET_HEADER_SIZE + ENET_FCS_LENGTH;
 	struct ixgb_hw *hw = &adapter->hw;
 
@@ -246,26 +246,21 @@ ixgb_up(struct ixgb_adapter *adapter)
 	/* disable interrupts and get the hardware into a known state */
 	IXGB_WRITE_REG(&adapter->hw, IMC, 0xffffffff);
 
-#ifdef CONFIG_PCI_MSI
-	{
-	boolean_t pcix = (IXGB_READ_REG(&adapter->hw, STATUS) & 
-						  IXGB_STATUS_PCIX_MODE) ? TRUE : FALSE;
-	adapter->have_msi = TRUE;
-
-	if (!pcix)
-	   adapter->have_msi = FALSE;
-	else if((err = pci_enable_msi(adapter->pdev))) {
-		DPRINTK(PROBE, ERR,
-		 "Unable to allocate MSI interrupt Error: %d\n", err);
-		adapter->have_msi = FALSE;
+	/* only enable MSI if bus is in PCI-X mode */
+	if (IXGB_READ_REG(&adapter->hw, STATUS) & IXGB_STATUS_PCIX_MODE) {
+		err = pci_enable_msi(adapter->pdev);
+		if (!err) {
+			adapter->have_msi = 1;
+			irq_flags = 0;
+		}
 		/* proceed to try to request regular interrupt */
 	}
-	}
 
-#endif
-	if((err = request_irq(adapter->pdev->irq, &ixgb_intr,
-				  IRQF_SHARED | IRQF_SAMPLE_RANDOM,
-			          netdev->name, netdev))) {
+	err = request_irq(adapter->pdev->irq, &ixgb_intr, irq_flags,
+	                  netdev->name, netdev);
+	if (err) {
+		if (adapter->have_msi)
+			pci_disable_msi(adapter->pdev);
 		DPRINTK(PROBE, ERR,
 		 "Unable to allocate interrupt Error: %d\n", err);
 		return err;
@@ -307,11 +302,10 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
-#ifdef CONFIG_PCI_MSI
-	if(adapter->have_msi == TRUE)
+
+	if (adapter->have_msi)
 		pci_disable_msi(adapter->pdev);
 
-#endif
 	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
 #ifdef CONFIG_IXGB_NAPI

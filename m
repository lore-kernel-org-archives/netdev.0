From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 8/9] e1000e: Do not write lsc to ics in msi-x mode
Date: Mon, 14 Dec 2015 21:38:43 -0800
Message-ID: <1450157924-58901-9-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Benjamin Poirier <bpoirier@suse.com>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:59684 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751577AbbLOFiu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Dec 2015 00:38:50 -0500
In-Reply-To: <1450157924-58901-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin Poirier <bpoirier@suse.com>

In msi-x mode, there is no handler for the lsc interrupt so there is no
point in writing that to ics now that we always assume Other interrupts
are caused by lsc.

Reviewed-by: Jasna Hodzic <jhodzic@ucdavis.edu>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |  3 ++-
 drivers/net/ethernet/intel/e1000e/netdev.c  | 28 +++++++++++++++++-----------
 2 files changed, 19 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/defines.h b/drivers/net/ethernet/intel/e1000e/defines.h
index 133d407..f7c7804 100644
--- a/drivers/net/ethernet/intel/e1000e/defines.h
+++ b/drivers/net/ethernet/intel/e1000e/defines.h
@@ -441,12 +441,13 @@
 #define E1000_IMS_RXQ1      E1000_ICR_RXQ1      /* Rx Queue 1 Interrupt */
 #define E1000_IMS_TXQ0      E1000_ICR_TXQ0      /* Tx Queue 0 Interrupt */
 #define E1000_IMS_TXQ1      E1000_ICR_TXQ1      /* Tx Queue 1 Interrupt */
-#define E1000_IMS_OTHER     E1000_ICR_OTHER     /* Other Interrupts */
+#define E1000_IMS_OTHER     E1000_ICR_OTHER     /* Other Interrupt */
 
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
 #define E1000_ICS_RXSEQ     E1000_ICR_RXSEQ     /* Rx sequence error */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* Rx desc min. threshold */
+#define E1000_ICS_OTHER     E1000_ICR_OTHER     /* Other Interrupt */
 
 /* Transmit Descriptor Control */
 #define E1000_TXDCTL_PTHRESH 0x0000003F /* TXDCTL Prefetch Threshold */
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 56bc422..d59c0bc 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4132,10 +4132,24 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 }
 
-void e1000e_up(struct e1000_adapter *adapter)
+/**
+ * e1000e_trigger_lsc - trigger an LSC interrupt
+ * @adapter: 
+ *
+ * Fire a link status change interrupt to start the watchdog.
+ **/
+static void e1000e_trigger_lsc(struct e1000_adapter *adapter)
 {
 	struct e1000_hw *hw = &adapter->hw;
 
+	if (adapter->msix_entries)
+		ew32(ICS, E1000_ICS_OTHER);
+	else
+		ew32(ICS, E1000_ICS_LSC);
+}
+
+void e1000e_up(struct e1000_adapter *adapter)
+{
 	/* hardware has been reset, we need to reload some things */
 	e1000_configure(adapter);
 
@@ -4147,11 +4161,7 @@ void e1000e_up(struct e1000_adapter *adapter)
 
 	netif_start_queue(adapter->netdev);
 
-	/* fire a link change interrupt to start the watchdog */
-	if (adapter->msix_entries)
-		ew32(ICS, E1000_ICS_LSC | E1000_ICR_OTHER);
-	else
-		ew32(ICS, E1000_ICS_LSC);
+	e1000e_trigger_lsc(adapter);
 }
 
 static void e1000e_flush_descriptors(struct e1000_adapter *adapter)
@@ -4576,11 +4586,7 @@ static int e1000_open(struct net_device *netdev)
 	hw->mac.get_link_status = true;
 	pm_runtime_put(&pdev->dev);
 
-	/* fire a link status change interrupt to start the watchdog */
-	if (adapter->msix_entries)
-		ew32(ICS, E1000_ICS_LSC | E1000_ICR_OTHER);
-	else
-		ew32(ICS, E1000_ICS_LSC);
+	e1000e_trigger_lsc(adapter);
 
 	return 0;
 
-- 
2.5.0

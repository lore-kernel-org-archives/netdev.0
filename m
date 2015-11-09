From: Benjamin Poirier <bpoirier@suse.com>
Subject: [PATCH v3 3/4] e1000e: Do not write lsc to ics in msi-x mode
Date: Mon,  9 Nov 2015 15:50:20 -0800
Message-ID: <1447113021-1611-4-git-send-email-bpoirier@suse.com>
References: <1447113021-1611-1-git-send-email-bpoirier@suse.com>
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	Frank Steiner <steiner-reg@bio.ifi.lmu.de>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Shannon Nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447113021-1611-1-git-send-email-bpoirier@suse.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In msi-x mode, there is no handler for the lsc interrupt so there is no
point in writing that to ics now that we always assume Other interrupts
are caused by lsc.

Reviewed-by: Jasna Hodzic <jhodzic@ucdavis.edu>
Signed-off-by: Benjamin Poirier <bpoirier@suse.com>
---
 drivers/net/ethernet/intel/e1000e/defines.h |  3 ++-
 drivers/net/ethernet/intel/e1000e/netdev.c  | 27 ++++++++++++++++-----------
 2 files changed, 18 insertions(+), 12 deletions(-)

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
index a73e323..ed7cc8e 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4130,10 +4130,23 @@ void e1000e_reset(struct e1000_adapter *adapter)
 
 }
 
-int e1000e_up(struct e1000_adapter *adapter)
+/**
+ * e1000e_trigger_lsc - trigger an lsc interrupt
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
+int e1000e_up(struct e1000_adapter *adapter)
+{
 	/* hardware has been reset, we need to reload some things */
 	e1000_configure(adapter);
 
@@ -4145,11 +4158,7 @@ int e1000e_up(struct e1000_adapter *adapter)
 
 	netif_start_queue(adapter->netdev);
 
-	/* fire a link change interrupt to start the watchdog */
-	if (adapter->msix_entries)
-		ew32(ICS, E1000_ICS_LSC | E1000_ICR_OTHER);
-	else
-		ew32(ICS, E1000_ICS_LSC);
+	e1000e_trigger_lsc(adapter);
 
 	return 0;
 }
@@ -4576,11 +4585,7 @@ static int e1000_open(struct net_device *netdev)
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
2.6.2

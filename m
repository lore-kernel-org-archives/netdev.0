From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 05/15] ixgbe: extract PTP clock device from ptp_init
Date: Tue, 27 May 2014 02:12:21 -0700
Message-ID: <1401181951-31358-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17021 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752085AbaE0JMj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 May 2014 05:12:39 -0400
In-Reply-To: <1401181951-31358-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

In order to properly handle a suspend/resume cycle, we cannot destroy
the PTP clock device. As part of this, we should only re-create the
device on first initialization. After a resume, when ixgbe_ptp_init is
called, we won't create a new clock, and we will use the old clock
device. To that end, this patch extracts the clock creation out of
ptp_init, and only calls it if we don't already have a ptp_clock
pointer.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c | 56 +++++++++++++++++++++++-----
 1 file changed, 47 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
index 9d329f5..9df7e57 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
@@ -851,16 +851,23 @@ void ixgbe_ptp_reset(struct ixgbe_adapter *adapter)
 }
 
 /**
- * ixgbe_ptp_init
+ * ixgbe_ptp_create_clock
  * @adapter: the ixgbe private adapter structure
  *
- * This function performs the required steps for enabling ptp
- * support. If ptp support has already been loaded it simply calls the
- * cyclecounter init routine and exits.
+ * This function performs setup of the user entry point function table and
+ * initializes the PTP clock device, which is used to access the clock-like
+ * features of the PTP core. It will be called by ixgbe_ptp_init, only if
+ * there isn't already a clock device (such as after a suspend/resume cycle,
+ * where the clock device wasn't destroyed).
  */
-void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
+static int ixgbe_ptp_create_clock(struct ixgbe_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
+	long err;
+
+	/* do nothing if we already have a clock device */
+	if (!IS_ERR_OR_NULL(adapter->ptp_clock))
+		return 0;
 
 	switch (adapter->hw.mac.type) {
 	case ixgbe_mac_X540:
@@ -897,22 +904,53 @@ void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
 		break;
 	default:
 		adapter->ptp_clock = NULL;
-		return;
+		return -EOPNOTSUPP;
 	}
 
-	spin_lock_init(&adapter->tmreg_lock);
-	INIT_WORK(&adapter->ptp_tx_work, ixgbe_ptp_tx_hwtstamp_work);
-
 	adapter->ptp_clock = ptp_clock_register(&adapter->ptp_caps,
 						&adapter->pdev->dev);
 	if (IS_ERR(adapter->ptp_clock)) {
+		err = PTR_ERR(adapter->ptp_clock);
 		adapter->ptp_clock = NULL;
 		e_dev_err("ptp_clock_register failed\n");
+		return err;
 	} else
 		e_dev_info("registered PHC device on %s\n", netdev->name);
 
+	/* set default timestamp mode to disabled here. We do this in
+	 * create_clock instead of init, because we don't want to override the
+	 * previous settings during a resume cycle.
+	 */
 	adapter->tstamp_config.rx_filter = HWTSTAMP_FILTER_NONE;
 	adapter->tstamp_config.tx_type = HWTSTAMP_TX_OFF;
+
+	return 0;
+}
+
+/**
+ * ixgbe_ptp_init
+ * @adapter: the ixgbe private adapter structure
+ *
+ * This function performs the required steps for enabling PTP
+ * support. If PTP support has already been loaded it simply calls the
+ * cyclecounter init routine and exits.
+ */
+void ixgbe_ptp_init(struct ixgbe_adapter *adapter)
+{
+	/* initialize the spin lock first since we can't control when a user
+	 * will call the entry functions once we have initialized the clock
+	 * device
+	 */
+	spin_lock_init(&adapter->tmreg_lock);
+
+	/* obtain a PTP device, or re-use an existing device */
+	if (ixgbe_ptp_create_clock(adapter))
+		return;
+
+	/* we have a clock so we can initialize work now */
+	INIT_WORK(&adapter->ptp_tx_work, ixgbe_ptp_tx_hwtstamp_work);
+
+	/* reset the PTP related hardware bits */
 	ixgbe_ptp_reset(adapter);
 
 	/* enter the IXGBE_PTP_RUNNING state */
-- 
1.9.3

From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 5/8] e1000e: call ndo_stop() instead of dev_close() when running offline selftest
Date: Wed,  6 Apr 2016 21:37:30 -0700
Message-ID: <1460003853-133949-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:18813 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752075AbcDGEhh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Apr 2016 00:37:37 -0400
In-Reply-To: <1460003853-133949-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Assmann <sassmann@kpanic.de>

Calling dev_close() causes IFF_UP to be cleared which will remove the
interfaces routes and some addresses. That's probably not what the user
intended when running the offline selftest. Besides this does not happen
if the interface is brought down before the test, so the current
behaviour is inconsistent.
Instead call the net_device_ops ndo_stop function directly and avoid
touching IFF_UP at all.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   |  2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c |  4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c  | 12 ++++++------
 3 files changed, 10 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 1dc293b..52eb641 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -480,6 +480,8 @@ extern const char e1000e_driver_version[];
 void e1000e_check_options(struct e1000_adapter *adapter);
 void e1000e_set_ethtool_ops(struct net_device *netdev);
 
+int e1000e_open(struct net_device *netdev);
+int e1000e_close(struct net_device *netdev);
 void e1000e_up(struct e1000_adapter *adapter);
 void e1000e_down(struct e1000_adapter *adapter, bool reset);
 void e1000e_reinit_locked(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 6cab1f3..1e3973a 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1816,7 +1816,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			e1000e_close(netdev);
 
 		if (e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1849,7 +1849,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		clear_bit(__E1000_TESTING, &adapter->state);
 		if (if_running)
-			dev_open(netdev);
+			e1000e_open(netdev);
 	} else {
 		/* Online tests */
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 9b4ec13..a7f16c3 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4495,7 +4495,7 @@ static int e1000_test_msi(struct e1000_adapter *adapter)
 }
 
 /**
- * e1000_open - Called when a network interface is made active
+ * e1000e_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
  * Returns 0 on success, negative value on failure
@@ -4506,7 +4506,7 @@ static int e1000_test_msi(struct e1000_adapter *adapter)
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
  **/
-static int e1000_open(struct net_device *netdev)
+int e1000e_open(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -4604,7 +4604,7 @@ err_setup_tx:
 }
 
 /**
- * e1000_close - Disables a network interface
+ * e1000e_close - Disables a network interface
  * @netdev: network interface device structure
  *
  * Returns 0, this is not allowed to fail
@@ -4614,7 +4614,7 @@ err_setup_tx:
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int e1000_close(struct net_device *netdev)
+int e1000e_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev = adapter->pdev;
@@ -6920,8 +6920,8 @@ static int e1000_set_features(struct net_device *netdev,
 }
 
 static const struct net_device_ops e1000e_netdev_ops = {
-	.ndo_open		= e1000_open,
-	.ndo_stop		= e1000_close,
+	.ndo_open		= e1000e_open,
+	.ndo_stop		= e1000e_close,
 	.ndo_start_xmit		= e1000_xmit_frame,
 	.ndo_get_stats64	= e1000e_get_stats64,
 	.ndo_set_rx_mode	= e1000e_set_rx_mode,
-- 
2.5.5

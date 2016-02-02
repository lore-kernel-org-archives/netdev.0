From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next 6/6] e1000e: call ndo_stop() instead of dev_close() when running offline selftest
Date: Tue,  2 Feb 2016 11:13:48 +0100
Message-ID: <1454408028-16986-7-git-send-email-sassmann@kpanic.de>
References: <1454408028-16986-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37801 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754487AbcBBKQf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 05:16:35 -0500
In-Reply-To: <1454408028-16986-1-git-send-email-sassmann@kpanic.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Calling dev_close() causes IFF_UP to be cleared which will remove the
interfaces routes and some addresses. That's probably not what the user
intended when running the offline selftest. Besides this does not happen
if the interface is brought down before the test, so the current
behaviour is inconsistent.
Instead call the net_device_ops ndo_stop function directly and avoid
touching IFF_UP at all.

Signed-off-by: Stefan Assmann <sassmann@kpanic.de>
---
 drivers/net/ethernet/intel/e1000e/e1000.h   | 2 ++
 drivers/net/ethernet/intel/e1000e/ethtool.c | 4 ++--
 drivers/net/ethernet/intel/e1000e/netdev.c  | 4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 1dc293b..3037ef8 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -480,6 +480,8 @@ extern const char e1000e_driver_version[];
 void e1000e_check_options(struct e1000_adapter *adapter);
 void e1000e_set_ethtool_ops(struct net_device *netdev);
 
+int e1000_open(struct net_device *netdev);
+int e1000_close(struct net_device *netdev);
 void e1000e_up(struct e1000_adapter *adapter);
 void e1000e_down(struct e1000_adapter *adapter, bool reset);
 void e1000e_reinit_locked(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c b/drivers/net/ethernet/intel/e1000e/ethtool.c
index 6cab1f3..16dc537 100644
--- a/drivers/net/ethernet/intel/e1000e/ethtool.c
+++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
@@ -1816,7 +1816,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			e1000_close(netdev);
 
 		if (e1000_reg_test(adapter, &data[0]))
 			eth_test->flags |= ETH_TEST_FL_FAILED;
@@ -1849,7 +1849,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		clear_bit(__E1000_TESTING, &adapter->state);
 		if (if_running)
-			dev_open(netdev);
+			e1000_open(netdev);
 	} else {
 		/* Online tests */
 
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index c71ba1b..f408c58 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -4506,7 +4506,7 @@ static int e1000_test_msi(struct e1000_adapter *adapter)
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
  **/
-static int e1000_open(struct net_device *netdev)
+int e1000_open(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -4614,7 +4614,7 @@ err_setup_tx:
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int e1000_close(struct net_device *netdev)
+int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev = adapter->pdev;
-- 
2.5.0

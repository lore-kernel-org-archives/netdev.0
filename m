From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 05/11] ixgbe: call ndo_stop() instead of dev_close() when running offline selftest
Date: Wed, 30 Mar 2016 16:00:49 -0700
Message-ID: <1459378855-139837-6-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:49527 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755313AbcC3XBT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Mar 2016 19:01:19 -0400
In-Reply-To: <1459378855-139837-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/ixgbe/ixgbe.h         | 2 ++
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index 458549c..e4949af 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -877,6 +877,8 @@ extern const char ixgbe_driver_version[];
 extern char ixgbe_default_device_descr[];
 #endif /* IXGBE_FCOE */
 
+int ixgbe_open(struct net_device *netdev);
+int ixgbe_close(struct net_device *netdev);
 void ixgbe_up(struct ixgbe_adapter *adapter);
 void ixgbe_down(struct ixgbe_adapter *adapter);
 void ixgbe_reinit_locked(struct ixgbe_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 726e0ee..b3530e1 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2053,7 +2053,7 @@ static void ixgbe_diag_test(struct net_device *netdev,
 
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			ixgbe_close(netdev);
 		else
 			ixgbe_reset(adapter);
 
@@ -2091,7 +2091,7 @@ skip_loopback:
 		/* clear testing bit and return adapter to previous state */
 		clear_bit(__IXGBE_TESTING, &adapter->state);
 		if (if_running)
-			dev_open(netdev);
+			ixgbe_open(netdev);
 		else if (hw->mac.ops.disable_tx_laser)
 			hw->mac.ops.disable_tx_laser(hw);
 	} else {
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index ee81618..267a507 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -5992,7 +5992,7 @@ static int ixgbe_change_mtu(struct net_device *netdev, int new_mtu)
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
  **/
-static int ixgbe_open(struct net_device *netdev)
+int ixgbe_open(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -6094,7 +6094,7 @@ static void ixgbe_close_suspend(struct ixgbe_adapter *adapter)
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int ixgbe_close(struct net_device *netdev)
+int ixgbe_close(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-- 
2.5.5

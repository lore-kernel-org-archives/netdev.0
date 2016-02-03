From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next V2 3/6] ixgbevf: call ndo_stop() instead of dev_close() when running offline selftest
Date: Wed,  3 Feb 2016 09:20:49 +0100
Message-ID: <1454487652-1545-4-git-send-email-sassmann@kpanic.de>
References: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40359 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933781AbcBCIVr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 03:21:47 -0500
In-Reply-To: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>
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
 drivers/net/ethernet/intel/ixgbevf/ethtool.c      | 4 ++--
 drivers/net/ethernet/intel/ixgbevf/ixgbevf.h      | 2 ++
 drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 4 ++--
 3 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/intel/ixgbevf/ethtool.c b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
index c48aef6..d7aa4b2 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ethtool.c
@@ -680,7 +680,7 @@ static void ixgbevf_diag_test(struct net_device *netdev,
 
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			ixgbevf_close(netdev);
 		else
 			ixgbevf_reset(adapter);
 
@@ -692,7 +692,7 @@ static void ixgbevf_diag_test(struct net_device *netdev,
 
 		clear_bit(__IXGBEVF_TESTING, &adapter->state);
 		if (if_running)
-			dev_open(netdev);
+			ixgbevf_open(netdev);
 	} else {
 		hw_dbg(&adapter->hw, "online testing starting\n");
 		/* Online tests */
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
index 68ec7daa..991eeae 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf.h
@@ -486,6 +486,8 @@ extern const struct ixgbe_mbx_operations ixgbevf_mbx_ops;
 extern const char ixgbevf_driver_name[];
 extern const char ixgbevf_driver_version[];
 
+int ixgbevf_open(struct net_device *netdev);
+int ixgbevf_close(struct net_device *netdev);
 void ixgbevf_up(struct ixgbevf_adapter *adapter);
 void ixgbevf_down(struct ixgbevf_adapter *adapter);
 void ixgbevf_reinit_locked(struct ixgbevf_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
index 3558f01..01f79fa 100644
--- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
+++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
@@ -3122,7 +3122,7 @@ static void ixgbevf_free_all_rx_resources(struct ixgbevf_adapter *adapter)
  * handler is registered with the OS, the watchdog timer is started,
  * and the stack is notified that the interface is ready.
  **/
-static int ixgbevf_open(struct net_device *netdev)
+int ixgbevf_open(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 	struct ixgbe_hw *hw = &adapter->hw;
@@ -3205,7 +3205,7 @@ err_setup_reset:
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int ixgbevf_close(struct net_device *netdev)
+int ixgbevf_close(struct net_device *netdev)
 {
 	struct ixgbevf_adapter *adapter = netdev_priv(netdev);
 
-- 
2.5.0

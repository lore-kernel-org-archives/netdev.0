From: Stefan Assmann <sassmann@kpanic.de>
Subject: [PATCH net-next V2 5/6] e1000: call ndo_stop() instead of dev_close() when running offline selftest
Date: Wed,  3 Feb 2016 09:20:51 +0100
Message-ID: <1454487652-1545-6-git-send-email-sassmann@kpanic.de>
References: <1454487652-1545-1-git-send-email-sassmann@kpanic.de>
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, sassmann@kpanic.de
To: intel-wired-lan@lists.osuosl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52044 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964791AbcBCIVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Feb 2016 03:21:50 -0500
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
 drivers/net/ethernet/intel/e1000/e1000.h         | 2 ++
 drivers/net/ethernet/intel/e1000/e1000_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/e1000/e1000_main.c    | 8 ++++----
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000/e1000.h b/drivers/net/ethernet/intel/e1000/e1000.h
index 98fe5a2..d7bdea7 100644
--- a/drivers/net/ethernet/intel/e1000/e1000.h
+++ b/drivers/net/ethernet/intel/e1000/e1000.h
@@ -358,6 +358,8 @@ struct net_device *e1000_get_hw_dev(struct e1000_hw *hw);
 extern char e1000_driver_name[];
 extern const char e1000_driver_version[];
 
+int e1000_open(struct net_device *netdev);
+int e1000_close(struct net_device *netdev);
 int e1000_up(struct e1000_adapter *adapter);
 void e1000_down(struct e1000_adapter *adapter);
 void e1000_reinit_locked(struct e1000_adapter *adapter);
diff --git a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
index 83e557c..975eeb8 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_ethtool.c
@@ -1553,7 +1553,7 @@ static void e1000_diag_test(struct net_device *netdev,
 
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			e1000_close(netdev);
 		else
 			e1000_reset(adapter);
 
@@ -1582,7 +1582,7 @@ static void e1000_diag_test(struct net_device *netdev,
 		e1000_reset(adapter);
 		clear_bit(__E1000_TESTING, &adapter->flags);
 		if (if_running)
-			dev_open(netdev);
+			e1000_open(netdev);
 	} else {
 		e_info(hw, "online testing starting\n");
 		/* Online tests */
diff --git a/drivers/net/ethernet/intel/e1000/e1000_main.c b/drivers/net/ethernet/intel/e1000/e1000_main.c
index 3fc7bde..6de0c7d 100644
--- a/drivers/net/ethernet/intel/e1000/e1000_main.c
+++ b/drivers/net/ethernet/intel/e1000/e1000_main.c
@@ -114,8 +114,8 @@ static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void e1000_remove(struct pci_dev *pdev);
 static int e1000_alloc_queues(struct e1000_adapter *adapter);
 static int e1000_sw_init(struct e1000_adapter *adapter);
-static int e1000_open(struct net_device *netdev);
-static int e1000_close(struct net_device *netdev);
+int e1000_open(struct net_device *netdev);
+int e1000_close(struct net_device *netdev);
 static void e1000_configure_tx(struct e1000_adapter *adapter);
 static void e1000_configure_rx(struct e1000_adapter *adapter);
 static void e1000_setup_rctl(struct e1000_adapter *adapter);
@@ -1360,7 +1360,7 @@ static int e1000_alloc_queues(struct e1000_adapter *adapter)
  * handler is registered with the OS, the watchdog task is started,
  * and the stack is notified that the interface is ready.
  **/
-static int e1000_open(struct net_device *netdev)
+int e1000_open(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
@@ -1437,7 +1437,7 @@ err_setup_tx:
  * needs to be disabled.  A global MAC reset is issued to stop the
  * hardware, and all transmit and receive resources are freed.
  **/
-static int e1000_close(struct net_device *netdev)
+int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
-- 
2.5.0

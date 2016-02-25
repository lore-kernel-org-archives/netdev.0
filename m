From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next v2 15/15] igb: call ndo_stop() instead of dev_close() when running offline selftest
Date: Wed, 24 Feb 2016 18:15:02 -0800
Message-ID: <1456366502-132841-16-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Stefan Assmann <sassmann@kpanic.de>, netdev@vger.kernel.org,
	nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36780 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759310AbcBYC0E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Feb 2016 21:26:04 -0500
In-Reply-To: <1456366502-132841-1-git-send-email-jeffrey.t.kirsher@intel.com>
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
 drivers/net/ethernet/intel/igb/igb.h         | 2 ++
 drivers/net/ethernet/intel/igb/igb_ethtool.c | 4 ++--
 drivers/net/ethernet/intel/igb/igb_main.c    | 8 ++++----
 3 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index 707ae5c..9413fa6 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -510,6 +510,8 @@ enum igb_boards {
 extern char igb_driver_name[];
 extern char igb_driver_version[];
 
+int igb_open(struct net_device *netdev);
+int igb_close(struct net_device *netdev);
 int igb_up(struct igb_adapter *);
 void igb_down(struct igb_adapter *);
 void igb_reinit_locked(struct igb_adapter *);
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 1d329f1..7982243 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2017,7 +2017,7 @@ static void igb_diag_test(struct net_device *netdev,
 
 		if (if_running)
 			/* indicate we're in test mode */
-			dev_close(netdev);
+			igb_close(netdev);
 		else
 			igb_reset(adapter);
 
@@ -2050,7 +2050,7 @@ static void igb_diag_test(struct net_device *netdev,
 
 		clear_bit(__IGB_TESTING, &adapter->state);
 		if (if_running)
-			dev_open(netdev);
+			igb_open(netdev);
 	} else {
 		dev_info(&adapter->pdev->dev, "online testing starting\n");
 
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index 3b56f80..834b1b6 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -122,8 +122,8 @@ static void igb_setup_mrqc(struct igb_adapter *);
 static int igb_probe(struct pci_dev *, const struct pci_device_id *);
 static void igb_remove(struct pci_dev *pdev);
 static int igb_sw_init(struct igb_adapter *);
-static int igb_open(struct net_device *);
-static int igb_close(struct net_device *);
+int igb_open(struct net_device *);
+int igb_close(struct net_device *);
 static void igb_configure(struct igb_adapter *);
 static void igb_configure_tx(struct igb_adapter *);
 static void igb_configure_rx(struct igb_adapter *);
@@ -3172,7 +3172,7 @@ err_setup_tx:
 	return err;
 }
 
-static int igb_open(struct net_device *netdev)
+int igb_open(struct net_device *netdev)
 {
 	return __igb_open(netdev, false);
 }
@@ -3209,7 +3209,7 @@ static int __igb_close(struct net_device *netdev, bool suspending)
 	return 0;
 }
 
-static int igb_close(struct net_device *netdev)
+int igb_close(struct net_device *netdev)
 {
 	return __igb_close(netdev, false);
 }
-- 
2.5.0

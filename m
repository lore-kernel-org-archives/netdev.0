From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net 2/3] e1000e: prevent oops when adapter is being closed and reset simultaneously
Date: Tue,  3 Apr 2012 15:28:58 -0700
Message-ID: <1333492139-32697-3-git-send-email-jeffrey.t.kirsher@intel.com>
References: <1333492139-32697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Bruce Allan <bruce.w.allan@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:28712 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755581Ab2DCW3D (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 18:29:03 -0400
In-Reply-To: <1333492139-32697-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

When the adapter is closed while it is simultaneously going through a
reset, it can cause a null-pointer dereference when the two different code
paths simultaneously cleanup up the Tx/Rx resources.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Tested-by: Aaron Brown <aaron.f.brown@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  |    6 ++++++
 drivers/net/ethernet/intel/e1000e/netdev.c |    9 +++++++++
 2 files changed, 15 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index 86cdd47..b83897f 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -161,6 +161,12 @@ struct e1000_info;
 /* Time to wait before putting the device into D3 if there's no link (in ms). */
 #define LINK_TIMEOUT		100
 
+/*
+ * Count for polling __E1000_RESET condition every 10-20msec.
+ * Experimentation has shown the reset can take approximately 210msec.
+ */
+#define E1000_CHECK_RESET_COUNT		25
+
 #define DEFAULT_RDTR			0
 #define DEFAULT_RADV			8
 #define BURST_RDTR			0x20
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 2c38a65..6878601 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3968,6 +3968,10 @@ static int e1000_close(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct pci_dev *pdev = adapter->pdev;
+	int count = E1000_CHECK_RESET_COUNT;
+
+	while (test_bit(__E1000_RESETTING, &adapter->state) && count--)
+		usleep_range(10000, 20000);
 
 	WARN_ON(test_bit(__E1000_RESETTING, &adapter->state));
 
@@ -5472,6 +5476,11 @@ static int __e1000_shutdown(struct pci_dev *pdev, bool *enable_wake,
 	netif_device_detach(netdev);
 
 	if (netif_running(netdev)) {
+		int count = E1000_CHECK_RESET_COUNT;
+
+		while (test_bit(__E1000_RESETTING, &adapter->state) && count--)
+			usleep_range(10000, 20000);
+
 		WARN_ON(test_bit(__E1000_RESETTING, &adapter->state));
 		e1000e_down(adapter);
 		e1000_free_irq(adapter);
-- 
1.7.7.6

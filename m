From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/2 net-next] e1000e: Move pm_qos_req to e1000e adapter
Date: Fri, 10 Apr 2015 15:52:37 +0200
Message-ID: <5c4f0f5fc93592d2b4bce2cd7dd494a52a2e19f8.1428672434.git.tgraf@suug.ch>
References: <cover.1428672434.git.tgraf@suug.ch>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com,
	daniel@iogearbox.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33614 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934366AbbDJNws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2015 09:52:48 -0400
In-Reply-To: <cover.1428672434.git.tgraf@suug.ch>
In-Reply-To: <cover.1428672434.git.tgraf@suug.ch>
References: <cover.1428672434.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000e is the only driver requiring pm_qos_req, instead of causing
every device to waste up to 240 bytes. Allocate it for the specific
driver.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/ethernet/intel/e1000e/e1000.h  | 1 +
 drivers/net/ethernet/intel/e1000e/netdev.c | 8 ++++----
 include/linux/netdevice.h                  | 1 -
 3 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
index a69f09e..5d9ceb1 100644
--- a/drivers/net/ethernet/intel/e1000e/e1000.h
+++ b/drivers/net/ethernet/intel/e1000e/e1000.h
@@ -343,6 +343,7 @@ struct e1000_adapter {
 	struct timecounter tc;
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_clock_info;
+	struct pm_qos_request pm_qos_req;
 
 	u16 eee_advert;
 };
diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 74ec185..c509a5c 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3297,9 +3297,9 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			ew32(RXDCTL(0), rxdctl | 0x3);
 		}
 
-		pm_qos_update_request(&adapter->netdev->pm_qos_req, lat);
+		pm_qos_update_request(&adapter->pm_qos_req, lat);
 	} else {
-		pm_qos_update_request(&adapter->netdev->pm_qos_req,
+		pm_qos_update_request(&adapter->pm_qos_req,
 				      PM_QOS_DEFAULT_VALUE);
 	}
 
@@ -4403,7 +4403,7 @@ static int e1000_open(struct net_device *netdev)
 		e1000_update_mng_vlan(adapter);
 
 	/* DMA latency requirement to workaround jumbo issue */
-	pm_qos_add_request(&adapter->netdev->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
+	pm_qos_add_request(&adapter->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
 			   PM_QOS_DEFAULT_VALUE);
 
 	/* before we allocate an interrupt, we must be ready to handle it.
@@ -4514,7 +4514,7 @@ static int e1000_close(struct net_device *netdev)
 	    !test_bit(__E1000_TESTING, &adapter->state))
 		e1000e_release_hw_control(adapter);
 
-	pm_qos_remove_request(&adapter->netdev->pm_qos_req);
+	pm_qos_remove_request(&adapter->pm_qos_req);
 
 	pm_runtime_put_sync(&pdev->dev);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bf6d9df..d66c0f9 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1743,7 +1743,6 @@ struct net_device {
 #endif
 	struct phy_device *phydev;
 	struct lock_class_key *qdisc_tx_busylock;
-	struct pm_qos_request	pm_qos_req;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
-- 
1.9.3

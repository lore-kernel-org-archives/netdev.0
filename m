From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH 1/3 net-next] e1000: Allocate pm_qos_req as needed
Date: Fri, 10 Apr 2015 01:43:26 +0200
Message-ID: <99ad8b242a65a60e2a76e952b4c91de2b54a0013.1428622095.git.tgraf@suug.ch>
References: <cover.1428622095.git.tgraf@suug.ch>
Cc: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:56815 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754245AbbDIXnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Apr 2015 19:43:41 -0400
In-Reply-To: <cover.1428622095.git.tgraf@suug.ch>
In-Reply-To: <cover.1428622095.git.tgraf@suug.ch>
References: <cover.1428622095.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

e1000 is the only driver requiring pm_qos_req, instead of causing
every device to waste up to 240 bytes. Allocate it for the specific
driver.

Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
 drivers/net/ethernet/intel/e1000e/netdev.c | 15 +++++++++++----
 include/linux/netdevice.h                  |  2 +-
 2 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
index 74ec185..ae9f6ed 100644
--- a/drivers/net/ethernet/intel/e1000e/netdev.c
+++ b/drivers/net/ethernet/intel/e1000e/netdev.c
@@ -3297,9 +3297,9 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
 			ew32(RXDCTL(0), rxdctl | 0x3);
 		}
 
-		pm_qos_update_request(&adapter->netdev->pm_qos_req, lat);
+		pm_qos_update_request(adapter->netdev->pm_qos_req, lat);
 	} else {
-		pm_qos_update_request(&adapter->netdev->pm_qos_req,
+		pm_qos_update_request(adapter->netdev->pm_qos_req,
 				      PM_QOS_DEFAULT_VALUE);
 	}
 
@@ -4402,8 +4402,12 @@ static int e1000_open(struct net_device *netdev)
 	if ((adapter->hw.mng_cookie.status & E1000_MNG_DHCP_COOKIE_STATUS_VLAN))
 		e1000_update_mng_vlan(adapter);
 
+	netdev->pm_qos_req = kzalloc(sizeof(struct pm_qos_request), GFP_KERNEL);
+	if (!netdev->pm_qos_req)
+		goto err_pm_qos_req;
+
 	/* DMA latency requirement to workaround jumbo issue */
-	pm_qos_add_request(&adapter->netdev->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
+	pm_qos_add_request(adapter->netdev->pm_qos_req, PM_QOS_CPU_DMA_LATENCY,
 			   PM_QOS_DEFAULT_VALUE);
 
 	/* before we allocate an interrupt, we must be ready to handle it.
@@ -4451,6 +4455,8 @@ static int e1000_open(struct net_device *netdev)
 	return 0;
 
 err_req_irq:
+	kfree(netdev->pm_qos_req);
+err_pm_qos_req:
 	e1000e_release_hw_control(adapter);
 	e1000_power_down_phy(adapter);
 	e1000e_free_rx_resources(adapter->rx_ring);
@@ -4514,7 +4520,8 @@ static int e1000_close(struct net_device *netdev)
 	    !test_bit(__E1000_TESTING, &adapter->state))
 		e1000e_release_hw_control(adapter);
 
-	pm_qos_remove_request(&adapter->netdev->pm_qos_req);
+	pm_qos_remove_request(adapter->netdev->pm_qos_req);
+	kfree(adapter->netdev->pm_qos_req);
 
 	pm_runtime_put_sync(&pdev->dev);
 
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bf6d9df..4653422 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1743,7 +1743,7 @@ struct net_device {
 #endif
 	struct phy_device *phydev;
 	struct lock_class_key *qdisc_tx_busylock;
-	struct pm_qos_request	pm_qos_req;
+	struct pm_qos_request *pm_qos_req;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
-- 
1.9.3

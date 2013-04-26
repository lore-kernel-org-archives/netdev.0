From: Shahed Shaikh <shahed.shaikh@qlogic.com>
Subject: [PATCH net 2/7] qlcnic: Fix bug in tuning offloads using QLogic application
Date: Fri, 26 Apr 2013 08:09:38 -0400
Message-ID: <1366978183-7282-3-git-send-email-shahed.shaikh@qlogic.com>
References: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Manish Chopra <manish.chopra@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [216.32.180.187] ([216.32.180.187]:37659 "EHLO
	co1outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756334Ab3DZMfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Apr 2013 08:35:19 -0400
In-Reply-To: <1366978183-7282-1-git-send-email-shahed.shaikh@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manish Chopra <manish.chopra@qlogic.com>

o LRO was not getting disabled when disabling checksum offloads
  using QLogic application.
o LRO was not getting re-enabled while enabling checksum offloads
  back

Signed-off-by: Manish Chopra <manish.chopra@qlogic.com>
Signed-off-by: Shahed Shaikh <shahed.shaikh@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic.h      |    1 +
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c |   19 +++++++++++++++++--
 2 files changed, 18 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
index ba3c72f..fe82fbf 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic.h
@@ -896,6 +896,7 @@ struct qlcnic_ipaddr {
 #define QLCNIC_FW_RESET_OWNER		0x2000
 #define QLCNIC_FW_HANG			0x4000
 #define QLCNIC_FW_LRO_MSS_CAP		0x8000
+#define QLCNIC_LRO_WAS_ENABLED		0x20000
 #define QLCNIC_IS_MSI_FAMILY(adapter) \
 	((adapter)->flags & (QLCNIC_MSI_ENABLED | QLCNIC_MSIX_ENABLED))
 
diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
index 8f4ce11..e387bf8 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_main.c
@@ -975,7 +975,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 		struct qlcnic_esw_func_cfg *esw_cfg)
 {
 	struct net_device *netdev = adapter->netdev;
-	unsigned long features, vlan_features;
+	netdev_features_t features, vlan_features;
 
 	if (qlcnic_83xx_check(adapter))
 		return;
@@ -994,8 +994,14 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 		features |= NETIF_F_LRO;
 
 	if (esw_cfg->offload_flags & BIT_0) {
-		netdev->features |= features;
 		adapter->rx_csum = 1;
+		if (adapter->flags & QLCNIC_LRO_WAS_ENABLED) {
+			if (qlcnic_config_hw_lro(adapter, QLCNIC_LRO_ENABLED))
+				return;
+			netdev_info(netdev, "Enabling LRO as Rx checksum is on\n");
+			netdev->features |= NETIF_F_LRO;
+		}
+		netdev->features |= features;
 		if (!(esw_cfg->offload_flags & BIT_1)) {
 			netdev->features &= ~NETIF_F_TSO;
 			features &= ~NETIF_F_TSO;
@@ -1005,6 +1011,15 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *adapter,
 			features &= ~NETIF_F_TSO6;
 		}
 	} else {
+		if (netdev->features & NETIF_F_LRO) {
+			if (qlcnic_config_hw_lro(adapter, QLCNIC_LRO_DISABLED))
+				return;
+
+			if (qlcnic_82xx_check(adapter))
+				qlcnic_send_lro_cleanup(adapter);
+			netdev_info(netdev, "Disabling LRO as rx_csum is off\n");
+			adapter->flags |= QLCNIC_LRO_WAS_ENABLED;
+		}
 		netdev->features &= ~features;
 		features &= ~features;
 		adapter->rx_csum = 0;
-- 
1.5.6

From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv1 NEXT 7/7] qlcnic: turn off lro when rxcsum is disabled.
Date: Thu, 12 Aug 2010 04:28:47 -0700
Message-ID: <1281612527-27838-8-git-send-email-amit.salecha@qlogic.com>
References: <1281612527-27838-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	Sucheta Chakraborty <sucheta@dut4145.unminc.com>,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:41756 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1759869Ab0HLL2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Aug 2010 07:28:49 -0400
In-Reply-To: <1281612527-27838-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta@dut4145.unminc.com>

o Also dont allow lro to be turn on, if rx csum is disabled

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic.h         |    1 +
 drivers/net/qlcnic/qlcnic_ethtool.c |   23 +++++++++++++++++++++++
 drivers/net/qlcnic/qlcnic_main.c    |    2 +-
 3 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index 7f4e11b..f6b887d 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -894,6 +894,7 @@ struct qlcnic_mac_req {
 #define QLCNIC_MSI_ENABLED		0x02
 #define QLCNIC_MSIX_ENABLED		0x04
 #define QLCNIC_LRO_ENABLED		0x08
+#define QLCNIC_LRO_DISABLED		0x00
 #define QLCNIC_BRIDGE_ENABLED       	0X10
 #define QLCNIC_DIAG_ENABLED		0x20
 #define QLCNIC_ESWITCH_ENABLED		0x40
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 3d4655d..e655aa1 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -818,7 +818,21 @@ static u32 qlcnic_get_rx_csum(struct net_device *dev)
 static int qlcnic_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct qlcnic_adapter *adapter = netdev_priv(dev);
+
+	if (!!data) {
+		adapter->rx_csum = !!data;
+		return 0;
+	}
+
+	if (adapter->flags & QLCNIC_LRO_ENABLED) {
+		if (qlcnic_config_hw_lro(adapter, QLCNIC_LRO_DISABLED))
+			return -EIO;
+
+		dev->features &= ~NETIF_F_LRO;
+		qlcnic_send_lro_cleanup(adapter);
+	}
 	adapter->rx_csum = !!data;
+	dev_info(&adapter->pdev->dev, "disabling LRO as rx_csum is off\n");
 	return 0;
 }
 
@@ -1001,6 +1015,15 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
 	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
 		return -EINVAL;
 
+	if (!adapter->rx_csum) {
+		dev_info(&adapter->pdev->dev, "rx csum is off, "
+			"cannot toggle lro\n");
+		return -EINVAL;
+	}
+
+	if ((data & ETH_FLAG_LRO) == (adapter->flags & QLCNIC_LRO_ENABLED))
+		return 0;
+
 	if (data & ETH_FLAG_LRO) {
 		hw_lro = QLCNIC_LRO_ENABLED;
 		netdev->features |= NETIF_F_LRO;
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 28985a9..92385e7 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -985,7 +985,7 @@ __qlcnic_up(struct qlcnic_adapter *adapter, struct net_device *netdev)
 
 	qlcnic_config_intr_coalesce(adapter);
 
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
+	if (netdev->features & NETIF_F_LRO)
 		qlcnic_config_hw_lro(adapter, QLCNIC_LRO_ENABLED);
 
 	qlcnic_napi_enable(adapter);
-- 
1.6.0.2


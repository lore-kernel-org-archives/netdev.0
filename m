From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCH NEXT 3/7] qlcnic: remove private LRO flag
Date: Fri,  8 Oct 2010 02:46:07 -0700
Message-ID: <1286531171-21173-4-git-send-email-amit.salecha@qlogic.com>
References: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:45180 "HELO unm84.unmin.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1754611Ab0JHJqM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Oct 2010 05:46:12 -0400
In-Reply-To: <1286531171-21173-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

LRO was not getting enable after interface down/up.

Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/qlcnic/qlcnic_ethtool.c |    4 ++--
 drivers/net/qlcnic/qlcnic_hw.c      |    5 -----
 drivers/net/qlcnic/qlcnic_main.c    |    2 --
 3 files changed, 2 insertions(+), 9 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/qlcnic_ethtool.c
index 0181301..e07adb1 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -865,7 +865,7 @@ static int qlcnic_set_rx_csum(struct net_device *dev, u32 data)
 		return 0;
 	}
 
-	if (adapter->flags & QLCNIC_LRO_ENABLED) {
+	if (dev->features & NETIF_F_LRO) {
 		if (qlcnic_config_hw_lro(adapter, QLCNIC_LRO_DISABLED))
 			return -EIO;
 
@@ -1062,7 +1062,7 @@ static int qlcnic_set_flags(struct net_device *netdev, u32 data)
 		return -EINVAL;
 	}
 
-	if ((data & ETH_FLAG_LRO) && (adapter->flags & QLCNIC_LRO_ENABLED))
+	if ((data & ETH_FLAG_LRO) && (netdev->features & NETIF_F_LRO))
 		return 0;
 
 	if (data & ETH_FLAG_LRO) {
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic_hw.c
index 9d3e16d..7f1f9b4 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -582,9 +582,6 @@ int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 	u64 word;
 	int rv;
 
-	if ((adapter->flags & QLCNIC_LRO_ENABLED) == enable)
-		return 0;
-
 	memset(&req, 0, sizeof(struct qlcnic_nic_req));
 
 	req.qhdr = cpu_to_le64(QLCNIC_HOST_REQUEST << 23);
@@ -599,8 +596,6 @@ int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable)
 		dev_err(&adapter->netdev->dev,
 			"Could not send configure hw lro request\n");
 
-	adapter->flags ^= QLCNIC_LRO_ENABLED;
-
 	return rv;
 }
 
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcnic_main.c
index 9b0acfb..e3c1b80 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -657,8 +657,6 @@ qlcnic_check_options(struct qlcnic_adapter *adapter)
 	dev_info(&pdev->dev, "firmware v%d.%d.%d\n",
 			fw_major, fw_minor, fw_build);
 
-	adapter->flags &= ~QLCNIC_LRO_ENABLED;
-
 	if (adapter->ahw.port_type == QLCNIC_XGBE) {
 		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_10G;
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
-- 
1.6.0.2


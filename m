From: Amit Kumar Salecha <amit.salecha@qlogic.com>
Subject: [PATCHv2 NEXT 1/2] netxen: enable LRO based on NETIF_F_LRO
Date: Sun,  2 Jan 2011 23:58:44 -0800
Message-ID: <1294041525-15553-2-git-send-email-amit.salecha@qlogic.com>
References: <1294041525-15553-1-git-send-email-amit.salecha@qlogic.com>
Cc: netdev@vger.kernel.org, ameen.rahman@qlogic.com,
	anirban.chakraborty@qlogic.com,
	Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mvnat01.qlogic.com ([198.186.3.73]:7432 "EHLO unm84.unminc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751426Ab1ACH7H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Jan 2011 02:59:07 -0500
In-Reply-To: <1294041525-15553-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>

o Enable/disable LRO in device based on NETIF_F_LRO flag, instead of using
  driver private flag.
o Disable LRO, if rx csum offloading is off.

David Miller,
	You should use netdev_info() instead of dev_info().

Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
---
 drivers/net/netxen/netxen_nic.h         |    1 +
 drivers/net/netxen/netxen_nic_ethtool.c |   26 ++++++++++++++++++++++++--
 drivers/net/netxen/netxen_nic_hw.c      |    5 -----
 drivers/net/netxen/netxen_nic_main.c    |    4 +---
 4 files changed, 26 insertions(+), 10 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 8e8a978..4e54587 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1132,6 +1132,7 @@ typedef struct {
 #define NETXEN_NIC_MSI_ENABLED		0x02
 #define NETXEN_NIC_MSIX_ENABLED		0x04
 #define NETXEN_NIC_LRO_ENABLED		0x08
+#define NETXEN_NIC_LRO_DISABLED		0x00
 #define NETXEN_NIC_BRIDGE_ENABLED       0X10
 #define NETXEN_NIC_DIAG_ENABLED		0x20
 #define NETXEN_IS_MSI_FAMILY(adapter) \
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netxen/netxen_nic_ethtool.c
index b30de24..587498e 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -720,7 +720,21 @@ static u32 netxen_nic_get_rx_csum(struct net_device *dev)
 static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
 {
 	struct netxen_adapter *adapter = netdev_priv(dev);
-	adapter->rx_csum = !!data;
+
+	if (data) {
+		adapter->rx_csum = data;
+		return 0;
+	}
+
+	if (dev->features & NETIF_F_LRO) {
+		if (netxen_config_hw_lro(adapter, NETXEN_NIC_LRO_DISABLED))
+			return -EIO;
+
+		dev->features &= ~NETIF_F_LRO;
+		netxen_send_lro_cleanup(adapter);
+		netdev_info(dev, "disabling LRO as rx_csum is off\n");
+	}
+	adapter->rx_csum = data;
 	return 0;
 }
 
@@ -893,11 +907,19 @@ static int netxen_nic_set_flags(struct net_device *netdev, u32 data)
 	if (!(adapter->capabilities & NX_FW_CAPABILITY_HW_LRO))
 		return -EINVAL;
 
+	if (!adapter->rx_csum) {
+		netdev_info(netdev, "rx csum is off, cannot toggle LRO\n");
+		return -EINVAL;
+	}
+
+	if (!!(data & ETH_FLAG_LRO) == !!(netdev->features & NETIF_F_LRO))
+		return 0;
+
 	if (data & ETH_FLAG_LRO) {
 		hw_lro = NETXEN_NIC_LRO_ENABLED;
 		netdev->features |= NETIF_F_LRO;
 	} else {
-		hw_lro = 0;
+		hw_lro = NETXEN_NIC_LRO_DISABLED;
 		netdev->features &= ~NETIF_F_LRO;
 	}
 
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index e42d26e..5cef718 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -809,9 +809,6 @@ int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable)
 	u64 word;
 	int rv = 0;
 
-	if ((adapter->flags & NETXEN_NIC_LRO_ENABLED) == enable)
-		return 0;
-
 	memset(&req, 0, sizeof(nx_nic_req_t));
 
 	req.qhdr = cpu_to_le64(NX_HOST_REQUEST << 23);
@@ -827,8 +824,6 @@ int netxen_config_hw_lro(struct netxen_adapter *adapter, int enable)
 			"configure hw lro request\n");
 	}
 
-	adapter->flags ^= NETXEN_NIC_LRO_ENABLED;
-
 	return rv;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 58a3643..33fac32 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -762,8 +762,6 @@ netxen_check_options(struct netxen_adapter *adapter)
 	if (adapter->fw_version >= NETXEN_VERSION_CODE(4, 0, 222))
 		adapter->capabilities = NXRD32(adapter, CRB_FW_CAPABILITIES_1);
 
-	adapter->flags &= ~NETXEN_NIC_LRO_ENABLED;
-
 	if (adapter->ahw.port_type == NETXEN_NIC_XGBE) {
 		adapter->num_rxd = DEFAULT_RCV_DESCRIPTORS_10G;
 		adapter->num_jumbo_rxd = MAX_JUMBO_RCV_DESCRIPTORS_10G;
@@ -990,7 +988,7 @@ __netxen_nic_up(struct netxen_adapter *adapter, struct net_device *netdev)
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		netxen_config_intr_coalesce(adapter);
 
-	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
+	if (netdev->features & NETIF_F_LRO)
 		netxen_config_hw_lro(adapter, NETXEN_NIC_LRO_ENABLED);
 
 	netxen_napi_enable(adapter);
-- 
1.7.3.2


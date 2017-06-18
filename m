From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: implement vlan filter enable and disable
Date: Sun, 18 Jun 2017 12:41:34 -0700
Message-ID: <20170618194134.GA1249@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        prasad.kanneganti@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0088.outbound.protection.outlook.com ([104.47.42.88]:48544
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750970AbdFRTll (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 15:41:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

Add implementation to support ethtool -K ethX rx-vlan-filter on/off.
Rename OCTNET_CMD_ENABLE_VLAN_FILTER command to OCTNET_CMD_VLAN_FILTER_CTL
and add OCTNET_CMD_VLAN_FILTER_ENABLE and OCTNET_CMD_VLAN_FILTER_DISABLE
parameters so that it can be used to enable or disable the filter.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_core.c    | 10 +++++---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 28 +++++++++++++++++-----
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  4 +++-
 3 files changed, 32 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_core.c b/drivers/net/ethernet/cavium/liquidio/lio_core.c
index 796c2cb..adde774 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_core.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_core.c
@@ -202,9 +202,13 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 			 netdev->name);
 		break;
 
-	case OCTNET_CMD_ENABLE_VLAN_FILTER:
-		dev_info(&oct->pci_dev->dev, "%s VLAN filter enabled\n",
-			 netdev->name);
+	case OCTNET_CMD_VLAN_FILTER_CTL:
+		if (nctrl->ncmd.s.param1)
+			dev_info(&oct->pci_dev->dev,
+				 "%s VLAN filter enabled\n", netdev->name);
+		else
+			dev_info(&oct->pci_dev->dev,
+				 "%s VLAN filter disabled\n", netdev->name);
 		break;
 
 	case OCTNET_CMD_ADD_VLAN_FILTER:
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index ba01242..17f963b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -3591,6 +3591,10 @@ static netdev_features_t liquidio_fix_features(struct net_device *netdev,
 	    (lio->dev_capability & NETIF_F_LRO))
 		request &= ~NETIF_F_LRO;
 
+	if ((request & NETIF_F_HW_VLAN_CTAG_FILTER) &&
+	    !(lio->dev_capability & NETIF_F_HW_VLAN_CTAG_FILTER))
+		request &= ~NETIF_F_HW_VLAN_CTAG_FILTER;
+
 	return request;
 }
 
@@ -3603,14 +3607,14 @@ static int liquidio_set_features(struct net_device *netdev,
 {
 	struct lio *lio = netdev_priv(netdev);
 
-	if (!((netdev->features ^ features) & NETIF_F_LRO))
-		return 0;
-
-	if ((features & NETIF_F_LRO) && (lio->dev_capability & NETIF_F_LRO))
+	if ((features & NETIF_F_LRO) &&
+	    (lio->dev_capability & NETIF_F_LRO) &&
+	    !(netdev->features & NETIF_F_LRO))
 		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
 				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 	else if (!(features & NETIF_F_LRO) &&
-		 (lio->dev_capability & NETIF_F_LRO))
+		 (lio->dev_capability & NETIF_F_LRO) &&
+		 (netdev->features & NETIF_F_LRO))
 		liquidio_set_feature(netdev, OCTNET_CMD_LRO_DISABLE,
 				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
@@ -3629,6 +3633,17 @@ static int liquidio_set_features(struct net_device *netdev,
 		liquidio_set_rxcsum_command(netdev, OCTNET_CMD_TNL_RX_CSUM_CTL,
 					    OCTNET_CMD_RXCSUM_DISABLE);
 
+	if ((features & NETIF_F_HW_VLAN_CTAG_FILTER) &&
+	    (lio->dev_capability & NETIF_F_HW_VLAN_CTAG_FILTER) &&
+	    !(netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
+		liquidio_set_feature(netdev, OCTNET_CMD_VLAN_FILTER_CTL,
+				     OCTNET_CMD_VLAN_FILTER_ENABLE);
+	else if (!(features & NETIF_F_HW_VLAN_CTAG_FILTER) &&
+		 (lio->dev_capability & NETIF_F_HW_VLAN_CTAG_FILTER) &&
+		 (netdev->features & NETIF_F_HW_VLAN_CTAG_FILTER))
+		liquidio_set_feature(netdev, OCTNET_CMD_VLAN_FILTER_CTL,
+				     OCTNET_CMD_VLAN_FILTER_DISABLE);
+
 	return 0;
 }
 
@@ -4199,7 +4214,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 			liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
 					     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
-		liquidio_set_feature(netdev, OCTNET_CMD_ENABLE_VLAN_FILTER, 0);
+		liquidio_set_feature(netdev, OCTNET_CMD_VLAN_FILTER_CTL,
+				     OCTNET_CMD_VLAN_FILTER_ENABLE);
 
 		if ((debug != -1) && (debug & NETIF_MSG_HW))
 			liquidio_set_feature(netdev,
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index 8ea2323..d03f529 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -215,7 +215,7 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_VERBOSE_ENABLE   0x14
 #define   OCTNET_CMD_VERBOSE_DISABLE  0x15
 
-#define   OCTNET_CMD_ENABLE_VLAN_FILTER 0x16
+#define   OCTNET_CMD_VLAN_FILTER_CTL 0x16
 #define   OCTNET_CMD_ADD_VLAN_FILTER  0x17
 #define   OCTNET_CMD_DEL_VLAN_FILTER  0x18
 #define   OCTNET_CMD_VXLAN_PORT_CONFIG 0x19
@@ -230,6 +230,8 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_RXCSUM_DISABLE    0x1
 #define   OCTNET_CMD_TXCSUM_ENABLE     0x0
 #define   OCTNET_CMD_TXCSUM_DISABLE    0x1
+#define   OCTNET_CMD_VLAN_FILTER_ENABLE 0x1
+#define   OCTNET_CMD_VLAN_FILTER_DISABLE 0x0
 
 /* RX(packets coming from wire) Checksum verification flags */
 /* TCP/UDP csum */

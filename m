From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 03/13] liquidio: Vlan filtering
Date: Tue, 21 Jun 2016 22:53:05 -0700
Message-ID: <1466574795-4306-4-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>,
	Derek Chickles <derek.chickles@caviumnetworks.com>,
	Satanand Burla <satananda.burla@caviumnetworks.com>,
	Felix Manlunas <felix.manlunas@caviumnetworks.com>,
	Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0070.outbound.protection.outlook.com ([65.55.169.70]:57977
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751231AbcFVFzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jun 2016 01:55:20 -0400
In-Reply-To: <1466574795-4306-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds supports for Vlan filtering for liquidio driver.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c    | 82 +++++++++++++++++++++-
 .../net/ethernet/cavium/liquidio/liquidio_common.h |  4 ++
 2 files changed, 83 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 4b95dbf..9f3a93b 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2310,6 +2310,21 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 			 netdev->name);
 		break;
 
+	case OCTNET_CMD_ENABLE_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter enabled\n",
+			 netdev->name);
+		break;
+
+	case OCTNET_CMD_ADD_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d added\n",
+			 netdev->name, nctrl->ncmd.s.param1);
+		break;
+
+	case OCTNET_CMD_DEL_VLAN_FILTER:
+		dev_info(&oct->pci_dev->dev, "%s VLAN filter %d removed\n",
+			 netdev->name, nctrl->ncmd.s.param1);
+		break;
+
 	case OCTNET_CMD_SET_SETTINGS:
 		dev_info(&oct->pci_dev->dev, "%s settings changed\n",
 			 netdev->name);
@@ -2965,6 +2980,61 @@ static void liquidio_tx_timeout(struct net_device *netdev)
 	txqs_wake(netdev);
 }
 
+static int liquidio_vlan_rx_add_vid(struct net_device *netdev,
+				    __be16 proto __attribute__((unused)),
+				    u16 vid)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_ADD_VLAN_FILTER;
+	nctrl.ncmd.s.param1 = vid;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Add VLAN filter failed in core (ret: 0x%x)\n",
+			ret);
+	}
+
+	return ret;
+}
+
+static int liquidio_vlan_rx_kill_vid(struct net_device *netdev,
+				     __be16 proto __attribute__((unused)),
+				     u16 vid)
+{
+	struct lio *lio = GET_LIO(netdev);
+	struct octeon_device *oct = lio->oct_dev;
+	struct octnic_ctrl_pkt nctrl;
+	int ret = 0;
+
+	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
+
+	nctrl.ncmd.u64 = 0;
+	nctrl.ncmd.s.cmd = OCTNET_CMD_DEL_VLAN_FILTER;
+	nctrl.ncmd.s.param1 = vid;
+	nctrl.iq_no = lio->linfo.txpciq[0].s.q_no;
+	nctrl.wait_time = 100;
+	nctrl.netpndev = (u64)netdev;
+	nctrl.cb_fn = liquidio_link_ctrl_cmd_completion;
+
+	ret = octnet_send_nic_ctrl_pkt(lio->oct_dev, &nctrl);
+	if (ret < 0) {
+		dev_err(&oct->pci_dev->dev, "Add VLAN filter failed in core (ret: 0x%x)\n",
+			ret);
+	}
+	return ret;
+}
+
 int liquidio_set_feature(struct net_device *netdev, int cmd, u16 param1)
 {
 	struct lio *lio = GET_LIO(netdev);
@@ -3056,6 +3126,9 @@ static struct net_device_ops lionetdevops = {
 	.ndo_set_mac_address	= liquidio_set_mac,
 	.ndo_set_rx_mode	= liquidio_set_mcast_list,
 	.ndo_tx_timeout		= liquidio_tx_timeout,
+
+	.ndo_vlan_rx_add_vid    = liquidio_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid   = liquidio_vlan_rx_kill_vid,
 	.ndo_change_mtu		= liquidio_change_mtu,
 	.ndo_do_ioctl		= liquidio_ioctl,
 	.ndo_fix_features	= liquidio_fix_features,
@@ -3319,7 +3392,8 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 
 		netdev->vlan_features = lio->dev_capability;
 		/* Add any unchangeable hw features */
-		lio->dev_capability |=  NETIF_F_HW_VLAN_CTAG_RX |
+		lio->dev_capability |=  NETIF_F_HW_VLAN_CTAG_FILTER |
+					NETIF_F_HW_VLAN_CTAG_RX |
 					NETIF_F_HW_VLAN_CTAG_TX;
 
 		netdev->features = (lio->dev_capability & ~NETIF_F_LRO);
@@ -3377,9 +3451,11 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		liquidio_set_feature(netdev, OCTNET_CMD_LRO_ENABLE,
 				     OCTNIC_LROIPV4 | OCTNIC_LROIPV6);
 
+		liquidio_set_feature(netdev, OCTNET_CMD_ENABLE_VLAN_FILTER, 0);
+
 		if ((debug != -1) && (debug & NETIF_MSG_HW))
-			liquidio_set_feature(netdev, OCTNET_CMD_VERBOSE_ENABLE,
-					     0);
+			liquidio_set_feature(netdev,
+					     OCTNET_CMD_VERBOSE_ENABLE, 0);
 
 		/* Register the network device with the OS */
 		if (register_netdev(netdev)) {
diff --git a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
index c86421f..3738877 100644
--- a/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
+++ b/drivers/net/ethernet/cavium/liquidio/liquidio_common.h
@@ -214,6 +214,10 @@ static inline void add_sg_size(struct octeon_sg_entry *sg_entry,
 #define   OCTNET_CMD_VERBOSE_ENABLE   0x14
 #define   OCTNET_CMD_VERBOSE_DISABLE  0x15
 
+#define   OCTNET_CMD_ENABLE_VLAN_FILTER 0x16
+#define   OCTNET_CMD_ADD_VLAN_FILTER  0x17
+#define   OCTNET_CMD_DEL_VLAN_FILTER  0x18
+
 /* RX(packets coming from wire) Checksum verification flags */
 /* TCP/UDP csum */
 #define   CNNIC_L4SUM_VERIFIED             0x1
-- 
1.8.3.1

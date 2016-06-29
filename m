From: Raghu Vatsavayi <rvatsavayi@caviumnetworks.com>
Subject: [PATCH net-next 07/10] liquidio: MTU limits
Date: Tue, 28 Jun 2016 17:54:29 -0700
Message-ID: <1467161672-21063-8-git-send-email-rvatsavayi@caviumnetworks.com>
References: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
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
Received: from mail-by2on0059.outbound.protection.outlook.com ([207.46.100.59]:46448
	"EHLO na01-by2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752578AbcF2AzS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Jun 2016 20:55:18 -0400
In-Reply-To: <1467161672-21063-1-git-send-email-rvatsavayi@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch limits the MTU  between 68 bytes and 16000 bytes.

Signed-off-by: Derek Chickles <derek.chickles@caviumnetworks.com>
Signed-off-by: Satanand Burla <satananda.burla@caviumnetworks.com>
Signed-off-by: Felix Manlunas <felix.manlunas@caviumnetworks.com>
Signed-off-by: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_ethtool.c  |  2 +-
 drivers/net/ethernet/cavium/liquidio/lio_main.c     | 21 +++++++++++----------
 .../net/ethernet/cavium/liquidio/octeon_network.h   |  3 +++
 3 files changed, 15 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
index 81c3b58..cc755aa 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_ethtool.c
@@ -563,7 +563,7 @@ lio_ethtool_get_ringparam(struct net_device *netdev,
 		tx_pending = CFG_GET_NUM_TX_DESCS_NIC_IF(conf6x, lio->ifidx);
 	}
 
-	if (lio->mtu > OCTNET_DEFAULT_FRM_SIZE) {
+	if (lio->mtu > OCTNET_DEFAULT_FRM_SIZE - OCTNET_FRM_HEADER_SIZE) {
 		ering->rx_pending = 0;
 		ering->rx_max_pending = 0;
 		ering->rx_mini_pending = 0;
diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 0f39ad0..ee83047 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2386,11 +2386,14 @@ void liquidio_link_ctrl_cmd_completion(void *nctrl_ptr)
 	case OCTNET_CMD_CHANGE_MTU:
 		/* If command is successful, change the MTU. */
 		netif_info(lio, probe, lio->netdev, " MTU Changed from %d to %d\n",
-			   netdev->mtu, nctrl->ncmd.s.param2);
+			   netdev->mtu, nctrl->ncmd.s.param1);
 		dev_info(&oct->pci_dev->dev, "%s MTU Changed from %d to %d\n",
 			 netdev->name, netdev->mtu,
-			 nctrl->ncmd.s.param2);
-		netdev->mtu = nctrl->ncmd.s.param2;
+			 nctrl->ncmd.s.param1);
+		rtnl_lock();
+		netdev->mtu = nctrl->ncmd.s.param1;
+		call_netdevice_notifiers(NETDEV_CHANGEMTU, netdev);
+		rtnl_unlock();
 		break;
 
 	case OCTNET_CMD_GPIO_ACCESS:
@@ -2682,18 +2685,16 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 	struct lio *lio = GET_LIO(netdev);
 	struct octeon_device *oct = lio->oct_dev;
 	struct octnic_ctrl_pkt nctrl;
-	int max_frm_size = new_mtu + OCTNET_FRM_HEADER_SIZE;
 	int ret = 0;
 
-	/* Limit the MTU to make sure the ethernet packets are between 64 bytes
-	 * and 65535 bytes
+	/* Limit the MTU to make sure the ethernet packets are between 68 bytes
+	 * and 16000 bytes
 	 */
-	if ((max_frm_size < OCTNET_MIN_FRM_SIZE) ||
-	    (max_frm_size > OCTNET_MAX_FRM_SIZE)) {
+	if ((new_mtu < LIO_MIN_MTU_SIZE) ||
+	    (new_mtu > LIO_MAX_MTU_SIZE)) {
 		dev_err(&oct->pci_dev->dev, "Invalid MTU: %d\n", new_mtu);
 		dev_err(&oct->pci_dev->dev, "Valid range %d and %d\n",
-			(OCTNET_MIN_FRM_SIZE - OCTNET_FRM_HEADER_SIZE),
-			(OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE));
+			LIO_MIN_MTU_SIZE, LIO_MAX_MTU_SIZE);
 		return -EINVAL;
 	}
 
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index 4489fc4..aa9ee79 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -30,6 +30,9 @@
 #include <linux/dma-mapping.h>
 #include <linux/ptp_clock_kernel.h>
 
+#define LIO_MAX_MTU_SIZE (OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE)
+#define LIO_MIN_MTU_SIZE 68
+
 struct oct_nic_stats_resp {
 	u64     rh;
 	struct oct_link_stats stats;
-- 
1.8.3.1

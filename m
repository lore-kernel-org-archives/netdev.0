From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 11/15] ethernet/cavium: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:13 -0400
Message-ID: <20161017195417.48259-12-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Sunil Goutham <sgoutham@cavium.com>,
        Robert Richter <rric@kernel.org>,
        Derek Chickles <derek.chickles@caviumnetworks.com>,
        Satanand Burla <satananda.burla@caviumnetworks.com>,
        Felix Manlunas <felix.manlunas@caviumnetworks.com>,
        Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

liquidio: min_mtu 68, max_mtu 16000

thunder: min_mtu 64, max_mtu 9200

CC: netdev@vger.kernel.org
CC: Sunil Goutham <sgoutham@cavium.com>
CC: Robert Richter <rric@kernel.org>
CC: Derek Chickles <derek.chickles@caviumnetworks.com>
CC: Satanand Burla <satananda.burla@caviumnetworks.com>
CC: Felix Manlunas <felix.manlunas@caviumnetworks.com>
CC: Raghu Vatsavayi <raghu.vatsavayi@caviumnetworks.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c       | 15 ++++-----------
 drivers/net/ethernet/cavium/liquidio/octeon_network.h |  2 +-
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c      | 13 +++----------
 drivers/net/ethernet/cavium/thunder/nicvf_main.c      | 10 ++++------
 4 files changed, 12 insertions(+), 28 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index afc6f9dc..71d01a7 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2868,17 +2868,6 @@ static int liquidio_change_mtu(struct net_device *netdev, int new_mtu)
 	struct octnic_ctrl_pkt nctrl;
 	int ret = 0;
 
-	/* Limit the MTU to make sure the ethernet packets are between 68 bytes
-	 * and 16000 bytes
-	 */
-	if ((new_mtu < LIO_MIN_MTU_SIZE) ||
-	    (new_mtu > LIO_MAX_MTU_SIZE)) {
-		dev_err(&oct->pci_dev->dev, "Invalid MTU: %d\n", new_mtu);
-		dev_err(&oct->pci_dev->dev, "Valid range %d and %d\n",
-			LIO_MIN_MTU_SIZE, LIO_MAX_MTU_SIZE);
-		return -EINVAL;
-	}
-
 	memset(&nctrl, 0, sizeof(struct octnic_ctrl_pkt));
 
 	nctrl.ncmd.u64 = 0;
@@ -3891,6 +3880,10 @@ static int setup_nic_devices(struct octeon_device *octeon_dev)
 		netdev->hw_features = netdev->hw_features &
 			~NETIF_F_HW_VLAN_CTAG_RX;
 
+		/* MTU range: 68 - 16000 */
+		netdev->min_mtu = LIO_MIN_MTU_SIZE;
+		netdev->max_mtu = LIO_MAX_MTU_SIZE;
+
 		/* Point to the  properties for octeon device to which this
 		 * interface belongs.
 		 */
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_network.h b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
index e5d1deb..54b9665 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_network.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_network.h
@@ -29,7 +29,7 @@
 #include <linux/ptp_clock_kernel.h>
 
 #define LIO_MAX_MTU_SIZE (OCTNET_MAX_FRM_SIZE - OCTNET_FRM_HEADER_SIZE)
-#define LIO_MIN_MTU_SIZE 68
+#define LIO_MIN_MTU_SIZE ETH_MIN_MTU
 
 struct oct_nic_stats_resp {
 	u64     rh;
diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index 4ab404f..16e12c4 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -645,16 +645,6 @@ static int octeon_mgmt_change_mtu(struct net_device *netdev, int new_mtu)
 	struct octeon_mgmt *p = netdev_priv(netdev);
 	int size_without_fcs = new_mtu + OCTEON_MGMT_RX_HEADROOM;
 
-	/* Limit the MTU to make sure the ethernet packets are between
-	 * 64 bytes and 16383 bytes.
-	 */
-	if (size_without_fcs < 64 || size_without_fcs > 16383) {
-		dev_warn(p->dev, "MTU must be between %d and %d.\n",
-			 64 - OCTEON_MGMT_RX_HEADROOM,
-			 16383 - OCTEON_MGMT_RX_HEADROOM);
-		return -EINVAL;
-	}
-
 	netdev->mtu = new_mtu;
 
 	cvmx_write_csr(p->agl + AGL_GMX_RX_FRM_MAX, size_without_fcs);
@@ -1491,6 +1481,9 @@ static int octeon_mgmt_probe(struct platform_device *pdev)
 	netdev->netdev_ops = &octeon_mgmt_ops;
 	netdev->ethtool_ops = &octeon_mgmt_ethtool_ops;
 
+	netdev->min_mtu = 64 - OCTEON_MGMT_RX_HEADROOM;
+	netdev->max_mtu = 16383 - OCTEON_MGMT_RX_HEADROOM;
+
 	mac = of_get_mac_address(pdev->dev.of_node);
 
 	if (mac)
diff --git a/drivers/net/ethernet/cavium/thunder/nicvf_main.c b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
index 45a13f7..b192712 100644
--- a/drivers/net/ethernet/cavium/thunder/nicvf_main.c
+++ b/drivers/net/ethernet/cavium/thunder/nicvf_main.c
@@ -1312,12 +1312,6 @@ static int nicvf_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct nicvf *nic = netdev_priv(netdev);
 
-	if (new_mtu > NIC_HW_MAX_FRS)
-		return -EINVAL;
-
-	if (new_mtu < NIC_HW_MIN_FRS)
-		return -EINVAL;
-
 	if (nicvf_update_hw_max_frs(nic, new_mtu))
 		return -EINVAL;
 	netdev->mtu = new_mtu;
@@ -1630,6 +1624,10 @@ static int nicvf_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->netdev_ops = &nicvf_netdev_ops;
 	netdev->watchdog_timeo = NICVF_TX_TIMEOUT;
 
+	/* MTU range: 64 - 9200 */
+	netdev->min_mtu = NIC_HW_MIN_FRS;
+	netdev->max_mtu = NIC_HW_MAX_FRS;
+
 	INIT_WORK(&nic->reset_task, nicvf_reset_task);
 
 	err = register_netdev(netdev);
-- 
2.10.0

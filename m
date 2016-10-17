From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 01/15] ethernet/atheros: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:03 -0400
Message-ID: <20161017195417.48259-2-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Jay Cliburn <jcliburn@gmail.com>,
        Chris Snook <chris.snook@gmail.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57368 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755939AbcJQTy1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 15:54:27 -0400
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

atl2: min_mtu 40, max_mtu 1504

- Remove a few redundant defines that already have equivalents in
  if_ether.h.

atl1: min_mtu 42, max_mtu 10218

atl1e: min_mtu 42, max_mtu 8170

atl1c: min_mtu 42, max_mtu 6122/1500

- GbE hardware gets a max_mtu of 6122, slower hardware gets 1500.

alx: min_mtu 34, max_mtu 9256

- Not so sure that minimum MTU number is really what was intended, but
  that's what the math actually makes it out to be, due to max_frame
  manipulations and comparison in alx_change_mtu, rather than just
  comparing new_mtu. (I think 68 was the intended min_mtu value).

CC: netdev@vger.kernel.org
CC: Jay Cliburn <jcliburn@gmail.com>
CC: Chris Snook <chris.snook@gmail.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/atheros/alx/hw.h           |  1 -
 drivers/net/ethernet/atheros/alx/main.c         | 10 ++----
 drivers/net/ethernet/atheros/atl1c/atl1c_main.c | 41 ++++++++++++++++---------
 drivers/net/ethernet/atheros/atl1e/atl1e_main.c | 12 +++-----
 drivers/net/ethernet/atheros/atlx/atl1.c        | 15 ++++-----
 drivers/net/ethernet/atheros/atlx/atl2.c        | 16 +++++-----
 drivers/net/ethernet/atheros/atlx/atl2.h        |  3 --
 7 files changed, 47 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/atheros/alx/hw.h b/drivers/net/ethernet/atheros/alx/hw.h
index 0191477..e42d7e0 100644
--- a/drivers/net/ethernet/atheros/alx/hw.h
+++ b/drivers/net/ethernet/atheros/alx/hw.h
@@ -351,7 +351,6 @@ struct alx_rrd {
 #define ALX_MAX_JUMBO_PKT_SIZE	(9*1024)
 #define ALX_MAX_TSO_PKT_SIZE	(7*1024)
 #define ALX_MAX_FRAME_SIZE	ALX_MAX_JUMBO_PKT_SIZE
-#define ALX_MIN_FRAME_SIZE	(ETH_ZLEN + ETH_FCS_LEN + VLAN_HLEN)
 
 #define ALX_MAX_RX_QUEUES	8
 #define ALX_MAX_TX_QUEUES	4
diff --git a/drivers/net/ethernet/atheros/alx/main.c b/drivers/net/ethernet/atheros/alx/main.c
index c0f84b7..eccbacd 100644
--- a/drivers/net/ethernet/atheros/alx/main.c
+++ b/drivers/net/ethernet/atheros/alx/main.c
@@ -892,6 +892,9 @@ static int alx_init_sw(struct alx_priv *alx)
 	hw->smb_timer = 400;
 	hw->mtu = alx->dev->mtu;
 	alx->rxbuf_size = ALX_MAX_FRAME_LEN(hw->mtu);
+	/* MTU range: 34 - 9256 */
+	alx->dev->min_mtu = 34;
+	alx->dev->max_mtu = ALX_MAX_FRAME_LEN(ALX_MAX_FRAME_SIZE);
 	alx->tx_ringsz = 256;
 	alx->rx_ringsz = 512;
 	hw->imt = 200;
@@ -994,13 +997,6 @@ static int alx_change_mtu(struct net_device *netdev, int mtu)
 	struct alx_priv *alx = netdev_priv(netdev);
 	int max_frame = ALX_MAX_FRAME_LEN(mtu);
 
-	if ((max_frame < ALX_MIN_FRAME_SIZE) ||
-	    (max_frame > ALX_MAX_FRAME_SIZE))
-		return -EINVAL;
-
-	if (netdev->mtu == mtu)
-		return 0;
-
 	netdev->mtu = mtu;
 	alx->hw.mtu = mtu;
 	alx->rxbuf_size = max(max_frame, ALX_DEF_RXBUF_SIZE);
diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
index a3200ea..773d3b7 100644
--- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
+++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
@@ -519,6 +519,26 @@ static int atl1c_set_features(struct net_device *netdev,
 	return 0;
 }
 
+static void atl1c_set_max_mtu(struct net_device *netdev)
+{
+	struct atl1c_adapter *adapter = netdev_priv(netdev);
+	struct atl1c_hw *hw = &adapter->hw;
+
+	switch (hw->nic_type) {
+	/* These (GbE) devices support jumbo packets, max_mtu 6122 */
+	case athr_l1c:
+	case athr_l1d:
+	case athr_l1d_2:
+		netdev->max_mtu = MAX_JUMBO_FRAME_SIZE -
+				  (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
+		break;
+	/* The 10/100 devices don't support jumbo packets, max_mtu 1500 */
+	default:
+		netdev->max_mtu = ETH_DATA_LEN;
+		break;
+	}
+}
+
 /**
  * atl1c_change_mtu - Change the Maximum Transfer Unit
  * @netdev: network interface device structure
@@ -529,22 +549,9 @@ static int atl1c_set_features(struct net_device *netdev,
 static int atl1c_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1c_adapter *adapter = netdev_priv(netdev);
-	struct atl1c_hw *hw = &adapter->hw;
-	int old_mtu   = netdev->mtu;
-	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
-
-	/* Fast Ethernet controller doesn't support jumbo packet */
-	if (((hw->nic_type == athr_l2c ||
-	      hw->nic_type == athr_l2c_b ||
-	      hw->nic_type == athr_l2c_b2) && new_mtu > ETH_DATA_LEN) ||
-	      max_frame < ETH_ZLEN + ETH_FCS_LEN ||
-	      max_frame > MAX_JUMBO_FRAME_SIZE) {
-		if (netif_msg_link(adapter))
-			dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
-		return -EINVAL;
-	}
+
 	/* set MTU */
-	if (old_mtu != new_mtu && netif_running(netdev)) {
+	if (netif_running(netdev)) {
 		while (test_and_set_bit(__AT_RESETTING, &adapter->flags))
 			msleep(1);
 		netdev->mtu = new_mtu;
@@ -2511,6 +2518,7 @@ static int atl1c_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 
 	netdev->netdev_ops = &atl1c_netdev_ops;
 	netdev->watchdog_timeo = AT_TX_WATCHDOG;
+	netdev->min_mtu = ETH_ZLEN - (ETH_HLEN + VLAN_HLEN);
 	atl1c_set_ethtool_ops(netdev);
 
 	/* TODO: add when ready */
@@ -2613,6 +2621,9 @@ static int atl1c_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		dev_err(&pdev->dev, "net device private data init failed\n");
 		goto err_sw_init;
 	}
+	/* set max MTU */
+	atl1c_set_max_mtu(netdev);
+
 	atl1c_reset_pcie(&adapter->hw, ATL1C_PCIE_L0S_L1_DISABLE);
 
 	/* Init GPHY as early as possible due to power saving issue  */
diff --git a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
index 974713b..e96091b6 100644
--- a/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
+++ b/drivers/net/ethernet/atheros/atl1e/atl1e_main.c
@@ -439,16 +439,10 @@ static int atl1e_set_features(struct net_device *netdev,
 static int atl1e_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
-	int old_mtu   = netdev->mtu;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
-			(max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		netdev_warn(adapter->netdev, "invalid MTU setting\n");
-		return -EINVAL;
-	}
 	/* set MTU */
-	if (old_mtu != new_mtu && netif_running(netdev)) {
+	if (netif_running(netdev)) {
 		while (test_and_set_bit(__AT_RESETTING, &adapter->flags))
 			msleep(1);
 		netdev->mtu = new_mtu;
@@ -2272,6 +2266,10 @@ static int atl1e_init_netdev(struct net_device *netdev, struct pci_dev *pdev)
 	netdev->netdev_ops = &atl1e_netdev_ops;
 
 	netdev->watchdog_timeo = AT_TX_WATCHDOG;
+	/* MTU range: 42 - 8170 */
+	netdev->min_mtu = ETH_ZLEN - (ETH_HLEN + VLAN_HLEN);
+	netdev->max_mtu = MAX_JUMBO_FRAME_SIZE -
+			  (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
 	atl1e_set_ethtool_ops(netdev);
 
 	netdev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_TSO |
diff --git a/drivers/net/ethernet/atheros/atlx/atl1.c b/drivers/net/ethernet/atheros/atlx/atl1.c
index 529bca7..9aede18 100644
--- a/drivers/net/ethernet/atheros/atlx/atl1.c
+++ b/drivers/net/ethernet/atheros/atlx/atl1.c
@@ -2701,23 +2701,15 @@ static void atl1_reset_dev_task(struct work_struct *work)
 static int atl1_change_mtu(struct net_device *netdev, int new_mtu)
 {
 	struct atl1_adapter *adapter = netdev_priv(netdev);
-	int old_mtu = netdev->mtu;
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
 
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
-	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
-		if (netif_msg_link(adapter))
-			dev_warn(&adapter->pdev->dev, "invalid MTU setting\n");
-		return -EINVAL;
-	}
-
 	adapter->hw.max_frame_size = max_frame;
 	adapter->hw.tx_jumbo_task_th = (max_frame + 7) >> 3;
 	adapter->rx_buffer_len = (max_frame + 7) & ~7;
 	adapter->hw.rx_jumbo_th = adapter->rx_buffer_len / 8;
 
 	netdev->mtu = new_mtu;
-	if ((old_mtu != new_mtu) && netif_running(netdev)) {
+	if (netif_running(netdev)) {
 		atl1_down(adapter);
 		atl1_up(adapter);
 	}
@@ -3031,6 +3023,11 @@ static int atl1_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	/* is this valid? see atl1_setup_mac_ctrl() */
 	netdev->features |= NETIF_F_RXCSUM;
 
+	/* MTU range: 42 - 10218 */
+	netdev->min_mtu = ETH_ZLEN - (ETH_HLEN + VLAN_HLEN);
+	netdev->max_mtu = MAX_JUMBO_FRAME_SIZE -
+			  (ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN);
+
 	/*
 	 * patch for some L1 of old version,
 	 * the final version of L1 may not need these
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.c b/drivers/net/ethernet/atheros/atlx/atl2.c
index 2ff4658..6911394 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.c
+++ b/drivers/net/ethernet/atheros/atlx/atl2.c
@@ -253,7 +253,7 @@ static int atl2_configure(struct atl2_adapter *adapter)
 
 	/* set MTU */
 	ATL2_WRITE_REG(hw, REG_MTU, adapter->netdev->mtu +
-		ENET_HEADER_SIZE + VLAN_SIZE + ETHERNET_FCS_SIZE);
+		ETH_HLEN + VLAN_HLEN + ETH_FCS_LEN);
 
 	/* 1590 */
 	ATL2_WRITE_REG(hw, REG_TX_CUT_THRESH, 0x177);
@@ -925,15 +925,11 @@ static int atl2_change_mtu(struct net_device *netdev, int new_mtu)
 	struct atl2_adapter *adapter = netdev_priv(netdev);
 	struct atl2_hw *hw = &adapter->hw;
 
-	if ((new_mtu < 40) || (new_mtu > (ETH_DATA_LEN + VLAN_SIZE)))
-		return -EINVAL;
-
 	/* set MTU */
-	if (hw->max_frame_size != new_mtu) {
-		netdev->mtu = new_mtu;
-		ATL2_WRITE_REG(hw, REG_MTU, new_mtu + ENET_HEADER_SIZE +
-			VLAN_SIZE + ETHERNET_FCS_SIZE);
-	}
+	netdev->mtu = new_mtu;
+	hw->max_frame_size = new_mtu;
+	ATL2_WRITE_REG(hw, REG_MTU, new_mtu + ETH_HLEN +
+		       VLAN_HLEN + ETH_FCS_LEN);
 
 	return 0;
 }
@@ -1398,6 +1394,8 @@ static int atl2_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	netdev->netdev_ops = &atl2_netdev_ops;
 	netdev->ethtool_ops = &atl2_ethtool_ops;
 	netdev->watchdog_timeo = 5 * HZ;
+	netdev->min_mtu = 40;
+	netdev->max_mtu = ETH_DATA_LEN + VLAN_HLEN;
 	strncpy(netdev->name, pci_name(pdev), sizeof(netdev->name) - 1);
 
 	netdev->mem_start = mmio_start;
diff --git a/drivers/net/ethernet/atheros/atlx/atl2.h b/drivers/net/ethernet/atheros/atlx/atl2.h
index 2f27d4c..c64a6bd 100644
--- a/drivers/net/ethernet/atheros/atlx/atl2.h
+++ b/drivers/net/ethernet/atheros/atlx/atl2.h
@@ -228,12 +228,9 @@ static void atl2_force_ps(struct atl2_hw *hw);
 #define AUTONEG_ADVERTISE_SPEED_DEFAULT	0x000F	/* Everything */
 
 /* The size (in bytes) of a ethernet packet */
-#define ENET_HEADER_SIZE		14
 #define MAXIMUM_ETHERNET_FRAME_SIZE	1518	/* with FCS */
 #define MINIMUM_ETHERNET_FRAME_SIZE	64	/* with FCS */
-#define ETHERNET_FCS_SIZE		4
 #define MAX_JUMBO_FRAME_SIZE		0x2000
-#define VLAN_SIZE                                               4
 
 struct tx_pkt_header {
 	unsigned pkt_size:11;
-- 
2.10.0

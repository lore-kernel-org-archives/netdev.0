From: Jarod Wilson <jarod@redhat.com>
Subject: [PATCH net-next 04/15] ethernet/marvell: use core min/max MTU checking
Date: Mon, 17 Oct 2016 15:54:06 -0400
Message-ID: <20161017195417.48259-5-jarod@redhat.com>
References: <20161017195417.48259-1-jarod@redhat.com>
Cc: Jarod Wilson <jarod@redhat.com>, netdev@vger.kernel.org,
        Mirko Lindner <mlindner@marvell.com>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43244 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758791AbcJQTya (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Oct 2016 15:54:30 -0400
In-Reply-To: <20161017195417.48259-1-jarod@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mvneta: min_mtu 68, max_mtu 9676
- mtu validation routine mostly did range check, merge back into
  mvneta_change_mtu for simplicity

mvpp2: min_mtu 68, max_mtu 9676
- mtu validation routine mostly did range check, merge back into
  mvpp2_change_mtu for simplicity

pxa168_eth: min_mtu 68, max_mtu 9500

skge: min_mtu 60, max_mtu 9000

sky2: min_mtu 68, max_mtu 1500 or 9000, depending on hw

CC: netdev@vger.kernel.org
CC: Mirko Lindner <mlindner@marvell.com>
CC: Stephen Hemminger <stephen@networkplumber.org>
CC: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Signed-off-by: Jarod Wilson <jarod@redhat.com>
---
 drivers/net/ethernet/marvell/mvneta.c     | 36 +++++++++----------------------
 drivers/net/ethernet/marvell/mvpp2.c      | 36 ++++++++-----------------------
 drivers/net/ethernet/marvell/pxa168_eth.c |  7 +++---
 drivers/net/ethernet/marvell/skge.c       |  7 +++---
 drivers/net/ethernet/marvell/sky2.c       | 18 +++++++---------
 5 files changed, 35 insertions(+), 69 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 5cb07c2..b85819e 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3024,29 +3024,6 @@ static void mvneta_stop_dev(struct mvneta_port *pp)
 	mvneta_rx_reset(pp);
 }
 
-/* Return positive if MTU is valid */
-static int mvneta_check_mtu_valid(struct net_device *dev, int mtu)
-{
-	if (mtu < 68) {
-		netdev_err(dev, "cannot change mtu to less than 68\n");
-		return -EINVAL;
-	}
-
-	/* 9676 == 9700 - 20 and rounding to 8 */
-	if (mtu > 9676) {
-		netdev_info(dev, "Illegal MTU value %d, round to 9676\n", mtu);
-		mtu = 9676;
-	}
-
-	if (!IS_ALIGNED(MVNETA_RX_PKT_SIZE(mtu), 8)) {
-		netdev_info(dev, "Illegal MTU value %d, rounding to %d\n",
-			mtu, ALIGN(MVNETA_RX_PKT_SIZE(mtu), 8));
-		mtu = ALIGN(MVNETA_RX_PKT_SIZE(mtu), 8);
-	}
-
-	return mtu;
-}
-
 static void mvneta_percpu_enable(void *arg)
 {
 	struct mvneta_port *pp = arg;
@@ -3067,9 +3044,11 @@ static int mvneta_change_mtu(struct net_device *dev, int mtu)
 	struct mvneta_port *pp = netdev_priv(dev);
 	int ret;
 
-	mtu = mvneta_check_mtu_valid(dev, mtu);
-	if (mtu < 0)
-		return -EINVAL;
+	if (!IS_ALIGNED(MVNETA_RX_PKT_SIZE(mtu), 8)) {
+		netdev_info(dev, "Illegal MTU value %d, rounding to %d\n",
+			    mtu, ALIGN(MVNETA_RX_PKT_SIZE(mtu), 8));
+		mtu = ALIGN(MVNETA_RX_PKT_SIZE(mtu), 8);
+	}
 
 	dev->mtu = mtu;
 
@@ -4154,6 +4133,11 @@ static int mvneta_probe(struct platform_device *pdev)
 	dev->priv_flags |= IFF_UNICAST_FLT | IFF_LIVE_ADDR_CHANGE;
 	dev->gso_max_segs = MVNETA_MAX_TSO_SEGS;
 
+	/* MTU range: 68 - 9676 */
+	dev->min_mtu = ETH_MIN_MTU;
+	/* 9676 == 9700 - 20 and rounding to 8 */
+	dev->max_mtu = 9676;
+
 	err = register_netdev(dev);
 	if (err < 0) {
 		dev_err(&pdev->dev, "failed to register\n");
diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/ethernet/marvell/mvpp2.c
index 60227a3..c8bf155 100644
--- a/drivers/net/ethernet/marvell/mvpp2.c
+++ b/drivers/net/ethernet/marvell/mvpp2.c
@@ -5453,29 +5453,6 @@ static void mvpp2_stop_dev(struct mvpp2_port *port)
 	phy_stop(ndev->phydev);
 }
 
-/* Return positive if MTU is valid */
-static inline int mvpp2_check_mtu_valid(struct net_device *dev, int mtu)
-{
-	if (mtu < 68) {
-		netdev_err(dev, "cannot change mtu to less than 68\n");
-		return -EINVAL;
-	}
-
-	/* 9676 == 9700 - 20 and rounding to 8 */
-	if (mtu > 9676) {
-		netdev_info(dev, "illegal MTU value %d, round to 9676\n", mtu);
-		mtu = 9676;
-	}
-
-	if (!IS_ALIGNED(MVPP2_RX_PKT_SIZE(mtu), 8)) {
-		netdev_info(dev, "illegal MTU value %d, round to %d\n", mtu,
-			    ALIGN(MVPP2_RX_PKT_SIZE(mtu), 8));
-		mtu = ALIGN(MVPP2_RX_PKT_SIZE(mtu), 8);
-	}
-
-	return mtu;
-}
-
 static int mvpp2_check_ringparam_valid(struct net_device *dev,
 				       struct ethtool_ringparam *ring)
 {
@@ -5717,10 +5694,10 @@ static int mvpp2_change_mtu(struct net_device *dev, int mtu)
 	struct mvpp2_port *port = netdev_priv(dev);
 	int err;
 
-	mtu = mvpp2_check_mtu_valid(dev, mtu);
-	if (mtu < 0) {
-		err = mtu;
-		goto error;
+	if (!IS_ALIGNED(MVPP2_RX_PKT_SIZE(mtu), 8)) {
+		netdev_info(dev, "illegal MTU value %d, round to %d\n", mtu,
+			    ALIGN(MVPP2_RX_PKT_SIZE(mtu), 8));
+		mtu = ALIGN(MVPP2_RX_PKT_SIZE(mtu), 8);
 	}
 
 	if (!netif_running(dev)) {
@@ -6212,6 +6189,11 @@ static int mvpp2_port_probe(struct platform_device *pdev,
 	dev->hw_features |= features | NETIF_F_RXCSUM | NETIF_F_GRO;
 	dev->vlan_features |= features;
 
+	/* MTU range: 68 - 9676 */
+	dev->min_mtu = ETH_MIN_MTU;
+	/* 9676 == 9700 - 20 and rounding to 8 */
+	dev->max_mtu = 9676;
+
 	err = register_netdev(dev);
 	if (err < 0) {
 		dev_err(&pdev->dev, "failed to register netdev\n");
diff --git a/drivers/net/ethernet/marvell/pxa168_eth.c b/drivers/net/ethernet/marvell/pxa168_eth.c
index 5d5000c..b78a838 100644
--- a/drivers/net/ethernet/marvell/pxa168_eth.c
+++ b/drivers/net/ethernet/marvell/pxa168_eth.c
@@ -1209,9 +1209,6 @@ static int pxa168_eth_change_mtu(struct net_device *dev, int mtu)
 	int retval;
 	struct pxa168_eth_private *pep = netdev_priv(dev);
 
-	if ((mtu > 9500) || (mtu < 68))
-		return -EINVAL;
-
 	dev->mtu = mtu;
 	retval = set_port_config_ext(pep);
 
@@ -1459,6 +1456,10 @@ static int pxa168_eth_probe(struct platform_device *pdev)
 	dev->base_addr = 0;
 	dev->ethtool_ops = &pxa168_ethtool_ops;
 
+	/* MTU range: 68 - 9500 */
+	dev->min_mtu = ETH_MIN_MTU;
+	dev->max_mtu = 9500;
+
 	INIT_WORK(&pep->tx_timeout_task, pxa168_eth_tx_timeout_task);
 
 	if (pdev->dev.of_node)
diff --git a/drivers/net/ethernet/marvell/skge.c b/drivers/net/ethernet/marvell/skge.c
index 7173836..9c4b722 100644
--- a/drivers/net/ethernet/marvell/skge.c
+++ b/drivers/net/ethernet/marvell/skge.c
@@ -2900,9 +2900,6 @@ static int skge_change_mtu(struct net_device *dev, int new_mtu)
 {
 	int err;
 
-	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
-		return -EINVAL;
-
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
 		return 0;
@@ -3857,6 +3854,10 @@ static struct net_device *skge_devinit(struct skge_hw *hw, int port,
 	dev->watchdog_timeo = TX_WATCHDOG;
 	dev->irq = hw->pdev->irq;
 
+	/* MTU range: 60 - 9000 */
+	dev->min_mtu = ETH_ZLEN;
+	dev->max_mtu = ETH_JUMBO_MTU;
+
 	if (highmem)
 		dev->features |= NETIF_F_HIGHDMA;
 
diff --git a/drivers/net/ethernet/marvell/sky2.c b/drivers/net/ethernet/marvell/sky2.c
index f05ea56..aa60f4d 100644
--- a/drivers/net/ethernet/marvell/sky2.c
+++ b/drivers/net/ethernet/marvell/sky2.c
@@ -2398,16 +2398,6 @@ static int sky2_change_mtu(struct net_device *dev, int new_mtu)
 	u16 ctl, mode;
 	u32 imask;
 
-	/* MTU size outside the spec */
-	if (new_mtu < ETH_ZLEN || new_mtu > ETH_JUMBO_MTU)
-		return -EINVAL;
-
-	/* MTU > 1500 on yukon FE and FE+ not allowed */
-	if (new_mtu > ETH_DATA_LEN &&
-	    (hw->chip_id == CHIP_ID_YUKON_FE ||
-	     hw->chip_id == CHIP_ID_YUKON_FE_P))
-		return -EINVAL;
-
 	if (!netif_running(dev)) {
 		dev->mtu = new_mtu;
 		netdev_update_features(dev);
@@ -4808,6 +4798,14 @@ static struct net_device *sky2_init_netdev(struct sky2_hw *hw, unsigned port,
 
 	dev->features |= dev->hw_features;
 
+	/* MTU range: 60 - 1500 or 9000 */
+	dev->min_mtu = ETH_ZLEN;
+	if (hw->chip_id == CHIP_ID_YUKON_FE ||
+	    hw->chip_id == CHIP_ID_YUKON_FE_P)
+		dev->max_mtu = ETH_DATA_LEN;
+	else
+		dev->max_mtu = ETH_JUMBO_MTU;
+
 	/* try to get mac address in the following order:
 	 * 1) from device tree data
 	 * 2) from internal registers set by bootloader
-- 
2.10.0

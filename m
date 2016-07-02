From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: cavium: octeon: use phydev from struct net_device
Date: Sat,  2 Jul 2016 23:36:59 +0200
Message-ID: <1467495420-23359-1-git-send-email-tremyfr@gmail.com>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Philippe Reynes <tremyfr@gmail.com>
To: davem@davemloft.net, mugunthanvnm@ti.com, ivecera@redhat.com,
	a@unstable.cc, fw@strlen.de, david.daney@cavium.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phy in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/cavium/octeon/octeon_mgmt.c |   86 ++++++++++------------
 1 files changed, 40 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
index 388cd79..de678e6 100644
--- a/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
+++ b/drivers/net/ethernet/cavium/octeon/octeon_mgmt.c
@@ -146,7 +146,6 @@ struct octeon_mgmt {
 	struct device *dev;
 	struct napi_struct napi;
 	struct tasklet_struct tx_clean_tasklet;
-	struct phy_device *phydev;
 	struct device_node *phy_np;
 	resource_size_t mix_phys;
 	resource_size_t mix_size;
@@ -787,14 +786,12 @@ static int octeon_mgmt_ioctl_hwtstamp(struct net_device *netdev,
 static int octeon_mgmt_ioctl(struct net_device *netdev,
 			     struct ifreq *rq, int cmd)
 {
-	struct octeon_mgmt *p = netdev_priv(netdev);
-
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
 		return octeon_mgmt_ioctl_hwtstamp(netdev, rq, cmd);
 	default:
-		if (p->phydev)
-			return phy_mii_ioctl(p->phydev, rq, cmd);
+		if (netdev->phydev)
+			return phy_mii_ioctl(netdev->phydev, rq, cmd);
 		return -EINVAL;
 	}
 }
@@ -836,16 +833,18 @@ static void octeon_mgmt_enable_link(struct octeon_mgmt *p)
 
 static void octeon_mgmt_update_link(struct octeon_mgmt *p)
 {
+	struct net_device *ndev = p->netdev;
+	struct phy_device *phydev = ndev->phydev;
 	union cvmx_agl_gmx_prtx_cfg prtx_cfg;
 
 	prtx_cfg.u64 = cvmx_read_csr(p->agl + AGL_GMX_PRT_CFG);
 
-	if (!p->phydev->link)
+	if (!phydev->link)
 		prtx_cfg.s.duplex = 1;
 	else
-		prtx_cfg.s.duplex = p->phydev->duplex;
+		prtx_cfg.s.duplex = phydev->duplex;
 
-	switch (p->phydev->speed) {
+	switch (phydev->speed) {
 	case 10:
 		prtx_cfg.s.speed = 0;
 		prtx_cfg.s.slottime = 0;
@@ -871,7 +870,7 @@ static void octeon_mgmt_update_link(struct octeon_mgmt *p)
 			prtx_cfg.s.speed_msb = 0;
 			/* Only matters for half-duplex */
 			prtx_cfg.s.slottime = 1;
-			prtx_cfg.s.burst = p->phydev->duplex;
+			prtx_cfg.s.burst = phydev->duplex;
 		}
 		break;
 	case 0:  /* No link */
@@ -894,9 +893,9 @@ static void octeon_mgmt_update_link(struct octeon_mgmt *p)
 		/* MII (both speeds) and RGMII 1000 speed. */
 		agl_clk.s.clk_cnt = 1;
 		if (prtx_ctl.s.mode == 0) { /* RGMII mode */
-			if (p->phydev->speed == 10)
+			if (phydev->speed == 10)
 				agl_clk.s.clk_cnt = 50;
-			else if (p->phydev->speed == 100)
+			else if (phydev->speed == 100)
 				agl_clk.s.clk_cnt = 5;
 		}
 		cvmx_write_csr(p->agl + AGL_GMX_TX_CLK, agl_clk.u64);
@@ -906,39 +905,40 @@ static void octeon_mgmt_update_link(struct octeon_mgmt *p)
 static void octeon_mgmt_adjust_link(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
+	struct phy_device *phydev = netdev->phydev;
 	unsigned long flags;
 	int link_changed = 0;
 
-	if (!p->phydev)
+	if (!phydev)
 		return;
 
 	spin_lock_irqsave(&p->lock, flags);
 
 
-	if (!p->phydev->link && p->last_link)
+	if (!phydev->link && p->last_link)
 		link_changed = -1;
 
-	if (p->phydev->link
-	    && (p->last_duplex != p->phydev->duplex
-		|| p->last_link != p->phydev->link
-		|| p->last_speed != p->phydev->speed)) {
+	if (phydev->link &&
+	    (p->last_duplex != phydev->duplex ||
+	     p->last_link != phydev->link ||
+	     p->last_speed != phydev->speed)) {
 		octeon_mgmt_disable_link(p);
 		link_changed = 1;
 		octeon_mgmt_update_link(p);
 		octeon_mgmt_enable_link(p);
 	}
 
-	p->last_link = p->phydev->link;
-	p->last_speed = p->phydev->speed;
-	p->last_duplex = p->phydev->duplex;
+	p->last_link = phydev->link;
+	p->last_speed = phydev->speed;
+	p->last_duplex = phydev->duplex;
 
 	spin_unlock_irqrestore(&p->lock, flags);
 
 	if (link_changed != 0) {
 		if (link_changed > 0) {
 			pr_info("%s: Link is up - %d/%s\n", netdev->name,
-				p->phydev->speed,
-				DUPLEX_FULL == p->phydev->duplex ?
+				phydev->speed,
+				phydev->duplex == DUPLEX_FULL ?
 				"Full" : "Half");
 		} else {
 			pr_info("%s: Link is down\n", netdev->name);
@@ -949,6 +949,7 @@ static void octeon_mgmt_adjust_link(struct net_device *netdev)
 static int octeon_mgmt_init_phy(struct net_device *netdev)
 {
 	struct octeon_mgmt *p = netdev_priv(netdev);
+	struct phy_device *phydev = NULL;
 
 	if (octeon_is_simulation() || p->phy_np == NULL) {
 		/* No PHYs in the simulator. */
@@ -956,11 +957,11 @@ static int octeon_mgmt_init_phy(struct net_device *netdev)
 		return 0;
 	}
 
-	p->phydev = of_phy_connect(netdev, p->phy_np,
-				   octeon_mgmt_adjust_link, 0,
-				   PHY_INTERFACE_MODE_MII);
+	phydev = of_phy_connect(netdev, p->phy_np,
+				octeon_mgmt_adjust_link, 0,
+				PHY_INTERFACE_MODE_MII);
 
-	if (!p->phydev)
+	if (!phydev)
 		return -ENODEV;
 
 	return 0;
@@ -1080,9 +1081,9 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	}
 
 	/* Set the mode of the interface, RGMII/MII. */
-	if (OCTEON_IS_MODEL(OCTEON_CN6XXX) && p->phydev) {
+	if (OCTEON_IS_MODEL(OCTEON_CN6XXX) && netdev->phydev) {
 		union cvmx_agl_prtx_ctl agl_prtx_ctl;
-		int rgmii_mode = (p->phydev->supported &
+		int rgmii_mode = (netdev->phydev->supported &
 				  (SUPPORTED_1000baseT_Half | SUPPORTED_1000baseT_Full)) != 0;
 
 		agl_prtx_ctl.u64 = cvmx_read_csr(p->agl_prt_ctl);
@@ -1205,7 +1206,7 @@ static int octeon_mgmt_open(struct net_device *netdev)
 
 	/* Configure the port duplex, speed and enables */
 	octeon_mgmt_disable_link(p);
-	if (p->phydev)
+	if (netdev->phydev)
 		octeon_mgmt_update_link(p);
 	octeon_mgmt_enable_link(p);
 
@@ -1214,9 +1215,9 @@ static int octeon_mgmt_open(struct net_device *netdev)
 	/* PHY is not present in simulator. The carrier is enabled
 	 * while initializing the phy for simulator, leave it enabled.
 	 */
-	if (p->phydev) {
+	if (netdev->phydev) {
 		netif_carrier_off(netdev);
-		phy_start_aneg(p->phydev);
+		phy_start_aneg(netdev->phydev);
 	}
 
 	netif_wake_queue(netdev);
@@ -1244,9 +1245,8 @@ static int octeon_mgmt_stop(struct net_device *netdev)
 	napi_disable(&p->napi);
 	netif_stop_queue(netdev);
 
-	if (p->phydev)
-		phy_disconnect(p->phydev);
-	p->phydev = NULL;
+	if (netdev->phydev)
+		phy_disconnect(netdev->phydev);
 
 	netif_carrier_off(netdev);
 
@@ -1349,10 +1349,8 @@ static void octeon_mgmt_get_drvinfo(struct net_device *netdev,
 static int octeon_mgmt_get_settings(struct net_device *netdev,
 				    struct ethtool_cmd *cmd)
 {
-	struct octeon_mgmt *p = netdev_priv(netdev);
-
-	if (p->phydev)
-		return phy_ethtool_gset(p->phydev, cmd);
+	if (netdev->phydev)
+		return phy_ethtool_gset(netdev->phydev, cmd);
 
 	return -EOPNOTSUPP;
 }
@@ -1360,26 +1358,22 @@ static int octeon_mgmt_get_settings(struct net_device *netdev,
 static int octeon_mgmt_set_settings(struct net_device *netdev,
 				    struct ethtool_cmd *cmd)
 {
-	struct octeon_mgmt *p = netdev_priv(netdev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (p->phydev)
-		return phy_ethtool_sset(p->phydev, cmd);
+	if (netdev->phydev)
+		return phy_ethtool_sset(netdev->phydev, cmd);
 
 	return -EOPNOTSUPP;
 }
 
 static int octeon_mgmt_nway_reset(struct net_device *dev)
 {
-	struct octeon_mgmt *p = netdev_priv(dev);
-
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
 
-	if (p->phydev)
-		return phy_start_aneg(p->phydev);
+	if (dev->phydev)
+		return phy_start_aneg(dev->phydev);
 
 	return -EOPNOTSUPP;
 }
-- 
1.7.4.4

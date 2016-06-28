From: Philippe Reynes <tremyfr@gmail.com>
Subject: [PATCH 1/2] net: ethernet: lpc_eth: use phydev from struct net_device
Date: Tue, 28 Jun 2016 23:59:44 +0200
Message-ID: <1467151185-31403-1-git-send-email-tremyfr@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, Philippe Reynes <tremyfr@gmail.com>
To: vz@mleia.com,
	slemieux.tyco@gmail.com,
	davem@davemloft.net
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

The private structure contain a pointer to phydev, but the structure
net_device already contain such pointer. So we can remove the pointer
phydev in the private structure, and update the driver to use the
one contained in struct net_device.

Signed-off-by: Philippe Reynes <tremyfr@gmail.com>
---
 drivers/net/ethernet/nxp/lpc_eth.c |   22 +++++++++-------------
 1 files changed, 9 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/nxp/lpc_eth.c b/drivers/net/ethernet/nxp/lpc_eth.c
index b1ce7aa..b003501 100644
--- a/drivers/net/ethernet/nxp/lpc_eth.c
+++ b/drivers/net/ethernet/nxp/lpc_eth.c
@@ -425,7 +425,6 @@ struct netdata_local {
 	unsigned int		last_tx_idx;
 	unsigned int		num_used_tx_buffs;
 	struct mii_bus		*mii_bus;
-	struct phy_device	*phy_dev;
 	struct clk		*clk;
 	dma_addr_t		dma_buff_base_p;
 	void			*dma_buff_base_v;
@@ -750,7 +749,7 @@ static int lpc_mdio_reset(struct mii_bus *bus)
 static void lpc_handle_link_change(struct net_device *ndev)
 {
 	struct netdata_local *pldat = netdev_priv(ndev);
-	struct phy_device *phydev = pldat->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 	unsigned long flags;
 
 	bool status_change = false;
@@ -814,7 +813,6 @@ static int lpc_mii_probe(struct net_device *ndev)
 	pldat->link = 0;
 	pldat->speed = 0;
 	pldat->duplex = -1;
-	pldat->phy_dev = phydev;
 
 	phy_attached_info(phydev);
 
@@ -1048,8 +1046,8 @@ static int lpc_eth_close(struct net_device *ndev)
 	napi_disable(&pldat->napi);
 	netif_stop_queue(ndev);
 
-	if (pldat->phy_dev)
-		phy_stop(pldat->phy_dev);
+	if (ndev->phydev)
+		phy_stop(ndev->phydev);
 
 	spin_lock_irqsave(&pldat->lock, flags);
 	__lpc_eth_reset(pldat);
@@ -1186,7 +1184,7 @@ static void lpc_eth_set_multicast_list(struct net_device *ndev)
 static int lpc_eth_ioctl(struct net_device *ndev, struct ifreq *req, int cmd)
 {
 	struct netdata_local *pldat = netdev_priv(ndev);
-	struct phy_device *phydev = pldat->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!netif_running(ndev))
 		return -EINVAL;
@@ -1207,14 +1205,14 @@ static int lpc_eth_open(struct net_device *ndev)
 	__lpc_eth_clock_enable(pldat, true);
 
 	/* Suspended PHY makes LPC ethernet core block, so resume now */
-	phy_resume(pldat->phy_dev);
+	phy_resume(ndev->phydev);
 
 	/* Reset and initialize */
 	__lpc_eth_reset(pldat);
 	__lpc_eth_init(pldat);
 
 	/* schedule a link state check */
-	phy_start(pldat->phy_dev);
+	phy_start(ndev->phydev);
 	netif_start_queue(ndev);
 	napi_enable(&pldat->napi);
 
@@ -1250,8 +1248,7 @@ static void lpc_eth_ethtool_setmsglevel(struct net_device *ndev, u32 level)
 static int lpc_eth_ethtool_getsettings(struct net_device *ndev,
 	struct ethtool_cmd *cmd)
 {
-	struct netdata_local *pldat = netdev_priv(ndev);
-	struct phy_device *phydev = pldat->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!phydev)
 		return -EOPNOTSUPP;
@@ -1262,8 +1259,7 @@ static int lpc_eth_ethtool_getsettings(struct net_device *ndev,
 static int lpc_eth_ethtool_setsettings(struct net_device *ndev,
 	struct ethtool_cmd *cmd)
 {
-	struct netdata_local *pldat = netdev_priv(ndev);
-	struct phy_device *phydev = pldat->phy_dev;
+	struct phy_device *phydev = ndev->phydev;
 
 	if (!phydev)
 		return -EOPNOTSUPP;
@@ -1460,7 +1456,7 @@ static int lpc_eth_drv_probe(struct platform_device *pdev)
 	netdev_info(ndev, "LPC mac at 0x%08x irq %d\n",
 	       res->start, ndev->irq);
 
-	phydev = pldat->phy_dev;
+	phydev = ndev->phydev;
 
 	device_init_wakeup(&pdev->dev, 1);
 	device_set_wakeup_enable(&pdev->dev, 0);
-- 
1.7.4.4

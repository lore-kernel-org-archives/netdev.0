From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 05/15] drivers: net: cpsw: ndev: fix accessing to suspended device
Date: Fri, 24 Jun 2016 21:23:45 +0300
Message-ID: <20160624182355.23515-6-grygorii.strashko@ti.com>
References: <20160624182355.23515-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
	<linux-omap@vger.kernel.org>,
	Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>,
	Rob Herring <robh+dt@kernel.org>, <devicetree@vger.kernel.org>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160624182355.23515-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The CPSW might be suspended by RPM if all ethX interfaces are down,
but it still could be accesible through net_device_ops interfce. In
this case net_device_ops operations requiring registers access will
cause L3 errors and CPSW crash.

Hence, fix it by adding RPM get/put calls in net_device_ops callbacks
which need to access CPSW registers: .ndo_set_mac_address(),
.ndo_vlan_rx_add_vid(), .ndo_vlan_rx_kill_vid().

Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpsw.c | 33 ++++++++++++++++++++++++++++++---
 1 file changed, 30 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
index 5fea986..33f9957 100644
--- a/drivers/net/ethernet/ti/cpsw.c
+++ b/drivers/net/ethernet/ti/cpsw.c
@@ -1616,10 +1616,17 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	struct sockaddr *addr = (struct sockaddr *)p;
 	int flags = 0;
 	u16 vid = 0;
+	int ret;
 
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
 
+	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&priv->pdev->dev);
+		return ret;
+	}
+
 	if (priv->data.dual_emac) {
 		vid = priv->slaves[priv->emac_port].port_vlan;
 		flags = ALE_VLAN;
@@ -1634,6 +1641,8 @@ static int cpsw_ndo_set_mac_address(struct net_device *ndev, void *p)
 	memcpy(ndev->dev_addr, priv->mac_addr, ETH_ALEN);
 	for_each_slave(priv, cpsw_set_slave_mac, priv);
 
+	pm_runtime_put(&priv->pdev->dev);
+
 	return 0;
 }
 
@@ -1698,10 +1707,17 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 				    __be16 proto, u16 vid)
 {
 	struct cpsw_priv *priv = netdev_priv(ndev);
+	int ret;
 
 	if (vid == priv->data.default_vlan)
 		return 0;
 
+	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&priv->pdev->dev);
+		return ret;
+	}
+
 	if (priv->data.dual_emac) {
 		/* In dual EMAC, reserved VLAN id should not be used for
 		 * creating VLAN interfaces as this can break the dual
@@ -1716,7 +1732,10 @@ static int cpsw_ndo_vlan_rx_add_vid(struct net_device *ndev,
 	}
 
 	dev_info(priv->dev, "Adding vlanid %d to vlan filter\n", vid);
-	return cpsw_add_vlan_ale_entry(priv, vid);
+	ret = cpsw_add_vlan_ale_entry(priv, vid);
+
+	pm_runtime_put(&priv->pdev->dev);
+	return ret;
 }
 
 static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
@@ -1728,6 +1747,12 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	if (vid == priv->data.default_vlan)
 		return 0;
 
+	ret = pm_runtime_get_sync(&priv->pdev->dev);
+	if (ret < 0) {
+		pm_runtime_put_noidle(&priv->pdev->dev);
+		return ret;
+	}
+
 	if (priv->data.dual_emac) {
 		int i;
 
@@ -1747,8 +1772,10 @@ static int cpsw_ndo_vlan_rx_kill_vid(struct net_device *ndev,
 	if (ret != 0)
 		return ret;
 
-	return cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast,
-				  0, ALE_VLAN, vid);
+	ret = cpsw_ale_del_mcast(priv->ale, priv->ndev->broadcast,
+				 0, ALE_VLAN, vid);
+	pm_runtime_put(&priv->pdev->dev);
+	return ret;
 }
 
 static const struct net_device_ops cpsw_netdev_ops = {
-- 
2.9.0

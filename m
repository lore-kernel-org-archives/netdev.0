From: Harvey Hunt <harvey.hunt@imgtec.com>
Subject: [PATCH v2 net] drivers: net: Don't print unpopulated net_device name
Date: Tue, 17 May 2016 14:33:27 +0100
Message-ID: <1463492007-12013-1-git-send-email-harvey.hunt@imgtec.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Harvey Hunt <harvey.hunt@imgtec.com>,
	Marcel Ziswiler <marcel@ziswiler.com>,
	Robert Jarzmik <robert.jarzmik@free.fr>,
	Barry Song <Baohua.Song@csr.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For ethernet devices, net_device.name will be eth%d before
register_netdev() is called. Don't print the net_device name until
the format string is replaced.

Signed-off-by: Harvey Hunt <harvey.hunt@imgtec.com>
Cc: Marcel Ziswiler <marcel@ziswiler.com>
Cc: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: Barry Song <Baohua.Song@csr.com>
Cc: netdev@vger.kernel.org
Cc: linux-kernel@vger.kernel.org 
---
v1 -> v2:
 - Replace ifconfig with ip
 - Delay printk until the netdev name is known

Tested on a board with a DM9000 and compile tested for the other two
platforms.

 drivers/net/ethernet/davicom/dm9000.c   | 11 +++++++----
 drivers/net/ethernet/micrel/ks8695net.c |  7 +++++--
 drivers/net/ethernet/netx-eth.c         | 12 ++++++++----
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/davicom/dm9000.c b/drivers/net/ethernet/davicom/dm9000.c
index 48d9194..161274b 100644
--- a/drivers/net/ethernet/davicom/dm9000.c
+++ b/drivers/net/ethernet/davicom/dm9000.c
@@ -1432,6 +1432,7 @@ dm9000_probe(struct platform_device *pdev)
 	int reset_gpios;
 	enum of_gpio_flags flags;
 	struct regulator *power;
+	bool inv_mac_addr = false;
 
 	power = devm_regulator_get(dev, "vcc");
 	if (IS_ERR(power)) {
@@ -1686,9 +1687,7 @@ dm9000_probe(struct platform_device *pdev)
 	}
 
 	if (!is_valid_ether_addr(ndev->dev_addr)) {
-		dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please "
-			 "set using ifconfig\n", ndev->name);
-
+		inv_mac_addr = true;
 		eth_hw_addr_random(ndev);
 		mac_src = "random";
 	}
@@ -1697,11 +1696,15 @@ dm9000_probe(struct platform_device *pdev)
 	platform_set_drvdata(pdev, ndev);
 	ret = register_netdev(ndev);
 
-	if (ret == 0)
+	if (ret == 0) {
+		if (inv_mac_addr)
+			dev_warn(db->dev, "%s: Invalid ethernet MAC address. Please set using ip\n",
+				 ndev->name);
 		printk(KERN_INFO "%s: dm9000%c at %p,%p IRQ %d MAC: %pM (%s)\n",
 		       ndev->name, dm9000_type_to_char(db->type),
 		       db->io_addr, db->io_data, ndev->irq,
 		       ndev->dev_addr, mac_src);
+	}
 	return 0;
 
 out:
diff --git a/drivers/net/ethernet/micrel/ks8695net.c b/drivers/net/ethernet/micrel/ks8695net.c
index a8522d8..20cb85b 100644
--- a/drivers/net/ethernet/micrel/ks8695net.c
+++ b/drivers/net/ethernet/micrel/ks8695net.c
@@ -1354,6 +1354,7 @@ ks8695_probe(struct platform_device *pdev)
 	struct resource *rxirq_res, *txirq_res, *linkirq_res;
 	int ret = 0;
 	int buff_n;
+	bool inv_mac_addr = false;
 	u32 machigh, maclow;
 
 	/* Initialise a net_device */
@@ -1456,8 +1457,7 @@ ks8695_probe(struct platform_device *pdev)
 	ndev->dev_addr[5] = maclow & 0xFF;
 
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		dev_warn(ksp->dev, "%s: Invalid ethernet MAC address. Please "
-			 "set using ifconfig\n", ndev->name);
+		inv_mac_addr = true;
 
 	/* In order to be efficient memory-wise, we allocate both
 	 * rings in one go.
@@ -1520,6 +1520,9 @@ ks8695_probe(struct platform_device *pdev)
 	ret = register_netdev(ndev);
 
 	if (ret == 0) {
+		if (inv_mac_addr)
+			dev_warn(ksp->dev, "%s: Invalid ethernet MAC address. Please set using ip\n",
+				 ndev->name);
 		dev_info(ksp->dev, "ks8695 ethernet (%s) MAC: %pM\n",
 			 ks8695_port_type(ksp), ndev->dev_addr);
 	} else {
diff --git a/drivers/net/ethernet/netx-eth.c b/drivers/net/ethernet/netx-eth.c
index 9fbc302..adbc47f 100644
--- a/drivers/net/ethernet/netx-eth.c
+++ b/drivers/net/ethernet/netx-eth.c
@@ -313,7 +313,8 @@ static int netx_eth_enable(struct net_device *ndev)
 {
 	struct netx_eth_priv *priv = netdev_priv(ndev);
 	unsigned int mac4321, mac65;
-	int running, i;
+	int running, i, ret;
+	bool inv_mac_addr = false;
 
 	ndev->netdev_ops = &netx_eth_netdev_ops;
 	ndev->watchdog_timeo = msecs_to_jiffies(5000);
@@ -358,15 +359,18 @@ static int netx_eth_enable(struct net_device *ndev)
 	xc_start(priv->xc);
 
 	if (!is_valid_ether_addr(ndev->dev_addr))
-		printk("%s: Invalid ethernet MAC address.  Please "
-		       "set using ifconfig\n", ndev->name);
+		inv_mac_addr = true;
 
 	for (i=2; i<=18; i++)
 		pfifo_push(EMPTY_PTR_FIFO(priv->id),
 			FIFO_PTR_FRAMENO(i) | FIFO_PTR_SEGMENT(priv->id));
 
-	return register_netdev(ndev);
+	ret = register_netdev(ndev);
+	if (inv_mac_addr)
+		printk("%s: Invalid ethernet MAC address. Please set using ip\n",
+		       ndev->name);
 
+	return ret;
 }
 
 static int netx_eth_drv_probe(struct platform_device *pdev)
-- 
2.8.2

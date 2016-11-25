From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next 4/5] net: mvneta: Add network support for Armada 3700 SoC
Date: Fri, 25 Nov 2016 16:30:17 +0100
Message-ID: <b207e3dcc20108bc1720f9e112dc35aae60b6e34.1480087510.git-series.gregory.clement@free-electrons.com>
References: <cover.2b146800967005632cd02d4da77397e6e2fdf51f.1480087510.git-series.gregory.clement@free-electrons.com>
Cc: Jisheng Zhang <jszhang@marvell.com>, Arnd Bergmann <arnd@arndb.de>,
        Jason Cooper <jason@lakedaemon.net>,
        Andrew Lunn <andrew@lunn.ch>,
        Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
        Gregory CLEMENT <gregory.clement@free-electrons.com>,
        Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
        linux-arm-kernel@lists.infradead.org,
        Nadav Haklai <nadavh@marvell.com>,
        Marcin Wojtas <mw@semihalf.com>,
        Dmitri Epshtein <dima@marvell.com>,
        Yelena Krivosheev <yelena@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.free-electrons.com ([62.4.15.54]:44039 "EHLO
        mail.free-electrons.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754813AbcKYPbV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 10:31:21 -0500
In-Reply-To: <cover.2b146800967005632cd02d4da77397e6e2fdf51f.1480087510.git-series.gregory.clement@free-electrons.com>
In-Reply-To: <cover.2b146800967005632cd02d4da77397e6e2fdf51f.1480087510.git-series.gregory.clement@free-electrons.com>
References: <cover.2b146800967005632cd02d4da77397e6e2fdf51f.1480087510.git-series.gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcin Wojtas <mw@semihalf.com>

Armada 3700 is a new ARMv8 SoC from Marvell using same network controller
as older Armada 370/38x/XP. There are however some differences that
needed taking into account when adding support for it:

* open default MBUS window to 4GB of DRAM - Armada 3700 SoC's Mbus
  configuration for network controller has to be done on two levels:
  global and per-port. The first one is inherited from the
  bootloader. The latter can be opened in a default way, leaving
  arbitration to the bus controller.  Hence filled mbus_dram_target_info
  structure is not needed

* make per-CPU operation optional - Recent patches adding RSS and XPS
  support for Armada 38x/XP enabled per-CPU operation of the controller
  by default. Contrary to older SoC's Armada 3700 SoC's network
  controller is not capable of per-CPU processing due to interrupt lines'
  connectivity.  This patch restores non-per-CPU operation, which is now
  optional and depends on neta_armada3700 flag value in mvneta_port
  structure. In order not to complicate the code, separate interrupt
  subroutine is implemented.

For now, on the Armada 3700, RSS is disabled as the current
implementation depend on the per cpu interrupts.

[gregory.clement@free-electrons.com: extract from a larger patch, replace
some ifdef and port to net-next for v4.10]

Signed-off-by: Marcin Wojtas <mw@semihalf.com>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt |   7 +-
 drivers/net/ethernet/marvell/Kconfig                              |   7 +-
 drivers/net/ethernet/marvell/mvneta.c                             | 287 +++++++++++++++++++++++++++++++++++++++++++++++++++---------------------
 3 files changed, 214 insertions(+), 87 deletions(-)

diff --git a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
index 73be8970815e..7aa840c8768d 100644
--- a/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
+++ b/Documentation/devicetree/bindings/net/marvell-armada-370-neta.txt
@@ -1,7 +1,10 @@
-* Marvell Armada 370 / Armada XP Ethernet Controller (NETA)
+* Marvell Armada 370 / Armada XP / Armada 3700 Ethernet Controller (NETA)
 
 Required properties:
-- compatible: "marvell,armada-370-neta" or "marvell,armada-xp-neta".
+- compatible: could be one of the followings
+	"marvell,armada-370-neta"
+	"marvell,armada-xp-neta"
+	"marvell,armada-3700-neta"
 - reg: address and length of the register set for the device.
 - interrupts: interrupt for the device
 - phy: See ethernet.txt file in the same directory.
diff --git a/drivers/net/ethernet/marvell/Kconfig b/drivers/net/ethernet/marvell/Kconfig
index 2ccea9dd9248..3b8f11fe5e13 100644
--- a/drivers/net/ethernet/marvell/Kconfig
+++ b/drivers/net/ethernet/marvell/Kconfig
@@ -56,14 +56,15 @@ config MVNETA_BM_ENABLE
 	  buffer management.
 
 config MVNETA
-	tristate "Marvell Armada 370/38x/XP network interface support"
-	depends on PLAT_ORION || COMPILE_TEST
+	tristate "Marvell Armada 370/38x/XP/37xx network interface support"
+	depends on ARCH_MVEBU || COMPILE_TEST
 	depends on HAS_DMA
 	select MVMDIO
 	select FIXED_PHY
 	---help---
 	  This driver supports the network interface units in the
-	  Marvell ARMADA XP, ARMADA 370 and ARMADA 38x SoC family.
+	  Marvell ARMADA XP, ARMADA 370, ARMADA 38x and
+	  ARMADA 37xx SoC family.
 
 	  Note that this driver is distinct from the mv643xx_eth
 	  driver, which should be used for the older Marvell SoCs
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index ad3872e07a93..77cef5a9de7b 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -397,6 +397,9 @@ struct mvneta_port {
 	spinlock_t lock;
 	bool is_stopped;
 
+	u32 cause_rx_tx;
+	struct napi_struct napi;
+
 	/* Core clock */
 	struct clk *clk;
 	/* AXI clock */
@@ -422,6 +425,9 @@ struct mvneta_port {
 	u64 ethtool_stats[ARRAY_SIZE(mvneta_statistics)];
 
 	u32 indir[MVNETA_RSS_LU_TABLE_SIZE];
+
+	/* Flags for special SoC configurations */
+	bool neta_armada3700;
 	u16 rx_offset_correction;
 };
 
@@ -965,14 +971,9 @@ static int mvneta_mbus_io_win_set(struct mvneta_port *pp, u32 base, u32 wsize,
 	return 0;
 }
 
-/* Assign and initialize pools for port. In case of fail
- * buffer manager will remain disabled for current port.
- */
-static int mvneta_bm_port_init(struct platform_device *pdev,
-			       struct mvneta_port *pp)
+static  int mvneta_bm_port_mbus_init(struct mvneta_port *pp)
 {
-	struct device_node *dn = pdev->dev.of_node;
-	u32 long_pool_id, short_pool_id, wsize;
+	u32 wsize;
 	u8 target, attr;
 	int err;
 
@@ -991,6 +992,25 @@ static int mvneta_bm_port_init(struct platform_device *pdev,
 		netdev_info(pp->dev, "fail to configure mbus window to BM\n");
 		return err;
 	}
+	return 0;
+}
+
+/* Assign and initialize pools for port. In case of fail
+ * buffer manager will remain disabled for current port.
+ */
+static int mvneta_bm_port_init(struct platform_device *pdev,
+			       struct mvneta_port *pp)
+{
+	struct device_node *dn = pdev->dev.of_node;
+	u32 long_pool_id, short_pool_id;
+
+	if (!pp->neta_armada3700) {
+		int ret;
+
+		ret = mvneta_bm_port_mbus_init(pp);
+		if (ret)
+			return ret;
+	}
 
 	if (of_property_read_u32(dn, "bm,pool-long", &long_pool_id)) {
 		netdev_info(pp->dev, "missing long pool id\n");
@@ -1359,22 +1379,27 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	for_each_present_cpu(cpu) {
 		int rxq_map = 0, txq_map = 0;
 		int rxq, txq;
+		if (!pp->neta_armada3700) {
+			for (rxq = 0; rxq < rxq_number; rxq++)
+				if ((rxq % max_cpu) == cpu)
+					rxq_map |= MVNETA_CPU_RXQ_ACCESS(rxq);
+
+			for (txq = 0; txq < txq_number; txq++)
+				if ((txq % max_cpu) == cpu)
+					txq_map |= MVNETA_CPU_TXQ_ACCESS(txq);
+
+			/* With only one TX queue we configure a special case
+			 * which will allow to get all the irq on a single
+			 * CPU
+			 */
+			if (txq_number == 1)
+				txq_map = (cpu == pp->rxq_def) ?
+					MVNETA_CPU_TXQ_ACCESS(1) : 0;
 
-		for (rxq = 0; rxq < rxq_number; rxq++)
-			if ((rxq % max_cpu) == cpu)
-				rxq_map |= MVNETA_CPU_RXQ_ACCESS(rxq);
-
-		for (txq = 0; txq < txq_number; txq++)
-			if ((txq % max_cpu) == cpu)
-				txq_map |= MVNETA_CPU_TXQ_ACCESS(txq);
-
-		/* With only one TX queue we configure a special case
-		 * which will allow to get all the irq on a single
-		 * CPU
-		 */
-		if (txq_number == 1)
-			txq_map = (cpu == pp->rxq_def) ?
-				MVNETA_CPU_TXQ_ACCESS(1) : 0;
+		} else {
+			txq_map = MVNETA_CPU_TXQ_ACCESS_ALL_MASK;
+			rxq_map = MVNETA_CPU_RXQ_ACCESS_ALL_MASK;
+		}
 
 		mvreg_write(pp, MVNETA_CPU_MAP(cpu), rxq_map | txq_map);
 	}
@@ -2632,6 +2657,17 @@ static void mvneta_set_rx_mode(struct net_device *dev)
 /* Interrupt handling - the callback for request_irq() */
 static irqreturn_t mvneta_isr(int irq, void *dev_id)
 {
+	struct mvneta_port *pp = (struct mvneta_port *)dev_id;
+
+	mvreg_write(pp, MVNETA_INTR_NEW_MASK, 0);
+	napi_schedule(&pp->napi);
+
+	return IRQ_HANDLED;
+}
+
+/* Interrupt handling - the callback for request_percpu_irq() */
+static irqreturn_t mvneta_percpu_isr(int irq, void *dev_id)
+{
 	struct mvneta_pcpu_port *port = (struct mvneta_pcpu_port *)dev_id;
 
 	disable_percpu_irq(port->pp->dev->irq);
@@ -2679,7 +2715,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	struct mvneta_pcpu_port *port = this_cpu_ptr(pp->ports);
 
 	if (!netif_running(pp->dev)) {
-		napi_complete(&port->napi);
+		napi_complete(napi);
 		return rx_done;
 	}
 
@@ -2708,7 +2744,8 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	 */
 	rx_queue = fls(((cause_rx_tx >> 8) & 0xff));
 
-	cause_rx_tx |= port->cause_rx_tx;
+	cause_rx_tx |= pp->neta_armada3700 ? pp->cause_rx_tx :
+		port->cause_rx_tx;
 
 	if (rx_queue) {
 		rx_queue = rx_queue - 1;
@@ -2722,11 +2759,27 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 
 	if (budget > 0) {
 		cause_rx_tx = 0;
-		napi_complete(&port->napi);
-		enable_percpu_irq(pp->dev->irq, 0);
+		napi_complete(napi);
+
+		if (pp->neta_armada3700) {
+			unsigned long flags;
+
+			local_irq_save(flags);
+			mvreg_write(pp, MVNETA_INTR_NEW_MASK,
+				    MVNETA_RX_INTR_MASK(rxq_number) |
+				    MVNETA_TX_INTR_MASK(txq_number) |
+				    MVNETA_MISCINTR_INTR_MASK);
+			local_irq_restore(flags);
+		} else {
+			enable_percpu_irq(pp->dev->irq, 0);
+		}
 	}
 
-	port->cause_rx_tx = cause_rx_tx;
+	if (pp->neta_armada3700)
+		pp->cause_rx_tx = cause_rx_tx;
+	else
+		port->cause_rx_tx = cause_rx_tx;
+
 	return rx_done;
 }
 
@@ -3054,11 +3107,16 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 	/* start the Rx/Tx activity */
 	mvneta_port_enable(pp);
 
-	/* Enable polling on the port */
-	for_each_online_cpu(cpu) {
-		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
+	if (!pp->neta_armada3700) {
+		/* Enable polling on the port */
+		for_each_online_cpu(cpu) {
+			struct mvneta_pcpu_port *port =
+				per_cpu_ptr(pp->ports, cpu);
 
-		napi_enable(&port->napi);
+			napi_enable(&port->napi);
+		}
+	} else {
+		napi_enable(&pp->napi);
 	}
 
 	/* Unmask interrupts. It has to be done from each CPU */
@@ -3080,10 +3138,15 @@ static void mvneta_stop_dev(struct mvneta_port *pp)
 
 	phy_stop(ndev->phydev);
 
-	for_each_online_cpu(cpu) {
-		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
+	if (!pp->neta_armada3700) {
+		for_each_online_cpu(cpu) {
+			struct mvneta_pcpu_port *port =
+				per_cpu_ptr(pp->ports, cpu);
 
-		napi_disable(&port->napi);
+			napi_disable(&port->napi);
+		}
+	} else {
+		napi_disable(&pp->napi);
 	}
 
 	netif_carrier_off(pp->dev);
@@ -3493,31 +3556,37 @@ static int mvneta_open(struct net_device *dev)
 		goto err_cleanup_rxqs;
 
 	/* Connect to port interrupt line */
-	ret = request_percpu_irq(pp->dev->irq, mvneta_isr,
-				 MVNETA_DRIVER_NAME, pp->ports);
+	if (pp->neta_armada3700)
+		ret = request_irq(pp->dev->irq, mvneta_isr, 0,
+				  dev->name, pp);
+	else
+		ret = request_percpu_irq(pp->dev->irq, mvneta_percpu_isr,
+					 dev->name, pp->ports);
 	if (ret) {
 		netdev_err(pp->dev, "cannot request irq %d\n", pp->dev->irq);
 		goto err_cleanup_txqs;
 	}
 
-	/* Enable per-CPU interrupt on all the CPU to handle our RX
-	 * queue interrupts
-	 */
-	on_each_cpu(mvneta_percpu_enable, pp, true);
+	if (!pp->neta_armada3700) {
+		/* Enable per-CPU interrupt on all the CPU to handle our RX
+		 * queue interrupts
+		 */
+		on_each_cpu(mvneta_percpu_enable, pp, true);
 
-	pp->is_stopped = false;
-	/* Register a CPU notifier to handle the case where our CPU
-	 * might be taken offline.
-	 */
-	ret = cpuhp_state_add_instance_nocalls(online_hpstate,
-					       &pp->node_online);
-	if (ret)
-		goto err_free_irq;
+		pp->is_stopped = false;
+		/* Register a CPU notifier to handle the case where our CPU
+		 * might be taken offline.
+		 */
+		ret = cpuhp_state_add_instance_nocalls(online_hpstate,
+						       &pp->node_online);
+		if (ret)
+			goto err_free_irq;
 
-	ret = cpuhp_state_add_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
-					       &pp->node_dead);
-	if (ret)
-		goto err_free_online_hp;
+		ret = cpuhp_state_add_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
+						       &pp->node_dead);
+		if (ret)
+			goto err_free_online_hp;
+	}
 
 	/* In default link is down */
 	netif_carrier_off(pp->dev);
@@ -3533,13 +3602,20 @@ static int mvneta_open(struct net_device *dev)
 	return 0;
 
 err_free_dead_hp:
-	cpuhp_state_remove_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
-					    &pp->node_dead);
+	if (!pp->neta_armada3700)
+		cpuhp_state_remove_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
+						    &pp->node_dead);
 err_free_online_hp:
-	cpuhp_state_remove_instance_nocalls(online_hpstate, &pp->node_online);
+	if (!pp->neta_armada3700)
+		cpuhp_state_remove_instance_nocalls(online_hpstate,
+						    &pp->node_online);
 err_free_irq:
-	on_each_cpu(mvneta_percpu_disable, pp, true);
-	free_percpu_irq(pp->dev->irq, pp->ports);
+	if (pp->neta_armada3700) {
+		free_irq(pp->dev->irq, pp);
+	} else {
+		on_each_cpu(mvneta_percpu_disable, pp, true);
+		free_percpu_irq(pp->dev->irq, pp->ports);
+	}
 err_cleanup_txqs:
 	mvneta_cleanup_txqs(pp);
 err_cleanup_rxqs:
@@ -3552,23 +3628,30 @@ static int mvneta_stop(struct net_device *dev)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
 
-	/* Inform that we are stopping so we don't want to setup the
-	 * driver for new CPUs in the notifiers. The code of the
-	 * notifier for CPU online is protected by the same spinlock,
-	 * so when we get the lock, the notifer work is done.
-	 */
-	spin_lock(&pp->lock);
-	pp->is_stopped = true;
-	spin_unlock(&pp->lock);
+	if (!pp->neta_armada3700) {
+		/* Inform that we are stopping so we don't want to setup the
+		 * driver for new CPUs in the notifiers. The code of the
+		 * notifier for CPU online is protected by the same spinlock,
+		 * so when we get the lock, the notifer work is done.
+		 */
+		spin_lock(&pp->lock);
+		pp->is_stopped = true;
+		spin_unlock(&pp->lock);
 
-	mvneta_stop_dev(pp);
-	mvneta_mdio_remove(pp);
+		mvneta_stop_dev(pp);
+		mvneta_mdio_remove(pp);
 
 	cpuhp_state_remove_instance_nocalls(online_hpstate, &pp->node_online);
 	cpuhp_state_remove_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
 					    &pp->node_dead);
-	on_each_cpu(mvneta_percpu_disable, pp, true);
-	free_percpu_irq(dev->irq, pp->ports);
+		on_each_cpu(mvneta_percpu_disable, pp, true);
+		free_percpu_irq(dev->irq, pp->ports);
+	} else {
+		mvneta_stop_dev(pp);
+		mvneta_mdio_remove(pp);
+		free_irq(dev->irq, pp);
+	}
+
 	mvneta_cleanup_rxqs(pp);
 	mvneta_cleanup_txqs(pp);
 
@@ -3847,6 +3930,11 @@ static int mvneta_ethtool_set_rxfh(struct net_device *dev, const u32 *indir,
 				   const u8 *key, const u8 hfunc)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
+
+	/* Current code for Armada 3700 doesn't support RSS features yet */
+	if (pp->neta_armada3700)
+		return -EOPNOTSUPP;
+
 	/* We require at least one supported parameter to be changed
 	 * and no change in any of the unsupported parameters
 	 */
@@ -3867,6 +3955,10 @@ static int mvneta_ethtool_get_rxfh(struct net_device *dev, u32 *indir, u8 *key,
 {
 	struct mvneta_port *pp = netdev_priv(dev);
 
+	/* Current code for Armada 3700 doesn't support RSS features yet */
+	if (pp->neta_armada3700)
+		return -EOPNOTSUPP;
+
 	if (hfunc)
 		*hfunc = ETH_RSS_HASH_TOP;
 
@@ -3969,16 +4061,29 @@ static void mvneta_conf_mbus_windows(struct mvneta_port *pp,
 	win_enable = 0x3f;
 	win_protect = 0;
 
-	for (i = 0; i < dram->num_cs; i++) {
-		const struct mbus_dram_window *cs = dram->cs + i;
-		mvreg_write(pp, MVNETA_WIN_BASE(i), (cs->base & 0xffff0000) |
-			    (cs->mbus_attr << 8) | dram->mbus_dram_target_id);
+	if (dram) {
+		for (i = 0; i < dram->num_cs; i++) {
+			const struct mbus_dram_window *cs = dram->cs + i;
+
+			mvreg_write(pp, MVNETA_WIN_BASE(i),
+				    (cs->base & 0xffff0000) |
+				    (cs->mbus_attr << 8) |
+				    dram->mbus_dram_target_id);
 
-		mvreg_write(pp, MVNETA_WIN_SIZE(i),
-			    (cs->size - 1) & 0xffff0000);
+			mvreg_write(pp, MVNETA_WIN_SIZE(i),
+				    (cs->size - 1) & 0xffff0000);
 
-		win_enable &= ~(1 << i);
-		win_protect |= 3 << (2 * i);
+			win_enable &= ~(1 << i);
+			win_protect |= 3 << (2 * i);
+		}
+	} else {
+		/* For Armada3700 open default 4GB Mbus window, leaving
+		 * arbitration of target/attribute to a different layer
+		 * of configuration.
+		 */
+		mvreg_write(pp, MVNETA_WIN_SIZE(0), 0xffff0000);
+		win_enable &= ~BIT(0);
+		win_protect = 3;
 	}
 
 	mvreg_write(pp, MVNETA_BASE_ADDR_ENABLE, win_enable);
@@ -4108,6 +4213,10 @@ static int mvneta_probe(struct platform_device *pdev)
 
 	pp->indir[0] = rxq_def;
 
+	/* Get special SoC configurations */
+	if (of_device_is_compatible(dn, "marvell,armada-3700-neta"))
+		pp->neta_armada3700 = true;
+
 	pp->clk = devm_clk_get(&pdev->dev, "core");
 	if (IS_ERR(pp->clk))
 		pp->clk = devm_clk_get(&pdev->dev, NULL);
@@ -4175,7 +4284,11 @@ static int mvneta_probe(struct platform_device *pdev)
 	pp->tx_csum_limit = tx_csum_limit;
 
 	dram_target_info = mv_mbus_dram_info();
-	if (dram_target_info)
+	/* Armada3700 requires setting default configuration of Mbus
+	 * windows, however without using filled mbus_dram_target_info
+	 * structure.
+	 */
+	if (dram_target_info || pp->neta_armada3700)
 		mvneta_conf_mbus_windows(pp, dram_target_info);
 
 	pp->tx_ring_size = MVNETA_MAX_TXD;
@@ -4208,11 +4321,20 @@ static int mvneta_probe(struct platform_device *pdev)
 		goto err_netdev;
 	}
 
-	for_each_present_cpu(cpu) {
-		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
+	/* Armada3700 network controller does not support per-cpu
+	 * operation, so only single NAPI should be initialized.
+	 */
+	if (pp->neta_armada3700) {
+		netif_napi_add(dev, &pp->napi, mvneta_poll, NAPI_POLL_WEIGHT);
+	} else {
+		for_each_present_cpu(cpu) {
+			struct mvneta_pcpu_port *port =
+				per_cpu_ptr(pp->ports, cpu);
 
-		netif_napi_add(dev, &port->napi, mvneta_poll, NAPI_POLL_WEIGHT);
-		port->pp = pp;
+			netif_napi_add(dev, &port->napi, mvneta_poll,
+				       NAPI_POLL_WEIGHT);
+			port->pp = pp;
+		}
 	}
 
 	dev->features = NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
@@ -4297,6 +4419,7 @@ static int mvneta_remove(struct platform_device *pdev)
 static const struct of_device_id mvneta_match[] = {
 	{ .compatible = "marvell,armada-370-neta" },
 	{ .compatible = "marvell,armada-xp-neta" },
+	{ .compatible = "marvell,armada-3700-neta" },
 	{ }
 };
 MODULE_DEVICE_TABLE(of, mvneta_match);
-- 
git-series 0.8.10

From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net-next v3 1/4] net: mvneta: Make the default queue related
 for each port
Date: Wed,  9 Dec 2015 18:23:48 +0100
Message-ID: <1449681831-2798-2-git-send-email-gregory.clement@free-electrons.com>
References: <1449681831-2798-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Arnd Bergmann <arnd@arndb.de>,
 Boris BREZILLON <boris.brezillon@free-electrons.com>,
 Simon Guinot <simon.guinot@sequanux.org>, Nadav Haklai <nadavh@marvell.com>,
 Ezequiel Garcia <ezequiel.garcia@free-electrons.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Maxime Ripard <maxime.ripard@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1449681831-2798-1-git-send-email-gregory.clement@free-electrons.com>
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

Instead of using the same default queue for all the port. Move it in the
port struct. It will allow have a different default queue for each port.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 33 ++++++++++++++++++---------------
 1 file changed, 18 insertions(+), 15 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index e84c7f2634d3..1c7751917d58 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -354,6 +354,7 @@ struct mvneta_port {
 	struct mvneta_tx_queue *txqs;
 	struct net_device *dev;
 	struct notifier_block cpu_notifier;
+	int rxq_def;
 
 	/* Core clock */
 	struct clk *clk;
@@ -817,7 +818,7 @@ static void mvneta_port_up(struct mvneta_port *pp)
 	mvreg_write(pp, MVNETA_TXQ_CMD, q_map);
 
 	/* Enable all initialized RXQs. */
-	mvreg_write(pp, MVNETA_RXQ_CMD, BIT(rxq_def));
+	mvreg_write(pp, MVNETA_RXQ_CMD, BIT(pp->rxq_def));
 }
 
 /* Stop the Ethernet port activity */
@@ -1027,7 +1028,7 @@ static void mvneta_defaults_set(struct mvneta_port *pp)
 	mvreg_write(pp, MVNETA_ACC_MODE, val);
 
 	/* Update val of portCfg register accordingly with all RxQueue types */
-	val = MVNETA_PORT_CONFIG_DEFL_VALUE(rxq_def);
+	val = MVNETA_PORT_CONFIG_DEFL_VALUE(pp->rxq_def);
 	mvreg_write(pp, MVNETA_PORT_CONFIG, val);
 
 	val = 0;
@@ -2076,19 +2077,19 @@ static void mvneta_set_rx_mode(struct net_device *dev)
 	if (dev->flags & IFF_PROMISC) {
 		/* Accept all: Multicast + Unicast */
 		mvneta_rx_unicast_promisc_set(pp, 1);
-		mvneta_set_ucast_table(pp, rxq_def);
-		mvneta_set_special_mcast_table(pp, rxq_def);
-		mvneta_set_other_mcast_table(pp, rxq_def);
+		mvneta_set_ucast_table(pp, pp->rxq_def);
+		mvneta_set_special_mcast_table(pp, pp->rxq_def);
+		mvneta_set_other_mcast_table(pp, pp->rxq_def);
 	} else {
 		/* Accept single Unicast */
 		mvneta_rx_unicast_promisc_set(pp, 0);
 		mvneta_set_ucast_table(pp, -1);
-		mvneta_mac_addr_set(pp, dev->dev_addr, rxq_def);
+		mvneta_mac_addr_set(pp, dev->dev_addr, pp->rxq_def);
 
 		if (dev->flags & IFF_ALLMULTI) {
 			/* Accept all multicast */
-			mvneta_set_special_mcast_table(pp, rxq_def);
-			mvneta_set_other_mcast_table(pp, rxq_def);
+			mvneta_set_special_mcast_table(pp, pp->rxq_def);
+			mvneta_set_other_mcast_table(pp, pp->rxq_def);
 		} else {
 			/* Accept only initialized multicast */
 			mvneta_set_special_mcast_table(pp, -1);
@@ -2097,7 +2098,7 @@ static void mvneta_set_rx_mode(struct net_device *dev)
 			if (!netdev_mc_empty(dev)) {
 				netdev_for_each_mc_addr(ha, dev) {
 					mvneta_mcast_addr_set(pp, ha->addr,
-							      rxq_def);
+							      pp->rxq_def);
 				}
 			}
 		}
@@ -2180,7 +2181,7 @@ static int mvneta_poll(struct napi_struct *napi, int budget)
 	 * RX packets
 	 */
 	cause_rx_tx |= port->cause_rx_tx;
-	rx_done = mvneta_rx(pp, budget, &pp->rxqs[rxq_def]);
+	rx_done = mvneta_rx(pp, budget, &pp->rxqs[pp->rxq_def]);
 	budget -= rx_done;
 
 	if (budget > 0) {
@@ -2393,17 +2394,17 @@ static void mvneta_cleanup_txqs(struct mvneta_port *pp)
 /* Cleanup all Rx queues */
 static void mvneta_cleanup_rxqs(struct mvneta_port *pp)
 {
-	mvneta_rxq_deinit(pp, &pp->rxqs[rxq_def]);
+	mvneta_rxq_deinit(pp, &pp->rxqs[pp->rxq_def]);
 }
 
 
 /* Init all Rx queues */
 static int mvneta_setup_rxqs(struct mvneta_port *pp)
 {
-	int err = mvneta_rxq_init(pp, &pp->rxqs[rxq_def]);
+	int err = mvneta_rxq_init(pp, &pp->rxqs[pp->rxq_def]);
 	if (err) {
 		netdev_err(pp->dev, "%s: can't create rxq=%d\n",
-			   __func__, rxq_def);
+			   __func__, pp->rxq_def);
 		mvneta_cleanup_rxqs(pp);
 		return err;
 	}
@@ -2609,7 +2610,7 @@ static int mvneta_set_mac_addr(struct net_device *dev, void *addr)
 	mvneta_mac_addr_set(pp, dev->dev_addr, -1);
 
 	/* Set new addr in hw */
-	mvneta_mac_addr_set(pp, sockaddr->sa_data, rxq_def);
+	mvneta_mac_addr_set(pp, sockaddr->sa_data, pp->rxq_def);
 
 	eth_commit_mac_addr_change(dev, addr);
 	return 0;
@@ -2728,7 +2729,7 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 {
 	int online_cpu_idx, cpu, i = 0;
 
-	online_cpu_idx = rxq_def % num_online_cpus();
+	online_cpu_idx = pp->rxq_def % num_online_cpus();
 
 	for_each_online_cpu(cpu) {
 		if (i == online_cpu_idx)
@@ -3306,6 +3307,8 @@ static int mvneta_probe(struct platform_device *pdev)
 				 strcmp(managed, "in-band-status") == 0);
 	pp->cpu_notifier.notifier_call = mvneta_percpu_notifier;
 
+	pp->rxq_def = rxq_def;
+
 	pp->clk = devm_clk_get(&pdev->dev, NULL);
 	if (IS_ERR(pp->clk)) {
 		err = PTR_ERR(pp->clk);
-- 
2.5.0

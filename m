From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 net 6/6] net: mvneta: Fix race condition during stopping
Date: Mon,  1 Feb 2016 14:07:47 +0100
Message-ID: <1454332067-16378-7-git-send-email-gregory.clement@free-electrons.com>
References: <1454332067-16378-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Willy Tarreau <w@1wt.eu>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454332067-16378-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When stopping the port, the CPU notifier are still there whereas the
mvneta_stop_dev function calls mvneta_percpu_disable() on each CPUs.
It was possible to have a new CPU coming at this point which could be
racy.

This patch adds a flag preventing executing the code notifier for a new CPU
when the port is stopping.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 4d40d2fde7ca..2f53975aa6ec 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -374,6 +374,7 @@ struct mvneta_port {
 	 * ensuring that the configuration remains coherent.
 	 */
 	spinlock_t lock;
+	bool is_stopping;
 
 	/* Core clock */
 	struct clk *clk;
@@ -2916,6 +2917,11 @@ static int mvneta_percpu_notifier(struct notifier_block *nfb,
 	switch (action) {
 	case CPU_ONLINE:
 	case CPU_ONLINE_FROZEN:
+		/* Configuring the driver for a new CPU while the
+		 * driver is stopping is racy, so just avoid it.
+		 */
+		if (pp->is_stopping)
+			break;
 		netif_tx_stop_all_queues(pp->dev);
 
 		/* We have to synchronise on tha napi of each CPU
@@ -3054,9 +3060,17 @@ static int mvneta_stop(struct net_device *dev)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
 
+	/* Inform that we are stopping so we don't want to setup the
+	 * driver for new CPUs in the notifiers
+	 */
+	pp->is_stopping = true;
 	mvneta_stop_dev(pp);
 	mvneta_mdio_remove(pp);
 	unregister_cpu_notifier(&pp->cpu_notifier);
+	/* Now that the notifier are unregistered, we can clear the
+	 * flag
+	 */
+	pp->is_stopping = false;
 	on_each_cpu(mvneta_percpu_disable, pp, true);
 	free_percpu_irq(dev->irq, pp->ports);
 	mvneta_cleanup_rxqs(pp);
-- 
2.5.0

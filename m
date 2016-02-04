From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v3 net 6/7] net: mvneta: The mvneta_percpu_elect function should be atomic
Date: Thu,  4 Feb 2016 22:09:28 +0100
Message-ID: <1454620169-8156-7-git-send-email-gregory.clement@free-electrons.com>
References: <1454620169-8156-1-git-send-email-gregory.clement@free-electrons.com>
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
In-Reply-To: <1454620169-8156-1-git-send-email-gregory.clement@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Electing a CPU must be done in an atomic way: it should be done after or
before the removal/insertion of a CPU and this function is not reentrant.

During the loop of mvneta_percpu_elect we associates the queues to the
CPUs, if there is a topology change during this loop, then the mapping
between the CPUs and the queues could be wrong. During this loop the
interrupt mask is also updating for each CPUs, It should not be changed
in the same time by other part of the driver.

This patch adds spinlock to create the needed critical sections.

Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 2d0e8a605ca9..b12a745a0e4c 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -370,6 +370,10 @@ struct mvneta_port {
 	struct net_device *dev;
 	struct notifier_block cpu_notifier;
 	int rxq_def;
+	/* Protect the access to the percpu interrupt registers,
+	 * ensuring that the configuration remains coherent.
+	 */
+	spinlock_t lock;
 
 	/* Core clock */
 	struct clk *clk;
@@ -2855,6 +2859,12 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 {
 	int elected_cpu = 0, max_cpu, cpu, i = 0;
 
+	/* Electing a CPU must be done in an atomic way: it should be
+	 * done after or before the removal/insertion of a CPU and
+	 * this function is not reentrant.
+	 */
+	spin_lock(&pp->lock);
+
 	/* Use the cpu associated to the rxq when it is online, in all
 	 * the other cases, use the cpu 0 which can't be offline.
 	 */
@@ -2898,6 +2908,7 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 		i++;
 
 	}
+	spin_unlock(&pp->lock);
 };
 
 static int mvneta_percpu_notifier(struct notifier_block *nfb,
@@ -2952,8 +2963,13 @@ static int mvneta_percpu_notifier(struct notifier_block *nfb,
 	case CPU_DOWN_PREPARE:
 	case CPU_DOWN_PREPARE_FROZEN:
 		netif_tx_stop_all_queues(pp->dev);
+		/* Thanks to this lock we are sure that any pending
+		 * cpu election is done
+		 */
+		spin_lock(&pp->lock);
 		/* Mask all ethernet port interrupts */
 		on_each_cpu(mvneta_percpu_mask_interrupt, pp, true);
+		spin_unlock(&pp->lock);
 
 		napi_synchronize(&port->napi);
 		napi_disable(&port->napi);
-- 
2.5.0

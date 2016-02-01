From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 net 5/6] net: mvneta: The mvneta_percpu_elect function should be atomic
Date: Mon,  1 Feb 2016 14:07:46 +0100
Message-ID: <1454332067-16378-6-git-send-email-gregory.clement@free-electrons.com>
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
 drivers/net/ethernet/marvell/mvneta.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 1ed813d478e8..4d40d2fde7ca 100644
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
@@ -2855,6 +2859,11 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 {
 	int online_cpu_idx, max_cpu, cpu, i = 0;
 
+	/* Electing a CPU must done in an atomic way: it should be
+	 * done after or before the removal/insertion of a CPU and
+	 * this function is not reentrant.
+	 */
+	spin_lock(&pp->lock);
 	online_cpu_idx = pp->rxq_def % num_online_cpus();
 	max_cpu = num_present_cpus();
 
@@ -2893,6 +2902,7 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 		i++;
 
 	}
+	spin_unlock(&pp->lock);
 };
 
 static int mvneta_percpu_notifier(struct notifier_block *nfb,
@@ -2947,8 +2957,13 @@ static int mvneta_percpu_notifier(struct notifier_block *nfb,
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

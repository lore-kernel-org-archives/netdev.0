From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net 2/6] net: mvneta: Use on_each_cpu when possible
Date: Fri, 29 Jan 2016 17:26:03 +0100
Message-ID: <1454084767-24715-3-git-send-email-gregory.clement@free-electrons.com>
References: <1454084767-24715-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Nadav Haklai <nadavh@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1454084767-24715-1-git-send-email-gregory.clement@free-electrons.com>
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

Instead of using a for_each_* loop in which we just call the
smp_call_function_single macro, it is more simple to directly use the
on_each_cpu macro. Moreover, this macro ensures that the calls will be
done all at once.

Suggested-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 17 ++++++-----------
 1 file changed, 6 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 90ff5c7e19ea..3d6e3137f305 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2555,7 +2555,7 @@ static void mvneta_percpu_mask_interrupt(void *arg)
 
 static void mvneta_start_dev(struct mvneta_port *pp)
 {
-	unsigned int cpu;
+	int cpu;
 
 	mvneta_max_rx_size_set(pp, pp->pkt_size);
 	mvneta_txq_max_tx_size_set(pp, pp->pkt_size);
@@ -2571,9 +2571,8 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 	}
 
 	/* Unmask interrupts. It has to be done from each CPU */
-	for_each_online_cpu(cpu)
-		smp_call_function_single(cpu, mvneta_percpu_unmask_interrupt,
-					 pp, true);
+	on_each_cpu(mvneta_percpu_unmask_interrupt, pp, true);
+
 	mvreg_write(pp, MVNETA_INTR_MISC_MASK,
 		    MVNETA_CAUSE_PHY_STATUS_CHANGE |
 		    MVNETA_CAUSE_LINK_CHANGE |
@@ -2988,7 +2987,7 @@ static int mvneta_percpu_notifier(struct notifier_block *nfb,
 static int mvneta_open(struct net_device *dev)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
-	int ret, cpu;
+	int ret;
 
 	pp->pkt_size = MVNETA_RX_PKT_SIZE(pp->dev->mtu);
 	pp->frag_size = SKB_DATA_ALIGN(MVNETA_RX_BUF_SIZE(pp->pkt_size)) +
@@ -3021,9 +3020,7 @@ static int mvneta_open(struct net_device *dev)
 	/* Enable per-CPU interrupt on all the CPU to handle our RX
 	 * queue interrupts
 	 */
-	for_each_online_cpu(cpu)
-		smp_call_function_single(cpu, mvneta_percpu_enable,
-					 pp, true);
+	on_each_cpu(mvneta_percpu_enable, pp, true);
 
 
 	/* Register a CPU notifier to handle the case where our CPU
@@ -3310,9 +3307,7 @@ static int  mvneta_config_rss(struct mvneta_port *pp)
 
 	netif_tx_stop_all_queues(pp->dev);
 
-	for_each_online_cpu(cpu)
-		smp_call_function_single(cpu, mvneta_percpu_mask_interrupt,
-					 pp, true);
+	on_each_cpu(mvneta_percpu_mask_interrupt, pp, true);
 
 	/* We have to synchronise on the napi of each CPU */
 	for_each_online_cpu(cpu) {
-- 
2.5.0

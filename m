From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v3 net 2/7] net: mvneta: Fix the CPU choice in
 mvneta_percpu_elect
Date: Thu,  4 Feb 2016 22:09:24 +0100
Message-ID: <1454620169-8156-3-git-send-email-gregory.clement@free-electrons.com>
References: <1454620169-8156-1-git-send-email-gregory.clement@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Lior Amsalem <alior@marvell.com>, Andrew Lunn <andrew@lunn.ch>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, stable@vger.kernel.org,
 Nadav Haklai <nadavh@marvell.com>,
 Gregory CLEMENT <gregory.clement@free-electrons.com>,
 Marcin Wojtas <mw@semihalf.com>, Willy Tarreau <w@1wt.eu>,
 linux-arm-kernel@lists.infradead.org,
 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
To: "David S. Miller" <davem@davemloft.net>, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org,
 Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <1454620169-8156-1-git-send-email-gregory.clement@free-electrons.com>
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

When passing to the management of multiple RX queue, the
mvneta_percpu_elect function was broken. The use of the modulo can lead
to elect the wrong cpu. For example with rxq_def=2, if the CPU 2 goes
offline and then online, we ended with the third RX queue activated in
the same time on CPU 0 and CPU2, which lead to a kernel crash.

With this fix, we don't try to get "the closer" CPU if the default CPU is
gone, now we just use CPU 0 which always be there. Thanks to this, the
code becomes more readable, easier to maintain and more predicable.

Cc: stable@vger.kernel.org
Fixes: 2dcf75e2793c ("net: mvneta: Associate RX queues with each CPU")
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 90ff5c7e19ea..4c2d12423750 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2849,9 +2849,14 @@ static void mvneta_percpu_disable(void *arg)
 
 static void mvneta_percpu_elect(struct mvneta_port *pp)
 {
-	int online_cpu_idx, max_cpu, cpu, i = 0;
+	int elected_cpu = 0, max_cpu, cpu, i = 0;
+
+	/* Use the cpu associated to the rxq when it is online, in all
+	 * the other cases, use the cpu 0 which can't be offline.
+	 */
+	if (cpu_online(pp->rxq_def))
+		elected_cpu = pp->rxq_def;
 
-	online_cpu_idx = pp->rxq_def % num_online_cpus();
 	max_cpu = num_present_cpus();
 
 	for_each_online_cpu(cpu) {
@@ -2862,7 +2867,7 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 			if ((rxq % max_cpu) == cpu)
 				rxq_map |= MVNETA_CPU_RXQ_ACCESS(rxq);
 
-		if (i == online_cpu_idx)
+		if (cpu == elected_cpu)
 			/* Map the default receive queue queue to the
 			 * elected CPU
 			 */
@@ -2873,7 +2878,7 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 		 * the CPU bound to the default RX queue
 		 */
 		if (txq_number == 1)
-			txq_map = (i == online_cpu_idx) ?
+			txq_map = (cpu == elected_cpu) ?
 				MVNETA_CPU_TXQ_ACCESS(1) : 0;
 		else
 			txq_map = mvreg_read(pp, MVNETA_CPU_MAP(cpu)) &
-- 
2.5.0

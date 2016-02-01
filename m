From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH v2 net 1/6] net: mvneta: Fix for_each_present_cpu usage
Date: Mon,  1 Feb 2016 14:07:42 +0100
Message-ID: <1454332067-16378-2-git-send-email-gregory.clement@free-electrons.com>
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

This patch convert the for_each_present in on_each_cpu, instead of
applying on the present cpus it will be applied only on the online cpus.
This fix a bug reported on
http://thread.gmane.org/gmane.linux.ports.arm.kernel/468173.

Using the macro on_each_cpu (instead of a for_each_* loop) also ensures
that all the calls will be done all at once.

Fixes: f86428854480 ("net: mvneta: Statically assign queues to CPUs")
Reported-by: Stefan Roese <stefan.roese@gmail.com>
Suggested-by: Jisheng Zhang <jszhang@marvell.com>
Suggested-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 662c2ee268c7..90ff5c7e19ea 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2564,7 +2564,7 @@ static void mvneta_start_dev(struct mvneta_port *pp)
 	mvneta_port_enable(pp);
 
 	/* Enable polling on the port */
-	for_each_present_cpu(cpu) {
+	for_each_online_cpu(cpu) {
 		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
 
 		napi_enable(&port->napi);
@@ -2589,7 +2589,7 @@ static void mvneta_stop_dev(struct mvneta_port *pp)
 
 	phy_stop(pp->phy_dev);
 
-	for_each_present_cpu(cpu) {
+	for_each_online_cpu(cpu) {
 		struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
 
 		napi_disable(&port->napi);
@@ -3057,13 +3057,11 @@ err_cleanup_rxqs:
 static int mvneta_stop(struct net_device *dev)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
-	int cpu;
 
 	mvneta_stop_dev(pp);
 	mvneta_mdio_remove(pp);
 	unregister_cpu_notifier(&pp->cpu_notifier);
-	for_each_present_cpu(cpu)
-		smp_call_function_single(cpu, mvneta_percpu_disable, pp, true);
+	on_each_cpu(mvneta_percpu_disable, pp, true);
 	free_percpu_irq(dev->irq, pp->ports);
 	mvneta_cleanup_rxqs(pp);
 	mvneta_cleanup_txqs(pp);
-- 
2.5.0

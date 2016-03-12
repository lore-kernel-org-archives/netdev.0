From: Gregory CLEMENT <gregory.clement@free-electrons.com>
Subject: [PATCH net v2 1/4] net: mvneta: Fix spinlock usage
Date: Sat, 12 Mar 2016 18:44:17 +0100
Message-ID: <1457804660-8463-2-git-send-email-gregory.clement@free-electrons.com>
References: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>,
	linux-arm-kernel@lists.infradead.org,
	Lior Amsalem <alior@marvell.com>,
	Nadav Haklai <nadavh@marvell.com>,
	Marcin Wojtas <mw@semihalf.com>,
	Patrick Uiterwijk <patrick@puiterwijk.org>,
	Dimitri Epshtein <dima@marvell.com>,
	Ofer Heifetz <oferh@marvell.com>
To: "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:54413 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751883AbcCLRoh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Mar 2016 12:44:37 -0500
In-Reply-To: <1457804660-8463-1-git-send-email-gregory.clement@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In the previous patch, the spinlock was not initialized. While it didn't
cause any trouble yet it could be a problem to use it uninitialized.

The most annoying part was the critical section protected by the spinlock
in mvneta_stop(). Some of the functions could sleep as pointed when
activated CONFIG_DEBUG_ATOMIC_SLEEP. Actually, in mvneta_stop() we only
need to protect the is_stopped flagged, indeed the code of the notifier
for CPU online is protected by the same spinlock, so when we get the
lock, the notifer work is done.

Reported-by: Patrick Uiterwijk <patrick@puiterwijk.org>
Signed-off-by: Gregory CLEMENT <gregory.clement@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index b0ae69f84493..8dc7df2edff6 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3070,17 +3070,17 @@ static int mvneta_stop(struct net_device *dev)
 	struct mvneta_port *pp = netdev_priv(dev);
 
 	/* Inform that we are stopping so we don't want to setup the
-	 * driver for new CPUs in the notifiers
+	 * driver for new CPUs in the notifiers. The code of the
+	 * notifier for CPU online is protected by the same spinlock,
+	 * so when we get the lock, the notifer work is done.
 	 */
 	spin_lock(&pp->lock);
 	pp->is_stopped = true;
+	spin_unlock(&pp->lock);
+
 	mvneta_stop_dev(pp);
 	mvneta_mdio_remove(pp);
 	unregister_cpu_notifier(&pp->cpu_notifier);
-	/* Now that the notifier are unregistered, we can release le
-	 * lock
-	 */
-	spin_unlock(&pp->lock);
 	on_each_cpu(mvneta_percpu_disable, pp, true);
 	free_percpu_irq(dev->irq, pp->ports);
 	mvneta_cleanup_rxqs(pp);
@@ -3612,6 +3612,7 @@ static int mvneta_probe(struct platform_device *pdev)
 	dev->ethtool_ops = &mvneta_eth_tool_ops;
 
 	pp = netdev_priv(dev);
+	spin_lock_init(&pp->lock);
 	pp->phy_node = phy_node;
 	pp->phy_interface = phy_mode;
 
-- 
2.5.0

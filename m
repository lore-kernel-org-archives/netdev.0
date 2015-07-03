From: Maxime Ripard <maxime.ripard@free-electrons.com>
Subject: [PATCH 6/6] net: mvneta: Statically assign queues to CPUs
Date: Fri,  3 Jul 2015 16:25:51 +0200
Message-ID: <1435933551-28696-7-git-send-email-maxime.ripard@free-electrons.com>
References: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Maxime Ripard <maxime.ripard@free-electrons.com>
To: Thomas Gleixner <tglx@linutronix.de>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1435933551-28696-1-git-send-email-maxime.ripard@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the switch to per-CPU interrupts, we lost the ability to set which
CPU was going to receive our RX interrupt, which was now only the CPU on
which the mvneta_open function was run.

We can now assign our queues to their respective CPUs, and make sure only
this CPU is going to handle our traffic.

This also paves the road to be able to change that at runtime, and later on
to support RSS.

Signed-off-by: Maxime Ripard <maxime.ripard@free-electrons.com>
---
 drivers/net/ethernet/marvell/mvneta.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 0d21b8a779d9..658d713abc18 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -2630,6 +2630,13 @@ static void mvneta_mdio_remove(struct mvneta_port *pp)
 	pp->phy_dev = NULL;
 }
 
+static void mvneta_percpu_enable(void *arg)
+{
+	struct mvneta_port *pp = arg;
+
+	enable_percpu_irq(pp->dev->irq, IRQ_TYPE_NONE);
+}
+
 static int mvneta_open(struct net_device *dev)
 {
 	struct mvneta_port *pp = netdev_priv(dev);
@@ -2655,6 +2662,19 @@ static int mvneta_open(struct net_device *dev)
 		goto err_cleanup_txqs;
 	}
 
+	/*
+	 * Even though the documentation says that request_percpu_irq
+	 * doesn't enable the interrupts automatically, it actually
+	 * does so on the local CPU.
+	 *
+	 * Make sure it's disabled.
+	 */
+	disable_percpu_irq(pp->dev->irq);
+
+	/* Enable per-CPU interrupt on the one CPU we care about */
+	smp_call_function_single(rxq_def % num_online_cpus(),
+				 mvneta_percpu_enable, pp, true);
+
 	/* In default link is down */
 	netif_carrier_off(pp->dev);
 
-- 
2.4.5

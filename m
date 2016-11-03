From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 08/25] net/dev: Convert to hotplug state machine
Date: Thu,  3 Nov 2016 15:50:04 +0100
Message-ID: <20161103145021.28528-9-bigeasy@linutronix.de>
References: <20161103145021.28528-1-bigeasy@linutronix.de>
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Cc: rt@linutronix.de,
        Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Thomas Gleixner <tglx@linutronix.de>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161103145021.28528-1-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Install the callbacks via the state machine.

Cc: "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Signed-off-by: Thomas Gleixner <tglx@linutronix.de>
---
 include/linux/cpuhotplug.h |  1 +
 net/core/dev.c             | 16 ++++++----------
 2 files changed, 7 insertions(+), 10 deletions(-)

diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index 31c58f6ec3c6..394eb7ed53be 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -36,6 +36,7 @@ enum cpuhp_state {
 	CPUHP_PERCPU_CNT_DEAD,
 	CPUHP_RADIX_DEAD,
 	CPUHP_PAGE_ALLOC_DEAD,
+	CPUHP_NET_DEV_DEAD,
 	CPUHP_WORKQUEUE_PREP,
 	CPUHP_POWER_NUMA_PREPARE,
 	CPUHP_HRTIMERS_PREPARE,
diff --git a/net/core/dev.c b/net/core/dev.c
index 4bc19a164ba5..71693729bdd5 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7947,18 +7947,13 @@ int dev_change_net_namespace(struct net_device *dev=
, struct net *net, const char
 }
 EXPORT_SYMBOL_GPL(dev_change_net_namespace);
=20
-static int dev_cpu_callback(struct notifier_block *nfb,
-			    unsigned long action,
-			    void *ocpu)
+static int dev_cpu_dead(unsigned int oldcpu)
 {
 	struct sk_buff **list_skb;
 	struct sk_buff *skb;
-	unsigned int cpu, oldcpu =3D (unsigned long)ocpu;
+	unsigned int cpu;
 	struct softnet_data *sd, *oldsd;
=20
-	if (action !=3D CPU_DEAD && action !=3D CPU_DEAD_FROZEN)
-		return NOTIFY_OK;
-
 	local_irq_disable();
 	cpu =3D smp_processor_id();
 	sd =3D &per_cpu(softnet_data, cpu);
@@ -8008,10 +8003,9 @@ static int dev_cpu_callback(struct notifier_block *n=
fb,
 		input_queue_head_incr(oldsd);
 	}
=20
-	return NOTIFY_OK;
+	return 0;
 }
=20
-
 /**
  *	netdev_increment_features - increment feature set by one
  *	@all: current feature set
@@ -8345,7 +8339,9 @@ static int __init net_dev_init(void)
 	open_softirq(NET_TX_SOFTIRQ, net_tx_action);
 	open_softirq(NET_RX_SOFTIRQ, net_rx_action);
=20
-	hotcpu_notifier(dev_cpu_callback, 0);
+	rc =3D cpuhp_setup_state_nocalls(CPUHP_NET_DEV_DEAD, "net/dev:dead",
+				       NULL, dev_cpu_dead);
+	WARN_ON(rc < 0);
 	dst_subsys_init();
 	rc =3D 0;
 out:
--=20
2.10.2

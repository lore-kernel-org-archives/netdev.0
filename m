From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: [PATCH 08/16] net: mvneta: Convert to hotplug state machine
Date: Thu, 18 Aug 2016 14:57:23 +0200
Message-ID: <20160818125731.27256-9-bigeasy@linutronix.de>
References: <20160818125731.27256-1-bigeasy@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>, rt@linutronix.de,
	Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160818125731.27256-1-bigeasy@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Install the callbacks via the state machine and let the core invoke
the callbacks on the already online CPUs.

Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Cc: netdev@vger.kernel.org
Signed-off-by: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
---
 drivers/net/ethernet/marvell/mvneta.c | 244 +++++++++++++++++++++-------------
 include/linux/cpuhotplug.h            |   1 +
 2 files changed, 149 insertions(+), 96 deletions(-)

diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 8e4252dd9a9d..b20a2459c109 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -382,7 +382,8 @@ struct mvneta_port {
 	struct mvneta_rx_queue *rxqs;
 	struct mvneta_tx_queue *txqs;
 	struct net_device *dev;
-	struct notifier_block cpu_notifier;
+	struct hlist_node node_online;
+	struct hlist_node node_dead;
 	int rxq_def;
 	/* Protect the access to the percpu interrupt registers,
 	 * ensuring that the configuration remains coherent.
@@ -573,6 +574,7 @@ struct mvneta_rx_queue {
 	int next_desc_to_proc;
 };
 
+static enum cpuhp_state online_hpstate;
 /* The hardware supports eight (8) rx queues, but we are only allowing
  * the first one to be used. Therefore, let's just allocate one queue.
  */
@@ -3313,101 +3315,101 @@ static void mvneta_percpu_elect(struct mvneta_port *pp)
 	}
 };
 
-static int mvneta_percpu_notifier(struct notifier_block *nfb,
-				  unsigned long action, void *hcpu)
+static int mvneta_cpu_online(unsigned int cpu, struct hlist_node *node)
 {
-	struct mvneta_port *pp = container_of(nfb, struct mvneta_port,
-					      cpu_notifier);
-	int cpu = (unsigned long)hcpu, other_cpu;
+	int other_cpu;
+	struct mvneta_port *pp = hlist_entry_safe(node, struct mvneta_port,
+						  node_online);
 	struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
 
-	switch (action) {
-	case CPU_ONLINE:
-	case CPU_ONLINE_FROZEN:
-	case CPU_DOWN_FAILED:
-	case CPU_DOWN_FAILED_FROZEN:
-		spin_lock(&pp->lock);
-		/* Configuring the driver for a new CPU while the
-		 * driver is stopping is racy, so just avoid it.
-		 */
-		if (pp->is_stopped) {
-			spin_unlock(&pp->lock);
-			break;
+
+	spin_lock(&pp->lock);
+	/* Configuring the driver for a new CPU while the
+	 * driver is stopping is racy, so just avoid it.
+	 */
+	if (pp->is_stopped) {
+		spin_unlock(&pp->lock);
+		return 0;
+	}
+	netif_tx_stop_all_queues(pp->dev);
+
+	/* We have to synchronise on tha napi of each CPU
+	 * except the one just being waked up
+	 */
+	for_each_online_cpu(other_cpu) {
+		if (other_cpu != cpu) {
+			struct mvneta_pcpu_port *other_port =
+				per_cpu_ptr(pp->ports, other_cpu);
+
+			napi_synchronize(&other_port->napi);
 		}
-		netif_tx_stop_all_queues(pp->dev);
-
-		/* We have to synchronise on tha napi of each CPU
-		 * except the one just being waked up
-		 */
-		for_each_online_cpu(other_cpu) {
-			if (other_cpu != cpu) {
-				struct mvneta_pcpu_port *other_port =
-					per_cpu_ptr(pp->ports, other_cpu);
-
-				napi_synchronize(&other_port->napi);
-			}
-		}
-
-		/* Mask all ethernet port interrupts */
-		on_each_cpu(mvneta_percpu_mask_interrupt, pp, true);
-		napi_enable(&port->napi);
-
-
-		/* Enable per-CPU interrupts on the CPU that is
-		 * brought up.
-		 */
-		mvneta_percpu_enable(pp);
-
-		/* Enable per-CPU interrupt on the one CPU we care
-		 * about.
-		 */
-		mvneta_percpu_elect(pp);
-
-		/* Unmask all ethernet port interrupts */
-		on_each_cpu(mvneta_percpu_unmask_interrupt, pp, true);
-		mvreg_write(pp, MVNETA_INTR_MISC_MASK,
-			MVNETA_CAUSE_PHY_STATUS_CHANGE |
-			MVNETA_CAUSE_LINK_CHANGE |
-			MVNETA_CAUSE_PSC_SYNC_CHANGE);
-		netif_tx_start_all_queues(pp->dev);
-		spin_unlock(&pp->lock);
-		break;
-	case CPU_DOWN_PREPARE:
-	case CPU_DOWN_PREPARE_FROZEN:
-		netif_tx_stop_all_queues(pp->dev);
-		/* Thanks to this lock we are sure that any pending
-		 * cpu election is done
-		 */
-		spin_lock(&pp->lock);
-		/* Mask all ethernet port interrupts */
-		on_each_cpu(mvneta_percpu_mask_interrupt, pp, true);
-		spin_unlock(&pp->lock);
-
-		napi_synchronize(&port->napi);
-		napi_disable(&port->napi);
-		/* Disable per-CPU interrupts on the CPU that is
-		 * brought down.
-		 */
-		mvneta_percpu_disable(pp);
-
-		break;
-	case CPU_DEAD:
-	case CPU_DEAD_FROZEN:
-		/* Check if a new CPU must be elected now this on is down */
-		spin_lock(&pp->lock);
-		mvneta_percpu_elect(pp);
-		spin_unlock(&pp->lock);
-		/* Unmask all ethernet port interrupts */
-		on_each_cpu(mvneta_percpu_unmask_interrupt, pp, true);
-		mvreg_write(pp, MVNETA_INTR_MISC_MASK,
-			MVNETA_CAUSE_PHY_STATUS_CHANGE |
-			MVNETA_CAUSE_LINK_CHANGE |
-			MVNETA_CAUSE_PSC_SYNC_CHANGE);
-		netif_tx_start_all_queues(pp->dev);
-		break;
 	}
 
-	return NOTIFY_OK;
+	/* Mask all ethernet port interrupts */
+	on_each_cpu(mvneta_percpu_mask_interrupt, pp, true);
+	napi_enable(&port->napi);
+
+	/* Enable per-CPU interrupts on the CPU that is
+	 * brought up.
+	 */
+	mvneta_percpu_enable(pp);
+
+	/* Enable per-CPU interrupt on the one CPU we care
+	 * about.
+	 */
+	mvneta_percpu_elect(pp);
+
+	/* Unmask all ethernet port interrupts */
+	on_each_cpu(mvneta_percpu_unmask_interrupt, pp, true);
+	mvreg_write(pp, MVNETA_INTR_MISC_MASK,
+		    MVNETA_CAUSE_PHY_STATUS_CHANGE |
+		    MVNETA_CAUSE_LINK_CHANGE |
+		    MVNETA_CAUSE_PSC_SYNC_CHANGE);
+	netif_tx_start_all_queues(pp->dev);
+	spin_unlock(&pp->lock);
+	return 0;
+}
+
+static int mvneta_cpu_down_prepare(unsigned int cpu, struct hlist_node *node)
+{
+	struct mvneta_port *pp = hlist_entry_safe(node, struct mvneta_port,
+						  node_online);
+	struct mvneta_pcpu_port *port = per_cpu_ptr(pp->ports, cpu);
+
+	/* Thanks to this lock we are sure that any pending
+	 * cpu election is done
+	 */
+	spin_lock(&pp->lock);
+	/* Mask all ethernet port interrupts */
+	on_each_cpu(mvneta_percpu_mask_interrupt, pp, true);
+	spin_unlock(&pp->lock);
+
+	napi_synchronize(&port->napi);
+	napi_disable(&port->napi);
+	/* Disable per-CPU interrupts on the CPU that is
+	 * brought down.
+	 */
+	mvneta_percpu_disable(pp);
+	return 0;
+}
+
+static int mvneta_cpu_dead(unsigned int cpu, struct hlist_node *node)
+{
+	struct mvneta_port *pp = hlist_entry_safe(node, struct mvneta_port,
+						  node_dead);
+
+	/* Check if a new CPU must be elected now this on is down */
+	spin_lock(&pp->lock);
+	mvneta_percpu_elect(pp);
+	spin_unlock(&pp->lock);
+	/* Unmask all ethernet port interrupts */
+	on_each_cpu(mvneta_percpu_unmask_interrupt, pp, true);
+	mvreg_write(pp, MVNETA_INTR_MISC_MASK,
+		    MVNETA_CAUSE_PHY_STATUS_CHANGE |
+		    MVNETA_CAUSE_LINK_CHANGE |
+		    MVNETA_CAUSE_PSC_SYNC_CHANGE);
+	netif_tx_start_all_queues(pp->dev);
+	return 0;
 }
 
 static int mvneta_open(struct net_device *dev)
@@ -3444,7 +3446,15 @@ static int mvneta_open(struct net_device *dev)
 	/* Register a CPU notifier to handle the case where our CPU
 	 * might be taken offline.
 	 */
-	register_cpu_notifier(&pp->cpu_notifier);
+	ret = cpuhp_state_add_instance_nocalls(online_hpstate,
+					       &pp->node_online);
+	if (ret)
+		goto err_free_irq;
+
+	ret = cpuhp_state_add_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
+					       &pp->node_dead);
+	if (ret)
+		goto err_free_online_hp;
 
 	/* In default link is down */
 	netif_carrier_off(pp->dev);
@@ -3452,15 +3462,19 @@ static int mvneta_open(struct net_device *dev)
 	ret = mvneta_mdio_probe(pp);
 	if (ret < 0) {
 		netdev_err(dev, "cannot probe MDIO bus\n");
-		goto err_free_irq;
+		goto err_free_dead_hp;
 	}
 
 	mvneta_start_dev(pp);
 
 	return 0;
 
+err_free_dead_hp:
+	cpuhp_state_remove_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
+					    &pp->node_dead);
+err_free_online_hp:
+	cpuhp_state_remove_instance_nocalls(online_hpstate, &pp->node_online);
 err_free_irq:
-	unregister_cpu_notifier(&pp->cpu_notifier);
 	on_each_cpu(mvneta_percpu_disable, pp, true);
 	free_percpu_irq(pp->dev->irq, pp->ports);
 err_cleanup_txqs:
@@ -3486,7 +3500,10 @@ static int mvneta_stop(struct net_device *dev)
 
 	mvneta_stop_dev(pp);
 	mvneta_mdio_remove(pp);
-	unregister_cpu_notifier(&pp->cpu_notifier);
+
+	cpuhp_state_remove_instance_nocalls(online_hpstate, &pp->node_online);
+	cpuhp_state_remove_instance_nocalls(CPUHP_NET_MVNETA_DEAD,
+					    &pp->node_dead);
 	on_each_cpu(mvneta_percpu_disable, pp, true);
 	free_percpu_irq(dev->irq, pp->ports);
 	mvneta_cleanup_rxqs(pp);
@@ -4014,7 +4031,6 @@ static int mvneta_probe(struct platform_device *pdev)
 	err = of_property_read_string(dn, "managed", &managed);
 	pp->use_inband_status = (err == 0 &&
 				 strcmp(managed, "in-band-status") == 0);
-	pp->cpu_notifier.notifier_call = mvneta_percpu_notifier;
 
 	pp->rxq_def = rxq_def;
 
@@ -4217,7 +4233,43 @@ static struct platform_driver mvneta_driver = {
 	},
 };
 
-module_platform_driver(mvneta_driver);
+static int __init mvneta_driver_init(void)
+{
+	int ret;
+
+	ret = cpuhp_setup_state_multi(CPUHP_AP_ONLINE_DYN, "NET_MVNETA_ONLINE",
+				      mvneta_cpu_online,
+				      mvneta_cpu_down_prepare);
+	if (ret < 0)
+		goto out;
+	online_hpstate = ret;
+	ret = cpuhp_setup_state_multi(CPUHP_NET_MVNETA_DEAD,
+				      "NET_MVNETA_DEAD", NULL,
+				      mvneta_cpu_dead);
+	if (ret)
+		goto err_dead;
+
+	ret = platform_driver_register(&mvneta_driver);
+	if (ret)
+		goto err;
+	return 0;
+
+err:
+	cpuhp_remove_multi_state(CPUHP_NET_MVNETA_DEAD);
+err_dead:
+	cpuhp_remove_multi_state(online_hpstate);
+out:
+	return ret;
+}
+module_init(mvneta_driver_init);
+
+static void __exit mvneta_driver_exit(void)
+{
+	platform_driver_unregister(&mvneta_driver);
+	cpuhp_remove_multi_state(CPUHP_NET_MVNETA_DEAD);
+	cpuhp_remove_multi_state(online_hpstate);
+}
+module_exit(mvneta_driver_exit);
 
 MODULE_DESCRIPTION("Marvell NETA Ethernet Driver - www.marvell.com");
 MODULE_AUTHOR("Rami Rosen <rosenr@marvell.com>, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>");
diff --git a/include/linux/cpuhotplug.h b/include/linux/cpuhotplug.h
index a421407a317f..332b39c21d2e 100644
--- a/include/linux/cpuhotplug.h
+++ b/include/linux/cpuhotplug.h
@@ -18,6 +18,7 @@ enum cpuhp_state {
 	CPUHP_SLUB_DEAD,
 	CPUHP_MM_WRITEBACK_DEAD,
 	CPUHP_SOFTIRQ_DEAD,
+	CPUHP_NET_MVNETA_DEAD,
 	CPUHP_WORKQUEUE_PREP,
 	CPUHP_POWER_NUMA_PREPARE,
 	CPUHP_HRTIMERS_PREPARE,
-- 
2.9.3

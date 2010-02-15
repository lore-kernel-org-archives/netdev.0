From: David Daney <ddaney@caviumnetworks.com>
Subject: [PATCH 2/4] Staging: Octeon:  Run phy bus accesses on a workqueue.
Date: Mon, 15 Feb 2010 12:13:17 -0800
Message-ID: <1266264799-3510-2-git-send-email-ddaney@caviumnetworks.com>
References: <4B79AAA6.60005@caviumnetworks.com>
Cc: David Daney <ddaney@caviumnetworks.com>
To: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:19968 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756305Ab0BOUNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 15:13:33 -0500
In-Reply-To: <4B79AAA6.60005@caviumnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When directly accessing a phy, we must acquire the mdio bus lock.  To
do that we cannot be in interrupt context, so we need to move these
operations to a workqueue.

Signed-off-by: David Daney <ddaney@caviumnetworks.com>
---
 drivers/staging/octeon/ethernet-rgmii.c  |   55 +++++++++++----
 drivers/staging/octeon/ethernet.c        |  113 +++++++++++++++++-------------
 drivers/staging/octeon/octeon-ethernet.h |    4 +
 3 files changed, 109 insertions(+), 63 deletions(-)

diff --git a/drivers/staging/octeon/ethernet-rgmii.c b/drivers/staging/octeon/ethernet-rgmii.c
index f90d46e..a0d4d4b 100644
--- a/drivers/staging/octeon/ethernet-rgmii.c
+++ b/drivers/staging/octeon/ethernet-rgmii.c
@@ -26,6 +26,7 @@
 **********************************************************************/
 #include <linux/kernel.h>
 #include <linux/netdevice.h>
+#include <linux/phy.h>
 #include <net/dst.h>
 
 #include <asm/octeon/octeon.h>
@@ -47,14 +48,20 @@ static int number_rgmii_ports;
 static void cvm_oct_rgmii_poll(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
-	unsigned long flags;
+	unsigned long flags = 0;
 	cvmx_helper_link_info_t link_info;
+	int use_global_register_lock = (priv->phydev == NULL);
 
-	/*
-	 * Take the global register lock since we are going to touch
-	 * registers that affect more than one port.
-	 */
-	spin_lock_irqsave(&global_register_lock, flags);
+	BUG_ON(in_interrupt());
+	if (use_global_register_lock) {
+		/*
+		 * Take the global register lock since we are going to
+		 * touch registers that affect more than one port.
+		 */
+		spin_lock_irqsave(&global_register_lock, flags);
+	} else {
+		mutex_lock(&priv->phydev->bus->mdio_lock);
+	}
 
 	link_info = cvmx_helper_link_get(priv->port);
 	if (link_info.u64 == priv->link_info) {
@@ -114,7 +121,11 @@ static void cvm_oct_rgmii_poll(struct net_device *dev)
 				     dev->name);
 			}
 		}
-		spin_unlock_irqrestore(&global_register_lock, flags);
+
+		if (use_global_register_lock)
+			spin_unlock_irqrestore(&global_register_lock, flags);
+		else
+			mutex_unlock(&priv->phydev->bus->mdio_lock);
 		return;
 	}
 
@@ -150,7 +161,12 @@ static void cvm_oct_rgmii_poll(struct net_device *dev)
 		link_info = cvmx_helper_link_autoconf(priv->port);
 		priv->link_info = link_info.u64;
 	}
-	spin_unlock_irqrestore(&global_register_lock, flags);
+
+	if (use_global_register_lock)
+		spin_unlock_irqrestore(&global_register_lock, flags);
+	else {
+		mutex_unlock(&priv->phydev->bus->mdio_lock);
+	}
 
 	if (priv->phydev == NULL) {
 		/* Tell core. */
@@ -212,8 +228,11 @@ static irqreturn_t cvm_oct_rgmii_rml_interrupt(int cpl, void *dev_id)
 				struct net_device *dev =
 				    cvm_oct_device[cvmx_helper_get_ipd_port
 						   (interface, index)];
-				if (dev)
-					cvm_oct_rgmii_poll(dev);
+				struct octeon_ethernet *priv = netdev_priv(dev);
+
+				if (dev && !atomic_read(&cvm_oct_poll_queue_stopping))
+					queue_work(cvm_oct_poll_queue, &priv->port_work);
+
 				gmx_rx_int_reg.u64 = 0;
 				gmx_rx_int_reg.s.phy_dupx = 1;
 				gmx_rx_int_reg.s.phy_link = 1;
@@ -251,8 +270,11 @@ static irqreturn_t cvm_oct_rgmii_rml_interrupt(int cpl, void *dev_id)
 				struct net_device *dev =
 				    cvm_oct_device[cvmx_helper_get_ipd_port
 						   (interface, index)];
-				if (dev)
-					cvm_oct_rgmii_poll(dev);
+				struct octeon_ethernet *priv = netdev_priv(dev);
+
+				if (dev && !atomic_read(&cvm_oct_poll_queue_stopping))
+					queue_work(cvm_oct_poll_queue, &priv->port_work);
+
 				gmx_rx_int_reg.u64 = 0;
 				gmx_rx_int_reg.s.phy_dupx = 1;
 				gmx_rx_int_reg.s.phy_link = 1;
@@ -301,6 +323,12 @@ int cvm_oct_rgmii_stop(struct net_device *dev)
 	return 0;
 }
 
+static void cvm_oct_rgmii_immediate_poll(struct work_struct *work)
+{
+	struct octeon_ethernet *priv = container_of(work, struct octeon_ethernet, port_work);
+	cvm_oct_rgmii_poll(cvm_oct_device[priv->port]);
+}
+
 int cvm_oct_rgmii_init(struct net_device *dev)
 {
 	struct octeon_ethernet *priv = netdev_priv(dev);
@@ -308,7 +336,7 @@ int cvm_oct_rgmii_init(struct net_device *dev)
 
 	cvm_oct_common_init(dev);
 	dev->netdev_ops->ndo_stop(dev);
-
+	INIT_WORK(&priv->port_work, cvm_oct_rgmii_immediate_poll);
 	/*
 	 * Due to GMX errata in CN3XXX series chips, it is necessary
 	 * to take the link down immediately when the PHY changes
@@ -396,4 +424,5 @@ void cvm_oct_rgmii_uninit(struct net_device *dev)
 	number_rgmii_ports--;
 	if (number_rgmii_ports == 0)
 		free_irq(OCTEON_IRQ_RML, &number_rgmii_ports);
+	cancel_work_sync(&priv->port_work);
 }
diff --git a/drivers/staging/octeon/ethernet.c b/drivers/staging/octeon/ethernet.c
index 5afece0..1771c10 100644
--- a/drivers/staging/octeon/ethernet.c
+++ b/drivers/staging/octeon/ethernet.c
@@ -123,9 +123,16 @@ MODULE_PARM_DESC(rx_napi_weight, "The NAPI WEIGHT parameter.");
 static unsigned int cvm_oct_mac_addr_offset;
 
 /**
- * Periodic timer to check auto negotiation
+ * cvm_oct_poll_queue - Workqueue for polling operations.
  */
-static struct timer_list cvm_oct_poll_timer;
+struct workqueue_struct *cvm_oct_poll_queue;
+
+/**
+ * cvm_oct_poll_queue_stopping - flag to indicate polling should stop.
+ *
+ * Set to one right before cvm_oct_poll_queue is destroyed.
+ */
+atomic_t cvm_oct_poll_queue_stopping = ATOMIC_INIT(0);
 
 /**
  * Array of every ethernet device owned by this driver indexed by
@@ -133,47 +140,39 @@ static struct timer_list cvm_oct_poll_timer;
  */
 struct net_device *cvm_oct_device[TOTAL_NUMBER_OF_PORTS];
 
-/**
- * Periodic timer tick for slow management operations
- *
- * @arg:    Device to check
- */
-static void cvm_do_timer(unsigned long arg)
+static void cvm_oct_rx_refill_worker(struct work_struct *work);
+static DECLARE_DELAYED_WORK(cvm_oct_rx_refill_work, cvm_oct_rx_refill_worker);
+
+static void cvm_oct_rx_refill_worker(struct work_struct *work)
 {
-	static int port;
-	if (port < CVMX_PIP_NUM_INPUT_PORTS) {
-		if (cvm_oct_device[port]) {
-			struct octeon_ethernet *priv = netdev_priv(cvm_oct_device[port]);
-			if (priv->poll)
-				priv->poll(cvm_oct_device[port]);
-			cvm_oct_free_tx_skbs(priv);
-			cvm_oct_device[port]->netdev_ops->ndo_get_stats(cvm_oct_device[port]);
-		}
-		port++;
-		/*
-		 * Poll the next port in a 50th of a second.  This
-		 * spreads the polling of ports out a little bit.
-		 */
-		mod_timer(&cvm_oct_poll_timer, jiffies + HZ/50);
-	} else {
-		port = 0;
-		/*
-		 * FPA 0 may have been drained, try to refill it if we
-		 * need more than num_packet_buffers / 2, otherwise
-		 * normal receive processing will refill it.  If it
-		 * were drained, no packets could be received so
-		 * cvm_oct_napi_poll would never be invoked to do the
-		 * refill.
-		 */
-		cvm_oct_rx_refill_pool(num_packet_buffers / 2);
-		/*
-		 * All ports have been polled. Start the next iteration through
-		 * the ports in one second.
-		 */
-		mod_timer(&cvm_oct_poll_timer, jiffies + HZ);
-	}
+	/*
+	 * FPA 0 may have been drained, try to refill it if we need
+	 * more than num_packet_buffers / 2, otherwise normal receive
+	 * processing will refill it.  If it were drained, no packets
+	 * could be received so cvm_oct_napi_poll would never be
+	 * invoked to do the refill.
+	 */
+	cvm_oct_rx_refill_pool(num_packet_buffers / 2);
+
+	if (!atomic_read(&cvm_oct_poll_queue_stopping))
+		queue_delayed_work(cvm_oct_poll_queue,
+				   &cvm_oct_rx_refill_work, HZ);
 }
 
+static void cvm_oct_tx_clean_worker(struct work_struct *work)
+{
+	struct octeon_ethernet *priv = container_of(work,
+						    struct octeon_ethernet,
+						    tx_clean_work.work);
+
+	if (priv->poll)
+		priv->poll(cvm_oct_device[priv->port]);
+	cvm_oct_free_tx_skbs(priv);
+	cvm_oct_device[priv->port]->netdev_ops->ndo_get_stats(cvm_oct_device[priv->port]);
+	if (!atomic_read(&cvm_oct_poll_queue_stopping))
+		queue_delayed_work(cvm_oct_poll_queue, &priv->tx_clean_work, HZ);
+ }
+
 /**
  * Configure common hardware for all interfaces
  */
@@ -624,6 +623,12 @@ static int __init cvm_oct_init_module(void)
 	else
 		cvm_oct_mac_addr_offset = 0;
 
+	cvm_oct_poll_queue = create_singlethread_workqueue("octeon-ethernet");
+	if (cvm_oct_poll_queue == NULL) {
+		pr_err("octeon-ethernet: Cannot create workqueue");
+		return -ENOMEM;
+	}
+
 	cvm_oct_proc_initialize();
 	cvm_oct_configure_common_hw();
 
@@ -719,7 +724,9 @@ static int __init cvm_oct_init_module(void)
 
 			/* Initialize the device private structure. */
 			priv = netdev_priv(dev);
-			memset(priv, 0, sizeof(struct octeon_ethernet));
+
+			INIT_DELAYED_WORK(&priv->tx_clean_work,
+					  cvm_oct_tx_clean_worker);
 
 			priv->imode = imode;
 			priv->port = port;
@@ -785,17 +792,15 @@ static int __init cvm_oct_init_module(void)
 				fau -=
 				    cvmx_pko_get_num_queues(priv->port) *
 				    sizeof(uint32_t);
+				queue_delayed_work(cvm_oct_poll_queue,
+						   &priv->tx_clean_work, HZ);
 			}
 		}
 	}
 
 	cvm_oct_rx_initialize();
 
-	/* Enable the poll timer for checking RGMII status */
-	init_timer(&cvm_oct_poll_timer);
-	cvm_oct_poll_timer.data = 0;
-	cvm_oct_poll_timer.function = cvm_do_timer;
-	mod_timer(&cvm_oct_poll_timer, jiffies + HZ);
+	queue_delayed_work(cvm_oct_poll_queue, &cvm_oct_rx_refill_work, HZ);
 
 	return 0;
 }
@@ -817,20 +822,28 @@ static void __exit cvm_oct_cleanup_module(void)
 	/* Free the interrupt handler */
 	free_irq(OCTEON_IRQ_WORKQ0 + pow_receive_group, cvm_oct_device);
 
-	del_timer(&cvm_oct_poll_timer);
+	atomic_inc_return(&cvm_oct_poll_queue_stopping);
+	cancel_delayed_work_sync(&cvm_oct_rx_refill_work);
+
 	cvm_oct_rx_shutdown();
 	cvmx_pko_disable();
 
 	/* Free the ethernet devices */
 	for (port = 0; port < TOTAL_NUMBER_OF_PORTS; port++) {
 		if (cvm_oct_device[port]) {
-			cvm_oct_tx_shutdown(cvm_oct_device[port]);
-			unregister_netdev(cvm_oct_device[port]);
-			kfree(cvm_oct_device[port]);
+			struct net_device *dev = cvm_oct_device[port];
+			struct octeon_ethernet *priv = netdev_priv(dev);
+			cancel_delayed_work_sync(&priv->tx_clean_work);
+
+			cvm_oct_tx_shutdown(dev);
+			unregister_netdev(dev);
+			kfree(dev);
 			cvm_oct_device[port] = NULL;
 		}
 	}
 
+	destroy_workqueue(cvm_oct_poll_queue);
+
 	cvmx_pko_shutdown();
 	cvm_oct_proc_shutdown();
 
diff --git a/drivers/staging/octeon/octeon-ethernet.h b/drivers/staging/octeon/octeon-ethernet.h
index 40b6956..8d09210 100644
--- a/drivers/staging/octeon/octeon-ethernet.h
+++ b/drivers/staging/octeon/octeon-ethernet.h
@@ -61,6 +61,8 @@ struct octeon_ethernet {
 	void (*poll) (struct net_device *dev);
 	struct hrtimer		tx_restart_timer;
 	ktime_t			tx_restart_interval;
+	struct delayed_work	tx_clean_work;
+	struct work_struct	port_work;	/* may be unused. */
 };
 
 /**
@@ -97,6 +99,8 @@ extern int pow_send_group;
 extern int pow_receive_group;
 extern char pow_send_list[];
 extern struct net_device *cvm_oct_device[];
+extern struct workqueue_struct *cvm_oct_poll_queue;
+extern atomic_t cvm_oct_poll_queue_stopping;
 
 extern int max_rx_cpus;
 extern int rx_napi_weight;
-- 
1.6.6


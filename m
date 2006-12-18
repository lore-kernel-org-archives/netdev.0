From: "Amit S. Kale" <amitkale@netxen.com>
Subject: [PATCH 6/8] NetXen: work queue fixes.
Date: Mon, 18 Dec 2006 05:53:36 -0800
Message-ID: <200612181353.kBIDraEQ012215@dut39.unminc.com>
Cc: amitkale@netxen.com, brazilnut@us.ibm.com, jeff@garzik.org,
	netxenproj@linsyssoft.com, rob@netxen.com, sanjeev@netxen.com,
	wendyx@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 66-126-254-34.unm.net ([66.126.254.34]:21896 "EHLO
	nxmail.netxen.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754060AbWLROW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Dec 2006 09:22:59 -0500
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Amit S. Kale <amitkale@netxen.com> 
 
 netxen_nic.h      |    3 +--
 netxen_nic_init.c |    2 +-
 netxen_nic_main.c |   15 +++++++--------
 3 files changed, 9 insertions(+), 11 deletions(-)


diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 421a074..86dcd52 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -852,8 +852,6 @@ struct netxen_adapter {
 	spinlock_t tx_lock;
 	spinlock_t lock;
 	struct work_struct watchdog_task;
-	struct work_struct tx_timeout_task;
-	struct net_device *netdev;
 	struct timer_list watchdog_timer;
 
 	u32 curr_window;
@@ -949,6 +947,7 @@ struct netxen_port {
 	struct pci_dev *pdev;
 	struct net_device_stats net_stats;
 	struct netxen_port_stats stats;
+	struct work_struct tx_timeout_task;
 };
 
 #define PCI_OFFSET_FIRST_RANGE(adapter, off)    \
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 869725f..c147943 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1023,7 +1023,7 @@ int netxen_process_cmd_ring(unsigned lon
 			     && netif_carrier_ok(port->netdev))
 		    && ((jiffies - port->netdev->trans_start) >
 			port->netdev->watchdog_timeo)) {
-			SCHEDULE_WORK(&port->adapter->tx_timeout_task);
+			SCHEDULE_WORK(&port->tx_timeout_task);
 		}
 
 		last_consumer = get_next_index(last_consumer,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 926ead7..bc08d21 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -424,8 +424,7 @@ netxen_nic_probe(struct pci_dev *pdev, c
 							     netdev->dev_addr);
 			}
 		}
-		adapter->netdev = netdev;
-		INIT_WORK(&adapter->tx_timeout_task, netxen_tx_timeout_task);
+		INIT_WORK(&port->tx_timeout_task, netxen_tx_timeout_task);
 		netif_carrier_off(netdev);
 		netif_stop_queue(netdev);
 
@@ -966,23 +965,23 @@ static void netxen_tx_timeout(struct net
 {
 	struct netxen_port *port = (struct netxen_port *)netdev_priv(netdev);
 
-	SCHEDULE_WORK(&port->adapter->tx_timeout_task);
+	SCHEDULE_WORK(&port->tx_timeout_task);
 }
 
 static void netxen_tx_timeout_task(struct work_struct *work)
 {
-	struct netxen_adapter *adapter =
-		container_of(work, struct netxen_adapter, tx_timeout_task);
-	struct net_device *netdev = adapter->netdev;
+	struct netxen_port *port =
+		container_of(work, struct netxen_port, tx_timeout_task);
+	struct net_device *netdev = port->netdev;
 	unsigned long flags;
 
 	printk(KERN_ERR "%s %s: transmit timeout, resetting.\n",
 	       netxen_nic_driver_name, netdev->name);
 
-	spin_lock_irqsave(&adapter->lock, flags);
+	spin_lock_irqsave(&port->adapter->lock, flags);
 	netxen_nic_close(netdev);
 	netxen_nic_open(netdev);
-	spin_unlock_irqrestore(&adapter->lock, flags);
+	spin_unlock_irqrestore(&port->adapter->lock, flags);
 	netdev->trans_start = jiffies;
 	netif_wake_queue(netdev);
 }

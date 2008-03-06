From: Daniel Walker <dwalker@mvista.com>
Subject: [PATCH 5/5] net: ehea: port_lock semaphore to mutex
Date: Thu, 06 Mar 2008 00:00:05 -0800
Message-ID: <20080307031633.763792992@mvista.com>
References: <20080307031621.590778480@mvista.com>
Cc: Christoph Raisch <raisch@de.ibm.com>,
	Jan-Bernd Themann <themann@de.ibm.com>,
	Thomas Klein <tklein@de.ibm.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway-1237.mvista.com ([63.81.120.158]:63438 "EHLO
	dwalker1.mvista.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757957AbYCGD0N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Mar 2008 22:26:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-- 
Content-Disposition: inline; filename=net-ehea-port_lock-semaphore-to-mutex.patch

Convert the port_lock to a mutex. There is also some additional
cleanup. The line length inside the ehea_rereg_mrs was getting
long so I made some adjustments to shorten them.

Signed-off-by: Daniel Walker <dwalker@mvista.com>

---
 drivers/net/ehea/ehea.h      |    2 +-
 drivers/net/ehea/ehea_main.c |   43 ++++++++++++++++++++++---------------------
 2 files changed, 23 insertions(+), 22 deletions(-)

Index: linux-2.6.24/drivers/net/ehea/ehea.h
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea.h
+++ linux-2.6.24/drivers/net/ehea/ehea.h
@@ -452,7 +452,7 @@ struct ehea_port {
 	struct vlan_group *vgrp;
 	struct ehea_eq *qp_eq;
 	struct work_struct reset_task;
-	struct semaphore port_lock;
+	struct mutex port_lock;
 	char int_aff_name[EHEA_IRQ_NAME_SIZE];
 	int allmulti;			 /* Indicates IFF_ALLMULTI state */
 	int promisc;		 	 /* Indicates IFF_PROMISC state */
Index: linux-2.6.24/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.24.orig/drivers/net/ehea/ehea_main.c
+++ linux-2.6.24/drivers/net/ehea/ehea_main.c
@@ -2543,7 +2543,7 @@ static int ehea_open(struct net_device *
 	int ret;
 	struct ehea_port *port = netdev_priv(dev);
 
-	down(&port->port_lock);
+	mutex_lock(&port->port_lock);
 
 	if (netif_msg_ifup(port))
 		ehea_info("enabling port %s", dev->name);
@@ -2554,7 +2554,7 @@ static int ehea_open(struct net_device *
 		netif_start_queue(dev);
 	}
 
-	up(&port->port_lock);
+	mutex_unlock(&port->port_lock);
 
 	return ret;
 }
@@ -2600,11 +2600,11 @@ static int ehea_stop(struct net_device *
 		ehea_info("disabling port %s", dev->name);
 
 	flush_scheduled_work();
-	down(&port->port_lock);
+	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 	port_napi_disable(port);
 	ret = ehea_down(dev);
-	up(&port->port_lock);
+	mutex_unlock(&port->port_lock);
 	return ret;
 }
 
@@ -2802,7 +2802,7 @@ static void ehea_reset_port(struct work_
 	struct net_device *dev = port->netdev;
 
 	port->resets++;
-	down(&port->port_lock);
+	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 
 	port_napi_disable(port);
@@ -2822,7 +2822,7 @@ static void ehea_reset_port(struct work_
 
 	netif_wake_queue(dev);
 out:
-	up(&port->port_lock);
+	mutex_unlock(&port->port_lock);
 	return;
 }
 
@@ -2840,20 +2840,21 @@ static void ehea_rereg_mrs(struct work_s
 			for (i = 0; i < EHEA_MAX_PORTS; i++) {
 				struct ehea_port *port = adapter->port[i];
 
-				if (port) {
-					struct net_device *dev = port->netdev;
+				if (!port)
+					continue;
 
-					if (dev->flags & IFF_UP) {
-						down(&port->port_lock);
-						netif_stop_queue(dev);
-						ret = ehea_stop_qps(dev);
-						if (ret) {
-							up(&port->port_lock);
-							goto out;
-						}
-						port_napi_disable(port);
-						up(&port->port_lock);
+				struct net_device *dev = port->netdev;
+
+				if (dev->flags & IFF_UP) {
+					mutex_lock(&port->port_lock);
+					netif_stop_queue(dev);
+					ret = ehea_stop_qps(dev);
+					if (ret) {
+						mutex_unlock(&port->port_lock);
+						goto out;
 					}
+					port_napi_disable(port);
+					mutex_unlock(&port->port_lock);
 				}
 			}
 
@@ -2893,12 +2894,12 @@ static void ehea_rereg_mrs(struct work_s
 					struct net_device *dev = port->netdev;
 
 					if (dev->flags & IFF_UP) {
-						down(&port->port_lock);
+						mutex_lock(&port->port_lock);
 						port_napi_enable(port);
 						ret = ehea_restart_qps(dev);
 						if (!ret)
 							netif_wake_queue(dev);
-						up(&port->port_lock);
+						mutex_unlock(&port->port_lock);
 					}
 				}
 			}
@@ -3064,7 +3065,7 @@ struct ehea_port *ehea_setup_single_port
 
 	port = netdev_priv(dev);
 
-	sema_init(&port->port_lock, 1);
+	mutex_init(&port->port_lock);
 	port->state = EHEA_PORT_DOWN;
 	port->sig_comp_iv = sq_entries / 10;
 

-- 

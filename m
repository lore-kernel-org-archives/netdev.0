From: akpm@linux-foundation.org
Subject: [patch 18/21] netdev: ehea: port_lock semaphore to mutex
Date: Fri, 28 Mar 2008 14:41:28 -0700
Message-ID: <200803282141.m2SLfTtm011852@imap1.linux-foundation.org>
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	dwalker@mvista.com, raisch@de.ibm.com, themann@de.ibm.com,
	tklein@de.ibm.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:57950 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756472AbYC1VmK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2008 17:42:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Walker <dwalker@mvista.com>

Convert the port_lock to a mutex.  There is also some additional cleanup.  The
line length inside the ehea_rereg_mrs was getting long so I made some
adjustments to shorten them.

[akpm@linux-foundation.org: dec99ification]
Signed-off-by: Daniel Walker <dwalker@mvista.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Christoph Raisch <raisch@de.ibm.com>
Cc: Jan-Bernd Themann <themann@de.ibm.com>
Cc: Thomas Klein <tklein@de.ibm.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 drivers/net/ehea/ehea.h      |    2 -
 drivers/net/ehea/ehea_main.c |   44 +++++++++++++++++----------------
 2 files changed, 24 insertions(+), 22 deletions(-)

diff -puN drivers/net/ehea/ehea.h~net-ehea-port_lock-semaphore-to-mutex drivers/net/ehea/ehea.h
--- a/drivers/net/ehea/ehea.h~net-ehea-port_lock-semaphore-to-mutex
+++ a/drivers/net/ehea/ehea.h
@@ -452,7 +452,7 @@ struct ehea_port {
 	struct vlan_group *vgrp;
 	struct ehea_eq *qp_eq;
 	struct work_struct reset_task;
-	struct semaphore port_lock;
+	struct mutex port_lock;
 	char int_aff_name[EHEA_IRQ_NAME_SIZE];
 	int allmulti;			 /* Indicates IFF_ALLMULTI state */
 	int promisc;		 	 /* Indicates IFF_PROMISC state */
diff -puN drivers/net/ehea/ehea_main.c~net-ehea-port_lock-semaphore-to-mutex drivers/net/ehea/ehea_main.c
--- a/drivers/net/ehea/ehea_main.c~net-ehea-port_lock-semaphore-to-mutex
+++ a/drivers/net/ehea/ehea_main.c
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
 
@@ -2839,21 +2839,23 @@ static void ehea_rereg_mrs(struct work_s
 			/* Shutdown all ports */
 			for (i = 0; i < EHEA_MAX_PORTS; i++) {
 				struct ehea_port *port = adapter->port[i];
+				struct net_device *dev;
 
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
+				dev = port->netdev;
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
 
@@ -2893,12 +2895,12 @@ static void ehea_rereg_mrs(struct work_s
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
@@ -3064,7 +3066,7 @@ struct ehea_port *ehea_setup_single_port
 
 	port = netdev_priv(dev);
 
-	sema_init(&port->port_lock, 1);
+	mutex_init(&port->port_lock);
 	port->state = EHEA_PORT_DOWN;
 	port->sig_comp_iv = sq_entries / 10;
 
_

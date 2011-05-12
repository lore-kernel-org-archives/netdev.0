From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 01/15] ehea: Remove NETIF_F_LLTX
Date: Thu, 12 May 2011 10:52:14 +1000
Message-ID: <20110512005622.578745502@samba.org>
References: <20110512005213.897432612@samba.org>
Cc: netdev@vger.kernel.org
To: leitao@linux.vnet.ibm.com, michael@ellerman.id.au,
	jesse@kernel.org, bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:46791 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755408Ab1ELB2A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 May 2011 21:28:00 -0400
Content-Disposition: inline; filename=ehea_1.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove the deprecated NETIF_F_LLTX feature. Since the network stack
now provides the locking we can remove the driver specific
pr->xmit_lock.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-net/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea_main.c	2011-05-11 14:39:08.443817605 +1000
+++ linux-net/drivers/net/ehea/ehea_main.c	2011-05-11 14:39:10.113846069 +1000
@@ -1536,7 +1536,6 @@ static int ehea_init_port_res(struct ehe
 	pr->rx_packets = rx_packets;
 
 	pr->port = port;
-	spin_lock_init(&pr->xmit_lock);
 	spin_lock_init(&pr->netif_queue);
 
 	pr->eq = ehea_create_eq(adapter, eq_type, EHEA_MAX_ENTRIES_EQ, 0);
@@ -2261,14 +2260,9 @@ static int ehea_start_xmit(struct sk_buf
 
 	pr = &port->port_res[ehea_hash_skb(skb, port->num_tx_qps)];
 
-	if (!spin_trylock(&pr->xmit_lock))
+	if (pr->queue_stopped)
 		return NETDEV_TX_BUSY;
 
-	if (pr->queue_stopped) {
-		spin_unlock(&pr->xmit_lock);
-		return NETDEV_TX_BUSY;
-	}
-
 	swqe = ehea_get_swqe(pr->qp, &swqe_index);
 	memset(swqe, 0, SWQE_HEADER_SIZE);
 	atomic_dec(&pr->swqe_avail);
@@ -2332,8 +2326,6 @@ static int ehea_start_xmit(struct sk_buf
 		}
 		spin_unlock_irqrestore(&pr->netif_queue, flags);
 	}
-	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
-	spin_unlock(&pr->xmit_lock);
 
 	return NETDEV_TX_OK;
 }
@@ -3267,7 +3259,7 @@ struct ehea_port *ehea_setup_single_port
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
-		      | NETIF_F_LLTX | NETIF_F_RXCSUM;
+		      | NETIF_F_RXCSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	if (use_lro)
Index: linux-net/drivers/net/ehea/ehea.h
===================================================================
--- linux-net.orig/drivers/net/ehea/ehea.h	2011-05-11 14:39:08.433817435 +1000
+++ linux-net/drivers/net/ehea/ehea.h	2011-05-11 14:39:10.113846069 +1000
@@ -363,7 +363,6 @@ struct ehea_port_res {
 	struct port_stats p_stats;
 	struct ehea_mr send_mr;       	/* send memory region */
 	struct ehea_mr recv_mr;       	/* receive memory region */
-	spinlock_t xmit_lock;
 	struct ehea_port *port;
 	char int_recv_name[EHEA_IRQ_NAME_SIZE];
 	char int_send_name[EHEA_IRQ_NAME_SIZE];



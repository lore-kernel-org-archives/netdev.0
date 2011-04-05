From: Anton Blanchard <anton@samba.org>
Subject: [PATCH 1/14] ehea: Remove NETIF_F_LLTX
Date: Tue, 5 Apr 2011 21:28:25 +1000
Message-ID: <20110405212825.6eb85677@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, michael@ellerman.id.au
To: leitao@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:42141 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab1DEL22 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:28:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Remove the deprecated NETIF_F_LLTX feature. Since the network stack
now provides the locking we can remove the driver specific
pr->xmit_lock.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

Index: linux-2.6/drivers/net/ehea/ehea_main.c
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea_main.c	2011-03-14 09:44:36.568408321 +1100
+++ linux-2.6/drivers/net/ehea/ehea_main.c	2011-03-14 09:44:38.538481778 +1100
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
@@ -3264,8 +3256,7 @@ struct ehea_port *ehea_setup_single_port
 
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
-		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
-		      | NETIF_F_LLTX;
+		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	if (use_lro)
Index: linux-2.6/drivers/net/ehea/ehea.h
===================================================================
--- linux-2.6.orig/drivers/net/ehea/ehea.h	2011-03-14 09:44:26.428030236 +1100
+++ linux-2.6/drivers/net/ehea/ehea.h	2011-03-14 09:44:38.538481778 +1100
@@ -363,7 +363,6 @@ struct ehea_port_res {
 	struct port_stats p_stats;
 	struct ehea_mr send_mr;       	/* send memory region */
 	struct ehea_mr recv_mr;       	/* receive memory region */
-	spinlock_t xmit_lock;
 	struct ehea_port *port;
 	char int_recv_name[EHEA_IRQ_NAME_SIZE];
 	char int_send_name[EHEA_IRQ_NAME_SIZE];

From: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
Subject: [PATCH 01/15] ehea: Remove NETIF_F_LLTX
Date: Fri, 14 Oct 2011 12:30:58 -0300
Message-ID: <1318606272-27647-2-git-send-email-cascardo@linux.vnet.ibm.com>
References: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Cc: Anton Blanchard <anton@samba.org>,
	Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp01.br.ibm.com ([32.104.18.85]:51400 "EHLO
	e24smtp01.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933146Ab1JNPbi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2011 11:31:38 -0400
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp01.br.ibm.com (8.14.4/8.13.1) with ESMTP id p9EGqS5w010316
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:52:28 -0400
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p9EFZBt41892486
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:35:12 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p9EFVQYo008368
	for <netdev@vger.kernel.org>; Fri, 14 Oct 2011 12:31:26 -0300
In-Reply-To: <1318606272-27647-1-git-send-email-cascardo@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Anton Blanchard <anton@samba.org>

Remove the deprecated NETIF_F_LLTX feature. Since the network stack
now provides the locking we can remove the driver specific
pr->xmit_lock.

Signed-off-by: Anton Blanchard <anton@samba.org>
Signed-off-by: Thadeu Lima de Souza Cascardo <cascardo@linux.vnet.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea.h      |    1 -
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   12 ++----------
 2 files changed, 2 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index 0b8e6a9..5b5c1b5 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
@@ -363,7 +363,6 @@ struct ehea_port_res {
 	struct port_stats p_stats;
 	struct ehea_mr send_mr;       	/* send memory region */
 	struct ehea_mr recv_mr;       	/* receive memory region */
-	spinlock_t xmit_lock;
 	struct ehea_port *port;
 	char int_recv_name[EHEA_IRQ_NAME_SIZE];
 	char int_send_name[EHEA_IRQ_NAME_SIZE];
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index dfefe80..ce9a670 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -1534,7 +1534,6 @@ static int ehea_init_port_res(struct ehea_port *port, struct ehea_port_res *pr,
 	pr->rx_packets = rx_packets;
 
 	pr->port = port;
-	spin_lock_init(&pr->xmit_lock);
 	spin_lock_init(&pr->netif_queue);
 
 	pr->eq = ehea_create_eq(adapter, eq_type, EHEA_MAX_ENTRIES_EQ, 0);
@@ -2254,14 +2253,9 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
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
@@ -2325,8 +2319,6 @@ static int ehea_start_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 		spin_unlock_irqrestore(&pr->netif_queue, flags);
 	}
-	dev->trans_start = jiffies; /* NETIF_F_LLTX driver :( */
-	spin_unlock(&pr->xmit_lock);
 
 	return NETDEV_TX_OK;
 }
@@ -3233,7 +3225,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 	dev->features = NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_TSO
 		      | NETIF_F_HIGHDMA | NETIF_F_IP_CSUM | NETIF_F_HW_VLAN_TX
 		      | NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER
-		      | NETIF_F_LLTX | NETIF_F_RXCSUM;
+		      | NETIF_F_RXCSUM;
 	dev->watchdog_timeo = EHEA_WATCH_DOG_TIMEOUT;
 
 	if (use_lro)
-- 
1.7.4.4

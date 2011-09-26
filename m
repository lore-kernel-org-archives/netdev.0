From: brenohl@br.ibm.com
Subject: [PATCH] ehea: Remove sleep at .ndo_get_stats
Date: Mon, 26 Sep 2011 16:21:58 -0300
Message-ID: <1317064918-1481-1-git-send-email-brenohl@br.ibm.com>
References: <1317060132.2796.4.camel@edumazet-laptop>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Breno Leitao <brenohl@br.ibm.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:51780 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752696Ab1IZTWH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 15:22:07 -0400
Received: from mailhub3.br.ibm.com (mailhub3.br.ibm.com [9.18.232.110])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p8QKi2aH018162
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 17:44:02 -0300
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by mailhub3.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8QJPLk63354858
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 16:25:23 -0300
Received: from d24av05.br.ibm.com (loopback [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8QJLxLo016904
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 16:22:00 -0300
In-Reply-To: <1317060132.2796.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ehea ndo_get_stats can sleep in two places, in a hcall
and in a GFP_KERNEL alloc, which is not correct.
This patch creates a delayed workqueue that grabs the information each 1
sec from the hardware, and place it into the device structure, so that,
.ndo_get_stats quickly returns the device structure statistics block.

Signed-off-by: Breno Leitao <brenohl@br.ibm.com>
---
 drivers/net/ethernet/ibm/ehea/ehea.h      |    1 +
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   53 ++++++++++++++++------------
 2 files changed, 31 insertions(+), 23 deletions(-)

diff --git a/drivers/net/ethernet/ibm/ehea/ehea.h b/drivers/net/ethernet/ibm/ehea/ehea.h
index 7dd5e6a..0b8e6a9 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea.h
+++ b/drivers/net/ethernet/ibm/ehea/ehea.h
@@ -459,6 +459,7 @@ struct ehea_port {
 	struct ehea_mc_list *mc_list;	 /* Multicast MAC addresses */
 	struct ehea_eq *qp_eq;
 	struct work_struct reset_task;
+	struct delayed_work stats_work;
 	struct mutex port_lock;
 	char int_aff_name[EHEA_IRQ_NAME_SIZE];
 	int allmulti;			 /* Indicates IFF_ALLMULTI state */
diff --git a/drivers/net/ethernet/ibm/ehea/ehea_main.c b/drivers/net/ethernet/ibm/ehea/ehea_main.c
index 583bcd3..976988d 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -331,16 +331,34 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
 	struct net_device_stats *stats = &port->stats;
-	struct hcp_ehea_port_cb2 *cb2;
-	u64 hret, rx_packets, tx_packets, rx_bytes = 0, tx_bytes = 0;
 	int i;
 
-	memset(stats, 0, sizeof(*stats));
+	for (i = 0; i < port->num_def_qps; i++) {
+		stats->rx_packets += port->port_res[i].rx_packets;
+		stats->rx_bytes   += port->port_res[i].rx_bytes;
+	}
+
+	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
+		stats->tx_packets += port->port_res[i].tx_packets;
+		stats->tx_bytes   += port->port_res[i].tx_bytes;
+	}
+
+	return &port->stats;
+}
+
+static void ehea_update_stats(struct work_struct *work)
+{
+	struct ehea_port *port =
+		container_of(work, struct ehea_port, stats_work.work);
+	struct net_device *dev = port->netdev;
+	struct net_device_stats *stats = &port->stats;
+	struct hcp_ehea_port_cb2 *cb2;
+	u64 hret;
 
 	cb2 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb2) {
-		netdev_err(dev, "no mem for cb2\n");
-		goto out;
+		netdev_err(dev, "No mem for cb2. Some interface statistics were not updated\n");
+		goto resched;
 	}
 
 	hret = ehea_h_query_ehea_port(port->adapter->handle,
@@ -354,29 +372,13 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	if (netif_msg_hw(port))
 		ehea_dump(cb2, sizeof(*cb2), "net_device_stats");
 
-	rx_packets = 0;
-	for (i = 0; i < port->num_def_qps; i++) {
-		rx_packets += port->port_res[i].rx_packets;
-		rx_bytes   += port->port_res[i].rx_bytes;
-	}
-
-	tx_packets = 0;
-	for (i = 0; i < port->num_def_qps + port->num_add_tx_qps; i++) {
-		tx_packets += port->port_res[i].tx_packets;
-		tx_bytes   += port->port_res[i].tx_bytes;
-	}
-
-	stats->tx_packets = tx_packets;
 	stats->multicast = cb2->rxmcp;
 	stats->rx_errors = cb2->rxuerr;
-	stats->rx_bytes = rx_bytes;
-	stats->tx_bytes = tx_bytes;
-	stats->rx_packets = rx_packets;
 
 out_herr:
 	free_page((unsigned long)cb2);
-out:
-	return stats;
+resched:
+	schedule_delayed_work(&port->stats_work, msecs_to_jiffies(1000));
 }
 
 static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
@@ -2651,6 +2653,7 @@ static int ehea_open(struct net_device *dev)
 	}
 
 	mutex_unlock(&port->port_lock);
+	schedule_delayed_work(&port->stats_work, msecs_to_jiffies(1000));
 
 	return ret;
 }
@@ -2690,6 +2693,7 @@ static int ehea_stop(struct net_device *dev)
 
 	set_bit(__EHEA_DISABLE_PORT_RESET, &port->flags);
 	cancel_work_sync(&port->reset_task);
+	cancel_delayed_work_sync(&port->stats_work);
 	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 	port_napi_disable(port);
@@ -3235,10 +3239,12 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		dev->features |= NETIF_F_LRO;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
+	INIT_DELAYED_WORK(&port->stats_work, ehea_update_stats);
 
 	init_waitqueue_head(&port->swqe_avail_wq);
 	init_waitqueue_head(&port->restart_wq);
 
+	memset(&port->stats, 0, sizeof(struct net_device_stats));
 	ret = register_netdev(dev);
 	if (ret) {
 		pr_err("register_netdev failed. ret=%d\n", ret);
@@ -3278,6 +3284,7 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 	struct ehea_adapter *adapter = port->adapter;
 
 	cancel_work_sync(&port->reset_task);
+	cancel_delayed_work_sync(&port->stats_work);
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
 	kfree(port->mc_list);
-- 
1.7.1

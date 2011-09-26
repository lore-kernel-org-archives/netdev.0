From: brenohl@br.ibm.com
Subject: [PATCH] ehea: Remove sleep at .ndo_get_stats
Date: Mon, 26 Sep 2011 14:15:25 -0300
Message-ID: <1317057325-7410-1-git-send-email-brenohl@br.ibm.com>
References: <1316704497.29549.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Breno Leitao <brenohl@br.ibm.com>
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:52373 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab1IZRPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2011 13:15:35 -0400
Received: from mailhub1.br.ibm.com (mailhub1.br.ibm.com [9.18.232.109])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p8QIbTSq011987
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 15:37:29 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by mailhub1.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8QHIlnL2077030
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 14:18:49 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8QHFI14013704
	for <netdev@vger.kernel.org>; Mon, 26 Sep 2011 14:15:19 -0300
In-Reply-To: <1316704497.29549.10.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
 drivers/net/ethernet/ibm/ehea/ehea_main.c |   26 ++++++++++++++++++++------
 2 files changed, 21 insertions(+), 6 deletions(-)

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
index 583bcd3..a10f6b3 100644
--- a/drivers/net/ethernet/ibm/ehea/ehea_main.c
+++ b/drivers/net/ethernet/ibm/ehea/ehea_main.c
@@ -330,17 +330,24 @@ out:
 static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 {
 	struct ehea_port *port = netdev_priv(dev);
+
+	return &port->stats;
+}
+
+static void ehea_update_stats(struct work_struct *work)
+{
+	struct ehea_port *port =
+		container_of(work, struct ehea_port, stats_work.work);
+	struct net_device *dev = port->netdev;
 	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
 	u64 hret, rx_packets, tx_packets, rx_bytes = 0, tx_bytes = 0;
 	int i;
 
-	memset(stats, 0, sizeof(*stats));
-
 	cb2 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb2) {
-		netdev_err(dev, "no mem for cb2\n");
-		goto out;
+		netdev_err(dev, "No mem for cb2. The interface statistics was not be updated\n");
+		goto resched;
 	}
 
 	hret = ehea_h_query_ehea_port(port->adapter->handle,
@@ -375,8 +382,10 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 
 out_herr:
 	free_page((unsigned long)cb2);
-out:
-	return stats;
+
+resched:
+	schedule_delayed_work(&port->stats_work, msecs_to_jiffies(1000));
+
 }
 
 static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
@@ -2651,6 +2660,7 @@ static int ehea_open(struct net_device *dev)
 	}
 
 	mutex_unlock(&port->port_lock);
+	schedule_delayed_work(&port->stats_work, msecs_to_jiffies(1000));
 
 	return ret;
 }
@@ -2690,6 +2700,7 @@ static int ehea_stop(struct net_device *dev)
 
 	set_bit(__EHEA_DISABLE_PORT_RESET, &port->flags);
 	cancel_work_sync(&port->reset_task);
+	cancel_delayed_work_sync(&port->stats_work);
 	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 	port_napi_disable(port);
@@ -3235,10 +3246,12 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		dev->features |= NETIF_F_LRO;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
+	INIT_DELAYED_WORK(&port->stats_work, ehea_update_stats);
 
 	init_waitqueue_head(&port->swqe_avail_wq);
 	init_waitqueue_head(&port->restart_wq);
 
+	memset(&port->stats, 0, sizeof(struct net_device_stats));
 	ret = register_netdev(dev);
 	if (ret) {
 		pr_err("register_netdev failed. ret=%d\n", ret);
@@ -3278,6 +3291,7 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 	struct ehea_adapter *adapter = port->adapter;
 
 	cancel_work_sync(&port->reset_task);
+	cancel_delayed_work_sync(&port->stats_work);
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
 	kfree(port->mc_list);
-- 
1.7.1

From: brenohl@br.ibm.com
Subject: [PATCH net-next] ehea: Remove sleep at .ndo_get_stats
Date: Thu, 22 Sep 2011 11:10:57 -0300
Message-ID: <1316700657-14980-1-git-send-email-brenohl@br.ibm.com>
Cc: netdev@vger.kernel.org, Breno Leitao <leitao@linux.vnet.ibm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from e24smtp02.br.ibm.com ([32.104.18.86]:56651 "EHLO
	e24smtp02.br.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254Ab1IVOLD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2011 10:11:03 -0400
Received: from d24relay01.br.ibm.com (d24relay01.br.ibm.com [9.8.31.16])
	by e24smtp02.br.ibm.com (8.14.4/8.13.1) with ESMTP id p8MFWHDe008557
	for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 12:32:17 -0300
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay01.br.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p8MEA5Q63473450
	for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 11:10:06 -0300
Received: from d24av01.br.ibm.com (loopback [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p8MEApgj029730
	for <netdev@vger.kernel.org>; Thu, 22 Sep 2011 11:10:52 -0300
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently ehea ndo_get_stats can sleep in two places, in a hcall
and in a GFP_KERNEL alloc, which is not correct.
This patch creates a workqueue that grabs the information from time
to time from the hardware, and place it into the device structure,
so that, .ndo_get_stats quickly returns the device structure statistics
block.

Signed-off-by: Breno Leitao <leitao@linux.vnet.ibm.com>
---
 drivers/net/ehea/ehea.h      |    1 +
 drivers/net/ehea/ehea_main.c |   20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 7dd5e6a..05c39ae 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -459,6 +459,7 @@ struct ehea_port {
 	struct ehea_mc_list *mc_list;	 /* Multicast MAC addresses */
 	struct ehea_eq *qp_eq;
 	struct work_struct reset_task;
+	struct work_struct stats_task;
 	struct mutex port_lock;
 	char int_aff_name[EHEA_IRQ_NAME_SIZE];
 	int allmulti;			 /* Indicates IFF_ALLMULTI state */
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index be2cb4a..7465553 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -330,6 +330,15 @@ out:
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
+		container_of(work, struct ehea_port, stats_task);
+	struct net_device *dev = port->netdev;
 	struct net_device_stats *stats = &port->stats;
 	struct hcp_ehea_port_cb2 *cb2;
 	u64 hret, rx_packets, tx_packets, rx_bytes = 0, tx_bytes = 0;
@@ -340,7 +349,7 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 	cb2 = (void *)get_zeroed_page(GFP_KERNEL);
 	if (!cb2) {
 		netdev_err(dev, "no mem for cb2\n");
-		goto out;
+		return;
 	}
 
 	hret = ehea_h_query_ehea_port(port->adapter->handle,
@@ -375,8 +384,6 @@ static struct net_device_stats *ehea_get_stats(struct net_device *dev)
 
 out_herr:
 	free_page((unsigned long)cb2);
-out:
-	return stats;
 }
 
 static void ehea_refill_rq1(struct ehea_port_res *pr, int index, int nr_of_wqes)
@@ -789,6 +796,8 @@ static int ehea_proc_rwqes(struct net_device *dev,
 	ehea_refill_rq2(pr, processed_rq2);
 	ehea_refill_rq3(pr, processed_rq3);
 
+	schedule_work(&port->stats_task);
+
 	return processed;
 }
 
@@ -953,6 +962,7 @@ static int ehea_poll(struct napi_struct *napi, int budget)
 		rx += ehea_proc_rwqes(dev, pr, budget - rx);
 	}
 
+	ehea_update_stats(dev);
 	pr->poll_counter++;
 	return rx;
 }
@@ -2651,6 +2661,7 @@ static int ehea_open(struct net_device *dev)
 	}
 
 	mutex_unlock(&port->port_lock);
+	schedule_work(&port->stats_task);
 
 	return ret;
 }
@@ -2690,6 +2701,7 @@ static int ehea_stop(struct net_device *dev)
 
 	set_bit(__EHEA_DISABLE_PORT_RESET, &port->flags);
 	cancel_work_sync(&port->reset_task);
+	cancel_work_sync(&port->stats_task);
 	mutex_lock(&port->port_lock);
 	netif_stop_queue(dev);
 	port_napi_disable(port);
@@ -3235,6 +3247,7 @@ struct ehea_port *ehea_setup_single_port(struct ehea_adapter *adapter,
 		dev->features |= NETIF_F_LRO;
 
 	INIT_WORK(&port->reset_task, ehea_reset_port);
+	INIT_WORK(&port->stats_task, ehea_update_stats);
 
 	init_waitqueue_head(&port->swqe_avail_wq);
 	init_waitqueue_head(&port->restart_wq);
@@ -3278,6 +3291,7 @@ static void ehea_shutdown_single_port(struct ehea_port *port)
 	struct ehea_adapter *adapter = port->adapter;
 
 	cancel_work_sync(&port->reset_task);
+	cancel_work_sync(&port->stats_task);
 	unregister_netdev(port->netdev);
 	ehea_unregister_port(port);
 	kfree(port->mc_list);
-- 
1.7.1

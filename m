From: Erez Shitrit <erezsh@mellanox.com>
Subject: [RFC v1 for accelerated IPoIB 01/25] IB/ipoib: Separate control and data related initializations
Date: Mon, 13 Mar 2017 20:31:12 +0200
Message-ID: <1489429896-10781-2-git-send-email-erezsh@mellanox.com>
References: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        valex@mellanox.com, leonro@mellanox.com, saedm@mellanox.com,
        erezsh@dev.mellanox.co.il, Erez Shitrit <erezsh@mellanox.com>
To: dledford@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:49614 "EHLO
        mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1752421AbdCMSb4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Mar 2017 14:31:56 -0400
In-Reply-To: <1489429896-10781-1-git-send-email-erezsh@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch prepares init and and teardown flows so we can call them
through ipoib_options function pointers.
It arranges that area of code as the following:
All operations which deal with the resource allocation/deletion are done
in one place.
All operations that are control oriented, meaning that they are not
connected to a specific HW beneath, are done in a separate place.

The operations for alloc HW resources are now in the function
ipoib_dev_init_default, the deletion of all the resources are in
ipoib_dev_uninit_default The only exception is the creation of the pd
object which is used both for resource allocation (create QP etc.) and for
control flows like creating ah.

It also does:
Move creation of rx_ring and tx_ring to be in the resources allocation
area.
Move the function ipoib_ib_dev_open that does the open device to the
control area instead of the dev_init which creates resources.

Signed-off-by: Erez Shitrit <erezsh@mellanox.com>
---
 drivers/infiniband/ulp/ipoib/ipoib.h       |   5 +-
 drivers/infiniband/ulp/ipoib/ipoib_ib.c    |  39 +++-------
 drivers/infiniband/ulp/ipoib/ipoib_main.c  | 116 ++++++++++++++++++++++++-----
 drivers/infiniband/ulp/ipoib/ipoib_verbs.c |  40 +---------
 4 files changed, 110 insertions(+), 90 deletions(-)

diff --git a/drivers/infiniband/ulp/ipoib/ipoib.h b/drivers/infiniband/ulp/ipoib/ipoib.h
index bed233bf45c3..7cd9befd7d54 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib.h
+++ b/drivers/infiniband/ulp/ipoib/ipoib.h
@@ -491,14 +491,13 @@ void ipoib_send(struct net_device *dev, struct sk_buff *skb,
 void ipoib_flush_paths(struct net_device *dev);
 int ipoib_check_sm_sendonly_fullmember_support(struct ipoib_dev_priv *priv);
 struct ipoib_dev_priv *ipoib_intf_alloc(const char *format);
-
-int ipoib_ib_dev_init(struct net_device *dev, struct ib_device *ca, int port);
+void ipoib_ib_tx_timer_func(unsigned long ctx);
 void ipoib_ib_dev_flush_light(struct work_struct *work);
 void ipoib_ib_dev_flush_normal(struct work_struct *work);
 void ipoib_ib_dev_flush_heavy(struct work_struct *work);
 void ipoib_pkey_event(struct work_struct *work);
 void ipoib_ib_dev_cleanup(struct net_device *dev);
-
+void ipoib_dev_uninit_default(struct net_device *dev);
 int ipoib_ib_dev_open(struct net_device *dev);
 void ipoib_ib_dev_up(struct net_device *dev);
 void ipoib_ib_dev_down(struct net_device *dev);
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_ib.c b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
index 12c4f84a6639..3c0a35d883e2 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
@@ -40,6 +40,7 @@
 
 #include <linux/ip.h>
 #include <linux/tcp.h>
+#include <linux/vmalloc.h>
 
 #include "ipoib.h"
 
@@ -692,7 +693,7 @@ static void ipoib_stop_ah(struct net_device *dev)
 	ipoib_flush_ah(dev);
 }
 
-static void ipoib_ib_tx_timer_func(unsigned long ctx)
+void ipoib_ib_tx_timer_func(unsigned long ctx)
 {
 	drain_tx_cq((struct net_device *)ctx);
 }
@@ -913,32 +914,6 @@ void ipoib_ib_dev_stop(struct net_device *dev)
 	ib_req_notify_cq(priv->recv_cq, IB_CQ_NEXT_COMP);
 }
 
-int ipoib_ib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
-{
-	struct ipoib_dev_priv *priv = netdev_priv(dev);
-
-	priv->ca = ca;
-	priv->port = port;
-	priv->qp = NULL;
-
-	if (ipoib_transport_dev_init(dev, ca)) {
-		printk(KERN_WARNING "%s: ipoib_transport_dev_init failed\n", ca->name);
-		return -ENODEV;
-	}
-
-	setup_timer(&priv->poll_timer, ipoib_ib_tx_timer_func,
-		    (unsigned long) dev);
-
-	if (dev->flags & IFF_UP) {
-		if (ipoib_ib_dev_open(dev)) {
-			ipoib_transport_dev_cleanup(dev);
-			return -ENODEV;
-		}
-	}
-
-	return 0;
-}
-
 /*
  * Takes whatever value which is in pkey index 0 and updates priv->pkey
  * returns 0 if the pkey value was changed.
@@ -1236,7 +1211,13 @@ void ipoib_ib_dev_cleanup(struct net_device *dev)
 	 */
 	ipoib_stop_ah(dev);
 
-	ipoib_transport_dev_cleanup(dev);
-}
+	clear_bit(IPOIB_PKEY_ASSIGNED, &priv->flags);
+
+	ipoib_dev_uninit_default(dev);
 
+	if (priv->pd) {
+		ib_dealloc_pd(priv->pd);
+		priv->pd = NULL;
+	}
+}
 
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
index 259c59f67394..8c644bbc2828 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
@@ -1622,8 +1622,23 @@ static void ipoib_neigh_hash_uninit(struct net_device *dev)
 	wait_for_completion(&priv->ntbl.deleted);
 }
 
+void ipoib_dev_uninit_default(struct net_device *dev)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
-int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
+	ipoib_transport_dev_cleanup(dev);
+
+	ipoib_cm_dev_cleanup(dev);
+
+	kfree(priv->rx_ring);
+	vfree(priv->tx_ring);
+
+	priv->rx_ring = NULL;
+	priv->tx_ring = NULL;
+}
+
+static int ipoib_dev_init_default(struct net_device *dev, struct ib_device *ca,
+				  int port)
 {
 	struct ipoib_dev_priv *priv = netdev_priv(dev);
 
@@ -1642,29 +1657,95 @@ int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
 
 	/* priv->tx_head, tx_tail & tx_outstanding are already 0 */
 
-	if (ipoib_ib_dev_init(dev, ca, port))
+	if (ipoib_transport_dev_init(dev, ca)) {
+		pr_warn("%s: ipoib_transport_dev_init failed\n", ca->name);
 		goto out_tx_ring_cleanup;
+	}
+
+	setup_timer(&priv->poll_timer, ipoib_ib_tx_timer_func,
+		    (unsigned long)dev);
+
+	return 0;
+
+out_tx_ring_cleanup:
+	vfree(priv->tx_ring);
+
+out_rx_ring_cleanup:
+	kfree(priv->rx_ring);
+
+out:
+	return -ENOMEM;
+}
+
+int ipoib_dev_init(struct net_device *dev, struct ib_device *ca, int port)
+{
+	struct ipoib_dev_priv *priv = netdev_priv(dev);
+	int ret = -ENOMEM;
+
+	priv->ca = ca;
+	priv->port = port;
+	priv->qp = NULL;
 
 	/*
-	 * Must be after ipoib_ib_dev_init so we can allocate a per
-	 * device wq there and use it here
+	 * the various IPoIB tasks assume they will never race against
+	 * themselves, so always use a single thread workqueue
 	 */
-	if (ipoib_neigh_hash_init(priv) < 0)
+	priv->wq = alloc_ordered_workqueue("ipoib_wq", WQ_MEM_RECLAIM);
+	if (!priv->wq) {
+		pr_warn("%s: failed to allocate device WQ\n", dev->name);
+		goto out;
+	}
+
+	/* create pd, which used both for control and datapath*/
+	priv->pd = ib_alloc_pd(priv->ca, 0);
+	if (IS_ERR(priv->pd)) {
+		pr_warn("%s: failed to allocate PD\n", ca->name);
+		goto clean_wq;
+	}
+
+	ret = ipoib_dev_init_default(dev, ca, port);
+	if (ret) {
+		pr_warn("%s failed to init HW resource\n", dev->name);
+		goto out_free_pd;
+	}
+
+	/* after qp created set dev address */
+	priv->dev->dev_addr[1] = (priv->qp->qp_num >> 16) & 0xff;
+	priv->dev->dev_addr[2] = (priv->qp->qp_num >>  8) & 0xff;
+	priv->dev->dev_addr[3] = (priv->qp->qp_num) & 0xff;
+
+	if (ipoib_neigh_hash_init(priv) < 0) {
+		pr_warn("%s failed to init neigh hash\n", dev->name);
 		goto out_dev_uninit;
+	}
+
+	if (dev->flags & IFF_UP) {
+		if (ipoib_ib_dev_open(dev)) {
+			pr_warn("%s failed to open device\n", dev->name);
+			ret = -ENODEV;
+			goto out_dev_uninit;
+		}
+	}
 
 	return 0;
 
 out_dev_uninit:
 	ipoib_ib_dev_cleanup(dev);
 
-out_tx_ring_cleanup:
-	vfree(priv->tx_ring);
+out_free_pd:
+	if (priv->pd) {
+		ib_dealloc_pd(priv->pd);
+		priv->pd = NULL;
+	}
 
-out_rx_ring_cleanup:
-	kfree(priv->rx_ring);
+clean_wq:
+	if (priv->wq) {
+		destroy_workqueue(priv->wq);
+		priv->wq = NULL;
+	}
 
 out:
-	return -ENOMEM;
+	return ret;
 }
 
 void ipoib_dev_cleanup(struct net_device *dev)
@@ -1685,19 +1766,16 @@ void ipoib_dev_cleanup(struct net_device *dev)
 	}
 	unregister_netdevice_many(&head);
 
-	/*
-	 * Must be before ipoib_ib_dev_cleanup or we delete an in use
-	 * work queue
-	 */
 	ipoib_neigh_hash_uninit(dev);
 
 	ipoib_ib_dev_cleanup(dev);
 
-	kfree(priv->rx_ring);
-	vfree(priv->tx_ring);
-
-	priv->rx_ring = NULL;
-	priv->tx_ring = NULL;
+	/* no more works over the priv->wq */
+	if (priv->wq) {
+		flush_workqueue(priv->wq);
+		destroy_workqueue(priv->wq);
+		priv->wq = NULL;
+	}
 }
 
 static int ipoib_set_vf_link_state(struct net_device *dev, int vf, int link_state)
diff --git a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
index 189dcd1709d2..529b9509a2c4 100644
--- a/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
+++ b/drivers/infiniband/ulp/ipoib/ipoib_verbs.c
@@ -147,22 +147,6 @@ int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 	int ret, size;
 	int i;
 
-	priv->pd = ib_alloc_pd(priv->ca, 0);
-	if (IS_ERR(priv->pd)) {
-		printk(KERN_WARNING "%s: failed to allocate PD\n", ca->name);
-		return -ENODEV;
-	}
-
-	/*
-	 * the various IPoIB tasks assume they will never race against
-	 * themselves, so always use a single thread workqueue
-	 */
-	priv->wq = alloc_ordered_workqueue("ipoib_wq", WQ_MEM_RECLAIM);
-	if (!priv->wq) {
-		printk(KERN_WARNING "ipoib: failed to allocate device WQ\n");
-		goto out_free_pd;
-	}
-
 	size = ipoib_recvq_size + 1;
 	ret = ipoib_cm_dev_init(dev);
 	if (!ret) {
@@ -173,7 +157,7 @@ int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 			size += ipoib_recvq_size * ipoib_max_conn_qp;
 	} else
 		if (ret != -ENOSYS)
-			goto out_free_wq;
+			return -ENODEV;
 
 	cq_attr.cqe = size;
 	priv->recv_cq = ib_create_cq(priv->ca, ipoib_ib_completion, NULL,
@@ -212,10 +196,6 @@ int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 		goto out_free_send_cq;
 	}
 
-	priv->dev->dev_addr[1] = (priv->qp->qp_num >> 16) & 0xff;
-	priv->dev->dev_addr[2] = (priv->qp->qp_num >>  8) & 0xff;
-	priv->dev->dev_addr[3] = (priv->qp->qp_num      ) & 0xff;
-
 	for (i = 0; i < MAX_SKB_FRAGS + 1; ++i)
 		priv->tx_sge[i].lkey = priv->pd->local_dma_lkey;
 
@@ -247,13 +227,6 @@ int ipoib_transport_dev_init(struct net_device *dev, struct ib_device *ca)
 out_cm_dev_cleanup:
 	ipoib_cm_dev_cleanup(dev);
 
-out_free_wq:
-	destroy_workqueue(priv->wq);
-	priv->wq = NULL;
-
-out_free_pd:
-	ib_dealloc_pd(priv->pd);
-
 	return -ENODEV;
 }
 
@@ -266,7 +239,6 @@ void ipoib_transport_dev_cleanup(struct net_device *dev)
 			ipoib_warn(priv, "ib_qp_destroy failed\n");
 
 		priv->qp = NULL;
-		clear_bit(IPOIB_PKEY_ASSIGNED, &priv->flags);
 	}
 
 	if (ib_destroy_cq(priv->send_cq))
@@ -274,16 +246,6 @@ void ipoib_transport_dev_cleanup(struct net_device *dev)
 
 	if (ib_destroy_cq(priv->recv_cq))
 		ipoib_warn(priv, "ib_cq_destroy (recv) failed\n");
-
-	ipoib_cm_dev_cleanup(dev);
-
-	if (priv->wq) {
-		flush_workqueue(priv->wq);
-		destroy_workqueue(priv->wq);
-		priv->wq = NULL;
-	}
-
-	ib_dealloc_pd(priv->pd);
 }
 
 void ipoib_event(struct ib_event_handler *handler,
-- 
1.8.3.1

From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/10] rocker: use switchdev transaction queue for allocated memory
Date: Wed, 23 Sep 2015 09:57:54 +0200
Message-ID: <1442995078-10491-7-git-send-email-jiri@resnulli.us>
References: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:34772 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753081AbbIWH6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Sep 2015 03:58:12 -0400
Received: by wicfx3 with SMTP id fx3so225677009wic.1
        for <netdev@vger.kernel.org>; Wed, 23 Sep 2015 00:58:10 -0700 (PDT)
In-Reply-To: <1442995078-10491-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Benefit from previously introduced transaction item queue infrastructure
and remove rocker specific transaction memory management.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
- free mem in case of none and commit transaction
---
 drivers/net/ethernet/rocker/rocker.c | 53 +++++-------------------------------
 1 file changed, 7 insertions(+), 46 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 10b3bfb..bfabf12 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -226,7 +226,6 @@ struct rocker_port {
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
 	struct rocker_dma_ring_info rx_ring;
-	struct list_head trans_mem;
 };
 
 struct rocker {
@@ -343,13 +342,13 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 				     struct switchdev_trans *trans, int flags,
 				     size_t size)
 {
-	struct list_head *elem = NULL;
+	struct switchdev_trans_item *elem = NULL;
 	gfp_t gfp_flags = (flags & ROCKER_OP_FLAG_NOWAIT) ?
 			  GFP_ATOMIC : GFP_KERNEL;
 
 	/* If in transaction prepare phase, allocate the memory
-	 * and enqueue it on a per-port list.  If in transaction
-	 * commit phase, dequeue the memory from the per-port list
+	 * and enqueue it on a transaction.  If in transaction
+	 * commit phase, dequeue the memory from the transaction
 	 * rather than re-allocating the memory.  The idea is the
 	 * driver code paths for prepare and commit are identical
 	 * so the memory allocated in the prepare phase is the
@@ -358,17 +357,13 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 
 	if (!trans) {
 		elem = kzalloc(size + sizeof(*elem), gfp_flags);
-		if (elem)
-			INIT_LIST_HEAD(elem);
 	} else if (switchdev_trans_ph_prepare(trans)) {
 		elem = kzalloc(size + sizeof(*elem), gfp_flags);
 		if (!elem)
 			return NULL;
-		list_add_tail(elem, &rocker_port->trans_mem);
+		switchdev_trans_item_enqueue(trans, elem, kfree, elem);
 	} else {
-		BUG_ON(list_empty(&rocker_port->trans_mem));
-		elem = rocker_port->trans_mem.next;
-		list_del_init(elem);
+		elem = switchdev_trans_item_dequeue(trans);
 	}
 
 	return elem ? elem + 1 : NULL;
@@ -390,7 +385,7 @@ static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
 
 static void rocker_port_kfree(struct switchdev_trans *trans, const void *mem)
 {
-	struct list_head *elem;
+	struct switchdev_trans_item *elem;
 
 	/* Frees are ignored if in transaction prepare phase.  The
 	 * memory remains on the per-port list until freed in the
@@ -400,8 +395,7 @@ static void rocker_port_kfree(struct switchdev_trans *trans, const void *mem)
 	if (switchdev_trans_ph_prepare(trans))
 		return;
 
-	elem = (struct list_head *)mem - 1;
-	BUG_ON(!list_empty(elem));
+	elem = (struct switchdev_trans_item *) mem - 1;
 	kfree(elem);
 }
 
@@ -4306,16 +4300,6 @@ static int rocker_port_attr_get(struct net_device *dev,
 	return 0;
 }
 
-static void rocker_port_trans_abort(const struct rocker_port *rocker_port)
-{
-	struct list_head *mem, *tmp;
-
-	list_for_each_safe(mem, tmp, &rocker_port->trans_mem) {
-		list_del(mem);
-		kfree(mem);
-	}
-}
-
 static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
 					struct switchdev_trans *trans,
 					unsigned long brport_flags)
@@ -4341,17 +4325,6 @@ static int rocker_port_attr_set(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err = 0;
 
-	switch (trans->ph) {
-	case SWITCHDEV_TRANS_PREPARE:
-		BUG_ON(!list_empty(&rocker_port->trans_mem));
-		break;
-	case SWITCHDEV_TRANS_ABORT:
-		rocker_port_trans_abort(rocker_port);
-		return 0;
-	default:
-		break;
-	}
-
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, trans,
@@ -4428,17 +4401,6 @@ static int rocker_port_obj_add(struct net_device *dev,
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (trans->ph) {
-	case SWITCHDEV_TRANS_PREPARE:
-		BUG_ON(!list_empty(&rocker_port->trans_mem));
-		break;
-	case SWITCHDEV_TRANS_ABORT:
-		rocker_port_trans_abort(rocker_port);
-		return 0;
-	default:
-		break;
-	}
-
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, trans,
@@ -4966,7 +4928,6 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->port_number = port_number;
 	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
-	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
 	rocker_port_dev_addr_init(rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
-- 
1.9.3

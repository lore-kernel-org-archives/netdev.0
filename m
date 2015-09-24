From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 06/10] rocker: use switchdev transaction queue for allocated memory
Date: Thu, 24 Sep 2015 10:02:45 +0200
Message-ID: <1443081769-11193-7-git-send-email-jiri@resnulli.us>
References: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com, rami.rosen@intel.com,
	roopa@cumulusnetworks.com, pjonnala@broadcom.com, andrew@lunn.ch,
	gospo@cumulusnetworks.com, Jiri Pirko <jiri@mellanox.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:37929 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751956AbbIXIDA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2015 04:03:00 -0400
Received: by wiclk2 with SMTP id lk2so101457151wic.1
        for <netdev@vger.kernel.org>; Thu, 24 Sep 2015 01:02:59 -0700 (PDT)
In-Reply-To: <1443081769-11193-1-git-send-email-jiri@resnulli.us>
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
index 102b37d..d3f6632 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -228,7 +228,6 @@ struct rocker_port {
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
 	struct rocker_dma_ring_info rx_ring;
-	struct list_head trans_mem;
 };
 
 struct rocker {
@@ -346,13 +345,13 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
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
@@ -361,17 +360,13 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 
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
@@ -393,7 +388,7 @@ static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
 
 static void rocker_port_kfree(struct switchdev_trans *trans, const void *mem)
 {
-	struct list_head *elem;
+	struct switchdev_trans_item *elem;
 
 	/* Frees are ignored if in transaction prepare phase.  The
 	 * memory remains on the per-port list until freed in the
@@ -403,8 +398,7 @@ static void rocker_port_kfree(struct switchdev_trans *trans, const void *mem)
 	if (switchdev_trans_ph_prepare(trans))
 		return;
 
-	elem = (struct list_head *)mem - 1;
-	BUG_ON(!list_empty(elem));
+	elem = (struct switchdev_trans_item *) mem - 1;
 	kfree(elem);
 }
 
@@ -4349,16 +4343,6 @@ static int rocker_port_attr_get(struct net_device *dev,
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
@@ -4384,17 +4368,6 @@ static int rocker_port_attr_set(struct net_device *dev,
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
@@ -4471,17 +4444,6 @@ static int rocker_port_obj_add(struct net_device *dev,
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
@@ -5010,7 +4972,6 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
 	rocker_port->ageing_time = BR_DEFAULT_AGEING_TIME;
-	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
 	rocker_port_dev_addr_init(rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
-- 
1.9.3

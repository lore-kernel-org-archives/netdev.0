From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next RFC 5/6] rocker: use switchdev transaction queue for allocated memory
Date: Sat, 19 Sep 2015 14:29:10 +0200
Message-ID: <1442665751-10949-6-git-send-email-jiri@resnulli.us>
References: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	sfeldma@gmail.com, f.fainelli@gmail.com, linux@roeck-us.net,
	vivien.didelot@savoirfairelinux.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:35618 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbbISM3Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Sep 2015 08:29:24 -0400
Received: by wicge5 with SMTP id ge5so62472562wic.0
        for <netdev@vger.kernel.org>; Sat, 19 Sep 2015 05:29:23 -0700 (PDT)
In-Reply-To: <1442665751-10949-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benefit from previously introduced infra and remove rocker specific
transaction memory management.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/ethernet/rocker/rocker.c | 64 ++++++++----------------------------
 1 file changed, 13 insertions(+), 51 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9750840..0735d90 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -226,7 +226,6 @@ struct rocker_port {
 	struct napi_struct napi_rx;
 	struct rocker_dma_ring_info tx_ring;
 	struct rocker_dma_ring_info rx_ring;
-	struct list_head trans_mem;
 };
 
 struct rocker {
@@ -347,6 +346,7 @@ enum rocker_trans_ph {
 };
 
 struct rocker_trans {
+	struct switchdev_trans *trans;
 	enum rocker_trans_ph ph;
 };
 
@@ -354,7 +354,7 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 				     struct rocker_trans *rtrans, int flags,
 				     size_t size)
 {
-	struct list_head *elem = NULL;
+	struct switchdev_trans_item *elem = NULL;
 	gfp_t gfp_flags = (flags & ROCKER_OP_FLAG_NOWAIT) ?
 			  GFP_ATOMIC : GFP_KERNEL;
 
@@ -369,20 +369,15 @@ static void *__rocker_port_mem_alloc(struct rocker_port *rocker_port,
 
 	switch (rtrans->ph) {
 	case ROCKER_TRANS_PH_PREPARE:
-		elem = kzalloc(size + sizeof(*elem), gfp_flags);
+		elem = kzalloc(size + sizeof(elem), gfp_flags);
 		if (!elem)
 			return NULL;
-		list_add_tail(elem, &rocker_port->trans_mem);
-		break;
+		switchdev_trans_item_enqueue(rtrans->trans, elem, kfree, elem);
 	case ROCKER_TRANS_PH_COMMIT:
-		BUG_ON(list_empty(&rocker_port->trans_mem));
-		elem = rocker_port->trans_mem.next;
-		list_del_init(elem);
+		elem = switchdev_trans_item_dequeue(rtrans->trans);
 		break;
 	case ROCKER_TRANS_PH_NONE:
-		elem = kzalloc(size + sizeof(*elem), gfp_flags);
-		if (elem)
-			INIT_LIST_HEAD(elem);
+		elem = kzalloc(size + sizeof(elem), gfp_flags);
 		break;
 	default:
 		break;
@@ -407,18 +402,16 @@ static void *rocker_port_kcalloc(struct rocker_port *rocker_port,
 
 static void rocker_port_kfree(struct rocker_trans *rtrans, const void *mem)
 {
-	struct list_head *elem;
+	struct switchdev_trans_item *elem;
 
-	/* Frees are ignored if in transaction prepare phase.  The
-	 * memory remains on the per-port list until freed in the
-	 * commit phase.
+	/* Free only in case of NONE phase, otherwise, switchdev core
+	 * will take care of the cleanup
 	 */
 
-	if (rtrans->ph == ROCKER_TRANS_PH_PREPARE)
+	if (rtrans->ph != ROCKER_TRANS_PH_NONE)
 		return;
 
-	elem = (struct list_head *)mem - 1;
-	BUG_ON(!list_empty(elem));
+	elem = (struct switchdev_trans_item *) mem - 1;
 	kfree(elem);
 }
 
@@ -4322,16 +4315,6 @@ static int rocker_port_attr_get(struct net_device *dev,
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
 					struct rocker_trans *rtrans,
 					unsigned long brport_flags)
@@ -4357,20 +4340,10 @@ static int rocker_port_attr_set(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker_trans rtrans = {
 		.ph = trans->ph,
+		.trans = trans,
 	};
 	int err = 0;
 
-	switch (rtrans.ph) {
-	case ROCKER_TRANS_PH_PREPARE:
-		BUG_ON(!list_empty(&rocker_port->trans_mem));
-		break;
-	case ROCKER_TRANS_PH_ABORT:
-		rocker_port_trans_abort(rocker_port);
-		return 0;
-	default:
-		break;
-	}
-
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, &rtrans,
@@ -4445,21 +4418,11 @@ static int rocker_port_obj_add(struct net_device *dev,
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	struct rocker_trans rtrans = {
 		.ph = trans->ph,
+		.trans = trans,
 	};
 	const struct switchdev_obj_ipv4_fib *fib4;
 	int err = 0;
 
-	switch (rtrans.ph) {
-	case ROCKER_TRANS_PH_PREPARE:
-		BUG_ON(!list_empty(&rocker_port->trans_mem));
-		break;
-	case ROCKER_TRANS_PH_ABORT:
-		rocker_port_trans_abort(rocker_port);
-		return 0;
-	default:
-		break;
-	}
-
 	switch (obj->id) {
 	case SWITCHDEV_OBJ_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, &rtrans,
@@ -4992,7 +4955,6 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->port_number = port_number;
 	rocker_port->pport = port_number + 1;
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
-	INIT_LIST_HEAD(&rocker_port->trans_mem);
 
 	rocker_port_dev_addr_init(rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
-- 
1.9.3

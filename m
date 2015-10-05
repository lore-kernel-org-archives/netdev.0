From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 06/13] rocker: introduce worlds infrastructure
Date: Mon,  5 Oct 2015 19:43:59 +0200
Message-ID: <1444067046-27825-7-git-send-email-jiri@resnulli.us>
References: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com,
	David.Laight@ACULAB.COM, john.fastabend@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:37681 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499AbbJERoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 13:44:17 -0400
Received: by wicfx3 with SMTP id fx3so125385965wic.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 10:44:16 -0700 (PDT)
In-Reply-To: <1444067046-27825-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is another step on the way to per-world clean cut. Introduce world
ops hooks which each world can implement in world-specific way.
Also introduce world infrastructure including function for port worlds
change.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
v1->v2:
 - removed functions to change worlds based on name, as rtnl mode
   set patch is removed from patchset.
---
 drivers/net/ethernet/rocker/rocker.h      |  56 ++++
 drivers/net/ethernet/rocker/rocker_main.c | 464 +++++++++++++++++++++++++++++-
 2 files changed, 519 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 650caa0..d49bc5d 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -12,7 +12,11 @@
 #ifndef _ROCKER_H
 #define _ROCKER_H
 
+#include <linux/kernel.h>
 #include <linux/types.h>
+#include <linux/netdevice.h>
+#include <net/neighbour.h>
+#include <net/switchdev.h>
 
 #include "rocker_hw.h"
 
@@ -24,4 +28,56 @@ struct rocker_desc_info {
 	dma_addr_t mapaddr;
 };
 
+struct rocker;
+struct rocker_port;
+
+struct rocker_world_ops {
+	const char *kind;
+	size_t priv_size;
+	size_t port_priv_size;
+	u8 mode;
+	int (*init)(struct rocker *rocker, void *priv);
+	void (*fini)(void *priv);
+	int (*port_init)(struct rocker_port *rocker_port, void *priv,
+			 void *port_priv);
+	void (*port_fini)(void *port_priv);
+	int (*port_open)(void *port_priv);
+	void (*port_stop)(void *port_priv);
+	int (*port_attr_stp_state_set)(void *port_priv, u8 state,
+				       struct switchdev_trans *trans);
+	int (*port_attr_bridge_flags_set)(void *port_priv,
+					  unsigned long brport_flags,
+					  struct switchdev_trans *trans);
+	int (*port_attr_bridge_flags_get)(void *port_priv,
+					  unsigned long *p_brport_flags);
+	int (*port_obj_vlan_add)(void *port_priv,
+				 const struct switchdev_obj_port_vlan *vlan,
+				 struct switchdev_trans *trans);
+	int (*port_obj_vlan_del)(void *port_priv,
+				 const struct switchdev_obj_port_vlan *vlan);
+	int (*port_obj_vlan_dump)(void *port_priv,
+				  struct switchdev_obj_port_vlan *vlan,
+				  switchdev_obj_dump_cb_t *cb);
+	int (*port_obj_fib4_add)(void *port_priv,
+				 const struct switchdev_obj_ipv4_fib *fib4,
+				 struct switchdev_trans *trans);
+	int (*port_obj_fib4_del)(void *port_priv,
+				 const struct switchdev_obj_ipv4_fib *fib4);
+	int (*port_obj_fdb_add)(void *port_priv,
+				const struct switchdev_obj_port_fdb *fdb,
+				struct switchdev_trans *trans);
+	int (*port_obj_fdb_del)(void *port_priv,
+				const struct switchdev_obj_port_fdb *fdb);
+	int (*port_obj_fdb_dump)(void *port_priv,
+				 struct switchdev_obj_port_fdb *fdb,
+				 switchdev_obj_dump_cb_t *cb);
+	int (*port_master_linked)(void *port_priv, struct net_device *master);
+	int (*port_master_unlinked)(void *port_priv, struct net_device *master);
+	int (*port_neigh_update)(void *port_priv, struct neighbour *n);
+	int (*port_neigh_destroy)(void *port_priv, struct neighbour *n);
+	int (*port_ev_mac_vlan_seen)(void *port_priv,
+				     const unsigned char *addr,
+				     __be16 vlan_id);
+};
+
 #endif
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 54d2f46..3bfb9e9 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -210,6 +210,8 @@ struct rocker_port {
 	struct net_device *dev;
 	struct net_device *bridge_dev;
 	struct rocker *rocker;
+	struct rocker_world *world;
+	void *world_port_priv;
 	unsigned int port_number;
 	u32 pport;
 	__be16 internal_vlan_id;
@@ -236,6 +238,7 @@ struct rocker {
 	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
+	struct list_head worlds;
 	DECLARE_HASHTABLE(flow_tbl, 16);
 	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
 	u64 flow_tbl_next_cookie;
@@ -1236,6 +1239,9 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 			   struct switchdev_trans *trans,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags);
+static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
+					      const unsigned char *addr,
+					      __be16 vlan_id);
 
 static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 				      const struct rocker_tlv *info)
@@ -1246,6 +1252,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 	const unsigned char *addr;
 	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_LEARNED;
 	__be16 vlan_id;
+	int err;
 
 	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
 	if (!attrs[ROCKER_TLV_EVENT_MAC_VLAN_PPORT] ||
@@ -1262,6 +1269,10 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 
 	rocker_port = rocker->ports[port_number];
 
+	err = rocker_world_port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
+	if (err)
+		return err;
+
 	if (rocker_port->stp_state != BR_STATE_LEARNING &&
 	    rocker_port->stp_state != BR_STATE_FORWARDING)
 		return 0;
@@ -2155,6 +2166,372 @@ static int rocker_cmd_group_tbl_del(const struct rocker_port *rocker_port,
 	return 0;
 }
 
+/**********************
+ * Worlds manipulation
+ **********************/
+
+static struct rocker_world_ops *rocker_world_ops[] = {
+};
+
+#define ROCKER_WORLD_OPS_LEN ARRAY_SIZE(rocker_world_ops)
+
+struct rocker_world {
+	struct list_head list;
+	const struct rocker_world_ops *ops;
+	unsigned int ref;
+	unsigned long priv[0];
+};
+
+static struct rocker_world *__rocker_world_find(struct rocker *rocker,
+						const struct rocker_world_ops *ops)
+{
+	struct rocker_world *world;
+
+	list_for_each_entry(world, &rocker->worlds, list) {
+		if (world->ops == ops)
+			return world;
+	}
+	return NULL;
+}
+
+static int rocker_world_init(struct rocker *rocker, struct rocker_world *world)
+{
+	if (!world->ops->init)
+		return 0;
+	return world->ops->init(rocker, world->priv);
+}
+
+static void rocker_world_fini(struct rocker *rocker, struct rocker_world *world)
+{
+	if (!world->ops->fini)
+		return;
+	return world->ops->fini(world->priv);
+}
+
+static int rocker_world_get(struct rocker_port *rocker_port,
+			    const struct rocker_world_ops *ops)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	struct rocker_world *world = __rocker_world_find(rocker, ops);
+	int err;
+
+	if (world)
+		goto ref_inc;
+	world = kzalloc(sizeof(*world) + ops->priv_size, GFP_KERNEL);
+	if (!world)
+		return -ENOMEM;
+	world->ops = ops;
+
+	err = rocker_world_init(rocker, world);
+	if (err)
+		goto err_world_init;
+
+	list_add_tail(&world->list, &rocker->worlds);
+ref_inc:
+	world->ref++;
+	rocker_port->world = world;
+	return 0;
+
+err_world_init:
+	kfree(world);
+	return err;
+}
+
+static void rocker_world_put(struct rocker_port *rocker_port)
+{
+	struct rocker_world *world = rocker_port->world;
+	struct rocker *rocker = rocker_port->rocker;
+
+	world->ref--;
+	if (world->ref)
+		return;
+	list_del(&world->list);
+	rocker_world_fini(rocker, world);
+	kfree(world);
+	rocker_port->world = NULL;
+}
+
+static int rocker_world_port_init(struct rocker_port *rocker_port)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_init)
+		return 0;
+	return world->ops->port_init(rocker_port, world->priv,
+				     rocker_port->world_port_priv);
+}
+
+static void rocker_world_port_fini(struct rocker_port *rocker_port)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_fini)
+		return;
+	world->ops->port_fini(rocker_port->world_port_priv);
+}
+
+static int rocker_world_port_join(struct rocker_port *rocker_port,
+				  const struct rocker_world_ops *ops)
+{
+	int err;
+
+	err = rocker_world_get(rocker_port, ops);
+	if (err)
+		return err;
+	rocker_port->world_port_priv = kzalloc(ops->port_priv_size, GFP_KERNEL);
+	if (!rocker_port->world_port_priv) {
+		err = -ENOMEM;
+		goto err_alloc_port_priv;
+	}
+	err = rocker_cmd_set_port_settings_mode(rocker_port, ops->mode);
+	if (err)
+		goto err_set_mode;
+	err = rocker_world_port_init(rocker_port);
+	if (err)
+		goto err_port_init;
+	return 0;
+
+err_port_init:
+err_set_mode:
+	kfree(rocker_port->world_port_priv);
+err_alloc_port_priv:
+	rocker_world_put(rocker_port);
+	return err;
+}
+
+static void rocker_world_port_leave(struct rocker_port *rocker_port)
+{
+	rocker_world_port_fini(rocker_port);
+	kfree(rocker_port->world_port_priv);
+	rocker_world_put(rocker_port);
+}
+
+static int rocker_port_change_world(struct rocker_port *rocker_port,
+				    const struct rocker_world_ops *ops)
+{
+	int err;
+
+	/* Check if mode was previously set and do cleanup if so */
+	if (rocker_port->world)
+		rocker_world_port_leave(rocker_port);
+	if (ops) {
+		err = rocker_world_port_join(rocker_port, ops);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int rocker_world_port_open(struct rocker_port *rocker_port)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (world->ops->port_open)
+		return 0;
+	return world->ops->port_open(rocker_port->world_port_priv);
+}
+
+static void rocker_world_port_stop(struct rocker_port *rocker_port)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (world->ops->port_stop)
+		return;
+	world->ops->port_stop(rocker_port->world_port_priv);
+}
+
+static int rocker_world_port_attr_stp_state_set(struct rocker_port *rocker_port,
+						u8 state,
+						struct switchdev_trans *trans)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_attr_stp_state_set)
+		return 0;
+	return world->ops->port_attr_stp_state_set(rocker_port->world_port_priv,
+						   state, trans);
+}
+
+static int
+rocker_world_port_attr_bridge_flags_set(struct rocker_port *rocker_port,
+					unsigned long brport_flags,
+					struct switchdev_trans *trans)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_attr_bridge_flags_set)
+		return 0;
+	return world->ops->port_attr_bridge_flags_set(rocker_port->world_port_priv,
+						      brport_flags, trans);
+}
+
+static int
+rocker_world_port_attr_bridge_flags_get(const struct rocker_port *rocker_port,
+					unsigned long *p_brport_flags)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_attr_bridge_flags_get)
+		return 0;
+	return world->ops->port_attr_bridge_flags_get(rocker_port->world_port_priv,
+						      p_brport_flags);
+}
+
+static int
+rocker_world_port_obj_vlan_add(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_port_vlan *vlan,
+			       struct switchdev_trans *trans)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_vlan_add)
+		return 0;
+	return world->ops->port_obj_vlan_add(rocker_port->world_port_priv,
+					     vlan, trans);
+}
+
+static int
+rocker_world_port_obj_vlan_del(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_port_vlan *vlan)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_vlan_del)
+		return 0;
+	return world->ops->port_obj_vlan_del(rocker_port->world_port_priv,
+					     vlan);
+}
+
+static int
+rocker_world_port_obj_vlan_dump(const struct rocker_port *rocker_port,
+				struct switchdev_obj_port_vlan *vlan,
+				switchdev_obj_dump_cb_t *cb)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_vlan_dump)
+		return 0;
+	return world->ops->port_obj_vlan_dump(rocker_port->world_port_priv,
+					      vlan, cb);
+}
+
+static int
+rocker_world_port_obj_fib4_add(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_ipv4_fib *fib4,
+			       struct switchdev_trans *trans)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_fib4_add)
+		return 0;
+	return world->ops->port_obj_fib4_add(rocker_port->world_port_priv,
+					     fib4, trans);
+}
+
+static int
+rocker_world_port_obj_fib4_del(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_ipv4_fib *fib4)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_fib4_del)
+		return 0;
+	return world->ops->port_obj_fib4_del(rocker_port->world_port_priv,
+					     fib4);
+}
+
+static int
+rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
+			      const struct switchdev_obj_port_fdb *fdb,
+			      struct switchdev_trans *trans)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_fdb_add)
+		return 0;
+	return world->ops->port_obj_fdb_add(rocker_port->world_port_priv,
+					    fdb, trans);
+}
+
+static int
+rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
+			      const struct switchdev_obj_port_fdb *fdb)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_fdb_del)
+		return 0;
+	return world->ops->port_obj_fdb_del(rocker_port->world_port_priv,
+					    fdb);
+}
+
+static int
+rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
+			       struct switchdev_obj_port_fdb *fdb,
+			       switchdev_obj_dump_cb_t *cb)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_obj_fdb_dump)
+		return 0;
+	return world->ops->port_obj_fdb_dump(rocker_port->world_port_priv,
+					     fdb, cb);
+}
+
+static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
+					   struct net_device *master)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_master_linked)
+		return 0;
+	return world->ops->port_master_linked(rocker_port->world_port_priv,
+					      master);
+}
+
+static int rocker_world_port_master_unlinked(struct rocker_port *rocker_port,
+					     struct net_device *master)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_master_unlinked)
+		return 0;
+	return world->ops->port_master_unlinked(rocker_port->world_port_priv,
+						master);
+}
+
+static int rocker_world_port_neigh_update(struct rocker_port *rocker_port,
+					  struct neighbour *n)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_neigh_update)
+		return 0;
+	return world->ops->port_neigh_update(rocker_port->world_port_priv, n);
+}
+
+static int rocker_world_port_neigh_destroy(struct rocker_port *rocker_port,
+					   struct neighbour *n)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_neigh_destroy)
+		return 0;
+	return world->ops->port_neigh_destroy(rocker_port->world_port_priv, n);
+}
+
+static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
+					      const unsigned char *addr,
+					      __be16 vlan_id)
+{
+	struct rocker_world *world = rocker_port->world;
+
+	if (!world->ops->port_ev_mac_vlan_seen)
+		return 0;
+	return world->ops->port_ev_mac_vlan_seen(rocker_port->world_port_priv,
+						 addr, vlan_id);
+}
+
 /***************************************************
  * Flow, group, FDB, internal VLAN and neigh tables
  ***************************************************/
@@ -3849,6 +4226,11 @@ static int rocker_port_open(struct net_device *dev)
 	struct rocker_port *rocker_port = netdev_priv(dev);
 	int err;
 
+	if (!rocker_port->world) {
+		netdev_err(rocker_port->dev, "World not set\n");
+		return -EINVAL;
+	}
+
 	err = rocker_port_dma_rings_init(rocker_port);
 	if (err)
 		return err;
@@ -3869,6 +4251,12 @@ static int rocker_port_open(struct net_device *dev)
 		goto err_request_rx_irq;
 	}
 
+	err = rocker_world_port_open(rocker_port);
+	if (err) {
+		netdev_err(rocker_port->dev, "cannot open port in world\n");
+		goto err_world_port_open;
+	}
+
 	err = rocker_port_fwd_enable(rocker_port, NULL, 0);
 	if (err)
 		goto err_fwd_enable;
@@ -3881,6 +4269,7 @@ static int rocker_port_open(struct net_device *dev)
 	return 0;
 
 err_fwd_enable:
+err_world_port_open:
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 err_request_rx_irq:
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
@@ -3897,6 +4286,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
+	rocker_world_port_stop(rocker_port);
 	rocker_port_fwd_disable(rocker_port, NULL,
 				ROCKER_OP_FLAG_NOWAIT);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
@@ -4107,9 +4497,14 @@ static void rocker_port_neigh_destroy(struct neighbour *n)
 	struct rocker_port *rocker_port = netdev_priv(n->dev);
 	int flags = ROCKER_OP_FLAG_REMOVE | ROCKER_OP_FLAG_NOWAIT;
 	__be32 ip_addr = *(__be32 *)n->primary_key;
+	int err;
 
 	rocker_port_ipv4_neigh(rocker_port, NULL,
 			       flags, ip_addr, n->ha);
+	err = rocker_world_port_neigh_destroy(rocker_port, n);
+	if (err)
+		netdev_warn(rocker_port->dev, "failed to handle neigh destroy (err %d)\n",
+			    err);
 }
 
 static const struct net_device_ops rocker_port_netdev_ops = {
@@ -4138,6 +4533,7 @@ static int rocker_port_attr_get(struct net_device *dev,
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct rocker *rocker = rocker_port->rocker;
+	int err = 0;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
@@ -4146,12 +4542,14 @@ static int rocker_port_attr_get(struct net_device *dev,
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
 		attr->u.brport_flags = rocker_port->brport_flags;
+		err = rocker_world_port_attr_bridge_flags_get(rocker_port,
+							      &attr->u.brport_flags);
 		break;
 	default:
 		return -EOPNOTSUPP;
 	}
 
-	return 0;
+	return err;
 }
 
 static int rocker_port_brport_flags_set(struct rocker_port *rocker_port,
@@ -4184,10 +4582,20 @@ static int rocker_port_attr_set(struct net_device *dev,
 		err = rocker_port_stp_update(rocker_port, trans,
 					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
+		if (err)
+			break;
+		err = rocker_world_port_attr_stp_state_set(rocker_port,
+							   attr->u.stp_state,
+							   trans);
 		break;
 	case SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS:
 		err = rocker_port_brport_flags_set(rocker_port, trans,
 						   attr->u.brport_flags);
+		if (err)
+			break;
+		err = rocker_world_port_attr_bridge_flags_set(rocker_port,
+							      attr->u.brport_flags,
+							      trans);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4259,16 +4667,31 @@ static int rocker_port_obj_add(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlans_add(rocker_port, trans,
 					    SWITCHDEV_OBJ_PORT_VLAN(obj));
+		if (err)
+			break;
+		err = rocker_world_port_obj_vlan_add(rocker_port,
+						     SWITCHDEV_OBJ_PORT_VLAN(obj),
+						     trans);
 		break;
 	case SWITCHDEV_OBJ_ID_IPV4_FIB:
 		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
 		err = rocker_port_fib_ipv4(rocker_port, trans,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id, 0);
+		if (err)
+			break;
+		err = rocker_world_port_obj_fib4_add(rocker_port,
+						     SWITCHDEV_OBJ_IPV4_FIB(obj),
+						     trans);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_add(rocker_port, trans,
 					  SWITCHDEV_OBJ_PORT_FDB(obj));
+		if (err)
+			break;
+		err = rocker_world_port_obj_fdb_add(rocker_port,
+						    SWITCHDEV_OBJ_PORT_FDB(obj),
+						    trans);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4331,6 +4754,10 @@ static int rocker_port_obj_del(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlans_del(rocker_port,
 					    SWITCHDEV_OBJ_PORT_VLAN(obj));
+		if (err)
+			break;
+		err = rocker_world_port_obj_vlan_del(rocker_port,
+						     SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_IPV4_FIB:
 		fib4 = SWITCHDEV_OBJ_IPV4_FIB(obj);
@@ -4338,10 +4765,18 @@ static int rocker_port_obj_del(struct net_device *dev,
 					   htonl(fib4->dst), fib4->dst_len,
 					   fib4->fi, fib4->tb_id,
 					   ROCKER_OP_FLAG_REMOVE);
+		if (err)
+			break;
+		err = rocker_world_port_obj_fib4_del(rocker_port,
+						     SWITCHDEV_OBJ_IPV4_FIB(obj));
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_del(rocker_port, NULL,
 					  SWITCHDEV_OBJ_PORT_FDB(obj));
+		if (err)
+			break;
+		err = rocker_world_port_obj_fdb_del(rocker_port,
+						    SWITCHDEV_OBJ_PORT_FDB(obj));
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4412,10 +4847,20 @@ static int rocker_port_obj_dump(struct net_device *dev,
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_port_fdb_dump(rocker_port,
 					   SWITCHDEV_OBJ_PORT_FDB(obj), cb);
+		if (err)
+			break;
+		err = rocker_world_port_obj_fdb_dump(rocker_port,
+						     SWITCHDEV_OBJ_PORT_FDB(obj),
+						     cb);
 		break;
 	case SWITCHDEV_OBJ_ID_PORT_VLAN:
 		err = rocker_port_vlan_dump(rocker_port,
 					    SWITCHDEV_OBJ_PORT_VLAN(obj), cb);
+		if (err)
+			break;
+		err = rocker_world_port_obj_vlan_dump(rocker_port,
+						      SWITCHDEV_OBJ_PORT_VLAN(obj),
+						      cb);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4910,6 +5355,7 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 	rocker = kzalloc(sizeof(*rocker), GFP_KERNEL);
 	if (!rocker)
 		return -ENOMEM;
+	INIT_LIST_HEAD(&rocker->worlds);
 
 	err = pci_enable_device(pdev);
 	if (err) {
@@ -5187,12 +5633,22 @@ static int rocker_netdevice_event(struct notifier_block *unused,
 			goto out;
 		rocker_port = netdev_priv(dev);
 		if (info->linking) {
+			err = rocker_world_port_master_linked(rocker_port,
+							      info->upper_dev);
+			if (err)
+				netdev_warn(dev, "failed to reflect master linked (err %d)\n",
+					    err);
 			err = rocker_port_master_linked(rocker_port,
 							info->upper_dev);
 			if (err)
 				netdev_warn(dev, "failed to reflect master linked (err %d)\n",
 					    err);
 		} else {
+			err = rocker_world_port_master_unlinked(rocker_port,
+								info->upper_dev);
+			if (err)
+				netdev_warn(dev, "failed to reflect master unlinked (err %d)\n",
+					    err);
 			err = rocker_port_master_unlinked(rocker_port);
 			if (err)
 				netdev_warn(dev, "failed to reflect master unlinked (err %d)\n",
@@ -5225,6 +5681,7 @@ static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
 static int rocker_netevent_event(struct notifier_block *unused,
 				 unsigned long event, void *ptr)
 {
+	struct rocker_port *rocker_port;
 	struct net_device *dev;
 	struct neighbour *n = ptr;
 	int err;
@@ -5236,6 +5693,11 @@ static int rocker_netevent_event(struct notifier_block *unused,
 		dev = n->dev;
 		if (!rocker_port_dev_check(dev))
 			return NOTIFY_DONE;
+		rocker_port = netdev_priv(dev);
+		err = rocker_world_port_neigh_update(rocker_port, n);
+		if (err)
+			netdev_warn(dev, "failed to handle neigh update (err %d)\n",
+				    err);
 		err = rocker_neigh_update(dev, n);
 		if (err)
 			netdev_warn(dev,
-- 
1.9.3

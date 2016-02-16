From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/13] rocker: introduce worlds infrastructure
Date: Tue, 16 Feb 2016 13:55:32 +0100
Message-ID: <1455627338-9872-8-git-send-email-jiri@resnulli.us>
References: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, David.Laight@ACULAB.COM,
	john.fastabend@gmail.com, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, prem@barefootnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:33899 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932073AbcBPMzv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2016 07:55:51 -0500
Received: by mail-wm0-f45.google.com with SMTP id b205so108671957wmb.1
        for <netdev@vger.kernel.org>; Tue, 16 Feb 2016 04:55:50 -0800 (PST)
In-Reply-To: <1455627338-9872-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

This is another step on the way to per-world clean cut. Introduce world
ops hooks which each world can implement in world-specific way.
Also introduce world infrastructure along with OF-DPA world stub.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/Makefile       |   2 +-
 drivers/net/ethernet/rocker/rocker.h       |  69 +++++
 drivers/net/ethernet/rocker/rocker_main.c  | 450 ++++++++++++++++++++++++++++-
 drivers/net/ethernet/rocker/rocker_ofdpa.c |  27 ++
 4 files changed, 545 insertions(+), 3 deletions(-)
 create mode 100644 drivers/net/ethernet/rocker/rocker_ofdpa.c

diff --git a/drivers/net/ethernet/rocker/Makefile b/drivers/net/ethernet/rocker/Makefile
index 47f3492..faa36ac 100644
--- a/drivers/net/ethernet/rocker/Makefile
+++ b/drivers/net/ethernet/rocker/Makefile
@@ -3,4 +3,4 @@
 #
 
 obj-$(CONFIG_ROCKER) += rocker.o
-rocker-y := rocker_main.o rocker_tlv.o
+rocker-y := rocker_main.o rocker_tlv.o rocker_ofdpa.o
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 05c1e1a..5fd0e35 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -12,9 +12,13 @@
 #ifndef _ROCKER_H
 #define _ROCKER_H
 
+#include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/hashtable.h>
 #include <linux/if_vlan.h>
+#include <linux/netdevice.h>
+#include <net/neighbour.h>
+#include <net/switchdev.h>
 
 #include "rocker_hw.h"
 
@@ -57,6 +61,7 @@ struct rocker_port {
 	struct net_device *dev;
 	struct net_device *bridge_dev;
 	struct rocker *rocker;
+	void *wpriv;
 	unsigned int port_number;
 	u32 pport;
 	__be16 internal_vlan_id;
@@ -71,6 +76,8 @@ struct rocker_port {
 	struct rocker_dma_ring_info rx_ring;
 };
 
+struct rocker_world_ops;
+
 struct rocker {
 	struct pci_dev *pdev;
 	u8 __iomem *hw_addr;
@@ -83,6 +90,8 @@ struct rocker {
 	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
+	struct rocker_world_ops *wops;
+	void *wpriv;
 	DECLARE_HASHTABLE(flow_tbl, 16);
 	spinlock_t flow_tbl_lock;		/* for flow tbl accesses */
 	u64 flow_tbl_next_cookie;
@@ -99,4 +108,64 @@ struct rocker {
 	u32 neigh_tbl_next_index;
 };
 
+struct rocker_world_ops {
+	const char *kind;
+	size_t priv_size;
+	size_t port_priv_size;
+	u8 mode;
+	int (*init)(struct rocker *rocker);
+	void (*fini)(struct rocker *rocker);
+	int (*port_pre_init)(struct rocker_port *rocker_port);
+	int (*port_init)(struct rocker_port *rocker_port);
+	void (*port_fini)(struct rocker_port *rocker_port);
+	void (*port_post_fini)(struct rocker_port *rocker_port);
+	int (*port_open)(struct rocker_port *rocker_port);
+	void (*port_stop)(struct rocker_port *rocker_port);
+	int (*port_attr_stp_state_set)(struct rocker_port *rocker_port,
+				       u8 state,
+				       struct switchdev_trans *trans);
+	int (*port_attr_bridge_flags_set)(struct rocker_port *rocker_port,
+					  unsigned long brport_flags,
+					  struct switchdev_trans *trans);
+	int (*port_attr_bridge_flags_get)(const struct rocker_port *rocker_port,
+					  unsigned long *p_brport_flags);
+	int (*port_attr_bridge_ageing_time_set)(struct rocker_port *rocker_port,
+						u32 ageing_time,
+						struct switchdev_trans *trans);
+	int (*port_obj_vlan_add)(struct rocker_port *rocker_port,
+				 const struct switchdev_obj_port_vlan *vlan,
+				 struct switchdev_trans *trans);
+	int (*port_obj_vlan_del)(struct rocker_port *rocker_port,
+				 const struct switchdev_obj_port_vlan *vlan);
+	int (*port_obj_vlan_dump)(const struct rocker_port *rocker_port,
+				  struct switchdev_obj_port_vlan *vlan,
+				  switchdev_obj_dump_cb_t *cb);
+	int (*port_obj_fib4_add)(struct rocker_port *rocker_port,
+				 const struct switchdev_obj_ipv4_fib *fib4,
+				 struct switchdev_trans *trans);
+	int (*port_obj_fib4_del)(struct rocker_port *rocker_port,
+				 const struct switchdev_obj_ipv4_fib *fib4);
+	int (*port_obj_fdb_add)(struct rocker_port *rocker_port,
+				const struct switchdev_obj_port_fdb *fdb,
+				struct switchdev_trans *trans);
+	int (*port_obj_fdb_del)(struct rocker_port *rocker_port,
+				const struct switchdev_obj_port_fdb *fdb);
+	int (*port_obj_fdb_dump)(const struct rocker_port *rocker_port,
+				 struct switchdev_obj_port_fdb *fdb,
+				 switchdev_obj_dump_cb_t *cb);
+	int (*port_master_linked)(struct rocker_port *rocker_port,
+				  struct net_device *master);
+	int (*port_master_unlinked)(struct rocker_port *rocker_port,
+				    struct net_device *master);
+	int (*port_neigh_update)(struct rocker_port *rocker_port,
+				 struct neighbour *n);
+	int (*port_neigh_destroy)(struct rocker_port *rocker_port,
+				  struct neighbour *n);
+	int (*port_ev_mac_vlan_seen)(struct rocker_port *rocker_port,
+				     const unsigned char *addr,
+				     __be16 vlan_id);
+};
+
+extern struct rocker_world_ops rocker_ofdpa_ops;
+
 #endif
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index a67a6c7..871ccbe 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1164,6 +1164,9 @@ static int rocker_port_fdb(struct rocker_port *rocker_port,
 			   struct switchdev_trans *trans,
 			   const unsigned char *addr,
 			   __be16 vlan_id, int flags);
+static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
+					      const unsigned char *addr,
+					      __be16 vlan_id);
 
 static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 				      const struct rocker_tlv *info)
@@ -1174,6 +1177,7 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 	const unsigned char *addr;
 	int flags = ROCKER_OP_FLAG_NOWAIT | ROCKER_OP_FLAG_LEARNED;
 	__be16 vlan_id;
+	int err;
 
 	rocker_tlv_parse_nested(attrs, ROCKER_TLV_EVENT_MAC_VLAN_MAX, info);
 	if (!attrs[ROCKER_TLV_EVENT_MAC_VLAN_PPORT] ||
@@ -1190,6 +1194,10 @@ static int rocker_event_mac_vlan_seen(const struct rocker *rocker,
 
 	rocker_port = rocker->ports[port_number];
 
+	err = rocker_world_port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
+	if (err)
+		return err;
+
 	if (rocker_port->stp_state != BR_STATE_LEARNING &&
 	    rocker_port->stp_state != BR_STATE_FORWARDING)
 		return 0;
@@ -1651,6 +1659,335 @@ static int rocker_port_set_learning(struct rocker_port *rocker_port,
 			       NULL, NULL, NULL);
 }
 
+/**********************
+ * Worlds manipulation
+ **********************/
+
+static struct rocker_world_ops *rocker_world_ops[] = {
+	&rocker_ofdpa_ops,
+};
+
+#define ROCKER_WORLD_OPS_LEN ARRAY_SIZE(rocker_world_ops)
+
+static struct rocker_world_ops *rocker_world_ops_find(u8 mode)
+{
+	int i;
+
+	for (i = 0; i < ROCKER_WORLD_OPS_LEN; i++)
+		if (rocker_world_ops[i]->mode == mode)
+			return rocker_world_ops[i];
+	return NULL;
+}
+
+static int rocker_world_init(struct rocker *rocker, u8 mode)
+{
+	struct rocker_world_ops *wops;
+	int err;
+
+	wops = rocker_world_ops_find(mode);
+	if (!wops) {
+		dev_err(&rocker->pdev->dev, "port mode \"%d\" is not supported\n",
+			mode);
+		return -EINVAL;
+	}
+	rocker->wops = wops;
+	rocker->wpriv = kzalloc(wops->priv_size, GFP_KERNEL);
+	if (!rocker->wpriv)
+		return -ENOMEM;
+	if (!wops->init)
+		return 0;
+	err = wops->init(rocker);
+	if (err)
+		kfree(rocker->wpriv);
+	return err;
+}
+
+static void rocker_world_fini(struct rocker *rocker)
+{
+	struct rocker_world_ops *wops = rocker->wops;
+
+	if (!wops || !wops->fini)
+		return;
+	wops->fini(rocker);
+	kfree(rocker->wpriv);
+}
+
+static int rocker_world_check_init(struct rocker_port *rocker_port)
+{
+	struct rocker *rocker = rocker_port->rocker;
+	u8 mode;
+	int err;
+
+	err = rocker_cmd_get_port_settings_mode(rocker_port, &mode);
+	if (err) {
+		dev_err(&rocker->pdev->dev, "failed to get port mode\n");
+		return err;
+	}
+	if (rocker->wops) {
+		if (rocker->wops->mode != mode) {
+			dev_err(&rocker->pdev->dev, "hardware has ports in different worlds, which is not supported\n");
+			return err;
+		}
+		return 0;
+	}
+	return rocker_world_init(rocker, mode);
+}
+
+static int rocker_world_port_pre_init(struct rocker_port *rocker_port)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+	int err;
+
+	rocker_port->wpriv = kzalloc(wops->port_priv_size, GFP_KERNEL);
+	if (!rocker_port->wpriv)
+		return -ENOMEM;
+	if (!wops->port_pre_init)
+		return 0;
+	err = wops->port_pre_init(rocker_port);
+	if (err)
+		kfree(rocker_port->wpriv);
+	return 0;
+}
+
+static int rocker_world_port_init(struct rocker_port *rocker_port)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_init)
+		return 0;
+	return wops->port_init(rocker_port);
+}
+
+static void rocker_world_port_fini(struct rocker_port *rocker_port)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_fini)
+		return;
+	wops->port_fini(rocker_port);
+}
+
+static void rocker_world_port_post_fini(struct rocker_port *rocker_port)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_post_fini)
+		return;
+	wops->port_post_fini(rocker_port);
+	kfree(rocker_port->wpriv);
+}
+
+static int rocker_world_port_open(struct rocker_port *rocker_port)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_open)
+		return 0;
+	return wops->port_open(rocker_port);
+}
+
+static void rocker_world_port_stop(struct rocker_port *rocker_port)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_stop)
+		return;
+	wops->port_stop(rocker_port);
+}
+
+static int rocker_world_port_attr_stp_state_set(struct rocker_port *rocker_port,
+						u8 state,
+						struct switchdev_trans *trans)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_attr_stp_state_set)
+		return 0;
+	return wops->port_attr_stp_state_set(rocker_port, state, trans);
+}
+
+static int
+rocker_world_port_attr_bridge_flags_set(struct rocker_port *rocker_port,
+					unsigned long brport_flags,
+					struct switchdev_trans *trans)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_attr_bridge_flags_set)
+		return 0;
+	return wops->port_attr_bridge_flags_set(rocker_port, brport_flags,
+						trans);
+}
+
+static int
+rocker_world_port_attr_bridge_flags_get(const struct rocker_port *rocker_port,
+					unsigned long *p_brport_flags)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_attr_bridge_flags_get)
+		return 0;
+	return wops->port_attr_bridge_flags_get(rocker_port, p_brport_flags);
+}
+
+static int
+rocker_world_port_attr_bridge_ageing_time_set(struct rocker_port *rocker_port,
+					      u32 ageing_time,
+					      struct switchdev_trans *trans)
+
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_attr_bridge_ageing_time_set)
+		return 0;
+	return wops->port_attr_bridge_ageing_time_set(rocker_port, ageing_time,
+						      trans);
+}
+
+static int
+rocker_world_port_obj_vlan_add(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_port_vlan *vlan,
+			       struct switchdev_trans *trans)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_vlan_add)
+		return 0;
+	return wops->port_obj_vlan_add(rocker_port, vlan, trans);
+}
+
+static int
+rocker_world_port_obj_vlan_del(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_port_vlan *vlan)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_vlan_del)
+		return 0;
+	return wops->port_obj_vlan_del(rocker_port, vlan);
+}
+
+static int
+rocker_world_port_obj_vlan_dump(const struct rocker_port *rocker_port,
+				struct switchdev_obj_port_vlan *vlan,
+				switchdev_obj_dump_cb_t *cb)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_vlan_dump)
+		return 0;
+	return wops->port_obj_vlan_dump(rocker_port, vlan, cb);
+}
+
+static int
+rocker_world_port_obj_fib4_add(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_ipv4_fib *fib4,
+			       struct switchdev_trans *trans)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_fib4_add)
+		return 0;
+	return wops->port_obj_fib4_add(rocker_port, fib4, trans);
+}
+
+static int
+rocker_world_port_obj_fib4_del(struct rocker_port *rocker_port,
+			       const struct switchdev_obj_ipv4_fib *fib4)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_fib4_del)
+		return 0;
+	return wops->port_obj_fib4_del(rocker_port, fib4);
+}
+
+static int
+rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
+			      const struct switchdev_obj_port_fdb *fdb,
+			      struct switchdev_trans *trans)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_fdb_add)
+		return 0;
+	return wops->port_obj_fdb_add(rocker_port, fdb, trans);
+}
+
+static int
+rocker_world_port_obj_fdb_del(struct rocker_port *rocker_port,
+			      const struct switchdev_obj_port_fdb *fdb)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_fdb_del)
+		return 0;
+	return wops->port_obj_fdb_del(rocker_port, fdb);
+}
+
+static int
+rocker_world_port_obj_fdb_dump(const struct rocker_port *rocker_port,
+			       struct switchdev_obj_port_fdb *fdb,
+			       switchdev_obj_dump_cb_t *cb)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_obj_fdb_dump)
+		return 0;
+	return wops->port_obj_fdb_dump(rocker_port, fdb, cb);
+}
+
+static int rocker_world_port_master_linked(struct rocker_port *rocker_port,
+					   struct net_device *master)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_master_linked)
+		return 0;
+	return wops->port_master_linked(rocker_port, master);
+}
+
+static int rocker_world_port_master_unlinked(struct rocker_port *rocker_port,
+					     struct net_device *master)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_master_unlinked)
+		return 0;
+	return wops->port_master_unlinked(rocker_port, master);
+}
+
+static int rocker_world_port_neigh_update(struct rocker_port *rocker_port,
+					  struct neighbour *n)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_neigh_update)
+		return 0;
+	return wops->port_neigh_update(rocker_port, n);
+}
+
+static int rocker_world_port_neigh_destroy(struct rocker_port *rocker_port,
+					   struct neighbour *n)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_neigh_destroy)
+		return 0;
+	return wops->port_neigh_destroy(rocker_port, n);
+}
+
+static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
+					      const unsigned char *addr,
+					      __be16 vlan_id)
+{
+	struct rocker_world_ops *wops = rocker_port->rocker->wops;
+
+	if (!wops->port_ev_mac_vlan_seen)
+		return 0;
+	return wops->port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
+}
+
 static int
 rocker_cmd_flow_tbl_add_ig_port(struct rocker_desc_info *desc_info,
 				const struct rocker_flow_tbl_entry *entry)
@@ -3799,6 +4136,12 @@ static int rocker_port_open(struct net_device *dev)
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
@@ -3811,6 +4154,7 @@ static int rocker_port_open(struct net_device *dev)
 	return 0;
 
 err_fwd_enable:
+err_world_port_open:
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
 err_request_rx_irq:
 	free_irq(rocker_msix_tx_vector(rocker_port), rocker_port);
@@ -3827,6 +4171,7 @@ static int rocker_port_stop(struct net_device *dev)
 	rocker_port_set_enable(rocker_port, false);
 	napi_disable(&rocker_port->napi_rx);
 	napi_disable(&rocker_port->napi_tx);
+	rocker_world_port_stop(rocker_port);
 	rocker_port_fwd_disable(rocker_port, NULL,
 				ROCKER_OP_FLAG_NOWAIT);
 	free_irq(rocker_msix_rx_vector(rocker_port), rocker_port);
@@ -4037,9 +4382,14 @@ static void rocker_port_neigh_destroy(struct neighbour *n)
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
@@ -4068,6 +4418,7 @@ static int rocker_port_attr_get(struct net_device *dev,
 {
 	const struct rocker_port *rocker_port = netdev_priv(dev);
 	const struct rocker *rocker = rocker_port->rocker;
+	int err = 0;
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID:
@@ -4076,12 +4427,14 @@ static int rocker_port_attr_get(struct net_device *dev,
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
@@ -4125,14 +4478,29 @@ static int rocker_port_attr_set(struct net_device *dev,
 	case SWITCHDEV_ATTR_ID_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, trans, 0,
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
 	case SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME:
 		err = rocker_port_bridge_ageing_time(rocker_port, trans,
 						     attr->u.ageing_time);
+		if (err)
+			break;
+		err = rocker_world_port_attr_bridge_ageing_time_set(rocker_port,
+								    attr->u.ageing_time,
+								    trans);
 		break;
 	default:
 		err = -EOPNOTSUPP;
@@ -4204,16 +4572,31 @@ static int rocker_port_obj_add(struct net_device *dev,
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
 					   &fib4->fi, fib4->tb_id, 0);
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
@@ -4276,6 +4659,10 @@ static int rocker_port_obj_del(struct net_device *dev,
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
@@ -4283,10 +4670,18 @@ static int rocker_port_obj_del(struct net_device *dev,
 					   htonl(fib4->dst), fib4->dst_len,
 					   &fib4->fi, fib4->tb_id,
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
@@ -4358,10 +4753,20 @@ static int rocker_port_obj_dump(struct net_device *dev,
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
@@ -4687,7 +5092,7 @@ static void rocker_carrier_init(const struct rocker_port *rocker_port)
 		netif_carrier_off(rocker_port->dev);
 }
 
-static void rocker_remove_ports(const struct rocker *rocker)
+static void rocker_remove_ports(struct rocker *rocker)
 {
 	struct rocker_port *rocker_port;
 	int i;
@@ -4697,9 +5102,12 @@ static void rocker_remove_ports(const struct rocker *rocker)
 		if (!rocker_port)
 			continue;
 		rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
+		rocker_world_port_fini(rocker_port);
 		unregister_netdev(rocker_port->dev);
+		rocker_world_port_post_fini(rocker_port);
 		free_netdev(rocker_port->dev);
 	}
+	rocker_world_fini(rocker);
 	kfree(rocker->ports);
 }
 
@@ -4736,6 +5144,12 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port->brport_flags = BR_LEARNING | BR_LEARNING_SYNC;
 	rocker_port->ageing_time = BR_DEFAULT_AGEING_TIME;
 
+	err = rocker_world_check_init(rocker_port);
+	if (err) {
+		dev_err(&pdev->dev, "world init failed\n");
+		goto err_world_check_init;
+	}
+
 	rocker_port_dev_addr_init(rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
 	dev->ethtool_ops = &rocker_port_ethtool_ops;
@@ -4748,6 +5162,11 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 
 	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_SG;
 
+	err = rocker_world_port_pre_init(rocker_port);
+	if (err) {
+		dev_err(&pdev->dev, "port world pre-init failed\n");
+		goto err_world_port_pre_init;
+	}
 	err = register_netdev(dev);
 	if (err) {
 		dev_err(&pdev->dev, "register_netdev failed\n");
@@ -4755,6 +5174,12 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	}
 	rocker->ports[port_number] = rocker_port;
 
+	err = rocker_world_port_init(rocker_port);
+	if (err) {
+		dev_err(&pdev->dev, "port world init failed\n");
+		goto err_world_port_init;
+	}
+
 	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
 
 	rocker_port_set_learning(rocker_port, NULL);
@@ -4779,9 +5204,14 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 err_untagged_vlan:
 	rocker_port_ig_tbl(rocker_port, NULL, ROCKER_OP_FLAG_REMOVE);
 err_port_ig_tbl:
+	rocker_world_port_fini(rocker_port);
+err_world_port_init:
 	rocker->ports[port_number] = NULL;
 	unregister_netdev(dev);
 err_register_netdev:
+	rocker_world_port_post_fini(rocker_port);
+err_world_port_pre_init:
+err_world_check_init:
 	free_netdev(dev);
 	return err;
 }
@@ -5132,12 +5562,22 @@ static int rocker_netdevice_event(struct notifier_block *unused,
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
@@ -5170,6 +5610,7 @@ static int rocker_neigh_update(struct net_device *dev, struct neighbour *n)
 static int rocker_netevent_event(struct notifier_block *unused,
 				 unsigned long event, void *ptr)
 {
+	struct rocker_port *rocker_port;
 	struct net_device *dev;
 	struct neighbour *n = ptr;
 	int err;
@@ -5181,6 +5622,11 @@ static int rocker_netevent_event(struct notifier_block *unused,
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
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
new file mode 100644
index 0000000..155dc53
--- /dev/null
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -0,0 +1,27 @@
+/*
+ * drivers/net/ethernet/rocker/rocker_ofdpa.c - Rocker switch OF-DPA-like
+ *					        implementation
+ * Copyright (c) 2014 Scott Feldman <sfeldma@gmail.com>
+ * Copyright (c) 2014-2016 Jiri Pirko <jiri@mellanox.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ */
+
+#include <linux/kernel.h>
+#include "rocker.h"
+
+struct ofdpa {
+};
+
+struct ofdpa_port {
+};
+
+struct rocker_world_ops rocker_ofdpa_ops = {
+	.kind = "ofdpa",
+	.priv_size = sizeof(struct ofdpa),
+	.port_priv_size = sizeof(struct ofdpa_port),
+	.mode = ROCKER_PORT_MODE_OF_DPA,
+};
-- 
1.9.3

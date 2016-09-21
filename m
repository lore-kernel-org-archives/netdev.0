From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 4/6] rocker: use FIB notifications instead of switchdev calls
Date: Wed, 21 Sep 2016 13:53:12 +0200
Message-ID: <1474458794-5512-5-git-send-email-jiri@resnulli.us>
References: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
        roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        linville@tuxdriver.com, andy@greyhouse.net, f.fainelli@gmail.com,
        dsa@cumulusnetworks.com, jhs@mojatatu.com,
        vivien.didelot@savoirfairelinux.com, andrew@lunn.ch,
        ivecera@redhat.com, kaber@trash.net, john@phrozen.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33338 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933723AbcIULxZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 07:53:25 -0400
Received: by mail-wm0-f67.google.com with SMTP id w84so8155758wmg.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 04:53:24 -0700 (PDT)
In-Reply-To: <1474458794-5512-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Until now, in order to offload a FIB entry to HW we use switchdev op.
Use the newly introduced FIB notifier infrasturucture to process
FIB entries to offload the in HW.
Abort mechanism is now handled within the rocker driver.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker.h       |  15 ++--
 drivers/net/ethernet/rocker/rocker_main.c  | 120 +++++++++++++++++++++--------
 drivers/net/ethernet/rocker/rocker_ofdpa.c | 115 ++++++++++++++++++++-------
 3 files changed, 185 insertions(+), 65 deletions(-)

diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 1ab995f..2eb9b49 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #include <linux/types.h>
 #include <linux/netdevice.h>
+#include <linux/notifier.h>
 #include <net/neighbour.h>
 #include <net/switchdev.h>
 
@@ -52,6 +53,9 @@ struct rocker_port {
 	struct rocker_dma_ring_info rx_ring;
 };
 
+struct rocker_port *rocker_port_dev_lower_find(struct net_device *dev,
+					       struct rocker *rocker);
+
 struct rocker_world_ops;
 
 struct rocker {
@@ -66,6 +70,7 @@ struct rocker {
 	spinlock_t cmd_ring_lock;		/* for cmd ring accesses */
 	struct rocker_dma_ring_info cmd_ring;
 	struct rocker_dma_ring_info event_ring;
+	struct notifier_block fib_nb;
 	struct rocker_world_ops *wops;
 	void *wpriv;
 };
@@ -117,11 +122,6 @@ struct rocker_world_ops {
 	int (*port_obj_vlan_dump)(const struct rocker_port *rocker_port,
 				  struct switchdev_obj_port_vlan *vlan,
 				  switchdev_obj_dump_cb_t *cb);
-	int (*port_obj_fib4_add)(struct rocker_port *rocker_port,
-				 const struct switchdev_obj_ipv4_fib *fib4,
-				 struct switchdev_trans *trans);
-	int (*port_obj_fib4_del)(struct rocker_port *rocker_port,
-				 const struct switchdev_obj_ipv4_fib *fib4);
 	int (*port_obj_fdb_add)(struct rocker_port *rocker_port,
 				const struct switchdev_obj_port_fdb *fdb,
 				struct switchdev_trans *trans);
@@ -141,6 +141,11 @@ struct rocker_world_ops {
 	int (*port_ev_mac_vlan_seen)(struct rocker_port *rocker_port,
 				     const unsigned char *addr,
 				     __be16 vlan_id);
+	int (*fib4_add)(struct rocker *rocker,
+			const struct fib_entry_notifier_info *fen_info);
+	int (*fib4_del)(struct rocker *rocker,
+			const struct fib_entry_notifier_info *fen_info);
+	void (*fib4_abort)(struct rocker *rocker);
 };
 
 extern struct rocker_world_ops rocker_ofdpa_ops;
diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 1f0c086..5424fb3 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -1625,29 +1625,6 @@ rocker_world_port_obj_vlan_dump(const struct rocker_port *rocker_port,
 }
 
 static int
-rocker_world_port_obj_fib4_add(struct rocker_port *rocker_port,
-			       const struct switchdev_obj_ipv4_fib *fib4,
-			       struct switchdev_trans *trans)
-{
-	struct rocker_world_ops *wops = rocker_port->rocker->wops;
-
-	if (!wops->port_obj_fib4_add)
-		return -EOPNOTSUPP;
-	return wops->port_obj_fib4_add(rocker_port, fib4, trans);
-}
-
-static int
-rocker_world_port_obj_fib4_del(struct rocker_port *rocker_port,
-			       const struct switchdev_obj_ipv4_fib *fib4)
-{
-	struct rocker_world_ops *wops = rocker_port->rocker->wops;
-
-	if (!wops->port_obj_fib4_del)
-		return -EOPNOTSUPP;
-	return wops->port_obj_fib4_del(rocker_port, fib4);
-}
-
-static int
 rocker_world_port_obj_fdb_add(struct rocker_port *rocker_port,
 			      const struct switchdev_obj_port_fdb *fdb,
 			      struct switchdev_trans *trans)
@@ -1733,6 +1710,34 @@ static int rocker_world_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
 	return wops->port_ev_mac_vlan_seen(rocker_port, addr, vlan_id);
 }
 
+static int rocker_world_fib4_add(struct rocker *rocker,
+				 const struct fib_entry_notifier_info *fen_info)
+{
+	struct rocker_world_ops *wops = rocker->wops;
+
+	if (!wops->fib4_add)
+		return 0;
+	return wops->fib4_add(rocker, fen_info);
+}
+
+static int rocker_world_fib4_del(struct rocker *rocker,
+				 const struct fib_entry_notifier_info *fen_info)
+{
+	struct rocker_world_ops *wops = rocker->wops;
+
+	if (!wops->fib4_del)
+		return 0;
+	return wops->fib4_del(rocker, fen_info);
+}
+
+static void rocker_world_fib4_abort(struct rocker *rocker)
+{
+	struct rocker_world_ops *wops = rocker->wops;
+
+	if (wops->fib4_abort)
+		wops->fib4_abort(rocker);
+}
+
 /*****************
  * Net device ops
  *****************/
@@ -2096,11 +2101,6 @@ static int rocker_port_obj_add(struct net_device *dev,
 						     SWITCHDEV_OBJ_PORT_VLAN(obj),
 						     trans);
 		break;
-	case SWITCHDEV_OBJ_ID_IPV4_FIB:
-		err = rocker_world_port_obj_fib4_add(rocker_port,
-						     SWITCHDEV_OBJ_IPV4_FIB(obj),
-						     trans);
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_world_port_obj_fdb_add(rocker_port,
 						    SWITCHDEV_OBJ_PORT_FDB(obj),
@@ -2125,10 +2125,6 @@ static int rocker_port_obj_del(struct net_device *dev,
 		err = rocker_world_port_obj_vlan_del(rocker_port,
 						     SWITCHDEV_OBJ_PORT_VLAN(obj));
 		break;
-	case SWITCHDEV_OBJ_ID_IPV4_FIB:
-		err = rocker_world_port_obj_fib4_del(rocker_port,
-						     SWITCHDEV_OBJ_IPV4_FIB(obj));
-		break;
 	case SWITCHDEV_OBJ_ID_PORT_FDB:
 		err = rocker_world_port_obj_fdb_del(rocker_port,
 						    SWITCHDEV_OBJ_PORT_FDB(obj));
@@ -2175,6 +2171,31 @@ static const struct switchdev_ops rocker_port_switchdev_ops = {
 	.switchdev_port_obj_dump	= rocker_port_obj_dump,
 };
 
+static int rocker_router_fib_event(struct notifier_block *nb,
+				   unsigned long event, void *ptr)
+{
+	struct rocker *rocker = container_of(nb, struct rocker, fib_nb);
+	struct fib_entry_notifier_info *fen_info = ptr;
+	int err;
+
+	switch (event) {
+	case FIB_EVENT_ENTRY_ADD:
+		err = rocker_world_fib4_add(rocker, fen_info);
+		if (err)
+			rocker_world_fib4_abort(rocker);
+		else
+		break;
+	case FIB_EVENT_ENTRY_DEL:
+		rocker_world_fib4_del(rocker, fen_info);
+		break;
+	case FIB_EVENT_RULE_ADD: /* fall through */
+	case FIB_EVENT_RULE_DEL:
+		rocker_world_fib4_abort(rocker);
+		break;
+	}
+	return NOTIFY_DONE;
+}
+
 /********************
  * ethtool interface
  ********************/
@@ -2740,6 +2761,9 @@ static int rocker_probe(struct pci_dev *pdev, const struct pci_device_id *id)
 		goto err_probe_ports;
 	}
 
+	rocker->fib_nb.notifier_call = rocker_router_fib_event;
+	register_fib_notifier(&rocker->fib_nb);
+
 	dev_info(&pdev->dev, "Rocker switch with id %*phN\n",
 		 (int)sizeof(rocker->hw.id), &rocker->hw.id);
 
@@ -2771,6 +2795,7 @@ static void rocker_remove(struct pci_dev *pdev)
 {
 	struct rocker *rocker = pci_get_drvdata(pdev);
 
+	unregister_fib_notifier(&rocker->fib_nb);
 	rocker_write32(rocker, CONTROL, ROCKER_CONTROL_RESET);
 	rocker_remove_ports(rocker);
 	free_irq(rocker_msix_vector(rocker, ROCKER_MSIX_VEC_EVENT), rocker);
@@ -2799,6 +2824,37 @@ static bool rocker_port_dev_check(const struct net_device *dev)
 	return dev->netdev_ops == &rocker_port_netdev_ops;
 }
 
+static bool rocker_port_dev_check_under(const struct net_device *dev,
+					struct rocker *rocker)
+{
+	struct rocker_port *rocker_port;
+
+	if (!rocker_port_dev_check(dev))
+		return false;
+
+	rocker_port = netdev_priv(dev);
+	if (rocker_port->rocker != rocker)
+		return false;
+
+	return true;
+}
+
+struct rocker_port *rocker_port_dev_lower_find(struct net_device *dev,
+					       struct rocker *rocker)
+{
+	struct net_device *lower_dev;
+	struct list_head *iter;
+
+	if (rocker_port_dev_check_under(dev, rocker))
+		return netdev_priv(dev);
+
+	netdev_for_each_all_lower_dev(dev, lower_dev, iter) {
+		if (rocker_port_dev_check_under(lower_dev, rocker))
+			return netdev_priv(lower_dev);
+	}
+	return NULL;
+}
+
 static int rocker_netdevice_event(struct notifier_block *unused,
 				  unsigned long event, void *ptr)
 {
diff --git a/drivers/net/ethernet/rocker/rocker_ofdpa.c b/drivers/net/ethernet/rocker/rocker_ofdpa.c
index fcad907..431a608 100644
--- a/drivers/net/ethernet/rocker/rocker_ofdpa.c
+++ b/drivers/net/ethernet/rocker/rocker_ofdpa.c
@@ -99,6 +99,7 @@ struct ofdpa_flow_tbl_entry {
 	struct ofdpa_flow_tbl_key key;
 	size_t key_len;
 	u32 key_crc32; /* key */
+	struct fib_info *fi;
 };
 
 struct ofdpa_group_tbl_entry {
@@ -189,6 +190,7 @@ struct ofdpa {
 	spinlock_t neigh_tbl_lock;		/* for neigh tbl accesses */
 	u32 neigh_tbl_next_index;
 	unsigned long ageing_time;
+	bool fib_aborted;
 };
 
 struct ofdpa_port {
@@ -1043,7 +1045,8 @@ static int ofdpa_flow_tbl_ucast4_routing(struct ofdpa_port *ofdpa_port,
 					 __be16 eth_type, __be32 dst,
 					 __be32 dst_mask, u32 priority,
 					 enum rocker_of_dpa_table_id goto_tbl,
-					 u32 group_id, int flags)
+					 u32 group_id, struct fib_info *fi,
+					 int flags)
 {
 	struct ofdpa_flow_tbl_entry *entry;
 
@@ -1060,6 +1063,7 @@ static int ofdpa_flow_tbl_ucast4_routing(struct ofdpa_port *ofdpa_port,
 	entry->key.ucast_routing.group_id = group_id;
 	entry->key_len = offsetof(struct ofdpa_flow_tbl_key,
 				  ucast_routing.group_id);
+	entry->fi = fi;
 
 	return ofdpa_flow_tbl_do(ofdpa_port, trans, flags, entry);
 }
@@ -1425,7 +1429,7 @@ static int ofdpa_port_ipv4_neigh(struct ofdpa_port *ofdpa_port,
 						    eth_type, ip_addr,
 						    inet_make_mask(32),
 						    priority, goto_tbl,
-						    group_id, flags);
+						    group_id, NULL, flags);
 
 		if (err)
 			netdev_err(ofdpa_port->dev, "Error (%d) /32 unicast route %pI4 group 0x%08x\n",
@@ -2390,7 +2394,7 @@ found:
 
 static int ofdpa_port_fib_ipv4(struct ofdpa_port *ofdpa_port,
 			       struct switchdev_trans *trans, __be32 dst,
-			       int dst_len, const struct fib_info *fi,
+			       int dst_len, struct fib_info *fi,
 			       u32 tb_id, int flags)
 {
 	const struct fib_nh *nh;
@@ -2426,7 +2430,7 @@ static int ofdpa_port_fib_ipv4(struct ofdpa_port *ofdpa_port,
 
 	err = ofdpa_flow_tbl_ucast4_routing(ofdpa_port, trans, eth_type, dst,
 					    dst_mask, priority, goto_tbl,
-					    group_id, flags);
+					    group_id, fi, flags);
 	if (err)
 		netdev_err(ofdpa_port->dev, "Error (%d) IPv4 route %pI4\n",
 			   err, &dst);
@@ -2718,28 +2722,6 @@ static int ofdpa_port_obj_vlan_dump(const struct rocker_port *rocker_port,
 	return err;
 }
 
-static int ofdpa_port_obj_fib4_add(struct rocker_port *rocker_port,
-				   const struct switchdev_obj_ipv4_fib *fib4,
-				   struct switchdev_trans *trans)
-{
-	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
-
-	return ofdpa_port_fib_ipv4(ofdpa_port, trans,
-				   htonl(fib4->dst), fib4->dst_len,
-				   fib4->fi, fib4->tb_id, 0);
-}
-
-static int ofdpa_port_obj_fib4_del(struct rocker_port *rocker_port,
-				   const struct switchdev_obj_ipv4_fib *fib4)
-{
-	struct ofdpa_port *ofdpa_port = rocker_port->wpriv;
-
-	return ofdpa_port_fib_ipv4(ofdpa_port, NULL,
-				   htonl(fib4->dst), fib4->dst_len,
-				   fib4->fi, fib4->tb_id,
-				   OFDPA_OP_FLAG_REMOVE);
-}
-
 static int ofdpa_port_obj_fdb_add(struct rocker_port *rocker_port,
 				  const struct switchdev_obj_port_fdb *fdb,
 				  struct switchdev_trans *trans)
@@ -2922,6 +2904,82 @@ static int ofdpa_port_ev_mac_vlan_seen(struct rocker_port *rocker_port,
 	return ofdpa_port_fdb(ofdpa_port, NULL, addr, vlan_id, flags);
 }
 
+static struct ofdpa_port *ofdpa_port_dev_lower_find(struct net_device *dev,
+						    struct rocker *rocker)
+{
+	struct rocker_port *rocker_port;
+
+	rocker_port = rocker_port_dev_lower_find(dev, rocker);
+	return rocker_port ? rocker_port->wpriv : NULL;
+}
+
+static int ofdpa_fib4_add(struct rocker *rocker,
+			  const struct fib_entry_notifier_info *fen_info)
+{
+	struct ofdpa *ofdpa = rocker->wpriv;
+	struct ofdpa_port *ofdpa_port;
+	int err;
+
+	if (ofdpa->fib_aborted)
+		return 0;
+	ofdpa_port = ofdpa_port_dev_lower_find(fen_info->fi->fib_dev, rocker);
+	if (!ofdpa_port)
+		return 0;
+	err = ofdpa_port_fib_ipv4(ofdpa_port, NULL, htonl(fen_info->dst),
+				  fen_info->dst_len, fen_info->fi,
+				  fen_info->tb_id, 0);
+	if (err)
+		return err;
+	fib_info_offload_inc(fen_info->fi);
+	return 0;
+}
+
+static int ofdpa_fib4_del(struct rocker *rocker,
+			  const struct fib_entry_notifier_info *fen_info)
+{
+	struct ofdpa *ofdpa = rocker->wpriv;
+	struct ofdpa_port *ofdpa_port;
+
+	if (ofdpa->fib_aborted)
+		return 0;
+	ofdpa_port = ofdpa_port_dev_lower_find(fen_info->fi->fib_dev, rocker);
+	if (!ofdpa_port)
+		return 0;
+	fib_info_offload_dec(fen_info->fi);
+	return ofdpa_port_fib_ipv4(ofdpa_port, NULL, htonl(fen_info->dst),
+				   fen_info->dst_len, fen_info->fi,
+				   fen_info->tb_id, OFDPA_OP_FLAG_REMOVE);
+}
+
+static void ofdpa_fib4_abort(struct rocker *rocker)
+{
+	struct ofdpa *ofdpa = rocker->wpriv;
+	struct ofdpa_port *ofdpa_port;
+	struct ofdpa_flow_tbl_entry *flow_entry;
+	struct hlist_node *tmp;
+	unsigned long flags;
+	int bkt;
+
+	if (ofdpa->fib_aborted)
+		return;
+
+	spin_lock_irqsave(&ofdpa->flow_tbl_lock, flags);
+	hash_for_each_safe(ofdpa->flow_tbl, bkt, tmp, flow_entry, entry) {
+		if (flow_entry->key.tbl_id !=
+		    ROCKER_OF_DPA_TABLE_ID_UNICAST_ROUTING)
+			continue;
+		ofdpa_port = ofdpa_port_dev_lower_find(flow_entry->fi->fib_dev,
+						       rocker);
+		if (!ofdpa_port)
+			continue;
+		fib_info_offload_dec(flow_entry->fi);
+		ofdpa_flow_tbl_del(ofdpa_port, NULL, OFDPA_OP_FLAG_REMOVE,
+				   flow_entry);
+	}
+	spin_unlock_irqrestore(&ofdpa->flow_tbl_lock, flags);
+	ofdpa->fib_aborted = true;
+}
+
 struct rocker_world_ops rocker_ofdpa_ops = {
 	.kind = "ofdpa",
 	.priv_size = sizeof(struct ofdpa),
@@ -2941,8 +2999,6 @@ struct rocker_world_ops rocker_ofdpa_ops = {
 	.port_obj_vlan_add = ofdpa_port_obj_vlan_add,
 	.port_obj_vlan_del = ofdpa_port_obj_vlan_del,
 	.port_obj_vlan_dump = ofdpa_port_obj_vlan_dump,
-	.port_obj_fib4_add = ofdpa_port_obj_fib4_add,
-	.port_obj_fib4_del = ofdpa_port_obj_fib4_del,
 	.port_obj_fdb_add = ofdpa_port_obj_fdb_add,
 	.port_obj_fdb_del = ofdpa_port_obj_fdb_del,
 	.port_obj_fdb_dump = ofdpa_port_obj_fdb_dump,
@@ -2951,4 +3007,7 @@ struct rocker_world_ops rocker_ofdpa_ops = {
 	.port_neigh_update = ofdpa_port_neigh_update,
 	.port_neigh_destroy = ofdpa_port_neigh_destroy,
 	.port_ev_mac_vlan_seen = ofdpa_port_ev_mac_vlan_seen,
+	.fib4_add = ofdpa_fib4_add,
+	.fib4_del = ofdpa_fib4_del,
+	.fib4_abort = ofdpa_fib4_abort,
 };
-- 
2.5.5

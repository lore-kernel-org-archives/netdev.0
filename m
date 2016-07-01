From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 30/42] mlxsw: spectrum_router: Add private neigh table
Date: Fri,  1 Jul 2016 16:04:58 +0200
Message-ID: <1467381910-3445-31-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35478 "EHLO
	mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbcGAOY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:24:57 -0400
Received: by mail-wm0-f68.google.com with SMTP id a66so5683880wme.2
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:24:01 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

We need to hold some private data for every neigh entry. It would be
possible to do it using neigh_priv_len/ndo_neigh_construct/
ndo_neigh_destroy however only for the port device itself. That would not
work for stacked devices like bridge/team/bond. So introduce a private
neigh table. Hook onto ndos neigh_construct/destroy and add/remove
table entry according to that.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c     |   2 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   6 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 146 ++++++++++++++++++++-
 3 files changed, 153 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 7b2b741b..9bebb7a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -803,6 +803,8 @@ static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_get_stats64	= mlxsw_sp_port_get_stats64,
 	.ndo_vlan_rx_add_vid	= mlxsw_sp_port_add_vid,
 	.ndo_vlan_rx_kill_vid	= mlxsw_sp_port_kill_vid,
+	.ndo_neigh_construct	= mlxsw_sp_router_neigh_construct,
+	.ndo_neigh_destroy	= mlxsw_sp_router_neigh_destroy,
 	.ndo_fdb_add		= switchdev_port_fdb_add,
 	.ndo_fdb_del		= switchdev_port_fdb_del,
 	.ndo_fdb_dump		= switchdev_port_fdb_dump,
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 958e821..734c5ba 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -39,6 +39,7 @@
 
 #include <linux/types.h>
 #include <linux/netdevice.h>
+#include <linux/rhashtable.h>
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
 #include <linux/list.h>
@@ -212,6 +213,7 @@ struct mlxsw_sp_vr {
 struct mlxsw_sp_router {
 	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
 	struct mlxsw_sp_vr vrs[MLXSW_SP_VIRTUAL_ROUTER_MAX];
+	struct rhashtable neigh_ht;
 };
 
 struct mlxsw_sp {
@@ -524,5 +526,9 @@ int mlxsw_sp_router_fib4_add(struct mlxsw_sp_port *mlxsw_sp_port,
 			     struct switchdev_trans *trans);
 int mlxsw_sp_router_fib4_del(struct mlxsw_sp_port *mlxsw_sp_port,
 			     const struct switchdev_obj_ipv4_fib *fib4);
+int mlxsw_sp_router_neigh_construct(struct net_device *dev,
+				    struct neighbour *n);
+void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
+				   struct neighbour *n);
 
 #endif
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 7e3992a..90d382a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -38,6 +38,8 @@
 #include <linux/rhashtable.h>
 #include <linux/bitops.h>
 #include <linux/in6.h>
+#include <net/neighbour.h>
+#include <net/arp.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -544,6 +546,147 @@ static void mlxsw_sp_vrs_init(struct mlxsw_sp *mlxsw_sp)
 	}
 }
 
+struct mlxsw_sp_neigh_key {
+	unsigned char addr[sizeof(struct in6_addr)];
+	struct net_device *dev;
+};
+
+struct mlxsw_sp_neigh_entry {
+	struct rhash_head ht_node;
+	struct mlxsw_sp_neigh_key key;
+	u16 rif;
+	struct neighbour *n;
+};
+
+static const struct rhashtable_params mlxsw_sp_neigh_ht_params = {
+	.key_offset = offsetof(struct mlxsw_sp_neigh_entry, key),
+	.head_offset = offsetof(struct mlxsw_sp_neigh_entry, ht_node),
+	.key_len = sizeof(struct mlxsw_sp_neigh_key),
+};
+
+static int
+mlxsw_sp_neigh_entry_insert(struct mlxsw_sp *mlxsw_sp,
+			    struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	return rhashtable_insert_fast(&mlxsw_sp->router.neigh_ht,
+				      &neigh_entry->ht_node,
+				      mlxsw_sp_neigh_ht_params);
+}
+
+static void
+mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
+			    struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	rhashtable_remove_fast(&mlxsw_sp->router.neigh_ht,
+			       &neigh_entry->ht_node,
+			       mlxsw_sp_neigh_ht_params);
+}
+
+static struct mlxsw_sp_neigh_entry *
+mlxsw_sp_neigh_entry_create(const void *addr, size_t addr_len,
+			    struct net_device *dev, u16 rif,
+			    struct neighbour *n)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+
+	neigh_entry = kzalloc(sizeof(*neigh_entry), GFP_ATOMIC);
+	if (!neigh_entry)
+		return NULL;
+	memcpy(neigh_entry->key.addr, addr, addr_len);
+	neigh_entry->key.dev = dev;
+	neigh_entry->rif = rif;
+	neigh_entry->n = n;
+	return neigh_entry;
+}
+
+static void
+mlxsw_sp_neigh_entry_destroy(struct mlxsw_sp_neigh_entry *neigh_entry)
+{
+	kfree(neigh_entry);
+}
+
+static struct mlxsw_sp_neigh_entry *
+mlxsw_sp_neigh_entry_lookup(struct mlxsw_sp *mlxsw_sp, const void *addr,
+			    size_t addr_len, struct net_device *dev)
+{
+	struct mlxsw_sp_neigh_key key = {{ 0 } };
+
+	memcpy(key.addr, addr, addr_len);
+	key.dev = dev;
+	return rhashtable_lookup_fast(&mlxsw_sp->router.neigh_ht,
+				      &key, mlxsw_sp_neigh_ht_params);
+}
+
+int mlxsw_sp_router_neigh_construct(struct net_device *dev,
+				    struct neighbour *n)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+	struct mlxsw_sp_rif *r;
+	u32 dip;
+	int err;
+
+	if (n->tbl != &arp_tbl)
+		return 0;
+
+	dip = ntohl(*((__be32 *) n->primary_key));
+	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &dip, sizeof(dip),
+						  n->dev);
+	if (neigh_entry) {
+		WARN_ON(neigh_entry->n != n);
+		return 0;
+	}
+
+	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
+	if (WARN_ON(!r))
+		return -EINVAL;
+
+	neigh_entry = mlxsw_sp_neigh_entry_create(&dip, sizeof(dip), n->dev,
+						  r->rif, n);
+	if (!neigh_entry)
+		return -ENOMEM;
+	err = mlxsw_sp_neigh_entry_insert(mlxsw_sp, neigh_entry);
+	if (err)
+		goto err_neigh_entry_insert;
+	return 0;
+
+err_neigh_entry_insert:
+	mlxsw_sp_neigh_entry_destroy(neigh_entry);
+	return err;
+}
+
+void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
+				   struct neighbour *n)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_neigh_entry *neigh_entry;
+	u32 dip;
+
+	if (n->tbl != &arp_tbl)
+		return;
+
+	dip = ntohl(*((__be32 *) n->primary_key));
+	neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp, &dip, sizeof(dip),
+						  n->dev);
+	if (!neigh_entry)
+		return;
+	mlxsw_sp_neigh_entry_remove(mlxsw_sp, neigh_entry);
+	mlxsw_sp_neigh_entry_destroy(neigh_entry);
+}
+
+static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
+{
+	return rhashtable_init(&mlxsw_sp->router.neigh_ht,
+			       &mlxsw_sp_neigh_ht_params);
+}
+
+static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
+}
+
 static int __mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	char rgcr_pl[MLXSW_REG_RGCR_LEN];
@@ -570,11 +713,12 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 		return err;
 	mlxsw_sp_lpm_init(mlxsw_sp);
 	mlxsw_sp_vrs_init(mlxsw_sp);
-	return 0;
+	return mlxsw_sp_neigh_init(mlxsw_sp);
 }
 
 void mlxsw_sp_router_fini(struct mlxsw_sp *mlxsw_sp)
 {
+	mlxsw_sp_neigh_fini(mlxsw_sp);
 	__mlxsw_sp_router_fini(mlxsw_sp);
 }
 
-- 
2.5.5

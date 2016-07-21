From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 9/9] mlxsw: spectrum: Add support in matchall mirror TC offloading
Date: Thu, 21 Jul 2016 10:19:20 +0200
Message-ID: <1469089160-4239-10-git-send-email-jiri@resnulli.us>
References: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, eladr@mellanox.com,
	idosch@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	jhs@mojatatu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32987 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbcGUITh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:19:37 -0400
Received: by mail-wm0-f66.google.com with SMTP id o80so1650696wme.0
        for <netdev@vger.kernel.org>; Thu, 21 Jul 2016 01:19:36 -0700 (PDT)
In-Reply-To: <1469089160-4239-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

This patch offloads port mirroring directives to hw using the matchall TC
with action mirror. It includes both the implementation of the
ndo_setup_tc function for the spectrum driver and the spectrum hardware
offload configuration code.

The hardware offload code is basically two new functions which are capable
of adding and removing a new mirror ports pair. It is done using the MPAT,
MPAR and SBIB registers:
 - A new Switch-Port Analyzer (SPAN) entry is added using MPAT to the 'to'
   port.
 - The 'to' port is bound to the SPAN entry using MPAR register.
 - In case of egress SPAN, the 'to' port gets a new internal shared
   buffer using SBIB register.

In addition, a new database was added to the mlxsw_sp struct to store all
the SPAN entries and their bound ports list. The number of supported SPAN
entries is determined by resource query.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 465 ++++++++++++++++++++++++-
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  44 +++
 2 files changed, 507 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 417dbd7..2d88faf 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -54,6 +54,8 @@
 #include <linux/inetdevice.h>
 #include <net/switchdev.h>
 #include <generated/utsrelease.h>
+#include <net/pkt_cls.h>
+#include <net/tc_act/tc_mirred.h>
 
 #include "spectrum.h"
 #include "core.h"
@@ -133,6 +135,8 @@ MLXSW_ITEM32(tx, hdr, fid, 0x08, 0, 16);
  */
 MLXSW_ITEM32(tx, hdr, type, 0x0C, 0, 4);
 
+static bool mlxsw_sp_port_dev_check(const struct net_device *dev);
+
 static void mlxsw_sp_txhdr_construct(struct sk_buff *skb,
 				     const struct mlxsw_tx_info *tx_info)
 {
@@ -161,6 +165,303 @@ static int mlxsw_sp_base_mac_get(struct mlxsw_sp *mlxsw_sp)
 	return 0;
 }
 
+static int mlxsw_sp_span_init(struct mlxsw_sp *mlxsw_sp)
+{
+	struct mlxsw_resources *resources;
+	int i;
+
+	resources = mlxsw_core_resources_get(mlxsw_sp->core);
+	if (!resources->max_span_valid)
+		return -EIO;
+
+	mlxsw_sp->span.entries_count = resources->max_span;
+	mlxsw_sp->span.entries = kcalloc(mlxsw_sp->span.entries_count,
+					 sizeof(struct mlxsw_sp_span_entry),
+					 GFP_KERNEL);
+	if (!mlxsw_sp->span.entries)
+		return -ENOMEM;
+
+	for (i = 0; i < mlxsw_sp->span.entries_count; i++)
+		INIT_LIST_HEAD(&mlxsw_sp->span.entries[i].bound_ports_list);
+
+	return 0;
+}
+
+static void mlxsw_sp_span_fini(struct mlxsw_sp *mlxsw_sp)
+{
+	int i;
+
+	for (i = 0; i < mlxsw_sp->span.entries_count; i++) {
+		struct mlxsw_sp_span_entry *curr = &mlxsw_sp->span.entries[i];
+
+		WARN_ON_ONCE(!list_empty(&curr->bound_ports_list));
+	}
+	kfree(mlxsw_sp->span.entries);
+}
+
+static struct mlxsw_sp_span_entry *
+mlxsw_sp_span_entry_create(struct mlxsw_sp_port *port)
+{
+	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
+	struct mlxsw_sp_span_entry *span_entry;
+	char mpat_pl[MLXSW_REG_MPAT_LEN];
+	u8 local_port = port->local_port;
+	int index;
+	int i;
+	int err;
+
+	/* find a free entry to use */
+	index = -1;
+	for (i = 0; i < mlxsw_sp->span.entries_count; i++) {
+		if (!mlxsw_sp->span.entries[i].used) {
+			index = i;
+			span_entry = &mlxsw_sp->span.entries[i];
+			break;
+		}
+	}
+	if (index < 0)
+		return NULL;
+
+	/* create a new port analayzer entry for local_port */
+	mlxsw_reg_mpat_pack(mpat_pl, index, local_port, true);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mpat), mpat_pl);
+	if (err)
+		return NULL;
+
+	span_entry->used = true;
+	span_entry->id = index;
+	span_entry->ref_count = 0;
+	span_entry->local_port = local_port;
+	return span_entry;
+}
+
+static void mlxsw_sp_span_entry_destroy(struct mlxsw_sp *mlxsw_sp,
+					struct mlxsw_sp_span_entry *span_entry)
+{
+	u8 local_port = span_entry->local_port;
+	char mpat_pl[MLXSW_REG_MPAT_LEN];
+	int pa_id = span_entry->id;
+
+	mlxsw_reg_mpat_pack(mpat_pl, pa_id, local_port, false);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mpat), mpat_pl);
+	span_entry->used = false;
+}
+
+struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_find(struct mlxsw_sp_port *port)
+{
+	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
+	int i;
+
+	for (i = 0; i < mlxsw_sp->span.entries_count; i++) {
+		struct mlxsw_sp_span_entry *curr = &mlxsw_sp->span.entries[i];
+
+		if (curr->used && curr->local_port == port->local_port)
+			return curr;
+	}
+	return NULL;
+}
+
+struct mlxsw_sp_span_entry *mlxsw_sp_span_entry_get(struct mlxsw_sp_port *port)
+{
+	struct mlxsw_sp_span_entry *span_entry;
+
+	span_entry = mlxsw_sp_span_entry_find(port);
+	if (span_entry) {
+		span_entry->ref_count++;
+		return span_entry;
+	}
+
+	return mlxsw_sp_span_entry_create(port);
+}
+
+static int mlxsw_sp_span_entry_put(struct mlxsw_sp *mlxsw_sp,
+				   struct mlxsw_sp_span_entry *span_entry)
+{
+	if (--span_entry->ref_count == 0)
+		mlxsw_sp_span_entry_destroy(mlxsw_sp, span_entry);
+	return 0;
+}
+
+static bool mlxsw_sp_span_is_egress_mirror(struct mlxsw_sp_port *port)
+{
+	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
+	struct mlxsw_sp_span_inspected_port *p;
+	int i;
+
+	for (i = 0; i < mlxsw_sp->span.entries_count; i++) {
+		struct mlxsw_sp_span_entry *curr = &mlxsw_sp->span.entries[i];
+
+		list_for_each_entry(p, &curr->bound_ports_list, list)
+			if (p->local_port == port->local_port &&
+			    p->type == MLXSW_SP_SPAN_EGRESS)
+				return true;
+	}
+
+	return false;
+}
+
+static int mlxsw_sp_span_mtu_to_buffsize(int mtu)
+{
+	return MLXSW_SP_BYTES_TO_CELLS(mtu * 5 / 2) + 1;
+}
+
+static int mlxsw_sp_span_port_mtu_update(struct mlxsw_sp_port *port, u16 mtu)
+{
+	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
+	char sbib_pl[MLXSW_REG_SBIB_LEN];
+	int err;
+
+	/* If port is egress mirrored, the shared buffer size should be
+	 * updated according to the mtu value
+	 */
+	if (mlxsw_sp_span_is_egress_mirror(port)) {
+		mlxsw_reg_sbib_pack(sbib_pl, port->local_port,
+				    mlxsw_sp_span_mtu_to_buffsize(mtu));
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbib), sbib_pl);
+		if (err) {
+			netdev_err(port->dev, "Could not update shared buffer for mirroring\n");
+			return err;
+		}
+	}
+
+	return 0;
+}
+
+static struct mlxsw_sp_span_inspected_port *
+mlxsw_sp_span_entry_bound_port_find(struct mlxsw_sp_port *port,
+				    struct mlxsw_sp_span_entry *span_entry)
+{
+	struct mlxsw_sp_span_inspected_port *p;
+
+	list_for_each_entry(p, &span_entry->bound_ports_list, list)
+		if (port->local_port == p->local_port)
+			return p;
+	return NULL;
+}
+
+static int
+mlxsw_sp_span_inspected_port_bind(struct mlxsw_sp_port *port,
+				  struct mlxsw_sp_span_entry *span_entry,
+				  enum mlxsw_sp_span_type type)
+{
+	struct mlxsw_sp_span_inspected_port *inspected_port;
+	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
+	char mpar_pl[MLXSW_REG_MPAR_LEN];
+	char sbib_pl[MLXSW_REG_SBIB_LEN];
+	int pa_id = span_entry->id;
+	int err;
+
+	/* if it is an egress SPAN, bind a shared buffer to it */
+	if (type == MLXSW_SP_SPAN_EGRESS) {
+		mlxsw_reg_sbib_pack(sbib_pl, port->local_port,
+				    mlxsw_sp_span_mtu_to_buffsize(port->dev->mtu));
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbib), sbib_pl);
+		if (err) {
+			netdev_err(port->dev, "Could not create shared buffer for mirroring\n");
+			return err;
+		}
+	}
+
+	/* bind the port to the SPAN entry */
+	mlxsw_reg_mpar_pack(mpar_pl, port->local_port, type, true, pa_id);
+	err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mpar), mpar_pl);
+	if (err)
+		goto err_mpar_reg_write;
+
+	inspected_port = kzalloc(sizeof(*inspected_port), GFP_KERNEL);
+	if (!inspected_port) {
+		err = -ENOMEM;
+		goto err_inspected_port_alloc;
+	}
+	inspected_port->local_port = port->local_port;
+	inspected_port->type = type;
+	list_add_tail(&inspected_port->list, &span_entry->bound_ports_list);
+
+	return 0;
+
+err_mpar_reg_write:
+err_inspected_port_alloc:
+	if (type == MLXSW_SP_SPAN_EGRESS) {
+		mlxsw_reg_sbib_pack(sbib_pl, port->local_port, 0);
+		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbib), sbib_pl);
+	}
+	return err;
+}
+
+static void
+mlxsw_sp_span_inspected_port_unbind(struct mlxsw_sp_port *port,
+				    struct mlxsw_sp_span_entry *span_entry,
+				    enum mlxsw_sp_span_type type)
+{
+	struct mlxsw_sp_span_inspected_port *inspected_port;
+	struct mlxsw_sp *mlxsw_sp = port->mlxsw_sp;
+	char mpar_pl[MLXSW_REG_MPAR_LEN];
+	char sbib_pl[MLXSW_REG_SBIB_LEN];
+	int pa_id = span_entry->id;
+
+	inspected_port = mlxsw_sp_span_entry_bound_port_find(port, span_entry);
+	if (!inspected_port)
+		return;
+
+	/* remove the inspected port */
+	mlxsw_reg_mpar_pack(mpar_pl, port->local_port, type, false, pa_id);
+	mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(mpar), mpar_pl);
+
+	/* remove the SBIB buffer if it was egress SPAN */
+	if (type == MLXSW_SP_SPAN_EGRESS) {
+		mlxsw_reg_sbib_pack(sbib_pl, port->local_port, 0);
+		mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sbib), sbib_pl);
+	}
+
+	mlxsw_sp_span_entry_put(mlxsw_sp, span_entry);
+
+	list_del(&inspected_port->list);
+	kfree(inspected_port);
+}
+
+static int mlxsw_sp_span_mirror_add(struct mlxsw_sp_port *from,
+				    struct mlxsw_sp_port *to,
+				    enum mlxsw_sp_span_type type)
+{
+	struct mlxsw_sp *mlxsw_sp = from->mlxsw_sp;
+	struct mlxsw_sp_span_entry *span_entry;
+	int err;
+
+	span_entry = mlxsw_sp_span_entry_get(to);
+	if (!span_entry)
+		return -ENOENT;
+
+	netdev_dbg(from->dev, "Adding inspected port to SPAN entry %d\n",
+		   span_entry->id);
+
+	err = mlxsw_sp_span_inspected_port_bind(from, span_entry, type);
+	if (err)
+		goto err_port_bind;
+
+	return 0;
+
+err_port_bind:
+	mlxsw_sp_span_entry_put(mlxsw_sp, span_entry);
+	return err;
+}
+
+static void mlxsw_sp_span_mirror_remove(struct mlxsw_sp_port *from,
+					struct mlxsw_sp_port *to,
+					enum mlxsw_sp_span_type type)
+{
+	struct mlxsw_sp_span_entry *span_entry;
+
+	span_entry = mlxsw_sp_span_entry_find(to);
+	if (!span_entry) {
+		netdev_err(from->dev, "no span entry found\n");
+		return;
+	}
+
+	netdev_dbg(from->dev, "removing inspected port from SPAN entry %d\n",
+		   span_entry->id);
+	mlxsw_sp_span_inspected_port_unbind(from, span_entry, type);
+}
+
 static int mlxsw_sp_port_admin_status_set(struct mlxsw_sp_port *mlxsw_sp_port,
 					  bool is_up)
 {
@@ -510,6 +811,9 @@ static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
 	err = mlxsw_sp_port_headroom_set(mlxsw_sp_port, mtu, pause_en);
 	if (err)
 		return err;
+	err = mlxsw_sp_span_port_mtu_update(mlxsw_sp_port, mtu);
+	if (err)
+		goto err_span_port_mtu_update;
 	err = mlxsw_sp_port_mtu_set(mlxsw_sp_port, mtu);
 	if (err)
 		goto err_port_mtu_set;
@@ -517,6 +821,8 @@ static int mlxsw_sp_port_change_mtu(struct net_device *dev, int mtu)
 	return 0;
 
 err_port_mtu_set:
+	mlxsw_sp_span_port_mtu_update(mlxsw_sp_port, dev->mtu);
+err_span_port_mtu_update:
 	mlxsw_sp_port_headroom_set(mlxsw_sp_port, dev->mtu, pause_en);
 	return err;
 }
@@ -793,10 +1099,155 @@ static int mlxsw_sp_port_get_phys_port_name(struct net_device *dev, char *name,
 	return 0;
 }
 
+static struct mlxsw_sp_port_mall_tc_entry *
+mlxsw_sp_port_mirror_entry_find(struct mlxsw_sp_port *port,
+				unsigned long cookie) {
+	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
+
+	list_for_each_entry(mall_tc_entry, &port->mall_tc_list, list)
+		if (mall_tc_entry->cookie == cookie)
+			return mall_tc_entry;
+
+	return NULL;
+}
+
+static int
+mlxsw_sp_port_add_cls_matchall_mirror(struct mlxsw_sp_port *mlxsw_sp_port,
+				      struct tc_cls_matchall_offload *cls,
+				      const struct tc_action *a,
+				      bool ingress)
+{
+	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
+	struct net *net = dev_net(mlxsw_sp_port->dev);
+	enum mlxsw_sp_span_type span_type;
+	struct mlxsw_sp_port *to_port;
+	struct net_device *to_dev;
+	int ifindex;
+	int err;
+
+	ifindex = tcf_mirred_ifindex(a);
+	to_dev = __dev_get_by_index(net, ifindex);
+	if (!to_dev) {
+		netdev_err(mlxsw_sp_port->dev, "Could not find requested device\n");
+		return -EINVAL;
+	}
+
+	if (!mlxsw_sp_port_dev_check(to_dev)) {
+		netdev_err(mlxsw_sp_port->dev, "Cannot mirror to a non-spectrum port");
+		return -ENOTSUPP;
+	}
+	to_port = netdev_priv(to_dev);
+
+	mall_tc_entry = kzalloc(sizeof(*mall_tc_entry), GFP_KERNEL);
+	if (!mall_tc_entry)
+		return -ENOMEM;
+
+	mall_tc_entry->cookie = cls->cookie;
+	mall_tc_entry->type = MLXSW_SP_PORT_MALL_MIRROR;
+	mall_tc_entry->mirror.to_local_port = to_port->local_port;
+	mall_tc_entry->mirror.ingress = ingress;
+	list_add_tail(&mall_tc_entry->list, &mlxsw_sp_port->mall_tc_list);
+
+	span_type = ingress ? MLXSW_SP_SPAN_INGRESS : MLXSW_SP_SPAN_EGRESS;
+	err = mlxsw_sp_span_mirror_add(mlxsw_sp_port, to_port, span_type);
+	if (err)
+		goto err_mirror_add;
+	return 0;
+
+err_mirror_add:
+	list_del(&mall_tc_entry->list);
+	kfree(mall_tc_entry);
+	return err;
+}
+
+static int mlxsw_sp_port_add_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
+					  __be16 protocol,
+					  struct tc_cls_matchall_offload *cls,
+					  bool ingress)
+{
+	struct tcf_exts *exts = cls->exts;
+	const struct tc_action *a;
+	int err;
+
+	if (!list_is_singular(&exts->actions)) {
+		netdev_err(mlxsw_sp_port->dev, "only singular actions are supported\n");
+		return -ENOTSUPP;
+	}
+
+	a = list_first_entry(&exts->actions, struct tc_action, list);
+	if (is_tcf_mirred_mirror(a) && protocol == htons(ETH_P_ALL)) {
+		err = mlxsw_sp_port_add_cls_matchall_mirror(mlxsw_sp_port, cls,
+							    a, ingress);
+		if (err)
+			return err;
+	} else {
+		return -ENOTSUPP;
+	}
+
+	return 0;
+}
+
+static void mlxsw_sp_port_del_cls_matchall(struct mlxsw_sp_port *mlxsw_sp_port,
+					   struct tc_cls_matchall_offload *cls)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	struct mlxsw_sp_port_mall_tc_entry *mall_tc_entry;
+	enum mlxsw_sp_span_type span_type;
+	struct mlxsw_sp_port *to_port;
+
+	mall_tc_entry = mlxsw_sp_port_mirror_entry_find(mlxsw_sp_port,
+							cls->cookie);
+	if (!mall_tc_entry) {
+		netdev_dbg(mlxsw_sp_port->dev, "tc entry not found on port\n");
+		return;
+	}
+
+	switch (mall_tc_entry->type) {
+	case MLXSW_SP_PORT_MALL_MIRROR:
+		to_port = mlxsw_sp->ports[mall_tc_entry->mirror.to_local_port];
+		span_type = mall_tc_entry->mirror.ingress ?
+				MLXSW_SP_SPAN_INGRESS : MLXSW_SP_SPAN_EGRESS;
+
+		mlxsw_sp_span_mirror_remove(mlxsw_sp_port, to_port, span_type);
+		break;
+	default:
+		WARN_ON(1);
+	}
+
+	list_del(&mall_tc_entry->list);
+	kfree(mall_tc_entry);
+}
+
+static int mlxsw_sp_setup_tc(struct net_device *dev, u32 handle,
+			     __be16 proto, struct tc_to_netdev *tc)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port = netdev_priv(dev);
+	bool ingress = TC_H_MAJ(handle) == TC_H_MAJ(TC_H_INGRESS);
+
+	if (tc->type == TC_SETUP_MATCHALL) {
+		switch (tc->cls_mall->command) {
+		case TC_CLSMATCHALL_REPLACE:
+			return mlxsw_sp_port_add_cls_matchall(mlxsw_sp_port,
+							      proto,
+							      tc->cls_mall,
+							      ingress);
+		case TC_CLSMATCHALL_DESTROY:
+			mlxsw_sp_port_del_cls_matchall(mlxsw_sp_port,
+						       tc->cls_mall);
+			return 0;
+		default:
+			return -EINVAL;
+		}
+	}
+
+	return -ENOTSUPP;
+}
+
 static const struct net_device_ops mlxsw_sp_port_netdev_ops = {
 	.ndo_open		= mlxsw_sp_port_open,
 	.ndo_stop		= mlxsw_sp_port_stop,
 	.ndo_start_xmit		= mlxsw_sp_port_xmit,
+	.ndo_setup_tc           = mlxsw_sp_setup_tc,
 	.ndo_set_rx_mode	= mlxsw_sp_set_rx_mode,
 	.ndo_set_mac_address	= mlxsw_sp_port_set_mac_address,
 	.ndo_change_mtu		= mlxsw_sp_port_change_mtu,
@@ -1679,6 +2130,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 		goto err_port_untagged_vlans_alloc;
 	}
 	INIT_LIST_HEAD(&mlxsw_sp_port->vports_list);
+	INIT_LIST_HEAD(&mlxsw_sp_port->mall_tc_list);
 
 	mlxsw_sp_port->pcpu_stats =
 		netdev_alloc_pcpu_stats(struct mlxsw_sp_port_pcpu_stats);
@@ -1700,7 +2152,8 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port,
 	netif_carrier_off(dev);
 
 	dev->features |= NETIF_F_NETNS_LOCAL | NETIF_F_LLTX | NETIF_F_SG |
-			 NETIF_F_HW_VLAN_CTAG_FILTER;
+			 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_TC;
+	dev->hw_features |= NETIF_F_HW_TC;
 
 	/* Each packet needs to have a Tx header (metadata) on top all other
 	 * headers.
@@ -2432,15 +2885,22 @@ static int mlxsw_sp_init(struct mlxsw_core *mlxsw_core,
 		goto err_router_init;
 	}
 
+	err = mlxsw_sp_span_init(mlxsw_sp);
+	if (err) {
+		dev_err(mlxsw_sp->bus_info->dev, "Failed to init span system\n");
+		goto err_span_init;
+	}
+
 	err = mlxsw_sp_ports_create(mlxsw_sp);
 	if (err) {
 		dev_err(mlxsw_sp->bus_info->dev, "Failed to create ports\n");
 		goto err_ports_create;
 	}
-
 	return 0;
 
 err_ports_create:
+	mlxsw_sp_span_fini(mlxsw_sp);
+err_span_init:
 	mlxsw_sp_router_fini(mlxsw_sp);
 err_router_init:
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
@@ -2461,6 +2921,7 @@ static void mlxsw_sp_fini(struct mlxsw_core *mlxsw_core)
 	int i;
 
 	mlxsw_sp_ports_remove(mlxsw_sp);
+	mlxsw_sp_span_fini(mlxsw_sp);
 	mlxsw_sp_router_fini(mlxsw_sp);
 	mlxsw_sp_switchdev_fini(mlxsw_sp);
 	mlxsw_sp_buffers_fini(mlxsw_sp);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ef4ac89..f69aa37 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -214,6 +214,43 @@ struct mlxsw_sp_vr {
 	struct mlxsw_sp_fib *fib;
 };
 
+enum mlxsw_sp_span_type {
+	MLXSW_SP_SPAN_EGRESS,
+	MLXSW_SP_SPAN_INGRESS
+};
+
+struct mlxsw_sp_span_inspected_port {
+	struct list_head list;
+	enum mlxsw_sp_span_type type;
+	u8 local_port;
+};
+
+struct mlxsw_sp_span_entry {
+	u8 local_port;
+	bool used;
+	struct list_head bound_ports_list;
+	int ref_count;
+	int id;
+};
+
+enum mlxsw_sp_port_mall_action_type {
+	MLXSW_SP_PORT_MALL_MIRROR,
+};
+
+struct mlxsw_sp_port_mall_mirror_tc_entry {
+	u8 to_local_port;
+	bool ingress;
+};
+
+struct mlxsw_sp_port_mall_tc_entry {
+	struct list_head list;
+	unsigned long cookie;
+	enum mlxsw_sp_port_mall_action_type type;
+	union {
+		struct mlxsw_sp_port_mall_mirror_tc_entry mirror;
+	};
+};
+
 struct mlxsw_sp_router {
 	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
 	struct mlxsw_sp_vr vrs[MLXSW_SP_VIRTUAL_ROUTER_MAX];
@@ -260,6 +297,11 @@ struct mlxsw_sp {
 	struct {
 		DECLARE_BITMAP(usage, MLXSW_SP_KVD_LINEAR_SIZE);
 	} kvdl;
+
+	struct {
+		struct mlxsw_sp_span_entry *entries;
+		int entries_count;
+	} span;
 };
 
 static inline struct mlxsw_sp_upper *
@@ -316,6 +358,8 @@ struct mlxsw_sp_port {
 	unsigned long *untagged_vlans;
 	/* VLAN interfaces */
 	struct list_head vports_list;
+	/* TC handles */
+	struct list_head mall_tc_list;
 };
 
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev);
-- 
2.5.5

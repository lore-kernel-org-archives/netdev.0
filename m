From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 07/16] mlxsw: spectrum_router: Periodically update the kernel's neigh table
Date: Tue,  5 Jul 2016 11:27:43 +0200
Message-ID: <1467710872-20056-8-git-send-email-jiri@resnulli.us>
References: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35394 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751070AbcGEJ2E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2016 05:28:04 -0400
Received: by mail-wm0-f67.google.com with SMTP id a66so27232249wme.2
        for <netdev@vger.kernel.org>; Tue, 05 Jul 2016 02:28:03 -0700 (PDT)
In-Reply-To: <1467710872-20056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

As previously explained, the driver should periodically poll the device
for neighbours activity according to the configured DELAY_PROBE_TIME.
This will prevent active neighbours from staying in STALE state for long
periods of time.

During init configure the polling interval according to the
DELAY_PROBE_TIME used in the default table. In addition, register a
netevent notification block, so that the interval is updated whenever
DELAY_PROBE_TIME changes.

Using the computed interval schedule a delayed work, which will update
the kernel via neigh_event_send() on any active neighbour since the last
delayed work.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h     |   4 +
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 192 ++++++++++++++++++++-
 2 files changed, 194 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 734c5ba..9c2a60f 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -214,6 +214,10 @@ struct mlxsw_sp_router {
 	struct mlxsw_sp_lpm_tree lpm_trees[MLXSW_SP_LPM_TREE_COUNT];
 	struct mlxsw_sp_vr vrs[MLXSW_SP_VIRTUAL_ROUTER_MAX];
 	struct rhashtable neigh_ht;
+	struct {
+		struct delayed_work dw;
+		unsigned long interval;	/* ms */
+	} neighs_update;
 };
 
 struct mlxsw_sp {
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 90d382a..db1c2c4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3,6 +3,7 @@
  * Copyright (c) 2016 Mellanox Technologies. All rights reserved.
  * Copyright (c) 2016 Jiri Pirko <jiri@mellanox.com>
  * Copyright (c) 2016 Ido Schimmel <idosch@mellanox.com>
+ * Copyright (c) 2016 Yotam Gigi <yotamg@mellanox.com>
  *
  * Redistribution and use in source and binary forms, with or without
  * modification, are permitted provided that the following conditions are met:
@@ -38,6 +39,8 @@
 #include <linux/rhashtable.h>
 #include <linux/bitops.h>
 #include <linux/in6.h>
+#include <linux/notifier.h>
+#include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
 
@@ -676,14 +679,199 @@ void mlxsw_sp_router_neigh_destroy(struct net_device *dev,
 	mlxsw_sp_neigh_entry_destroy(neigh_entry);
 }
 
+static void
+mlxsw_sp_router_neighs_update_interval_init(struct mlxsw_sp *mlxsw_sp)
+{
+	unsigned long interval = NEIGH_VAR(&arp_tbl.parms, DELAY_PROBE_TIME);
+
+	mlxsw_sp->router.neighs_update.interval = jiffies_to_msecs(interval);
+}
+
+static void mlxsw_sp_router_neigh_ent_ipv4_process(struct mlxsw_sp *mlxsw_sp,
+						   char *rauhtd_pl,
+						   int ent_index)
+{
+	struct net_device *dev;
+	struct neighbour *n;
+	__be32 dipn;
+	u32 dip;
+	u16 rif;
+
+	mlxsw_reg_rauhtd_ent_ipv4_unpack(rauhtd_pl, ent_index, &rif, &dip);
+
+	if (!mlxsw_sp->rifs[rif]) {
+		dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Incorrect RIF in neighbour entry\n");
+		return;
+	}
+
+	dipn = htonl(dip);
+	dev = mlxsw_sp->rifs[rif]->dev;
+	n = neigh_lookup(&arp_tbl, &dipn, dev);
+	if (!n) {
+		netdev_err(dev, "Failed to find matching neighbour for IP=%pI4h\n",
+			   &dip);
+		return;
+	}
+
+	netdev_dbg(dev, "Updating neighbour with IP=%pI4h\n", &dip);
+	neigh_event_send(n, NULL);
+	neigh_release(n);
+}
+
+static void mlxsw_sp_router_neigh_rec_ipv4_process(struct mlxsw_sp *mlxsw_sp,
+						   char *rauhtd_pl,
+						   int rec_index)
+{
+	u8 num_entries;
+	int i;
+
+	num_entries = mlxsw_reg_rauhtd_ipv4_rec_num_entries_get(rauhtd_pl,
+								rec_index);
+	/* Hardware starts counting at 0, so add 1. */
+	num_entries++;
+
+	/* Each record consists of several neighbour entries. */
+	for (i = 0; i < num_entries; i++) {
+		int ent_index;
+
+		ent_index = rec_index * MLXSW_REG_RAUHTD_IPV4_ENT_PER_REC + i;
+		mlxsw_sp_router_neigh_ent_ipv4_process(mlxsw_sp, rauhtd_pl,
+						       ent_index);
+	}
+
+}
+
+static void mlxsw_sp_router_neigh_rec_process(struct mlxsw_sp *mlxsw_sp,
+					      char *rauhtd_pl, int rec_index)
+{
+	switch (mlxsw_reg_rauhtd_rec_type_get(rauhtd_pl, rec_index)) {
+	case MLXSW_REG_RAUHTD_TYPE_IPV4:
+		mlxsw_sp_router_neigh_rec_ipv4_process(mlxsw_sp, rauhtd_pl,
+						       rec_index);
+		break;
+	case MLXSW_REG_RAUHTD_TYPE_IPV6:
+		WARN_ON_ONCE(1);
+		break;
+	}
+}
+
+static void
+mlxsw_sp_router_neighs_update_work_schedule(struct mlxsw_sp *mlxsw_sp)
+{
+	unsigned long interval = mlxsw_sp->router.neighs_update.interval;
+
+	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw,
+			       msecs_to_jiffies(interval));
+}
+
+static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
+{
+	struct mlxsw_sp *mlxsw_sp;
+	char *rauhtd_pl;
+	u8 num_rec;
+	int i, err;
+
+	rauhtd_pl = kmalloc(MLXSW_REG_RAUHTD_LEN, GFP_KERNEL);
+	if (!rauhtd_pl)
+		return;
+
+	mlxsw_sp = container_of(work, struct mlxsw_sp,
+				router.neighs_update.dw.work);
+
+	/* Make sure the neighbour's netdev isn't removed in the
+	 * process.
+	 */
+	rtnl_lock();
+	do {
+		mlxsw_reg_rauhtd_pack(rauhtd_pl, MLXSW_REG_RAUHTD_TYPE_IPV4);
+		err = mlxsw_reg_query(mlxsw_sp->core, MLXSW_REG(rauhtd),
+				      rauhtd_pl);
+		if (err) {
+			dev_err_ratelimited(mlxsw_sp->bus_info->dev, "Failed to dump neighbour talbe\n");
+			break;
+		}
+		num_rec = mlxsw_reg_rauhtd_num_rec_get(rauhtd_pl);
+		for (i = 0; i < num_rec; i++)
+			mlxsw_sp_router_neigh_rec_process(mlxsw_sp, rauhtd_pl,
+							  i);
+	} while (num_rec);
+	rtnl_unlock();
+
+	kfree(rauhtd_pl);
+	mlxsw_sp_router_neighs_update_work_schedule(mlxsw_sp);
+}
+
+static int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
+					  unsigned long event, void *ptr)
+{
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	struct mlxsw_sp *mlxsw_sp;
+	unsigned long interval;
+	struct neigh_parms *p;
+
+	switch (event) {
+	case NETEVENT_DELAY_PROBE_TIME_UPDATE:
+		p = ptr;
+
+		/* We don't care about changes in the default table. */
+		if (!p->dev || p->tbl != &arp_tbl)
+			return NOTIFY_DONE;
+
+		/* We are in atomic context and can't take RTNL mutex,
+		 * so use RCU variant to walk the device chain.
+		 */
+		mlxsw_sp_port = mlxsw_sp_port_lower_dev_hold(p->dev);
+		if (!mlxsw_sp_port)
+			return NOTIFY_DONE;
+
+		mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+		interval = jiffies_to_msecs(NEIGH_VAR(p, DELAY_PROBE_TIME));
+		mlxsw_sp->router.neighs_update.interval = interval;
+
+		mlxsw_sp_port_dev_put(mlxsw_sp_port);
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static struct notifier_block mlxsw_sp_router_netevent_nb __read_mostly = {
+	.notifier_call = mlxsw_sp_router_netevent_event,
+};
+
 static int mlxsw_sp_neigh_init(struct mlxsw_sp *mlxsw_sp)
 {
-	return rhashtable_init(&mlxsw_sp->router.neigh_ht,
-			       &mlxsw_sp_neigh_ht_params);
+	int err;
+
+	err = rhashtable_init(&mlxsw_sp->router.neigh_ht,
+			      &mlxsw_sp_neigh_ht_params);
+	if (err)
+		return err;
+
+	/* Initialize the polling interval according to the default
+	 * table.
+	 */
+	mlxsw_sp_router_neighs_update_interval_init(mlxsw_sp);
+
+	err = register_netevent_notifier(&mlxsw_sp_router_netevent_nb);
+	if (err)
+		goto err_register_netevent_notifier;
+
+	INIT_DELAYED_WORK(&mlxsw_sp->router.neighs_update.dw,
+			  mlxsw_sp_router_neighs_update_work);
+	mlxsw_core_schedule_dw(&mlxsw_sp->router.neighs_update.dw, 0);
+
+	return 0;
+
+err_register_netevent_notifier:
+	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
+	return err;
 }
 
 static void mlxsw_sp_neigh_fini(struct mlxsw_sp *mlxsw_sp)
 {
+	cancel_delayed_work_sync(&mlxsw_sp->router.neighs_update.dw);
+	unregister_netevent_notifier(&mlxsw_sp_router_netevent_nb);
 	rhashtable_destroy(&mlxsw_sp->router.neigh_ht);
 }
 
-- 
2.5.5

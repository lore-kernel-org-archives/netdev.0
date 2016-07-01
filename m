From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 34/42] mlxsw: spectrum_router: Offload neighbours based on NUD state change
Date: Fri,  1 Jul 2016 16:05:02 +0200
Message-ID: <1467381910-3445-35-git-send-email-jiri@resnulli.us>
References: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, yotamg@mellanox.com,
	eladr@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com,
	sfeldma@gmail.com, roopa@cumulusnetworks.com, andy@greyhouse.net,
	dsa@cumulusnetworks.com, tgraf@suug.ch, jhs@mojatatu.com,
	linville@tuxdriver.com, ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36514 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752296AbcGAOTg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jul 2016 10:19:36 -0400
Received: by mail-wm0-f65.google.com with SMTP id c82so5660341wme.3
        for <netdev@vger.kernel.org>; Fri, 01 Jul 2016 07:19:36 -0700 (PDT)
In-Reply-To: <1467381910-3445-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Listen to any NEIGH_UPDATE events sent and program the device
accordingly. If NUD state is VALID and neighbour isn't yet offloaded,
then program it into the device's table. Otherwise, just edit its
parameters.

If NUD state machine transitioned neighbour out of VALID state and it's
present in the device's table, then remove it.

Note that the device is programmed in delayed work, as the netevent
notification chain is atomic and prevents us from going to sleep.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 103 +++++++++++++++++++++
 1 file changed, 103 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index db1c2c4..ed0e6c0 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -559,6 +559,10 @@ struct mlxsw_sp_neigh_entry {
 	struct mlxsw_sp_neigh_key key;
 	u16 rif;
 	struct neighbour *n;
+	bool offloaded;
+	struct delayed_work dw;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	unsigned char ha[ETH_ALEN];
 };
 
 static const struct rhashtable_params mlxsw_sp_neigh_ht_params = {
@@ -585,6 +589,8 @@ mlxsw_sp_neigh_entry_remove(struct mlxsw_sp *mlxsw_sp,
 			       mlxsw_sp_neigh_ht_params);
 }
 
+static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work);
+
 static struct mlxsw_sp_neigh_entry *
 mlxsw_sp_neigh_entry_create(const void *addr, size_t addr_len,
 			    struct net_device *dev, u16 rif,
@@ -599,6 +605,7 @@ mlxsw_sp_neigh_entry_create(const void *addr, size_t addr_len,
 	neigh_entry->key.dev = dev;
 	neigh_entry->rif = rif;
 	neigh_entry->n = n;
+	INIT_DELAYED_WORK(&neigh_entry->dw, mlxsw_sp_router_neigh_update_hw);
 	return neigh_entry;
 }
 
@@ -801,13 +808,76 @@ static void mlxsw_sp_router_neighs_update_work(struct work_struct *work)
 	mlxsw_sp_router_neighs_update_work_schedule(mlxsw_sp);
 }
 
+static void mlxsw_sp_router_neigh_update_hw(struct work_struct *work)
+{
+	struct mlxsw_sp_neigh_entry *neigh_entry =
+		container_of(work, struct mlxsw_sp_neigh_entry, dw.work);
+	struct neighbour *n = neigh_entry->n;
+	struct mlxsw_sp_port *mlxsw_sp_port = neigh_entry->mlxsw_sp_port;
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char rauht_pl[MLXSW_REG_RAUHT_LEN];
+	struct net_device *dev;
+	bool entry_connected;
+	u8 nud_state;
+	bool updating;
+	bool removing;
+	bool adding;
+	u32 dip;
+	int err;
+
+	read_lock_bh(&n->lock);
+	dip = ntohl(*((__be32 *) n->primary_key));
+	memcpy(neigh_entry->ha, n->ha, sizeof(neigh_entry->ha));
+	nud_state = n->nud_state;
+	dev = n->dev;
+	read_unlock_bh(&n->lock);
+
+	entry_connected = nud_state & NUD_VALID;
+	adding = (!neigh_entry->offloaded) && entry_connected;
+	updating = neigh_entry->offloaded && entry_connected;
+	removing = neigh_entry->offloaded && !entry_connected;
+
+	if (adding || updating) {
+		mlxsw_reg_rauht_pack4(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_ADD,
+				      neigh_entry->rif,
+				      neigh_entry->ha, dip);
+		err = mlxsw_reg_write(mlxsw_sp->core,
+				      MLXSW_REG(rauht), rauht_pl);
+		if (err) {
+			netdev_err(dev, "Could not add neigh %pI4h\n", &dip);
+			neigh_entry->offloaded = false;
+		} else {
+			neigh_entry->offloaded = true;
+		}
+	} else if (removing) {
+		mlxsw_reg_rauht_pack4(rauht_pl, MLXSW_REG_RAUHT_OP_WRITE_DELETE,
+				      neigh_entry->rif,
+				      neigh_entry->ha, dip);
+		err = mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(rauht),
+				      rauht_pl);
+		if (err) {
+			netdev_err(dev, "Could not delete neigh %pI4h\n", &dip);
+			neigh_entry->offloaded = true;
+		} else {
+			neigh_entry->offloaded = false;
+		}
+	}
+
+	neigh_release(n);
+	mlxsw_sp_port_dev_put(mlxsw_sp_port);
+}
+
 static int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 					  unsigned long event, void *ptr)
 {
+	struct mlxsw_sp_neigh_entry *neigh_entry;
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct mlxsw_sp *mlxsw_sp;
 	unsigned long interval;
+	struct net_device *dev;
 	struct neigh_parms *p;
+	struct neighbour *n;
+	u32 dip;
 
 	switch (event) {
 	case NETEVENT_DELAY_PROBE_TIME_UPDATE:
@@ -830,6 +900,39 @@ static int mlxsw_sp_router_netevent_event(struct notifier_block *unused,
 
 		mlxsw_sp_port_dev_put(mlxsw_sp_port);
 		break;
+	case NETEVENT_NEIGH_UPDATE:
+		n = ptr;
+		dev = n->dev;
+
+		if (n->tbl != &arp_tbl)
+			return NOTIFY_DONE;
+
+		mlxsw_sp_port = mlxsw_sp_port_lower_dev_hold(dev);
+		if (!mlxsw_sp_port)
+			return NOTIFY_DONE;
+
+		mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+		dip = ntohl(*((__be32 *) n->primary_key));
+		neigh_entry = mlxsw_sp_neigh_entry_lookup(mlxsw_sp,
+							  &dip,
+							  sizeof(__be32),
+							  dev);
+		if (WARN_ON(!neigh_entry) || WARN_ON(neigh_entry->n != n)) {
+			mlxsw_sp_port_dev_put(mlxsw_sp_port);
+			return NOTIFY_DONE;
+		}
+		neigh_entry->mlxsw_sp_port = mlxsw_sp_port;
+
+		/* Take a reference to ensure the neighbour won't be
+		 * destructed until we drop the reference in delayed
+		 * work.
+		 */
+		neigh_clone(n);
+		if (!mlxsw_core_schedule_dw(&neigh_entry->dw, 0)) {
+			neigh_release(n);
+			mlxsw_sp_port_dev_put(mlxsw_sp_port);
+		}
+		break;
 	}
 
 	return NOTIFY_DONE;
-- 
2.5.5

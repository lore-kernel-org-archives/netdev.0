From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 03/14] mlxsw: spectrum: Allocate active VLANs only for port netdevs
Date: Tue, 15 Dec 2015 16:03:36 +0100
Message-ID: <1450191827-6679-4-git-send-email-jiri@resnulli.us>
References: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	gospo@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	f.fainelli@gmail.com, sfeldma@gmail.com, john.fastabend@gmail.com,
	roopa@cumulusnetworks.com, andrew@lunn.ch, kaber@trash.net,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:38373 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933406AbbLOPDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 10:03:55 -0500
Received: by mail-wm0-f49.google.com with SMTP id p66so29755972wmp.1
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 07:03:55 -0800 (PST)
In-Reply-To: <1450191827-6679-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

When adding support for bridges between VLAN interfaces, we'll introduce
a new entity called a vPort, which is a represntation of the VLAN
interface in the hardware.

The main difference between a vPort and a physical port is that several
FIDs can be bound to the latter, whereas only one (called a vFID) can be
bound to the first.

Therefore, it makes sense to use the same struct to represent the two,
but to only allocate the 'active_vlans' bitmap in case of a physical
port.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 10 ++++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h |  2 +-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 322ed54..6bacdcf5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1245,6 +1245,7 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	struct mlxsw_sp_port *mlxsw_sp_port;
 	struct net_device *dev;
 	bool usable;
+	size_t bytes;
 	int err;
 
 	dev = alloc_etherdev(sizeof(struct mlxsw_sp_port));
@@ -1258,6 +1259,12 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port->learning_sync = 1;
 	mlxsw_sp_port->uc_flood = 1;
 	mlxsw_sp_port->pvid = 1;
+	bytes = DIV_ROUND_UP(VLAN_N_VID, BITS_PER_BYTE);
+	mlxsw_sp_port->active_vlans = kzalloc(bytes, GFP_KERNEL);
+	if (!mlxsw_sp_port->active_vlans) {
+		err = -ENOMEM;
+		goto err_port_active_vlans_alloc;
+	}
 
 	mlxsw_sp_port->pcpu_stats =
 		netdev_alloc_pcpu_stats(struct mlxsw_sp_port_pcpu_stats);
@@ -1359,6 +1366,8 @@ err_port_module_check:
 err_dev_addr_init:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
+	kfree(mlxsw_sp_port->active_vlans);
+err_port_active_vlans_alloc:
 	free_netdev(dev);
 	return err;
 }
@@ -1381,6 +1390,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	unregister_netdev(mlxsw_sp_port->dev); /* This calls ndo_stop */
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
+	kfree(mlxsw_sp_port->active_vlans);
 	free_netdev(mlxsw_sp_port->dev);
 }
 
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 48be5a6..608be6e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -103,7 +103,7 @@ struct mlxsw_sp_port {
 	u16 pvid;
 	u16 lag_id;
 	/* 802.1Q bridge VLANs */
-	unsigned long active_vlans[BITS_TO_LONGS(VLAN_N_VID)];
+	unsigned long *active_vlans;
 	/* VLAN interfaces */
 	unsigned long active_vfids[BITS_TO_LONGS(VLAN_N_VID)];
 	u16 nr_vfids;
-- 
1.9.3

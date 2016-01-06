From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 8/8] mlxsw: Remember untagged VLANs
Date: Wed,  6 Jan 2016 11:11:56 +0100
Message-ID: <1452075116-5726-9-git-send-email-jiri@resnulli.us>
References: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com,
	stephen@networkplumber.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:34549 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752391AbcAFKMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jan 2016 05:12:09 -0500
Received: by mail-wm0-f49.google.com with SMTP id u188so54433856wmu.1
        for <netdev@vger.kernel.org>; Wed, 06 Jan 2016 02:12:08 -0800 (PST)
In-Reply-To: <1452075116-5726-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Elad Raz <eladr@mellanox.com>

When a vlan is been configured, remeber the untagged mode of the vlan.
When displaying the list of configured VLANs, show the untagged attribute.

Signed-off-by: Elad Raz <eladr@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c           | 8 ++++++++
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h           | 1 +
 drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c | 9 ++++++++-
 3 files changed, 17 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 74ff011..b6f3650 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -1370,6 +1370,11 @@ static int mlxsw_sp_port_create(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 		err = -ENOMEM;
 		goto err_port_active_vlans_alloc;
 	}
+	mlxsw_sp_port->untagged_vlans = kzalloc(bytes, GFP_KERNEL);
+	if (!mlxsw_sp_port->untagged_vlans) {
+		err = -ENOMEM;
+		goto err_port_untagged_vlans_alloc;
+	}
 	INIT_LIST_HEAD(&mlxsw_sp_port->vports_list);
 
 	mlxsw_sp_port->pcpu_stats =
@@ -1472,6 +1477,8 @@ err_port_module_check:
 err_dev_addr_init:
 	free_percpu(mlxsw_sp_port->pcpu_stats);
 err_alloc_stats:
+	kfree(mlxsw_sp_port->untagged_vlans);
+err_port_untagged_vlans_alloc:
 	kfree(mlxsw_sp_port->active_vlans);
 err_port_active_vlans_alloc:
 	free_netdev(dev);
@@ -1505,6 +1512,7 @@ static void mlxsw_sp_port_remove(struct mlxsw_sp *mlxsw_sp, u8 local_port)
 	mlxsw_sp_port_vports_fini(mlxsw_sp_port);
 	mlxsw_sp_port_switchdev_fini(mlxsw_sp_port);
 	free_percpu(mlxsw_sp_port->pcpu_stats);
+	kfree(mlxsw_sp_port->untagged_vlans);
 	kfree(mlxsw_sp_port->active_vlans);
 	free_netdev(mlxsw_sp_port->dev);
 }
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index 463ed6d..7601789 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -144,6 +144,7 @@ struct mlxsw_sp_port {
 	} vport;
 	/* 802.1Q bridge VLANs */
 	unsigned long *active_vlans;
+	unsigned long *untagged_vlans;
 	/* VLAN interfaces */
 	struct list_head vports_list;
 };
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
index d6242cf..614ef57 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_switchdev.c
@@ -526,8 +526,13 @@ static int __mlxsw_sp_port_vlans_add(struct mlxsw_sp_port *mlxsw_sp_port,
 	}
 
 	/* Changing activity bits only if HW operation succeded */
-	for (vid = vid_begin; vid <= vid_end; vid++)
+	for (vid = vid_begin; vid <= vid_end; vid++) {
 		set_bit(vid, mlxsw_sp_port->active_vlans);
+		if (flag_untagged)
+			set_bit(vid, mlxsw_sp_port->untagged_vlans);
+		else
+			clear_bit(vid, mlxsw_sp_port->untagged_vlans);
+	}
 
 	/* STP state change must be done after we set active VLANs */
 	err = mlxsw_sp_port_stp_state_set(mlxsw_sp_port,
@@ -954,6 +959,8 @@ static int mlxsw_sp_port_vlan_dump(struct mlxsw_sp_port *mlxsw_sp_port,
 		vlan->flags = 0;
 		if (vid == mlxsw_sp_port->pvid)
 			vlan->flags |= BRIDGE_VLAN_INFO_PVID;
+		if (test_bit(vid, mlxsw_sp_port->untagged_vlans))
+			vlan->flags |= BRIDGE_VLAN_INFO_UNTAGGED;
 		vlan->vid_begin = vid;
 		vlan->vid_end = vid;
 		err = cb(&vlan->obj);
-- 
1.9.3

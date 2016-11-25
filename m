From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 02/19] mlxsw: core: Create a generic function to register / unregister traps
Date: Fri, 25 Nov 2016 10:33:30 +0100
Message-ID: <1480066427-3961-3-git-send-email-jiri@resnulli.us>
References: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, nogahf@mellanox.com, idosch@mellanox.com,
        eladr@mellanox.com, yotamg@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33808 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbcKYJem (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 04:34:42 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so7223377wme.1
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 01:33:52 -0800 (PST)
In-Reply-To: <1480066427-3961-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nogah Frankel <nogahf@mellanox.com>

We have 2 types of HW traps to handle, rx traps and events.
The registration workflow for both is very similar. So it only make
sense to create one function to handle both.

This patch creates a struct to hold the data for both cases. It also
creates a registration and an un-registration functions that get this
generic struct as input.

Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/core.c | 67 ++++++++++++++++++++++++++++++
 drivers/net/ethernet/mellanox/mlxsw/core.h | 18 ++++++++
 2 files changed, 85 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.c b/drivers/net/ethernet/mellanox/mlxsw/core.c
index bcd7251..a8cff78 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.c
@@ -1392,6 +1392,73 @@ void mlxsw_core_event_listener_unregister(struct mlxsw_core *mlxsw_core,
 }
 EXPORT_SYMBOL(mlxsw_core_event_listener_unregister);
 
+static int mlxsw_core_listener_register(struct mlxsw_core *mlxsw_core,
+					const struct mlxsw_listener *listener,
+					void *priv)
+{
+	if (listener->is_event)
+		return mlxsw_core_event_listener_register(mlxsw_core,
+						&listener->u.event_listener,
+						priv);
+	else
+		return mlxsw_core_rx_listener_register(mlxsw_core,
+						&listener->u.rx_listener,
+						priv);
+}
+
+static void mlxsw_core_listener_unregister(struct mlxsw_core *mlxsw_core,
+				      const struct mlxsw_listener *listener,
+				      void *priv)
+{
+	if (listener->is_event)
+		mlxsw_core_event_listener_unregister(mlxsw_core,
+						     &listener->u.event_listener,
+						     priv);
+	else
+		mlxsw_core_rx_listener_unregister(mlxsw_core,
+						  &listener->u.rx_listener,
+						  priv);
+}
+
+int mlxsw_core_trap_register(struct mlxsw_core *mlxsw_core,
+			     const struct mlxsw_listener *listener, void *priv)
+{
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+	int err;
+
+	err = mlxsw_core_listener_register(mlxsw_core, listener, priv);
+	if (err)
+		return err;
+
+	mlxsw_reg_hpkt_pack(hpkt_pl, listener->action, listener->trap_id);
+	err = mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
+	if (err)
+		goto err_trap_set;
+
+	return 0;
+
+err_trap_set:
+	mlxsw_core_listener_unregister(mlxsw_core, listener, priv);
+	return err;
+}
+EXPORT_SYMBOL(mlxsw_core_trap_register);
+
+void mlxsw_core_trap_unregister(struct mlxsw_core *mlxsw_core,
+				const struct mlxsw_listener *listener,
+				void *priv)
+{
+	char hpkt_pl[MLXSW_REG_HPKT_LEN];
+
+	if (!listener->is_event) {
+		mlxsw_reg_hpkt_pack(hpkt_pl, listener->unreg_action,
+				    listener->trap_id);
+		mlxsw_reg_write(mlxsw_core, MLXSW_REG(hpkt), hpkt_pl);
+	}
+
+	mlxsw_core_listener_unregister(mlxsw_core, listener, priv);
+}
+EXPORT_SYMBOL(mlxsw_core_trap_unregister);
+
 static u64 mlxsw_core_tid_get(struct mlxsw_core *mlxsw_core)
 {
 	return atomic64_inc_return(&mlxsw_core->emad.tid);
diff --git a/drivers/net/ethernet/mellanox/mlxsw/core.h b/drivers/net/ethernet/mellanox/mlxsw/core.h
index 3de8955..66d97c4 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/core.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/core.h
@@ -90,6 +90,17 @@ struct mlxsw_event_listener {
 	enum mlxsw_event_trap_id trap_id;
 };
 
+struct mlxsw_listener {
+	u16 trap_id;
+	union {
+		struct mlxsw_rx_listener rx_listener;
+		struct mlxsw_event_listener event_listener;
+	} u;
+	enum mlxsw_reg_hpkt_action action;
+	enum mlxsw_reg_hpkt_action unreg_action;
+	bool is_event;
+};
+
 int mlxsw_core_rx_listener_register(struct mlxsw_core *mlxsw_core,
 				    const struct mlxsw_rx_listener *rxl,
 				    void *priv);
@@ -104,6 +115,13 @@ void mlxsw_core_event_listener_unregister(struct mlxsw_core *mlxsw_core,
 					  const struct mlxsw_event_listener *el,
 					  void *priv);
 
+int mlxsw_core_trap_register(struct mlxsw_core *mlxsw_core,
+			     const struct mlxsw_listener *listener,
+			     void *priv);
+void mlxsw_core_trap_unregister(struct mlxsw_core *mlxsw_core,
+				const struct mlxsw_listener *listener,
+				void *priv);
+
 typedef void mlxsw_reg_trans_cb_t(struct mlxsw_core *mlxsw_core, char *payload,
 				  size_t payload_len, unsigned long cb_priv);
 
-- 
2.7.4

From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 28/28] mlxsw: spectrum: Implement LAG tx enabled lower state change
Date: Wed,  2 Dec 2015 21:07:51 +0100
Message-ID: <1449086871-19911-29-git-send-email-jiri@resnulli.us>
References: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com, j.vosburgh@gmail.com,
	vfalico@gmail.com, gospo@cumulusnetworks.com,
	dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	pjonnala@broadcom.com, f.fainelli@gmail.com, sfeldma@gmail.com,
	john.fastabend@gmail.com, roopa@cumulusnetworks.com, andrew@lunn.ch
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:32938 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756084AbbLBUIb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 15:08:31 -0500
Received: by wmec201 with SMTP id c201so270769048wme.0
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 12:08:30 -0800 (PST)
In-Reply-To: <1449086871-19911-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Enabling/disabling TX on a LAG port means enabling/disabling distribution
in our HW.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 81 +++++++++++++++++++++++++-
 1 file changed, 79 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 7d1f0a8..3ec07b9 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -2108,8 +2108,47 @@ static int mlxsw_sp_port_lag_leave(struct mlxsw_sp_port *mlxsw_sp_port,
 	return 0;
 }
 
-static int mlxsw_sp_netdevice_port_event(struct net_device *dev,
-					 unsigned long event, void *ptr)
+static int mlxsw_sp_lag_dist_port_add(struct mlxsw_sp_port *mlxsw_sp_port,
+				      u16 lag_id)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char sldr_pl[MLXSW_REG_SLDR_LEN];
+
+	mlxsw_reg_sldr_lag_add_port_pack(sldr_pl, lag_id,
+					 mlxsw_sp_port->local_port);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sldr), sldr_pl);
+}
+
+static int mlxsw_sp_lag_dist_port_remove(struct mlxsw_sp_port *mlxsw_sp_port,
+					 u16 lag_id)
+{
+	struct mlxsw_sp *mlxsw_sp = mlxsw_sp_port->mlxsw_sp;
+	char sldr_pl[MLXSW_REG_SLDR_LEN];
+
+	mlxsw_reg_sldr_lag_remove_port_pack(sldr_pl, lag_id,
+					    mlxsw_sp_port->local_port);
+	return mlxsw_reg_write(mlxsw_sp->core, MLXSW_REG(sldr), sldr_pl);
+}
+
+static int mlxsw_sp_port_lag_tx_en_set(struct mlxsw_sp_port *mlxsw_sp_port,
+				       bool lag_tx_enabled)
+{
+	if (lag_tx_enabled)
+		return mlxsw_sp_lag_dist_port_add(mlxsw_sp_port,
+						  mlxsw_sp_port->lag_id);
+	else
+		return mlxsw_sp_lag_dist_port_remove(mlxsw_sp_port,
+						     mlxsw_sp_port->lag_id);
+}
+
+static int mlxsw_sp_port_lag_changed(struct mlxsw_sp_port *mlxsw_sp_port,
+				     struct netdev_lag_lower_state_info *info)
+{
+	return mlxsw_sp_port_lag_tx_en_set(mlxsw_sp_port, info->tx_enabled);
+}
+
+static int mlxsw_sp_netdevice_port_upper_event(struct net_device *dev,
+					       unsigned long event, void *ptr)
 {
 	struct netdev_notifier_changeupper_info *info;
 	struct mlxsw_sp_port *mlxsw_sp_port;
@@ -2176,6 +2215,44 @@ static int mlxsw_sp_netdevice_port_event(struct net_device *dev,
 	return NOTIFY_DONE;
 }
 
+static int mlxsw_sp_netdevice_port_lower_event(struct net_device *dev,
+					       unsigned long event, void *ptr)
+{
+	struct netdev_notifier_changelowerstate_info *info;
+	struct mlxsw_sp_port *mlxsw_sp_port;
+	int err;
+
+	mlxsw_sp_port = netdev_priv(dev);
+	info = ptr;
+
+	switch (event) {
+	case NETDEV_CHANGELOWERSTATE:
+		if (netif_is_lag_port(dev) && mlxsw_sp_port->lagged) {
+			err = mlxsw_sp_port_lag_changed(mlxsw_sp_port,
+							info->lower_state_info);
+			if (err)
+				netdev_err(dev, "Failed to reflect link aggregation lower state change\n");
+		}
+		break;
+	}
+
+	return NOTIFY_DONE;
+}
+
+static int mlxsw_sp_netdevice_port_event(struct net_device *dev,
+					 unsigned long event, void *ptr)
+{
+	switch (event) {
+	case NETDEV_PRECHANGEUPPER:
+	case NETDEV_CHANGEUPPER:
+		return mlxsw_sp_netdevice_port_upper_event(dev, event, ptr);
+	case NETDEV_CHANGELOWERSTATE:
+		return mlxsw_sp_netdevice_port_lower_event(dev, event, ptr);
+	}
+
+	return NOTIFY_DONE;
+}
+
 static int mlxsw_sp_netdevice_lag_event(struct net_device *lag_dev,
 					unsigned long event, void *ptr)
 {
-- 
1.9.3

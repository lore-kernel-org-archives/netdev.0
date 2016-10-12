From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 07/11] mlxsw: Flip to the new dev walk API
Date: Wed, 12 Oct 2016 13:51:55 -0700
Message-ID: <1476305519-28833-8-git-send-email-dsa@cumulusnetworks.com>
References: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Cc: dledford@redhat.com, sean.hefty@intel.com,
        hal.rosenstock@gmail.com, linux-rdma@vger.kernel.org,
        j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
        jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        David Ahern <dsa@cumulusnetworks.com>
To: jiri@mellanox.com, netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:36296 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934214AbcJLUwQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 12 Oct 2016 16:52:16 -0400
Received: by mail-pf0-f181.google.com with SMTP id e6so23427618pfk.3
        for <netdev@vger.kernel.org>; Wed, 12 Oct 2016 13:52:16 -0700 (PDT)
In-Reply-To: <1476305519-28833-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Convert mlxsw users to new dev walk API. This is just a move to the
new API; no functional change is intended.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 37 ++++++++++++++++----------
 1 file changed, 23 insertions(+), 14 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index 1ec0a4ce3c46..1d5434ff02bb 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3090,19 +3090,30 @@ static bool mlxsw_sp_port_dev_check(const struct net_device *dev)
 	return dev->netdev_ops == &mlxsw_sp_port_netdev_ops;
 }
 
+static int mlxsw_lower_dev_walk(struct net_device *lower_dev, void *data)
+{
+	struct mlxsw_sp_port **port = data;
+	int ret = 0;
+
+	if (mlxsw_sp_port_dev_check(lower_dev)) {
+		*port = netdev_priv(lower_dev);
+		ret = 1;
+	}
+
+	return ret;
+}
+
 static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find(struct net_device *dev)
 {
-	struct net_device *lower_dev;
-	struct list_head *iter;
+	struct mlxsw_sp_port *port;
 
 	if (mlxsw_sp_port_dev_check(dev))
 		return netdev_priv(dev);
 
-	netdev_for_each_all_lower_dev(dev, lower_dev, iter) {
-		if (mlxsw_sp_port_dev_check(lower_dev))
-			return netdev_priv(lower_dev);
-	}
-	return NULL;
+	port = NULL;
+	netdev_walk_all_lower_dev(dev, mlxsw_lower_dev_walk, &port);
+
+	return port;
 }
 
 static struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
@@ -3115,17 +3126,15 @@ static struct mlxsw_sp *mlxsw_sp_lower_get(struct net_device *dev)
 
 static struct mlxsw_sp_port *mlxsw_sp_port_dev_lower_find_rcu(struct net_device *dev)
 {
-	struct net_device *lower_dev;
-	struct list_head *iter;
+	struct mlxsw_sp_port *port;
 
 	if (mlxsw_sp_port_dev_check(dev))
 		return netdev_priv(dev);
 
-	netdev_for_each_all_lower_dev_rcu(dev, lower_dev, iter) {
-		if (mlxsw_sp_port_dev_check(lower_dev))
-			return netdev_priv(lower_dev);
-	}
-	return NULL;
+	port = NULL;
+	netdev_walk_all_lower_dev_rcu(dev, mlxsw_lower_dev_walk, &port);
+
+	return port;
 }
 
 struct mlxsw_sp_port *mlxsw_sp_port_lower_dev_hold(struct net_device *dev)
-- 
2.1.4

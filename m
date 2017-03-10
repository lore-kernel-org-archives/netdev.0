From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 04/10] mlxsw: spectrum: Destroy RIFs based on last removed address
Date: Fri, 10 Mar 2017 08:53:37 +0100
Message-ID: <1489132423-12575-5-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33490 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753120AbdCJHxv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:51 -0500
Received: by mail-wm0-f65.google.com with SMTP id n11so937244wma.0
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:50 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

We only use the RIF reference count to determine when the last IP
address was removed, but instead we can just test 'in_dev->ifa_list'.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum.c | 7 +++----
 drivers/net/ethernet/mellanox/mlxsw/spectrum.h | 1 -
 2 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
index fd6c40e..cb0e77a 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.c
@@ -3392,16 +3392,16 @@ void mlxsw_sp_port_dev_put(struct mlxsw_sp_port *mlxsw_sp_port)
 }
 
 static bool mlxsw_sp_rif_should_config(struct mlxsw_sp_rif *r,
+				       const struct in_device *in_dev,
 				       unsigned long event)
 {
 	switch (event) {
 	case NETDEV_UP:
 		if (!r)
 			return true;
-		r->ref_count++;
 		return false;
 	case NETDEV_DOWN:
-		if (r && --r->ref_count == 0)
+		if (r && !in_dev->ifa_list)
 			return true;
 		/* It is possible we already removed the RIF ourselves
 		 * if it was assigned to a netdev that is now a bridge
@@ -3484,7 +3484,6 @@ mlxsw_sp_rif_alloc(u16 rif, struct net_device *l3_dev, struct mlxsw_sp_fid *f)
 	INIT_LIST_HEAD(&r->neigh_list);
 	ether_addr_copy(r->addr, l3_dev->dev_addr);
 	r->mtu = l3_dev->mtu;
-	r->ref_count = 1;
 	r->dev = l3_dev;
 	r->rif = rif;
 	r->f = f;
@@ -3858,7 +3857,7 @@ static int mlxsw_sp_inetaddr_event(struct notifier_block *unused,
 		goto out;
 
 	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
-	if (!mlxsw_sp_rif_should_config(r, event))
+	if (!mlxsw_sp_rif_should_config(r, ifa->ifa_dev, event))
 		goto out;
 
 	if (mlxsw_sp_port_dev_check(dev))
diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
index ac445d8..7805430 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum.h
@@ -111,7 +111,6 @@ struct mlxsw_sp_rif {
 	struct list_head nexthop_list;
 	struct list_head neigh_list;
 	struct net_device *dev;
-	unsigned int ref_count;
 	struct mlxsw_sp_fid *f;
 	unsigned char addr[ETH_ALEN];
 	int mtu;
-- 
2.7.4

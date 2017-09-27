From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 11/12] mlxsw: spectrum: Notify multicast router on RIF MTU changes
Date: Wed, 27 Sep 2017 08:23:21 +0200
Message-ID: <20170927062322.5476-12-jiri@resnulli.us>
References: <20170927062322.5476-1-jiri@resnulli.us>
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        linyunsheng@huawei.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34449 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdI0GXf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 02:23:35 -0400
Received: by mail-wm0-f68.google.com with SMTP id i131so10521682wma.1
        for <netdev@vger.kernel.org>; Tue, 26 Sep 2017 23:23:35 -0700 (PDT)
In-Reply-To: <20170927062322.5476-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yotam Gigi <yotamg@mellanox.com>

Due to the fact that multicast routes hold the minimum MTU of all the
egress RIFs and trap packets that don't meet it, notify the mulitcast
router code on RIF MTU changes.

Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 7758442..dbd9c19 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5773,6 +5773,17 @@ int mlxsw_sp_netdevice_router_port_event(struct net_device *dev)
 	if (err)
 		goto err_rif_fdb_op;
 
+	if (rif->mtu != dev->mtu) {
+		struct mlxsw_sp_vr *vr;
+
+		/* The RIF is relevant only to its mr_table instance, as unlike
+		 * unicast routing, in multicast routing a RIF cannot be shared
+		 * between several multicast routing tables.
+		 */
+		vr = &mlxsw_sp->router->vrs[rif->vr_id];
+		mlxsw_sp_mr_rif_mtu_update(vr->mr4_table, rif, dev->mtu);
+	}
+
 	ether_addr_copy(rif->addr, dev->dev_addr);
 	rif->mtu = dev->mtu;
 
-- 
2.9.5

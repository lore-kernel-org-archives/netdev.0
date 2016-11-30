From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v3 11/12] mlxsw: spectrum_router: Request a dump of FIB tables during init
Date: Wed, 30 Nov 2016 11:09:05 +0100
Message-ID: <1480500546-2544-12-git-send-email-jiri@resnulli.us>
References: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34844 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933146AbcK3KJW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 05:09:22 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so28642367wme.2
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 02:09:21 -0800 (PST)
In-Reply-To: <1480500546-2544-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Make sure the device has a complete view of the FIB tables by invoking
their dump during module init.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 23 ++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 14bed1d..d176047 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2027,8 +2027,23 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	return NOTIFY_DONE;
 }
 
+static void mlxsw_sp_router_fib_dump_flush(struct notifier_block *nb)
+{
+	struct mlxsw_sp *mlxsw_sp = container_of(nb, struct mlxsw_sp, fib_nb);
+
+	/* Flush pending FIB notifications and then flush the device's
+	 * table before requesting another dump. Do that with RTNL held,
+	 * as FIB notification block is already registered.
+	 */
+	mlxsw_core_flush_owq();
+	rtnl_lock();
+	mlxsw_sp_router_fib_flush(mlxsw_sp);
+	rtnl_unlock();
+}
+
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
+	fib_dump_cb_t *cb = mlxsw_sp_router_fib_dump_flush;
 	int err;
 
 	INIT_LIST_HEAD(&mlxsw_sp->router.nexthop_neighs_list);
@@ -2048,8 +2063,16 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 
 	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
 	register_fib_notifier(&mlxsw_sp->fib_nb);
+	if (!fib_notifier_dump(&mlxsw_sp->fib_nb, &init_net, cb)) {
+		err = -EBUSY;
+		goto err_fib_notifier_dump;
+	}
+
 	return 0;
 
+err_fib_notifier_dump:
+	unregister_fib_notifier(&mlxsw_sp->fib_nb);
+	mlxsw_sp_neigh_fini(mlxsw_sp);
 err_neigh_init:
 	mlxsw_sp_vrs_fini(mlxsw_sp);
 err_vrs_init:
-- 
2.7.4

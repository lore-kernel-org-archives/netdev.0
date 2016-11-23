From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/11] mlxsw: spectrum_router: Request a dump of FIB tables during init
Date: Wed, 23 Nov 2016 15:48:47 +0100
Message-ID: <1479912528-4636-1-git-send-email-jiri@resnulli.us>
References: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com,
        ogerlitz@mellanox.com, roopa@cumulusnetworks.com,
        dsa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        andy@greyhouse.net, vivien.didelot@savoirfairelinux.com,
        andrew@lunn.ch, f.fainelli@gmail.com, alexander.h.duyck@intel.com,
        hannes@stressinduktion.org, kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:34061 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964993AbcKWOsu (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Nov 2016 09:48:50 -0500
Received: by mail-wm0-f66.google.com with SMTP id g23so2222666wme.1
        for <netdev@vger.kernel.org>; Wed, 23 Nov 2016 06:48:50 -0800 (PST)
In-Reply-To: <1479911670-4525-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Make sure the device has a complete view of the FIB tables by invoking
their dump during module init.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 14bed1d..36a71d2 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -2027,6 +2027,21 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	return NOTIFY_DONE;
 }
 
+static void mlxsw_sp_router_fib_dump(struct mlxsw_sp *mlxsw_sp)
+{
+	while (!fib_notifier_dump(&mlxsw_sp->fib_nb)) {
+		/* Flush pending FIB notifications and then flush the
+		 * device's table before requesting another dump. Do
+		 * that with RTNL held, as FIB notification block is
+		 * already registered.
+		 */
+		mlxsw_core_flush_owq();
+		rtnl_lock();
+		mlxsw_sp_router_fib_flush(mlxsw_sp);
+		rtnl_unlock();
+	}
+}
+
 int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 {
 	int err;
@@ -2048,6 +2063,7 @@ int mlxsw_sp_router_init(struct mlxsw_sp *mlxsw_sp)
 
 	mlxsw_sp->fib_nb.notifier_call = mlxsw_sp_router_fib_event;
 	register_fib_notifier(&mlxsw_sp->fib_nb);
+	mlxsw_sp_router_fib_dump(mlxsw_sp);
 	return 0;
 
 err_neigh_init:
-- 
2.7.4

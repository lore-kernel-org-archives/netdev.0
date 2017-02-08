From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 14/15] mlxsw: spectrum_router: Don't reflect LINKDOWN nexthops
Date: Wed,  8 Feb 2017 11:16:41 +0100
Message-ID: <1486549002-2056-15-git-send-email-jiri@resnulli.us>
References: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35803 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751357AbdBHX2d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 18:28:33 -0500
Received: by mail-wm0-f65.google.com with SMTP id u63so508167wmu.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 15:27:18 -0800 (PST)
In-Reply-To: <1486549002-2056-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The kernel resolves the nexthops for a given route using
FIB_LOOKUP_IGNORE_LINKSTATE which means a notification can be sent for a
route with one of its nexthops being LINKDOWN.

In case IGNORE_ROUTES_WITH_LINKDOWN is set for the nexthop netdev, then
we shouldn't reflect the nexthop to the device's table.

Once the nexthop netdev's carrier goes up we'll be notified using NH_ADD
and reflect it to the device.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 1c68b40..8dfc025 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -40,6 +40,7 @@
 #include <linux/bitops.h>
 #include <linux/in6.h>
 #include <linux/notifier.h>
+#include <linux/inetdevice.h>
 #include <net/netevent.h>
 #include <net/neighbour.h>
 #include <net/arp.h>
@@ -1503,6 +1504,7 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 				 struct fib_nh *fib_nh)
 {
 	struct net_device *dev = fib_nh->nh_dev;
+	struct in_device *in_dev;
 	struct mlxsw_sp_rif *r;
 	int err;
 
@@ -1512,6 +1514,11 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		return err;
 
+	in_dev = __in_dev_get_rtnl(dev);
+	if (in_dev && IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
+	    fib_nh->nh_flags & RTNH_F_LINKDOWN)
+		return 0;
+
 	r = mlxsw_sp_rif_find_by_dev(mlxsw_sp, dev);
 	if (!r)
 		return 0;
-- 
2.7.4

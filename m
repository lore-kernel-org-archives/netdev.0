From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 05/10] mlxsw: spectrum_router: Allow more route types to be programmed
Date: Fri, 10 Mar 2017 08:53:38 +0100
Message-ID: <1489132423-12575-6-git-send-email-jiri@resnulli.us>
References: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        ivecera@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:35798 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754918AbdCJHxw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 02:53:52 -0500
Received: by mail-wm0-f65.google.com with SMTP id z63so931128wmg.2
        for <netdev@vger.kernel.org>; Thu, 09 Mar 2017 23:53:51 -0800 (PST)
In-Reply-To: <1489132423-12575-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

Allow 'unreachable', 'blackhole' and 'prohibit' route types to be
programmed into the device by sending any packet hitting them to the
CPU.

This is needed so that users will be able to program a default route
into the VRF's table, thereby preventing lookup from leaking to other
tables.

Audit the code paths to make sure we don't rely on the presence of a
nexthop netdev, as it doesn't exist for above mentioned route types.

Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 31 ++++++++++++++++------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index bd8de6b..2fc4a97 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1514,6 +1514,9 @@ static int mlxsw_sp_nexthop_init(struct mlxsw_sp *mlxsw_sp,
 	if (err)
 		return err;
 
+	if (!dev)
+		return 0;
+
 	in_dev = __in_dev_get_rtnl(dev);
 	if (in_dev && IN_DEV_IGNORE_ROUTES_WITH_LINKDOWN(in_dev) &&
 	    fib_nh->nh_flags & RTNH_F_LINKDOWN)
@@ -1877,17 +1880,29 @@ mlxsw_sp_fib4_entry_type_set(struct mlxsw_sp *mlxsw_sp,
 {
 	struct fib_info *fi = fen_info->fi;
 
-	if (fen_info->type == RTN_LOCAL || fen_info->type == RTN_BROADCAST) {
+	switch (fen_info->type) {
+	case RTN_BROADCAST: /* fall through */
+	case RTN_LOCAL:
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
 		return 0;
-	}
-	if (fen_info->type != RTN_UNICAST)
-		return -EINVAL;
-	if (fi->fib_nh->nh_scope != RT_SCOPE_LINK)
+	case RTN_UNREACHABLE: /* fall through */
+	case RTN_BLACKHOLE: /* fall through */
+	case RTN_PROHIBIT:
+		/* Packets hitting these routes need to be trapped, but
+		 * can do so with a lower priority than packets directed
+		 * at the host, so use action type local instead of trap.
+		 */
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
-	else
-		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
-	return 0;
+		return 0;
+	case RTN_UNICAST:
+		if (fi->fib_nh->nh_scope != RT_SCOPE_LINK)
+			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
+		else
+			fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_REMOTE;
+		return 0;
+	default:
+		return -EINVAL;
+	}
 }
 
 static struct mlxsw_sp_fib_entry *
-- 
2.7.4

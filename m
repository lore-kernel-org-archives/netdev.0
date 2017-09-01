From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 1/2] mlxsw: spectrum_router: Trap packets hitting anycast routes
Date: Fri,  1 Sep 2017 10:58:55 +0200
Message-ID: <20170901085856.2286-2-jiri@resnulli.us>
References: <20170901085856.2286-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:37323 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751503AbdIAI7B (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 04:59:01 -0400
Received: by mail-wm0-f66.google.com with SMTP id x189so1853158wmg.4
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 01:59:00 -0700 (PDT)
In-Reply-To: <20170901085856.2286-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

I relied on the fact that anycast routes use the loopback device as
their nexthop device to trap packets hitting them to the CPU.

After commit 4832c30d5458 ("net: ipv6: put host and anycast routes on
device with address") this is no longer the case and such routes are
programmed with a forward action (note the 'offload' flag):

anycast cafe:: dev enp3s0np7 proto kernel metric 0 offload pref medium

This will prevent the router from locally receiving packets destined to
the Subnet-Router anycast address.

Fix this by specifically programming anycast routes with action trap,
which results in the following output:

anycast cafe:: dev enp3s0np7 proto kernel metric 0 pref medium

Fixes: 4832c30d5458 ("net: ipv6: put host and anycast routes on device with address")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 0cf6810..00e3aec 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -3659,7 +3659,7 @@ static void mlxsw_sp_fib6_entry_type_set(struct mlxsw_sp_fib_entry *fib_entry,
 	 * local, which will cause them to be trapped with a lower
 	 * priority than packets that need to be locally received.
 	 */
-	if (rt->rt6i_flags & RTF_LOCAL)
+	if (rt->rt6i_flags & (RTF_LOCAL | RTF_ANYCAST))
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_TRAP;
 	else if (rt->rt6i_flags & RTF_REJECT)
 		fib_entry->type = MLXSW_SP_FIB_ENTRY_TYPE_LOCAL;
-- 
2.9.3

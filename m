From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net] mlxsw: spectrum_router: Only handle IPv4 and IPv6 events
Date: Fri, 15 Sep 2017 15:31:07 +0200
Message-ID: <20170915133107.1258-1-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, flokli@flokli.de,
        andreas@rammhold.de, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:37142 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751352AbdIONbL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 15 Sep 2017 09:31:11 -0400
Received: by mail-wm0-f65.google.com with SMTP id f4so2797079wmh.4
        for <netdev@vger.kernel.org>; Fri, 15 Sep 2017 06:31:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

The driver doesn't support events from address families other than IPv4
and IPv6, so ignore them. Otherwise, we risk queueing a work item before
it's initialized.

This can happen in case a VRF is configured when MROUTE_MULTIPLE_TABLES
is enabled, as the VRF driver will try to add an l3mdev rule for the
IPMR family.

Fixes: 65e65ec137f4 ("mlxsw: spectrum_router: Don't ignore IPv6 notifications")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Reported-by: Andreas Rammhold <andreas@rammhold.de>
Reported-by: Florian Klink <flokli@flokli.de>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index f0fb898..2cfb3f5 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -4868,7 +4868,8 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct fib_notifier_info *info = ptr;
 	struct mlxsw_sp_router *router;
 
-	if (!net_eq(info->net, &init_net))
+	if (!net_eq(info->net, &init_net) ||
+	    (info->family != AF_INET && info->family != AF_INET6))
 		return NOTIFY_DONE;
 
 	fib_work = kzalloc(sizeof(*fib_work), GFP_ATOMIC);
-- 
2.9.3

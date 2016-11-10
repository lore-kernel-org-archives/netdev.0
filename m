From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 2/2] mlxsw: spectrum_router: Ignore FIB notification events for non-init namespaces
Date: Thu, 10 Nov 2016 12:31:05 +0100
Message-ID: <1478777465-6567-3-git-send-email-jiri@resnulli.us>
References: <1478777465-6567-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, ogerlitz@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:35692 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754684AbcKJLbK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Nov 2016 06:31:10 -0500
Received: by mail-wm0-f66.google.com with SMTP id a20so2510081wme.2
        for <netdev@vger.kernel.org>; Thu, 10 Nov 2016 03:31:10 -0800 (PST)
In-Reply-To: <1478777465-6567-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Since now, the table with same id in multiple netnamespaces were squashed
to a single virtual router. That is not only incorrect, it also causes
error messages when trying to use RALUE register to do double remove
of FIB entries, like this one:

mlxsw_spectrum 0000:03:00.0: EMAD reg access failed (tid=facb831c00007b20,reg_id=8013(ralue),type=write,status=7(bad parameter))

Since we don't allow ports to change namespaces (NETIF_F_NETNS_LOCAL),
and the infrastructure is not yet prepared to handle netnamespaces, just
ignore FIB notification events for non-init namespaces. That is clear to
do since we don't need to offload them.

Fixes: b45f64d16d45 ("mlxsw: spectrum_router: Use FIB notifications instead of switchdev calls")
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
Acked-by: Ido Schimmel <idosch@mellanox.com>
---
v1->v2:
- use net_eq
---
 drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2863012..040737e 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -1931,6 +1931,9 @@ static int mlxsw_sp_router_fib_event(struct notifier_block *nb,
 	struct fib_entry_notifier_info *fen_info = ptr;
 	int err;
 
+	if (!net_eq(fen_info->info.net, &init_net))
+		return NOTIFY_DONE;
+
 	switch (event) {
 	case FIB_EVENT_ENTRY_ADD:
 		err = mlxsw_sp_router_fib4_add(mlxsw_sp, fen_info);
-- 
2.7.4

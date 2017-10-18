From: David Ahern <dsahern@gmail.com>
Subject: [PATCH net-next] spectrum: Convert fib event handlers to use container_of on info arg
Date: Wed, 18 Oct 2017 15:01:38 -0700
Message-ID: <1508364098-29621-1-git-send-email-dsahern@gmail.com>
Cc: jiri@mellanox.com, idosch@mellanox.com,
        David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:44925 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750880AbdJRWBp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 18:01:45 -0400
Received: by mail-pf0-f194.google.com with SMTP id x7so4964235pfa.1
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 15:01:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use container_of to convert the generic fib_notifier_info into
the event specific data structure.

Signed-off-by: David Ahern <dsahern@gmail.com>
Reviewed-by: Ido Schimmel <idosch@mellanox.com>
---
 .../net/ethernet/mellanox/mlxsw/spectrum_router.c  | 29 +++++++++++++++++-----
 1 file changed, 23 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
index 2420f69797a9..12d471d2a90b 100644
--- a/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
+++ b/drivers/net/ethernet/mellanox/mlxsw/spectrum_router.c
@@ -5209,25 +5209,35 @@ static void mlxsw_sp_router_fibmr_event_work(struct work_struct *work)
 static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
+	struct fib_entry_notifier_info *fen_info;
+	struct fib_rule_notifier_info *fr_info;
+	struct fib_nh_notifier_info *fnh_info;
+
 	switch (fib_work->event) {
 	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
 	case FIB_EVENT_ENTRY_APPEND: /* fall through */
 	case FIB_EVENT_ENTRY_ADD: /* fall through */
 	case FIB_EVENT_ENTRY_DEL:
-		memcpy(&fib_work->fen_info, info, sizeof(fib_work->fen_info));
-		/* Take referece on fib_info to prevent it from being
+		fen_info = container_of(info, struct fib_entry_notifier_info,
+					info);
+		fib_work->fen_info = *fen_info;
+		/* Take reference on fib_info to prevent it from being
 		 * freed while work is queued. Release it afterwards.
 		 */
 		fib_info_hold(fib_work->fen_info.fi);
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		memcpy(&fib_work->fr_info, info, sizeof(fib_work->fr_info));
+		fr_info = container_of(info, struct fib_rule_notifier_info,
+				       info);
+		fib_work->fr_info = *fr_info;
 		fib_rule_get(fib_work->fr_info.rule);
 		break;
 	case FIB_EVENT_NH_ADD: /* fall through */
 	case FIB_EVENT_NH_DEL:
-		memcpy(&fib_work->fnh_info, info, sizeof(fib_work->fnh_info));
+		fnh_info = container_of(info, struct fib_nh_notifier_info,
+					info);
+		fib_work->fnh_info = *fnh_info;
 		fib_info_hold(fib_work->fnh_info.fib_nh->nh_parent);
 		break;
 	}
@@ -5236,16 +5246,23 @@ static void mlxsw_sp_router_fib4_event(struct mlxsw_sp_fib_event_work *fib_work,
 static void mlxsw_sp_router_fib6_event(struct mlxsw_sp_fib_event_work *fib_work,
 				       struct fib_notifier_info *info)
 {
+	struct fib6_entry_notifier_info *fen6_info;
+	struct fib_rule_notifier_info *fr_info;
+
 	switch (fib_work->event) {
 	case FIB_EVENT_ENTRY_REPLACE: /* fall through */
 	case FIB_EVENT_ENTRY_ADD: /* fall through */
 	case FIB_EVENT_ENTRY_DEL:
-		memcpy(&fib_work->fen6_info, info, sizeof(fib_work->fen6_info));
+		fen6_info = container_of(info, struct fib6_entry_notifier_info,
+					 info);
+		fib_work->fen6_info = *fen6_info;
 		rt6_hold(fib_work->fen6_info.rt);
 		break;
 	case FIB_EVENT_RULE_ADD: /* fall through */
 	case FIB_EVENT_RULE_DEL:
-		memcpy(&fib_work->fr_info, info, sizeof(fib_work->fr_info));
+		fr_info = container_of(info, struct fib_rule_notifier_info,
+				       info);
+		fib_work->fr_info = *fr_info;
 		fib_rule_get(fib_work->fr_info.rule);
 		break;
 	}
-- 
2.1.4

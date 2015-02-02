From: Siva Mannem <siva.mannem.lnx@gmail.com>
Subject: [PATCH net-next] bridge: Let bridge not age 'externally' learnt FDB entries, they are removed when 'external' entity notifies the aging
Date: Mon,  2 Feb 2015 22:51:54 +0530
Message-ID: <1422897714-5956-1-git-send-email-siva.mannem.lnx@gmail.com>
Cc: Siva Mannem <siva.mannem.lnx@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:44736 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbbBBRWL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Feb 2015 12:22:11 -0500
Received: by mail-pa0-f48.google.com with SMTP id ey11so84857437pad.7
        for <netdev@vger.kernel.org>; Mon, 02 Feb 2015 09:22:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

 When 'learned_sync' flag is turned on, the offloaded switch
 port syncs learned MAC addresses to bridge's FDB via switchdev notifier
 (NETDEV_SWITCH_FDB_ADD). Currently, FDB entries learnt via this mechanism are
 wrongly being deleted by bridge aging logic. This patch ensures that FDB
 entries synced from offloaded switch ports are not deleted by bridging logic.
 Such entries can only be deleted via switchdev notifier
 (NETDEV_SWITCH_FDB_DEL).

Signed-off-by: Siva Mannem <siva.mannem.lnx@gmail.com>
---
 net/bridge/br_fdb.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/bridge/br_fdb.c b/net/bridge/br_fdb.c
index 08bf04b..6eb94b5 100644
--- a/net/bridge/br_fdb.c
+++ b/net/bridge/br_fdb.c
@@ -280,7 +280,7 @@ void br_fdb_cleanup(unsigned long _data)
 
 		hlist_for_each_entry_safe(f, n, &br->hash[i], hlist) {
 			unsigned long this_timer;
-			if (f->is_static)
+			if (f->is_static || f->added_by_external_learn)
 				continue;
 			this_timer = f->updated + delay;
 			if (time_before_eq(this_timer, jiffies))
-- 
2.1.0

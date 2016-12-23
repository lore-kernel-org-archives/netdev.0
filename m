From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net 1/3] neigh: Send netevent after marking neigh as dead
Date: Fri, 23 Dec 2016 09:32:48 +0100
Message-ID: <1482481970-2327-2-git-send-email-jiri@resnulli.us>
References: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
        yotamg@mellanox.com, nogahf@mellanox.com, arkadis@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:35188 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754810AbcLWIcy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Dec 2016 03:32:54 -0500
Received: by mail-wm0-f68.google.com with SMTP id l2so14688637wml.2
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2016 00:32:53 -0800 (PST)
In-Reply-To: <1482481970-2327-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ido Schimmel <idosch@mellanox.com>

neigh_cleanup_and_release() is always called after marking a neighbour
as dead, but it only notifies user space and not in-kernel listeners of
the netevent notification chain.

This can cause multiple problems. In my specific use case, it causes the
listener (a switch driver capable of L3 offloads) to believe a neighbour
entry is still valid, and is thus erroneously kept in the device's
table.

Fix that by sending a netevent after marking the neighbour as dead.

Fixes: a6bf9e933daf ("mlxsw: spectrum_router: Offload neighbours based on NUD state change")
Signed-off-by: Ido Schimmel <idosch@mellanox.com>
Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/neighbour.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 782dd86..7bb12e0 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -100,6 +100,7 @@ static void neigh_cleanup_and_release(struct neighbour *neigh)
 		neigh->parms->neigh_cleanup(neigh);
 
 	__neigh_notify(neigh, RTM_DELNEIGH, 0);
+	call_netevent_notifiers(NETEVENT_NEIGH_UPDATE, neigh);
 	neigh_release(neigh);
 }
 
-- 
2.7.4

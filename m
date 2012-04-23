From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net] net/neigh: move neigh cleanup routine to neigh_destroy
Date: Mon, 23 Apr 2012 18:34:42 +0300
Message-ID: <1335195282-28738-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Shlomo Pongratz <shlomop@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog107.obsmtp.com ([207.126.144.123]:35008 "HELO
	eu1sys200aog107.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753251Ab2DWPey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 11:34:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>

Move call the neigh_cleanup call to be done from neigh_destroy, this
ensures the cleanup callback is invoked only when the neighbour reference
count becomes zero (e.g in the same manner as ndo_neigh_destory).

Note that with this change neigh_destroy will truly revert the action of
neigh_create, as neigh_release which calls neigh_destroy is called directly
from various code paths, and thus neigh->parms->neigh_cleanup is not called
for these code paths.

Also, with commit 7d26bb103 "bonding: emit event when bonding changes MAC" that
triggers netdev address change event, a race was introduced since neigh cleanup
can be called when there's reference on the neighbour.

Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/core/neighbour.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 0a68045..f4a4e64 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -106,9 +106,6 @@ static int neigh_blackhole(struct neighbour *neigh, struct sk_buff *skb)
 
 static void neigh_cleanup_and_release(struct neighbour *neigh)
 {
-	if (neigh->parms->neigh_cleanup)
-		neigh->parms->neigh_cleanup(neigh);
-
 	__neigh_notify(neigh, RTM_DELNEIGH, 0);
 	neigh_release(neigh);
 }
@@ -724,6 +721,9 @@ void neigh_destroy(struct neighbour *neigh)
 	skb_queue_purge(&neigh->arp_queue);
 	neigh->arp_queue_len_bytes = 0;
 
+	if (neigh->parms->neigh_cleanup)
+		neigh->parms->neigh_cleanup(neigh);
+
 	if (dev->netdev_ops->ndo_neigh_destroy)
 		dev->netdev_ops->ndo_neigh_destroy(neigh);
 
-- 
1.7.1

From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 2/3] ipv4: ipmr: fix invalid cache resolving when adding a non-matching entry
Date: Thu, 15 Apr 2010 14:47:57 +0200
Message-ID: <1271335678-20961-3-git-send-email-kaber@trash.net>
References: <1271335678-20961-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:63170 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab0DOMsD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 08:48:03 -0400
In-Reply-To: <1271335678-20961-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The patch to convert struct mfc_cache to list_heads (ipv4: ipmr: convert
struct mfc_cache to struct list_head) introduced a bug when adding new
cache entries that don't match any unresolved entries.

The unres queue is searched for a matching entry, which is then resolved.
When no matching entry is present, the iterator points to the head of the
list, but is treated as a matching entry. Use a seperate variable to
indicate that a matching entry was found.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/ipmr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5df5fd7..0643fb6 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1089,12 +1089,14 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 	 *	Check to see if we resolved a queued list. If so we
 	 *	need to send on the frames and tidy up.
 	 */
+	found = false;
 	spin_lock_bh(&mfc_unres_lock);
 	list_for_each_entry(uc, &mrt->mfc_unres_queue, list) {
 		if (uc->mfc_origin == c->mfc_origin &&
 		    uc->mfc_mcastgrp == c->mfc_mcastgrp) {
 			list_del(&uc->list);
 			atomic_dec(&mrt->cache_resolve_queue_len);
+			found = true;
 			break;
 		}
 	}
@@ -1102,7 +1104,7 @@ static int ipmr_mfc_add(struct net *net, struct mr_table *mrt,
 		del_timer(&mrt->ipmr_expire_timer);
 	spin_unlock_bh(&mfc_unres_lock);
 
-	if (uc) {
+	if (found) {
 		ipmr_cache_resolve(net, mrt, uc, c);
 		ipmr_cache_free(uc);
 	}
-- 
1.7.0.4


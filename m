From: Sorin Dumitru <sorin@returnze.ro>
Subject: [PATCH net-next] vxlan: release lock after each bucket in vxlan_cleanup
Date: Tue, 26 May 2015 10:42:04 +0300
Message-ID: <1432626124-24676-1-git-send-email-sorin@returnze.ro>
Cc: davem@davemloft.net, Sorin Dumitru <sorin@returnze.ro>,
	Sorin Dumitru <sdumitru@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:34950 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbbEZHmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 03:42:16 -0400
Received: by wgme6 with SMTP id e6so20422429wgm.2
        for <netdev@vger.kernel.org>; Tue, 26 May 2015 00:42:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We're seeing some softlockups from this function when there
are a lot fdb entries on a vxlan device. Taking the lock for
each bucket instead of the whole table is enough to fix that.

Signed-off-by: Sorin Dumitru <sdumitru@ixiacom.com>
---
 drivers/net/vxlan.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 5eddbc0..34c519e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2131,9 +2131,10 @@ static void vxlan_cleanup(unsigned long arg)
 	if (!netif_running(vxlan->dev))
 		return;
 
-	spin_lock_bh(&vxlan->hash_lock);
 	for (h = 0; h < FDB_HASH_SIZE; ++h) {
 		struct hlist_node *p, *n;
+
+		spin_lock_bh(&vxlan->hash_lock);
 		hlist_for_each_safe(p, n, &vxlan->fdb_head[h]) {
 			struct vxlan_fdb *f
 				= container_of(p, struct vxlan_fdb, hlist);
@@ -2152,8 +2153,8 @@ static void vxlan_cleanup(unsigned long arg)
 			} else if (time_before(timeout, next_timer))
 				next_timer = timeout;
 		}
+		spin_unlock_bh(&vxlan->hash_lock);
 	}
-	spin_unlock_bh(&vxlan->hash_lock);
 
 	mod_timer(&vxlan->age_timer, next_timer);
 }
-- 
2.4.1

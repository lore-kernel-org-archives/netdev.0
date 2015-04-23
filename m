From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] rhashtable: don't attempt to grow when at max_size
Date: Thu, 23 Apr 2015 16:38:43 +0200
Message-ID: <1429799923-28122-1-git-send-email-johannes@sipsolutions.net>
Cc: Patrick McHardy <kaber@trash.net>, Thomas Graf <tgraf@suug.ch>,
	Johannes Berg <johannes.berg@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:34786 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964922AbbDWOir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Apr 2015 10:38:47 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

The conversion of mac80211's station table to rhashtable had a bug
that I found by accident in code review, that hadn't been found as
rhashtable apparently managed to have a maximum hash chain length
of one (!) in all our testing.

In order to test the bug and verify the fix I set my rhashtable's
max_size very low (4) in order to force getting hash collisions.

At that point, rhashtable WARNed in rhashtable_insert_rehash() but
didn't actually reject the hash table insertion. This caused it to
lose insertions - my master list of stations would have 9 entries,
but the rhashtable only had 5. This may warrant a deeper look, but
that WARN_ON() just shouldn't happen.

Fix this by not returning true from rht_grow_above_100() when the
rhashtable's max_size has been reached - in this case the user is
explicitly configuring it to be at most that big, so even if it's
now above 100% it shouldn't attempt to resize.

This fixes the "lost insertion" issue and consequently allows my
code to display its error (and verify my fix for it.)

Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
 include/linux/rhashtable.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/include/linux/rhashtable.h b/include/linux/rhashtable.h
index e23d242d1230..dbcbcc59aa92 100644
--- a/include/linux/rhashtable.h
+++ b/include/linux/rhashtable.h
@@ -282,7 +282,8 @@ static inline bool rht_shrink_below_30(const struct rhashtable *ht,
 static inline bool rht_grow_above_100(const struct rhashtable *ht,
 				      const struct bucket_table *tbl)
 {
-	return atomic_read(&ht->nelems) > tbl->size;
+	return atomic_read(&ht->nelems) > tbl->size &&
+		(!ht->p.max_size || tbl->size < ht->p.max_size);
 }
 
 /* The bucket lock is selected based on the hash and protects mutations
-- 
2.1.4

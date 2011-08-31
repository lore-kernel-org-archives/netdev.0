From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net: Make flow cache namespace-aware
Date: Wed, 31 Aug 2011 12:05:27 -0400
Message-ID: <1314806727-5340-1-git-send-email-david.ward@ll.mit.edu>
References: <AANLkTinZJ9REmG0pHCVzEZ=tN-R4WuiQunuCBhmYtzyb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>,
	Andrew Dickinson <whydna@whydna.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:38431 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756233Ab1HaQX3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Aug 2011 12:23:29 -0400
In-Reply-To: <AANLkTinZJ9REmG0pHCVzEZ=tN-R4WuiQunuCBhmYtzyb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

flow_cache_lookup will return a cached object (or null pointer) that the
resolver (i.e. xfrm_policy_lookup) previously found for another namespace
using the same key/family/dir.  Instead, make the namespace part of what
identifies entries in the cache.

As before, flow_entry_valid will return 0 for entries where the namespace
has been deleted, and they will be removed from the cache the next time
flow_cache_gc_task is run.

Reported-by: Andrew Dickinson <whydna@whydna.net>
Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/core/flow.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/core/flow.c b/net/core/flow.c
index bf32c33..47b6d26 100644
--- a/net/core/flow.c
+++ b/net/core/flow.c
@@ -30,6 +30,7 @@ struct flow_cache_entry {
 		struct hlist_node	hlist;
 		struct list_head	gc_list;
 	} u;
+	struct net			*net;
 	u16				family;
 	u8				dir;
 	u32				genid;
@@ -232,7 +233,8 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 
 	hash = flow_hash_code(fc, fcp, key);
 	hlist_for_each_entry(tfle, entry, &fcp->hash_table[hash], u.hlist) {
-		if (tfle->family == family &&
+		if (tfle->net == net &&
+		    tfle->family == family &&
 		    tfle->dir == dir &&
 		    flow_key_compare(key, &tfle->key) == 0) {
 			fle = tfle;
@@ -246,6 +248,7 @@ flow_cache_lookup(struct net *net, const struct flowi *key, u16 family, u8 dir,
 
 		fle = kmem_cache_alloc(flow_cachep, GFP_ATOMIC);
 		if (fle) {
+			fle->net = net;
 			fle->family = family;
 			fle->dir = dir;
 			memcpy(&fle->key, key, sizeof(*key));
-- 
1.7.4.1

From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 3/6] xfrm: state: delay freeing until rcu grace period has elapsed
Date: Tue,  9 Aug 2016 12:16:06 +0200
Message-ID: <1470737769-30438-4-git-send-email-fw@strlen.de>
References: <1470737769-30438-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:43908 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751592AbcHIKQf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 06:16:35 -0400
In-Reply-To: <1470737769-30438-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The hash table backend memory and the state structs are free'd via
kfree/vfree.

Once we only rely on rcu during lookups we have to make sure no other cpu
is currently accessing this before doing the free.

Free operations already happen from worker so we can use synchronize_rcu
to wait until concurrent readers are done.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/xfrm/xfrm_state.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
index 84c1db6..8e37387 100644
--- a/net/xfrm/xfrm_state.c
+++ b/net/xfrm/xfrm_state.c
@@ -146,6 +146,9 @@ static void xfrm_hash_resize(struct work_struct *work)
 	spin_unlock_bh(&net->xfrm.xfrm_state_lock);
 
 	osize = (ohashmask + 1) * sizeof(struct hlist_head);
+
+	synchronize_rcu();
+
 	xfrm_hash_free(odst, osize);
 	xfrm_hash_free(osrc, osize);
 	xfrm_hash_free(ospi, osize);
@@ -369,6 +372,8 @@ static void xfrm_state_gc_task(struct work_struct *work)
 	hlist_move_list(&net->xfrm.state_gc_list, &gc_list);
 	spin_unlock_bh(&xfrm_state_gc_lock);
 
+	synchronize_rcu();
+
 	hlist_for_each_entry_safe(x, tmp, &gc_list, gclist)
 		xfrm_state_gc_destroy(x);
 }
-- 
2.7.3

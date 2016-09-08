From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 04/17] xfrm: state: delay freeing until rcu grace period has elapsed
Date: Thu, 8 Sep 2016 07:54:39 +0200
Message-ID: <1473314092-11319-5-git-send-email-steffen.klassert@secunet.com>
References: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36352 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753871AbcIHGvZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:25 -0400
In-Reply-To: <1473314092-11319-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

The hash table backend memory and the state structs are free'd via
kfree/vfree.

Once we only rely on rcu during lookups we have to make sure no other cpu
is currently accessing this before doing the free.

Free operations already happen from worker so we can use synchronize_rcu
to wait until concurrent readers are done.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
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
1.9.1

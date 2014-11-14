From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 8/8] netfilter: conntrack: fix race in __nf_conntrack_confirm against get_next_corpse
Date: Fri, 14 Nov 2014 17:58:49 +0100
Message-ID: <1415984329-5569-10-git-send-email-pablo@netfilter.org>
References: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1415984329-5569-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: bill bonaparte <programme110@gmail.com>

After removal of the central spinlock nf_conntrack_lock, in
commit 93bb0ceb75be2 ("netfilter: conntrack: remove central
spinlock nf_conntrack_lock"), it is possible to race against
get_next_corpse().

The race is against the get_next_corpse() cleanup on
the "unconfirmed" list (a per-cpu list with seperate locking),
which set the DYING bit.

Fix this race, in __nf_conntrack_confirm(), by removing the CT
from unconfirmed list before checking the DYING bit.  In case
race occured, re-add the CT to the dying list.

While at this, fix coding style of the comment that has been
updated.

Fixes: 93bb0ceb75be2 ("netfilter: conntrack: remove central spinlock nf_conntrack_lock")
Reported-by: bill bonaparte <programme110@gmail.com>
Signed-off-by: bill bonaparte <programme110@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 net/netfilter/nf_conntrack_core.c |   14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5016a69..2c69975 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -611,12 +611,16 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 */
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
 	pr_debug("Confirming conntrack %p\n", ct);
-	/* We have to check the DYING flag inside the lock to prevent
-	   a race against nf_ct_get_next_corpse() possibly called from
-	   user context, else we insert an already 'dead' hash, blocking
-	   further use of that particular connection -JM */
+
+	/* We have to check the DYING flag after unlink to prevent
+	 * a race against nf_ct_get_next_corpse() possibly called from
+	 * user context, else we insert an already 'dead' hash, blocking
+	 * further use of that particular connection -JM.
+	 */
+	nf_ct_del_from_dying_or_unconfirmed_list(ct);
 
 	if (unlikely(nf_ct_is_dying(ct))) {
+		nf_ct_add_to_dying_list(ct);
 		nf_conntrack_double_unlock(hash, reply_hash);
 		local_bh_enable();
 		return NF_ACCEPT;
@@ -636,8 +640,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
 
-	nf_ct_del_from_dying_or_unconfirmed_list(ct);
-
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
 	   weird delay cases. */
-- 
1.7.10.4


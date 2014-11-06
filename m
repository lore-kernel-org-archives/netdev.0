From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: [PATCH nf] netfilter: conntrack: fix race in __nf_conntrack_confirm
	against get_next_corpse
Date: Thu, 06 Nov 2014 14:36:48 +0100
Message-ID: <20141106133648.2534.1403.stgit@dragon>
References: <012601cff7d1$7ce2d620$76a88260$@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	programme110@gmail.com, netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <012601cff7d1$7ce2d620$76a88260$@gmail.com>
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

Fixes: 93bb0ceb75be2 ("netfilter: conntrack: remove central spinlock nf_conntrack_lock")
Reported-by: bill bonaparte <programme110@gmail.com>
Signed-off-by: bill bonaparte <programme110@gmail.com>
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---

 net/netfilter/nf_conntrack_core.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 5016a69..1072650 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -611,12 +611,15 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	 */
 	NF_CT_ASSERT(!nf_ct_is_confirmed(ct));
 	pr_debug("Confirming conntrack %p\n", ct);
-	/* We have to check the DYING flag inside the lock to prevent
+
+	/* We have to check the DYING flag after unlink to prevent
 	   a race against nf_ct_get_next_corpse() possibly called from
 	   user context, else we insert an already 'dead' hash, blocking
 	   further use of that particular connection -JM */
+	nf_ct_del_from_dying_or_unconfirmed_list(ct);
 
 	if (unlikely(nf_ct_is_dying(ct))) {
+		nf_ct_add_to_dying_list(ct);
 		nf_conntrack_double_unlock(hash, reply_hash);
 		local_bh_enable();
 		return NF_ACCEPT;
@@ -636,8 +639,6 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
 
-	nf_ct_del_from_dying_or_unconfirmed_list(ct);
-
 	/* Timer relative to confirmation time, not original
 	   setting time, otherwise we'd get timer wrap in
 	   weird delay cases. */


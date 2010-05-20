From: kaber@trash.net
Subject: [PATCH 2/3] netfilter: nf_conntrack: fix a race in __nf_conntrack_confirm against nf_ct_get_next_corpse()
Date: Thu, 20 May 2010 18:00:45 +0200
Message-ID: <1274371246-26760-3-git-send-email-kaber@trash.net>
References: <1274371246-26760-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1274371246-26760-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joerg Marx <joerg.marx@secunet.com>

This race was triggered by a 'conntrack -F' command running in parallel
to the insertion of a hash for a new connection. Losing this race led to
a dead conntrack entry effectively blocking traffic for a particular
connection until timeout or flushing the conntrack hashes again.
Now the check for an already dying connection is done inside the lock.

Signed-off-by: Joerg Marx <joerg.marx@secunet.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/netfilter/nf_conntrack_core.h |    2 +-
 net/netfilter/nf_conntrack_core.c         |   10 ++++++++++
 2 files changed, 11 insertions(+), 1 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index dffde8e..3d7524f 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -61,7 +61,7 @@ static inline int nf_conntrack_confirm(struct sk_buff *skb)
 	int ret = NF_ACCEPT;
 
 	if (ct && ct != &nf_conntrack_untracked) {
-		if (!nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct))
+		if (!nf_ct_is_confirmed(ct))
 			ret = __nf_conntrack_confirm(skb);
 		if (likely(ret == NF_ACCEPT))
 			nf_ct_deliver_cached_events(ct);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index b83c530..eeeb8bc 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -424,6 +424,16 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 
 	spin_lock_bh(&nf_conntrack_lock);
 
+	/* We have to check the DYING flag inside the lock to prevent
+	   a race against nf_ct_get_next_corpse() possibly called from
+	   user context, else we insert an already 'dead' hash, blocking
+	   further use of that particular connection -JM */
+
+	if (unlikely(nf_ct_is_dying(ct))) {
+		spin_unlock_bh(&nf_conntrack_lock);
+		return NF_ACCEPT;
+	}
+
 	/* See if there's one in the list already, including reverse:
 	   NAT could have grabbed it without realizing, since we're
 	   not in the hash.  If there is, we lost race. */
-- 
1.7.0.4


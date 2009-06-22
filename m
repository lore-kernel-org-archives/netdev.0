From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 03/07: nf_conntrack: fix conntrack lookup race
Date: Mon, 22 Jun 2009 14:53:53 +0200 (MEST)
Message-ID: <20090622125353.6531.83797.sendpatchset@x2.localnet>
References: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090622125349.6531.35515.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 8d8890b7751387f58ce0a6428773de2fbc0fd596
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Jun 22 14:14:41 2009 +0200

    netfilter: nf_conntrack: fix conntrack lookup race
    
    The RCU protected conntrack hash lookup only checks whether the entry
    has a refcount of zero to decide whether it is stale. This is not
    sufficient, entries are explicitly removed while there is at least
    one reference left, possibly more. Explicitly check whether the entry
    has been marked as dying to fix this.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index b0b06c7..7508f11 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -335,7 +335,8 @@ begin:
 	h = __nf_conntrack_find(net, tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
-		if (unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		if (unlikely(nf_ct_is_dying(ct) ||
+			     !atomic_inc_not_zero(&ct->ct_general.use)))
 			h = NULL;
 		else {
 			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple))) {
@@ -510,7 +511,8 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 			cnt++;
 		}
 
-		if (ct && unlikely(!atomic_inc_not_zero(&ct->ct_general.use)))
+		if (ct && unlikely(nf_ct_is_dying(ct) ||
+				   !atomic_inc_not_zero(&ct->ct_general.use)))
 			ct = NULL;
 		if (ct || cnt >= NF_CT_EVICTION_RANGE)
 			break;

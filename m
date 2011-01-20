From: kaber@trash.net
Subject: [PATCH 4/7] netfilter: nf_nat: place conntrack in source hash after SNAT is done
Date: Thu, 20 Jan 2011 21:22:43 +0100
Message-ID: <1295554966-5263-5-git-send-email-kaber@trash.net>
References: <1295554966-5263-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>,
	Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1295554966-5263-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Changli Gao <xiaosuo@gmail.com>

If SNAT isn't done, the wrong info maybe got by the other cts.

As the filter table is after DNAT table, the packets dropped in filter
table also bother bysource hash table.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/ipv4/netfilter/nf_nat_core.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index 3002c04..21bcf47 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -221,7 +221,14 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	   manips not an issue.  */
 	if (maniptype == IP_NAT_MANIP_SRC &&
 	    !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
-		if (find_appropriate_src(net, zone, orig_tuple, tuple, range)) {
+		/* try the original tuple first */
+		if (in_range(orig_tuple, range)) {
+			if (!nf_nat_used_tuple(orig_tuple, ct)) {
+				*tuple = *orig_tuple;
+				return;
+			}
+		} else if (find_appropriate_src(net, zone, orig_tuple, tuple,
+			   range)) {
 			pr_debug("get_unique_tuple: Found current src map\n");
 			if (!nf_nat_used_tuple(tuple, ct))
 				return;
@@ -266,7 +273,6 @@ nf_nat_setup_info(struct nf_conn *ct,
 	struct net *net = nf_ct_net(ct);
 	struct nf_conntrack_tuple curr_tuple, new_tuple;
 	struct nf_conn_nat *nat;
-	int have_to_hash = !(ct->status & IPS_NAT_DONE_MASK);
 
 	/* nat helper or nfctnetlink also setup binding */
 	nat = nfct_nat(ct);
@@ -306,8 +312,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 			ct->status |= IPS_DST_NAT;
 	}
 
-	/* Place in source hash if this is the first time. */
-	if (have_to_hash) {
+	if (maniptype == IP_NAT_MANIP_SRC) {
 		unsigned int srchash;
 
 		srchash = hash_by_src(net, nf_ct_zone(ct),
@@ -535,7 +540,7 @@ static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
 	if (nat == NULL || nat->ct == NULL)
 		return;
 
-	NF_CT_ASSERT(nat->ct->status & IPS_NAT_DONE_MASK);
+	NF_CT_ASSERT(nat->ct->status & IPS_SRC_NAT_DONE);
 
 	spin_lock_bh(&nf_nat_lock);
 	hlist_del_rcu(&nat->bysource);
@@ -548,11 +553,10 @@ static void nf_nat_move_storage(void *new, void *old)
 	struct nf_conn_nat *old_nat = old;
 	struct nf_conn *ct = old_nat->ct;
 
-	if (!ct || !(ct->status & IPS_NAT_DONE_MASK))
+	if (!ct || !(ct->status & IPS_SRC_NAT_DONE))
 		return;
 
 	spin_lock_bh(&nf_nat_lock);
-	new_nat->ct = ct;
 	hlist_replace_rcu(&old_nat->bysource, &new_nat->bysource);
 	spin_unlock_bh(&nf_nat_lock);
 }
-- 
1.7.3.4


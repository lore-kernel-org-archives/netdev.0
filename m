From: Patrick McHardy <kaber@trash.net>
Subject: netfilter -stable 02/02: xt_connlimit: fix regression caused by zero family value
Date: Tue, 10 Nov 2009 11:40:21 +0100 (MET)
Message-ID: <20091110104017.8250.88301.sendpatchset@x2.localnet>
References: <20091110104014.8250.89589.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net
To: stable@kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20091110104014.8250.89589.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 4dcaa8fa124a6d8ab0f64dc1c289b13a724f8fc1
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Nov 10 10:53:33 2009 +0100

    netfilter: xt_connlimit: fix regression caused by zero family value
    
    Upstream commit 539054a8:
    
    Commit v2.6.28-rc1~717^2~109^2~2 was slightly incomplete; not all
    instances of par->match->family were changed to par->family.
    
    References: http://bugzilla.netfilter.org/show_bug.cgi?id=610
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 6809809..38f03f7 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -103,7 +103,7 @@ static int count_them(struct xt_connlimit_data *data,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr,
 		      const union nf_inet_addr *mask,
-		      const struct xt_match *match)
+		      u_int8_t family)
 {
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
@@ -113,8 +113,7 @@ static int count_them(struct xt_connlimit_data *data,
 	bool addit = true;
 	int matches = 0;
 
-
-	if (match->family == NFPROTO_IPV6)
+	if (family == NFPROTO_IPV6)
 		hash = &data->iphash[connlimit_iphash6(addr, mask)];
 	else
 		hash = &data->iphash[connlimit_iphash(addr->ip & mask->ip)];
@@ -157,8 +156,7 @@ static int count_them(struct xt_connlimit_data *data,
 			continue;
 		}
 
-		if (same_source_net(addr, mask, &conn->tuple.src.u3,
-		    match->family))
+		if (same_source_net(addr, mask, &conn->tuple.src.u3, family))
 			/* same source network -> be counted! */
 			++matches;
 		nf_ct_put(found_ct);
@@ -207,7 +205,7 @@ connlimit_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 
 	spin_lock_bh(&info->data->lock);
 	connections = count_them(info->data, tuple_ptr, &addr,
-	                         &info->mask, par->match);
+	                         &info->mask, par->family);
 	spin_unlock_bh(&info->data->lock);
 
 	if (connections < 0) {

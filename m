From: kaber@trash.net
Subject: [PATCH 02/13] netfilter: xt_connlimit: connlimit-above early loop termination
Date: Wed,  2 Mar 2011 13:12:42 +0100
Message-ID: <1299067973-15977-3-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Berger <stefanb@linux.vnet.ibm.com>

The patch below introduces an early termination of the loop that is
counting matches. It terminates once the counter has exceeded the
threshold provided by the user. There's no point in continuing the loop
afterwards and looking at other entries.

It plays together with the following code further below:

return (connections > info->limit) ^ info->inverse;

where connections is the result of the counted connection, which in turn
is the matches variable in the loop. So once

        -> matches = info->limit + 1
alias   -> matches > info->limit
alias   -> matches > threshold

we can terminate the loop.

Signed-off-by: Stefan Berger <stefanb@linux.vnet.ibm.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_connlimit.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index e029c48..82ce7c5 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -97,7 +97,8 @@ static int count_them(struct net *net,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr,
 		      const union nf_inet_addr *mask,
-		      u_int8_t family)
+		      u_int8_t family,
+		      unsigned int threshold)
 {
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
@@ -151,9 +152,14 @@ static int count_them(struct net *net,
 			continue;
 		}
 
-		if (same_source_net(addr, mask, &conn->tuple.src.u3, family))
+		if (same_source_net(addr, mask, &conn->tuple.src.u3, family)) {
 			/* same source network -> be counted! */
 			++matches;
+			if (matches > threshold) {
+				nf_ct_put(found_ct);
+				break;
+			}
+		}
 		nf_ct_put(found_ct);
 	}
 
@@ -207,7 +213,8 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	spin_lock_bh(&info->data->lock);
 	connections = count_them(net, info->data, tuple_ptr, &addr,
-	                         &info->mask, par->family);
+	                         &info->mask, par->family,
+	                         info->limit);
 	spin_unlock_bh(&info->data->lock);
 
 	if (connections < 0)
-- 
1.7.4


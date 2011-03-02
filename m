From: kaber@trash.net
Subject: [PATCH 04/13] Revert "netfilter: xt_connlimit: connlimit-above early loop termination"
Date: Wed,  2 Mar 2011 13:12:44 +0100
Message-ID: <1299067973-15977-5-git-send-email-kaber@trash.net>
References: <1299067973-15977-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:32938 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757030Ab1CBMM7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 07:12:59 -0500
In-Reply-To: <1299067973-15977-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Berger <stefanb@linux.vnet.ibm.com>

This reverts commit 44bd4de9c2270b22c3c898310102bc6be9ed2978.

I have to revert the early loop termination in connlimit since it generates
problems when an iptables statement does not use -m state --state NEW before
the connlimit match extension.

Signed-off-by: Stefan Berger <stefanb@linux.vnet.ibm.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_connlimit.c |   13 +++----------
 1 files changed, 3 insertions(+), 10 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 82ce7c5..e029c48 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -97,8 +97,7 @@ static int count_them(struct net *net,
 		      const struct nf_conntrack_tuple *tuple,
 		      const union nf_inet_addr *addr,
 		      const union nf_inet_addr *mask,
-		      u_int8_t family,
-		      unsigned int threshold)
+		      u_int8_t family)
 {
 	const struct nf_conntrack_tuple_hash *found;
 	struct xt_connlimit_conn *conn;
@@ -152,14 +151,9 @@ static int count_them(struct net *net,
 			continue;
 		}
 
-		if (same_source_net(addr, mask, &conn->tuple.src.u3, family)) {
+		if (same_source_net(addr, mask, &conn->tuple.src.u3, family))
 			/* same source network -> be counted! */
 			++matches;
-			if (matches > threshold) {
-				nf_ct_put(found_ct);
-				break;
-			}
-		}
 		nf_ct_put(found_ct);
 	}
 
@@ -213,8 +207,7 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 
 	spin_lock_bh(&info->data->lock);
 	connections = count_them(net, info->data, tuple_ptr, &addr,
-	                         &info->mask, par->family,
-	                         info->limit);
+	                         &info->mask, par->family);
 	spin_unlock_bh(&info->data->lock);
 
 	if (connections < 0)
-- 
1.7.4


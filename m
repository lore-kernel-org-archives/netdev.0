From: kaber@trash.net
Subject: [PATCH 29/37] netfilter: xt_connlimit: fix daddr connlimit in SNAT scenario
Date: Tue, 15 Mar 2011 20:44:09 +0100
Message-ID: <1300218257-26953-30-git-send-email-kaber@trash.net>
References: <1300218257-26953-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:49424 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758508Ab1COTod (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 15:44:33 -0400
In-Reply-To: <1300218257-26953-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>

We use the reply tuples when limiting the connections by the destination
addresses, however, in SNAT scenario, the final reply tuples won't be
ready until SNAT is done in POSTROUING or INPUT chain, and the following
nf_conntrack_find_get() in count_tem() will get nothing, so connlimit
can't work as expected.

In this patch, the original tuples are always used, and an additional
member addr is appended to save the address in either end.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 net/netfilter/xt_connlimit.c |   20 +++++++++-----------
 1 files changed, 9 insertions(+), 11 deletions(-)

diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index e029c48..1f4b9f9 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -33,8 +33,9 @@
 
 /* we will save the tuples of all connections we care about */
 struct xt_connlimit_conn {
-	struct list_head list;
-	struct nf_conntrack_tuple tuple;
+	struct list_head		list;
+	struct nf_conntrack_tuple	tuple;
+	union nf_inet_addr		addr;
 };
 
 struct xt_connlimit_data {
@@ -151,7 +152,7 @@ static int count_them(struct net *net,
 			continue;
 		}
 
-		if (same_source_net(addr, mask, &conn->tuple.src.u3, family))
+		if (same_source_net(addr, mask, &conn->addr, family))
 			/* same source network -> be counted! */
 			++matches;
 		nf_ct_put(found_ct);
@@ -165,6 +166,7 @@ static int count_them(struct net *net,
 		if (conn == NULL)
 			return -ENOMEM;
 		conn->tuple = *tuple;
+		conn->addr = *addr;
 		list_add(&conn->list, hash);
 		++matches;
 	}
@@ -185,15 +187,11 @@ connlimit_mt(const struct sk_buff *skb, struct xt_action_param *par)
 	int connections;
 
 	ct = nf_ct_get(skb, &ctinfo);
-	if (ct != NULL) {
-		if (info->flags & XT_CONNLIMIT_DADDR)
-			tuple_ptr = &ct->tuplehash[IP_CT_DIR_REPLY].tuple;
-		else
-			tuple_ptr = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
-	} else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
-				    par->family, &tuple)) {
+	if (ct != NULL)
+		tuple_ptr = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
+	else if (!nf_ct_get_tuplepr(skb, skb_network_offset(skb),
+				    par->family, &tuple))
 		goto hotdrop;
-	}
 
 	if (par->family == NFPROTO_IPV6) {
 		const struct ipv6hdr *iph = ipv6_hdr(skb);
-- 
1.7.2.3


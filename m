From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/8] ipv6: only generate one new serial number during fib6_add()
Date: Sun, 21 Sep 2014 00:05:20 +0200
Message-ID: <a8c28d9c6940bd30d414d3587dfe737184f5d158.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Cc: eric.dumazet@gmail.com, vyasevich@gmail.com,
	nicolas.dichtel@6wind.com, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:43031 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750707AbaITWFg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 18:05:36 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 3349D20766
	for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 18:05:36 -0400 (EDT)
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1411249633.git.hannes@stressinduktion.org>
References: <cover.1411249633.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Vlad Yasevich <vyasevich@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 19 +++++++++----------
 1 file changed, 9 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index c5e7e04..0725fc1 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -415,16 +415,15 @@ out:
  */
 
 static struct fib6_node *fib6_add_1(struct fib6_node *root,
-				     struct in6_addr *addr, int plen,
-				     int offset, int allow_create,
-				     int replace_required)
+				    struct in6_addr *addr, int plen,
+				    int offset, int allow_create,
+				    int replace_required, u32 sernum)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
 	struct rt6key *key;
 	int	bit;
 	__be32	dir = 0;
-	u32	sernum = fib6_new_sernum();
 
 	RT6_TRACE("fib6_add_1\n");
 
@@ -842,6 +841,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
+	u32 sernum = fib6_new_sernum();
 
 	if (info->nlh) {
 		if (!(info->nlh->nlmsg_flags & NLM_F_CREATE))
@@ -854,7 +854,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 
 	fn = fib6_add_1(root, &rt->rt6i_dst.addr, rt->rt6i_dst.plen,
 			offsetof(struct rt6_info, rt6i_dst), allow_create,
-			replace_required);
+			replace_required, sernum);
 	if (IS_ERR(fn)) {
 		err = PTR_ERR(fn);
 		fn = NULL;
@@ -888,14 +888,14 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 			sfn->leaf = info->nl_net->ipv6.ip6_null_entry;
 			atomic_inc(&info->nl_net->ipv6.ip6_null_entry->rt6i_ref);
 			sfn->fn_flags = RTN_ROOT;
-			sfn->fn_sernum = fib6_new_sernum();
+			sfn->fn_sernum = sernum;
 
 			/* Now add the first leaf node to new subtree */
 
 			sn = fib6_add_1(sfn, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required);
+					allow_create, replace_required, sernum);
 
 			if (IS_ERR(sn)) {
 				/* If it is failed, discard just allocated
@@ -914,7 +914,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 			sn = fib6_add_1(fn->subtree, &rt->rt6i_src.addr,
 					rt->rt6i_src.plen,
 					offsetof(struct rt6_info, rt6i_src),
-					allow_create, replace_required);
+					allow_create, replace_required, sernum);
 
 			if (IS_ERR(sn)) {
 				err = PTR_ERR(sn);
@@ -934,8 +934,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	if (!err) {
 		fib6_start_gc(info->nl_net, rt);
 		if (!(rt->rt6i_flags & RTF_CACHE))
-			fib6_prune_clones(info->nl_net, pn,
-					  FIB6_NO_SERNUM_CHANGE);
+			fib6_prune_clones(info->nl_net, pn, sernum);
 	}
 
 out:
-- 
1.9.3

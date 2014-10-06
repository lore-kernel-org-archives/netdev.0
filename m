From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 3/5] ipv6: only generate one new serial number per fib mutation
Date: Mon,  6 Oct 2014 10:52:12 +0200
Message-ID: <4b06f87b74e5ce9d39fb8b13af5a62604fb372f5.1412585163.git.hannes@stressinduktion.org>
References: <cover.1412585162.git.hannes@stressinduktion.org>
Cc: hideaki@yoshifuji.org, kafai@fb.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:37613 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752040AbaJFIwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 04:52:24 -0400
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by gateway2.nyi.internal (Postfix) with ESMTP id 2A914208C7
	for <netdev@vger.kernel.org>; Mon,  6 Oct 2014 04:52:24 -0400 (EDT)
In-Reply-To: <cover.1412585162.git.hannes@stressinduktion.org>
In-Reply-To: <cover.1412585162.git.hannes@stressinduktion.org>
References: <cover.1412585162.git.hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: YOSHIFUJI Hideaki <hideaki@yoshifuji.org>
Cc: Martin Lau <kafai@fb.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/ip6_fib.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index bfad469..a55a072 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -417,14 +417,13 @@ out:
 static struct fib6_node *fib6_add_1(struct fib6_node *root,
 				     struct in6_addr *addr, int plen,
 				     int offset, int allow_create,
-				     int replace_required)
+				     int replace_required, int sernum)
 {
 	struct fib6_node *fn, *in, *ln;
 	struct fib6_node *pn = NULL;
 	struct rt6key *key;
 	int	bit;
 	__be32	dir = 0;
-	int	sernum = fib6_new_sernum();
 
 	RT6_TRACE("fib6_add_1\n");
 
@@ -842,6 +841,7 @@ int fib6_add(struct fib6_node *root, struct rt6_info *rt, struct nl_info *info,
 	int err = -ENOMEM;
 	int allow_create = 1;
 	int replace_required = 0;
+	int sernum = fib6_new_sernum();
 
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
-- 
1.9.3

From: Wei Wang <weiwan@google.com>
Subject: [PATCH net-next 14/16] ipv6: add key length check into rt6_select()
Date: Fri,  6 Oct 2017 12:06:09 -0700
Message-ID: <20171006190611.110633-15-tracywwnj@gmail.com>
References: <20171006190611.110633-1-tracywwnj@gmail.com>
 <20171006190611.110633-2-tracywwnj@gmail.com>
 <20171006190611.110633-3-tracywwnj@gmail.com>
 <20171006190611.110633-4-tracywwnj@gmail.com>
 <20171006190611.110633-5-tracywwnj@gmail.com>
 <20171006190611.110633-6-tracywwnj@gmail.com>
 <20171006190611.110633-7-tracywwnj@gmail.com>
 <20171006190611.110633-8-tracywwnj@gmail.com>
 <20171006190611.110633-9-tracywwnj@gmail.com>
 <20171006190611.110633-10-tracywwnj@gmail.com>
 <20171006190611.110633-11-tracywwnj@gmail.com>
 <20171006190611.110633-12-tracywwnj@gmail.com>
 <20171006190611.110633-13-tracywwnj@gmail.com>
 <20171006190611.110633-14-tracywwnj@gmail.com>
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>, Wei Wang <weiwan@google.com>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:44594 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752750AbdJFTGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Oct 2017 15:06:55 -0400
Received: by mail-pg0-f46.google.com with SMTP id j3so330275pga.1
        for <netdev@vger.kernel.org>; Fri, 06 Oct 2017 12:06:55 -0700 (PDT)
In-Reply-To: <20171006190611.110633-14-tracywwnj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Wang <weiwan@google.com>

After rwlock is replaced with rcu and spinlock, fib6_lookup() could
potentially return an intermediate node if other thread is doing
fib6_del() on a route which is the only route on the node so that
fib6_repair_tree() will be called on this node and potentially assigns
fn->leaf to the its child's fn->leaf.

In order to detect this situation in rt6_select(), we have to check if
fn->fn_bit is consistent with the key length stored in the route. And
depending on if the fn is in the subtree or not, the key is either
rt->rt6i_dst or rt->rt6i_src.
If any inconsistency is found, that means the node no longer holds valid
routes in it. So net->ipv6.ip6_null_entry is returned.

Signed-off-by: Wei Wang <weiwan@google.com>
Signed-off-by: Martin KaFai Lau <kafai@fb.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv6/route.c | 14 ++++++++++++++
 1 file changed, 14 insertions(+)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index 05dc450af441..24b80f43bbfb 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -755,6 +755,7 @@ static struct rt6_info *rt6_select(struct net *net, struct fib6_node *fn,
 	struct rt6_info *leaf = fn->leaf;
 	struct rt6_info *match, *rt0;
 	bool do_rr = false;
+	int key_plen;
 
 	if (!leaf)
 		return net->ipv6.ip6_null_entry;
@@ -763,6 +764,19 @@ static struct rt6_info *rt6_select(struct net *net, struct fib6_node *fn,
 	if (!rt0)
 		fn->rr_ptr = rt0 = leaf;
 
+	/* Double check to make sure fn is not an intermediate node
+	 * and fn->leaf does not points to its child's leaf
+	 * (This might happen if all routes under fn are deleted from
+	 * the tree and fib6_repair_tree() is called on the node.)
+	 */
+	key_plen = rt0->rt6i_dst.plen;
+#ifdef CONFIG_IPV6_SUBTREES
+	if (rt0->rt6i_src.plen)
+		key_plen = rt0->rt6i_src.plen;
+#endif
+	if (fn->fn_bit != key_plen)
+		return net->ipv6.ip6_null_entry;
+
 	match = find_rr_leaf(fn, leaf, rt0, rt0->rt6i_metric, oif, strict,
 			     &do_rr);
 
-- 
2.14.2.920.gcf0c67979c-goog

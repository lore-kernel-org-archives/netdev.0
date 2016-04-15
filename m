From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [RFC net-next] soreuseport: fix ordering for mixed v4/v6 sockets
Date: Fri, 15 Apr 2016 13:58:50 -0400
Message-ID: <1460743130-27741-1-git-send-email-kraigatgoog@gmail.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f179.google.com ([209.85.223.179]:36562 "EHLO
	mail-io0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750846AbcDOR6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Apr 2016 13:58:54 -0400
Received: by mail-io0-f179.google.com with SMTP id u185so142066675iod.3
        for <netdev@vger.kernel.org>; Fri, 15 Apr 2016 10:58:53 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

With the SO_REUSEPORT socket option, it is possible to create sockets
in the AF_INET and AF_INET6 domains which are bound to the same IPv4 address.
This is only possible with SO_REUSEPORT and when not using IPV6_V6ONLY on
the AF_INET6 sockets.

Prior to the commits referenced below, an incoming IPv4 packet would
always be routed to a socket of type AF_INET when this mixed-mode was used.
After those changes, the same packet would be routed to the most recently
bound socket (if this happened to be an AF_INET6 socket, it would
have an IPv4 mapped IPv6 address).

The change in behavior occurred because the recent SO_REUSEPORT optimizations
short-circuit the socket scoring logic as soon as they find a match.  They
did not take into account the scoring logic that favors AF_INET sockets
over AF_INET6 sockets in the event of a tie.

To fix this problem, this patch changes the insertion order of AF_INET
and AF_INET6 addresses in the TCP and UDP socket lists when the sockets
have SO_REUSEPORT set.  AF_INET sockets will be inserted at the head of the
list and AF_INET6 sockets with SO_REUSEPORT set will always be inserted at
the tail of the list.  This will force AF_INET sockets to always be
considered first.

Fixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selection")
Fixes: 125e80b88687 ("soreuseport: fast reuseport TCP socket selection")
Signed-off-by: Craig Gallek <kraig@google.com>
---
A similar patch was recently accepted to the net tree:
d894ba18d4e4 ("soreuseport: fix ordering for mixed v4/v6 sockets")

However, two patches have already been submitted to net-next which
will conflict when net is merged back into net-next:
ca065d0cf80f ("udp: no longer use SLAB_DESTROY_BY_RCU")
3b24d854cb35 ("tcp/dccp: do not touch listener sk_refcnt under synflood")

These net-next patches change the TCP and UDP socket list datastructures
from hlist_nulls to hlists.  The fix for net needed to extend the
hlist_nulls API, the fix for net-next will need to extend the hlist API.
Further, the TCP stack now directly uses the hlist API rather than
the sk_* helper functions that wrapped them.

This RFC patch is a re-implementation of the net patch for the net-next
tree.  It could be used if the net patch is first reverted before merging to
net-next or simply used as a reference to correct the merge conflict.
The test submitted with the initial patch should work in both cases.
---
 include/linux/rculist.h    | 35 +++++++++++++++++++++++++++++++++++
 include/net/sock.h         |  6 +++++-
 net/ipv4/inet_hashtables.c |  6 +++++-
 net/ipv4/udp.c             |  9 +++++++--
 4 files changed, 52 insertions(+), 4 deletions(-)

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index 17d4f849c65e..7c5a8f7b0cb1 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -542,6 +542,41 @@ static inline void hlist_add_behind_rcu(struct hlist_node *n,
 		n->next->pprev = &n->next;
 }
 
+/**
+ * hlist_add_tail_rcu
+ * @n: the element to add to the hash list.
+ * @h: the list to add to.
+ *
+ * Description:
+ * Adds the specified element to the end of the specified hlist_nulls,
+ * while permitting racing traversals.  NOTE: tail insertion requires
+ * list traversal.
+ *
+ * The caller must take whatever precautions are necessary
+ * (such as holding appropriate locks) to avoid racing
+ * with another list-mutation primitive, such as hlist_add_head_rcu()
+ * or hlist_del_rcu(), running on this same list.
+ * However, it is perfectly legal to run concurrently with
+ * the _rcu list-traversal primitives, such as
+ * hlist_for_each_entry_rcu(), used to prevent memory-consistency
+ * problems on Alpha CPUs.  Regardless of the type of CPU, the
+ * list-traversal primitive must be guarded by rcu_read_lock().
+ */
+
+static inline void hlist_add_tail_rcu(struct hlist_node *n,
+					struct hlist_head *h)
+{
+	struct hlist_node *i, *last = NULL;
+
+	for (i = hlist_first_rcu(h); i; i = hlist_next_rcu(i))
+		last = i;
+
+	if (last)
+		hlist_add_behind_rcu(n, last);
+	else
+		hlist_add_head_rcu(n, h);
+}
+
 #define __hlist_for_each_rcu(pos, head)				\
 	for (pos = rcu_dereference(hlist_first_rcu(head));	\
 	     pos;						\
diff --git a/include/net/sock.h b/include/net/sock.h
index d997ec13a643..2b620c79f531 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -630,7 +630,11 @@ static inline void sk_add_node(struct sock *sk, struct hlist_head *list)
 static inline void sk_add_node_rcu(struct sock *sk, struct hlist_head *list)
 {
 	sock_hold(sk);
-	hlist_add_head_rcu(&sk->sk_node, list);
+	if (IS_ENABLED(CONFIG_IPV6) && sk->sk_reuseport &&
+	    sk->sk_family == AF_INET6)
+		hlist_add_tail_rcu(&sk->sk_node, list);
+	else
+		hlist_add_head_rcu(&sk->sk_node, list);
 }
 
 static inline void __sk_nulls_add_node_rcu(struct sock *sk, struct hlist_nulls_head *list)
diff --git a/net/ipv4/inet_hashtables.c b/net/ipv4/inet_hashtables.c
index fcadb670f50b..b76b0d7e59c1 100644
--- a/net/ipv4/inet_hashtables.c
+++ b/net/ipv4/inet_hashtables.c
@@ -479,7 +479,11 @@ int __inet_hash(struct sock *sk, struct sock *osk,
 		if (err)
 			goto unlock;
 	}
-	hlist_add_head_rcu(&sk->sk_node, &ilb->head);
+	if (IS_ENABLED(CONFIG_IPV6) && sk->sk_reuseport &&
+		sk->sk_family == AF_INET6)
+		hlist_add_tail_rcu(&sk->sk_node, &ilb->head);
+	else
+		hlist_add_head_rcu(&sk->sk_node, &ilb->head);
 	sock_set_flag(sk, SOCK_RCU_FREE);
 	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
 unlock:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index f1863136d3e4..fe294b320c83 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -336,8 +336,13 @@ found:
 
 		hslot2 = udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
 		spin_lock(&hslot2->lock);
-		hlist_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
-					 &hslot2->head);
+		if (IS_ENABLED(CONFIG_IPV6) && sk->sk_reuseport &&
+			sk->sk_family == AF_INET6)
+			hlist_add_tail_rcu(&udp_sk(sk)->udp_portaddr_node,
+					   &hslot2->head);
+		else
+			hlist_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
+					   &hslot2->head);
 		hslot2->count++;
 		spin_unlock(&hslot2->lock);
 	}
-- 
2.8.0.rc3.226.g39d4020

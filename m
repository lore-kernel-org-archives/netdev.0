From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net 1/2] soreuseport: fix ordering for mixed v4/v6 sockets
Date: Tue, 12 Apr 2016 13:11:25 -0400
Message-ID: <1460481086-12982-2-git-send-email-kraigatgoog@gmail.com>
References: <1460481086-12982-1-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f178.google.com ([209.85.220.178]:35191 "EHLO
	mail-qk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965447AbcDLRLf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 13:11:35 -0400
Received: by mail-qk0-f178.google.com with SMTP id o6so8959775qkc.2
        for <netdev@vger.kernel.org>; Tue, 12 Apr 2016 10:11:35 -0700 (PDT)
In-Reply-To: <1460481086-12982-1-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Craig Gallek <kraig@google.com>

With the SO_REUSEPORT socket option, it is possible to create sockets
in the AF_INET and AF_INET6 domains which are bound to the same IPv4 ad=
dress.
This is only possible with SO_REUSEPORT and when not using IPV6_V6ONLY =
on
the AF_INET6 sockets.

Prior to the commits referenced below, an incoming IPv4 packet would
always be routed to a socket of type AF_INET when this mixed-mode was u=
sed.
After those changes, the same packet would be routed to the most recent=
ly
bound socket (if this happened to be an AF_INET6 socket, it would
have an IPv4 mapped IPv6 address).

The change in behavior occurred because the recent SO_REUSEPORT optimiz=
ations
short-circuit the socket scoring logic as soon as they find a match.  T=
hey
did not take into account the scoring logic that favors AF_INET sockets
over AF_INET6 sockets in the event of a tie.

To fix this problem, this patch changes the insertion order of AF_INET
and AF_INET6 addresses in the TCP and UDP socket lists when the sockets
have SO_REUSEPORT set.  AF_INET sockets will be inserted at the head of=
 the
list and AF_INET6 sockets with SO_REUSEPORT set will always be inserted=
 at
the tail of the list.  This will force AF_INET sockets to always be
considered first.

=46ixes: e32ea7e74727 ("soreuseport: fast reuseport UDP socket selectio=
n")
=46ixes: 125e80b88687 ("soreuseport: fast reuseport TCP socket selectio=
n")

Reported-by: Maciej =C5=BBenczykowski <maze@google.com>
Signed-off-by: Craig Gallek <kraig@google.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/rculist_nulls.h | 39 +++++++++++++++++++++++++++++++++++=
++++
 include/net/sock.h            |  6 +++++-
 net/ipv4/udp.c                |  9 +++++++--
 3 files changed, 51 insertions(+), 3 deletions(-)

diff --git a/include/linux/rculist_nulls.h b/include/linux/rculist_null=
s.h
index 1c33dd7da4a7..4ae95f7e8597 100644
--- a/include/linux/rculist_nulls.h
+++ b/include/linux/rculist_nulls.h
@@ -98,6 +98,45 @@ static inline void hlist_nulls_add_head_rcu(struct h=
list_nulls_node *n,
 	if (!is_a_nulls(first))
 		first->pprev =3D &n->next;
 }
+
+/**
+ * hlist_nulls_add_tail_rcu
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
+ * with another list-mutation primitive, such as hlist_nulls_add_head_=
rcu()
+ * or hlist_nulls_del_rcu(), running on this same list.
+ * However, it is perfectly legal to run concurrently with
+ * the _rcu list-traversal primitives, such as
+ * hlist_nulls_for_each_entry_rcu(), used to prevent memory-consistenc=
y
+ * problems on Alpha CPUs.  Regardless of the type of CPU, the
+ * list-traversal primitive must be guarded by rcu_read_lock().
+ */
+static inline void hlist_nulls_add_tail_rcu(struct hlist_nulls_node *n=
,
+					struct hlist_nulls_head *h)
+{
+	struct hlist_nulls_node *i, *last =3D NULL;
+
+	for (i =3D hlist_nulls_first_rcu(h); !is_a_nulls(i);
+	     i =3D hlist_nulls_next_rcu(i))
+		last =3D i;
+
+	if (last) {
+		n->next =3D last->next;
+		n->pprev =3D &last->next;
+		rcu_assign_pointer(hlist_nulls_next_rcu(last), n);
+	} else {
+		hlist_nulls_add_head_rcu(n, h);
+	}
+}
+
 /**
  * hlist_nulls_for_each_entry_rcu - iterate over rcu list of given typ=
e
  * @tpos:	the type * to use as a loop cursor.
diff --git a/include/net/sock.h b/include/net/sock.h
index 255d3e03727b..121ffc115c4f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -630,7 +630,11 @@ static inline void sk_add_node_rcu(struct sock *sk=
, struct hlist_head *list)
=20
 static inline void __sk_nulls_add_node_rcu(struct sock *sk, struct hli=
st_nulls_head *list)
 {
-	hlist_nulls_add_head_rcu(&sk->sk_nulls_node, list);
+	if (IS_ENABLED(CONFIG_IPV6) && sk->sk_reuseport &&
+	    sk->sk_family =3D=3D AF_INET6)
+		hlist_nulls_add_tail_rcu(&sk->sk_nulls_node, list);
+	else
+		hlist_nulls_add_head_rcu(&sk->sk_nulls_node, list);
 }
=20
 static inline void sk_nulls_add_node_rcu(struct sock *sk, struct hlist=
_nulls_head *list)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 08eed5e16df0..a2e7f55a1f61 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -339,8 +339,13 @@ found:
=20
 		hslot2 =3D udp_hashslot2(udptable, udp_sk(sk)->udp_portaddr_hash);
 		spin_lock(&hslot2->lock);
-		hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
-					 &hslot2->head);
+		if (IS_ENABLED(CONFIG_IPV6) && sk->sk_reuseport &&
+			sk->sk_family =3D=3D AF_INET6)
+			hlist_nulls_add_tail_rcu(&udp_sk(sk)->udp_portaddr_node,
+						 &hslot2->head);
+		else
+			hlist_nulls_add_head_rcu(&udp_sk(sk)->udp_portaddr_node,
+						 &hslot2->head);
 		hslot2->count++;
 		spin_unlock(&hslot2->lock);
 	}
--=20
2.8.0.rc3.226.g39d4020

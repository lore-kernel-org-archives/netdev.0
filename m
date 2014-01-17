From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] ipv4: fix a dst leak in tunnels
Date: Thu, 16 Jan 2014 16:41:19 -0800
Message-ID: <1389919279.31367.439.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Cong Wang <cwang@twopensource.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f50.google.com ([209.85.213.50]:61297 "EHLO
	mail-yh0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750937AbaAQAlX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jan 2014 19:41:23 -0500
Received: by mail-yh0-f50.google.com with SMTP id f10so1198975yha.23
        for <netdev@vger.kernel.org>; Thu, 16 Jan 2014 16:41:22 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

This patch :

1) Remove a dst leak if DST_NOCACHE was set on dst
   Fix this by holding a reference only if dst really cached.

2) Remove a lockdep warning in __tunnel_dst_set()
    This was reported by Cong Wang.

3) Remove usage of a spinlock where xchg() is enough

4) Remove some spurious inline keywords.
   Let compiler decide for us.

=46ixes: 7d442fab0a67 ("ipv4: Cache dst in tunnels")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Cong Wang <cwang@twopensource.com>
Cc: Tom Herbert <therbert@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 include/net/ip_tunnels.h |    1 -
 net/ipv4/ip_tunnel.c     |   34 ++++++++++++++--------------------
 2 files changed, 14 insertions(+), 21 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index cd729becbb07..48ed75c21260 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -40,7 +40,6 @@ struct ip_tunnel_prl_entry {
=20
 struct ip_tunnel_dst {
 	struct dst_entry __rcu 		*dst;
-	spinlock_t			lock;
 };
=20
 struct ip_tunnel {
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
index d3929a69f008..432c28ab3197 100644
--- a/net/ipv4/ip_tunnel.c
+++ b/net/ipv4/ip_tunnel.c
@@ -68,27 +68,27 @@ static unsigned int ip_tunnel_hash(struct ip_tunnel=
_net *itn,
 			 IP_TNL_HASH_BITS);
 }
=20
-static inline void __tunnel_dst_set(struct ip_tunnel_dst *idst,
-				    struct dst_entry *dst)
+static void __tunnel_dst_set(struct ip_tunnel_dst *idst,
+			     struct dst_entry *dst)
 {
 	struct dst_entry *old_dst;
=20
-	if (dst && (dst->flags & DST_NOCACHE))
-		dst =3D NULL;
-
-	spin_lock_bh(&idst->lock);
-	old_dst =3D rcu_dereference(idst->dst);
-	rcu_assign_pointer(idst->dst, dst);
+	if (dst) {
+		if (dst->flags & DST_NOCACHE)
+			dst =3D NULL;
+		else
+			dst_clone(dst);
+	}
+	old_dst =3D xchg((__force struct dst_entry **)&idst->dst, dst);
 	dst_release(old_dst);
-	spin_unlock_bh(&idst->lock);
 }
=20
-static inline void tunnel_dst_set(struct ip_tunnel *t, struct dst_entr=
y *dst)
+static void tunnel_dst_set(struct ip_tunnel *t, struct dst_entry *dst)
 {
 	__tunnel_dst_set(this_cpu_ptr(t->dst_cache), dst);
 }
=20
-static inline void tunnel_dst_reset(struct ip_tunnel *t)
+static void tunnel_dst_reset(struct ip_tunnel *t)
 {
 	tunnel_dst_set(t, NULL);
 }
@@ -101,7 +101,7 @@ static void tunnel_dst_reset_all(struct ip_tunnel *=
t)
 		__tunnel_dst_set(per_cpu_ptr(t->dst_cache, i), NULL);
 }
=20
-static inline struct dst_entry *tunnel_dst_get(struct ip_tunnel *t)
+static struct dst_entry *tunnel_dst_get(struct ip_tunnel *t)
 {
 	struct dst_entry *dst;
=20
@@ -413,7 +413,7 @@ static int ip_tunnel_bind_dev(struct net_device *de=
v)
=20
 		if (!IS_ERR(rt)) {
 			tdev =3D rt->dst.dev;
-			tunnel_dst_set(tunnel, dst_clone(&rt->dst));
+			tunnel_dst_set(tunnel, &rt->dst);
 			ip_rt_put(rt);
 		}
 		if (dev->type !=3D ARPHRD_ETHER)
@@ -668,7 +668,7 @@ void ip_tunnel_xmit(struct sk_buff *skb, struct net=
_device *dev,
 			goto tx_error;
 		}
 		if (connected)
-			tunnel_dst_set(tunnel, dst_clone(&rt->dst));
+			tunnel_dst_set(tunnel, &rt->dst);
 	}
=20
 	if (rt->dst.dev =3D=3D dev) {
@@ -1066,12 +1066,6 @@ int ip_tunnel_init(struct net_device *dev)
 		return -ENOMEM;
 	}
=20
-	for_each_possible_cpu(i) {
-		struct ip_tunnel_dst *idst =3D per_cpu_ptr(tunnel->dst_cache, i);
-		idst-> dst =3D NULL;
-		spin_lock_init(&idst->lock);
-	}
-
 	err =3D gro_cells_init(&tunnel->gro_cells, dev);
 	if (err) {
 		free_percpu(tunnel->dst_cache);

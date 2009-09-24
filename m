From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet_peer: Optimize inet_getid()
Date: Thu, 24 Sep 2009 22:44:53 +0200
Message-ID: <4ABBDA45.2040109@gmail.com>
References: <4ABBC2D8.2040901@gmail.com> <20090924123020.59a2ee6e@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43446 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181AbZIXUow (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 16:44:52 -0400
In-Reply-To: <20090924123020.59a2ee6e@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Thu, 24 Sep 2009 21:04:56 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> While investigating for network latencies, I found inet_getid() was =
a contention point
>> for some workloads.
>>
>> Fix is straightforward, using cmpxchg() instead of
>> a spin_lock_bh()/spin_unlock_bh() pair on a central lock.
>>
>> Another possibility was to use an atomic_t and atomic_add_return() b=
ut
>> the size of struct inet_peer object would had doubled on x86_64 beca=
use of
>> SLAB_HWCACHE_ALIGN constraint.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I thought cmpxchg was not available on all architectures.

Here is the second version of the patch, thanks Stephen

[PATCH] inet_peer: Optimize inet_getid()

While investigating for network latencies, I found inet_getid() was a c=
ontention point
for some workloads.

If __HAVE_ARCH_CMPXCHG is defined, we can use cmpxchg() instead of
a spin_lock_bh()/spin_unlock_bh() pair on a central lock.

On other arches, we can use an atomic_t instead of a u16,
and atomic_add_return(). This might grow memory usage a bit, unless
someone invents atomic16_t :)

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/inetpeer.h |   43 ++++++++++++++++++++++++++++++++-------
 net/ipv4/inetpeer.c    |    5 ----
 net/ipv4/route.c       |    2 -
 3 files changed, 38 insertions(+), 12 deletions(-)

diff --git a/include/net/inetpeer.h b/include/net/inetpeer.h
index 15e1f8f..f1cde51 100644
--- a/include/net/inetpeer.h
+++ b/include/net/inetpeer.h
@@ -19,7 +19,11 @@ struct inet_peer
 	struct inet_peer	*avl_left, *avl_right;
 	__be32			v4daddr;	/* peer's address */
 	__u16			avl_height;
+#if defined(__HAVE_ARCH_CMPXCHG)
 	__u16			ip_id_count;	/* IP ID for the next packet */
+#else
+	atomic_t		ip_id_count;
+#endif
 	struct list_head	unused;
 	__u32			dtime;		/* the time of last use of not
 						 * referenced entries */
@@ -37,17 +41,42 @@ struct inet_peer	*inet_getpeer(__be32 daddr, int cr=
eate);
 /* can be called from BH context or outside */
 extern void inet_putpeer(struct inet_peer *p);
=20
-extern spinlock_t inet_peer_idlock;
 /* can be called with or without local BH being disabled */
 static inline __u16	inet_getid(struct inet_peer *p, int more)
 {
-	__u16 id;
+	__u16 old;
=20
-	spin_lock_bh(&inet_peer_idlock);
-	id =3D p->ip_id_count;
-	p->ip_id_count +=3D 1 + more;
-	spin_unlock_bh(&inet_peer_idlock);
-	return id;
+	more++;
+#if defined(__HAVE_ARCH_CMPXCHG)
+	while (1) {
+		old =3D p->ip_id_count;
+		if (cmpxchg(&p->ip_id_count, old, old + more) =3D=3D old)
+			break;
+	}
+#else
+	old =3D atomic_add_return(more, &p->ip_id_count) - more;
+#endif
+	return old;
 }
=20
+static inline void inet_id_set(struct inet_peer *p, int val)
+{
+#if defined(__HAVE_ARCH_CMPXCHG)
+	p->ip_id_count =3D val;
+#else
+	atomic_set(&p->ip_id_count, val);
+#endif
+}
+
+static inline __u16 inet_id_read(const struct inet_peer *p)
+{
+#if defined(__HAVE_ARCH_CMPXCHG)
+	return p->ip_id_count;
+#else
+	return atomic_read(&p->ip_id_count);
+#endif
+}
+
+
+
 #endif /* _NET_INETPEER_H */
diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index b1fbe18..3641831 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -67,9 +67,6 @@
  *		ip_id_count: idlock
  */
=20
-/* Exported for inet_getid inline function.  */
-DEFINE_SPINLOCK(inet_peer_idlock);
-
 static struct kmem_cache *peer_cachep __read_mostly;
=20
 #define node_height(x) x->avl_height
@@ -390,7 +387,7 @@ struct inet_peer *inet_getpeer(__be32 daddr, int cr=
eate)
 	n->v4daddr =3D daddr;
 	atomic_set(&n->refcnt, 1);
 	atomic_set(&n->rid, 0);
-	n->ip_id_count =3D secure_ip_id(daddr);
+	inet_id_set(n, secure_ip_id(daddr));
 	n->tcp_ts_stamp =3D 0;
=20
 	write_lock_bh(&peer_pool_lock);
diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index df93473..a090fcf 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2855,7 +2855,7 @@ static int rt_fill_info(struct net *net,
 	error =3D rt->u.dst.error;
 	expires =3D rt->u.dst.expires ? rt->u.dst.expires - jiffies : 0;
 	if (rt->peer) {
-		id =3D rt->peer->ip_id_count;
+		id =3D inet_id_read(rt->peer);
 		if (rt->peer->tcp_ts_stamp) {
 			ts =3D rt->peer->tcp_ts;
 			tsage =3D get_seconds() - rt->peer->tcp_ts_stamp;

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
Date: Wed, 08 Jul 2009 00:33:29 +0200
Message-ID: <4A53CD39.7080407@gmail.com>
References: <EA929A9653AAE14F841771FB1DE5A1365F8AB77D05@rrsmsx501.amr.corp.intel.com>	 <4A4C4F46.2070701@gmail.com> <bde4e1140907061754r1b158bf5w4bbf7b4dca06086@mail.gmail.com> <4A52F78B.6020503@gmail.com> <4A52FBE6.8070402@gmail.com> <4A537469.3040207@gmail.com> <EA929A9653AAE14F841771FB1DE5A1365F8ACEBEE9@rrsmsx501.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Emil S Tantilov <emils.tantilov@gmail.com>,
	NetDev <netdev@vger.kernel.org>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	Jiri Olsa <jolsa@redhat.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58888 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754983AbZGGWd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2009 18:33:57 -0400
In-Reply-To: <EA929A9653AAE14F841771FB1DE5A1365F8ACEBEE9@rrsmsx501.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tantilov, Emil S a =C3=A9crit :
> Eric Dumazet wrote:
>> Eric Dumazet a =C3=A9crit :
>>>
>>> Hold on, I found the problem and will submit a patch (after testing
>>> it) in following hours=20
>>>
>> David, while looking at Emil case, I found following problem.
>>
>> I am not sure this bug is responsible for the BUG hit by Emil,
>> but it seems a candidate for stable as well...
>>
>> Thanks
>>
>> [PATCH] net: sk_alloc() should not blindly overwrite memory
>>
>> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code rely that som=
e
>> fields should not be blindly overwritten, even with null.
>>
>> These fields are sk->sk_refcnt and sk->sk_nulls_node.next
>>
>> Current sk_alloc() implementation doesnt respect this hypothesis,
>> calling kmem_alloc with __GFP_ZERO and setting sk_refcnt to 1 instea=
d
>> of atomically increment it.
>>
>> Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Eric,
>=20
> With this patch applied, I get panic on boot:

Oops, this stuff has to be done inside sk_prot_alloc() or breaks selinu=
x

Thanks for testing Emil, here is a second try !


[PATCH] net: sk_prot_alloc() should not blindly overwrite memory

Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code rely that some
fields should not be blindly overwritten, even with null.

These fields are sk->sk_refcnt and sk->sk_nulls_node.next

Current sk_prot_alloc() implementation doesnt respect this hypothesis,
calling kmem_cache_alloc() with __GFP_ZERO and setting sk_refcnt to 1
instead of atomically increment it.

Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h            |   24 +++++++++------
 net/core/sock.c               |   49 ++++++++++++++++++++++++++++----
 net/ipv4/inet_timewait_sock.c |    2 -
 3 files changed, 59 insertions(+), 16 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 352f06b..3f6284e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -103,15 +103,15 @@ struct net;
=20
 /**
  *	struct sock_common - minimal network layer representation of socket=
s
+ *	@skc_node: main hash linkage for various protocol lookup tables
+ *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
+ *	@skc_refcnt: reference count
+ *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_family: network address family
  *	@skc_state: Connection state
  *	@skc_reuse: %SO_REUSEADDR setting
  *	@skc_bound_dev_if: bound device index if !=3D 0
- *	@skc_node: main hash linkage for various protocol lookup tables
- *	@skc_nulls_node: main hash linkage for UDP/UDP-Lite protocol
  *	@skc_bind_node: bind hash linkage for various protocol lookup table=
s
- *	@skc_refcnt: reference count
- *	@skc_hash: hash value used with various protocol lookup tables
  *	@skc_prot: protocol handlers inside a network family
  *	@skc_net: reference to the network namespace of this socket
  *
@@ -119,17 +119,23 @@ struct net;
  *	for struct sock and struct inet_timewait_sock.
  */
 struct sock_common {
-	unsigned short		skc_family;
-	volatile unsigned char	skc_state;
-	unsigned char		skc_reuse;
-	int			skc_bound_dev_if;
+	/*
+	 * WARNING : skc_node, skc_refcnt must be first elements of this stru=
ct
+	 * (sk_prot_alloc() should not clear skc_node.next & skc_refcnt becau=
se
+	 *  of RCU lookups)
+	 */
 	union {
 		struct hlist_node	skc_node;
 		struct hlist_nulls_node skc_nulls_node;
 	};
-	struct hlist_node	skc_bind_node;
 	atomic_t		skc_refcnt;
+
 	unsigned int		skc_hash;
+	unsigned short		skc_family;
+	volatile unsigned char	skc_state;
+	unsigned char		skc_reuse;
+	int			skc_bound_dev_if;
+	struct hlist_node	skc_bind_node;
 	struct proto		*skc_prot;
 #ifdef CONFIG_NET_NS
 	struct net	 	*skc_net;
diff --git a/net/core/sock.c b/net/core/sock.c
index b0ba569..cf43ff1 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -939,8 +939,31 @@ static struct sock *sk_prot_alloc(struct proto *pr=
ot, gfp_t priority,
 	struct kmem_cache *slab;
=20
 	slab =3D prot->slab;
-	if (slab !=3D NULL)
-		sk =3D kmem_cache_alloc(slab, priority);
+	if (slab !=3D NULL) {
+		/*
+		 * caches using SLAB_DESTROY_BY_RCU should let sk_node
+		 * and sk_refcnt untouched.
+		 *
+		 * Following makes sense only if sk first fields are
+		 * in following order : sk_node, refcnt, sk_hash
+		 */
+		BUILD_BUG_ON(offsetof(struct sock, sk_node) !=3D 0);
+		BUILD_BUG_ON(offsetof(struct sock, sk_refcnt) !=3D
+			     sizeof(sk->sk_node));
+		BUILD_BUG_ON(offsetof(struct sock, sk_hash) !=3D
+			     sizeof(sk->sk_node) + sizeof(sk->sk_refcnt));
+		sk =3D kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
+		if (!sk)
+			return sk;
+		if (priority & __GFP_ZERO) {
+			if (prot->slab_flags & SLAB_DESTROY_BY_RCU)
+				memset(&sk->sk_hash, 0,
+				       prot->obj_size -
+				       offsetof(struct sock, sk_hash));
+			else
+				memset(sk, 0, prot->obj_size);
+		}
+	}
 	else
 		sk =3D kmalloc(prot->obj_size, priority);
=20
@@ -1125,7 +1148,7 @@ struct sock *sk_clone(const struct sock *sk, cons=
t gfp_t priority)
=20
 		newsk->sk_err	   =3D 0;
 		newsk->sk_priority =3D 0;
-		atomic_set(&newsk->sk_refcnt, 2);
+		atomic_add(2, &newsk->sk_refcnt);
=20
 		/*
 		 * Increment the counter in the same struct proto as the master
@@ -1840,7 +1863,7 @@ void sock_init_data(struct socket *sock, struct s=
ock *sk)
=20
 	sk->sk_stamp =3D ktime_set(-1L, 0);
=20
-	atomic_set(&sk->sk_refcnt, 1);
+	atomic_inc(&sk->sk_refcnt);
 	atomic_set(&sk->sk_wmem_alloc, 1);
 	atomic_set(&sk->sk_drops, 0);
 }
@@ -2140,12 +2163,25 @@ static inline void release_proto_idx(struct pro=
to *prot)
 }
 #endif
=20
+/*
+ * We need to initialize skc->skc_refcnt to 0, and skc->skc_node.pprev=
 to NULL
+ * but only on newly allocated objects (check sk_prot_alloc())
+ */
+static void sk_init_once(void *arg)
+{
+	struct sock_common *skc =3D arg;
+
+	atomic_set(&skc->skc_refcnt, 0);
+	skc->skc_node.pprev =3D NULL;
+}
+
 int proto_register(struct proto *prot, int alloc_slab)
 {
 	if (alloc_slab) {
 		prot->slab =3D kmem_cache_create(prot->name, prot->obj_size, 0,
 					SLAB_HWCACHE_ALIGN | prot->slab_flags,
-					NULL);
+					prot->slab_flags & SLAB_DESTROY_BY_RCU ?
+					    sk_init_once : NULL);
=20
 		if (prot->slab =3D=3D NULL) {
 			printk(KERN_CRIT "%s: Can't create sock SLAB cache!\n",
@@ -2187,7 +2223,8 @@ int proto_register(struct proto *prot, int alloc_=
slab)
 						  0,
 						  SLAB_HWCACHE_ALIGN |
 							prot->slab_flags,
-						  NULL);
+						  prot->slab_flags & SLAB_DESTROY_BY_RCU ?
+							sk_init_once : NULL);
 			if (prot->twsk_prot->twsk_slab =3D=3D NULL)
 				goto out_free_timewait_sock_slab_name;
 		}
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_soc=
k.c
index 61283f9..a2997df 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -139,7 +139,7 @@ struct inet_timewait_sock *inet_twsk_alloc(const st=
ruct sock *sk, const int stat
 		tw->tw_transparent  =3D inet->transparent;
 		tw->tw_prot	    =3D sk->sk_prot_creator;
 		twsk_net_set(tw, hold_net(sock_net(sk)));
-		atomic_set(&tw->tw_refcnt, 1);
+		atomic_inc(&tw->tw_refcnt);
 		inet_twsk_dead_node_init(tw);
 		__module_get(tw->tw_prot->owner);
 	}

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
Date: Thu, 09 Jul 2009 07:36:05 +0200
Message-ID: <4A5581C5.5070409@gmail.com>
References: <4A537469.3040207@gmail.com>	<EA929A9653AAE14F841771FB1DE5A1365F8ACEBEE9@rrsmsx501.amr.corp.intel.com>	<4A53CD39.7080407@gmail.com> <20090707.191424.167842005.davem@davemloft.net> <4A5441A0.3050504@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emil.s.tantilov@intel.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, jolsa@redhat.com,
	Patrick McHardy <kaber@trash.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:51190 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750967AbZGIFgh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jul 2009 01:36:37 -0400
In-Reply-To: <4A5441A0.3050504@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> David Miller a =E9crit :
>> From: Eric Dumazet <eric.dumazet@gmail.com>
>> Date: Wed, 08 Jul 2009 00:33:29 +0200
>>
>>> [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
>>>
>>> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code rely that so=
me
>>> fields should not be blindly overwritten, even with null.
>>>
>>> These fields are sk->sk_refcnt and sk->sk_nulls_node.next
>>>
>>> Current sk_prot_alloc() implementation doesnt respect this hypothes=
is,
>>> calling kmem_cache_alloc() with __GFP_ZERO and setting sk_refcnt to=
 1
>>> instead of atomically increment it.
>>>
>>> Reported-by: Emil S Tantilov <emils.tantilov@gmail.com>
>>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> I've applied this but will wait for some more testing before
>> I push it out for real to kernel.org
>=20
> Thanks David
>=20
> I forgot to CC Paul and Patrick, so I'll ask them to look at this pat=
ch.
>=20
> Patrick, a similar fix is needed in conntrack as well, we currently
> uses "ct =3D kmem_cache_zalloc(nf_conntrack_cachep, gfp);" and thus
>  overwrite struct hlist_nulls_node hnnode; contained
> in "struct nf_conntrack_tuple_hash", while lockless readers still
> potentialy need them. Setting hnnode.next to NULL is dangerous
> since last bit is not set (not a nulls value), a reader could
> try to dereference this NULL pointer and trap.
>=20
>=20
> Here is the patch again so that Paul & Patrick can comment on it.
>=20
> I am not sure about the refcnt thing (blindly setting it to 0 again
> should be OK in fact, since no reader should/can to the=20
> atomic_inc_if_not_zero on it), but the nulls.next thing is problemati=
c.

Here is an updated and much simpler patch, taking care of sk_node.next =
being not set to 0

This patch applies to >=3D 2.6.29 kernels

[PATCH] net: sk_prot_alloc() should not blindly overwrite memory

Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code correctness
depends on sk->sk_nulls_node.next being always valid. A NULL
value is not allowed as it might fault a lockless reader.

Current sk_prot_alloc() implementation doesnt respect this hypothesis,
calling kmem_cache_alloc() with __GFP_ZERO. Just call memset() around
the forbidden field.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/core/sock.c b/net/core/sock.c
index b0ba569..7b87ec0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -939,8 +939,23 @@ static struct sock *sk_prot_alloc(struct proto *pr=
ot, gfp_t priority,
 	struct kmem_cache *slab;
=20
 	slab =3D prot->slab;
-	if (slab !=3D NULL)
-		sk =3D kmem_cache_alloc(slab, priority);
+	if (slab !=3D NULL) {
+		sk =3D kmem_cache_alloc(slab, priority & ~__GFP_ZERO);
+		if (!sk)
+			return sk;
+		if (priority & __GFP_ZERO) {
+			/*
+			 * caches using SLAB_DESTROY_BY_RCU should let
+			 * sk_node.next un-modified. Special care is taken
+			 * when initializing object to zero.
+			 */
+			if (offsetof(struct sock, sk_node.next) !=3D 0)
+				memset(sk, 0, offsetof(struct sock, sk_node.next));
+			memset(&sk->sk_node.pprev, 0,
+			       prot->obj_size - offsetof(struct sock,
+							 sk_node.pprev));
+		}
+	}
 	else
 		sk =3D kmalloc(prot->obj_size, priority);
=20

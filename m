From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: nf_conntrack_alloc() fixes
Date: Wed, 15 Jul 2009 21:54:01 +0200
Message-ID: <4A5E33D9.2030602@gmail.com>
References: <20090707.191424.167842005.davem@davemloft.net>	<4A5441A0.3050504@gmail.com>	<4A5581C5.5070409@gmail.com> <20090711.202727.18146102.davem@davemloft.net> <4A598BAB.6030400@gmail.com> <4A5DCB7C.9000502@gmail.com> <4A5DF5B4.5090809@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:38262 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756034AbZGOTyM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jul 2009 15:54:12 -0400
In-Reply-To: <4A5DF5B4.5090809@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Patrick McHardy a =E9crit :
> Eric Dumazet wrote:
>> [PATCH] net: nf_conntrack_alloc() should not use kmem_cache_zalloc()
>>
>> When a slab cache uses SLAB_DESTROY_BY_RCU, we must be careful when =
allocating
>> objects, since slab allocator could give a freed object still used b=
y lockless
>> readers.
>>
>> In particular, nf_conntrack RCU lookups rely on ct->tuplehash[xxx].h=
nnode.next
>> being always valid (ie containing a valid 'nulls' value, or a valid =
pointer to next
>> object in hash chain.)
>>
>> kmem_cache_zalloc() setups object with NULL values, but a NULL value=
 is not valid
>> for ct->tuplehash[xxx].hnnode.next.
>>
>> Fix is to call kmem_cache_alloc() and do the zeroing ourself.
>=20
> I think this is still racy, please see below:

Nice catch indeed !

>=20
>> diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_co=
nntrack_core.c
>> index 7508f11..23feafa 100644
>> --- a/net/netfilter/nf_conntrack_core.c
>> +++ b/net/netfilter/nf_conntrack_core.c
>> @@ -561,17 +561,28 @@ struct nf_conn *nf_conntrack_alloc(struct net =
*net,
>>  		}
>>  	}
>> =20
>> -	ct =3D kmem_cache_zalloc(nf_conntrack_cachep, gfp);
>> +	/*
>> +	 * Do not use kmem_cache_zalloc(), as this cache uses
>> +	 * SLAB_DESTROY_BY_RCU.
>> +	 */
>> +	ct =3D kmem_cache_alloc(nf_conntrack_cachep, gfp);
>>  	if (ct =3D=3D NULL) {
>>  		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
>>  		atomic_dec(&net->ct.count);
>>  		return ERR_PTR(-ENOMEM);
>>  	}
>> -
>=20
> __nf_conntrack_find() on another CPU finds the entry at this point.
>=20
>> +	/*
>> +	 * Let ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
>> +	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
>> +	 */
>> +	memset(&ct->tuplehash[IP_CT_DIR_MAX], 0,
>> +	       sizeof(*ct) - offsetof(struct nf_conn, tuplehash[IP_CT_DIR_=
MAX]));
>>  	spin_lock_init(&ct->lock);
>>  	atomic_set(&ct->ct_general.use, 1);
>=20
> nf_conntrack_find_get() successfully tries to atomic_inc_not_zero()
> at this point, following by another tuple comparison which is also
> successful.
>=20
> Am I missing something? I think we need to make sure the reference
> count is not increased until the new tuples are visible.

Yes you are right, and Documentation/RCU/rculist_nulls.txt should be
updated to reflect this as well (in insert algo, must use smp_wmb()
between obj->key assignment and refcnt assigment)

We'll have to change socket allocation too, this will be addressed
by a followup patch

Thanks Patrick !

[PATCH] net: nf_conntrack_alloc() fixes

When a slab cache uses SLAB_DESTROY_BY_RCU, we must be careful when all=
ocating
objects, since slab allocator could give a freed object still used by l=
ockless
readers.

In particular, nf_conntrack RCU lookups rely on ct->tuplehash[xxx].hnno=
de.next
being always valid (ie containing a valid 'nulls' value, or a valid poi=
nter to next
object in hash chain.)

kmem_cache_zalloc() setups object with NULL values, but a NULL value is=
 not valid
for ct->tuplehash[xxx].hnnode.next.

=46ix is to call kmem_cache_alloc() and do the zeroing ourself.

As spotted by Patrick, we also need to make sure lookup keys are commit=
ted to
memory before setting refcount to 1, or a lockless reader could get a r=
eference
on the old version of the object. Its key re-check could then pass the =
barrier.=20

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/RCU/rculist_nulls.txt |    7 ++++++-
 net/netfilter/nf_conntrack_core.c   |   21 ++++++++++++++++++---
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/Documentation/RCU/rculist_nulls.txt b/Documentation/RCU/rc=
ulist_nulls.txt
index 93cb28d..18f9651 100644
--- a/Documentation/RCU/rculist_nulls.txt
+++ b/Documentation/RCU/rculist_nulls.txt
@@ -83,11 +83,12 @@ not detect it missed following items in original ch=
ain.
 obj =3D kmem_cache_alloc(...);
 lock_chain(); // typically a spin_lock()
 obj->key =3D key;
-atomic_inc(&obj->refcnt);
 /*
  * we need to make sure obj->key is updated before obj->next
+ * or obj->refcnt
  */
 smp_wmb();
+atomic_set(&obj->refcnt, 1);
 hlist_add_head_rcu(&obj->obj_node, list);
 unlock_chain(); // typically a spin_unlock()
=20
@@ -159,6 +160,10 @@ out:
 obj =3D kmem_cache_alloc(cachep);
 lock_chain(); // typically a spin_lock()
 obj->key =3D key;
+/*
+ * changes to obj->key must be visible before refcnt one
+ */
+smp_wmb();
 atomic_set(&obj->refcnt, 1);
 /*
  * insert obj in RCU way (readers might be traversing chain)
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_connt=
rack_core.c
index 7508f11..b5869b9 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -561,23 +561,38 @@ struct nf_conn *nf_conntrack_alloc(struct net *ne=
t,
 		}
 	}
=20
-	ct =3D kmem_cache_zalloc(nf_conntrack_cachep, gfp);
+	/*
+	 * Do not use kmem_cache_zalloc(), as this cache uses
+	 * SLAB_DESTROY_BY_RCU.
+	 */
+	ct =3D kmem_cache_alloc(nf_conntrack_cachep, gfp);
 	if (ct =3D=3D NULL) {
 		pr_debug("nf_conntrack_alloc: Can't alloc conntrack.\n");
 		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
-
+	/*
+	 * Let ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
+	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
+	 */
+	memset(&ct->tuplehash[IP_CT_DIR_MAX], 0,
+	       sizeof(*ct) - offsetof(struct nf_conn, tuplehash[IP_CT_DIR_MAX=
]));
 	spin_lock_init(&ct->lock);
-	atomic_set(&ct->ct_general.use, 1);
 	ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple =3D *orig;
+	ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.pprev =3D NULL;
 	ct->tuplehash[IP_CT_DIR_REPLY].tuple =3D *repl;
+	ct->tuplehash[IP_CT_DIR_REPLY].hnnode.pprev =3D NULL;
 	/* Don't set timer yet: wait for confirmation */
 	setup_timer(&ct->timeout, death_by_timeout, (unsigned long)ct);
 #ifdef CONFIG_NET_NS
 	ct->ct_net =3D net;
 #endif
=20
+	/*
+	 * changes to lookup keys must be done before setting refcnt to 1
+	 */
+	smp_wmb();
+	atomic_set(&ct->ct_general.use, 1);
 	return ct;
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_alloc);

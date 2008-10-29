From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 2/2] udp: RCU handling for Unicast packets.
Date: Wed, 29 Oct 2008 15:36:34 +0100
Message-ID: <490874F2.2060306@cosmosbay.com>
References: <20081008.114527.189056050.davem@davemloft.net> <49077918.4050706@cosmosbay.com>	<490795FB.2000201@cosmosbay.com> <20081028.220536.183082966.davem@davemloft.net> <49081D67.3050502@cosmosbay.com> <49082718.2030201@cosmosbay.com> <4908627C.6030001@acm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050005030502070200050807"
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	benny+usenet@amorsen.dk, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com,
	Christoph Lameter <cl@linux-foundation.org>,
	a.p.zijlstra@chello.nl, johnpol@2ka.mipt.ru,
	Christian Bell <christian@myri.com>
To: Corey Minyard <minyard@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:38449 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752971AbYJ2Ohg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Oct 2008 10:37:36 -0400
In-Reply-To: <4908627C.6030001@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------050005030502070200050807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable

Corey Minyard a =E9crit :
> I believe there is a race in this patch:
>=20
> +    sk_for_each_rcu(sk, node, &hslot->head) {
> +        /*
> +         * lockless reader, and SLAB_DESTROY_BY_RCU items:
> +         * We must check this item was not moved to another chain
> +         */
> +        if (udp_hashfn(net, sk->sk_hash) !=3D hash)
> +            goto begin;
>         score =3D compute_score(sk, net, hnum, saddr, sport, daddr, dpo=
rt,=20
> dif);
>         if (score > badness) {
>             result =3D sk;
>             badness =3D score;
>         }
>     }
>=20
> If the socket is moved from one list to another list in-between the tim=
e=20
> the hash is calculated and the next field is accessed, and the socket=20
> has moved to the end of the new list, the traversal will not complete=20
> properly on the list it should have, since the socket will be on the en=
d=20
> of the new list and there's not a way to tell it's on a new list and=20
> restart the list traversal.  I think that this can be solved by=20
> pre-fetching the "next" field (with proper barriers) before checking th=
e=20
> hash.
>=20

You are absolutely right. As we *need* next pointer anyway for the prefet=
ch(),
we can store it, so that its value is kept.

> I also might be nice to have a way to avoid recomputing the score the=20
> second time, perhaps using a sequence number of some type.

Well, computing score is really cheap, everything is in cache, granted
the chain was not really huge and high score item at the beginning.

Adding yet another field in sock structure should be avoided if possible.=


Thanks

[PATCH] udp: introduce sk_for_each_rcu_safenext()

Corey Minyard found a race added in commit 271b72c7fa82c2c7a795bc16896149=
933110672d
(udp: RCU handling for Unicast packets.)

 "If the socket is moved from one list to another list in-between the tim=
e=20
  the hash is calculated and the next field is accessed, and the socket=20
  has moved to the end of the new list, the traversal will not complete=20
  properly on the list it should have, since the socket will be on the en=
d=20
  of the new list and there's not a way to tell it's on a new list and=20
  restart the list traversal.  I think that this can be solved by=20
  pre-fetching the "next" field (with proper barriers) before checking th=
e=20
  hash."

This patch corrects this problem, introducing a new sk_for_each_rcu_safen=
ext()
macro.

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
---
 include/linux/rculist.h |   17 +++++++++++++++++
 include/net/sock.h      |    4 ++--
 net/ipv4/udp.c          |    4 ++--
 net/ipv6/udp.c          |    4 ++--
 4 files changed, 23 insertions(+), 6 deletions(-)


--------------050005030502070200050807
Content-Type: text/plain;
 name="corey.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="corey.patch"

diff --git a/include/linux/rculist.h b/include/linux/rculist.h
index e649bd3..3ba2998 100644
--- a/include/linux/rculist.h
+++ b/include/linux/rculist.h
@@ -383,5 +383,22 @@ static inline void hlist_add_after_rcu(struct hlist_node *prev,
 		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
 		pos = rcu_dereference(pos->next))
 
+/**
+ * hlist_for_each_entry_rcu_safenext - iterate over rcu list of given type
+ * @tpos:	the type * to use as a loop cursor.
+ * @pos:	the &struct hlist_node to use as a loop cursor.
+ * @head:	the head for your list.
+ * @member:	the name of the hlist_node within the struct.
+ * @next:       the &struct hlist_node to use as a next cursor
+ *
+ * Special version of hlist_for_each_entry_rcu that make sure
+ * each next pointer is fetched before each iteration.
+ */
+#define hlist_for_each_entry_rcu_safenext(tpos, pos, head, member, next) \
+	for (pos = rcu_dereference((head)->first);			 \
+		pos && ({ next = pos->next; smp_rmb(); prefetch(next); 1; }) &&	\
+		({ tpos = hlist_entry(pos, typeof(*tpos), member); 1; }); \
+		pos = rcu_dereference(next))
+
 #endif	/* __KERNEL__ */
 #endif
diff --git a/include/net/sock.h b/include/net/sock.h
index 0bea25d..a4f6d3f 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -419,8 +419,8 @@ static __inline__ void sk_add_bind_node(struct sock *sk,
 
 #define sk_for_each(__sk, node, list) \
 	hlist_for_each_entry(__sk, node, list, sk_node)
-#define sk_for_each_rcu(__sk, node, list) \
-	hlist_for_each_entry_rcu(__sk, node, list, sk_node)
+#define sk_for_each_rcu_safenext(__sk, node, list, next) \
+	hlist_for_each_entry_rcu_safenext(__sk, node, list, sk_node, next)
 #define sk_for_each_from(__sk, node) \
 	if (__sk && ({ node = &(__sk)->sk_node; 1; })) \
 		hlist_for_each_entry_from(__sk, node, sk_node)
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 5ba0340..c3ecec8 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -256,7 +256,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 		int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;
-	struct hlist_node *node;
+	struct hlist_node *node, *next;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
@@ -266,7 +266,7 @@ static struct sock *__udp4_lib_lookup(struct net *net, __be32 saddr,
 begin:
 	result = NULL;
 	badness = -1;
-	sk_for_each_rcu(sk, node, &hslot->head) {
+	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
 		/*
 		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
 		 * We must check this item was not moved to another chain
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 1d9790e..32d914d 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -98,7 +98,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 				      int dif, struct udp_table *udptable)
 {
 	struct sock *sk, *result;
-	struct hlist_node *node;
+	struct hlist_node *node, *next;
 	unsigned short hnum = ntohs(dport);
 	unsigned int hash = udp_hashfn(net, hnum);
 	struct udp_hslot *hslot = &udptable->hash[hash];
@@ -108,7 +108,7 @@ static struct sock *__udp6_lib_lookup(struct net *net,
 begin:
 	result = NULL;
 	badness = -1;
-	sk_for_each_rcu(sk, node, &hslot->head) {
+	sk_for_each_rcu_safenext(sk, node, &hslot->head, next) {
 		/*
 		 * lockless reader, and SLAB_DESTROY_BY_RCU items:
 		 * We must check this item was not moved to another chain

--------------050005030502070200050807--

From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RCU problems in fib_table_insert
Date: Sun, 21 Mar 2010 22:25:52 +0100
Message-ID: <1269206752.3004.9.camel@edumazet-laptop>
References: <20100321202525.GA966@basil.fritz.box>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f211.google.com ([209.85.218.211]:43906 "EHLO
	mail-bw0-f211.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753308Ab0CUVZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Mar 2010 17:25:58 -0400
Received: by bwz3 with SMTP id 3so4814282bwz.29
        for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 14:25:56 -0700 (PDT)
In-Reply-To: <20100321202525.GA966@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 21 mars 2010 =C3=A0 21:25 +0100, Andi Kleen a =C3=A9crit :
> Hi,
>=20
> I got the following warning at boot with a 2.6.34-rc2ish git kernel
> with RCU debugging and preemption enabled.
>=20
> It seems the problem is that not all callers of fib_find_node
> call it with rcu_read_lock() to stabilize access to the fib.=20
>=20
> I tried to fix it, but especially for fib_table_insert() that's rathe=
r=20
> tricky: it does a lot of memory allocations and also route flushing a=
nd=20
> other blocking operations while assuming the original fa is RCU stabl=
e.
>=20
> I first tried to move some allocations to the beginning and keep
> preemption disabled in the rest, but it's difficult with all of them.
> No patch because of that.
>=20
> Does the fa need an additional reference count for this problem?
> Or perhaps some optimistic locking?
>=20
> -Andi

No real changes needed, only a lockdep warning...

Probably a rcu_dereference() should be changed to
rcu_dereference_check() like we did for __in6_dev_get()

We hold RTNL or rcu_read_lock

[PATCH] net: fib_find_node() rcu check

We hold rcu read lock or RTNL when fib_find_node() is called.
Shutup lockdep complain.

Reported-by: Andi Kleen <andi@firstfloor.org>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index af5d897..471fe07 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -961,7 +961,8 @@ fib_find_node(struct trie *t, u32 key)
 	struct node *n;
=20
 	pos =3D 0;
-	n =3D rcu_dereference(t->trie);
+	n =3D rcu_dereference_check(t->trie,
+				  rcu_read_lock_held() || lockdep_rtnl_is_held());
=20
 	while (n !=3D NULL &&  NODE_TYPE(n) =3D=3D T_TNODE) {
 		tn =3D (struct tnode *) n;



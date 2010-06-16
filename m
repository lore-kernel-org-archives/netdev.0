From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: do not use zero refcnt for freed
 entries
Date: Wed, 16 Jun 2010 04:45:24 +0200
Message-ID: <1276656324.19249.39.camel@edumazet-laptop>
References: <1276626194.2541.186.camel@edumazet-laptop>
	 <20100615.142506.02275206.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:59433 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151Ab0FPCpa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 22:45:30 -0400
Received: by wwb18 with SMTP id 18so5297487wwb.19
        for <netdev@vger.kernel.org>; Tue, 15 Jun 2010 19:45:28 -0700 (PDT)
In-Reply-To: <20100615.142506.02275206.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 15 juin 2010 =C3=A0 14:25 -0700, David Miller a =C3=A9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 15 Jun 2010 20:23:14 +0200
>=20
> > inetpeer currently uses an AVL tree protected by an rwlock.
> >=20
> > It's possible to make most lookups use RCU
>  ...
> > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> Applied, nice work Eric.

Thanks David !

Re-reading patch I realize refcnt is expected to be 0 for unused entrie=
s
(obviously), so we should use a different marker for 'about to be freed=
'
ones.

Thanks

[PATCH net-next-2.6] inetpeer: do not use zero refcnt for freed entries

=46ollowup of commit aa1039e73cc2 (inetpeer: RCU conversion)

Unused inet_peer entries have a null refcnt.

Using atomic_inc_not_zero() in rcu lookups is not going to work for
them, and slow path is taken.

=46ix this using -1 marker instead of 0 for deleted entries.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inetpeer.c |   10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 58fbc7e..39a14ba 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -187,7 +187,12 @@ static struct inet_peer *lookup_rcu_bh(__be32 dadd=
r)
=20
 	while (u !=3D peer_avl_empty) {
 		if (daddr =3D=3D u->v4daddr) {
-			if (unlikely(!atomic_inc_not_zero(&u->refcnt)))
+			/* Before taking a reference, check if this entry was
+			 * deleted, unlink_from_pool() sets refcnt=3D-1 to make
+			 * distinction between an unused entry (refcnt=3D0) and
+			 * a freed one.
+			 */
+			if (unlikely(!atomic_add_unless(&u->refcnt, 1, -1)))
 				u =3D NULL;
 			return u;
 		}
@@ -322,8 +327,9 @@ static void unlink_from_pool(struct inet_peer *p)
 	 * in cleanup() function to prevent sudden disappearing.  If we can
 	 * atomically (because of lockless readers) take this last reference,
 	 * it's safe to remove the node and free it later.
+	 * We use refcnt=3D-1 to alert lockless readers this entry is deleted=
=2E
 	 */
-	if (atomic_cmpxchg(&p->refcnt, 1, 0) =3D=3D 1) {
+	if (atomic_cmpxchg(&p->refcnt, 1, -1) =3D=3D 1) {
 		struct inet_peer **stack[PEER_MAXDEPTH];
 		struct inet_peer ***stackptr, ***delp;
 		if (lookup(p->v4daddr, stack) !=3D p)



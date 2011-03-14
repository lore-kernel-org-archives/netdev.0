From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] inetpeer: should use call_rcu() variant
Date: Mon, 14 Mar 2011 05:15:31 +0100
Message-ID: <1300076131.2761.61.camel@edumazet-laptop>
References: <20110308.145954.59682618.davem@davemloft.net>
	 <1300010649.2761.3.camel@edumazet-laptop>
	 <20110313.164215.193721466.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:44552 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751244Ab1CNEPf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 00:15:35 -0400
Received: by wya21 with SMTP id 21so4010666wya.19
        for <netdev@vger.kernel.org>; Sun, 13 Mar 2011 21:15:34 -0700 (PDT)
In-Reply-To: <20110313.164215.193721466.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 13 mars 2011 =C3=A0 16:42 -0700, David Miller a =C3=A9crit =
:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 13 Mar 2011 11:04:09 +0100
>=20
> > David, I am not sure this is safe, since we use call_rcu_bh() when
> > freeing one item. One cpu could decide to kfree() one item while an=
other
> > cpu could still use it.
> >=20
> > rcu_read_lock_bh() was signalling to others cpu we were in a softir=
q
> > section, so we were delaying a possible kfree().
>=20
> Ok, could we use normal call_rcu() to solve this then?

Yes, this should be good.

Thanks

[PATCH net-next-2.6] inetpeer: should use call_rcu() variant

After commit 7b46ac4e77f3224a (inetpeer: Don't disable BH for initial
fast RCU lookup.), we should use call_rcu() to wait proper RCU grace
period.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/ipv4/inetpeer.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/inetpeer.c b/net/ipv4/inetpeer.c
index 86b1d08..dd1b20e 100644
--- a/net/ipv4/inetpeer.c
+++ b/net/ipv4/inetpeer.c
@@ -399,7 +399,7 @@ static void unlink_from_pool(struct inet_peer *p, s=
truct inet_peer_base *base)
 	write_sequnlock_bh(&base->lock);
=20
 	if (do_free)
-		call_rcu_bh(&p->rcu, inetpeer_free_rcu);
+		call_rcu(&p->rcu, inetpeer_free_rcu);
 	else
 		/* The node is used again.  Decrease the reference counter
 		 * back.  The loop "cleanup -> unlink_from_unused



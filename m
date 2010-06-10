From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] ip: ip_ra_control() rcu fix
Date: Thu, 10 Jun 2010 04:21:07 +0200
Message-ID: <1276136467.2475.13.camel@edumazet-laptop>
References: <1275916328.2545.64.camel@edumazet-laptop>
	 <20100607.212612.35795010.davem@davemloft.net>
	 <1276136109.2475.9.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:36907 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117Ab0FJCVL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jun 2010 22:21:11 -0400
Received: by wwb18 with SMTP id 18so93470wwb.19
        for <netdev@vger.kernel.org>; Wed, 09 Jun 2010 19:21:10 -0700 (PDT)
In-Reply-To: <1276136109.2475.9.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 10 juin 2010 =C3=A0 04:15 +0200, Eric Dumazet a =C3=A9crit :

> [PATCH net-next-2.6] ip: ip_ra_control() rcu fix
>=20
> commit 66018506e15b (ip: Router Alert RCU conversion) introduced RCU
> lookups to ip_call_ra_chain(). It missed proper deinit phase :
> When ip_ra_control() deletes an ip_ra_chain, it should make sure
> ip_call_ra_chain() users can not start to use socket during the rcu
> grace period. It should also delay the sock_put() after the grace
> period, or we risk a premature socket freeing and corruptions, as
> raw sockets are not rcu protected yet.
>=20
> This delay avoids using expensive atomic_inc_not_return() in

Grrr... should be atomic_inc_not_zero(), sorry for the typo in
ChangeLog :(



[PATCH net-next-2.6 v2] ip: ip_ra_control() rcu fix

commit 66018506e15b (ip: Router Alert RCU conversion) introduced RCU
lookups to ip_call_ra_chain(). It missed proper deinit phase :
When ip_ra_control() deletes an ip_ra_chain, it should make sure
ip_call_ra_chain() users can not start to use socket during the rcu
grace period. It should also delay the sock_put() after the grace
period, or we risk a premature socket freeing and corruptions, as
raw sockets are not rcu protected yet.

This delay avoids using expensive atomic_inc_not_zero() in
ip_call_ra_chain().

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/ip.h       |    5 ++++-
 net/ipv4/ip_sockglue.c |   19 +++++++++++++++----
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 9982c97..d52f011 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -61,7 +61,10 @@ struct ipcm_cookie {
 struct ip_ra_chain {
 	struct ip_ra_chain	*next;
 	struct sock		*sk;
-	void			(*destructor)(struct sock *);
+	union {
+		void			(*destructor)(struct sock *);
+		struct sock		*saved_sk;
+	};
 	struct rcu_head		rcu;
 };
=20
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 08b9519..47fff52 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -241,9 +241,13 @@ int ip_cmsg_send(struct net *net, struct msghdr *m=
sg, struct ipcm_cookie *ipc)
 struct ip_ra_chain *ip_ra_chain;
 static DEFINE_SPINLOCK(ip_ra_lock);
=20
-static void ip_ra_free_rcu(struct rcu_head *head)
+
+static void ip_ra_destroy_rcu(struct rcu_head *head)
 {
-	kfree(container_of(head, struct ip_ra_chain, rcu));
+	struct ip_ra_chain *ra =3D container_of(head, struct ip_ra_chain, rcu=
);
+
+	sock_put(ra->saved_sk);
+	kfree(ra);
 }
=20
 int ip_ra_control(struct sock *sk, unsigned char on,
@@ -264,13 +268,20 @@ int ip_ra_control(struct sock *sk, unsigned char =
on,
 				kfree(new_ra);
 				return -EADDRINUSE;
 			}
+			/* dont let ip_call_ra_chain() use sk again */
+			ra->sk =3D NULL;
 			rcu_assign_pointer(*rap, ra->next);
 			spin_unlock_bh(&ip_ra_lock);
=20
 			if (ra->destructor)
 				ra->destructor(sk);
-			sock_put(sk);
-			call_rcu(&ra->rcu, ip_ra_free_rcu);
+			/*
+			 * Delay sock_put(sk) and kfree(ra) after one rcu grace
+			 * period. This guarantee ip_call_ra_chain() dont need
+			 * to mess with socket refcounts.
+			 */
+			ra->saved_sk =3D sk;
+			call_rcu(&ra->rcu, ip_ra_destroy_rcu);
 			return 0;
 		}
 	}



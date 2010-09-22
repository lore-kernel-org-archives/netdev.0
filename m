From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: fix a lockdep splat
Date: Wed, 22 Sep 2010 21:34:48 +0200
Message-ID: <1285184088.2380.18.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
	 <1285064011.2617.238.camel@edumazet-laptop>
	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
	 <1285144306.2639.90.camel@edumazet-laptop>
	 <1285144471.2639.96.camel@edumazet-laptop>
	 <1285144681.2639.102.camel@edumazet-laptop>
	 <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
	 <1285176935.2639.453.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:42142 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755146Ab0IVTey (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 15:34:54 -0400
In-Reply-To: <1285176935.2639.453.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 septembre 2010 =C3=A0 19:35 +0200, Eric Dumazet a =C3=A9=
crit :

> Thanks !
>=20
> We have for each socket :
>=20
> One spinlock (sk_slock.slock)
> One rwlock (sk_callback_lock)
>=20
> It is legal to use :
>=20
> A) (this is used in net/sunrpc/xprtsock.c)
> read_lock(&sk->sk_callback_lock) (without blocking BH)
> <BH>
> spin_lock(&sk->sk_slock.slock);
> ...
> read_lock(&sk->sk_callback_lock);
> ...
>=20
> Its also legal to do
>=20
> B)
> write_lock_bh(&sk->sk_callback_lock)
> stuff
> write_unlock_bh(&sk->sk_callback_lock)
>=20
>=20
> But if we have a path that :
>=20
> C)
> spin_lock_bh(&sk->sk_slock)
> ...
> write_lock_bh(&sk->sk_callback_lock)
> stuff
> write_unlock_bh(&sk->sk_callback_lock)
>=20
> Then we can have a deadlock with A)
>=20
> CPU1 [A]                                CPU2 [C]
> read_lock(&sk->sk_callback_lock)
> <BH>					spin_lock_bh(&sk->sk_slock)
> <wait to spin_lock(slock)>
> 					<wait to write_lock_bh(callback_lock)>
>=20
> We have one such path C) in inet_csk_listen_stop() :
>=20
> local_bh_disable();
> bh_lock_sock(child); // spin_lock_bh(&sk->sk_slock)
> WARN_ON(sock_owned_by_user(child));
> ...
> sock_orphan(child); // write_lock_bh(&sk->sk_callback_lock)
>=20
> This is a false positive because its not possible that this particula=
r
> deadlock can occur, since inet_csk_listen_stop() manipulates half
> sockets (not yet given to a listener)
>=20
> Give me a moment to think about it and write a fix.
>=20
>=20

Could you try following patch ?

Thanks !

[PATCH] net: fix a lockdep splat

We have for each socket :

One spinlock (sk_slock.slock)
One rwlock (sk_callback_lock)

Possible scenarios are :

(A) (this is used in net/sunrpc/xprtsock.c)
read_lock(&sk->sk_callback_lock) (without blocking BH)
<BH>
spin_lock(&sk->sk_slock.slock);
=2E..
read_lock(&sk->sk_callback_lock);
=2E..


(B)
write_lock_bh(&sk->sk_callback_lock)
stuff
write_unlock_bh(&sk->sk_callback_lock)


(C)
spin_lock_bh(&sk->sk_slock)
=2E..
write_lock_bh(&sk->sk_callback_lock)
stuff
write_unlock_bh(&sk->sk_callback_lock)
spin_unlock_bh(&sk->sk_slock)

This (C) case conflicts with (A) :

CPU1 [A]                         CPU2 [C]
read_lock(callback_lock)
<BH>                             spin_lock_bh(slock)
<wait to spin_lock(slock)>
                                 <wait to write_lock_bh(callback_lock)>

We have one problematic (C) use case in inet_csk_listen_stop() :

local_bh_disable();
bh_lock_sock(child); // spin_lock_bh(&sk->sk_slock)
WARN_ON(sock_owned_by_user(child));
=2E..
sock_orphan(child); // write_lock_bh(&sk->sk_callback_lock)

lockdep is not happy with this, as reported by Tetsuo Handa

This patch makes sure inet_csk_listen_stop() uses following lock order =
:

write_lock_bh(&sk->sk_callback_lock)
spin_lock(&sk->sk_slock)
=2E..
spin_unlock(&sk->sk_slock)
write_unlock_bh(&sk->sk_callback_lock)

Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/net/sock.h              |   18 +++++++++++++++---
 net/ipv4/inet_connection_sock.c |    7 ++++---
 2 files changed, 19 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index adab9dc..b6c60d5 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1242,6 +1242,14 @@ static inline wait_queue_head_t *sk_sleep(struct=
 sock *sk)
 {
 	return &sk->sk_wq->wait;
 }
+
+static inline void __sock_orphan(struct sock *sk)
+{
+	sock_set_flag(sk, SOCK_DEAD);
+	sk_set_socket(sk, NULL);
+	sk->sk_wq  =3D NULL;
+}
+
 /* Detach socket from process context.
  * Announce socket dead, detach it from wait queue and inode.
  * Note that parent inode held reference count on this struct sock,
@@ -1251,15 +1259,19 @@ static inline wait_queue_head_t *sk_sleep(struc=
t sock *sk)
  */
 static inline void sock_orphan(struct sock *sk)
 {
+#ifdef CONFIG_PROVE_LOCKING
+	WARN_ON(lockdep_is_held(&sk->sk_lock.slock));
+#endif
 	write_lock_bh(&sk->sk_callback_lock);
-	sock_set_flag(sk, SOCK_DEAD);
-	sk_set_socket(sk, NULL);
-	sk->sk_wq  =3D NULL;
+	__sock_orphan(sk);
 	write_unlock_bh(&sk->sk_callback_lock);
 }
=20
 static inline void sock_graft(struct sock *sk, struct socket *parent)
 {
+#ifdef CONFIG_PROVE_LOCKING
+	WARN_ON(lockdep_is_held(&sk->sk_lock.slock));
+#endif
 	write_lock_bh(&sk->sk_callback_lock);
 	rcu_assign_pointer(sk->sk_wq, parent->wq);
 	parent->sk =3D sk;
diff --git a/net/ipv4/inet_connection_sock.c b/net/ipv4/inet_connection=
_sock.c
index 7174370..c65df13 100644
--- a/net/ipv4/inet_connection_sock.c
+++ b/net/ipv4/inet_connection_sock.c
@@ -685,21 +685,22 @@ void inet_csk_listen_stop(struct sock *sk)
=20
 		acc_req =3D req->dl_next;
=20
-		local_bh_disable();
+		write_lock_bh(&child->sk_callback_lock);
+
 		bh_lock_sock(child);
 		WARN_ON(sock_owned_by_user(child));
 		sock_hold(child);
=20
 		sk->sk_prot->disconnect(child, O_NONBLOCK);
=20
-		sock_orphan(child);
+		__sock_orphan(child);
=20
 		percpu_counter_inc(sk->sk_prot->orphan_count);
=20
 		inet_csk_destroy_sock(child);
=20
 		bh_unlock_sock(child);
-		local_bh_enable();
+		write_unlock_bh(&child->sk_callback_lock);
 		sock_put(child);
=20
 		sk_acceptq_removed(sk);



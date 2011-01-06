From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: POLLPRI/poll() behavior change since 2.6.31
Date: Thu, 06 Jan 2011 17:55:29 +0100
Message-ID: <1294332929.3074.49.camel@edumazet-laptop>
References: <20110106155040.GA27769@libre.l.ngdn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Leonardo Chiquitto <leonardo.lists@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56974 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753667Ab1AFRAu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 12:00:50 -0500
Received: by wyb28 with SMTP id 28so16577376wyb.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 09:00:48 -0800 (PST)
In-Reply-To: <20110106155040.GA27769@libre.l.ngdn.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 06 janvier 2011 =C3=A0 13:50 -0200, Leonardo Chiquitto a =C3=A9=
crit :
> Hello,
>=20
> Since 2.6.31, poll() no longer returns when waiting exclusively for a
> POLLPRI event. If we wait for POLLPRI | POLLIN, though, it will
> correctly return POLLPRI as a received event.
>=20
> The reproducer (code below) will print the following when running on
> 2.6.30:
>=20
> $ ./pollpri-oob=20
> main: starting
> main: setup_pipe ok (sfd[0] =3D 5, sfd[1] =3D 4)
> parent: child <pid 3790> started
> child: polling...
> parent: sending the message
> parent: waiting for child to exit
> child: poll(): some data <1,2> has arrived!
> child: done
> parent: done
>=20
> ... and will block when running on 2.6.37-rc7:
>=20
> $ ./pollpri-oob=20
> main: starting
> main: setup_pipe ok (sfd[0] =3D 5, sfd[1] =3D 4)
> parent: child <pid 14148> started
> child: polling...
> parent: sending the message
> parent: waiting for child to exit
> [hangs here]
>=20
> I've bisected this behavior change to the following commit:
>=20
> commit 4938d7e0233a455f04507bac81d0886c71529537
> Author: Eric Dumazet <dada1@cosmosbay.com>
> Date:   Tue Jun 16 15:33:36 2009 -0700
>=20
>   poll: avoid extra wakeups in select/poll
>=20
>   After introduction of keyed wakeups Davide Libenzi did on epoll, we=
 are
>   able to avoid spurious wakeups in poll()/select() code too.
>=20
>   For example, typical use of poll()/select() is to wait for incoming
>   network frames on many sockets.  But TX completion for UDP/TCP fram=
es call
>   sock_wfree() which in turn schedules thread.
>=20
>   When scheduled, thread does a full scan of all polled fds and can s=
leep
>   again, because nothing is really available.  If number of fds is la=
rge,
>   this cause significant load.
>=20
>   This patch makes select()/poll() aware of keyed wakeups and useless
>   wakeups are avoided.  This reduces number of context switches by ab=
out 50%
>   on some setups, and work performed by sofirq handlers.
>=20
>=20
> I don't know if the new behavior is correct, but we've got one report=
 of
> an application that broke due to the change.

Hi Leonardo

Hmm, this is because 	sock_def_readable() uses :

wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLRDNORM |
POLLRDBAND);

So POLLPRI bit is not signaled.=20

I would just add POLLPRI flag in sock_def_readable()

(Alternatively, define a tcp_def_readable() function to pass POLLPRI
only if TCP_URG is set, but is it worth the pain for a seldom used
feature ?)

David, do you have an opinion on this ?

Thanks

diff --git a/net/core/sock.c b/net/core/sock.c
index e5af8d5..7fd3541 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1907,7 +1907,7 @@ static void sock_def_readable(struct sock *sk, in=
t len)
 	rcu_read_lock();
 	wq =3D rcu_dereference(sk->sk_wq);
 	if (wq_has_sleeper(wq))
-		wake_up_interruptible_sync_poll(&wq->wait, POLLIN |
+		wake_up_interruptible_sync_poll(&wq->wait, POLLIN | POLLPRI |
 						POLLRDNORM | POLLRDBAND);
 	sk_wake_async(sk, SOCK_WAKE_WAITD, POLL_IN);
 	rcu_read_unlock();



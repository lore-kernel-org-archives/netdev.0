From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] af_unix: unix_write_space() use keyed wakeups
Date: Sat, 30 Oct 2010 08:44:44 +0200
Message-ID: <1288421084.2680.717.camel@edumazet-laptop>
References: <20101029191857.5f789d56@chocolatine.cbg.collabora.co.uk>
	 <1288380431.2680.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Cyrill Gorcunov <gorcunov@openvz.org>,
	Alexey Dobriyan <adobriyan@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Pauli Nieminen <pauli.nieminen@collabora.co.uk>,
	Rainer Weikusat <rweikusat@mssgmbh.com>
To: Alban Crequy <alban.crequy@collabora.co.uk>,
	Davide Libenzi <davidel@xmailserver.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:59092 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751570Ab0J3Gou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Oct 2010 02:44:50 -0400
In-Reply-To: <1288380431.2680.3.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 octobre 2010 =C3=A0 21:27 +0200, Eric Dumazet a =C3=A9cr=
it :
> Le vendredi 29 octobre 2010 =C3=A0 19:18 +0100, Alban Crequy a =C3=A9=
crit :
> > Hi,
> >=20
> > When a process calls the poll or select, the kernel calls (struct
> > file_operations)->poll on every file descriptor and returns a mask =
of
> > events which are ready. If the process is only interested by POLLIN
> > events, the mask is still computed for POLLOUT and it can be expens=
ive.
> > For example, on Unix datagram sockets, a process running poll() wit=
h
> > POLLIN will wakes-up when the remote end call read(). This is a
> > performance regression introduced when fixing another bug by
> > 3c73419c09a5ef73d56472dbfdade9e311496e9b and
> > ec0d215f9420564fc8286dcf93d2d068bb53a07e.
> >=20

unix_write_space() doesn=E2=80=99t yet use the wake_up_interruptible_sy=
nc_poll()
to restrict wakeups to only POLLOUT | POLLWRNORM | POLLWRBAND intereste=
d
sleepers. Same for unix_dgram_recvmsg()

In your pathological case, each time the other process calls
unix_dgram_recvmsg(), it loops on 800 pollwake() /
default_wake_function() / try_to_wake_up(), which are obviously
expensive, as you pointed out with your test program, carefully designe=
d
to show the false sharing and O(N^2) effect :)

Once do_select() thread can _really_ block, the false sharing problem
disappears for good.

We still loop on 800 items, on each wake_up_interruptible_sync_poll()
call, so maybe we want to optimize this later, adding a global key,
ORing all items keys. I dont think its worth the added complexity, give=
n
the biased usage of your program (800 'listeners' to one event). Is it =
a
real life scenario ?

Thanks

[PATCH] af_unix: use keyed wakeups

Instead of wakeup all sleepers, use wake_up_interruptible_sync_poll() t=
o
wakeup only ones interested into writing the socket.

This patch is a specialization of commit 37e5540b3c9d (epoll keyed
wakeups: make sockets use keyed wakeups).

On a test program provided by Alan Crequy :

Before:
real    0m3.101s
user    0m0.000s
sys     0m6.104s

After:

real	0m0.211s
user	0m0.000s
sys	0m0.208s

Reported-by: Alban Crequy <alban.crequy@collabora.co.uk>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Davide Libenzi <davidel@xmailserver.org>
---
 net/unix/af_unix.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 3c95304..f33c595 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -316,7 +316,8 @@ static void unix_write_space(struct sock *sk)
 	if (unix_writable(sk)) {
 		wq =3D rcu_dereference(sk->sk_wq);
 		if (wq_has_sleeper(wq))
-			wake_up_interruptible_sync(&wq->wait);
+			wake_up_interruptible_sync_poll(&wq->wait,
+				POLLOUT | POLLWRNORM | POLLWRBAND);
 		sk_wake_async(sk, SOCK_WAKE_SPACE, POLL_OUT);
 	}
 	rcu_read_unlock();
@@ -1710,7 +1711,8 @@ static int unix_dgram_recvmsg(struct kiocb *iocb,=
 struct socket *sock,
 		goto out_unlock;
 	}
=20
-	wake_up_interruptible_sync(&u->peer_wait);
+	wake_up_interruptible_sync_poll(&u->peer_wait,
+					POLLOUT | POLLWRNORM | POLLWRBAND);
=20
 	if (msg->msg_name)
 		unix_copy_addr(msg, skb->sk);



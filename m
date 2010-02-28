From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH V2] net: add accounting for socket backlog
Date: Sun, 28 Feb 2010 06:31:11 +0100
Message-ID: <1267335071.9082.56.camel@edumazet-laptop>
References: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Zhu Yi <yi.zhu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:41083 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750770Ab0B1FbQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 00:31:16 -0500
Received: by bwz1 with SMTP id 1so526593bwz.21
        for <netdev@vger.kernel.org>; Sat, 27 Feb 2010 21:31:15 -0800 (PST)
In-Reply-To: <1267176464-426-1-git-send-email-yi.zhu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 f=C3=A9vrier 2010 =C3=A0 17:27 +0800, Zhu Yi a =C3=A9cri=
t :
> We got system OOM while running some UDP netperf testing on the loopb=
ack
> device. The case is multiple senders sent stream UDP packets to a sin=
gle
> receiver via loopback on local host. Of course, the receiver is not a=
ble
> to handle all the packets in time. But we surprisingly found that the=
se
> packets were not discarded due to the receiver's sk->sk_rcvbuf limit.
> Instead, they are kept queuing to sk->sk_backlog and finally ate up a=
ll
> the memory. We believe this is a secure hole that a none privileged u=
ser
> can crash the system.
>=20
> The root cause for this problem is, when the receiver is doing
> __release_sock() (i.e. after userspace recv, kernel udp_recvmsg ->
> skb_free_datagram_locked -> release_sock), it moves skbs from backlog=
 to
> sk_receive_queue with the softirq enabled. In the above case, multipl=
e
> busy senders will almost make it an endless loop. The skbs in the
> backlog end up eat all the system memory.
>=20
> The patch fixed this problem by adding accounting for the socket
> backlog. So that the backlog size can be restricted by protocol's cho=
ice
> (i.e. UDP).
>=20
> Reported-by: Alex Shi <alex.shi@intel.com>
> Cc: David Miller <davem@davemloft.net>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Zhu Yi <yi.zhu@intel.com>
> ---
> V2: remove atomic operation for sk_backlog.len
>     limit UDP backlog size to 2*sk->sk_rcvbuf
>=20

> +
>  static inline int sk_backlog_rcv(struct sock *sk, struct sk_buff *sk=
b)
>  {
> +	sk->sk_backlog.len -=3D skb->truesize;
>  	return sk->sk_backlog_rcv(sk, skb);
>  }
> =20

I am afraid sk_backlog_rcv() is not always called with lock held, and
not always called to process backlog (see TCP ucopy.prequeue)

If you take a look at __release_sock() for example, we make the backlog
private to the process before handling it (outside of lock_sock())

Therefore, I suggest doing the 'substraction' outside of
sk_backlog_rcv().

diff --git a/net/core/sock.c b/net/core/sock.c
index e1f6f22..57271cb 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1520,6 +1520,7 @@ static void __release_sock(struct sock *sk)
=20
        do {
                sk->sk_backlog.head =3D sk->sk_backlog.tail =3D NULL;
+               sk->sk_backlog.len =3D 0;
                bh_unlock_sock(sk);
=20
                do {


Ah, I see __release_sock() is already doing a preemption check, please
ignore my previous comment, when I said "__release_sock() could run
forever with no preemption, even with a limit on backlog"

Thanks



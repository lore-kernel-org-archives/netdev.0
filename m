From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Thu, 23 Sep 2010 07:05:00 +0200
Message-ID: <1285218300.2380.68.camel@edumazet-laptop>
References: <4C9A7F7F.5010507@gmail.com>
	 <1285195419.2380.39.camel@edumazet-laptop>
	 <20100922.205324.68141587.davem@davemloft.net>
	 <20100922.212332.45886457.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jarkao2@gmail.com, penguin-kernel@I-love.SAKURA.ne.jp,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:41165 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752804Ab0IWFFH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 01:05:07 -0400
In-Reply-To: <20100922.212332.45886457.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 septembre 2010 =C3=A0 21:23 -0700, David Miller a =C3=A9=
crit :
> From: David Miller <davem@davemloft.net>
> Date: Wed, 22 Sep 2010 20:53:24 -0700 (PDT)
>=20
> > From: Eric Dumazet <eric.dumazet@gmail.com>
> > Date: Thu, 23 Sep 2010 00:43:39 +0200
> >=20
> >> (A) (this is used in net/sunrpc/xprtsock.c)
> >> read_lock(&sk->sk_callback_lock) (without blocking BH)
> >> <BH>
> >> spin_lock(&sk->sk_slock.slock);
> >> ...
> >> read_lock(&sk->sk_callback_lock);
> >> ...
> >=20
> > What's the exact path that leads to this?  I looked quickly and cou=
ldn't
> > find which sunrpc callback override does it.
>=20
> Sorry, I'm being unusually dense at the moment, ignore this question =
:-)

No problem ;)

But we might answer it anyway for other readers :

vi +1417 net/sunrpc/xprtsock.c

static void xs_udp_write_space(struct sock *sk)
{
        read_lock(&sk->sk_callback_lock);

// We can be interrupted here and call INPUT_PATH()

        /* from net/core/sock.c:sock_def_write_space */
        if (sock_writeable(sk))
                xs_write_space(sk);

        read_unlock(&sk->sk_callback_lock);
}

INPUT_PATH()
{
	spin_lock(&sk->slock);
	queue skb to receive queue or backlog
	spin_unlock(&sk->slock);
}


If another cpu does (C), we can deadlock.

C)
spin_lock_bh(&sk->sk_slock)
=2E..
write_lock_bh(&sk->sk_callback_lock)
=2E..

Then we can have a deadlock with (A)

CPU1 [A]                                CPU2 [C]
read_lock(&sk->sk_callback_lock)
<BH>                                    spin_lock_bh(&sk->sk_slock)
<wait to spin_lock(slock)>
                                        <wait to write_lock_bh(callback=
_lock)>


It seems only TCP stack contains [C] cases, in very unlikely paths, but=
 still...

Since all AF_INET sockets share the same af_callback_key=20
*and* the same af_family_slock_keys, lockdep warned Tetsuo because
 it detects an UDP [A] case and a TCP [C] case.




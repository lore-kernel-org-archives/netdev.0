From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: sk_add_backlog() take rmem_alloc
 into account
Date: Wed, 28 Apr 2010 17:52:04 +0200
Message-ID: <1272469924.2267.80.camel@edumazet-laptop>
References: <4BD6E887.3000804@athenacr.com>
	 <20100427.095108.68126984.davem@davemloft.net>
	 <1272388439.2295.369.camel@edumazet-laptop>
	 <20100427.102038.57469310.davem@davemloft.net>
	 <1272389872.2295.405.camel@edumazet-laptop>
	 <1272399662.2343.12.camel@edumazet-laptop>  <4BD85718.5000404@athenacr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, therbert@google.com,
	netdev@vger.kernel.org, rick.jones2@hp.com
To: Brian Bloniarz <bmb@athenacr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:47696 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750859Ab0D1Pwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Apr 2010 11:52:40 -0400
Received: by bwz19 with SMTP id 19so111bwz.21
        for <netdev@vger.kernel.org>; Wed, 28 Apr 2010 08:52:39 -0700 (PDT)
In-Reply-To: <4BD85718.5000404@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 28 avril 2010 =C3=A0 11:41 -0400, Brian Bloniarz a =C3=A9cr=
it :

> > =20
> > +/*
> > + * Take into account size of receive queue and backlog queue
> > + */
> > +static inline bool sk_rcvqueues_full(const struct sock *sk, const =
struct sk_buff *skb)
> > +{
> > +	unsigned int qsize =3D sk->sk_backlog.len + atomic_read(&sk->sk_r=
mem_alloc);
> > +
> > +	return qsize + skb->truesize > sk->sk_rcvbuf;
> > +}
> > +
>=20
> Reading sk_backlog.len without the socket lock held seems to
> contradict the comment in sock.h:
>   *	@sk_backlog: always used with the per-socket spinlock held
>   ...
> struct sock {
>=20
>         ...
> 	/*
> 	 * The backlog queue is special, it is always used with
> 	 * the per-socket spinlock held and requires low latency
> 	 * access. Therefore we special case it's implementation.
> 	 */
> 	struct { ... } sk_backlog;
>=20
> Is this just a doc mismatch or does sk_backlog.len need to use
> atomic_read & atomic_set?
>=20

I'll submit a doc cleanup, and will avoid this 32bit hole in a reorg of
struct sock layout.

We read 'sk_backlog.len'  without lock to have a hint. We could have a
false positive only when queue is full, so this is not a big deal.

Then, after locking, we call sk_rcvqueues_full() once again.

Thanks for reviewing !



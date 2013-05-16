From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: gso: do not generate out of order packets
Date: Wed, 15 May 2013 21:19:01 -0700
Message-ID: <1368677941.4519.85.camel@edumazet-glaptop>
References: <1368668281.4519.75.camel@edumazet-glaptop>
	 <CAHo-OozZz4yx5iuoEWcq5vTJvJ0b_5bNbiQuc4PMw22jBZOxpg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:45870 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751162Ab3EPETE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 00:19:04 -0400
Received: by mail-pb0-f54.google.com with SMTP id ro8so1945565pbb.41
        for <netdev@vger.kernel.org>; Wed, 15 May 2013 21:19:04 -0700 (PDT)
In-Reply-To: <CAHo-OozZz4yx5iuoEWcq5vTJvJ0b_5bNbiQuc4PMw22jBZOxpg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 20:58 -0700, Maciej =C5=BBenczykowski wrote:
> I'd be worried that calling the destructor that many times would caus=
e
> performance problems
> (and only call the destructor and do memory accounting on the last se=
gment).
>=20
> Could we instead move the queue mapping into the skb somehow instead?

There is no performance problem, because all these packets are going to
be freed at the same time from TX completion handler.

The socket cache lines we use (sk->sk_state, sk->sk_wmem_alloc) are hot=
=2E

Anyway its way cleaner propagating socket information, as it might be
needed by netfilter or classifiers.

Some months ago I tested a variant of sock_wfree() not testing
sk>sk_state as TCP sockets set SOCK_USE_WRITE_QUEUE flag, and I had no
change in performance. sk_state & sk_wmem_alloc were on separate cache
lines :

offsetof(struct sock, sk_flags) =3D 0xe8
offsetof(struct sock, sk_wmem_alloc) =3D 0x104

void sock_fast_wfree(struct sk_buff *skb)
{
        struct sock *sk =3D skb->sk;

        if (atomic_sub_and_test(skb->truesize, &sk->sk_wmem_alloc))
                __sk_free(sk);
}

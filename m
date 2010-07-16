From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC] act_cpu: packet distributing
Date: Fri, 16 Jul 2010 06:42:26 +0200
Message-ID: <1279255346.2433.16.camel@edumazet-laptop>
References: <1279077475-2956-1-git-send-email-xiaosuo@gmail.com>
	 <1279078875.2444.103.camel@edumazet-laptop>
	 <AANLkTimPmXWyAspJqnya7aM_vDRNzDdJJf2bl7CYrAXN@mail.gmail.com>
	 <1279198139.4510.710.camel@bigi>
	 <1279212897.2496.133.camel@edumazet-laptop>
	 <AANLkTiljdBpQkZAGybwFQtej-_j7sFtD72CTErT9TaOX@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37482 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751310Ab0GPEmc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 00:42:32 -0400
Received: by wyb42 with SMTP id 42so1343515wyb.19
        for <netdev@vger.kernel.org>; Thu, 15 Jul 2010 21:42:31 -0700 (PDT)
In-Reply-To: <AANLkTiljdBpQkZAGybwFQtej-_j7sFtD72CTErT9TaOX@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 16 juillet 2010 =C3=A0 07:30 +0800, Changli Gao a =C3=A9cri=
t :
> On Fri, Jul 16, 2010 at 12:54 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:

> > Even if we solve this locking problem, using percpu variables, act_=
cpu
> > hits another problem :
> >
> > The socket refcount, taken by the 'master' cpu, and released by the
> > consumer cpu.
> This is why I asked if I can assign sk to skb.
>=20

This assignement doesnt change the cache line ping pong problem.

Let me explain for you :

You lookup the TCP or UDP socket. This automatically takes a refcount o=
n
it (atomic operation on sk->sk_refcnt).

Then you assign sk to skb.  (skb->sk =3D sk)

Then you transfert skb handling to another cpu (IPI cost already in RPS
as we all know)

This remote cpu finds skb->sk (and avoids the lookup/refcnt) and handle=
s
the packet through TCP/UDP stack.

This remote cpu _releases_ the socket refcount.

Conclusion :

"The socket refcount, taken by the 'master' cpu, and released by the
consumer cpu."




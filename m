From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] socket sk_sndmsg_page waste
Date: Tue, 06 Dec 2011 14:01:19 -0500 (EST)
Message-ID: <20111206.140119.1263464283287684389.davem@davemloft.net>
References: <1323154416.2467.27.camel@edumazet-laptop>
	<1323188117.2448.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60646 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab1LFTBW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 14:01:22 -0500
In-Reply-To: <1323188117.2448.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 06 Dec 2011 17:15:17 +0100

> Le mardi 06 d=E9cembre 2011 =E0 07:53 +0100, Eric Dumazet a =E9crit :
>> TCP can steer one page of memory per socket to cook outgoing frames.
>>=20
>> This means a machine handling long living sockets can consume a lot =
of
>> ram.
>>=20
>> 1.000.000 tcp sockets : up to 4GB of allocated memory, if some write=
s
>> had been done on these sockets.
>>=20
>> It would make sense to use a per thread page as a pool, instead of a=
 per
>> socket pool, and remove sk_sndmsg_page/off fields.
>>=20
>> Problem with this strategy is impact outside of net tree, and a cost=
 at
>> thread creation/destruction.
>>=20
>> [ But this could be used in fs/pipe.c or fs/splice.c code..., so tha=
t
>> small writes() dont allocate a full page but try to reuse the "per
>> task_struct" page ]
>>=20
>>=20
>=20
> Another idea would be to use a percpu variable, to get proper NUMA
> affinity as well, and no extra cost at thread create/delete time.
>=20
> Only 'problem' is we can sleep (pagefault) in
> skb_copy_to_page_nocache(), so special care must be taken (disabling
> preemption wont prevent another thread on same cpu can use the same
> page)

I think you're going to end up adding overhead to implement this proper=
ly,
first you'll make it per-thread but then you'll want a per-cpu array
per-thread to get NUMA affinities et al. right.

Also, keeping the page per-socket gives a certain piece of mind, that
leaking socket data from one connection to another accidently is that
much less likely.

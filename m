From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: speedup udp receive path
Date: Sat, 01 May 2010 13:42:59 +0200
Message-ID: <1272714179.2230.151.camel@edumazet-laptop>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <20100427.150817.84390202.davem@davemloft.net>
	 <1272406693.2343.26.camel@edumazet-laptop>  <1272454432.14068.4.camel@bigi>
	 <1272458001.2267.0.camel@edumazet-laptop>  <1272458174.14068.16.camel@bigi>
	 <1272463605.2267.70.camel@edumazet-laptop> <1272498293.4258.121.camel@bigi>
	 <1272514176.2201.85.camel@edumazet-laptop> <1272540952.4258.161.camel@bigi>
	 <u2l412e6f7f1004290512x7fcdb5c3w591c6446d676502@mail.gmail.com>
	 <1272545108.2222.65.camel@edumazet-laptop> <1272547061.4258.174.camel@bigi>
	 <1272547307.2222.83.camel@edumazet-laptop> <1272548258.4258.185.camel@bigi>
	 <1272548980.2222.87.camel@edumazet-laptop> <1272549408.4258.189.camel@bigi>
	 <1272573383.3969.8.camel@bigi>  <1272655814.3879.8.camel@bigi>
	 <1272660000.2230.4.camel@edumazet-laptop>  <1272672394.14499.1.camel@bigi>
	 <1272693424.2230.75.camel@edumazet-laptop> <1272713014.14499.21.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, therbert@google.com,
	shemminger@vyatta.com, netdev@vger.kernel.org,
	Eilon Greenstein <eilong@broadcom.com>,
	Brian Bloniarz <bmb@athenacr.com>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:61010 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751539Ab0EALnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 May 2010 07:43:06 -0400
Received: by bwz19 with SMTP id 19so554551bwz.21
        for <netdev@vger.kernel.org>; Sat, 01 May 2010 04:43:04 -0700 (PDT)
In-Reply-To: <1272713014.14499.21.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 01 mai 2010 =C3=A0 07:23 -0400, jamal a =C3=A9crit :
> On Sat, 2010-05-01 at 07:57 +0200, Eric Dumazet wrote:
>=20
> > I changed your program a bit to use EV_PERSIST, (to avoid epoll_ctl=
()
> > overhead for each packet...)
>=20
> Thats a different test case then ;-> You can also get rid of the time=
r
> (I doubt it will show much difference in results) - I have it in ther=
e
> because it i am trying to replicate what i saw causing the regression=
=2E
>=20
> > RPS off : 220.000 pps=20
> >=20
> > RPS on (ee mask) : 700.000 pps  (with a slightly modified tg3 drive=
r)
> > 96% of delivered packets
> >=20
>=20
> That's a very very huge gap. What were the numbers before you changed=
 to
> EV_PERSIST?

But, whole point of epoll is to not change interest each time you get a=
n
event.

Without EV_PERSIST, you need two more syscalls per recvfrom()

epoll_wait()
 epoll_ctl(REMOVE)
 epoll_ctl(ADD)
 recvfrom()

Even poll() would be faster in your case

poll(one fd)
recvfrom()



> Note: i did not add any of your other patches for dst refcnt, sockets
> etc. Were you running with those patches in these tests? I will try t=
he
> next opportunity i get to have latest kernel + those patches.=20
>=20
> > This is on tg3 adapter, and tg3 has copybreak feature : small packe=
ts
> > are copied into skb of the right size.
>=20
> Ok, so the driver tuning is also important then (and it shows in the
> profile).

I always thought copybreak was borderline...

It can help to reduce memory footprint (allocating 128 bytes instead of
2048/4096 bytes per frame), but with RPS, it would make sense to perfor=
m
copybreak after RPS, not before.

Reducing memory footprint also means less changes on
udp_memory_allocated /tcp_memory_allocate (memory reclaim logic)




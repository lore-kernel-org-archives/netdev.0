From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ICMP echo reply fails
Date: Fri, 26 Mar 2010 23:46:15 +0100
Message-ID: <1269643575.2256.19.camel@edumazet-laptop>
References: <2acbd3e41003261448q26cb19d4w63487894b24f0254@mail.gmail.com>
	 <1269641190.2256.1.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:39431 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754459Ab0CZWqT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 18:46:19 -0400
Received: by bwz1 with SMTP id 1so2205189bwz.21
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 15:46:18 -0700 (PDT)
In-Reply-To: <1269641190.2256.1.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 26 mars 2010 =C3=A0 23:06 +0100, Eric Dumazet a =C3=A9crit =
:
> Le vendredi 26 mars 2010 =C3=A0 16:48 -0500, Andy Fleming a =C3=A9cri=
t :
> > For various reasons, we have been running a stress test on one of o=
ur
> > boards.  The test consists of initiating 2-3 flood pings from a
> > Windows box running Cygwin, plus one additional ping we use as a
> > "heartbeat".  The ping flood is overwhelming our board (we're dropp=
ing
> > packets at a prodigious rate), but the board continues to respond f=
or
> > a while.  In addition, we are running a script on the  board which
> > alternates bringing up and bringing down the interface every ten
> > seconds.  After a highly variable amount of time, the board stops
> > replying to the pings.  We suspected a driver issue, however, on
> > closer inspection, we are still able to send and receive packets (I
> > can ping *from* the board to the PC, and I can *telnet* from the PC=
 to
> > the board).  We tried pinging the board from another PC, and it als=
o
> > failed.  Essentially, ICMP echo requests are being ignored (A glanc=
e
> > at memory indicates that packets are arriving, but no packets are
> > being enqueued to the ethernet controller).  We still have a lot mo=
re
> > debugging to do, but I was wondering if anyone had ever seen someth=
ing
> > like this, or might be quicker to realize the obvious mistake we're
> > making.
> >=20
> > Thanks,
> > Andy Fleming
>=20
>=20
> kernel version ?
>=20
> NIC driver ?
>=20
> Are ICMP echo request received ? (grep Icmp /proc/net/snmp)
>=20

vi +1166 net/ipv4/icmp.c

        /* Enough space for 2 64K ICMP packets, including
         * sk_buff struct overhead.
         */
        sk->sk_sndbuf =3D
                (2 * ((64 * 1024) + sizeof(struct sk_buff)));


If many ICMP replies are lost/leaked by your driver when doing up/down
things, ICMP socket can consume all its sndbuf reserve and no more icmp
replies can be sent (a reboot is needed)

You could try changing sk->sk_sndbuf to 0x7FFFFFFF  to see if the icmp
replies survive longer to your tests. If this is the case, then find th=
e
leaks in your driver (tx path, maybe you forgot to free skbs in some
reset cases ?)



We should add a SNMP counter for failed ip_append() calls in
icmp_push_reply()...



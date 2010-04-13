From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: SO_REUSEADDR with UDP (again)
Date: Tue, 13 Apr 2010 12:39:23 +0200
Message-ID: <1271155163.16881.244.camel@edumazet-laptop>
References: <20100413093408.GA16595@myhost.felk.cvut.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Michal Svoboda <michal.svoboda@agents.felk.cvut.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f219.google.com ([209.85.218.219]:33452 "EHLO
	mail-bw0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752791Ab0DMKjb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Apr 2010 06:39:31 -0400
Received: by bwz19 with SMTP id 19so7581bwz.21
        for <netdev@vger.kernel.org>; Tue, 13 Apr 2010 03:39:29 -0700 (PDT)
In-Reply-To: <20100413093408.GA16595@myhost.felk.cvut.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 avril 2010 =C3=A0 11:34 +0200, Michal Svoboda a =C3=A9crit =
:
> Hello,
>=20
> (redirected here from LKML)
>=20
> I found SO_REUSEADDR on UDP sockets to behave somewhat nasty. If you
> create a UDP socket with that flag and bind it to a port, then anyone
> doing the same later will "steal" your packets, ie.
>=20
> 1. process A binds to port 12345 with SO_REUSEADDR, packets to that p=
ort
>    go to process A

why process A sets SO_REUSEADDR ?

> 2. process B binds to port 12345 with SO_REUSEADDR, packets to that p=
ort
>    now go to process B

	Or not... this is implementation (un)defined.

> 3. A dies, fires up again, packets go back to A
        Or not. Not documented.
> 4. A dies, does not fire up, packets go to B, as if they were stacked
>=20
> And this works even if A and B are owned by different users, thus any=
one
> can "steal" packets from anyone as long as they use SO_REUSEADDR.
> However, in most programs that's the default.

Really ? They are very buggy then.

>=20
> Furthermore, one can lock-out a particular source from being "stolen"=
 by
> using connect() to that source, ie.
>=20
> 1. process A binds to port 12345 with SO_REUSEADDR, gets the packets
> 2. B does the same, gets the packets, but also connect()s to the sour=
ce
>    of the packets
> 3. A can now restart or try to bind again, but does not get the packe=
ts
>    (from that source)
>=20
> (I haven't tested the case if A also issues a connect() even if it do=
es
> not receive packets.)
>=20
> All of this seems confusing to me, and the fact that users can steal
> packets from each other seems like a mild security risk. I've found s=
ome
> discussions about this from circa 2002, but the above cases were not
> mentioned. So - a problem or not?
>=20
>=20

Why do you use REUSEADDR ? This is doing what is documented.

       SO_REUSEADDR
              Indicates that the rules used in validating addresses  su=
pplied
              in  a  bind(2) call should allow reuse of local addresses=
=2E  For
              AF_INET sockets this means that a socket may bind, except=
  when
              there is an active listening socket bound to the address.=
  When
              the listening socket is bound to  INADDR_ANY  with  a  sp=
ecific
              port then it is not possible to bind to this port for any=
 local
              address.  Argument is an integer boolean flag.


An UDP application wanting a port for its exclusive use dont set
REUSEADDR, or basically allows anybody to bind an udp socket to same
port, and potentially steal incoming frames.

REUSEADDR is usually used when an application has several sockets bound
to same port, but different IP addresses (or bound to different devices=
)




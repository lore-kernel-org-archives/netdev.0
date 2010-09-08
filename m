From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet: dont set inet_rcv_saddr in connect()
Date: Wed, 08 Sep 2010 06:57:37 +0200
Message-ID: <1283921857.2634.747.camel@edumazet-laptop>
References: <4C865C21.5010803@ans.pl>
	 <1283877391.2313.62.camel@edumazet-laptop>
	 <1283887569.2634.95.camel@edumazet-laptop>
	 <20100907.125947.39192078.davem@davemloft.net>
	 <1283895316.2634.248.camel@edumazet-laptop>  <4C86F653.6070707@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, ole@ans.pl,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:64352 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab0IHE5n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 00:57:43 -0400
Received: by fxm16 with SMTP id 16so504674fxm.19
        for <netdev@vger.kernel.org>; Tue, 07 Sep 2010 21:57:42 -0700 (PDT)
In-Reply-To: <4C86F653.6070707@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 07 septembre 2010 =C3=A0 22:34 -0400, Brian Haley a =C3=A9crit=
 :

> Is this really the right thing to do?  Linux has been doing this fore=
ver,
> right?  Just like BSD has done it forever.  The way I've always "clea=
red"
> a local address is to set the address family to AF_UNSPEC on the next
> connect() call, as mentioned on the man page.  I just want to make su=
re
> we're not changing something just to work around a broken application=
,
> sendto()/sendmsg() work perfect in this case by not setting the local=
 address.
>=20
> BTW, it seems as though the reason this might only happen sometimes i=
s
> that if the first connect() is to 127.0.0.1, you won't be able to the=
n
> try and connect to say, 192.168.1.1.  If you first connect() to a rem=
ote
> address things will probably just work.


I believe we have the following choice :

1) connect(AF_UNIX) sets the remote address/port
   bind() sets the local port (and optionally address)
   connect(AF_UNSPEC) clears remote addess/port,
                      let local address/port unchanged

2) Correct UDP hashing, when local address changes from 0 to x.y.z.t
   (cost : two locks taken), and a possible packet drop during the
operation.

   Document that connect() also sets local address, and that before
doing a second connect() to change remote address, its mandatory to
first issue a connect(AF_UNSPEC) to clear local address (if not locked
by a prior bind() call)




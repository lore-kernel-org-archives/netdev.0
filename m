From: David Lamparter <equinox@diac24.net>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Fri, 10 Dec 2010 15:31:40 +0100
Message-ID: <20101210143140.GD3536057@jupiter.n2.diac24.net>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
 <1291906948.19763.16.camel@localhost>
 <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
 <20101209.113806.71114756.davem@davemloft.net>
 <AANLkTi=7NLkHW6c88gUcyW8i0Wwmf2Cw4NdmRiGci4kE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	srk@ti.com, netdev@vger.kernel.org
To: =?utf-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:41961 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750983Ab0LJObu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Dec 2010 09:31:50 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTi=7NLkHW6c88gUcyW8i0Wwmf2Cw4NdmRiGci4kE@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 10, 2010 at 03:18:11PM +0100, Micha=C5=82 Miros=C5=82aw wro=
te:
> I'm trying to understand the dependency because it looks artificial f=
or me.

You have the data you want to send in the RAM, somewhere, possibly
scattered. The application calls sendfile(). The kernel puts the
transmission in the network card's queue, which might already have lots
of entries.

A millisecond later - an eternity for the CPU - the card decides to do
the transmission.

However, the data might have changed in the meantime.

sendfile() is defined so that it works asynchronously, that means if yo=
u
change the data while it is in the queue, you get unpredictable results=
=2E

But, what you should NOT get is packets with an invalid checksum.
Whatever data you are sending, it needs to have a correct checksum.

Now, if the card does the checksum itself, everything is fine. But what
are you supposed to do if the card can't checksum? Call back the kernel
at the point where the card does the TX? That's pointless (and racy).
Pre-calculate the Checksum at submission time? Doesn't work, you would
have to make a copy of the data, so it doesn't change anymore, so the
checksum stays correct. But not copying the data is the whole point of
sendfile().


You see why SG without HW checksum is useless here?


-David


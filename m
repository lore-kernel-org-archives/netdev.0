From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Fri, 10 Dec 2010 17:26:19 +0100
Message-ID: <1291998379.3580.154.camel@edumazet-laptop>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	 <1291906948.19763.16.camel@localhost>
	 <AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
	 <20101209.113806.71114756.davem@davemloft.net>
	 <AANLkTi=7NLkHW6c88gUcyW8i0Wwmf2Cw4NdmRiGci4kE@mail.gmail.com>
	 <20101210143140.GD3536057@jupiter.n2.diac24.net>
	 <AANLkTi=cVufUAHn6LRs_vG-cW2cY87SdP9MOE7i5Ru09@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Lamparter <equinox@diac24.net>,
	David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	srk@ti.com, netdev@vger.kernel.org, Jens Axboe <axboe@kernel.dk>
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39821 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756546Ab0LJQ0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 11:26:25 -0500
Received: by wyb28 with SMTP id 28so3630717wyb.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 08:26:23 -0800 (PST)
In-Reply-To: <AANLkTi=cVufUAHn6LRs_vG-cW2cY87SdP9MOE7i5Ru09@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 10 d=C3=A9cembre 2010 =C3=A0 17:01 +0100, Micha=C5=82 Miros=
=C5=82aw a =C3=A9crit :
> W dniu 10 grudnia 2010 15:31 u=C5=BCytkownik David Lamparter
> <equinox@diac24.net> napisa=C5=82:
> > On Fri, Dec 10, 2010 at 03:18:11PM +0100, Micha=C5=82 Miros=C5=82aw=
 wrote:
> >> I'm trying to understand the dependency because it looks artificia=
l for me.
> >
> > You have the data you want to send in the RAM, somewhere, possibly
> > scattered. The application calls sendfile(). The kernel puts the
> > transmission in the network card's queue, which might already have =
lots
> > of entries.
> >
> > A millisecond later - an eternity for the CPU - the card decides to=
 do
> > the transmission.
> >
> > However, the data might have changed in the meantime.
> >
> > sendfile() is defined so that it works asynchronously, that means i=
f you
> > change the data while it is in the queue, you get unpredictable res=
ults.
> >
> > But, what you should NOT get is packets with an invalid checksum.
> > Whatever data you are sending, it needs to have a correct checksum.
> >
> > Now, if the card does the checksum itself, everything is fine. But =
what
> > are you supposed to do if the card can't checksum? Call back the ke=
rnel
> > at the point where the card does the TX? That's pointless (and racy=
).
> > Pre-calculate the Checksum at submission time? Doesn't work, you wo=
uld
> > have to make a copy of the data, so it doesn't change anymore, so t=
he
> > checksum stays correct. But not copying the data is the whole point=
 of
> > sendfile().
>=20
> The question is do we really want good checksum for bogus data?

A frame must be sent with good checksum, or you violate very basic
transport rule. You mix several layers here.

>  I
> think that what matters is that good data (it had not changed between
> queuing and sending, and so the checksum does not depend on whether
> hardware or software calculated it) need to be accompanied by good
> checksum. For broken data it would be even better to not send
> anything, but that's not always possible. Bad checksum in this case i=
s
> actually a good thing as it clearly shows that something is broken in
> the sender and avoids accepting the data as valid at the receiving
> end.
>=20

a crc checksum is very lazy, and not guarantee the file you received is
consistent. Is a "per frame" checksum, not a "per file" checksum. If yo=
u
want, add a MD5 sum and all be fine.

> sendfile() is supposed to replace read()/write() loops to avoid
> copying data buffers. Whatever the optimizations, it has no additiona=
l
> cavat that it might corrupt the transfer. Fixing the checksum in case
> data gets corrupted is not the right thing, I think.
>=20

You cannot fix the dam thing, or you MUST play VM games, that we cant t=
o
avoid at the very beginning.

> The change of file data might happen if sendfile() submits page from
> pagecache when something writes to the file, or when an application
> modifies vmsplice()-submitted memory. In current kernel sendfile() is
> a wrapper around splice(), and so has a kernel pipe buffer between
> file and the socket. Can this hide the possible data changes?

No. Nothing in sendfile() API states that underlying file cannot change=
=2E

If we said : "We dont allow page content to change", then we _must_ add
special logic to detect a buggy application wont change the page while
we compute checksum or between this computation and final DMA to device=
=2E
=20
That means playing VM games, and that is expensive, particularly in
multi threaded apps.

We instead say that : As we dont want to make this expensive checks, an
application is allowed to write into the page (but what should it, it
would be very stupid no ???), and a sendfile() wont be stopped/stalled
because of invalid checksum (because checksums are done after the page
content is fetched by NIC hardware)

But but but : the receiver of sendfile() get a file with possible
inconsistent content. In order to avoid this, higher level should take
locks (samba does), or make sure file is readonly.

> Unless I totally misunderstood, you say that we accept bogus data to
> being sent using sendfile(). If yes, then we might as well allow
> broken checksum (CPU calculated, before data changed and then was sen=
t
> to network).
>=20
>=20


> If the splice/sendfile is taken out of the picture, are there any
> other scenarios, when data pages could be changed after
> ndo_start_xmit() entry and before TX DMA completion (between dma_map
> .. dma_unmap)? And is it really what can happen with splice/sendfile?
>=20

If you want to perform checksum before DMA to device, then you also
should copy the page into private storage (a bounce buffer), to make
sure checksum wont be invalid.

You add one copy. Your choice, but not ours.





From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: Adding Support for SG,GSO,GRO
Date: Fri, 10 Dec 2010 17:01:33 +0100
Message-ID: <AANLkTi=cVufUAHn6LRs_vG-cW2cY87SdP9MOE7i5Ru09@mail.gmail.com>
References: <FCCFB4CDC6E5564B9182F639FC356087035F21D9F9@dbde02.ent.ti.com>
	<1291906948.19763.16.camel@localhost>
	<AANLkTi=8zWMYWG0DU147B08nN7xcvwaB9Bpq9fE8_fBe@mail.gmail.com>
	<20101209.113806.71114756.davem@davemloft.net>
	<AANLkTi=7NLkHW6c88gUcyW8i0Wwmf2Cw4NdmRiGci4kE@mail.gmail.com>
	<20101210143140.GD3536057@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	srk@ti.com, netdev@vger.kernel.org, Jens Axboe <axboe@kernel.dk>
To: David Lamparter <equinox@diac24.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:58161 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756105Ab0LJQBe convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 11:01:34 -0500
Received: by qwa26 with SMTP id 26so4007720qwa.19
        for <netdev@vger.kernel.org>; Fri, 10 Dec 2010 08:01:33 -0800 (PST)
In-Reply-To: <20101210143140.GD3536057@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

W dniu 10 grudnia 2010 15:31 u=BFytkownik David Lamparter
<equinox@diac24.net> napisa=B3:
> On Fri, Dec 10, 2010 at 03:18:11PM +0100, Micha=B3 Miros=B3aw wrote:
>> I'm trying to understand the dependency because it looks artificial =
for me.
>
> You have the data you want to send in the RAM, somewhere, possibly
> scattered. The application calls sendfile(). The kernel puts the
> transmission in the network card's queue, which might already have lo=
ts
> of entries.
>
> A millisecond later - an eternity for the CPU - the card decides to d=
o
> the transmission.
>
> However, the data might have changed in the meantime.
>
> sendfile() is defined so that it works asynchronously, that means if =
you
> change the data while it is in the queue, you get unpredictable resul=
ts.
>
> But, what you should NOT get is packets with an invalid checksum.
> Whatever data you are sending, it needs to have a correct checksum.
>
> Now, if the card does the checksum itself, everything is fine. But wh=
at
> are you supposed to do if the card can't checksum? Call back the kern=
el
> at the point where the card does the TX? That's pointless (and racy).
> Pre-calculate the Checksum at submission time? Doesn't work, you woul=
d
> have to make a copy of the data, so it doesn't change anymore, so the
> checksum stays correct. But not copying the data is the whole point o=
f
> sendfile().

The question is do we really want good checksum for bogus data? I
think that what matters is that good data (it had not changed between
queuing and sending, and so the checksum does not depend on whether
hardware or software calculated it) need to be accompanied by good
checksum. For broken data it would be even better to not send
anything, but that's not always possible. Bad checksum in this case is
actually a good thing as it clearly shows that something is broken in
the sender and avoids accepting the data as valid at the receiving
end.

sendfile() is supposed to replace read()/write() loops to avoid
copying data buffers. Whatever the optimizations, it has no additional
cavat that it might corrupt the transfer. Fixing the checksum in case
data gets corrupted is not the right thing, I think.

The change of file data might happen if sendfile() submits page from
pagecache when something writes to the file, or when an application
modifies vmsplice()-submitted memory. In current kernel sendfile() is
a wrapper around splice(), and so has a kernel pipe buffer between
file and the socket. Can this hide the possible data changes?

Best Regards,
Micha=B3 Miros=B3aw

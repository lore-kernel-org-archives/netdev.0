From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] sendfile() and UDP socket
Date: Fri, 19 Sep 2008 16:14:12 +0300
Message-ID: <200809191614.14763.rdenis@simphalempin.com>
References: <1221387956.9204.7.camel@fry> <200809182031.01291.rdenis@simphalempin.com> <20080919.212854.19019802.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: johaahn@gmail.com, netdev@vger.kernel.org
To: Hirokazu Takahashi <taka@valinux.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:46579 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309AbYISNOR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2008 09:14:17 -0400
In-Reply-To: <20080919.212854.19019802.taka@valinux.co.jp>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 septembre 2008 15:28:54 Hirokazu Takahashi, vous avez =E9=
crit=A0:
> > > UDP is a datagram protocol, so I think applications using UDP sho=
uld
> > > care about the size of packets they are going to send rather than
> > > expecting that the messages will be split into several packets
> > > automatically. If some of the packets have lost, it will be reall=
y hard
> > > for the applications to re-create the same ones to send again.
> >
> > Also, why use UDP for this... If you want stream semantics, why not=
 use
> > TCP or SCTP instead?
>
> I think a lot of VoIP and video streaming services are working on UDP=
=2E

VoIP uses lots of small packets, considering the typical packetization =
times.=20
Using send(MSG_MORE) + sendfile would definitely be slower than a singl=
e=20
sendmsg() in such case, because the per-packet memcpy() will be quite s=
hort.

Video streaming typically does send lots of large packets, and might we=
ll read=20
the data from a mmap-able file. But video streaming protocols such as R=
TP=20
typically try to avoid fragmentation, so large sendfile() won't work.

> > > If you want send a large file over UDP, the typical code will be =
like:
> > >
> > > while (...) {
> > >         sendmsg(fd, &apl_header, sizeof(apl_header), MSG_MORE);
> > >         offset +=3D sendfile(fd, offset, count);
> > > }
> >
> > Correct me if I am wrong, but... Unless you have a big MTU (as _not=
_ in
> > 1500 bytes :D), doing an extra syscall might be slower than copying=
 data
> > in a single vectorized sendmsg() syscall.
>
> That's not true.
> Even if the MTU is small, you can send a UDP message whose size can b=
e
> up to 64KB at once. They will be split into several IP packets withou=
t
> any copies.

And you will encounter fragmentation, which sucks at high data rates.
As for low rates, you typically would not bother to optimize memcpy. Bu=
t more=20
importantly, you should not assume that the other end is only talking t=
o=20
you - it might as well be talking to many different people and not appr=
eciate=20
if all of them send lots of fragments.

And lets not get into how poorly fragmentation works through middleboxe=
s...

> And more, copying data will pollute the cache memory much, which cann=
ot
> be ignored if you want send tons of data of files.

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/

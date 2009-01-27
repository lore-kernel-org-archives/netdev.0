From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix setsockopt() locking errors
Date: Tue, 27 Jan 2009 09:08:46 +0000
Message-ID: <20090127090846.GD4197@ff.dom.local>
References: <20090126115012.GA5620@ff.dom.local> <497E2B76.4030901@ribosome.natur.cuni.cz> <20090127084525.GC4197@ff.dom.local> <1233046369.4984.5.camel@laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin =?iso-8859-2?Q?MOKREJ=A9?=
	<mmokrejs@ribosome.natur.cuni.cz>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.158]:26219 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbZA0JIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 04:08:52 -0500
Received: by fg-out-1718.google.com with SMTP id 13so52843fge.17
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 01:08:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1233046369.4984.5.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 27, 2009 at 09:52:49AM +0100, Peter Zijlstra wrote:
> On Tue, 2009-01-27 at 08:45 +0000, Jarek Poplawski wrote:
> > On Mon, Jan 26, 2009 at 10:30:30PM +0100, Martin MOKREJ=A9 wrote:
> > > The patch really did not help:
> > > http://bugzilla.kernel.org/show_bug.cgi?id=3D12515#c5
> > > Martin
> >=20
> > Actually, there is a little change: the warning triggerd in another
> > place (sock_setsockopt() -> sk_attach_filter()). So we could go dee=
per
> > with these changes, but I'm not sure this is the right way to fix.
> >=20
> > It looks like the scenario is very old, but probably wasn't reporte=
d
> > (maybe there is some lockdep improvement):
>=20
> Yes, they likely are very old, and yes we added a lockdep annotation =
to
> copy_to/from_user() to catch these.
>=20
> > A) sys_mmap2() -> mm->mmap_sem -> packet_mmap() -> sk_lock
> > B) sock_setsockopt() -> sk_lock -> copy_from_user() -> mm->mmap_sem
> >=20
> > packet_mmap() (net/packet/af_packet.c) seems to be the only place i=
n
> > net to implement mmap method, and using this lock order btw. On the
> > other hand copy_from_user() could be more popular under sk_lock, an=
d
> > I'm not sure these changes are necessary.
> >=20
> > Since I don't know enough neither sock/packet nor sys_mmap, I guess
> > some advice would be precious. It looks like Peter Zijlstra solved
> > similar problems in nfs, so I CC him.
>=20
> The NFS/sunrpc case was special in that it did copy_to/from_kernel, t=
hat
> is, it never actually touched user memory -- we taught the might_faul=
t()
> annotation about that.
>=20
> Can't you simply do the copy_from_user() before you take the sk_lock?
>=20

Since it's really needed, and Vegard started doing it like this, I
guess he will try to add the missing pieces.

Thanks again,
Jarek P.

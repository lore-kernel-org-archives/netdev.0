From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH] net: fix setsockopt() locking errors
Date: Tue, 27 Jan 2009 09:52:49 +0100
Message-ID: <1233046369.4984.5.camel@laptop>
References: <20090126115012.GA5620@ff.dom.local>
	 <497E2B76.4030901@ribosome.natur.cuni.cz>
	 <20090127084525.GC4197@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Martin =?UTF-8?Q?MOKREJ=C5=A0?= <mmokrejs@ribosome.natur.cuni.cz>,
	Vegard Nossum <vegard.nossum@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53660 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751124AbZA0Iw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 03:52:57 -0500
In-Reply-To: <20090127084525.GC4197@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2009-01-27 at 08:45 +0000, Jarek Poplawski wrote:
> On Mon, Jan 26, 2009 at 10:30:30PM +0100, Martin MOKREJ=C5=A0 wrote:
> > The patch really did not help:
> > http://bugzilla.kernel.org/show_bug.cgi?id=3D12515#c5
> > Martin
>=20
> Actually, there is a little change: the warning triggerd in another
> place (sock_setsockopt() -> sk_attach_filter()). So we could go deepe=
r
> with these changes, but I'm not sure this is the right way to fix.
>=20
> It looks like the scenario is very old, but probably wasn't reported
> (maybe there is some lockdep improvement):

Yes, they likely are very old, and yes we added a lockdep annotation to
copy_to/from_user() to catch these.

> A) sys_mmap2() -> mm->mmap_sem -> packet_mmap() -> sk_lock
> B) sock_setsockopt() -> sk_lock -> copy_from_user() -> mm->mmap_sem
>=20
> packet_mmap() (net/packet/af_packet.c) seems to be the only place in
> net to implement mmap method, and using this lock order btw. On the
> other hand copy_from_user() could be more popular under sk_lock, and
> I'm not sure these changes are necessary.
>=20
> Since I don't know enough neither sock/packet nor sys_mmap, I guess
> some advice would be precious. It looks like Peter Zijlstra solved
> similar problems in nfs, so I CC him.

The NFS/sunrpc case was special in that it did copy_to/from_kernel, tha=
t
is, it never actually touched user memory -- we taught the might_fault(=
)
annotation about that.

Can't you simply do the copy_from_user() before you take the sk_lock?


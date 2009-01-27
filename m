From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix setsockopt() locking errors
Date: Tue, 27 Jan 2009 08:45:26 +0000
Message-ID: <20090127084525.GC4197@ff.dom.local>
References: <20090126115012.GA5620@ff.dom.local> <497E2B76.4030901@ribosome.natur.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vegard Nossum <vegard.nossum@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
To: Martin =?iso-8859-2?Q?MOKREJ=A9?=
	<mmokrejs@ribosome.natur.cuni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.156]:4747 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755171AbZA0Ipd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 03:45:33 -0500
Received: by fg-out-1718.google.com with SMTP id 13so45076fge.17
        for <netdev@vger.kernel.org>; Tue, 27 Jan 2009 00:45:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <497E2B76.4030901@ribosome.natur.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 26, 2009 at 10:30:30PM +0100, Martin MOKREJ=A9 wrote:
> The patch really did not help:
> http://bugzilla.kernel.org/show_bug.cgi?id=3D12515#c5
> Martin

Actually, there is a little change: the warning triggerd in another
place (sock_setsockopt() -> sk_attach_filter()). So we could go deeper
with these changes, but I'm not sure this is the right way to fix.

It looks like the scenario is very old, but probably wasn't reported
(maybe there is some lockdep improvement):

A) sys_mmap2() -> mm->mmap_sem -> packet_mmap() -> sk_lock
B) sock_setsockopt() -> sk_lock -> copy_from_user() -> mm->mmap_sem

packet_mmap() (net/packet/af_packet.c) seems to be the only place in
net to implement mmap method, and using this lock order btw. On the
other hand copy_from_user() could be more popular under sk_lock, and
I'm not sure these changes are necessary.

Since I don't know enough neither sock/packet nor sys_mmap, I guess
some advice would be precious. It looks like Peter Zijlstra solved
similar problems in nfs, so I CC him.

Thanks,
Jarek P.

>=20
> Jarek Poplawski wrote:
> > On 24-01-2009 23:49, Vegard Nossum wrote:
> >> Hi,
> >>
> >> This survives basic testing here, but I don't know what that count=
s for
> >> when I couldn't reproduce the lockdep report in the first place. P=
lease
> >> review.
> >>
> >>
> >> Vegard
> >>
> >>
> >> From cc8bcd1c4fd219a31d6d191aefa4b4b57dadb9b0 Mon Sep 17 00:00:00 =
2001
> >> From: Vegard Nossum <vegard.nossum@gmail.com>
> >> Date: Sat, 24 Jan 2009 22:44:16 +0100
> >> Subject: [PATCH] net: fix setsockopt() locking errors
> >> MIME-Version: 1.0
> >> Content-Type: text/plain; charset=3Dutf-8
> >> Content-Transfer-Encoding: 8bit
> >>
> >> Martin MOKREJ.  <mmokrejs@ribosome.natur.cuni.cz> reported:
> >>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >>> [ INFO: possible circular locking dependency detected ]
> >>> 2.6.29-rc2-git1 #1
> >>> -------------------------------------------------------
> >>> tcpdump/3734 is trying to acquire lock:
> >>>  (&mm->mmap_sem){----}, at: [<c1053294>] might_fault+0x30/0x6b
> >>>
> >>> but task is already holding lock:
> >>>  (sk_lock-AF_PACKET){--..}, at: [<c12798c8>] sock_setsockopt+0x12=
b/0x4a4
> >>>
> >>> which lock already depends on the new lock.
> >> It turns out that sock_setsockopt() is calling copy_from_user() wh=
ile
> >> holding the lock on the socket.
> >=20
> > I guess it has been like this for some time, so it would be nice to
> > mention what scenario happens here, or IOW what exactly needs to ge=
t
> > these locks in reverse order.
> >=20
> >> We fix it by splitting the ioctl code
> >> so that one switch handles the ioctls that have their own code for
> >> reading from userspace, and one switch handles the cases that requ=
ire
> >> no additional reading.
> >>
> >> Reported-by: Martin MOKREJ.  <mmokrejs@ribosome.natur.cuni.cz>
> >> Signed-off-by: Vegard Nossum <vegard.nossum@gmail.com>
> >> ---
> >>  net/core/sock.c |  134 +++++++++++++++++++++++++++++++++++-------=
------------
> >>  1 files changed, 87 insertions(+), 47 deletions(-)
> >>
> >> diff --git a/net/core/sock.c b/net/core/sock.c
> >> index f3a0d08..6bd618d 100644
> >> --- a/net/core/sock.c
> >> +++ b/net/core/sock.c
> >> @@ -424,6 +424,80 @@ out:
> >>  	return ret;
> >>  }
> >> =20
> >> +static int sock_linger(struct sock *sk, char __user *optval, int =
optlen)
> > ...
> >> +static int sock_set_rcvtimeo(struct sock *sk, char __user *optval=
, int optlen)
> >> +{
> >> +	int ret;
> >> +	long rcvtimeo;
> >> +
> >> +	ret =3D sock_set_timeout(&rcvtimeo, optval, optlen);
> >=20
> > A check for error is needed here and below.
> >=20
> [cut]

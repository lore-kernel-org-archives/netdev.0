From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Wed, 01 Apr 2009 07:35:39 -0400
Message-ID: <49D3518B.1030403@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <200904011638.45135.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig9D46F49FD5418A8DAD72AF9E"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, anthony@codemonkey.ws,
	netdev@vger.kernel.org, kvm@vger.kernel.org
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:46566 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760944AbZDALd2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2009 07:33:28 -0400
In-Reply-To: <200904011638.45135.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig9D46F49FD5418A8DAD72AF9E
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Rusty Russell wrote:
> On Wednesday 01 April 2009 05:12:47 Gregory Haskins wrote:
>  =20
>> Bare metal: tput =3D 4078Mb/s, round-trip =3D 25593pps (39us rtt)
>> Virtio-net: tput =3D 4003Mb/s, round-trip =3D 320pps (3125us rtt)
>> Venet: tput =3D 4050Mb/s, round-trip =3D 15255 (65us rtt)
>>    =20
>
> That rtt time is awful.  I know the notification suppression heuristic
> in qemu sucks.
>
> I could dig through the code, but I'll ask directly: what heuristic do
> you use for notification prevention in your venet_tap driver?
>  =20

I am not 100% sure I know what you mean with "notification prevention",
but let me take a stab at it.

So like most of these kinds of constructs, I have two rings (rx + tx on
the guest is reversed to tx + rx on the host), each of which can signal
in either direction for a total of 4 events, 2 on each side of the
connection.  I utilize what I call "bidirectional napi" so that only the
first packet submitted needs to signal across the guest/host boundary.=20
E.g. first ingress packet injects an interrupt, and then does a
napi_schedule and masks future irqs.  Likewise, first egress packet does
a hypercall, and then does a "napi_schedule" (I dont actually use napi
in this path, but its conceptually identical) and masks future
hypercalls.  So thats is my first form of what I would call notification
prevention.

The second form occurs on the "tx-complete" path (that is guest->host
tx).  I only signal back to the guest to reclaim its skbs every 10
packets, or if I drain the queue, whichever comes first (note to self:
make this # configurable).

The nice part about this scheme is it significantly reduces the amount
of guest/host transitions, while still providing the lowest latency
response for single packets possible.  e.g. Send one packet, and you get
one hypercall, and one tx-complete interrupt as soon as it queues on the
hardware.  Send 100 packets, and you get one hypercall and 10
tx-complete interrupts as frequently as every tenth packet queues on the
hardware.  There is no timer governing the flow, etc.

Is that what you were asking?

> As you point out, 350-450 is possible, which is still bad, and it's at =
least
> partially caused by the exit to userspace and two system calls.  If vir=
tio_net
> had a backend in the kernel, we'd be able to compare numbers properly.
>  =20
:)

But that is the whole point, isnt it?  I created vbus specifically as a
framework for putting things in the kernel, and that *is* one of the
major reasons it is faster than virtio-net...its not the difference in,
say, IOQs vs virtio-ring (though note I also think some of the
innovations we have added such as bi-dir napi are helping too, but these
are not "in-kernel" specific kinds of features and could probably help
the userspace version too).

I would be entirely happy if you guys accepted the general concept and
framework of vbus, and then worked with me to actually convert what I
have as "venet-tap" into essentially an in-kernel virtio-net.  I am not
specifically interested in creating a competing pv-net driver...I just
needed something to showcase the concepts and I didnt want to hack the
virtio-net infrastructure to do it until I had everyone's blessing.=20
Note to maintainers: I *am* perfectly willing to maintain the venet
drivers if, for some reason, we decide that we want to keep them as
is.   Its just an ideal for me to collapse virtio-net and venet-tap
together, and I suspect our community would prefer this as well.

-Greg


--------------enig9D46F49FD5418A8DAD72AF9E
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknTUYsACgkQlOSOBdgZUxmo3wCfSi/VhY2StroSGlj1/mUKKw/8
1ycAnAh1J2rtSdeR9rjLE/2HSjCvFN/p
=QNZH
-----END PGP SIGNATURE-----

--------------enig9D46F49FD5418A8DAD72AF9E--

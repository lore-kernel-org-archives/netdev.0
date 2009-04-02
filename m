From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 08:22:36 -0400
Message-ID: <49D4AE0C.3000604@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig39D72AAAE9FDDAD5CCB6C67B"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D4A4EB.8020105@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig39D72AAAE9FDDAD5CCB6C67B
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>
> =20
>
>>> virtio is already non-kvm-specific (lguest uses it) and
>>> non-pci-specific (s390 uses it).
>>>    =20
>>
>> Ok, then to be more specific, I need it to be more generic than it
>> already is.  For instance, I need it to be able to integrate with
>> shm_signals. =20
>
> Why?
Well, shm_signals is what I designed to be the event mechanism for vbus
devices.  One of the design criteria of shm_signal is that it should
support a variety of environments, such as kvm, but also something like
userspace apps.  So I cannot make assumptions about things like "pci
interrupts", etc.

So if I want to use it in vbus, virtio-ring has to be able to use them,
as opposed to what it does today. Part of this would be a natural fit
for the "kick()" callback in virtio, but there are other problems.  For
one, virtio-ring (IIUC) does its own event-masking directly in the
virtio metadata.  However, really I want the higher layer ring-overlay
to do its masking in terms of the lower-layered shm_signal in order to
work the way I envision this stuff.  If you look at the IOQ
implementation, this is exactly what it does.

To be clear, and Ive stated this in the past: venet is just an example
of this generic, in-kernel concept.  We plan on doing much much more
with all this.  One of the things we are working on is have userspace
clients be able to access this too, with an ultimately goal of
supporting things like having guest-userspace doing bypass, rdma, etc.=20
We are not there yet, though...only the kvm-host to guest kernel is
currently functional and is thus the working example.

I totally "get" the attraction to doing things in userspace.  Its
contained, naturally isolated, easily supports migration, etc.  Its also
a penalty.  Bare-metal userspace apps have a direct path to the kernel
IO.  I want to give guest the same advantage.  Some people will care
more about things like migration than performance, and that is fine.=20
But others will certainly care more about performance, and that is what
we are trying to address.

>
> =20
>
>>> If you have a good exit mitigation scheme you can cut exits by a
>>> factor of 100; so the userspace exit costs are cut by the same
>>> factor.  If you have good copyless networking APIs you can cut the
>>> cost of copies to zero (well, to the cost of get_user_pages_fast(),
>>> but a kernel solution needs that too).
>>>    =20
>>
>> "exit mitigation' schemes are for bandwidth, not latency.  For latency=

>> it all comes down to how fast you can signal in both directions.  If
>> someone is going to do a stand-alone request-reply, its generally alwa=
ys
>> going to be at least one hypercall and one rx-interrupt.  So your spee=
d
>> will be governed by your signal path, not your buffer bandwidth.
>>  =20
>
> The userspace path is longer by 2 microseconds (for two additional
> heavyweight exits) and a few syscalls.  I don't think that's worthy of
> putting all the code in the kernel.

By your own words, the exit to userspace is "prohibitively expensive",
so that is either true or its not.  If its 2 microseconds, show me.  We
need the rtt time to go from a "kick" PIO all the way to queue a packet
on the egress hardware and return.  That is going to define your
latency.  If you can do this such that you can do something like ICMP
ping in 65us (or anything close to a few dozen microseconds of this),
I'll shut-up about how much I think the current path sucks ;)  Even so,
I still propose the concept of a frame-work for in-kernel devices for
all the other reasons I mentioned above.

-Greg



--------------enig39D72AAAE9FDDAD5CCB6C67B
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknUrgwACgkQlOSOBdgZUxlgywCfYH26CpOH15CL/QEhTIGOYPvx
VsoAn2khGouR2P0u62Tu3sLWt3SyXWao
=V/SV
-----END PGP SIGNATURE-----

--------------enig39D72AAAE9FDDAD5CCB6C67B--

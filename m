From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 11:31:32 -0400
Message-ID: <49D4DA54.3090401@novell.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig94891DD15D21C26AFB2C86C7"
Cc: Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:35800 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762090AbZDBP33 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2009 11:29:29 -0400
In-Reply-To: <49D4CB38.5030205@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig94891DD15D21C26AFB2C86C7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Patrick Mullaney wrote:
>> On Thu, 2009-04-02 at 16:27 +0300, Avi Kivity wrote:
>>
>> =20
>>> virtio is a stable ABI.
>>>
>>>   =20
>>>> However, theres still the possibility we can make this work in an AB=
I
>>>> friendly way with cap-bits, or other such features.  For instance, t=
he
>>>> virtio-net driver could register both with pci and vbus-proxy and
>>>> instantiate a device with a slightly different ops structure for
>>>> each or
>>>> something.  Alternatively we could write a host-side shim to expose
>>>> vbus
>>>> devices as pci devices or something like that.
>>>>        =20
>>> Sounds complicated...
>>>
>>>    =20
>>
>> IMO, it doesn't sound anymore complicated than making virtio support t=
he
>> concepts already provided by vbus/venet-tap driver. Isn't there alread=
y
>> precedent for alternative approaches co-existing and having the users
>> decide which is the most appropriate for their use case? Switching
>> drivers in order to improve latency for a certain class of application=
s
>> would seem like something latency sensitive users would be more than
>> willing to do. I'd like to point out 2 things. Greg has offered help
>> in moving virtio into the vbus infrastructure. The vbus infrastructure=

>> is a large part of what is being proposed here.
>>  =20
>
> vbus (if I understand it right) is a whole package of things:
>
> - a way to enumerate, discover, and manage devices

Yes
>
> That part duplicates PCI

Yes, but the important thing to point out is it doesn't *replace* PCI.=20
It simply an alternative.

> and it would be pretty hard to convince me we need to move to
> something new

But thats just it.  You don't *need* to move.  The two can coexist side
by side peacefully.  "vbus" just ends up being another device that may
or may not be present, and that may or may not have devices on it.  In
fact, during all this testing I was booting my guest with "eth0" as
virtio-net, and "eth1" as venet.  The both worked totally fine and
harmoniously.  The guest simply discovers if vbus is supported via a
cpuid feature bit and dynamically adds it if present.

> .  virtio-pci (a) works,
And it will continue to work

> (b) works on Windows.

virtio will continue to work on windows, as well.  And if one of my
customers wants vbus support on windows and is willing to pay us to
develop it, we can support *it* there as well.
>
>
> - a different way of doing interrupts
Yeah, but this is ok.  And I am not against doing that mod we talked
about earlier where I replace dynirq with a pci shim to represent the
vbus.  Question about that: does userspace support emulation of MSI
interrupts?  I would probably prefer it if I could keep the vbus IRQ (or
IRQs when I support MQ) from being shared.  It seems registering the
vbus as an MSI device would be more conducive to avoiding this.

>
> Again, the need to paravirtualize kills this on Windows (I think).
Not really.  Its the same thing conceptually as virtio, except I am not
riding on PCI so I would need to manage this somehow.  Its support would
not be "free", but I dont think the ability to support this new bus type
is ultimately predicated on having PCI support.  But like I said, this
is really vbus's problem.  virtio will continue to work, and customer
funding (or a dev volunteer) will dictate if windows can support vbus as
well.  Right now I am perfectly willing to accept that windows guests
have no ability to access the feature.

>
> - a different ring layout, and splitting notifications from the ring
Again, virtio will continue to work.  And if we cannot find a way to
collapse virtio and ioq together in a way that everyone agrees on, there
is no harm in having two.  I have no problem saying I will maintain
IOQ.  There is plenty of precedent for multiple ways to do the same thing=
=2E

>
>
> I don't see the huge win here
>
> - placing the host part in the host kernel
>
> Nothing vbus-specific here.

Well, it depends on what you want.  Do you want a implementation that is
virtio-net, kvm, and pci specific while being hardcoded in?  What
happens when someone wants to access it but doesnt support pci?  What if
something like lguest wants to use it too?  What if you want
virtio-block next?  This is one extreme.

The other extreme is the direction I have gone, which is dynamically
loaded/instantiated generic objects which can work with kvm or whatever
subsystem wants to write a vbus-connector for.  I realize this is more
complex.  It is also more flexible.  Everything has a cost, though I
will point out that a good portion of the cost has already been paid for
by me and my employer ;)

So yeah, it doesn't *need* vbus to do this.  This is just one way of
many things that could be done between the two extremes.  But I didn't
design this thing to be some randomly coded amorphous blob that I am now
trying to miraculously shoehorn into KVM.  I designed it from the start
as what I felt a good virtual IO facility could be when starting with a
clean slate, keeping KVM as a primary target application the whole
time.  It is unfortunate that we, I think, disagree on the value add of
PCI, and that in the end may prevent vbus as ever being a transport for
an ABI compatible virtio-net implementation.  However, that also doesn't
mean it isn't useful in other contexts outside of this one particular
type of IO.

-Greg


--------------enig94891DD15D21C26AFB2C86C7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknU2lQACgkQlOSOBdgZUxlpxQCbB4TaJYJO2/iCTVJcpCA+PoZM
CvoAn3SsWJgjw1BkoN789h90jD8tl/ll
=EJhz
-----END PGP SIGNATURE-----

--------------enig94891DD15D21C26AFB2C86C7--

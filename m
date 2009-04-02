From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Thu, 02 Apr 2009 13:44:31 -0400
Message-ID: <49D4F97F.6040507@novell.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8380702319377D057F6DB9DD"
Cc: Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D4DE82.5020306@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8380702319377D057F6DB9DD
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>>> vbus (if I understand it right) is a whole package of things:
>>>
>>> - a way to enumerate, discover, and manage devices
>>>    =20
>>
>> Yes
>> =20
>>> That part duplicates PCI
>>>    =20
>>
>> Yes, but the important thing to point out is it doesn't *replace*
>> PCI. It simply an alternative.
>>  =20
>
> Does it offer substantial benefits over PCI?  If not, it's just extra
> code.

First of all, do you think I would spend time designing it if I didn't
think so? :)

Second of all, I want to use vbus for other things that do not speak PCI
natively (like userspace for instance...and if I am gleaning this
correctly, lguest doesnt either).

PCI sounds good at first, but I believe its a false economy.  It was
designed, of course, to be a hardware solution, so it carries all this
baggage derived from hardware constraints that simply do not exist in a
pure software world and that have to be emulated.  Things like the fixed
length and centrally managed PCI-IDs, PIO config cycles, BARs,
pci-irq-routing, etc.  While emulation of PCI is invaluable for
executing unmodified guest, its not strictly necessary from a
paravirtual software perspective...PV software is inherently already
aware of its context and can therefore use the best mechanism
appropriate from a broader selection of choices.

If we insist that PCI is the only interface we can support and we want
to do something, say, in the kernel for instance, we have to have either
something like the ICH model in the kernel (and really all of the pci
chipset models that qemu supports), or a hacky hybrid userspace/kernel
solution.  I think this is what you are advocating, but im sorry. IMO
that's just gross and unecessary gunk.  Lets stop beating around the
bush and just define the 4-5 hypercall verbs we need and be done with
it.  :)

FYI: The guest support for this is not really *that* much code IMO.
=20
 drivers/vbus/proxy/Makefile      |    2
 drivers/vbus/proxy/kvm.c         |  726 +++++++++++++++++

and plus, I'll gladly maintain it :)

I mean, its not like new buses do not get defined from time to time.=20
Should the computing industry stop coming up with new bus types because
they are afraid that the windows ABI only speaks PCI?  No, they just
develop a new driver for whatever the bus is and be done with it.  This
is really no different.

>
> Note that virtio is not tied to PCI, so "vbus is generic" doesn't count=
=2E
Well, preserving the existing virtio-net on x86 ABI is tied to PCI,
which is what I was referring to.  Sorry for the confusion.

>
>>> and it would be pretty hard to convince me we need to move to
>>> something new
>>>    =20
>>
>> But thats just it.  You don't *need* to move.  The two can coexist sid=
e
>> by side peacefully.  "vbus" just ends up being another device that may=

>> or may not be present, and that may or may not have devices on it.  In=

>> fact, during all this testing I was booting my guest with "eth0" as
>> virtio-net, and "eth1" as venet.  The both worked totally fine and
>> harmoniously.  The guest simply discovers if vbus is supported via a
>> cpuid feature bit and dynamically adds it if present.
>>  =20
>
> I meant, move the development effort, testing, installed base, Windows
> drivers.

Again, I will maintain this feature, and its completely off to the
side.  Turn it off in the config, or do not enable it in qemu and its
like it never existed.  Worst case is it gets reverted if you don't like
it.  Aside from the last few kvm specific patches, the rest is no
different than the greater linux environment.  E.g. if I update the
venet driver upstream, its conceptually no different than someone else
updating e1000, right?

>
>> =20
>>> .  virtio-pci (a) works,
>>>    =20
>> And it will continue to work
>>  =20
>
> So why add something new?

I was hoping this was becoming clear by now, but apparently I am doing a
poor job of articulating things. :(  I think we got bogged down in the
802.x performance discussion and lost sight of what we are trying to
accomplish with the core infrastructure.

So this core vbus infrastructure is for generic, in-kernel IO models.=20
As a first pass, we have implemented a kvm-connector, which lets kvm
guest kernels have access to the bus.  We also have a userspace
connector (which I haven't pushed yet due to remaining issues being
ironed out) which allows userspace applications to interact with the
devices as well.  As a prototype, we built "venet" to show how it all wor=
ks.

In the future, we want to use this infrastructure to build IO models for
various things like high performance fabrics and guest bypass
technologies, etc.  For instance, guest userspace connections to RDMA
devices in the kernel, etc.

>
>> =20
>>> (b) works on Windows.
>>>    =20
>>
>> virtio will continue to work on windows, as well.  And if one of my
>> customers wants vbus support on windows and is willing to pay us to
>> develop it, we can support *it* there as well.
>>  =20
>
> I don't want to develop and support both virtio and vbus.  And I
> certainly don't want to depend on your customers.

So don't.  Ill maintain the drivers and the infrastructure.  All we are
talking here is the possible acceptance of my kvm-connector patches
*after* the broader LKML community accepts the core infrastructure,
assuming that happens.

You can always just state that you do not support enabling the feature.=20
Bug reports with it enabled go to me, etc.

If that is still not acceptable and you are ultimately not interested in
any kind of merge/collaboration:  At the very least, I hope we can get
some very trivial patches in for registering things like the
KVM_CAP_VBUS bits for vbus so I can present a stable ABI to anyone
downstream from me.  Those things have been shifting on me a lot lately ;=
)

>
>
>>> - a different way of doing interrupts
>>>    =20
>> Yeah, but this is ok.  And I am not against doing that mod we talked
>> about earlier where I replace dynirq with a pci shim to represent the
>> vbus.  Question about that: does userspace support emulation of MSI
>> interrupts? =20
>
> Yes, this is new.  See the interrupt routing stuff I mentioned.  It's
> probably only in kvm.git, not even in 2.6.30.
Cool, will check out, thanks.

>
>> I would probably prefer it if I could keep the vbus IRQ (or
>> IRQs when I support MQ) from being shared.  It seems registering the
>> vbus as an MSI device would be more conducive to avoiding this.
>>  =20
>
> I still think you want one MSI per device rather than one MSI per
> vbus, to avoid scaling problems on large guest.  After Herbert's let
> loose on the code, one MSI per queue.

This is trivial for me to support with just a few tweaks to the kvm
host/guest connector patches.

>
>
>
>>> - a different ring layout, and splitting notifications from the ring
>>>    =20
>> Again, virtio will continue to work.  And if we cannot find a way to
>> collapse virtio and ioq together in a way that everyone agrees on, the=
re
>> is no harm in having two.  I have no problem saying I will maintain
>> IOQ.  There is plenty of precedent for multiple ways to do the same
>> thing.
>>  =20
>
> IMO we should just steal whatever makes ioq better, and credit you in
> some file no one reads.  We get backwards compatibility, Windows
> support, continuity, etc.
>
>>> I don't see the huge win here
>>>
>>> - placing the host part in the host kernel
>>>
>>> Nothing vbus-specific here.
>>>    =20
>>
>> Well, it depends on what you want.  Do you want a implementation that =
is
>> virtio-net, kvm, and pci specific while being hardcoded in?
>
> No.  virtio is already not kvm or pci specific.  Definitely all the
> pci emulation parts will remain in user space.

blech :)

-Greg


--------------enig8380702319377D057F6DB9DD
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknU+X8ACgkQlOSOBdgZUxkxJwCcCWSiZI3qC8CChc+xu9q5BUf+
gQ0An2sHQwUdzzYHhlv9KatAAky3UMyr
=hVKJ
-----END PGP SIGNATURE-----

--------------enig8380702319377D057F6DB9DD--

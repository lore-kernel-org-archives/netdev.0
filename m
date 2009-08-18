From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 09:16:45 -0400
Message-ID: <4A8AA9BD.2070909@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws> <4A8965E0.8050608@gmail.com> <4A89FF08.30509@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig4E2580682E311698A6C8BB03"
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932095AbZHRNQx@vger.kernel.org>
In-Reply-To: <4A89FF08.30509@codemonkey.ws>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig4E2580682E311698A6C8BB03
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anthony Liguori wrote:
> Gregory Haskins wrote:
>> Note: No one has ever proposed to change the virtio-ABI.
>=20
> virtio-pci is part of the virtio ABI.  You are proposing changing that.=


I'm sorry, but I respectfully disagree with you here.

virtio has an ABI...I am not modifying that.

virtio-pci has an ABI...I am not modifying that either.

The subsystem in question is virtio-vbus, and is a completely standalone
addition to the virtio ecosystem.  By your argument, virtio amd
virtio-pci should fuse together, and virtio-lguest and virtio-s390
should go away because they diverge from the virtio-pci ABI, right?

I seriously doubt you would agree with that statement.  The fact is, the
design of virtio not only permits modular replacement of its transport
ABI, it encourages it.

So how is virtio-vbus any different from the other three?  I understand
that it means you need to load a new driver in the guest, and I am ok
with that.  virtio-pci was once a non-upstream driver too and required
someone to explicitly load it, wasn't it?  You gotta crawl before you
can walk...

>=20
> You cannot add new kernel modules to guests and expect them to remain
> supported.

??? Of course you can.  How is this different from any other driver?


>  So there is value in reusing existing ABIs


Well, I wont argue with you on that one.  There is certainly value there.=


My contention is that sometimes the liability of that ABI is greater
than its value, and thats when its time to evaluate the design decisions
that lead to re-use vs re-design.


>=20
>>> I think the reason vbus gets better performance for networking today =
is
>>> that vbus' backends are in the kernel while virtio's backends are
>>> currently in userspace.
>>>    =20
>>
>> Well, with all due respect, you also said initially when I announced
>> vbus that in-kernel doesn't matter, and tried to make virtio-net run a=
s
>> fast as venet from userspace ;)  Given that we never saw those userspa=
ce
>> patches from you that in fact equaled my performance, I assume you wer=
e
>> wrong about that statement.  Perhaps you were wrong about other things=

>> too?
>>  =20
>=20
> I'm wrong about a lot of things :-)  I haven't yet been convinced that
> I'm wrong here though.
>=20
> One of the gray areas here is what constitutes an in-kernel backend.=20
> tun/tap is a sort of an in-kernel backend.  Userspace is still involved=

> in all of the paths.  vhost seems to be an intermediate step between
> tun/tap and vbus.  The fast paths avoid userspace completely.  Many of
> the slow paths involve userspace still (like migration apparently).=20
> With vbus, userspace is avoided entirely.  In some ways, you could argu=
e
> that slirp and vbus are opposite ends of the virtual I/O spectrum.
>=20
> I believe strongly that we should avoid putting things in the kernel
> unless they absolutely have to be.


I would generally agree with you on that.  Particularly in the case of
kvm, having slow-path bus-management code in-kernel is not strictly
necessary because KVM has qemu in userspace.

The issue here is that vbus is designed to be a generic solution to
in-kernel virtual-IO.  It will support (via abstraction of key
subsystems) a variety of environments that may or may not be similar in
facilities to KVM, and therefore it represents the
least-common-denominator as far as what external dependencies it requires=
=2E

The bottom line is this: despite the tendency for people to jump at
"don't put much in the kernel!", the fact is that a "bus" designed for
software to software (such as vbus) is almost laughably trivial.  Its
essentially a list of objects that have an int (dev-id) and char*
(dev-type) attribute.  All the extra goo that you see me setting up in
something like the kvm-connector needs to be done for fast-path
_anyway_, so transporting the verbs to query this simple list is not
really a big deal.

If we were talking about full ICH emulation for a PCI bus, I would agree
with you.  In the case of vbus, I think its overstated.


>  I'm definitely interested in playing
> with vhost to see if there are ways to put even less in the kernel.  In=

> particular, I think it would be a big win to avoid knowledge of slots i=
n
> the kernel by doing ring translation in userspace.

Ultimately I think that would not be a very good proposition.  Ring
translation is actually not that hard, and that would definitely be a
measurable latency source to try and do as you propose.  But, I will not
discourage you from trying if that is what you want to do.

>  This implies a
> userspace transition in the fast path.  This may or may not be
> acceptable.  I think this is going to be a very interesting experiment
> and will ultimately determine whether my intuition about the cost of
> dropping to userspace is right or wrong.

I can already tell you its wrong, just based on the fact that even extra
kthread switches can hurt from my own experience playing in this area...

>=20
>=20
>> Conversely, I am not afraid of requiring a new driver to optimize the
>> general PV interface.  In the long term, this will reduce the amount o=
f
>> reimplementing the same code over and over, reduce system overhead, an=
d
>> it adds new features not previously available (for instance, coalescin=
g
>> and prioritizing interrupts).
>>  =20
>=20
> I think you have a lot of ideas and I don't know that we've been able t=
o
> really understand your vision.  Do you have any plans on writing a pape=
r
> about vbus that goes into some of your thoughts in detail?

I really need to, I know...


>=20
>>> If that's the case, then I don't see any
>>> reason to adopt vbus unless Greg things there are other compelling
>>> features over virtio.
>>>    =20
>>
>> Aside from the fact that this is another confusion of the vbus/virtio
>> relationship...yes, of course there are compelling features (IMHO) or =
I
>> wouldn't be expending effort ;)  They are at least compelling enough t=
o
>> put in AlacrityVM.
>=20
> This whole AlactricyVM thing is really hitting this nail with a
> sledgehammer.

Note that I didn't really want to go that route.  As you know, I tried
pushing this straight through kvm first since earlier this year, but I
was met with reluctance to even bother truly understanding what I was
proposing, comments like "tell me your ideas so I can steal them", and
"sorry, we are going to reinvent our own instead".  This isn't exactly
going to motivate someone to continue pushing these ideas within that
community.  I was made to feel (purposely?) unwelcome at times.  So I
can either roll over and die, or start my own project.

In addition, almost all of vbus is completely independent of kvm anyway
(I think there are only 3 patches that actually touch KVM, and they are
relatively minor).  And vbus doesn't really fit into any other category
of maintained subsystem either.  So it really calls for a new branch of
maintainership, of which I currently sit.  AlacrityVM will serve as the
collaboration point of that maintainership.

The bottom line is, there are people out there who are interested in
what we are doing (and that number grows everyday).  Starting a new
project wasn't what I wanted per se, but I don't think there was much
choice.


  While the kernel needs to be very careful about what it
> pulls in, as long as you're willing to commit to ABI compatibility, we
> can pull code into QEMU to support vbus.  Then you can just offer vbus
> host and guest drivers instead of forking the kernel.

Ok, I will work on pushing those patches next.

>=20
>>   If upstream KVM doesn't want them, that's KVMs
>> decision and I am fine with that.  Simply never apply my qemu patches =
to
>> qemu-kvm.git, and KVM will be blissfully unaware if vbus is present.
>=20
> As I mentioned before, if you submit patches to upstream QEMU, we'll
> apply them (after appropriate review).  As I said previously, we want t=
o
> avoid user confusion as much as possible.  Maybe this means limiting it=

> to -device or a separate machine type.  I'm not sure, but that's
> something we can discussion on qemu-devel.

Ok.

Kind Regards,
-Greg


--------------enig4E2580682E311698A6C8BB03
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqKqb4ACgkQP5K2CMvXmqHhVwCggZTZqWJtdKn2ioP+xJsYaN+d
1uoAnRCPfLLr0PBV7uo7m1xVIPYUuod4
=v/Dx
-----END PGP SIGNATURE-----

--------------enig4E2580682E311698A6C8BB03--

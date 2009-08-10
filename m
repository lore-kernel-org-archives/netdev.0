From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH v2 19/19] virtio: add a vbus transport
Date: Mon, 10 Aug 2009 11:40:57 -0400
Message-ID: <4A803F89.1090608@novell.com>
References: <20090409155200.32740.19358.stgit@dev.haskins.net> <20090409163221.32740.38373.stgit@dev.haskins.net> <4A7EFBE8.7050409@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigC41CE0EEA1A611AA760AD3E1"
Cc: linux-kernel@vger.kernel.org, agraf@suse.de, pmullaney@novell.com,
	pmorreale@novell.com, rusty@rustcorp.com.au,
	netdev@vger.kernel.org, kvm@vger.kernel.org, avi@redhat.com,
	bhutchings@solarflare.com, andi@firstfloor.org, gregkh@suse.de,
	herber@gondor.apana.org.au, chrisw@sous-sol.org,
	shemminger@vyatta.com, "Michael S. Tsirkin" <mst@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	Arnd Bergmann <arnd@arndb.de>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A7EFBE8.7050409@codemonkey.ws>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigC41CE0EEA1A611AA760AD3E1
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Anthony Liguori wrote:
> Gregory Haskins wrote:
>> We add a new virtio transport for accessing backends located on vbus. =

>> This
>> complements the existing transports for virtio-pci, virtio-s390, and
>> virtio-lguest that already exist.
>>
>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>=20
> Very interesting...
>=20
> I'm somewhat confused by what you're advocating vbus as.  I'm trying to=

> figure out how we converge vbus and virtio and become one big happy
> family :-)
>=20
> What parts of it do you think are better than virtio?

I see them as distinctly different, and complimentary: virtio is
primarily a device-interface.  vbus is primarily a bus-model.

While its true that vbus has a rudimentary "device interface" (ala
dev->call(), dev->shm(), etc), it will typically be layered with a more
robust device model (such as virtqueue based virtio-net, or IOQ based
venet).

This is akin to raw PCI.  PCI has the basic mechanics (MMIO, PIO,
interrupts, DMA), but generally devices overlay higher layer constructs
(such as tx/rx rings for ethernet).  vbus is similar in that regard.

virtio, on the other hand, is a fully fleshed device model, but it needs
to be paired up with some other bus-model (such as qemu+pci via
virtio-pci, or linux+vbus via virtio-vbus) to be complete.


> Should we forget
> about venet and just focus on virtio-net on top of virtio-vbus assuming=

> that we can prove venet-tap/virtio-vbus/virtio-net is just as good as
> venet-tap/vbus/venet?

I think going forward, I would love to see some community weight behind
virtio-vbus and the standardization of the virtio-X drivers (net, blk,
console, etc) as the default core IO device model for vbus.  If that
were to happen, I would not be inclined to create any new native vbus
drivers for where there is overlap with virtio (net, disk, etc).

I *will*, however, likely use the native vbus interfaces for some of the
device models in the pipeline (such as the real-time controller, and
OFED) because there isn't a virtio equivalent for that, and the vbus
device model was written with them in mind.

And regardless of the final outcome of virtio-vbus as a viable virtio
transport model, I will probably continue to support the native vbus
"venet" protocol for AlacrityVM indefinitely only because I have people
that are using it today (AlacrityVM being one example, but others are in
the works), it is simple, and it works extremely well.

>=20
> If we can prove that an in-kernel virtio-net
> backend/virtio-pci/virtio-net does just as well as
> venet-tap/virtio-vbus/virtio-net does that mean that vbus is no longer
> needed?

vbus is primarily about the bus model and resource-containers.  It is
therefore so much more than just 802.x networking and/or KVM.  So no,
obtaining equal network performance with virtio-net sans vbus does not
invalidate vbus as a concept.  It would perhaps purely be disincentive
for anyone to chose venet over virtio-net within a KVM guest who doesn't
have a vested interest in the venet ABI.


>=20
> If you concede that the transport mechanisms can be identical, are you
> really advocating the discovering and configuration mechanisms in vbus?=


The problem is that they are not truly identical, and they cannot easily
be made identical.

One of the design goals is to create a re-useable, in-kernel device
model with a thin-shim transport between the guest and the bus.  The
transport (called a "vbus-connector") in question must convey a very
small verb namespace (devadd/drop, devopen/close, shmsignal, etc) to use
this bus.  So you have a driver for this transport (e.g. vbus-pcibridge)
but the bus-model itself, device-models, and guest drivers are all reusab=
le.

Another design goal is to create a high-performance, low-latency,
software-to-software optimized IO subsystem.  PCI was designed for
software-to-hardware, so it has assumptions about that environment that
simply do not apply in software-to-software.  Most of these limitations
can be worked-around with KVM surgery and/or creative guest development,
but they are (at best) awkward to express in PCI.

For example, creating a high-performance, synchronous, in-kernel "call"
in PCI is fairly complicated, awkward, and requires a bit of per-device
heap to pull off.  Yet, I need this functionality for things like RT
support (scheduler state changes, etc).

As another example, the PCI model is somewhat resource rigid and
therefore awkward for creating dynamic software objects in response to
guest actions on demand, such as IPC sockets, due to the way MSI works.

As a third example, the PCI device model makes assumptions about
signal-path delivery (MSI to APIC) which may or may not be the optimal
path (e.g. see my priority+aggregation thread with Arnd).

I am open to suggestions on ways to write the "connector" code
differently.  I am sure that some things could be addressed at a
different layer (such as the conversation with Arnd regarding the PV
interrupt controller).

I think, however, that the motivations to PCI'ize the x86-KVM world are
driven more by inertia (its already in qemu and many guests know it)
than by intentional selection (its model is the best to express the
needs of virt).  Therefore, I am trying to put a stake in the ground to
redirect that inertia towards a path that I believe is more amenable to
virt in the long term.  Consider it a long-term investment in the platfor=
m.

My approach to date is more akin to how something like USB was
introduced.  The USB designers were not trying to artificially constrain
their design so that it looked like PCI just to avoid needing an OS
driver.  They (presumably) designed a bus that best achieved their
goals, and then people wrote adaption layers (ala PCI-to-USB bridges) to
support them on the OS's/arches that cared.  Eventually most did.

I admit that, as with any new bus (e.g. USB), there will undoubtedly be
some lumps during the initial roll-out phase since it is not yet
universally supported.  But the long term vision is that (assuming it
succeeds as a project) that eventually vbus would be ubiquitous (ala
USB) and it makes for a better bus-model choice for things like
linux-based hypervisors (pci-based kvm (x86/ppc), s390-kvm, lguest, UML,
openvz, and even something like Xen-Dom0, etc), as well as applications
and even some specialized physical systems (Blade systems, clusters, etc)=
=2E


> Is that what we should be focusing on? Do you care only about the host
> mechanisms or do you also require the guest infrastructure to be presen=
t?

I see it as a tightly integrated portion of the stack that sits right
below the virtio layer.

>=20
> I think two paravirtual I/O frameworks for KVM is a bad thing.

So hopefully after reading my reply above you can see that I don't think
this is indeed what is being proposed.

> It duplicates a ton of code and will very likely lead to user unhappine=
ss.

I totally agree and I hope we can work together to find a solution that
makes the most sense and eliminates as much duplicate effort as possible.=


Kind Regards,
-Greg


--------------enigC41CE0EEA1A611AA760AD3E1
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqAP4kACgkQP5K2CMvXmqGLIgCdF9lheOvDIRkKLs2q29OR6TMH
mDEAoISYdvr7msTtWsz7brh127IsDi2Y
=rrgb
-----END PGP SIGNATURE-----

--------------enigC41CE0EEA1A611AA760AD3E1--

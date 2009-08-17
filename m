From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 10:14:56 -0400
Message-ID: <4A8965E0.8050608@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A870964.9090408@codemonkey.ws>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig69256F46D1D7E98B690AB8E8"
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Anthony Liguori <anthony@codemonkey.ws>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f175.google.com ([209.85.210.175]:60005 "EHLO
	mail-yx0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751588AbZHQOO7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 10:14:59 -0400
In-Reply-To: <4A870964.9090408@codemonkey.ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig69256F46D1D7E98B690AB8E8
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Anthony Liguori wrote:
> Ingo Molnar wrote:
>> * Gregory Haskins <ghaskins@novell.com> wrote:
>>
>> =20
>>> This will generally be used for hypervisors to publish any host-side
>>> virtual devices up to a guest.  The guest will have the opportunity
>>> to consume any devices present on the vbus-proxy as if they were
>>> platform devices, similar to existing buses like PCI.
>>>
>>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
>>> ---
>>>
>>>  MAINTAINERS                 |    6 ++
>>>  arch/x86/Kconfig            |    2 +
>>>  drivers/Makefile            |    1  drivers/vbus/Kconfig        | =20
>>> 14 ++++
>>>  drivers/vbus/Makefile       |    3 +
>>>  drivers/vbus/bus-proxy.c    |  152
>>> +++++++++++++++++++++++++++++++++++++++++++
>>>  include/linux/vbus_driver.h |   73 +++++++++++++++++++++
>>>  7 files changed, 251 insertions(+), 0 deletions(-)
>>>  create mode 100644 drivers/vbus/Kconfig
>>>  create mode 100644 drivers/vbus/Makefile
>>>  create mode 100644 drivers/vbus/bus-proxy.c
>>>  create mode 100644 include/linux/vbus_driver.h
>>>    =20
>>
>> Is there a consensus on this with the KVM folks? (i've added the KVM
>> list to the Cc:)
>>  =20
>=20
> I'll let Avi comment about it from a KVM perspective but from a QEMU
> perspective, I don't think we want to support two paravirtual IO
> frameworks.  I'd like to see them converge.  Since there's an install
> base of guests today with virtio drivers, there really ought to be a
> compelling reason to change the virtio ABI in a non-backwards compatibl=
e
> way.


Note: No one has ever proposed to change the virtio-ABI.  In fact, this
thread in question doesn't even touch virtio, and even the patches that
I have previously posted to add virtio-capability do it in a backwards
compatible way

Case in point: Take an upstream kernel and you can modprobe the
vbus-pcibridge in and virtio devices will work over that transport
unmodified.

See http://lkml.org/lkml/2009/8/6/244 for details.

Note that I have tentatively dropped the virtio-vbus patch from the
queue due to lack of interest, but I can resurrect it if need be.

>  This means convergence really ought to be adding features to virtio.

virtio is a device model. vbus is a bus model and a host backend
facility.  Adding features to virtio would be orthogonal to some kind of
convergence goal.  virtio can run unmodified or add new features within
its own namespace independent of vbus, as it pleases.  vbus will simply
transport those changes.

>=20
> On paper, I don't think vbus really has any features over virtio.

Again, do not confuse vbus with virtio.  They are different layers of
the stack.

>  vbus
> does things in different ways (paravirtual bus vs. pci for discovery)
> but I think we're happy with how virtio does things today.
>=20

Thats fine.  KVM can stick with virtio-pci if it wants.  AlacrityVM will
support virtio-pci and vbus (with possible convergence with
virtio-vbus).  If at some point KVM thinks vbus is interesting, I will
gladly work with getting it integrated into upstream KVM as well.  Until
then, they can happily coexist without issue between the two projects.


> I think the reason vbus gets better performance for networking today is=

> that vbus' backends are in the kernel while virtio's backends are
> currently in userspace.

Well, with all due respect, you also said initially when I announced
vbus that in-kernel doesn't matter, and tried to make virtio-net run as
fast as venet from userspace ;)  Given that we never saw those userspace
patches from you that in fact equaled my performance, I assume you were
wrong about that statement.  Perhaps you were wrong about other things to=
o?


> Since Michael has a functioning in-kernel
> backend for virtio-net now, I suspect we're weeks (maybe days) away fro=
m
> performance results.  My expectation is that vhost + virtio-net will be=

> as good as venet + vbus.

This is not entirely impossible, at least for certain simple benchmarks
like singleton throughput and latency.  But if you think that this
somehow invalidates vbus as a concept, you have missed the point entirely=
=2E

vbus is about creating a flexible (e.g. cross hypervisor, and even
physical system or userspace application) in-kernel IO containers with
linux.  The "guest" interface represents what I believe to be the ideal
interface for ease of use, yet maximum performance for
software-to-software interaction.  This means very low latency and
high-throughput for both synchronous and asynchronous IO, minimizing
enters/exits, reducing enter/exit cost, prioritization, parallel
computation, etc.  The things that we (the alacrityvm community) have
coming down the pipeline for high-performance virtualization require
that these issues be addressed.

venet was originally crafted just to validate the approach and test the
vbus interface.  It ended up being so much faster that virtio-net, that
people in the vbus community started coding against its ABI.  Therefore,
I decided to support it formally and indefinately.  If I can get
consensus on virtio-vbus going forward, it will probably be the last
vbus-specific driver for which there is overlap with virtio (e.g.
virtio-block, virtio-console, etc).  Instead, you will only see native
vbus devices for non-native virtio type things, like real-time and
advanced fabric support.

OTOH, Michael's patch is purely targeted at improving virtio-net on kvm,
and its likewise constrained by various limitations of that decision
(such as its reliance of the PCI model, and the kvm memory scheme).  The
tradeoff is that his approach will work in all existing virtio-net kvm
guests, and is probably significantly less code since he can re-use the
qemu PCI bus model.

Conversely, I am not afraid of requiring a new driver to optimize the
general PV interface.  In the long term, this will reduce the amount of
reimplementing the same code over and over, reduce system overhead, and
it adds new features not previously available (for instance, coalescing
and prioritizing interrupts).


> If that's the case, then I don't see any
> reason to adopt vbus unless Greg things there are other compelling
> features over virtio.

Aside from the fact that this is another confusion of the vbus/virtio
relationship...yes, of course there are compelling features (IMHO) or I
wouldn't be expending effort ;)  They are at least compelling enough to
put in AlacrityVM.  If upstream KVM doesn't want them, that's KVMs
decision and I am fine with that.  Simply never apply my qemu patches to
qemu-kvm.git, and KVM will be blissfully unaware if vbus is present.  I
do hope that I can convince the KVM community otherwise, however. :)

Kind Regards,
-Greg


--------------enig69256F46D1D7E98B690AB8E8
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJZeAACgkQP5K2CMvXmqGH5wCfawylNujsd4y4ikxRCbO+n/g1
pyMAnjO2hugN0ofwZ2Q555boxNZlEPny
=76z4
-----END PGP SIGNATURE-----

--------------enig69256F46D1D7E98B690AB8E8--

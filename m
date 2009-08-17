From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Mon, 17 Aug 2009 15:33:30 -0400
Message-ID: <4A89B08A.4010103@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigCCEC513B0F6D65FAFBBDE36D"
Cc: Gregory Haskins <ghaskins@novell.com>, kvm@vger.kernel.org,
	Avi Kivity <avi@redhat.com>,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f175.google.com ([209.85.210.175]:64795 "EHLO
	mail-yx0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751276AbZHQTdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 15:33:37 -0400
In-Reply-To: <20090817150844.GA3307@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigCCEC513B0F6D65FAFBBDE36D
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Ingo Molnar wrote:
> * Gregory Haskins <gregory.haskins@gmail.com> wrote:
>=20
>> Hi Ingo,
>>
>> 1) First off, let me state that I have made every effort to=20
>> propose this as a solution to integrate with KVM, the most recent=20
>> of which is April:
>>
>>    http://lkml.org/lkml/2009/4/21/408
>>
>> If you read through the various vbus related threads on LKML/KVM=20
>> posted this year, I think you will see that I made numerous polite=20
>> offerings to work with people on finding a common solution here,=20
>> including Michael.
>>
>> In the end, Michael decided that go a different route using some=20
>> of the ideas proposed in vbus + venet-tap to create vhost-net. =20
>> This is fine, and I respect his decision.  But do not try to pin=20
>> "fracturing" on me, because I tried everything to avoid it. :)
>=20
> That's good.
>=20
> So if virtio is fixed to be as fast as vbus, and if there's no other=20
> techical advantages of vbus over virtio you'll be glad to drop vbus=20
> and stand behind virtio?

To reiterate: vbus and virtio are not mutually exclusive.  The virtio
device model rides happily on top of the vbus bus model.

This is primarily a question of the virtio-pci adapter, vs virtio-vbus.

For more details, see this post: http://lkml.org/lkml/2009/8/6/244

There is a secondary question of venet (a vbus native device) verses
virtio-net (a virtio native device that works with PCI or VBUS).  If
this contention is really around venet vs virtio-net, I may possibly
conceed and retract its submission to mainline.  I've been pushing it to
date because people are using it and I don't see any reason that the
driver couldn't be upstream.

>=20
> Also, are you willing to help virtio to become faster?

Yes, that is not a problem.  Note that virtio in general, and
virtio-net/venet in particular are not the primary goal here, however.
Improved 802.x and block IO are just positive side-effects of the
effort.  I started with 802.x networking just to demonstrate the IO
layer capabilities, and to test it.  It ended up being so good on
contrast to existing facilities, that developers in the vbus community
started using it for production development.

Ultimately, I created vbus to address areas of performance that have not
yet been addressed in things like KVM.  Areas such as real-time guests,
or RDMA (host bypass) interfaces.  I also designed it in such a way that
we could, in theory, write one set of (linux-based) backends, and have
them work across a variety of environments (such as containers/VMs like
KVM, lguest, openvz, but also physical systems like blade enclosures and
clusters, or even applications running on the host).

> Or do you=20
> have arguments why that is impossible to do so and why the only=20
> possible solution is vbus? Avi says no such arguments were offered=20
> so far.

Not for lack of trying.  I think my points have just been missed
everytime I try to describe them. ;)  Basically I write a message very
similar to this one, and the next conversation starts back from square
one.  But I digress, let me try again..

Noting that this discussion is really about the layer *below* virtio,
not virtio itself (e.g. PCI vs vbus).  Lets start with a little backgroun=
d:

-- Background --

So on one level, we have the resource-container technology called
"vbus".  It lets you create a container on the host, fill it with
virtual devices, and assign that container to some context (such as a
KVM guest).  These "devices" are LKMs, and each device has a very simple
verb namespace consisting of a synchronous "call()" method, and a
"shm()" method for establishing async channels.

The async channels are just shared-memory with a signal path (e.g.
interrupts and hypercalls), which the device+driver can use to overlay
things like rings (virtqueues, IOQs), or other shared-memory based
constructs of their choosing (such as a shared table).  The signal path
is designed to minimize enter/exits and reduce spurious signals in a
unified way (see shm-signal patch).

call() can be used both for config-space like details, as well as
fast-path messaging that require synchronous behavior (such as guest
scheduler updates).

All of this is managed via sysfs/configfs.

On the guest, we have a "vbus-proxy" which is how the guest gets access
to devices assigned to its container.  (as an aside, "virtio" devices
can be populated in the container, and then surfaced up to the
virtio-bus via that virtio-vbus patch I mentioned).

There is a thing called a "vbus-connector" which is the guest specific
part.  Its job is to connect the vbus-proxy in the guest, to the vbus
container on the host.  How it does its job is specific to the connector
implementation, but its role is to transport messages between the guest
and the host (such as for call() and shm() invocations) and to handle
things like discovery and hotswap.

-- Issues --

Out of all this, I think the biggest contention point is the design of
the vbus-connector that I use in AlacrityVM (Avi, correct me if I am
wrong and you object to other aspects as well).  I suspect that if I had
designed the vbus-connector to surface vbus devices as PCI devices via
QEMU, the patches would potentially have been pulled in a while ago.

There are, of course, reasons why vbus does *not* render as PCI, so this
is the meat of of your question, I believe.

At a high level, PCI was designed for software-to-hardware interaction,
so it makes assumptions about that relationship that do not necessarily
apply to virtualization.

For instance:

A) hardware can only generate byte/word sized requests at a time because
that is all the pcb-etch and silicon support. So hardware is usually
expressed in terms of some number of "registers".

B) each access to one of these registers is relatively cheap

C) the target end-point has no visibility into the CPU machine state
other than the parameters passed in the bus-cycle (usually an address
and data tuple).

D) device-ids are in a fixed width register and centrally assigned from
an authority (e.g. PCI-SIG).

E) Interrupt/MSI routing is per-device oriented

F) Interrupts/MSI are assumed cheap to inject

G) Interrupts/MSI are non-priortizable.

H) Interrupts/MSI are statically established

These assumptions and constraints may be completely different or simply
invalid in a virtualized guest. For instance, the hypervisor is just
software, and therefore it's not restricted to "etch" constraints. IO
requests can be arbitrarily large, just as if you are invoking a library
function-call or OS system-call. Likewise, each one of those requests is
a branch and a context switch, so it has often has greater performance
implications than a simple register bus-cycle in hardware.  If you use
an MMIO variant, it has to run through the page-fault code to be decoded.=


The result is typically decreased performance if you try to do the same
thing real hardware does. This is why you usually see hypervisor
specific drivers (e.g. virtio-net, vmnet, etc) a common feature.

_Some_ performance oriented items can technically be accomplished in
PCI, albeit in a much more awkward way.  For instance, you can set up a
really fast, low-latency "call()" mechanism using a PIO port on a
PCI-model and ioeventfd.  As a matter of fact, this is exactly what the
vbus pci-bridge does:

http://git.kernel.org/?p=3Dlinux/kernel/git/ghaskins/alacrityvm/linux-2.6=
=2Egit;a=3Dblob;f=3Ddrivers/vbus/pci-bridge.c;h=3Df0ed51af55b5737b3ae4239=
ed2adfe12c7859941;hb=3Dee557a5976921650b792b19e6a93cd03fcad304a#l102

(Also note that the enabling technology, ioeventfd, is something that
came out of my efforts on vbus).

The problem here is that this is incredibly awkward to setup.  You have
all that per-cpu goo and the registration of the memory on the guest.
And on the host side, you have all the vmapping of the registered
memory, and the file-descriptor to manage.  In short, its really painful.=


I would much prefer to do this *once*, and then let all my devices
simple re-use that infrastructure.  This is, in fact, what I do.  Here
is the device model that a guest sees:

struct vbus_device_proxy_ops {
           int (*open)(struct vbus_device_proxy *dev, int version, int
flags);
           int (*close)(struct vbus_device_proxy *dev, int flags);
           int (*shm)(struct vbus_device_proxy *dev, int id, int prio,
                      void *ptr, size_t len,
                      struct shm_signal_desc *sigdesc, struct shm_signal
**signal,
                      int flags);
           int (*call)(struct vbus_device_proxy *dev, u32 func,
                       void *data, size_t len, int flags);
           void (*release)(struct vbus_device_proxy *dev);
   };

Now the client just calls dev->call() and its lighting quick, and they
don't have to worry about all the details of making it quick, nor expend
addition per-cpu heap and address space to get it.

Moving on: _Other_ items cannot be replicated (at least, not without
hacking it into something that is no longer PCI.

Things like the pci-id namespace are just silly for software.  I would
rather have a namespace that does not require central management so
people are free to create vbus-backends at will.  This is akin to
registering a device MAJOR/MINOR, verses using the various dynamic
assignment mechanisms.  vbus uses a string identifier in place of a
pci-id.  This is superior IMHO, and not compatible with PCI.

As another example, the connector design coalesces *all* shm-signals
into a single interrupt (by prio) that uses the same context-switch
mitigation techniques that help boost things like networking.  This
effectively means we can detect and optimize out ack/eoi cycles from the
APIC as the IO load increases (which is when you need it most).  PCI has
no such concept.

In addition, the signals and interrupts are priority aware, which is
useful for things like 802.1p networking where you may establish 8-tx
and 8-rx queues for your virtio-net device.  x86 APIC really has no
usable equivalent, so PCI is stuck here.

Also, the signals can be allocated on-demand for implementing things
like IPC channels in response to guest requests since there is no
assumption about device-to-interrupt mappings.  This is more flexible.

And through all of this, this design would work in any guest even if it
doesn't have PCI (e.g. lguest, UML, physical systems, etc).

-- Bottom Line --

The idea here is to generalize all the interesting parts that are common
(fast sync+async io, context-switch mitigation, back-end models, memory
abstractions, signal-path routing, etc) that a variety of linux based
technologies can use (kvm, lguest, openvz, uml, physical systems) and
only require the thin "connector" code to port the system around.  The
idea is to try to get this aspect of PV right once, and at some point in
the future, perhaps vbus will be as ubiquitous as PCI.  Well, perhaps
not *that* ubiquitous, but you get the idea ;)

Then device models like virtio can ride happily on top and we end up
with a really robust and high-performance Linux-based stack.  I don't
buy the argument that we already have PCI so lets use it.  I don't think
its the best design and I am not afraid to make an investment in a
change here because I think it will pay off in the long run.

I hope this helps to clarify my motivation.

Kind Regards,
-Greg


--------------enigCCEC513B0F6D65FAFBBDE36D
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqJsIoACgkQP5K2CMvXmqE+swCfeKEUX4YwPLNfUZa0Rw0Fxw7g
JFMAn1FogIsx0q+ECQ4g5JrLeYdrT242
=76Ys
-----END PGP SIGNATURE-----

--------------enigCCEC513B0F6D65FAFBBDE36D--

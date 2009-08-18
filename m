From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 10:46:33 -0400
Message-ID: <4A8ABEC9.6090006@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigD0EF423B8C186B3306C014A7"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8A674E.8070200@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigD0EF423B8C186B3306C014A7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/17/2009 10:33 PM, Gregory Haskins wrote:
>>
>> There is a secondary question of venet (a vbus native device) verses
>> virtio-net (a virtio native device that works with PCI or VBUS).  If
>> this contention is really around venet vs virtio-net, I may possibly
>> conceed and retract its submission to mainline.  I've been pushing it =
to
>> date because people are using it and I don't see any reason that the
>> driver couldn't be upstream.
>>   =20
>=20
> That's probably the cause of much confusion.  The primary kvm pain poin=
t
> is now networking, so in any vbus discussion we're concentrating on tha=
t
> aspect.
>=20
>>> Also, are you willing to help virtio to become faster?
>>>     =20
>> Yes, that is not a problem.  Note that virtio in general, and
>> virtio-net/venet in particular are not the primary goal here, however.=

>> Improved 802.x and block IO are just positive side-effects of the
>> effort.  I started with 802.x networking just to demonstrate the IO
>> layer capabilities, and to test it.  It ended up being so good on
>> contrast to existing facilities, that developers in the vbus community=

>> started using it for production development.
>>
>> Ultimately, I created vbus to address areas of performance that have n=
ot
>> yet been addressed in things like KVM.  Areas such as real-time guests=
,
>> or RDMA (host bypass) interfaces.
>=20
> Can you explain how vbus achieves RDMA?
>=20
> I also don't see the connection to real time guests.

Both of these are still in development.  Trying to stay true to the
"release early and often" mantra, the core vbus technology is being
pushed now so it can be reviewed.  Stay tuned for these other development=
s.

>=20
>> I also designed it in such a way that
>> we could, in theory, write one set of (linux-based) backends, and have=

>> them work across a variety of environments (such as containers/VMs lik=
e
>> KVM, lguest, openvz, but also physical systems like blade enclosures a=
nd
>> clusters, or even applications running on the host).
>>   =20
>=20
> Sorry, I'm still confused.  Why would openvz need vbus?

Its just an example.  The point is that I abstracted what I think are
the key points of fast-io, memory routing, signal routing, etc, so that
it will work in a variety of (ideally, _any_) environments.

There may not be _performance_ motivations for certain classes of VMs
because they already have decent support, but they may want a connector
anyway to gain some of the new features available in vbus.

And looking forward, the idea is that we have commoditized the backend
so we don't need to redo this each time a new container comes along.


>  It already has
> zero-copy networking since it's a shared kernel.  Shared memory should
> also work seamlessly, you just need to expose the shared memory object
> on a shared part of the namespace.  And of course, anything in the
> kernel is already shared.
>=20
>>> Or do you
>>> have arguments why that is impossible to do so and why the only
>>> possible solution is vbus? Avi says no such arguments were offered
>>> so far.
>>>     =20
>> Not for lack of trying.  I think my points have just been missed
>> everytime I try to describe them. ;)  Basically I write a message very=

>> similar to this one, and the next conversation starts back from square=

>> one.  But I digress, let me try again..
>>
>> Noting that this discussion is really about the layer *below* virtio,
>> not virtio itself (e.g. PCI vs vbus).  Lets start with a little
>> background:
>>
>> -- Background --
>>
>> So on one level, we have the resource-container technology called
>> "vbus".  It lets you create a container on the host, fill it with
>> virtual devices, and assign that container to some context (such as a
>> KVM guest).  These "devices" are LKMs, and each device has a very simp=
le
>> verb namespace consisting of a synchronous "call()" method, and a
>> "shm()" method for establishing async channels.
>>
>> The async channels are just shared-memory with a signal path (e.g.
>> interrupts and hypercalls), which the device+driver can use to overlay=

>> things like rings (virtqueues, IOQs), or other shared-memory based
>> constructs of their choosing (such as a shared table).  The signal pat=
h
>> is designed to minimize enter/exits and reduce spurious signals in a
>> unified way (see shm-signal patch).
>>
>> call() can be used both for config-space like details, as well as
>> fast-path messaging that require synchronous behavior (such as guest
>> scheduler updates).
>>
>> All of this is managed via sysfs/configfs.
>>   =20
>=20
> One point of contention is that this is all managementy stuff and shoul=
d
> be kept out of the host kernel.  Exposing shared memory, interrupts, an=
d
> guest hypercalls can all be easily done from userspace (as virtio
> demonstrates).  True, some devices need kernel acceleration, but that's=

> no reason to put everything into the host kernel.

See my last reply to Anthony.  My two points here are that:

a) having it in-kernel makes it a complete subsystem, which perhaps has
diminished value in kvm, but adds value in most other places that we are
looking to use vbus.

b) the in-kernel code is being overstated as "complex".  We are not
talking about your typical virt thing, like an emulated ICH/PCI chipset.
 Its really a simple list of devices with a handful of attributes.  They
are managed using established linux interfaces, like sysfs/configfs.


>=20
>> On the guest, we have a "vbus-proxy" which is how the guest gets acces=
s
>> to devices assigned to its container.  (as an aside, "virtio" devices
>> can be populated in the container, and then surfaced up to the
>> virtio-bus via that virtio-vbus patch I mentioned).
>>
>> There is a thing called a "vbus-connector" which is the guest specific=

>> part.  Its job is to connect the vbus-proxy in the guest, to the vbus
>> container on the host.  How it does its job is specific to the connect=
or
>> implementation, but its role is to transport messages between the gues=
t
>> and the host (such as for call() and shm() invocations) and to handle
>> things like discovery and hotswap.
>>   =20
>=20
> virtio has an exact parallel here (virtio-pci and friends).
>=20
>> Out of all this, I think the biggest contention point is the design of=

>> the vbus-connector that I use in AlacrityVM (Avi, correct me if I am
>> wrong and you object to other aspects as well).  I suspect that if I h=
ad
>> designed the vbus-connector to surface vbus devices as PCI devices via=

>> QEMU, the patches would potentially have been pulled in a while ago.
>>   =20
>=20
> Exposing devices as PCI is an important issue for me, as I have to
> consider non-Linux guests.

Thats your prerogative, but obviously not everyone agrees with you.
Getting non-Linux guests to work is my problem if you chose to not be
part of the vbus community.

> Another issue is the host kernel management code which I believe is
> superfluous.

In your opinion, right?

>=20
> But the biggest issue is compatibility.  virtio exists and has Windows
> and Linux drivers.  Without a fatal flaw in virtio we'll continue to
> support it.

So go ahead.

> Given that, why spread to a new model?

Note: I haven't asked you to (at least, not since April with the vbus-v3
release).  Spreading to a new model is currently the role of the
AlacrityVM project, since we disagree on the utility of a new model.

>=20
> Of course, I understand you're interested in non-ethernet, non-block
> devices.  I can't comment on these until I see them.  Maybe they can fi=
t
> the virtio model, and maybe they can't.

Yes, that I am not sure.  They may.  I will certainly explore that angle
at some point.

>=20
>> There are, of course, reasons why vbus does *not* render as PCI, so th=
is
>> is the meat of of your question, I believe.
>>
>> At a high level, PCI was designed for software-to-hardware interaction=
,
>> so it makes assumptions about that relationship that do not necessaril=
y
>> apply to virtualization.
>>
>> For instance:
>>
>> A) hardware can only generate byte/word sized requests at a time becau=
se
>> that is all the pcb-etch and silicon support. So hardware is usually
>> expressed in terms of some number of "registers".
>>   =20
>=20
> No, hardware happily DMAs to and fro main memory.

Yes, now walk me through how you set up DMA to do something like a call
when you do not know addresses apriori.  Hint: count the number of
MMIO/PIOs you need.  If the number is > 1, you've lost.


>  Some hardware of
> course uses mmio registers extensively, but not virtio hardware.  With
> the recent MSI support no registers are touched in the fast path.

Note we are not talking about virtio here.  Just raw PCI and why I
advocate vbus over it.


>=20
>> C) the target end-point has no visibility into the CPU machine state
>> other than the parameters passed in the bus-cycle (usually an address
>> and data tuple).
>>   =20
>=20
> That's not an issue.  Accessing memory is cheap.
>=20
>> D) device-ids are in a fixed width register and centrally assigned fro=
m
>> an authority (e.g. PCI-SIG).
>>   =20
>=20
> That's not an issue either.  Qumranet/Red Hat has donated a range of
> device IDs for use in virtio.

Yes, and to get one you have to do what?  Register it with kvm.git,
right?  Kind of like registering a MAJOR/MINOR, would you agree?  Maybe
you do not mind (especially given your relationship to kvm.git), but
there are disadvantages to that model for most of the rest of us.


>  Device IDs are how devices are associated
> with drivers, so you'll need something similar for vbus.

Nope, just like you don't need to do anything ahead of time for using a
dynamic misc-device name.  You just have both the driver and device know
what they are looking for (its part of the ABI).

>=20
>> E) Interrupt/MSI routing is per-device oriented
>>   =20
>=20
> Please elaborate.  What is the issue?  How does vbus solve it?

There are no "interrupts" in vbus..only shm-signals.  You can establish
an arbitrary amount of shm regions, each with an optional shm-signal
associated with it.  To do this, the driver calls dev->shm(), and you
get back a shm_signal object.

Underneath the hood, the vbus-connector (e.g. vbus-pcibridge) decides
how it maps real interrupts to shm-signals (on a system level, not per
device).  This can be 1:1, or any other scheme.  vbus-pcibridge uses one
system-wide interrupt per priority level (today this is 8 levels), each
with an IOQ based event channel.  "signals" come as an event on that
channel.

So the "issue" is that you have no real choice with PCI.  You just get
device oriented interrupts.  With vbus, its abstracted.  So you can
still get per-device standard MSI, or you can do fancier things like do
coalescing and prioritization.

>=20
>> F) Interrupts/MSI are assumed cheap to inject
>>   =20
>=20
> Interrupts are not assumed cheap; that's why interrupt mitigation is
> used (on real and virtual hardware).

Its all relative.  IDT dispatch and EOI overhead are "baseline" on real
hardware, whereas they are significantly more expensive to do the
vmenters and vmexits on virt (and you have new exit causes, like
irq-windows, etc, that do not exist in real HW).


>=20
>> G) Interrupts/MSI are non-priortizable.
>>   =20
>=20
> They are prioritizable; Linux ignores this though (Windows doesn't).=20
> Please elaborate on what the problem is and how vbus solves it.

It doesn't work right.  The x86 sense of interrupt priority is, sorry to
say it, half-assed at best.  I've worked with embedded systems that have
real interrupt priority support in the hardware, end to end, including
the PIC.  The LAPIC on the other hand is really weak in this dept, and
as you said, Linux doesn't even attempt to use whats there.


>=20
>> H) Interrupts/MSI are statically established
>>   =20
>=20
> Can you give an example of why this is a problem?

Some of the things we are building use the model of having a device that
hands out shm-signal in response to guest events (say, the creation of
an IPC channel).  This would generally be handled by a specific device
model instance, and it would need to do this without pre-declaring the
MSI vectors (to use PCI as an example).


>=20
>> These assumptions and constraints may be completely different or simpl=
y
>> invalid in a virtualized guest. For instance, the hypervisor is just
>> software, and therefore it's not restricted to "etch" constraints. IO
>> requests can be arbitrarily large, just as if you are invoking a libra=
ry
>> function-call or OS system-call. Likewise, each one of those requests =
is
>> a branch and a context switch, so it has often has greater performance=

>> implications than a simple register bus-cycle in hardware.  If you use=

>> an MMIO variant, it has to run through the page-fault code to be decod=
ed.
>>
>> The result is typically decreased performance if you try to do the sam=
e
>> thing real hardware does. This is why you usually see hypervisor
>> specific drivers (e.g. virtio-net, vmnet, etc) a common feature.
>>
>> _Some_ performance oriented items can technically be accomplished in
>> PCI, albeit in a much more awkward way.  For instance, you can set up =
a
>> really fast, low-latency "call()" mechanism using a PIO port on a
>> PCI-model and ioeventfd.  As a matter of fact, this is exactly what th=
e
>> vbus pci-bridge does:
>>   =20
>=20
> What performance oriented items have been left unaddressed?

Well, the interrupt model to name one.

>=20
> virtio and vbus use three communications channels:  call from guest to
> host (implemented as pio and reasonably fast), call from host to guest
> (implemented as msi and reasonably fast) and shared memory (as fast as
> it can be).  Where does PCI limit you in any way?
>=20
>> The problem here is that this is incredibly awkward to setup.  You hav=
e
>> all that per-cpu goo and the registration of the memory on the guest.
>> And on the host side, you have all the vmapping of the registered
>> memory, and the file-descriptor to manage.  In short, its really painf=
ul.
>>
>> I would much prefer to do this *once*, and then let all my devices
>> simple re-use that infrastructure.  This is, in fact, what I do.  Here=

>> is the device model that a guest sees:
>>   =20
>=20
> virtio also reuses the pci code, on both guest and host.
>=20
>> Moving on: _Other_ items cannot be replicated (at least, not without
>> hacking it into something that is no longer PCI.
>>
>> Things like the pci-id namespace are just silly for software.  I would=

>> rather have a namespace that does not require central management so
>> people are free to create vbus-backends at will.  This is akin to
>> registering a device MAJOR/MINOR, verses using the various dynamic
>> assignment mechanisms.  vbus uses a string identifier in place of a
>> pci-id.  This is superior IMHO, and not compatible with PCI.
>>   =20
>=20
> How do you handle conflicts?  Again you need a central authority to han=
d
> out names or prefixes.

Not really, no.  If you really wanted to be formal about it, you could
adopt any series of UUID schemes.  For instance, perhaps venet should be
"com.novell::virtual-ethernet".  Heck, I could use uuidgen.

>=20
>> As another example, the connector design coalesces *all* shm-signals
>> into a single interrupt (by prio) that uses the same context-switch
>> mitigation techniques that help boost things like networking.  This
>> effectively means we can detect and optimize out ack/eoi cycles from t=
he
>> APIC as the IO load increases (which is when you need it most).  PCI h=
as
>> no such concept.
>>   =20
>=20
> That's a bug, not a feature.  It means poor scaling as the number of
> vcpus increases and as the number of devices increases.

So the "avi-vbus-connector" can use 1:1, if you prefer.  Large vcpu
counts (which are not typical) and irq-affinity is not a target
application for my design, so I prefer the coalescing model in the
vbus-pcibridge included in this series. YMMV

Note: If you really wanted to, you could have priority queues per-cpu,
and get the best of both worlds (irq routing and coalescing/priority).


>=20
> Note nothing prevents steering multiple MSIs into a single vector.  It'=
s
> a bad idea though.

Yes, it is a bad idea...and not the same thing either.  This would
effectively create a shared-line scenario in the irq code, which is not
what happens in vbus.

>=20
>> In addition, the signals and interrupts are priority aware, which is
>> useful for things like 802.1p networking where you may establish 8-tx
>> and 8-rx queues for your virtio-net device.  x86 APIC really has no
>> usable equivalent, so PCI is stuck here.
>>   =20
>=20
> x86 APIC is priority aware.

Have you ever tried to use it?

>=20
>> Also, the signals can be allocated on-demand for implementing things
>> like IPC channels in response to guest requests since there is no
>> assumption about device-to-interrupt mappings.  This is more flexible.=

>>   =20
>=20
> Yes.  However given that vectors are a scarce resource you're severely
> limited in that.

The connector I am pushing out does not have this limitation.

>  And if you're multiplexing everything on one vector,
> then you can just as well demultiplex your channels in the virtio drive=
r
> code.

Only per-device, not system wide.

>=20
>> And through all of this, this design would work in any guest even if i=
t
>> doesn't have PCI (e.g. lguest, UML, physical systems, etc).
>>   =20
>=20
> That is true for virtio which works on pci-less lguest and s390.

Yes, and lguest and s390 had to build their own bus-model to do it, right=
?

Thank you for bringing this up, because it is one of the main points
here.  What I am trying to do is generalize the bus to prevent the
proliferation of more of these isolated models in the future.  Build
one, fast, in-kernel model so that we wouldn't need virtio-X, and
virtio-Y in the future.  They can just reuse the (performance optimized)
bus and models, and only need to build the connector to bridge them.


>=20
>> -- Bottom Line --
>>
>> The idea here is to generalize all the interesting parts that are comm=
on
>> (fast sync+async io, context-switch mitigation, back-end models, memor=
y
>> abstractions, signal-path routing, etc) that a variety of linux based
>> technologies can use (kvm, lguest, openvz, uml, physical systems) and
>> only require the thin "connector" code to port the system around.  The=

>> idea is to try to get this aspect of PV right once, and at some point =
in
>> the future, perhaps vbus will be as ubiquitous as PCI.  Well, perhaps
>> not *that* ubiquitous, but you get the idea ;)
>>   =20
>=20
> That is exactly the design goal of virtio (except it limits itself to
> virtualization).

No, virtio is only part of the picture.  It not including the backend
models, or how to do memory/signal-path abstraction for in-kernel, for
instance.  But otherwise, virtio as a device model is compatible with
vbus as a bus model.  They compliment one another.



>=20
>> Then device models like virtio can ride happily on top and we end up
>> with a really robust and high-performance Linux-based stack.  I don't
>> buy the argument that we already have PCI so lets use it.  I don't thi=
nk
>> its the best design and I am not afraid to make an investment in a
>> change here because I think it will pay off in the long run.
>>   =20
>=20
> Sorry, I don't think you've shown any quantifiable advantages.

We can agree to disagree then, eh?  There are certainly quantifiable
differences.  Waving your hand at the differences to say they are not
advantages is merely an opinion, one that is not shared universally.

The bottom line is all of these design distinctions are encapsulated
within the vbus subsystem and do not affect the kvm code-base.  So
agreement with kvm upstream is not a requirement, but would be
advantageous for collaboration.

Kind Regards,
-Greg




--------------enigD0EF423B8C186B3306C014A7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqKvskACgkQP5K2CMvXmqG2XgCgia3V5+vWaA1rpgNhr/hBRc3M
jSoAoI0YlkFL/Tq4sG7IX7173ukdW4kr
=EiQb
-----END PGP SIGNATURE-----

--------------enigD0EF423B8C186B3306C014A7--

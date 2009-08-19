From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 02:28:09 -0400
Message-ID: <4A8B9B79.9050004@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enigAC1FF8A389B8626192A1013C"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8AD678.7050609@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigAC1FF8A389B8626192A1013C
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/18/2009 05:46 PM, Gregory Haskins wrote:
>>
>>> Can you explain how vbus achieves RDMA?
>>>
>>> I also don't see the connection to real time guests.
>>>     =20
>> Both of these are still in development.  Trying to stay true to the
>> "release early and often" mantra, the core vbus technology is being
>> pushed now so it can be reviewed.  Stay tuned for these other
>> developments.
>>   =20
>=20
> Hopefully you can outline how it works.  AFAICT, RDMA and kernel bypass=

> will need device assignment.  If you're bypassing the call into the hos=
t
> kernel, it doesn't really matter how that call is made, does it?

This is for things like the setup of queue-pairs, and the transport of
door-bells, and ib-verbs.  I am not on the team doing that work, so I am
not an expert in this area.  What I do know is having a flexible and
low-latency signal-path was deemed a key requirement.

For real-time, a big part of it is relaying the guest scheduler state to
the host, but in a smart way.  For instance, the cpu priority for each
vcpu is in a shared-table.  When the priority is raised, we can simply
update the table without taking a VMEXIT.  When it is lowered, we need
to inform the host of the change in case the underlying task needs to
reschedule.

This is where the really fast call() type mechanism is important.

Its also about having the priority flow-end to end, and having the vcpu
interrupt state affect the task-priority, etc (e.g. pending interrupts
affect the vcpu task prio).

etc, etc.

I can go on and on (as you know ;), but will wait till this work is more
concrete and proven.

>=20
>>>> I also designed it in such a way that
>>>> we could, in theory, write one set of (linux-based) backends, and ha=
ve
>>>> them work across a variety of environments (such as containers/VMs l=
ike
>>>> KVM, lguest, openvz, but also physical systems like blade enclosures=

>>>> and
>>>> clusters, or even applications running on the host).
>>>>
>>>>       =20
>>> Sorry, I'm still confused.  Why would openvz need vbus?
>>>     =20
>> Its just an example.  The point is that I abstracted what I think are
>> the key points of fast-io, memory routing, signal routing, etc, so tha=
t
>> it will work in a variety of (ideally, _any_) environments.
>>
>> There may not be _performance_ motivations for certain classes of VMs
>> because they already have decent support, but they may want a connecto=
r
>> anyway to gain some of the new features available in vbus.
>>
>> And looking forward, the idea is that we have commoditized the backend=

>> so we don't need to redo this each time a new container comes along.
>>   =20
>=20
> I'll wait until a concrete example shows up as I still don't understand=
=2E

Ok.

>=20
>>> One point of contention is that this is all managementy stuff and sho=
uld
>>> be kept out of the host kernel.  Exposing shared memory, interrupts, =
and
>>> guest hypercalls can all be easily done from userspace (as virtio
>>> demonstrates).  True, some devices need kernel acceleration, but that=
's
>>> no reason to put everything into the host kernel.
>>>     =20
>> See my last reply to Anthony.  My two points here are that:
>>
>> a) having it in-kernel makes it a complete subsystem, which perhaps ha=
s
>> diminished value in kvm, but adds value in most other places that we a=
re
>> looking to use vbus.
>>   =20
>=20
> It's not a complete system unless you want users to administer VMs usin=
g
> echo and cat and configfs.  Some userspace support will always be
> necessary.

Well, more specifically, it doesn't require a userspace app to hang
around.  For instance, you can set up your devices with udev scripts, or
whatever.

But that is kind of a silly argument, since the kernel always needs
userspace around to give it something interesting, right? ;)

Basically, what it comes down to is both vbus and vhost need
configuration/management.  Vbus does it with sysfs/configfs, and vhost
does it with ioctls.  I ultimately decided to go with sysfs/configfs
because, at least that the time I looked, it seemed like the "blessed"
way to do user->kernel interfaces.

>=20
>> b) the in-kernel code is being overstated as "complex".  We are not
>> talking about your typical virt thing, like an emulated ICH/PCI chipse=
t.
>>   Its really a simple list of devices with a handful of attributes.  T=
hey
>> are managed using established linux interfaces, like sysfs/configfs.
>>   =20
>=20
> They need to be connected to the real world somehow.  What about
> security?  can any user create a container and devices and link them to=

> real interfaces?  If not, do you need to run the VM as root?

Today it has to be root as a result of weak mode support in configfs, so
you have me there.  I am looking for help patching this limitation, thoug=
h.

Also, venet-tap uses a bridge, which of course is not as slick as a
raw-socket w.r.t. perms.


>=20
> virtio and vhost-net solve these issues.  Does vbus?
>=20
> The code may be simple to you.  But the question is whether it's
> necessary, not whether it's simple or complex.
>=20
>>> Exposing devices as PCI is an important issue for me, as I have to
>>> consider non-Linux guests.
>>>     =20
>> Thats your prerogative, but obviously not everyone agrees with you.
>>   =20
>=20
> I hope everyone agrees that it's an important issue for me and that I
> have to consider non-Linux guests.  I also hope that you're considering=

> non-Linux guests since they have considerable market share.

I didn't mean non-Linux guests are not important.  I was disagreeing
with your assertion that it only works if its PCI.  There are numerous
examples of IHV/ISV "bridge" implementations deployed in Windows, no?
If vbus is exposed as a PCI-BRIDGE, how is this different?

>=20
>> Getting non-Linux guests to work is my problem if you chose to not be
>> part of the vbus community.
>>   =20
>=20
> I won't be writing those drivers in any case.

Ok.

>=20
>>> Another issue is the host kernel management code which I believe is
>>> superfluous.
>>>     =20
>> In your opinion, right?
>>   =20
>=20
> Yes, this is why I wrote "I believe".

Fair enough.

>=20
>=20
>>> Given that, why spread to a new model?
>>>     =20
>> Note: I haven't asked you to (at least, not since April with the vbus-=
v3
>> release).  Spreading to a new model is currently the role of the
>> AlacrityVM project, since we disagree on the utility of a new model.
>>   =20
>=20
> Given I'm not the gateway to inclusion of vbus/venet, you don't need to=

> ask me anything.  I'm still free to give my opinion.

Agreed, and I didn't mean to suggest otherwise.  It not clear if you are
wearing the "kvm maintainer" hat, or the "lkml community member" hat at
times, so its important to make that distinction.  Otherwise, its not
clear if this is edict as my superior, or input as my peer. ;)

>=20
>>>> A) hardware can only generate byte/word sized requests at a time
>>>> because
>>>> that is all the pcb-etch and silicon support. So hardware is usually=

>>>> expressed in terms of some number of "registers".
>>>>
>>>>       =20
>>> No, hardware happily DMAs to and fro main memory.
>>>     =20
>> Yes, now walk me through how you set up DMA to do something like a cal=
l
>> when you do not know addresses apriori.  Hint: count the number of
>> MMIO/PIOs you need.  If the number is>  1, you've lost.
>>   =20
>=20
> With virtio, the number is 1 (or less if you amortize).  Set up the rin=
g
> entries and kick.

Again, I am just talking about basic PCI here, not the things we build
on top.

The point is: the things we build on top have costs associated with
them, and I aim to minimize it.  For instance, to do a "call()" kind of
interface, you generally need to pre-setup some per-cpu mappings so that
you can just do a single iowrite32() to kick the call off.  Those
per-cpu mappings have a cost if you want them to be high-performance, so
my argument is that you ideally want to limit the number of times you
have to do this.  My current design reduces this to "once".


>=20
>>>   Some hardware of
>>> course uses mmio registers extensively, but not virtio hardware.  Wit=
h
>>> the recent MSI support no registers are touched in the fast path.
>>>     =20
>> Note we are not talking about virtio here.  Just raw PCI and why I
>> advocate vbus over it.
>>   =20
>=20
> There's no such thing as raw PCI.  Every PCI device has a protocol.  Th=
e
> protocol virtio chose is optimized for virtualization.

And its a question of how that protocol scales, more than how the
protocol works.

Obviously the general idea of the protocol works, as vbus itself is
implemented as a PCI-BRIDGE and is therefore limited to the underlying
characteristics that I can get out of PCI (like PIO latency).

>=20
>=20
>>>> D) device-ids are in a fixed width register and centrally assigned f=
rom
>>>> an authority (e.g. PCI-SIG).
>>>>
>>>>       =20
>>> That's not an issue either.  Qumranet/Red Hat has donated a range of
>>> device IDs for use in virtio.
>>>     =20
>> Yes, and to get one you have to do what?  Register it with kvm.git,
>> right?  Kind of like registering a MAJOR/MINOR, would you agree?  Mayb=
e
>> you do not mind (especially given your relationship to kvm.git), but
>> there are disadvantages to that model for most of the rest of us.
>>   =20
>=20
> Send an email, it's not that difficult.  There's also an experimental
> range.

Ugly....


>=20
>>>   Device IDs are how devices are associated
>>> with drivers, so you'll need something similar for vbus.
>>>     =20
>> Nope, just like you don't need to do anything ahead of time for using =
a
>> dynamic misc-device name.  You just have both the driver and device kn=
ow
>> what they are looking for (its part of the ABI).
>>   =20
>=20
> If you get a device ID clash, you fail.  If you get a device name clash=
,
> you fail in the same way.

No argument here.


>=20
>>>> E) Interrupt/MSI routing is per-device oriented
>>>>
>>>>       =20
>>> Please elaborate.  What is the issue?  How does vbus solve it?
>>>     =20
>> There are no "interrupts" in vbus..only shm-signals.  You can establis=
h
>> an arbitrary amount of shm regions, each with an optional shm-signal
>> associated with it.  To do this, the driver calls dev->shm(), and you
>> get back a shm_signal object.
>>
>> Underneath the hood, the vbus-connector (e.g. vbus-pcibridge) decides
>> how it maps real interrupts to shm-signals (on a system level, not per=

>> device).  This can be 1:1, or any other scheme.  vbus-pcibridge uses o=
ne
>> system-wide interrupt per priority level (today this is 8 levels), eac=
h
>> with an IOQ based event channel.  "signals" come as an event on that
>> channel.
>>
>> So the "issue" is that you have no real choice with PCI.  You just get=

>> device oriented interrupts.  With vbus, its abstracted.  So you can
>> still get per-device standard MSI, or you can do fancier things like d=
o
>> coalescing and prioritization.
>>   =20
>=20
> As I've mentioned before, prioritization is available on x86

But as Ive mentioned, it doesn't work very well.


>, and coalescing scales badly.

Depends on what is scaling.  Scaling vcpus?  Yes, you are right.
Scaling the number of devices?  No, this is where it improves.

>=20
>>>> F) Interrupts/MSI are assumed cheap to inject
>>>>
>>>>       =20
>>> Interrupts are not assumed cheap; that's why interrupt mitigation is
>>> used (on real and virtual hardware).
>>>     =20
>> Its all relative.  IDT dispatch and EOI overhead are "baseline" on rea=
l
>> hardware, whereas they are significantly more expensive to do the
>> vmenters and vmexits on virt (and you have new exit causes, like
>> irq-windows, etc, that do not exist in real HW).
>>   =20
>=20
> irq window exits ought to be pretty rare, so we're only left with
> injection vmexits.  At around 1us/vmexit, even 100,000 interrupts/vcpu
> (which is excessive) will only cost you 10% cpu time.

1us is too much for what I am building, IMHO.  Besides, there are a slew
of older machines (like Woodcrests) that are more like 2+us per exit, so
1us is a best-case scenario.

>=20
>>>> G) Interrupts/MSI are non-priortizable.
>>>>
>>>>       =20
>>> They are prioritizable; Linux ignores this though (Windows doesn't).
>>> Please elaborate on what the problem is and how vbus solves it.
>>>     =20
>> It doesn't work right.  The x86 sense of interrupt priority is, sorry =
to
>> say it, half-assed at best.  I've worked with embedded systems that ha=
ve
>> real interrupt priority support in the hardware, end to end, including=

>> the PIC.  The LAPIC on the other hand is really weak in this dept, and=

>> as you said, Linux doesn't even attempt to use whats there.
>>   =20
>=20
> Maybe prioritization is not that important then.  If it is, it needs to=

> be fixed at the lapic level, otherwise you have no real prioritization
> wrt non-vbus interrupts.

While this is true, I am generally not worried about it.  For the
environments that care, I plan on having it be predominantly vbus
devices and using an -rt kernel (with irq-threads).

>=20
>>>> H) Interrupts/MSI are statically established
>>>>
>>>>       =20
>>> Can you give an example of why this is a problem?
>>>     =20
>> Some of the things we are building use the model of having a device th=
at
>> hands out shm-signal in response to guest events (say, the creation of=

>> an IPC channel).  This would generally be handled by a specific device=

>> model instance, and it would need to do this without pre-declaring the=

>> MSI vectors (to use PCI as an example).
>>   =20
>=20
> You're free to demultiplex an MSI to however many consumers you want,
> there's no need for a new bus for that.

Hmmm...can you elaborate?


>=20
>>> What performance oriented items have been left unaddressed?
>>>     =20
>> Well, the interrupt model to name one.
>>   =20
>=20
> Like I mentioned, you can merge MSI interrupts, but that's not
> necessarily a good idea.
>=20
>>> How do you handle conflicts?  Again you need a central authority to h=
and
>>> out names or prefixes.
>>>     =20
>> Not really, no.  If you really wanted to be formal about it, you could=

>> adopt any series of UUID schemes.  For instance, perhaps venet should =
be
>> "com.novell::virtual-ethernet".  Heck, I could use uuidgen.
>>   =20
>=20
> Do you use DNS.  We use PCI-SIG.  If Novell is a PCI-SIG member you can=

> get a vendor ID and control your own virtio space.

Yeah, we have our own id.  I am more concerned about making this design
make sense outside of PCI oriented environments.

>=20
>>>> As another example, the connector design coalesces *all* shm-signals=

>>>> into a single interrupt (by prio) that uses the same context-switch
>>>> mitigation techniques that help boost things like networking.  This
>>>> effectively means we can detect and optimize out ack/eoi cycles from=

>>>> the
>>>> APIC as the IO load increases (which is when you need it most).  PCI=

>>>> has
>>>> no such concept.
>>>>
>>>>       =20
>>> That's a bug, not a feature.  It means poor scaling as the number of
>>> vcpus increases and as the number of devices increases.

vcpu increases, I agree (and am ok with, as I expect low vcpu count
machines to be typical).  nr of devices, I disagree.  can you elaborate?

>>>     =20
>> So the "avi-vbus-connector" can use 1:1, if you prefer.  Large vcpu
>> counts (which are not typical) and irq-affinity is not a target
>> application for my design, so I prefer the coalescing model in the
>> vbus-pcibridge included in this series. YMMV
>>   =20
>=20
> So far you've left out live migration

guilty as charged.

> Windows,

Work in progress.

> large guests

Can you elaborate?  I am not familiar with the term.

> and multiqueue out of your design.

AFAICT, multiqueue should work quite nicely with vbus.  Can you
elaborate on where you see the problem?

>  If you wish to position vbus/venet for
> large scale use you'll need to address all of them.
>=20
>>> Note nothing prevents steering multiple MSIs into a single vector.  I=
t's
>>> a bad idea though.
>>>     =20
>> Yes, it is a bad idea...and not the same thing either.  This would
>> effectively create a shared-line scenario in the irq code, which is no=
t
>> what happens in vbus.
>>   =20
>=20
> Ok.
>=20
>>>> In addition, the signals and interrupts are priority aware, which is=

>>>> useful for things like 802.1p networking where you may establish 8-t=
x
>>>> and 8-rx queues for your virtio-net device.  x86 APIC really has no
>>>> usable equivalent, so PCI is stuck here.
>>>>
>>>>       =20
>>> x86 APIC is priority aware.
>>>     =20
>> Have you ever tried to use it?
>>   =20
>=20
> I haven't, but Windows does.

Yeah, it doesn't really work well.  Its an extremely rigid model that
(IIRC) only lets you prioritize in 16 groups spaced by IDT (0-15 are one
level, 16-31 are another, etc).  Most of the embedded PICs I have worked
with supported direct remapping, etc.  But in any case, Linux doesn't
support it so we are hosed no matter how good it is.


>=20
>>>> Also, the signals can be allocated on-demand for implementing things=

>>>> like IPC channels in response to guest requests since there is no
>>>> assumption about device-to-interrupt mappings.  This is more flexibl=
e.
>>>>
>>>>       =20
>>> Yes.  However given that vectors are a scarce resource you're severel=
y
>>> limited in that.
>>>     =20
>> The connector I am pushing out does not have this limitation.
>>   =20
>=20
> Okay.
>=20
>>  =20
>>>   And if you're multiplexing everything on one vector,
>>> then you can just as well demultiplex your channels in the virtio dri=
ver
>>> code.
>>>     =20
>> Only per-device, not system wide.
>>   =20
>=20
> Right.  I still think multiplexing interrupts is a bad idea in a large
> system.  In a small system... why would you do it at all?

device scaling, like for running a device-domain / bridge in a guest.

>=20
>>>> And through all of this, this design would work in any guest even if=
 it
>>>> doesn't have PCI (e.g. lguest, UML, physical systems, etc).
>>>>
>>>>       =20
>>> That is true for virtio which works on pci-less lguest and s390.
>>>     =20
>> Yes, and lguest and s390 had to build their own bus-model to do it,
>> right?
>>   =20
>=20
> They had to build connectors just like you propose to do.

More importantly, they had to build back-end busses too, no?

>=20
>> Thank you for bringing this up, because it is one of the main points
>> here.  What I am trying to do is generalize the bus to prevent the
>> proliferation of more of these isolated models in the future.  Build
>> one, fast, in-kernel model so that we wouldn't need virtio-X, and
>> virtio-Y in the future.  They can just reuse the (performance optimize=
d)
>> bus and models, and only need to build the connector to bridge them.
>>   =20
>=20
> But you still need vbus-connector-lguest and vbus-connector-s390 becaus=
e
> they all talk to the host differently.  So what's changed?  the names?

The fact that they don't need to redo most of the in-kernel backend
stuff.  Just the connector.

>=20
>>> That is exactly the design goal of virtio (except it limits itself to=

>>> virtualization).
>>>     =20
>> No, virtio is only part of the picture.  It not including the backend
>> models, or how to do memory/signal-path abstraction for in-kernel, for=

>> instance.  But otherwise, virtio as a device model is compatible with
>> vbus as a bus model.  They compliment one another.
>>   =20
>=20
> Well, venet doesn't complement virtio-net, and virtio-pci doesn't
> complement vbus-connector.

Agreed, but virtio complements vbus by virtue of virtio-vbus.

>=20
>>>> Then device models like virtio can ride happily on top and we end up=

>>>> with a really robust and high-performance Linux-based stack.  I don'=
t
>>>> buy the argument that we already have PCI so lets use it.  I don't
>>>> think
>>>> its the best design and I am not afraid to make an investment in a
>>>> change here because I think it will pay off in the long run.
>>>>
>>>>       =20
>>> Sorry, I don't think you've shown any quantifiable advantages.
>>>     =20
>> We can agree to disagree then, eh?  There are certainly quantifiable
>> differences.  Waving your hand at the differences to say they are not
>> advantages is merely an opinion, one that is not shared universally.
>>   =20
>=20
> I've addressed them one by one.  We can agree to disagree on interrupt
> multiplexing, and the importance of compatibility, Windows, large
> guests, multiqueue, and DNS vs. PCI-SIG.
>=20
>> The bottom line is all of these design distinctions are encapsulated
>> within the vbus subsystem and do not affect the kvm code-base.  So
>> agreement with kvm upstream is not a requirement, but would be
>> advantageous for collaboration.
>>   =20
>=20
> Certainly.
>=20

Kind Regards,
-Greg


--------------enigAC1FF8A389B8626192A1013C
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqLm3kACgkQP5K2CMvXmqHH6gCeK399CwhcWA/m92SOiVlqZ7DW
kMYAn39+FKZhWrXfOe7zU4eG5sChIt8x
=gO8s
-----END PGP SIGNATURE-----

--------------enigAC1FF8A389B8626192A1013C--

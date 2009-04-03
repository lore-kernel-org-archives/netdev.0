From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 14:19:07 -0400
Message-ID: <49D6531B.9020708@novell.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <49D4F97F.6040507@novell.com> <49D5F669.1070502@redhat.com> <49D6240B.4080809@novell.com> <49D62D1C.9030704@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig992C8AC61C5CB6DBBF6DD9B7"
Cc: Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D62D1C.9030704@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig992C8AC61C5CB6DBBF6DD9B7
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>>> I'll rephrase.  What are the substantial benefits that this offers
>>> over PCI?
>>>    =20
>>
>> Simplicity and optimization.  You don't need most of the junk that com=
es
>> with PCI.  Its all overhead and artificial constraints.  You really on=
ly
>> need things like a handful of hypercall verbs and thats it.
>>
>>  =20
>
> Simplicity:
>
> The guest already supports PCI.  It has to, since it was written to
> the PC platform, and since today it is fashionable to run kernels that
> support both bare metal and a hypervisor.  So you can't remove PCI
> from the guest.

Agreed
>
> The host also already supports PCI.  It has to, since it must supports
> guests which do not support vbus.  We can't remove PCI from the host.

Agreed
>
> You don't gain simplicity by adding things.

But you are failing to account for the fact that we still have to add
something for PCI if we go with something like the in-kernel model.  Its
nice for the userspace side because a) it was already in qemu, and b) we
need it for proper guest support.  But we don't presumably have it for
this new thing, so something has to be created (unless this support is
somehow already there and I don't know it?)

>   Sure, lguest is simple because it doesn't support PCI.  But Linux
> will forever support PCI, and Qemu will always support PCI.  You
> aren't simplifying anything by adding vbus.
>
> Optimization:
>
> Most of PCI (in our context) deals with configuration.  So removing it
> doesn't optimize anything, unless you're counting hotplugs-per-second
> or something.

Most, but not all ;)  (Sorry, you left the window open on that one).

What about IRQ routing?  What if I want to coalesce interrupts to
minimize injection overhead?  How do I do that in PCI?

How do I route those interrupts in an arbitrarily nested fashion, say,
to a guest userspace?

What about scale?  What if Herbet decides to implement a 2048 ring MQ
device ;)  Theres no great way to do that in x86 with PCI, yet I can do
it in vbus.  (And yes, I know, this is ridiculous..just wanting to get
you thinking)

>
>
>>>> Second of all, I want to use vbus for other things that do not
>>>> speak PCI
>>>> natively (like userspace for instance...and if I am gleaning this
>>>> correctly, lguest doesnt either).
>>>>        =20
>>> And virtio supports lguest and s390.  virtio is not PCI specific.
>>>    =20
>> I understand that.  We keep getting wrapped around the axle on this
>> one.   At some point in the discussion we were talking about supportin=
g
>> the existing guest ABI without changing the guest at all.  So while I
>> totally understand the virtio can work over various transports, I am
>> referring to what would be needed to have existing ABI guests work wit=
h
>> an in-kernel version.  This may or may not be an actual requirement.
>>  =20
>
> There is be no problem supporting an in-kernel host virtio endpoint
> with the existing guest/host ABI.  Nothing in the ABI assumes the host
> endpoint is in userspace.  Nothing in the implementation requires us
> to move any of the PCI stuff into the kernel.
Well, thats not really true.  If the device is a PCI device, there is
*some* stuff that has to go into the kernel.  Not an ICH model or
anything, but at least an ability to interact with userspace for
config-space changes, etc.

>
> In fact, we already have in-kernel sources of PCI interrupts, these
> are assigned PCI devices (obviously, these have to use PCI).

This will help.

>
>>> However, for the PC platform, PCI has distinct advantages.  What
>>> advantages does vbus have for the PC platform?
>>>    =20
>> To reiterate: IMO simplicity and optimization.  Its designed
>> specifically for PV use, which is software to software.
>>  =20
>
> To avoid reiterating, please be specific about these advantages.
We are both reading the same thread, right?

>
>> =20
>>>> PCI sounds good at first, but I believe its a false economy.  It was=

>>>> designed, of course, to be a hardware solution, so it carries all th=
is
>>>> baggage derived from hardware constraints that simply do not exist
>>>> in a
>>>> pure software world and that have to be emulated.  Things like the
>>>> fixed
>>>> length and centrally managed PCI-IDs,      =20
>>> Not a problem in practice.
>>>    =20
>>
>> Perhaps, but its just one more constraint that isn't actually needed.
>> Its like the cvs vs git debate.  Why have it centrally managed when yo=
u
>> don't technically need it.  Sure, centrally managed works, but I'd
>> rather not deal with it if there was a better option.
>>  =20
>
> We've allocated 3 PCI device IDs so far.  It's not a problem.  There
> are enough real problems out there.
>
>> =20
>>>> PIO config cycles, BARs,
>>>> pci-irq-routing, etc.       =20
>>> What are the problems with these?
>>>    =20
>>
>> 1) PIOs are still less efficient to decode than a hypercall vector.  W=
e
>> dont need to pretend we are hardware..the guest already knows whats
>> underneath them.  Use the most efficient call method.
>>  =20
>
> Last time we measured, hypercall overhead was the same as pio
> overhead.  Both vmx and svm decode pio completely (except for string
> pio ...)
Not on my woodcrests last time I looked, but I'll check again.

>
>> 2) BARs?  No one in their right mind should use an MMIO BAR for PV. :)=

>> The last thing we want to do is cause page faults here.  Don't use the=
m,
>> period.  (This is where something like the vbus::shm() interface
>> comes in)
>>  =20
>
> So don't use BARs for your fast path.  virtio places the ring in guest
> memory (like most real NICs).
>
>> 3) pci-irq routing was designed to accommodate etch constraints on a
>> piece of silicon that doesn't actually exist in kvm.  Why would I want=

>> to pretend I have PCI A,B,C,D lines that route to a pin on an IOAPIC?
>> Forget all that stuff and just inject an IRQ directly.  This gets much=

>> better with MSI, I admit, but you hopefully catch my drift now.
>>  =20
>
> True, PCI interrupts suck.  But this was fixed with MSI.  Why fix it
> again?

As I stated, I don't like the constraints in place even by MSI (though
that is definately a step in the right direction).

 With vbus I can have a device that has an arbitrary number of shm
regions (limited by memory, of course), each with an arbitrarily routed
signal path that is limited by a u64, even on x86.  Each region can be
signaled bidirectionally and masked with a simple local memory write.=20
They can be declared on the fly, allowing for the easy expression of
things like nested devices or or other dynamic resources.  The can be
routed across various topologies, such as IRQs or posix signals, even
across multiple hops in a single path.

How do I do that in PCI?

What does masking an interrupt look like?  Again, for the nested case?

Interrupt acknowledgment cycles?

>
>> One of my primary design objectives with vbus was to a) reduce the
>> signaling as much as possible, and b) reduce the cost of signaling.=20
>> That is why I do things like use explicit hypercalls, aggregated
>> interrupts, bidir napi to mitigate signaling, the shm_signal::pending
>> mitigation, and avoiding going to userspace by running in the kernel.
>> All of these things together help to form what I envision would be a
>> maximum performance transport.  Not all of these tricks are
>> interdependent (for instance, the bidir + full-duplex threading that I=

>> do can be done in userspace too, as discussed).  They are just the
>> collective design elements that I think we need to make a guest perfor=
m
>> very close to its peak.  That is what I am after.
>>
>>  =20
>
> None of these require vbus.  They can all be done with PCI.
Well, first of all:  Not really.  Second of all, even if you *could* do
this all with PCI, its not really PCI anymore.  So the question I have
is: whats the value in still using it?  For the discovery?  Its not very
hard to do discovery.  I wrote that whole part in a few hours and it
worked the first time I ran it.

What about that interrupt model I keep talking about?  How do you work
around that?  How do I nest these to support bypass?

>
>> You are right, its not strictly necessary to work.  Its just presents
>> the opportunity to optimize as much as possible and to move away from
>> legacy constraints that no longer apply.  And since PVs sole purpose i=
s
>> about optimization, I was not really interested in going "half-way".
>>  =20
>
> What constraints?  Please be specific.

Avi, I have been.  Is this an exercise to see how much you can get me to
type? ;)

>
>>>   We need a positive advantage, we don't do things just because we ca=
n
>>> (and then lose the real advantages PCI has).
>>>    =20
>>
>> Agreed, but I assert there are advantages.  You may not think they
>> outweigh the cost, and thats your prerogative, but I think they are
>> still there nonetheless.
>>  =20
>
> I'm not saying anything about what the advantages are worth and how
> they compare to the cost.  I'm asking what are the advantages.  Please
> don't just assert them into existence.

Thats an unfair statement, Avi.  Now I would say you are playing word-gam=
es.

>
>>>> If we insist that PCI is the only interface we can support and we wa=
nt
>>>> to do something, say, in the kernel for instance, we have to have
>>>> either
>>>> something like the ICH model in the kernel (and really all of the pc=
i
>>>> chipset models that qemu supports), or a hacky hybrid userspace/kern=
el
>>>> solution.  I think this is what you are advocating, but im sorry. IM=
O
>>>> that's just gross and unecessary gunk.       =20
>>> If we go for a kernel solution, a hybrid solution is the best IMO.  I=

>>> have no idea what's wrong with it.
>>>    =20
>>
>> Its just that rendering these objects as PCI is overhead that you don'=
t
>> technically need.  You only want this backwards compat because you don=
't
>> want to require a new bus-driver in the guest, which is a perfectly
>> reasonable position to take.  But that doesn't mean it isn't a
>> compromise.  You are trading more complexity and overhead in the host
>> for simplicity in the guest.  I am trying to clean up this path for
>> looking forward.
>>  =20
>
> All of this overhead is incurred at configuration time.  All the
> complexity already exists

So you already have the ability to represent PCI devices that are in the
kernel?  Is this the device-assignment infrastructure?  Cool!  Wouldn't
this still need to be adapted to work with software devices?  If not,
then I take back the statements that they both add more host code and
agree that vbus is simply the one adding more.


> so we gain nothing by adding a competing implementation.  And making
> the guest complex in order to simplify the host is a pretty bad
> tradeoff considering we maintain one host but want to support many
> guests.
>
> It's good to look forward, but in the vbus-dominated universe, what do
> we have that we don't have now?  Besides simplicity.

A unified framework for declaring virtual resources directly in the
kernel, yet still retaining the natural isolation that we get in
userspace.  The ability to support guests that don't have PCI.  The
ability to support things that are not guests.  The ability to support
things that are not supported by PCI, like less hardware-centric signal
path routing.  The ability to signal across more than just IRQs.  The
ability for nesting (e.g. guest-userspace talking to host-kernel, etc).=20

I recognize that this has no bearing on whether you, or anyone else
cares about these features.  But it certainly has features beyond what
he have with PCI, and I hope that is clear now.


>
>>> The guest would discover and configure the device using normal PCI
>>> methods.  Qemu emulates the requests, and configures the kernel part
>>> using normal Linux syscalls.  The nice thing is, kvm and the kernel
>>> part don't even know about each other, except for a way for hypercall=
s
>>> to reach the device and a way for interrupts to reach kvm.
>>>
>>>   =20
>>>> Lets stop beating around the
>>>> bush and just define the 4-5 hypercall verbs we need and be done wit=
h
>>>> it.  :)
>>>>
>>>> FYI: The guest support for this is not really *that* much code IMO.
>>>> =20
>>>>  drivers/vbus/proxy/Makefile      |    2
>>>>  drivers/vbus/proxy/kvm.c         |  726 +++++++++++++++++
>>>>        =20
>>> Does it support device hotplug and hotunplug?
>>>    =20
>> Yes, today (use "ln -s" in configfs to map a device to a bus, and the
>> guest will see the device immediately)
>>  =20
>
> Neat.
>
>> =20
>>>   Can vbus interrupts be load balanced by irqbalance?
>>>    =20
>>
>> Yes (tho support for the .affinity verb on the guests irq-chip is
>> currently missing...but the backend support is there)
>>
>>
>> =20
>>>   Can guest userspace enumerate devices?
>>>    =20
>>
>> Yes, it presents as a standard LDM device in things like
>> /sys/bus/vbus_proxy
>>
>> =20
>>>   Module autoloading support?
>>>    =20
>>
>> Yes
>>
>>  =20
>
> Cool, looks like you have a nice part covered.
>
>>>   pxe booting?
>>>    =20
>> No, but this is something I don't think we need for now.  If it was
>> really needed it could be added, I suppose.  But there are other
>> alternatives already, so I am not putting this high on the priority
>> list.  (For instance you can chose to not use vbus, or you can use
>> --kernel, etc).
>>
>> =20
>>> Plus a port to Windows,
>>>    =20
>>
>> Ive already said this is low on my list, but it could always be added =
if
>> someone cares that much
>>  =20
>
> That's unreasonable.  Windows is an important workload.

Well, this is all GPL, right.  I mean, was KVM 100% complete when it was
proposed?  Accepted?  I am hoping to get some help building the parts of
this infrastructure from anyone interested in the community.  If Windows
support is truly important and someone cares, it will get built soon enou=
gh.

I pushed it out now because I have enough working to be useful in of
itself and to get a review.  But its certainly not done.

>
>> =20
>>> enerprise Linux distros based on 2.6.dead
>>>    =20
>>
>> Thats easy, though there is nothing that says we need to.  This can be=
 a
>> 2.6.31ish thing that they pick up next time.
>>  =20
>
> Of course we need to.  RHEL 4/5 and their equivalents will live for a
> long time as guests.  Customers will expect good performance.

Okay, easy enough from my perspective.  However, I didn't realize it was
very common to backport new features to enterprise distros like this.  I
have a sneaking suspicion we wouldn't really need to worry about this as
the project managers for those products would probably never allow it.=20
But in the event that it was necessary, I think it wouldn't be horrendous=
=2E


>
>
>>> As a matter of fact, a new bus was developed recently called PCI
>>> express.  It uses new slots, new electricals, it's not even a bus
>>> (routers + point-to-point links), new everything except that the
>>> software model was 1000000000000% compatible with traditional PCI.
>>> That's how much people are afraid of the Windows ABI.
>>>    =20
>>
>> Come on, Avi.  Now you are being silly.  So should the USB designers
>> have tried to make it look like PCI too?  Should the PCI designers hav=
e
>> tried to make it look like ISA?  :)  Yes, there are advantages to maki=
ng
>> something backwards compatible.  There are also disadvantages to
>> maintaining that backwards compatibility.
>>  =20
>
> Most PCI chipsets include an ISA bridge, at least until recently.

You don't give up, do you? :P


>
>> Let me ask you this:  If you had a clean slate and were designing a
>> hypervisor and a guest OS from scratch:  What would you make the bus
>> look like?
>>  =20
>
> If there were no installed base to cater for, the avi-bus would blow
> anything out of the water.  It would be so shiny and new to make you
> cry in envy.  It would strongly compete with lguest and steal its two
> users.
>
> Back on earth, there are a hundred gazillion machines with good old
> x86, booting through 1978 era real mode, jumping over the 640K memory
> barrier (est. 1981), running BIOS code which was probably written in
> the 14th century, and sporting a PCI-compatible peripheral bus.

Im ok with that, as none of them will have VMX :P

>
> This is not an academic exercise, we're not trying to develop the most
> aesthetically pleasing stack.  We need to be pragmatic so we can
> provide users with real value, not provide outselves with software
> design entertainment (nominally called wanking on lkml, but kvm@ is a
> kinder, gentler list).
>
>>> virtio-net knows nothing about PCI.  If you have a problem with PCI,
>>> write virtio-blah for a new bus.
>>>    =20
>> Can virtio-net use a different backend other than virtio-pci?  Cool!  =
I
>> will look into that.  Perhaps that is what I need to make this work
>> smoothly.
>>  =20
>
> virtio-net (all virtio devices, actually) supports three platforms
> today.  PCI, lguest, and s390.
Cool.  I bet I can just write a virtio-vbus adapter then.  Rusty, any
thoughts?

>
>>> I think you're integrating too tightly with kvm, which is likely to
>>> cause problems when kvm evolves.  The way I'd do it is:
>>>
>>> - drop all mmu integration; instead, have your devices maintain their=

>>> own slots layout and use copy_to_user()/copy_from_user() (or
>>> get_user_pages_fast()).
>>>    =20
>>
>> =20
>>> - never use vmap like structures for more than the length of a reques=
t
>>>    =20
>>
>> So does virtio also do demand loading in the backend? =20
>
> Given that it's entirely in userspace, yes.

Ah, right.  How does that work our of curiosity?  Do you have to do a
syscall for every page you want to read?

>
>> Hmm.  I suppose
>> we could do this, but it will definitely affect the performance
>> somewhat.  I was thinking that the pages needed for the basic shm
>> components should be minimal, so this is a good tradeoff to vmap them =
in
>> and only demand load the payload.
>>  =20
>
> This is negotiable :) I won't insist on it, only strongly recommend
> it.  copy_to_user() should be pretty fast.

It probably is, but generally we cant use it since we are not in the
same context when we need to do the copy (copy_to/from_user assume
"current" is proper).  Thats ok, there are ways to do what you request
without explicitly using c_t_u().


>
>
>>> I think virtio can be used for much of the same things.  There's
>>> nothing in virtio that implies guest/host, or pci, or anything else.
>>> It's similar to your shm/signal and ring abstractions except virtio
>>> folds them together.  Is this folding the main problem?
>>>    =20
>> Right.  Virtio and ioq overlap, and they do so primarily because I
>> needed a ring that was compatible with some of my design ideas, yet I
>> didnt want to break the virtio ABI without a blessing first.  If the
>> signaling was not folded in virtio, that would be a first great step. =
 I
>> am not sure if there would be other areas to address as well.
>>  =20
>
> It would be good to find out.  virtio has evolved in time, mostly
> keeping backwards compatibility, so if you need a feature, it could be
> added.
>
>>> As far as I can tell, everything around it just duplicates existing
>>> infrastructure (which may be old and crusty, but so what) without
>>> added value.
>>>    =20
>>
>> I am not sure what you refer to with "everything around it".  Are you
>> talking about the vbus core?  =20
>
> I'm talking about enumeration, hotplug, interrupt routing, all that
> PCI slowpath stuff.  My feeling is the fast path is mostly virtio
> except for being in kernel, and the slow path is totally redundant.

Ok, but note that I think you are still confusing the front-end and
back-end here.  See my last email for clarification.

-Greg

>
>



--------------enig992C8AC61C5CB6DBBF6DD9B7
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknWUxwACgkQlOSOBdgZUxnUmQCfRn/fxZmIvqwKLQqgJ+WSv8CP
iSAAmwVMtoDz0XqQ7UzmK2c6q7t7hhhr
=zxge
-----END PGP SIGNATURE-----

--------------enig992C8AC61C5CB6DBBF6DD9B7--

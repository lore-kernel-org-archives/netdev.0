From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 10:58:19 -0400
Message-ID: <49D6240B.4080809@novell.com>
References: <49D469D2020000A100045FA1@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D473EA020000C700056627@lucius.provo.novell.com> <49D4CB38.5030205@redhat.com> <49D4DA54.3090401@novell.com> <49D4DE82.5020306@redhat.com> <49D4F97F.6040507@novell.com> <49D5F669.1070502@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig2BDE90BE87158EAB66358614"
Cc: Patrick Mullaney <pmullaney@novell.com>, anthony@codemonkey.ws,
	andi@firstfloor.org, herbert@gondor.apana.org.au,
	Peter Morreale <PMorreale@novell.com>, rusty@rustcorp.com.au,
	agraf@suse.de, kvm@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <49D5F669.1070502@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig2BDE90BE87158EAB66358614
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Hi Avi,

 I think we have since covered these topics later in the thread, but in
case you wanted to know my thoughts here:

Avi Kivity wrote:
> Gregory Haskins wrote:
>>>> Yes, but the important thing to point out is it doesn't *replace*
>>>> PCI. It simply an alternative.
>>>>        =20
>>> Does it offer substantial benefits over PCI?  If not, it's just extra=

>>> code.
>>>    =20
>>
>> First of all, do you think I would spend time designing it if I didn't=

>> think so? :)
>>  =20
>
> I'll rephrase.  What are the substantial benefits that this offers
> over PCI?

Simplicity and optimization.  You don't need most of the junk that comes
with PCI.  Its all overhead and artificial constraints.  You really only
need things like a handful of hypercall verbs and thats it.

>
>> Second of all, I want to use vbus for other things that do not speak P=
CI
>> natively (like userspace for instance...and if I am gleaning this
>> correctly, lguest doesnt either).
>>  =20
>
> And virtio supports lguest and s390.  virtio is not PCI specific.
I understand that.  We keep getting wrapped around the axle on this
one.   At some point in the discussion we were talking about supporting
the existing guest ABI without changing the guest at all.  So while I
totally understand the virtio can work over various transports, I am
referring to what would be needed to have existing ABI guests work with
an in-kernel version.  This may or may not be an actual requirement.

>
> However, for the PC platform, PCI has distinct advantages.  What
> advantages does vbus have for the PC platform?
To reiterate: IMO simplicity and optimization.  Its designed
specifically for PV use, which is software to software.

>
>> PCI sounds good at first, but I believe its a false economy.  It was
>> designed, of course, to be a hardware solution, so it carries all this=

>> baggage derived from hardware constraints that simply do not exist in =
a
>> pure software world and that have to be emulated.  Things like the fix=
ed
>> length and centrally managed PCI-IDs,=20
>
> Not a problem in practice.

Perhaps, but its just one more constraint that isn't actually needed.=20
Its like the cvs vs git debate.  Why have it centrally managed when you
don't technically need it.  Sure, centrally managed works, but I'd
rather not deal with it if there was a better option.

>
>> PIO config cycles, BARs,
>> pci-irq-routing, etc. =20
>
> What are the problems with these?

1) PIOs are still less efficient to decode than a hypercall vector.  We
dont need to pretend we are hardware..the guest already knows whats
underneath them.  Use the most efficient call method.

2) BARs?  No one in their right mind should use an MMIO BAR for PV. :)
The last thing we want to do is cause page faults here.  Don't use them,
period.  (This is where something like the vbus::shm() interface comes in=
)

3) pci-irq routing was designed to accommodate etch constraints on a
piece of silicon that doesn't actually exist in kvm.  Why would I want
to pretend I have PCI A,B,C,D lines that route to a pin on an IOAPIC?=20
Forget all that stuff and just inject an IRQ directly.  This gets much
better with MSI, I admit, but you hopefully catch my drift now.

One of my primary design objectives with vbus was to a) reduce the
signaling as much as possible, and b) reduce the cost of signaling. =20
That is why I do things like use explicit hypercalls, aggregated
interrupts, bidir napi to mitigate signaling, the shm_signal::pending
mitigation, and avoiding going to userspace by running in the kernel.=20
All of these things together help to form what I envision would be a
maximum performance transport.  Not all of these tricks are
interdependent (for instance, the bidir + full-duplex threading that I
do can be done in userspace too, as discussed).  They are just the
collective design elements that I think we need to make a guest perform
very close to its peak.  That is what I am after.

>
>> While emulation of PCI is invaluable for
>> executing unmodified guest, its not strictly necessary from a
>> paravirtual software perspective...PV software is inherently already
>> aware of its context and can therefore use the best mechanism
>> appropriate from a broader selection of choices.
>>  =20
>
> It's also not necessary to invent a new bus.
You are right, its not strictly necessary to work.  Its just presents
the opportunity to optimize as much as possible and to move away from
legacy constraints that no longer apply.  And since PVs sole purpose is
about optimization, I was not really interested in going "half-way".

>   We need a positive advantage, we don't do things just because we can
> (and then lose the real advantages PCI has).

Agreed, but I assert there are advantages.  You may not think they
outweigh the cost, and thats your prerogative, but I think they are
still there nonetheless.

>
>> If we insist that PCI is the only interface we can support and we want=

>> to do something, say, in the kernel for instance, we have to have eith=
er
>> something like the ICH model in the kernel (and really all of the pci
>> chipset models that qemu supports), or a hacky hybrid userspace/kernel=

>> solution.  I think this is what you are advocating, but im sorry. IMO
>> that's just gross and unecessary gunk. =20
>
> If we go for a kernel solution, a hybrid solution is the best IMO.  I
> have no idea what's wrong with it.

Its just that rendering these objects as PCI is overhead that you don't
technically need.  You only want this backwards compat because you don't
want to require a new bus-driver in the guest, which is a perfectly
reasonable position to take.  But that doesn't mean it isn't a
compromise.  You are trading more complexity and overhead in the host
for simplicity in the guest.  I am trying to clean up this path for
looking forward.

>
> The guest would discover and configure the device using normal PCI
> methods.  Qemu emulates the requests, and configures the kernel part
> using normal Linux syscalls.  The nice thing is, kvm and the kernel
> part don't even know about each other, except for a way for hypercalls
> to reach the device and a way for interrupts to reach kvm.
>
>> Lets stop beating around the
>> bush and just define the 4-5 hypercall verbs we need and be done with
>> it.  :)
>>
>> FYI: The guest support for this is not really *that* much code IMO.
>> =20
>>  drivers/vbus/proxy/Makefile      |    2
>>  drivers/vbus/proxy/kvm.c         |  726 +++++++++++++++++
>>  =20
>
> Does it support device hotplug and hotunplug?
Yes, today (use "ln -s" in configfs to map a device to a bus, and the
guest will see the device immediately)

>   Can vbus interrupts be load balanced by irqbalance?

Yes (tho support for the .affinity verb on the guests irq-chip is
currently missing...but the backend support is there)


>   Can guest userspace enumerate devices?

Yes, it presents as a standard LDM device in things like /sys/bus/vbus_pr=
oxy

>   Module autoloading support?

Yes

>   pxe booting?
No, but this is something I don't think we need for now.  If it was
really needed it could be added, I suppose.  But there are other
alternatives already, so I am not putting this high on the priority
list.  (For instance you can chose to not use vbus, or you can use
--kernel, etc).

>
>
> Plus a port to Windows,

Ive already said this is low on my list, but it could always be added if
someone cares that much

> enerprise Linux distros based on 2.6.dead

Thats easy, though there is nothing that says we need to.  This can be a
2.6.31ish thing that they pick up next time.


> , and possibly less mainstream OSes.
>
>> and plus, I'll gladly maintain it :)
>>
>> I mean, its not like new buses do not get defined from time to time.
>> Should the computing industry stop coming up with new bus types becaus=
e
>> they are afraid that the windows ABI only speaks PCI?  No, they just
>> develop a new driver for whatever the bus is and be done with it.  Thi=
s
>> is really no different.
>>  =20
>
> As a matter of fact, a new bus was developed recently called PCI
> express.  It uses new slots, new electricals, it's not even a bus
> (routers + point-to-point links), new everything except that the
> software model was 1000000000000% compatible with traditional PCI.=20
> That's how much people are afraid of the Windows ABI.

Come on, Avi.  Now you are being silly.  So should the USB designers
have tried to make it look like PCI too?  Should the PCI designers have
tried to make it look like ISA?  :)  Yes, there are advantages to making
something backwards compatible.  There are also disadvantages to
maintaining that backwards compatibility.

Let me ask you this:  If you had a clean slate and were designing a
hypervisor and a guest OS from scratch:  What would you make the bus
look like?

>
>>> Note that virtio is not tied to PCI, so "vbus is generic" doesn't
>>> count.
>>>    =20
>> Well, preserving the existing virtio-net on x86 ABI is tied to PCI,
>> which is what I was referring to.  Sorry for the confusion.
>>  =20
>
> virtio-net knows nothing about PCI.  If you have a problem with PCI,
> write virtio-blah for a new bus.
Can virtio-net use a different backend other than virtio-pci?  Cool!  I
will look into that.  Perhaps that is what I need to make this work
smoothly.


>   Though I still don't understand why.
>
> =20
>
>>> I meant, move the development effort, testing, installed base, Window=
s
>>> drivers.
>>>    =20
>>
>> Again, I will maintain this feature, and its completely off to the
>> side.  Turn it off in the config, or do not enable it in qemu and its
>> like it never existed.  Worst case is it gets reverted if you don't li=
ke
>> it.  Aside from the last few kvm specific patches, the rest is no
>> different than the greater linux environment.  E.g. if I update the
>> venet driver upstream, its conceptually no different than someone else=

>> updating e1000, right?
>>  =20
>
> I have no objections to you maintaining vbus, though I'd much prefer
> if we can pool our efforts and cooperate on having one good set of
> drivers.

I agree, that would be ideal.

>
> I think you're integrating too tightly with kvm, which is likely to
> cause problems when kvm evolves.  The way I'd do it is:
>
> - drop all mmu integration; instead, have your devices maintain their
> own slots layout and use copy_to_user()/copy_from_user() (or
> get_user_pages_fast()).

> - never use vmap like structures for more than the length of a request

So does virtio also do demand loading in the backend?  Hmm.  I suppose
we could do this, but it will definitely affect the performance
somewhat.  I was thinking that the pages needed for the basic shm
components should be minimal, so this is a good tradeoff to vmap them in
and only demand load the payload.

> - for hypercalls, add kvm_register_hypercall_handler()

This is a good idea.  In fact, I had something like this in my series
back when I posted it as "PV-IO" a year and a half ago.  I am not sure
why I took it out, but I will put it back.

> - for interrupts, see the interrupt routing thingie and have an
> in-kernel version of the KVM_IRQ_LINE ioctl.

Will do.

>
> This way, the parts that go into kvm know nothing about vbus, you're
> not pinning any memory, and the integration bits can be used for other
> purposes.
>
> =20
>
>>> So why add something new?
>>>    =20
>>
>> I was hoping this was becoming clear by now, but apparently I am doing=
 a
>> poor job of articulating things. :(  I think we got bogged down in the=

>> 802.x performance discussion and lost sight of what we are trying to
>> accomplish with the core infrastructure.
>>
>> So this core vbus infrastructure is for generic, in-kernel IO models.
>> As a first pass, we have implemented a kvm-connector, which lets kvm
>> guest kernels have access to the bus.  We also have a userspace
>> connector (which I haven't pushed yet due to remaining issues being
>> ironed out) which allows userspace applications to interact with the
>> devices as well.  As a prototype, we built "venet" to show how it all
>> works.
>>
>> In the future, we want to use this infrastructure to build IO models f=
or
>> various things like high performance fabrics and guest bypass
>> technologies, etc.  For instance, guest userspace connections to RDMA
>> devices in the kernel, etc.
>>  =20
>
> I think virtio can be used for much of the same things.  There's
> nothing in virtio that implies guest/host, or pci, or anything else.=20
> It's similar to your shm/signal and ring abstractions except virtio
> folds them together.  Is this folding the main problem?
Right.  Virtio and ioq overlap, and they do so primarily because I
needed a ring that was compatible with some of my design ideas, yet I
didnt want to break the virtio ABI without a blessing first.  If the
signaling was not folded in virtio, that would be a first great step.  I
am not sure if there would be other areas to address as well.

>
> As far as I can tell, everything around it just duplicates existing
> infrastructure (which may be old and crusty, but so what) without
> added value.

I am not sure what you refer to with "everything around it".  Are you
talking about the vbus core?=20

>
>>>
>>> I don't want to develop and support both virtio and vbus.  And I
>>> certainly don't want to depend on your customers.
>>>    =20
>>
>> So don't.  Ill maintain the drivers and the infrastructure.  All we ar=
e
>> talking here is the possible acceptance of my kvm-connector patches
>> *after* the broader LKML community accepts the core infrastructure,
>> assuming that happens.
>>  =20
>
> As I mentioned above, I'd much rather we cooperate rather than
> fragment the development effort (and user base).
Me too.  I think we can get to that point if I make some of the changes
you suggested above.

Thanks Avi,
-Greg



--------------enig2BDE90BE87158EAB66358614
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknWJAsACgkQlOSOBdgZUxmSkACdHZFRNTu7iaXmEaseSMu/Irzu
1uwAn1v5qMmmPOb7/PrwM6DVaWK6nWvT
=hsiY
-----END PGP SIGNATURE-----

--------------enig2BDE90BE87158EAB66358614--

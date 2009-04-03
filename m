From: Gregory Haskins <ghaskins@novell.com>
Subject: Re: [RFC PATCH 00/17] virtual-bus
Date: Fri, 03 Apr 2009 12:28:15 -0400
Message-ID: <49D6391F.8010408@novell.com>
References: <20090331184057.28333.77287.stgit@dev.haskins.net> <87ab71monw.fsf@basil.nowhere.org> <49D35825.3050001@novell.com> <20090401132340.GT11935@one.firstfloor.org> <49D37805.1060301@novell.com> <20090401170103.GU11935@one.firstfloor.org> <49D3B64F.6070703@codemonkey.ws> <49D3D7EE.4080202@novell.com> <49D46089.5040204@redhat.com> <49D497A1.4090900@novell.com> <49D4A4EB.8020105@redhat.com> <49D4AE0C.3000604@novell.com> <49D4B2C0.5060906@redhat.com> <49D4B594.6080703@novell.com> <49D4B8B4.4020003@redhat.com> <49D4BF70.1060301@novell.com> <49D4C191.2070502@redhat.com> <49D4CAA7.3020004@novell.com> <49D4CC61.6010105@redhat.com> <49D4CEB1.9020001@redhat.com> <49D4D075.9010702@codemonkey.ws> <49D4E33F.5000303@codemonkey.ws> <49D5FAFD.1010102@novell.com> <49D5FDF9.7090602@redhat.com> <49D6
 0B91.6010503@novell.com> <49D61100.5010202@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig7BFA96E329C8491632F27B63"
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	agraf@suse.de, pmullaney@novell.com, pmorreale@novell.com,
	rusty@rustcorp.com.au, netdev@vger.kernel.org, kvm@vger.kernel.org
To: Avi Kivity <avi@redhat.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S936019AbZDCQ03@vger.kernel.org>
In-Reply-To: <49D61100.5010202@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig7BFA96E329C8491632F27B63
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> Gregory Haskins wrote:
>> Avi Kivity wrote:
>> =20
>>> Gregory Haskins wrote:
>>>   =20
>>>> So again, I am proposing for consideration of accepting my work
>>>> (either
>>>> in its current form, or something we agree on after the normal revie=
w
>>>> process) not only on the basis of the future development of the
>>>> platform, but also to keep current components in their running to
>>>> their
>>>> full potential.  I will again point out that the code is almost
>>>> completely off to the side, can be completely disabled with config
>>>> options, and I will maintain it.  Therefore the only real impact is =
to
>>>> people who care to even try it, and to me.
>>>>        =20
>>> Your work is a whole stack.  Let's look at the constituents.
>>>
>>> - a new virtual bus for enumerating devices.
>>>
>>> Sorry, I still don't see the point.  It will just make writing driver=
s
>>> more difficult.  The only advantage I've heard from you is that it
>>> gets rid of the gunk.  Well, we still have to support the gunk for
>>> non-pv devices so the gunk is basically free.  The clean version is
>>> expensive since we need to port it to all guests and implement
>>> exciting features like hotplug.
>>>    =20
>> My real objection to PCI is fast-path related.  I don't object, per se=
,
>> to using PCI for discovery and hotplug.  If you use PCI just for these=

>> types of things, but then allow fastpath to use more hypercall oriente=
d
>> primitives, then I would agree with you.  We can leave PCI emulation i=
n
>> user-space, and we get it for free, and things are relatively tidy.
>>  =20
>
> PCI has very little to do with the fast path (nothing, if we use MSI).

At the very least, PIOs are slightly slower than hypercalls.  Perhaps
not enough to care, but the last time I measured them they were slower,
and therefore my clean slate design doesn't use them.

But I digress.  I think I was actually kind of agreeing with you that we
could do this. :P

>
>> Its once you start requiring that we stay ABI compatible with somethin=
g
>> like the existing virtio-net in x86 KVM where I think it starts to get=

>> ugly when you try to move it into the kernel.  So that is what I had a=

>> real objection to.  I think as long as we are not talking about trying=

>> to make something like that work, its a much more viable prospect.
>>  =20
>
> I don't see why the fast path of virtio-net would be bad.  Can you
> elaborate?

Im not.  I am saying I think we might be able to do this.

>
> Obviously all the pci glue stays in userspace.
>
>> So what I propose is the following:
>> 1) The core vbus design stays the same (or close to it)
>>  =20
>
> Sorry, I still don't see what advantage this has over PCI, and how you
> deal with the disadvantages.

I think you are confusing the vbus-proxy (guest side) with the vbus
backend.  (1) is saying "keep the vbus backend'" and (2) is saying drop
the guest side stuff.  In this proposal, the guest would speak a PCI ABI
as far as its concerned.  Devices in the vbus backend would render as
PCI objects in the ICH (or whatever) model in userspace.

>
>> 2) the vbus-proxy and kvm-guest patch go away
>> 3) the kvm-host patch changes to work with coordination from the
>> userspace-pci emulation for things like MSI routing
>> 4) qemu will know to create some MSI shim 1:1 with whatever it
>> instantiates on the bus (and can communicate changes
>>  =20
>
> Don't userstand.  What's this MSI shim?

Well, if the device model was an object in vbus down in the kernel, yet
PCI emulation was up in qemu, presumably we would want something to
handle things like PCI config-cycles up in userspace.  Like, for
instance, if the guest re-routes the MSI.  The shim/proxy would handle
the config-cycle, and then turn around and do an ioctl to the kernel to
configure the change with the in-kernel device model (or the irq
infrastructure, as required).

But, TBH, I haven't really looked into whats actually required to make
this work yet.  I am just spitballing to try to find a compromise.

>
>> 5) any drivers that are written for these new PCI-IDs that might be
>> present are allowed to use a hypercall ABI to talk after they have bee=
n
>> probed for that ID (e.g. they are not limited to PIO or MMIO BAR type
>> access methods).
>>  =20
>
> The way we'd to it with virtio is to add a feature bit that say "you
> can hypercall here instead of pio".  This way old drivers continue to
> work.

Yep, agreed.  This is what I was thinking we could do.  But now that I
have the possibility that I just need to write a virtio-vbus module to
co-exist with virtio-pci, perhaps it doesn't even need to be explicit.

>
> Note that nothing prevents us from trapping pio in the kernel (in
> fact, we do) and forwarding it to the device.  It shouldn't be any
> slower than hypercalls.
Sure, its just slightly slower, so I would prefer pure hypercalls if at
all possible.

>
>> Once I get here, I might have greater clarity to see how hard it would=

>> make to emulate fast path components as well.  It might be easier than=
 I
>> think.
>>
>> This is all off the cuff so it might need some fine tuning before its
>> actually workable.
>>
>> Does that sound reasonable?
>>  =20
>
> The vbus part (I assume you mean device enumeration) worries me

No, you are confusing the front-end and back-end again ;)

The back-end remains, and holds the device models as before.  This is
the "vbus core".  Today the front-end interacts with the hypervisor to
render "vbus" specific devices.  The proposal is to eliminate the
front-end, and have the back end render the objects on the bus as PCI
devices to the guest.  I am not sure if I can make it work, yet.  It
needs more thought.

> .  I don't think you've yet set down what its advantages are.  Being
> pure and clean doesn't count, unless you rip out PCI from all existing
> installed hardware and from Windows.

You are being overly dramatic.  No one has ever said we are talking
about ripping something out.  In fact, I've explicitly stated that PCI
can coexist peacefully.    Having more than one bus in a system is
certainly not without precedent (PCI, scsi, usb, etc).

Rather, PCI is PCI, and will always be.  PCI was designed as a
software-to-hardware interface.  It works well for its intention.  When
we do full emulation of guests, we still do PCI so that all that
software that was designed to work software-to-hardware still continue
to work, even though technically its now software-to-software.  When we
do PV, on the other hand, we no longer need to pretend it is
software-to-hardware.  We can continue to use an interface designed for
software-to-hardware if we choose, or we can use something else such as
an interface designed specifically for software-to-software.

As I have stated, PCI was designed with hardware constraints in mind.=20
What if I don't want to be governed by those constraints?  What if I
don't want an interrupt per device (I don't)?   What do I need BARs for
(I don't)?  Is a PCI PIO address relevant to me (no, hypercalls are more
direct)?  Etc.  Its crap I dont need.

All I really need is a way to a) discover and enumerate devices,
preferably dynamically (hotswap), and b) a way to communicate with those
devices.  I think you are overstating the the importance that PCI plays
in (a), and are overstating the complexity associated with doing an
alternative.  I think you are understating the level of hackiness
required to continue to support PCI as we move to new paradigms, like
in-kernel models.  And I think I have already stated that I can
establish a higher degree of flexibility, and arguably, performance for
(b).  Therefore, I have come to the conclusion that I don't want it and
thus eradicated the dependence on it in my design.  I understand the
design tradeoffs that are associated with that decision.

>
>>> - finer-grained point-to-point communication abstractions
>>>
>>> Where virtio has ring+signalling together, you layer the two.  For
>>> networking, it doesn't matter.  For other applications, it may be
>>> helpful, perhaps you have something in mind.
>>>    =20
>>
>> Yeah, actually.  Thanks for bringing that up.
>>
>> So the reason why signaling and the ring are distinct constructs in th=
e
>> design is to facilitate constructs other than rings.  For instance,
>> there may be some models where having a flat shared page is better tha=
n
>> a ring.  A ring will naturally preserve all values in flight, where as=
 a
>> flat shared page would not (last update is always current).  There are=

>> some algorithms where a previously posted value is obsoleted by an
>> update, and therefore rings are inherently bad for this update model.
>> And as we know, there are plenty of algorithms where a ring works
>> perfectly.  So I wanted that flexibility to be able to express both.
>>  =20
>
> I agree that there is significant potential here.
>
>> One of the things I have in mind for the flat page model is that RT vc=
pu
>> priority thing.  Another thing I am thinking of is coming up with a PV=

>> LAPIC type replacement (where we can avoid doing the EOI trap by havin=
g
>> the PICs state shared).
>>  =20
>
> You keep falling into the paravirtualize the entire universe trap.  If
> you look deep down, you can see Jeremy struggling in there trying to
> bring dom0 support to Linux/Xen.
>
> The lapic is a huge ball of gunk but ripping it out is a monumental
> job with no substantial benefits.  We can at much lower effort avoid
> the EOI trap by paravirtualizing that small bit of ugliness.  Sure the
> result isn't a pure and clean room implementation.  It's a band aid.=20
> But I'll take a 50-line band aid over a 3000-line implementation split
> across guest and host, which only works with Linux.
Well, keep in mind that I was really just giving you an example of
something that might want a shared-page instead of a shared-ring model.=20
The possibility that such a device may be desirable in the future was
enough for me to decide that I wanted the shm model to be flexible,
instead of, say, designed specifically for virtio.  We may never, in
fact, do anything with the LAPIC idea.

-Greg

>
>



--------------enig7BFA96E329C8491632F27B63
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.9 (GNU/Linux)
Comment: Using GnuPG with SUSE - http://enigmail.mozdev.org

iEYEARECAAYFAknWOR8ACgkQlOSOBdgZUxm14gCbBcf0J5bp2CaCkfYseJTzLBXA
q40An2jtUHPmPlCiTL3iYxaPB3/kRARe
=oLV2
-----END PGP SIGNATURE-----

--------------enig7BFA96E329C8491632F27B63--

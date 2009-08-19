From: Gregory Haskins <gregory.haskins@gmail.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 14:26:27 -0400
Message-ID: <4A8C43D3.7030002@gmail.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig8654F3DC7403146F427624B6"
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Patrick Mullaney <pmullaney@novell.com>
To: Avi Kivity <avi@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8BA5AE.3030308@redhat.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig8654F3DC7403146F427624B6
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

Avi Kivity wrote:
> On 08/19/2009 09:28 AM, Gregory Haskins wrote:
>> Avi Kivity wrote:
>>  =20
>>> On 08/18/2009 05:46 PM, Gregory Haskins wrote:
>>>    =20
>>>>      =20
>>>>> Can you explain how vbus achieves RDMA?
>>>>>
>>>>> I also don't see the connection to real time guests.
>>>>>
>>>>>         =20
>>>> Both of these are still in development.  Trying to stay true to the
>>>> "release early and often" mantra, the core vbus technology is being
>>>> pushed now so it can be reviewed.  Stay tuned for these other
>>>> developments.
>>>>
>>>>       =20
>>> Hopefully you can outline how it works.  AFAICT, RDMA and kernel bypa=
ss
>>> will need device assignment.  If you're bypassing the call into the h=
ost
>>> kernel, it doesn't really matter how that call is made, does it?
>>>     =20
>> This is for things like the setup of queue-pairs, and the transport of=

>> door-bells, and ib-verbs.  I am not on the team doing that work, so I =
am
>> not an expert in this area.  What I do know is having a flexible and
>> low-latency signal-path was deemed a key requirement.
>>   =20
>=20
> That's not a full bypass, then.  AFAIK kernel bypass has userspace
> talking directly to the device.

Like I said, I am not an expert on the details here.  I only work on the
vbus plumbing.  FWIW, the work is derivative from the "Xen-IB" project

http://www.openib.org/archives/nov2006sc/xen-ib-presentation.pdf

There were issues with getting Xen-IB to map well into the Xen model.
Vbus was specifically designed to address some of those short-comings.

>=20
> Given that both virtio and vbus can use ioeventfds, I don't see how one=

> can perform better than the other.
>=20
>> For real-time, a big part of it is relaying the guest scheduler state =
to
>> the host, but in a smart way.  For instance, the cpu priority for each=

>> vcpu is in a shared-table.  When the priority is raised, we can simply=

>> update the table without taking a VMEXIT.  When it is lowered, we need=

>> to inform the host of the change in case the underlying task needs to
>> reschedule.
>>   =20
>=20
> This is best done using cr8/tpr so you don't have to exit at all.  See
> also my vtpr support for Windows which does this in software, generally=

> avoiding the exit even when lowering priority.

You can think of vTPR as a good model, yes.  Generally, you can't
actually use it for our purposes for several reasons, however:

1) the prio granularity is too coarse (16 levels, -rt has 100)

2) it is too scope limited (it covers only interrupts, we need to have
additional considerations, like nested guest/host scheduling algorithms
against the vcpu, and prio-remap policies)

3) I use "priority" generally..there may be other non-priority based
policies that need to add state to the table (such as EDF deadlines, etc)=
=2E

but, otherwise, the idea is the same.  Besides, this was one example.


>=20
>> This is where the really fast call() type mechanism is important.
>>
>> Its also about having the priority flow-end to end, and having the vcp=
u
>> interrupt state affect the task-priority, etc (e.g. pending interrupts=

>> affect the vcpu task prio).
>>
>> etc, etc.
>>
>> I can go on and on (as you know ;), but will wait till this work is mo=
re
>> concrete and proven.
>>   =20
>=20
> Generally cpu state shouldn't flow through a device but rather through
> MSRs, hypercalls, and cpu registers.


Well, you can blame yourself for that one ;)

The original vbus was implemented as cpuid+hypercalls, partly for that
reason.  You kicked me out of kvm.ko, so I had to make due with plan B
via a less direct PCI-BRIDGE route.

But in reality, it doesn't matter much.  You can certainly have "system"
devices sitting on vbus that fit a similar role as "MSRs", so the access
method is more of an implementation detail.  The key is it needs to be
fast, and optimize out extraneous exits when possible.

>=20
>> Basically, what it comes down to is both vbus and vhost need
>> configuration/management.  Vbus does it with sysfs/configfs, and vhost=

>> does it with ioctls.  I ultimately decided to go with sysfs/configfs
>> because, at least that the time I looked, it seemed like the "blessed"=

>> way to do user->kernel interfaces.
>>   =20
>=20
> I really dislike that trend but that's an unrelated discussion.


Ok

>=20
>>> They need to be connected to the real world somehow.  What about
>>> security?  can any user create a container and devices and link them =
to
>>> real interfaces?  If not, do you need to run the VM as root?
>>>     =20
>> Today it has to be root as a result of weak mode support in configfs, =
so
>> you have me there.  I am looking for help patching this limitation,
>> though.
>>
>>   =20
>=20
> Well, do you plan to address this before submission for inclusion?

Maybe, maybe not.  Its workable for now (i.e. run as root), so its
inclusion is not predicated on the availability of the fix, per se (at
least IMHO).  If I can get it working before I get to pushing the core,
great!  Patches welcome.


>=20
>>> I hope everyone agrees that it's an important issue for me and that I=

>>> have to consider non-Linux guests.  I also hope that you're consideri=
ng
>>> non-Linux guests since they have considerable market share.
>>>     =20
>> I didn't mean non-Linux guests are not important.  I was disagreeing
>> with your assertion that it only works if its PCI.  There are numerous=

>> examples of IHV/ISV "bridge" implementations deployed in Windows, no?
>>   =20
>=20
> I don't know.
>=20
>> If vbus is exposed as a PCI-BRIDGE, how is this different?
>>   =20
>=20
> Technically it would work, but given you're not interested in Windows,

s/interested in/priortizing

For the time being, windows will not be RT, and windows can fall-back to
use virtio-net, etc.  So I am ok with this.  It will come in due time.

> who would write a driver?

Someone from the vbus community who is motivated enough and has the time
to do it, I suppose.  We have people interested in looking at this
internally, but other items have pushed it primarily to the back-burner.


>=20
>>> Given I'm not the gateway to inclusion of vbus/venet, you don't need =
to
>>> ask me anything.  I'm still free to give my opinion.
>>>     =20
>> Agreed, and I didn't mean to suggest otherwise.  It not clear if you a=
re
>> wearing the "kvm maintainer" hat, or the "lkml community member" hat a=
t
>> times, so its important to make that distinction.  Otherwise, its not
>> clear if this is edict as my superior, or input as my peer. ;)
>>   =20
>=20
> When I wear a hat, it is a Red Hat.  However I am bareheaded most often=
=2E
>=20
> (that is, look at the contents of my message, not who wrote it or his
> role).

Like it or not, maintainers always carry more weight when they opine
what can and can't be done w.r.t. what can be perceived as their
relevant subsystem.

>=20
>>> With virtio, the number is 1 (or less if you amortize).  Set up the r=
ing
>>> entries and kick.
>>>     =20
>> Again, I am just talking about basic PCI here, not the things we build=

>> on top.
>>   =20
>=20
> Whatever that means, it isn't interesting.  Performance is measure for
> the whole stack.
>=20
>> The point is: the things we build on top have costs associated with
>> them, and I aim to minimize it.  For instance, to do a "call()" kind o=
f
>> interface, you generally need to pre-setup some per-cpu mappings so th=
at
>> you can just do a single iowrite32() to kick the call off.  Those
>> per-cpu mappings have a cost if you want them to be high-performance, =
so
>> my argument is that you ideally want to limit the number of times you
>> have to do this.  My current design reduces this to "once".
>>   =20
>=20
> Do you mean minimizing the setup cost?  Seriously?

Not the time-to-complete-setup overhead.  The residual costs, like
heap/vmap usage at run-time.  You generally have to set up per-cpu
mappings to gain maximum performance.  You would need it per-device, I
do it per-system.  Its not a big deal in the grand-scheme of things,
really.  But chalk that up as an advantage to my approach over yours,
nonetheless.

>=20
>>> There's no such thing as raw PCI.  Every PCI device has a protocol.  =
The
>>> protocol virtio chose is optimized for virtualization.
>>>     =20
>> And its a question of how that protocol scales, more than how the
>> protocol works.
>>
>> Obviously the general idea of the protocol works, as vbus itself is
>> implemented as a PCI-BRIDGE and is therefore limited to the underlying=

>> characteristics that I can get out of PCI (like PIO latency).
>>   =20
>=20
> I thought we agreed that was insignificant?

I think I was agreeing with you, there. (e.g. obviously PIO latency is
acceptable, as I use it to underpin vbus)


>=20
>>> As I've mentioned before, prioritization is available on x86
>>>     =20
>> But as Ive mentioned, it doesn't work very well.
>>   =20
>=20
> I guess it isn't that important then.  I note that clever prioritizatio=
n
> in a guest is pointless if you can't do the same prioritization in the
> host.

I answer this below...


>=20
>>> , and coalescing scales badly.
>>>     =20
>> Depends on what is scaling.  Scaling vcpus?  Yes, you are right.
>> Scaling the number of devices?  No, this is where it improves.
>>   =20
>=20
> If you queue pending messages instead of walking the device list, you
> may be right.  Still, if hard interrupt processing takes 10% of your
> time you'll only have coalesced 10% of interrupts on average.
>=20
>>> irq window exits ought to be pretty rare, so we're only left with
>>> injection vmexits.  At around 1us/vmexit, even 100,000 interrupts/vcp=
u
>>> (which is excessive) will only cost you 10% cpu time.
>>>     =20
>> 1us is too much for what I am building, IMHO.
>=20
> You can't use current hardware then.

The point is that I am eliminating as many exits as possible, so 1us,
2us, whatever...it doesn't matter.  The fastest exit is the one you
don't have to take.

>=20
>>> You're free to demultiplex an MSI to however many consumers you want,=

>>> there's no need for a new bus for that.
>>>     =20
>> Hmmm...can you elaborate?
>>   =20
>=20
> Point all those MSIs at one vector.  Its handler will have to poll all
> the attached devices though.

Right, thats broken.


>=20
>>> Do you use DNS.  We use PCI-SIG.  If Novell is a PCI-SIG member you c=
an
>>> get a vendor ID and control your own virtio space.
>>>     =20
>> Yeah, we have our own id.  I am more concerned about making this desig=
n
>> make sense outside of PCI oriented environments.
>>   =20
>=20
> IIRC we reuse the PCI IDs for non-PCI.


You already know how I feel about this gem.


>=20
>=20
>=20
>=20
>>>>> That's a bug, not a feature.  It means poor scaling as the number o=
f
>>>>> vcpus increases and as the number of devices increases.
>>>>>         =20
>> vcpu increases, I agree (and am ok with, as I expect low vcpu count
>> machines to be typical).
>=20
> I'm not okay with it.  If you wish people to adopt vbus over virtio
> you'll have to address all concerns, not just yours.

By building a community around the development of vbus, isnt this what I
am doing?  Working towards making it usable for all?

>=20
>> nr of devices, I disagree.  can you elaborate?
>>   =20
>=20
> With message queueing, I retract my remark.

Ok.

>=20
>>> Windows,
>>>     =20
>> Work in progress.
>>   =20
>=20
> Interesting.  Do you plan to open source the code?  If not, will the
> binaries be freely available?

Ideally, yeah.  But I guess that has to go through legal, etc.  Right
now its primarily back-burnered.  If someone wants to submit code to
support this, great!


>=20
>>  =20
>>> large guests
>>>     =20
>> Can you elaborate?  I am not familiar with the term.
>>   =20
>=20
> Many vcpus.
>=20
>>  =20
>>> and multiqueue out of your design.
>>>     =20
>> AFAICT, multiqueue should work quite nicely with vbus.  Can you
>> elaborate on where you see the problem?
>>   =20
>=20
> You said you aren't interested in it previously IIRC.
>=20

I don't think so, no.  Perhaps I misspoke or was misunderstood.  I
actually think its a good idea and will be looking to do this.


>>>>> x86 APIC is priority aware.
>>>>>
>>>>>         =20
>>>> Have you ever tried to use it?
>>>>
>>>>       =20
>>> I haven't, but Windows does.
>>>     =20
>> Yeah, it doesn't really work well.  Its an extremely rigid model that
>> (IIRC) only lets you prioritize in 16 groups spaced by IDT (0-15 are o=
ne
>> level, 16-31 are another, etc).  Most of the embedded PICs I have work=
ed
>> with supported direct remapping, etc.  But in any case, Linux doesn't
>> support it so we are hosed no matter how good it is.
>>   =20
>=20
> I agree that it isn't very clever (not that I am a real time expert) bu=
t
> I disagree about dismissing Linux support so easily.  If prioritization=

> is such a win it should be a win on the host as well and we should make=

> it work on the host as well.  Further I don't see how priorities on the=

> guest can work if they don't on the host.

Its more about task priority in the case of real-time.  We do stuff with
802.1p as well for control messages, etc.  But for the most part, this
is an orthogonal effort.  And yes, you are right, it would be nice to
have this interrupt classification capability in the host.

Generally this is mitigated by the use of irq-threads.  You could argue
that if irq-threads help the host without a prioritized interrupt
controller, why cant the guest?  The answer is simply that the host can
afford sub-optimal behavior w.r.t. IDT injection here, where the guest
cannot (due to the disparity of hw-injection vs guest-injection overheads=
).

IOW: The cost of an IDT dispatch in real-hardware adds minimal latency,
even if a low-priority IDT preempts a high-priority interrupt thread.
The cost of an IDT dispatch in a guest, OTOH, especially when you factor
in the complete picture (IPI-exit, inject, eoi exit, re-enter) is
greater...to great, in fact.  So if you can get the guests interrupts
priority aware, you can avoid even the IDT preempting the irq-thread
until the system is in the ideal state.

>=20
>>>>
>>>>       =20
>>> They had to build connectors just like you propose to do.
>>>     =20
>> More importantly, they had to build back-end busses too, no?
>>   =20
>=20
> They had to write 414 lines in drivers/s390/kvm/kvm_virtio.c and
> something similar for lguest.

Well, then I retract that statement.  I think the small amount of code
is probably because they are re-using the qemu device-models, however.
Note that I am essentially advocating the same basic idea here.


>=20
>>> But you still need vbus-connector-lguest and vbus-connector-s390 beca=
use
>>> they all talk to the host differently.  So what's changed?  the names=
?
>>>     =20
>> The fact that they don't need to redo most of the in-kernel backend
>> stuff.  Just the connector.
>>   =20
>=20
> So they save 414 lines but have to write a connector which is... how la=
rge?

I guess that depends on the features they want.  A pci-based connector
would probably be pretty thin, since you don't need event channels like
I use in the pci-bridge connector.

The idea, of course, is that the vbus can become your whole bus if you
want.  So you wouldn't need to tunnel, say, vbus over some lguest bus.
You just base the design on vbus outright.

Note that this was kind of what the first pass of vbus did for KVM.  The
bus was exposed via cpuid and hypercalls as kind of a system-service.
It wasn't until later that I surfaced it as a bridge model.

>=20
>>> Well, venet doesn't complement virtio-net, and virtio-pci doesn't
>>> complement vbus-connector.
>>>     =20
>> Agreed, but virtio complements vbus by virtue of virtio-vbus.
>>   =20
>=20
> I don't see what vbus adds to virtio-net.

Well, as you stated in your last reply, you don't want it.  So I guess
that doesn't matter much at this point.  I will continue developing
vbus, and pushing things your way.  You can opt to accept or reject
those things at your own discretion.

Kind Regards,
-Greg



--------------enig8654F3DC7403146F427624B6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG/MacGPG2 v2.0.11 (Darwin)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iEYEARECAAYFAkqMQ9MACgkQP5K2CMvXmqHR4ACfR4N/4Kx3MMxdw6iObqZ/RnfN
q1kAmwTaJ1z5APmDIoBEhccMUypIPE+o
=/tKk
-----END PGP SIGNATURE-----

--------------enig8654F3DC7403146F427624B6--

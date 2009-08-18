From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 19:27:36 +0300
Message-ID: <4A8AD678.7050609@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46399 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754908AbZHRQ2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Aug 2009 12:28:06 -0400
In-Reply-To: <4A8ABEC9.6090006@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2009 05:46 PM, Gregory Haskins wrote:
>
>> Can you explain how vbus achieves RDMA?
>>
>> I also don't see the connection to real time guests.
>>      
> Both of these are still in development.  Trying to stay true to the
> "release early and often" mantra, the core vbus technology is being
> pushed now so it can be reviewed.  Stay tuned for these other developments.
>    

Hopefully you can outline how it works.  AFAICT, RDMA and kernel bypass 
will need device assignment.  If you're bypassing the call into the host 
kernel, it doesn't really matter how that call is made, does it?

>>> I also designed it in such a way that
>>> we could, in theory, write one set of (linux-based) backends, and have
>>> them work across a variety of environments (such as containers/VMs like
>>> KVM, lguest, openvz, but also physical systems like blade enclosures and
>>> clusters, or even applications running on the host).
>>>
>>>        
>> Sorry, I'm still confused.  Why would openvz need vbus?
>>      
> Its just an example.  The point is that I abstracted what I think are
> the key points of fast-io, memory routing, signal routing, etc, so that
> it will work in a variety of (ideally, _any_) environments.
>
> There may not be _performance_ motivations for certain classes of VMs
> because they already have decent support, but they may want a connector
> anyway to gain some of the new features available in vbus.
>
> And looking forward, the idea is that we have commoditized the backend
> so we don't need to redo this each time a new container comes along.
>    

I'll wait until a concrete example shows up as I still don't understand.

>> One point of contention is that this is all managementy stuff and should
>> be kept out of the host kernel.  Exposing shared memory, interrupts, and
>> guest hypercalls can all be easily done from userspace (as virtio
>> demonstrates).  True, some devices need kernel acceleration, but that's
>> no reason to put everything into the host kernel.
>>      
> See my last reply to Anthony.  My two points here are that:
>
> a) having it in-kernel makes it a complete subsystem, which perhaps has
> diminished value in kvm, but adds value in most other places that we are
> looking to use vbus.
>    

It's not a complete system unless you want users to administer VMs using 
echo and cat and configfs.  Some userspace support will always be necessary.

> b) the in-kernel code is being overstated as "complex".  We are not
> talking about your typical virt thing, like an emulated ICH/PCI chipset.
>   Its really a simple list of devices with a handful of attributes.  They
> are managed using established linux interfaces, like sysfs/configfs.
>    

They need to be connected to the real world somehow.  What about 
security?  can any user create a container and devices and link them to 
real interfaces?  If not, do you need to run the VM as root?

virtio and vhost-net solve these issues.  Does vbus?

The code may be simple to you.  But the question is whether it's 
necessary, not whether it's simple or complex.

>> Exposing devices as PCI is an important issue for me, as I have to
>> consider non-Linux guests.
>>      
> Thats your prerogative, but obviously not everyone agrees with you.
>    

I hope everyone agrees that it's an important issue for me and that I 
have to consider non-Linux guests.  I also hope that you're considering 
non-Linux guests since they have considerable market share.

> Getting non-Linux guests to work is my problem if you chose to not be
> part of the vbus community.
>    

I won't be writing those drivers in any case.

>> Another issue is the host kernel management code which I believe is
>> superfluous.
>>      
> In your opinion, right?
>    

Yes, this is why I wrote "I believe".


>> Given that, why spread to a new model?
>>      
> Note: I haven't asked you to (at least, not since April with the vbus-v3
> release).  Spreading to a new model is currently the role of the
> AlacrityVM project, since we disagree on the utility of a new model.
>    

Given I'm not the gateway to inclusion of vbus/venet, you don't need to 
ask me anything.  I'm still free to give my opinion.

>>> A) hardware can only generate byte/word sized requests at a time because
>>> that is all the pcb-etch and silicon support. So hardware is usually
>>> expressed in terms of some number of "registers".
>>>
>>>        
>> No, hardware happily DMAs to and fro main memory.
>>      
> Yes, now walk me through how you set up DMA to do something like a call
> when you do not know addresses apriori.  Hint: count the number of
> MMIO/PIOs you need.  If the number is>  1, you've lost.
>    

With virtio, the number is 1 (or less if you amortize).  Set up the ring 
entries and kick.

>>   Some hardware of
>> course uses mmio registers extensively, but not virtio hardware.  With
>> the recent MSI support no registers are touched in the fast path.
>>      
> Note we are not talking about virtio here.  Just raw PCI and why I
> advocate vbus over it.
>    

There's no such thing as raw PCI.  Every PCI device has a protocol.  The 
protocol virtio chose is optimized for virtualization.


>>> D) device-ids are in a fixed width register and centrally assigned from
>>> an authority (e.g. PCI-SIG).
>>>
>>>        
>> That's not an issue either.  Qumranet/Red Hat has donated a range of
>> device IDs for use in virtio.
>>      
> Yes, and to get one you have to do what?  Register it with kvm.git,
> right?  Kind of like registering a MAJOR/MINOR, would you agree?  Maybe
> you do not mind (especially given your relationship to kvm.git), but
> there are disadvantages to that model for most of the rest of us.
>    

Send an email, it's not that difficult.  There's also an experimental range.

>>   Device IDs are how devices are associated
>> with drivers, so you'll need something similar for vbus.
>>      
> Nope, just like you don't need to do anything ahead of time for using a
> dynamic misc-device name.  You just have both the driver and device know
> what they are looking for (its part of the ABI).
>    

If you get a device ID clash, you fail.  If you get a device name clash, 
you fail in the same way.

>>> E) Interrupt/MSI routing is per-device oriented
>>>
>>>        
>> Please elaborate.  What is the issue?  How does vbus solve it?
>>      
> There are no "interrupts" in vbus..only shm-signals.  You can establish
> an arbitrary amount of shm regions, each with an optional shm-signal
> associated with it.  To do this, the driver calls dev->shm(), and you
> get back a shm_signal object.
>
> Underneath the hood, the vbus-connector (e.g. vbus-pcibridge) decides
> how it maps real interrupts to shm-signals (on a system level, not per
> device).  This can be 1:1, or any other scheme.  vbus-pcibridge uses one
> system-wide interrupt per priority level (today this is 8 levels), each
> with an IOQ based event channel.  "signals" come as an event on that
> channel.
>
> So the "issue" is that you have no real choice with PCI.  You just get
> device oriented interrupts.  With vbus, its abstracted.  So you can
> still get per-device standard MSI, or you can do fancier things like do
> coalescing and prioritization.
>    

As I've mentioned before, prioritization is available on x86, and 
coalescing scales badly.

>>> F) Interrupts/MSI are assumed cheap to inject
>>>
>>>        
>> Interrupts are not assumed cheap; that's why interrupt mitigation is
>> used (on real and virtual hardware).
>>      
> Its all relative.  IDT dispatch and EOI overhead are "baseline" on real
> hardware, whereas they are significantly more expensive to do the
> vmenters and vmexits on virt (and you have new exit causes, like
> irq-windows, etc, that do not exist in real HW).
>    

irq window exits ought to be pretty rare, so we're only left with 
injection vmexits.  At around 1us/vmexit, even 100,000 interrupts/vcpu 
(which is excessive) will only cost you 10% cpu time.

>>> G) Interrupts/MSI are non-priortizable.
>>>
>>>        
>> They are prioritizable; Linux ignores this though (Windows doesn't).
>> Please elaborate on what the problem is and how vbus solves it.
>>      
> It doesn't work right.  The x86 sense of interrupt priority is, sorry to
> say it, half-assed at best.  I've worked with embedded systems that have
> real interrupt priority support in the hardware, end to end, including
> the PIC.  The LAPIC on the other hand is really weak in this dept, and
> as you said, Linux doesn't even attempt to use whats there.
>    

Maybe prioritization is not that important then.  If it is, it needs to 
be fixed at the lapic level, otherwise you have no real prioritization 
wrt non-vbus interrupts.

>>> H) Interrupts/MSI are statically established
>>>
>>>        
>> Can you give an example of why this is a problem?
>>      
> Some of the things we are building use the model of having a device that
> hands out shm-signal in response to guest events (say, the creation of
> an IPC channel).  This would generally be handled by a specific device
> model instance, and it would need to do this without pre-declaring the
> MSI vectors (to use PCI as an example).
>    

You're free to demultiplex an MSI to however many consumers you want, 
there's no need for a new bus for that.

>> What performance oriented items have been left unaddressed?
>>      
> Well, the interrupt model to name one.
>    

Like I mentioned, you can merge MSI interrupts, but that's not 
necessarily a good idea.

>> How do you handle conflicts?  Again you need a central authority to hand
>> out names or prefixes.
>>      
> Not really, no.  If you really wanted to be formal about it, you could
> adopt any series of UUID schemes.  For instance, perhaps venet should be
> "com.novell::virtual-ethernet".  Heck, I could use uuidgen.
>    

Do you use DNS.  We use PCI-SIG.  If Novell is a PCI-SIG member you can 
get a vendor ID and control your own virtio space.

>>> As another example, the connector design coalesces *all* shm-signals
>>> into a single interrupt (by prio) that uses the same context-switch
>>> mitigation techniques that help boost things like networking.  This
>>> effectively means we can detect and optimize out ack/eoi cycles from the
>>> APIC as the IO load increases (which is when you need it most).  PCI has
>>> no such concept.
>>>
>>>        
>> That's a bug, not a feature.  It means poor scaling as the number of
>> vcpus increases and as the number of devices increases.
>>      
> So the "avi-vbus-connector" can use 1:1, if you prefer.  Large vcpu
> counts (which are not typical) and irq-affinity is not a target
> application for my design, so I prefer the coalescing model in the
> vbus-pcibridge included in this series. YMMV
>    

So far you've left out live migration, Windows, large guests, and 
multiqueue out of your design.  If you wish to position vbus/venet for 
large scale use you'll need to address all of them.

>> Note nothing prevents steering multiple MSIs into a single vector.  It's
>> a bad idea though.
>>      
> Yes, it is a bad idea...and not the same thing either.  This would
> effectively create a shared-line scenario in the irq code, which is not
> what happens in vbus.
>    

Ok.

>>> In addition, the signals and interrupts are priority aware, which is
>>> useful for things like 802.1p networking where you may establish 8-tx
>>> and 8-rx queues for your virtio-net device.  x86 APIC really has no
>>> usable equivalent, so PCI is stuck here.
>>>
>>>        
>> x86 APIC is priority aware.
>>      
> Have you ever tried to use it?
>    

I haven't, but Windows does.

>>> Also, the signals can be allocated on-demand for implementing things
>>> like IPC channels in response to guest requests since there is no
>>> assumption about device-to-interrupt mappings.  This is more flexible.
>>>
>>>        
>> Yes.  However given that vectors are a scarce resource you're severely
>> limited in that.
>>      
> The connector I am pushing out does not have this limitation.
>    

Okay.

>    
>>   And if you're multiplexing everything on one vector,
>> then you can just as well demultiplex your channels in the virtio driver
>> code.
>>      
> Only per-device, not system wide.
>    

Right.  I still think multiplexing interrupts is a bad idea in a large 
system.  In a small system... why would you do it at all?

>>> And through all of this, this design would work in any guest even if it
>>> doesn't have PCI (e.g. lguest, UML, physical systems, etc).
>>>
>>>        
>> That is true for virtio which works on pci-less lguest and s390.
>>      
> Yes, and lguest and s390 had to build their own bus-model to do it, right?
>    

They had to build connectors just like you propose to do.

> Thank you for bringing this up, because it is one of the main points
> here.  What I am trying to do is generalize the bus to prevent the
> proliferation of more of these isolated models in the future.  Build
> one, fast, in-kernel model so that we wouldn't need virtio-X, and
> virtio-Y in the future.  They can just reuse the (performance optimized)
> bus and models, and only need to build the connector to bridge them.
>    

But you still need vbus-connector-lguest and vbus-connector-s390 because 
they all talk to the host differently.  So what's changed?  the names?

>> That is exactly the design goal of virtio (except it limits itself to
>> virtualization).
>>      
> No, virtio is only part of the picture.  It not including the backend
> models, or how to do memory/signal-path abstraction for in-kernel, for
> instance.  But otherwise, virtio as a device model is compatible with
> vbus as a bus model.  They compliment one another.
>    

Well, venet doesn't complement virtio-net, and virtio-pci doesn't 
complement vbus-connector.

>>> Then device models like virtio can ride happily on top and we end up
>>> with a really robust and high-performance Linux-based stack.  I don't
>>> buy the argument that we already have PCI so lets use it.  I don't think
>>> its the best design and I am not afraid to make an investment in a
>>> change here because I think it will pay off in the long run.
>>>
>>>        
>> Sorry, I don't think you've shown any quantifiable advantages.
>>      
> We can agree to disagree then, eh?  There are certainly quantifiable
> differences.  Waving your hand at the differences to say they are not
> advantages is merely an opinion, one that is not shared universally.
>    

I've addressed them one by one.  We can agree to disagree on interrupt 
multiplexing, and the importance of compatibility, Windows, large 
guests, multiqueue, and DNS vs. PCI-SIG.

> The bottom line is all of these design distinctions are encapsulated
> within the vbus subsystem and do not affect the kvm code-base.  So
> agreement with kvm upstream is not a requirement, but would be
> advantageous for collaboration.
>    

Certainly.

-- 
error compiling committee.c: too many arguments to function


From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Tue, 18 Aug 2009 11:33:18 +0300
Message-ID: <4A8A674E.8070200@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, Gregory Haskins <ghaskins@novell.com>,
	kvm@vger.kernel.org, alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A89B08A.4010103@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/17/2009 10:33 PM, Gregory Haskins wrote:
>
> There is a secondary question of venet (a vbus native device) verses
> virtio-net (a virtio native device that works with PCI or VBUS).  If
> this contention is really around venet vs virtio-net, I may possibly
> conceed and retract its submission to mainline.  I've been pushing it to
> date because people are using it and I don't see any reason that the
> driver couldn't be upstream.
>    

That's probably the cause of much confusion.  The primary kvm pain point 
is now networking, so in any vbus discussion we're concentrating on that 
aspect.

>> Also, are you willing to help virtio to become faster?
>>      
> Yes, that is not a problem.  Note that virtio in general, and
> virtio-net/venet in particular are not the primary goal here, however.
> Improved 802.x and block IO are just positive side-effects of the
> effort.  I started with 802.x networking just to demonstrate the IO
> layer capabilities, and to test it.  It ended up being so good on
> contrast to existing facilities, that developers in the vbus community
> started using it for production development.
>
> Ultimately, I created vbus to address areas of performance that have not
> yet been addressed in things like KVM.  Areas such as real-time guests,
> or RDMA (host bypass) interfaces.

Can you explain how vbus achieves RDMA?

I also don't see the connection to real time guests.

> I also designed it in such a way that
> we could, in theory, write one set of (linux-based) backends, and have
> them work across a variety of environments (such as containers/VMs like
> KVM, lguest, openvz, but also physical systems like blade enclosures and
> clusters, or even applications running on the host).
>    

Sorry, I'm still confused.  Why would openvz need vbus?  It already has 
zero-copy networking since it's a shared kernel.  Shared memory should 
also work seamlessly, you just need to expose the shared memory object 
on a shared part of the namespace.  And of course, anything in the 
kernel is already shared.

>> Or do you
>> have arguments why that is impossible to do so and why the only
>> possible solution is vbus? Avi says no such arguments were offered
>> so far.
>>      
> Not for lack of trying.  I think my points have just been missed
> everytime I try to describe them. ;)  Basically I write a message very
> similar to this one, and the next conversation starts back from square
> one.  But I digress, let me try again..
>
> Noting that this discussion is really about the layer *below* virtio,
> not virtio itself (e.g. PCI vs vbus).  Lets start with a little background:
>
> -- Background --
>
> So on one level, we have the resource-container technology called
> "vbus".  It lets you create a container on the host, fill it with
> virtual devices, and assign that container to some context (such as a
> KVM guest).  These "devices" are LKMs, and each device has a very simple
> verb namespace consisting of a synchronous "call()" method, and a
> "shm()" method for establishing async channels.
>
> The async channels are just shared-memory with a signal path (e.g.
> interrupts and hypercalls), which the device+driver can use to overlay
> things like rings (virtqueues, IOQs), or other shared-memory based
> constructs of their choosing (such as a shared table).  The signal path
> is designed to minimize enter/exits and reduce spurious signals in a
> unified way (see shm-signal patch).
>
> call() can be used both for config-space like details, as well as
> fast-path messaging that require synchronous behavior (such as guest
> scheduler updates).
>
> All of this is managed via sysfs/configfs.
>    

One point of contention is that this is all managementy stuff and should 
be kept out of the host kernel.  Exposing shared memory, interrupts, and 
guest hypercalls can all be easily done from userspace (as virtio 
demonstrates).  True, some devices need kernel acceleration, but that's 
no reason to put everything into the host kernel.

> On the guest, we have a "vbus-proxy" which is how the guest gets access
> to devices assigned to its container.  (as an aside, "virtio" devices
> can be populated in the container, and then surfaced up to the
> virtio-bus via that virtio-vbus patch I mentioned).
>
> There is a thing called a "vbus-connector" which is the guest specific
> part.  Its job is to connect the vbus-proxy in the guest, to the vbus
> container on the host.  How it does its job is specific to the connector
> implementation, but its role is to transport messages between the guest
> and the host (such as for call() and shm() invocations) and to handle
> things like discovery and hotswap.
>    

virtio has an exact parallel here (virtio-pci and friends).

> Out of all this, I think the biggest contention point is the design of
> the vbus-connector that I use in AlacrityVM (Avi, correct me if I am
> wrong and you object to other aspects as well).  I suspect that if I had
> designed the vbus-connector to surface vbus devices as PCI devices via
> QEMU, the patches would potentially have been pulled in a while ago.
>    

Exposing devices as PCI is an important issue for me, as I have to 
consider non-Linux guests.
Another issue is the host kernel management code which I believe is 
superfluous.

But the biggest issue is compatibility.  virtio exists and has Windows 
and Linux drivers.  Without a fatal flaw in virtio we'll continue to 
support it.  Given that, why spread to a new model?

Of course, I understand you're interested in non-ethernet, non-block 
devices.  I can't comment on these until I see them.  Maybe they can fit 
the virtio model, and maybe they can't.

> There are, of course, reasons why vbus does *not* render as PCI, so this
> is the meat of of your question, I believe.
>
> At a high level, PCI was designed for software-to-hardware interaction,
> so it makes assumptions about that relationship that do not necessarily
> apply to virtualization.
>
> For instance:
>
> A) hardware can only generate byte/word sized requests at a time because
> that is all the pcb-etch and silicon support. So hardware is usually
> expressed in terms of some number of "registers".
>    

No, hardware happily DMAs to and fro main memory.  Some hardware of 
course uses mmio registers extensively, but not virtio hardware.  With 
the recent MSI support no registers are touched in the fast path.

> C) the target end-point has no visibility into the CPU machine state
> other than the parameters passed in the bus-cycle (usually an address
> and data tuple).
>    

That's not an issue.  Accessing memory is cheap.

> D) device-ids are in a fixed width register and centrally assigned from
> an authority (e.g. PCI-SIG).
>    

That's not an issue either.  Qumranet/Red Hat has donated a range of 
device IDs for use in virtio.  Device IDs are how devices are associated 
with drivers, so you'll need something similar for vbus.

> E) Interrupt/MSI routing is per-device oriented
>    

Please elaborate.  What is the issue?  How does vbus solve it?

> F) Interrupts/MSI are assumed cheap to inject
>    

Interrupts are not assumed cheap; that's why interrupt mitigation is 
used (on real and virtual hardware).

> G) Interrupts/MSI are non-priortizable.
>    

They are prioritizable; Linux ignores this though (Windows doesn't).  
Please elaborate on what the problem is and how vbus solves it.

> H) Interrupts/MSI are statically established
>    

Can you give an example of why this is a problem?

> These assumptions and constraints may be completely different or simply
> invalid in a virtualized guest. For instance, the hypervisor is just
> software, and therefore it's not restricted to "etch" constraints. IO
> requests can be arbitrarily large, just as if you are invoking a library
> function-call or OS system-call. Likewise, each one of those requests is
> a branch and a context switch, so it has often has greater performance
> implications than a simple register bus-cycle in hardware.  If you use
> an MMIO variant, it has to run through the page-fault code to be decoded.
>
> The result is typically decreased performance if you try to do the same
> thing real hardware does. This is why you usually see hypervisor
> specific drivers (e.g. virtio-net, vmnet, etc) a common feature.
>
> _Some_ performance oriented items can technically be accomplished in
> PCI, albeit in a much more awkward way.  For instance, you can set up a
> really fast, low-latency "call()" mechanism using a PIO port on a
> PCI-model and ioeventfd.  As a matter of fact, this is exactly what the
> vbus pci-bridge does:
>    

What performance oriented items have been left unaddressed?

virtio and vbus use three communications channels:  call from guest to 
host (implemented as pio and reasonably fast), call from host to guest 
(implemented as msi and reasonably fast) and shared memory (as fast as 
it can be).  Where does PCI limit you in any way?

> The problem here is that this is incredibly awkward to setup.  You have
> all that per-cpu goo and the registration of the memory on the guest.
> And on the host side, you have all the vmapping of the registered
> memory, and the file-descriptor to manage.  In short, its really painful.
>
> I would much prefer to do this *once*, and then let all my devices
> simple re-use that infrastructure.  This is, in fact, what I do.  Here
> is the device model that a guest sees:
>    

virtio also reuses the pci code, on both guest and host.

> Moving on: _Other_ items cannot be replicated (at least, not without
> hacking it into something that is no longer PCI.
>
> Things like the pci-id namespace are just silly for software.  I would
> rather have a namespace that does not require central management so
> people are free to create vbus-backends at will.  This is akin to
> registering a device MAJOR/MINOR, verses using the various dynamic
> assignment mechanisms.  vbus uses a string identifier in place of a
> pci-id.  This is superior IMHO, and not compatible with PCI.
>    

How do you handle conflicts?  Again you need a central authority to hand 
out names or prefixes.

> As another example, the connector design coalesces *all* shm-signals
> into a single interrupt (by prio) that uses the same context-switch
> mitigation techniques that help boost things like networking.  This
> effectively means we can detect and optimize out ack/eoi cycles from the
> APIC as the IO load increases (which is when you need it most).  PCI has
> no such concept.
>    

That's a bug, not a feature.  It means poor scaling as the number of 
vcpus increases and as the number of devices increases.

Note nothing prevents steering multiple MSIs into a single vector.  It's 
a bad idea though.

> In addition, the signals and interrupts are priority aware, which is
> useful for things like 802.1p networking where you may establish 8-tx
> and 8-rx queues for your virtio-net device.  x86 APIC really has no
> usable equivalent, so PCI is stuck here.
>    

x86 APIC is priority aware.

> Also, the signals can be allocated on-demand for implementing things
> like IPC channels in response to guest requests since there is no
> assumption about device-to-interrupt mappings.  This is more flexible.
>    

Yes.  However given that vectors are a scarce resource you're severely 
limited in that.  And if you're multiplexing everything on one vector, 
then you can just as well demultiplex your channels in the virtio driver 
code.

> And through all of this, this design would work in any guest even if it
> doesn't have PCI (e.g. lguest, UML, physical systems, etc).
>    

That is true for virtio which works on pci-less lguest and s390.

> -- Bottom Line --
>
> The idea here is to generalize all the interesting parts that are common
> (fast sync+async io, context-switch mitigation, back-end models, memory
> abstractions, signal-path routing, etc) that a variety of linux based
> technologies can use (kvm, lguest, openvz, uml, physical systems) and
> only require the thin "connector" code to port the system around.  The
> idea is to try to get this aspect of PV right once, and at some point in
> the future, perhaps vbus will be as ubiquitous as PCI.  Well, perhaps
> not *that* ubiquitous, but you get the idea ;)
>    

That is exactly the design goal of virtio (except it limits itself to 
virtualization).

> Then device models like virtio can ride happily on top and we end up
> with a really robust and high-performance Linux-based stack.  I don't
> buy the argument that we already have PCI so lets use it.  I don't think
> its the best design and I am not afraid to make an investment in a
> change here because I think it will pay off in the long run.
>    

Sorry, I don't think you've shown any quantifiable advantages.

-- 
error compiling committee.c: too many arguments to function


From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 10:11:42 +0300
Message-ID: <4A8BA5AE.3030308@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49794 "EHLO mx2.redhat.com"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751152AbZHSHLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 03:11:37 -0400
In-Reply-To: <4A8B9B79.9050004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/19/2009 09:28 AM, Gregory Haskins wrote:
> Avi Kivity wrote:
>    
>> On 08/18/2009 05:46 PM, Gregory Haskins wrote:
>>      
>>>        
>>>> Can you explain how vbus achieves RDMA?
>>>>
>>>> I also don't see the connection to real time guests.
>>>>
>>>>          
>>> Both of these are still in development.  Trying to stay true to the
>>> "release early and often" mantra, the core vbus technology is being
>>> pushed now so it can be reviewed.  Stay tuned for these other
>>> developments.
>>>
>>>        
>> Hopefully you can outline how it works.  AFAICT, RDMA and kernel bypass
>> will need device assignment.  If you're bypassing the call into the host
>> kernel, it doesn't really matter how that call is made, does it?
>>      
> This is for things like the setup of queue-pairs, and the transport of
> door-bells, and ib-verbs.  I am not on the team doing that work, so I am
> not an expert in this area.  What I do know is having a flexible and
> low-latency signal-path was deemed a key requirement.
>    

That's not a full bypass, then.  AFAIK kernel bypass has userspace 
talking directly to the device.

Given that both virtio and vbus can use ioeventfds, I don't see how one 
can perform better than the other.

> For real-time, a big part of it is relaying the guest scheduler state to
> the host, but in a smart way.  For instance, the cpu priority for each
> vcpu is in a shared-table.  When the priority is raised, we can simply
> update the table without taking a VMEXIT.  When it is lowered, we need
> to inform the host of the change in case the underlying task needs to
> reschedule.
>    

This is best done using cr8/tpr so you don't have to exit at all.  See 
also my vtpr support for Windows which does this in software, generally 
avoiding the exit even when lowering priority.

> This is where the really fast call() type mechanism is important.
>
> Its also about having the priority flow-end to end, and having the vcpu
> interrupt state affect the task-priority, etc (e.g. pending interrupts
> affect the vcpu task prio).
>
> etc, etc.
>
> I can go on and on (as you know ;), but will wait till this work is more
> concrete and proven.
>    

Generally cpu state shouldn't flow through a device but rather through 
MSRs, hypercalls, and cpu registers.

> Basically, what it comes down to is both vbus and vhost need
> configuration/management.  Vbus does it with sysfs/configfs, and vhost
> does it with ioctls.  I ultimately decided to go with sysfs/configfs
> because, at least that the time I looked, it seemed like the "blessed"
> way to do user->kernel interfaces.
>    

I really dislike that trend but that's an unrelated discussion.

>> They need to be connected to the real world somehow.  What about
>> security?  can any user create a container and devices and link them to
>> real interfaces?  If not, do you need to run the VM as root?
>>      
> Today it has to be root as a result of weak mode support in configfs, so
> you have me there.  I am looking for help patching this limitation, though.
>
>    

Well, do you plan to address this before submission for inclusion?

>> I hope everyone agrees that it's an important issue for me and that I
>> have to consider non-Linux guests.  I also hope that you're considering
>> non-Linux guests since they have considerable market share.
>>      
> I didn't mean non-Linux guests are not important.  I was disagreeing
> with your assertion that it only works if its PCI.  There are numerous
> examples of IHV/ISV "bridge" implementations deployed in Windows, no?
>    

I don't know.

> If vbus is exposed as a PCI-BRIDGE, how is this different?
>    

Technically it would work, but given you're not interested in Windows, 
who would write a driver?

>> Given I'm not the gateway to inclusion of vbus/venet, you don't need to
>> ask me anything.  I'm still free to give my opinion.
>>      
> Agreed, and I didn't mean to suggest otherwise.  It not clear if you are
> wearing the "kvm maintainer" hat, or the "lkml community member" hat at
> times, so its important to make that distinction.  Otherwise, its not
> clear if this is edict as my superior, or input as my peer. ;)
>    

When I wear a hat, it is a Red Hat.  However I am bareheaded most often.

(that is, look at the contents of my message, not who wrote it or his role).

>> With virtio, the number is 1 (or less if you amortize).  Set up the ring
>> entries and kick.
>>      
> Again, I am just talking about basic PCI here, not the things we build
> on top.
>    

Whatever that means, it isn't interesting.  Performance is measure for 
the whole stack.

> The point is: the things we build on top have costs associated with
> them, and I aim to minimize it.  For instance, to do a "call()" kind of
> interface, you generally need to pre-setup some per-cpu mappings so that
> you can just do a single iowrite32() to kick the call off.  Those
> per-cpu mappings have a cost if you want them to be high-performance, so
> my argument is that you ideally want to limit the number of times you
> have to do this.  My current design reduces this to "once".
>    

Do you mean minimizing the setup cost?  Seriously?

>> There's no such thing as raw PCI.  Every PCI device has a protocol.  The
>> protocol virtio chose is optimized for virtualization.
>>      
> And its a question of how that protocol scales, more than how the
> protocol works.
>
> Obviously the general idea of the protocol works, as vbus itself is
> implemented as a PCI-BRIDGE and is therefore limited to the underlying
> characteristics that I can get out of PCI (like PIO latency).
>    

I thought we agreed that was insignificant?

>> As I've mentioned before, prioritization is available on x86
>>      
> But as Ive mentioned, it doesn't work very well.
>    

I guess it isn't that important then.  I note that clever prioritization 
in a guest is pointless if you can't do the same prioritization in the host.

>> , and coalescing scales badly.
>>      
> Depends on what is scaling.  Scaling vcpus?  Yes, you are right.
> Scaling the number of devices?  No, this is where it improves.
>    

If you queue pending messages instead of walking the device list, you 
may be right.  Still, if hard interrupt processing takes 10% of your 
time you'll only have coalesced 10% of interrupts on average.

>> irq window exits ought to be pretty rare, so we're only left with
>> injection vmexits.  At around 1us/vmexit, even 100,000 interrupts/vcpu
>> (which is excessive) will only cost you 10% cpu time.
>>      
> 1us is too much for what I am building, IMHO.

You can't use current hardware then.

>> You're free to demultiplex an MSI to however many consumers you want,
>> there's no need for a new bus for that.
>>      
> Hmmm...can you elaborate?
>    

Point all those MSIs at one vector.  Its handler will have to poll all 
the attached devices though.

>> Do you use DNS.  We use PCI-SIG.  If Novell is a PCI-SIG member you can
>> get a vendor ID and control your own virtio space.
>>      
> Yeah, we have our own id.  I am more concerned about making this design
> make sense outside of PCI oriented environments.
>    

IIRC we reuse the PCI IDs for non-PCI.




>>>> That's a bug, not a feature.  It means poor scaling as the number of
>>>> vcpus increases and as the number of devices increases.
>>>>          
> vcpu increases, I agree (and am ok with, as I expect low vcpu count
> machines to be typical).

I'm not okay with it.  If you wish people to adopt vbus over virtio 
you'll have to address all concerns, not just yours.

> nr of devices, I disagree.  can you elaborate?
>    

With message queueing, I retract my remark.

>> Windows,
>>      
> Work in progress.
>    

Interesting.  Do you plan to open source the code?  If not, will the 
binaries be freely available?

>    
>> large guests
>>      
> Can you elaborate?  I am not familiar with the term.
>    

Many vcpus.

>    
>> and multiqueue out of your design.
>>      
> AFAICT, multiqueue should work quite nicely with vbus.  Can you
> elaborate on where you see the problem?
>    

You said you aren't interested in it previously IIRC.

>>>> x86 APIC is priority aware.
>>>>
>>>>          
>>> Have you ever tried to use it?
>>>
>>>        
>> I haven't, but Windows does.
>>      
> Yeah, it doesn't really work well.  Its an extremely rigid model that
> (IIRC) only lets you prioritize in 16 groups spaced by IDT (0-15 are one
> level, 16-31 are another, etc).  Most of the embedded PICs I have worked
> with supported direct remapping, etc.  But in any case, Linux doesn't
> support it so we are hosed no matter how good it is.
>    

I agree that it isn't very clever (not that I am a real time expert) but 
I disagree about dismissing Linux support so easily.  If prioritization 
is such a win it should be a win on the host as well and we should make 
it work on the host as well.  Further I don't see how priorities on the 
guest can work if they don't on the host.

>>>
>>>        
>> They had to build connectors just like you propose to do.
>>      
> More importantly, they had to build back-end busses too, no?
>    

They had to write 414 lines in drivers/s390/kvm/kvm_virtio.c and 
something similar for lguest.

>> But you still need vbus-connector-lguest and vbus-connector-s390 because
>> they all talk to the host differently.  So what's changed?  the names?
>>      
> The fact that they don't need to redo most of the in-kernel backend
> stuff.  Just the connector.
>    

So they save 414 lines but have to write a connector which is... how large?

>> Well, venet doesn't complement virtio-net, and virtio-pci doesn't
>> complement vbus-connector.
>>      
> Agreed, but virtio complements vbus by virtue of virtio-vbus.
>    

I don't see what vbus adds to virtio-net.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.


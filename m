From: Avi Kivity <avi@redhat.com>
Subject: Re: [PATCH v3 3/6] vbus: add a "vbus-proxy" bus model for vbus_driver
 objects
Date: Wed, 19 Aug 2009 23:37:16 +0300
Message-ID: <4A8C627C.70001@redhat.com>
References: <20090814154125.26116.70709.stgit@dev.haskins.net> <20090814154308.26116.46980.stgit@dev.haskins.net> <20090815103243.GA26749@elte.hu> <4A8954F0.3040402@gmail.com> <20090817142506.GB3602@elte.hu> <4A8971A8.2040102@gmail.com> <20090817150844.GA3307@elte.hu> <4A89B08A.4010103@gmail.com> <4A8A674E.8070200@redhat.com> <4A8ABEC9.6090006@gmail.com> <4A8AD678.7050609@redhat.com> <4A8B9B79.9050004@gmail.com> <4A8BA5AE.3030308@redhat.com> <4A8C43D3.7030002@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, kvm@vger.kernel.org,
	alacrityvm-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	Patrick Mullaney <pmullaney@novell.com>
To: Gregory Haskins <gregory.haskins@gmail.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <4A8C43D3.7030002@gmail.com>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/19/2009 09:26 PM, Gregory Haskins wrote:
>>> This is for things like the setup of queue-pairs, and the transport of
>>> door-bells, and ib-verbs.  I am not on the team doing that work, so I am
>>> not an expert in this area.  What I do know is having a flexible and
>>> low-latency signal-path was deemed a key requirement.
>>>
>>>        
>> That's not a full bypass, then.  AFAIK kernel bypass has userspace
>> talking directly to the device.
>>      
> Like I said, I am not an expert on the details here.  I only work on the
> vbus plumbing.  FWIW, the work is derivative from the "Xen-IB" project
>
> http://www.openib.org/archives/nov2006sc/xen-ib-presentation.pdf
>
> There were issues with getting Xen-IB to map well into the Xen model.
> Vbus was specifically designed to address some of those short-comings.
>    

Well I'm not an Infiniband expert.  But from what I understand VMM 
bypass means avoiding the call to the VMM entirely by exposing hardware 
registers directly to the guest.

>> This is best done using cr8/tpr so you don't have to exit at all.  See
>> also my vtpr support for Windows which does this in software, generally
>> avoiding the exit even when lowering priority.
>>      
> You can think of vTPR as a good model, yes.  Generally, you can't
> actually use it for our purposes for several reasons, however:
>
> 1) the prio granularity is too coarse (16 levels, -rt has 100)
>
> 2) it is too scope limited (it covers only interrupts, we need to have
> additional considerations, like nested guest/host scheduling algorithms
> against the vcpu, and prio-remap policies)
>
> 3) I use "priority" generally..there may be other non-priority based
> policies that need to add state to the table (such as EDF deadlines, etc).
>
> but, otherwise, the idea is the same.  Besides, this was one example.
>    

Well, if priority is so important then I'd recommend exposing it via a 
virtual interrupt controller.  A bus is the wrong model to use, because 
its scope is only the devices it contains, and because it is system-wide 
in nature, not per-cpu.

>>> This is where the really fast call() type mechanism is important.
>>>
>>> Its also about having the priority flow-end to end, and having the vcpu
>>> interrupt state affect the task-priority, etc (e.g. pending interrupts
>>> affect the vcpu task prio).
>>>
>>> etc, etc.
>>>
>>> I can go on and on (as you know ;), but will wait till this work is more
>>> concrete and proven.
>>>
>>>        
>> Generally cpu state shouldn't flow through a device but rather through
>> MSRs, hypercalls, and cpu registers.
>>      
>
> Well, you can blame yourself for that one ;)
>
> The original vbus was implemented as cpuid+hypercalls, partly for that
> reason.  You kicked me out of kvm.ko, so I had to make due with plan B
> via a less direct PCI-BRIDGE route.
>    

A bus has no business doing these things.  But cpu state definitely 
needs to be manipulated using hypercalls, see the pvmmu and vtpr 
hypercalls or the pvclock msr.

> But in reality, it doesn't matter much.  You can certainly have "system"
> devices sitting on vbus that fit a similar role as "MSRs", so the access
> method is more of an implementation detail.  The key is it needs to be
> fast, and optimize out extraneous exits when possible.
>    

No, percpu state belongs in the vcpu model, not the device model.  cpu 
priority is logically a cpu register or state, not device state.



>> Well, do you plan to address this before submission for inclusion?
>>      
> Maybe, maybe not.  Its workable for now (i.e. run as root), so its
> inclusion is not predicated on the availability of the fix, per se (at
> least IMHO).  If I can get it working before I get to pushing the core,
> great!  Patches welcome.
>    

The lack of so many feature indicates the whole thing is immature.  That 
would be find if the whole thing was the first of its kind, but it isn't.

> For the time being, windows will not be RT, and windows can fall-back to
> use virtio-net, etc.  So I am ok with this.  It will come in due time.
>
>    

So we need to work on optimizing both virtio-net and venet.  Great.

>>> The point is: the things we build on top have costs associated with
>>> them, and I aim to minimize it.  For instance, to do a "call()" kind of
>>> interface, you generally need to pre-setup some per-cpu mappings so that
>>> you can just do a single iowrite32() to kick the call off.  Those
>>> per-cpu mappings have a cost if you want them to be high-performance, so
>>> my argument is that you ideally want to limit the number of times you
>>> have to do this.  My current design reduces this to "once".
>>>
>>>        
>> Do you mean minimizing the setup cost?  Seriously?
>>      
> Not the time-to-complete-setup overhead.  The residual costs, like
> heap/vmap usage at run-time.  You generally have to set up per-cpu
> mappings to gain maximum performance.  You would need it per-device, I
> do it per-system.  Its not a big deal in the grand-scheme of things,
> really.  But chalk that up as an advantage to my approach over yours,
> nonetheless.
>    

Without measurements, it's just handwaving.
>> I guess it isn't that important then.  I note that clever prioritization
>> in a guest is pointless if you can't do the same prioritization in the
>> host.
>>      
> I answer this below...
>
> The point is that I am eliminating as many exits as possible, so 1us,
> 2us, whatever...it doesn't matter.  The fastest exit is the one you
> don't have to take.
>    

You'll still have to exit if the host takes a low priority interrupt, 
schedule the irq thread according to its priority, and return to the 
guest.  At this point you may as well inject the interrupt and let the 
guest do the same thing.

>> IIRC we reuse the PCI IDs for non-PCI.
>>      
>
> You already know how I feel about this gem.
>    

The earth keeps rotating despite the widespread use of PCI IDs.

>> I'm not okay with it.  If you wish people to adopt vbus over virtio
>> you'll have to address all concerns, not just yours.
>>      
> By building a community around the development of vbus, isnt this what I
> am doing?  Working towards making it usable for all?
>    

I've no idea if you're actually doing that.  Maybe inclusion should be 
predicated on achieving feature parity.

>>>> and multiqueue out of your design.
>>>>
>>>>          
>>> AFAICT, multiqueue should work quite nicely with vbus.  Can you
>>> elaborate on where you see the problem?
>>>
>>>        
>> You said you aren't interested in it previously IIRC.
>>
>>      
> I don't think so, no.  Perhaps I misspoke or was misunderstood.  I
> actually think its a good idea and will be looking to do this.
>    

When I pointed out that multiplexing all interrupts onto a single vector 
is bad for per-vcpu multiqueue, you said you're not interested in that.

>> I agree that it isn't very clever (not that I am a real time expert) but
>> I disagree about dismissing Linux support so easily.  If prioritization
>> is such a win it should be a win on the host as well and we should make
>> it work on the host as well.  Further I don't see how priorities on the
>> guest can work if they don't on the host.
>>      
> Its more about task priority in the case of real-time.  We do stuff with
> 802.1p as well for control messages, etc.  But for the most part, this
> is an orthogonal effort.  And yes, you are right, it would be nice to
> have this interrupt classification capability in the host.
>
> Generally this is mitigated by the use of irq-threads.  You could argue
> that if irq-threads help the host without a prioritized interrupt
> controller, why cant the guest?  The answer is simply that the host can
> afford sub-optimal behavior w.r.t. IDT injection here, where the guest
> cannot (due to the disparity of hw-injection vs guest-injection overheads).
>    

Guest injection overhead is not too bad, most of the cost is the exit 
itself, and you can't avoid that without host task priorities.




>> They had to write 414 lines in drivers/s390/kvm/kvm_virtio.c and
>> something similar for lguest.
>>      
> Well, then I retract that statement.  I think the small amount of code
> is probably because they are re-using the qemu device-models, however.
>    

No that's guest code, it isn't related to qemu.

> Note that I am essentially advocating the same basic idea here.
>    

Right, duplicating existing infrastructure.

>> I don't see what vbus adds to virtio-net.
>>      
> Well, as you stated in your last reply, you don't want it.  So I guess
> that doesn't matter much at this point.  I will continue developing
> vbus, and pushing things your way.  You can opt to accept or reject
> those things at your own discretion.
>    

I'm not the one to merge it.  However my opinion is that it shouldn't be 
merged.

-- 
I have a truly marvellous patch that fixes the bug which this
signature is too narrow to contain.


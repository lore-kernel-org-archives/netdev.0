From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [RFC PATCH v0 1/2] net: bridge: propagate FDB table into hardware
Date: Mon, 13 Feb 2012 07:13:03 -0800
Message-ID: <4F39287F.6030204@intel.com>
References: <20120209032206.32468.92296.stgit@jf-dev1-dcblab>  <20120208203627.035c6b0e@nehalam.linuxnetplumber.net>  <4F34042F.6090806@intel.com>  <20120209094047.3ea7aa56@nehalam.linuxnetplumber.net>  <4F3407F7.9000202@intel.com> <1328821894.2089.3.camel@mojatatu>  <4F347D96.2020806@intel.com>  <4F3499BC.8020609@intel.com> <1328887111.2075.43.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: jamal <hadi@cyberus.ca>, Stephen Hemminger <shemminger@vyatta.com>,
	bhutchings@solarflare.com, roprabhu@cisco.com,
	netdev@vger.kernel.org, mst@redhat.com, chrisw@redhat.com,
	davem@davemloft.net, gregory.v.rose@intel.com, kvm@vger.kernel.org,
	sri@us.ibm.com
To: jhs@mojatatu.com
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1328887111.2075.43.camel@mojatatu>
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2/10/2012 7:18 AM, jamal wrote:
> Hi John,
> 
> I went backwards to summarize at the top after going through your email.
> 
> TL;DR version 0.1: 
> you provide a good use case where it makes sense to do things in the
> kernel. IMO, you could make the same arguement if your embedded switch
> could do ACLs, IPv4 forwarding etc. And the kernel bloats.
> I am always bigoted to move all policy control to user space instead of
> bloating in the kernel.
> 
>  
> On Thu, 2012-02-09 at 20:14 -0800, John Fastabend wrote:
> 
>>>
>>> Hi Jamal,
>>>
>>> The user space app in this case would listen for FDB updates to the SW
>>> bridge and then mirror them at the embedded NIC. In this case it seems
>>> easier to just add a notifier chain and let the kernel keep these in
>>> sync. Otherwise we need a daemon in user space to replicate these.
>>>
> 
> A user space daemon if you need to ensure synchronization. Thats what i
> meant when i said there was a "disadvantage" over the simple case when
> the goal is always to synchronize.
> 
>>> On the other hand if you could make the same RTM_NEWNEIGH, RTM_DELNEIGH,
>>> and RTM_GETNEIGH work for the bridge, embedded bridge, and macvlan you
>>> would have one common interface to drive these. But the bridge already
>>> has this protocol/msgtype so that would require either some demux or
>>> new protocol/msgtype pairs to be created. 
>>>
> 
> The bridge is very netlink friendly these days. Given the rest of the
> network stack (*NEIGH* you mention above) talks netlink to user space
> it should be workable. 
> 
>>> Let me think on it. I'm tempted by the simplicity of adding notifier
>>> hooks though.
> 
> If something is missing bridge-side it may need to be added (as Per
> Stephen's comment) - i just took it one further indicating those
> notifiers need to also netlink-speak
> 

Sure.

> 
>> Actually because the bridge is adding/removing fdb entries dynamically
>> maybe its best this gets done in kernel. Here's the example case,
> 
> [..]
> 
>>
>> With the flow by letters above hope this is not too difficult to follow.
> 
>> (A) veth0 a virtual device transmits packet destined for ethx.y
>> (B) SW bridge receives frames and updates FDB flooding to C
>> (C) eth0 the PF in this case sends the frame to the HW backed by the
>>     embedded bridge
> 
> Following so far.
> Can you have more than one PF per embedded switch? Or is the intent here
> purely to do VMs/VF separation?
> 

The use case here is multiple VFs but the same solution should work with
multiple PFs as well. FDB controls should be independent of how the ports
are exposed VFs, PFs, VMDQ/queue pairs, macvlan, etc.

>> (D) The HW embedded switch has a static entry for ethx.y and forwards
>>     the frame to the VF or if its a broadcast frame also floods it to
>>     the wire and ethx.y
> 
> nod.
> 
>> (E) ethx.y receives the frame and generates a response to the dest mac of
>>     veth0
> 
> nod.
> Since you said in #D the entries in the switch are static, I am assuming
> at this point neither ethx.y nor veth0 exist in the embedded FDB.
> 
>> Now here is the potential issue,
>>
>> (G) The frame transmitted from ethx.y with the destination address of
>>     veth0 but the embedded switch is not a learning switch. If the FDB
>>     update is done in user space its possible (likely?) that the FDB
>>     entry for veth0 has not been added to the embedded switch yet. 
> 
> Ok, got it - so the catch here is the switch is not capable of learning.
> I think this depends on where learning is done. Your intent is to
> use the S/W bridge as something that does the learning for you i.e in
> the kernel. This makes the s/w bridge part of MUST-have-for-this-to-run.
> And that maybe the case for your use case.
> 

This is _my_ use case today.

> What if I dont wanna run the S/W bridge at all?
> Ive been making a point that with a simple knob(Stephen doesn like to
> add such a knob), the SW bridge could defer learning to user space. 
> [This way you can add a lot of richness e.g on ACLs such as restricting
> what MAC addresses etc are allowed to talk to which ones etc.].
> But if bypass the s/w bridge all together and learn in user space
> or have a static config in which i populate the embedded switch, i dont
> see the issue.

With events and ADD/DEL/GET FDB controls we can solve both cases. This also
solves Roopa's case with macvlan where he wants to add additional addresses
to macvlan ports.

> 
>> Now
>>     we either have to flood the frame which is not horrible but not
>>     ideal or worse if the embedded switch does not support flooding send
>>     it to the wire and veth0 never receives it. 
> 
> If it is a switch it has to flood, no? Otherwise it sounds broken.
> 

Yes it should flood here, unless its acting as a 802.1Qbg VEB or VEPA.

>> If the SW bridge pushes
>>     the FDB update down into the embedded switch the address is for
>>     sure in the embedded switches forwarding tables and the switching
>>     works as expected.
> 
> Yes, there is a small gap between the s/w bridge learning and the
> synchronization happening to the embedded nic switch. That gap gets
> larger if you defer learning to user space. But like you said earlier,
> during that gap packets are flooded - and do you care if the
> synchronization doesnt happen immediately?
> 

Maybe not. But the kernel already has the needed signals with one extra
hook we can save running a daemon in user space. Maybe that's not a great
argument to add kernel code though.

>> So to handle this case correctly its probably best IMHO to use a notifier
>> hook. Having a RTM_GETNEIGH for the embedded switch implemented though
>> would be nice for dumping the FDB of the embedded switch and SET/DEL
>> could be used to configure the FDB when its not being driven by the SW
>> switch. Of course we should try to be minimalists here.
> 
> Do you need to have a different *NEIGH* than what we already have
> really?
> 

The PF_BRIDGE:RTM_GETNEIGH,RTM_NEWNEIGH,RTM_DELNEIGH are registered in the
br_netlink_init() path. Adding notifier hooks here might be possible but
I'm wondering if its better to add new message types or tear apart the
existing bridging events. I'll play with the code some today and see what
works out better. As Stephen noted the PF_UNSPEC:RTM_XXX events in the
neighbor code are not really for bridging.

> The problem with putting policies in the kernel is you are gonna keep
> adding more. Bloat user space instead. 
> 

Agree policy is best left for user space.

Thanks,
John

> cheers,
> jamal
> 
> 


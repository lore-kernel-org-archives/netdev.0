From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next-2.6 2/2] bonding: allow user-controlled output
 slave selection
Date: Fri, 14 May 2010 01:53:27 -0700
Message-ID: <4BED0F87.6020601@intel.com>
References: <20100511003245.GB7497@gospo.rdu.redhat.com> <17897.1273608579@death.nxdomain.ibm.com> <20100512002725.GA2460@localhost.localdomain> <25238.1273693314@death.nxdomain.ibm.com> <20100512221408.GI7497@gospo.rdu.redhat.com> <4BEBAAF4.5040904@intel.com> <3797.1273776862@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:40953 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752021Ab0ENIxd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 May 2010 04:53:33 -0400
In-Reply-To: <3797.1273776862@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> John Fastabend <john.r.fastabend@intel.com> wrote:
> 
>> Andy Gospodarek wrote:
>>> On Wed, May 12, 2010 at 12:41:54PM -0700, Jay Vosburgh wrote:
> [...]
>>>>       One goal I'm hoping to achieve is something that would satisfy
>>>> both the queue map stuff that you're looking for, and would meet the
>>>> needs of the FCOE people who also want to disable the duplicate
>>>> suppression (i.e., permit incoming traffic on the inactive slave) for a
>>>> different special case.
>>>>
>>>>       The FCOE proposal revolves around, essentially, active-backup
>>>> mode, but permitting incoming traffic on the inactive slave.  At the
>>>> moment, the patches attempt to special case things such that only
>>>> dev_add_pack listeners directly bound to the inactive slave are checked
>>>> (to permit the FCOE traffic to pass on the inactive slave, but still
>>>> dropping IP, as ip_rcv is a wildcard bind).
>>>>
>>>>       Your keep_all patch is, by and large, the same thing, except
>>>> that it permits anything to come in on the "inactive" slave, and it's a
>>>> switch that has to be turned on.
>>>>
>>>>       This seems like needless duplication to me; I'd prefer to see a
>>>> single solution that handles both cases instead of two special cases
>>>> that each do 90% of what the other does.
>>>>
>>>>       As far as a new mode goes, one major reason I think a separate
>>>> mode is warranted is the semantics: with either of these changes (to
>>>> permit more or less regular use of the "inactive" slaves), the mode
>>>> isn't really an "active-backup" mode any longer; there is no "inactive"
>>>> or "backup" slave.  I think of this as being a major change of
>>>> functionality, not simply a minor option.
>>>>
>>>>       Hence my thought that "active-backup" could stay as a "true" hot
>>>> standby mode (backup slaves are just that: for backup, only), and this
>>>> new mode would be the place to do the special queue-map / FCOE /
>>>> whatever that isn't really a hot standby configuration any longer.
>>>>
>>>>       As far as the behavior of the new mode (your concern about its
>>>> policy map approximations), in the end, it would probably act pretty
>>>> much like active-backup with your patch applied: traffic goes out the
>>>> active slave, unless directed otherwise.  It's a lot less complicated
>>>> than I had feared.
>>>>
>>> It's beginning to sound like the 'FCoE use-case' and the one Neil and I
>>> are proposing are quite similar.  The main goal of both is to have the
>>> option to have multiple slaves send and receive traffic during the
>>> steady-state, but in the event of a failover all traffic would run on a
>>> single interface.
>>>
>> I believe they are similar although I never considered using FCoE over a
>> device that is actually in the bond.  For example the current FCoE use
>> case is,
>>
>> bond0 ------> ethx
>>               |
>> vlan-fcoe -->  |
>>
>> Here vlan-fcoe is not a slave of bond0.  With the keep_all patch this
>> would work plus an additional configuration,
> 
>         I also recall discussion that another valid FCOE configuration
> is to simply bind to ethx, with no VLANs involved.
> 

Correct this is valid and works today because the skb will be delivered 
to exact matches in this case.

>> bond0 --> vlan-fcoe1  ---> ethx
>>   \                        |
>>    \ --- vlan-fcoe2  --->  |
>>
>> Here both vlan-fcoe1 and vlan-fcoe2 are slaves of bond0.
>>
>> Even with the keep_all patch it still seems a little inconsistent to drop
>> a packet outright if it is received on an inactive slave and destined for
>> a vlan on the bond and then to deliver the packet to devices that have
>> exact matches if it is received on an inactive slave but destined for the
>> bond device.  I'll post a patch in just a moment that hopefully
>> illustrates what I see as an unexpected side effect.
> 
>         Yes, I understand this, and I view this as a separate concern
> from the duplicate suppressor (although they are linked to a degree).

OK, my third patch adding bond_should_drop flag to the sk_buff struct 
should address this.

> 
>         The ultimate intent (for your changes) is to permit slaves to
> operate simultaneously as members of the bond as well as independent
> entities, which is a significant behavior change from the past.
> 

I expect the primary use case to be attaching a vlan outside the bond 
over a enslaved real device.  Most of this is already implemented though 
by delivering skbs to exact matches in the inactive case.

>>> The implementation proposed with this patch is a bit different that the
>>> 'mark-mode' patch you may recall I posted a few months ago.  It created
>>> a new mode that essentially did exactly what you are describing --
>>> transmit on the primary interface unless pushed to another interface via
>>> info in the skb and receive on all interfaces.  We initially did not
>>> create a new mode based on your reservations about the previous
>>> mark-mode patch and went the direction of enhancing one or two modes
>>> initially (figuring it would be good to run before walking), with the
>>> idea that other modes could take care of this output slave selection
>>> logic in the future.
>>>
>>>
>>>>>>    I presume you're overloading active-backup because it's not
>>>>>> etherchannel, 802.3ad, etc, and just talks right to the switch.  For the
>>>>>> regular load balance modes, I still think overlay into the existing
>>>>>> modes is preferable (more on that later); I'm thinking of "manual"
>>>>>> instead of another tweak to active-backup.
>>>>>>
>>>>>>    If users want to have actual hot-standby functionality, then
>>>>>> active-backup would do that, and nothing else (and it can be multi-queue
>>>>>> aware, but only one slave active at a time).
>>>>>>
>>>>> Yes, but active backup doesn't provide prefered output path selection in and of
>>>>> itself.  Thats the feature here.
>>>>       I understand that; I'm suggesting that active-backup should
>>>> provide no service other than hot standby, and not be overloaded into a
>>>> manual load balancing scheme (both for your use, and for FCOE).
>>>>
>>>>       Maybe I'm worrying too much about defending the purity of the
>>>> active-backup mode; I understand what you're trying to do a little
>>>> better now, and yes, the "manual" mode I think of (in your queue mapping
>>>> scheme, not the other doodads I talked about) would basically be
>>>> active-backup with your queue mapper, minus the duplicate suppressor.
>>>>
>>> It doesn't matter terribly to me which direction is taken.  Again, a
>>> major reason this route was proposed was that you were not as keen on
>>> creating a new mode as I was at the time of that patch posting.  It's
>>> somewhat understandable as once a mode is added it's tough to take away,
>>> but when one sees how much we are really changing the way active-backup
>>> might behave in some cases maybe it makes sense to use a new mode?
>>>
>>> I guess I like the idea of adding this output selection to existing
>>> modes because it at least gives us the option to use queue maps to
>>> select output interfaces for more than a mode that looks like
>>> present-day active-backup minus the duplicate suppression.   I'm happy to
>>> code-up a patch that creates a new mode, but before I go do that and
>>> test it, I'd like to know we have come to an agreement on the direction
>>> for the future.
>>>
>>>>>>    Users who want the set of bonded slaves to look like a big
>>>>>> multiqueue buffet could use this "manual" mode and set things up however
>>>>>> they want.  One way to set it up is simply that the bond is N queues
>>>>>> wide, where N is the total of the queue counts of all the slaves.  If a
>>>>>> slave fails, N gets smaller, and the user code has to deal with that.
>>>>>> Since the queue count of a device can't change dynamically, the bond
>>>>>> would have to actually be set up with some big number of queues, and
>>>>>> then only a subset is actually active (or there is some sort of wrap).
>>>>>>
>>>>>>    In such an implementation, each slave would have a range of
>>>>>> queue IDs, not necessarily just one.  I'm a bit leery of exposing an API
>>>>>> where each slave is one queue ID, as it could make transitioning to real
>>>>>> multi-queue awareness difficult.
>>>>>>
>>>>> I'm sorry, what exactly do you mean when you say 'real' multi queue
>>>>> awareness?  How is this any less real than any other implementation?  The
>>>>> approach you outline above isn't any more or less valid than this one.
>>>>       That was my misunderstanding of how you planned to handle
>>>> things.  I had thought this patch was simply a scheme to use the queue
>>>> IDs for slave selection, without any method to further perform queue
>>>> selection on the slave itself (I hadn't thought of placing a tc action
>>>> on the slave itself, which you described later on).  I had been thinking
>>>> in terms of schemes to expose all of the slave queues on the bonding
>>>> device.
>>> It wasn't our original intention either.  I didn't mention it in my
>>> original post as it wasn't really the intent of our patch, but a nice
>>> side-effect for the informed user. :) Obviously a bit more testing could
>>> take place and we could add more examples to the documentation for the
>>> nice side-effect feature of this patch, but since this wasn't our
>>> original intent and we didn't test it, we did not advertise it.
>>>
>>>>       So, I don't see any issues with the queue mapping part.  I still
>>>> want to find a common solution for FCOE / your patch with regards to the
>>>> duplicate suppressor.
>>> Understood.
>>>
>>>>> While we're on the subject, Andy and I did discuss a model simmilar to what you
>>>>> describe above (what I'll refer to as a queue id passthrough model), in which
>>>>> you can tell the bonding driver to map a frame to a queue, and the bonding
>>>>> driver doesn't really do anything with the queue id other than pass to the slave
>>>>> device for hardware based multiqueue tx handling.  While we could do that, its
>>>>> my feeling such a model isn't the way to go for two primary reasons:
>>>>>
>>>>> 1) Inconsistent behavior.  Such an implementation makes assumptions regarding
>>>>> queue id specification within a driver.  For example, What if one of the slaves
>>>>> reserves some fixed number of low order queues for a sepecific purpose, and as
>>>>> such general use queues begin an at offset from zero, while other slaves do not.
>>>>> While its easy to accomidate such needs when writing the tc filters, if a slave
>>>>> fails over, such a bias would change output traffic behavior, as the bonding
>>>>> driver can't be clearly informed of such a bias.  Likewise, what if a slave
>>>>> driver allocates more queues than it actually supports in hardware (like the
>>>>> implementation you propose, ixgbe IIRC actually does this).  If slaves handled
>>>>> unimplemented tx queues different (if one wrapped queues, while the other simply
>>>>> dropped frames to unimplemented queues for instance).  A failover would change
>>>>> traffic patterns dramatically.
>>>>>
>>>>> 2) Need.  While (1) can pretty easily be managed with a few configuration
>>>>> guidelines (output queues on slaves have to be configured identically, lets
>>>>> chaos and madness befall you, etc), theres really no reason to bind users to
>>>>> such a system.  We're using tc filters to set the queue id on skbs enqueued to
>>>>> the bonding driver, theres absolutely no reason you can add addition filters to
>>>>> the slaves directly.  Since the bonding driver uses dev_queue_xmit to send a
>>>>> frame to a slave, it has the opportunity to pass through another set of queuing
>>>>> diciplines and filters that can reset and re-assign the skbs queue mapping.  So
>>>>> with the approach in this patch you can get both direct output control without
>>>>> sacrificing actual hardware tx output queue control.  With a passthrough model,
>>>>> you save a bit of filter configuration, but at the expense of having to be much
>>>>> more careful about how you configure your slave nics, and detecting such errors
>>>>> in configuration would be rather difficult to track down, as it would require
>>>>> the generation of traffic that hit the right filter after a failover.
>>>>       I don't disagree with any of this.  One thought I do have is
>>>> that Eric Dumazet, I believe, has mentioned that the read lock in
>>>> bonding is a limiting factor on 10G performance.  In the far distant
>>>> future when bonding is RCU, going through the lock(s) on the tc actions
>>>> of the slave could have the same net effect, and in such a case, a
>>>> qdisc-less path may be of benefit.  Not a concern for today, I suspect.
>>>>
>>>>>>    There might also be a way to tie it in to the new RPS code on
>>>>>> the receive side.
>>>>>>
>>>>>>    If the slaves all have the same MAC and attach to a single
>>>>>> switch via etherchannel, then it all looks pretty much like a single big
>>>>>> honkin' multiqueue device.  The switch probably won't map the flows back
>>>>>> the same way, though.
>>>>>>
>>>>> I agree, they probably wont.  Receive side handling wasn't really our focus here
>>>>> though.  Thats largely why we chose round robin and active backup as our first
>>>>> modes to use this with.  They are already written to expect frames on either
>>>>> interface.
>>>>>
>>>>>>    If the slaves are on discrete switches (without etherchannel),
>>>>>> things become more complicated.  If the slaves have the same MAC, then
>>>>>> the switches will be irritated about seeing that same MAC coming in from
>>>>>> multiple places.  If the slaves have different MACs, then ARP has the
>>>>>> same sort of issues.
>>>>>>
>>>>>>    In thinking about it, if it's linux bonding at both ends, there
>>>>>> could be any number of discrete switches in the path, and it wouldn't
>>>>>> matter as long as the linux end can work things out, e.g.,
>>>>>>
>>>>>>         -- switch 1 --
>>>>>> hostA  /              \  hostB
>>>>>> bond  ---- switch 2 ---- bond
>>>>>>        \              /
>>>>>>         -- switch 3 --
>>>>>>
>>>>>>    For something like this, the switches would never share MAC
>>>>>> information for the bonding slaves.  The issue here then becomes more of
>>>>>> detecting link failures (it would require either a "trunk failover" type
>>>>>> of function on the switch, or some kind of active probe between the
>>>>>> bonds).
>>>>>>
>>>>>>    Now, I realize that I'm babbling a bit, as from reading your
>>>>>> description, this isn't necessarily your target topology (which sounded
>>>>>> more like a case of slave A can reach only network X, and slave B can
>>>>>> reach anywhere, so sending to network X should use slave A
>>>>>> preferentially), or, as long as I'm doing ASCII-art,
>>>>>>
>>>>>>        --- switch 1 ---- network X
>>>>>> hostA /               /
>>>>>> bond  ---- switch 2 -+-- anywhere
>>>>>>
>>>>>>    Is that an accurate representation?  Or is it something a bit
>>>>>> different, e.g.,
>>>>>>
>>>>>>        --- switch 1 ---- network X -\
>>>>>> hostA /                             /
>>>>>> bond  ---- switch 2 ---- anywhere --
>>>>>>
>>>>>>    I.e., the "anywhere" connects back to network X from the
>>>>>> outside, so to speak.  Or, oh, maybe I'm missing it entirely, and you're
>>>>>> thinking of something like this:
>>>>>>
>>>>>>        --- switch 1 --- VPN --- web site
>>>>>> hostA /                          /
>>>>>> bond  ---- switch 2 - Internet -/
>>>>>>
>>>>>>    Where you prefer to hit "web site" via the VPN (perhaps it's a
>>>>>> more efficient or secure path), but can do it from the public network at
>>>>>> large if necessary.
>>>>>>
>>>>> Yes, this one.  I think the other models are equally interesting, but this model
>>>>> in which either path had universal reachabilty, but for some classes of traffic
>>>>> one path is preferred over the other is the one we had in mind.
>>>>>
>>>>>>    Now, regardless of the above, your first patch ("keep_all") is
>>>>>> to deal with the reverse problem, if this is a piggyback on top of
>>>>>> active-backup mode: how to get packets back, when both channels can be
>>>>>> active simultaneously.  That actually dovetails to a degree with work
>>>>>> I've been doing lately, but the solution there probably isn't what
>>>>>> you're looking for (there's a user space daemon to do path finding, and
>>>>>> the "bond IP" address is piggybacked on the slaves' MAC addresses, which
>>>>>> are not changed; the "bond IP" set exists in a separate subnet all its
>>>>>> own).
>>>>>>
>>>>>>    As I said, I'm not convinced that the "keep_all" option to
>>>>>> active-backup is really better than just a "manual" mode that lacks the
>>>>>> dup suppression and expects the user to set everything up.
>>>>>>
>>>>>>    As for the round-robin change in this patch, if I'm reading it
>>>>>> right, then the way it works is that the packets are round-robined,
>>>>>> unless there's a queue id passed in, in which case it's assigned to the
>>>>>> slave mapped to that queue id.  I'm not entirely sure why you picked
>>>>>> round-robin mode for that over balance-xor; it doesn't seem to fit well
>>>>>> with the description in the documentation.  Or is it just sort of a
>>>>>> demonstrator?
>>>>>>
>>>>> It was selected because round robin allows transmits on any interface already,
>>>>> and expects frames on any interface, so it was a 'safe' choice.  I would think
>>>>> balance-xor would also work.  Ideally it would be nice to get more modes
>>>>> supporting this mechanism.
>>>>       I think that this should work for balance-xor and 802.3ad.  The
>>>> only limitation for 802.3ad is that the spec requires "conversations" to
>>>> not be striped or to skip around in a manner that could lead to out of
>>>> order delivery.
>>> Agreed.  Checking would probably also have to be done to make sure that
>>> we were not trasmitting on an inactive aggregator.
>>>
>>>>       I'm not so sure about the alb/tlb modes; at first thought, I
>>>> think it could have conflicts with the internal balancing done within
>>>> the modes (if, e.g., the tc action put traffic for the same destination
>>>> on two slaves).
>>>>
>>> TLB and ALB modes would certainly have to be done differently.  It
>>> should not be terribly difficult to move from the existing hashing
>>> that's done to one that relies on the queue_mapping, but it will take a
>>> bit to make sure it's not a complete hack.
>>>
>>> We decided against doing that for all modes on the first pass as it
>>> seemed like the active-backup and round-robin were the most-likely
>>> users.  We also wanted present the code early rather that spending time
>>> supporting this on every-mode to find out that it just wasn't rational
>>> to do it on some of them.
>>>
>>>>>>    I do like one other aspect of the patch, and that's the concept
>>>>>> of overlaying the queue map on top of the balance algorithm.  So, e.g.,
>>>>>> balance-xor would do its usual thing, unless the packet is queue mapped,
>>>>>> in which case the packet's assignment is obeyed.  The balance-xor could
>>>>>> even optionally do its xor across the full set of all slaves output
>>>>>> queues instead of just across the slaves.  Round-robin can operate
>>>>>> similarly.  For those modes, a "balance by queue vs. balance by slave"
>>>>>> seems like a reasonable knob to have.
>>>>> Not sure what you mean here.  In the model implemented by this patch, there is
>>>>> one output queue per slave, and as such, balance by queue == balance by slave.
>>>>> That would make sense in the model you describe earlier in this note, but not in
>>>>> the model presented by this patch.
>>>>       Yes, I was thinking about what I had described; again,
>>>> predicated on my misunderstanding of how it all worked.
>>>>
>>>>>>    I do understand that you're proposing something relatively
>>>>>> simple, and I'm thinking out loud about alternate or additional
>>>>>> implementation details.  Some of this is "ooh ahh what if", but we also
>>>>>> don't want to end up with something that's forwards incompatible, and
>>>>>> I'm hoping to find one solution to multiple problems.
>>>>>>
>>>>> For clarification, can you ennumerate what other problems you are trying to
>>>>> solve with this feature, or features simmilar to this?  From this email, the one
>>>>> that I most clearly see is the desire to allow a passthrough mode of queue
>>>>> selection, which I think I've noted can be done already (even without this
>>>>> patch), by attaching additional tc filters to the slaves output queues directly.
>>>>> What else do you have in mind?
>>>>       As I said above, I hadn't thought of stacking tc actions on to
>>>> the slaves directly, so I was thinking on ways to expose the slave
>>>> queues.
>>>>
>>>>       I still find something intriguing about a round-robin or xor
>>>> mode that robins/xors through all of the slave queues, though, but that
>>>> should be something separate (I'm not sure if such a scheme is actually
>>>> "better", either).
>>>>
>>>>       -J
>> It would be best if there was a solution for the FCoE use case that works
>> with the current bonding modes including 802.3ad.  There is switch support
>> to run mpio FCoE while doing link aggregation on the LAN side that we
>> should support.  I'm not sure the keep_all patch would be good in this
>> case Jay I think you mentioned this at some point, but I missed the
>> conclusion?  Although maybe it would be OK I'll think about it some more
>> tomorrow.
> 
>         How does that mpio FCOE / switch support function?  Does it rely
> on utilizing ports (for the FC traffic) that are not members of the
> 802.3ad active aggregator?  E.g.:
> 
>        / eth0,eth1 -- switch A -- etc
> bond0 -
>        \ eth2,eth3 -- switch B -- etc
> 
>         Bond0 has four slaves, eth0 - eth3.  Eth0 and eth1 connect to
> switch A; eth2 and eth3 to switch B.  Presuming that the switches aren't
> stacked / magic, either eth0/eth1 or eth2/eth3 will be the active
> aggregator (linux bonding only supports one active aggregator).
> 
>         Am I correct in presuming that the FCOE balancer gizmo doesn't
> care about the 802.3ad state of the ports, and it and the switch will
> run FC traffic across all four ports, regardless of which ports are
> active and which are not?
> 
>         Or is the switch even simpler than that, and it processes all
> FCOE traffic to ports, regardless of how the ports are configured
> (etherchannel, 802.3ad, etc)?
>

The switch is simple and FCoE traffic is bound to ports which are in 
turn bound to VSAN (virtual SAN) ports on the FC side.  So the FCoE 
traffic works regardless of how the ports are configured (etherchannel, 
802.3ad, etc).

>         As for other bonding modes, balance-xor or balance-rr (round
> robin) shouldn't have the same problems with the duplicate suppression
> logic that active-backup and 802.3ad have.  The alb/tlb modes might or
> might not be workable at all, depending upon how the FCOE traffic looks
> (e.g., what source and destination MAC addresses are in the FCOE
> frames?).

We have the ability to use a SAN MAC that can be different then the LAN 
MAC which should allow this to work.

> 
>         In any event, wanting to run FCOE in conjunction with a variety
> of bonding modes suggests that Neil was right all along, and the
> duplicate suppressor change should be an option, not a new mode.

This should be OK, but all FCoE really needs is skbs to be delivered to 
devices that have packet handlers with exact matches.  Basically, making 
  the inactive VLAN case behave the same as an inactive real device.

Thanks,
John


> 
>         -J
> 
> ---
>         -Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com


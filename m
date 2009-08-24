From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce
	primary_lazy option
Date: Mon, 24 Aug 2009 13:16:19 +0200
Message-ID: <20090824111619.GC4018@psychotron.englab.brq.redhat.com>
References: <20090813150513.GB10449@psychotron.englab.brq.redhat.com> <4A846C4E.8030509@free.fr> <20090814105938.GE3457@psychotron.englab.brq.redhat.com> <4A859057.3020606@free.fr> <20090817114938.GA3416@psychotron.englab.brq.redhat.com> <4A89C3B1.3070509@free.fr> <20090818124550.GB3539@psychotron.englab.brq.redhat.com> <4A8D4427.8080004@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Nicolas de =?iso-8859-1?Q?Peslo=FCan?= <nicolas.2p.debian@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8729 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752256AbZHXLQa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Aug 2009 07:16:30 -0400
Content-Disposition: inline
In-Reply-To: <4A8D4427.8080004@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thu, Aug 20, 2009 at 02:40:07PM CEST, nicolas.2p.debian@free.fr wrote:
> Jiri Pirko awrote:
>> Mon, Aug 17, 2009 at 10:55:13PM CEST, nicolas.2p.debian@free.fr wrote:
>>> Jiri Pirko wrote:
>>>> Fri, Aug 14, 2009 at 06:27:03PM CEST, nicolas.2p.debian@free.fr wrote:
>>>>> Jiri Pirko wrote:
>>>>>> Thu, Aug 13, 2009 at 09:41:02PM CEST, nicolas.2p.debian@free.fr wrote:
>>>>>>> Jiri Pirko wrote:
>>>>>>>> In some cases there is not desirable to switch back to primary interface when
>>>>>>>> it's link recovers and rather stay wiith currently active one. We need to avoid
>>>>>>>> packetloss as much as we can in some cases. This is solved by introducing
>>>>>>>> primary_lazy option. Note that enslaved primary slave is set as current
>>>>>>>> active no matter what.
>>>>>>> May I suggest that instead of creating a new option to better define how
>>>>>>> the "primary" option is expected to behave for active-backup  
>>>>>>> mode, we  try the "weight" slave  option I proposed in the 
>>>>>>> thread "alternative to  primary" earlier this year ?
>>>>>>>
>>>>>>> http://sourceforge.net/mailarchive/forum.php?thread_name=49D5357E.4020201%40free.fr&forum_name=bonding-devel
>>>>>> This link does not work for me :(
>>>>> Nor for me... Sourceforge apparently decided to drop the  
>>>>> bonding-devel  list archive just now. 'hope the list archive will 
>>>>> be back soon.
>>>>>
>>>>> Originally, the proposed "weight" option for slaves was designed 
>>>>> just to  provide a way to better define which slave should become 
>>>>> active when the  active one just went down. As you know, the 
>>>>> current "primary" option  does not allow for a predictable 
>>>>> selection of the new active slave when  the primary loose 
>>>>> connectivity. The new active slave is chosen "at  random" between 
>>>>> the remaining slaves.
>>>>>
>>>>> After a short thread, involving Jay Vosburg and Andy Gospodarek, 
>>>>> we end  up with a general configuration interface, that provide a 
>>>>> way to tune  many things in slave management :
>>>>>
>>>>> - Active slave selection in active/backup mode, even in the 
>>>>> presence of  more than two slaves.
>>>>> - Active aggregator selection in 802.3ad mode.
>>>>> - Load balancing tuning for most load balancing modes.
>>>>>
>>>>> The sysfs interface would be /sys/class/net/eth0/bonding/weight.  
>>>>> Writing  a number there would give a "user supplied weight" to a  
>>>>> slave. The speed  and link state of the slave would give a 
>>>>> "natural weight" for the slave.  And the "effective weight" would 
>>>>> be computed every time one of user  supplied or natural weight 
>>>>> change (upon speed or link state changes) and  would be used 
>>>>> everywhere we need a slave weight.
>>>>>
>>>>> I suggest that :
>>>>> - slave's natural weight = speed of the slave if link UP, else 0.
>>>>> - slave's effective weight = slave's natural weight * slave's 
>>>>> user   supplied weight.
>>>>> - aggregator's effective weight = sum of the effective weights of 
>>>>> the  slaves inside the aggregator.
>>>>>
>>>>> For the active/backup mode, the exact behavior would be :
>>>>>
>>>>> - When the active slave disappear, the new active slave is the 
>>>>> one whose  effective weight is the highest.
>>>>> - When a slave comes back, it only becomes active if its 
>>>>> effective   weight is strictly higher than the one of the current 
>>>>> active slave.   (This stop the flip-flop risk you stated).
>>>>> - To keep the old "primary" option, we simply give a very high 
>>>>> user   supplied weight to the primary slave. Jay suggested :
>>>>> #define BOND_PRIMARY_PRIO 0x80000000
>>>>> user_supplied_weight &= BOND_PRIMARY_PRIO /* to set the primary */
>>>>> user_supplied_weight &= ~BOND_PRIMAY_PRIO  /* to clear the primary */
>>>>>
>>>>> The same apply to aggregator : Every time a slave enter (link UP) 
>>>>> or  leave (link DOWN) an aggregator, the aggregator effective 
>>>>> weight is   recomputed. Then, if an aggregator exist with an 
>>>>> strictly higher   effective weight than the current active one, 
>>>>> the new best aggregator  becomes active.
>>>>>
>>>>> For others modes, the weight might be used later to tune the load 
>>>>>   balancing logic in some way.
>>>>>
>>>>> A default value of 1 for slave weight would cause slave speed to 
>>>>> be used  alone, hence the "natural weight".
>>>>>
>>>> I read your text and also the original list thread and I must say I see no
>>>> solution in this "weight" parameter for this issue. Because it's desired for one
>>>> link to stay active even if second come up, these 2 must have the same weight.
>>>> But imagine 3 links of the same weight. In that case you cannot insure that the
>>>> "primary one" will be chosen as active (see my picture in the reply to Jay's
>>>> post). Correct me if I'm wrong but for that what I want to fix by primary_lazy
>>>> option, your proposed weight option has no effect.
>>>>
>>>> Therefor I still think the primary_lazy is the only solution now.
>>>>
>>>> Jirka
>>> Hi Jirka,
>>>
>>> From your previous posts (first one and reply to Jay), I understand 
>>> that your want to achieve  the following behavior :
>>>
>>> eth0 is primary and active.
>>> eth1 is allowed to be active is eth0 is down.
>>> Also, eth1 should stay active, even if eth0 comes back up.
>>> Switch active to eth0 if eth1 eventually fall down.
>>> Switch active to eth2 only if both eth0 and eth1 are down.
>>>
>>> eth0		eth1		eth2
>>> UP(curr)	UP		UP
>>> DOWN		UP(curr)	UP
>>> UP		UP(curr)	UP
>>> UP(curr)	DOWN		UP
>>> DOWN		DOWN		UP(curr)
>>>
>>> Using weight, the following setup should give this result :
>>>
>>> echo 1000 > /sys/class/net/eth0/bonding/weight
>>> echo 1000 > /sys/class/net/eth1/bonding/weight
>>> echo 1 > /sys/class/net/eth2/bonding/weight
>>> echo eth0 > /sys/class/net/bond0/bonding/active_slave
>>>
>>> I hope this is clear now.
>>
>> Hmm... I ment the eth1 and eth2 to be the equivalent...
>> If eth1 is down (let's say for good) and eth0 comes down, eth2 is
>> selected as current active. But when eth0 comes up then eth0 is selected. That
>> is not desired.
>
> OK, now I think I really understand your exact requirement.
>
> You want the ability to keep the current active slave active, even if a
> better slave comes back up, so the only reason for the active slave to
> change would be that the current active slave falls down:
>
> eth0		eth1		eth2
> UP(curr)	UP		UP
> DOWN		UP(curr)	UP
> UP		UP(curr)	UP
> UP(curr)	DOWN		UP
> DOWN		DOWN		UP(curr)
> UP		DOWN		UP(curr)  <-
>
> But at the same time, you still need the ability to properly select the
> best new active slave when the current one falls down, hence your answer
> in reply to Jay's proposal:
>
> 	> But imagine you have bond with 3 slaves:
> 	> eth0		eth1		eth2
> 	> UP(curr)	UP		UP
> 	> DOWN		UP(curr)	UP
> 	> UP		UP(curr)	UP
> 	> UP		DOWN		UP(curr)
>
> 	> eth2 ends up being current active but we prefer eth0 (as
> 	> primary interface).
> 	> This is not desirable and is solved by primary_lazy option.
>
> I think your proposed "primary_lazy" option suffer some limits and
> should not be a per bond option but a per slave option.
>
> You are right that some slave should be able to be "sticky" when active,
> in order to reduce packets loose when switching. But due to performance
> reason, it might be desirable to say that some other slaves are not
> "sticky" when active, in the same configuration.
>
> Let's imagine the following configuration :
>
> eth0: 1 Gb/s - primary
> eth1: 1 Gb/s
> eth2: 100 Mb/s
>
> With "primary_lazy=1, eth2 has a chance to stay active, after eth0
> and eth1 both failed at the same time. The risk of loosing a few packets
> while switching back from eth2 to eth0 or eth1 might be seen acceptable,
> compared to sticking to a 100 Mb/s interface when a 1 Gb/s interface
> is available.
>
> Due to eth2 speed, one might want to have the following behavior:
>
> If eth1 is active, keep it active, even if eth0 comes back up. But if
> eth2 is active, switch to any better slave right at the time one comes
> back up.
>
> I suggest that instead of having a per bond "primary_lazy" option, we
> define a per slave option, describing whether this particular slave is
> "sticky when active" or not.
>
> The above setup would become :
>
> echo 1 > /sys/class/net/eth0/bonding/sticky_active
> echo 1 > /sys/class/net/eth1/bonding/sticky_active
> echo 0 > /sys/class/net/eth2/bonding/sticky_active
> echo eth0 > /sys/class/net/bond0/bonding/primary
>
> Or may be better, keeping the "weight" idea in mind, a per slave option
> "active_weight" that gives the weight of the slave, *when active*.
>
> The effective weight of a slave would become :
>
> effective_slave =
> (is_active ? user_supplied_active_weight ? user_supplied_weight) *
> natural_weight
>
> # Prefer eth0, then one of eth1 or eth2, then eth3.
> echo 1000 > /sys/class/net/eth0/bonding/weight
> echo 999 > /sys/class/net/eth1/bonding/weight
> echo 999 > /sys/class/net/eth2/bonding/weight
> echo 10 > /sys/class/net/eth3/bonding/weight
>
> # Do not switch back to primary eth0 if eth1 or eth2 is active.
> echo 1000 > /sys/class/net/eth1/bonding/active_weight
> echo 1000 > /sys/class/net/eth2/bonding/active_weight
>
> Every time one changes the user_supplied_weight, then
> user_supplied_active_weight must be reset to the same value. This way,  
> if no special setup is done on active_weight, then the current normal
> behavior is achieved.

I must say I like this approach. But it would be not trivial to implement this.
Therefore I would stick with your propose of extending primary lazy to 3 values
until the weight option is implemented.

I'm going to implement your propose below.

>
> If none of those options seem acceptable to you, I suggest a third one:
>
> You keep primary_lazy, but with the following values :
>
> # Switch back to primary slaves when it comes back.
> echo 0 > /sys/class/net/bond0/bonding/primary_lazy
>
> # Switch back to primary when it comes back, only if the speed of the
> # primary slave is higher than the speed of the current active slave.
> echo 1 > /sys/class/net/bond0/bonding/primary_lazy
>
> # Stick to the current active slave when the primary slave comes back,
> # even if the primary slave speed is higher than the speed of the
> # current active slave.
> echo 2 > /sys/class/net/bond0/bonding/primary_lazy
>
> You can consider the value as being the level of laziness of the primary.
>
> 	Nicolas.
>
>>>>>>> Giving the same "weight" to two different slaves means "chose at random
>>>>>>> on startup and keep the active one until it fails". And if the "at
>>>>>>> random" behavior is not appropriate, one can force the active slave
>>>>>>> using what Jay suggested  (/sys/class/net/bond0/bonding/active).
>>>>>>>
>>>>>>> The proposed "weight" slave's option is able to prevent the slaves from
>>>>>>> flip-flopping, by stating the fact that two slaves share the 
>>>>>>> same   "primary" level, and may provide several other 
>>>>>>> enhancements as  described  in the thread.
>>>>>>>
>>>>>> Although I cannot reach the thread, this looks interesting. But I'm not sure it
>>>>>> has real benefits over primary_lazy option (and it doesn't solve initial curr
>>>>>> active slave setup)
>>>>> You are right, it doesn't solve the initial active slave 
>>>>> selection. But  why would it be so important to properly select 
>>>>> the initial active  slave, if you feel comfortable with staying 
>>>>> with a new active slave,  after a failure and return of the 
>>>>> original active slave ? This kind of  failures may last for only 
>>>>> a few seconds (just unplugging and plugging  back the wire), and 
>>>>> you configuration may then stay with the new active  slave 
>>>>> "forever". If "forever" is acceptable, may be "at startup" is  
>>>>> acceptable too. :-)
>>>>>
>>>>> From my point of view (and Andy Gospodarek apparently agreed), 
>>>>> the real  benefits of the weight slave option is that is it more 
>>>>> generic and allow  for later usage in other modes, that we don't 
>>>>> anticipate for now.
>>>>>
>>>>> Quoted from a mail from Andy Gospodarek in the original thread :
>>>>>
>>>>> "I really have no objection to that.  Adding this as a base part of
>>>>> bonding for a few modes with known features would be a nice start.
>>>>> I'm sure others will be kind enough to send suggestions or patches for
>>>>> ways this could benefit other modes."
>
>
>

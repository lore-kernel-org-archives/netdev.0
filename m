From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce	primary_lazy
 option
Date: Fri, 14 Aug 2009 18:27:03 +0200
Message-ID: <4A859057.3020606@free.fr>
References: <20090813150513.GB10449@psychotron.englab.brq.redhat.com> <4A846C4E.8030509@free.fr> <20090814105938.GE3457@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g21.free.fr ([212.27.42.6]:55128 "EHLO smtp6-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755950AbZHNQ1M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2009 12:27:12 -0400
In-Reply-To: <20090814105938.GE3457@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Thu, Aug 13, 2009 at 09:41:02PM CEST, nicolas.2p.debian@free.fr wrote:
>> Jiri Pirko wrote:
>>> In some cases there is not desirable to switch back to primary interface when
>>> it's link recovers and rather stay wiith currently active one. We need to avoid
>>> packetloss as much as we can in some cases. This is solved by introducing
>>> primary_lazy option. Note that enslaved primary slave is set as current
>>> active no matter what.
>> May I suggest that instead of creating a new option to better define how
>> the "primary" option is expected to behave for active-backup mode, we  
>> try the "weight" slave  option I proposed in the thread "alternative to  
>> primary" earlier this year ?
>>
>> http://sourceforge.net/mailarchive/forum.php?thread_name=49D5357E.4020201%40free.fr&forum_name=bonding-devel
> 
> This link does not work for me :(

Nor for me... Sourceforge apparently decided to drop the bonding-devel 
list archive just now. 'hope the list archive will be back soon.

Originally, the proposed "weight" option for slaves was designed just to 
provide a way to better define which slave should become active when the 
active one just went down. As you know, the current "primary" option 
does not allow for a predictable selection of the new active slave when 
the primary loose connectivity. The new active slave is chosen "at 
random" between the remaining slaves.

After a short thread, involving Jay Vosburg and Andy Gospodarek, we end 
up with a general configuration interface, that provide a way to tune 
many things in slave management :

- Active slave selection in active/backup mode, even in the presence of 
more than two slaves.
- Active aggregator selection in 802.3ad mode.
- Load balancing tuning for most load balancing modes.

The sysfs interface would be /sys/class/net/eth0/bonding/weight. Writing 
a number there would give a "user supplied weight" to a slave. The speed 
and link state of the slave would give a "natural weight" for the slave. 
And the "effective weight" would be computed every time one of user 
supplied or natural weight change (upon speed or link state changes) and 
would be used everywhere we need a slave weight.

I suggest that :
- slave's natural weight = speed of the slave if link UP, else 0.
- slave's effective weight = slave's natural weight * slave's user 
supplied weight.
- aggregator's effective weight = sum of the effective weights of the 
slaves inside the aggregator.

For the active/backup mode, the exact behavior would be :

- When the active slave disappear, the new active slave is the one whose 
effective weight is the highest.
- When a slave comes back, it only becomes active if its effective 
weight is strictly higher than the one of the current active slave. 
(This stop the flip-flop risk you stated).
- To keep the old "primary" option, we simply give a very high user 
supplied weight to the primary slave. Jay suggested :
#define BOND_PRIMARY_PRIO 0x80000000
user_supplied_weight &= BOND_PRIMARY_PRIO /* to set the primary */
user_supplied_weight &= ~BOND_PRIMAY_PRIO  /* to clear the primary */

The same apply to aggregator : Every time a slave enter (link UP) or 
leave (link DOWN) an aggregator, the aggregator effective weight is 
recomputed. Then, if an aggregator exist with an strictly higher 
effective weight than the current active one, the new best aggregator 
becomes active.

For others modes, the weight might be used later to tune the load 
balancing logic in some way.

A default value of 1 for slave weight would cause slave speed to be used 
alone, hence the "natural weight".

>> Giving the same "weight" to two different slaves means "chose at random
>> on startup and keep the active one until it fails". And if the "at
>> random" behavior is not appropriate, one can force the active slave
>> using what Jay suggested  (/sys/class/net/bond0/bonding/active).
>>
>> The proposed "weight" slave's option is able to prevent the slaves from
>> flip-flopping, by stating the fact that two slaves share the same  
>> "primary" level, and may provide several other enhancements as described  
>> in the thread.
>>
> 
> Although I cannot reach the thread, this looks interesting. But I'm not sure it
> has real benefits over primary_lazy option (and it doesn't solve initial curr
> active slave setup)

You are right, it doesn't solve the initial active slave selection. But 
why would it be so important to properly select the initial active 
slave, if you feel comfortable with staying with a new active slave, 
after a failure and return of the original active slave ? This kind of 
failures may last for only a few seconds (just unplugging and plugging 
back the wire), and you configuration may then stay with the new active 
slave "forever". If "forever" is acceptable, may be "at startup" is 
acceptable too. :-)

 From my point of view (and Andy Gospodarek apparently agreed), the real 
benefits of the weight slave option is that is it more generic and allow 
for later usage in other modes, that we don't anticipate for now.

Quoted from a mail from Andy Gospodarek in the original thread :

"I really have no objection to that.  Adding this as a base part of
bonding for a few modes with known features would be a nice start.
I'm sure others will be kind enough to send suggestions or patches for
ways this could benefit other modes."

	Nicolas.

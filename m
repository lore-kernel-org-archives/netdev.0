From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?= <nicolas.2p.debian@free.fr>
Subject: Re: [Bonding-devel] [PATCH net-next-2.6] bonding: introduce	primary_lazy
 option
Date: Mon, 24 Aug 2009 17:07:18 +0200
Message-ID: <4A92ACA6.7070600@free.fr>
References: <20090813150513.GB10449@psychotron.englab.brq.redhat.com> <4A846C4E.8030509@free.fr> <20090814105938.GE3457@psychotron.englab.brq.redhat.com> <4A859057.3020606@free.fr> <20090817114938.GA3416@psychotron.englab.brq.redhat.com> <4A89C3B1.3070509@free.fr> <20090818124550.GB3539@psychotron.englab.brq.redhat.com> <4A8D4427.8080004@free.fr> <20090824111619.GC4018@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp23.services.sfr.fr ([93.17.128.21]:53383 "EHLO
	smtp23.services.sfr.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752487AbZHXPHU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2009 11:07:20 -0400
In-Reply-To: <20090824111619.GC4018@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko wrote:
> Thu, Aug 20, 2009 at 02:40:07PM CEST, nicolas.2p.debian@free.fr wrote:
[--cut--]
>> I suggest that instead of having a per bond "primary_lazy" option, we
>> define a per slave option, describing whether this particular slave is
>> "sticky when active" or not.
>>
>> The above setup would become :
>>
>> echo 1 > /sys/class/net/eth0/bonding/sticky_active
>> echo 1 > /sys/class/net/eth1/bonding/sticky_active
>> echo 0 > /sys/class/net/eth2/bonding/sticky_active
>> echo eth0 > /sys/class/net/bond0/bonding/primary
>>
>> Or may be better, keeping the "weight" idea in mind, a per slave option
>> "active_weight" that gives the weight of the slave, *when active*.
>>
>> The effective weight of a slave would become :
>>
>> effective_slave =
>> (is_active ? user_supplied_active_weight ? user_supplied_weight) *
>> natural_weight
>>
>> # Prefer eth0, then one of eth1 or eth2, then eth3.
>> echo 1000 > /sys/class/net/eth0/bonding/weight
>> echo 999 > /sys/class/net/eth1/bonding/weight
>> echo 999 > /sys/class/net/eth2/bonding/weight
>> echo 10 > /sys/class/net/eth3/bonding/weight
>>
>> # Do not switch back to primary eth0 if eth1 or eth2 is active.
>> echo 1000 > /sys/class/net/eth1/bonding/active_weight
>> echo 1000 > /sys/class/net/eth2/bonding/active_weight
>>
>> Every time one changes the user_supplied_weight, then
>> user_supplied_active_weight must be reset to the same value. This way,  
>> if no special setup is done on active_weight, then the current normal
>> behavior is achieved.
> 
> I must say I like this approach. But it would be not trivial to implement this.
> Therefore I would stick with your propose of extending primary lazy to 3 values
> until the weight option is implemented.

It sounds good for me. Later, if I eventually implement the weight option, it 
shouldn't be that hard to convert internally the primary_lazy setup to 
active_weight, the same way we plan to convert internally primary setup to 
weight setup.

primary and primary_lazy are convenient for simple - two slaves only - 
configurations. weight and active_weight are for more advanced configurations. 
Keeping both configuration interface does sound user friendly.

> I'm going to implement your propose below.

By the way, even if I'm not a native English speaker, I think that primary_lazy 
option should be named lazy_primary instead.

	Nicolas.

>> If none of those options seem acceptable to you, I suggest a third one:
>>
>> You keep primary_lazy, but with the following values :
>>
>> # Switch back to primary slaves when it comes back.
>> echo 0 > /sys/class/net/bond0/bonding/primary_lazy
>>
>> # Switch back to primary when it comes back, only if the speed of the
>> # primary slave is higher than the speed of the current active slave.
>> echo 1 > /sys/class/net/bond0/bonding/primary_lazy
>>
>> # Stick to the current active slave when the primary slave comes back,
>> # even if the primary slave speed is higher than the speed of the
>> # current active slave.
>> echo 2 > /sys/class/net/bond0/bonding/primary_lazy
>>
>> You can consider the value as being the level of laziness of the primary.
>>
>> 	Nicolas.
>>



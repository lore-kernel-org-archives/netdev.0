From: Ben Greear <greearb@candelatech.com>
Subject: Re: Routing tables associated with VLANs dissappear when parent ethX
 down/up
Date: Wed, 21 Nov 2007 13:52:35 -0800
Message-ID: <4744A8A3.8060406@candelatech.com>
References: <474387E4.7020802@candelatech.com>	<47448C4F.3060107@candelatech.com> <20071121120027.54c277ea@freepuppy.rosehill> <4744943E.2010000@trash.net> <47449AE9.5020301@candelatech.com> <47449F57.7080500@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	NetDev <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:50266 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752579AbXKUVwn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Nov 2007 16:52:43 -0500
In-Reply-To: <47449F57.7080500@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
>> Patrick McHardy wrote:
>>> Stephen Hemminger wrote:
>>>>
>>>> But then if you are doing bonding or bridging of vlan's and you 
>>>> bring down the root network device, the upper layer is not
>>>> notified (for failover).
>>>>   
>>>
>>> operstate should be enough for this I guess. Ben, what does iproute show
>>> for the vlan device when the lower device is down?
>>
>> It looks like it knows, assuming M-DOWN is useful information.
>> Eth2 is un-plugged, by the way.
>>
>> [root@lanforge-33-46 ~]# ifconfig eth2 up
>> [root@lanforge-33-46 ~]# ip link show eth2.2
>> 125: eth2.2@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc 
>> noqueue
>>     link/ether 00:03:2d:08:33:47 brd ff:ff:ff:ff:ff:ff
>> [root@lanforge-33-46 ~]# ifconfig eth2 down
>> [root@lanforge-33-46 ~]# ip link show eth2.2
>> 125: eth2.2@eth2: <NO-CARRIER,BROADCAST,MULTICAST,UP,M-DOWN> mtu 1500 
>> qdisc noqueue
>>     link/ether 00:03:2d:08:33:47 brd ff:ff:ff:ff:ff:ff
>> [root@lanforge-33-46 ~]# 
> 
> That comes from iproute itself, but the missing LOWER-UP flag
> indicates it and that should be enough for bridging and bonding.
> I'm unsure about this though since its still a big difference in
> userspace visible behaviour, people might just as well manually
> configure failover once routing disappears or the device goes down,
> or just have routing fall through to different routes. All this
> wouldn't work anymore.
> 
> Maybe we can make this optional somehow without too much uglyness?

I'm fine with that..we can just add a new vlan-device flag similar to the
reorder-header flag.

With the current code, on 'UP' of the underlying
code, all of the VLANs will also go UP, even if the user had previously
put them DOWN.  That seems like it could be quite dangerous/unexpected
to me..but I guess it's required if we are going to automatically DOWN them...

One other thought:  Maybe we could tell a small lie and say that we have
NO-CARRIER on the VLAN when the underlying device is down OR has no carrier?

That way we keep normal link up/down semantics w/out having to change the
admin state of the VLANs...

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com


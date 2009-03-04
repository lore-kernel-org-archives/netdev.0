From: Patrick McHardy <kaber@trash.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 04 Mar 2009 12:45:33 +0100
Message-ID: <49AE69DD.80802@trash.net>
References: <20090228180541.GA729@jukie.net>	<20090303.234327.81716668.davem@davemloft.net>	<49AE509B.3000305@trash.net> <20090304.025914.149394356.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:33717 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755554AbZCDLpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2009 06:45:38 -0500
In-Reply-To: <20090304.025914.149394356.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Patrick McHardy <kaber@trash.net>
> Date: Wed, 04 Mar 2009 10:57:47 +0100
> 
>>>> I can reproduce it reliably with:
>>>>
>>>>   $ modprobe 8021q
>>>>   $ vconfig add eth1 5
>>>>   $ ifconfig eth1.5 up
>>>>   $ vconfig add eth1.5 4
>>> Stephen please fix this.
>> I'm maintaining vlan :) I haven't been able to look into this yet,
>> but I should be later today.
> 
> Ok, I don't actually care who fixes it :-)
> 
> I asked Stephen because this appears like it might be netdev_ops
> fallout.

Good point. I think I know whats happening. The VLAN devices are
registered with vlan_netdev_ops, the ->init function then potentially
replaces them based on whether the underlying device supports HW
acceleration. At this point the register_netdev() function already
has used the first netdev_ops structure to initialize the compat
pointers, meaning the new assignment is largely without effect and
causes incorrect ops to be used with HW acceleration

This probably causes the slab corruption since the HW accelerated
VLAN device doesn't increase the headroom, but the non-accelerated
functions try to add a hard header anyways.

This is a bit tricky to fix since we actually need some valid
ops before invoking ->init(). One way would be to move the compat
ops initialization to a seperate function and have VLAN use it to
switch its ops.

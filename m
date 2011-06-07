From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] vlan: only create special VLAN 0 once
Date: Tue, 07 Jun 2011 17:17:27 +0200
Message-ID: <4DEE4107.1080706@trash.net>
References: <20110603200738.GA24804@midget.suse.cz> <20110605.142823.1727360496050285755.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, netdev@vger.kernel.org, pedro.netdev@dondevamos.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54371 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756662Ab1FGPRh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jun 2011 11:17:37 -0400
In-Reply-To: <20110605.142823.1727360496050285755.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05.06.2011 23:28, David Miller wrote:
> From: Jiri Bohac <jbohac@suse.cz>
> Date: Fri, 3 Jun 2011 22:07:38 +0200
> 
>> Commit ad1afb00 registers a VLAN with vid == 0 for every device to handle
>> 802.1p frames.  This is currently done on every NETDEV_UP event and the special
>> vlan is never unregistered.  This may have strange effects on drivers
>> implementning ndo_vlan_rx_add_vid(). E.g. bonding will allocate a linked-list
>> element each time, causing a memory leak.
>>
>> Only register the special VLAN once on NETDEV_REGISTER.
>>
>> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 
> I recognize the problem, but this solution isn't all that good.
> 
> I am pretty sure that the hardware device driver methods that
> implement ndo_vlan_rx_add_vid() assume that the device is up.
> Because most drivers completely reset the chip when the
> interface is brought up and this will likely clear out the
> VLAN ID tables in the chip.
> 

Good point.

I don't think this approach works very well at all since
some drivers don't do incremental updates, but iterate over
the registered VLAN group when constructing filters. The
group is not created until the first real VLAN device is
registered however.

Based on a quick grep (may have missed some):

- via_velocity, mlx4, starfire: will do nothing

- benet, igb, vxge, igbvf, ixgbevf, e1000e: would oops on
  rx_kill_vid due to unnecessary vlan_group_set_device()

The assumption of the drivers that a VLAN group exists
before the first VID is configured is reasonable in my
opinion, a lot of them also don't even configure VLAN
filtering until the VLAN group is registered.

So I think a good solution would be to make sure all
drivers don't enable VLAN filtering before the first
VLAN is actually registered and do the automatic
registration of VID 0 once the first real VLAN device
is created.

Also the code currently doesn't handle module unload:
regulary registered VLAN devices are removed through
rtnl_link, the manually registered VIDs need to be
removed manually.

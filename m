From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/8021q: Check the correct vlan filter capability
Date: Wed, 24 Feb 2016 16:48:14 -0500 (EST)
Message-ID: <20160224.164814.157691299176786528.davem@davemloft.net>
References: <1456331959-3573-1-git-send-email-saeedm@mellanox.com>
	<20160224.114839.300751853393269073.davem@davemloft.net>
	<CALzJLG-CR1Ac5biwP5CuFbygqCOWh4-VGQc-XZ=BuZQLRnnRDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, galp@mellanox.com,
	ogerlitz@mellanox.com, kaber@trash.net
To: saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57339 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779AbcBXVsQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 16:48:16 -0500
In-Reply-To: <CALzJLG-CR1Ac5biwP5CuFbygqCOWh4-VGQc-XZ=BuZQLRnnRDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Date: Wed, 24 Feb 2016 22:27:16 +0200

>>> Netdev features can be changed dynamically to off after vlan_vid_add
>>> was called, thus vlan_vid_del will skip ndo_vlan_rx_kill_vid and will
>>> leave the device driver with un-freed resources.
>>
>> Are you sure the fix isn't to make vlan_vid_add() check ->features instead
>> of ->hw_features.
> 
> This is exactly what this fix suggests, "->features" is not consistent
> and can be turned ON/OFF between vlan_add/del which can leave the NIC
> driver in inconsistent state !

But the user changes the setting _exactly_ to control whether these
VLAN offloads occur or not.

>> Should we really be trying to add VLAN filters when the user has
>> turned it off?
> 
> Well, I think it is debatable, but the current implementation is not
> consistent, especially for adding vlan 0 by default and then the user
> disables the vlan filter, this will cause the stack to never call the
> nic ndo_vlan_rx_kill_vid for the pre added vlan 0 and vise versa call
> kill_vid without add_vid, BUG ?
> 
> So i think we have two options, use this patch, and always trust to
> delegate vlan_vid_add/del to the NIC when it's HW supports it, and the
> nic will be smart enough to know what to do with it (in case vlan
> filter is enabled/disabled). Or, for each vlan we can remember if it
> was added to the NIC or not so the stack will know whether to clean it
> up or not.

If automatically added VLANs are the issue, then we should specially
mark it such that it will get forcefully removed regardless of feature
settings.

The whole point of the separation of ->hw_features and ->features is
to separate what the card can do from what the user wants enabled or
not.

Therefore offload operations should be triggered by ->features not
->hw_features.

Any test on ->hw_features that is not a validation of a ->features
change request is a BIG RED FLAG and almost always a bug.

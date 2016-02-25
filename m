From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net] net/8021q: Check the correct vlan filter capability
Date: Wed, 24 Feb 2016 19:58:59 -0800
Message-ID: <56CE7C03.2060200@gmail.com>
References: <1456331959-3573-1-git-send-email-saeedm@mellanox.com>	<20160224.114839.300751853393269073.davem@davemloft.net>	<CALzJLG-CR1Ac5biwP5CuFbygqCOWh4-VGQc-XZ=BuZQLRnnRDg@mail.gmail.com> <20160224.164814.157691299176786528.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: saeedm@mellanox.com, netdev@vger.kernel.org, galp@mellanox.com,
	ogerlitz@mellanox.com, kaber@trash.net
To: David Miller <davem@davemloft.net>, saeedm@dev.mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:34201 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755358AbcBYD7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Feb 2016 22:59:15 -0500
Received: by mail-pf0-f175.google.com with SMTP id x65so25069366pfb.1
        for <netdev@vger.kernel.org>; Wed, 24 Feb 2016 19:59:14 -0800 (PST)
In-Reply-To: <20160224.164814.157691299176786528.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-02-24 01:48 PM, David Miller wrote:
> From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
> Date: Wed, 24 Feb 2016 22:27:16 +0200
> 
>>>> Netdev features can be changed dynamically to off after vlan_vid_add
>>>> was called, thus vlan_vid_del will skip ndo_vlan_rx_kill_vid and will
>>>> leave the device driver with un-freed resources.
>>>
>>> Are you sure the fix isn't to make vlan_vid_add() check ->features instead
>>> of ->hw_features.
>>
>> This is exactly what this fix suggests, "->features" is not consistent
>> and can be turned ON/OFF between vlan_add/del which can leave the NIC
>> driver in inconsistent state !
> 
> But the user changes the setting _exactly_ to control whether these
> VLAN offloads occur or not.
> 
>>> Should we really be trying to add VLAN filters when the user has
>>> turned it off?
>>
>> Well, I think it is debatable, but the current implementation is not
>> consistent, especially for adding vlan 0 by default and then the user
>> disables the vlan filter, this will cause the stack to never call the
>> nic ndo_vlan_rx_kill_vid for the pre added vlan 0 and vise versa call
>> kill_vid without add_vid, BUG ?
>>
>> So i think we have two options, use this patch, and always trust to
>> delegate vlan_vid_add/del to the NIC when it's HW supports it, and the
>> nic will be smart enough to know what to do with it (in case vlan
>> filter is enabled/disabled). Or, for each vlan we can remember if it
>> was added to the NIC or not so the stack will know whether to clean it
>> up or not.
> 
> If automatically added VLANs are the issue, then we should specially
> mark it such that it will get forcefully removed regardless of feature
> settings.
> 

I suspect the hardware driver should flush the vid list in hardware
when the feature flag is disabled and when it is enabled I guess we
would need to do something like vlan_vids_add_by_dev() and do an add
for all the upper dev vlans.

I guess with some helper functions this could be done generally in
the ethtool set_features code path by tracking down the vid list and
calling all the del and add routines for each vlan.

A bit more work but seems more correct then creating strange cases
where hw_fatures and features don't actually work as expected.

> The whole point of the separation of ->hw_features and ->features is
> to separate what the card can do from what the user wants enabled or
> not.
> 
> Therefore offload operations should be triggered by ->features not
> ->hw_features.
> 
> Any test on ->hw_features that is not a validation of a ->features
> change request is a BIG RED FLAG and almost always a bug.
> 

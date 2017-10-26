From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: removing bridge in vlan_filtering mode requests delete of
 attached ports main MAC address
Date: Thu, 26 Oct 2017 12:21:40 +0200
Message-ID: <e48172b8-52ec-a9e8-c720-d9da69d8ced7@redhat.com>
References: <02874ECE860811409154E81DA85FBB5882ACC9A4@ORSMSX115.amr.corp.intel.com>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Malek, Patryk" <patryk.malek@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37144 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750884AbdJZKVm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Oct 2017 06:21:42 -0400
In-Reply-To: <02874ECE860811409154E81DA85FBB5882ACC9A4@ORSMSX115.amr.corp.intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/20/2017 08:06 PM, Keller, Jacob E wrote:
>> -----Original Message-----
>> From: Keller, Jacob E
>> Sent: Friday, October 20, 2017 10:23 AM
>> To: netdev@vger.kernel.org
>> Cc: Malek, Patryk <patryk.malek@intel.com>; 'Vlad Yasevich'
>> <vyasevic@redhat.com>
>> Subject: removing bridge in vlan_filtering mode requests delete of attached
>> ports main MAC address
>>
>> Hi,
>>
>> We've run into an issue with bridges set in vlan_filtering mode. Basically, if we
>> attach a device to a bridge which has enabled vlan_filtering, and then remove the
>> bridge, we end up requesting the driver of the attached device to remove its
>> own MAC HW address.
>>
>> In i40e, at least, this causes the driver to actually delete such an address and then
>> it will no longer receive any traffic.
>>
>> To reproduce this:
>>
>> a) brctl addbr br0
>> b) brctl addif br0 enp<n>
>> # enable vlan filtering
>> c) echo 1 >/sys/class/net/br0/bridge/vlan_filtering
>> d) brctl delbr br0
>>
>> Specifically this appears to happen because of how we automatically enter static
>> configuration for routes when vlan_filtering is enabled, and we call
>> br_fdb_unsync_static which will clear all the routes from the fdb table for the
>> device. See commit 2796d0c648c9 ("bridge: Automatically manage port
>> promiscuous mode.", 2014-05-16) for more details.
>>
>> This happens to include the devices own default address, which results in the
>> bug.
>>
>> I'm not sure if this is a driver bug, or if it's a bug in the bridging code.
>>
>> Who would know more about this and what to do about this?
>>
>> One obvious solution is to hard code the i40e device driver so that it does not
>> actually delete the HW address from the unicast filter list. This could work, but
>> seems to me like its papering over the problem. Is this just a known thing that
>> drivers should be aware of? I don't really know...
>>
>> An alternative solution would be to possibly ignore any fdb addresses which
>> specifically target that port?
>>
>> Any ideas?
> 
> For the record, adding a check to prevent unsync_static from removing addresses which are targetting the specific port does work to resolve this specific issue, but I'm sure it's not the correct solution as I expect that would cause other problems.
> 

Hi Jake

I think adding a !fdb->local should work.  local fdb contain the address of assigned to
the ports of the bridge and those shouldn't be directly removed.

If that works,  that looks like the right solution.

-vlad

> Thanks,
> Jake
> 
>>
>> Regards,
>> Jake

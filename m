From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [PATCH net-next 3/4] bridge: vlan: break vlan_flush in two phases
 to keep old order
Date: Mon, 12 Oct 2015 20:16:11 +0200
Message-ID: <561BF8EB.1010701@cumulusnetworks.com>
References: <1444650069-32572-1-git-send-email-razor@blackwall.org>
 <1444650069-32572-4-git-send-email-razor@blackwall.org>
 <20151012173904.GC6756@colbert.mtl.com>
 <561BF413.5010609@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com,
	roopa@cumulusnetworks.com, stephen@networkplumber.org,
	bridge@lists.linux-foundation.org, davem@davemloft.net
To: Ido Schimmel <idosch@mellanox.com>,
	Nikolay Aleksandrov <razor@blackwall.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:35280 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751630AbbJLSQO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 14:16:14 -0400
Received: by wicge5 with SMTP id ge5so160726650wic.0
        for <netdev@vger.kernel.org>; Mon, 12 Oct 2015 11:16:13 -0700 (PDT)
In-Reply-To: <561BF413.5010609@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/12/2015 07:55 PM, Nikolay Aleksandrov wrote:
> On 10/12/2015 07:39 PM, Ido Schimmel wrote:
>> Mon, Oct 12, 2015 at 02:41:08PM IDT, razor@blackwall.org wrote:
>>> From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>>
>> Hi,
>>
>>> Ido Schimmel reported a problem with switchdev devices because of the
>>> order change of del_nbp operations, more specifically the move of
>>> nbp_vlan_flush() which deletes all vlans and frees vlgrp after the
>>> rx_handler has been unregistered. So in order to fix this break
>>> vlan_flush in two phases:
>>> 1. delete all of vlan_group's vlans
>>> 2. destroy rhtable and free vlgrp
>>> We execute phase I (free_rht == false) in the same place as before so the
>>> vlans can be cleared and free the vlgrp after the rx_handler has been
>>> unregistered in phase II (free_rht == true).
>> I don't fully understand the reason for the two-phase cleanup. Please
>> see below.
>>>
>>> Reported-by: Ido Schimmel <idosch@mellanox.com>
>>> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
>>> ---
>>> Ido: I hope this fixes it for your case, a test would be much appreciated.
>> This indeed fixes our switchdev issue. Thanks for the fix!
>>>
> [snip]
>>>
>>> -static void __vlan_flush(struct net_bridge_vlan_group *vlgrp)
>>> +static void __vlan_flush(struct net_bridge_vlan_group *vlgrp, bool free_rht)
>>> {
>>> 	struct net_bridge_vlan *vlan, *tmp;
>>>
>>> 	__vlan_delete_pvid(vlgrp, vlgrp->pvid);
>>> 	list_for_each_entry_safe(vlan, tmp, &vlgrp->vlan_list, vlist)
>>> 		__vlan_del(vlan);
>>> -	rhashtable_destroy(&vlgrp->vlan_hash);
>>> -	kfree_rcu(vlgrp, rcu);
>>> +
>> Why not just issue a synchronize_rcu here and remove the if statement? I
>> believe that would also be better for when we remove the bridge device
>> itself. It's fully symmetric with init that way.
> Hi,
> I considered that, but I don't want to issue a second synchronize_rcu() for each
> port when deleting them, with this change we avoid a second synchronize_rcu()
> and use the rx_handler unregister one. In complex setups with lots of ports
> this is a considerable overhead.
> For the bridge device del case - the call is the same, there're no two phases
> there.
> 
> Cheers,
>  Nik
> 

Actually I have a better idea, we can use the delayed rcu free and destroy the
rhashtable there. v2 coming soon :-)

Thanks,
 Nik

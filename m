From: Vlad Yasevich <vyasevic@redhat.com>
Subject: Re: [PATCH net 4/7] bridge: Fix the way checking if a local fdb entry
 can be deleted
Date: Tue, 03 Dec 2013 10:41:00 -0500
Message-ID: <529DFB8C.2080300@redhat.com>
References: <1385966439-26526-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <1385966439-26526-5-git-send-email-makita.toshiaki@lab.ntt.co.jp>	 <529CBE61.8030402@redhat.com> <1386074738.4038.65.camel@ubuntu-vm-makita>
Reply-To: vyasevic@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64217 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753100Ab3LCPlI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Dec 2013 10:41:08 -0500
In-Reply-To: <1386074738.4038.65.camel@ubuntu-vm-makita>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/03/2013 07:45 AM, Toshiaki Makita wrote:
> On Mon, 2013-12-02 at 12:07 -0500, Vlad Yasevich wrote:
>> On 12/02/2013 01:40 AM, Toshiaki Makita wrote:
>>> We should take into account the followings when deleting a local fdb entry.
>>>
>>> - nbp_vlan_find() can be used only when vid != 0 to check if an entry is
>>>   deletable, because a fdb entry with vid 0 can exist at any time but
>>>   nbp_vlan_find() always return false with vid 0.
>>>
>>>   Example of problematic case:
>>>     ip link set eth0 address 12:34:56:78:90:ab
>>>     ip link set eth1 address 12:34:56:78:90:ab
>>>     brctl addif br0 eth0
>>>     brctl addif br0 eth1
>>>     ip link set eth0 address aa:bb:cc:dd:ee:ff
>>>   Then, the fdb entry 12:34:56:78:90:ab will be deleted even though the
>>>   bridge port eth1 still has that address.
>>>
>>> - The port to which the bridge device is attached might needs a local entry
>>>   if its mac address is set manually.
>>>
>>>   Example of problematic case:
>>>     ip link set eth0 address 12:34:56:78:90:ab
>>>     brctl addif br0 eth0
>>>     ip link set br0 address 12:34:56:78:90:ab
>>>     ip link set eth0 address aa:bb:cc:dd:ee:ff
>>>   Then, the fdb still must have the entry 12:34:56:78:90:ab, but it will be
>>>   deleted.
>>>
>>> We can use br->dev->addr_assign_type to check if the address is manually
>>> set or not, but I propose another approach.
>>>
>>> Since we delete and insert local entries whenever changing mac address
>>> of the bridge device, we can change dst of the entry to NULL regardless of
>>> addr_assign_type when deleting an entry associated with a certain port,
>>> and if it is found to be unnecessary later, then delete it.
>>> That is, if changing mac address of a port, the entry might be changed
>>> to its dst being NULL first, but is eventually deleted when recalculating
>>> and changing bridge id.
>>>
>>> This approach is useful when we want to share the code with deleting
>>> vlan in which the bridge device might want such an entry regardless of
>>> addr_assign_type, and makes things easy because we don't have to consider
>>> if mac address of the bridge device will be changed or not at
>>> fdb_delete_local().
>>
>> This is a nifty approach, but it does have one side-effect that I am not
>> sure is correct.  In the case where bridge mac address is not manually
>> set, a fdb entry for the removed address survives past the
>> synchronize_net() call.  This would result in a behavioral change where
>> packets that always used to flood, would now sometimes be delivered
>> only to the bridge.
> 
> I think no unnecessary entry will survive in any case.
> It will survive only if the bridge device remains to have the same mac
> address, because we check if the entry is necessary or not whenever the
> address of the bridge device is changed (assuming patch 3/7 is applied).
> 
> Further analysis:
> The function fdb_delete_local() (and __fdb_delete_local()) will called
> by br_fdb_changeaddr(), br_fdb_change_mac_address(),
> br_fdb_delete_by_port() (with do_all==1), br_vlan_delete(), and
> nbp_vlan_delete() after all of this patch series are applied.
> So, we have to consider only these 5 functions.
> 
> br_fdb_changeaddr():
> It is called by br_device_event().
> br_device_event() calls br_stp_recalculate_bridge_id() right after
> calling br_fdb_changeaddr(), so if the address of bridge device should
> be changed, the fdb entry will immediately reflect it and be deleted.

This doesn't happen until later.  Currently nbp_del() will remove all
fdb entries for a given port.  With this patch, the local fdb entry for
the port will survive the removal process and the fdb->dst will be set
to NULL.
The port is now removed from the list, rx_handler is unregistered and we
push call synchronize_net() trying flush all packets currently in rcu
section.  Once this completes, the port and all the fdbs for it should
be removed, but now they are not. We have to wait for br_del_if() to
call the notifier call chain to remove the the fdb entry.  Any packet
arriving at the bridge for the mac address of the port that just got
removed will now be handed over to the bridge, instead of being flooded.
This is a change in behavior.

-vlad

> 
> br_fdb_change_mac_address():
> In this case, fdb_delete_local() is called with p==NULL, so it will not
> be affected by this change.
> 
> br_fdb_delete_by_port() with do_all==1 and p!=NULL:
> It is called by del_nbp() and del_nbp() is called by br_del_if() and
> br_dev_delete().
> br_del_if() calls br_stp_recalculate_bridge_id() right after calling
> del_nbp(), so if the address of bridge device should be changed, the fdb
> entry will immediately reflect it and be deleted.
> br_dev_delete() calls br_fdb_delete_by_port() with p==NULL right after
> calling del_nbp(), so all fdb entry will be immediately deleted.
> 
> br_vlan_delete():
> In this case, fdb_delete_local() is called with p==NULL, so it will not
> be affected by this change.
> 
> nbp_vlan_delete():
> In this case, the address of bridge device will not be changed, and if
> the bridge device has the same vlan, it survives. This is very my
> intended behavior.
> 
> Thanks,
> Toshiaki Makita
> 
>>
>> -vlad
> 
> 

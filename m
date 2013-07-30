From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next] bonding: fix system hang due to fast igmp timer
 rescheduling
Date: Wed, 31 Jul 2013 01:25:52 +0200
Message-ID: <51F84B80.7070106@redhat.com>
References: <1375205852-31325-1-git-send-email-nikolay@redhat.com> <7289.1375209640@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62185 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756336Ab3G3XZ4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 30 Jul 2013 19:25:56 -0400
In-Reply-To: <7289.1375209640@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/30/2013 08:40 PM, Jay Vosburgh wrote:
> Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> 
>> From: Nikolay Aleksandrov <Nikolay Aleksandrov nikolay@redhat.com>
>>
>> After commit 4aa5dee4d9 ("net: convert resend IGMP to notifier event")
>> we try to acquire rtnl in bond_resend_igmp_join_requests but it can be
>> scheduled with rtnl already held (e.g. when bond_change_active_slave is
>> called with rtnl) causing a loop of immediate reschedules + calls because
>> rtnl_trylock fails each time since it's being already held.
>> For me this issue leads to system hangs very easy:
>> modprobe bonding; ifconfig bond0 up; ifenslave bond0 eth0; rmmod
>> bonding;
> 
> 	I believe that bond_change_active_slave is always called with
> rtnl held, and it is the only caller of bond_resend_igmp_join_requests
> (well, "caller" in the sense that it queues the delayed work for
> mcast_work that runs the function, currently with delay of 0).
> 
>> The fix is to introduce a small (1 jiffy) delay which is enough for the
>> sections holding rtnl to finish without putting any strain on the system.
> 
> 	Should the delay also be in the bond_change_active_slave queue
> work call as well, to eliminate one loop of the "rtnl_trylock failing ->
> queue_delayed_work" sequence in bond_resend_igmp_join_requests?
> 
> 	-J
> 
Hi Jay,
I actually think there's one way to call bond_change_active_slave without rtnl:
bond_select_active_slave (and thus bond_change_active_slave) called from
bond_loadbalance_arp_mon with read_lock(&bond->lock) &
write_lock_bh(&bond->curr_slave_lock) only.

But you're right that most of the time (i.e. all other callers) it's called
with rtnl held, I will adjust its timer as well and send a v2.

Since I've prepared the initial RCU conversion of the bonding which I think
to submit tomorrow I don't want to make this patch a part of that series,
so I will submit it alone (and thus apart).
If this is not the protocol in such cases, or if there's anything else, I
can wait for it to go in and submit the series then, just let me know.

Thanks,
 Nik

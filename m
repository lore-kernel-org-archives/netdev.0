From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH 2/2] bonding: fix igmp_retrans type and two related races
Date: Fri, 07 Jun 2013 11:37:30 +0200
Message-ID: <51B1A9DA.9020600@redhat.com>
References: <1370519702-18581-1-git-send-email-nikolay@redhat.com> <1370519702-18581-3-git-send-email-nikolay@redhat.com> <4475.1370566850@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47136 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751694Ab3FGJho (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jun 2013 05:37:44 -0400
In-Reply-To: <4475.1370566850@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/06/13 03:00, Jay Vosburgh wrote:
> nikolay@redhat.com wrote:
> 
>> From: Nikolay Aleksandrov <nikolay@redhat.com>
>>
>> First the type of igmp_retrans (which is the actual counter of
>> igmp_resend parameter) is changed to u8 to be able to store values up
>> to 255 (as per documentation). There are two races that were hidden
>> there and which are easy to trigger after the previous fix, the first is
>> between bond_resend_igmp_join_requests and bond_change_active_slave
>> where igmp_retrans is set and can be altered by the periodic. The second
>> race condition is between multiple running instances of the periodic
>> (upon execution it can be scheduled again for immediate execution which
>> can cause the counter to go < 0 which in the unsigned case leads to
>> unnecessary igmp retransmissions).
>> Since in bond_change_active_slave bond->lock is held for reading and
>> curr_slave_lock for writing, we use curr_slave_lock for mutual
>> exclusion. We can't drop them as there're cases where RTNL is not held
>> when bond_change_active_slave is called. RCU is unlocked in
>> bond_resend_igmp_join_requests before getting curr_slave_lock since we
>> don't need it there and it's pointless to delay.
> 
> 	My first thought is that it would be much simpler to change the
> limit in the documentation and code from 255 to 127 and be done with it.
> I'm skeptical that anybody uses values for igmp_retrans even as high as
> 10, much less 100 (which would take 20 seconds to complete at 5 per
> second).
> 
> 	That said, this is technically correct, although I have one
> question, below.
> 
Yes, I was thinking the same thing at first and even discussed it with
Andy. Although the race between bond_resend_igmp_join_requests and
bond_change_active_slave will still be valid.

>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> ---
>> drivers/net/bonding/bond_main.c | 15 +++++++++++----
>> drivers/net/bonding/bonding.h   |  2 +-
>> 2 files changed, 12 insertions(+), 5 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index 473633a..02d9ae7 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -764,8 +764,8 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
>> 	struct net_device *bond_dev, *vlan_dev, *upper_dev;
>> 	struct vlan_entry *vlan;
>>
>> -	rcu_read_lock();
>> 	read_lock(&bond->lock);
>> +	rcu_read_lock();
>>
>> 	bond_dev = bond->dev;
>>
>> @@ -787,12 +787,19 @@ static void bond_resend_igmp_join_requests(struct bonding *bond)
>> 		if (vlan_dev)
>> 			__bond_resend_igmp_join_requests(vlan_dev);
>> 	}
>> +	rcu_read_unlock();
>>
>> -	if (--bond->igmp_retrans > 0)
>> +	/* We use curr_slave_lock to protect against concurrent access to
>> +	 * igmp_retrans from multiple running instances of this function and
>> +	 * bond_change_active_slave
>> +	 */
>> +	write_lock_bh(&bond->curr_slave_lock);
>> +	if (bond->igmp_retrans > 1) {
>> +		bond->igmp_retrans--;
>> 		queue_delayed_work(bond->wq, &bond->mcast_work, HZ/5);
> 
> 	Why split out the -- from the comparison?
> 
> 	-J
This one was very tricky, because we can have more than 2 instances
running concurrently and if we unconditionally decrement the value it
can still drop < 0. Example with 3 instances running and igmp_retrans ==
1 (with check bond->igmp_retrans-- > 1):
f1 passes, doesn't re-schedule, but decrements - igmp_retrans = 0
f2 then passes, doesn't re-schedule, but decrements - igmp_retrans = 255
f3 does the unnecessary retransmissions.

I also have an interesting solution with cmpxchg without curr_slave_lock
but this is more straightforward and since this is not a fast path I
think it's preferrable.

Nik
>> -
>> +	}
>> +	write_unlock_bh(&bond->curr_slave_lock);
>> 	read_unlock(&bond->lock);
>> -	rcu_read_unlock();
>> }
>>
>> static void bond_resend_igmp_join_requests_delayed(struct work_struct *work)
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 2baec24..f989e15 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -225,7 +225,7 @@ struct bonding {
>> 	rwlock_t curr_slave_lock;
>> 	u8	 send_peer_notif;
>> 	s8	 setup_by_slave;
>> -	s8       igmp_retrans;
>> +	u8       igmp_retrans;
>> #ifdef CONFIG_PROC_FS
>> 	struct   proc_dir_entry *proc_entry;
>> 	char     proc_file_name[IFNAMSIZ];
>> -- 
>> 1.8.1.4
>>
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 

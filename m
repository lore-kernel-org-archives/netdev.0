From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 12:23:56 +0000
Message-ID: <20100901122356.GB9468@ff.dom.local>
References: <20136.1283288063@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>, bonding-devel@lists.sourceforge.net,
	markine@google.com, chavey@google.com, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:36766 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752714Ab0IAMYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Sep 2010 08:24:05 -0400
Received: by bwz11 with SMTP id 11so5234023bwz.19
        for <netdev@vger.kernel.org>; Wed, 01 Sep 2010 05:24:03 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20136.1283288063@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-08-31 22:54, Jay Vosburgh wrote:
> Jiri Bohac <jbohac@suse.cz> wrote:
> 
>> Hi,
>>
>> this is another attempt to solve the bonding workqueue re-arming
>> races.
>>
>> The issue has been thoroughly discussed here:
>> http://article.gmane.org/gmane.linux.network/146949 "[PATCH]
>> bonding: cancel_delayed_work() -> cancel_delayed_work_sync()"
>> However, the only outcome was a proposal for an ugly hack with
>> busy-waiting on the rtnl.
>>
>> The problem:
>> Bonding uses delayed work that automatically re-arms itself,
>> e.g.: bond_mii_monitor().
>>
>> A dev->close() quickly followed by dev->open() on the bonding
>> master has a race condition. bond_close() sets kill_timers=1 and
>> calls cancel_delayed_work(), hoping that bond_mii_monitor() will
>> not re-arm again anymore.  There are two problems with this:
>>
>> - bond->kill_timers is not re-checked after re-acquiring the
>>  bond->lock (this would be easy to fix)
>>
>> - bond_open() resets bond->kill_timers to 0. If this happens
>>  before bond_mii_monitor() notices the flag and exits, it will
>>  re-arm itself. bond_open() then tries to schedule the delayed
>>  work, which causes a BUG.
>>
>> The issue would be solved by calling cancel_delayed_work_sync(),
>> but this can not be done from bond_close() since it is called
>> under rtnl and the delayed work locks rtnl itself.
>>
>> My proposal is to move all the "commit" work that requires rtnl
>> to a separate work and schedule it on the bonding wq. Thus, the
>> re-arming work does not need rtnl and can be cancelled using
>> cancel_delayed_work_sync().
>>
>> Comments?

Looks mostly OK to me, but a bit more below...

>>
>> [note, this does not deal with bond_loadbalance_arp_mon(), where
>> rtnl is now taken as well in net-next; I'll do this if you think
>> the idea is good ]
> 
> 	I don't believe the loadbalance_arp_mon acquires RTNL in
> net-next.  I recall discussing this with Andy not too long ago, but I
> didn't think that change went in, and I don't see it in the tree.
> 
>> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 822f586..8015e12 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -2119,10 +2119,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>
>> 	read_lock(&bond->lock);
>>
>> -	if (bond->kill_timers) {
>> -		goto out;
>> -	}
>> -
>> 	//check if there are any slaves
>> 	if (bond->slave_cnt == 0) {
>> 		goto re_arm;
>> @@ -2166,7 +2162,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>
>> re_arm:
>> 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
>> -out:
>> 	read_unlock(&bond->lock);
>> }
>>
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>> index c746b33..250d027 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -1397,6 +1397,23 @@ out:
>> 	return NETDEV_TX_OK;
>> }
>>
>> +void bond_alb_promisc_disable(struct work_struct *work)
>> +{
>> +	struct bonding *bond = container_of(work, struct bonding,
>> +					    alb_promisc_disable_work);
>> +	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> +
>> +	/*
>> +	 * dev_set_promiscuity requires rtnl and
>> +	 * nothing else.
>> +	 */
>> +	rtnl_lock();
>> +	dev_set_promiscuity(bond->curr_active_slave->dev, -1);
>> +	bond_info->primary_is_promisc = 0;
>> +	bond_info->rlb_promisc_timeout_counter = 0;
>> +	rtnl_unlock();
>> +}
> 
> 	What prevents this from deadlocking such that cpu A is in
> bond_close, holding RTNL and in cancel_delayed_work_sync, while cpu B is
> in the above function, trying to acquire RTNL?

I guess this one isn't cancelled in bond_close, so it should be safe.

> 
> 	Also, assuming for the moment that the above isn't a problem,
> curr_active_slave may be NULL if the last slave is removed between the
> time bond_alb_promisc_disable is scheduled and when it runs.  I'm not
> sure that the alb_bond_info can be guaranteed to be valid, either, if
> the mode changed.

Probably some or all of these work functions should test for closing
eg. with netif_running() or some other flag/variable under rtnl_lock().

....
>> static void bond_work_cancel_all(struct bonding *bond)
>> {
>> -	write_lock_bh(&bond->lock);
>> -	bond->kill_timers = 1;
>> -	write_unlock_bh(&bond->lock);
>> -
>> 	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))

I'd suggest to skip these delayed_work_pending() tests.

Thanks,
Jarek P.

>> -		cancel_delayed_work(&bond->mii_work);
>> +		cancel_delayed_work_sync(&bond->mii_work);
...

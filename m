From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 2/3] bonding: add new slave param and bond_slave_state_notify()
Date: Tue, 18 Feb 2014 11:49:44 +0800
Message-ID: <5302D858.5020802@huawei.com>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com> <1392626151-23916-3-git-send-email-dingtianhong@huawei.com> <5310.1392689226@death.nxdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <vfalico@redhat.com>, <andy@greyhouse.net>,
	<cwang@twopensource.com>, <jiri@resnulli.us>,
	<thomas@glanzmann.de>, <eric.dumazet@gmail.com>,
	<sfeldma@cumulusnetworks.com>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:50462 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbaBRDus (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 22:50:48 -0500
In-Reply-To: <5310.1392689226@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/18 10:07, Jay Vosburgh wrote:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>> Add a new slave parameter which called should_notify, if the slave's state
>> changed and don't notify yet, the parameter will be set to 1, and then if
>> the slave's state changed again, the param will be set to 0, it indicate that
>> the slave's state has been restored, no need to notify any one.
>>
>> The bond_slave_state_notify() will check whether the status changed and then
>> decide to notify or not.
>>
>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Cc: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bonding.h | 44 +++++++++++++++++++++++++++++++++++++++++--
>> 1 file changed, 42 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index d210124..4d0cd41 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -195,7 +195,8 @@ struct slave {
>> 	s8     new_link;
>> 	u8     backup:1,   /* indicates backup slave. Value corresponds with
>> 			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
>> -	       inactive:1; /* indicates inactive slave */
>> +	       inactive:1, /* indicates inactive slave */
>> +	       should_notify:1; /* indicateds whether the state changed */
>> 	u8     duplex;
>> 	u32    original_mtu;
>> 	u32    link_failure_count;
>> @@ -311,8 +312,47 @@ static inline void bond_set_slave_state(struct slave *slave,
>> 	else
>> 		return;
>>
>> -	if (notify)
>> +	if (notify) {
>> 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
>> +		slave->should_notify = 0;
>> +	} else {
>> +		if (slave->should_notify)
>> +			slave->should_notify = 0;
>> +		else
>> +			slave->should_notify = 1;
>> +	}
>> +}
>> +
>> +static inline void bond_slave_state_notify(struct bonding *bond,
>> +					   bool rtnl_locked)
>> +{
>> +	struct list_head *iter;
>> +	struct slave *tmp;
>> +
>> +	rcu_read_lock();
>> +	bond_for_each_slave_rcu(bond, tmp, iter) {
>> +		if (tmp->should_notify) {
>> +			rcu_read_unlock();
>> +			goto should_notify;
>> +		}
>> +	}
>> +	rcu_read_unlock();
>> +	return;
>> +
>> +should_notify:
>> +
>> +	if (!rtnl_locked && !rtnl_trylock())
>> +		return;
>> +
>> +	bond_for_each_slave(bond, tmp, iter) {
>> +		if (tmp->should_notify) {
>> +			rtmsg_ifinfo(RTM_NEWLINK, tmp->dev, 0, GFP_KERNEL);
>> +			tmp->should_notify = 0;
>> +		}
>> +	}
>> +
>> +	if (!rtnl_locked)
>> +		rtnl_unlock();
>> }
> 
> 	This function (bond_slave_state_notify) seems overly complicated
> given that there appears to be only one caller.  In particular, why
> bother with the "rtnl_locked" flag at all, when it is never called with
> it set to true?  Really, with only one caller (in patch 3 of the
> series), I'm not convinced this even needs to be a separate function.
> 
> 	-J
> 
In my original opinion, I think it may be used in RTNL for other monitor,
so add this one, I will remove it, thanks.

Regards
Ding

>>
>> static inline void bond_slave_state_change(struct bonding *bond)
>> -- 
>> 1.8.0
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
> 
> .
> 

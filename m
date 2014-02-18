From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 3/3] bonding: Fix the RTNL assertion failed for
 802.3ad state machine
Date: Tue, 18 Feb 2014 11:47:30 +0800
Message-ID: <5302D7D2.2020601@huawei.com>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com> <1392626151-23916-4-git-send-email-dingtianhong@huawei.com> <5300.1392689172@death.nxdomain>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:51100 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbaBRDvl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 22:51:41 -0500
In-Reply-To: <5300.1392689172@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/18 10:06, Jay Vosburgh wrote:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>> The 802.3ad state machine don't run in RTNL, but when the slave's
>> state changed, the rtmsg_ifinfo will be called, it will cause
>> warning message because the RTML is not locked, acquiring RTNL
>> for the __enable_port and __disable_port cases is difficult, as
>> those calls generally already hold the state machine lock, and
>> can't unconditionally call rtnl_lock because either they already
>> hold RTNL (for calls via bond_3ad_unbind_slave) or due to the
>> potential for deadlock with bond_3ad_adapter_speed_changed,
>> bond_3ad_adapter_duplex_changed, bond_3ad_link_change, or
>> bond_3ad_update_lacp_rate. All four of those are called with RTNL
>> held, and acquire the state machine lock second, The calling contexts for
>> __enable_port and __disable_port already hold the state machine lock,
>> and may or may not need RTNL.
>>
>> So according to the Jay's opinion, the __enable_port and __disable_port
>> should not call rtmsg_ifinfo in the state machine lock, any change in
>> the state of slave could set a flag in the slave, it will indicated that
>> an rtmsg_ifinfo should be called at the end of the state machine.
> 
> 	To clarify, my opinion being referenced here was really asking
> Scott Feldman <sfeldma@cumulusnetworks.com> if: (a) the calls had to be
> synchronous, and, (b) if the intermediate calls to adjust flags within
> the ARP monitor "cycle through slaves looking for a functional slave"
> all required notifications.  My suspicion is that the answer to both of
> those is "no," but I haven't heard from Scott.
> 

Yes, this question has been in existence for a long time, and I admin your opinions, it is very
clear and reasonable, so I try to fix it by this way, in my original idea, I think not only
the 802.3ad state machine, but the ab, loadbalance monitor is still need to modify, the existing
solution for bond_ab_arp_probe which I think is not good enough, so I think it will be a big
patchset, so I send this patchset just only fix for 802.3ad for review.

>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Cc: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_3ad.c | 5 +++--
>> 1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index cce1f1b..e80b78f 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -181,7 +181,7 @@ static inline int __agg_has_partner(struct aggregator *agg)
>>  */
>> static inline void __disable_port(struct port *port)
>> {
>> -	bond_set_slave_inactive_flags(port->slave);
>> +	bond_set_slave_flags(port->slave, BOND_STATE_BACKUP, false);
>> }
>>
>> /**
>> @@ -193,7 +193,7 @@ static inline void __enable_port(struct port *port)
>> 	struct slave *slave = port->slave;
>>
>> 	if ((slave->link == BOND_LINK_UP) && IS_UP(slave->dev))
>> -		bond_set_slave_active_flags(slave);
>> +		bond_set_slave_flags(slave, BOND_STATE_ACTIVE, false);
> 
> 	I don't agree that we need to have two separate systems (your
> new bond_set_slave_flags plus bond_set_slave_{active,inactive}_flags)
> that both tweak the "active" or "inactive" flags for a slave.  It would
> be much cleaner and consistent with the current code to add a "notify"
> boolean to the existing functions.
> 
> 	-J

Yep, this problem has troubled me for a long time, whether to add a new function
or modify current function, I think your answer has gave me the right direction,
thanks.

Regards
Ding 

> 
>> }
>>
>> /**
>> @@ -2123,6 +2123,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>> re_arm:
>> 	rcu_read_unlock();
>> 	read_unlock(&bond->lock);
>> +	bond_slave_state_notify(bond, false);
>> 	queue_delayed_work(bond->wq, &bond->ad_work, ad_delta_in_ticks);
>> }
>>
>> -- 
>> 1.8.0
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> .
> 

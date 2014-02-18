From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/3] bonding: add bond_set_slave_state/flags()
Date: Tue, 18 Feb 2014 11:50:29 +0800
Message-ID: <5302D885.7070407@huawei.com>
References: <1392626151-23916-1-git-send-email-dingtianhong@huawei.com> <1392626151-23916-2-git-send-email-dingtianhong@huawei.com> <5329.1392689302@death.nxdomain>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:51659 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbaBRDyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 22:54:02 -0500
In-Reply-To: <5329.1392689302@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/2/18 10:08, Jay Vosburgh wrote:
> Ding Tianhong <dingtianhong@huawei.com> wrote:
> 
>> The new function could change the slave state and flags, then call
>> rtmsg_ifinfo() according to the input parameters notify.
>>
>> Cc: Jay Vosburgh <fubar@us.ibm.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> Cc: Andy Gospodarek <andy@greyhouse.net>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bonding.h | 26 ++++++++++++++++++++++++++
>> 1 file changed, 26 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 86ccfb9..d210124 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -303,6 +303,18 @@ static inline void bond_set_backup_slave(struct slave *slave)
>> 	}
>> }
>>
>> +static inline void bond_set_slave_state(struct slave *slave,
>> +					int slave_state, bool notify)
>> +{
>> +	if (slave->backup != slave_state)
>> +		slave->backup = slave_state;
>> +	else
>> +		return;
>> +
>> +	if (notify)
>> +		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
> 
> 	I think this would be clearer if coded as:
> 
> 	if (slave->backup == slave_slave)
> 		return;
> 
> 	slave->backup = slave_state;
> 	if (notify)
> 		rtmsg_ifinfo(RTM_NEWLINK, slave->dev, 0, GFP_KERNEL);
> 
Yes, more simple.

>> +}
>> +
>> static inline void bond_slave_state_change(struct bonding *bond)
>> {
>> 	struct list_head *iter;
>> @@ -408,6 +420,20 @@ static inline void bond_set_slave_active_flags(struct slave *slave)
>> 	slave->inactive = 0;
>> }
>>
>> +static inline void bond_set_slave_flags(struct slave *slave,
>> +					int state, bool notify)
>> +
>> +{
>> +	if (state == BOND_STATE_ACTIVE) {
>> +		bond_set_slave_state(slave, state, notify);
>> +		slave->inactive = 0;
>> +	} else if (state == BOND_STATE_BACKUP && !bond_is_lb(slave->bond)) {
>> +		bond_set_slave_state(slave, state, notify);
>> +		if (!slave->bond->params.all_slaves_active)
>> +			slave->inactive = 1;
>> +	}
>> +}
> 
> 	As I said in my other reply, I don't see why this shouldn't be
> integrated into the existing state change functions instead of creating
> a new function.
> 
> 	-J

Ok, thanks.

Ding

> 
>> static inline bool bond_is_slave_inactive(struct slave *slave)
>> {
>> 	return slave->inactive;
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

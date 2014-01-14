From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 1/3] bonding: update the primary slave when slave's
 name changed
Date: Tue, 14 Jan 2014 14:51:52 +0800
Message-ID: <52D4DE88.4080501@huawei.com>
References: <52D4A2C8.3000908@huawei.com> <20140114063847.GB7798@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:1143 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751261AbaANG4E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 01:56:04 -0500
In-Reply-To: <20140114063847.GB7798@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2014/1/14 14:38, Veaceslav Falico wrote:
> On Tue, Jan 14, 2014 at 10:36:56AM +0800, Ding Tianhong wrote:
>> If the slave's name changed, and the bond params primary is exist,
>> the bond should deal with the situation in two ways:
>>
>> 1) If the slave is the primary slave yet, clean the primary slave
>>   and reselect active slave.
>> 2) If the slave's new name is as same as bond primary, set the slave
>>   as primary slave and reselect active slave.
>>
>> Thanks for Veaceslav's suggestion.
>>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
> 
> As in my previous email - please, don't use my name until I say so.
> 
> I'll add my signed-off-by to any patch that I've worked enough on.
> 
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>> drivers/net/bonding/bond_main.c | 30 ++++++++++++++++++++++++++++--
>> 1 file changed, 28 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index e06c445..63d6533 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -2860,9 +2860,35 @@ static int bond_slave_netdev_event(unsigned long event,
>>          */
>>         break;
>>     case NETDEV_CHANGENAME:
>> -        /*
>> -         * TODO: handle changing the primary's name
>> +        /* Handle changing the slave's name:
>> +         * 1) If the slave is primary save yet,
>> +         * clean the primary slave and reselect
>> +         * active slave.
> 
> I usually don't mind bad english (as I myself am speaking quite horrible
> one), but I can't really understand what you've meant here. And given that
> it's a comment in code - please, proof-read it first.
> 
>> +         * 2) If the slave's new name is bond
>> +         * primary, set the slave as primary
>> +         * slave and reselect active slave.
>>          */
>> +        if (USES_PRIMARY(bond->params.mode) &&
>> +            bond->params.primary[0]) {
> 
> Too many indentions. Verify if we're not using primary or primary string
> name is null and break, otherwise go further.
> 
>> +            if (bond->primary_slave &&
>> +                slave == bond->primary_slave) {
> 
> Useless verification, slave can't be NULL.
> 
>> +                pr_info("%s: Setting primary slave to None.\n",
>> +                    bond->dev->name);
>> +                bond->primary_slave = NULL;
>> +                write_lock_bh(&bond->curr_slave_lock);
>> +                bond_select_active_slave(bond);
> 
> Get bond_select_active_slave() out of if()s, you use it twice here.
> 
>> +                write_unlock_bh(&bond->curr_slave_lock);
>> +            } else if (!bond->primary_slave &&
> 
> Useless verification, if the name of a slave changed to our params.primary
> - then it means that bond->primary_slave was NULL, as it can only be
> not-null when we have a matching interface, and that would mean that we
> have two interfaces with the same name.
> 
>> +                   !strcmp(bond->params.primary,
>> +                      slave_dev->name)) {
>> +                pr_info("%s: Setting %s as primary slave.\n",
>> +                    bond->dev->name, slave_dev->name);
>> +                bond->primary_slave = slave;
>> +                write_lock_bh(&bond->curr_slave_lock);
>> +                bond_select_active_slave(bond);
>> +                write_unlock_bh(&bond->curr_slave_lock);
>> +            }
>> +        }
>>         break;
>>     case NETDEV_FEAT_CHANGE:
>>         bond_compute_features(bond);
>> -- 
>> 1.8.0
>>
>>
> 

fix in v2, thanks.

Regards
Ding 

> .
> 

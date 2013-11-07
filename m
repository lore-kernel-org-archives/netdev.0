From: Ding Tianhong <dingtianhong@huawei.com>
Subject: Re: [PATCH net-next 6/9] bonding: use RTNL instead of bond lock for
 bond_3ad_state_machine_handler()
Date: Thu, 7 Nov 2013 09:40:56 +0800
Message-ID: <527AEFA8.9030609@huawei.com>
References: <5279E74C.8070403@huawei.com> <527AD5BC.7040907@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	"Veaceslav Falico" <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:10097 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751361Ab3KGBmS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 20:42:18 -0500
In-Reply-To: <527AD5BC.7040907@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013/11/7 7:50, Sergei Shtylyov wrote:
> Hello.
> 
> On 11/06/2013 09:53 AM, Ding Tianhong wrote:
> 
>> The bond_3ad_state_machine_handler() is a slow path, it use the bond
>> lock to protect the bond slave list and slave port, the slave list
>> could not be protect by bond lock anymore, so I need to use RTNL or
>> RCU instead of bond lock, but if I remove the bond lock, the
>> bond_3ad_state_machine_handler() may use the slave port when bond
>> releasing the slave, it will occur problems.
> 
>> As the bond_3ad_unbind_slave() only protected by bond lock or RTNL,
>> so add RCU is not a good solution as it could not protect the slave
>> port, so RTNL is fit here.
> 
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/net/bonding/bond_3ad.c | 15 +++++++--------
>>   1 file changed, 7 insertions(+), 8 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index 187b1b7..a4d190e 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -2068,18 +2068,19 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
> [...]
>> -    //check if there are any slaves
>>       if (!bond_has_slaves(bond))
>>           goto re_arm;
>>
>> -    // check if agg_select_timer timer after initialize is timed out
>> +    /* check if agg_select_timer timer after initialize is timed out */
>>       if (BOND_AD_INFO(bond).agg_select_timer && !(--BOND_AD_INFO(bond).agg_select_timer)) {
>>           slave = bond_first_slave(bond);
>>           port = slave ? &(SLAVE_AD_INFO(slave).port) : NULL;
>>
>> -        // select the active aggregator for the bond
>>           if (port) {
>>               if (!port->slave) {
>>                   pr_warning("%s: Warning: bond's first port is uninitialized\n",
>> @@ -2093,7 +2094,6 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>           bond_3ad_set_carrier(bond);
>>       }
>>
>> -    // for each port run the state machines
>>       bond_for_each_slave(bond, slave, iter) {
>>           port = &(SLAVE_AD_INFO(slave).port);
>>           if (!port->slave) {
>> @@ -2114,7 +2114,7 @@ void bond_3ad_state_machine_handler(struct work_struct *work)
>>           ad_mux_machine(port);
>>           ad_tx_machine(port);
>>
>> -        // turn off the BEGIN bit, since we already handled it
>> +        /* turn off the BEGIN bit, since we already handled it */
>>           if (port->sm_vars & AD_PORT_BEGIN)
>>               port->sm_vars &= ~AD_PORT_BEGIN;
>>
> 
>    These comment changes are not documented in the changelog and should most probably be in a separate patch.
> 
> WBR, Sergei
> 

thanks for your reply, I miss it in the changelog, it is already a big patch set, so I really do not want to add patch any more, I will add it in changelog.

Tnanks

Ding

> 
> .
> 

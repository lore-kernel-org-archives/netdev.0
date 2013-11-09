From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 3/10] bonding: rebuild the lock use for bond_alb_monitor()
Date: Sat, 09 Nov 2013 22:15:01 +0800
Message-ID: <527E4365.6060107@gmail.com>
References: <527C4778.5080209@huawei.com> <527D0C42.3010402@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:46932 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752907Ab3KIOZp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 09:25:45 -0500
Received: by mail-pd0-f173.google.com with SMTP id r10so3329982pdi.4
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 06:25:45 -0800 (PST)
In-Reply-To: <527D0C42.3010402@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/9 0:07, Nikolay Aleksandrov =E5=86=99=E9=81=93:
> On 11/08/2013 03:07 AM, Ding Tianhong wrote:
>> The bond_alb_monitor use bond lock to protect the bond slave list,
>> it is no effect here, we need to use RTNL or RCU to replace bond loc=
k,
>> the bond_alb_monitor will called 10 times one second, RTNL may loss
>> performance here, so the bond lock replace with RCU to protect the
>> bond slave list, also the RTNL is preserved, the logic of the monito=
r
>> did not changed.
>>
>> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> ---
>>   drivers/net/bonding/bond_alb.c | 21 +++++++++------------
>>   1 file changed, 9 insertions(+), 12 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bo=
nd_alb.c
>> index 1fae915..ffdb91b 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -816,7 +816,7 @@ static void rlb_rebalance(struct bonding *bond)
>>   	for (; hash_index !=3D RLB_NULL_INDEX;
>>   	     hash_index =3D client_info->used_next) {
>>   		client_info =3D &(bond_info->rx_hashtbl[hash_index]);
>> -		assigned_slave =3D rlb_next_rx_slave(bond);
>> +		assigned_slave =3D __rlb_next_rx_slave(bond);
>>   		if (assigned_slave && (client_info->slave !=3D assigned_slave)) =
{
>>   			client_info->slave =3D assigned_slave;
>>   			client_info->ntt =3D 1;
>> @@ -1495,9 +1495,10 @@ void bond_alb_monitor(struct work_struct *wor=
k)
>>   	struct list_head *iter;
>>   	struct slave *slave;
>>  =20
>> -	read_lock(&bond->lock);
>> +	rcu_read_lock();
>>  =20
>> -	if (!bond_has_slaves(bond)) {
>> +	if (!bond_has_slaves_rcu(bond)) {
>> +		rcu_read_unlock();
>>   		bond_info->tx_rebalance_counter =3D 0;
>>   		bond_info->lp_counter =3D 0;
>>   		goto re_arm;
> If I'm not mistaken there's one more bond_for_each_slave() inside thi=
s function
> which should be converted to RCU.

But I really could not find any place should converted to RCU,

__rlb_next_rx_slave() is in RCU yet.

pls remind me if I miss something.

Regards
Ding


>> @@ -1528,7 +1529,7 @@ void bond_alb_monitor(struct work_struct *work=
)
>>  =20
>>   		read_lock(&bond->curr_slave_lock);
>>  =20
>> -		bond_for_each_slave(bond, slave, iter) {
>> +		bond_for_each_slave_rcu(bond, slave, iter) {
>>   			tlb_clear_slave(bond, slave, 1);
>>   			if (slave =3D=3D bond->curr_active_slave) {
>>   				SLAVE_TLB_INFO(slave).load =3D
>> @@ -1552,11 +1553,9 @@ void bond_alb_monitor(struct work_struct *wor=
k)
>>   			 * dev_set_promiscuity requires rtnl and
>>   			 * nothing else.  Avoid race with bond_close.
>>   			 */
>> -			read_unlock(&bond->lock);
>> -			if (!rtnl_trylock()) {
>> -				read_lock(&bond->lock);
>> +			rcu_read_unlock();
>> +			if (!rtnl_trylock())
>>   				goto re_arm;
>> -			}
>>  =20
>>   			bond_info->rlb_promisc_timeout_counter =3D 0;
>>  =20
>> @@ -1568,7 +1567,7 @@ void bond_alb_monitor(struct work_struct *work=
)
>>   			bond_info->primary_is_promisc =3D 0;
>>  =20
>>   			rtnl_unlock();
>> -			read_lock(&bond->lock);
>> +			rcu_read_lock();
>>   		}
>>  =20
>>   		if (bond_info->rlb_rebalance) {
>> @@ -1590,11 +1589,9 @@ void bond_alb_monitor(struct work_struct *wor=
k)
>>   			}
>>   		}
>>   	}
>> -
>> +	rcu_read_unlock();
>>   re_arm:
>>   	queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ticks)=
;
>> -
>> -	read_unlock(&bond->lock);
>>   }
>>  =20
>>   /* assumption: called before the slave is attached to the bond
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

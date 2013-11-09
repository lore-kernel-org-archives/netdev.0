From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 3/10] bonding: rebuild the lock use for bond_alb_monitor()
Date: Sat, 09 Nov 2013 15:30:02 +0100
Message-ID: <527E46EA.5030804@redhat.com>
References: <527C4778.5080209@huawei.com> <527D0C42.3010402@redhat.com> <527E4365.6060107@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Ding Tianhong <dthxman@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753180Ab3KIObW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 Nov 2013 09:31:22 -0500
In-Reply-To: <527E4365.6060107@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/09/2013 03:15 PM, Ding Tianhong wrote:
> =E4=BA=8E 2013/11/9 0:07, Nikolay Aleksandrov =E5=86=99=E9=81=93:
>> On 11/08/2013 03:07 AM, Ding Tianhong wrote:
>>> The bond_alb_monitor use bond lock to protect the bond slave list,
>>> it is no effect here, we need to use RTNL or RCU to replace bond lo=
ck,
>>> the bond_alb_monitor will called 10 times one second, RTNL may loss
>>> performance here, so the bond lock replace with RCU to protect the
>>> bond slave list, also the RTNL is preserved, the logic of the monit=
or
>>> did not changed.
>>>
>>> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>> ---
>>>   drivers/net/bonding/bond_alb.c | 21 +++++++++------------
>>>   1 file changed, 9 insertions(+), 12 deletions(-)
>>>
>>> diff --git a/drivers/net/bonding/bond_alb.c
>>> b/drivers/net/bonding/bond_alb.c
>>> index 1fae915..ffdb91b 100644
>>> --- a/drivers/net/bonding/bond_alb.c
>>> +++ b/drivers/net/bonding/bond_alb.c
>>> @@ -816,7 +816,7 @@ static void rlb_rebalance(struct bonding *bond)
>>>       for (; hash_index !=3D RLB_NULL_INDEX;
>>>            hash_index =3D client_info->used_next) {
>>>           client_info =3D &(bond_info->rx_hashtbl[hash_index]);
>>> -        assigned_slave =3D rlb_next_rx_slave(bond);
>>> +        assigned_slave =3D __rlb_next_rx_slave(bond);
>>>           if (assigned_slave && (client_info->slave !=3D assigned_s=
lave)) {
>>>               client_info->slave =3D assigned_slave;
>>>               client_info->ntt =3D 1;
>>> @@ -1495,9 +1495,10 @@ void bond_alb_monitor(struct work_struct *wo=
rk)
>>>       struct list_head *iter;
>>>       struct slave *slave;
>>>   -    read_lock(&bond->lock);
>>> +    rcu_read_lock();
>>>   -    if (!bond_has_slaves(bond)) {
>>> +    if (!bond_has_slaves_rcu(bond)) {
>>> +        rcu_read_unlock();
>>>           bond_info->tx_rebalance_counter =3D 0;
>>>           bond_info->lp_counter =3D 0;
>>>           goto re_arm;
>> If I'm not mistaken there's one more bond_for_each_slave() inside th=
is
>> function
>> which should be converted to RCU.
>=20
> But I really could not find any place should converted to RCU,
>=20
> __rlb_next_rx_slave() is in RCU yet.
>=20
> pls remind me if I miss something.
>=20
> Regards
> Ding
>=20
>=20
I was talking about this piece of code inside bond_alb_monitor():
        /* send learning packets */
        if (bond_info->lp_counter >=3D BOND_ALB_LP_TICKS(bond)) {
                /* change of curr_active_slave involves swapping of mac
addresses.
                 * in order to avoid this swapping from happening while
                 * sending the learning packets, the curr_slave_lock mu=
st
be held for
                 * read.
                 */
                read_lock(&bond->curr_slave_lock);

                bond_for_each_slave(bond, slave, iter)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                        alb_send_learning_packets(slave, slave->dev->de=
v_addr);

                read_unlock(&bond->curr_slave_lock);

                bond_info->lp_counter =3D 0;
        }

This is copied after your patch-set was applied.

Cheers,
 Nik
>>> @@ -1528,7 +1529,7 @@ void bond_alb_monitor(struct work_struct *wor=
k)
>>>             read_lock(&bond->curr_slave_lock);
>>>   -        bond_for_each_slave(bond, slave, iter) {
>>> +        bond_for_each_slave_rcu(bond, slave, iter) {
>>>               tlb_clear_slave(bond, slave, 1);
>>>               if (slave =3D=3D bond->curr_active_slave) {
>>>                   SLAVE_TLB_INFO(slave).load =3D
>>> @@ -1552,11 +1553,9 @@ void bond_alb_monitor(struct work_struct *wo=
rk)
>>>                * dev_set_promiscuity requires rtnl and
>>>                * nothing else.  Avoid race with bond_close.
>>>                */
>>> -            read_unlock(&bond->lock);
>>> -            if (!rtnl_trylock()) {
>>> -                read_lock(&bond->lock);
>>> +            rcu_read_unlock();
>>> +            if (!rtnl_trylock())
>>>                   goto re_arm;
>>> -            }
>>>                 bond_info->rlb_promisc_timeout_counter =3D 0;
>>>   @@ -1568,7 +1567,7 @@ void bond_alb_monitor(struct work_struct *w=
ork)
>>>               bond_info->primary_is_promisc =3D 0;
>>>                 rtnl_unlock();
>>> -            read_lock(&bond->lock);
>>> +            rcu_read_lock();
>>>           }
>>>             if (bond_info->rlb_rebalance) {
>>> @@ -1590,11 +1589,9 @@ void bond_alb_monitor(struct work_struct *wo=
rk)
>>>               }
>>>           }
>>>       }
>>> -
>>> +    rcu_read_unlock();
>>>   re_arm:
>>>       queue_delayed_work(bond->wq, &bond->alb_work, alb_delta_in_ti=
cks);
>>> -
>>> -    read_unlock(&bond->lock);
>>>   }
>>>     /* assumption: called before the slave is attached to the bond
>>>
>> --=20
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>=20
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

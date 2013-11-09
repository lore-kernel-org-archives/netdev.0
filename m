From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 3/10] bonding: rebuild the lock use for bond_alb_monitor()
Date: Sat, 09 Nov 2013 23:14:07 +0800
Message-ID: <527E513F.4010908@gmail.com>
References: <527C4778.5080209@huawei.com> <527D0C42.3010402@redhat.com> <527E4365.6060107@gmail.com> <527E46EA.5030804@redhat.com>
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
Received: from mail-pa0-f42.google.com ([209.85.220.42]:44389 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753507Ab3KIPYv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Nov 2013 10:24:51 -0500
Received: by mail-pa0-f42.google.com with SMTP id kp14so3512469pab.1
        for <netdev@vger.kernel.org>; Sat, 09 Nov 2013 07:24:51 -0800 (PST)
In-Reply-To: <527E46EA.5030804@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/11/9 22:30, Nikolay Aleksandrov =E5=86=99=E9=81=93:
> On 11/09/2013 03:15 PM, Ding Tianhong wrote:
>> =E4=BA=8E 2013/11/9 0:07, Nikolay Aleksandrov =E5=86=99=E9=81=93:
>>> On 11/08/2013 03:07 AM, Ding Tianhong wrote:
>>>> The bond_alb_monitor use bond lock to protect the bond slave list,
>>>> it is no effect here, we need to use RTNL or RCU to replace bond l=
ock,
>>>> the bond_alb_monitor will called 10 times one second, RTNL may los=
s
>>>> performance here, so the bond lock replace with RCU to protect the
>>>> bond slave list, also the RTNL is preserved, the logic of the moni=
tor
>>>> did not changed.
>>>>
>>>> Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
>>>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>>>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>>>> ---
>>>>    drivers/net/bonding/bond_alb.c | 21 +++++++++------------
>>>>    1 file changed, 9 insertions(+), 12 deletions(-)
>>>>
>>>> diff --git a/drivers/net/bonding/bond_alb.c
>>>> b/drivers/net/bonding/bond_alb.c
>>>> index 1fae915..ffdb91b 100644
>>>> --- a/drivers/net/bonding/bond_alb.c
>>>> +++ b/drivers/net/bonding/bond_alb.c
>>>> @@ -816,7 +816,7 @@ static void rlb_rebalance(struct bonding *bond=
)
>>>>        for (; hash_index !=3D RLB_NULL_INDEX;
>>>>             hash_index =3D client_info->used_next) {
>>>>            client_info =3D &(bond_info->rx_hashtbl[hash_index]);
>>>> -        assigned_slave =3D rlb_next_rx_slave(bond);
>>>> +        assigned_slave =3D __rlb_next_rx_slave(bond);
>>>>            if (assigned_slave && (client_info->slave !=3D assigned=
_slave)) {
>>>>                client_info->slave =3D assigned_slave;
>>>>                client_info->ntt =3D 1;
>>>> @@ -1495,9 +1495,10 @@ void bond_alb_monitor(struct work_struct *w=
ork)
>>>>        struct list_head *iter;
>>>>        struct slave *slave;
>>>>    -    read_lock(&bond->lock);
>>>> +    rcu_read_lock();
>>>>    -    if (!bond_has_slaves(bond)) {
>>>> +    if (!bond_has_slaves_rcu(bond)) {
>>>> +        rcu_read_unlock();
>>>>            bond_info->tx_rebalance_counter =3D 0;
>>>>            bond_info->lp_counter =3D 0;
>>>>            goto re_arm;
>>> If I'm not mistaken there's one more bond_for_each_slave() inside t=
his
>>> function
>>> which should be converted to RCU.
>> But I really could not find any place should converted to RCU,
>>
>> __rlb_next_rx_slave() is in RCU yet.
>>
>> pls remind me if I miss something.
>>
>> Regards
>> Ding
>>
>>
> I was talking about this piece of code inside bond_alb_monitor():
>          /* send learning packets */
>          if (bond_info->lp_counter >=3D BOND_ALB_LP_TICKS(bond)) {
>                  /* change of curr_active_slave involves swapping of =
mac
> addresses.
>                   * in order to avoid this swapping from happening wh=
ile
>                   * sending the learning packets, the curr_slave_lock=
 must
> be held for
>                   * read.
>                   */
>                  read_lock(&bond->curr_slave_lock);
>
>                  bond_for_each_slave(bond, slave, iter)
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>                          alb_send_learning_packets(slave, slave->dev-=
>dev_addr);
>
>                  read_unlock(&bond->curr_slave_lock);
>
>                  bond_info->lp_counter =3D 0;
>          }
>
> This is copied after your patch-set was applied.
>
> Cheers,
>   Nik
oh, yes, thanks, I take the focus on the wrong place.

Regards
Ding

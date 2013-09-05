From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v3 5/6] bonding: restructure and add rcu for
 bond_for_each_slave_next()
Date: Thu, 05 Sep 2013 22:29:58 +0800
Message-ID: <52289566.8040900@gmail.com>
References: <5228376D.2040608@huawei.com> <20130905133027.GA26163@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ding Tianhong <dingtianhong@huawei.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Netdev <netdev@vger.kernel.org>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:45892 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752690Ab3IEOjQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 10:39:16 -0400
Received: by mail-pd0-f171.google.com with SMTP id g10so1889049pdj.16
        for <netdev@vger.kernel.org>; Thu, 05 Sep 2013 07:39:16 -0700 (PDT)
In-Reply-To: <20130905133027.GA26163@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/9/5 21:30, Veaceslav Falico =E5=86=99=E9=81=93:
> On Thu, Sep 05, 2013 at 03:49:01PM +0800, Ding Tianhong wrote:
>> Remove the wordy int and add bond_for_each_slave_next_rcu() for=20
>> future use.
>>
>> Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
>> Suggested-by: Veaceslav Falico <vfalico@redhat.com>
>> Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
>> Cc: Nikolay Aleksandrov <nikolay@redhat.com>
>> Cc: Veaceslav Falico <vfalico@redhat.com>
>> ---
>> drivers/net/bonding/bond_alb.c | 3 +--
>> drivers/net/bonding/bond_main.c | 6 ++----
>> drivers/net/bonding/bonding.h | 23 +++++++++++++++++++----
>> 3 files changed, 22 insertions(+), 10 deletions(-)
>>
>> diff --git a/drivers/net/bonding/bond_alb.c=20
>> b/drivers/net/bonding/bond_alb.c
>> index 91f179d..c75d383 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -383,7 +383,6 @@ static struct slave *rlb_next_rx_slave(struct=20
>> bonding *bond)
>> {
>> struct alb_bond_info *bond_info =3D &(BOND_ALB_INFO(bond));
>> struct slave *rx_slave, *slave, *start_at;
>> - int i =3D 0;
>>
>> if (bond_info->next_rx_slave)
>> start_at =3D bond_info->next_rx_slave;
>> @@ -392,7 +391,7 @@ static struct slave *rlb_next_rx_slave(struct=20
>> bonding *bond)
>>
>> rx_slave =3D NULL;
>>
>> - bond_for_each_slave_from(bond, slave, i, start_at) {
>> + bond_for_each_slave_from(bond, slave, start_at) {
>> if (SLAVE_IS_OK(slave)) {
>> if (!rx_slave) {
>> rx_slave =3D slave;
>> diff --git a/drivers/net/bonding/bond_main.c=20
>> b/drivers/net/bonding/bond_main.c
>> index 39e5b1c..4190389 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -782,7 +782,6 @@ static struct slave *bond_find_best_slave(struct=
=20
>> bonding *bond)
>> struct slave *new_active, *old_active;
>> struct slave *bestslave =3D NULL;
>> int mintime =3D bond->params.updelay;
>> - int i;
>>
>> new_active =3D bond->curr_active_slave;
>>
>> @@ -801,7 +800,7 @@ static struct slave *bond_find_best_slave(struct=
=20
>> bonding *bond)
>> /* remember where to stop iterating over the slaves */
>> old_active =3D new_active;
>>
>> - bond_for_each_slave_from(bond, new_active, i, old_active) {
>> + bond_for_each_slave_from(bond, new_active, old_active) {
>> if (new_active->link =3D=3D BOND_LINK_UP) {
>> return new_active;
>> } else if (new_active->link =3D=3D BOND_LINK_BACK &&
>> @@ -2756,7 +2755,6 @@ do_failover:
>> static void bond_ab_arp_probe(struct bonding *bond)
>> {
>> struct slave *slave, *next_slave;
>> - int i;
>>
>> read_lock(&bond->curr_slave_lock);
>>
>> @@ -2788,7 +2786,7 @@ static void bond_ab_arp_probe(struct bonding=20
>> *bond)
>>
>> /* search for next candidate */
>> next_slave =3D bond_next_slave(bond, bond->current_arp_slave);
>> - bond_for_each_slave_from(bond, slave, i, next_slave) {
>> + bond_for_each_slave_from(bond, slave, next_slave) {
>> if (IS_UP(slave->dev)) {
>> slave->link =3D BOND_LINK_BACK;
>> bond_set_slave_active_flags(slave);
>> diff --git a/drivers/net/bonding/bonding.h=20
>> b/drivers/net/bonding/bonding.h
>> index f013b12..48fd41a 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -123,18 +123,33 @@
>> (bond_is_first_slave(bond, pos) ? bond_last_slave_rcu(bond) : \
>> bond_to_slave_rcu((pos)->list.prev))
>>
>> +/* Check whether the slave is the only one in bond */
>> +
>> /**
>> * bond_for_each_slave_from - iterate the slaves list from a starting=
=20
>> point
>> * @bond: the bond holding this list.
>> * @pos: current slave.
>> - * @cnt: counter for max number of moves
>> * @start: starting point.
>> *
>> * Caller must hold bond->lock
>> */
>> -#define bond_for_each_slave_from(bond, pos, cnt, start) \
>> - for (cnt =3D 0, pos =3D start; pos && cnt < (bond)->slave_cnt; \
>> - cnt++, pos =3D bond_next_slave(bond, pos))
>> +#define bond_for_each_slave_from(bond, pos, start) \
>> + for (pos =3D start; pos && &pos->list !=3D &bond->slave_list; \
>> + (pos =3D bond_next_slave(bond, pos)) !=3D start ? pos : \
>> + (pos =3D list_entry(&bond->slave_list, typeof(*pos), list)))
>
> Do you understand the differences of these two implementations?
>
> pos && cnt < (bond)->slave_cnt
>
> vs
>
> pos && &pos->list !=3D &bond->slave_list
>
> I'm sorry, but you should listen to comments.
>
if the slave is only one, it will run once, and out the loop, else if
the slave is more than one, it will run until reach the start again,
here I use the &bond->slave_list to control the loop, as it will not
change any time, maybe it is hard to understand first.

ok, I think they are same, just in the purpose to remove the cnt, so=20
maybe it make you
unconfortable, sorry about that, if you strangly disagree, I will miss=20
this patch, but
thanks again for your different opinions. :)

>> +
>> +/**
>> + * bond_for_each_slave_from_rcu - iterate the slaves list from a=20
>> starting point
>> + * @bond: the bond holding this list.
>> + * @pos: current slave.
>> + * @start: starting point.
>> + *
>> + * Caller must hold rcu_read_lock
>> + */
>> +#define bond_for_each_slave_from_rcu(bond, pos, start) \
>> + for (pos =3D start; pos && &pos->list !=3D &bond->slave_list; \
>> + (pos =3D bond_next_slave_rcu(bond, pos)) !=3D start ? pos : \
>> + (pos =3D list_entry_rcu(&bond->slave_list, typeof(*pos), list)))
>>
>> /**
>> * bond_for_each_slave - iterate over all slaves
>> --=20
>> 1.8.2.1
>>
>>
>>
> --=20
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at http://vger.kernel.org/majordomo-info.html
>

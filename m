From: Ding Tianhong <dthxman@gmail.com>
Subject: Re: [PATCH net-next v2 5/6] bonding: restructure and add rcu for
 bond_for_each_slave_next()
Date: Wed, 04 Sep 2013 23:02:28 +0800
Message-ID: <52274B84.2010509@gmail.com>
References: <522700EF.3000702@huawei.com> <20130904103540.GP1992@redhat.com>
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
Received: from mail-pb0-f53.google.com ([209.85.160.53]:57588 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762801Ab3IDPLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Sep 2013 11:11:50 -0400
Received: by mail-pb0-f53.google.com with SMTP id up15so432131pbc.26
        for <netdev@vger.kernel.org>; Wed, 04 Sep 2013 08:11:49 -0700 (PDT)
In-Reply-To: <20130904103540.GP1992@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=E4=BA=8E 2013/9/4 18:35, Veaceslav Falico =E5=86=99=E9=81=93:
> On Wed, Sep 04, 2013 at 05:44:15PM +0800, Ding Tianhong wrote:
> ...snip...
>> +/* Check whether the slave is the only one in bond */
>> +#define bond_is_only_slave(bond, pos) \
>> + (((pos)->list.prev =3D=3D &(bond)->slave_list) && \
>> + ((pos)->list.next =3D=3D &(bond)->slave_list))
>
> Could be done without pos at all -
>
> !list_empty(&(bond)->slave_list) && \
> &(bond)->slave_list.next =3D=3D &(bond)->slave_list.prev
>
> If we have only one slave and pos is NOT our slave then... well.. we =
have
> big troubles.
>
yes, more simple more beautiful, thanks.

but if the pos is not our slave, it is the mistake, not bug. :)

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
>> + for (pos =3D start; pos && (bond_is_only_slave(bond, start) ? \
>> + &pos->list !=3D &bond->slave_list : \
>> + &pos->list !=3D &start->list); bond_is_only_slave(bond, start) ? \
>> + (pos =3D list_entry(pos->list.next, typeof(*pos), list)) : \
>> + (pos =3D bond_next_slave(bond, pos)))
>
> Did you check that?
>
> pos =3D slave1 (bond has more than one slave);
> pos && &pos->list !=3D &slave1->list - false.
>
> We won't ever enter this loop if we have >1 slaves.
>
> I don't understand this at all.
>

ok, the logic is : if slaves =3D=3D 1, run once for the slave.
if slaves > 1, run loops until reach the end list.
I could not get a better way to simplify the function, I think it is a=20
suitable scheme.

by the way, I test the function and works well. :)

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
>> + for (pos =3D start; pos && (bond_is_only_slave(bond, start) ? \
>> + &pos->list !=3D &bond->slave_list : \
>> + &pos->list !=3D &start->list); bond_is_only_slave(bond, start) ? \
>> + (pos =3D list_entry_rcu(pos->list.next, typeof(*pos), list)) : \
>> + (pos =3D bond_next_slave_rcu(bond, pos)))
>
> Ditto as bond_for_each_slave_from() and, also, see my comment about R=
CU
> from patch 1.
>
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

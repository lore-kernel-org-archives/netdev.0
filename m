From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v1] bonding: implement bond_poll_controller()
Date: Thu, 5 Mar 2015 17:37:42 -0800
Message-ID: <CAF2d9jjH-8FkZwkNPF3iC=3cVLnGi739amwchWZ7hRqHj_DeJA@mail.gmail.com>
References: <1425522400-3671-1-git-send-email-maheshb@google.com> <1425557425.3164.55.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	Maciej Zenczykowski <maze@google.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:44555 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755289AbbCFBiF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 20:38:05 -0500
Received: by obcuy5 with SMTP id uy5so10796098obc.11
        for <netdev@vger.kernel.org>; Thu, 05 Mar 2015 17:38:02 -0800 (PST)
In-Reply-To: <1425557425.3164.55.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 5, 2015 at 4:10 AM, Ben Hutchings <ben@decadent.org.uk> wrote:
> On Wed, 2015-03-04 at 18:26 -0800, Mahesh Bandewar wrote:
>> This patches implements the poll_controller support for all
>> bonding driver. If the slaves have poll_controller net_op defined,
>> this implementation calls them. This is mode agnostic implementation
>> and iterates through all slaves (based on mode) and calls respective
>> handler.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>>  drivers/net/bonding/bond_main.c | 33 +++++++++++++++++++++++++++++++++
>>  1 file changed, 33 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index af5908a2190c..cbf77d388f53 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -928,6 +928,39 @@ static inline void slave_disable_netpoll(struct slave *slave)
>>
>>  static void bond_poll_controller(struct net_device *bond_dev)
>>  {
>> +     struct bonding *bond = netdev_priv(bond_dev);
>> +     struct slave *slave = NULL;
>> +     struct list_head *iter;
>> +     struct ad_info ad_info;
>> +     struct netpoll_info *ni;
>> +     const struct net_device_ops *ops;
>> +
>> +     if (BOND_MODE(bond) == BOND_MODE_8023AD)
>> +             if (bond_3ad_get_active_agg_info(bond, &ad_info))
>> +                     return;
>
> I don't think you need all that information...
>
>> +     rcu_read_lock();
>> +     bond_for_each_slave_rcu(bond, slave, iter) {
>> +             ops = slave->dev->netdev_ops;
>> +             if (!bond_slave_is_up(slave) || !ops->ndo_poll_controller)
>> +                     continue;
>> +
>> +             if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>> +                     struct aggregator *agg =
>> +                         SLAVE_AD_INFO(slave)->port.aggregator;
>> +
>> +                     if (agg &&
>> +                         agg->aggregator_identifier != ad_info.aggregator_id)
>> +                             continue;
>
> I think this could be:
>
>                         if (!(agg && agg->is_active))
>                                 continue;
>
> Ben.
>
yes, thanks for this micro-optimization.

>> +             }
>> +
>> +             ni = rcu_dereference_bh(slave->dev->npinfo);
>> +             if (down_trylock(&ni->dev_lock))
>> +                     continue;
>> +             ops->ndo_poll_controller(slave->dev);
>> +             up(&ni->dev_lock);
>> +     }
>> +     rcu_read_unlock();
>>  }
>>
>>  static void bond_netpoll_cleanup(struct net_device *bond_dev)
>
> --
> Ben Hutchings
> Beware of programmers who carry screwdrivers. - Leonard Brandwein
>
> --
> Ben Hutchings
> Beware of programmers who carry screwdrivers. - Leonard Brandwein

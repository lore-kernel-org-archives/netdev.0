From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH next 2/6] bonding: implement bond_poll_controller()
Date: Sat, 7 Feb 2015 20:19:23 -0800
Message-ID: <CAF2d9jhVAqDCyNP7De4cpqOTAoLpsar=T2i7S3sKCmOF2yukJw@mail.gmail.com>
References: <1423270311-9181-1-git-send-email-maheshb@google.com> <20150207090400.GA11343@vps.falico.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Veaceslav Falico <vfalico@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f46.google.com ([209.85.218.46]:34127 "EHLO
	mail-oi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751836AbbBHETo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Feb 2015 23:19:44 -0500
Received: by mail-oi0-f46.google.com with SMTP id a141so17905657oig.5
        for <netdev@vger.kernel.org>; Sat, 07 Feb 2015 20:19:43 -0800 (PST)
In-Reply-To: <20150207090400.GA11343@vps.falico.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 7, 2015 at 1:04 AM, Veaceslav Falico <vfalico@gmail.com> wrote:
> On Fri, Feb 06, 2015 at 04:51:51PM -0800, Mahesh Bandewar wrote:
>>
>> This patches implements the poll_controller support for all
>> bonding driver. If the slaves have poll_controller net_op defined,
>> this implementation calls them. This is mode agnostic implementation
>> and iterates through all slaves (based on mode) and calls respective
>> handler.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>
>
> Really good patchset, thank you. Two nitpicks below, nothing serious. Also,
> please, add Doc/bonding.txt changes for every user-visible
> change/enhancement, this doc is a go-to for a lot of users.
>
> Otherwise, with the doc and other issues, pointed by Jay and Andy, fixed, I
> guess it's good to go. The 0/ patch would be welcome too, btw.
>
>
>> ---
>> drivers/net/bonding/bond_3ad.c  | 24 +++++++++++++++++++++
>> drivers/net/bonding/bond_main.c | 47
>> +++++++++++++++++++++++++++++++++++++++++
>> include/net/bond_3ad.h          |  1 +
>> 3 files changed, 72 insertions(+)
>>
>> diff --git a/drivers/net/bonding/bond_3ad.c
>> b/drivers/net/bonding/bond_3ad.c
>> index 9b436696b95e..14f2ebe786c5 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -2477,6 +2477,30 @@ int bond_3ad_get_active_agg_info(struct bonding
>> *bond, struct ad_info *ad_info)
>>         return ret;
>> }
>>
>> +#define BOND_3AD_PORT_OPERATIONAL \
>> +               (AD_STATE_DISTRIBUTING | AD_STATE_COLLECTING | \
>> +                AD_STATE_SYNCHRONIZATION | AD_STATE_AGGREGATION)
>> +
>> +static int bond_3ad_port_operational(struct slave *slave)
>> +{
>> +       port_t *port = &SLAVE_AD_INFO(slave)->port;
>> +
>> +       return bond_slave_can_tx(slave) &&
>> +              (port->actor_oper_port_state &
>> port->partner_oper.port_state &
>> +               BOND_3AD_PORT_OPERATIONAL) == BOND_3AD_PORT_OPERATIONAL;
>> +}
>> +
>> +/* bond_3ad_port_is_active - check if a slave port is active or not. A
>> port
>> + * is active when it can forward traffic.
>> + *
>> + * @slave: slave port to check state for.
>> + * Returns: 0 if not active else is active.
>> + */
>> +int bond_3ad_port_is_active(struct slave *slave)
>> +{
>> +       return bond_3ad_port_operational(slave);
>> +}
>> +
>> int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>>                          struct slave *slave)
>> {
>> diff --git a/drivers/net/bonding/bond_main.c
>> b/drivers/net/bonding/bond_main.c
>> index c9e519cb9214..a50ec87486f3 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -928,6 +928,53 @@ static inline void slave_disable_netpoll(struct slave
>> *slave)
>>
>> static void bond_poll_controller(struct net_device *bond_dev)
>> {
>> +       struct bonding *bond = netdev_priv(bond_dev);
>> +       struct slave *slave = NULL;
>> +       struct list_head *iter;
>> +       struct ad_info ad_info;
>> +       struct aggregator *agg;
>> +       const struct net_device_ops *ops;
>> +       bool call_slave_netpoll;
>> +
>> +       if (BOND_MODE(bond) == BOND_MODE_8023AD)
>> +               if (bond_3ad_get_active_agg_info(bond, &ad_info))
>> +                       return;
>> +
>> +       bond_for_each_slave(bond, slave, iter) {
>> +               call_slave_netpoll = false;
>> +               switch (BOND_MODE(bond)) {
>> +               case BOND_MODE_8023AD:
>> +                       agg = SLAVE_AD_INFO(slave)->port.aggregator;
>> +                       if (!bond_slave_is_up(slave))
>
>
> bond_3ad_port_is_active() already contains the check for being up.
>
>> +                               break;
>> +                       if (agg && agg->aggregator_identifier !=
>
>
> Hm, should we poll it without an aggregator?
>
>> +                               ad_info.aggregator_id)
>> +                               break;
>> +                       if (!bond_3ad_port_is_active(slave) &&
>> +                           ad_info.ports != 1)
>> +                               break;
>> +
>> +                       call_slave_netpoll = true;
>> +                       break;
>> +               default:
>> +                       if (bond_slave_is_up(slave))
>> +                               call_slave_netpoll = true;
>> +                       break;
>> +               }
>> +
>> +               if (call_slave_netpoll) {
>> +                       ops = slave->dev->netdev_ops;
>> +                       if (ops->ndo_poll_controller) {
>
>
> It's weird to see this check so down the road. Maybe reorg the logic to
> something like:
>
> bond_for_each_slave() {
>         if (!bond_slave_is_up() || !bond_slave_has_ndo_poll())
>                 continue;
>
>         if (BOND_MODE(bond) == 3AD && !bond_3ad_port_is_active())
>                 continue;
>
>         slave-do_ndo_poll_stuff();
> }
>
> Just as a thought, might be easier to read/shorter.
>
>
OK, I'll try that. thanks

>> +                               struct netpoll_info *ni =
>> +
>> rcu_dereference_bh(slave->dev->npinfo);
>> +
>> +                               if (down_trylock(&ni->dev_lock))
>> +                                       continue;
>> +                               ops->ndo_poll_controller(slave->dev);
>> +                               up(&ni->dev_lock);
>> +                       }
>> +               }
>> +       }
>> }
>>
>> static void bond_netpoll_cleanup(struct net_device *bond_dev)
>> diff --git a/include/net/bond_3ad.h b/include/net/bond_3ad.h
>> index f04cdbb7848e..6c455c646d61 100644
>> --- a/include/net/bond_3ad.h
>> +++ b/include/net/bond_3ad.h
>> @@ -278,5 +278,6 @@ int bond_3ad_lacpdu_recv(const struct sk_buff *skb,
>> struct bonding *bond,
>>                          struct slave *slave);
>> int bond_3ad_set_carrier(struct bonding *bond);
>> void bond_3ad_update_lacp_rate(struct bonding *bond);
>> +int bond_3ad_port_is_active(struct slave *slave);
>> #endif /* _NET_BOND_3AD_H */
>>
>> --
>> 2.2.0.rc0.207.ga3a616c
>>
>

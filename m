From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Thu, 4 Sep 2014 17:10:28 -0700
Message-ID: <CAF2d9ji2Dsi9dr6B0HKy4oQ841CN-00zWcOxCa+oTyPp79hOHA@mail.gmail.com>
References: <1409780851-32081-1-git-send-email-maheshb@google.com> <54086645.3010102@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f173.google.com ([209.85.220.173]:58227 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400AbaIEAKu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2014 20:10:50 -0400
Received: by mail-vc0-f173.google.com with SMTP id im17so11592094vcb.32
        for <netdev@vger.kernel.org>; Thu, 04 Sep 2014 17:10:49 -0700 (PDT)
In-Reply-To: <54086645.3010102@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 4, 2014 at 6:16 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> On 03/09/14 23:47, Mahesh Bandewar wrote:
>>
>> Earlier change to use usable slave array for TLB mode had an additional
>> performance advantage. So extending the same logic to all other modes
>> that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>> Also consolidating this with the earlier TLB change.
>>
>> The main idea is to build the usable slaves array in the control path
>> and use that array for slave selection during xmit operation.
>>
>> Measured performance in a setup with a bond of 4x1G NICs with 200
>> instances of netperf for the modes involved (3ad, xor, tlb)
>> cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>>
>> Mode        TPS-Before   TPS-After
>>
>> 802.3ad   : 468,694      493,101
>> TLB (lb=0): 392,583      392,965
>> XOR       : 475,696      484,517
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>
> <<snip>>
> Hi Mahesh,
> I really like this idea, but I think this patch is far from ready and needs
> more thorough examination.
>
I see that you have looked it from the XOR-mode perspective and thanks
for that. I admit that, I did not test that mode thoroughly.

>
>> diff --git a/drivers/net/bonding/bond_main.c
>> b/drivers/net/bonding/bond_main.c
>> index f0f5eab0fab1..b0e8e7cfa10f 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>
>
> What happens to modes that don't have miimon enabled i.e. if I do: modprobe
> bonding mode=2 and enslave something then the slave array will never get
> created and I won't be able to xmit anything ever because miimon is 0 by
> default and even if it wasn't I'll have to wait for it to create the slave
> array before I can do any transmissions.
> By the way, I just noticed that arp_interval is actually supported in XOR
> mode.
>
Yes, this should not be restricted to just the miimon case, and it
should be irrespective of miimon, arp-mon enabled / disabled etc. I'll
correct that!

>
>> @@ -1693,6 +1693,9 @@ static int __bond_release_one(struct net_device
>> *bond_dev,
>>         if (BOND_MODE(bond) == BOND_MODE_8023AD)
>>                 bond_3ad_unbind_slave(slave);
>>
> ^^^^^^^^^^^^^^^^^^^^^^^
> Empty line.
>
>
>> +       else if (BOND_MODE(bond) == BOND_MODE_XOR)
>> +               bond_update_slave_arr(bond, slave);
>> +
>>         write_unlock_bh(&bond->lock);
>>
>>         netdev_info(bond_dev, "Releasing %s interface %s\n",
>> @@ -2009,6 +2012,9 @@ static void bond_miimon_commit(struct bonding *bond)
>>                                 bond_alb_handle_link_change(bond, slave,
>>                                                             BOND_LINK_UP);
>>
>> +                       if (BOND_MODE(bond) == BOND_MODE_XOR)
>> +                               bond_update_slave_arr(bond, NULL);
>> +
>>                         if (!bond->curr_active_slave ||
>>                             (slave == bond->primary_slave))
>>                                 goto do_failover;
>> @@ -2037,6 +2043,9 @@ static void bond_miimon_commit(struct bonding *bond)
>>                                 bond_alb_handle_link_change(bond, slave,
>>
>> BOND_LINK_DOWN);
>>
>> +                       if (BOND_MODE(bond) == BOND_MODE_XOR)
>> +                               bond_update_slave_arr(bond, slave);
>> +
>>                         if (slave ==
>> rcu_access_pointer(bond->curr_active_slave))
>>                                 goto do_failover;
>>
>> @@ -3149,6 +3158,7 @@ static int bond_open(struct net_device *bond_dev)
>>   static int bond_close(struct net_device *bond_dev)
>>   {
>>         struct bonding *bond = netdev_priv(bond_dev);
>> +       struct bond_up_slave *arr;
>>
>>         bond_work_cancel_all(bond);
>>         bond->send_peer_notif = 0;
>> @@ -3156,6 +3166,10 @@ static int bond_close(struct net_device *bond_dev)
>>                 bond_alb_deinitialize(bond);
>>         bond->recv_probe = NULL;
>>
>> +       arr = rtnl_dereference(bond->slave_arr);
>> +       if (arr)
>> +           kfree_rcu(arr, rcu);
>> +
>
> ^^^^^^^^^^^^^^
> Bond close is dealt with, but what happens after: ip l set bond down, ip l
> set bond up
> or alternatively: ip l set bond down, echo -slave > slaves
>
> The array is freed but slave_arr still points to it.
>
good point. I'll update it. Also applicable to the earlier TLB mode,
so will add that into the patch for the stable.

>
>>         return 0;
>>   }
>>
>> @@ -3684,15 +3698,84 @@ static int bond_xmit_activebackup(struct sk_buff
>> *skb, struct net_device *bond_d
>>         return NETDEV_TX_OK;
>>   }
>>
>> -/* In bond_xmit_xor() , we determine the output device by using a pre-
>> - * determined xmit_hash_policy(), If the selected device is not enabled,
>> - * find the next active slave.
>> +/* Build the usable slaves array in control path for modes that use
>> xmit-hash
>> + * to determine the slave interface -
>> + * (a) BOND_MODE_8023AD
>> + * (b) BOND_MODE_XOR
>> + * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
>>    */
>> -static int bond_xmit_xor(struct sk_buff *skb, struct net_device
>> *bond_dev)
>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>
> ^^^^^^^^^^^^^^^^^^^^^^^^^^
> In general any failing in this function means that the old array stays with
> the old slave list. I think that you really should revisit the places that
> use this after the patch and see if that won't cause any problems.
>
The only really problematic scenario is where one of the slaves is
disappearing (as pointed out by Jay earlier) and I'll fix that in the
next version. For rest of the cases, the worse that could happen is
the slave that is selected wont be able to transmit that packet. As I
have explained earlier, in case of failure to allocate such small
portion of memory (less than 1k in worse scenario!) machine has lot
other problems to handle than not being able to send a packet out.

>
>>   {
>> -       struct bonding *bond = netdev_priv(bond_dev);
>> +       struct slave *slave;
>> +       struct list_head *iter;
>> +       struct bond_up_slave *new_arr, *old_arr;
>> +       int slaves_in_agg;
>> +       int agg_id = 0;
>> +       int ret = 0;
>> +
>> +       new_arr = kzalloc(offsetof(struct bond_up_slave,
>> arr[bond->slave_cnt]),
>> +                         GFP_ATOMIC);
>> +       if (!new_arr) {
>> +               ret = -ENOMEM;
>> +               goto out;
>> +       }
>> +       if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>> +               struct ad_info ad_info;
>> +
>> +               if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> Called with RCU otherwise sparse won't be happy. Perhaps
> bond_3ad_get_active_agg_info() ?
>
Yes, corrected!
>
>> +                       pr_debug("__bond_3ad_get_active_agg_info
>> failed\n");
>> +                       kfree_rcu(new_arr, rcu);
>> +                       ret = -EINVAL;
>> +                       goto out;
>> +               }
>> +               slaves_in_agg = ad_info.ports;
>> +               agg_id = ad_info.aggregator_id;
>> +       }
>> +       bond_for_each_slave(bond, slave, iter) {
>> +               if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>> +                       struct aggregator *agg;
>> +
>> +                       agg = SLAVE_AD_INFO(slave)->port.aggregator;
>> +                       if (!agg || agg->aggregator_identifier != agg_id)
>> +                               continue;
>> +               }
>> +               if (!bond_slave_can_tx(slave))
>> +                       continue;
>> +               if (skipslave == slave)
>> +                       continue;
>> +               new_arr->arr[new_arr->count++] = slave;
>> +       }
>>
>> -       bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) %
>> bond->slave_cnt);
>> +       old_arr = rcu_dereference_protected(bond->slave_arr,
>> +                                           lockdep_rtnl_is_held() ||
>> +                                           lockdep_is_held(&bond->lock)
>> ||
>> +
>> lockdep_is_held(&bond->curr_slave_lock));
>
> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
> This line is the most troublesome for me, which lock is it ? Does this mean
> that whichever I hold from the three I can update the slave array ?
> I don't think this is worked out well, you should explicitly specify how and
> why it is safe to update this under each of the locks and maybe you'll be
> able to reduce the lock list :-)
>
This is primarily because of different code paths it's taking to reach
here. In all these cases, one of those locks is held. Unfortunately
there are three such locks  that I have identified (for all three
modes involved) and hence the above line.

>
>> +       rcu_assign_pointer(bond->slave_arr, new_arr);
>> +       if (old_arr)
>> +               kfree_rcu(old_arr, rcu);
>> +
>> +out:
>> +       return ret;
>> +}
>> +
>> +/* Use this Xmit function for 3AD as well as XOR modes. The current
>> + * usable slave array is formed in the control path. The xmit function
>> + * just calculates hash and sends the packet out.
>> + */
>> +int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +       struct bonding *bond = netdev_priv(dev);
>> +       struct slave *slave;
>> +       struct bond_up_slave *slaves;
>> +
>> +       slaves = rcu_dereference(bond->slave_arr);
>> +       if (slaves && slaves->count) {
>> +               slave = slaves->arr[bond_xmit_hash(bond, skb) %
>> slaves->count];
>> +               bond_dev_queue_xmit(bond, skb, slave->dev);
>> +       } else {
>> +               dev_kfree_skb_any(skb);
>> +               atomic_long_inc(&dev->tx_dropped);
>> +       }
>>
>>         return NETDEV_TX_OK;
>>   }
>> @@ -3794,12 +3877,11 @@ static netdev_tx_t __bond_start_xmit(struct
>> sk_buff *skb, struct net_device *dev
>>                 return bond_xmit_roundrobin(skb, dev);
>>         case BOND_MODE_ACTIVEBACKUP:
>>                 return bond_xmit_activebackup(skb, dev);
>> +       case BOND_MODE_8023AD:
>>         case BOND_MODE_XOR:
>> -               return bond_xmit_xor(skb, dev);
>> +               return bond_3ad_xor_xmit(skb, dev);
>>         case BOND_MODE_BROADCAST:
>>                 return bond_xmit_broadcast(skb, dev);
>> -       case BOND_MODE_8023AD:
>> -               return bond_3ad_xmit_xor(skb, dev);
>>         case BOND_MODE_ALB:
>>                 return bond_alb_xmit(skb, dev);
>>         case BOND_MODE_TLB:
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index aace510d08d1..4a6195c0de60 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -177,6 +177,12 @@ struct slave {
>>         struct kobject kobj;
>>   };
>>
>> +struct bond_up_slave {
>> +       unsigned int    count;
>> +       struct rcu_head rcu;
>> +       struct slave    *arr[0];
>> +};
>> +
>>   /*
>>    * Link pseudo-state only used internally by monitors
>>    */
>> @@ -196,6 +202,7 @@ struct bonding {
>>         struct   slave __rcu *curr_active_slave;
>>         struct   slave __rcu *current_arp_slave;
>>         struct   slave *primary_slave;
>> +       struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves
>> */
>>         bool     force_primary;
>>         s32      slave_cnt; /* never change this value outside the
>> attach/detach wrappers */
>>         int     (*recv_probe)(const struct sk_buff *, struct bonding *,
>> @@ -527,6 +534,7 @@ const char *bond_slave_link_status(s8 link);
>>   struct bond_vlan_tag *bond_verify_device_path(struct net_device
>> *start_dev,
>>                                               struct net_device *end_dev,
>>                                               int level);
>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
>>
>>   #ifdef CONFIG_PROC_FS
>>   void bond_create_proc_entry(struct bonding *bond);
>>
>

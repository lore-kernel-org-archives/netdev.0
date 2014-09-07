From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v1 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Sat, 6 Sep 2014 22:33:35 -0700
Message-ID: <CAF2d9jhXEMZF-W+wYns4NCiJ1W2LjDoNEmO2X-3791DmbYaDkg@mail.gmail.com>
References: <1409985356-2384-1-git-send-email-maheshb@google.com> <540AE9CC.10206@redhat.com>
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
Received: from mail-vc0-f173.google.com ([209.85.220.173]:36852 "EHLO
	mail-vc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaIGFd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2014 01:33:57 -0400
Received: by mail-vc0-f173.google.com with SMTP id le20so236072vcb.18
        for <netdev@vger.kernel.org>; Sat, 06 Sep 2014 22:33:56 -0700 (PDT)
In-Reply-To: <540AE9CC.10206@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 6, 2014 at 4:02 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> On 09/06/2014 08:35 AM, Mahesh Bandewar wrote:
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
>> v1:
>>   (a) If bond_update_slave_arr() fails to allocate memory, it will overwrite
>>       the slave that need to be removed.
>>   (b) Freeing of array will assign NULL (to handle bond->down to bond->up
>>       transition gracefully.
>>   (c) Change from pr_debug() to pr_err() if bond_update_slave_arr() returns
>>       failure.
>>   (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases and
>>       will populate the array even if these parameters are not used.
>>   (e) 3AD: Should handle the ad_agg_selection_logic correctly.
>>
>>  drivers/net/bonding/bond_3ad.c  |  79 ++++-----------------
>>  drivers/net/bonding/bond_alb.c  |  45 +-----------
>>  drivers/net/bonding/bond_alb.h  |   8 ---
>>  drivers/net/bonding/bond_main.c | 150 ++++++++++++++++++++++++++++++++++++----
>>  drivers/net/bonding/bonding.h   |   8 +++
>>  5 files changed, 161 insertions(+), 129 deletions(-)
>>
> Hi Mahesh,
> From my last posts I revisited the bond_3ad_state_machine_handler() case
> and I think I was wrong that the machine state lock would protect you since
> it's different for every port so if the machine handler runs for port X and
> something else executes for port Y without bond->lock for writing - race.
> As I said in my last post primary_reselect is an ideal case for that even
> though it's not used in 3ad, it can be altered and to cause a reselect of
> the active slave thus rebuilding the slave_arr. Of course this is
> theoretical, but I'd prefer not to have such bugs in the first place.
> More notes below.
>
I'm not going to claim that I understood all the locking scenarios in
all modes but your attempt to simplify these locks is a step in right
direction and hopefully we can do all these operations under RTNL.

>> diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>> index ee2c73a9de39..ba05c83d5d83 100644
>> --- a/drivers/net/bonding/bond_3ad.c
>> +++ b/drivers/net/bonding/bond_3ad.c
>> @@ -1579,6 +1579,8 @@ static void ad_agg_selection_logic(struct aggregator *agg)
>>                               __disable_port(port);
>>                       }
>>               }
>> +             if (bond_update_slave_arr(bond, NULL))
>> +                     pr_err("Failed to build slave-array for 3ad mode.\n");
>>       }
>>
>>       /* if the selected aggregator is of join individuals
>> @@ -1717,6 +1719,8 @@ static void ad_enable_collecting_distributing(struct port *port)
>>                        port->actor_port_number,
>>                        port->aggregator->aggregator_identifier);
>>               __enable_port(port);
>> +             if (bond_update_slave_arr(port->slave->bond, NULL))
>> +                     pr_err("Failed to build slave-array for 3ad mode.\n");
>>       }
>>  }
>>
>> @@ -1733,6 +1737,8 @@ static void ad_disable_collecting_distributing(struct port *port)
>>                        port->actor_port_number,
>>                        port->aggregator->aggregator_identifier);
>>               __disable_port(port);
>> +             if (bond_update_slave_arr(port->slave->bond, NULL))
>> +                     pr_err("Failed to build slave-array for 3ad mode.\n");
>>       }
>>  }
>>
>> @@ -1917,6 +1923,9 @@ void bond_3ad_unbind_slave(struct slave *slave)
>>       __update_lacpdu_from_port(port);
>>       ad_lacpdu_send(port);
>>
>> +     if (bond_update_slave_arr(bond, slave))
>> +             pr_err("Failed to build slave-array for 3AD mode.\n");
>> +
>>       /* check if this aggregator is occupied */
>>       if (aggregator->lag_ports) {
>>               /* check if there are other ports related to this aggregator
>> @@ -2311,6 +2320,9 @@ void bond_3ad_handle_link_change(struct slave *slave, char link)
>>        */
>>       port->sm_vars |= AD_PORT_BEGIN;
>>
>> +     if (bond_update_slave_arr(slave->bond, NULL))
>> +             pr_err("Failed to build slave-array for 3ad mode.\n");
>> +
>>       __release_state_machine_lock(port);
>>  }
>>
>> @@ -2407,73 +2419,6 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
>>       return ret;
>>  }
>>
>> -int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
>> -{
>> -     struct bonding *bond = netdev_priv(dev);
>> -     struct slave *slave, *first_ok_slave;
>> -     struct aggregator *agg;
>> -     struct ad_info ad_info;
>> -     struct list_head *iter;
>> -     int slaves_in_agg;
>> -     int slave_agg_no;
>> -     int agg_id;
>> -
>> -     if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
>> -             netdev_dbg(dev, "__bond_3ad_get_active_agg_info failed\n");
>> -             goto err_free;
>> -     }
>> -
>> -     slaves_in_agg = ad_info.ports;
>> -     agg_id = ad_info.aggregator_id;
>> -
>> -     if (slaves_in_agg == 0) {
>> -             netdev_dbg(dev, "active aggregator is empty\n");
>> -             goto err_free;
>> -     }
>> -
>> -     slave_agg_no = bond_xmit_hash(bond, skb) % slaves_in_agg;
>> -     first_ok_slave = NULL;
>> -
>> -     bond_for_each_slave_rcu(bond, slave, iter) {
>> -             agg = SLAVE_AD_INFO(slave)->port.aggregator;
>> -             if (!agg || agg->aggregator_identifier != agg_id)
>> -                     continue;
>> -
>> -             if (slave_agg_no >= 0) {
>> -                     if (!first_ok_slave && bond_slave_can_tx(slave))
>> -                             first_ok_slave = slave;
>> -                     slave_agg_no--;
>> -                     continue;
>> -             }
>> -
>> -             if (bond_slave_can_tx(slave)) {
>> -                     bond_dev_queue_xmit(bond, skb, slave->dev);
>> -                     goto out;
>> -             }
>> -     }
>> -
>> -     if (slave_agg_no >= 0) {
>> -             netdev_err(dev, "Couldn't find a slave to tx on for aggregator ID %d\n",
>> -                        agg_id);
>> -             goto err_free;
>> -     }
>> -
>> -     /* we couldn't find any suitable slave after the agg_no, so use the
>> -      * first suitable found, if found.
>> -      */
>> -     if (first_ok_slave)
>> -             bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
>> -     else
>> -             goto err_free;
>> -
>> -out:
>> -     return NETDEV_TX_OK;
>> -err_free:
>> -     /* no suitable interface, frame not sent */
>> -     dev_kfree_skb_any(skb);
>> -     goto out;
>> -}
>> -
>>  int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
>>                        struct slave *slave)
>>  {
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>> index 73c21e233131..334d92127baf 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -200,7 +200,6 @@ static int tlb_initialize(struct bonding *bond)
>>  static void tlb_deinitialize(struct bonding *bond)
>>  {
>>       struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> -     struct tlb_up_slave *arr;
>>
>>       _lock_tx_hashtbl_bh(bond);
>>
>> @@ -208,10 +207,6 @@ static void tlb_deinitialize(struct bonding *bond)
>>       bond_info->tx_hashtbl = NULL;
>>
>>       _unlock_tx_hashtbl_bh(bond);
>> -
>> -     arr = rtnl_dereference(bond_info->slave_arr);
>> -     if (arr)
>> -             kfree_rcu(arr, rcu);
>>  }
>>
>>  static long long compute_gap(struct slave *slave)
>> @@ -1409,39 +1404,9 @@ out:
>>       return NETDEV_TX_OK;
>>  }
>>
>> -static int bond_tlb_update_slave_arr(struct bonding *bond,
>> -                                  struct slave *skipslave)
>> -{
>> -     struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> -     struct slave *tx_slave;
>> -     struct list_head *iter;
>> -     struct tlb_up_slave *new_arr, *old_arr;
>> -
>> -     new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
>> -                       GFP_ATOMIC);
>> -     if (!new_arr)
>> -             return -ENOMEM;
>> -
>> -     bond_for_each_slave(bond, tx_slave, iter) {
>> -             if (!bond_slave_can_tx(tx_slave))
>> -                     continue;
>> -             if (skipslave == tx_slave)
>> -                     continue;
>> -             new_arr->arr[new_arr->count++] = tx_slave;
>> -     }
>> -
>> -     old_arr = rtnl_dereference(bond_info->slave_arr);
>> -     rcu_assign_pointer(bond_info->slave_arr, new_arr);
>> -     if (old_arr)
>> -             kfree_rcu(old_arr, rcu);
>> -
>> -     return 0;
>> -}
>> -
>>  int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>  {
>>       struct bonding *bond = netdev_priv(bond_dev);
>> -     struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>       struct ethhdr *eth_data;
>>       struct slave *tx_slave = NULL;
>>       u32 hash_index;
>> @@ -1462,9 +1427,9 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>                                                             hash_index & 0xFF,
>>                                                             skb->len);
>>                       } else {
>> -                             struct tlb_up_slave *slaves;
>> +                             struct bond_up_slave *slaves;
>>
>> -                             slaves = rcu_dereference(bond_info->slave_arr);
>> +                             slaves = rcu_dereference(bond->slave_arr);
>>                               if (slaves && slaves->count)
>>                                       tx_slave = slaves->arr[hash_index %
>>                                                              slaves->count];
>> @@ -1733,10 +1698,6 @@ void bond_alb_deinit_slave(struct bonding *bond, struct slave *slave)
>>               rlb_clear_slave(bond, slave);
>>       }
>>
>> -     if (bond_is_nondyn_tlb(bond))
>> -             if (bond_tlb_update_slave_arr(bond, slave))
>> -                     pr_err("Failed to build slave-array for TLB mode.\n");
>> -
>>  }
>>
>>  /* Caller must hold bond lock for read */
>> @@ -1762,7 +1723,7 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
>>       }
>>
>>       if (bond_is_nondyn_tlb(bond)) {
>> -             if (bond_tlb_update_slave_arr(bond, NULL))
>> +             if (bond_update_slave_arr(bond, NULL))
>>                       pr_err("Failed to build slave-array for TLB mode.\n");
>>       }
>>  }
>> diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>> index aaeac61d03cf..5fc76c01636c 100644
>> --- a/drivers/net/bonding/bond_alb.h
>> +++ b/drivers/net/bonding/bond_alb.h
>> @@ -139,20 +139,12 @@ struct tlb_slave_info {
>>                        */
>>  };
>>
>> -struct tlb_up_slave {
>> -     unsigned int    count;
>> -     struct rcu_head rcu;
>> -     struct slave    *arr[0];
>> -};
>> -
>>  struct alb_bond_info {
>>       struct tlb_client_info  *tx_hashtbl; /* Dynamically allocated */
>>       spinlock_t              tx_hashtbl_lock;
>>       u32                     unbalanced_load;
>>       int                     tx_rebalance_counter;
>>       int                     lp_counter;
>> -     /* -------- non-dynamic tlb mode only ---------*/
>> -     struct tlb_up_slave __rcu *slave_arr;     /* Up slaves */
>>       /* -------- rlb parameters -------- */
>>       int rlb_enabled;
>>       struct rlb_client_info  *rx_hashtbl;    /* Receive hash table */
>> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>> index f0f5eab0fab1..43f066539dab 100644
>> --- a/drivers/net/bonding/bond_main.c
>> +++ b/drivers/net/bonding/bond_main.c
>> @@ -1413,6 +1413,10 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
>>               dev_mc_add(slave_dev, lacpdu_multicast);
>>       }
>>
>> +     if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +         bond_update_slave_arr(bond, NULL))
>> +             pr_err("Failed to build slave-array for XOR mode.\n");
>> +
> ^^^^^^^^^^^^^^
> 2 issues here:
> 1.  a little bit after this you can find the following switch:
>         switch (BOND_MODE(bond)) {
>
> that is meant for specific mode handling, I don't think you need to add
> additional "if" here.
>
> 2. Why do you rebuild here, bond_master_upper_dev_link() hasn't been called
> yet so the new slave isn't visible yet.
>
You are right! It's useless here and I'll remove it.

>>       res = vlan_vids_add_by_dev(slave_dev, bond_dev);
>>       if (res) {
>>               netdev_err(bond_dev, "Couldn't add bond vlan ids to %s\n",
>> @@ -1692,6 +1696,11 @@ static int __bond_release_one(struct net_device *bond_dev,
>>       /* Inform AD package of unbinding of slave. */
>>       if (BOND_MODE(bond) == BOND_MODE_8023AD)
>>               bond_3ad_unbind_slave(slave);
>> +     else if (BOND_MODE(bond) == BOND_MODE_XOR ||
>> +              bond_is_nondyn_tlb(bond)) {
>> +             if (bond_update_slave_arr(bond, slave))
>> +                     pr_err("Failed to build slave-array.\n");
>> +     }
> Documentation/CodingStyle:
> both branches must use braces.
>
Will do.
>>
>>       write_unlock_bh(&bond->lock);
>>
>> @@ -2009,6 +2018,10 @@ static void bond_miimon_commit(struct bonding *bond)
>>                               bond_alb_handle_link_change(bond, slave,
>>                                                           BOND_LINK_UP);
>>
>> +                     if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +                         bond_update_slave_arr(bond, NULL))
>> +                             pr_err("Failed to build slave-array for XOR mode.\n");
>> +
>>                       if (!bond->curr_active_slave ||
>>                           (slave == bond->primary_slave))
>>                               goto do_failover;
>> @@ -2037,6 +2050,10 @@ static void bond_miimon_commit(struct bonding *bond)
>>                               bond_alb_handle_link_change(bond, slave,
>>                                                           BOND_LINK_DOWN);
>>
>> +                     if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +                         bond_update_slave_arr(bond, NULL))
>> +                             pr_err("Failed to build slave-array for XOR mode.\n");
>> +
>>                       if (slave == rcu_access_pointer(bond->curr_active_slave))
>>                               goto do_failover;
>>
>> @@ -2500,6 +2517,9 @@ static void bond_loadbalance_arp_mon(struct work_struct *work)
>>
>>               if (slave_state_changed) {
>>                       bond_slave_state_change(bond);
>> +                     if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +                         bond_update_slave_arr(bond, NULL))
>> +                             pr_err("Failed to build slave-array for XOR mode.\n");
>>               } else if (do_failover) {
>>                       /* the bond_select_active_slave must hold RTNL
>>                        * and curr_slave_lock for write.
>> @@ -2893,11 +2913,14 @@ static int bond_slave_netdev_event(unsigned long event,
>>                       if (old_duplex != slave->duplex)
>>                               bond_3ad_adapter_duplex_changed(slave);
>>               }
>> +             if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +                 bond_update_slave_arr(bond, NULL))
>> +                     pr_err("Failed to build slave-array for XOR mode.\n");
>>               break;
>>       case NETDEV_DOWN:
>> -             /*
>> -              * ... Or is it this?
>> -              */
>> +             if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +                 bond_update_slave_arr(bond, NULL))
>> +                     pr_err("Failed to build slave-array for XOR mode.\n");
> ^^^^^^^^^^^^^^^^
> In the case of a netdev event (up/down) does this only affect XOR mode ?
> You could be right, just wanted to make sure we're not missing something :-)
>
There is no mode specific stuff for XOR mode and link events do not
trigger anything for this mode. So the array stays stale and thats
bad. The situation is different if the miimon or arpmon is used. But
if someone tries to use this mode without arp/mii-mon, then these
slave device event will have to be used to update the usable
slave-array. I think 3ad handles it correctly, but now thinking about
it, I need to check how TLB mode handles it.


>>               break;
>>       case NETDEV_CHANGEMTU:
>>               /*
>> @@ -3143,12 +3166,17 @@ static int bond_open(struct net_device *bond_dev)
>>               bond_3ad_initiate_agg_selection(bond, 1);
>>       }
>>
>> +     if (BOND_MODE(bond) == BOND_MODE_XOR &&
>> +         bond_update_slave_arr(bond, NULL))
>> +             pr_err("Failed to build slave-array for XOR mode.\n");
>> +
>>       return 0;
>>  }
>>
>>  static int bond_close(struct net_device *bond_dev)
>>  {
>>       struct bonding *bond = netdev_priv(bond_dev);
>> +     struct bond_up_slave *arr;
>>
>>       bond_work_cancel_all(bond);
>>       bond->send_peer_notif = 0;
>> @@ -3156,6 +3184,12 @@ static int bond_close(struct net_device *bond_dev)
>>               bond_alb_deinitialize(bond);
>>       bond->recv_probe = NULL;
>>
>> +     arr = rtnl_dereference(bond->slave_arr);
>> +     if (arr) {
>> +             kfree_rcu(arr, rcu);
>> +             RCU_INIT_POINTER(bond->slave_arr, NULL);
>> +     }
>> +
> ^^^^^^^^
> Why do this in the first place ? I mean I could easily release a slave
> while the bond is down and rebuild the slave_arr.
>
If you do bond down the slave array is free-ed here, but next time
when the bond up operation is performed, the slave array will be
rebuilt. In that code, the logic always dereferences the earlier array
and since it's non-NULL, this might end-up in double-free situation.
So to avoid that I'm assigning NULL after the free.

> One more issue that I just saw is that you might be leaking memory as
> ndo_uninit() is called for a device after dev_close_many() so you'll free
> the array here, but bond_uninit() calls __bond_release_slave and will
> rebuild it.
>
Shouldn't __bond_release_slave() be called before closing the bond()?
I'll have to check the code, but if you are right, then this is not
the correct place for this free operation and probably the better
place would be the bond_ununit() in that case.

>>       return 0;
>>  }
>>
>> @@ -3684,15 +3718,108 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
>>       return NETDEV_TX_OK;
>>  }
>>
>> -/* In bond_xmit_xor() , we determine the output device by using a pre-
>> - * determined xmit_hash_policy(), If the selected device is not enabled,
>> - * find the next active slave.
>> +/* Build the usable slaves array in control path for modes that use xmit-hash
>> + * to determine the slave interface -
>> + * (a) BOND_MODE_8023AD
>> + * (b) BOND_MODE_XOR
>> + * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
>>   */
>> -static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>>  {
>> -     struct bonding *bond = netdev_priv(bond_dev);
>> +     struct slave *slave;
>> +     struct list_head *iter;
>> +     struct bond_up_slave *new_arr, *old_arr;
>> +     int slaves_in_agg;
>> +     int agg_id = 0;
>> +     int ret = 0;
>> +
>> +     new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
>> +                       GFP_ATOMIC);
>> +     if (!new_arr) {
>> +             ret = -ENOMEM;
>> +             goto out;
>> +     }
>> +     if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>> +             struct ad_info ad_info;
>>
>> -     bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) % bond->slave_cnt);
>> +             if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
>> +                     pr_debug("bond_3ad_get_active_agg_info failed\n");
>> +                     kfree_rcu(new_arr, rcu);
>> +                     ret = -EINVAL;
>> +                     goto out;
>> +             }
>> +             slaves_in_agg = ad_info.ports;
>> +             agg_id = ad_info.aggregator_id;
>> +     }
>> +     bond_for_each_slave(bond, slave, iter) {
>> +             if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>> +                     struct aggregator *agg;
>> +
>> +                     agg = SLAVE_AD_INFO(slave)->port.aggregator;
>> +                     if (!agg || agg->aggregator_identifier != agg_id)
>> +                             continue;
>> +             }
>> +             if (!bond_slave_can_tx(slave))
>> +                     continue;
>> +             if (skipslave == slave)
>> +                     continue;
>> +             new_arr->arr[new_arr->count++] = slave;
>> +     }
>> +
>> +     old_arr = rcu_dereference_protected(bond->slave_arr,
>> +                                         lockdep_rtnl_is_held() ||
>> +                                         lockdep_is_held(&bond->lock) ||
>> +                                         lockdep_is_held(&bond->curr_slave_lock));
>> +     rcu_assign_pointer(bond->slave_arr, new_arr);
>> +     if (old_arr)
>> +             kfree_rcu(old_arr, rcu);
>> +
>> +out:
>> +     if (ret != 0 && skipslave) {
>> +             int idx;
>> +
>> +             /* Rare situation where caller has asked to skip a specific
>> +              * slave but allocation failed (most likely!). In this sitation
>> +              * overwrite the skipslave entry in the array with the last
>> +              * entry from the array to avoid a situation where the xmit
>> +              * path may choose this to-be-skipped slave to send a packet
>> +              * out.
>> +              */
>> +             rcu_read_lock();
> ^^^^^^^^^^^^^^
> RCU ?
>
Shouldn't the array manipulation (the overwrite operation) be
performed with rcu-lock? May be I'm wrong!

>> +             old_arr = rcu_dereference_protected(bond->slave_arr,
>> +                                         lockdep_is_held(&bond->lock));
>                                                 ^^^^^^^^
> Only bond->lock ? This doesn't make any sense.
>
The only possibility here is from the __bond_release_one() because of
the skipslave and that path uses bond->lock.

>> +             for (idx = 0; idx < old_arr->count; idx++) {
>> +                     if (skipslave == old_arr->arr[idx]) {
>> +                             if (idx != old_arr->count - 1)
> You can drop the "if" and remove one level of indentation, if idx == count
> - 1, then it'll overwrite itself (i.e. nothing) but count will still go down.
> But I think there's a potential bigger problem here as in the case of
> failure count might drop down to 0 but some transmitter might be pass the
> check and at the modulus part and if count is re-fetched we might end up
> with a div by zero.
>
__bond_release_one() uses write_lock_bh(). Isn't that sufficient to
prevent a potential xmitter from getting into that mode?


>> +                                     old_arr->arr[idx] =
>> +                                         old_arr->arr[old_arr->count-1];
>> +                             old_arr->count--;
>> +                             break;
>> +                     }
>> +             }
>> +             rcu_read_unlock();
>> +     }
>> +     return ret;
>> +}
>> +
>> +/* Use this Xmit function for 3AD as well as XOR modes. The current
>> + * usable slave array is formed in the control path. The xmit function
>> + * just calculates hash and sends the packet out.
>> + */
>> +int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
>> +{
>> +     struct bonding *bond = netdev_priv(dev);
>> +     struct slave *slave;
>> +     struct bond_up_slave *slaves;
>> +
>> +     slaves = rcu_dereference(bond->slave_arr);
>> +     if (slaves && slaves->count) {
>> +             slave = slaves->arr[bond_xmit_hash(bond, skb) % slaves->count];
>> +             bond_dev_queue_xmit(bond, skb, slave->dev);
>> +     } else {
>> +             dev_kfree_skb_any(skb);
>> +             atomic_long_inc(&dev->tx_dropped);
>> +     }
>>
>>       return NETDEV_TX_OK;
>>  }
>> @@ -3794,12 +3921,11 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
>>               return bond_xmit_roundrobin(skb, dev);
>>       case BOND_MODE_ACTIVEBACKUP:
>>               return bond_xmit_activebackup(skb, dev);
>> +     case BOND_MODE_8023AD:
>>       case BOND_MODE_XOR:
>> -             return bond_xmit_xor(skb, dev);
>> +             return bond_3ad_xor_xmit(skb, dev);
>>       case BOND_MODE_BROADCAST:
>>               return bond_xmit_broadcast(skb, dev);
>> -     case BOND_MODE_8023AD:
>> -             return bond_3ad_xmit_xor(skb, dev);
>>       case BOND_MODE_ALB:
>>               return bond_alb_xmit(skb, dev);
>>       case BOND_MODE_TLB:
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index aace510d08d1..4a6195c0de60 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -177,6 +177,12 @@ struct slave {
>>       struct kobject kobj;
>>  };
>>
>> +struct bond_up_slave {
>> +     unsigned int    count;
>> +     struct rcu_head rcu;
>> +     struct slave    *arr[0];
>> +};
>> +
>>  /*
>>   * Link pseudo-state only used internally by monitors
>>   */
>> @@ -196,6 +202,7 @@ struct bonding {
>>       struct   slave __rcu *curr_active_slave;
>>       struct   slave __rcu *current_arp_slave;
>>       struct   slave *primary_slave;
>> +     struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
>>       bool     force_primary;
>>       s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
>>       int     (*recv_probe)(const struct sk_buff *, struct bonding *,
>> @@ -527,6 +534,7 @@ const char *bond_slave_link_status(s8 link);
>>  struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>>                                             struct net_device *end_dev,
>>                                             int level);
>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
>>
>>  #ifdef CONFIG_PROC_FS
>>  void bond_create_proc_entry(struct bonding *bond);
>>
>

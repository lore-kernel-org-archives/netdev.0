From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v1 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Sun, 07 Sep 2014 12:36:15 +0200
Message-ID: <540C351F.9070800@redhat.com>
References: <1409985356-2384-1-git-send-email-maheshb@google.com> <540AE9CC.10206@redhat.com> <CAF2d9jhXEMZF-W+wYns4NCiJ1W2LjDoNEmO2X-3791DmbYaDkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44000 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751151AbaIGKg3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Sep 2014 06:36:29 -0400
In-Reply-To: <CAF2d9jhXEMZF-W+wYns4NCiJ1W2LjDoNEmO2X-3791DmbYaDkg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/07/2014 07:33 AM, Mahesh Bandewar wrote:
> On Sat, Sep 6, 2014 at 4:02 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>> On 09/06/2014 08:35 AM, Mahesh Bandewar wrote:
>>> Earlier change to use usable slave array for TLB mode had an additional
>>> performance advantage. So extending the same logic to all other modes
>>> that use xmit-hash for slave selection (viz 802.3AD, and XOR modes).
>>> Also consolidating this with the earlier TLB change.
>>>
>>> The main idea is to build the usable slaves array in the control path
>>> and use that array for slave selection during xmit operation.
>>>
>>> Measured performance in a setup with a bond of 4x1G NICs with 200
>>> instances of netperf for the modes involved (3ad, xor, tlb)
>>> cmd: netperf -t TCP_RR -H <TargetHost> -l 60 -s 5
>>>
>>> Mode        TPS-Before   TPS-After
>>>
>>> 802.3ad   : 468,694      493,101
>>> TLB (lb=0): 392,583      392,965
>>> XOR       : 475,696      484,517
>>>
>>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>>> ---
>>> v1:
>>>   (a) If bond_update_slave_arr() fails to allocate memory, it will overwrite
>>>       the slave that need to be removed.
>>>   (b) Freeing of array will assign NULL (to handle bond->down to bond->up
>>>       transition gracefully.
>>>   (c) Change from pr_debug() to pr_err() if bond_update_slave_arr() returns
>>>       failure.
>>>   (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases and
>>>       will populate the array even if these parameters are not used.
>>>   (e) 3AD: Should handle the ad_agg_selection_logic correctly.
>>>
<<<<<snip>>>>>
>>>  static int bond_close(struct net_device *bond_dev)
>>>  {
>>>       struct bonding *bond = netdev_priv(bond_dev);
>>> +     struct bond_up_slave *arr;
>>>
>>>       bond_work_cancel_all(bond);
>>>       bond->send_peer_notif = 0;
>>> @@ -3156,6 +3184,12 @@ static int bond_close(struct net_device *bond_dev)
>>>               bond_alb_deinitialize(bond);
>>>       bond->recv_probe = NULL;
>>>
>>> +     arr = rtnl_dereference(bond->slave_arr);
>>> +     if (arr) {
>>> +             kfree_rcu(arr, rcu);
>>> +             RCU_INIT_POINTER(bond->slave_arr, NULL);
>>> +     }
>>> +
>> ^^^^^^^^
>> Why do this in the first place ? I mean I could easily release a slave
>> while the bond is down and rebuild the slave_arr.
>>
> If you do bond down the slave array is free-ed here, but next time
> when the bond up operation is performed, the slave array will be
> rebuilt. In that code, the logic always dereferences the earlier array
> and since it's non-NULL, this might end-up in double-free situation.
> So to avoid that I'm assigning NULL after the free.
> 
>> One more issue that I just saw is that you might be leaking memory as
>> ndo_uninit() is called for a device after dev_close_many() so you'll free
>> the array here, but bond_uninit() calls __bond_release_slave and will
>> rebuild it.
>>
> Shouldn't __bond_release_slave() be called before closing the bond()?
> I'll have to check the code, but if you are right, then this is not
> the correct place for this free operation and probably the better
> place would be the bond_ununit() in that case.
>
>>>       return 0;
>>>  }
>>>
>>> @@ -3684,15 +3718,108 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
>>>       return NETDEV_TX_OK;
>>>  }
>>>
>>> -/* In bond_xmit_xor() , we determine the output device by using a pre-
>>> - * determined xmit_hash_policy(), If the selected device is not enabled,
>>> - * find the next active slave.
>>> +/* Build the usable slaves array in control path for modes that use xmit-hash
>>> + * to determine the slave interface -
>>> + * (a) BOND_MODE_8023AD
>>> + * (b) BOND_MODE_XOR
>>> + * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
>>>   */
>>> -static int bond_xmit_xor(struct sk_buff *skb, struct net_device *bond_dev)
>>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>>>  {
>>> -     struct bonding *bond = netdev_priv(bond_dev);
>>> +     struct slave *slave;
>>> +     struct list_head *iter;
>>> +     struct bond_up_slave *new_arr, *old_arr;
>>> +     int slaves_in_agg;
>>> +     int agg_id = 0;
>>> +     int ret = 0;
>>> +
>>> +     new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
>>> +                       GFP_ATOMIC);
>>> +     if (!new_arr) {
>>> +             ret = -ENOMEM;
>>> +             goto out;
>>> +     }
>>> +     if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>>> +             struct ad_info ad_info;
>>>
>>> -     bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) % bond->slave_cnt);
>>> +             if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
>>> +                     pr_debug("bond_3ad_get_active_agg_info failed\n");
>>> +                     kfree_rcu(new_arr, rcu);
>>> +                     ret = -EINVAL;
>>> +                     goto out;
>>> +             }
>>> +             slaves_in_agg = ad_info.ports;
>>> +             agg_id = ad_info.aggregator_id;
>>> +     }
>>> +     bond_for_each_slave(bond, slave, iter) {
>>> +             if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>>> +                     struct aggregator *agg;
>>> +
>>> +                     agg = SLAVE_AD_INFO(slave)->port.aggregator;
>>> +                     if (!agg || agg->aggregator_identifier != agg_id)
>>> +                             continue;
>>> +             }
>>> +             if (!bond_slave_can_tx(slave))
>>> +                     continue;
>>> +             if (skipslave == slave)
>>> +                     continue;
>>> +             new_arr->arr[new_arr->count++] = slave;
>>> +     }
>>> +
>>> +     old_arr = rcu_dereference_protected(bond->slave_arr,
>>> +                                         lockdep_rtnl_is_held() ||
>>> +                                         lockdep_is_held(&bond->lock) ||
>>> +                                         lockdep_is_held(&bond->curr_slave_lock));
>>> +     rcu_assign_pointer(bond->slave_arr, new_arr);
>>> +     if (old_arr)
>>> +             kfree_rcu(old_arr, rcu);
>>> +
>>> +out:
>>> +     if (ret != 0 && skipslave) {
>>> +             int idx;
>>> +
>>> +             /* Rare situation where caller has asked to skip a specific
>>> +              * slave but allocation failed (most likely!). In this sitation
>>> +              * overwrite the skipslave entry in the array with the last
>>> +              * entry from the array to avoid a situation where the xmit
>>> +              * path may choose this to-be-skipped slave to send a packet
>>> +              * out.
>>> +              */
>>> +             rcu_read_lock();
>> ^^^^^^^^^^^^^^
>> RCU ?
>>
> Shouldn't the array manipulation (the overwrite operation) be
> performed with rcu-lock? May be I'm wrong!
> 
I don't see any additional protection you'd get with RCU here, and for a
writer it's definitely useless.

>>> +             old_arr = rcu_dereference_protected(bond->slave_arr,
>>> +                                         lockdep_is_held(&bond->lock));
>>                                                 ^^^^^^^^
>> Only bond->lock ? This doesn't make any sense.
>>
> The only possibility here is from the __bond_release_one() because of
> the skipslave and that path uses bond->lock.
> 
Ah, okay now it makes sense, but then you should probably add a comment
about that peculiarity and also lockdep_rtnl_is_held().

>>> +             for (idx = 0; idx < old_arr->count; idx++) {
>>> +                     if (skipslave == old_arr->arr[idx]) {
>>> +                             if (idx != old_arr->count - 1)
>> You can drop the "if" and remove one level of indentation, if idx == count
>> - 1, then it'll overwrite itself (i.e. nothing) but count will still go down.
>> But I think there's a potential bigger problem here as in the case of
>> failure count might drop down to 0 but some transmitter might be pass the
>> check and at the modulus part and if count is re-fetched we might end up
>> with a div by zero.
>>
> __bond_release_one() uses write_lock_bh(). Isn't that sufficient to
> prevent a potential xmitter from getting into that mode?
> 
No, the xmit code was converted to RCU some time ago and runs in parallel
with these operations. I've actually hit this bug with bond->slave_cnt
before. You should probably edit the xmit code that uses ->count and make
sure to fetch it only once.

> 
>>> +                                     old_arr->arr[idx] =
>>> +                                         old_arr->arr[old_arr->count-1];
>>> +                             old_arr->count--;
>>> +                             break;
>>> +                     }
>>> +             }
>>> +             rcu_read_unlock();
>>> +     }
>>> +     return ret;
>>> +}
>>> +
>>> +/* Use this Xmit function for 3AD as well as XOR modes. The current
>>> + * usable slave array is formed in the control path. The xmit function
>>> + * just calculates hash and sends the packet out.
>>> + */
>>> +int bond_3ad_xor_xmit(struct sk_buff *skb, struct net_device *dev)
>>> +{
>>> +     struct bonding *bond = netdev_priv(dev);
>>> +     struct slave *slave;
>>> +     struct bond_up_slave *slaves;
>>> +
>>> +     slaves = rcu_dereference(bond->slave_arr);
>>> +     if (slaves && slaves->count) {
>>> +             slave = slaves->arr[bond_xmit_hash(bond, skb) % slaves->count];
>>> +             bond_dev_queue_xmit(bond, skb, slave->dev);
>>> +     } else {
>>> +             dev_kfree_skb_any(skb);
>>> +             atomic_long_inc(&dev->tx_dropped);
>>> +     }
>>>
>>>       return NETDEV_TX_OK;
>>>  }
>>> @@ -3794,12 +3921,11 @@ static netdev_tx_t __bond_start_xmit(struct sk_buff *skb, struct net_device *dev
>>>               return bond_xmit_roundrobin(skb, dev);
>>>       case BOND_MODE_ACTIVEBACKUP:
>>>               return bond_xmit_activebackup(skb, dev);
>>> +     case BOND_MODE_8023AD:
>>>       case BOND_MODE_XOR:
>>> -             return bond_xmit_xor(skb, dev);
>>> +             return bond_3ad_xor_xmit(skb, dev);
>>>       case BOND_MODE_BROADCAST:
>>>               return bond_xmit_broadcast(skb, dev);
>>> -     case BOND_MODE_8023AD:
>>> -             return bond_3ad_xmit_xor(skb, dev);
>>>       case BOND_MODE_ALB:
>>>               return bond_alb_xmit(skb, dev);
>>>       case BOND_MODE_TLB:
>>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>>> index aace510d08d1..4a6195c0de60 100644
>>> --- a/drivers/net/bonding/bonding.h
>>> +++ b/drivers/net/bonding/bonding.h
>>> @@ -177,6 +177,12 @@ struct slave {
>>>       struct kobject kobj;
>>>  };
>>>
>>> +struct bond_up_slave {
>>> +     unsigned int    count;
>>> +     struct rcu_head rcu;
>>> +     struct slave    *arr[0];
>>> +};
>>> +
>>>  /*
>>>   * Link pseudo-state only used internally by monitors
>>>   */
>>> @@ -196,6 +202,7 @@ struct bonding {
>>>       struct   slave __rcu *curr_active_slave;
>>>       struct   slave __rcu *current_arp_slave;
>>>       struct   slave *primary_slave;
>>> +     struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
>>>       bool     force_primary;
>>>       s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
>>>       int     (*recv_probe)(const struct sk_buff *, struct bonding *,
>>> @@ -527,6 +534,7 @@ const char *bond_slave_link_status(s8 link);
>>>  struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>>>                                             struct net_device *end_dev,
>>>                                             int level);
>>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
>>>
>>>  #ifdef CONFIG_PROC_FS
>>>  void bond_create_proc_entry(struct bonding *bond);
>>>
>>

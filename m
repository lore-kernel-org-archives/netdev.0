From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH v7 net-next 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Sun, 5 Oct 2014 05:52:10 +0530
Message-ID: <CAF2d9jia=NLdwcUGa_=wnh1gO1w1ZW4JP-kt1-TOKNeLZ4AJ4g@mail.gmail.com>
References: <1412383720-1540-1-git-send-email-maheshb@google.com> <542FA3C1.9080405@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Cong Wang <cwang@twopensource.com>
To: Nikolay Aleksandrov <nikolay@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f171.google.com ([209.85.220.171]:48648 "EHLO
	mail-vc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEAWb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:22:31 -0400
Received: by mail-vc0-f171.google.com with SMTP id hy10so1985242vcb.30
        for <netdev@vger.kernel.org>; Sat, 04 Oct 2014 17:22:30 -0700 (PDT)
In-Reply-To: <542FA3C1.9080405@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Oct 4, 2014 at 1:07 PM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> On 10/04/2014 02:48 AM, Mahesh Bandewar wrote:
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
>> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
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
>> v2:
>>   (a) Removed rcu_read_{un}lock() calls from array manipulation code.
>>   (b) Slave link-events now refresh array for all these modes.
>>   (c) Moved free-array call from bond_close() to bond_uninit().
>> v3:
>>   (a) Fixed null pointer dereference.
>>   (b) Removed bond->lock lockdep dependency.
>> v4:
>>   (a) Made to changes to comply with Nikolay's locking changes
>>   (b) Added a work-queue to refresh slave-array when RTNL is not held
>>   (c) Array refresh happens ONLY with RTNL now.
>>   (d) alloc changed from GFP_ATOMIC to GFP_KERNEL
>> v5:
>>   (a) Consolidated all delayed slave-array updates at one place in
>>       3ad_state_machine_handler()
>> v6:
>>   (a) Free slave array when there is no active aggregator
>> v7:
>>   (a) Couple of trivial changes.
>>
>>  drivers/net/bonding/bond_3ad.c  | 140 +++++++++++------------------
>>  drivers/net/bonding/bond_alb.c  |  51 ++---------
>>  drivers/net/bonding/bond_alb.h  |   8 --
>>  drivers/net/bonding/bond_main.c | 192 +++++++++++++++++++++++++++++++++++++---
>>  drivers/net/bonding/bonding.h   |  10 +++
>>  5 files changed, 249 insertions(+), 152 deletions(-)
>>
> <<<snip>>>
>> +/* Build the usable slaves array in control path for modes that use xmit-hash
>> + * to determine the slave interface -
>> + * (a) BOND_MODE_8023AD
>> + * (b) BOND_MODE_XOR
>> + * (c) BOND_MODE_TLB && tlb_dynamic_lb == 0
>> + *
>> + * The caller is expected to hold RTNL only and NO other lock!
>> + */
>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave)
>> +{
>> +     struct slave *slave;
>> +     struct list_head *iter;
>> +     struct bond_up_slave *new_arr, *old_arr;
>> +     int slaves_in_agg;
>> +     int agg_id = 0;
>> +     int ret = 0;
>> +
>> +#ifdef CONFIG_LOCKDEP
>> +     lockdep_assert_held(&bond->mode_lock);
>> +#endif
> ^^^^^^^^^
> This is wrong now, the logic is inverted.
> It will WARN every time mode_lock is _not_ held:
>
> #define lockdep_assert_held(l)  do {                            \
>                 WARN_ON(debug_locks && !lockdep_is_held(l));    \
>         } while (0)
>
> The previous version was correct which did a WARN when mode_lock was
> actually held as that is the wrong condition, not when it's not held.
> I've missed that comment earlier.
>
Thanks Nik, I missed that. I'll revert it!

> (also switched Veaceslav's email address with the correct one in the CC list)
>
>> +
>> +     new_arr = kzalloc(offsetof(struct bond_up_slave, arr[bond->slave_cnt]),
>> +                       GFP_KERNEL);
>> +     if (!new_arr) {
>> +             ret = -ENOMEM;
>> +             pr_err("Failed to build slave-array.\n");
>> +             goto out;
>> +     }
>> +     if (BOND_MODE(bond) == BOND_MODE_8023AD) {
>> +             struct ad_info ad_info;
>> +
>> +             if (bond_3ad_get_active_agg_info(bond, &ad_info)) {
>> +                     pr_debug("bond_3ad_get_active_agg_info failed\n");
>> +                     kfree_rcu(new_arr, rcu);
>> +                     /* No active aggragator means it's not safe to use
>> +                      * the previous array.
>> +                      */
>> +                     old_arr = rtnl_dereference(bond->slave_arr);
>> +                     if (old_arr) {
>> +                             RCU_INIT_POINTER(bond->slave_arr, NULL);
>> +                             kfree_rcu(old_arr, rcu);
>> +                     }
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
>> +     old_arr = rtnl_dereference(bond->slave_arr);
>> +     rcu_assign_pointer(bond->slave_arr, new_arr);
>> +     if (old_arr)
>> +             kfree_rcu(old_arr, rcu);
>> +out:
>> +     if (ret != 0 && skipslave) {
>> +             int idx;
>> +
>> +             /* Rare situation where caller has asked to skip a specific
>> +              * slave but allocation failed (most likely!). BTW this is
>> +              * only possible when the call is initiated from
>> +              * __bond_release_one(). In this situation; overwrite the
>> +              * skipslave entry in the array with the last entry from the
>> +              * array to avoid a situation where the xmit path may choose
>> +              * this to-be-skipped slave to send a packet out.
>> +              */
>> +             old_arr = rtnl_dereference(bond->slave_arr);
>> +             for (idx = 0; idx < old_arr->count; idx++) {
>> +                     if (skipslave == old_arr->arr[idx]) {
>> +                             old_arr->arr[idx] =
>> +                                 old_arr->arr[old_arr->count-1];
>> +                             old_arr->count--;
>> +                             break;
>> +                     }
>> +             }
>> +     }
>> +     return ret;
>> +}
>> +
> <<<snip>>>
>

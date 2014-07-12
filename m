From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCHv2] bonding: Do not try to send packets over dead link
 in TLB mode.
Date: Sat, 12 Jul 2014 10:44:17 +0200
Message-ID: <53C0F561.2090600@redhat.com>
References: <1405113030-28877-1-git-send-email-maheshb@google.com> <CAF2d9jiH0dQka-vwDFKFmpjea5rY+ijhCOjovJ_kP6AA-jT_Lg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751546AbaGLIo1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jul 2014 04:44:27 -0400
In-Reply-To: <CAF2d9jiH0dQka-vwDFKFmpjea5rY+ijhCOjovJ_kP6AA-jT_Lg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/2014 11:15 PM, Mahesh Bandewar wrote:
> In my tests with added instrumentation (similar to __might_sleep()) in
> the update_arr function; the calls were never in the automic context
> so did not change the GFP flag to GFP_ATOMIC.
> 
> On Fri, Jul 11, 2014 at 2:10 PM, Mahesh Bandewar <maheshb@google.com> wrote:
>> In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
>> group are selected based on the hash distribution. This does not
>> exclude dead links which are part of the bond. Also if there is a
>> temporary link event which brings down the interface, packets
>> hashed on that interface would be dropped too.
>>
>> This patch fixes these issues and distributes flows across the
>> UP links only. Also the array construction of links which are
>> capable of sending packets happen in the control path leaving
>> only link-selection during the data-path.
>>
>> One possible side effect of this is - at a link event; all
>> flows will be shuffled to get good distribution. But impact of
>> this should be minimum with the assumption that a member or
>> members of the bond group are not available is a very temporary
>> situation.
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
>> ---
>>  drivers/net/bonding/bond_alb.c | 44 +++++++++++++++++++++++++++++++++++++-----
>>  drivers/net/bonding/bond_alb.h |  8 ++++++++
>>  drivers/net/bonding/bonding.h  |  6 ++++++
>>  3 files changed, 53 insertions(+), 5 deletions(-)
>>
>> [v1]
>>   * Initial patch
>> [v2]
>>   * Removed spinlock protection
>>   * Removed explicit rcu_read_(un)lock() calls since Xmit fn run in RCU
>>   * Updated condition during bond-dismantle to check for only arrays' existance.
>>
>> diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
>> index 76c0dade233f..7fb2066432b1 100644
>> --- a/drivers/net/bonding/bond_alb.c
>> +++ b/drivers/net/bonding/bond_alb.c
>> @@ -209,6 +209,9 @@ static void tlb_deinitialize(struct bonding *bond)
>>         bond_info->tx_hashtbl = NULL;
>>
>>         _unlock_tx_hashtbl_bh(bond);
>> +
>> +       if (bond_info->slave_arr)
>> +               kfree_rcu(bond_info->slave_arr, rcu);
>>  }
>>
>>  static long long compute_gap(struct slave *slave)
>> @@ -1406,9 +1409,35 @@ out:
>>         return NETDEV_TX_OK;
>>  }
>>
>> +static int bond_tlb_update_slave_arr(struct bonding *bond)
>> +{
>> +       struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> +       struct slave *tx_slave;
>> +       struct list_head *iter;
>> +       struct tlb_up_slave *new_arr, *old_arr;
>> +
>> +       new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
>> +                         GFP_KERNEL);
>> +       if (!new_arr)
>> +               return -ENOMEM;
>> +
>> +       bond_for_each_slave(bond, tx_slave, iter) {
>> +               if (bond_slave_can_tx(tx_slave))
>> +                       new_arr->arr[new_arr->count++] = tx_slave;
>> +       }
>> +
>> +       old_arr = bond_info->slave_arr;
>> +       rcu_assign_pointer(bond_info->slave_arr, new_arr);
>> +       if (old_arr)
>> +               kfree_rcu(old_arr, rcu);
>> +
>> +       return 0;
>> +}
>> +
>>  int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>  {
>>         struct bonding *bond = netdev_priv(bond_dev);
>> +       struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>>         struct ethhdr *eth_data;
>>         struct slave *tx_slave = NULL;
>>         u32 hash_index;
>> @@ -1429,12 +1458,12 @@ int bond_tlb_xmit(struct sk_buff *skb, struct net_device *bond_dev)
>>                                                               hash_index & 0xFF,
>>                                                               skb->len);
>>                         } else {
>> -                               struct list_head *iter;
>> -                               int idx = hash_index % bond->slave_cnt;
>> +                               struct tlb_up_slave *slaves;
>>
>> -                               bond_for_each_slave_rcu(bond, tx_slave, iter)
>> -                                       if (--idx < 0)
>> -                                               break;
>> +                               slaves = rcu_dereference(bond_info->slave_arr);
>> +                               if (slaves && slaves->count)
>> +                                       tx_slave = slaves->arr[hash_index %
>> +                                                              slaves->count];
>>                         }
>>                         break;
>>                 }
>> @@ -1721,6 +1750,11 @@ void bond_alb_handle_link_change(struct bonding *bond, struct slave *slave, char
>>                          */
>>                 }
>>         }
>> +
>> +       if (bond_is_nondyn_tlb(bond)) {
>> +               if (bond_tlb_update_slave_arr(bond))
>> +                       pr_err("Failed to build slave-array for TLB mode.\n");
>> +       }
>>  }
>>
>>  /**
>> diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
>> index 5fc76c01636c..aaeac61d03cf 100644
>> --- a/drivers/net/bonding/bond_alb.h
>> +++ b/drivers/net/bonding/bond_alb.h
>> @@ -139,12 +139,20 @@ struct tlb_slave_info {
>>                          */
>>  };
>>
>> +struct tlb_up_slave {
>> +       unsigned int    count;
>> +       struct rcu_head rcu;
>> +       struct slave    *arr[0];
>> +};
>> +
>>  struct alb_bond_info {
>>         struct tlb_client_info  *tx_hashtbl; /* Dynamically allocated */
>>         spinlock_t              tx_hashtbl_lock;
>>         u32                     unbalanced_load;
>>         int                     tx_rebalance_counter;
>>         int                     lp_counter;
>> +       /* -------- non-dynamic tlb mode only ---------*/
>> +       struct tlb_up_slave __rcu *slave_arr;     /* Up slaves */
>>         /* -------- rlb parameters -------- */
>>         int rlb_enabled;
>>         struct rlb_client_info  *rx_hashtbl;    /* Receive hash table */
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 0b4d9cde0b05..ad9b3dce07d8 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -265,6 +265,12 @@ static inline bool bond_is_lb(const struct bonding *bond)
>>                BOND_MODE(bond) == BOND_MODE_ALB;
>>  }
>>
>> +static inline bool bond_is_nondyn_tlb(const struct bonding *bond)
>> +{
>> +       return (BOND_MODE(bond) == BOND_MODE_TLB)  &&
>> +              (bond->params.tlb_dynamic_lb == 0);
>> +}
>> +
>>  static inline bool bond_mode_uses_arp(int mode)
>>  {
>>         return mode != BOND_MODE_8023AD && mode != BOND_MODE_TLB &&
>> --
>> 2.0.0.526.g5318336
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

Did you have CONFIG_DEBUG_ATOMIC_SLEEP in your kernel config ?

[  556.669144] BUG: sleeping function called from invalid context at
mm/slub.c:965
[  556.670262] in_atomic(): 1, irqs_disabled(): 0, pid: 3316, name: bash
[  556.670939] CPU: 1 PID: 3316 Comm: bash Tainted: G           OE
3.16.0-rc2+ #3
[  556.670941] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  556.670943]  0000000000000000 ffff88005b60fc70 ffffffff816af012
ffff8800490cb900
[  556.670957]  ffff88005b60fc80 ffffffff8109c30a ffff88005b60fcc0
ffffffff811b2283
[  556.670961]  ffffffffa01f45ae ffff8800490cb900 0000000000000000
ffff880049d9ac00
[  556.670965] Call Trace:
[  556.670975]  [<ffffffff816af012>] dump_stack+0x4d/0x66
[  556.670981]  [<ffffffff8109c30a>] __might_sleep+0xca/0x100
[  556.670987]  [<ffffffff811b2283>] __kmalloc+0x63/0x270
[  556.670996]  [<ffffffffa01f45ae>] ?
bond_alb_handle_link_change+0x7e/0x180 [bonding]
[  556.671010]  [<ffffffffa01f45ae>] bond_alb_handle_link_change+0x7e/0x180
[bonding]
[  556.671068]  [<ffffffffa01eac62>] bond_change_active_slave+0x3b2/0x620
[bonding]
[  556.671076]  [<ffffffffa01eaf94>] bond_select_active_slave+0xc4/0x1a0
[bonding]
[  556.671082]  [<ffffffffa01ec00d>] bond_enslave+0xf9d/0xfc0 [bonding]
[  556.671089]  [<ffffffffa01f70df>] bond_option_slaves_set+0xff/0x130
[bonding]
[  556.671095]  [<ffffffffa01f83ff>] __bond_opt_set+0xdf/0x330 [bonding]
[  556.671100]  [<ffffffffa01f8697>] bond_opt_tryset_rtnl+0x47/0x80 [bonding]
[  556.671106]  [<ffffffffa01f52e5>] bonding_sysfs_store_option+0x35/0x60
[bonding]
[  556.671113]  [<ffffffff8141e6f8>] dev_attr_store+0x18/0x30
[  556.671118]  [<ffffffff812435ad>] sysfs_kf_write+0x3d/0x50
[  556.671121]  [<ffffffff812430a4>] kernfs_fop_write+0xe4/0x160
[  556.671126]  [<ffffffff811cc367>] vfs_write+0xb7/0x1f0
[  556.671129]  [<ffffffff811ccf19>] SyS_write+0x49/0xb0
[  556.671134]  [<ffffffff81106f36>] ? __audit_syscall_exit+0x1f6/0x2a0
[  556.671139]  [<ffffffff816b69d2>] system_call_fastpath+0x16/0x1b

Cheers,
 Nik

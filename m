From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Fri, 05 Sep 2014 13:26:11 +0200
Message-ID: <54099DD3.20109@redhat.com>
References: <1409780851-32081-1-git-send-email-maheshb@google.com> <54086645.3010102@redhat.com> <CAF2d9ji2Dsi9dr6B0HKy4oQ841CN-00zWcOxCa+oTyPp79hOHA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
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
Received: from mx1.redhat.com ([209.132.183.28]:43033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756478AbaIEL0W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2014 07:26:22 -0400
In-Reply-To: <CAF2d9ji2Dsi9dr6B0HKy4oQ841CN-00zWcOxCa+oTyPp79hOHA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/09/14 02:10, Mahesh Bandewar wrote:
> On Thu, Sep 4, 2014 at 6:16 AM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
>> On 03/09/14 23:47, Mahesh Bandewar wrote:
>>>
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
>>
<<<<<snip>>>>>>
>>> -       bond_xmit_slave_id(bond, skb, bond_xmit_hash(bond, skb) %
>>> bond->slave_cnt);
>>> +       old_arr = rcu_dereference_protected(bond->slave_arr,
>>> +                                           lockdep_rtnl_is_held() ||
>>> +                                           lockdep_is_held(&bond->lock)
>>> ||
>>> +
>>> lockdep_is_held(&bond->curr_slave_lock));
>>
>> ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
>> This line is the most troublesome for me, which lock is it ? Does this mean
>> that whichever I hold from the three I can update the slave array ?
>> I don't think this is worked out well, you should explicitly specify how and
>> why it is safe to update this under each of the locks and maybe you'll be
>> able to reduce the lock list :-)
>>
> This is primarily because of different code paths it's taking to reach
> here. In all these cases, one of those locks is held. Unfortunately
> there are three such locks  that I have identified (for all three
> modes involved) and hence the above line.
>

True, but I did a little grepping and here's my analysis of the call sites which 
I can't guarantee is full or complete, but it shows at least 1 problem.
bond_update_slave_arr() callers:

1. 3ad mode
1.1. bond_3ad_state_machine_handler -> ad_mux_machine -> 
ad_(en|dis)able_collecting_distributing
  - read_lock(bond->lock), rcu_read_lock, state_machine_lock
1.2. __bond_release_one -> bond_3ad_unbind_slave
  - rtnl, write_lock(bond->lock)
1.3. bond_change_active_slave -> bond_3ad_handle_link_change
  -  from 4. rtnl, new_active != NULL -> write_lock(curr_slave_lock)
1.4. bond_miimon_commit -> bond_3ad_handle_link_change
  - rtnl

2. TLB
2.1. __bond_release_one -> bond_alb_deinit_slave
  - rtnl
2.2. bond_change_active_slave -> bond_alb_handle_link_change
  - from 4. rtnl, new_active != NULL -> write_lock(curr_slave_lock)
2.3. bond_miimon_commit -> bond_alb_handle_link_change
  - rtnl

3. XOR
3.1. __bond_release_one
  - rtnl
3.2. bond_miimon_commit
  - rtnl

4. bond_change_active_slave:
1. bond_select_active_slave -> bond_change_active_slave
1.1. bond_enslave -> bond_select_active_slave
  - rtnl, write_lock(curr_slave_lock)
1.2. __bond_release_one -> bond_select_active_slave
  - rtnl, write_lock(curr_slave_lock)
1.3. bond_miimon_commit -> bond_select_active_slave
  - rtnl, write_lock(curr_slave_lock)
1.4. bond_loadbalance_arp_mon -> bond_select_active_slave
  - rtnl, write_lock(curr_slave_lock)
1.5. bond_ab_arp_commit -> bond_select_active_slave
  - rtnl, write_lock(curr_slave_lock)
1.6. bond_slave_netdev_event -> bond_select_active_slave
  - rtnl, write_lock(curr_slave_lock)
1.7. bond_options.c (all callers)
  - rtnl, write_lock(curr_slave_lock)


Almost all callers of slave_update_arr() currently have rtnl acquired, but 
there's 1 troubling caller: bond_3ad_state_machine_handler() which is called 
from a workqueue. Now if we're able to execute anything with that workqueue, we 
have a race condition, good candidates are all options which don't acquire 
write_lock(bond->lock), I think the only one that can call 
bond_slave_update_arr() of those is primary_reselect right now.
So if you come up with some way to deal with that, you probably can use only 
rtnl for syncing the array and simplify this.
Again I might be wrong since this is done only via grepping :-)

Cheers,
  Nik

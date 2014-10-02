From: Mahesh Bandewar <maheshb@google.com>
Subject: Re: [PATCH net-next v6 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Thu, 2 Oct 2014 08:22:19 +0530
Message-ID: <CAF2d9ji1i5C2YmPhdpZxauEqdb3DbPDBWQcv+F8jqedxJq-k2g@mail.gmail.com>
References: <1412152711-12646-1-git-send-email-maheshb@google.com> <542BD293.5090404@redhat.com>
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
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34076 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750868AbaJBCwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Oct 2014 22:52:41 -0400
Received: by mail-yk0-f177.google.com with SMTP id q200so843550ykb.36
        for <netdev@vger.kernel.org>; Wed, 01 Oct 2014 19:52:41 -0700 (PDT)
In-Reply-To: <542BD293.5090404@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 1, 2014 at 3:38 PM, Nikolay Aleksandrov <nikolay@redhat.com> wrote:
> On 01/10/14 10:38, Mahesh Bandewar wrote:
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
>> v1:
>>    (a) If bond_update_slave_arr() fails to allocate memory, it will
>> overwrite
>>        the slave that need to be removed.
>>    (b) Freeing of array will assign NULL (to handle bond->down to bond->up
>>        transition gracefully.
>>    (c) Change from pr_debug() to pr_err() if bond_update_slave_arr()
>> returns
>>        failure.
>>    (d) XOR: bond_update_slave_arr() will consider mii-mon, arp-mon cases
>> and
>>        will populate the array even if these parameters are not used.
>>    (e) 3AD: Should handle the ad_agg_selection_logic correctly.
>> v2:
>>    (a) Removed rcu_read_{un}lock() calls from array manipulation code.
>>    (b) Slave link-events now refresh array for all these modes.
>>    (c) Moved free-array call from bond_close() to bond_uninit().
>> v3:
>>    (a) Fixed null pointer dereference.
>>    (b) Removed bond->lock lockdep dependency.
>> v4:
>>    (a) Made to changes to comply with Nikolay's locking changes
>>    (b) Added a work-queue to refresh slave-array when RTNL is not held
>>    (c) Array refresh happens ONLY with RTNL now.
>>    (d) alloc changed from GFP_ATOMIC to GFP_KERNEL
>> v5:
>>    (a) Consolidated all delayed slave-array updates at one place in
>>        3ad_state_machine_handler()
>> v6:
>>    (a) Free slave array when there is no active aggregator
>>
>>   drivers/net/bonding/bond_3ad.c  | 140 +++++++++++------------------
>>   drivers/net/bonding/bond_alb.c  |  51 ++---------
>>   drivers/net/bonding/bond_alb.h  |   8 --
>>   drivers/net/bonding/bond_main.c | 192
>> +++++++++++++++++++++++++++++++++++++---
>>   drivers/net/bonding/bonding.h   |  10 +++
>>   5 files changed, 249 insertions(+), 152 deletions(-)
>>
> <<<snip>>>
>>
>> @@ -3869,6 +4029,12 @@ static void bond_uninit(struct net_device
>> *bond_dev)
>>                 __bond_release_one(bond_dev, slave->dev, true);
>>         netdev_info(bond_dev, "Released all slaves\n");
>>
>> +       arr = rtnl_dereference(bond->slave_arr);
>> +       if (arr) {
>> +               kfree_rcu(arr, rcu);
>> +               RCU_INIT_POINTER(bond->slave_arr, NULL);
>> +       }
>> +
>>         list_del(&bond->bond_list);
>>
>>         bond_debug_unregister(bond);
>
> <<<snip>>>
> I'm fine with this version, just one last question about something I just
> noticed in the hunk above:
> You first call kfree_rcu() and then RCU_INIT_POINTER(). This feels wrong as
> the currently used slave_arr can get freed before it's set to NULL if we get
> preempted after the kfree_rcu(). Now, I know it's not really a problem
> because at this point the bond device has been closed and shouldn't operate,
> but just in case I think it'd be nice to first NULL it and call kfree_rcu()
> after that.
>
I don't see that as a problem but that's a trivial change and I'll
reverse the order.

> Thanks for all your hard work on this.
>
> Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
>

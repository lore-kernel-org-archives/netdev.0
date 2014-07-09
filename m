From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH] bonding: Do not try to send packets over dead link in
 TLB mode.
Date: Wed, 09 Jul 2014 12:25:43 +0200
Message-ID: <53BD18A7.6090109@redhat.com>
References: <1404868198-24839-1-git-send-email-maheshb@google.com> <20140709102441.GB1227@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Veaceslav Falico <vfalico@redhat.com>,
	Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54900 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754479AbaGIKbO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jul 2014 06:31:14 -0400
In-Reply-To: <20140709102441.GB1227@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/09/2014 12:24 PM, Veaceslav Falico wrote:
> On Tue, Jul 08, 2014 at 06:09:58PM -0700, Mahesh Bandewar wrote:
>> In TLB mode if tlb_dynamic_lb is NOT set, slaves from the bond
>> group are selected based on the hash distribution. This does not
>> exclude dead links which are part of the bond. Also if there is a
>> temporary link event which brings down the interface, packets
>> hashed on that interface would be dropped too.
>>
>> This patch fixes these issues and distributes flows across the
>> UP links only. Also the array construction of links which are
>> capable of sending packets happen in the control path leaving
>> only link-selection duing the data-path.
>>
>> One possible side effect of this is - at a link event; all
>> flows will be shuffled to get good distribution. But impact of
>> this should be minimum with the assumption that a member or
>> members of the bond group are not available is a very temporary
>> situation.
> 
> Good one, it indeed will speed up things/fix it.
> 
> Some comments:
> 
> I didn't see how you handle the case when a slave is removed (i.e.
> released) from bonding.
> 
>>
>> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ...snip...
>> +static int bond_tlb_update_slave_arr(struct bonding *bond)
>> +{
>> +    struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>> +    struct slave *tx_slave;
>> +    struct list_head *iter;
>> +    struct tlb_up_slave *new_arr, *old_arr;
>> +
>> +    new_arr = kzalloc(offsetof(struct tlb_up_slave, arr[bond->slave_cnt]),
>> +              GFP_KERNEL);
>> +    if (!new_arr)
>> +        return -ENOMEM;
>> +
>> +    bond_for_each_slave(bond, tx_slave, iter) {
>> +        if (bond_slave_can_tx(tx_slave))
>> +            new_arr->arr[new_arr->count++] = tx_slave;
>> +    }
>> +
>> +    spin_lock(&bond_info->slave_arr_lock);
> 
> I don't think you can re-enter bond_alb_handle_link_change(), as it's
> protected either by rtnl or write-lock curr_active_slave.
> 
Actually a very good catch :-)
Maybe the allocation above should be done with GFP_ATOMIC.

>> +    old_arr = bond_info->slave_arr;
>> +    rcu_assign_pointer(bond_info->slave_arr, new_arr);
>> +    spin_unlock(&bond_info->slave_arr_lock);
>> +    if (old_arr)
>> +        kfree_rcu(old_arr, rcu);
>> +
>> +    return 0;
>> +}
> ...snip...
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

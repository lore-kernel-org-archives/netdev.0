From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v4 2/2] bonding: Simplify the xmit function for
 modes that use xmit_hash
Date: Fri, 19 Sep 2014 13:06:18 +0200
Message-ID: <541C0E2A.3050309@redhat.com>
References: <1411077211-20117-1-git-send-email-maheshb@google.com> <541BFEA4.9080702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
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
Received: from mx1.redhat.com ([209.132.183.28]:50489 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752300AbaISLGk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 07:06:40 -0400
In-Reply-To: <541BFEA4.9080702@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2014 12:00 PM, Nikolay Aleksandrov wrote:
> On 09/18/2014 11:53 PM, Mahesh Bandewar wrote:
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
>>
<<<snip>>>
>> @@ -3839,6 +4003,7 @@ static void bond_uninit(struct net_device *bond_dev)
>>  	struct bonding *bond = netdev_priv(bond_dev);
>>  	struct list_head *iter;
>>  	struct slave *slave;
>> +	struct bond_up_slave *arr;
>>  
>>  	bond_netpoll_cleanup(bond_dev);
>>  
>> @@ -3847,6 +4012,12 @@ static void bond_uninit(struct net_device *bond_dev)
>>  		__bond_release_one(bond_dev, slave->dev, true);
>>  	netdev_info(bond_dev, "Released all slaves\n");
>>  
Sorry but I just spotted a major problem, bond_3ad_unbind_slave() (called
from __bond_release_one) calls ad_agg_selection_logic() which can re-arm
the slave_arr work after it's supposed to be stopped here (i.e. the bond
device has been closed so all works should've been stopped) so we might
leak memory and access freed memory after all since it'll keep
re-scheduling itself until it can acquire rtnl which is after the bond
device has been destroyed.

>> +	arr = rtnl_dereference(bond->slave_arr);
>> +	if (arr) {
>> +		kfree_rcu(arr, rcu);
>> +		RCU_INIT_POINTER(bond->slave_arr, NULL);
>> +	}
>> +
>>  	list_del(&bond->bond_list);
>>  
>>  	bond_debug_unregister(bond);
>> diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
>> index 98dc0d7ad731..4635b175256a 100644
>> --- a/drivers/net/bonding/bonding.h
>> +++ b/drivers/net/bonding/bonding.h
>> @@ -177,6 +177,12 @@ struct slave {
>>  	struct kobject kobj;
>>  };
>>  
>> +struct bond_up_slave {
>> +	unsigned int	count;
>> +	struct rcu_head rcu;
>> +	struct slave	*arr[0];
>> +};
>> +
>>  /*
>>   * Link pseudo-state only used internally by monitors
>>   */
>> @@ -191,6 +197,7 @@ struct bonding {
>>  	struct   slave __rcu *curr_active_slave;
>>  	struct   slave __rcu *current_arp_slave;
>>  	struct   slave __rcu *primary_slave;
>> +	struct   bond_up_slave __rcu *slave_arr; /* Array of usable slaves */
>>  	bool     force_primary;
>>  	s32      slave_cnt; /* never change this value outside the attach/detach wrappers */
>>  	int     (*recv_probe)(const struct sk_buff *, struct bonding *,
>> @@ -220,6 +227,7 @@ struct bonding {
>>  	struct   delayed_work alb_work;
>>  	struct   delayed_work ad_work;
>>  	struct   delayed_work mcast_work;
>> +	struct   delayed_work slave_arr_work;
>>  #ifdef CONFIG_DEBUG_FS
>>  	/* debugging support via debugfs */
>>  	struct	 dentry *debug_dir;
>> @@ -531,6 +539,8 @@ const char *bond_slave_link_status(s8 link);
>>  struct bond_vlan_tag *bond_verify_device_path(struct net_device *start_dev,
>>  					      struct net_device *end_dev,
>>  					      int level);
>> +int bond_update_slave_arr(struct bonding *bond, struct slave *skipslave);
>> +void bond_slave_arr_work_rearm(struct bonding *bond);
>>  
>>  #ifdef CONFIG_PROC_FS
>>  void bond_create_proc_entry(struct bonding *bond);
>>
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

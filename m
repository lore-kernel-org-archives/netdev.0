From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/16] net: introduce upper device lists
Date: Tue, 14 Aug 2012 14:24:33 +0200
Message-ID: <20120814122433.GB1661@minipsycho.brq.redhat.com>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
 <1344871635-1052-2-git-send-email-jiri@resnulli.us>
 <20120813145217.38748c4f@obelix.rh>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	faisal.latif@intel.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	linux390@de.ibm.com, shemminger@vyatta.com,
	bhutchings@solarflare.com, therbert@google.com,
	xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org
To: Flavio Leitner <fbl@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20120813145217.38748c4f@obelix.rh>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Aug 13, 2012 at 07:52:17PM CEST, fbl@redhat.com wrote:
>On Mon, 13 Aug 2012 17:27:00 +0200
>Jiri Pirko <jiri@resnulli.us> wrote:
>
>> This lists are supposed to serve for storing pointers to all upper devices.
>> Eventually it will replace dev->master pointer which is used for
>> bonding, bridge, team but it cannot be used for vlan, macvlan where
>> there might be multiple "masters" present.
>> 
>> New upper device list resolves this limitation. Also, the information
>> stored in lists is used for preventing looping setups like
>> "bond->somethingelse->samebond"
>> 
>> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
>> ---
>>  include/linux/netdevice.h |   14 +++
>>  net/core/dev.c            |  232 ++++++++++++++++++++++++++++++++++++++++++++-
>>  2 files changed, 244 insertions(+), 2 deletions(-)
>> 
>> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
>> index a9db4f3..e7a07f8 100644
>> --- a/include/linux/netdevice.h
>> +++ b/include/linux/netdevice.h
>> @@ -1173,6 +1173,8 @@ struct net_device {
>>  					  * which this device is member of.
>>  					  */
>>  
>> +	struct list_head	upper_dev_list; /* List of upper devices */
>> +
>>  	/* Interface address info used in eth_type_trans() */
>>  	unsigned char		*dev_addr;	/* hw address, (before bcast
>>  						   because most packets are
>> @@ -2611,6 +2613,18 @@ extern int		netdev_max_backlog;
>>  extern int		netdev_tstamp_prequeue;
>>  extern int		weight_p;
>>  extern int		bpf_jit_enable;
>> +
>> +extern bool netdev_has_upper_dev(struct net_device *dev,
>> +				 struct net_device *upper_dev);
>> +extern bool netdev_has_any_upper_dev(struct net_device *dev);
>> +extern struct net_device *netdev_unique_upper_dev_get(struct net_device *dev);
>> +extern struct net_device *netdev_unique_upper_dev_get_rcu(struct net_device *dev);
>> +extern int netdev_upper_dev_link(struct net_device *dev,
>> +				 struct net_device *upper_dev);
>> +extern int netdev_unique_upper_dev_link(struct net_device *dev,
>> +					struct net_device *upper_dev);
>> +extern void netdev_upper_dev_unlink(struct net_device *dev,
>> +				    struct net_device *upper_dev);
>>  extern int		netdev_set_master(struct net_device *dev, struct net_device *master);
>>  extern int netdev_set_bond_master(struct net_device *dev,
>>  				  struct net_device *master);
>> diff --git a/net/core/dev.c b/net/core/dev.c
>> index 1f06df8..68db1ac 100644
>> --- a/net/core/dev.c
>> +++ b/net/core/dev.c
>> @@ -4425,6 +4425,229 @@ static int __init dev_proc_init(void)
>>  #endif	/* CONFIG_PROC_FS */
>>  
>>  
>> +struct netdev_upper {
>> +	struct net_device *dev;
>> +	bool unique;
>
>unique is quite confusing here. I see that it is possible to have 
>one unique and many non-unique linked in the list, so maybe rename
>to 'main_dev', 'master' or 'principal'...
>
>
>> +	struct list_head list;
>> +	struct rcu_head rcu;
>> +};
>> +
>> +static bool __netdev_has_upper_dev(struct net_device *dev,
>> +				   struct net_device *upper_dev,
>> +				   bool deep)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	list_for_each_entry(upper, &dev->upper_dev_list, list) {
>> +		if (upper->dev == upper_dev)
>> +			return true;
>> +		if (deep && __netdev_has_upper_dev(upper->dev, upper_dev, deep))
>> +			return true;
>> +	}
>> +	return false;
>> +}
>> +
>> +static struct netdev_upper *__netdev_find_upper(struct net_device *dev,
>> +						struct net_device *upper_dev)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	list_for_each_entry(upper, &dev->upper_dev_list, list) {
>> +		if (upper->dev == upper_dev)
>> +			return upper;
>> +	}
>> +	return NULL;
>> +}
>> +
>> +/**
>> + * netdev_has_upper_dev - Check if device is linked to an upper device
>> + * @dev: device
>> + * @upper_dev: upper device to check
>> + *
>> + * Find out if a device is linked to specified upper device and return true
>> + * in case it is. The caller must hold the RTNL semaphore.
>> + */
>> +bool netdev_has_upper_dev(struct net_device *dev,
>> +			  struct net_device *upper_dev)
>> +{
>> +	ASSERT_RTNL();
>> +
>> +	return __netdev_has_upper_dev(dev, upper_dev, false);
>> +}
>> +EXPORT_SYMBOL(netdev_has_upper_dev);
>> +
>> +/**
>> + * netdev_has_any_upper_dev - Check if device is linked to some device
>> + * @dev: device
>> + *
>> + * Find out if a device is linked to an upper device and return true in case
>> + * it is. The caller must hold the RTNL semaphore.
>> + */
>> +bool netdev_has_any_upper_dev(struct net_device *dev)
>> +{
>> +	ASSERT_RTNL();
>> +
>> +	return !list_empty(&dev->upper_dev_list);
>> +}
>> +EXPORT_SYMBOL(netdev_has_any_upper_dev);
>> +
>> +/**
>> + * netdev_unique_upper_dev_get - Get unique upper device
>> + * @dev: device
>> + *
>> + * Find a unique upper device and return pointer to it or NULL in case
>> + * it's not there. The caller must hold the RTNL semaphore.
>> + */
>> +struct net_device *netdev_unique_upper_dev_get(struct net_device *dev)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	if (list_empty(&dev->upper_dev_list))
>> +		return NULL;
>> +
>> +	upper = list_first_entry(&dev->upper_dev_list,
>> +				 struct netdev_upper, list);
>> +	if (likely(upper->unique))
>> +		return upper->dev;
>> +	return NULL;
>> +}
>> +EXPORT_SYMBOL(netdev_unique_upper_dev_get);
>> +
>> +/**
>> + * netdev_unique_upper_dev_get_rcu - Get unique upper device
>> + * @dev: device
>> + *
>> + * Find a unique upper device and return pointer to it or NULL in case
>> + * it's not there. The caller must hold the RCU read lock.
>> + */
>> +struct net_device *netdev_unique_upper_dev_get_rcu(struct net_device *dev)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	upper = list_first_or_null_rcu(&dev->upper_dev_list,
>> +				       struct netdev_upper, list);
>> +	if (likely(upper->unique))
>
>It will oopses here if 'upper' is NULL (i.e. no upper devices).


Fixed

>
>
>> +		return upper->dev;
>> +	return NULL;
>> +}
>> +EXPORT_SYMBOL(netdev_unique_upper_dev_get_rcu);
>> +
>> +static int __netdev_upper_dev_link(struct net_device *dev,
>> +				   struct net_device *upper_dev, bool unique)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	if (dev == upper_dev)
>> +		return -EBUSY;
>> +	/*
>> +	 * To prevent loops, check if dev is not upper device to upper_dev.
>> +	 */
>> +	if (__netdev_has_upper_dev(upper_dev, dev, true))
>> +		return -EBUSY;
>> +
>> +	if (__netdev_find_upper(dev, upper_dev))
>> +		return -EEXIST;
>
>__netdev_has_upper_dev() can go all the way up finding the device and
>the __netdev_find_upper() just check the first level.


I do not think this ordering is somewhat inportant.

>
>I think it would be better to use:
>__netdev_find_upper_dev(,,deep=true/false)
>__netdev_has_upper(,)
>
>thanks,
>fbl
>
>> +	if (unique && netdev_unique_upper_dev_get(dev))
>> +		return -EBUSY;
>> +
>> +	upper = kmalloc(sizeof(*upper), GFP_KERNEL);
>> +	if (!upper)
>> +		return -ENOMEM;
>> +
>> +	upper->dev = upper_dev;
>> +	upper->unique = unique;
>> +
>> +	/*
>> +	 * Ensure that unique upper link is always the first item in the list.
>> +	 */
>> +	if (unique)
>> +		list_add_rcu(&upper->list, &dev->upper_dev_list);
>> +	else
>> +		list_add_tail_rcu(&upper->list, &dev->upper_dev_list);
>> +	dev_hold(upper_dev);
>> +
>> +	return 0;
>> +}
>> +/**
>> + * netdev_upper_dev_link - Add a link to the upper device
>> + * @dev: device
>> + * @upper_dev: new upper device
>> + *
>> + * Adds a link to device which is upper to this one. The caller must hold
>> + * the RTNL semaphore. On a failure a negative errno code is returned.
>> + * On success the reference counts are adjusted and the function
>> + * returns zero.
>> + */
>> +int netdev_upper_dev_link(struct net_device *dev,
>> +			  struct net_device *upper_dev)
>> +{
>> +	return __netdev_upper_dev_link(dev, upper_dev, false);
>> +}
>> +EXPORT_SYMBOL(netdev_upper_dev_link);
>> +
>> +/**
>> + * netdev_unique_upper_dev_link - Add a unique link to the upper device
>> + * @dev: device
>> + * @upper_dev: new upper device
>> + *
>> + * Adds a link to device which is upper to this one. In this case, only
>> + * one unique upper device can be linked, although other non-unique devices
>> + * might be linked as well. The caller must hold the RTNL semaphore.
>> + * On a failure a negative errno code is returned. On success the reference
>> + * counts are adjusted and the function returns zero.
>> + */
>> +int netdev_unique_upper_dev_link(struct net_device *dev,
>> +				 struct net_device *upper_dev)
>> +{
>> +	return __netdev_upper_dev_link(dev, upper_dev, true);
>> +}
>> +EXPORT_SYMBOL(netdev_unique_upper_dev_link);
>> +
>> +/**
>> + * netdev_upper_free_rcu - Frees a upper device list item via the RCU pointer
>> + * @entry: the entry's RCU field
>> + *
>> + * This function is designed to be used as a callback to the call_rcu()
>> + * function so that the memory allocated to the netdev upper device list item
>> + * can be released safely.
>> + */
>> +static void netdev_upper_free_rcu(struct rcu_head *entry)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	upper = container_of(entry, struct netdev_upper, rcu);
>> +	kfree(upper);
>> +}
>> +
>> +/**
>> + * netdev_upper_dev_unlink - Removes a link to upper device
>> + * @dev: device
>> + * @upper_dev: new upper device
>> + *
>> + * Removes a link to device which is upper to this one. The caller must hold
>> + * the RTNL semaphore.
>> + */
>> +void netdev_upper_dev_unlink(struct net_device *dev,
>> +			     struct net_device *upper_dev)
>> +{
>> +	struct netdev_upper *upper;
>> +
>> +	ASSERT_RTNL();
>> +
>> +	upper = __netdev_find_upper(dev, upper_dev);
>> +	if (!upper)
>> +		return;
>> +	list_del_rcu(&upper->list);
>> +	dev_put(upper_dev);
>> +	call_rcu(&upper->rcu, netdev_upper_free_rcu);
>> +}
>> +EXPORT_SYMBOL(netdev_upper_dev_unlink);
>> +
>>  /**
>>   *	netdev_set_master	-	set up master pointer
>>   *	@slave: slave device
>> @@ -4438,19 +4661,23 @@ static int __init dev_proc_init(void)
>>  int netdev_set_master(struct net_device *slave, struct net_device *master)
>>  {
>>  	struct net_device *old = slave->master;
>> +	int err;
>>  
>>  	ASSERT_RTNL();
>>  
>>  	if (master) {
>>  		if (old)
>>  			return -EBUSY;
>> -		dev_hold(master);
>> +		err = netdev_unique_upper_dev_link(slave, master);
>> +		if (err)
>> +			return err;
>>  	}
>>  
>>  	slave->master = master;
>>  
>>  	if (old)
>> -		dev_put(old);
>> +		netdev_upper_dev_unlink(slave, master);
>> +
>>  	return 0;
>>  }
>>  EXPORT_SYMBOL(netdev_set_master);
>> @@ -5999,6 +6226,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_priv, const char *name,
>>  	INIT_LIST_HEAD(&dev->napi_list);
>>  	INIT_LIST_HEAD(&dev->unreg_list);
>>  	INIT_LIST_HEAD(&dev->link_watch_list);
>> +	INIT_LIST_HEAD(&dev->upper_dev_list);
>>  	dev->priv_flags = IFF_XMIT_DST_RELEASE;
>>  	setup(dev);
>>  
>

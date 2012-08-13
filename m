From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next 01/16] net: introduce upper device lists
Date: Mon, 13 Aug 2012 19:31:10 +0200
Message-ID: <20120813173110.GA1808@minipsycho.orion>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
 <1344871635-1052-2-git-send-email-jiri@resnulli.us>
 <1344877451.2733.26.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	faisal.latif@intel.com, roland@kernel.org, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, fubar@us.ibm.com, andy@greyhouse.net,
	divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	linux390@de.ibm.com, shemminger@vyatta.com, therbert@google.com,
	xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1344877451.2733.26.camel@bwh-desktop.uk.solarflarecom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Mon, Aug 13, 2012 at 07:04:11PM CEST, bhutchings@solarflare.com wrote:
>On Mon, 2012-08-13 at 17:27 +0200, Jiri Pirko wrote:
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
>[...]
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
>This needs a better name.  It doesn't really have anything to do with
>uniqueness and doesn't ensure exclusivity.  I think that it would be
>fine to keep the 'master' term.

Hmm. I admit that "unique" I do not like too much as well. But "master"
I like even less.

This flag should ensure exclusivity. Only one upper device with this
flag can be present at a time.

>
>> +	struct list_head list;
>> +	struct rcu_head rcu;
>> +};
>[...]
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
>> +
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
>
>This behaviour (calling dev_hold()) matches netdev_set_master().  But
>it's oddly asymmetric: generally the administrator can remove either the
>upper device or the lower device (rtnl_link_ops or unbinding a physical
>device) and the upper device driver must then unlink itself from the
>lower device (using a notifier to catch lower device removal).
>
>If the upper device driver fails to unlink when the upper device is
>unregistered, then this extra reference causes netdev_wait_allrefs() to
>hang... is that the intent?  Or should there be a more explicit counter
>and check on unregistration, e.g. WARN_ON(dev->num_lower_devs != 0)?
>

I'm not sure I understand you. I believe that upper device notifier
should take care of the unlink. This behaviour is unchanged by the
patch.



>If it fails to unlink when the lower device is removed, this warning in
>rollback_registered_many() may be triggered:
>
>		/* Notifier chain MUST detach us from master device. */
>		WARN_ON(dev->master);
>
>I think that needs to become WARN_ON(netdev_has_upper_dev(dev)).

Patch 15

>
>> +	return 0;
>> +}
>[...] 
>
>-- 
>Ben Hutchings, Staff Engineer, Solarflare
>Not speaking for my employer; that's the marketing department's job.
>They asked us to note that Solarflare product names are trademarked.
>

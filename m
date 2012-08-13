From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [patch net-next 01/16] net: introduce upper device lists
Date: Mon, 13 Aug 2012 18:04:11 +0100
Message-ID: <1344877451.2733.26.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344871635-1052-1-git-send-email-jiri@resnulli.us>
	 <1344871635-1052-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	<edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, <faisal.latif-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <fubar-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>,
	<andy-QlMahl40kYEqcZcGjlUOXw@public.gmane.org>, <divy-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>,
	<jitendra.kalsaria-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <sony.chacko-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
	<linux-driver-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>, <kaber-dcUjhNyLwpNeoWH0uzbU5w@public.gmane.org>,
	<ursula.braun-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, <blaschka-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>,
	<linux390-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org>, <shemminger-ZtmgI6mnKB3QT0dZR+AlfA@public.gmane.org>,
	<therbert-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>, <gregory.v.rose-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	<john.r.fastabend-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<bridge-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, <fbl-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1344871635-1052-2-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-13 at 17:27 +0200, Jiri Pirko wrote:
> This lists are supposed to serve for storing pointers to all upper devices.
> Eventually it will replace dev->master pointer which is used for
> bonding, bridge, team but it cannot be used for vlan, macvlan where
> there might be multiple "masters" present.
> 
> New upper device list resolves this limitation. Also, the information
> stored in lists is used for preventing looping setups like
> "bond->somethingelse->samebond"
> 
> Signed-off-by: Jiri Pirko <jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -4425,6 +4425,229 @@ static int __init dev_proc_init(void)
>  #endif	/* CONFIG_PROC_FS */
>  
> 
> +struct netdev_upper {
> +	struct net_device *dev;
> +	bool unique;

This needs a better name.  It doesn't really have anything to do with
uniqueness and doesn't ensure exclusivity.  I think that it would be
fine to keep the 'master' term.

> +	struct list_head list;
> +	struct rcu_head rcu;
> +};
[...]
> +static int __netdev_upper_dev_link(struct net_device *dev,
> +				   struct net_device *upper_dev, bool unique)
> +{
> +	struct netdev_upper *upper;
> +
> +	ASSERT_RTNL();
> +
> +	if (dev == upper_dev)
> +		return -EBUSY;
> +	/*
> +	 * To prevent loops, check if dev is not upper device to upper_dev.
> +	 */
> +	if (__netdev_has_upper_dev(upper_dev, dev, true))
> +		return -EBUSY;
> +
> +	if (__netdev_find_upper(dev, upper_dev))
> +		return -EEXIST;
> +
> +	if (unique && netdev_unique_upper_dev_get(dev))
> +		return -EBUSY;
> +
> +	upper = kmalloc(sizeof(*upper), GFP_KERNEL);
> +	if (!upper)
> +		return -ENOMEM;
> +
> +	upper->dev = upper_dev;
> +	upper->unique = unique;
> +
> +	/*
> +	 * Ensure that unique upper link is always the first item in the list.
> +	 */
> +	if (unique)
> +		list_add_rcu(&upper->list, &dev->upper_dev_list);
> +	else
> +		list_add_tail_rcu(&upper->list, &dev->upper_dev_list);
> +	dev_hold(upper_dev);

This behaviour (calling dev_hold()) matches netdev_set_master().  But
it's oddly asymmetric: generally the administrator can remove either the
upper device or the lower device (rtnl_link_ops or unbinding a physical
device) and the upper device driver must then unlink itself from the
lower device (using a notifier to catch lower device removal).

If the upper device driver fails to unlink when the upper device is
unregistered, then this extra reference causes netdev_wait_allrefs() to
hang... is that the intent?  Or should there be a more explicit counter
and check on unregistration, e.g. WARN_ON(dev->num_lower_devs != 0)?

If it fails to unlink when the lower device is removed, this warning in
rollback_registered_many() may be triggered:

		/* Notifier chain MUST detach us from master device. */
		WARN_ON(dev->master);

I think that needs to become WARN_ON(netdev_has_upper_dev(dev)).

> +	return 0;
> +}
[...] 

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

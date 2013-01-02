From: Ben Hutchings <bhutchings-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Subject: Re: [patch net-next V5 01/15] net: introduce upper device lists
Date: Wed, 2 Jan 2013 18:57:26 +0000
Message-ID: <1357153046.3652.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357129716-2450-1-git-send-email-jiri@resnulli.us>
	 <1357129716-2450-2-git-send-email-jiri@resnulli.us>
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
In-Reply-To: <1357129716-2450-2-git-send-email-jiri-rHqAuBHg3fBzbRFIqnYvSA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, 2013-01-02 at 13:28 +0100, Jiri Pirko wrote:
> This lists are supposed to serve for storing pointers to all upper devices.
> Eventually it will replace dev->master pointer which is used for
> bonding, bridge, team but it cannot be used for vlan, macvlan where
> there might be multiple upper present. In case the upper link is
> replacement for dev->master, it is marked with "master" flag.
> 
> New upper device list resolves this limitation. Also, the information
> stored in lists is used for preventing looping setups like
> "bond->somethingelse->samebond"

Thanks for continuing with this, Jiri.  I just see some
cosmetic/documentation issues:

[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
[...]
> +static bool __netdev_has_upper_dev(struct net_device *dev,
> +				   struct net_device *upper_dev)
> +{
> +	LIST_HEAD(search_list);
> +	struct netdev_upper *upper;
> +	struct netdev_upper *tmp;
> +	bool ret = false;
> +
> +	__append_search_uppers(&search_list, dev);
> +	list_for_each_entry(upper, &search_list, search_list) {
> +		if (upper->dev == upper_dev) {
> +			ret = true;
> +			break;
> +		}
> +		__append_search_uppers(&search_list, upper->dev);
> +	}
> +	list_for_each_entry_safe(upper, tmp, &search_list, search_list)
> +		INIT_LIST_HEAD(&upper->search_list);
> +	return ret;
> +}
> +
> +static struct netdev_upper *__netdev_find_upper(struct net_device *dev,
> +						struct net_device *upper_dev)
> +{
> +	struct netdev_upper *upper;
> +
> +	list_for_each_entry(upper, &dev->upper_dev_list, list) {
> +		if (upper->dev == upper_dev)
> +			return upper;
> +	}
> +	return NULL;
> +}
> +
> +/**
> + * netdev_has_upper_dev - Check if device is linked to an upper device

Please clarify that this (and other functions) only checks for an
immediate upper device and not through a complete stack of devices.

> + * @dev: device
> + * @upper_dev: upper device to check
> + *
> + * Find out if a device is linked to specified upper device and return true
> + * in case it is. The caller must hold the RTNL semaphore.

It is no longer a semaphore, even if some kernel-doc in this file calls
it that.  'RTNL lock' would be better as it matches the function naming:
rtnl_lock() etc.

> + */
> +bool netdev_has_upper_dev(struct net_device *dev,
> +			  struct net_device *upper_dev)

The '__' prefix normally implies doing less work than the un-prefixed
function but __netdev_has_upper_dev() checks all devices stacked above
dev whereas this only checks a single level.  Therefore I think one or
both should be renamed.

> +{
> +	ASSERT_RTNL();
> +
> +	return __netdev_find_upper(dev, upper_dev);
> +}
> +EXPORT_SYMBOL(netdev_has_upper_dev);
[...]
> +static int __netdev_upper_dev_link(struct net_device *dev,
> +				   struct net_device *upper_dev, bool master)
> +{
[...]
> +}
> +/**
> + * netdev_upper_dev_link - Add a link to the upper device
[...] 

There should be a blank line between the closing brace and the comment
for the next function.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html

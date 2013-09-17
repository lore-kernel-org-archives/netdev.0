From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 net-next 21/27] net: add a function to get the next
 private
Date: Tue, 17 Sep 2013 02:50:01 +0100
Message-ID: <1379382601.23881.36.camel@deadeye.wl.decadent.org.uk>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
	 <1379378812-18346-22-git-send-email-vfalico@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>
To: Veaceslav Falico <vfalico@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:32114 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751409Ab3IQBuG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Sep 2013 21:50:06 -0400
In-Reply-To: <1379378812-18346-22-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-17 at 02:46 +0200, Veaceslav Falico wrote:
> It searches for the provided private and returns the next one. If private
> is not found or next list element is list head - returns NULL.

This is going to take linear time, which is probably OK for a bond that
has only a very few devices.  But it would likely be a really bad idea
for, say, a bridge device that could have tens or hundreds of lower
devices.  So it's not a generically useful function.

I think the bonding driver can implement this:

[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -5055,6 +5055,33 @@ void *netdev_lower_dev_get_private(struct net_device *dev,
>  }
>  EXPORT_SYMBOL(netdev_lower_dev_get_private);
>  
> +/* netdev_lower_dev_get_next_private - return the ->private of the list
> + *				       element whos ->private == private.
> + * @dev - device to search
> + * @private - private pointer to search for.
> + *
> + * Returns the next ->private pointer, if ->next is not head and private is
> + * found.
> + */
> +extern void *netdev_lower_dev_get_next_private(struct net_device *dev,
> +					       void *private)
> +{
> +	struct netdev_adjacent *lower;
> +
> +	list_for_each_entry(lower, &dev->adj_list.lower, list) {
> +		if (lower->private == private) {
> +			lower = list_entry(lower->list.next,
> +					   struct netdev_adjacent, list);
> +			if (&lower->list == &dev->adj_list.lower)
> +				return NULL;
> +			return lower->private;
> +		}
> +	}
> +
> +	return NULL;
> +}
> +EXPORT_SYMBOL(netdev_lower_dev_get_next_private);

using only the functions already exported:

static void *__bond_next_slave(struct net_device *dev, void *private)
{
	struct list_head *iter;
	struct net_device *lower;
	bool found = false;

	netdev_for_each_lower_dev(dev, lower, iter) {
		if (found)
			return netdev_adjacent_get_private(iter);
		if (netdev_adjacent_get_private(iter) == private)
			found = true;
	}

	return NULL;
}

(not that I've tested it :-).

Ben.

> +
>  static void dev_change_rx_flags(struct net_device *dev, int flags)
>  {
>  	const struct net_device_ops *ops = dev->netdev_ops;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

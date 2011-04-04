From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 5/6] ethtool: Change ETHTOOL_PHYS_ID
 implementation to allow dropping RTNL
Date: Tue, 05 Apr 2011 00:26:31 +0100
Message-ID: <1301959591.2935.64.camel@localhost>
References: <1301859889.2935.23.camel@localhost>
	 <1301860429.2935.29.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:40294 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148Ab1DDX0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Apr 2011 19:26:35 -0400
In-Reply-To: <1301860429.2935.29.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This reimplementation lets us blink LEDs on multiple device at the same
time, but that's pretty pointless.  The nasty thing is we could try to
blink LEDs twice over on the same device, violating the rules that the
drivers depend on.  So I think I need to add:

On Sun, 2011-04-03 at 20:53 +0100, Ben Hutchings wrote:
[...]
> @@ -1618,14 +1620,54 @@ out:
>  static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
>  {
	static struct net_device *active_dev;

>  	struct ethtool_value id;
> +	int rc;
>  
> -	if (!dev->ethtool_ops->phys_id)
> +	if (!dev->ethtool_ops->set_phys_id && !dev->ethtool_ops->phys_id)
>  		return -EOPNOTSUPP;

	if (active_dev)
		return -EBUSY;

>  	if (copy_from_user(&id, useraddr, sizeof(id)))
>  		return -EFAULT;
>  
> -	return dev->ethtool_ops->phys_id(dev, id.data);
> +	if (!dev->ethtool_ops->set_phys_id)
> +		/* Do it the old way */
> +		return dev->ethtool_ops->phys_id(dev, id.data);
> +
> +	rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
> +	if (rc && rc != -EINVAL)
> +		return rc;
> +

	active_dev = dev;

> +	dev_hold(dev);
> +	rtnl_unlock();
> +
> +	if (rc == 0) {
> +		/* Driver will handle this itself */
> +		schedule_timeout_interruptible(
> +			id.data ? id.data : MAX_SCHEDULE_TIMEOUT);
> +	} else {
> +		/* Driver expects to be called periodically */
> +		do {
> +			rtnl_lock();
> +			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ON);
> +			rtnl_unlock();
> +			if (rc)
> +				break;
> +			schedule_timeout_interruptible(HZ / 2);
> +
> +			rtnl_lock();
> +			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_OFF);
> +			rtnl_unlock();
> +			if (rc)
> +				break;
> +			schedule_timeout_interruptible(HZ / 2);
> +		} while (!signal_pending(current) &&
> +			 (id.data == 0 || --id.data != 0));
> +	}
> +
> +	rtnl_lock();
> +	dev_put(dev);

	active_dev = NULL;

> +	(void)dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_INACTIVE);
> +	return rc;
>  }
>  
>  static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


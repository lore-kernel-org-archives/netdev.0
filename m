From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next-2.6 1/2] net: allow to change carrier via sysfs
Date: Tue, 30 Aug 2011 16:14:22 +0100
Message-ID: <1314717262.2752.11.camel@bwh-desktop>
References: <1314715608-978-1-git-send-email-jpirko@redhat.com>
	 <1314715608-978-2-git-send-email-jpirko@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:39256 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754800Ab1H3PO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 11:14:27 -0400
In-Reply-To: <1314715608-978-2-git-send-email-jpirko@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-08-30 at 16:46 +0200, Jiri Pirko wrote:
> Allow to write to "carrier" attribute. Devices may implement ndo_change_carrier
> callback to allow changing carrier from userspace.
[...]
> diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
> index 56e42ab..c8f2ca4 100644
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -126,6 +126,30 @@ static ssize_t show_broadcast(struct device *dev,
>  	return -EINVAL;
>  }
>  
> +static ssize_t store_carrier(struct device *dev, struct device_attribute *attr,
> +			     const char *buf, size_t len)
> +{
> +	struct net_device *netdev = to_net_dev(dev);
> +	ssize_t ret;
> +	int new_value;
> +
> +	if (!capable(CAP_NET_ADMIN))
> +		return -EPERM;
> +
> +	if (!netif_running(netdev))
> +		return -EINVAL;

Not sure that's the right error code.

> +	if (sscanf(buf, "%d", &new_value) != 1)
> +		return -EINVAL;

kstrtoint()

(Or maybe we should have kstrobool().)

> +	if (!rtnl_trylock())
> +		return restart_syscall();
[...]

This is consistent with other attributes, but it seems like a really bad
practice as it will generally result in the process busy-waiting on the
RTNL lock!  I think it would be better to add and use an
rtnl_lock_interruptible().

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

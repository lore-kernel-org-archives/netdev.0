From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v1 net-next] net: Add phys_port identifier to struct
 net_device and export it to sysfs
Date: Mon, 1 Jul 2013 21:12:22 +0100
Message-ID: <1372709542.2083.61.camel@bwh-desktop.uk.level5networks.com>
References: <20130628152652.GA4247@fedora-17-guest.blr.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <john.r.fastabend@intel.com>
To: <Narendra_K@Dell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:53598 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755621Ab3GAUM0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 16:12:26 -0400
In-Reply-To: <20130628152652.GA4247@fedora-17-guest.blr.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-06-28 at 20:57 +0530, Narendra_K@Dell.com wrote:
[...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -1062,6 +1062,14 @@ struct net_device_ops {
>  						      bool new_carrier);
>  };
>  
> +/* This structure holds a universally unique identifier to
> + * identify the physical port used by a netdevice
> + */
> +struct port_identifier {
> +	unsigned char port_id[MAX_ADDR_LEN];
> +	unsigned port_id_len;

Was this meant to be unsigned (int) or unsigned char?  The length is
typed as unsigned char in show_phys_port().

> +};
[...]
> --- a/net/core/net-sysfs.c
> +++ b/net/core/net-sysfs.c
> @@ -334,6 +334,27 @@ static ssize_t store_group(struct device *dev, struct device_attribute *attr,
>  	return netdev_store(dev, attr, buf, len, change_group);
>  }
>  
> +static ssize_t show_phys_port(struct device *dev,
> +			      struct device_attribute *attr, char *buf)
> +{
> +	struct net_device *net = to_net_dev(dev);
> +	ssize_t ret = -EINVAL;
> +	unsigned char len;
> +
> +	read_lock(&dev_base_lock);
> +	if (dev_isalive(net)) {
> +		len = net->phys_port.port_id_len;
> +		if (!len) {
> +			read_unlock(&dev_base_lock);
> +			return 0;
> +		}

I would write this as:
		if (!len)
			ret = 0;
		else
so that the same exit path is used in all three cases.

Ben.

> +		ret = sysfs_format_mac(buf, net->phys_port.port_id, len);
> +	}
> +	read_unlock(&dev_base_lock);
> +
> +	return ret;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

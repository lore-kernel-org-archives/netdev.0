From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC 1/7] netdev: add standardized irq naming function
Date: Tue, 21 Jun 2011 19:07:41 +0100
Message-ID: <1308679661.2743.42.camel@bwh-desktop>
References: <20110621170541.309890798@vyatta.com>
	 <20110621170658.395370414@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:7889 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751929Ab1FUSHo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 14:07:44 -0400
In-Reply-To: <20110621170658.395370414@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-06-21 at 10:05 -0700, Stephen Hemminger wrote:

> To force driver developers to use a standard convention for naming
> network device IRQ's, provide a standardized method for creating
> the name.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> 
> --- a/include/linux/netdevice.h	2011-06-21 08:58:32.207953328 -0700
> +++ b/include/linux/netdevice.h	2011-06-21 09:12:12.155952869 -0700
> @@ -2631,6 +2631,46 @@ static inline const char *netdev_name(co
>  	return dev->name;
>  }
>  
> +/* function bits for netdev_irqname */
> +#define NETIF_IRQ_TX	1
> +#define NETIF_IRQ_RX	2
> +#define NETIF_IRQ_TXRX	3
> +#define NETIF_IRQ_OTHER 0	/* none of the above */

There can be multiple 'other' IRQs in which case they will need their
own suffixes.

Also: 'netdev' and 'NETIF'?  We are terribly inconsistent about this but
we could at least make this single change self-consistent. :-)

> +/**
> + *	netdev_irqname - generate name for irq
> + *	@buf: space to store result
> + *	@buflen: sizeof buf
> + *	@dev: network device
> + *	@queue: assoctiated network queue

Queue index.

> + *	@function: function of irq
> + *
> + * Format a IRQ name according to standard convention to be passed
> + * to request_irq().
> + */
> +static inline const char *netdev_irqname(char *buf, size_t buflen,
> +					 const struct net_device *dev,
> +					 unsigned queue,
> +					 unsigned function)

Might be worth making this a little more generic as storage devices are
also going multiqueue in a similar way.

> +{
> +	switch (function) {
> +	case NETIF_IRQ_TX:
> +		snprintf(buf, buflen, "%s-tx-%u", dev->name, queue);
> +		break;
> +	case NETIF_IRQ_RX:
> +		snprintf(buf, buflen, "%s-rx-%u", dev->name, queue);
> +		break;
> +	case NETIF_IRQ_TXRX:
> +		snprintf(buf, buflen, "%s-%u", dev->name, queue);
> +		break;
> +	default:
> +		snprintf(buf, buflen, "%s", dev->name);
> +	}
> +
> +	return buf;
> +}

So perhaps something like:

/* kernel/irq/manage.c */

const char *irq_name(char *buf, size_t buflen, const char *base_name,
		     int index, const char *type)
{
	if (type) {
		if (index >= 0)
			snprintf(buf, buflen, "%s-%s-%d", base_name, type, index);
		else
			snprintf(buf, buflen, "%s-%s", base_name, type);
	} else {
		if (index >= 0)
			snprintf(buf, buflen, "%s-%d", base_name, index);
		else
			strlcpy(buf, base_name, buflen);
	}
	return buf;
}

/* include/linux/interrupt.h */

#define IRQ_NAME_NO_INDEX (-1)

/* include/linux/netdevice.h */

/* IRQ type name for netdev_irqname */
#define NETDEV_IRQ_TYPE_TX   "tx"
#define NETDEV_IRQ_TYPE_RX   "rx"
#define NETDEV_IRQ_TYPE_TXRX NULL

/**
 *     netdev_irqname - generate name for irq
 *     @buf: space to store result
 *     @buflen: sizeof buf
 *     @dev: network device
 *     @index: network queue index
 *     @type: type of IRQ
 *
 * Format a IRQ name according to standard convention to be passed
 * to request_irq().
 */
static inline const char *netdev_irqname(char *buf, size_t buflen,
                                        const struct net_device *dev,
                                        int index, const char *type)
{
	return irq_name(buf, buflen, dev->name, index, type);
}

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


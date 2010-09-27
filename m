From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v11 04/17]Add a function make external buffer owner to
 query capability.
Date: Mon, 27 Sep 2010 14:45:49 +0100
Message-ID: <1285595149.2263.8.camel@achroite.uk.solarflarecom.com>
References: <1285388855-27410-1-git-send-email-xiaohui.xin@intel.com>
	 <6df1b1c2d2ffe70da911984c7fe6fab16f23043b.1285385607.git.xiaohui.xin@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kvm@vger.kernel.org,
	linux-kernel@vger.kernel.org, mingo@elte.hu, davem@davemloft.net,
	herbert@gondor.hengli.com.au, jdike@linux.intel.com
To: xiaohui.xin@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <6df1b1c2d2ffe70da911984c7fe6fab16f23043b.1285385607.git.xiaohui.xin@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2010-09-25 at 12:27 +0800, xiaohui.xin@intel.com wrote:
[...]
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 264137f..636f11b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -2468,6 +2468,55 @@ void netif_nit_deliver(struct sk_buff *skb)
>  	rcu_read_unlock();
>  }
>  
> +/* To support meidate passthru(zero-copy) with NIC driver,
> + * we'd better query NIC driver for the capability it can
> + * provide, especially for packet split mode, now we only
> + * query for the header size, and the payload a descriptor
> + * may carry. If a driver does not use the API to export,
> + * then we may try to use a default value, currently,
> + * we use the default value from an IGB driver. Now,
> + * it's only called by mpassthru device.
> + */
> +#if defined(CONFIG_MEDIATE_PASSTHRU) || defined(CONFIG_MEDIATE_PASSTHRU_MODULE)
> +int netdev_mp_port_prep(struct net_device *dev,
> +		struct mpassthru_port *port)
> +{
> +	int rc;
> +	int npages, data_len;
> +	const struct net_device_ops *ops = dev->netdev_ops;
> +
> +	if (ops->ndo_mp_port_prep) {
> +		rc = ops->ndo_mp_port_prep(dev, port);
> +		if (rc)
> +			return rc;
> +	} else {
> +		/* If the NIC driver did not report this,
> +		 * then we try to use default value.
> +		 */
> +		port->hdr_len = 128;
> +		port->data_len = 2048;
> +		port->npages = 1;
> +	}
[...]

Is it really necessary to have a default?

Also have you considered an API for changing the header/data split?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next-2.6 RFC PATCH v2 01/13] ethtool: allow custom
 interval for physical identification
Date: Wed, 13 Apr 2011 21:25:13 +0100
Message-ID: <1302726313.2873.18.camel@bwh-desktop>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
	 <20110413195851.25901.8139.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Bruce Allan <bruce.w.allan@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:48762 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757492Ab1DMUZQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Apr 2011 16:25:16 -0400
In-Reply-To: <20110413195851.25901.8139.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-13 at 12:58 -0700, Bruce Allan wrote:
> When physical identification of an adapter is done by toggling the
> mechanism on and off through software utilizing the set_phys_id operation,
> it is done with a fixed duration for both on and off states.  Some drivers
> may want to set a custom duration for the on/off intervals.  This patch
> changes the API so the return code from the driver's entry point when it
> is called with ETHTOOL_ID_ACTIVE can specify the frequency at which to
> cycle the on/off states.
[...]
> @@ -1655,23 +1655,26 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
>  		schedule_timeout_interruptible(
>  			id.data ? (id.data * HZ) : MAX_SCHEDULE_TIMEOUT);
>  	} else {
> -		/* Driver expects to be called periodically */
> +		/* Driver expects to be called using the frequency in rc */
> +		int i = 0, interval = (HZ / (rc * 2));
> +
>  		do {
>  			rtnl_lock();
>  			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ON);
>  			rtnl_unlock();
>  			if (rc)
>  				break;
> -			schedule_timeout_interruptible(HZ / 2);
> +			schedule_timeout_interruptible(interval);
>  
>  			rtnl_lock();
>  			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_OFF);
>  			rtnl_unlock();
>  			if (rc)
>  				break;
> -			schedule_timeout_interruptible(HZ / 2);
> +			schedule_timeout_interruptible(interval);
>  		} while (!signal_pending(current) &&
> -			 (id.data == 0 || --id.data != 0));
> +			 (id.data == 0 ||
> +			  (++i * 2 * interval) < (id.data * HZ)));
[...]

I'm sure there ought to be a clearer way to do this, and to avoid any
weird effects from integer overflow in the multiplication.  How about
using an inner loop for each second:

		/* Driver expects to be called at twice the frequency in rc */
		int n = rc * 2, i, interval = HZ / n;

		do {
			i = n;
			do {
	 			rtnl_lock();
 				rc = dev->ethtool_ops->set_phys_id(
					dev, (i & 1) ? ETHTOOL_ID_OFF : ETHTOOL_ID_ON);
	 			rtnl_unlock();
 				if (rc)
 					break;
				schedule_timeout_interruptible(interval);
			} while (!signal_pending(current) && --i != 0);
 		} while (!signal_pending(current) &&
			 (id.data == 0 || --id.data != 0));

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.


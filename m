From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Fri, 21 Sep 2012 18:19:25 +0100
Message-ID: <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1348245523.git.richardcochran@gmail.com>
	 <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	Matthew Vick <matthew.vick@intel.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:56293 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756681Ab2IURTb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Sep 2012 13:19:31 -0400
In-Reply-To: <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-21 at 19:00 +0200, Richard Cochran wrote:
> PTP Hardware Clock device have a name that appears under sysfs that should
> identify the underlying device. Instead of leaving it up to the driver to
> invent a name, this patch changes the registration to automatically use
> the name from the parent device.

I thought you wanted the driver name and not the parent device name?

[...]
> diff --git a/drivers/ptp/ptp_clock.c b/drivers/ptp/ptp_clock.c
> index 6e47450..60fa259 100644
> --- a/drivers/ptp/ptp_clock.c
> +++ b/drivers/ptp/ptp_clock.c
[...]
> @@ -219,11 +220,13 @@ struct ptp_clock *ptp_clock_register(struct ptp_clock_info *info)
>         init_waitqueue_head(&ptp->tsev_wq);
>  
>         /* Create a new device in our class. */
> -       ptp->dev = device_create(ptp_class, NULL, ptp->devid, ptp,
> +       ptp->dev = device_create(ptp_class, parent, ptp->devid, ptp,
>                                  "ptp%d", ptp->index);
>         if (IS_ERR(ptp->dev))
>                 goto no_device;
>  
> +       ptp->name = parent ? dev_name(parent) : dev_name(ptp->dev);
> +

The fallback of using dev_name(ptp->dev) is a bit sad, as that's the
same name userland already has when it reads this attribute.

[...]
> diff --git a/drivers/ptp/ptp_ixp46x.c b/drivers/ptp/ptp_ixp46x.c
> index e03c406..c0939b1 100644
> --- a/drivers/ptp/ptp_ixp46x.c
> +++ b/drivers/ptp/ptp_ixp46x.c
> @@ -241,7 +241,6 @@ static int ptp_ixp_enable(struct ptp_clock_info *ptp,
>  
>  static struct ptp_clock_info ptp_ixp_caps = {
>  	.owner		= THIS_MODULE,
> -	.name		= "IXP46X timer",
>  	.max_adj	= 66666655,
>  	.n_ext_ts	= N_EXT_TS,
>  	.pps		= 0,
> @@ -298,7 +297,7 @@ static int __init ptp_ixp_init(void)
>  
>  	ixp_clock.caps = ptp_ixp_caps;
>  
> -	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps);
> +	ixp_clock.ptp_clock = ptp_clock_register(&ixp_clock.caps, NULL);
[...]

I think this should really register a platform driver and a platform
device to be the parent of the clock device.  And then you don't need
the fallback for parent == NULL.

Since David has pulled the addition of PTP/PHC support to sfc, that will
need to be adjusted as well.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

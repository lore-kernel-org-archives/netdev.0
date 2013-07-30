From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH v3 2/2] net: igmp: Allow user-space configuration of igmp unsolicited report interval
Date: Tue, 30 Jul 2013 08:14:26 +0200
Message-ID: <20130730061426.GF2490@order.stressinduktion.org>
References: <20130726163610.GF3890@order.stressinduktion.org> <1375107711-9029-1-git-send-email-william.manley@youview.com> <1375107711-9029-2-git-send-email-william.manley@youview.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, bcrl@kvack.org, luky-37@hotmail.com,
	sergei.shtylyov@cogentembedded.com, bhutchings@solarflare.com,
	davem@davemloft.net
To: William Manley <william.manley@youview.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:47673 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754782Ab3G3GO2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jul 2013 02:14:28 -0400
Content-Disposition: inline
In-Reply-To: <1375107711-9029-2-git-send-email-william.manley@youview.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 29, 2013 at 03:21:51PM +0100, William Manley wrote:
> --- a/include/linux/inetdevice.h
> +++ b/include/linux/inetdevice.h
> @@ -30,6 +30,8 @@ enum
>  	IPV4_DEVCONF_NOXFRM,
>  	IPV4_DEVCONF_NOPOLICY,
>  	IPV4_DEVCONF_FORCE_IGMP_VERSION,
> +	IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL,
> +	IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL,
>  	IPV4_DEVCONF_ARP_ANNOUNCE,
>  	IPV4_DEVCONF_ARP_IGNORE,
>  	IPV4_DEVCONF_PROMOTE_SECONDARIES,
> @@ -62,6 +64,8 @@ struct in_device {
>  	unsigned long		mr_v1_seen;
>  	unsigned long		mr_v2_seen;
>  	unsigned long		mr_maxdelay;
> +	unsigned long		mr_v2_unsolicited_report_interval;
> +	unsigned long		mr_v3_unsolicited_report_interval;
>  	unsigned char		mr_qrv;
>  	unsigned char		mr_gq_running;
>  	unsigned char		mr_ifc_count;
> diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
> index dfc39d4..f681518 100644
> --- a/net/ipv4/devinet.c
> +++ b/net/ipv4/devinet.c
> @@ -73,6 +73,8 @@ static struct ipv4_devconf ipv4_devconf = {
>  		[IPV4_DEVCONF_SEND_REDIRECTS - 1] = 1,
>  		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
>  		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
> +		[IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL - 1] = 10000 /*ms*/,
> +		[IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL - 1] =  1000 /*ms*/,
>  	},
>  };
>  
> @@ -83,6 +85,8 @@ static struct ipv4_devconf ipv4_devconf_dflt = {
>  		[IPV4_DEVCONF_SECURE_REDIRECTS - 1] = 1,
>  		[IPV4_DEVCONF_SHARED_MEDIA - 1] = 1,
>  		[IPV4_DEVCONF_ACCEPT_SOURCE_ROUTE - 1] = 1,
> +		[IPV4_DEVCONF_IGMPV2_UNSOLICITED_REPORT_INTERVAL - 1] = 10000 /*ms*/,
> +		[IPV4_DEVCONF_IGMPV3_UNSOLICITED_REPORT_INTERVAL - 1] =  1000 /*ms*/,
>  	},
>  };
>  
> @@ -2099,6 +2103,10 @@ static struct devinet_sysctl_table {
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
>  					      "force_igmp_version"),
> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV2_UNSOLICITED_REPORT_INTERVAL,
> +					      "igmpv2_unsolicited_report_interval"),
> +		DEVINET_SYSCTL_FLUSHING_ENTRY(IGMPV3_UNSOLICITED_REPORT_INTERVAL,
> +					      "igmpv3_unsolicited_report_interval"),
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
>  					      "promote_secondaries"),
>  		DEVINET_SYSCTL_FLUSHING_ENTRY(ROUTE_LOCALNET,

Why did you use DEVINET_SYSCTL_FLUSHING_ENTRY here? Wouldn't
DEVINET_SYSCTL_RW_ENTRY be a better choice?

> diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
> index 9f0aaea..035ee77 100644
> --- a/net/ipv4/igmp.c
> +++ b/net/ipv4/igmp.c
> @@ -141,10 +141,25 @@
>  
>  static int unsolicited_report_interval(struct in_device *in_dev)
>  {
> +	int interval_ms, interval_jiffies;
> +
>  	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev))
> -		return IGMP_V2_Unsolicited_Report_Interval;
> +		interval_ms = IPV4_DEVCONF_ALL(
> +			dev_net(in_dev->dev),
> +			IGMPV2_UNSOLICITED_REPORT_INTERVAL);

IN_DEV_CONF_GET()?

Or should the igmpv{2,3}_unsolicited_report_interval only be a global setting?

>  	else /* v3 */
> -		return IGMP_V3_Unsolicited_Report_Interval;
> +		interval_ms = IPV4_DEVCONF_ALL(
> +			dev_net(in_dev->dev),
> +			IGMPV3_UNSOLICITED_REPORT_INTERVAL);

Here as well.

> +
> +	interval_jiffies = msecs_to_jiffies(interval_ms);
> +
> +	/* _timer functions can't handle a delay of 0 jiffies so ensure
> +	 *  we always return a positive value.
> +	 */

I am not sure here, but have seen mod_timer with 0 work before. But it is a
good idea anyway.

> +	if (interval_jiffies <= 0)
> +		interval_jiffies = 1;
> +	return interval_jiffies;
>  }

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC ETHTOOL PATCH 2/2] ethtool: allow setting MDI-X state
Date: Wed, 25 Jul 2012 23:59:02 +0100
Message-ID: <1343257142.5132.160.camel@deadeye.wl.decadent.org.uk>
References: <20120725174351.9839.132.stgit@jbrandeb-snb.jf.intel.com>
	 <20120725175308.9839.50343.stgit@jbrandeb-snb.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19485 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750975Ab2GYW7G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jul 2012 18:59:06 -0400
In-Reply-To: <20120725175308.9839.50343.stgit@jbrandeb-snb.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-25 at 10:53 -0700, Jesse Brandeburg wrote:
> A bit ago ethtool added support for reading MDI-X state, this
> patch finishes the implementation, adding the complementary write
> command.
> 
> Add support to ethtool for controlling the MDI-X (crossover)
> state of a network port.  Most adapters correctly negotiate
> MDI-X, but some ill-behaved switches have trouble and end up
> picking the wrong MDI setting, which results in complete loss of
> link.  Usually this error condition can be observed when multiple
> ethtool -r ethX are required before link is achieved.
> 
> This patch allows the user to override the normal "auto" setting
> and force the crossover state to on or off.
> 
> The set will fail if the driver doesn't support the get, as
> suggested by Ben Hutchings.
> 
> # ./ethtool -s p1p1 mdix off
> setting MDI not supported
> 
> In addition the do_gset output was changed slightly to report the
> value set by the user (when the driver supports the set)
> 
> old:
> MDI-X: on
> 
> new:
> MDI-X: on (auto)
> or
> MDI-X: on (forced)
> 
> usage is ethtool -s eth0 mdix [auto|on|off]
[...]
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -18,6 +18,8 @@
>   * Rx Network Flow Control configuration support <santwona.behera@sun.com>
>   * Various features by Ben Hutchings <bhutchings@solarflare.com>;
>   *	Copyright 2009, 2010 Solarflare Communications
> + * MDI-X set support by Jesse Brandeburg <jesse.brandeburg@intel.com>
> + * 	Copyright 2012 Intel Corporation
>   *
>   * TODO:
>   *   * show settings for all devices
> @@ -559,13 +561,29 @@ static int dump_ecmd(struct ethtool_cmd *ep)
>  		fprintf(stdout, "	MDI-X: ");
>  		switch (ep->eth_tp_mdix) {
>  		case ETH_TP_MDI:
> -			fprintf(stdout, "off\n");
> +			fprintf(stdout, "off");
>  			break;
>  		case ETH_TP_MDI_X:
> -			fprintf(stdout, "on\n");
> +			fprintf(stdout, "on");
>  			break;
>  		default:
> -			fprintf(stdout, "Unknown\n");
> +			fprintf(stdout, "Unknown");
> +			break;
> +		}
> +		switch (ep->eth_tp_mdix_ctrl) {
> +		case ETH_TP_MDI:
> +		case ETH_TP_MDI_X:
> +			/* forced via sset */
> +			fprintf(stdout, " (forced)\n");
[...]

How about when you have a forced mode but the driver reports eth_tp_mdix
= ETH_TP_MDI_INVALID because the link is down?  This is going to result
in:

        MDI-X: Unknown (forced)

which makes no sense at all.  So I think that we have to do something
like:

	if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI) {
		fprintf(stdout, "off (forced)\n");
	} else if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_X) {
		fprintf(stdout, "on (forced)\n");
	} else {
		switch (ep->eth_tp_mdix) {
			...
		}
		if (ep->eth_tp_mdix_ctrl == ETH_TP_MDI_AUTO)
			fprintf(stdout, " (auto)");
		fprintf(stdout, "\n");
	}

Or else we require that when the mode is forced then drivers report that
as the current status even if the link is down.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

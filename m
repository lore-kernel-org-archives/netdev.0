From: "Merav Sicron" <meravs@broadcom.com>
Subject: Re: [net-next patch] bnx2x: Add run-time CNIC support
Date: Sun, 8 Jul 2012 14:00:39 +0300
Message-ID: <1341745239.27284.13.camel@lb-tlvb-meravs.il.broadcom.com>
References: <1341740914-3181-1-git-send-email-meravs@broadcom.com>
 <20120708.033122.2108511545126626834.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, dmitry@broadcom.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2432 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751211Ab2GHLB5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Jul 2012 07:01:57 -0400
In-Reply-To: <20120708.033122.2108511545126626834.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-07-08 at 03:31 -0700, David Miller wrote:
> From: "Merav Sicron" <meravs@broadcom.com>
> Date: Sun, 8 Jul 2012 12:48:34 +0300
> 
> > This patch replaces the BCM_CNIC compilation flag with a run-time flag.
> > This is mainly important for the SR-IOV driver, as this driver will share the
> > same code with the PF/hypervisor driver. Since storage is not supported in
> > SR-IOV (while is usually enabled in the non-SR-IOV driver), we don't want to
> > waste resources on it.
> > In addition this change makes the code prettier.
>  ...
> > -static const struct net_device_ops bnx2x_netdev_ops = {
> > +static struct net_device_ops bnx2x_netdev_ops = {
>  ...
> > 
> > +	if (CNIC_ENABLED(bp))
> > +		bnx2x_netdev_ops.ndo_select_queue = bnx2x_select_queue;
> > +#if defined(NETDEV_FCOE_WWNN)
> > +	if (CNIC_ENABLED(bp))
> > +		bnx2x_netdev_ops.ndo_fcoe_get_wwn = bnx2x_fcoe_get_wwn;
> > +#endif
>  ...
> +static int set_is_cnic_enabled(void)
> +{
> +#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
> +	return 1;
> +#else
> +	return 0;
> +#endif
> +}
> 
> This is basically a joke.
> 
> You're losing const'ness of net_device_ops and other nice things for
> what is still, in the end, set by kconfig options.
> 
> I'm not applying crap like this, sorry.
> 
It seems that I didn't explain our motivation well enough...
This feature is indeed not useful for the current bnx2x functionality.
However we are adding support for a VF driver to be used in SR-IOV, and
we will have single-binary bnx2x which will be used in both
PF/Hypervisor and VF (hopefully will send a patch on it in a couple of
weeks).
Since we want CNIC in the PF/Hypervisor but don't want CNIC in the VF,
and since it is a single binary, we can't use a compilation flag but
should rather use a run-time flag. 
The set_is_cnic_enabled function will eventually look something like
this:
static int set_is_cnic_enabled(bool is_vf)
{
        if (is_vf)
                return 0;
#if defined(CONFIG_CNIC) || defined(CONFIG_CNIC_MODULE)
        return 1;
#else
        return 0;
#endif
}

Thanks,
Merav

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next PATCH 1/3] Added kernel support in EEE Ethtool
 commands
Date: Tue, 5 Jun 2012 20:01:05 +0100
Message-ID: <1338922865.21665.27.camel@deadeye.wl.decadent.org.uk>
References: <1338878342-24586-1-git-send-email-yuvalmin@broadcom.com>
	 <1338878342-24586-2-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<eilong@broadcom.com>, <peppe.cavallaro@st.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:14431 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750898Ab2FETBN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 15:01:13 -0400
In-Reply-To: <1338878342-24586-2-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-06-05 at 09:39 +0300, Yuval Mintz wrote:
> This patch extends the kernel's ethtool interface by adding support
> for 2 new EEE commands - get_eee and set_eee.
> 
> Thanks goes to Giuseppe Cavallaro for his original patch adding this support.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
> ---
>  include/linux/ethtool.h |   19 +++++++++++++++++++
>  net/core/ethtool.c      |   34 ++++++++++++++++++++++++++++++++++
>  2 files changed, 53 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index e17fa71..527de4c 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -136,6 +136,19 @@ struct ethtool_eeprom {
>  	__u8	data[0];
>  };
>  
> +/* EEE settings */
> +struct ethtool_eee {
> +	__u32	cmd;
> +	__u32	supported;
> +	__u32	advertised;
> +	__u32	lp_advertised;
> +	__u32	eee_active;
> +	__u32	eee_enabled;
> +	__u32	tx_lpi_enabled;
> +	__u32	tx_lpi_timer;
> +	__u32	reserved[2];
> +};

This needs a kernel-doc comment explaining exactly what each of the
fields means.

[...]
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
> @@ -729,6 +729,34 @@ static int ethtool_set_wol(struct net_device *dev, char __user *useraddr)
>  	return dev->ethtool_ops->set_wol(dev, &wol);
>  }
>  
> +static int ethtool_get_eee(struct net_device *dev, char __user *useraddr)
> +{
> +	struct ethtool_eee edata;
> +
> +	if (!dev->ethtool_ops->get_eee)
> +		return -EOPNOTSUPP;

We *must* initialise all of edata and we should not leave it to the
driver to do.  Otherwise we will be copying back uninitialised data to
userland which (1) might reveal sensitive information stored on the
stack by previous function calls (2) sets the cmd field to the wrong
value (3) sets the reserved fields to random values, making them
unusable for expansion.

> +	dev->ethtool_ops->get_eee(dev, &edata);

Missing error check.

> +	if (copy_to_user(useraddr, &edata, sizeof(edata)))
> +		return -EFAULT;
> +
> +	return 0;
> +}
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

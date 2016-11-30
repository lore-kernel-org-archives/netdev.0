From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/6] net: ethernet: ti: netcp: add support of cpts
Date: Wed, 30 Nov 2016 10:44:41 +0100
Message-ID: <20161130094441.GB28680@localhost.localdomain>
References: <20161128230428.6872-1-grygorii.strashko@ti.com>
 <20161128230428.6872-2-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
        devicetree@vger.kernel.org, Murali Karicheri <m-karicheri2@ti.com>,
        Wingman Kwok <w-kwok2@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f193.google.com ([209.85.210.193]:34307 "EHLO
        mail-wj0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754190AbcK3Jos (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 04:44:48 -0500
Content-Disposition: inline
In-Reply-To: <20161128230428.6872-2-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 28, 2016 at 05:04:23PM -0600, Grygorii Strashko wrote:
> @@ -678,6 +744,9 @@ struct gbe_priv {
>  	int				num_et_stats;
>  	/*  Lock for updating the hwstats */
>  	spinlock_t			hw_stats_lock;
> +
> +	int                             cpts_registered;

The usage of this counter is racy.

> +	struct cpts                     *cpts;
>  };

This ++ and -- business ...

> +static void gbe_register_cpts(struct gbe_priv *gbe_dev)
> +{
> +	if (!gbe_dev->cpts)
> +		return;
> +
> +	if (gbe_dev->cpts_registered > 0)
> +		goto done;
> +
> +	if (cpts_register(gbe_dev->cpts)) {
> +		dev_err(gbe_dev->dev, "error registering cpts device\n");
> +		return;
> +	}
> +
> +done:
> +	++gbe_dev->cpts_registered;
> +}
> +
> +static void gbe_unregister_cpts(struct gbe_priv *gbe_dev)
> +{
> +	if (!gbe_dev->cpts || (gbe_dev->cpts_registered <= 0))
> +		return;
> +
> +	if (--gbe_dev->cpts_registered)
> +		return;
> +
> +	cpts_unregister(gbe_dev->cpts);
> +}

is invoked from your open() and close() methods, but those methods
are not serialized among multiple ports.

Thanks,
Richard

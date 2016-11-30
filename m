From: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
Subject: Re: [PATCH] net: ethernet: ti: cpsw: fix ASSERT_RTNL() warning
 during resume
Date: Wed, 30 Nov 2016 02:18:57 +0200
Message-ID: <20161130001857.GB18604@khorivan>
References: <20161129222703.10908-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Sekhar Nori <nsekhar@ti.com>, linux-kernel@vger.kernel.org,
        linux-omap@vger.kernel.org, Dave Gerlach <d-gerlach@ti.com>
To: Grygorii Strashko <grygorii.strashko@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36536 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756258AbcK3ATC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:19:02 -0500
Received: by mail-lf0-f45.google.com with SMTP id t196so134748953lff.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 16:19:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20161129222703.10908-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 29, 2016 at 04:27:03PM -0600, Grygorii Strashko wrote:
> netif_set_real_num_tx/rx_queues() are required to be called with rtnl_lock
> taken, otherwise ASSERT_RTNL() warning will be triggered - which happens
> now during System resume from suspend:
> cpsw_resume()
> |- cpsw_ndo_open()
>   |- netif_set_real_num_tx/rx_queues()
>      |- ASSERT_RTNL();
> 
> Hence, fix it by surrounding cpsw_ndo_open() by rtnl_lock/unlock() calls.
> 
> Cc: Dave Gerlach <d-gerlach@ti.com>
> Cc: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>
> Fixes: commit e05107e6b747 ("net: ethernet: ti: cpsw: add multi queue support")
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
Reviewed-by: Ivan Khoronzhuk <ivan.khoronzhuk@linaro.org>

> ---
>  drivers/net/ethernet/ti/cpsw.c | 4 ++++
>  1 file changed, 4 insertions(+)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index ae1ec6a..fd6c03b 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -2944,6 +2944,8 @@ static int cpsw_resume(struct device *dev)
>  	/* Select default pin state */
>  	pinctrl_pm_select_default_state(dev);
>  
> +	/* shut up ASSERT_RTNL() warning in netif_set_real_num_tx/rx_queues */
> +	rtnl_lock();
>  	if (cpsw->data.dual_emac) {
>  		int i;
>  
> @@ -2955,6 +2957,8 @@ static int cpsw_resume(struct device *dev)
>  		if (netif_running(ndev))
>  			cpsw_ndo_open(ndev);
>  	}
> +	rtnl_unlock();
> +
>  	return 0;
>  }
>  #endif
> -- 
> 2.10.1
> 

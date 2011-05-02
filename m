From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: Fix failure to enable WoL by default when possible
Date: Mon, 02 May 2011 15:47:52 -0700 (PDT)
Message-ID: <20110502.154752.28799639.davem@davemloft.net>
References: <201104282302.15502.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mcarlson@broadcom.com, mchan@broadcom.com, sfr@canb.auug.org.au,
	linux-next@vger.kernel.org
To: rjw@sisk.pl
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <201104282302.15502.rjw@sisk.pl>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Rafael J. Wysocki" <rjw@sisk.pl>
Date: Thu, 28 Apr 2011 23:02:15 +0200

> From: Rafael J. Wysocki <rjw@sisk.pl>
> 
> tg3 is supposed to enable WoL by default on adapters which support
> that, but it fails to do so unless the adapter's
> /sys/devices/.../power/wakeup file contains 'enabled' during the
> initialization of the adapter.  Fix that by making tg3 use
> device_set_wakeup_enable() to enable wakeup automatically whenever
> WoL should be enabled by default.
> 
> Signed-off-by: Rafael J. Wysocki <rjw@sisk.pl>

Applied, thanks Rafael.

Stephen, this patch is going to show up in net-2.6 and it will
generate a merge conflict with Joe Perches's commit in net-next-2.6
which converts tg3 to use a bitmap for the tp->tg3_flags* values.

--------------------
commit 63c3a66fe6c827a731dcbdee181158b295626f83
Author: Joe Perches <joe@perches.com>
Date:   Tue Apr 26 08:12:10 2011 +0000

    tg3: Convert u32 flag,flg2,flg3 uses to bitmap
--------------------

It should be easy to resolve, and you don't need to report this
to us when you hit it while building your -next tree, thanks :-)

I'll resolve it myself over the next day or two.

> ---
>  drivers/net/tg3.c |    8 ++++++--
>  1 file changed, 6 insertions(+), 2 deletions(-)
> 
> Index: linux-2.6/drivers/net/tg3.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/tg3.c
> +++ linux-2.6/drivers/net/tg3.c
> @@ -12327,8 +12327,10 @@ static void __devinit tg3_get_eeprom_hw_
>  		if (val & VCPU_CFGSHDW_ASPM_DBNC)
>  			tp->tg3_flags |= TG3_FLAG_ASPM_WORKAROUND;
>  		if ((val & VCPU_CFGSHDW_WOL_ENABLE) &&
> -		    (val & VCPU_CFGSHDW_WOL_MAGPKT))
> +		    (val & VCPU_CFGSHDW_WOL_MAGPKT)) {
>  			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
> +			device_set_wakeup_enable(&tp->pdev->dev, true);
> +		}
>  		goto done;
>  	}
>  
> @@ -12461,8 +12463,10 @@ static void __devinit tg3_get_eeprom_hw_
>  			tp->tg3_flags &= ~TG3_FLAG_WOL_CAP;
>  
>  		if ((tp->tg3_flags & TG3_FLAG_WOL_CAP) &&
> -		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE))
> +		    (nic_cfg & NIC_SRAM_DATA_CFG_WOL_ENABLE)) {
>  			tp->tg3_flags |= TG3_FLAG_WOL_ENABLE;
> +			device_set_wakeup_enable(&tp->pdev->dev, true);
> +		}
>  
>  		if (cfg2 & (1 << 17))
>  			tp->phy_flags |= TG3_PHYFLG_CAPACITIVE_COUPLING;
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

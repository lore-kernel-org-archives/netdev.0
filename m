From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net 1/3] r8169:fix kernel log spam when set or get
 hardware wol setting.
Date: Thu, 28 Jul 2016 00:10:01 +0200
Message-ID: <20160727221001.GA3338@electric-eye.fr.zoreil.com>
References: <1469637668-8751-1-git-send-email-hau@realtek.com>
 <1469637668-8751-2-git-send-email-hau@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org
To: Chunhao Lin <hau@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1469637668-8751-2-git-send-email-hau@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chunhao Lin <hau@realtek.com> :
[...]
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 0e62d74..f07604f 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
[...]
> @@ -1852,12 +1863,17 @@ static int rtl8169_set_wol(struct net_device *dev, struct ethtool_wolinfo *wol)
>  		tp->features |= RTL_FEATURE_WOL;
>  	else
>  		tp->features &= ~RTL_FEATURE_WOL;
> -	__rtl8169_set_wol(tp, wol->wolopts);
> +	if (pm_runtime_active(&pdev->dev))
> +		__rtl8169_set_wol(tp, wol->wolopts);
> +	else
> +		tp->saved_wolopts = wol->wolopts;
>  
>  	rtl_unlock_work(tp);
>  
>  	device_set_wakeup_enable(&tp->pci_dev->dev, wol->wolopts);
>  
> +	pm_runtime_put_noidle(&pdev->dev);
> +
>  	return 0;

Either the driver resumes the device so that it can perform requested
operation or it signals .set_wol failure when the device is suspended.

If the driver does something else, "spam removal" translates to
"silent failure".

-- 
Ueimor

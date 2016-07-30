From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH net-next 01/10] drivers: net: xgene: Fix kbuild warning
Date: Sat, 30 Jul 2016 11:13:17 +0200
Message-ID: <14140485.FlkQbu0aHJ@wuerfel>
References: <1469838843-19943-1-git-send-email-isubramanian@apm.com> <1469838843-19943-2-git-send-email-isubramanian@apm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	devicetree@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	patches@apm.com, linux@armlinux.org.uk
To: Iyappan Subramanian <isubramanian@apm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([217.72.192.74]:64276 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750833AbcG3JNz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jul 2016 05:13:55 -0400
In-Reply-To: <1469838843-19943-2-git-send-email-isubramanian@apm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, July 29, 2016 5:33:54 PM CEST Iyappan Subramanian wrote:
> This patch fixes the following kbuild warning, when ACPI was not enabled.
> 
> >> drivers/net/ethernet/apm/xgene/xgene_enet_hw.c:878:23: warning: 'phy_dev' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      phy_dev->advertising = phy_dev->supported;

>From looking at the patch, I don't think it addresses the warning.
Note that Linus added a patch to disable the warning in the latest
mainline kernel, so you won't see it any more, but I think the bug
is still there.

> diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> index 7714b7d..b6bc6fa 100644
> --- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> +++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
> @@ -776,15 +776,11 @@ int xgene_enet_phy_connect(struct net_device *ndev)
>                         netdev_err(ndev, "Could not connect to PHY\n");
>                         return -ENODEV;
>                 }
> -
> -               pdata->phy_dev = phy_dev;
>         } else {
>  #ifdef CONFIG_ACPI
>                 struct acpi_device *adev = acpi_phy_find_device(dev);
>                 if (adev)
> -                       pdata->phy_dev =  adev->driver_data;
> -
> -               phy_dev = pdata->phy_dev;
> +                       phy_dev =  adev->driver_data;
>  
>                 if (!phy_dev ||
>                     phy_connect_direct(ndev, phy_dev, &xgene_enet_adjust_link,
> @@ -795,6 +791,7 @@ int xgene_enet_phy_connect(struct net_device *ndev)
>  #endif
>         }
>  
> +       pdata->phy_dev = phy_dev;

phy_dev is not initialized anywhere if CONFIG_ACPI is not set
and dev->of_node is NULL (which should not happen in practice,
but the compiler doesn't know that).

I think you want this instead:

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
index 7714b7d4026a..98779fe2d558 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_hw.c
@@ -792,6 +792,8 @@ int xgene_enet_phy_connect(struct net_device *ndev)
 			netdev_err(ndev, "Could not connect to PHY\n");
 			return  -ENODEV;
 		}
+#else
+		return -ENODEV;
 #endif
 	}
 

	ARnd

	Arnd

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] korina: fix probing crash
Date: Mon, 12 Jan 2009 21:52:02 -0800 (PST)
Message-ID: <20090112.215202.194850308.davem@davemloft.net>
References: <200901111654.24651.florian@openwrt.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, n0-1@freewrt.org
To: florian@openwrt.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38766
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751163AbZAMFwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 00:52:01 -0500
In-Reply-To: <200901111654.24651.florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <florian@openwrt.org>
Date: Sun, 11 Jan 2009 16:54:24 +0100

> korina: fix probing crash
> 
> This patch fixes the wrong retrieval of platform_data
> which makes the driver crash on probe. Propagate error
> if the platform_driver cannot use its data.
> 
> Signed-off-by: Florian Fainelli <florian@openwrt.org>

There are several problems with this patch:

> @@ -1078,12 +1078,18 @@ static int korina_close(struct net_device *dev)
>  
>  static int korina_probe(struct platform_device *pdev)
>  {
> -	struct korina_device *bif = platform_get_drvdata(pdev);
> +	struct korina_device *bif;
>  	struct korina_private *lp;
>  	struct net_device *dev;
>  	struct resource *r;
>  	int rc;
>  
> +	bif = (struct korina_device *)pdev->dev.platform_data;

This cast is unnecessary, platform_data is "void *"

Secondly, korina_remove() also expects the korina_device pointer to be
in the platform drvdata.  It therefore has the same bug as
korina_probe() and needs to be fixed too.

But I suspect there is some other weird problem here.  If
you need to change from drvdata over to platform_data, then
this driver never could have been probed or removed properly.

This is absolutely a fundamental bug, where did it come from?

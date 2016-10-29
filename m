From: Baoquan He <bhe@redhat.com>
Subject: Re: [bnx2] [Regression 4.8] Driver loading fails without firmware
Date: Sat, 29 Oct 2016 10:55:38 +0800
Message-ID: <20161029025538.GA4099@x1>
References: <244cb42b-0fce-fe41-7b7c-babb51411e8c@molgen.mpg.de>
 <b0675854-41f9-e7b6-4ad0-85ff59b98977@molgen.mpg.de>
 <20161026120021.GA4402@x1>
 <f055c961-58ca-ea81-46d8-610fa055cce8@molgen.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Sony Chacko <sony.chacko@qlogic.com>,
        Dept-HSGLinuxNICDev@qlogic.com, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, dvteam@molgen.mpg.de
To: Paul Menzel <pmenzel@molgen.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51630 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752756AbcJ2Czo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 22:55:44 -0400
Content-Disposition: inline
In-Reply-To: <f055c961-58ca-ea81-46d8-610fa055cce8@molgen.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/27/16 at 03:21pm, Paul Menzel wrote:
> Dear Baoquan,
> > > Baoquan, could you please fix this regression. My suggestion is, that you
> > > add the old code back, but check if the firmware has been loaded. If it
> > > hasn’t, load it again.
> > > 
> > > That way, people can update their Linux kernel, and it continues working
> > > without changing the initramfs, or anything else.
> > 
> > I saw your mail but I am also not familiar with bnx2 driver. As the
> > commit log says I just tried to make bnx2 driver reset itself earlier.
> > 
> > So you did a git bisect and found this commit caused the regression,
> > right? If yes, and network developers have no action, I will look into
> > the code and see if I have idea to fix it.
> 
> Well, I looked through the commits and found that one, which would explain
> the changed behavior.
> 
> To be sure, and to follow your request, I took Linux 4.8.4 and reverted your
> commit (attached). Then I deleted the firmware again from the initramfs, and
> rebooted. The devices showed up just fine as before.
> 
> So to summarize, the commit is indeed the culprit.

Hi Paul,

Sorry for this.

Could you tell the steps to reproduce? I will find a machine with bnx2
NIC and check if there's other ways.

Thanks
Baoquan

> From 61b8dac8796343a797858b4a2eb0a59a0cfcd735 Mon Sep 17 00:00:00 2001
> From: Paul Menzel <pmenzel@molgen.mpg.de>
> Date: Thu, 27 Oct 2016 11:34:52 +0200
> Subject: [PATCH] Revert "bnx2: Reset device during driver initialization"
> 
> This reverts commit 3e1be7ad2d38c6bd6aeef96df9bd0a7822f4e51c.
> ---
>  drivers/net/ethernet/broadcom/bnx2.c | 12 +++++-------
>  1 file changed, 5 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/ethernet/broadcom/bnx2.c b/drivers/net/ethernet/broadcom/bnx2.c
> index 27f11a5..ecd357d 100644
> --- a/drivers/net/ethernet/broadcom/bnx2.c
> +++ b/drivers/net/ethernet/broadcom/bnx2.c
> @@ -6356,6 +6356,10 @@ bnx2_open(struct net_device *dev)
>  	struct bnx2 *bp = netdev_priv(dev);
>  	int rc;
>  
> +	rc = bnx2_request_firmware(bp);
> +	if (rc < 0)
> +		goto out;
> +
>  	netif_carrier_off(dev);
>  
>  	bnx2_disable_int(bp);
> @@ -6424,6 +6428,7 @@ bnx2_open(struct net_device *dev)
>  	bnx2_free_irq(bp);
>  	bnx2_free_mem(bp);
>  	bnx2_del_napi(bp);
> +	bnx2_release_firmware(bp);
>  	goto out;
>  }
>  
> @@ -8570,12 +8575,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  
>  	pci_set_drvdata(pdev, dev);
>  
> -	rc = bnx2_request_firmware(bp);
> -	if (rc < 0)
> -		goto error;
> -
> -
> -	bnx2_reset_chip(bp, BNX2_DRV_MSG_CODE_RESET);
>  	memcpy(dev->dev_addr, bp->mac_addr, ETH_ALEN);
>  
>  	dev->hw_features = NETIF_F_IP_CSUM | NETIF_F_SG |
> @@ -8608,7 +8607,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
>  	return 0;
>  
>  error:
> -	bnx2_release_firmware(bp);
>  	pci_iounmap(pdev, bp->regview);
>  	pci_release_regions(pdev);
>  	pci_disable_device(pdev);
> -- 
> 2.4.1
> 

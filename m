From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net V2] tuntap: correctly handle error in tun_set_iff()
Date: Wed, 11 Sep 2013 13:43:50 +0300
Message-ID: <20130911104350.GA25316@redhat.com>
References: <1378894188-8015-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, wannes.rombouts@epitech.eu
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59855 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750935Ab3IKKlq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Sep 2013 06:41:46 -0400
Content-Disposition: inline
In-Reply-To: <1378894188-8015-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 06:09:48PM +0800, Jason Wang wrote:
> Commit c8d68e6be1c3b242f1c598595830890b65cea64a
> (tuntap: multiqueue support) only call free_netdev() on error in
> tun_set_iff(). This causes several issues:
> 
> - memory of tun security were leaked
> - use after free since the flow gc timer was not deleted and the tfile
>   were not detached
> 
> This patch solves the above issues.
> 
> Reported-by: Wannes Rombouts <wannes.rombouts@epitech.eu>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> - Changes from V1: shift 1 space for label err_free_netdev and keep
>   commit log under 70 chars per line.
> - The patch were needed for stable kernel 3.8+.
> ---
>  drivers/net/tun.c |   11 ++++++++---
>  1 files changed, 8 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index a639de8..807815f 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1641,11 +1641,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  		INIT_LIST_HEAD(&tun->disabled);
>  		err = tun_attach(tun, file, false);
>  		if (err < 0)
> -			goto err_free_dev;
> +			goto err_free_flow;
>  
>  		err = register_netdevice(tun->dev);
>  		if (err < 0)
> -			goto err_free_dev;
> +			goto err_detach;
>  
>  		if (device_create_file(&tun->dev->dev, &dev_attr_tun_flags) ||
>  		    device_create_file(&tun->dev->dev, &dev_attr_owner) ||
> @@ -1689,7 +1689,12 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  	strcpy(ifr->ifr_name, tun->dev->name);
>  	return 0;
>  
> - err_free_dev:
> +err_detach:
> +	tun_detach_all(dev);
> +err_free_flow:
> +	tun_flow_uninit(tun);
> +	security_tun_dev_free_security(tun->security);
> +err_free_dev:
>  	free_netdev(dev);
>  	return err;
>  }
> -- 
> 1.7.1

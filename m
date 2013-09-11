From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH net] tuntap: correctly handle error in tun_set_iff()
Date: Wed, 11 Sep 2013 12:38:43 +0300
Message-ID: <20130911093843.GA20836@redhat.com>
References: <1378887845-6821-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	wannes.rombouts@epitech.eu, linux-kernel@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1378887845-6821-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 11, 2013 at 04:24:05PM +0800, Jason Wang wrote:
> Commit c8d68e6be1c3b242f1c598595830890b65cea64a (tuntap: multiqueue support)
> only call free_netdev() on err in tun_set_iff(). This causes several issues:
> 
> - memory of tun security were leaked

Not just tun security -  sock reference too (didn't detach)

> - use after free since the flow gc timer was not deleted and the tfile were not
>   detached
> 
> This patch solves the above issues.
> 
> Reported-by: Wannes Rombouts <wannes.rombouts@epitech.eu>
> Cc: Michael S. Tsirkin <mst@redhat.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>
> ---
> The patch were also needed for stable 3.8+.
> ---
>  drivers/net/tun.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index a639de8..e5fb5d3 100644
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
> @@ -1689,6 +1689,11 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>  	strcpy(ifr->ifr_name, tun->dev->name);
>  	return 0;
>  
> +err_detach:
> +	tun_detach_all(dev);
> +err_free_flow:
> +	tun_flow_uninit(tun);
> +	security_tun_dev_free_security(tun->security);

This bit looks wrong: if flow_init fails, we
need security_tun_dev_free_security, don't we?
I think we need:
	+err_free_sec:	security_tun_dev_free_security(tun->security);
and goto here on flow_init failures.

>   err_free_dev:

Pls shift this one 1 space left for consistency.

>  	free_netdev(dev);
>  	return err;
> -- 
> 1.7.1

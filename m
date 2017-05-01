From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net v3] driver: veth: Fix one possbile memleak when fail
 to register_netdevice
Date: Mon, 1 May 2017 09:08:17 -0600
Message-ID: <92eab1fc-cd70-1561-1f94-665e77725750@cumulusnetworks.com>
References: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
To: gfree.wind@foxmail.com, davem@davemloft.net, jarod@redhat.com,
        lucien.xin@gmail.com, stephen@networkplumber.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f41.google.com ([74.125.83.41]:36617 "EHLO
        mail-pg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763628AbdEAQN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 1 May 2017 12:13:58 -0400
Received: by mail-pg0-f41.google.com with SMTP id t7so46808157pgt.3
        for <netdev@vger.kernel.org>; Mon, 01 May 2017 09:13:58 -0700 (PDT)
In-Reply-To: <1493437911-27167-1-git-send-email-gfree.wind@foxmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/28/17 9:51 PM, gfree.wind@foxmail.com wrote:
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 8c39d6d..418376a 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -224,9 +224,21 @@ static int veth_dev_init(struct net_device *dev)
>  	return 0;
>  }
>  
> -static void veth_dev_free(struct net_device *dev)
> +static void veth_destructor_free(struct net_device *dev)

_destructor in the name is confusing since veth_dev_free is the
dev->destructor. Perhaps that should be veth_free_stats.


>  {
>  	free_percpu(dev->vstats);
> +}
> +
> +static void veth_dev_uninit(struct net_device *dev)
> +{
> +	/* dev is not registered, perform the free instead of destructor */
> +	if (dev->reg_state == NETREG_UNINITIALIZED)
> +		veth_destructor_free(dev);
> +}
> +
> +static void veth_dev_free(struct net_device *dev)
> +{
> +	veth_destructor_free(dev);
>  	free_netdev(dev);
>  }
>  
> @@ -284,6 +296,7 @@ static void veth_set_rx_headroom(struct net_device *dev, int new_hr)
>  
>  static const struct net_device_ops veth_netdev_ops = {
>  	.ndo_init            = veth_dev_init,
> +	.ndo_uninit          = veth_dev_uninit,
>  	.ndo_open            = veth_open,
>  	.ndo_stop            = veth_close,
>  	.ndo_start_xmit      = veth_xmit,
> 

Functionally, it looks good to me.

Acked-by: David Ahern <dsa@cumulusnetworks.com>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: rtnl_lock deadlock on 3.10
Date: Wed, 3 Jul 2013 07:11:52 +0200
Message-ID: <20130703051152.GA12615@order.stressinduktion.org>
References: <20130701145456.GA7756@sbohrermbp13-local.rgmadvisors.com> <20130702082818.GA26178@order.stressinduktion.org> <kqul4h$ib8$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:51307 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751830Ab3GCFLy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Jul 2013 01:11:54 -0400
Content-Disposition: inline
In-Reply-To: <kqul4h$ib8$1@ger.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 02, 2013 at 01:38:26PM +0000, Cong Wang wrote:
> On Tue, 02 Jul 2013 at 08:28 GMT, Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > On Mon, Jul 01, 2013 at 09:54:56AM -0500, Shawn Bohrer wrote:
> >> I've managed to hit a deadlock at boot a couple times while testing
> >> the 3.10 rc kernels.  It seems to always happen when my network
> >> devices are initializing.  This morning I updated to v3.10 and made a
> >> few config tweaks and so far I've hit it 4 out of 5 reboots.  It looks
> >> like most processes are getting stuck on rtnl_lock.  Below is a boot
> >> log with the soft lockup prints.  Please let know if there is any
> >> other information I can provide:
> >
> > Could you try a build with CONFIG_LOCKDEP enabled?
> >
> 
> The problem is clear: ib_register_device() is called with rtnl_lock,
> but itself needs device_mutex, however, ib_register_client() first
> acquires device_mutex, then indirectly calls register_netdev() which
> takes rtnl_lock. Deadlock!
> 
> One possible fix is always taking rtnl_lock before taking
> device_mutex, something like below:
> 
> diff --git a/drivers/infiniband/core/device.c b/drivers/infiniband/core/device.c
> index 18c1ece..890870b 100644
> --- a/drivers/infiniband/core/device.c
> +++ b/drivers/infiniband/core/device.c
> @@ -381,6 +381,7 @@ int ib_register_client(struct ib_client *client)
>  {
>  	struct ib_device *device;
>  
> +	rtnl_lock();
>  	mutex_lock(&device_mutex);
>  
>  	list_add_tail(&client->list, &client_list);
> @@ -389,6 +390,7 @@ int ib_register_client(struct ib_client *client)
>  			client->add(device);
>  
>  	mutex_unlock(&device_mutex);
> +	rtnl_unlock();
>  
>  	return 0;
>  }
> diff --git a/drivers/infiniband/ulp/ipoib/ipoib_main.c b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> index b6e049a..5a7a048 100644
> --- a/drivers/infiniband/ulp/ipoib/ipoib_main.c
> +++ b/drivers/infiniband/ulp/ipoib/ipoib_main.c
> @@ -1609,7 +1609,7 @@ static struct net_device *ipoib_add_port(const char *format,
>  		goto event_failed;
>  	}
>  
> -	result = register_netdev(priv->dev);
> +	result = register_netdevice(priv->dev);
>  	if (result) {
>  		printk(KERN_WARNING "%s: couldn't register ipoib port %d; error %d\n",
>  		       hca->name, port, result);

Looks good to me. Shawn, could you test this patch?

Thanks,

  Hannes

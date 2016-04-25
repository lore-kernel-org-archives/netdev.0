From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next] macvlan: fix failure during registration v3
Date: Mon, 25 Apr 2016 14:00:24 -0500
Message-ID: <87y4813453.fsf@x220.int.ebiederm.org>
References: <1461449012-7401-1-git-send-email-fruggeri@arista.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Francesco Ruggeri <fruggeri@arista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:59200 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932961AbcDYTK4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Apr 2016 15:10:56 -0400
In-Reply-To: <1461449012-7401-1-git-send-email-fruggeri@arista.com> (Francesco
	Ruggeri's message of "Sat, 23 Apr 2016 15:03:32 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Francesco Ruggeri <fruggeri@arista.com> writes:

> If macvlan_common_newlink fails in register_netdevice after macvlan_init
> then it decrements port->count twice, first in macvlan_uninit (from
> register_netdevice or rollback_registered) and then again in
> macvlan_common_newlink.
> A similar problem may exist in the ipvlan driver.
> This patch consolidates modifications to port->count into macvlan_init
> and macvlan_uninit (thanks to Eric Biederman for suggesting this approach).
>
> v3: remove macvtap specific bits.

Acked-by: "Eric W. Biederman" <ebiederm@xmission.com>

> Signed-off-by: Francesco Ruggeri <fruggeri@arista.com>
> ---
>  drivers/net/macvlan.c | 10 ++++------
>  1 file changed, 4 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
> index 2bcf1f3..cb01023 100644
> --- a/drivers/net/macvlan.c
> +++ b/drivers/net/macvlan.c
> @@ -795,6 +795,7 @@ static int macvlan_init(struct net_device *dev)
>  {
>  	struct macvlan_dev *vlan = netdev_priv(dev);
>  	const struct net_device *lowerdev = vlan->lowerdev;
> +	struct macvlan_port *port = vlan->port;
>  
>  	dev->state		= (dev->state & ~MACVLAN_STATE_MASK) |
>  				  (lowerdev->state & MACVLAN_STATE_MASK);
> @@ -812,6 +813,8 @@ static int macvlan_init(struct net_device *dev)
>  	if (!vlan->pcpu_stats)
>  		return -ENOMEM;
>  
> +	port->count += 1;
> +
>  	return 0;
>  }
>  
> @@ -1312,10 +1315,9 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>  			return err;
>  	}
>  
> -	port->count += 1;
>  	err = register_netdevice(dev);
>  	if (err < 0)
> -		goto destroy_port;
> +		return err;
>  
>  	dev->priv_flags |= IFF_MACVLAN;
>  	err = netdev_upper_dev_link(lowerdev, dev);
> @@ -1330,10 +1332,6 @@ int macvlan_common_newlink(struct net *src_net, struct net_device *dev,
>  
>  unregister_netdev:
>  	unregister_netdevice(dev);
> -destroy_port:
> -	port->count -= 1;
> -	if (!port->count)
> -		macvlan_port_destroy(lowerdev);
>  
>  	return err;
>  }

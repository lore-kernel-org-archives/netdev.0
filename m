From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: replace hooks in __netif_receive_skb
Date: Thu, 27 May 2010 16:17:46 +0200
Message-ID: <1274969866.2523.22.camel@edumazet-laptop>
References: <20100527134935.GA6916@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, shemminger@vyatta.com,
	kaber@trash.net
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39726 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757924Ab0E0ORv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 May 2010 10:17:51 -0400
Received: by wyb29 with SMTP id 29so4217546wyb.19
        for <netdev@vger.kernel.org>; Thu, 27 May 2010 07:17:50 -0700 (PDT)
In-Reply-To: <20100527134935.GA6916@psychotron.lab.eng.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 27 mai 2010 =C3=A0 15:49 +0200, Jiri Pirko a =C3=A9crit :

> +/**
> + *	netdev_rx_handler_unregister - unregister receive handler
> + *	@dev: device to unregister a handler from
> + *	@rh: receive handler to unregister
> + *
> + *	Unregister a receive hander from a device.
> + */
> +void netdev_rx_handler_unregister(struct net_device *dev,
> +				  struct netdev_rx_handler *rh)
> +{
> +	struct netdev_rx_handler *rh1;
> +
> +	spin_lock_bh(&dev->rx_handlers_lock);
> +	list_for_each_entry(rh1, &dev->rx_handlers, list) {
> +		if (rx_handlers_equal(rh, rh1)) {
> +			list_del_rcu(&rh1->list);
> +			synchronize_net();
> +			kfree(rh1);
> +			break;
> +		}
> +	}
> +	spin_unlock_bh(&dev->rx_handlers_lock);
> +}
> +EXPORT_SYMBOL(netdev_rx_handler_unregister);
> +

Please dont synchronize_net(); inside the spin_lock_bh() section, at a
very minimum.

void netdev_rx_handler_unregister(struct net_device *dev,
                                 struct netdev_rx_handler *rh)
{
        struct netdev_rx_handler *rh1, *found =3D NULL;

       spin_lock_bh(&dev->rx_handlers_lock);
       list_for_each_entry(rh1, &dev->rx_handlers, list) {
               if (rx_handlers_equal(rh, rh1)) {
               		list_del_rcu(&rh1->list);
			found =3D rh1;
               		break;
               }
	}
	spin_unlock_bh(&dev->rx_handlers_lock);
	if (found) {
		synchronize_net();
		kfree(rh1);
	}
}


This synchronize_net() proliferation makes me very nervous.

Am I the only one that think this thing is/should be avoided as much as
possible ?

Please dont use synchronize_net() but a call_rcu(), there is absolutely
no point making this thread waits 30 or 40 ms, there is no risk here.

Thanks



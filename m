From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [BUG] Lockdep splat in usb network gadget
Date: Wed, 23 Jul 2014 11:11:14 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1407231110490.23352@nanos>
References: <alpine.DEB.2.10.1407181542290.24854@nanos> <CAJFZqHys3KUxBBaV18Gb3h-R7tQQpZJyh92dR1tyNizgoT5=UQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev <netdev@vger.kernel.org>, linux-usb@vger.kernel.org,
	jeff.westfahl@ni.com
To: Li RongQing <roy.qing.li@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:43248 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757551AbaGWJLR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jul 2014 05:11:17 -0400
In-Reply-To: <CAJFZqHys3KUxBBaV18Gb3h-R7tQQpZJyh92dR1tyNizgoT5=UQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 23 Jul 2014, Li RongQing wrote:

> This commit introduced this bug
> 
> commit a9232076374334ca2bc2a448dfde96d38a54349a
> Author: Jeff Westfahl <jeff.westfahl@ni.com>
> Date:   Thu May 29 09:49:41 2014 +0300
> 
>     usb: gadget: u_ether: synchronize with transmit when stopping queue
> 
>     When disconnecting, it's possible that another thread has already made it
>     into eth_start_xmit before we call netif_stop_queue. This can lead to a
>     crash as eth_start_xmit tries to use resources that gether_disconnect is
>     freeing. Use netif_tx_lock/unlock around netif_stop_queue to ensure no
>     threads are executing during the remainder of gether_disconnect.
> 
>     Signed-off-by: Jeff Westfahl <jeff.westfahl@ni.com>
>     Tested-by: Jaeden Amero <jaeden.amero@ni.com>
>     Signed-off-by: Felipe Balbi <balbi@ti.com>

So what's the fix?
 
> diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
> index 3d78a88..97b0277 100644
> --- a/drivers/usb/gadget/u_ether.c
> +++ b/drivers/usb/gadget/u_ether.c
> @@ -1120,7 +1120,10 @@ void gether_disconnect(struct gether *link)
> 
>         DBG(dev, "%s\n", __func__);
> 
> +       netif_tx_lock(dev->net);
>         netif_stop_queue(dev->net);
> +       netif_tx_unlock(dev->net);
> +
>         netif_carrier_off(dev->net);

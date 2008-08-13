From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
	code
Date: Wed, 13 Aug 2008 13:59:43 +0400
Message-ID: <20080813095942.GA9145@martell.zuzino.mipt.ru>
References: <20080813095324.GA15055@ben.ifi.uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>
To: Vegard Nossum <vegard.nossum@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:21285 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751825AbYHMJ7r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Aug 2008 05:59:47 -0400
Received: by fg-out-1718.google.com with SMTP id 19so1625663fgg.17
        for <netdev@vger.kernel.org>; Wed, 13 Aug 2008 02:59:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080813095324.GA15055@ben.ifi.uio.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 13, 2008 at 11:53:24AM +0200, Vegard Nossum wrote:
> I encountered a hard-to-debug deadlock when I pulled out the plug of my
> RealTek 8139 which was also running netconsole: The driver wants to print
> a "link down" message. However, this triggers netconsole, which wants to
> print the message using the same device. Here is a backtrace:
> 
>  [<c05916b6>] _spin_lock_irqsave+0x76/0x90
>  [<c035b255>] rtl8139_start_xmit+0x65/0x130 <-- spin_lock(&tp->lock)
>  [<c04c5e28>] netpoll_send_skb+0x158/0x1a0
>  [<c04c62fb>] netpoll_send_udp+0x1db/0x1f0
>  [<c037c70c>] write_msg+0x8c/0xc0
>  [<c0135883>] __call_console_drivers+0x53/0x60
>  [<c01358db>] _call_console_drivers+0x4b/0x90
>  [<c0135a25>] release_console_sem+0xc5/0x1f0
>  [<c0135f0b>] vprintk+0x1ab/0x3e0
>  [<c013615b>] printk+0x1b/0x20
>  [<c0349736>] mii_check_media+0x196/0x1e0
>  [<c03597f4>] rtl_check_media+0x24/0x30
>  [<c035a0ea>] rtl8139_interrupt+0x42a/0x4a0 <-- spin_lock(&tp->lock)
>  [<c01716d8>] handle_IRQ_event+0x28/0x70
>  [<c0172d9b>] handle_fasteoi_irq+0x6b/0xe0
>  [<c0107128>] do_IRQ+0x48/0xa0
> 
> The least invasive fix is to detect that we're trying to re-enter the
> driver code. We provide a netdev_busy() function which can be used to
> determine whether a deadlock can occur if we try to transmit another
> packet.
> 
> Note that this may lead to lost messages if the driver is active on
> another CPU while we try to use the same device for netconsole.

This sucks.

> It would probably be best to set a "lost messages" flag in this case and
> add it to the stream when the device becomes ready again.
> 
> The only extra overhead in non-netconsole code paths is the fact that we
> need another callback in struct net_device. However, all drivers must be
> checked for the possibility of a deadlock and implement the ->busy()
> callback as necessary.

> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -979,6 +980,7 @@ static int __devinit rtl8139_init_one (struct pci_dev *pdev,
>  	/* The Rtl8139-specific entries in the device structure. */
>  	dev->open = rtl8139_open;
>  	dev->hard_start_xmit = rtl8139_start_xmit;
> +	dev->busy = rtl8139_busy;
>  	netif_napi_add(dev, &tp->napi, rtl8139_poll, 64);
>  	dev->stop = rtl8139_close;
>  	dev->get_stats = rtl8139_get_stats;
> @@ -1741,6 +1743,11 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
>  	return 0;
>  }
>  
> +static bool rtl8139_busy (struct net_device *dev)
> +{
> +	struct rtl8139_private *tp = netdev_priv(dev);
> +	return spin_is_locked(&tp->lock);
> +}

How do I know if my driver is suspectible to this sort of deadlock?


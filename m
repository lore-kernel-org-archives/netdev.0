From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [PATCH] Updated 8139too with NAPI
Date: Thu, 13 Nov 2003 00:41:34 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <87d6bx4ms1.fsf@devron.myhome.or.jp>
References: <3F9070B6.9090306@pobox.com> <873cdqbt6z.fsf@devron.myhome.or.jp>
	<20031020131106.6862e951.shemminger@osdl.org>
	<877k2ysohc.fsf@devron.myhome.or.jp>
	<20031028114707.1d234da6.shemminger@osdl.org>
	<3FA01629.2080202@pobox.com> <873cdaabue.fsf@devron.myhome.or.jp>
	<20031030104943.20b61af0.shemminger@osdl.org>
	<87ekwu9tn4.fsf@devron.myhome.or.jp>
	<20031111143143.794909e8.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031111143143.794909e8.shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> @@ -1663,6 +1678,8 @@
>  	/* Disable interrupts by clearing the interrupt mask. */
>  	RTL_W16 (IntrMask, 0x0000);
>  
> +	__netif_poll_disable(dev);

Rx-poll can enable interrupt. However, because it can happen on SMP
only, then reset of chips should be done sooner or later, so I don't
care so much.

> +		/*
> +		 * This order is important
> +		 * (see Documentation/networking/NAPI_HOWTO.txt)
> +		 */
> +		netif_rx_complete(dev);
> +		RTL_W16_F(IntrMask, rtl8139_intr_mask);

    netif_rx_complete(dev);
    -- interrupted --
	in rtl8139_interrupt(),
		if (netif_rx_schedule_prep(dev)) {
			RTL_W16_F (IntrMask, rtl8139_norx_intr_mask);
			__netif_rx_schedule (dev);
		}
    -- resume --
    /* enable interrupt, but rx-poll is already scheduling */
    RTL_W16_F(IntrMask, rtl8139_intr_mask);

So doesn't disable interrupt. Umm... this problem was things that my
patch fixed. Any objections?

		local_irq_disable();
		__netif_rx_complete(dev);
		RTL_W16_F(IntrMask, rtl8139_intr_mask);
		local_irq_enable();
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>

From: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
Subject: Re: [Fwd: [RFT] NAPI for 8139too]
Date: Sat, 18 Oct 2003 21:56:20 +0900
Sender: netdev-bounce@oss.sgi.com
Message-ID: <873cdqbt6z.fsf@devron.myhome.or.jp>
References: <3F9070B6.9090306@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <3F9070B6.9090306@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

--=-=-=

Hi,

I also working for it (patches attached). So I have several comment.

Jeff Garzik <jgarzik@pobox.com> writes:

> +	dev->weight = 16;

just question: Is there basis for believing that this value is
rightness?  Although I use 64, I don't have a reason for having chosen
it at all.

>  	dev->stop = rtl8139_close;
>  	dev->get_stats = rtl8139_get_stats;
>  	dev->set_multicast_list = rtl8139_set_rx_mode;
> @@ -1879,24 +1877,28 @@
>  #endif
>  }
>  
> -static void rtl8139_rx_interrupt (struct net_device *dev,
> -				  struct rtl8139_private *tp, void *ioaddr)
> +/*
> + * NAPI poll routine.
> + */
> +static int rtl8139_poll(struct net_device *dev, int *budget)
>  {
> +	struct rtl8139_private *tp = dev->priv;
> +	void *ioaddr = tp->mmio_addr;
>  	unsigned char *rx_ring;
>  	u16 cur_rx;
> +	int rx, status;
> +	unsigned long flags;
>  
> -	assert (dev != NULL);
> -	assert (tp != NULL);
> -	assert (ioaddr != NULL);
> -
> +	spin_lock_irqsave(&tp->lock, flags);

I don't think lock of interrupt related path needed here. And this
thinks that it has a bad influence on TX path.

Instead of it, I think we need synchronize with ->tx_timeout because
->tx_timeout touch IntrMask.

> + rescan:
>  	rx_ring = tp->rx_ring;
>  	cur_rx = tp->cur_rx;
> -
[...]
>  			RTL_W16_F (IntrStatus, RxAckBits);
> +
> +		if (++rx >= dev->quota)

Shouldn't we use "min(dev->quota, *budget)" for this limit? Users can
change "budget" via sysctl.

> +	/* If received interrupt, then disable furthur interrupts
> +	 * and enable NAPI polling.
> +	 */
> +	if (netif_running (dev) && (status & RxAckBits)) {
> +		/* disable more receive interrupts */
> +		RTL_W16 (IntrMask, rtl8139_intr_mask & ~RxAckBits);
> +		netif_rx_schedule(dev);
> +	}

This style have problem on shutdowning interface path. Please see
8139too-napi-stop-fix.patch.

Thanks.
-- 
OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>


--=-=-=
Content-Type: application/octet-stream
Content-Disposition: attachment; filename=8139too.tar.gz
Content-Transfer-Encoding: base64

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
--=-=-=--

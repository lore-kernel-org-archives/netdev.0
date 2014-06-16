From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 1/2] slip: Fix deadlock in write_wakeup
Date: Mon, 16 Jun 2014 19:55:04 +0200
Message-ID: <539F2F78.40502@hartkopp.net>
References: <1402885397-21062-1-git-send-email-tylerwhall@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Tyler Hall <tylerwhall@gmail.com>,
	Andre Naujoks <nautsch2@gmail.com>,
	Alexander Stein <alexander.stein@systec-electronic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.218]:13429 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752171AbaFPRzO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2014 13:55:14 -0400
In-Reply-To: <1402885397-21062-1-git-send-email-tylerwhall@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Tyler,

On 16.06.2014 04:23, Tyler Hall wrote:
> Use schedule_work() to avoid potentially taking the spinlock in
> interrupt context.
> 
(..)

> 
> To deal with these issues, don't grab the lock in the wakeup function by
> deferring the writeout to a workqueue. Also hold the lock during close
> when de-assigning the tty pointer to safely disarm the worker and
> timers.
> 
> This bug is easily reproducible on the first transmit when slip is
> used with the standard 8250 serial driver.
> 

looks reasonable. Thanks for your patch!
Indeed I can't remember ever using the slcan driver with a real serial
controller hardware with irq line but only via serial-to-USB adapters :-)
Due to the recent fixes from Andre and Alexander these two drivers got in
motion again ...

@Andre/Alexander: Can you please check if slcan still works in your setup. I
don't have that hardware with me. I only was able to compile it successfully.

Just for the records: These two patches would be candidates for stable 3.12+

Thanks,
Oliver


> [<c0410b7c>] (spin_bug+0x0/0x38) from [<c006109c>] (do_raw_spin_lock+0x60/0x1d0)
>  r5:eab27000 r4:ec02754c
> [<c006103c>] (do_raw_spin_lock+0x0/0x1d0) from [<c04185c0>] (_raw_spin_lock+0x28/0x2c)
>  r10:0000001f r9:eabb814c r8:eabb8140 r7:40070193 r6:ec02754c r5:eab27000
>  r4:ec02754c r3:00000000
> [<c0418598>] (_raw_spin_lock+0x0/0x2c) from [<bf3a0220>] (slip_write_wakeup+0x50/0xe0 [slip])
>  r4:ec027540 r3:00000003
> [<bf3a01d0>] (slip_write_wakeup+0x0/0xe0 [slip]) from [<c026e420>] (tty_wakeup+0x48/0x68)
>  r6:00000000 r5:ea80c480 r4:eab27000 r3:bf3a01d0
> [<c026e3d8>] (tty_wakeup+0x0/0x68) from [<c028a8ec>] (uart_write_wakeup+0x2c/0x30)
>  r5:ed68ea90 r4:c06790d8
> [<c028a8c0>] (uart_write_wakeup+0x0/0x30) from [<c028dc44>] (serial8250_tx_chars+0x114/0x170)
> [<c028db30>] (serial8250_tx_chars+0x0/0x170) from [<c028dffc>] (serial8250_handle_irq+0xa0/0xbc)
>  r6:000000c2 r5:00000060 r4:c06790d8 r3:00000000
> [<c028df5c>] (serial8250_handle_irq+0x0/0xbc) from [<c02933a4>] (dw8250_handle_irq+0x38/0x64)
>  r7:00000000 r6:edd2f390 r5:000000c2 r4:c06790d8
> [<c029336c>] (dw8250_handle_irq+0x0/0x64) from [<c028d2f4>] (serial8250_interrupt+0x44/0xc4)
>  r6:00000000 r5:00000000 r4:c06791c4 r3:c029336c
> [<c028d2b0>] (serial8250_interrupt+0x0/0xc4) from [<c0067fe4>] (handle_irq_event_percpu+0xb4/0x2b0)
>  r10:c06790d8 r9:eab27000 r8:00000000 r7:00000000 r6:0000001f r5:edd52980
>  r4:ec53b6c0 r3:c028d2b0
> [<c0067f30>] (handle_irq_event_percpu+0x0/0x2b0) from [<c006822c>] (handle_irq_event+0x4c/0x6c)
>  r10:c06790d8 r9:eab27000 r8:c0673ae0 r7:c05c2020 r6:ec53b6c0 r5:edd529d4
>  r4:edd52980
> [<c00681e0>] (handle_irq_event+0x0/0x6c) from [<c006b140>] (handle_level_irq+0xe8/0x100)
>  r6:00000000 r5:edd529d4 r4:edd52980 r3:00022000
> [<c006b058>] (handle_level_irq+0x0/0x100) from [<c00676f8>] (generic_handle_irq+0x30/0x40)
>  r5:0000001f r4:0000001f
> [<c00676c8>] (generic_handle_irq+0x0/0x40) from [<c000f57c>] (handle_IRQ+0xd0/0x13c)
>  r4:ea997b18 r3:000000e0
> [<c000f4ac>] (handle_IRQ+0x0/0x13c) from [<c00086c4>] (armada_370_xp_handle_irq+0x4c/0x118)
>  r8:000003ff r7:ea997b18 r6:ffffffff r5:60070013 r4:c0674dc0
> [<c0008678>] (armada_370_xp_handle_irq+0x0/0x118) from [<c0013840>] (__irq_svc+0x40/0x70)
> Exception stack(0xea997b18 to 0xea997b60)
> 7b00:                                                       00000001 20070013
> 7b20: 00000000 0000000b 20070013 eab27000 20070013 00000000 ed10103e eab27000
> 7b40: c06790d8 ea997b74 ea997b60 ea997b60 c04186c0 c04186c8 60070013 ffffffff
>  r9:eab27000 r8:ed10103e r7:ea997b4c r6:ffffffff r5:60070013 r4:c04186c8
> [<c04186a4>] (_raw_spin_unlock_irqrestore+0x0/0x54) from [<c0288fc0>] (uart_start+0x40/0x44)
>  r4:c06790d8 r3:c028ddd8
> [<c0288f80>] (uart_start+0x0/0x44) from [<c028982c>] (uart_write+0xe4/0xf4)
>  r6:0000003e r5:00000000 r4:ed68ea90 r3:0000003e
> [<c0289748>] (uart_write+0x0/0xf4) from [<bf3a0d20>] (sl_xmit+0x1c4/0x228 [slip])
>  r10:ed388e60 r9:0000003c r8:ffffffdd r7:0000003e r6:ec02754c r5:ea717eb8
>  r4:ec027000
> [<bf3a0b5c>] (sl_xmit+0x0/0x228 [slip]) from [<c0368d74>] (dev_hard_start_xmit+0x39c/0x6d0)
>  r8:eaf163c0 r7:ec027000 r6:ea717eb8 r5:00000000 r4:00000000
> 
> Signed-off-by: Tyler Hall <tylerwhall@gmail.com>
> Cc: Oliver Hartkopp <socketcan@hartkopp.net>
> Cc: Andre Naujoks <nautsch2@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/slip/slip.c | 36 ++++++++++++++++++++++++++----------
>  drivers/net/slip/slip.h |  1 +
>  2 files changed, 27 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
> index ad4a94e..8752644 100644
> --- a/drivers/net/slip/slip.c
> +++ b/drivers/net/slip/slip.c
> @@ -83,6 +83,7 @@
>  #include <linux/delay.h>
>  #include <linux/init.h>
>  #include <linux/slab.h>
> +#include <linux/workqueue.h>
>  #include "slip.h"
>  #ifdef CONFIG_INET
>  #include <linux/ip.h>
> @@ -416,36 +417,46 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
>  #endif
>  }
>  
> -/*
> - * Called by the driver when there's room for more data.  If we have
> - * more packets to send, we send them here.
> - */
> -static void slip_write_wakeup(struct tty_struct *tty)
> +/* Write out any remaining transmit buffer. Scheduled when tty is writable */
> +static void slip_transmit(struct work_struct *work)
>  {
> +	struct slip *sl = container_of(work, struct slip, tx_work);
>  	int actual;
> -	struct slip *sl = tty->disc_data;
>  
> +	spin_lock_bh(&sl->lock);
>  	/* First make sure we're connected. */
> -	if (!sl || sl->magic != SLIP_MAGIC || !netif_running(sl->dev))
> +	if (!sl->tty || sl->magic != SLIP_MAGIC || !netif_running(sl->dev)) {
> +		spin_unlock_bh(&sl->lock);
>  		return;
> +	}
>  
> -	spin_lock_bh(&sl->lock);
>  	if (sl->xleft <= 0)  {
>  		/* Now serial buffer is almost free & we can start
>  		 * transmission of another packet */
>  		sl->dev->stats.tx_packets++;
> -		clear_bit(TTY_DO_WRITE_WAKEUP, &tty->flags);
> +		clear_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
>  		spin_unlock_bh(&sl->lock);
>  		sl_unlock(sl);
>  		return;
>  	}
>  
> -	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
> +	actual = sl->tty->ops->write(sl->tty, sl->xhead, sl->xleft);
>  	sl->xleft -= actual;
>  	sl->xhead += actual;
>  	spin_unlock_bh(&sl->lock);
>  }
>  
> +/*
> + * Called by the driver when there's room for more data.
> + * Schedule the transmit.
> + */
> +static void slip_write_wakeup(struct tty_struct *tty)
> +{
> +	struct slip *sl = tty->disc_data;
> +
> +	schedule_work(&sl->tx_work);
> +}
> +
>  static void sl_tx_timeout(struct net_device *dev)
>  {
>  	struct slip *sl = netdev_priv(dev);
> @@ -749,6 +760,7 @@ static struct slip *sl_alloc(dev_t line)
>  	sl->magic       = SLIP_MAGIC;
>  	sl->dev	      	= dev;
>  	spin_lock_init(&sl->lock);
> +	INIT_WORK(&sl->tx_work, slip_transmit);
>  	sl->mode        = SL_MODE_DEFAULT;
>  #ifdef CONFIG_SLIP_SMART
>  	/* initialize timer_list struct */
> @@ -872,8 +884,12 @@ static void slip_close(struct tty_struct *tty)
>  	if (!sl || sl->magic != SLIP_MAGIC || sl->tty != tty)
>  		return;
>  
> +	spin_lock_bh(&sl->lock);
>  	tty->disc_data = NULL;
>  	sl->tty = NULL;
> +	spin_unlock_bh(&sl->lock);
> +
> +	flush_work(&sl->tx_work);
>  
>  	/* VSV = very important to remove timers */
>  #ifdef CONFIG_SLIP_SMART
> diff --git a/drivers/net/slip/slip.h b/drivers/net/slip/slip.h
> index 67673cf..cf32aad 100644
> --- a/drivers/net/slip/slip.h
> +++ b/drivers/net/slip/slip.h
> @@ -53,6 +53,7 @@ struct slip {
>    struct tty_struct	*tty;		/* ptr to TTY structure		*/
>    struct net_device	*dev;		/* easy for intr handling	*/
>    spinlock_t		lock;
> +  struct work_struct	tx_work;	/* Flushes transmit buffer	*/
>  
>  #ifdef SL_INCLUDE_CSLIP
>    struct slcompress	*slcomp;	/* for header compression 	*/
> 

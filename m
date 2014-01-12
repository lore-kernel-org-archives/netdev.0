From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 3/5] net: mvneta: do not schedule in mvneta_tx_timeout
Date: Sun, 12 Jan 2014 16:49:51 +0000
Message-ID: <1389545391.3720.56.camel@deadeye.wl.decadent.org.uk>
References: <1389519069-1619-1-git-send-email-w@1wt.eu>
	 <1389519069-1619-4-git-send-email-w@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory CLEMENT <gregory.clement@free-electrons.com>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:40992 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaALQtz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jan 2014 11:49:55 -0500
In-Reply-To: <1389519069-1619-4-git-send-email-w@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-12 at 10:31 +0100, Willy Tarreau wrote:
> If a queue timeout is reported, we can oops because of some
> schedules while the caller is atomic, as shown below :
> 
>   mvneta d0070000.ethernet eth0: tx timeout
>   BUG: scheduling while atomic: bash/1528/0x00000100
>   Modules linked in: slhttp_ethdiv(C) [last unloaded: slhttp_ethdiv]
>   CPU: 2 PID: 1528 Comm: bash Tainted: G        WC   3.13.0-rc4-mvebu-nf #180
>   [<c0011bd9>] (unwind_backtrace+0x1/0x98) from [<c000f1ab>] (show_stack+0xb/0xc)
>   [<c000f1ab>] (show_stack+0xb/0xc) from [<c02ad323>] (dump_stack+0x4f/0x64)
>   [<c02ad323>] (dump_stack+0x4f/0x64) from [<c02abe67>] (__schedule_bug+0x37/0x4c)
>   [<c02abe67>] (__schedule_bug+0x37/0x4c) from [<c02ae261>] (__schedule+0x325/0x3ec)
>   [<c02ae261>] (__schedule+0x325/0x3ec) from [<c02adb97>] (schedule_timeout+0xb7/0x118)
>   [<c02adb97>] (schedule_timeout+0xb7/0x118) from [<c0020a67>] (msleep+0xf/0x14)
>   [<c0020a67>] (msleep+0xf/0x14) from [<c01dcbe5>] (mvneta_stop_dev+0x21/0x194)
>   [<c01dcbe5>] (mvneta_stop_dev+0x21/0x194) from [<c01dcfe9>] (mvneta_tx_timeout+0x19/0x24)
>   [<c01dcfe9>] (mvneta_tx_timeout+0x19/0x24) from [<c024afc7>] (dev_watchdog+0x18b/0x1c4)
>   [<c024afc7>] (dev_watchdog+0x18b/0x1c4) from [<c0020b53>] (call_timer_fn.isra.27+0x17/0x5c)
>   [<c0020b53>] (call_timer_fn.isra.27+0x17/0x5c) from [<c0020cad>] (run_timer_softirq+0x115/0x170)
>   [<c0020cad>] (run_timer_softirq+0x115/0x170) from [<c001ccb9>] (__do_softirq+0xbd/0x1a8)
>   [<c001ccb9>] (__do_softirq+0xbd/0x1a8) from [<c001cfad>] (irq_exit+0x61/0x98)
>   [<c001cfad>] (irq_exit+0x61/0x98) from [<c000d4bf>] (handle_IRQ+0x27/0x60)
>   [<c000d4bf>] (handle_IRQ+0x27/0x60) from [<c000843b>] (armada_370_xp_handle_irq+0x33/0xc8)
>   [<c000843b>] (armada_370_xp_handle_irq+0x33/0xc8) from [<c000fba9>] (__irq_usr+0x49/0x60)
> 
> So for now, let's simply ignore these timeouts generally caused by bugs
> only.

No, don't ignore them.  Schedule a work item to reset the device.  (And
remember to cancel it when stopping the device.)

Ben.

> Cc: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Cc: Gregory CLEMENT <gregory.clement@free-electrons.com>
> Signed-off-by: Willy Tarreau <w@1wt.eu>
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 11 -----------
>  1 file changed, 11 deletions(-)
> 
> diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
> index 40d3e8b..84220c1 100644
> --- a/drivers/net/ethernet/marvell/mvneta.c
> +++ b/drivers/net/ethernet/marvell/mvneta.c
> @@ -2244,16 +2244,6 @@ static void mvneta_stop_dev(struct mvneta_port *pp)
>  	mvneta_rx_reset(pp);
>  }
>  
> -/* tx timeout callback - display a message and stop/start the network device */
> -static void mvneta_tx_timeout(struct net_device *dev)
> -{
> -	struct mvneta_port *pp = netdev_priv(dev);
> -
> -	netdev_info(dev, "tx timeout\n");
> -	mvneta_stop_dev(pp);
> -	mvneta_start_dev(pp);
> -}
> -
>  /* Return positive if MTU is valid */
>  static int mvneta_check_mtu_valid(struct net_device *dev, int mtu)
>  {
> @@ -2634,7 +2624,6 @@ static const struct net_device_ops mvneta_netdev_ops = {
>  	.ndo_set_rx_mode     = mvneta_set_rx_mode,
>  	.ndo_set_mac_address = mvneta_set_mac_addr,
>  	.ndo_change_mtu      = mvneta_change_mtu,
> -	.ndo_tx_timeout      = mvneta_tx_timeout,
>  	.ndo_get_stats64     = mvneta_get_stats64,
>  	.ndo_do_ioctl        = mvneta_ioctl,
>  };

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3] sis900: Fix the tx queue timeout issue
Date: Fri, 2 Aug 2013 21:18:55 +0200
Message-ID: <1375471135.32254.15.camel@deadeye.wl.decadent.org.uk>
References: <1375437054-1995-1-git-send-email-kda@linux-powerpc.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <venza@brownhat.org>,
	<B38611@freescale.com>, <netdev@vger.kernel.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:58460 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755760Ab3HBTTB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Aug 2013 15:19:01 -0400
In-Reply-To: <1375437054-1995-1-git-send-email-kda@linux-powerpc.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-08-02 at 13:50 +0400, Denis Kirjanov wrote:
> [  198.720048] ------------[ cut here ]------------
> [  198.720108] WARNING: CPU: 0 PID: 0 at net/sched/sch_generic.c:255 dev_watchdog+0x229/0x240()
> [  198.720118] NETDEV WATCHDOG: eth0 (sis900): transmit queue 0 timed out
> [  198.720125] Modules linked in: bridge stp llc dmfe sundance 3c59x sis900 mii
> [  198.720159] CPU: 0 PID: 0 Comm: swapper Not tainted 3.11.0-rc3+ #12
> [  198.720167] Hardware name: System Manufacturer System Name/TUSI-M, BIOS ASUS TUSI-M ACPI BIOS
> Revision 1013 Beta 001 12/14/2001
> [  198.720175]  000000ff c13fa6b9 c169ddcc c12208d6 c169ddf8 c1031e4d c1664a84 c169de24
> [  198.720197]  00000000 c165f5ea 000000ff c13fa6b9 00000001 000000ff c1664a84 c169de10
> [  198.720217]  c1031f13 00000009 c169de08 c1664a84 c169de24 c169de50 c13fa6b9 c165f5ea
> [  198.720240] Call Trace:
> [  198.720257]  [<c13fa6b9>] ? dev_watchdog+0x229/0x240
> [  198.720274]  [<c12208d6>] dump_stack+0x16/0x20
> [  198.720306]  [<c1031e4d>] warn_slowpath_common+0x7d/0xa0
> [  198.720318]  [<c13fa6b9>] ? dev_watchdog+0x229/0x240
> [  198.720330]  [<c1031f13>] warn_slowpath_fmt+0x33/0x40
> [  198.720342]  [<c13fa6b9>] dev_watchdog+0x229/0x240
> [  198.720357]  [<c103f158>] call_timer_fn+0x78/0x150
> [  198.720369]  [<c103f0e0>] ? internal_add_timer+0x40/0x40
> [  198.720381]  [<c13fa490>] ? dev_init_scheduler+0xa0/0xa0
> [  198.720392]  [<c103f33f>] run_timer_softirq+0x10f/0x200
> [  198.720412]  [<c103954f>] ? __do_softirq+0x6f/0x210
> [  198.720424]  [<c13fa490>] ? dev_init_scheduler+0xa0/0xa0
> [  198.720435]  [<c1039598>] __do_softirq+0xb8/0x210
> [  198.720467]  [<c14b54d2>] ? _raw_spin_unlock+0x22/0x30
> [  198.720484]  [<c1003245>] ? handle_irq+0x25/0xd0
> [  198.720496]  [<c1039c0c>] irq_exit+0x9c/0xb0
> [  198.720508]  [<c14bc9d7>] do_IRQ+0x47/0x94
> [  198.720534]  [<c1056078>] ? hrtimer_start+0x28/0x30
> [  198.720564]  [<c14bc8b1>] common_interrupt+0x31/0x38
> [  198.720589]  [<c1008692>] ? default_idle+0x22/0xa0
> [  198.720600]  [<c10083c7>] arch_cpu_idle+0x17/0x30
> [  198.720631]  [<c106d23d>] cpu_startup_entry+0xcd/0x180
> [  198.720643]  [<c14ae30a>] rest_init+0xaa/0xb0
> [  198.720654]  [<c14ae260>] ? reciprocal_value+0x50/0x50
> [  198.720668]  [<c17044e0>] ? repair_env_string+0x60/0x60
> [  198.720679]  [<c1704bda>] start_kernel+0x29a/0x350
> [  198.720690]  [<c17044e0>] ? repair_env_string+0x60/0x60
> [  198.720721]  [<c1704269>] i386_start_kernel+0x39/0xa0
> [  198.720729] ---[ end trace 81e0a6266f5c73a8 ]---
> [  198.720740] eth0: Transmit timeout, status 00000204 00000000
> 
> timer routine checks the link status and if it's up calls
> netif_carrier_on() allowing upper layer to start the tx queue
> even if the auto-negotiation process is not finished.
> 
> Also remove ugly auto-negotiation check from the sis900_start_xmit()
> 
> CC: Duan Fugang <B38611@freescale.com>
> CC: Ben Hutchings <bhutchings@solarflare.com>
> 
> Signed-off-by: Denis Kirjanov <kda@linux-powerpc.org>
> ---
> v1->v2: use netdev_dbg() instead of printk()
> v2->v3:
>  handle link change from timer,
>  remove auto-negotiation check from xmit path

This looks reasonable.  It looks like link changes now work like this:

1. When sis900_timer() detects link-down, it calls netif_carrier_off()
but does not clear autong_complete.
2. When sis900_timer() detects link-up, it calls sis900_check_mode()
which restarts autonegotiation and clears autong_complete.
3. sis900_timer() will now call sis900_read_mode().  When that detects
link-up, it sets autong_complete and calls netif_carrier_on().

This patch has moved the call to netif_carrier_on() from step 2 to step
3.  However, I don't understand why autonegotiation is restarted in step
2.  When autonegotiation is enabled, the PHY should not indicate link-up
until it has completed.  Perhaps this is a necessary workaround for a
hardware bug.  Otherwise it's a waste of time.

Ben.

> ---
>  drivers/net/ethernet/sis/sis900.c | 12 ++----------
>  1 file changed, 2 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/sis/sis900.c b/drivers/net/ethernet/sis/sis900.c
> index eb4aea3..f5d7ad7 100644
> --- a/drivers/net/ethernet/sis/sis900.c
> +++ b/drivers/net/ethernet/sis/sis900.c
> @@ -1318,7 +1318,7 @@ static void sis900_timer(unsigned long data)
>  		if (duplex){
>  			sis900_set_mode(sis_priv, speed, duplex);
>  			sis630_set_eq(net_dev, sis_priv->chipset_rev);
> -			netif_start_queue(net_dev);
> +			netif_carrier_on(net_dev);
>  		}
>  
>  		sis_priv->timer.expires = jiffies + HZ;
> @@ -1336,10 +1336,8 @@ static void sis900_timer(unsigned long data)
>  		status = sis900_default_phy(net_dev);
>  		mii_phy = sis_priv->mii;
>  
> -		if (status & MII_STAT_LINK){
> +		if (status & MII_STAT_LINK)
>  			sis900_check_mode(net_dev, mii_phy);
> -			netif_carrier_on(net_dev);
> -		}
>  	} else {
>  	/* Link ON -> OFF */
>                  if (!(status & MII_STAT_LINK)){
> @@ -1612,12 +1610,6 @@ sis900_start_xmit(struct sk_buff *skb, struct net_device *net_dev)
>  	unsigned int  index_cur_tx, index_dirty_tx;
>  	unsigned int  count_dirty_tx;
>  
> -	/* Don't transmit data before the complete of auto-negotiation */
> -	if(!sis_priv->autong_complete){
> -		netif_stop_queue(net_dev);
> -		return NETDEV_TX_BUSY;
> -	}
> -
>  	spin_lock_irqsave(&sis_priv->lock, flags);
>  
>  	/* Calculate the next Tx descriptor entry. */

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

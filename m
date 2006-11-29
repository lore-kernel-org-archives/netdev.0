From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow
 interrupt handler to disable receive interrupts at high bi-directional
 traffic
Date: Wed, 29 Nov 2006 12:24:44 -0800
Message-ID: <20061129122444.0614cf56@freekitty>
References: <010C7BAE6783F34D9AC336EE5A01A08802D2D762@dbde01.ent.ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:34209 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S967633AbWK2UZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 15:25:06 -0500
To: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>
In-Reply-To: <010C7BAE6783F34D9AC336EE5A01A08802D2D762@dbde01.ent.ti.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006 14:20:31 +0530
"Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com> wrote:

> Francois Romieu [mailto:romieu@fr.zoreil.com] wrote:
> 
> > Afaics your change may disable the Rx irq right after the poll routine
> 
> > enabled it again. It will not always work either.
> > 
> > The (slow) timeout watchdog could grab the poll handler and hack the 
> > irq mask depending on whether poll was scheduled or not.
> 
> Could you please confirm whether the attached patch would work?
> I tested it and it works for me.
> 
> 
> Signed-off-by: Mansoor Ahamed <mansoor.ahamed@ti.com>
> 
> --- old/8139too.c	2006-11-14 10:44:27.000000000 +0530
> +++ new/8139too.c	2006-11-14 10:44:18.000000000 +0530
> @@ -1438,8 +1438,18 @@
>  	if ((!(tmp & CmdRxEnb)) || (!(tmp & CmdTxEnb)))
>  		RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
>  
> -	/* Enable all known interrupts by setting the interrupt mask. */
> -	RTL_W16 (IntrMask, rtl8139_intr_mask);
> +	local_irq_disable();
> +	/* Don't enable RX if RX was already scheduled */
> +	if(test_bit(__LINK_STATE_START, &dev->state) &&
> +			test_bit(__LINK_STATE_RX_SCHED, &dev->state) ) {
> +		/* Enable all interrupts except RX by setting the
> interrupt mask. */
> +		RTL_W16 (IntrMask, rtl8139_norx_intr_mask);
> +	}
> +	else {
> +		/* Enable all known interrupts by setting the interrupt
> mask. */ 
> +		RTL_W16 (IntrMask, rtl8139_intr_mask);
> +	}
> +	local_irq_enable();
>  }

Sorry, that's not the right way. Testing for bits is not
SMP safe and is usually a bad idea. The rx_lock model is not the
best way. Try something like this:

--- a/drivers/net/8139too.c.orig	2006-11-29 12:22:32.000000000 -0800
+++ b/drivers/net/8139too.c	2006-11-29 12:22:06.000000000 -0800
@@ -589,7 +589,6 @@ struct rtl8139_private {
 	unsigned int default_port : 4;	/* Last dev->if_port value. */
 	unsigned int have_thread : 1;
 	spinlock_t lock;
-	spinlock_t rx_lock;
 	chip_t chipset;
 	u32 rx_config;
 	struct rtl_extra_stats xstats;
@@ -1009,7 +1008,6 @@ static int __devinit rtl8139_init_one (s
 	tp->msg_enable =
 		(debug < 0 ? RTL8139_DEF_MSG_ENABLE : ((1 << debug) - 1));
 	spin_lock_init (&tp->lock);
-	spin_lock_init (&tp->rx_lock);
 	INIT_WORK(&tp->thread, rtl8139_thread, dev);
 	tp->mii.dev = dev;
 	tp->mii.mdio_read = mdio_read;
@@ -1654,6 +1652,9 @@ static void rtl8139_tx_timeout_task (voi
 	int i;
 	u8 tmp8;
 
+	if (!netif_running(dev))
+		return;
+
 	printk (KERN_DEBUG "%s: Transmit timeout, status %2.2x %4.4x %4.4x "
 		"media %2.2x.\n", dev->name, RTL_R8 (ChipCmd),
 		RTL_R16(IntrStatus), RTL_R16(IntrMask), RTL_R8(MediaStatus));
@@ -1673,7 +1674,9 @@ static void rtl8139_tx_timeout_task (voi
 	if (tmp8 & CmdTxEnb)
 		RTL_W8 (ChipCmd, CmdRxEnb);
 
-	spin_lock_bh(&tp->rx_lock);
+	/* prevent NAPI poll from running */
+	netif_poll_disable();
+
 	/* Disable interrupts by clearing the interrupt mask. */
 	RTL_W16 (IntrMask, 0x0000);
 
@@ -1682,12 +1685,11 @@ static void rtl8139_tx_timeout_task (voi
 	rtl8139_tx_clear (tp);
 	spin_unlock_irq(&tp->lock);
 
+	netif_poll_enable();
+
 	/* ...and finally, reset everything */
-	if (netif_running(dev)) {
-		rtl8139_hw_start (dev);
-		netif_wake_queue (dev);
-	}
-	spin_unlock_bh(&tp->rx_lock);
+	rtl8139_hw_start (dev);
+	netif_wake_queue (dev);
 }
 
 static void rtl8139_tx_timeout (struct net_device *dev)
@@ -2116,7 +2118,6 @@ static int rtl8139_poll(struct net_devic
 	int orig_budget = min(*budget, dev->quota);
 	int done = 1;
 
-	spin_lock(&tp->rx_lock);
 	if (likely(RTL_R16(IntrStatus) & RxAckBits)) {
 		int work_done;
 
@@ -2138,7 +2139,6 @@ static int rtl8139_poll(struct net_devic
 		__netif_rx_complete(dev);
 		local_irq_enable();
 	}
-	spin_unlock(&tp->rx_lock);
 
 	return !done;
 }

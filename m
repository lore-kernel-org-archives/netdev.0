From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow
 interrupt handler to disable receive interrupts at high bi-directional
 traffic
Date: Wed, 29 Nov 2006 16:09:06 -0800
Message-ID: <20061129160906.695b4d03@freekitty>
References: <010C7BAE6783F34D9AC336EE5A01A08802D2D762@dbde01.ent.ti.com>
	<20061129122444.0614cf56@freekitty>
	<20061129224400.GC18057@electric-eye.fr.zoreil.com>
	<20061129145054.741ad7c5@freekitty>
	<20061129233219.GD18057@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:38381 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S967698AbWK3AJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 19:09:36 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061129233219.GD18057@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 30 Nov 2006 00:32:19 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> > Francois Romieu <romieu@fr.zoreil.com> wrote:
> > > Stephen Hemminger <shemminger@osdl.org> :
> > > [...]
> > > > @@ -1682,12 +1685,11 @@ static void rtl8139_tx_timeout_task (voi
> > > >  	rtl8139_tx_clear (tp);
> > > >  	spin_unlock_irq(&tp->lock);
> > > >  
> > > > +	netif_poll_enable();
> > >                           ^ -> dev
> > > > +
> > > >  	/* ...and finally, reset everything */
> > > > -	if (netif_running(dev)) {
> > > > -		rtl8139_hw_start (dev);
> > > > -		netif_wake_queue (dev);
> > > > -	}
> > > > -	spin_unlock_bh(&tp->rx_lock);
> > > > +	rtl8139_hw_start (dev);
> > > > +	netif_wake_queue (dev);
> > > >  }
> > > 
> > > rtl8139_hw_start() may mess with cur_rx, whence a race with rtl8139_rx()
> > > if an in-flight interruption enables it a bit too fast. I'd rather go
> > > with:
> > 
> > but rt8139_rx is not possible here because we have blocked the poll
> > routine from starting.  Basically it uses the NAPI rx scheduler bit
> > to replace the rx_lock.
> 
> 1 - the irq handler is waiting for tp->lock
> 2 - rtl8139_tx_timeout_task releases the lock
> 3 - rtl8139_tx_timeout_task issues netif_poll_enable
> 4 - the irq handler schedules ->poll(), returns

Move the poll_enable to after hw_start() or put it inside hw_start.
- 
Stephen Hemminger <shemminger@osdl.org>

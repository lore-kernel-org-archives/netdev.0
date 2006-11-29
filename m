From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow
 interrupt handler to disable receive interrupts at high bi-directional
 traffic
Date: Wed, 29 Nov 2006 14:50:54 -0800
Message-ID: <20061129145054.741ad7c5@freekitty>
References: <010C7BAE6783F34D9AC336EE5A01A08802D2D762@dbde01.ent.ti.com>
	<20061129122444.0614cf56@freekitty>
	<20061129224400.GC18057@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:56782 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1758917AbWK2WvW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Nov 2006 17:51:22 -0500
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20061129224400.GC18057@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 29 Nov 2006 23:44:00 +0100
Francois Romieu <romieu@fr.zoreil.com> wrote:

> Stephen Hemminger <shemminger@osdl.org> :
> [...]
> > @@ -1682,12 +1685,11 @@ static void rtl8139_tx_timeout_task (voi
> >  	rtl8139_tx_clear (tp);
> >  	spin_unlock_irq(&tp->lock);
> >  
> > +	netif_poll_enable();
>                           ^ -> dev
> > +
> >  	/* ...and finally, reset everything */
> > -	if (netif_running(dev)) {
> > -		rtl8139_hw_start (dev);
> > -		netif_wake_queue (dev);
> > -	}
> > -	spin_unlock_bh(&tp->rx_lock);
> > +	rtl8139_hw_start (dev);
> > +	netif_wake_queue (dev);
> >  }
> 
> rtl8139_hw_start() may mess with cur_rx, whence a race with rtl8139_rx()
> if an in-flight interruption enables it a bit too fast. I'd rather go
> with:

but rt8139_rx is not possible here because we have blocked the poll
routine from starting.  Basically it uses the NAPI rx scheduler bit
to replace the rx_lock.

It is totally, untested.  

-- 
Stephen Hemminger <shemminger@osdl.org>

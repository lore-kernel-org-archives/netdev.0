From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Realtek 8139 driver (8139too.c) TX Timeout doesn't allow interrupt handler to disable receive interrupts at high bi-directional traffic
Date: Wed, 29 Nov 2006 23:44:00 +0100
Message-ID: <20061129224400.GC18057@electric-eye.fr.zoreil.com>
References: <010C7BAE6783F34D9AC336EE5A01A08802D2D762@dbde01.ent.ti.com> <20061129122444.0614cf56@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Basheer, Mansoor Ahamed" <mansoor.ahamed@ti.com>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:14559 "EHLO
	fr.zoreil.com") by vger.kernel.org with ESMTP id S1758905AbWK2Wqc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Nov 2006 17:46:32 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061129122444.0614cf56@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> :
[...]
> @@ -1682,12 +1685,11 @@ static void rtl8139_tx_timeout_task (voi
>  	rtl8139_tx_clear (tp);
>  	spin_unlock_irq(&tp->lock);
>  
> +	netif_poll_enable();
                          ^ -> dev
> +
>  	/* ...and finally, reset everything */
> -	if (netif_running(dev)) {
> -		rtl8139_hw_start (dev);
> -		netif_wake_queue (dev);
> -	}
> -	spin_unlock_bh(&tp->rx_lock);
> +	rtl8139_hw_start (dev);
> +	netif_wake_queue (dev);
>  }

rtl8139_hw_start() may mess with cur_rx, whence a race with rtl8139_rx()
if an in-flight interruption enables it a bit too fast. I'd rather go
with:
[...]

	rtl8139_tx_clear (tp);

	rtl8139_hw_start (dev);
	netif_wake_queue (dev);
   
	netif_poll_enable(dev);
	spin_unlock_irq(&tp->lock);
}

Otherwise the patch is cool.

-- 
Ueimor

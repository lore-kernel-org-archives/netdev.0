From: Tommy Christensen <tommy.christensen@tpack.net>
Subject: Re: [PATCH]: was Re: LLTX and netif_stop_queue
Date: Thu, 20 Jan 2005 14:51:25 +0100
Message-ID: <1106229084.5812.40.camel@tsc-6.cph.tpack.net>
References: <5cac192f0412230110628749e3@mail.gmail.com>
	 <41CAF444.3000305@trash.net> <5cac192f04122408102129af43@mail.gmail.com>
	 <1104240717.1100.66.camel@jzny.localdomain>
	 <5cac192f0501021530672a908a@mail.gmail.com>
	 <1104764660.1048.578.camel@jzny.localdomain> <52brc68q05.fsf@topspin.com>
	 <5cac192f05010308414a25b548@mail.gmail.com> <527jmu8nbw.fsf@topspin.com>
	 <5cac192f0501030907c755135@mail.gmail.com>
	 <20050103171227.GD7370@esmail.cup.hp.com>
	 <1104812294.1085.53.camel@jzny.localdomain>
	 <20050119144711.3fdd3d93.davem@davemloft.net>
	 <20050119151853.259de49a@dxpl.pdx.osdl.net>
	 <20050119164640.6c67bdfa.davem@davemloft.net> <52r7kgu5n5.fsf@topspin.com>
	 <20050119230526.393a5184.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Roland Dreier <roland@topspin.com>, shemminger@osdl.org, hadi@cyberus.ca,
        iod00d@hp.com, eric.lemoine@gmail.com, netdev@oss.sgi.com, ak@suse.de,
        openib-general@openib.org, kaber@trash.net
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050119230526.393a5184.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2005-01-20 at 08:05, David S. Miller wrote:
> So I'm going to check this in and push upstream.  Let me know
> if folks find any other errors.

Hi Dave
Sorry to be the one with bad news.
I am in favour of this idea, but there are still issues that
need to be sorted out.

> ===== drivers/net/sungem.c 1.72 vs edited =====
> --- 1.72/drivers/net/sungem.c	2004-11-05 15:56:15 -08:00
> +++ edited/drivers/net/sungem.c	2005-01-19 22:29:14 -08:00

> @@ -932,12 +932,12 @@
>  	       readl(gp->regs + MAC_RXCFG));
>  
>  	spin_lock_irq(&gp->lock);
> -	spin_lock(&gp->tx_lock);
> +	spin_lock(&dev->xmit_lock);
>  
>  	gp->reset_task_pending = 2;
>  	schedule_work(&gp->reset_task);
>  
> -	spin_unlock(&gp->tx_lock);
> +	spin_unlock(&dev->xmit_lock);
>  	spin_unlock_irq(&gp->lock);
>  }
>  

->tx_timeout() can't take dev->xmit_lock, since dev_watchdog
already has it held.

A lot more serious is the fact that ->tx_timeout() and
->hard_start_xmit() are no longer allowed to do this:

  spin_lock_irq()
  ...
  spin_unlock_irq()

since that would leave us with irq's enabled while still
holding the xmit_lock.
This would have to be fixed for non-LLTX drivers as well.

-Tommy

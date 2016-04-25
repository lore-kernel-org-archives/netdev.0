From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 2/6] atl1c: remove private tx lock
Date: Mon, 25 Apr 2016 17:43:39 +0200
Message-ID: <20160425154339.GA17538@breakpoint.cc>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
 <1461526694-11367-3-git-send-email-fw@strlen.de>
 <20160424220529.GA29377@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jcliburn@gmail.com>,
	Chris Snook <chris.snook@gmail.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160424220529.GA29377@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com> wrote:
> Florian Westphal <fw@strlen.de> :
> [...]
> > diff --git a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> > index d0084d4..a3200ea 100644
> > --- a/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> > +++ b/drivers/net/ethernet/atheros/atl1c/atl1c_main.c
> [...]
> > @@ -2217,16 +2215,10 @@ static netdev_tx_t atl1c_xmit_frame(struct sk_buff *skb,
> >  	}
> >  
> >  	tpd_req = atl1c_cal_tpd_req(skb);
> > -	if (!spin_trylock_irqsave(&adapter->tx_lock, flags)) {
> > -		if (netif_msg_pktdata(adapter))
> > -			dev_info(&adapter->pdev->dev, "tx locked\n");
> > -		return NETDEV_TX_LOCKED;
> > -	}
> >  
> >  	if (atl1c_tpd_avail(adapter, type) < tpd_req) {
> >  		/* no enough descriptor, just stop queue */
> >  		netif_stop_queue(netdev);
> > -		spin_unlock_irqrestore(&adapter->tx_lock, flags);
> >  		return NETDEV_TX_BUSY;
> >  	}
> >
> 
> Play it safe and keep the implicit local_irq_{save / restore} call ?
> 
> It may not be needed but it will help avoiding any unexpected regression
> report pointing at the NETDEV_TX_LOCKED removal change.

I thought about that but it doesn't prevent the irq handler from
running on another CPU, so leaving it around seemed like cargo culting
to me...

I don't have an atl1c, but the atl1e in my laptop seems to work fine
with the (similar) change.

If you disagree I can respin with local_irq_save of course, but, if
'playing it safe' is main goal then its simpler to convert
spin_trylock_irqsave to spin_lock_irqsave.

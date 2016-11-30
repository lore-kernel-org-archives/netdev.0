From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 20:17:11 +0100
Message-ID: <20161130201711.2f353a76@redhat.com>
References: <20140903165943.372b897b@redhat.com>
        <20161116131609.4e5726b4@redhat.com>
        <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
        <20161116234022.2bad179b@redhat.com>
        <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117091638.5fab8494@redhat.com>
        <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117144248.23500001@redhat.com>
        <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117155753.17b76f5a@redhat.com>
        <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161117193021.580589ae@redhat.com>
        <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161121170351.50a09ee1@redhat.com>
        <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
        <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
        <20161130123810.581ba21f@redhat.com>
        <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>, brouer@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43116 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758776AbcK3TRP (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 30 Nov 2016 14:17:15 -0500
In-Reply-To: <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Nov 2016 07:56:26 -0800
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2016-11-30 at 12:38 +0100, Jesper Dangaard Brouer wrote:
> > I've played with a somewhat similar patch (from Achiad Shochat) for
> > mlx5 (attached).  While it gives huge improvements, the problem I ran
> > into was that; TX performance became a function of the TX completion
> > time/interrupt and could easily be throttled if configured too
> > high/slow.
> > 
> > Can your patch be affected by this too?  
> 
> Like all TX business, you should know this Jesper.
> No need to constantly remind us something very well known.

Don't take is as critique Eric.  I was hoping your patch would have
solved this issue of being sensitive to TX completion adjustments.  You
usually have good solutions for difficult issues. I basically rejected
Achiad's approach/patch because it was too sensitive to these kind of
adjustments.


> > On Mon, 28 Nov 2016 22:58:36 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:
[...]
> > 
> > These +75% number is pktgen without "burst", and definitely show that
> > your patch activate xmit_more.
> > What is the pps performance number when using pktgen "burst" option?  
> 
> About the same really. About all packets now get the xmit_more effect.

Perfect!

> > [...]  
> > > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > > index 4b597dca5c52..affebb435679 100644
> > > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c  
> > [...]  
> > > -static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
> > > +static inline bool mlx4_en_is_tx_ring_full(const struct mlx4_en_tx_ring *ring)
> > >  {
> > > -	return ring->prod - ring->cons > ring->full_size;
> > > +	return READ_ONCE(ring->prod) - READ_ONCE(ring->cons) > ring->full_size;
> > >  }  
> > [...]
> >   
> > > @@ -1033,6 +1058,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
> > >  	}
> > >  	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
> > >  
> > > +	/* Doorbell avoidance : We can omit doorbell if we know a TX completion
> > > +	 * will happen shortly.
> > > +	 */
> > > +	if (send_doorbell &&
> > > +	    dev->doorbell_opt &&
> > > +	    (s32)(READ_ONCE(ring->prod_bell) - READ_ONCE(ring->ncons)) > 0)  
> > 
> > It would be nice with a function call with an appropriate name, instead
> > of an open-coded queue size check.  I'm also confused by the "ncons" name.
> >   
> > > +		send_doorbell = false;
> > > +  
> > [...]
> >   
> > > diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > > index 574bcbb1b38f..c3fd0deda198 100644
> > > --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > > +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > > @@ -280,6 +280,7 @@ struct mlx4_en_tx_ring {
> > >  	 */
> > >  	u32			last_nr_txbb;
> > >  	u32			cons;
> > > +	u32			ncons;  
> > 
> > Maybe we can find a better name than "ncons" ?  
> 
> Thats because 'cons' in this driver really means 'old cons' 
> 
> and new cons = old cons + last_nr_txbb;

It was not clear to me that "n" meant "new".  And also not clear that
this drive have an issue of "cons" (consumer) is tracking "old" cons.

  
> > >  	unsigned long		wake_queue;
> > >  	struct netdev_queue	*tx_queue;
> > >  	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
> > > @@ -290,6 +291,7 @@ struct mlx4_en_tx_ring {
> > >  
> > >  	/* cache line used and dirtied in mlx4_en_xmit() */
> > >  	u32			prod ____cacheline_aligned_in_smp;
> > > +	u32			prod_bell;  
> > 
> > Good descriptive variable name.


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer

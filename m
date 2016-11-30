From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 07:56:26 -0800
Message-ID: <1480521386.18162.189.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Achiad Shochat <achiad@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:32796 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753148AbcK3P53 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 10:57:29 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so1694245pgd.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 07:57:29 -0800 (PST)
In-Reply-To: <20161130123810.581ba21f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 12:38 +0100, Jesper Dangaard Brouer wrote:
> I've played with a somewhat similar patch (from Achiad Shochat) for
> mlx5 (attached).  While it gives huge improvements, the problem I ran
> into was that; TX performance became a function of the TX completion
> time/interrupt and could easily be throttled if configured too
> high/slow.
> 
> Can your patch be affected by this too?

Like all TX business, you should know this Jesper.

No need to constantly remind us something very well known.

> 
> Adjustable via:
>  ethtool -C mlx5p2 tx-usecs 16 tx-frames 32
>  

Generally speaking these settings impact TX, throughput/latencies.

Since NIC IRQ then trigger softirqs, we already know that IRQ handling
is critical, and some tuning can help, depending on particular load.

Now the trick is when you want a generic kernel, being deployed on hosts
shared by millions of jobs.


> 
> On Mon, 28 Nov 2016 22:58:36 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > I have a WIP, that increases pktgen rate by 75 % on mlx4 when bulking is
> > not used.
> > 
> > lpaa23:~# echo 0 >/sys/class/net/eth0/doorbell_opt 
> > lpaa23:~# sar -n DEV 1 10|grep eth0
> [...]
> > Average:         eth0      9.50 5707925.60      0.99 585285.69      0.00      0.00      0.50
> > lpaa23:~# echo 1 >/sys/class/net/eth0/doorbell_opt 
> > lpaa23:~# sar -n DEV 1 10|grep eth0
> [...]
> > Average:         eth0      2.40 9985214.90      0.31 1023874.60      0.00      0.00      0.50
> 
> These +75% number is pktgen without "burst", and definitely show that
> your patch activate xmit_more.
> What is the pps performance number when using pktgen "burst" option?

About the same really. About all packets now get the xmit_more effect.

> 
> 
> > And about 11 % improvement on an mono-flow UDP_STREAM test.
> > 
> > skb_set_owner_w() is now the most consuming function.
> > 
> > 
> > lpaa23:~# ./udpsnd -4 -H 10.246.7.152 -d 2 &
> > [1] 13696
> > lpaa23:~# echo 0 >/sys/class/net/eth0/doorbell_opt
> > lpaa23:~# sar -n DEV 1 10|grep eth0
> [...]
> > Average:         eth0      9.00 1307380.50      1.00 308356.18      0.00      0.00      0.50
> > lpaa23:~# echo 3 >/sys/class/net/eth0/doorbell_opt
> > lpaa23:~# sar -n DEV 1 10|grep eth0
> [...]
> > Average:         eth0      3.10 1459558.20      0.44 344267.57      0.00      0.00      0.50
> 
> The +11% number seems consistent with my perf observations that approx
> 12% was "fakely" spend on the xmit spin_lock.
> 
> 
> [...]
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > index 4b597dca5c52..affebb435679 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> > +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> [...]
> > -static inline bool mlx4_en_is_tx_ring_full(struct mlx4_en_tx_ring *ring)
> > +static inline bool mlx4_en_is_tx_ring_full(const struct mlx4_en_tx_ring *ring)
> >  {
> > -	return ring->prod - ring->cons > ring->full_size;
> > +	return READ_ONCE(ring->prod) - READ_ONCE(ring->cons) > ring->full_size;
> >  }
> [...]
> 
> > @@ -1033,6 +1058,14 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
> >  	}
> >  	send_doorbell = !skb->xmit_more || netif_xmit_stopped(ring->tx_queue);
> >  
> > +	/* Doorbell avoidance : We can omit doorbell if we know a TX completion
> > +	 * will happen shortly.
> > +	 */
> > +	if (send_doorbell &&
> > +	    dev->doorbell_opt &&
> > +	    (s32)(READ_ONCE(ring->prod_bell) - READ_ONCE(ring->ncons)) > 0)
> 
> It would be nice with a function call with an appropriate name, instead
> of an open-coded queue size check.  I'm also confused by the "ncons" name.
> 
> > +		send_doorbell = false;
> > +
> [...]
> 
> > diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > index 574bcbb1b38f..c3fd0deda198 100644
> > --- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > +++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
> > @@ -280,6 +280,7 @@ struct mlx4_en_tx_ring {
> >  	 */
> >  	u32			last_nr_txbb;
> >  	u32			cons;
> > +	u32			ncons;
> 
> Maybe we can find a better name than "ncons" ?

Thats because 'cons' in this driver really means 'old cons' 

and new cons = old cons + last_nr_txbb;


> 
> >  	unsigned long		wake_queue;
> >  	struct netdev_queue	*tx_queue;
> >  	u32			(*free_tx_desc)(struct mlx4_en_priv *priv,
> > @@ -290,6 +291,7 @@ struct mlx4_en_tx_ring {
> >  
> >  	/* cache line used and dirtied in mlx4_en_xmit() */
> >  	u32			prod ____cacheline_aligned_in_smp;
> > +	u32			prod_bell;
> 
> Good descriptive variable name.
> 
> >  	unsigned int		tx_dropped;
> >  	unsigned long		bytes;
> >  	unsigned long		packets;
> 
> 

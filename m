From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: tbench regression in 2.6.25-rc1
Date: Tue, 19 Feb 2008 10:44:55 +0800
Message-ID: <1203389095.3248.6.camel@ymzhang>
References: <47B52B95.3070607@cosmosbay.com>
	 <1203057044.3027.134.camel@ymzhang> <47B59FFC.4030603@cosmosbay.com>
	 <20080215.152200.145584182.davem@davemloft.net>
	 <1203322358.3027.200.camel@ymzhang>
	 <20080218111101.6d590c04.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, herbert@gondor.apana.org.au,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:50192 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754879AbYBSCsI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Feb 2008 21:48:08 -0500
In-Reply-To: <20080218111101.6d590c04.dada1@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-02-18 at 11:11 +0100, Eric Dumazet wrote:
> On Mon, 18 Feb 2008 16:12:38 +0800
> "Zhang, Yanmin" <yanmin_zhang@linux.intel.com> wrote:
> 
> > On Fri, 2008-02-15 at 15:22 -0800, David Miller wrote:
> > > From: Eric Dumazet <dada1@cosmosbay.com>
> > > Date: Fri, 15 Feb 2008 15:21:48 +0100
> > > 
> > > > On linux-2.6.25-rc1 x86_64 :
> > > > 
> > > > offsetof(struct dst_entry, lastuse)=0xb0
> > > > offsetof(struct dst_entry, __refcnt)=0xb8
> > > > offsetof(struct dst_entry, __use)=0xbc
> > > > offsetof(struct dst_entry, next)=0xc0
> > > > 
> > > > So it should be optimal... I dont know why tbench prefers __refcnt being 
> > > > on 0xc0, since in this case lastuse will be on a different cache line...
> > > > 
> > > > Each incoming IP packet will need to change lastuse, __refcnt and __use, 
> > > > so keeping them in the same cache line is a win.
> > > > 
> > > > I suspect then that even this patch could help tbench, since it avoids 
> > > > writing lastuse...
> > > 
> > > I think your suspicions are right, and even moreso
> > > it helps to keep __refcnt out of the same cache line
> > > as input/output/ops which are read-almost-entirely :-
> > I think you are right. The issue is these three variables sharing the same cache line
> > with input/output/ops.
> > 
> > > )
> > > 
> > > I haven't done an exhaustive analysis, but it seems that
> > > the write traffic to lastuse and __refcnt are about the
> > > same.  However if we find that __refcnt gets hit more
> > > than lastuse in this workload, it explains the regression.
> > I also think __refcnt is the key. I did a new testing by adding 2 unsigned long
> > pading before lastuse, so the 3 members are moved to next cache line. The performance is
> > recovered.
> > 
> > How about below patch? Almost all performance is recovered with the new patch.
> > 
> > Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> > 
> > ---
> > 
> > --- linux-2.6.25-rc1/include/net/dst.h	2008-02-21 14:33:43.000000000 +0800
> > +++ linux-2.6.25-rc1_work/include/net/dst.h	2008-02-21 14:36:22.000000000 +0800
> > @@ -52,11 +52,10 @@ struct dst_entry
> >  	unsigned short		header_len;	/* more space at head required */
> >  	unsigned short		trailer_len;	/* space to reserve at tail */
> >  
> > -	u32			metrics[RTAX_MAX];
> > -	struct dst_entry	*path;
> > -
> > -	unsigned long		rate_last;	/* rate limiting for ICMP */
> >  	unsigned int		rate_tokens;
> > +	unsigned long		rate_last;	/* rate limiting for ICMP */
> > +
> > +	struct dst_entry	*path;
> >  
> >  #ifdef CONFIG_NET_CLS_ROUTE
> >  	__u32			tclassid;
> > @@ -70,10 +69,12 @@ struct dst_entry
> >  	int			(*output)(struct sk_buff*);
> >  
> >  	struct  dst_ops	        *ops;
> > -		
> > -	unsigned long		lastuse;
> > +
> > +	u32			metrics[RTAX_MAX];
> > +
> >  	atomic_t		__refcnt;	/* client references	*/
> >  	int			__use;
> > +	unsigned long		lastuse;
> >  	union {
> >  		struct dst_entry *next;
> >  		struct rtable    *rt_next;
> > 
> > 
> 
> Well, after this patch, we grow dst_entry by 8 bytes :
With my .config, it doesn't grow. Perhaps because of CONFIG_NET_CLS_ROUTE, I don't
enable it. I will move tclassid under ops.

> 
> sizeof(struct dst_entry)=0xd0
> offsetof(struct dst_entry, input)=0x68
> offsetof(struct dst_entry, output)=0x70
> offsetof(struct dst_entry, __refcnt)=0xb4
> offsetof(struct dst_entry, lastuse)=0xc0
> offsetof(struct dst_entry, __use)=0xb8
> sizeof(struct rtable)=0x140
> 
> 
> So we dirty two cache lines instead of one, unless your cpu have 128 bytes cache lines ?
> 
> I am quite suprised that my patch to not change lastuse if already set to jiffies changes nothing...
> 
> If you have some time, could you also test this (unrelated) patch ?
> 
> We can avoid dirty all the time a cache line of loopback device.
> 
> diff --git a/drivers/net/loopback.c b/drivers/net/loopback.c
> index f2a6e71..0a4186a 100644
> --- a/drivers/net/loopback.c
> +++ b/drivers/net/loopback.c
> @@ -150,7 +150,10 @@ static int loopback_xmit(struct sk_buff *skb, struct net_device *dev)
>                 return 0;
>         }
>  #endif
> -       dev->last_rx = jiffies;
> +#ifdef CONFIG_SMP
> +       if (dev->last_rx != jiffies)
> +#endif
> +               dev->last_rx = jiffies;
>  
>         /* it's OK to use per_cpu_ptr() because BHs are off */
>         pcpu_lstats = netdev_priv(dev);
> 
Although I didn't test it, I don't think it's ok. The key is __refcnt shares the same
cache line with ops/input/output.

-yanmin



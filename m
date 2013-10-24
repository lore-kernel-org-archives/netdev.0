From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH 1/1] net:sched  fix a bug about memery leak
Date: Thu, 24 Oct 2013 16:23:59 +0200
Message-ID: <20131024142359.GC19470@cpaasch-mac>
References: <1382605964-2693-1-git-send-email-windsdaemon@gmail.com>
 <1382607218.7572.45.camel@edumazet-glaptop.roam.corp.google.com>
 <20131024140709.GA19470@cpaasch-mac>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jing Wang <windsdaemon@gmail.com>, davem@davemloft.net,
	jhs@mojatatu.com, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:52152 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754926Ab3JXOYG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 10:24:06 -0400
Content-Disposition: inline
In-Reply-To: <20131024140709.GA19470@cpaasch-mac>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 24/10/13 - 16:07:09, Christoph Paasch wrote:
> On 24/10/13 - 02:33:38, Eric Dumazet wrote:
> > On Thu, 2013-10-24 at 17:12 +0800, Jing Wang wrote:
> > > From: Jing Wang <windsdaemon@gmail.com>
> > > 
> > > the code isn't properly release memory
> > > 
> > > Signed-off-by: Jing Wang <windsdaemon@gmail.com>
> > > ---
> > >  net/sched/cls_route.c |    9 ++++++---
> > >  1 files changed, 6 insertions(+), 3 deletions(-)
> > > 
> > > diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> > > index 37da567..118f8d5 100644
> > > --- a/net/sched/cls_route.c
> > > +++ b/net/sched/cls_route.c
> > > @@ -466,11 +466,11 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
> > >  		goto reinsert;
> > >  	}
> > >  
> > > -	err = -ENOBUFS;
> > > +	err = -ENOMEM;
> > >  	if (head == NULL) {
> > >  		head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
> > >  		if (head == NULL)
> > > -			goto errout;
> > > +			goto errhead;
> > >  
> > >  		tcf_tree_lock(tp);
> > >  		tp->root = head;
> > > @@ -479,7 +479,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
> > >  
> > >  	f = kzalloc(sizeof(struct route4_filter), GFP_KERNEL);
> > >  	if (f == NULL)
> > > -		goto errout;
> > > +		goto errflt;
> > >  
> > >  	err = route4_set_parms(net, tp, base, f, handle, head, tb,
> > >  		tca[TCA_RATE], 1);
> > > @@ -517,6 +517,9 @@ reinsert:
> > >  
> > >  errout:
> > >  	kfree(f);
> > > +errflt:
> > > +    kfree(head);
> > > +errhead:
> > >  	return err;
> > >  }
> > >  
> > 
> > I don't think this patch is needed or correct.
> > 
> > tp->root is the head, you cannot free it like that.
> > 
> > It will be freed properly in route4_destroy()
> > 
> > Please elaborate, thanks.
> 
> I think there is something else wrong in route4_change:
> 
> ----
> From 1409402bf964bef79667755a5d0d5e0c2bd663f3 Mon Sep 17 00:00:00 2001
> From: Christoph Paasch <christoph.paasch@uclouvain.be>
> Date: Thu, 24 Oct 2013 15:33:28 +0200
> Subject: [PATCH net] net: sched: Don't free f before it is allocated in
>  route4_change
> 
> f is set to *arg in route4_change at the beginning, which points to a                                                                                                                                                                                                          
> route4_filter in the hash-table (gotten through route4_get, called by
> tc_ctl_filter). If the alloc of head fails, we should not goto errout,
> because this will free f and thus freed memory will be referenced by
> the hash-table.
> Only later the pointer f will change to an allocated route4_filter.
> 
> This patch returns err if the allocation of head fails as f has not yet
> been allocated inside route4_change.
> 
> Seems the code has been like this since Linus's original git-commit.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>
> ---
>  net/sched/cls_route.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sched/cls_route.c b/net/sched/cls_route.c
> index 37da567..f17c67f 100644
> --- a/net/sched/cls_route.c
> +++ b/net/sched/cls_route.c
> @@ -470,7 +470,7 @@ static int route4_change(struct net *net, struct sk_buff *in_skb,
>         if (head == NULL) {
>                 head = kzalloc(sizeof(struct route4_head), GFP_KERNEL);
>                 if (head == NULL)
> -                       goto errout;
> +                       return err;

Oh... copy-paste from vim into mutt actually replaced the tabs by spaces...

I will resend. Sorry.


Christoph

> 
>                 tcf_tree_lock(tp);
>                 tp->root = head;
> -- 
> 1.8.3.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

From: Julia Lawall <julia@diku.dk>
Subject: Re: Subject: [PATCH] net/ipv6: Use GFP_ATOMIC when a lock is held
Date: Sun, 30 May 2010 22:50:16 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005302248500.19253@ask.diku.dk>
References: <Pine.LNX.4.64.1005302147310.19253@ask.diku.dk>
 <1275250288.2472.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-511516320-1925940719-1275252616=:19253"
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:36415 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754127Ab0E3UuY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 30 May 2010 16:50:24 -0400
In-Reply-To: <1275250288.2472.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---511516320-1925940719-1275252616=:19253
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT

On Sun, 30 May 2010, Eric Dumazet wrote:

> Le dimanche 30 mai 2010 à 21:48 +0200, Julia Lawall a écrit :
> > From: Julia Lawall <julia@diku.dk>
> > 
> > A spin lock is taken near the beginning of the enclosing function.
> > 
> > The semantic patch that makes this change is as follows:
> > (http://coccinelle.lip6.fr/)
> > 
> > // <smpl>
> > @@
> > @@
> > 
> > spin_lock(...)
> > ... when != spin_unlock(...)
> > -GFP_KERNEL
> > +GFP_ATOMIC
> > // </smpl>
> > 
> > Signed-off-by: Julia Lawall <julia@diku.dk>
> > 
> > ---
> >  net/ipv6/sit.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff -u -p a/net/ipv6/sit.c b/net/ipv6/sit.c
> > --- a/net/ipv6/sit.c
> > +++ b/net/ipv6/sit.c
> > @@ -358,7 +358,7 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t
> >  		goto out;
> >  	}
> >  
> > -	p = kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
> > +	p = kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_ATOMIC);
> >  	if (!p) {
> >  		err = -ENOBUFS;
> >  		goto out;
> 
> Nice catch, but what about allocating this outside of the locked
> section ?

I think the proposed patch does not work, because the for loop overwrites 
p.  That use of p looks like it is completely local to the for loop, so 
perhaps a new variable p1 could be added to be used there?

julia

> diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
> index e51e650..ff3dd84 100644
> --- a/net/ipv6/sit.c
> +++ b/net/ipv6/sit.c
> @@ -340,6 +340,10 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
>  	if (a->addr == htonl(INADDR_ANY))
>  		return -EINVAL;
>  
> +	p = kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
> +	if (!p)
> +		return -ENOBUFS;
> +
>  	spin_lock(&ipip6_prl_lock);
>  
>  	for (p = t->prl; p; p = p->next) {
> @@ -358,19 +362,16 @@ ipip6_tunnel_add_prl(struct ip_tunnel *t, struct ip_tunnel_prl *a, int chg)
>  		goto out;
>  	}
>  
> -	p = kzalloc(sizeof(struct ip_tunnel_prl_entry), GFP_KERNEL);
> -	if (!p) {
> -		err = -ENOBUFS;
> -		goto out;
> -	}
>  
>  	p->next = t->prl;
>  	p->addr = a->addr;
>  	p->flags = a->flags;
>  	t->prl_count++;
>  	rcu_assign_pointer(t->prl, p);
> +	p = NULL;
>  out:
>  	spin_unlock(&ipip6_prl_lock);
> +	kfree(p);
>  	return err;
>  }
>  
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
---511516320-1925940719-1275252616=:19253--

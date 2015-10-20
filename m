From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH nf-next 4/4] netfilter: ipv6: avoid nf_iterate recursion
Date: Tue, 20 Oct 2015 10:18:37 +0200
Message-ID: <20151020081837.GI4386@breakpoint.cc>
References: <1445112865-31523-1-git-send-email-fw@strlen.de>
 <1445112865-31523-5-git-send-email-fw@strlen.de>
 <CANr6G5z3SYGo-f7OmKwncHFK0M01YkeWk2W9tPcQWX3LV5NEEA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netfilter-devel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>,
	Andy Zhou <azhou@nicira.com>
To: Joe Stringer <joestringer@nicira.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CANr6G5z3SYGo-f7OmKwncHFK0M01YkeWk2W9tPcQWX3LV5NEEA@mail.gmail.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Joe Stringer <joestringer@nicira.com> wrote:
> On 17 October 2015 at 13:14, Florian Westphal <fw@strlen.de> wrote:
> > @@ -606,19 +599,22 @@ struct sk_buff *nf_ct_frag6_gather(struct net *net, struct sk_buff *skb, u32 use
> >                 spin_unlock_bh(&fq->q.lock);
> >                 pr_debug("Can't insert skb to queue\n");
> >                 inet_frag_put(&fq->q, &nf_frags);
> > -               return skb;
> > +               return -EINVAL;
> >         }
> >
> > +       /* after queue has assumed skb ownership, only 0 or -EINPROGRESS
> > +        * must be returned.
> > +        */
> > +       ret = -EINPROGRESS;
> >         if (fq->q.flags == (INET_FRAG_FIRST_IN | INET_FRAG_LAST_IN) &&
> > -           fq->q.meat == fq->q.len) {
> > -               ret_skb = nf_ct_frag6_reasm(fq, skb, dev);
> > -               if (ret_skb == NULL)
> > -                       pr_debug("Can't reassemble fragmented packets\n");
> > -       }
> > +           fq->q.meat == fq->q.len &&
> > +           nf_ct_frag6_reasm(fq, skb, dev))
> > +               ret = 0;
> > +
> >         spin_unlock_bh(&fq->q.lock);
> >
> >         inet_frag_put(&fq->q, &nf_frags);
> > -       return ret_skb;
> > +       return ret;
> >  }
> >  EXPORT_SYMBOL_GPL(nf_ct_frag6_gather);
> 
> Minor nit below, feel free to disregard if it misses some code style
> guideline. The lock/unlock reads easier to me if the
> unlocking/frag_put is grouped together, something like the following
> incremental:

I like it, will change it for v2.

Thanks!

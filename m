From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH -next] cbq: remove only caller of qdisc->drop()
Date: Tue, 7 Jun 2016 00:52:27 +0200
Message-ID: <20160606225227.GE7827@breakpoint.cc>
References: <1465248027-21652-1-git-send-email-fw@strlen.de>
 <1465251192.24873.1.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54674 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750764AbcFFWwc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 18:52:32 -0400
Content-Disposition: inline
In-Reply-To: <1465251192.24873.1.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >  static void cbq_ovl_drop(struct cbq_class *cl)
> >  {
> > -	if (cl->q->ops->drop)
> > -		if (cl->q->ops->drop(cl->q))
> > -			cl->qdisc->q.qlen--;
> > +	struct sk_buff *skb = cl->q->ops->dequeue(cl->q);
> > +
> > +	if (skb) {
> > +		cl->deficit -= qdisc_pkt_len(skb);
> > +		cl->qdisc->q.qlen--;
> > +		qdisc_drop(skb, cl->qdisc);
> > +	}
> > +
> >  	cl->xstats.overactions++;
> >  	cbq_ovl_classic(cl);
> >  }
> 
> A drop() is not equivalent to a dequeue() followed by qdisc_drop() for
> statistics.
> 
> dequeue() will update stats of _sent_ packets/bytes, while drop() should
> not.

Well, I could send patch to just remove cbq_ovl_drop completely,
you can't configure this facility with iproute2.

You are right of course, but is it really worth to have this?

Not calling cl->q->ops->drop() in cbq would allow removal of ~300 LOC
in qdiscs...

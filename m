From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: use an RB tree for ooo receive queue
Date: Thu, 08 Sep 2016 06:38:21 -0700
Message-ID: <1473341901.15733.41.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1473284968.15733.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <alpine.DEB.2.10.1609081236470.18111@whp-28.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yaogong Wang <wygivan@google.com>,
        Yuchung Cheng <ycheng@google.com>,
        Neal Cardwell <ncardwell@google.com>
To: Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:35216 "EHLO
        mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757667AbcIHNiY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 8 Sep 2016 09:38:24 -0400
Received: by mail-pa0-f48.google.com with SMTP id b2so17604308pat.2
        for <netdev@vger.kernel.org>; Thu, 08 Sep 2016 06:38:23 -0700 (PDT)
In-Reply-To: <alpine.DEB.2.10.1609081236470.18111@whp-28.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-08 at 14:02 +0300, Ilpo Järvinen wrote:
> On Wed, 7 Sep 2016, Eric Dumazet wrote:

> While testing, was there any check done for the data that was delivered
> in order to ensure that no corruption occured (either by you or Yaogong)? 
> ...This kind of changes have some potential to cause some corruption to
> the stream content and it would be nice to be sure there wasn't any
> accidents.

Sure, we did tests on real GFE, serving real data to users.

My ssh/scp sessions did not catch any error, even with up to 10% packet
losses.

> >  	}
> >  
> > -	seq = TCP_SKB_CB(skb)->seq;
> > -	end_seq = TCP_SKB_CB(skb)->end_seq;
> 
> I hate to nitpick but moving these variables earlier and the 
> TCP_SKB_CB(skb)->seq/end_seq simplifications seem unrelated and
> could be done in another patch?

You are right.

I could split this patch in 3 parts if David requests it.

1) One patch adding skb_rbtree_purge(struct rb_root *root) helper
2) One patch doing this seq/end_seq cleanup.
3) RB patch


> > -
> > -	for (;;) {
> > -		struct sk_buff *next = NULL;
> >  
> > -		if (!skb_queue_is_last(&tp->out_of_order_queue, skb))
> > -			next = skb_queue_next(&tp->out_of_order_queue, skb);
> > -		skb = next;
> > +	for (head = skb;;) {
> > +		skb = tcp_skb_next(skb, NULL);
> >  
> > -		/* Segment is terminated when we see gap or when
> > -		 * we are at the end of all the queue. */
> > +		/* Range is terminated when we see a gap or when
> > +		 * we are at the queue end.
> > +		 */
> >  		if (!skb ||
> >  		    after(TCP_SKB_CB(skb)->seq, end) ||
> >  		    before(TCP_SKB_CB(skb)->end_seq, start)) {
> > -			tcp_collapse(sk, &tp->out_of_order_queue,
> > +			tcp_collapse(sk, NULL, &tp->out_of_order_queue,
> >  				     head, skb, start, end);
> > -			head = skb;
> > -			if (!skb)
> > -				break;
> > -			/* Start new segment */
> > +			goto new_range;
> > +		}
> > +
> > +		if (unlikely(before(TCP_SKB_CB(skb)->seq, start)))
> >  			start = TCP_SKB_CB(skb)->seq;
> > +		if (after(TCP_SKB_CB(skb)->end_seq, end))
> >  			end = TCP_SKB_CB(skb)->end_seq;
> > -		} else {
> > -			if (before(TCP_SKB_CB(skb)->seq, start))
> > -				start = TCP_SKB_CB(skb)->seq;
> > -			if (after(TCP_SKB_CB(skb)->end_seq, end))
> > -				end = TCP_SKB_CB(skb)->end_seq;
> > -		}
> >  	}
> >  }
> 
> I tried long to think if I could propose alternative layout which would 
> make this function to exit from the end but couldn't come up anything 
> sensible. As is, it's always exiting within that top if block which is
> somewhat unintuitive :-).
> 
> Acked-By: Ilpo Järvinen <ilpo.jarvinen@helsinki>
> 

Thanks for the review !

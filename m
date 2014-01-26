From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [BUG] null pointer dereference in tcp_gso_segment()
Date: Sat, 25 Jan 2014 17:18:25 -0800
Message-ID: <1390699105.27806.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <87r47z7kqo.fsf@natisbad.org>
	 <1390427824.27806.36.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8761pb7jzq.fsf@natisbad.org>
	 <1390429125.27806.40.camel@edumazet-glaptop2.roam.corp.google.com>
	 <87r47v4ny9.fsf@natisbad.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Willy Tarreau <w@1wt.eu>, netdev@vger.kernel.org
To: Arnaud Ebalard <arno@natisbad.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:58453 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750840AbaAZBS2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jan 2014 20:18:28 -0500
Received: by mail-pa0-f53.google.com with SMTP id lj1so4623429pab.12
        for <netdev@vger.kernel.org>; Sat, 25 Jan 2014 17:18:28 -0800 (PST)
In-Reply-To: <87r47v4ny9.fsf@natisbad.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-01-26 at 00:54 +0100, Arnaud Ebalard wrote:

> Thanks for the explanation and sorry for the delay, I only just found
> the time to take a look at the code. For the discussion, a simplified
> version of tcp_gso_segment() is:
> 
> 
>   th = tcp_hdr(skb);
>   thlen = th->doff * 4;
> 
>   ...
> 
>   __skb_pull(skb, thlen);
> 
>   ...
> 
>   mss = tcp_skb_mss(skb);
>   if (unlikely(skb->len <= mss))
>  	goto out;
> 
>   ...
> 
>   segs = skb_segment(skb, features);
>   skb = segs;
> 
>   ...
> 
> 		skb = skb->next;
> 		th = tcp_hdr(skb);   <- bug occurs here
> 
> 
> So the logic seems to be that if we pass the mss test (i.e. skb->len >
> mss), then skb_segment() *should* indeed create at least two segments
> from the skb. I took a look at skb_segment() but the code is !trivial,
> i.e. it is not obvious that there is no way for the function to deliver
> a sk_buff skb w/ a NULL skb->next. Eric, I guess you or Herbert are
> familiar enough w/ the code to tell. But before checking that, your lead
> below is interesting ...
> 
> > Since TCP stack seemed to be the provider of the packet in your stack
> > trace, check tcp_set_skb_tso_segs()
> 
> It is indeed called in tcp_write_xmit() which appears in the
> backtrace. That function you point has an interesting property:
> 
>  static void tcp_set_skb_tso_segs(const struct sock *sk, struct sk_buff *skb,
>  				 unsigned int mss_now)
>  {
>  	/* Make sure we own this skb before messing gso_size/gso_segs */
>  	WARN_ON_ONCE(skb_cloned(skb));
>  
>  	if (skb->len <= mss_now || skb->ip_summed == CHECKSUM_NONE) {
>  		/* Avoid the costly divide in the normal
>  		 * non-TSO case.
>  		 */
>  		skb_shinfo(skb)->gso_segs = 1;
>  		skb_shinfo(skb)->gso_size = 0;
>  		skb_shinfo(skb)->gso_type = 0;
>  	} else {
>  		skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss_now);
>  		skb_shinfo(skb)->gso_size = mss_now;
>  		skb_shinfo(skb)->gso_type = sk->sk_gso_type;
>  	}
>  }
>  
> If it is called with skb->len <= mss, the resulting skb will be modified
> so that you will then have skb_shinfo(skb)->gso_size set to 0,
> i.e. skb->len > skb_shinfo(skb)->gso_size.
> 

The key part is that gso_size is set to 0.

Meaning its not a gso packet :

static inline bool skb_is_gso(const struct sk_buff *skb)
{
        return skb_shinfo(skb)->gso_size;
}

So the packet cannot possibly go up to tcp_gso_segment() because
we fail the first test in :

static inline bool netif_needs_gso(struct sk_buff *skb,
                                   netdev_features_t features)
{
        return skb_is_gso(skb) && (!skb_gso_ok(skb, features) ||
                unlikely((skb->ip_summed != CHECKSUM_PARTIAL) &&
                         (skb->ip_summed != CHECKSUM_UNNECESSARY)));
}


> In tcp_gso_segment(), mss is grabbed using tcp_skb_mss() which simply
> returns skb_shinfo(skb)->gso_size. That function comes with a comment
> indicating that it provides the mss only when tcp_skb_pcount() > 1,
> i.e when skb_shinfo(skb)->gso_segs > 1. Said differently, one should
> never call tcp_skb_mss() after tcp_set_skb_tso_segs() has been called on
> a skb *unless* she tests explicitly that tcp_skb_pcount() > 1.
> 
> This test (tcp_skb_pcount() > 1) is not done in tcp_gso_segment() before
> getting the mss value w/ tcp_skb_mss(). I may have missed a test
> somewhere in a caller but I do not see why tcp_gso_segment() makes the
> assumption it can safely call tcp_skb_mss().

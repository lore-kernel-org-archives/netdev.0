From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] tcp: remove dst refcount false sharing for
 prequeue mode
Date: Mon, 08 Sep 2014 14:30:42 -0700
Message-ID: <1410211842.11872.133.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1410014704.11872.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410017237.11872.31.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1410188767.11872.110.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20140908.142143.807176983873922125.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: therbert@google.com, alexander.h.duyck@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:47454 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754735AbaIHVao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:30:44 -0400
Received: by mail-pa0-f48.google.com with SMTP id hz1so6597748pad.21
        for <netdev@vger.kernel.org>; Mon, 08 Sep 2014 14:30:44 -0700 (PDT)
In-Reply-To: <20140908.142143.807176983873922125.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-09-08 at 14:21 -0700, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 08 Sep 2014 08:06:07 -0700
> 
> > @@ -1559,7 +1559,17 @@ bool tcp_prequeue(struct sock *sk, struct sk_buff *skb)
> >  	    skb_queue_len(&tp->ucopy.prequeue) == 0)
> >  		return false;
> >  
> > -	skb_dst_force(skb);
> > +	/* Before escaping RCU protected region, we need to take care of skb
> > +	 * dst. Prequeue is only enabled for established sockets.
> > +	 * For such sockets, we might need the skb dst only to set sk->sk_rx_dst
> > +	 * Instead of doing full sk_rx_dst validity here, let's perform
> > +	 * an optimistic check.
> > +	 */
> > +	if (likely(sk->sk_rx_dst))
> > +		skb_dst_drop(skb);
> > +	else
> > +		skb_dst_force(skb);
> > +
> 
> This might not be a strong enough test.
> 
> We have to also make all of the checks that would cause the input
> path to invalidate sk->sk_rx_dst too.
> 
> Otherwise, if it does, we'll crash when we try to do a dst_hold()
> on skb_dst(skb) in sk->sk_rx_dst_set().

I thought I gave enough details in this comment and changelog. Maybe I
had been too verbose  :(

In the worst case, here is what is happening :

sk_rx_dst is checked and invalidated in tcp_v4_do_rcv()

Next packets coming from prequeue might then have a NULL dst, and
we'll do nothing special (sk_rx_dst will stay NULL), because we do
handle NULL dst properly in inet_sk_rx_dst_set() and
inet6_sk_rx_dst_set() 

But next packet to be processed (either in non prequeue mode or
prequeue) will carry skb->dst and we will set sk->sk_rx_dst

I decided to not copy/paste the tests we do in the family dependent
parts, because it was not worth the pain.

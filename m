From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Sat, 08 Oct 2011 10:16:48 +0200
Message-ID: <1318061808.3991.12.camel@jlt3.sipsolutions.net>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
	 <20111007.133356.489094996618032061.davem@davemloft.net>
	 <20111008075719.GA2284@netboy.at.omicron.at>
	 (sfid-20111008_095753_882744_64F82E9F)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:45843 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750798Ab1JHIQ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 04:16:56 -0400
In-Reply-To: <20111008075719.GA2284@netboy.at.omicron.at> (sfid-20111008_095753_882744_64F82E9F)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-10-08 at 09:57 +0200, Richard Cochran wrote:

> I don't remember why I put it that way, but I took a look at the
> problem, and I am not sure how to solve it. The other callers of
> sock_queue_err_skb all create or clone the error skb immediately
> before queueing it:
> 
>   net/core/skbuff.c:       skb_tstamp_tx
>   net/ipv4/ip_sockglue.c:  ip_icmp_error, ip_local_error
>   net/ipv6/datagram.c:     ipv6_icmp_error, ipv6_local_error

Yeah, I noticed that too. That's also the reason they pass the socket
externally I believe, since it's not a properly refcounted socket (the
reference they use is still from the original skb).

The thing that makes it work is that
 a) they don't release the original SKB before sock_queue_err_skb() and
 b) skb->sk is NULL for them

Since this is just a single function, they can guarantee that -- in the
case we found here it's scattered across the code and won't always be
guaranteed -- e.g. the kfree_skb() case in the PHY driver potentially
violates b).

> So I need to prevent the socket from disappearing between
> skb_clone_tx_timestamp and skb_complete_tx_timestamp:
> 
>   skb_clone_tx_timestamp
> 	clone = skb_clone(skb, GFP_ATOMIC);
> 	sock_hold
>   skb_complete_tx_timestamp
> 	sock_queue_err_skb(sk, skb);
> 	sock_put
> 
> What do you think?

I'm not terribly familiar with struct sock. Looking at it, I'm a bit
confused by skb_orphan() -- it doesn't put the sock reference. So are
sockets not refcounted for skbs in this way? They seem to use
sock_wfree() which does a bit more than this it seems, and I don't see
it using sk_refcnt anywhere so I'm a bit confused now.

> BTW, while looking for a good pattern to follow, I found that the can
> driver also sets skb->sk after clone with no special treatment, like
> so:
> 
>   drivers/net/can/dev.c:285
> 	can_put_echo_skb
> 		struct sock *srcsk = skb->sk;
> 		skb = skb_clone(old_skb, GFP_ATOMIC);
> 		skb->sk = srcsk;

Yeah that looks fishy too. But to me it looks a bit like it should
charge to the socket instead of refcounting it -- though of course
that's not really the correct thing to do from a socket buffer point of
view, but it seems the sk_refcnt and sk_wmem_alloc are two separate
mechanisms of refcounting the socket -- I just haven't figured out yet
how they interact.

> > The TX side of this infrastructure seems very poorly tested.
> 
> In fact, we do have the phyter driver used in an extensive automated
> test farm, but the applications just don't do the kinds of things
> suggested to trigger the problem. The normal pattern is, send event
> packet, get tx timestamp, and so we haven't seen the bug at all.

Makes sense, you never wrote an application trying to crash it :-)

> > Maybe that's how you can trigger it: have one thread turn on and off
> > timestamping all the time, and another thread send frames all the time,
> > then eventually you'll probably run into the kfree_skb() case there. If
> > you ever manage to run into that case, it'll crash either when freeing
> > this skb or when freeing the original.
> 
> Thats one weird app, but I get the point, and thanks for your
> attention to my code.

Agree, it's obviously a specifically devised app to try to make it
crash. It serves no other practical purpose.

johannes

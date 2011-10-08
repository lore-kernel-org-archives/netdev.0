From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC] net: remove erroneous sk null assignment in timestamping
Date: Sat, 8 Oct 2011 09:57:20 +0200
Message-ID: <20111008075719.GA2284@netboy.at.omicron.at>
References: <1318007501.3988.20.camel@jlt3.sipsolutions.net>
 <20111007.133356.489094996618032061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johannes@sipsolutions.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:48857 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753339Ab1JHH5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Oct 2011 03:57:24 -0400
Received: by eye27 with SMTP id 27so187128eye.19
        for <netdev@vger.kernel.org>; Sat, 08 Oct 2011 00:57:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20111007.133356.489094996618032061.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 07, 2011 at 01:33:56PM -0400, David Miller wrote:
> It looks like skb_clone_tx_timestamp() sets clone->sk without any
> proper refcounting, so I bet this NULL'ing it out is working
> around that bug.

I don't remember why I put it that way, but I took a look at the
problem, and I am not sure how to solve it. The other callers of
sock_queue_err_skb all create or clone the error skb immediately
before queueing it:

  net/core/skbuff.c:       skb_tstamp_tx
  net/ipv4/ip_sockglue.c:  ip_icmp_error, ip_local_error
  net/ipv6/datagram.c:     ipv6_icmp_error, ipv6_local_error

So I need to prevent the socket from disappearing between
skb_clone_tx_timestamp and skb_complete_tx_timestamp:

  skb_clone_tx_timestamp
	clone = skb_clone(skb, GFP_ATOMIC);
	sock_hold
  skb_complete_tx_timestamp
	sock_queue_err_skb(sk, skb);
	sock_put

What do you think?

BTW, while looking for a good pattern to follow, I found that the can
driver also sets skb->sk after clone with no special treatment, like
so:

  drivers/net/can/dev.c:285
	can_put_echo_skb
		struct sock *srcsk = skb->sk;
		skb = skb_clone(old_skb, GFP_ATOMIC);
		skb->sk = srcsk;

> The TX side of this infrastructure seems very poorly tested.

In fact, we do have the phyter driver used in an extensive automated
test farm, but the applications just don't do the kinds of things
suggested to trigger the problem. The normal pattern is, send event
packet, get tx timestamp, and so we haven't seen the bug at all.

Thanks,
Richard

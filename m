From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] Generalize socket rx gap / receive queue overflow cmsg
Date: Thu, 8 Oct 2009 09:54:35 -0400
Message-ID: <20091008135435.GA23928@hmsreliant.think-freely.org>
References: <20091007180835.GB20524@hmsreliant.think-freely.org> <4ACD3AC8.608@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, socketcan@hartkopp.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:45617 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932226AbZJHNzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2009 09:55:18 -0400
Content-Disposition: inline
In-Reply-To: <4ACD3AC8.608@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> > +	if (check_drops) {
> > +		skb = skb_recv_datagram(sk, flags|MSG_PEEK,
> > +				flags & MSG_DONTWAIT, &err);
> 
> 	Ouch, this is too expensive, please find another way :)
> 
> > +		if (skb) {
> > +			gap = skb->dropcount;
> > +			consume_skb(skb);
> > +		}
> > +	}
> > +
I'm not sure that I see the expense here, and what expense there is, I don't see
how it avoidable.  In order to do this reporting at the socket level, we need to
look at the skb at the head of the receive queue.  But we need to do so in a way
thats consistent with the flags being passed in (i.e. if this is a blocking
socket, we need to block here until something is available to read).  Then its
just an atomic_inc on skb->users, followed by a dec in the consume_skb.  I could
implement the logic for DONTWAIT myself, and skip the atomic_inc/dec, but I'm
not sure thats much of a savings.  If you have another thought, I'm certainly
open to it.

Neil

> > +	rc = sock->ops->recvmsg(iocb, sock, msg, size, flags);
> > +
> > +	if (check_drops && (rc > 0))
> 
> 		&& gap != 0
> 
> > +		put_cmsg(msg, SOL_SOCKET, SO_RXQ_OVFL, sizeof(__u32), &gap);
> > +
> 
> 

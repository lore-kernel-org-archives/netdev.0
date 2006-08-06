From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [e1000]: Remove unnecessary tx_lock
Date: Sun, 06 Aug 2006 01:35:16 -0700 (PDT)
Message-ID: <20060806.013516.35333380.davem@davemloft.net>
References: <20060806071418.GB20432@edgar.underground.se.axis.com>
	<20060806.002644.26512828.davem@davemloft.net>
	<20060806073655.GA28735@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: edgar.iglesias@axis.com, hadi@cyberus.ca, shemminger@osdl.org,
	mchan@broadcom.com, jesse.brandeburg@intel.com,
	auke-jan.h.kok@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:53690
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1750713AbWHFIfE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 6 Aug 2006 04:35:04 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060806073655.GA28735@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 6 Aug 2006 17:36:55 +1000

> Actually, why do we charge the memory to the socket at all between
> the packet leaving the TCP stack and it entering the device?

Because it's easy to verify that it prevents all the possible
DoS scenerios a user could play out.

> Most packets spend a tiny amount of time on this journey so it seems
> silly to do atomic operations as they leave the stack only to undo
> it when they enter the device.

I agree.

> The biggest reason packets spend a non-trivial amount of time on
> this journey is traffic shaping.  In that case the memory is already
> accounted to the device anyway (in terms of queue length) so it would
> seem unfair to charge the socket as well.

Again, total agreement.

> So how about simply charging the socket for the retransmit queue
> as we do now and skip the caharge for packets leaving the stack?
> 
> For UDP it's different since it doesn't have a retransmit queue.
> However, I'm unsure how much of a positive effect the socket charge
> actually has for UDP.

UDP and other datagram protocols are a thorny case aren't they? :)

This has actually been a source of problems in the past, come to think
of it.  We used to have this bug in the output path where UDP could
build a packet of size X that fit in the socket send buffer, but if we
had to fragment this packet because "mtu < X" not all of the fragments
would fit in the socket send buffer and we'd drop the entire packet :)

What happens now is we just try to strictly charge the first fragment
to the socket's send buffer on fragmentation and then we only enfore
lighter rules (allowing up to "2 * sk_sndbuf" to be used) as we charge
for the rest of the frags.

You can see this logic in ip_append_data():

		if (transhdrlen) {
			skb = sock_alloc_send_skb(sk, 
					alloclen + hh_len + 15,
					(flags & MSG_DONTWAIT), &err);
		} else {
			skb = NULL;
			if (atomic_read(&sk->sk_wmem_alloc) <=
			    2 * sk->sk_sndbuf)
				skb = sock_wmalloc(sk, 
						   alloclen + hh_len + 15, 1,
						   sk->sk_allocation);
			if (unlikely(skb == NULL))
				err = -ENOBUFS;
		}

As you say these things are about to go out to the device, so it's
kind of silly from that perspective, BUT...  it does exist to a
certain extent for application flow control, especially for these
datagram apps.

I tried to see if there was any wisdom on this matter in TCP/IP
Illustrated Volume 2, but BSD does the same thing we do.

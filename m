From: Ingo Molnar <mingo@elte.hu>
Subject: Re: poor network loopback performance and scalability
Date: Mon, 21 Apr 2008 10:11:03 +0200
Message-ID: <20080421081103.GA31328@elte.hu>
References: <20080331113602.GA13526@elte.hu> <E1JnmdQ-0001qO-00@gondolin.me.apana.org.au> <20080420.203810.183610437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: herbert@gondor.apana.org.au, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	a.p.zijlstra@chello.nl
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:33759 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753312AbYDUIL3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Apr 2008 04:11:29 -0400
Content-Disposition: inline
In-Reply-To: <20080420.203810.183610437.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* David Miller <davem@davemloft.net> wrote:

> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Mon, 21 Apr 2008 11:24:04 +0800
> 
> > Ingo Molnar <mingo@elte.hu> wrote:
> > > 
> > >   # ifconfig lo mtu 1048576
> > 
> > Chiming in late here, but 1048576 can't possibly work with IP which 
> > uses a 16-bit quantity as the length header.  In fact a quick test 
> > seems to indicate that an 1048576 mtu doesn't generate anything 
> > bigger than the default 16K mtu.
> 
> Right.
> 
> To move things forward, we should look into doing something similar to 
> what Al Viro suggested, which would be to return an SKB pointer from 
> the transmit path and call back into netif_receive_skb() using that.

yep, basically the sk_peer trick that AF_UNIX is already using.

it just seems rather more tricky in the 'real skb' localhost case 
because there's no real established trust path we can pass this coupling 
of the two sockets over. Netfilter might affect it and deny a localhost 
connection. Lifetime rules seem rather tricky as well: either end of the 
localhost connection can go away independently so a refcount to the 
socket has to be kept. skb->sk might be something to use, but it looks 
like a dangerous complication and it would burden the fastpath with an 
extra sk reference inc/dec.

... so i'm not implying that any of this is an easy topic to solve (to 
me at least :). But fact is that database connections over localhost are 
very common on web apps and it is very convenient as well. I use it 
myself - AF_UNIX transport is often non-existing in apps and libraries 
or is often just an afterthought with limitations - apps tend to 
gravitate towards a single API. So i dont think "use AF_UNIX" is an 
acceptable answer in this case. I believe we should try to make 
localhost transport comparably fast to AF_UNIX.

	Ingo

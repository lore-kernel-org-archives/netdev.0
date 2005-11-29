From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 07/13]: [NETFILTER]: Fix xfrm lookup in
 ip_route_me_harder/ip6_route_me_harder
Date: Mon, 28 Nov 2005 23:49:47 -0800 (PST)
Message-ID: <20051128.234947.117781000.davem@davemloft.net>
References: <20051128210628.GA15057@gondor.apana.org.au>
	<438BFD0A.5040105@trash.net>
	<20051129073441.GA18387@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: herbert@gondor.apana.org.au
In-Reply-To: <20051129073441.GA18387@gondor.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Tue, 29 Nov 2005 18:34:41 +1100

> On Tue, Nov 29, 2005 at 08:02:34AM +0100, Patrick McHardy wrote:
> > It seems in most places where only IPCB(skb)->opt is cleared
> > the entire CB should be cleared. A couple of spots also look
> > completely unnecessary, for example all places clearing the CB
> > before passing the packet to netif_rx. I would expect the next
> > user beeing responsible for clearing the space he needs if
> > neccessary.
> 
> Agreed.  However, it seems that ip_rcv() only clears the CB options
> if ihl is greater than 5.  So until that's changed the people feeding
> netif_rx will have to clear the CB.

I wonder if that stuff can be simplified somehow.

We only use those options in two ways:

1) To process early in input via ip_options_compile()
   and the source route check in ip_rcv_finish()

2) To do forwarding processing on options in ip_forward_finish()
   and the multicast equivalent in ipmr.c

3) For locally destined packets, when the options are to be
   passed to the user via a recvmsg() CMSG.

Well, there is a 4th, which is what we're talking about here,
which is all of the zero'ing out of the thing during encapsulation
which is mostly a waste.

I think #1 and #2 can be handled by an on-stack copy of "struct
ip_options" high enough in the call chain, but #3 is a bit less
trivial to cope with like that.

It would be nice to kill the IPCB() copy, and give us 12 bytes back in
skb->cb[] :-)

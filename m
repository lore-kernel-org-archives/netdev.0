From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][IPv6] separation xfrm_lookup from ip6_dst_lookup
Date: Mon, 2 Aug 2004 19:09:14 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040802190914.303ccfbe.davem@redhat.com>
References: <20040730171205.114f22ba.kazunori@miyazawa.org>
	<20040802074147.GA16381@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com, usagi-core@linux-ipv6.org,
        kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040802074147.GA16381@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 2 Aug 2004 17:41:47 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> This raises an interesting question.  Is it really correct to look at
> the first hop address when doing the route lookup?
> 
> The problem is that if we use the first-hop address as the dst when
> doing the route lookup then we may end up with incorrect MTU information.
> This is because the MTU to the final destination may well be smaller than
> the MTU to the first hop.
> 
> It seems that Alexey thought about this six years ago according to
> the rthdr comment in icmpv6_rcv().

When the ICMP6 packet comes back in such a case, the type zero
routing header will be suitable edited.  So at least we can determine
which exact destination address the PMTU information applies to.

But I understand what the problem is.  We cannot update the destination
cache entry for destination "D" if the ICMP message is for hop "B"
specified in the routing header.  Furthermore, we cannot even update
a destination cache entry for hop "B" in the case where the routing
header specifies --> A --> B --> C --> D because a direct packet
destinated for "B" might use a different path than "A" does.

An intesting solution would be to use stacked destinations, which
do no actual encapsulation (or perhaps do the routing header work)
and merely represent the hop-by-hop path.  Then the PMTU propagation
machinery can be used, and route lookups will go through a slower path
to find these special stacked hop-by-hop routes.

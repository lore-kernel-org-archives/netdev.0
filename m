From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] dst_entry structure use,lastuse and refcnt abstraction
Date: Thu, 23 Jun 2005 21:11:40 -0700 (PDT)
Message-ID: <20050623.211140.131918815.davem@davemloft.net>
References: <Pine.LNX.4.62.0506232047450.29103@graphe.net>
	<20050623.205447.66178303.davem@davemloft.net>
	<Pine.LNX.4.62.0506232057340.29222@graphe.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-net@vger.kernel.org,
	shai@scalex86.org, akpm@osdl.org, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
Return-path: <linux-net-owner@vger.kernel.org>
To: christoph@lameter.com
In-Reply-To: <Pine.LNX.4.62.0506232057340.29222@graphe.net>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <christoph@lameter.com>
Date: Thu, 23 Jun 2005 21:06:30 -0700 (PDT)

> I am sure one can do better than that. The x445 is the smallest NUMA box 
> that I know of and the only one available in the context of that project. 
> But I am also not sure that this will reach proportions  that will 
> outweigh the complexity added by these patches. What would be 
> the performance benefit that we would need to see to feel that is 
> is right to get such a change in?

Something on the order of %10.  If I recall correctly, that's
basically what we got on SMP from the RCU changes to the routing
cache.

> Hmm. I like the idea of a separate routing cache per node. May actually 
> reach higher performance than splitting the counters. Lets think a bit 
> about that.

One thing that may happen down the line is that the flow cache
becomes a more unified thing.  Ie. local sockets get found there,
netfilter rules can match, as well as normal "routes".

The idea is that on a miss, you go down into the "slow" lookup path
where the data structure is less distributed (SMP and NUMA wise) and
slower to search.  And this populates the flow tables.

But that seems to work best on a per-cpu basis.

Unfortunately, it really doesn't address your problem in and of
itself.  This is because flow entries, especially when used on
sockets, would still get accessed by other cpus and thus nodes.
We would need to build something on top of the per-cpu flowcache,
such as the socket node array idea, to get something that helps
this NUMA issue as well.

Just tossing out some forward looking ideas :)

To be honest, the unified flow cache idea has been tossed around
a lot, and it's still intellectual masterbation.  But then again,
so was the design for the IPSEC stuff we have now for several years.

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Thu, 23 Sep 2004 12:16:51 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923121651.51a58cf2.davem@davemloft.net>
References: <414DF11C.1080505@eurodev.net>
	<20040919215915.GB9573@gondor.apana.org.au>
	<1095633569.1047.107.camel@jzny.localdomain>
	<20040919231734.GA10124@gondor.apana.org.au>
	<1095647944.1046.206.camel@jzny.localdomain>
	<20040920025802.GA11567@gondor.apana.org.au>
	<1095683660.1047.254.camel@jzny.localdomain>
	<414F1E12.6010808@eurodev.net>
	<20040922000503.GA13218@gondor.apana.org.au>
	<4150E7E5.2000001@eurodev.net>
	<20040922045239.GA19573@gondor.apana.org.au>
	<1095854920.1047.64.camel@jzny.localdomain>
	<20040922105221.59a67d4b.davem@davemloft.net>
	<4152EE68.4030803@eurodev.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au, davem@redhat.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Pablo Neira <pablo@eurodev.net>
In-Reply-To: <4152EE68.4030803@eurodev.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 23 Sep 2004 17:40:24 +0200
Pablo Neira <pablo@eurodev.net> wrote:

> Initially we could allocate a skb with size NLMSG_GOODSIZE, then after 
> all the information has been added, we could use a function (skb_*) 
> which allocates a new buffer headroom, memcpy the old skb headroom and 
> release it, so we trim the useless part of the headroom. This make us 
> waste some extra jiffies with memcpy's but we could save same space in 
> the queue. Does such skb_* function exist?

No such function exists.

Such a function would need to modify skb->truesize and that is
very dangerous.  People using such a routine would need to be
_extremely_ careful since if the skb being worked on is on
a socket queue, changing skb->truesize is going to mess up
socket buffer accounting later when the skb gets freed
and the socket buffer space liberated.

That doesn't apply to what you're trying to do here, of course.

Simpler would be:

1) For each netlink socket, allocate a page, much like TCP sockets
   do.

2) Construct the netlink response in this page sized buffer,
   keeping track of how much of the page is actually used.

3) At the end, allocate the skb with the necessary length,
   copy into the skb from the page buffer.

4) Since the RTNL semaphore is held during the length of these
   operations, the per-socket page needs no locking.

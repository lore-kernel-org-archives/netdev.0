From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Fri, 14 Jan 2005 13:27:57 -0800
Message-ID: <20050114132757.4ca3153a.davem@davemloft.net>
References: <20050113171234.3fde0925.davem@davemloft.net>
	<20050114012504.GF6309@krispykreme.ozlabs.ibm.com>
	<20050113201914.46b7c4a2.davem@davemloft.net>
	<20050114111648.GA27964@gondor.apana.org.au>
	<20050114120322.GA28449@gondor.apana.org.au>
	<20050114110352.23c94ab9.davem@davemloft.net>
	<20050114203452.GA1277@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050114203452.GA1277@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 15 Jan 2005 07:34:52 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> My reasoning is as follows:
> 
> The size of the skb is bounded by the MSS.  Therefore it can
> never grow beyond that.  So if we allocated that much memory
> then we can tack bits on as long as we don't exceed the original
> MSS that was used.
> 
> The problem before was that the MSS could've changed between
> sendpages calls.  If it increased then we may exceed the
> amount of memory allocated originally.
> 
> My idea is to remember the original MSS so that we never exceed
> it.  Did I missing something?

You missed the whole problem.

It has nothing to do with the MSS changing.

The bug case is when _SEND_MSG_ creates the SKB, and a subsequent
_SEND_PAGE_ call adds pages onto that SKB in the queue.

Unlike _SEND_PAGE_, _SEND_MSG_ does not do the "allocate tp->mss_cache"
thingy.  Instead, it adjusts the queueing allocation values as it copies
the data into the SKB.

Therefore my change aims to make _SEND_PAGE_ use _SEND_MSG_'s accounting
scheme (adjust as we actually add the data) so that it all works out.

That fix is in Linus's tree at this point.

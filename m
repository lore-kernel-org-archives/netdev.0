From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [DEBUG]: sk_forward_alloc assertion failures
Date: Sat, 15 Jan 2005 08:55:04 +1100
Message-ID: <20050114215504.GA12569@gondor.apana.org.au>
References: <20050113171234.3fde0925.davem@davemloft.net> <20050114012504.GF6309@krispykreme.ozlabs.ibm.com> <20050113201914.46b7c4a2.davem@davemloft.net> <20050114111648.GA27964@gondor.apana.org.au> <20050114120322.GA28449@gondor.apana.org.au> <20050114110352.23c94ab9.davem@davemloft.net> <20050114203452.GA1277@gondor.apana.org.au> <20050114132757.4ca3153a.davem@davemloft.net> <20050114213829.GA12454@gondor.apana.org.au> <20050114133611.69ff0bb2.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: anton@samba.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050114133611.69ff0bb2.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 14, 2005 at 01:36:11PM -0800, David S. Miller wrote:
> 
> MSS changes are handled _transparently_ if we do the adjustments
> as we actaully add data to the packet.  We always account what is
> actually put into the packet in this way.
> 
> That's why I made the fix the way that I did.

You're right.  However, doing so requires us to check sk_forward_alloc
every time around the loop.  That is, you'll need to do the same check
as is done in sk_stream_alloc_pskb and sk_stream_alloc_page.  If we
simply adjust sk_forward_alloc as you do now then it can easily go
negative if we didn't have enough memory to start with.

My point is that most of the time sendpages will produce a packet that
is MSS-sized.  Therefore we can avoid the duplicate work (if the
connection is at full throttle then MSS ~~ 64K which is much bigger
than the page size of 4K) by allocating MSS bytes up front in
sk_forward_alloc.

As long as we're careful about what we've allocated in the skb then
everything will be alright.  We're in trouble right now with mixed
sendmsg/sendpages calls and changing MSSs only because we're not
careful about keeping track of how much memory we've allocated
at the start.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [IPV6] Fix memory leaks in TCP error path
Date: Fri, 5 Nov 2004 16:18:20 -0800
Message-ID: <20041105161820.5c9bd53b.davem@davemloft.net>
References: <20041105084904.GA8253@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20041105084904.GA8253@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 5 Nov 2004 19:49:04 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> I've gone through all the xfrm_lookup() calls in net/ipv6 and I haven't
> seen anything that can cause an underflow.  I did find a couple of
> memory leaks though.
> 
> In tcp_ipv6.c we may leak skb's if xfrm_lookup fails.

This patch actually adds a leak with the way xfrm_lookup() is currently
coded.

 	/* sk = NULL, but it is safe for now. RST socket required. */
-	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
-
-		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
-			dst_release(buff->dst);
-			return;
-		}
-
+	if (!ip6_dst_lookup(NULL, &buff->dst, &fl) &&
+	    !xfrm_lookup(&buff->dst, &fl, NULL, 0)) {

To recount from yesterday's analysis, xfrm_lookup() behaves
two different ways on error return:

1) Release 'dst' and set &dst to NULL
2) Leave 'dst' alone and also do not modify &dst

This means that to cover all cases you have to have the dst_release()
there in that "if (xfrm_lookup()<0)" code path in order to handle
case #2 above.

We can get rid of the dst_release() calls only once the xfrm_lookup()
patch I posted yesterday is included, which as per your advice today
I'm not going to include until we've figured out the dst underflow
problem :-)

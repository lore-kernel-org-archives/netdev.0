From: "David S. Miller" <davem@redhat.com>
Subject: Re: [ROUTE] PMTU only works on half the time
Date: Mon, 1 Dec 2003 14:21:31 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031201142131.5da50a07.davem@redhat.com>
References: <20031201201651.GA20194@gondor.apana.org.au>
	<20031201204700.GA20349@gondor.apana.org.au>
	<20031201135154.6906454c.davem@redhat.com>
	<20031201220509.GA20827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20031201220509.GA20827@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, 2 Dec 2003 09:05:09 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Dec 01, 2003 at 01:51:54PM -0800, David S. Miller wrote:
> > 
> > Herbert, do you see how the outer loop and the skey[] thing works in
> > this PMTU handling code?  This takes care of comparing both iph->saddr
> > and '0' against rt->rt_src.
> 
> It only takes care of fl4_src, not rt_src.

Indeed.

At the surface it looks like a bug, but look at the redirect handling
tests in ip_rt_redirect().  It's a very similar key comparison as
the PMTU code, just structured differently:

            if (rth->fl.fl4_dst != daddr ||
                rth->fl.fl4_src != skeys[i] ||
                rth->fl.fl4_tos != tos ||
                rth->fl.oif != ikeys[k] ||
                rth->fl.iif != 0) {
                    rthp = &rth->u.rt_next;
                    continue;
            }

            if (rth->rt_dst != daddr ||
                rth->rt_src != saddr ||
                rth->u.dst.error ||
                rth->rt_gateway != old_gw ||
                rth->u.dst.dev != dev)
                    break;

See?  He's not comparing rt->rt_src against skeys[] and therefore '0'
here either.

I think the tests might be like this for a reason.

I could see Alexey constructing this test wrong in one instance, but
in two instances where the tests were structured totally different in
each case is hard to believe.

Let me think about this some more, maybe you're right and the
error exists in both of these places.

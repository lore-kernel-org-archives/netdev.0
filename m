From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH] Fix double dereference (Re: IPv6 badness continues)
Date: Sat, 8 Jan 2005 14:24:21 +1100
Message-ID: <20050108032421.GA1427@gondor.apana.org.au>
References: <41DA3A60.8050102@pobox.com> <20050107.111806.27181187.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.com, davem@davemloft.net, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "YOSHIFUJI Hideaki / ?$B5HF#1QL@" <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <20050107.111806.27181187.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jan 07, 2005 at 11:18:06AM +0900, YOSHIFUJI Hideaki / ?$B5HF#1QL@ wrote:
> 
> I think we should NOT release refcnt in sk_dst_check() (or its variants)
> even we return NULL because that reference was held for sk->dst_cache
> and it is available yet. Instead, we should release refcnt when we 
> really reset the dst in sk_dst_reset() (or its variants).
> (Alternatively, we may always set sk->dst_cache to NULL and release 
> refcnt when we're about to return NULL in sk_dst_check()
> (or its variants).)

I think the current approach is safe.  The reason is that sk_dst_cache
has its own reference which gets dropped in __sk_dst_reset.  So even
though ip6_dst_check has dropped a refcnt, it should not hit zero unless
there is a bug somewhere else.

> ===== net/decnet/dn_route.c 1.29 vs edited =====
> --- 1.29/net/decnet/dn_route.c	2004-11-10 09:44:25 +09:00
> +++ edited/net/decnet/dn_route.c	2005-01-04 17:14:01 +09:00
> @@ -253,7 +253,6 @@
>   */
>  static struct dst_entry *dn_dst_check(struct dst_entry *dst, __u32 cookie)
>  {
> -	dst_release(dst);
>  	return NULL;
>  }

This patch is not going to work unless you drop the refcnt somewhere
else.  This refcnt is the one given by the caller of sk_dst_check.
So someone needs to drop it.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

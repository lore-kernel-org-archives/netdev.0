From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Sat, 20 Mar 2004 08:05:25 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040319210525.GA479@gondor.apana.org.au>
References: <20040308110331.GA20719@gondor.apana.org.au> <404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com> <4059CF17.8090907@trash.net> <20040319115130.GE29066@gondor.apana.org.au> <405B2132.6060403@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
Content-Disposition: inline
In-Reply-To: <405B2132.6060403@trash.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 19, 2004 at 05:34:58PM +0100, Patrick McHardy wrote:
> Herbert Xu wrote:
> >On Thu, Mar 18, 2004 at 05:32:23PM +0100, Patrick McHardy wrote:
> >
> >>@@ -635,7 +636,6 @@
> >>#ifdef CONFIG_IP_ROUTE_FWMARK
> >>		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
> >>#endif
> >>-		fl.proto = iph->protocol;
> >
> >
> >Better call __ip_route_output_key rather than not setting proto because
> >you'll need proto in xfrm_lookup.

Right, you're calling decode_session below which is much better.

> >>@@ -661,6 +661,20 @@
> >>	
> >>	if ((*pskb)->dst->error)
> >>		return -1;
> >>+
> >>+#ifdef CONFIG_XFRM
> >>+	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)) {
> >>+		struct xfrm_policy_afinfo *afinfo;
> >>+
> >>+		afinfo = xfrm_policy_get_afinfo(AF_INET);
> >>+		if (afinfo != NULL) {
> >>+			afinfo->decode_session(*pskb, &fl);
> >>+			xfrm_policy_put_afinfo(afinfo);
> >>+			if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0) 
> >>!= 0)
> >>+				return -1;
> >>+		}
> >>+	}
> >>+#endif
> >
> >
> >If we can reinject transport packets then we can move this back into
> >the if clause.
> 
> I don't understand the relationship to transport mode packets. I used an

Actually it was me who was confused.  ip_route_me_harder can be called
on both incoming/outgoing packets.  That's what the if clause is trying
to determine.  You should only call xfrm_lookup on the outgoing path.

So this should be moved back to the if clause above:

		fl.proto = iph->protocol;
		lookup = __ip_route_output_key;
#ifdef CONFIG_XFRM
		if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)) {
			lookup = ip_route_output_key;
			do_decode
		}
#endif
		if (lookup(&rt, &fl) != 0)
			return -1;
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

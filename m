From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Tue, 31 Aug 2004 18:23:39 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831082339.GA949@gondor.apana.org.au>
References: <20040830191915.04d49268.davem@davemloft.net> <E1C1yRs-00086x-00@gondolin.me.apana.org.au> <20040830223920.1db0d5ae.davem@davemloft.net> <20040831064337.GA32614@gondor.apana.org.au> <20040831070043.GA320@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Cc: laforge@netfilter.org, netfilter-devel@lists.netfilter.org,
        rusty@rustcorp.com.au, netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20040831070043.GA320@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 31, 2004 at 05:00:43PM +1000, herbert wrote:
> 
> Here's a better idea.  Why don't we forget about the route lookup
> and call inet_select_addr directly?

Even better, why don't we use the skb->dst directly? It already
contains the preferred source for the route that led us to the
device.

Here is an untested patch which does exactly that? Please do your
best to break it :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/netfilter/ipt_MASQUERADE.c 1.16 vs edited =====
--- 1.16/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-08-02 12:27:11 +10:00
+++ edited/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-08-31 18:21:41 +10:00
@@ -97,34 +97,13 @@
 
 	mr = targinfo;
 
-	{
-		struct flowi fl = { .nl_u = { .ip4_u =
-					      { .daddr = (*pskb)->nh.iph->daddr,
-						.tos = (RT_TOS((*pskb)->nh.iph->tos) |
-							RTO_CONN),
-#ifdef CONFIG_IP_ROUTE_FWMARK
-						.fwmark = (*pskb)->nfmark
-#endif
-					      } } };
-		if (ip_route_output_key(&rt, &fl) != 0) {
-			/* Funky routing can do this. */
-			if (net_ratelimit())
-				printk("MASQUERADE:"
-				       " No route: Rusty's brain broke!\n");
-			return NF_DROP;
-		}
-		if (rt->u.dst.dev != out) {
-			if (net_ratelimit())
-				printk("MASQUERADE:"
-				       " Route sent us somewhere else.\n");
-			ip_rt_put(rt);
-			return NF_DROP;
-		}
-	}
+	rt = (struct rtable *)(*pskb)->dst;
+	if (rt->fl.iif)
+		newsrc = rt->rt_spec_dst;
+	else
+		newsrc = rt->rt_src;
 
-	newsrc = rt->rt_src;
 	DEBUGP("newsrc = %u.%u.%u.%u\n", NIPQUAD(newsrc));
-	ip_rt_put(rt);
 
 	WRITE_LOCK(&masq_lock);
 	ct->nat.masq_index = out->ifindex;

--J2SCkAp4GZ/dPZZf--

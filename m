From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere else")
Date: Tue, 31 Aug 2004 20:12:03 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040831101203.GA1951@gondor.apana.org.au>
References: <20040831082339.GA949@gondor.apana.org.au> <Pine.LNX.4.44.0408311208500.1773-100000@l>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
Cc: "David S. Miller" <davem@davemloft.net>, laforge@netfilter.org,
        netfilter-devel@lists.netfilter.org, rusty@rustcorp.com.au,
        netdev@oss.sgi.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0408311208500.1773-100000@l>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 31, 2004 at 12:41:35PM +0300, Julian Anastasov wrote:
>
> > Here is an untested patch which does exactly that? Please do your
> > best to break it :)
> 
> 	No need for tests :) rt_spec_dst is your preferred src
> to the sender (your local internal IP) and rt_src is the internal
> IP of the sender (what we snat).

I knew it can't be that easy :)

So let's go back to the previous idea of using inet_select_addr?
Can you find any problems with this? In fact, it seems that the
2.2 compatibility code does exactly this.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/netfilter/ipt_MASQUERADE.c 1.16 vs edited =====
--- 1.16/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-08-02 12:27:11 +10:00
+++ edited/net/ipv4/netfilter/ipt_MASQUERADE.c	2004-08-31 20:08:47 +10:00
@@ -97,34 +97,12 @@
 
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
+	newsrc = inet_select_addr(out, rt->rt_gateway, RT_SCOPE_LINK);
+	if (!newsrc)
+		return NF_DROP;
 
-	newsrc = rt->rt_src;
 	DEBUGP("newsrc = %u.%u.%u.%u\n", NIPQUAD(newsrc));
-	ip_rt_put(rt);
 
 	WRITE_LOCK(&masq_lock);
 	ct->nat.masq_index = out->ifindex;

--YZ5djTAD1cGYuMQK--

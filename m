From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [24/*] [IPSEC] Get ttl from child instead of path
Date: Fri, 18 Mar 2005 21:07:57 +1100
Message-ID: <20050318100757.GA29433@gondor.apana.org.au>
References: <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318091918.GA28944@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="CE+1k2dSO48ffgeK"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050318091918.GA28944@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Now that dst_pmtu is almost gone let's do the same to dst_path_metric.
I've only found one legitimate use of it and that's the one that was
recently added in dst_allfrag.

This patch makes xfrm4_encap/xfrm6_encap use dst->child instead of
dst->path so that we choose the correct route to get the hoplimit
from when nested tunnels are present.

For simple tunnels dst->child == dst->path so there is no change.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--CE+1k2dSO48ffgeK
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-24

===== net/ipv4/xfrm4_output.c 1.9 vs edited =====
--- 1.9/net/ipv4/xfrm4_output.c	2005-03-15 16:38:41 +11:00
+++ edited/net/ipv4/xfrm4_output.c	2005-03-18 21:02:33 +11:00
@@ -58,7 +58,7 @@
 	if (!top_iph->frag_off)
 		__ip_select_ident(top_iph, dst, 0);
 
-	top_iph->ttl = dst_path_metric(dst, RTAX_HOPLIMIT);
+	top_iph->ttl = dst_metric(dst->child, RTAX_HOPLIMIT);
 
 	top_iph->saddr = x->props.saddr.a4;
 	top_iph->daddr = x->id.daddr.a4;
===== net/ipv6/xfrm6_output.c 1.10 vs edited =====
--- 1.10/net/ipv6/xfrm6_output.c	2005-03-15 16:38:41 +11:00
+++ edited/net/ipv6/xfrm6_output.c	2005-03-18 21:02:46 +11:00
@@ -69,7 +69,7 @@
 		dsfield &= ~INET_ECN_MASK;
 	ipv6_change_dsfield(top_iph, 0, dsfield);
 	top_iph->nexthdr = IPPROTO_IPV6; 
-	top_iph->hop_limit = dst_path_metric(dst, RTAX_HOPLIMIT);
+	top_iph->hop_limit = dst_metric(dst->child, RTAX_HOPLIMIT);
 	ipv6_addr_copy(&top_iph->saddr, (struct in6_addr *)&x->props.saddr);
 	ipv6_addr_copy(&top_iph->daddr, (struct in6_addr *)&x->id.daddr);
 }

--CE+1k2dSO48ffgeK--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [26/*] [NET] Kill dst_pmtu/dst_path_metric
Date: Fri, 18 Mar 2005 22:06:11 +1100
Message-ID: <20050318110611.GA5843@gondor.apana.org.au>
References: <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au> <20050318091918.GA28944@gondor.apana.org.au> <20050318100757.GA29433@gondor.apana.org.au> <20050318101126.GA29583@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="azLHFNyN32YCQGCU"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050318101126.GA29583@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This would have been the patch that removed dst->path.  But
ip_append_data got in the way :)

However, using dst->path is only needed rarely and should always
require a bit of deliberation.  So let's get rid of dst_pmtu
and dst_path_metric and use dst_mtu and dst_metric directly.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

BTW, shouldn't dst_allfrag be called dst_path_allfrag?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--azLHFNyN32YCQGCU
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-26

===== include/net/dst.h 1.29 vs edited =====
--- 1.29/include/net/dst.h	2005-03-11 13:17:32 +11:00
+++ edited/include/net/dst.h	2005-03-18 21:08:56 +11:00
@@ -109,21 +109,6 @@
 	return dst->metrics[metric-1];
 }
 
-static inline u32
-dst_path_metric(const struct dst_entry *dst, int metric)
-{
-	return dst->path->metrics[metric-1];
-}
-
-static inline u32
-dst_pmtu(const struct dst_entry *dst)
-{
-	u32 mtu = dst_path_metric(dst, RTAX_MTU);
-	/* Yes, _exactly_. This is paranoia. */
-	barrier();
-	return mtu;
-}
-
 static inline u32 dst_mtu(const struct dst_entry *dst)
 {
 	u32 mtu = dst_metric(dst, RTAX_MTU);
@@ -137,7 +122,7 @@
 static inline u32
 dst_allfrag(const struct dst_entry *dst)
 {
-	int ret = dst_path_metric(dst, RTAX_FEATURES) & RTAX_FEATURE_ALLFRAG;
+	int ret = dst_metric(dst->path, RTAX_FEATURES) & RTAX_FEATURE_ALLFRAG;
 	/* Yes, _exactly_. This is paranoia. */
 	barrier();
 	return ret;
===== net/ipv4/ip_output.c 1.79 vs edited =====
--- 1.79/net/ipv4/ip_output.c	2005-03-17 09:02:36 +11:00
+++ edited/net/ipv4/ip_output.c	2005-03-18 21:00:08 +11:00
@@ -746,7 +746,7 @@
 			inet->cork.addr = ipc->addr;
 		}
 		dst_hold(&rt->u.dst);
-		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
+		inet->cork.fragsize = mtu = dst_mtu(rt->u.dst.path);
 		inet->cork.rt = rt;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
===== net/ipv6/ip6_output.c 1.89 vs edited =====
--- 1.89/net/ipv6/ip6_output.c	2005-03-17 09:02:36 +11:00
+++ edited/net/ipv6/ip6_output.c	2005-03-18 21:00:08 +11:00
@@ -850,7 +850,7 @@
 		np->cork.rt = rt;
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
-		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
+		inet->cork.fragsize = mtu = dst_mtu(rt->u.dst.path);
 		if (dst_allfrag(&rt->u.dst))
 			inet->cork.flags |= IPCORK_ALLFRAG;
 		inet->cork.length = 0;

--azLHFNyN32YCQGCU--

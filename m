From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPV6] Fix memory leaks in TCP error path
Date: Fri, 5 Nov 2004 19:49:04 +1100
Message-ID: <20041105084904.GA8253@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="NzB8fVQJ5HfG6fxh"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, netdev@oss.sgi.com
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

I've gone through all the xfrm_lookup() calls in net/ipv6 and I haven't
seen anything that can cause an underflow.  I did find a couple of
memory leaks though.

In tcp_ipv6.c we may leak skb's if xfrm_lookup fails.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--NzB8fVQJ5HfG6fxh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/tcp_ipv6.c 1.100 vs edited =====
--- 1.100/net/ipv6/tcp_ipv6.c	2004-11-02 11:48:28 +11:00
+++ edited/net/ipv6/tcp_ipv6.c	2004-11-05 19:44:56 +11:00
@@ -1045,13 +1045,8 @@
 	fl.fl_ip_sport = t1->source;
 
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
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 		TCP_INC_STATS_BH(TCP_MIB_OUTRSTS);
@@ -1113,11 +1108,8 @@
 	fl.fl_ip_dport = t1->dest;
 	fl.fl_ip_sport = t1->source;
 
-	if (!ip6_dst_lookup(NULL, &buff->dst, &fl)) {
-		if ((xfrm_lookup(&buff->dst, &fl, NULL, 0)) < 0) {
-			dst_release(buff->dst);
-			return;
-		}
+	if (!ip6_dst_lookup(NULL, &buff->dst, &fl) &&
+	    !xfrm_lookup(&buff->dst, &fl, NULL, 0)) {
 		ip6_xmit(NULL, buff, &fl, NULL, 0);
 		TCP_INC_STATS_BH(TCP_MIB_OUTSEGS);
 		return;

--NzB8fVQJ5HfG6fxh--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [TCP] Fix tcp_current_mss when MTU changes
Date: Fri, 24 Sep 2004 09:45:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040923234552.GA4846@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

There is a small bug in tcp_current_mss where it can return the real
MSS when MTU changes even if the TSO MSS is what is intended.  This
patch fixes it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/tcp.h 1.88 vs edited =====
--- 1.88/include/net/tcp.h	2004-09-15 06:57:07 +10:00
+++ edited/include/net/tcp.h	2004-09-24 09:35:22 +10:00
@@ -1049,17 +1049,20 @@
 	struct dst_entry *dst = __sk_dst_get(sk);
 	int do_large, mss_now;
 
-	do_large = (large &&
-		    (sk->sk_route_caps & NETIF_F_TSO) &&
-		    !tp->urg_mode);
-	mss_now = do_large ? tp->mss_cache : tp->mss_cache_std;
-
+	mss_now = tp->mss_cache_std;
 	if (dst) {
 		u32 mtu = dst_pmtu(dst);
 		if (mtu != tp->pmtu_cookie ||
 		    tp->ext2_header_len != dst->header_len)
 			mss_now = tcp_sync_mss(sk, mtu);
 	}
+
+	do_large = (large &&
+		    (sk->sk_route_caps & NETIF_F_TSO) &&
+		    !tp->urg_mode);
+	if (do_large)
+		mss_now = tp->mss_cache;
+
 	if (tp->eff_sacks)
 		mss_now -= (TCPOLEN_SACK_BASE_ALIGNED +
 			    (tp->eff_sacks * TCPOLEN_SACK_PERBLOCK));

--C7zPtVaVf+AK4Oqc--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [15/*] [INET] Fix IPsec calculation in ip_append_data/ip6_append_data
Date: Tue, 15 Mar 2005 20:19:04 +1100
Message-ID: <20050315091904.GA6256@gondor.apana.org.au>
References: <20050214221006.GA18415@gondor.apana.org.au> <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="bg08WKrSYDhXBjb5"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050314111002.GA29156@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch fixes the IPsec overhead handling in ip_append_data and
ip6_append_data.  As it is they assume that the IPsec overhead is
constant.  This is not true as with ESP the IPsec overhead will vary
as the MTU varies.

The result is that they may produce packets that will exceed the MTU
when ESP is used.  Had it taken the trailer_len into account, it would
have produced packets less than the real MTU.

By switching to dst_mtu we get the optimal result.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--bg08WKrSYDhXBjb5
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-15

===== net/ipv4/ip_output.c 1.76 vs edited =====
--- 1.76/net/ipv4/ip_output.c	2005-02-01 02:43:53 +11:00
+++ edited/net/ipv4/ip_output.c	2005-03-15 20:13:13 +11:00
@@ -719,7 +719,6 @@
 
 	struct ip_options *opt = NULL;
 	int hh_len;
-	int exthdrlen;
 	int mtu;
 	int copy;
 	int err;
@@ -746,22 +745,17 @@
 			inet->cork.addr = ipc->addr;
 		}
 		dst_hold(&rt->u.dst);
-		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
+		inet->cork.fragsize = mtu = dst_mtu(&rt->u.dst);
 		inet->cork.rt = rt;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
-		if ((exthdrlen = rt->u.dst.header_len) != 0) {
-			length += exthdrlen;
-			transhdrlen += exthdrlen;
-		}
 	} else {
 		rt = inet->cork.rt;
 		if (inet->cork.flags & IPCORK_OPT)
 			opt = inet->cork.opt;
 
 		transhdrlen = 0;
-		exthdrlen = 0;
 		mtu = inet->cork.fragsize;
 	}
 	hh_len = LL_RESERVED_SPACE(rt->u.dst.dev);
@@ -770,7 +764,7 @@
 	maxfraglen = ((mtu - fragheaderlen) & ~7) + fragheaderlen;
 
 	if (inet->cork.length + length > 0xFFFF - fragheaderlen) {
-		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu-exthdrlen);
+		ip_local_error(sk, EMSGSIZE, rt->rt_dst, inet->dport, mtu);
 		return -EMSGSIZE;
 	}
 
@@ -781,7 +775,7 @@
 	if (transhdrlen &&
 	    length + fragheaderlen <= mtu &&
 	    rt->u.dst.dev->features&(NETIF_F_IP_CSUM|NETIF_F_NO_CSUM|NETIF_F_HW_CSUM) &&
-	    !exthdrlen)
+	    !rt->u.dst.header_len)
 		csummode = CHECKSUM_HW;
 
 	inet->cork.length += length;
@@ -866,9 +860,9 @@
 			 *	Find where to start putting bytes.
 			 */
 			data = skb_put(skb, fraglen);
-			skb->nh.raw = data + exthdrlen;
+			skb->nh.raw = data;
 			data += fragheaderlen;
-			skb->h.raw = data + exthdrlen;
+			skb->h.raw = data;
 
 			if (fraggap) {
 				skb->csum = skb_copy_and_csum_bits(
@@ -890,7 +884,6 @@
 			offset += copy;
 			length -= datalen - fraggap;
 			transhdrlen = 0;
-			exthdrlen = 0;
 			csummode = CHECKSUM_NONE;
 
 			/*
===== net/ipv6/ip6_output.c 1.85 vs edited =====
--- 1.85/net/ipv6/ip6_output.c	2005-03-03 16:12:38 +11:00
+++ edited/net/ipv6/ip6_output.c	2005-03-15 20:12:15 +11:00
@@ -849,13 +849,13 @@
 		np->cork.rt = rt;
 		inet->cork.fl = *fl;
 		np->cork.hop_limit = hlimit;
-		inet->cork.fragsize = mtu = dst_pmtu(&rt->u.dst);
+		inet->cork.fragsize = mtu = dst_mtu(&rt->u.dst);
 		if (dst_allfrag(&rt->u.dst))
 			inet->cork.flags |= IPCORK_ALLFRAG;
 		inet->cork.length = 0;
 		sk->sk_sndmsg_page = NULL;
 		sk->sk_sndmsg_off = 0;
-		exthdrlen = rt->u.dst.header_len + (opt ? opt->opt_flen : 0);
+		exthdrlen = opt ? opt->opt_flen : 0;
 		length += exthdrlen;
 		transhdrlen += exthdrlen;
 	} else {

--bg08WKrSYDhXBjb5--

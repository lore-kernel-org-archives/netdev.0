From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [16/*] [INET] Take IPsec overhead into account in tunnels
Date: Tue, 15 Mar 2005 20:58:37 +1100
Message-ID: <20050315095837.GA7130@gondor.apana.org.au>
References: <20050214221200.GA18465@gondor.apana.org.au> <20050214221433.GB18465@gondor.apana.org.au> <20050214221607.GC18465@gondor.apana.org.au> <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="XsQoSWH+UP9D9v3l"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050315091904.GA6256@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch uses dst_mtu instead of dst_pmtu in the various tunnel
implementations.  As it is they simply ignore the IPsec overhead.
This leads to bogus MTU values inside the tunnels.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

BTW, we're doing lazy MTU updates in the tunnel xmit functions.
When a packet with DF set hits us and exceeds the updated MTU,
we will send an ICMP packet back which is good.

Unfortunately when a packet with DF clear hits us as we update
the MTU downwards, the packet will be silently discarded instead
of fragmented (well we will send an ICMP back to ourselves but
we already knew that MTU value :).

I presume we want to fix this, right?
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--XsQoSWH+UP9D9v3l
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-16

===== net/ipv4/ip_gre.c 1.47 vs edited =====
--- 1.47/net/ipv4/ip_gre.c	2005-03-10 16:12:11 +11:00
+++ edited/net/ipv4/ip_gre.c	2005-03-15 20:19:26 +11:00
@@ -511,7 +511,7 @@
 
 	/* change mtu on this route */
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		if (rel_info > dst_pmtu(skb2->dst)) {
+		if (rel_info > dst_mtu(skb2->dst)) {
 			kfree_skb(skb2);
 			return;
 		}
@@ -764,9 +764,9 @@
 
 	df = tiph->frag_off;
 	if (df)
-		mtu = dst_pmtu(&rt->u.dst) - tunnel->hlen;
+		mtu = dst_mtu(&rt->u.dst) - tunnel->hlen;
 	else
-		mtu = skb->dst ? dst_pmtu(skb->dst) : dev->mtu;
+		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
 
 	if (skb->dst)
 		skb->dst->ops->update_pmtu(skb->dst, mtu);
@@ -785,7 +785,7 @@
 	else if (skb->protocol == htons(ETH_P_IPV6)) {
 		struct rt6_info *rt6 = (struct rt6_info*)skb->dst;
 
-		if (rt6 && mtu < dst_pmtu(skb->dst) && mtu >= IPV6_MIN_MTU) {
+		if (rt6 && mtu < dst_mtu(skb->dst) && mtu >= IPV6_MIN_MTU) {
 			if ((tunnel->parms.iph.daddr && !MULTICAST(tunnel->parms.iph.daddr)) ||
 			    rt6->rt6i_dst.plen == 128) {
 				rt6->rt6i_flags |= RTF_MODIFIED;
===== net/ipv4/ipip.c 1.46 vs edited =====
--- 1.46/net/ipv4/ipip.c	2005-01-14 15:41:05 +11:00
+++ edited/net/ipv4/ipip.c	2005-03-15 20:19:26 +11:00
@@ -436,7 +436,7 @@
 
 	/* change mtu on this route */
 	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		if (rel_info > dst_pmtu(skb2->dst)) {
+		if (rel_info > dst_mtu(skb2->dst)) {
 			kfree_skb(skb2);
 			return;
 		}
@@ -569,9 +569,9 @@
 	}
 
 	if (tiph->frag_off)
-		mtu = dst_pmtu(&rt->u.dst) - sizeof(struct iphdr);
+		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
 	else
-		mtu = skb->dst ? dst_pmtu(skb->dst) : dev->mtu;
+		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
 
 	if (mtu < 68) {
 		tunnel->stat.collisions++;
===== net/ipv6/ip6_tunnel.c 1.29 vs edited =====
--- 1.29/net/ipv6/ip6_tunnel.c	2005-03-11 13:17:32 +11:00
+++ edited/net/ipv6/ip6_tunnel.c	2005-03-15 20:19:26 +11:00
@@ -689,14 +689,14 @@
 			       t->parms.name);
 		goto tx_err_dst_release;
 	}
-	mtu = dst_pmtu(dst) - sizeof (*ipv6h);
+	mtu = dst_mtu(dst) - sizeof (*ipv6h);
 	if (opt) {
 		max_headroom += 8;
 		mtu -= 8;
 	}
 	if (mtu < IPV6_MIN_MTU)
 		mtu = IPV6_MIN_MTU;
-	if (skb->dst && mtu < dst_pmtu(skb->dst)) {
+	if (skb->dst && mtu < dst_mtu(skb->dst)) {
 		struct rt6_info *rt = (struct rt6_info *) skb->dst;
 		rt->rt6i_flags |= RTF_MODIFIED;
 		rt->u.dst.metrics[RTAX_MTU-1] = mtu;
===== net/ipv6/sit.c 1.45 vs edited =====
--- 1.45/net/ipv6/sit.c	2005-01-14 15:41:06 +11:00
+++ edited/net/ipv6/sit.c	2005-03-15 20:19:27 +11:00
@@ -500,9 +500,9 @@
 	}
 
 	if (tiph->frag_off)
-		mtu = dst_pmtu(&rt->u.dst) - sizeof(struct iphdr);
+		mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
 	else
-		mtu = skb->dst ? dst_pmtu(skb->dst) : dev->mtu;
+		mtu = skb->dst ? dst_mtu(skb->dst) : dev->mtu;
 
 	if (mtu < 68) {
 		tunnel->stat.collisions++;

--XsQoSWH+UP9D9v3l--

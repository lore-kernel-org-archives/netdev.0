From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [23/*] [IPV4] Kill remaining unnecessary uses of dst_pmtu
Date: Fri, 18 Mar 2005 20:19:18 +1100
Message-ID: <20050318091918.GA28944@gondor.apana.org.au>
References: <20050306213214.7d8a143d.davem@davemloft.net> <20050307103536.GB7137@gondor.apana.org.au> <20050308102741.GA23468@gondor.apana.org.au> <20050314102614.GA9610@gondor.apana.org.au> <20050314105313.GA21001@gondor.apana.org.au> <20050314111002.GA29156@gondor.apana.org.au> <20050315091904.GA6256@gondor.apana.org.au> <20050315095837.GA7130@gondor.apana.org.au> <20050318090310.GA28443@gondor.apana.org.au> <20050318091129.GA28658@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="rwEMma7ioTxnRzrJ"
Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20050318091129.GA28658@gondor.apana.org.au>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

Once again here is a couple of trivial dst_pmtu/dst_mtu replacements.
In both locations, we can only have simple dst entries which means
that dst == dst->path.

BTW, this is the rule that we should apply in future for uses of
dst_mtu/dst_pmtu (or other metrics on dst).  If the only dst's that
can appear are simple dst's (dst == dst->path), then we should use
dst_mtu or dst_metric.  If dst != dst->path, then whoever is writing
the code will need to think about which of dst or dst->path is the
right one.

In most instances dst will be the one.  However, as we have seen in
ip_append_data, dst->path may be needed rarely.  In particular, if
we're doing fragmentation immediately after IPsec, then you may need
it.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
 
Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--rwEMma7ioTxnRzrJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=xfrm-23

===== net/ipv4/ipvs/ip_vs_xmit.c 1.12 vs edited =====
--- 1.12/net/ipv4/ipvs/ip_vs_xmit.c	2005-03-11 13:17:32 +11:00
+++ edited/net/ipv4/ipvs/ip_vs_xmit.c	2005-03-18 19:56:34 +11:00
@@ -178,7 +178,7 @@
 	}
 
 	/* MTU checking */
-	mtu = dst_pmtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->u.dst);
 	if ((skb->len > mtu) && (iph->frag_off&__constant_htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
@@ -245,7 +245,7 @@
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_pmtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->u.dst);
 	if ((skb->len > mtu) && (iph->frag_off&__constant_htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
@@ -342,7 +342,7 @@
 
 	tdev = rt->u.dst.dev;
 
-	mtu = dst_pmtu(&rt->u.dst) - sizeof(struct iphdr);
+	mtu = dst_mtu(&rt->u.dst) - sizeof(struct iphdr);
 	if (mtu < 68) {
 		ip_rt_put(rt);
 		IP_VS_DBG_RL("ip_vs_tunnel_xmit(): mtu less than 68\n");
@@ -445,7 +445,7 @@
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_pmtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->u.dst);
 	if ((iph->frag_off&__constant_htons(IP_DF)) && skb->len > mtu) {
 		icmp_send(skb, ICMP_DEST_UNREACH,ICMP_FRAG_NEEDED, htonl(mtu));
 		ip_rt_put(rt);
@@ -520,7 +520,7 @@
 		goto tx_error_icmp;
 
 	/* MTU checking */
-	mtu = dst_pmtu(&rt->u.dst);
+	mtu = dst_mtu(&rt->u.dst);
 	if ((skb->len > mtu) && (skb->nh.iph->frag_off&__constant_htons(IP_DF))) {
 		ip_rt_put(rt);
 		icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
===== net/ipv4/netfilter/ip_conntrack_standalone.c 1.66 vs edited =====
--- 1.66/net/ipv4/netfilter/ip_conntrack_standalone.c	2005-03-04 09:17:07 +11:00
+++ edited/net/ipv4/netfilter/ip_conntrack_standalone.c	2005-03-18 19:56:34 +11:00
@@ -457,7 +457,7 @@
 	/* Local packets are never produced too large for their
 	   interface.  We degfragment them at LOCAL_OUT, however,
 	   so we have to refragment them here. */
-	if ((*pskb)->len > dst_pmtu(&rt->u.dst) &&
+	if ((*pskb)->len > dst_mtu(&rt->u.dst) &&
 	    !skb_shinfo(*pskb)->tso_size) {
 		/* No hook can be after us, so this should be OK. */
 		ip_fragment(*pskb, okfn);

--rwEMma7ioTxnRzrJ--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IP6IP6] Handle ECN correctly
Date: Thu, 9 Sep 2004 13:45:08 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040909034508.GA19547@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="UlVJffcvxoiEqYs2"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>,
        YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>, vnourval@tcs.hut.fi,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch adds ECN encapsulation/decapsulation to ip6_tunnel.c.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--UlVJffcvxoiEqYs2
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/ip6_tunnel.c 1.23 vs edited =====
--- 1.23/net/ipv6/ip6_tunnel.c	2004-06-22 07:34:06 +10:00
+++ edited/net/ipv6/ip6_tunnel.c	2004-09-09 13:34:19 +10:00
@@ -48,6 +48,8 @@
 #include <net/addrconf.h>
 #include <net/ip6_tunnel.h>
 #include <net/xfrm.h>
+#include <net/dsfield.h>
+#include <net/inet_ecn.h>
 
 MODULE_AUTHOR("Ville Nuorvala");
 MODULE_DESCRIPTION("IPv6-in-IPv6 tunnel");
@@ -490,6 +492,15 @@
 	read_unlock(&ip6ip6_lock);
 }
 
+static inline void ip6ip6_ecn_decapsulate(struct ipv6hdr *outer_iph,
+					  struct sk_buff *skb)
+{
+	struct ipv6hdr *inner_iph = skb->nh.ipv6h;
+
+	if (INET_ECN_is_ce(ipv6_get_dsfield(outer_iph)))
+		IP6_ECN_set_ce(inner_iph);
+}
+
 /**
  * ip6ip6_rcv - decapsulate IPv6 packet and retransmit it locally
  *   @skb: received socket buffer
@@ -531,6 +542,7 @@
 		skb->dev = t->dev;
 		dst_release(skb->dst);
 		skb->dst = NULL;
+		ip6ip6_ecn_decapsulate(ipv6h, skb);
 		t->stat.rx_packets++;
 		t->stat.rx_bytes += skb->len;
 		netif_rx(skb);
@@ -621,6 +633,7 @@
 	u8 proto;
 	int err;
 	int pkt_len;
+	int dsfield;
 
 	if (t->recursion++) {
 		stats->collisions++;
@@ -646,6 +659,7 @@
 	memcpy(&fl, &t->fl, sizeof (fl));
 	proto = fl.proto;
 
+	dsfield = ipv6_get_dsfield(ipv6h);
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_TCLASS))
 		fl.fl6_flowlabel |= (*(__u32 *) ipv6h & IPV6_TCLASS_MASK);
 	if ((t->parms.flags & IP6_TNL_F_USE_ORIG_FLOWLABEL))
@@ -717,6 +731,8 @@
 	skb->nh.raw = skb_push(skb, sizeof(struct ipv6hdr));
 	ipv6h = skb->nh.ipv6h;
 	*(u32*)ipv6h = fl.fl6_flowlabel | htonl(0x60000000);
+	dsfield = INET_ECN_encapsulate(0, dsfield);
+	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
 	ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;

--UlVJffcvxoiEqYs2--

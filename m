From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [IPSEC] Move hardware headers for decaped packets
Date: Sat, 14 Feb 2004 14:55:34 +1100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040214035534.GA25965@gondor.apana.org.au>
References: <20030925121131.GA17968@gondor.apana.org.au> <200309251228.QAA11650@yakov.inr.ac.ru> <20030925124102.GA18188@gondor.apana.org.au> <20031207090205.GA2358@gondor.apana.org.au> <20031207014714.03e79cd2.davem@redhat.com> <20031207095527.GA2767@gondor.apana.org.au> <20031207165516.1edfde10.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="VS++wcV0S1rZb1Fb"
Cc: kuznet@ms2.inr.ac.ru, jmorris@redhat.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20031207165516.1edfde10.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Sun, Dec 07, 2003 at 04:55:16PM -0800, David S. Miller wrote:
> 
> Ok, we can make it a receive only thing at first, I guess.
> 
> But I think this will definitely need to be deferred to
> 2.6.1 at least, along with that XFRM device unload fix you
> sent me the other week.

Looks like I've forgotten about this mac moving patch.  Here it is again.

Just to recap, this moves the hardware header so that it appears
next to the payload for AF_PACKET sockets.

Cheers,
-- 
Debian GNU/Linux 3.0 is out! ( http://www.debian.org/ )
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--VS++wcV0S1rZb1Fb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

Index: include/linux/skbuff.h
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/include/linux/skbuff.h,v
retrieving revision 1.1.1.8
retrieving revision 1.6
diff -u -r1.1.1.8 -r1.6
--- include/linux/skbuff.h	9 Aug 2003 08:12:03 -0000	1.1.1.8
+++ include/linux/skbuff.h	13 Sep 2003 00:11:55 -0000	1.6
@@ -159,6 +161,7 @@
  *	@cb: Control buffer. Free for use by every layer. Put private vars here
  *	@len: Length of actual data
  *	@data_len: Data length
+ *	@mac_len: Length of link layer header
  *	@csum: Checksum
  *	@__unused: Dead field, may be reused
  *	@cloned: Head may be cloned (check refcnt to be sure)
@@ -199,6 +202,7 @@
 		struct icmphdr	*icmph;
 		struct igmphdr	*igmph;
 		struct iphdr	*ipiph;
+		struct ipv6hdr	*ipv6h;
 		unsigned char	*raw;
 	} h;
 
@@ -227,6 +231,7 @@
 
 	unsigned int		len,
 				data_len,
+				mac_len,
 				csum;
 	unsigned char		local_df,
 				cloned,
Index: net/core/dev.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/core/dev.c,v
retrieving revision 1.1.1.17
retrieving revision 1.2
diff -u -r1.1.1.17 -r1.2
--- net/core/dev.c	22 Aug 2003 23:56:14 -0000	1.1.1.17
+++ net/core/dev.c	13 Sep 2003 00:11:55 -0000	1.2
@@ -1547,6 +1547,7 @@
 #endif
 
 	skb->h.raw = skb->nh.raw = skb->data;
+	skb->mac_len = skb->nh.raw - skb->mac.raw;
 
 	pt_prev = NULL;
 	rcu_read_lock();
Index: net/ipv4/xfrm4_input.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv4/xfrm4_input.c,v
retrieving revision 1.1.1.6
retrieving revision 1.9
diff -u -r1.1.1.6 -r1.9
--- net/ipv4/xfrm4_input.c	22 Aug 2003 23:52:18 -0000	1.1.1.6
+++ net/ipv4/xfrm4_input.c	13 Sep 2003 00:11:55 -0000	1.9
@@ -9,6 +9,7 @@
  * 	
  */
 
+#include <linux/string.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/xfrm.h>
@@ -18,9 +19,10 @@
 	return xfrm4_rcv_encap(skb, 0);
 }
 
-static inline void ipip_ecn_decapsulate(struct iphdr *outer_iph, struct sk_buff *skb)
+static inline void ipip_ecn_decapsulate(struct sk_buff *skb)
 {
-	struct iphdr *inner_iph = skb->nh.iph;
+	struct iphdr *outer_iph = skb->nh.iph;
+	struct iphdr *inner_iph = skb->h.ipiph;
 
 	if (INET_ECN_is_ce(outer_iph->tos) &&
 	    INET_ECN_is_not_ce(inner_iph->tos))
@@ -95,10 +97,16 @@
 		if (x->props.mode) {
 			if (iph->protocol != IPPROTO_IPIP)
 				goto drop;
-			skb->nh.raw = skb->data;
+			if (!pskb_may_pull(skb, sizeof(struct iphdr)))
+				goto drop;
+			if (skb_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto drop;
 			if (!(x->props.flags & XFRM_STATE_NOECN))
-				ipip_ecn_decapsulate(iph, skb);
-			iph = skb->nh.iph;
+				ipip_ecn_decapsulate(skb);
+			skb->mac.raw = memmove(skb->data - skb->mac_len,
+					       skb->mac.raw, skb->mac_len);
+			skb->nh.raw = skb->data;
 			memset(&(IPCB(skb)->opt), 0, sizeof(struct ip_options));
 			decaps = 1;
 			break;
Index: net/ipv6/xfrm6_input.c
===================================================================
RCS file: /home/gondolin/herbert/src/CVS/debian/kernel-source-2.5/net/ipv6/xfrm6_input.c,v
retrieving revision 1.1.1.7
retrieving revision 1.8
diff -u -r1.1.1.7 -r1.8
--- net/ipv6/xfrm6_input.c	9 Aug 2003 08:12:04 -0000	1.1.1.7
+++ net/ipv6/xfrm6_input.c	13 Sep 2003 00:11:55 -0000	1.8
@@ -9,17 +9,20 @@
  *		IPv6 support
  */
 
+#include <linux/string.h>
 #include <net/inet_ecn.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
 #include <net/xfrm.h>
 
-static inline void ipip6_ecn_decapsulate(struct ipv6hdr *iph,
-					 struct sk_buff *skb)
+static inline void ipip6_ecn_decapsulate(struct sk_buff *skb)
 {
-	if (INET_ECN_is_ce(ip6_get_dsfield(iph)) &&
-	    INET_ECN_is_not_ce(ip6_get_dsfield(skb->nh.ipv6h)))
-		IP6_ECN_set_ce(skb->nh.ipv6h);
+	struct ipv6hdr *outer_iph = skb->nh.ipv6h;
+	struct ipv6hdr *inner_iph = skb->h.ipv6h;
+
+	if (INET_ECN_is_ce(ip6_get_dsfield(outer_iph)) &&
+	    INET_ECN_is_not_ce(ip6_get_dsfield(inner_iph)))
+		IP6_ECN_set_ce(inner_iph);
 }
 
 int xfrm6_rcv(struct sk_buff **pskb, unsigned int *nhoffp)
@@ -77,10 +80,16 @@
 		if (x->props.mode) { /* XXX */
 			if (nexthdr != IPPROTO_IPV6)
 				goto drop;
-			skb->nh.raw = skb->data;
+			if (!pskb_may_pull(skb, sizeof(struct ipv6hdr)))
+				goto drop;
+			if (skb_cloned(skb) &&
+			    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
+				goto drop;
 			if (!(x->props.flags & XFRM_STATE_NOECN))
-				ipip6_ecn_decapsulate(iph, skb);
-			iph = skb->nh.ipv6h;
+				ipip6_ecn_decapsulate(skb);
+			skb->mac.raw = memmove(skb->data - skb->mac_len,
+					       skb->mac.raw, skb->mac_len);
+			skb->nh.raw = skb->data;
 			decaps = 1;
 			break;
 		}

--VS++wcV0S1rZb1Fb--

From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 18/24] [IPV6]: Add ip6_local_out
Date: Wed, 07 Nov 2007 22:08:34 +0800
Message-ID: <E1Ipla6-0001IG-00@gondolin.me.apana.org.au>
References: <20071107140701.GA4685@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:3780 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757896AbXKGO0r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Nov 2007 09:26:47 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV6]: Add ip6_local_out

Most callers of the LOCAL_OUT chain will set the IP packet length
before doing so.  They also share the same output function dst_output.

This patch creates a new function called ip6_local_out which does all
of that and converts the appropriate users over to it.

Apart from removing duplicate code, it will also help in merging the
IPsec output path.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/net/ipv6.h               |    7 +++++++
 net/ipv6/ip6_output.c            |   35 +++++++++++++++++++++++++++++------
 net/ipv6/ip6_tunnel.c            |    4 +---
 net/ipv6/netfilter/ip6t_REJECT.c |    4 +---
 net/ipv6/xfrm6_output.c          |    7 +------
 5 files changed, 39 insertions(+), 18 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ae328b6..5078605 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -509,6 +509,13 @@ extern int			ip6_forward(struct sk_buff *skb);
 extern int			ip6_input(struct sk_buff *skb);
 extern int			ip6_mc_input(struct sk_buff *skb);
 
+extern int			__ip6_local_out(struct sk_buff *skb);
+#ifdef CONFIG_NETFILTER
+extern int			ip6_local_out(struct sk_buff *skb);
+#else
+#define ip6_local_out		__ip6_local_out
+#endif
+
 /*
  *	Extension header (options) processing
  */
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 698d9d2..a0a366f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -29,7 +29,7 @@
  */
 
 #include <linux/errno.h>
-#include <linux/types.h>
+#include <linux/kernel.h>
 #include <linux/string.h>
 #include <linux/socket.h>
 #include <linux/net.h>
@@ -70,6 +70,33 @@ static __inline__ void ipv6_select_ident(struct sk_buff *skb, struct frag_hdr *f
 	spin_unlock_bh(&ip6_id_lock);
 }
 
+int __ip6_local_out(struct sk_buff *skb)
+{
+	int len;
+
+	len = skb->len - sizeof(struct ipv6hdr);
+	if (len > IPV6_MAXPLEN)
+		len = 0;
+	ipv6_hdr(skb)->payload_len = htons(len);
+
+	return nf_hook(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev,
+		       dst_output);
+}
+
+#ifdef CONFIG_NETFILTER
+int ip6_local_out(struct sk_buff *skb)
+{
+	int err;
+
+	err = __ip6_local_out(skb);
+	if (likely(err == 1))
+		err = dst_output(skb);
+
+	return err;
+}
+#endif
+EXPORT_SYMBOL_GPL(ip6_local_out);
+
 static int ip6_output_finish(struct sk_buff *skb)
 {
 	struct dst_entry *dst = skb->dst;
@@ -1388,10 +1415,6 @@ int ip6_push_pending_frames(struct sock *sk)
 	*(__be32*)hdr = fl->fl6_flowlabel |
 		     htonl(0x60000000 | ((int)np->cork.tclass << 20));
 
-	if (skb->len <= sizeof(struct ipv6hdr) + IPV6_MAXPLEN)
-		hdr->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
-	else
-		hdr->payload_len = 0;
 	hdr->hop_limit = np->cork.hop_limit;
 	hdr->nexthdr = proto;
 	ipv6_addr_copy(&hdr->saddr, &fl->fl6_src);
@@ -1408,7 +1431,7 @@ int ip6_push_pending_frames(struct sock *sk)
 		ICMP6_INC_STATS_BH(idev, ICMP6_MIB_OUTMSGS);
 	}
 
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL, skb->dst->dev, dst_output);
+	err = ip6_local_out(skb);
 	if (err) {
 		if (err > 0)
 			err = np->recverr ? net_xmit_errno(err) : 0;
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a4051af..29b5321 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -910,15 +910,13 @@ static int ip6_tnl_xmit2(struct sk_buff *skb,
 	*(__be32*)ipv6h = fl->fl6_flowlabel | htonl(0x60000000);
 	dsfield = INET_ECN_encapsulate(0, dsfield);
 	ipv6_change_dsfield(ipv6h, ~INET_ECN_MASK, dsfield);
-	ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	ipv6h->hop_limit = t->parms.hop_limit;
 	ipv6h->nexthdr = proto;
 	ipv6_addr_copy(&ipv6h->saddr, &fl->fl6_src);
 	ipv6_addr_copy(&ipv6h->daddr, &fl->fl6_dst);
 	nf_reset(skb);
 	pkt_len = skb->len;
-	err = NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL,
-		      skb->dst->dev, dst_output);
+	err = ip6_local_out(skb);
 
 	if (net_xmit_eval(err) == 0) {
 		stats->tx_bytes += pkt_len;
diff --git a/net/ipv6/netfilter/ip6t_REJECT.c b/net/ipv6/netfilter/ip6t_REJECT.c
index 1a7d291..c1c6634 100644
--- a/net/ipv6/netfilter/ip6t_REJECT.c
+++ b/net/ipv6/netfilter/ip6t_REJECT.c
@@ -121,7 +121,6 @@ static void send_reset(struct sk_buff *oldskb)
 	ip6h->version = 6;
 	ip6h->hop_limit = dst_metric(dst, RTAX_HOPLIMIT);
 	ip6h->nexthdr = IPPROTO_TCP;
-	ip6h->payload_len = htons(sizeof(struct tcphdr));
 	ipv6_addr_copy(&ip6h->saddr, &oip6h->daddr);
 	ipv6_addr_copy(&ip6h->daddr, &oip6h->saddr);
 
@@ -159,8 +158,7 @@ static void send_reset(struct sk_buff *oldskb)
 
 	nf_ct_attach(nskb, oldskb);
 
-	NF_HOOK(PF_INET6, NF_IP6_LOCAL_OUT, nskb, NULL, nskb->dst->dev,
-		dst_output);
+	ip6_local_out(nskb);
 }
 
 static inline void
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index c45050c..0f0ff51 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -75,16 +75,12 @@ EXPORT_SYMBOL(xfrm6_prepare_output);
 
 static inline int xfrm6_output_one(struct sk_buff *skb)
 {
-	struct ipv6hdr *iph;
 	int err;
 
 	err = xfrm_output(skb);
 	if (err)
 		goto error_nolock;
 
-	iph = ipv6_hdr(skb);
-	iph->payload_len = htons(skb->len - sizeof(*iph));
-
 	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 	err = 0;
 
@@ -102,8 +98,7 @@ static int xfrm6_output_finish2(struct sk_buff *skb)
 	while (likely((err = xfrm6_output_one(skb)) == 0)) {
 		nf_reset(skb);
 
-		err = nf_hook(PF_INET6, NF_IP6_LOCAL_OUT, skb, NULL,
-			      skb->dst->dev, dst_output);
+		err = __ip6_local_out(skb);
 		if (unlikely(err != 1))
 			break;
 

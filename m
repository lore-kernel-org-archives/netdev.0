From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/4] [IPV6]: Added GSO support for TCPv6
Date: Fri, 30 Jun 2006 15:43:00 +1000
Message-ID: <20060630054300.GA30149@gondor.apana.org.au>
References: <20060630054209.GA28558@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from [64.62.148.172] ([64.62.148.172]:60938 "EHLO arnor.apana.org.au")
	by vger.kernel.org with ESMTP id S1751119AbWF3Foi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 01:44:38 -0400
To: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Ananda Raju <Ananda.Raju@neterion.com>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060630054209.GA28558@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[IPV6]: Added GSO support for TCPv6

This patch adds GSO support for IPv6 and TCPv6.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/net/protocol.h b/include/net/protocol.h
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -50,11 +50,17 @@ struct inet6_protocol 
 			       struct inet6_skb_parm *opt,
 			       int type, int code, int offset,
 			       __u32 info);
+
+	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
+				       int features);
+
 	unsigned int	flags;	/* INET6_PROTO_xxx */
 };
 
 #define INET6_PROTO_NOPOLICY	0x1
 #define INET6_PROTO_FINAL	0x2
+/* This should be set for any extension header which is compatible with GSO. */
+#define INET6_PROTO_GSO_EXTHDR	0x4
 #endif
 
 /* This is used to register socket interfaces for IP protocols.  */
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2215,6 +2215,7 @@ struct sk_buff *tcp_tso_segment(struct s
 out:
 	return segs;
 }
+EXPORT_SYMBOL(tcp_tso_segment);
 
 extern void __skb_cb_too_small_for_tcp(int, int);
 extern struct tcp_congestion_ops tcp_reno;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -179,7 +179,7 @@ static int ipv6_destopt_rcv(struct sk_bu
 
 static struct inet6_protocol destopt_protocol = {
 	.handler	=	ipv6_destopt_rcv,
-	.flags		=	INET6_PROTO_NOPOLICY,
+	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
 };
 
 void __init ipv6_destopt_init(void)
@@ -340,7 +340,7 @@ looped_back:
 
 static struct inet6_protocol rthdr_protocol = {
 	.handler	=	ipv6_rthdr_rcv,
-	.flags		=	INET6_PROTO_NOPOLICY,
+	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
 };
 
 void __init ipv6_rthdr_init(void)
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -58,9 +58,71 @@
 
 DEFINE_SNMP_STAT(struct ipstats_mib, ipv6_statistics) __read_mostly;
 
+static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct ipv6hdr *ipv6h;
+	struct inet6_protocol *ops;
+	int proto;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
+		goto out;
+
+	ipv6h = skb->nh.ipv6h;
+	proto = ipv6h->nexthdr;
+	__skb_pull(skb, sizeof(*ipv6h));
+
+	rcu_read_lock();
+	for (;;) {
+		struct ipv6_opt_hdr *opth;
+		int len;
+
+		if (proto != NEXTHDR_HOP) {
+			ops = rcu_dereference(inet6_protos[proto]);
+
+			if (unlikely(!ops))
+				goto unlock;
+
+			if (!(ops->flags & INET6_PROTO_GSO_EXTHDR))
+				break;
+		}
+
+		if (unlikely(!pskb_may_pull(skb, 8)))
+			goto unlock;
+
+		opth = (void *)skb->data;
+		len = opth->hdrlen * 8 + 8;
+
+		if (unlikely(!pskb_may_pull(skb, len)))
+			goto unlock;
+
+		proto = opth->nexthdr;
+		__skb_pull(skb, len);
+	}
+
+	skb->h.raw = skb->data;
+	if (likely(ops->gso_segment))
+		segs = ops->gso_segment(skb, features);
+
+unlock:
+	rcu_read_unlock();
+
+	if (unlikely(IS_ERR(segs)))
+		goto out;
+
+	for (skb = segs; skb; skb = skb->next) {
+		ipv6h = skb->nh.ipv6h;
+		ipv6h->payload_len = htons(skb->len - skb->mac_len);
+	}
+
+out:
+	return segs;
+}
+
 static struct packet_type ipv6_packet_type = {
 	.type = __constant_htons(ETH_P_IPV6), 
 	.func = ipv6_rcv,
+	.gso_segment = ipv6_gso_segment,
 };
 
 struct ip6_ra_chain *ip6_ra_chain;
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1605,6 +1605,7 @@ struct proto tcpv6_prot = {
 static struct inet6_protocol tcpv6_protocol = {
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
+	.gso_segment	=	tcp_tso_segment,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 

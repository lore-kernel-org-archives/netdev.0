From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [1/2] ipv6: Add GRO support
Date: Wed, 7 Jan 2009 14:14:04 +1100
Message-ID: <20090107031404.GA16827@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:44511 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751838AbZAGDOI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Jan 2009 22:14:08 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave:

Give an inch and take a mile, parity with LRO just isn't enough :)
I've tested it locally and it does work.

ipv6: Add GRO support

This patch adds GRO support for IPv6.  IPv6 GRO supports extension
headers in the same way as GSO (by using the same infrastructure).
It's also simpler compared to IPv4 since we no longer have to worry
about fragmentation attributes or header checksums.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/net/protocol.h b/include/net/protocol.h
index cb2965a..ffa5b8b 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -59,6 +59,9 @@ struct inet6_protocol
 	int	(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
 				       int features);
+	struct sk_buff **(*gro_receive)(struct sk_buff **head,
+					struct sk_buff *skb);
+	int	(*gro_complete)(struct sk_buff *skb);
 
 	unsigned int	flags;	/* INET6_PROTO_xxx */
 };
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 437b750..94f74f5 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -672,8 +672,7 @@ int ipv6_opt_accepted(struct sock *sk, struct sk_buff *skb)
 
 EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
-static struct inet6_protocol *ipv6_gso_pull_exthdrs(struct sk_buff *skb,
-						    int proto)
+static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 {
 	struct inet6_protocol *ops = NULL;
 
@@ -704,7 +703,7 @@ static struct inet6_protocol *ipv6_gso_pull_exthdrs(struct sk_buff *skb,
 		__skb_pull(skb, len);
 	}
 
-	return ops;
+	return proto;
 }
 
 static int ipv6_gso_send_check(struct sk_buff *skb)
@@ -721,7 +720,9 @@ static int ipv6_gso_send_check(struct sk_buff *skb)
 	err = -EPROTONOSUPPORT;
 
 	rcu_read_lock();
-	ops = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
+	ops = rcu_dereference(inet6_protos[
+		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
+
 	if (likely(ops && ops->gso_send_check)) {
 		skb_reset_transport_header(skb);
 		err = ops->gso_send_check(skb);
@@ -757,7 +758,9 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
 	segs = ERR_PTR(-EPROTONOSUPPORT);
 
 	rcu_read_lock();
-	ops = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
+	ops = rcu_dereference(inet6_protos[
+		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
+
 	if (likely(ops && ops->gso_segment)) {
 		skb_reset_transport_header(skb);
 		segs = ops->gso_segment(skb, features);
@@ -777,11 +780,105 @@ out:
 	return segs;
 }
 
+struct ipv6_gro_cb {
+	struct napi_gro_cb napi;
+	int proto;
+};
+
+#define IPV6_GRO_CB(skb) ((struct ipv6_gro_cb *)(skb)->cb)
+
+static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
+					 struct sk_buff *skb)
+{
+	struct inet6_protocol *ops;
+	struct sk_buff **pp = NULL;
+	struct sk_buff *p;
+	struct ipv6hdr *iph;
+	unsigned int nlen;
+	int flush = 1;
+	int proto;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
+		goto out;
+
+	iph = ipv6_hdr(skb);
+	__skb_pull(skb, sizeof(*iph));
+
+	flush += ntohs(iph->payload_len) != skb->len;
+
+	rcu_read_lock();
+	proto = ipv6_gso_pull_exthdrs(skb, iph->nexthdr);
+	IPV6_GRO_CB(skb)->proto = proto;
+	ops = rcu_dereference(inet6_protos[proto]);
+	if (!ops || !ops->gro_receive)
+		goto out_unlock;
+
+	flush--;
+	skb_reset_transport_header(skb);
+	nlen = skb_network_header_len(skb);
+
+	for (p = *head; p; p = p->next) {
+		struct ipv6hdr *iph2;
+
+		if (!NAPI_GRO_CB(p)->same_flow)
+			continue;
+
+		iph2 = ipv6_hdr(p);
+
+		/* All fields must match except length. */
+		if (nlen != skb_network_header_len(p) ||
+		    memcmp(iph, iph2, offsetof(struct ipv6hdr, payload_len)) ||
+		    memcmp(&iph->nexthdr, &iph2->nexthdr,
+			   nlen - offsetof(struct ipv6hdr, nexthdr))) {
+			NAPI_GRO_CB(p)->same_flow = 0;
+			continue;
+		}
+
+		NAPI_GRO_CB(p)->flush |= flush;
+	}
+
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	pp = ops->gro_receive(head, skb);
+
+out_unlock:
+	rcu_read_unlock();
+
+out:
+	NAPI_GRO_CB(skb)->flush |= flush;
+
+	return pp;
+}
+
+static int ipv6_gro_complete(struct sk_buff *skb)
+{
+	struct inet6_protocol *ops;
+	struct ipv6hdr *iph = ipv6_hdr(skb);
+	int err = -ENOSYS;
+
+	iph->payload_len = htons(skb->len - skb_network_offset(skb) -
+				 sizeof(*iph));
+
+	rcu_read_lock();
+	ops = rcu_dereference(inet6_protos[IPV6_GRO_CB(skb)->proto]);
+	if (WARN_ON(!ops || !ops->gro_complete))
+		goto out_unlock;
+
+	err = ops->gro_complete(skb);
+
+out_unlock:
+	rcu_read_unlock();
+
+	return err;
+}
+
 static struct packet_type ipv6_packet_type = {
 	.type = __constant_htons(ETH_P_IPV6),
 	.func = ipv6_rcv,
 	.gso_send_check = ipv6_gso_send_check,
 	.gso_segment = ipv6_gso_segment,
+	.gro_receive = ipv6_gro_receive,
+	.gro_complete = ipv6_gro_complete,
 };
 
 static int __init ipv6_packet_init(void)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

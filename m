From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [2/2] [NET] gso: Fix up GSO packets with broken checksums
Date: Sat, 8 Jul 2006 13:53:30 +1000
Message-ID: <20060708035330.GA5396@gondor.apana.org.au>
References: <20060708035301.GA5351@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:63499 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S932504AbWGHDxd
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Jul 2006 23:53:33 -0400
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Content-Disposition: inline
In-Reply-To: <20060708035301.GA5351@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi:

[NET] gso: Fix up GSO packets with broken checksums

Certain subsystems in the stack (e.g., netfilter) can break the partial
checksum on GSO packets.  Until they're fixed, this patch allows this to
work by recomputing the partial checksums through the GSO mechanism.

Once they've all been converted to update the partial checksum instead of
clearing it, this workaround can be removed.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -549,6 +549,7 @@ struct packet_type {
 					 struct net_device *);
 	struct sk_buff		*(*gso_segment)(struct sk_buff *skb,
 						int features);
+	int			(*gso_send_check)(struct sk_buff *skb);
 	void			*af_packet_priv;
 	struct list_head	list;
 };
@@ -1001,13 +1002,14 @@ static inline int net_gso_ok(int feature
 
 static inline int skb_gso_ok(struct sk_buff *skb, int features)
 {
-	return net_gso_ok(features, skb_is_gso(skb) ?
-				    skb_shinfo(skb)->gso_type : 0);
+	return net_gso_ok(features, skb_shinfo(skb)->gso_type);
 }
 
 static inline int netif_needs_gso(struct net_device *dev, struct sk_buff *skb)
 {
-	return !skb_gso_ok(skb, dev->features);
+	return skb_is_gso(skb) &&
+	       (!skb_gso_ok(skb, dev->features) ||
+		unlikely(skb->ip_summed != CHECKSUM_HW));
 }
 
 #endif /* __KERNEL__ */
diff --git a/include/net/protocol.h b/include/net/protocol.h
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -36,6 +36,7 @@
 struct net_protocol {
 	int			(*handler)(struct sk_buff *skb);
 	void			(*err_handler)(struct sk_buff *skb, u32 info);
+	int			(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff	       *(*gso_segment)(struct sk_buff *skb,
 					       int features);
 	int			no_policy;
@@ -51,6 +52,7 @@ struct inet6_protocol 
 			       int type, int code, int offset,
 			       __u32 info);
 
+	int	(*gso_send_check)(struct sk_buff *skb);
 	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
 				       int features);
 
diff --git a/include/net/tcp.h b/include/net/tcp.h
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -1086,6 +1086,7 @@ extern struct request_sock_ops tcp_reque
 
 extern int tcp_v4_destroy_sock(struct sock *sk);
 
+extern int tcp_v4_gso_send_check(struct sk_buff *skb);
 extern struct sk_buff *tcp_tso_segment(struct sk_buff *skb, int features);
 
 #ifdef CONFIG_PROC_FS
diff --git a/net/core/dev.c b/net/core/dev.c
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1162,9 +1162,17 @@ int skb_checksum_help(struct sk_buff *sk
 	unsigned int csum;
 	int ret = 0, offset = skb->h.raw - skb->data;
 
-	if (inward) {
-		skb->ip_summed = CHECKSUM_NONE;
-		goto out;
+	if (inward)
+		goto out_set_summed;
+
+	if (unlikely(skb_shinfo(skb)->gso_size)) {
+		static int warned;
+
+		WARN_ON(!warned);
+		warned = 1;
+
+		/* Let GSO fix up the checksum. */
+		goto out_set_summed;
 	}
 
 	if (skb_cloned(skb)) {
@@ -1181,6 +1189,8 @@ int skb_checksum_help(struct sk_buff *sk
 	BUG_ON(skb->csum + 2 > offset);
 
 	*(u16*)(skb->h.raw + skb->csum) = csum_fold(csum);
+
+out_set_summed:
 	skb->ip_summed = CHECKSUM_NONE;
 out:	
 	return ret;
@@ -1201,17 +1211,35 @@ struct sk_buff *skb_gso_segment(struct s
 	struct sk_buff *segs = ERR_PTR(-EPROTONOSUPPORT);
 	struct packet_type *ptype;
 	int type = skb->protocol;
+	int err;
 
 	BUG_ON(skb_shinfo(skb)->frag_list);
-	BUG_ON(skb->ip_summed != CHECKSUM_HW);
 
 	skb->mac.raw = skb->data;
 	skb->mac_len = skb->nh.raw - skb->data;
 	__skb_pull(skb, skb->mac_len);
 
+	if (unlikely(skb->ip_summed != CHECKSUM_HW)) {
+		static int warned;
+
+		WARN_ON(!warned);
+		warned = 1;
+
+		if (skb_header_cloned(skb) &&
+		    (err = pskb_expand_head(skb, 0, 0, GFP_ATOMIC)))
+			return ERR_PTR(err);
+	}
+
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_base[ntohs(type) & 15], list) {
 		if (ptype->type == type && !ptype->dev && ptype->gso_segment) {
+			if (unlikely(skb->ip_summed != CHECKSUM_HW)) {
+				err = ptype->gso_send_check(skb);
+				segs = ERR_PTR(err);
+				if (err || skb_gso_ok(skb, features))
+					break;
+				__skb_push(skb, skb->data - skb->nh.raw);
+			}
 			segs = ptype->gso_segment(skb, features);
 			break;
 		}
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1097,6 +1097,40 @@ int inet_sk_rebuild_header(struct sock *
 
 EXPORT_SYMBOL(inet_sk_rebuild_header);
 
+static int inet_gso_send_check(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	struct net_protocol *ops;
+	int proto;
+	int ihl;
+	int err = -EINVAL;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*iph))))
+		goto out;
+
+	iph = skb->nh.iph;
+	ihl = iph->ihl * 4;
+	if (ihl < sizeof(*iph))
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, ihl)))
+		goto out;
+
+	skb->h.raw = __skb_pull(skb, ihl);
+	iph = skb->nh.iph;
+	proto = iph->protocol & (MAX_INET_PROTOS - 1);
+	err = -EPROTONOSUPPORT;
+
+	rcu_read_lock();
+	ops = rcu_dereference(inet_protos[proto]);
+	if (likely(ops && ops->gso_send_check))
+		err = ops->gso_send_check(skb);
+	rcu_read_unlock();
+
+out:
+	return err;
+}
+
 static struct sk_buff *inet_gso_segment(struct sk_buff *skb, int features)
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
@@ -1162,6 +1196,7 @@ static struct net_protocol igmp_protocol
 static struct net_protocol tcp_protocol = {
 	.handler =	tcp_v4_rcv,
 	.err_handler =	tcp_v4_err,
+	.gso_send_check = tcp_v4_gso_send_check,
 	.gso_segment =	tcp_tso_segment,
 	.no_policy =	1,
 };
@@ -1208,6 +1243,7 @@ static int ipv4_proc_init(void);
 static struct packet_type ip_packet_type = {
 	.type = __constant_htons(ETH_P_IP),
 	.func = ip_rcv,
+	.gso_send_check = inet_gso_send_check,
 	.gso_segment = inet_gso_segment,
 };
 
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -496,6 +496,24 @@ void tcp_v4_send_check(struct sock *sk, 
 	}
 }
 
+int tcp_v4_gso_send_check(struct sk_buff *skb)
+{
+	struct iphdr *iph;
+	struct tcphdr *th;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		return -EINVAL;
+
+	iph = skb->nh.iph;
+	th = skb->h.th;
+
+	th->check = 0;
+	th->check = ~tcp_v4_check(th, skb->len, iph->saddr, iph->daddr, 0);
+	skb->csum = offsetof(struct tcphdr, check);
+	skb->ip_summed = CHECKSUM_HW;
+	return 0;
+}
+
 /*
  *	This routine will send an RST to the other tcp.
  *
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -57,29 +57,11 @@
 
 DEFINE_SNMP_STAT(struct ipstats_mib, ipv6_statistics) __read_mostly;
 
-static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
+static struct inet6_protocol *ipv6_gso_pull_exthdrs(struct sk_buff *skb,
+						    int proto)
 {
-	struct sk_buff *segs = ERR_PTR(-EINVAL);
-	struct ipv6hdr *ipv6h;
-	struct inet6_protocol *ops;
-	int proto;
+	struct inet6_protocol *ops = NULL;
 
-	if (unlikely(skb_shinfo(skb)->gso_type &
-		     ~(SKB_GSO_UDP |
-		       SKB_GSO_DODGY |
-		       SKB_GSO_TCP_ECN |
-		       SKB_GSO_TCPV6 |
-		       0)))
-		goto out;
-
-	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
-		goto out;
-
-	ipv6h = skb->nh.ipv6h;
-	proto = ipv6h->nexthdr;
-	__skb_pull(skb, sizeof(*ipv6h));
-
-	rcu_read_lock();
 	for (;;) {
 		struct ipv6_opt_hdr *opth;
 		int len;
@@ -88,30 +70,80 @@ static struct sk_buff *ipv6_gso_segment(
 			ops = rcu_dereference(inet6_protos[proto]);
 
 			if (unlikely(!ops))
-				goto unlock;
+				break;
 
 			if (!(ops->flags & INET6_PROTO_GSO_EXTHDR))
 				break;
 		}
 
 		if (unlikely(!pskb_may_pull(skb, 8)))
-			goto unlock;
+			break;
 
 		opth = (void *)skb->data;
 		len = opth->hdrlen * 8 + 8;
 
 		if (unlikely(!pskb_may_pull(skb, len)))
-			goto unlock;
+			break;
 
 		proto = opth->nexthdr;
 		__skb_pull(skb, len);
 	}
 
-	skb->h.raw = skb->data;
-	if (likely(ops->gso_segment))
-		segs = ops->gso_segment(skb, features);
+	return ops;
+}
+
+static int ipv6_gso_send_check(struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+	struct inet6_protocol *ops;
+	int err = -EINVAL;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
+		goto out;
 
-unlock:
+	ipv6h = skb->nh.ipv6h;
+	__skb_pull(skb, sizeof(*ipv6h));
+	err = -EPROTONOSUPPORT;
+
+	rcu_read_lock();
+	ops = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
+	if (likely(ops && ops->gso_send_check)) {
+		skb->h.raw = skb->data;
+		err = ops->gso_send_check(skb);
+	}
+	rcu_read_unlock();
+
+out:
+	return err;
+}
+
+static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb, int features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	struct ipv6hdr *ipv6h;
+	struct inet6_protocol *ops;
+
+	if (unlikely(skb_shinfo(skb)->gso_type &
+		     ~(SKB_GSO_UDP |
+		       SKB_GSO_DODGY |
+		       SKB_GSO_TCP_ECN |
+		       SKB_GSO_TCPV6 |
+		       0)))
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
+		goto out;
+
+	ipv6h = skb->nh.ipv6h;
+	__skb_pull(skb, sizeof(*ipv6h));
+	segs = ERR_PTR(-EPROTONOSUPPORT);
+
+	rcu_read_lock();
+	ops = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
+	if (likely(ops && ops->gso_segment)) {
+		skb->h.raw = skb->data;
+		segs = ops->gso_segment(skb, features);
+	}
 	rcu_read_unlock();
 
 	if (unlikely(IS_ERR(segs)))
@@ -130,6 +162,7 @@ out:
 static struct packet_type ipv6_packet_type = {
 	.type = __constant_htons(ETH_P_IPV6), 
 	.func = ipv6_rcv,
+	.gso_send_check = ipv6_gso_send_check,
 	.gso_segment = ipv6_gso_segment,
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -552,6 +552,24 @@ static void tcp_v6_send_check(struct soc
 	}
 }
 
+static int tcp_v6_gso_send_check(struct sk_buff *skb)
+{
+	struct ipv6hdr *ipv6h;
+	struct tcphdr *th;
+
+	if (!pskb_may_pull(skb, sizeof(*th)))
+		return -EINVAL;
+
+	ipv6h = skb->nh.ipv6h;
+	th = skb->h.th;
+
+	th->check = 0;
+	th->check = ~csum_ipv6_magic(&ipv6h->saddr, &ipv6h->daddr, skb->len,
+				     IPPROTO_TCP, 0);
+	skb->csum = offsetof(struct tcphdr, check);
+	skb->ip_summed = CHECKSUM_HW;
+	return 0;
+}
 
 static void tcp_v6_send_reset(struct sk_buff *skb)
 {
@@ -1603,6 +1621,7 @@ struct proto tcpv6_prot = {
 static struct inet6_protocol tcpv6_protocol = {
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
+	.gso_send_check	=	tcp_v6_gso_send_check,
 	.gso_segment	=	tcp_tso_segment,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };

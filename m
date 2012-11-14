From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 06/13] ipv6: Switch to using new offload infrastructure.
Date: Tue, 13 Nov 2012 20:24:07 -0500
Message-ID: <1352856254-29667-7-git-send-email-vyasevic@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35647 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932377Ab2KNBY2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:28 -0500
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Switch IPv6 protocol to using the new GRO/GSO calls and data.

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 include/net/protocol.h |    8 --------
 net/ipv6/af_inet6.c    |   22 +++++++++++-----------
 net/ipv6/exthdrs.c     |   38 +++++++++++++++++++++++++++++++++++---
 net/ipv6/tcp_ipv6.c    |   17 ++++++++++-------
 net/ipv6/udp.c         |   11 ++++++++---
 5 files changed, 64 insertions(+), 32 deletions(-)

diff --git a/include/net/protocol.h b/include/net/protocol.h
index 3bb7051..7019c16 100644
--- a/include/net/protocol.h
+++ b/include/net/protocol.h
@@ -54,14 +54,6 @@ struct inet6_protocol {
 			       struct inet6_skb_parm *opt,
 			       u8 type, u8 code, int offset,
 			       __be32 info);
-
-	int	(*gso_send_check)(struct sk_buff *skb);
-	struct sk_buff *(*gso_segment)(struct sk_buff *skb,
-				       netdev_features_t features);
-	struct sk_buff **(*gro_receive)(struct sk_buff **head,
-					struct sk_buff *skb);
-	int	(*gro_complete)(struct sk_buff *skb);
-
 	unsigned int	flags;	/* INET6_PROTO_xxx */
 };
 
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 6e24517..eb63dac 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -701,14 +701,14 @@ EXPORT_SYMBOL_GPL(ipv6_opt_accepted);
 
 static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 {
-	const struct inet6_protocol *ops = NULL;
+	const struct net_offload *ops = NULL;
 
 	for (;;) {
 		struct ipv6_opt_hdr *opth;
 		int len;
 
 		if (proto != NEXTHDR_HOP) {
-			ops = rcu_dereference(inet6_protos[proto]);
+			ops = rcu_dereference(inet6_offloads[proto]);
 
 			if (unlikely(!ops))
 				break;
@@ -736,7 +736,7 @@ static int ipv6_gso_pull_exthdrs(struct sk_buff *skb, int proto)
 static int ipv6_gso_send_check(struct sk_buff *skb)
 {
 	const struct ipv6hdr *ipv6h;
-	const struct inet6_protocol *ops;
+	const struct net_offload *ops;
 	int err = -EINVAL;
 
 	if (unlikely(!pskb_may_pull(skb, sizeof(*ipv6h))))
@@ -747,7 +747,7 @@ static int ipv6_gso_send_check(struct sk_buff *skb)
 	err = -EPROTONOSUPPORT;
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet6_protos[
+	ops = rcu_dereference(inet6_offloads[
 		ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr)]);
 
 	if (likely(ops && ops->gso_send_check)) {
@@ -765,7 +765,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	struct ipv6hdr *ipv6h;
-	const struct inet6_protocol *ops;
+	const struct net_offload *ops;
 	int proto;
 	struct frag_hdr *fptr;
 	unsigned int unfrag_ip6hlen;
@@ -792,7 +792,7 @@ static struct sk_buff *ipv6_gso_segment(struct sk_buff *skb,
 
 	proto = ipv6_gso_pull_exthdrs(skb, ipv6h->nexthdr);
 	rcu_read_lock();
-	ops = rcu_dereference(inet6_protos[proto]);
+	ops = rcu_dereference(inet6_offloads[proto]);
 	if (likely(ops && ops->gso_segment)) {
 		skb_reset_transport_header(skb);
 		segs = ops->gso_segment(skb, features);
@@ -825,7 +825,7 @@ out:
 static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
-	const struct inet6_protocol *ops;
+	const struct net_offload *ops;
 	struct sk_buff **pp = NULL;
 	struct sk_buff *p;
 	struct ipv6hdr *iph;
@@ -852,7 +852,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 
 	rcu_read_lock();
 	proto = iph->nexthdr;
-	ops = rcu_dereference(inet6_protos[proto]);
+	ops = rcu_dereference(inet6_offloads[proto]);
 	if (!ops || !ops->gro_receive) {
 		__pskb_pull(skb, skb_gro_offset(skb));
 		proto = ipv6_gso_pull_exthdrs(skb, proto);
@@ -860,7 +860,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 		skb_reset_transport_header(skb);
 		__skb_push(skb, skb_gro_offset(skb));
 
-		ops = rcu_dereference(inet6_protos[proto]);
+		ops = rcu_dereference(inet6_offloads[proto]);
 		if (!ops || !ops->gro_receive)
 			goto out_unlock;
 
@@ -915,7 +915,7 @@ out:
 
 static int ipv6_gro_complete(struct sk_buff *skb)
 {
-	const struct inet6_protocol *ops;
+	const struct net_offload *ops;
 	struct ipv6hdr *iph = ipv6_hdr(skb);
 	int err = -ENOSYS;
 
@@ -923,7 +923,7 @@ static int ipv6_gro_complete(struct sk_buff *skb)
 				 sizeof(*iph));
 
 	rcu_read_lock();
-	ops = rcu_dereference(inet6_protos[NAPI_GRO_CB(skb)->proto]);
+	ops = rcu_dereference(inet6_offloads[NAPI_GRO_CB(skb)->proto]);
 	if (WARN_ON(!ops || !ops->gro_complete))
 		goto out_unlock;
 
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 8c01574..d5a807d 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -549,14 +549,44 @@ static const struct inet6_protocol nodata_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
+static int ipv6_exthdrs_offload_init(void)
+{
+	int ret;
+
+	ret = inet6_add_offload(&rthdr_offload, IPPROTO_ROUTING);
+	if (!ret)
+		goto out;
+
+	ret = inet6_add_offload(&dstopt_offload, IPPROTO_DSTOPTS);
+	if (!ret)
+		goto out_rt;
+
+out:
+	return ret;
+
+out_rt:
+	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
+	goto out;
+}
+
+static void ipv6_exthdrs_offload_exit(void)
+{
+	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
+	inet_del_offload(&rthdr_offload, IPPROTO_DSTOPTS);
+}
+
 int __init ipv6_exthdrs_init(void)
 {
 	int ret;
 
-	ret = inet6_add_protocol(&rthdr_protocol, IPPROTO_ROUTING);
+	ret = ipv6_exthdrs_offload_init();
 	if (ret)
 		goto out;
 
+	ret = inet6_add_protocol(&rthdr_protocol, IPPROTO_ROUTING);
+	if (ret)
+		goto out_offload;
+
 	ret = inet6_add_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
 	if (ret)
 		goto out_rthdr;
@@ -567,10 +597,12 @@ int __init ipv6_exthdrs_init(void)
 
 out:
 	return ret;
-out_rthdr:
-	inet6_del_protocol(&rthdr_protocol, IPPROTO_ROUTING);
 out_destopt:
 	inet6_del_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
+out_rthdr:
+	inet6_del_protocol(&rthdr_protocol, IPPROTO_ROUTING);
+out_offload:
+	ipv6_exthdrs_offload_exit();
 	goto out;
 };
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 8ce2c30..ac59c84 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -2063,10 +2063,6 @@ static const struct inet6_protocol tcpv6_protocol = {
 	.early_demux	=	tcp_v6_early_demux,
 	.handler	=	tcp_v6_rcv,
 	.err_handler	=	tcp_v6_err,
-	.gso_send_check	=	tcp_v6_gso_send_check,
-	.gso_segment	=	tcp_tso_segment,
-	.gro_receive	=	tcp6_gro_receive,
-	.gro_complete	=	tcp6_gro_complete,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
@@ -2113,10 +2109,14 @@ int __init tcpv6_init(void)
 {
 	int ret;
 
-	ret = inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP);
+	ret = inet6_add_offload(&tcpv6_offload, IPPROTO_TCP);
 	if (ret)
 		goto out;
 
+	ret = inet6_add_protocol(&tcpv6_protocol, IPPROTO_TCP);
+	if (ret)
+		goto out_offload;
+
 	/* register inet6 protocol */
 	ret = inet6_register_protosw(&tcpv6_protosw);
 	if (ret)
@@ -2128,10 +2128,12 @@ int __init tcpv6_init(void)
 out:
 	return ret;
 
-out_tcpv6_protocol:
-	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
 out_tcpv6_protosw:
 	inet6_unregister_protosw(&tcpv6_protosw);
+out_tcpv6_protocol:
+	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
+out_offload:
+	inet6_del_offload(&tcpv6_offload, IPPROTO_TCP);
 	goto out;
 }
 
@@ -2140,4 +2142,5 @@ void tcpv6_exit(void)
 	unregister_pernet_subsys(&tcpv6_net_ops);
 	inet6_unregister_protosw(&tcpv6_protosw);
 	inet6_del_protocol(&tcpv6_protocol, IPPROTO_TCP);
+	inet6_del_offload(&tcpv6_offload, IPPROTO_TCP);
 }
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index 3ad44e1..e4cc1f4 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -1438,8 +1438,6 @@ out:
 static const struct inet6_protocol udpv6_protocol = {
 	.handler	=	udpv6_rcv,
 	.err_handler	=	udpv6_err,
-	.gso_send_check =	udp6_ufo_send_check,
-	.gso_segment	=	udp6_ufo_fragment,
 	.flags		=	INET6_PROTO_NOPOLICY|INET6_PROTO_FINAL,
 };
 
@@ -1570,10 +1568,14 @@ int __init udpv6_init(void)
 {
 	int ret;
 
-	ret = inet6_add_protocol(&udpv6_protocol, IPPROTO_UDP);
+	ret = inet6_add_offload(&udpv6_offload, IPPROTO_UDP);
 	if (ret)
 		goto out;
 
+	ret = inet6_add_protocol(&udpv6_protocol, IPPROTO_UDP);
+	if (ret)
+		goto out_offload;
+
 	ret = inet6_register_protosw(&udpv6_protosw);
 	if (ret)
 		goto out_udpv6_protocol;
@@ -1582,6 +1584,8 @@ out:
 
 out_udpv6_protocol:
 	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
+out_offload:
+	inet6_del_offload(&udpv6_offload, IPPROTO_UDP);
 	goto out;
 }
 
@@ -1589,4 +1593,5 @@ void udpv6_exit(void)
 {
 	inet6_unregister_protosw(&udpv6_protosw);
 	inet6_del_protocol(&udpv6_protocol, IPPROTO_UDP);
+	inet6_del_offload(&udpv6_offload, IPPROTO_UDP);
 }
-- 
1.7.7.6

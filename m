From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/8] fou: Change ip_tunnel_encap to take net argument
Date: Thu, 16 Jun 2016 10:51:56 -0700
Message-ID: <1466099522-690741-3-git-send-email-tom@herbertland.com>
References: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:56087 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752587AbcFPRwZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jun 2016 13:52:25 -0400
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u5GHpiUX005853
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:24 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 23kyrn8bfq-1
	(version=TLSv1 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 16 Jun 2016 10:52:24 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.103.99.99) with ESMTP	id
 1476131033eb11e6b7aa0002c9dfb610-84cc2e0 for <netdev@vger.kernel.org>;	Thu,
 16 Jun 2016 10:52:23 -0700
In-Reply-To: <1466099522-690741-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a struct net argument to ip_tunnel_encap function and pass into
backend build_header functions. This give build_header function the
correct netns and so they don't have to fish for it in the skbuff.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/fou.h        |  4 ++--
 include/net/ip6_tunnel.h |  5 +++--
 include/net/ip_tunnels.h |  5 +++--
 net/ipv4/fou.c           | 18 ++++++++----------
 net/ipv6/fou6.c          |  8 ++++----
 5 files changed, 20 insertions(+), 20 deletions(-)

diff --git a/include/net/fou.h b/include/net/fou.h
index f5cc691..172995e 100644
--- a/include/net/fou.h
+++ b/include/net/fou.h
@@ -12,8 +12,8 @@ size_t fou_encap_hlen(struct ip_tunnel_encap *e);
 size_t gue_encap_hlen(struct ip_tunnel_encap *e);
 
 int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		       u8 *protocol, __be16 *sport, int type);
+		       u8 *protocol, __be16 *sport, int type, struct net *net);
 int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		       u8 *protocol, __be16 *sport, int type);
+		       u8 *protocol, __be16 *sport, int type, struct net *net);
 
 #endif
diff --git a/include/net/ip6_tunnel.h b/include/net/ip6_tunnel.h
index 43a5a0e..4d2a39a 100644
--- a/include/net/ip6_tunnel.h
+++ b/include/net/ip6_tunnel.h
@@ -60,7 +60,7 @@ struct ip6_tnl {
 struct ip6_tnl_encap_ops {
 	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
 	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
-			    u8 *protocol, struct flowi6 *fl6);
+			    u8 *protocol, struct flowi6 *fl6, struct net *net);
 };
 
 #ifdef CONFIG_INET
@@ -110,7 +110,8 @@ static inline int ip6_tnl_encap(struct sk_buff *skb, struct ip6_tnl *t,
 	rcu_read_lock();
 	ops = rcu_dereference(ip6tun_encaps[t->encap.type]);
 	if (likely(ops && ops->build_header))
-		ret = ops->build_header(skb, &t->encap, protocol, fl6);
+		ret = ops->build_header(skb, &t->encap, protocol, fl6,
+					dev_net(t->dev));
 	rcu_read_unlock();
 
 	return ret;
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 9222678..7594132 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -258,7 +258,7 @@ void ip_tunnel_setup(struct net_device *dev, int net_id);
 struct ip_tunnel_encap_ops {
 	size_t (*encap_hlen)(struct ip_tunnel_encap *e);
 	int (*build_header)(struct sk_buff *skb, struct ip_tunnel_encap *e,
-			    u8 *protocol, struct flowi4 *fl4);
+			    u8 *protocol, struct flowi4 *fl4, struct net *net);
 };
 
 #define MAX_IPTUN_ENCAP_OPS 8
@@ -309,7 +309,8 @@ static inline int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
 	rcu_read_lock();
 	ops = rcu_dereference(iptun_encaps[t->encap.type]);
 	if (likely(ops && ops->build_header))
-		ret = ops->build_header(skb, &t->encap, protocol, fl4);
+		ret = ops->build_header(skb, &t->encap, protocol, fl4,
+					dev_net(t->dev));
 	rcu_read_unlock();
 
 	return ret;
diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index 321d57f..9cd9168 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -875,7 +875,7 @@ static void fou_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 }
 
 int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		       u8 *protocol, __be16 *sport, int type)
+		       u8 *protocol, __be16 *sport, int type, struct net *net)
 {
 	int err;
 
@@ -883,22 +883,21 @@ int __fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 	if (err)
 		return err;
 
-	*sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
-						skb, 0, 0, false);
+	*sport = e->sport ? : udp_flow_src_port(net, skb, 0, 0, false);
 
 	return 0;
 }
 EXPORT_SYMBOL(__fou_build_header);
 
 int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		     u8 *protocol, struct flowi4 *fl4)
+		     u8 *protocol, struct flowi4 *fl4, struct net *net)
 {
 	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
 						       SKB_GSO_UDP_TUNNEL;
 	__be16 sport;
 	int err;
 
-	err = __fou_build_header(skb, e, protocol, &sport, type);
+	err = __fou_build_header(skb, e, protocol, &sport, type, net);
 	if (err)
 		return err;
 
@@ -909,7 +908,7 @@ int fou_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 EXPORT_SYMBOL(fou_build_header);
 
 int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		       u8 *protocol, __be16 *sport, int type)
+		       u8 *protocol, __be16 *sport, int type, struct net *net)
 {
 	struct guehdr *guehdr;
 	size_t hdrlen, optlen = 0;
@@ -931,8 +930,7 @@ int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 		return err;
 
 	/* Get source port (based on flow hash) before skb_push */
-	*sport = e->sport ? : udp_flow_src_port(dev_net(skb->dev),
-						skb, 0, 0, false);
+	*sport = e->sport ? : udp_flow_src_port(net, skb, 0, 0, false);
 
 	hdrlen = sizeof(struct guehdr) + optlen;
 
@@ -982,14 +980,14 @@ int __gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 EXPORT_SYMBOL(__gue_build_header);
 
 int gue_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		     u8 *protocol, struct flowi4 *fl4)
+		     u8 *protocol, struct flowi4 *fl4, struct net *net)
 {
 	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM ? SKB_GSO_UDP_TUNNEL_CSUM :
 						       SKB_GSO_UDP_TUNNEL;
 	__be16 sport;
 	int err;
 
-	err = __gue_build_header(skb, e, protocol, &sport, type);
+	err = __gue_build_header(skb, e, protocol, &sport, type, net);
 	if (err)
 		return err;
 
diff --git a/net/ipv6/fou6.c b/net/ipv6/fou6.c
index 9ea249b..e38a7b1 100644
--- a/net/ipv6/fou6.c
+++ b/net/ipv6/fou6.c
@@ -34,14 +34,14 @@ static void fou6_build_udp(struct sk_buff *skb, struct ip_tunnel_encap *e,
 }
 
 int fou6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		      u8 *protocol, struct flowi6 *fl6)
+		      u8 *protocol, struct flowi6 *fl6, struct net *net)
 {
 	__be16 sport;
 	int err;
 	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM6 ?
 		SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
-	err = __fou_build_header(skb, e, protocol, &sport, type);
+	err = __fou_build_header(skb, e, protocol, &sport, type, net);
 	if (err)
 		return err;
 
@@ -52,14 +52,14 @@ int fou6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
 EXPORT_SYMBOL(fou6_build_header);
 
 int gue6_build_header(struct sk_buff *skb, struct ip_tunnel_encap *e,
-		      u8 *protocol, struct flowi6 *fl6)
+		      u8 *protocol, struct flowi6 *fl6, struct net *net)
 {
 	__be16 sport;
 	int err;
 	int type = e->flags & TUNNEL_ENCAP_FLAG_CSUM6 ?
 		SKB_GSO_UDP_TUNNEL_CSUM : SKB_GSO_UDP_TUNNEL;
 
-	err = __gue_build_header(skb, e, protocol, &sport, type);
+	err = __gue_build_header(skb, e, protocol, &sport, type, net);
 	if (err)
 		return err;
 
-- 
2.8.0.rc2

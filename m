From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v4 4/4] gre: Remove support for sharing GRE protocol hook.
Date: Wed,  5 Aug 2015 20:12:46 -0700
Message-ID: <1438830766-6602-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:35153 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537AbbHFE2B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2015 00:28:01 -0400
Received: by pdrg1 with SMTP id g1so27337376pdr.2
        for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 21:28:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support for sharing GREPROTO_CISCO port was added so that
OVS gre port and kernel GRE devices can co-exist. After
flow-based tunneling patches OVS GRE protocol processing
is completely moved to ip_gre module. so there is no need
for GRE protocol hook. Following patch consolidates
GRE protocol related functions into ip_gre module.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/gre.h    |  80 ++-----------------
 net/ipv4/gre_demux.c | 201 +----------------------------------------------
 net/ipv4/ip_gre.c    | 215 +++++++++++++++++++++++++++++++++++++++++++++++----
 3 files changed, 206 insertions(+), 290 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index e3e0845..97eafdc 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -4,6 +4,12 @@
 #include <linux/skbuff.h>
 #include <net/ip_tunnels.h>
 
+struct gre_base_hdr {
+	__be16 flags;
+	__be16 protocol;
+};
+#define GRE_HEADER_SECTION 4
+
 #define GREPROTO_CISCO		0
 #define GREPROTO_PPTP		1
 #define GREPROTO_MAX		2
@@ -14,83 +20,9 @@ struct gre_protocol {
 	void (*err_handler)(struct sk_buff *skb, u32 info);
 };
 
-struct gre_base_hdr {
-	__be16 flags;
-	__be16 protocol;
-};
-#define GRE_HEADER_SECTION 4
-
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
-struct gre_cisco_protocol {
-	int (*handler)(struct sk_buff *skb, const struct tnl_ptk_info *tpi);
-	int (*err_handler)(struct sk_buff *skb, u32 info,
-			   const struct tnl_ptk_info *tpi);
-	u8 priority;
-};
-
-int gre_cisco_register(struct gre_cisco_protocol *proto);
-int gre_cisco_unregister(struct gre_cisco_protocol *proto);
-
 struct net_device *gretap_fb_dev_create(struct net *net, const char *name,
 				       u8 name_assign_type);
-
-static inline int ip_gre_calc_hlen(__be16 o_flags)
-{
-	int addend = 4;
-
-	if (o_flags&TUNNEL_CSUM)
-		addend += 4;
-	if (o_flags&TUNNEL_KEY)
-		addend += 4;
-	if (o_flags&TUNNEL_SEQ)
-		addend += 4;
-	return addend;
-}
-
-static inline __be16 gre_flags_to_tnl_flags(__be16 flags)
-{
-	__be16 tflags = 0;
-
-	if (flags & GRE_CSUM)
-		tflags |= TUNNEL_CSUM;
-	if (flags & GRE_ROUTING)
-		tflags |= TUNNEL_ROUTING;
-	if (flags & GRE_KEY)
-		tflags |= TUNNEL_KEY;
-	if (flags & GRE_SEQ)
-		tflags |= TUNNEL_SEQ;
-	if (flags & GRE_STRICT)
-		tflags |= TUNNEL_STRICT;
-	if (flags & GRE_REC)
-		tflags |= TUNNEL_REC;
-	if (flags & GRE_VERSION)
-		tflags |= TUNNEL_VERSION;
-
-	return tflags;
-}
-
-static inline __be16 tnl_flags_to_gre_flags(__be16 tflags)
-{
-	__be16 flags = 0;
-
-	if (tflags & TUNNEL_CSUM)
-		flags |= GRE_CSUM;
-	if (tflags & TUNNEL_ROUTING)
-		flags |= GRE_ROUTING;
-	if (tflags & TUNNEL_KEY)
-		flags |= GRE_KEY;
-	if (tflags & TUNNEL_SEQ)
-		flags |= GRE_SEQ;
-	if (tflags & TUNNEL_STRICT)
-		flags |= GRE_STRICT;
-	if (tflags & TUNNEL_REC)
-		flags |= GRE_REC;
-	if (tflags & TUNNEL_VERSION)
-		flags |= GRE_VERSION;
-
-	return flags;
-}
-
 #endif
diff --git a/net/ipv4/gre_demux.c b/net/ipv4/gre_demux.c
index 77562e0..d9c552a 100644
--- a/net/ipv4/gre_demux.c
+++ b/net/ipv4/gre_demux.c
@@ -31,7 +31,6 @@
 #include <net/xfrm.h>
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
-static struct gre_cisco_protocol __rcu *gre_cisco_proto_list[GRE_IP_PROTO_MAX];
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
@@ -61,163 +60,6 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 }
 EXPORT_SYMBOL_GPL(gre_del_protocol);
 
-static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-			    bool *csum_err)
-{
-	const struct gre_base_hdr *greh;
-	__be32 *options;
-	int hdr_len;
-
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
-		return -EINVAL;
-
-	greh = (struct gre_base_hdr *)skb_transport_header(skb);
-	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
-		return -EINVAL;
-
-	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
-	hdr_len = ip_gre_calc_hlen(tpi->flags);
-
-	if (!pskb_may_pull(skb, hdr_len))
-		return -EINVAL;
-
-	greh = (struct gre_base_hdr *)skb_transport_header(skb);
-	tpi->proto = greh->protocol;
-
-	options = (__be32 *)(greh + 1);
-	if (greh->flags & GRE_CSUM) {
-		if (skb_checksum_simple_validate(skb)) {
-			*csum_err = true;
-			return -EINVAL;
-		}
-
-		skb_checksum_try_convert(skb, IPPROTO_GRE, 0,
-					 null_compute_pseudo);
-
-		options++;
-	}
-
-	if (greh->flags & GRE_KEY) {
-		tpi->key = *options;
-		options++;
-	} else
-		tpi->key = 0;
-
-	if (unlikely(greh->flags & GRE_SEQ)) {
-		tpi->seq = *options;
-		options++;
-	} else
-		tpi->seq = 0;
-
-	/* WCCP version 1 and 2 protocol decoding.
-	 * - Change protocol to IP
-	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
-	 */
-	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
-		tpi->proto = htons(ETH_P_IP);
-		if ((*(u8 *)options & 0xF0) != 0x40) {
-			hdr_len += 4;
-			if (!pskb_may_pull(skb, hdr_len))
-				return -EINVAL;
-		}
-	}
-
-	return iptunnel_pull_header(skb, hdr_len, tpi->proto);
-}
-
-static int gre_cisco_rcv(struct sk_buff *skb)
-{
-	struct tnl_ptk_info tpi;
-	int i;
-	bool csum_err = false;
-
-#ifdef CONFIG_NET_IPGRE_BROADCAST
-	if (ipv4_is_multicast(ip_hdr(skb)->daddr)) {
-		/* Looped back packet, drop it! */
-		if (rt_is_output_route(skb_rtable(skb)))
-			goto drop;
-	}
-#endif
-
-	if (parse_gre_header(skb, &tpi, &csum_err) < 0)
-		goto drop;
-
-	rcu_read_lock();
-	for (i = 0; i < GRE_IP_PROTO_MAX; i++) {
-		struct gre_cisco_protocol *proto;
-		int ret;
-
-		proto = rcu_dereference(gre_cisco_proto_list[i]);
-		if (!proto)
-			continue;
-		ret = proto->handler(skb, &tpi);
-		if (ret == PACKET_RCVD) {
-			rcu_read_unlock();
-			return 0;
-		}
-	}
-	rcu_read_unlock();
-
-	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
-drop:
-	kfree_skb(skb);
-	return 0;
-}
-
-static void gre_cisco_err(struct sk_buff *skb, u32 info)
-{
-	/* All the routers (except for Linux) return only
-	 * 8 bytes of packet payload. It means, that precise relaying of
-	 * ICMP in the real Internet is absolutely infeasible.
-	 *
-	 * Moreover, Cisco "wise men" put GRE key to the third word
-	 * in GRE header. It makes impossible maintaining even soft
-	 * state for keyed
-	 * GRE tunnels with enabled checksum. Tell them "thank you".
-	 *
-	 * Well, I wonder, rfc1812 was written by Cisco employee,
-	 * what the hell these idiots break standards established
-	 * by themselves???
-	 */
-
-	const int type = icmp_hdr(skb)->type;
-	const int code = icmp_hdr(skb)->code;
-	struct tnl_ptk_info tpi;
-	bool csum_err = false;
-	int i;
-
-	if (parse_gre_header(skb, &tpi, &csum_err)) {
-		if (!csum_err)		/* ignore csum errors. */
-			return;
-	}
-
-	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				skb->dev->ifindex, 0, IPPROTO_GRE, 0);
-		return;
-	}
-	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0,
-				IPPROTO_GRE, 0);
-		return;
-	}
-
-	rcu_read_lock();
-	for (i = 0; i < GRE_IP_PROTO_MAX; i++) {
-		struct gre_cisco_protocol *proto;
-
-		proto = rcu_dereference(gre_cisco_proto_list[i]);
-		if (!proto)
-			continue;
-
-		if (proto->err_handler(skb, info, &tpi) == PACKET_RCVD)
-			goto out;
-
-	}
-out:
-	rcu_read_unlock();
-}
-
 static int gre_rcv(struct sk_buff *skb)
 {
 	const struct gre_protocol *proto;
@@ -268,60 +110,19 @@ static const struct net_protocol net_gre_protocol = {
 	.netns_ok    = 1,
 };
 
-static const struct gre_protocol ipgre_protocol = {
-	.handler     = gre_cisco_rcv,
-	.err_handler = gre_cisco_err,
-};
-
-int gre_cisco_register(struct gre_cisco_protocol *newp)
-{
-	struct gre_cisco_protocol **proto = (struct gre_cisco_protocol **)
-					    &gre_cisco_proto_list[newp->priority];
-
-	return (cmpxchg(proto, NULL, newp) == NULL) ? 0 : -EBUSY;
-}
-EXPORT_SYMBOL_GPL(gre_cisco_register);
-
-int gre_cisco_unregister(struct gre_cisco_protocol *del_proto)
-{
-	struct gre_cisco_protocol **proto = (struct gre_cisco_protocol **)
-					    &gre_cisco_proto_list[del_proto->priority];
-	int ret;
-
-	ret = (cmpxchg(proto, del_proto, NULL) == del_proto) ? 0 : -EINVAL;
-
-	if (ret)
-		return ret;
-
-	synchronize_net();
-	return 0;
-}
-EXPORT_SYMBOL_GPL(gre_cisco_unregister);
-
 static int __init gre_init(void)
 {
 	pr_info("GRE over IPv4 demultiplexor driver\n");
 
 	if (inet_add_protocol(&net_gre_protocol, IPPROTO_GRE) < 0) {
 		pr_err("can't add protocol\n");
-		goto err;
+		return -EAGAIN;
 	}
-
-	if (gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0) {
-		pr_info("%s: can't add ipgre handler\n", __func__);
-		goto err_gre;
-	}
-
 	return 0;
-err_gre:
-	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
-err:
-	return -EAGAIN;
 }
 
 static void __exit gre_exit(void)
 {
-	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 }
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 49d1402..fb44d69 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -123,8 +123,127 @@ static int ipgre_tunnel_init(struct net_device *dev);
 static int ipgre_net_id __read_mostly;
 static int gre_tap_net_id __read_mostly;
 
-static int ipgre_err(struct sk_buff *skb, u32 info,
-		     const struct tnl_ptk_info *tpi)
+static int ip_gre_calc_hlen(__be16 o_flags)
+{
+	int addend = 4;
+
+	if (o_flags & TUNNEL_CSUM)
+		addend += 4;
+	if (o_flags & TUNNEL_KEY)
+		addend += 4;
+	if (o_flags & TUNNEL_SEQ)
+		addend += 4;
+	return addend;
+}
+
+static __be16 gre_flags_to_tnl_flags(__be16 flags)
+{
+	__be16 tflags = 0;
+
+	if (flags & GRE_CSUM)
+		tflags |= TUNNEL_CSUM;
+	if (flags & GRE_ROUTING)
+		tflags |= TUNNEL_ROUTING;
+	if (flags & GRE_KEY)
+		tflags |= TUNNEL_KEY;
+	if (flags & GRE_SEQ)
+		tflags |= TUNNEL_SEQ;
+	if (flags & GRE_STRICT)
+		tflags |= TUNNEL_STRICT;
+	if (flags & GRE_REC)
+		tflags |= TUNNEL_REC;
+	if (flags & GRE_VERSION)
+		tflags |= TUNNEL_VERSION;
+
+	return tflags;
+}
+
+static __be16 tnl_flags_to_gre_flags(__be16 tflags)
+{
+	__be16 flags = 0;
+
+	if (tflags & TUNNEL_CSUM)
+		flags |= GRE_CSUM;
+	if (tflags & TUNNEL_ROUTING)
+		flags |= GRE_ROUTING;
+	if (tflags & TUNNEL_KEY)
+		flags |= GRE_KEY;
+	if (tflags & TUNNEL_SEQ)
+		flags |= GRE_SEQ;
+	if (tflags & TUNNEL_STRICT)
+		flags |= GRE_STRICT;
+	if (tflags & TUNNEL_REC)
+		flags |= GRE_REC;
+	if (tflags & TUNNEL_VERSION)
+		flags |= GRE_VERSION;
+
+	return flags;
+}
+
+static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
+			    bool *csum_err)
+{
+	const struct gre_base_hdr *greh;
+	__be32 *options;
+	int hdr_len;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
+		return -EINVAL;
+
+	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
+	hdr_len = ip_gre_calc_hlen(tpi->flags);
+
+	if (!pskb_may_pull(skb, hdr_len))
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)skb_transport_header(skb);
+	tpi->proto = greh->protocol;
+
+	options = (__be32 *)(greh + 1);
+	if (greh->flags & GRE_CSUM) {
+		if (skb_checksum_simple_validate(skb)) {
+			*csum_err = true;
+			return -EINVAL;
+		}
+
+		skb_checksum_try_convert(skb, IPPROTO_GRE, 0,
+					 null_compute_pseudo);
+		options++;
+	}
+
+	if (greh->flags & GRE_KEY) {
+		tpi->key = *options;
+		options++;
+	} else {
+		tpi->key = 0;
+	}
+	if (unlikely(greh->flags & GRE_SEQ)) {
+		tpi->seq = *options;
+		options++;
+	} else {
+		tpi->seq = 0;
+	}
+	/* WCCP version 1 and 2 protocol decoding.
+	 * - Change protocol to IP
+	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
+	 */
+	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
+		tpi->proto = htons(ETH_P_IP);
+		if ((*(u8 *)options & 0xF0) != 0x40) {
+			hdr_len += 4;
+			if (!pskb_may_pull(skb, hdr_len))
+				return -EINVAL;
+		}
+	}
+	return iptunnel_pull_header(skb, hdr_len, tpi->proto);
+}
+
+static void ipgre_err(struct sk_buff *skb, u32 info,
+		      const struct tnl_ptk_info *tpi)
 {
 
 	/* All the routers (except for Linux) return only
@@ -150,14 +269,14 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 	switch (type) {
 	default:
 	case ICMP_PARAMETERPROB:
-		return PACKET_RCVD;
+		return;
 
 	case ICMP_DEST_UNREACH:
 		switch (code) {
 		case ICMP_SR_FAILED:
 		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
-			return PACKET_RCVD;
+			return;
 		default:
 			/* All others are translated to HOST_UNREACH.
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
@@ -166,9 +285,10 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 			break;
 		}
 		break;
+
 	case ICMP_TIME_EXCEEDED:
 		if (code != ICMP_EXC_TTL)
-			return PACKET_RCVD;
+			return;
 		break;
 
 	case ICMP_REDIRECT:
@@ -185,21 +305,60 @@ static int ipgre_err(struct sk_buff *skb, u32 info,
 			     iph->daddr, iph->saddr, tpi->key);
 
 	if (!t)
-		return PACKET_REJECT;
+		return;
 
 	if (t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
-		return PACKET_RCVD;
+		return;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-		return PACKET_RCVD;
+		return;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
 	t->err_time = jiffies;
-	return PACKET_RCVD;
+}
+
+static void gre_err(struct sk_buff *skb, u32 info)
+{
+	/* All the routers (except for Linux) return only
+	 * 8 bytes of packet payload. It means, that precise relaying of
+	 * ICMP in the real Internet is absolutely infeasible.
+	 *
+	 * Moreover, Cisco "wise men" put GRE key to the third word
+	 * in GRE header. It makes impossible maintaining even soft
+	 * state for keyed
+	 * GRE tunnels with enabled checksum. Tell them "thank you".
+	 *
+	 * Well, I wonder, rfc1812 was written by Cisco employee,
+	 * what the hell these idiots break standards established
+	 * by themselves???
+	 */
+
+	const int type = icmp_hdr(skb)->type;
+	const int code = icmp_hdr(skb)->code;
+	struct tnl_ptk_info tpi;
+	bool csum_err = false;
+
+	if (parse_gre_header(skb, &tpi, &csum_err)) {
+		if (!csum_err)		/* ignore csum errors. */
+			return;
+	}
+
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
+		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
+				 skb->dev->ifindex, 0, IPPROTO_GRE, 0);
+		return;
+	}
+	if (type == ICMP_REDIRECT) {
+		ipv4_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0,
+			      IPPROTO_GRE, 0);
+		return;
+	}
+
+	ipgre_err(skb, info, &tpi);
 }
 
 static __be64 key_to_tunnel_id(__be32 key)
@@ -268,6 +427,31 @@ static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 	return PACKET_REJECT;
 }
 
+static int gre_rcv(struct sk_buff *skb)
+{
+	struct tnl_ptk_info tpi;
+	bool csum_err = false;
+
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	if (ipv4_is_multicast(ip_hdr(skb)->daddr)) {
+		/* Looped back packet, drop it! */
+		if (rt_is_output_route(skb_rtable(skb)))
+			goto drop;
+	}
+#endif
+
+	if (parse_gre_header(skb, &tpi, &csum_err) < 0)
+		goto drop;
+
+	if (ipgre_rcv(skb, &tpi) == PACKET_RCVD)
+		return 0;
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
 static void build_header(struct sk_buff *skb, int hdr_len, __be16 flags,
 			 __be16 proto, __be32 key, __be32 seq)
 {
@@ -684,10 +868,9 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	return ip_tunnel_init(dev);
 }
 
-static struct gre_cisco_protocol ipgre_protocol = {
-	.handler        = ipgre_rcv,
-	.err_handler    = ipgre_err,
-	.priority       = 0,
+static const struct gre_protocol ipgre_protocol = {
+	.handler     = gre_rcv,
+	.err_handler = gre_err,
 };
 
 static int __net_init ipgre_init_net(struct net *net)
@@ -1080,7 +1263,7 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto pnet_tap_faied;
 
-	err = gre_cisco_register(&ipgre_protocol);
+	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	if (err < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		goto add_proto_failed;
@@ -1099,7 +1282,7 @@ static int __init ipgre_init(void)
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
-	gre_cisco_unregister(&ipgre_protocol);
+	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 add_proto_failed:
 	unregister_pernet_device(&ipgre_tap_net_ops);
 pnet_tap_faied:
@@ -1111,7 +1294,7 @@ static void __exit ipgre_fini(void)
 {
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
-	gre_cisco_unregister(&ipgre_protocol);
+	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	unregister_pernet_device(&ipgre_tap_net_ops);
 	unregister_pernet_device(&ipgre_net_ops);
 }
-- 
1.8.3.1

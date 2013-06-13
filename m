From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 02/12] gre: Allow multiple protocol listener for gre protocol.
Date: Thu, 13 Jun 2013 11:24:17 -0700
Message-ID: <1371147857-9166-1-git-send-email-pshelar@nicira.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
To: netdev@vger.kernel.org, dev@openvswitch.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog135.obsmtp.com ([74.125.149.84]:57514 "HELO
	na3sys009aog135.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756774Ab3FMSYV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jun 2013 14:24:21 -0400
Received: by mail-pa0-f41.google.com with SMTP id bj3so7219503pad.28
        for <netdev@vger.kernel.org>; Thu, 13 Jun 2013 11:24:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently there is only one user is allowed to register for gre
protocol.  Following patch adds de-multiplexer.  So that multiple
modules can listen on gre protocol e.g. kernel gre devices and ovs.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/net/gre.h |   24 ++++++
 net/ipv4/gre.c    |  221 ++++++++++++++++++++++++++++++++++++++++++++++++++++-
 net/ipv4/ip_gre.c |  173 ++++++-----------------------------------
 3 files changed, 267 insertions(+), 151 deletions(-)

diff --git a/include/net/gre.h b/include/net/gre.h
index 9f03a39..c6ea0c7 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -7,6 +7,7 @@
 #define GREPROTO_CISCO		0
 #define GREPROTO_PPTP		1
 #define GREPROTO_MAX		2
+#define GRE_IP_PROTO_MAX	2
 
 struct gre_protocol {
 	int  (*handler)(struct sk_buff *skb);
@@ -22,6 +23,29 @@ struct gre_base_hdr {
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
+struct gre_cisco_protocol {
+	int (*handler)(struct sk_buff *skb, const struct tnl_ptk_info *tpi);
+	int (*err_handler)(struct sk_buff *skb, u32 info,
+			   const struct tnl_ptk_info *tpi);
+	u8 priority;
+};
+
+int gre_cisco_register(struct gre_cisco_protocol *proto);
+int gre_cisco_unregister(struct gre_cisco_protocol *proto);
+
+static inline int ip_gre_calc_hlen(__be16 o_flags)
+{
+	int addend = 4;
+
+	if (o_flags&TUNNEL_CSUM)
+		addend += 4;
+	if (o_flags&TUNNEL_KEY)
+		addend += 4;
+	if (o_flags&TUNNEL_SEQ)
+		addend += 4;
+	return addend;
+}
+
 static inline __be16 gre_flags_to_tnl_flags(__be16 flags)
 {
 	__be16 tflags = 0;
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index 1e294d5..8b9a373 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -13,6 +13,8 @@
 #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 
 #include <linux/module.h>
+#include <linux/if.h>
+#include <linux/icmp.h>
 #include <linux/kernel.h>
 #include <linux/kmod.h>
 #include <linux/skbuff.h>
@@ -24,8 +26,12 @@
 #include <net/protocol.h>
 #include <net/gre.h>
 
+#include <net/icmp.h>
+#include <net/route.h>
+#include <net/xfrm.h>
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
+static struct gre_cisco_protocol __rcu *gre_cisco_proto_list[GRE_IP_PROTO_MAX];
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
@@ -55,6 +61,173 @@ int gre_del_protocol(const struct gre_protocol *proto, u8 version)
 }
 EXPORT_SYMBOL_GPL(gre_del_protocol);
 
+static __sum16 check_checksum(struct sk_buff *skb)
+{
+	__sum16 csum = 0;
+
+	switch (skb->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		csum = csum_fold(skb->csum);
+
+		if (!csum)
+			break;
+		/* Fall through. */
+
+	case CHECKSUM_NONE:
+		skb->csum = 0;
+		csum = __skb_checksum_complete(skb);
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		break;
+	}
+
+	return csum;
+}
+
+static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
+			    bool *csum_err)
+{
+	unsigned int ip_hlen = ip_hdrlen(skb);
+	const struct gre_base_hdr *greh;
+	__be32 *options;
+	int hdr_len;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
+	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
+		return -EINVAL;
+
+	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
+	hdr_len = ip_gre_calc_hlen(tpi->flags);
+
+	if (!pskb_may_pull(skb, hdr_len))
+		return -EINVAL;
+
+	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
+	tpi->proto = greh->protocol;
+
+	options = (__be32 *)(greh + 1);
+	if (greh->flags & GRE_CSUM) {
+		if (check_checksum(skb)) {
+			*csum_err = true;
+			return -EINVAL;
+		}
+		options++;
+	}
+
+	if (greh->flags & GRE_KEY) {
+		tpi->key = *options;
+		options++;
+	} else
+		tpi->key = 0;
+
+	if (unlikely(greh->flags & GRE_SEQ)) {
+		tpi->seq = *options;
+		options++;
+	} else
+		tpi->seq = 0;
+
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
+	return 0;
+}
+
+static int gre_cisco_rcv(struct sk_buff *skb)
+{
+	struct tnl_ptk_info tpi;
+	int i;
+	bool csum_err = false;
+
+	if (parse_gre_header(skb, &tpi, &csum_err) < 0)
+		goto drop;
+
+	rcu_read_lock();
+	for (i = 0; i < GRE_IP_PROTO_MAX; i++) {
+		struct gre_cisco_protocol *proto;
+		int ret;
+
+		proto = rcu_dereference(gre_cisco_proto_list[i]);
+		if (!proto)
+			continue;
+		ret = proto->handler(skb, &tpi);
+		if (ret == PACKET_RCVD) {
+			rcu_read_unlock();
+			return 0;
+		}
+	}
+	rcu_read_unlock();
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
+static void gre_cisco_err(struct sk_buff *skb, u32 info)
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
+	int i;
+
+	if (parse_gre_header(skb, &tpi, &csum_err)) {
+		if (!csum_err)		/* ignore csum errors. */
+			return;
+	}
+
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
+		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
+				skb->dev->ifindex, 0, IPPROTO_GRE, 0);
+		return;
+	}
+	if (type == ICMP_REDIRECT) {
+		ipv4_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0,
+				IPPROTO_GRE, 0);
+		return;
+	}
+
+	rcu_read_lock();
+	for (i = 0; i < GRE_IP_PROTO_MAX; i++) {
+		struct gre_cisco_protocol *proto;
+
+		proto = rcu_dereference(gre_cisco_proto_list[i]);
+		if (!proto)
+			continue;
+
+		if (proto->err_handler(skb, info, &tpi) == PACKET_RCVD)
+			goto out;
+
+	}
+out:
+	rcu_read_unlock();
+}
+
 static int gre_rcv(struct sk_buff *skb)
 {
 	const struct gre_protocol *proto;
@@ -206,27 +379,68 @@ static const struct net_offload gre_offload = {
 	},
 };
 
+static const struct gre_protocol ipgre_protocol = {
+	.handler     = gre_cisco_rcv,
+	.err_handler = gre_cisco_err,
+};
+
+int gre_cisco_register(struct gre_cisco_protocol *newp)
+{
+	struct gre_cisco_protocol **proto = (struct gre_cisco_protocol **)
+					    &gre_cisco_proto_list[newp->priority];
+
+	return (cmpxchg(proto, NULL, newp) == NULL) ? 0 : -EBUSY;
+}
+EXPORT_SYMBOL_GPL(gre_cisco_register);
+
+int gre_cisco_unregister(struct gre_cisco_protocol *del_proto)
+{
+	struct gre_cisco_protocol **proto = (struct gre_cisco_protocol **)
+					    &gre_cisco_proto_list[del_proto->priority];
+	int ret;
+
+	ret = (cmpxchg(proto, del_proto, NULL) == del_proto) ? 0 : -EINVAL;
+
+	if (ret)
+		return ret;
+
+	synchronize_net();
+	return 0;
+}
+EXPORT_SYMBOL_GPL(gre_cisco_unregister);
+
 static int __init gre_init(void)
 {
 	pr_info("GRE over IPv4 demultiplexor driver\n");
 
 	if (inet_add_protocol(&net_gre_protocol, IPPROTO_GRE) < 0) {
 		pr_err("can't add protocol\n");
-		return -EAGAIN;
+		goto err;
+	}
+
+	if (gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0) {
+		pr_info("%s: can't add ipgre handler\n", __func__);
+		goto err_gre;
 	}
 
 	if (inet_add_offload(&gre_offload, IPPROTO_GRE)) {
 		pr_err("can't add protocol offload\n");
-		inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
-		return -EAGAIN;
+		goto err_gso;
 	}
 
 	return 0;
+err_gso:
+	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
+err_gre:
+	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
+err:
+	return -EAGAIN;
 }
 
 static void __exit gre_exit(void)
 {
 	inet_del_offload(&gre_offload, IPPROTO_GRE);
+	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 }
 
@@ -236,4 +450,3 @@ module_exit(gre_exit);
 MODULE_DESCRIPTION("GRE over IPv4 demultiplexer driver");
 MODULE_AUTHOR("D. Kozlov (xeb@mail.ru)");
 MODULE_LICENSE("GPL");
-
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index a982657..19863a8 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -121,103 +121,8 @@ static int ipgre_tunnel_init(struct net_device *dev);
 static int ipgre_net_id __read_mostly;
 static int gre_tap_net_id __read_mostly;
 
-static __sum16 check_checksum(struct sk_buff *skb)
-{
-	__sum16 csum = 0;
-
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		csum = csum_fold(skb->csum);
-
-		if (!csum)
-			break;
-		/* Fall through. */
-
-	case CHECKSUM_NONE:
-		skb->csum = 0;
-		csum = __skb_checksum_complete(skb);
-		skb->ip_summed = CHECKSUM_COMPLETE;
-		break;
-	}
-
-	return csum;
-}
-
-static int ip_gre_calc_hlen(__be16 o_flags)
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
-static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
-			    bool *csum_err, int *hdr_len)
-{
-	unsigned int ip_hlen = ip_hdrlen(skb);
-	const struct gre_base_hdr *greh;
-	__be32 *options;
-
-	if (unlikely(!pskb_may_pull(skb, sizeof(struct gre_base_hdr))))
-		return -EINVAL;
-
-	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
-	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
-		return -EINVAL;
-
-	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
-	*hdr_len = ip_gre_calc_hlen(tpi->flags);
-
-	if (!pskb_may_pull(skb, *hdr_len))
-		return -EINVAL;
-
-	greh = (struct gre_base_hdr *)(skb_network_header(skb) + ip_hlen);
-
-	tpi->proto = greh->protocol;
-
-	options = (__be32 *)(greh + 1);
-	if (greh->flags & GRE_CSUM) {
-		if (check_checksum(skb)) {
-			*csum_err = true;
-			return -EINVAL;
-		}
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
-			*hdr_len += 4;
-			if (!pskb_may_pull(skb, *hdr_len))
-				return -EINVAL;
-		}
-	}
-
-	return 0;
-}
-
-static void ipgre_err(struct sk_buff *skb, u32 info)
+static int ipgre_err(struct sk_buff *skb, u32 info,
+		     const struct tnl_ptk_info *tpi)
 {
 
 	/* All the routers (except for Linux) return only
@@ -239,26 +144,18 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
-	struct tnl_ptk_info tpi;
-	int hdr_len;
-	bool csum_err = false;
-
-	if (parse_gre_header(skb, &tpi, &csum_err, &hdr_len)) {
-		if (!csum_err)          /* ignore csum errors. */
-			return;
-	}
 
 	switch (type) {
 	default:
 	case ICMP_PARAMETERPROB:
-		return;
+		return PACKET_RCVD;
 
 	case ICMP_DEST_UNREACH:
 		switch (code) {
 		case ICMP_SR_FAILED:
 		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
-			return;
+			return PACKET_RCVD;
 		default:
 			/* All others are translated to HOST_UNREACH.
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
@@ -269,79 +166,61 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		break;
 	case ICMP_TIME_EXCEEDED:
 		if (code != ICMP_EXC_TTL)
-			return;
+			return PACKET_RCVD;
 		break;
 
 	case ICMP_REDIRECT:
 		break;
 	}
 
-	if (tpi.proto == htons(ETH_P_TEB))
+	if (tpi->proto == htons(ETH_P_TEB))
 		itn = net_generic(net, gre_tap_net_id);
 	else
 		itn = net_generic(net, ipgre_net_id);
 
 	iph = (const struct iphdr *)skb->data;
-	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi.flags,
-			     iph->daddr, iph->saddr, tpi.key);
+	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
+			     iph->daddr, iph->saddr, tpi->key);
 
 	if (t == NULL)
-		return;
+		return PACKET_REJECT;
 
-	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->parms.link, 0, IPPROTO_GRE, 0);
-		return;
-	}
-	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
-			      IPPROTO_GRE, 0);
-		return;
-	}
 	if (t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
-		return;
+		return PACKET_RCVD;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-		return;
+		return PACKET_RCVD;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
 	t->err_time = jiffies;
+	return PACKET_RCVD;
 }
 
-static int ipgre_rcv(struct sk_buff *skb)
+static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 {
 	struct net *net = dev_net(skb->dev);
 	struct ip_tunnel_net *itn;
 	const struct iphdr *iph;
 	struct ip_tunnel *tunnel;
-	struct tnl_ptk_info tpi;
-	int hdr_len;
-	bool csum_err = false;
-
-	if (parse_gre_header(skb, &tpi, &csum_err, &hdr_len) < 0)
-		goto drop;
 
-	if (tpi.proto == htons(ETH_P_TEB))
+	if (tpi->proto == htons(ETH_P_TEB))
 		itn = net_generic(net, gre_tap_net_id);
 	else
 		itn = net_generic(net, ipgre_net_id);
 
 	iph = ip_hdr(skb);
-	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi.flags,
-				  iph->saddr, iph->daddr, tpi.key);
+	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
+				  iph->saddr, iph->daddr, tpi->key);
 
 	if (tunnel) {
-		ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
-		return 0;
+		ip_tunnel_rcv(tunnel, skb, tpi, log_ecn_error);
+		return PACKET_RCVD;
 	}
-	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
-drop:
-	kfree_skb(skb);
-	return 0;
+	return PACKET_REJECT;
 }
 
 static struct sk_buff *handle_offloads(struct ip_tunnel *tunnel, struct sk_buff *skb)
@@ -708,9 +587,10 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	return ip_tunnel_init(dev);
 }
 
-static const struct gre_protocol ipgre_protocol = {
-	.handler     = ipgre_rcv,
-	.err_handler = ipgre_err,
+static struct gre_cisco_protocol ipgre_protocol = {
+	.handler        = ipgre_rcv,
+	.err_handler    = ipgre_err,
+	.priority       = 0,
 };
 
 static int __net_init ipgre_init_net(struct net *net)
@@ -978,7 +858,7 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto pnet_tap_faied;
 
-	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	err = gre_cisco_register(&ipgre_protocol);
 	if (err < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
 		goto add_proto_failed;
@@ -997,7 +877,7 @@ static int __init ipgre_init(void)
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
-	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	gre_cisco_unregister(&ipgre_protocol);
 add_proto_failed:
 	unregister_pernet_device(&ipgre_tap_net_ops);
 pnet_tap_faied:
@@ -1009,8 +889,7 @@ static void __exit ipgre_fini(void)
 {
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
-	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
-		pr_info("%s: can't remove protocol\n", __func__);
+	gre_cisco_unregister(&ipgre_protocol);
 	unregister_pernet_device(&ipgre_tap_net_ops);
 	unregister_pernet_device(&ipgre_net_ops);
 }
-- 
1.7.1

From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 12/14] gtp: Configuration for zero UDP checksum
Date: Mon, 18 Sep 2017 17:39:02 -0700
Message-ID: <20170919003904.5124-13-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:55317 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751499AbdISAkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:40:01 -0400
Received: by mail-pg0-f49.google.com with SMTP id b11so1081389pgn.12
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:40:00 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add configuration to control use of zero checksums on transmit for both
IPv4 and IPv6, and control over accepting zero IPv6 checksums on
receive.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c            | 35 +++++++++++++++++++++++++++++++++--
 include/uapi/linux/if_link.h |  4 ++++
 2 files changed, 37 insertions(+), 2 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 393f63cb2576..b53946f8b10b 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -75,6 +75,13 @@ struct pdp_ctx {
 	struct rcu_head		rcu_head;
 
 	struct dst_cache	dst_cache;
+
+	unsigned int		cfg_flags;
+
+#define GTP_F_UDP_ZERO_CSUM_TX		0x1
+#define GTP_F_UDP_ZERO_CSUM6_TX		0x2
+#define GTP_F_UDP_ZERO_CSUM6_RX		0x4
+
 };
 
 /* One instance of the GTP device. */
@@ -536,6 +543,7 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 	struct gtp_dev *gtp = netdev_priv(dev);
 	bool xnet = !net_eq(gtp->net, dev_net(gtp->dev));
 	struct sock *sk = pctx->sk;
+	bool udp_csum;
 	int err = 0;
 
 	/* Ensure there is sufficient headroom. */
@@ -563,11 +571,12 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 		skb_dst_drop(skb);
 
 		gtp_push_header(skb, pctx);
+		udp_csum = !(pctx->cfg_flags & GTP_F_UDP_ZERO_CSUM_TX);
 		udp_tunnel_xmit_skb(rt, sk, skb, saddr,
 				    pctx->peer_addr_ip4.s_addr,
 				    0, ip4_dst_hoplimit(&rt->dst), 0,
 				    pctx->gtp_port, pctx->gtp_port,
-				    xnet, false);
+				    xnet, !udp_csum);
 
 		netdev_dbg(dev, "gtp -> IP src: %pI4 dst: %pI4\n",
 			   &saddr, &pctx->peer_addr_ip4.s_addr);
@@ -591,11 +600,12 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 		skb_dst_drop(skb);
 
 		gtp_push_header(skb, pctx);
+		udp_csum = !(pctx->cfg_flags & GTP_F_UDP_ZERO_CSUM6_TX);
 		udp_tunnel6_xmit_skb(dst, sk, skb, dev,
 				     &saddr, &pctx->peer_addr_ip6,
 				     0, ip6_dst_hoplimit(dst), 0,
 				     pctx->gtp_port, pctx->gtp_port,
-				     true);
+				     !udp_csum);
 
 		netdev_dbg(dev, "gtp -> IP src: %pI6 dst: %pI6\n",
 			   &saddr, &pctx->peer_addr_ip6);
@@ -728,6 +738,7 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 {
 	unsigned int role = GTP_ROLE_GGSN;
 	bool have_fd, have_ports;
+	unsigned int flags = 0;
 	bool is_ipv6 = false;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
@@ -747,6 +758,21 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 			return -EINVAL;
 	}
 
+	if (data[IFLA_GTP_UDP_CSUM]) {
+		if (!nla_get_u8(data[IFLA_GTP_UDP_CSUM]))
+			flags |= GTP_F_UDP_ZERO_CSUM_TX;
+	}
+
+	if (data[IFLA_GTP_UDP_ZERO_CSUM6_TX]) {
+		if (nla_get_u8(data[IFLA_GTP_UDP_ZERO_CSUM6_TX]))
+			flags |= GTP_F_UDP_ZERO_CSUM6_TX;
+	}
+
+	if (data[IFLA_GTP_UDP_ZERO_CSUM6_RX]) {
+		if (nla_get_u8(data[IFLA_GTP_UDP_ZERO_CSUM6_RX]))
+			flags |= GTP_F_UDP_ZERO_CSUM6_RX;
+	}
+
 	if (data[IFLA_GTP_AF]) {
 		u16 af = nla_get_u16(data[IFLA_GTP_AF]);
 
@@ -819,6 +845,9 @@ static const struct nla_policy gtp_policy[IFLA_GTP_MAX + 1] = {
 	[IFLA_GTP_ROLE]			= { .type = NLA_U32 },
 	[IFLA_GTP_PORT0]		= { .type = NLA_U16 },
 	[IFLA_GTP_PORT1]		= { .type = NLA_U16 },
+	[IFLA_GTP_UDP_CSUM]		= { .type = NLA_U8 },
+	[IFLA_GTP_UDP_ZERO_CSUM6_TX]	= { .type = NLA_U8 },
+	[IFLA_GTP_UDP_ZERO_CSUM6_RX]	= { .type = NLA_U8 },
 };
 
 static int gtp_validate(struct nlattr *tb[], struct nlattr *data[],
@@ -990,6 +1019,8 @@ static struct socket *gtp_create_sock(struct net *net, bool ipv6,
 
 	if (ipv6) {
 		udp_conf.family = AF_INET6;
+		udp_conf.use_udp6_rx_checksums =
+		    !(flags & GTP_F_UDP_ZERO_CSUM6_RX);
 		udp_conf.ipv6_v6only = 1;
 	} else {
 		udp_conf.family = AF_INET;
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 81c26864abeb..14a32d745e24 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -555,6 +555,10 @@ enum {
 	IFLA_GTP_AF,
 	IFLA_GTP_PORT0,
 	IFLA_GTP_PORT1,
+	IFLA_GTP_UDP_CSUM,
+	IFLA_GTP_UDP_ZERO_CSUM6_TX,
+	IFLA_GTP_UDP_ZERO_CSUM6_RX,
+
 	__IFLA_GTP_MAX,
 };
 #define IFLA_GTP_MAX (__IFLA_GTP_MAX - 1)
-- 
2.11.0

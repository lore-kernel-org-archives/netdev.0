From: Tom Herbert <tom@quantonium.net>
Subject: [PATCH net-next 08/14] gtp: Support encpasulating over IPv6
Date: Mon, 18 Sep 2017 17:38:58 -0700
Message-ID: <20170919003904.5124-9-tom@quantonium.net>
References: <20170919003904.5124-1-tom@quantonium.net>
Cc: netdev@vger.kernel.org, pablo@netfilter.org, laforge@gnumonks.org,
        rohit@quantonium.net, Tom Herbert <tom@quantonium.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:50966 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751462AbdISAjv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 20:39:51 -0400
Received: by mail-pg0-f44.google.com with SMTP id p5so1089160pgn.7
        for <netdev@vger.kernel.org>; Mon, 18 Sep 2017 17:39:51 -0700 (PDT)
In-Reply-To: <20170919003904.5124-1-tom@quantonium.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow peers to be specified by IPv6 addresses.

Signed-off-by: Tom Herbert <tom@quantonium.net>
---
 drivers/net/gtp.c            | 198 +++++++++++++++++++++++++++++++++----------
 include/uapi/linux/gtp.h     |   1 +
 include/uapi/linux/if_link.h |   3 +
 3 files changed, 158 insertions(+), 44 deletions(-)

diff --git a/drivers/net/gtp.c b/drivers/net/gtp.c
index 62c0c968efa6..121b41e7a901 100644
--- a/drivers/net/gtp.c
+++ b/drivers/net/gtp.c
@@ -28,6 +28,7 @@
 #include <net/net_namespace.h>
 #include <net/protocol.h>
 #include <net/ip.h>
+#include <net/ip6_tunnel.h>
 #include <net/udp.h>
 #include <net/udp_tunnel.h>
 #include <net/icmp.h>
@@ -61,7 +62,11 @@ struct pdp_ctx {
 		struct in6_addr	ms_addr_ip6;
 	};
 
-	struct in_addr		peer_addr_ip4;
+	u16			peer_af;
+	union {
+		struct in_addr	peer_addr_ip4;
+		struct in6_addr	peer_addr_ip6;
+	};
 
 	struct sock		*sk;
 	struct net_device       *dev;
@@ -76,6 +81,8 @@ struct pdp_ctx {
 struct gtp_dev {
 	struct list_head	list;
 
+	unsigned int		is_ipv6:1;
+
 	struct sock		*sk0;
 	struct sock		*sk1u;
 
@@ -515,8 +522,6 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 		    struct pdp_ctx *pctx)
 {
 	struct sock *sk = pctx->sk;
-	__be32 saddr = inet_sk(sk)->inet_saddr;
-	struct rtable *rt;
 	int err = 0;
 
 	/* Ensure there is sufficient headroom. */
@@ -526,28 +531,63 @@ static int gtp_xmit(struct sk_buff *skb, struct net_device *dev,
 
 	skb_reset_inner_headers(skb);
 
-	rt = ip_tunnel_get_route(dev, skb, sk->sk_protocol,
-				 sk->sk_bound_dev_if, RT_CONN_FLAGS(sk),
-				 pctx->peer_addr_ip4.s_addr, &saddr,
-				 pctx->gtp_port, pctx->gtp_port,
-				 &pctx->dst_cache, NULL);
+	if (pctx->peer_af == AF_INET) {
+		__be32 saddr = inet_sk(sk)->inet_saddr;
+		struct rtable *rt;
 
-	if (IS_ERR(rt)) {
-		err = PTR_ERR(rt);
-		goto out_err;
-	}
+		rt = ip_tunnel_get_route(dev, skb, sk->sk_protocol,
+					 sk->sk_bound_dev_if, RT_CONN_FLAGS(sk),
+					 pctx->peer_addr_ip4.s_addr, &saddr,
+					 pctx->gtp_port, pctx->gtp_port,
+					 &pctx->dst_cache, NULL);
+
+		if (IS_ERR(rt)) {
+			err = PTR_ERR(rt);
+			goto out_err;
+		}
+
+		skb_dst_drop(skb);
+
+		gtp_push_header(skb, pctx);
+		udp_tunnel_xmit_skb(rt, sk, skb, saddr,
+				    pctx->peer_addr_ip4.s_addr,
+				    0, ip4_dst_hoplimit(&rt->dst), 0,
+				    pctx->gtp_port, pctx->gtp_port,
+				    false, false);
 
-	skb_dst_drop(skb);
+		netdev_dbg(dev, "gtp -> IP src: %pI4 dst: %pI4\n",
+			   &saddr, &pctx->peer_addr_ip4.s_addr);
 
-	gtp_push_header(skb, pctx);
-	udp_tunnel_xmit_skb(rt, sk, skb, saddr,
-			    pctx->peer_addr_ip4.s_addr,
-			    0, ip4_dst_hoplimit(&rt->dst), 0,
-			    pctx->gtp_port, pctx->gtp_port,
-			    false, false);
+#if IS_ENABLED(CONFIG_IPV6)
+	} else if (pctx->peer_af == AF_INET6) {
+		struct in6_addr saddr = inet6_sk(sk)->saddr;
+		struct dst_entry *dst;
 
-	netdev_dbg(dev, "gtp -> IP src: %pI4 dst: %pI4\n",
-		   &saddr, &pctx->peer_addr_ip4.s_addr);
+		dst = ip6_tnl_get_route(dev, skb, sk, sk->sk_protocol,
+					sk->sk_bound_dev_if, 0,
+					0, &pctx->peer_addr_ip6, &saddr,
+					pctx->gtp_port, pctx->gtp_port,
+					&pctx->dst_cache, NULL);
+
+		if (IS_ERR(dst)) {
+			err = PTR_ERR(dst);
+			goto out_err;
+		}
+
+		skb_dst_drop(skb);
+
+		gtp_push_header(skb, pctx);
+		udp_tunnel6_xmit_skb(dst, sk, skb, dev,
+				     &saddr, &pctx->peer_addr_ip6,
+				     0, ip6_dst_hoplimit(dst), 0,
+				     pctx->gtp_port, pctx->gtp_port,
+				     true);
+
+		netdev_dbg(dev, "gtp -> IP src: %pI6 dst: %pI6\n",
+			   &saddr, &pctx->peer_addr_ip6);
+
+#endif
+	}
 
 	return 0;
 
@@ -652,7 +692,8 @@ static void gtp_link_setup(struct net_device *dev)
 
 	/* Assume largest header, ie. GTPv0. */
 	dev->needed_headroom	= LL_MAX_HEADER +
-				  sizeof(struct iphdr) +
+				  max_t(int, sizeof(struct iphdr),
+					sizeof(struct ipv6hdr)) +
 				  sizeof(struct udphdr) +
 				  sizeof(struct gtp0_header);
 
@@ -661,12 +702,15 @@ static void gtp_link_setup(struct net_device *dev)
 
 static int gtp_hashtable_new(struct gtp_dev *gtp, int hsize);
 static void gtp_hashtable_free(struct gtp_dev *gtp);
-static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[]);
+static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[],
+			    bool is_ipv6);
 
 static int gtp_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[],
 		       struct netlink_ext_ack *extack)
 {
+	unsigned int role = GTP_ROLE_GGSN;
+	bool is_ipv6 = false;
 	struct gtp_dev *gtp;
 	struct gtp_net *gn;
 	int hashsize, err;
@@ -674,9 +718,30 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 	if (!data[IFLA_GTP_FD0] && !data[IFLA_GTP_FD1])
 		return -EINVAL;
 
+	if (data[IFLA_GTP_ROLE]) {
+		role = nla_get_u32(data[IFLA_GTP_ROLE]);
+		if (role > GTP_ROLE_SGSN)
+			return -EINVAL;
+	}
+
+	if (data[IFLA_GTP_AF]) {
+		u16 af = nla_get_u16(data[IFLA_GTP_AF]);
+
+		switch (af) {
+		case AF_INET:
+			is_ipv6 = false;
+			break;
+		case AF_INET6:
+			is_ipv6 = true;
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
+
 	gtp = netdev_priv(dev);
 
-	err = gtp_encap_enable(gtp, data);
+	err = gtp_encap_enable(gtp, data, is_ipv6);
 	if (err < 0)
 		return err;
 
@@ -695,6 +760,9 @@ static int gtp_newlink(struct net *src_net, struct net_device *dev,
 		goto out_hashtable;
 	}
 
+	gtp->role = role;
+	gtp->is_ipv6 = is_ipv6;
+
 	gn = net_generic(dev_net(dev), gtp_net_id);
 	list_add_rcu(&gtp->list, &gn->gtp_dev_list);
 
@@ -816,7 +884,8 @@ static void gtp_hashtable_free(struct gtp_dev *gtp)
 }
 
 static struct sock *gtp_encap_enable_socket(int fd, int type,
-					    struct gtp_dev *gtp)
+					    struct gtp_dev *gtp,
+					    bool is_ipv6)
 {
 	struct udp_tunnel_sock_cfg tuncfg = {NULL};
 	struct socket *sock;
@@ -837,6 +906,12 @@ static struct sock *gtp_encap_enable_socket(int fd, int type,
 		goto out_sock;
 	}
 
+	if (sock->sk->sk_family != (is_ipv6 ? AF_INET6 : AF_INET)) {
+		pr_debug("socket fd=%d not right family\n", fd);
+		sk = ERR_PTR(-EINVAL);
+		goto out_sock;
+	}
+
 	if (rcu_dereference_sk_user_data(sock->sk)) {
 		sk = ERR_PTR(-EBUSY);
 		goto out_sock;
@@ -869,16 +944,16 @@ static struct sock *gtp_encap_enable_socket(int fd, int type,
 	return sk;
 }
 
-static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
+static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[],
+			    bool is_ipv6)
 {
-	struct sock *sk1u = NULL;
-	struct sock *sk0 = NULL;
-	unsigned int role = GTP_ROLE_GGSN;
+	struct sock *sk0 = NULL, *sk1u = NULL;
 
 	if (data[IFLA_GTP_FD0]) {
 		u32 fd0 = nla_get_u32(data[IFLA_GTP_FD0]);
 
-		sk0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, gtp);
+		sk0 = gtp_encap_enable_socket(fd0, UDP_ENCAP_GTP0, gtp,
+					      is_ipv6);
 		if (IS_ERR(sk0))
 			return PTR_ERR(sk0);
 	}
@@ -886,7 +961,8 @@ static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
 	if (data[IFLA_GTP_FD1]) {
 		u32 fd1 = nla_get_u32(data[IFLA_GTP_FD1]);
 
-		sk1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp);
+		sk1u = gtp_encap_enable_socket(fd1, UDP_ENCAP_GTP1U, gtp,
+					       is_ipv6);
 		if (IS_ERR(sk1u)) {
 			if (sk0)
 				gtp_encap_disable_sock(sk0);
@@ -894,15 +970,8 @@ static int gtp_encap_enable(struct gtp_dev *gtp, struct nlattr *data[])
 		}
 	}
 
-	if (data[IFLA_GTP_ROLE]) {
-		role = nla_get_u32(data[IFLA_GTP_ROLE]);
-		if (role > GTP_ROLE_SGSN)
-			return -EINVAL;
-	}
-
 	gtp->sk0 = sk0;
 	gtp->sk1u = sk1u;
-	gtp->role = role;
 
 	return 0;
 }
@@ -938,8 +1007,16 @@ static void pdp_fill(struct pdp_ctx *pctx, struct genl_info *info)
 	__be16 default_port = 0;
 
 	pctx->gtp_version = nla_get_u32(info->attrs[GTPA_VERSION]);
-	pctx->peer_addr_ip4.s_addr =
-		nla_get_be32(info->attrs[GTPA_PEER_ADDRESS]);
+
+	if (info->attrs[GTPA_PEER_ADDRESS]) {
+		pctx->peer_af = AF_INET;
+		pctx->peer_addr_ip4.s_addr =
+			nla_get_in_addr(info->attrs[GTPA_PEER_ADDRESS]);
+	} else if (info->attrs[GTPA_PEER6_ADDRESS]) {
+		pctx->peer_af = AF_INET6;
+		pctx->peer_addr_ip6 = nla_get_in6_addr(
+					info->attrs[GTPA_PEER6_ADDRESS]);
+	}
 
 	switch (pctx->gtp_version) {
 	case GTP_V0:
@@ -1101,9 +1178,15 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 	int err;
 
 	if (!info->attrs[GTPA_VERSION] ||
-	   !info->attrs[GTPA_LINK] ||
-	   !info->attrs[GTPA_PEER_ADDRESS])
+	    !info->attrs[GTPA_LINK])
+		return -EINVAL;
+
+	if (!(!!info->attrs[GTPA_PEER_ADDRESS] ^
+	      !!info->attrs[GTPA_PEER6_ADDRESS])) {
+		/* Either v4 or v6 peer address must be set */
+
 		return -EINVAL;
+	}
 
 	if (!(!!info->attrs[GTPA_MS_ADDRESS] ^
 	      !!info->attrs[GTPA_MS6_ADDRESS])) {
@@ -1138,6 +1221,12 @@ static int gtp_genl_new_pdp(struct sk_buff *skb, struct genl_info *info)
 		goto out_unlock;
 	}
 
+	if ((info->attrs[GTPA_PEER_ADDRESS] && gtp->is_ipv6) ||
+	    (info->attrs[GTPA_PEER6_ADDRESS] && !gtp->is_ipv6)) {
+		err = -EINVAL;
+		goto out_unlock;
+	}
+
 	if (version == GTP_V0)
 		sk = gtp->sk0;
 	else if (version == GTP_V1)
@@ -1244,9 +1333,28 @@ static int gtp_genl_fill_info(struct sk_buff *skb, u32 snd_portid, u32 snd_seq,
 	if (genlh == NULL)
 		goto nlmsg_failure;
 
-	if (nla_put_u32(skb, GTPA_VERSION, pctx->gtp_version) ||
-	    nla_put_be32(skb, GTPA_PEER_ADDRESS, pctx->peer_addr_ip4.s_addr))
+	if (nla_put_u32(skb, GTPA_VERSION, pctx->gtp_version))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, GTPA_LINK, pctx->dev->ifindex))
+		goto nla_put_failure;
+
+	switch (pctx->peer_af) {
+	case AF_INET:
+		if (nla_put_be32(skb, GTPA_PEER_ADDRESS,
+				 pctx->peer_addr_ip4.s_addr))
+			goto nla_put_failure;
+
+		break;
+	case AF_INET6:
+		if (nla_put_in6_addr(skb, GTPA_PEER6_ADDRESS,
+				     &pctx->peer_addr_ip6))
+			goto nla_put_failure;
+
+		break;
+	default:
 		goto nla_put_failure;
+	}
 
 	switch (pctx->ms_af) {
 	case AF_INET:
@@ -1373,6 +1481,8 @@ static struct nla_policy gtp_genl_policy[GTPA_MAX + 1] = {
 	[GTPA_VERSION]		= { .type = NLA_U32, },
 	[GTPA_TID]		= { .type = NLA_U64, },
 	[GTPA_PEER_ADDRESS]	= { .type = NLA_U32, },
+	[GTPA_PEER6_ADDRESS]	= { .len = FIELD_SIZEOF(struct ipv6hdr,
+							daddr) },
 	[GTPA_MS_ADDRESS]	= { .type = NLA_U32, },
 	[GTPA_MS6_ADDRESS]	= { .len = FIELD_SIZEOF(struct ipv6hdr,
 							daddr) },
diff --git a/include/uapi/linux/gtp.h b/include/uapi/linux/gtp.h
index ae4e632c0360..8eec519fa754 100644
--- a/include/uapi/linux/gtp.h
+++ b/include/uapi/linux/gtp.h
@@ -29,6 +29,7 @@ enum gtp_attrs {
 	GTPA_PAD,
 	GTPA_PORT,
 	GTPA_MS6_ADDRESS,
+	GTPA_PEER6_ADDRESS,
 	__GTPA_MAX,
 };
 #define GTPA_MAX (__GTPA_MAX + 1)
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 8d062c58d5cb..81c26864abeb 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -552,6 +552,9 @@ enum {
 	IFLA_GTP_FD1,
 	IFLA_GTP_PDP_HASHSIZE,
 	IFLA_GTP_ROLE,
+	IFLA_GTP_AF,
+	IFLA_GTP_PORT0,
+	IFLA_GTP_PORT1,
 	__IFLA_GTP_MAX,
 };
 #define IFLA_GTP_MAX (__IFLA_GTP_MAX - 1)
-- 
2.11.0

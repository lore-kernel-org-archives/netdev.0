From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/8] l2tp: Add support for zero IPv6 checksums
Date: Mon, 12 May 2014 09:58:54 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405120947140.1323@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f201.google.com ([209.85.216.201]:37488 "EHLO
	mail-qc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932512AbaELQ6z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 May 2014 12:58:55 -0400
Received: by mail-qc0-f201.google.com with SMTP id l6so1068821qcy.4
        for <netdev@vger.kernel.org>; Mon, 12 May 2014 09:58:54 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added new L2TP configuration options to allow TX and RX of
zero checksums in UDP6. Default is that zero UDP6 checksums
are not allowed.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/uapi/linux/l2tp.h |  2 ++
 net/l2tp/l2tp_core.c      |  7 +++++++
 net/l2tp/l2tp_core.h      |  4 +++-
 net/l2tp/l2tp_netlink.c   | 12 ++++++++++++
 4 files changed, 24 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/l2tp.h b/include/uapi/linux/l2tp.h
index 8adb681..21caa26 100644
--- a/include/uapi/linux/l2tp.h
+++ b/include/uapi/linux/l2tp.h
@@ -124,6 +124,8 @@ enum {
 	L2TP_ATTR_STATS,		/* nested */
 	L2TP_ATTR_IP6_SADDR,		/* struct in6_addr */
 	L2TP_ATTR_IP6_DADDR,		/* struct in6_addr */
+	L2TP_ATTR_UDP_ZERO_CSUM6_TX,	/* u8 */
+	L2TP_ATTR_UDP_ZERO_CSUM6_RX,	/* u8 */
 	__L2TP_ATTR_MAX,
 };
 
diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 27b7cdb..28cdf45 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1102,6 +1102,8 @@ static void l2tp_xmit_ipv6_csum(struct sock *sk, struct sk_buff *skb,
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct udphdr *uh = udp_hdr(skb);
 
+	if (udp_get_no_check6_tx(sk))
+		skb->ip_summed = CHECKSUM_NONE;
 	if (!skb_dst(skb) || !skb_dst(skb)->dev ||
 	    !(skb_dst(skb)->dev->features & NETIF_F_IPV6_CSUM)) {
 		__wsum csum = skb_checksum(skb, 0, udp_len, 0);
@@ -1435,6 +1437,11 @@ static int l2tp_tunnel_sock_create(struct net *net,
 					     sizeof(udp6_addr), 0);
 			if (err < 0)
 				goto out;
+
+			if (cfg->udp6_zero_tx_checksums)
+				udp_set_no_check6_tx(sock->sk, true);
+			if (cfg->udp6_zero_rx_checksums)
+				udp_set_no_check6_rx(sock->sk, true);
 		} else
 #endif
 		{
diff --git a/net/l2tp/l2tp_core.h b/net/l2tp/l2tp_core.h
index 3f93ccd..68aa9ff 100644
--- a/net/l2tp/l2tp_core.h
+++ b/net/l2tp/l2tp_core.h
@@ -162,7 +162,9 @@ struct l2tp_tunnel_cfg {
 #endif
 	u16			local_udp_port;
 	u16			peer_udp_port;
-	unsigned int		use_udp_checksums:1;
+	unsigned int		use_udp_checksums:1,
+				udp6_zero_tx_checksums:1,
+				udp6_zero_rx_checksums:1;
 };
 
 struct l2tp_tunnel {
diff --git a/net/l2tp/l2tp_netlink.c b/net/l2tp/l2tp_netlink.c
index f3d331b..35e3d63 100644
--- a/net/l2tp/l2tp_netlink.c
+++ b/net/l2tp/l2tp_netlink.c
@@ -161,6 +161,13 @@ static int l2tp_nl_cmd_tunnel_create(struct sk_buff *skb, struct genl_info *info
 			cfg.peer_udp_port = nla_get_u16(info->attrs[L2TP_ATTR_UDP_DPORT]);
 		if (info->attrs[L2TP_ATTR_UDP_CSUM])
 			cfg.use_udp_checksums = nla_get_flag(info->attrs[L2TP_ATTR_UDP_CSUM]);
+
+#if IS_ENABLED(CONFIG_IPV6)
+		if (info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX])
+			cfg.udp6_zero_tx_checksums = nla_get_flag(info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_TX]);
+		if (info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX])
+			cfg.udp6_zero_rx_checksums = nla_get_flag(info->attrs[L2TP_ATTR_UDP_ZERO_CSUM6_RX]);
+#endif
 	}
 
 	if (info->attrs[L2TP_ATTR_DEBUG])
@@ -299,6 +306,11 @@ static int l2tp_nl_tunnel_send(struct sk_buff *skb, u32 portid, u32 seq, int fla
 		    nla_put_u16(skb, L2TP_ATTR_UDP_DPORT, ntohs(inet->inet_dport)) ||
 		    nla_put_u8(skb, L2TP_ATTR_UDP_CSUM, !sk->sk_no_check_tx))
 			goto nla_put_failure;
+#if IS_ENABLED(CONFIG_IPV6)
+		if (nla_put_u8(skb, L2TP_ATTR_UDP_ZERO_CSUM6_TX, udp_get_no_check6_tx(sk)) ||
+		    nla_put_u8(skb, L2TP_ATTR_UDP_ZERO_CSUM6_RX, udp_get_no_check6_rx(sk)))
+			goto nla_put_failure;
+#endif
 		/* NOBREAK */
 	case L2TP_ENCAPTYPE_IP:
 #if IS_ENABLED(CONFIG_IPV6)
-- 
1.9.1.423.g4596e3a

From: William Tu <u9012063@gmail.com>
Subject: [PATCH net-next 2/3] gre: add collect_md mode to ERSPAN tunnel
Date: Wed, 23 Aug 2017 07:55:56 -0700
Message-ID: <1503500157-3717-2-git-send-email-u9012063@gmail.com>
References: <1503500157-3717-1-git-send-email-u9012063@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35369 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932070AbdHWO4N (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 10:56:13 -0400
Received: by mail-pf0-f193.google.com with SMTP id k3so266914pfc.2
        for <netdev@vger.kernel.org>; Wed, 23 Aug 2017 07:56:13 -0700 (PDT)
Received: from localhost.localdomain ([73.93.152.207])
        by smtp.gmail.com with ESMTPSA id o18sm4416209pgd.51.2017.08.23.07.56.11
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 07:56:12 -0700 (PDT)
In-Reply-To: <1503500157-3717-1-git-send-email-u9012063@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to gre, vxlan, geneve, ipip tunnels, allow ERSPAN tunnels to
operate in 'collect metadata' mode.  bpf_skb_[gs]et_tunnel_key() helpers
can make use of it right away.  OVS can use it as well in the future.

Signed-off-by: William Tu <u9012063@gmail.com>
---
 include/net/ip_tunnels.h |   4 +-
 net/ipv4/ip_gre.c        | 102 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 101 insertions(+), 5 deletions(-)

diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
index 625c29329372..992652856fe8 100644
--- a/include/net/ip_tunnels.h
+++ b/include/net/ip_tunnels.h
@@ -154,8 +154,10 @@ struct ip_tunnel {
 #define TUNNEL_GENEVE_OPT	__cpu_to_be16(0x0800)
 #define TUNNEL_VXLAN_OPT	__cpu_to_be16(0x1000)
 #define TUNNEL_NOCACHE		__cpu_to_be16(0x2000)
+#define TUNNEL_ERSPAN_OPT	__cpu_to_be16(0x4000)
 
-#define TUNNEL_OPTIONS_PRESENT	(TUNNEL_GENEVE_OPT | TUNNEL_VXLAN_OPT)
+#define TUNNEL_OPTIONS_PRESENT \
+		(TUNNEL_GENEVE_OPT | TUNNEL_VXLAN_OPT | TUNNEL_ERSPAN_OPT)
 
 struct tnl_ptk_info {
 	__be16 flags;
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index cc4c6285179a..6840771912b5 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -113,6 +113,8 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
+static void erspan_build_header(struct sk_buff *skb,
+				__be32 id, u32 index, bool truncate);
 
 static unsigned int ipgre_net_id __read_mostly;
 static unsigned int gre_tap_net_id __read_mostly;
@@ -288,7 +290,33 @@ static int erspan_rcv(struct sk_buff *skb, struct tnl_ptk_info *tpi,
 					   false, false) < 0)
 			goto drop;
 
-		tunnel->index = ntohl(index);
+		if (tunnel->collect_md) {
+			struct ip_tunnel_info *info;
+			struct erspan_metadata *md;
+			__be64 tun_id;
+			__be16 flags;
+
+			tpi->flags |= TUNNEL_KEY;
+			flags = tpi->flags;
+			tun_id = key32_to_tunnel_id(tpi->key);
+
+			tun_dst = ip_tun_rx_dst(skb, flags,
+						tun_id, sizeof(*md));
+			if (!tun_dst)
+				return PACKET_REJECT;
+
+			md = ip_tunnel_info_opts(&tun_dst->u.tun_info);
+			if (!md)
+				return PACKET_REJECT;
+
+			md->index = index;
+			info = &tun_dst->u.tun_info;
+			info->key.tun_flags |= TUNNEL_ERSPAN_OPT;
+			info->options_len = sizeof(*md);
+		} else {
+			tunnel->index = ntohl(index);
+		}
+
 		skb_reset_mac_header(skb);
 		ip_tunnel_rcv(tunnel, skb, tpi, tun_dst, log_ecn_error);
 		return PACKET_RCVD;
@@ -524,6 +552,64 @@ static void gre_fb_xmit(struct sk_buff *skb, struct net_device *dev,
 	dev->stats.tx_dropped++;
 }
 
+static void erspan_fb_xmit(struct sk_buff *skb, struct net_device *dev,
+			   __be16 proto)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_info *tun_info;
+	const struct ip_tunnel_key *key;
+	struct erspan_metadata *md;
+	struct rtable *rt = NULL;
+	bool truncate = false;
+	struct flowi4 fl;
+	int tunnel_hlen;
+	__be16 df;
+
+	tun_info = skb_tunnel_info(skb);
+	if (unlikely(!tun_info || !(tun_info->mode & IP_TUNNEL_INFO_TX) ||
+		     ip_tunnel_info_af(tun_info) != AF_INET))
+		goto err_free_skb;
+
+	key = &tun_info->key;
+
+	/* ERSPAN has fixed 8 byte GRE header */
+	tunnel_hlen = 8 + sizeof(struct erspanhdr);
+
+	rt = prepare_fb_xmit(skb, dev, &fl, tunnel_hlen);
+	if (!rt)
+		return;
+
+	if (gre_handle_offloads(skb, false))
+		goto err_free_rt;
+
+	if (skb->len > dev->mtu) {
+		pskb_trim(skb, dev->mtu);
+		truncate = true;
+	}
+
+	md = ip_tunnel_info_opts(tun_info);
+	if (!md)
+		goto err_free_rt;
+
+	erspan_build_header(skb, tunnel_id_to_key32(key->tun_id),
+			    ntohl(md->index), truncate);
+
+	gre_build_header(skb, 8, TUNNEL_SEQ,
+			 htons(ETH_P_ERSPAN), 0, htonl(tunnel->o_seqno++));
+
+	df = key->tun_flags & TUNNEL_DONT_FRAGMENT ?  htons(IP_DF) : 0;
+
+	iptunnel_xmit(skb->sk, rt, skb, fl.saddr, key->u.ipv4.dst, IPPROTO_GRE,
+		      key->tos, key->ttl, df, false);
+	return;
+
+err_free_rt:
+	ip_rt_put(rt);
+err_free_skb:
+	kfree_skb(skb);
+	dev->stats.tx_dropped++;
+}
+
 static int gre_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
 {
 	struct ip_tunnel_info *info = skb_tunnel_info(skb);
@@ -637,6 +723,11 @@ static netdev_tx_t erspan_xmit(struct sk_buff *skb,
 	struct ip_tunnel *tunnel = netdev_priv(dev);
 	bool truncate = false;
 
+	if (tunnel->collect_md) {
+		erspan_fb_xmit(skb, dev, skb->protocol);
+		return NETDEV_TX_OK;
+	}
+
 	if (gre_handle_offloads(skb, false))
 		goto free_skb;
 
@@ -999,9 +1090,12 @@ static int erspan_validate(struct nlattr *tb[], struct nlattr *data[],
 		return ret;
 
 	/* ERSPAN should only have GRE sequence and key flag */
-	flags |= nla_get_be16(data[IFLA_GRE_OFLAGS]);
-	flags |= nla_get_be16(data[IFLA_GRE_IFLAGS]);
-	if (flags != (GRE_SEQ | GRE_KEY))
+	if (data[IFLA_GRE_OFLAGS])
+		flags |= nla_get_be16(data[IFLA_GRE_OFLAGS]);
+	if (data[IFLA_GRE_IFLAGS])
+		flags |= nla_get_be16(data[IFLA_GRE_IFLAGS]);
+	if (!data[IFLA_GRE_COLLECT_METADATA] &&
+	    flags != (GRE_SEQ | GRE_KEY))
 		return -EINVAL;
 
 	/* ERSPAN Session ID only has 10-bit. Since we reuse
-- 
2.7.4

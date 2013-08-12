From: Kristian Evensen <kristian.evensen@gmail.com>
Subject: [PATCH net-next] ipip: Add room for user-specified custom header
Date: Mon, 12 Aug 2013 10:39:38 +0200
Message-ID: <1376296778-1983-1-git-send-email-kristian.evensen@gmail.com>
Cc: Kristian Evensen <kristian.evensen@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f173.google.com ([74.125.82.173]:59135 "EHLO
	mail-we0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755196Ab3HLIju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Aug 2013 04:39:50 -0400
Received: by mail-we0-f173.google.com with SMTP id x55so5279150wes.32
        for <netdev@vger.kernel.org>; Mon, 12 Aug 2013 01:39:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds support for specifying the size of a custom header to be
inserted between the two IP headers. The actual content will be inserted later,
for example by a module that is attached to a hook.

A use-case for the feature provided by this patch is to ease the implementation
of custom tunneling protocols. Instead of implementing them directly in the
kernel and having to look out for changes in the kernel behavior/APIs, a
tunneling protocol can be implemented as an independent module.

To avoid breaking user space (by updating ip_tunnel_params), it is only possible
to specify the custom header length when an IPIP-tunnel is created using
netlink-messages.

Signed-off-by: Kristian Evensen <kristian.evensen@gmail.com>
---
 include/uapi/linux/if_tunnel.h |  1 +
 net/ipv4/ipip.c                | 20 ++++++++++++++++----
 2 files changed, 17 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index aee73d0..a8ef1d3 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -44,6 +44,7 @@ enum {
 	IFLA_IPTUN_REMOTE,
 	IFLA_IPTUN_TTL,
 	IFLA_IPTUN_TOS,
+	IFLA_IPTUN_HLEN,
 	IFLA_IPTUN_ENCAP_LIMIT,
 	IFLA_IPTUN_FLOWINFO,
 	IFLA_IPTUN_FLAGS,
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 51fc2a1..1e5bd85 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -190,13 +190,14 @@ static int ipip_rcv(struct sk_buff *skb)
 	struct ip_tunnel *tunnel;
 	const struct iphdr *iph;
 
-	if (iptunnel_pull_header(skb, 0, tpi.proto))
-		goto drop;
-
 	iph = ip_hdr(skb);
 	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, TUNNEL_NO_KEY,
 			iph->saddr, iph->daddr, 0);
+
 	if (tunnel) {
+		if (iptunnel_pull_header(skb, tunnel->hlen, tpi.proto))
+			goto drop;
+
 		if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
 			goto drop;
 		return ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
@@ -226,6 +227,9 @@ static netdev_tx_t ipip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 		skb->encapsulation = 1;
 	}
 
+	if (tunnel->hlen > 0)
+		skb_push(skb, tunnel->hlen);
+
 	ip_tunnel_xmit(skb, dev, tiph, tiph->protocol);
 	return NETDEV_TX_OK;
 
@@ -302,7 +306,6 @@ static int ipip_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	tunnel->hlen = 0;
 	tunnel->parms.iph.protocol = IPPROTO_IPIP;
 	return ip_tunnel_init(dev);
 }
@@ -345,8 +348,13 @@ static int ipip_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip_tunnel_parm p;
+	struct ip_tunnel *tunnel = netdev_priv(dev);
 
 	ipip_netlink_parms(data, &p);
+
+	if (data[IFLA_IPTUN_HLEN])
+		tunnel->hlen = nla_get_u32(data[IFLA_IPTUN_HLEN]);
+
 	return ip_tunnel_newlink(dev, tb, &p);
 }
 
@@ -373,6 +381,8 @@ static size_t ipip_get_size(const struct net_device *dev)
 		nla_total_size(4) +
 		/* IFLA_IPTUN_REMOTE */
 		nla_total_size(4) +
+		/* IFLA_IPTUN_HLEN */
+		nla_total_size(4) +
 		/* IFLA_IPTUN_TTL */
 		nla_total_size(1) +
 		/* IFLA_IPTUN_TOS */
@@ -390,6 +400,7 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	if (nla_put_u32(skb, IFLA_IPTUN_LINK, parm->link) ||
 	    nla_put_be32(skb, IFLA_IPTUN_LOCAL, parm->iph.saddr) ||
 	    nla_put_be32(skb, IFLA_IPTUN_REMOTE, parm->iph.daddr) ||
+	    nla_put_u32(skb, IFLA_IPTUN_HLEN, tunnel->hlen) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TTL, parm->iph.ttl) ||
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
@@ -405,6 +416,7 @@ static const struct nla_policy ipip_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_LINK]		= { .type = NLA_U32 },
 	[IFLA_IPTUN_LOCAL]		= { .type = NLA_U32 },
 	[IFLA_IPTUN_REMOTE]		= { .type = NLA_U32 },
+	[IFLA_IPTUN_HLEN]		= { .type = NLA_U32 },
 	[IFLA_IPTUN_TTL]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_TOS]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_PMTUDISC]		= { .type = NLA_U8 },
-- 
1.8.1.2

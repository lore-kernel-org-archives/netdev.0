From: Tom Herbert <therbert@google.com>
Subject: [PATCH v4 net-next 5/7] sit: Setup and TX path for sit/UDP foo-over-udp encapsulation
Date: Wed, 17 Sep 2014 12:25:59 -0700
Message-ID: <1410981961-15545-6-git-send-email-therbert@google.com>
References: <1410981961-15545-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:33510 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756527AbaIQT0c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 15:26:32 -0400
Received: by mail-pd0-f177.google.com with SMTP id r10so1306175pdi.8
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 12:26:32 -0700 (PDT)
In-Reply-To: <1410981961-15545-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added netlink handling of IP tunnel encapulation paramters, properly
adjust MTU for encapsulation. Added ip_tunnel_encap call to
ipip6_tunnel_xmit to actually perform FOU encapsulation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/sit.c | 107 +++++++++++++++++++++++++++++++++++++++++++++++++++------
 1 file changed, 97 insertions(+), 10 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 86e3fa8..db75809 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -822,6 +822,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	int addr_type;
 	u8 ttl;
 	int err;
+	u8 protocol = IPPROTO_IPV6;
+	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
 
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto tx_error;
@@ -911,8 +913,14 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		goto tx_error;
 	}
 
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
+	if (IS_ERR(skb)) {
+		ip_rt_put(rt);
+		goto out;
+	}
+
 	if (df) {
-		mtu = dst_mtu(&rt->dst) - sizeof(struct iphdr);
+		mtu = dst_mtu(&rt->dst) - t_hlen;
 
 		if (mtu < 68) {
 			dev->stats.collisions++;
@@ -947,7 +955,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	/*
 	 * Okay, now see if we can stuff it in the buffer as-is.
 	 */
-	max_headroom = LL_RESERVED_SPACE(tdev)+sizeof(struct iphdr);
+	max_headroom = LL_RESERVED_SPACE(tdev) + t_hlen;
 
 	if (skb_headroom(skb) < max_headroom || skb_shared(skb) ||
 	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
@@ -969,14 +977,13 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		ttl = iph6->hop_limit;
 	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 
-	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
-	if (IS_ERR(skb)) {
+	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0) {
 		ip_rt_put(rt);
-		goto out;
+		goto tx_error;
 	}
 
 	err = iptunnel_xmit(skb->sk, rt, skb, fl4.saddr, fl4.daddr,
-			    IPPROTO_IPV6, tos, ttl, df,
+			    protocol, tos, ttl, df,
 			    !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
@@ -1059,8 +1066,10 @@ static void ipip6_tunnel_bind_dev(struct net_device *dev)
 		tdev = __dev_get_by_index(tunnel->net, tunnel->parms.link);
 
 	if (tdev) {
+		int t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
 		dev->hard_header_len = tdev->hard_header_len + sizeof(struct iphdr);
-		dev->mtu = tdev->mtu - sizeof(struct iphdr);
+		dev->mtu = tdev->mtu - t_hlen;
 		if (dev->mtu < IPV6_MIN_MTU)
 			dev->mtu = IPV6_MIN_MTU;
 	}
@@ -1307,7 +1316,10 @@ done:
 
 static int ipip6_tunnel_change_mtu(struct net_device *dev, int new_mtu)
 {
-	if (new_mtu < IPV6_MIN_MTU || new_mtu > 0xFFF8 - sizeof(struct iphdr))
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
+	if (new_mtu < IPV6_MIN_MTU || new_mtu > 0xFFF8 - t_hlen)
 		return -EINVAL;
 	dev->mtu = new_mtu;
 	return 0;
@@ -1338,12 +1350,15 @@ static void ipip6_dev_free(struct net_device *dev)
 
 static void ipip6_tunnel_setup(struct net_device *dev)
 {
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
 	dev->netdev_ops		= &ipip6_netdev_ops;
 	dev->destructor		= ipip6_dev_free;
 
 	dev->type		= ARPHRD_SIT;
-	dev->hard_header_len	= LL_MAX_HEADER + sizeof(struct iphdr);
-	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr);
+	dev->hard_header_len	= LL_MAX_HEADER + t_hlen;
+	dev->mtu		= ETH_DATA_LEN - t_hlen;
 	dev->flags		= IFF_NOARP;
 	dev->priv_flags	       &= ~IFF_XMIT_DST_RELEASE;
 	dev->iflink		= 0;
@@ -1466,6 +1481,40 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 
 }
 
+/* This function returns true when ENCAP attributes are present in the nl msg */
+static bool ipip6_netlink_encap_parms(struct nlattr *data[],
+				      struct ip_tunnel_encap *ipencap)
+{
+	bool ret = false;
+
+	memset(ipencap, 0, sizeof(*ipencap));
+
+	if (!data)
+		return ret;
+
+	if (data[IFLA_IPTUN_ENCAP_TYPE]) {
+		ret = true;
+		ipencap->type = nla_get_u16(data[IFLA_IPTUN_ENCAP_TYPE]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_FLAGS]) {
+		ret = true;
+		ipencap->flags = nla_get_u16(data[IFLA_IPTUN_ENCAP_FLAGS]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_SPORT]) {
+		ret = true;
+		ipencap->sport = nla_get_u16(data[IFLA_IPTUN_ENCAP_SPORT]);
+	}
+
+	if (data[IFLA_IPTUN_ENCAP_DPORT]) {
+		ret = true;
+		ipencap->dport = nla_get_u16(data[IFLA_IPTUN_ENCAP_DPORT]);
+	}
+
+	return ret;
+}
+
 #ifdef CONFIG_IPV6_SIT_6RD
 /* This function returns true when 6RD attributes are present in the nl msg */
 static bool ipip6_netlink_6rd_parms(struct nlattr *data[],
@@ -1509,12 +1558,20 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct net *net = dev_net(dev);
 	struct ip_tunnel *nt;
+	struct ip_tunnel_encap ipencap;
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd ip6rd;
 #endif
 	int err;
 
 	nt = netdev_priv(dev);
+
+	if (ipip6_netlink_encap_parms(data, &ipencap)) {
+		err = ip_tunnel_encap_setup(nt, &ipencap);
+		if (err < 0)
+			return err;
+	}
+
 	ipip6_netlink_parms(data, &nt->parms);
 
 	if (ipip6_tunnel_locate(net, &nt->parms, 0))
@@ -1537,15 +1594,23 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 {
 	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_encap ipencap;
 	struct net *net = t->net;
 	struct sit_net *sitn = net_generic(net, sit_net_id);
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd ip6rd;
 #endif
+	int err;
 
 	if (dev == sitn->fb_tunnel_dev)
 		return -EINVAL;
 
+	if (ipip6_netlink_encap_parms(data, &ipencap)) {
+		err = ip_tunnel_encap_setup(t, &ipencap);
+		if (err < 0)
+			return err;
+	}
+
 	ipip6_netlink_parms(data, &p);
 
 	if (((dev->flags & IFF_POINTOPOINT) && !p.iph.daddr) ||
@@ -1599,6 +1664,14 @@ static size_t ipip6_get_size(const struct net_device *dev)
 		/* IFLA_IPTUN_6RD_RELAY_PREFIXLEN */
 		nla_total_size(2) +
 #endif
+		/* IFLA_IPTUN_ENCAP_TYPE */
+		nla_total_size(2) +
+		/* IFLA_IPTUN_ENCAP_FLAGS */
+		nla_total_size(2) +
+		/* IFLA_IPTUN_ENCAP_SPORT */
+		nla_total_size(2) +
+		/* IFLA_IPTUN_ENCAP_DPORT */
+		nla_total_size(2) +
 		0;
 }
 
@@ -1630,6 +1703,16 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 		goto nla_put_failure;
 #endif
 
+	if (nla_put_u16(skb, IFLA_IPTUN_ENCAP_TYPE,
+			tunnel->encap.type) ||
+	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_SPORT,
+			tunnel->encap.sport) ||
+	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_DPORT,
+			tunnel->encap.dport) ||
+	    nla_put_u16(skb, IFLA_IPTUN_ENCAP_FLAGS,
+			tunnel->encap.dport))
+		goto nla_put_failure;
+
 	return 0;
 
 nla_put_failure:
@@ -1651,6 +1734,10 @@ static const struct nla_policy ipip6_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_6RD_PREFIXLEN]	= { .type = NLA_U16 },
 	[IFLA_IPTUN_6RD_RELAY_PREFIXLEN] = { .type = NLA_U16 },
 #endif
+	[IFLA_IPTUN_ENCAP_TYPE]		= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_FLAGS]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
 };
 
 static void ipip6_dellink(struct net_device *dev, struct list_head *head)
-- 
2.1.0.rc2.206.gedb03e5

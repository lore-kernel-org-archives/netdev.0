From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 5/7] sit: TX path for sit/UDP foo-over-udp encapsulation
Date: Thu, 11 Sep 2014 13:07:34 -0700
Message-ID: <1410466056-30239-6-git-send-email-therbert@google.com>
References: <1410466056-30239-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:46036 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754709AbaIKUIS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Sep 2014 16:08:18 -0400
Received: by mail-pa0-f51.google.com with SMTP id kx10so10547335pab.10
        for <netdev@vger.kernel.org>; Thu, 11 Sep 2014 13:08:17 -0700 (PDT)
In-Reply-To: <1410466056-30239-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/sit.c | 81 +++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 74 insertions(+), 7 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 86e3fa8..fc65b60f 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -822,6 +822,7 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	int addr_type;
 	u8 ttl;
 	int err;
+	u8 protocol = IPPROTO_IPV6;
 
 	if (skb->protocol != htons(ETH_P_IPV6))
 		goto tx_error;
@@ -905,6 +906,17 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 	}
 	tdev = rt->dst.dev;
 
+	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
+	if (IS_ERR(skb)) {
+		ip_rt_put(rt);
+		goto tx_error;
+	}
+
+	if (ip_tunnel_encap(skb, tunnel, &protocol, &fl4) < 0) {
+		ip_rt_put(rt);
+		goto tx_error;
+	}
+
 	if (tdev == dev) {
 		ip_rt_put(rt);
 		dev->stats.collisions++;
@@ -969,14 +981,8 @@ static netdev_tx_t ipip6_tunnel_xmit(struct sk_buff *skb,
 		ttl = iph6->hop_limit;
 	tos = INET_ECN_encapsulate(tos, ipv6_get_dsfield(iph6));
 
-	skb = iptunnel_handle_offloads(skb, false, SKB_GSO_SIT);
-	if (IS_ERR(skb)) {
-		ip_rt_put(rt);
-		goto out;
-	}
-
 	err = iptunnel_xmit(skb->sk, rt, skb, fl4.saddr, fl4.daddr,
-			    IPPROTO_IPV6, tos, ttl, df,
+			    protocol, tos, ttl, df,
 			    !net_eq(tunnel->net, dev_net(dev)));
 	iptunnel_xmit_stats(err, &dev->stats, dev->tstats);
 	return NETDEV_TX_OK;
@@ -1089,6 +1095,12 @@ static void ipip6_tunnel_update(struct ip_tunnel *t, struct ip_tunnel_parm *p)
 	netdev_state_change(t->dev);
 }
 
+static int ipip6_tunnel_update_encap(struct ip_tunnel *t,
+				     struct ip_tunnel_encap *ipencap)
+{
+	return 0;
+}
+
 #ifdef CONFIG_IPV6_SIT_6RD
 static int ipip6_tunnel_update_6rd(struct ip_tunnel *t,
 				   struct ip_tunnel_6rd *ip6rd)
@@ -1135,6 +1147,12 @@ ipip6_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 	struct ip_tunnel_6rd ip6rd;
 #endif
 
+	/* Try generic tunnel ioctls first */
+	err = __ip_tunnel_gen_ioctl(dev, sitn->fb_tunnel_dev, ifr, cmd);
+	if (err != -ENOIOCTLCMD)
+		return err;
+
+	err = 0;
 	switch (cmd) {
 	case SIOCGETTUNNEL:
 #ifdef CONFIG_IPV6_SIT_6RD
@@ -1466,6 +1484,40 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 
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
@@ -1509,6 +1561,7 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 {
 	struct net *net = dev_net(dev);
 	struct ip_tunnel *nt;
+	struct ip_tunnel_encap ipencap;
 #ifdef CONFIG_IPV6_SIT_6RD
 	struct ip_tunnel_6rd ip6rd;
 #endif
@@ -1524,6 +1577,12 @@ static int ipip6_newlink(struct net *src_net, struct net_device *dev,
 	if (err < 0)
 		return err;
 
+	if (ipip6_netlink_encap_parms(data, &ipencap)) {
+		err = ipip6_tunnel_update_encap(nt, &ipencap);
+		if (err < 0)
+			return err;
+	}
+
 #ifdef CONFIG_IPV6_SIT_6RD
 	if (ipip6_netlink_6rd_parms(data, &ip6rd))
 		err = ipip6_tunnel_update_6rd(nt, &ip6rd);
@@ -1537,11 +1596,13 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
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
@@ -1562,6 +1623,12 @@ static int ipip6_changelink(struct net_device *dev, struct nlattr *tb[],
 
 	ipip6_tunnel_update(t, &p);
 
+	if (ipip6_netlink_encap_parms(data, &ipencap)) {
+		err = ipip6_tunnel_update_encap(t, &ipencap);
+		if (err < 0)
+			return err;
+	}
+
 #ifdef CONFIG_IPV6_SIT_6RD
 	if (ipip6_netlink_6rd_parms(data, &ip6rd))
 		return ipip6_tunnel_update_6rd(t, &ip6rd);
-- 
2.1.0.rc2.206.gedb03e5

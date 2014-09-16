From: Tom Herbert <therbert@google.com>
Subject: [PATCH v3 net-next 6/7] ipip: Setup and TX path for ipip/UDP foo-over-udp encapsulation
Date: Mon, 15 Sep 2014 20:30:23 -0700
Message-ID: <1410838224-19777-7-git-send-email-therbert@google.com>
References: <1410838224-19777-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:53026 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754040AbaIPDbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 23:31:09 -0400
Received: by mail-pd0-f177.google.com with SMTP id y10so7577745pdj.8
        for <netdev@vger.kernel.org>; Mon, 15 Sep 2014 20:31:08 -0700 (PDT)
In-Reply-To: <1410838224-19777-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netlink handling for IP tunnel encapsulation parameters and
and adjustment of MTU for encapsulation.  ip_tunnel_encap is called
from ip_tunnel_xmit to actually perform FOU encapsulation.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/ipip.c | 86 +++++++++++++++++++++++++++++++++++++++++++++++++++++++--
 1 file changed, 83 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 62eaa00..2985551 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -301,7 +301,8 @@ static int ipip_tunnel_init(struct net_device *dev)
 	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
 	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
 
-	tunnel->hlen = 0;
+	tunnel->tun_hlen = 0;
+	tunnel->hlen = tunnel->tun_hlen + tunnel->encap_hlen;
 	tunnel->parms.iph.protocol = IPPROTO_IPIP;
 	return ip_tunnel_init(dev);
 }
@@ -340,19 +341,73 @@ static void ipip_netlink_parms(struct nlattr *data[],
 		parms->iph.frag_off = htons(IP_DF);
 }
 
+/* This function returns true when ENCAP attributes are present in the nl msg */
+static bool ipip_netlink_encap_parms(struct nlattr *data[],
+				     struct ip_tunnel_encap *ipencap)
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
 static int ipip_newlink(struct net *src_net, struct net_device *dev,
 			struct nlattr *tb[], struct nlattr *data[])
 {
 	struct ip_tunnel_parm p;
+	struct ip_tunnel *t = netdev_priv(dev);
+	struct ip_tunnel_encap ipencap;
+	int err;
+
+	if (ipip_netlink_encap_parms(data, &ipencap)) {
+		err = ip_tunnel_encap_setup(t, &ipencap);
+		if (err < 0)
+			return err;
+	}
 
 	ipip_netlink_parms(data, &p);
-	return ip_tunnel_newlink(dev, tb, &p);
+	err = ip_tunnel_newlink(dev, tb, &p);
+
+	return err;
 }
 
 static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 			   struct nlattr *data[])
 {
+	struct ip_tunnel *t = netdev_priv(dev);
 	struct ip_tunnel_parm p;
+	struct ip_tunnel_encap ipencap;
+	int err;
+
+	if (ipip_netlink_encap_parms(data, &ipencap)) {
+		err = ip_tunnel_encap_setup(t, &ipencap);
+		if (err < 0)
+			return err;
+	}
 
 	ipip_netlink_parms(data, &p);
 
@@ -360,7 +415,9 @@ static int ipip_changelink(struct net_device *dev, struct nlattr *tb[],
 	    (!(dev->flags & IFF_POINTOPOINT) && p.iph.daddr))
 		return -EINVAL;
 
-	return ip_tunnel_changelink(dev, tb, &p);
+	err = ip_tunnel_changelink(dev, tb, &p);
+
+	return err;
 }
 
 static size_t ipip_get_size(const struct net_device *dev)
@@ -378,6 +435,14 @@ static size_t ipip_get_size(const struct net_device *dev)
 		nla_total_size(1) +
 		/* IFLA_IPTUN_PMTUDISC */
 		nla_total_size(1) +
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
 
@@ -394,6 +459,17 @@ static int ipip_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
 		       !!(parm->iph.frag_off & htons(IP_DF))))
 		goto nla_put_failure;
+
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
@@ -407,6 +483,10 @@ static const struct nla_policy ipip_policy[IFLA_IPTUN_MAX + 1] = {
 	[IFLA_IPTUN_TTL]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_TOS]		= { .type = NLA_U8 },
 	[IFLA_IPTUN_PMTUDISC]		= { .type = NLA_U8 },
+	[IFLA_IPTUN_ENCAP_TYPE]		= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_FLAGS]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_SPORT]	= { .type = NLA_U16 },
+	[IFLA_IPTUN_ENCAP_DPORT]	= { .type = NLA_U16 },
 };
 
 static struct rtnl_link_ops ipip_link_ops __read_mostly = {
-- 
2.1.0.rc2.206.gedb03e5

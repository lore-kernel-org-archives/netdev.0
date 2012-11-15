From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: [PATCH net-next 2/3] sit: fix sparse warnings
Date: Thu, 15 Nov 2012 09:53:35 +0100
Message-ID: <1352969616-30476-2-git-send-email-nicolas.dichtel@6wind.com>
References: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
Cc: davem@davemloft.net, Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 33.106-14-84.ripe.coltfrance.com ([84.14.106.33]:35922 "EHLO
	proxy.6wind.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755750Ab2KOIy4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 03:54:56 -0500
In-Reply-To: <1352969616-30476-1-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note that i_flags is defined as be16, but is used here like an u16. The test
in ipip6_tunnel_create() was just moved into this function.

Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
---
 net/ipv6/sit.c | 10 +++++-----
 1 file changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 7bd2a06..ca6c2c8 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -228,7 +228,7 @@ static int ipip6_tunnel_create(struct net_device *dev)
 		goto out;
 	ipip6_tunnel_clone_6rd(dev, sitn);
 
-	if (t->parms.i_flags & SIT_ISATAP)
+	if ((__force u16)t->parms.i_flags & SIT_ISATAP)
 		dev->priv_flags |= IFF_ISATAP;
 
 	err = register_netdevice(dev);
@@ -1240,10 +1240,10 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_IPTUN_LINK]);
 
 	if (data[IFLA_IPTUN_LOCAL])
-		parms->iph.saddr = nla_get_u32(data[IFLA_IPTUN_LOCAL]);
+		parms->iph.saddr = nla_get_be32(data[IFLA_IPTUN_LOCAL]);
 
 	if (data[IFLA_IPTUN_REMOTE])
-		parms->iph.daddr = nla_get_u32(data[IFLA_IPTUN_REMOTE]);
+		parms->iph.daddr = nla_get_be32(data[IFLA_IPTUN_REMOTE]);
 
 	if (data[IFLA_IPTUN_TTL]) {
 		parms->iph.ttl = nla_get_u8(data[IFLA_IPTUN_TTL]);
@@ -1258,7 +1258,7 @@ static void ipip6_netlink_parms(struct nlattr *data[],
 		parms->iph.frag_off = htons(IP_DF);
 
 	if (data[IFLA_IPTUN_FLAGS])
-		parms->i_flags = nla_get_u16(data[IFLA_IPTUN_FLAGS]);
+		parms->i_flags = nla_get_be16(data[IFLA_IPTUN_FLAGS]);
 }
 
 static int ipip6_newlink(struct net *src_net, struct net_device *dev,
@@ -1337,7 +1337,7 @@ static int ipip6_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	    nla_put_u8(skb, IFLA_IPTUN_TOS, parm->iph.tos) ||
 	    nla_put_u8(skb, IFLA_IPTUN_PMTUDISC,
 		       !!(parm->iph.frag_off & htons(IP_DF))) ||
-	    nla_put_u16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
+	    nla_put_be16(skb, IFLA_IPTUN_FLAGS, parm->i_flags))
 		goto nla_put_failure;
 	return 0;
 
-- 
1.7.12

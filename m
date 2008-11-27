From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 02/29: netns-aware ipt_addrtype
Date: Thu, 27 Nov 2008 17:15:06 +0100 (MET)
Message-ID: <20081127161505.13891.13844.sendpatchset@x2.localnet>
References: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:53357 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbYK0QPI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2008 11:15:08 -0500
In-Reply-To: <20081127161503.13891.62766.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d4ec52bae739409b2372fea30dba0e7a8d6b9181
Author: Alexey Dobriyan <adobriyan@gmail.com>
Date:   Tue Nov 4 14:21:48 2008 +0100

    netfilter: netns-aware ipt_addrtype
    
    Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/net/ipv4/netfilter/ipt_addrtype.c b/net/ipv4/netfilter/ipt_addrtype.c
index 88762f0..3b216be 100644
--- a/net/ipv4/netfilter/ipt_addrtype.c
+++ b/net/ipv4/netfilter/ipt_addrtype.c
@@ -23,24 +23,25 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
 MODULE_DESCRIPTION("Xtables: address type match for IPv4");
 
-static inline bool match_type(const struct net_device *dev, __be32 addr,
-			      u_int16_t mask)
+static inline bool match_type(struct net *net, const struct net_device *dev,
+			      __be32 addr, u_int16_t mask)
 {
-	return !!(mask & (1 << inet_dev_addr_type(&init_net, dev, addr)));
+	return !!(mask & (1 << inet_dev_addr_type(net, dev, addr)));
 }
 
 static bool
 addrtype_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 {
+	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct ipt_addrtype_info *info = par->matchinfo;
 	const struct iphdr *iph = ip_hdr(skb);
 	bool ret = true;
 
 	if (info->source)
-		ret &= match_type(NULL, iph->saddr, info->source) ^
+		ret &= match_type(net, NULL, iph->saddr, info->source) ^
 		       info->invert_source;
 	if (info->dest)
-		ret &= match_type(NULL, iph->daddr, info->dest) ^
+		ret &= match_type(net, NULL, iph->daddr, info->dest) ^
 		       info->invert_dest;
 
 	return ret;
@@ -49,6 +50,7 @@ addrtype_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 static bool
 addrtype_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
 {
+	struct net *net = dev_net(par->in ? par->in : par->out);
 	const struct ipt_addrtype_info_v1 *info = par->matchinfo;
 	const struct iphdr *iph = ip_hdr(skb);
 	const struct net_device *dev = NULL;
@@ -60,10 +62,10 @@ addrtype_mt_v1(const struct sk_buff *skb, const struct xt_match_param *par)
 		dev = par->out;
 
 	if (info->source)
-		ret &= match_type(dev, iph->saddr, info->source) ^
+		ret &= match_type(net, dev, iph->saddr, info->source) ^
 		       (info->flags & IPT_ADDRTYPE_INVERT_SOURCE);
 	if (ret && info->dest)
-		ret &= match_type(dev, iph->daddr, info->dest) ^
+		ret &= match_type(net, dev, iph->daddr, info->dest) ^
 		       !!(info->flags & IPT_ADDRTYPE_INVERT_DEST);
 	return ret;
 }

From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 31/33] netns ct: fixup DNAT in netns
Date: Mon,  8 Sep 2008 07:03:08 +0400
Message-ID: <1220842990-30500-31-git-send-email-adobriyan@gmail.com>
References: <48C01046.2070704@trash.net>
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.188]:48601 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753093AbYIHDD1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Sep 2008 23:03:27 -0400
Received: by mu-out-0910.google.com with SMTP id g7so1163113muf.1
        for <netdev@vger.kernel.org>; Sun, 07 Sep 2008 20:03:27 -0700 (PDT)
In-Reply-To: <48C01046.2070704@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
index 0a02a8c..f929352 100644
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ b/net/ipv4/netfilter/nf_nat_rule.c
@@ -91,13 +91,13 @@ static unsigned int ipt_snat_target(struct sk_buff *skb,
 }
 
 /* Before 2.6.11 we did implicit source NAT if required. Warn about change. */
-static void warn_if_extra_mangle(__be32 dstip, __be32 srcip)
+static void warn_if_extra_mangle(struct net *net, __be32 dstip, __be32 srcip)
 {
 	static int warned = 0;
 	struct flowi fl = { .nl_u = { .ip4_u = { .daddr = dstip } } };
 	struct rtable *rt;
 
-	if (ip_route_output_key(&init_net, &rt, &fl) != 0)
+	if (ip_route_output_key(net, &rt, &fl) != 0)
 		return;
 
 	if (rt->rt_src != srcip && !warned) {
@@ -130,7 +130,7 @@ static unsigned int ipt_dnat_target(struct sk_buff *skb,
 
 	if (hooknum == NF_INET_LOCAL_OUT &&
 	    mr->range[0].flags & IP_NAT_RANGE_MAP_IPS)
-		warn_if_extra_mangle(ip_hdr(skb)->daddr,
+		warn_if_extra_mangle(dev_net(out), ip_hdr(skb)->daddr,
 				     mr->range[0].min_ip);
 
 	return nf_nat_setup_info(ct, &mr->range[0], IP_NAT_MANIP_DST);

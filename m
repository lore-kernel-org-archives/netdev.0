From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net] lwtunnel: remove source and destination UDP port config option
Date: Thu, 24 Sep 2015 10:43:07 +0200
Message-ID: <340cecb5131ca28951399bf245ec37d2ca577109.1443084164.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	ebiederm@xmission.com (Eric W. Biederman)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39099 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752393AbbIXInh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 04:43:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The UDP tunnel config is asymmetric wrt. to the ports used. The source and
destination ports from one direction of the tunnel are not related to the
ports of the other direction. We need to be able to respond to ARP requests
using the correct ports without involving routing.

As the consequence, UDP ports need to be fixed property of the tunnel
interface and cannot be set per route. Remove the ability to set ports per
route. This is still okay to do, as no kernel has been released with these
attributes yet.

Note that the ability to specify source and destination ports is preserved
for other users of the lwtunnel API which don't use routes for tunnel key
specification (like openvswitch).

If in the future we rework ARP handling to allow port specification, the
attributes can be added back.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
Acked-by: Thomas Graf <tgraf@suug.ch>
---
Resending what was formerly patch 2/2 of the "lwtunnel: make it really work,
for IPv4" series, without change. This patch can be applied standalone and
is rather important before the uAPI is set in stone.
---
 include/uapi/linux/lwtunnel.h |  4 ----
 net/ipv4/ip_tunnel_core.c     | 24 ------------------------
 2 files changed, 28 deletions(-)

diff --git a/include/uapi/linux/lwtunnel.h b/include/uapi/linux/lwtunnel.h
index 34141a5dfe74..f8b01887a495 100644
--- a/include/uapi/linux/lwtunnel.h
+++ b/include/uapi/linux/lwtunnel.h
@@ -21,8 +21,6 @@ enum lwtunnel_ip_t {
 	LWTUNNEL_IP_SRC,
 	LWTUNNEL_IP_TTL,
 	LWTUNNEL_IP_TOS,
-	LWTUNNEL_IP_SPORT,
-	LWTUNNEL_IP_DPORT,
 	LWTUNNEL_IP_FLAGS,
 	__LWTUNNEL_IP_MAX,
 };
@@ -36,8 +34,6 @@ enum lwtunnel_ip6_t {
 	LWTUNNEL_IP6_SRC,
 	LWTUNNEL_IP6_HOPLIMIT,
 	LWTUNNEL_IP6_TC,
-	LWTUNNEL_IP6_SPORT,
-	LWTUNNEL_IP6_DPORT,
 	LWTUNNEL_IP6_FLAGS,
 	__LWTUNNEL_IP6_MAX,
 };
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 9b97204b8c81..175b340aac23 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -198,8 +198,6 @@ static const struct nla_policy ip_tun_policy[LWTUNNEL_IP_MAX + 1] = {
 	[LWTUNNEL_IP_SRC]	= { .type = NLA_U32 },
 	[LWTUNNEL_IP_TTL]	= { .type = NLA_U8 },
 	[LWTUNNEL_IP_TOS]	= { .type = NLA_U8 },
-	[LWTUNNEL_IP_SPORT]	= { .type = NLA_U16 },
-	[LWTUNNEL_IP_DPORT]	= { .type = NLA_U16 },
 	[LWTUNNEL_IP_FLAGS]	= { .type = NLA_U16 },
 };
 
@@ -239,12 +237,6 @@ static int ip_tun_build_state(struct net_device *dev, struct nlattr *attr,
 	if (tb[LWTUNNEL_IP_TOS])
 		tun_info->key.tos = nla_get_u8(tb[LWTUNNEL_IP_TOS]);
 
-	if (tb[LWTUNNEL_IP_SPORT])
-		tun_info->key.tp_src = nla_get_be16(tb[LWTUNNEL_IP_SPORT]);
-
-	if (tb[LWTUNNEL_IP_DPORT])
-		tun_info->key.tp_dst = nla_get_be16(tb[LWTUNNEL_IP_DPORT]);
-
 	if (tb[LWTUNNEL_IP_FLAGS])
 		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP_FLAGS]);
 
@@ -266,8 +258,6 @@ static int ip_tun_fill_encap_info(struct sk_buff *skb,
 	    nla_put_be32(skb, LWTUNNEL_IP_SRC, tun_info->key.u.ipv4.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TOS, tun_info->key.tos) ||
 	    nla_put_u8(skb, LWTUNNEL_IP_TTL, tun_info->key.ttl) ||
-	    nla_put_u16(skb, LWTUNNEL_IP_SPORT, tun_info->key.tp_src) ||
-	    nla_put_u16(skb, LWTUNNEL_IP_DPORT, tun_info->key.tp_dst) ||
 	    nla_put_u16(skb, LWTUNNEL_IP_FLAGS, tun_info->key.tun_flags))
 		return -ENOMEM;
 
@@ -281,8 +271,6 @@ static int ip_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
 		+ nla_total_size(4)	/* LWTUNNEL_IP_SRC */
 		+ nla_total_size(1)	/* LWTUNNEL_IP_TOS */
 		+ nla_total_size(1)	/* LWTUNNEL_IP_TTL */
-		+ nla_total_size(2)	/* LWTUNNEL_IP_SPORT */
-		+ nla_total_size(2)	/* LWTUNNEL_IP_DPORT */
 		+ nla_total_size(2);	/* LWTUNNEL_IP_FLAGS */
 }
 
@@ -305,8 +293,6 @@ static const struct nla_policy ip6_tun_policy[LWTUNNEL_IP6_MAX + 1] = {
 	[LWTUNNEL_IP6_SRC]		= { .len = sizeof(struct in6_addr) },
 	[LWTUNNEL_IP6_HOPLIMIT]		= { .type = NLA_U8 },
 	[LWTUNNEL_IP6_TC]		= { .type = NLA_U8 },
-	[LWTUNNEL_IP6_SPORT]		= { .type = NLA_U16 },
-	[LWTUNNEL_IP6_DPORT]		= { .type = NLA_U16 },
 	[LWTUNNEL_IP6_FLAGS]		= { .type = NLA_U16 },
 };
 
@@ -346,12 +332,6 @@ static int ip6_tun_build_state(struct net_device *dev, struct nlattr *attr,
 	if (tb[LWTUNNEL_IP6_TC])
 		tun_info->key.tos = nla_get_u8(tb[LWTUNNEL_IP6_TC]);
 
-	if (tb[LWTUNNEL_IP6_SPORT])
-		tun_info->key.tp_src = nla_get_be16(tb[LWTUNNEL_IP6_SPORT]);
-
-	if (tb[LWTUNNEL_IP6_DPORT])
-		tun_info->key.tp_dst = nla_get_be16(tb[LWTUNNEL_IP6_DPORT]);
-
 	if (tb[LWTUNNEL_IP6_FLAGS])
 		tun_info->key.tun_flags = nla_get_u16(tb[LWTUNNEL_IP6_FLAGS]);
 
@@ -373,8 +353,6 @@ static int ip6_tun_fill_encap_info(struct sk_buff *skb,
 	    nla_put_in6_addr(skb, LWTUNNEL_IP6_SRC, &tun_info->key.u.ipv6.src) ||
 	    nla_put_u8(skb, LWTUNNEL_IP6_HOPLIMIT, tun_info->key.tos) ||
 	    nla_put_u8(skb, LWTUNNEL_IP6_TC, tun_info->key.ttl) ||
-	    nla_put_u16(skb, LWTUNNEL_IP6_SPORT, tun_info->key.tp_src) ||
-	    nla_put_u16(skb, LWTUNNEL_IP6_DPORT, tun_info->key.tp_dst) ||
 	    nla_put_u16(skb, LWTUNNEL_IP6_FLAGS, tun_info->key.tun_flags))
 		return -ENOMEM;
 
@@ -388,8 +366,6 @@ static int ip6_tun_encap_nlsize(struct lwtunnel_state *lwtstate)
 		+ nla_total_size(16)	/* LWTUNNEL_IP6_SRC */
 		+ nla_total_size(1)	/* LWTUNNEL_IP6_HOPLIMIT */
 		+ nla_total_size(1)	/* LWTUNNEL_IP6_TC */
-		+ nla_total_size(2)	/* LWTUNNEL_IP6_SPORT */
-		+ nla_total_size(2)	/* LWTUNNEL_IP6_DPORT */
 		+ nla_total_size(2);	/* LWTUNNEL_IP6_FLAGS */
 }
 
-- 
1.8.3.1

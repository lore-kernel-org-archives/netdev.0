From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next v5] IPv6: add the option to use anycast addresses as source addresses in echo reply
Date: Tue,  7 Jan 2014 14:57:27 +0100
Message-ID: <1389103047-3380-1-git-send-email-fx.lebail@yahoo.com>
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp07.smtpout.orange.fr ([80.12.242.129]:23735 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617AbaAGOOX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 09:14:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows to follow a recommandation of RFC4942.

- Add "anycast_src_echo_reply" sysctl to control the use of anycast addresses
  as source addresses for ICMPv6 echo reply. This sysctl is false by default
  to preserve existing behavior.
- Add inline check ipv6_anycast_destination().
- Use them in icmpv6_echo_reply().

Reference:
RFC4942 - IPv6 Transition/Coexistence Security Considerations
   (http://tools.ietf.org/html/rfc4942#section-2.1.6)

2.1.6. Anycast Traffic Identification and Security

   [...]
   To avoid exposing knowledge about the internal structure of the
   network, it is recommended that anycast servers now take advantage of
   the ability to return responses with the anycast address as the
   source address if possible.

Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
v4: update Subject and Documentation, this work also with anycast addresses
    created via API, not just with Subnet-Router anycast addresses.

v5: alternative way, replace ipv6_chk_acast_addr() test by
    ipv6_anycast_destination() test.

 Documentation/networking/ip-sysctl.txt |    7 +++++++
 include/net/ip6_route.h                |    7 +++++++
 include/net/netns/ipv6.h               |    1 +
 net/ipv6/icmp.c                        |    4 +++-
 net/ipv6/sysctl_net_ipv6.c             |    8 ++++++++
 5 files changed, 26 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d71afa8..7373115 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1094,6 +1094,13 @@ bindv6only - BOOLEAN
 
 	Default: FALSE (as specified in RFC3493)
 
+anycast_src_echo_reply - BOOLEAN
+	Controls the use of anycast addresses as source addresses for ICMPv6
+	echo reply
+	TRUE:  enabled
+	FALSE: disabled
+	Default: FALSE
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
diff --git a/include/net/ip6_route.h b/include/net/ip6_route.h
index 1fb6cdd..017badb 100644
--- a/include/net/ip6_route.h
+++ b/include/net/ip6_route.h
@@ -152,6 +152,13 @@ static inline bool ipv6_unicast_destination(const struct sk_buff *skb)
 	return rt->rt6i_flags & RTF_LOCAL;
 }
 
+static inline bool ipv6_anycast_destination(const struct sk_buff *skb)
+{
+	struct rt6_info *rt = (struct rt6_info *) skb_dst(skb);
+
+	return rt->rt6i_flags & RTF_ANYCAST;
+}
+
 int ip6_fragment(struct sk_buff *skb, int (*output)(struct sk_buff *));
 
 static inline int ip6_skb_dst_mtu(struct sk_buff *skb)
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 0fb2401..76fc7d1 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -73,6 +73,7 @@ struct netns_ipv6 {
 #endif
 	atomic_t		dev_addr_genid;
 	atomic_t		rt_genid;
+	int			anycast_src_echo_reply;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 5d42009..9a809a4 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
-	if (!ipv6_unicast_destination(skb))
+	if (!ipv6_unicast_destination(skb) &&
+	    !(net->ipv6.anycast_src_echo_reply &&
+	      ipv6_anycast_destination(skb)))
 		saddr = NULL;
 
 	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 107b2f1..6b6a2c8 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -24,6 +24,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "anycast_src_echo_reply",
+		.data		= &init_net.ipv6.anycast_src_echo_reply,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -51,6 +58,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 	if (!ipv6_table)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
+	ipv6_table[1].data = &net->ipv6.anycast_src_echo_reply;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)

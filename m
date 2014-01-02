From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next v2] IPv6: add option to use Subnet-Router anycast addresses as source addresses
Date: Thu,  2 Jan 2014 16:53:48 +0100
Message-ID: <1388678028-15413-1-git-send-email-fx.lebail@yahoo.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp11.smtpout.orange.fr ([80.12.242.133]:41374 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751136AbaABQJX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 11:09:23 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change allows to follow a recommandation of RFC4942.

- Add "enable_anycast_src" sysctl to control the use of Subnet-Router anycast
  addresses as source addresses. This sysctl is false by default to preserve
  existing behavior.
- Use it in ip6_datagram_send_ctl() and icmpv6_echo_reply().

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
 Documentation/networking/ip-sysctl.txt |    6 ++++++
 include/net/netns/ipv6.h               |    1 +
 net/ipv6/datagram.c                    |    3 +++
 net/ipv6/icmp.c                        |    4 +++-
 net/ipv6/sysctl_net_ipv6.c             |    8 ++++++++
 5 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index d71afa8..2a062a7 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1094,6 +1094,12 @@ bindv6only - BOOLEAN
 
 	Default: FALSE (as specified in RFC3493)
 
+enable_anycast_src - BOOLEAN
+	Controls the use of Subnet-Router anycast addresses as source addresses
+	TRUE:  enabled
+	FALSE: disabled
+	Default: FALSE
+
 IPv6 Fragmentation:
 
 ip6frag_high_thresh - INTEGER
diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 0fb2401..3d3aa86 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -73,6 +73,7 @@ struct netns_ipv6 {
 #endif
 	atomic_t		dev_addr_genid;
 	atomic_t		rt_genid;
+	int			enable_anycast_src;
 };
 
 #if IS_ENABLED(CONFIG_NF_DEFRAG_IPV6)
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 6983058..0b32095 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -668,6 +668,9 @@ int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
 			if (addr_type != IPV6_ADDR_ANY) {
 				int strict = __ipv6_addr_src_scope(addr_type) <= IPV6_ADDR_SCOPE_LINKLOCAL;
 				if (!(inet_sk(sk)->freebind || inet_sk(sk)->transparent) &&
+					!(net->ipv6.enable_anycast_src &&
+					  ipv6_chk_acast_addr(net, NULL,
+							      &src_info->ipi6_addr)) &&
 				    !ipv6_chk_addr(net, &src_info->ipi6_addr,
 						   strict ? dev : NULL, 0))
 					err = -EINVAL;
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 5d42009..1c25c85 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -556,7 +556,9 @@ static void icmpv6_echo_reply(struct sk_buff *skb)
 
 	saddr = &ipv6_hdr(skb)->daddr;
 
-	if (!ipv6_unicast_destination(skb))
+	if (!ipv6_unicast_destination(skb) &&
+	    !(net->ipv6.enable_anycast_src &&
+	      ipv6_chk_acast_addr(net, NULL, saddr)))
 		saddr = NULL;
 
 	memcpy(&tmp_hdr, icmph, sizeof(tmp_hdr));
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index 107b2f1..67c09f5 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -24,6 +24,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "enable_anycast_src",
+		.data		= &init_net.ipv6.enable_anycast_src,
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
+	ipv6_table[1].data = &net->ipv6.enable_anycast_src;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)

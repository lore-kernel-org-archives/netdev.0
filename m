From: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
Subject: [PATCH net-next] IPv6: add option to use anycast addresses as source addresses in icmp error messages
Date: Mon, 13 Jan 2014 18:22:44 +0100
Message-ID: <1389633764-5210-1-git-send-email-fx.lebail@yahoo.com>
Cc: Bill Fink <billfink@mindspring.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki Yoshifuji <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Francois-Xavier Le Bail <fx.lebail@yahoo.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp06.smtpout.orange.fr ([80.12.242.128]:51932 "EHLO
	smtp.smtpout.orange.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752581AbaAMRlm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Jan 2014 12:41:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

- Add "anycast_src_icmp_error" sysctl to control the use of anycast addresses
  as source addresses for ICMPv6 error messages. This sysctl is false by
  default to preserve existing behavior.
- Use it in icmp6_send().

Suggested-by: Bill Fink <billfink@mindspring.com>
Signed-off-by: Francois-Xavier Le Bail <fx.lebail@yahoo.com>
---
This change allows to follow a recommandation of RFC4942.

RFC4942 - IPv6 Transition/Coexistence Security Considerations
   (http://tools.ietf.org/html/rfc4942#section-2.1.6)

2.1.6. Anycast Traffic Identification and Security
   [...]
   To avoid exposing knowledge about the internal structure of the
   network, it is recommended that anycast servers now take advantage of
   the ability to return responses with the anycast address as the
   source address if possible.

 include/net/netns/ipv6.h   |    1 +
 net/ipv6/icmp.c            |    4 +++-
 net/ipv6/sysctl_net_ipv6.c |    8 ++++++++
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/net/netns/ipv6.h b/include/net/netns/ipv6.h
index 592fecd..75abbbe 100644
--- a/include/net/netns/ipv6.h
+++ b/include/net/netns/ipv6.h
@@ -29,6 +29,7 @@ struct netns_sysctl_ipv6 {
 	int ip6_rt_min_advmss;
 	int icmpv6_time;
 	int anycast_src_echo_reply;
+	int anycast_src_icmp_error;
 };
 
 struct netns_ipv6 {
diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 13640f2..410aa32 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -412,7 +412,9 @@ static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
 	 */
 	addr_type = ipv6_addr_type(&hdr->daddr);
 
-	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0))
+	if (ipv6_chk_addr(net, &hdr->daddr, skb->dev, 0) ||
+	    (net->ipv6.sysctl.anycast_src_icmp_error &&
+	     ipv6_chk_acast_addr_src(net, skb->dev, &hdr->daddr)))
 		saddr = &hdr->daddr;
 
 	/*
diff --git a/net/ipv6/sysctl_net_ipv6.c b/net/ipv6/sysctl_net_ipv6.c
index b51b268..5f6d5bb 100644
--- a/net/ipv6/sysctl_net_ipv6.c
+++ b/net/ipv6/sysctl_net_ipv6.c
@@ -31,6 +31,13 @@ static struct ctl_table ipv6_table_template[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec
 	},
+	{
+		.procname	= "anycast_src_icmp_error",
+		.data		= &init_net.ipv6.sysctl.anycast_src_icmp_error,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
 	{ }
 };
 
@@ -59,6 +66,7 @@ static int __net_init ipv6_sysctl_net_init(struct net *net)
 		goto out;
 	ipv6_table[0].data = &net->ipv6.sysctl.bindv6only;
 	ipv6_table[1].data = &net->ipv6.sysctl.anycast_src_echo_reply;
+	ipv6_table[2].data = &net->ipv6.sysctl.anycast_src_icmp_error;
 
 	ipv6_route_table = ipv6_route_sysctl_init(net);
 	if (!ipv6_route_table)

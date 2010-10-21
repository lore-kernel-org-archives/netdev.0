From: kaber@trash.net
Subject: [PATCH 08/72] ipvs: make rerouting optional with snat_reroute
Date: Thu, 21 Oct 2010 17:18:55 +0200
Message-ID: <1287674399-31455-9-git-send-email-kaber@trash.net>
References: <1287674399-31455-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59995 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab0JUPUE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 11:20:04 -0400
In-Reply-To: <1287674399-31455-1-git-send-email-kaber@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

	Add new sysctl flag "snat_reroute". Recent kernels use
ip_route_me_harder() to route LVS-NAT responses properly by
VIP when there are multiple paths to client. But setups
that do not have alternative default routes can skip this
routing lookup by using snat_reroute=0.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/net/ip_vs.h             |    1 +
 net/netfilter/ipvs/ip_vs_core.c |   37 +++++++++++++++++++++++++++++--------
 net/netfilter/ipvs/ip_vs_ctl.c  |    8 ++++++++
 3 files changed, 38 insertions(+), 8 deletions(-)

diff --git a/include/net/ip_vs.h b/include/net/ip_vs.h
index e8ec523..3915a4f 100644
--- a/include/net/ip_vs.h
+++ b/include/net/ip_vs.h
@@ -801,6 +801,7 @@ extern int sysctl_ip_vs_expire_quiescent_template;
 extern int sysctl_ip_vs_sync_threshold[2];
 extern int sysctl_ip_vs_nat_icmp_send;
 extern int sysctl_ip_vs_conntrack;
+extern int sysctl_ip_vs_snat_reroute;
 extern struct ip_vs_stats ip_vs_stats;
 extern const struct ctl_path net_vs_ctl_path[];
 
diff --git a/net/netfilter/ipvs/ip_vs_core.c b/net/netfilter/ipvs/ip_vs_core.c
index 7fbc80d..06c388b 100644
--- a/net/netfilter/ipvs/ip_vs_core.c
+++ b/net/netfilter/ipvs/ip_vs_core.c
@@ -929,20 +929,31 @@ handle_response(int af, struct sk_buff *skb, struct ip_vs_protocol *pp,
 		ip_send_check(ip_hdr(skb));
 	}
 
+	/*
+	 * nf_iterate does not expect change in the skb->dst->dev.
+	 * It looks like it is not fatal to enable this code for hooks
+	 * where our handlers are at the end of the chain list and
+	 * when all next handlers use skb->dst->dev and not outdev.
+	 * It will definitely route properly the inout NAT traffic
+	 * when multiple paths are used.
+	 */
+
 	/* For policy routing, packets originating from this
 	 * machine itself may be routed differently to packets
 	 * passing through.  We want this packet to be routed as
 	 * if it came from this machine itself.  So re-compute
 	 * the routing information.
 	 */
+	if (sysctl_ip_vs_snat_reroute) {
 #ifdef CONFIG_IP_VS_IPV6
-	if (af == AF_INET6) {
-		if (ip6_route_me_harder(skb) != 0)
-			goto drop;
-	} else
+		if (af == AF_INET6) {
+			if (ip6_route_me_harder(skb) != 0)
+				goto drop;
+		} else
 #endif
-		if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
-			goto drop;
+			if (ip_route_me_harder(skb, RTN_LOCAL) != 0)
+				goto drop;
+	}
 
 	IP_VS_DBG_PKT(10, pp, skb, 0, "After SNAT");
 
@@ -991,8 +1002,13 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 		if (unlikely(iph.protocol == IPPROTO_ICMPV6)) {
 			int related, verdict = ip_vs_out_icmp_v6(skb, &related);
 
-			if (related)
+			if (related) {
+				if (sysctl_ip_vs_snat_reroute &&
+					NF_ACCEPT == verdict &&
+					ip6_route_me_harder(skb))
+					verdict = NF_DROP;
 				return verdict;
+			}
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 	} else
@@ -1000,8 +1016,13 @@ ip_vs_out(unsigned int hooknum, struct sk_buff *skb,
 		if (unlikely(iph.protocol == IPPROTO_ICMP)) {
 			int related, verdict = ip_vs_out_icmp(skb, &related);
 
-			if (related)
+			if (related) {
+				if (sysctl_ip_vs_snat_reroute &&
+					NF_ACCEPT == verdict &&
+					ip_route_me_harder(skb, RTN_LOCAL))
+					verdict = NF_DROP;
 				return verdict;
+			}
 			ip_vs_fill_iphdr(af, skb_network_header(skb), &iph);
 		}
 
diff --git a/net/netfilter/ipvs/ip_vs_ctl.c b/net/netfilter/ipvs/ip_vs_ctl.c
index d2d842f..e637cd0 100644
--- a/net/netfilter/ipvs/ip_vs_ctl.c
+++ b/net/netfilter/ipvs/ip_vs_ctl.c
@@ -91,6 +91,7 @@ int sysctl_ip_vs_nat_icmp_send = 0;
 #ifdef CONFIG_IP_VS_NFCT
 int sysctl_ip_vs_conntrack;
 #endif
+int sysctl_ip_vs_snat_reroute = 1;
 
 
 #ifdef CONFIG_IP_VS_DEBUG
@@ -1599,6 +1600,13 @@ static struct ctl_table vs_vars[] = {
 		.mode		= 0644,
 		.proc_handler	= proc_do_defense_mode,
 	},
+	{
+		.procname	= "snat_reroute",
+		.data		= &sysctl_ip_vs_snat_reroute,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= &proc_dointvec,
+	},
 #if 0
 	{
 		.procname	= "timeout_established",
-- 
1.7.1


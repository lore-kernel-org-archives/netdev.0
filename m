From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCHv3  3/4][RFC]     net: basic xfrm/netfilter support for UDP-Lite
Date: Tue, 19 Sep 2006 08:25:35 +0100
Message-ID: <200609190825.35251@strip-the-willow>
References: <200607141719.02766@strip-the-willow> <20060727.223010.63131639.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:48373 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751190AbWISHZv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 03:25:51 -0400
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
In-Reply-To: <20060727.223010.63131639.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Basic xfrm and netfilter support for UDP-Lite:
  * matching of UDP-Lite packets
  * LOG support
  * header file support

--
 include/net/xfrm.h            |    2 ++
 net/ipv4/netfilter/ipt_LOG.c  |   11 ++++++++---
 net/ipv4/xfrm4_policy.c       |    1 +
 net/ipv6/netfilter/ip6t_LOG.c |   10 +++++++---
 net/ipv6/xfrm6_policy.c       |    1 +
 net/netfilter/xt_multiport.c  |    9 +++++----
 net/netfilter/xt_tcpudp.c     |   20 +++++++++++++++++++-
 7 files changed, 43 insertions(+), 11 deletions(-)

diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index bf8e2df..e697862 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -468,6 +468,7 @@ u16 xfrm_flowi_sport(struct flowi *fl)
 	switch(fl->proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE:
 	case IPPROTO_SCTP:
 		port = fl->fl_ip_sport;
 		break;
@@ -493,6 +494,7 @@ u16 xfrm_flowi_dport(struct flowi *fl)
 	switch(fl->proto) {
 	case IPPROTO_TCP:
 	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE:
 	case IPPROTO_SCTP:
 		port = fl->fl_ip_dport;
 		break;
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 4795985..22b53ea 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -180,6 +180,7 @@ _decode_session4(struct sk_buff *skb, st
 	if (!(iph->frag_off & htons(IP_MF | IP_OFFSET))) {
 		switch (iph->protocol) {
 		case IPPROTO_UDP:
+		case IPPROTO_UDPLITE:
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 9391c4c..ea94bd1 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -252,6 +252,7 @@ _decode_session6(struct sk_buff *skb, st
 			break;
 
 		case IPPROTO_UDP:
+		case IPPROTO_UDPLITE:
 		case IPPROTO_TCP:
 		case IPPROTO_SCTP:
 		case IPPROTO_DCCP:
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index e76a68e..46414b5 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -10,7 +10,7 @@ #include <linux/netfilter/xt_tcpudp.h>
 #include <linux/netfilter_ipv4/ip_tables.h>
 #include <linux/netfilter_ipv6/ip6_tables.h>
 
-MODULE_DESCRIPTION("x_tables match for TCP and UDP, supports IPv4 and IPv6");
+MODULE_DESCRIPTION("x_tables match for TCP and UDP(-Lite), supports IPv4 and IPv6");
 MODULE_LICENSE("GPL");
 MODULE_ALIAS("xt_tcp");
 MODULE_ALIAS("xt_udp");
@@ -234,6 +234,24 @@ static struct xt_match xt_tcpudp_match[]
 		.proto		= IPPROTO_UDP,
 		.me		= THIS_MODULE,
 	},
+	{
+		.name		= "udplite",
+		.family		= AF_INET,
+		.checkentry	= udp_checkentry,
+		.match		= udp_match,
+		.matchsize	= sizeof(struct xt_udp),
+		.proto		= IPPROTO_UDPLITE,
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "udplite",
+		.family		= AF_INET6,
+		.checkentry	= udp_checkentry,
+		.match		= udp_match,
+		.matchsize	= sizeof(struct xt_udp),
+		.proto		= IPPROTO_UDPLITE,
+		.me		= THIS_MODULE,
+	},
 };
 
 static int __init xt_tcpudp_init(void)
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index d3aefd3..9127f85 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -1,5 +1,5 @@
-/* Kernel module to match one of a list of TCP/UDP/SCTP/DCCP ports: ports are in
-   the same place so we can treat them as equal. */
+/* Kernel module to match one of a list of TCP/UDP(-Lite)/SCTP/DCCP ports:
+ * ports are in the same place so we can treat them as equal. */
 
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2004 Netfilter Core Team <coreteam@netfilter.org>
@@ -161,8 +161,9 @@ check(u_int16_t proto,
       u_int8_t count)
 {
 	/* Must specify supported protocol, no unknown flags or bad count */
-	return (proto == IPPROTO_TCP || proto == IPPROTO_UDP
-		|| proto == IPPROTO_SCTP || proto == IPPROTO_DCCP)
+	return ( proto == IPPROTO_TCP  ||
+		 proto == IPPROTO_UDP  || proto == IPPROTO_UDPLITE ||
+		 proto == IPPROTO_SCTP || proto == IPPROTO_DCCP      )
 		&& !(ip_invflags & XT_INV_PROTO)
 		&& (match_flags == XT_MULTIPORT_SOURCE
 		    || match_flags == XT_MULTIPORT_DESTINATION
diff --git a/net/ipv6/netfilter/ip6t_LOG.c b/net/ipv6/netfilter/ip6t_LOG.c
index 0cf537d..3cb6bb7 100644
--- a/net/ipv6/netfilter/ip6t_LOG.c
+++ b/net/ipv6/netfilter/ip6t_LOG.c
@@ -270,11 +270,15 @@ static void dump_packet(const struct nf_
 		}
 		break;
 	}
-	case IPPROTO_UDP: {
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE: {
 		struct udphdr _udph, *uh;
 
-		/* Max length: 10 "PROTO=UDP " */
-		printk("PROTO=UDP ");
+		if (currenthdr == IPPROTO_UDP)
+			/* Max length: 10 "PROTO=UDP "     */
+			printk("PROTO=UDP " );
+		else	/* Max length: 14 "PROTO=UDPLITE " */
+			printk("PROTO=UDPLITE ");
 
 		if (fragment)
 			break;
diff --git a/net/ipv4/netfilter/ipt_LOG.c b/net/ipv4/netfilter/ipt_LOG.c
index 7dc820d..46eee64 100644
--- a/net/ipv4/netfilter/ipt_LOG.c
+++ b/net/ipv4/netfilter/ipt_LOG.c
@@ -171,11 +171,15 @@ static void dump_packet(const struct nf_
 		}
 		break;
 	}
-	case IPPROTO_UDP: {
+	case IPPROTO_UDP:
+	case IPPROTO_UDPLITE: {
 		struct udphdr _udph, *uh;
 
-		/* Max length: 10 "PROTO=UDP " */
-		printk("PROTO=UDP ");
+		if (ih->protocol == IPPROTO_UDP)
+			/* Max length: 10 "PROTO=UDP "     */
+			printk("PROTO=UDP " );
+		else	/* Max length: 14 "PROTO=UDPLITE " */
+			printk("PROTO=UDPLITE ");
 
 		if (ntohs(ih->frag_off) & IP_OFFSET)
 			break;
@@ -341,6 +345,7 @@ static void dump_packet(const struct nf_
 	/* IP:      40+46+6+11+127 = 230 */
 	/* TCP:     10+max(25,20+30+13+9+32+11+127) = 252 */
 	/* UDP:     10+max(25,20) = 35 */
+	/* UDPLITE: 14+max(25,20) = 39 */
 	/* ICMP:    11+max(25, 18+25+max(19,14,24+3+n+10,3+n+10)) = 91+n */
 	/* ESP:     10+max(25)+15 = 50 */
 	/* AH:      9+max(25)+15 = 49 */

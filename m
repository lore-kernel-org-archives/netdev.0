From: Julian Anastasov <ja@ssi.bg>
Subject: [2.6 PATCH] ipvs - remove some unused fields from the protocols
Date: Tue, 7 Oct 2003 01:16:36 +0300 (EEST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.44.0310070104470.6107-100000@u.domain.uli>
References: <20031006000225.AF7642C0A7@lists.samba.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@redhat.com>, Wensong Zhang <wensong@linux-vs.org>,
        <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20031006000225.AF7642C0A7@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


	Hello,

	The promised removal of some unused fields. For inclusion after 
comments from Rusty. Rusty, it seems we can not convert the transmitters 
to NF_STOLEN, ip_vs_null_xmit returns NF_ACCEPT.

Regards,

Julian Anastasov <ja@ssi.bg>


# This is a BitKeeper generated patch for the following project:
# Project Name: Linux kernel tree
# This patch format is intended for GNU patch command version 2.5 or higher.
# This patch includes the following deltas:
#	           ChangeSet	1.1357  -> 1.1358 
#	net/ipv4/ipvs/ip_vs_core.c	1.4     -> 1.5    
#	 include/net/ip_vs.h	1.5     -> 1.6    
#	net/ipv4/ipvs/ip_vs_proto_icmp.c	1.2     -> 1.3    
#	net/ipv4/ipvs/ip_vs_proto_tcp.c	1.3     -> 1.4    
#	net/ipv4/ipvs/ip_vs_proto_ah.c	1.2     -> 1.3    
#	net/ipv4/ipvs/ip_vs_proto_esp.c	1.2     -> 1.3    
#	net/ipv4/ipvs/ip_vs_proto_udp.c	1.3     -> 1.4    
#
# The following is the BitKeeper ChangeSet Log
# --------------------------------------------
# 03/10/07	ja@ssi.bg	1.1358
# [IPVS]: remove some unused fields from the protocols
# --------------------------------------------
#
diff -Nru a/include/net/ip_vs.h b/include/net/ip_vs.h
--- a/include/net/ip_vs.h	Tue Oct  7 01:01:36 2003
+++ b/include/net/ip_vs.h	Tue Oct  7 01:01:36 2003
@@ -435,11 +435,7 @@
 	struct ip_vs_protocol	*next;
 	char			*name;
 	__u16			protocol;
-	int			minhlen;
-	int			minhlen_icmp;
 	int			dont_defrag;
-	int			skip_nonexisting;
-	int			slave;		/* if controlled by others */
 	atomic_t		appcnt;		/* counter of proto app incs */
 	int			*timeout_table;	/* protocol timeout table */
 
@@ -528,7 +524,10 @@
 	struct ip_vs_dest       *dest;          /* real server */
 	atomic_t                in_pkts;        /* incoming packet counter */
 
-	/* packet transmitter for different forwarding methods */
+	/* packet transmitter for different forwarding methods.  If it
+	   mangles the packet, it must return NF_DROP or NF_STOLEN, otherwise
+	   this must be changed to a sk_buff **.
+	 */
 	int (*packet_xmit)(struct sk_buff *skb, struct ip_vs_conn *cp,
 			   struct ip_vs_protocol *pp);
 
diff -Nru a/net/ipv4/ipvs/ip_vs_core.c b/net/ipv4/ipvs/ip_vs_core.c
--- a/net/ipv4/ipvs/ip_vs_core.c	Tue Oct  7 01:01:36 2003
+++ b/net/ipv4/ipvs/ip_vs_core.c	Tue Oct  7 01:01:36 2003
@@ -660,7 +660,7 @@
 
 	/* Is the embedded protocol header present? */
 	if (unlikely(ciph.frag_off & __constant_htons(IP_OFFSET) &&
-		     (pp->minhlen || pp->dont_defrag)))
+		     pp->dont_defrag))
 		return NF_ACCEPT;
 
 	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking outgoing ICMP for");
@@ -911,7 +911,7 @@
 
 	/* Is the embedded protocol header present? */
 	if (unlikely(ciph.frag_off & __constant_htons(IP_OFFSET) &&
-		     (pp->minhlen || pp->dont_defrag)))
+		     pp->dont_defrag))
 		return NF_ACCEPT;
 
 	IP_VS_DBG_PKT(11, pp, skb, offset, "Checking incoming ICMP for");
diff -Nru a/net/ipv4/ipvs/ip_vs_proto_ah.c b/net/ipv4/ipvs/ip_vs_proto_ah.c
--- a/net/ipv4/ipvs/ip_vs_proto_ah.c	Tue Oct  7 01:01:36 2003
+++ b/net/ipv4/ipvs/ip_vs_proto_ah.c	Tue Oct  7 01:01:36 2003
@@ -69,11 +69,11 @@
 	if (!cp) {
 		/*
 		 * We are not sure if the packet is from our
-		 * service, so the caller should check skip_nonexisting
+		 * service, so our conn_schedule hook should return NF_ACCEPT
 		 */
 		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
 			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse?"ICMP+":"",
+			  inverse ? "ICMP+" : "",
 			  pp->name,
 			  NIPQUAD(iph->saddr),
 			  NIPQUAD(iph->daddr));
@@ -104,11 +104,6 @@
 	}
 
 	if (!cp) {
-		/*
-		 * We are not sure if the packet is from our
-		 * service, so the caller should check skip_nonexisting
-		 * or our conn_schedule hook should return NF_ACCEPT
-		 */
 		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
 			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
 			  inverse ? "ICMP+" : "",
@@ -167,11 +162,7 @@
 struct ip_vs_protocol ip_vs_protocol_ah = {
 	.name =			"AH",
 	.protocol =		IPPROTO_AH,
-	.minhlen =		0,
-	.minhlen_icmp =		0,
 	.dont_defrag =		1,
-	.skip_nonexisting =	1,
-	.slave =		1,
 	.init =			ah_init,
 	.exit =			ah_exit,
 	.conn_schedule =	ah_conn_schedule,
@@ -179,11 +170,11 @@
 	.conn_out_get =		ah_conn_out_get,
 	.snat_handler =		NULL,
 	.dnat_handler =		NULL,
+	.csum_check =		NULL,
 	.state_transition =	NULL,
 	.register_app =		NULL,
 	.unregister_app =	NULL,
 	.app_conn_bind =	NULL,
-	.csum_check =		NULL,
 	.debug_packet =		ah_debug_packet,
 	.timeout_change =	NULL,		/* ISAKMP */
 	.set_state_timeout =	NULL,
diff -Nru a/net/ipv4/ipvs/ip_vs_proto_esp.c b/net/ipv4/ipvs/ip_vs_proto_esp.c
--- a/net/ipv4/ipvs/ip_vs_proto_esp.c	Tue Oct  7 01:01:36 2003
+++ b/net/ipv4/ipvs/ip_vs_proto_esp.c	Tue Oct  7 01:01:36 2003
@@ -69,7 +69,7 @@
 	if (!cp) {
 		/*
 		 * We are not sure if the packet is from our
-		 * service, so the caller should check skip_nonexisting
+		 * service, so our conn_schedule hook should return NF_ACCEPT
 		 */
 		IP_VS_DBG(12, "Unknown ISAKMP entry for outin packet "
 			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
@@ -104,14 +104,9 @@
 	}
 
 	if (!cp) {
-		/*
-		 * We are not sure if the packet is from our
-		 * service, so the caller should check skip_nonexisting
-		 * or our conn_schedule hook should return NF_ACCEPT
-		 */
 		IP_VS_DBG(12, "Unknown ISAKMP entry for inout packet "
 			  "%s%s %u.%u.%u.%u->%u.%u.%u.%u\n",
-			  inverse?"ICMP+":"",
+			  inverse ? "ICMP+" : "",
 			  pp->name,
 			  NIPQUAD(iph->saddr),
 			  NIPQUAD(iph->daddr));
@@ -166,11 +161,7 @@
 struct ip_vs_protocol ip_vs_protocol_esp = {
 	.name =			"ESP",
 	.protocol =		IPPROTO_ESP,
-	.minhlen =		0,
-	.minhlen_icmp =		0,
 	.dont_defrag =		1,
-	.skip_nonexisting =	1,
-	.slave =		1,
 	.init =			esp_init,
 	.exit =			esp_exit,
 	.conn_schedule =	esp_conn_schedule,
diff -Nru a/net/ipv4/ipvs/ip_vs_proto_icmp.c b/net/ipv4/ipvs/ip_vs_proto_icmp.c
--- a/net/ipv4/ipvs/ip_vs_proto_icmp.c	Tue Oct  7 01:01:36 2003
+++ b/net/ipv4/ipvs/ip_vs_proto_icmp.c	Tue Oct  7 01:01:36 2003
@@ -163,11 +163,7 @@
 struct ip_vs_protocol ip_vs_protocol_icmp = {
 	.name =			"ICMP",
 	.protocol =		IPPROTO_ICMP,
-	.minhlen =		sizeof(struct icmphdr),
-	.minhlen_icmp =		8,
 	.dont_defrag =		0,
-	.skip_nonexisting =	0,
-	.slave =		0,
 	.init =			icmp_init,
 	.exit =			icmp_exit,
 	.conn_schedule =	icmp_conn_schedule,
diff -Nru a/net/ipv4/ipvs/ip_vs_proto_tcp.c b/net/ipv4/ipvs/ip_vs_proto_tcp.c
--- a/net/ipv4/ipvs/ip_vs_proto_tcp.c	Tue Oct  7 01:01:36 2003
+++ b/net/ipv4/ipvs/ip_vs_proto_tcp.c	Tue Oct  7 01:01:36 2003
@@ -132,7 +132,7 @@
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->slave && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(*pskb, pp))
 			return 0;
 
 		/* Call application helper if needed */
@@ -180,7 +180,7 @@
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->slave && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(*pskb, pp))
 			return 0;
 
 		/*
@@ -614,11 +614,7 @@
 struct ip_vs_protocol ip_vs_protocol_tcp = {
 	.name =			"TCP",
 	.protocol =		IPPROTO_TCP,
-	.minhlen =		sizeof(struct tcphdr),
-	.minhlen_icmp =		8,
 	.dont_defrag =		0,
-	.skip_nonexisting =	0,
-	.slave =		0,
 	.appcnt =		ATOMIC_INIT(0),
 	.init =			tcp_init,
 	.exit =			tcp_exit,
diff -Nru a/net/ipv4/ipvs/ip_vs_proto_udp.c b/net/ipv4/ipvs/ip_vs_proto_udp.c
--- a/net/ipv4/ipvs/ip_vs_proto_udp.c	Tue Oct  7 01:01:36 2003
+++ b/net/ipv4/ipvs/ip_vs_proto_udp.c	Tue Oct  7 01:01:36 2003
@@ -133,7 +133,7 @@
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->slave && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(*pskb, pp))
 			return 0;
 
 		/*
@@ -187,7 +187,7 @@
 
 	if (unlikely(cp->app != NULL)) {
 		/* Some checks before mangling */
-		if (pp->csum_check && !pp->slave && !pp->csum_check(*pskb, pp))
+		if (pp->csum_check && !pp->csum_check(*pskb, pp))
 			return 0;
 
 		/*
@@ -401,11 +401,7 @@
 struct ip_vs_protocol ip_vs_protocol_udp = {
 	.name =			"UDP",
 	.protocol =		IPPROTO_UDP,
-	.minhlen =		sizeof(struct udphdr),
-	.minhlen_icmp =		8,
 	.dont_defrag =		0,
-	.skip_nonexisting =	0,
-	.slave =		0,
 	.init =			udp_init,
 	.exit =			udp_exit,
 	.conn_schedule =	udp_conn_schedule,

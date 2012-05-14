From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 17/17] netfilter: cttimeout use pernet data of l4proto
Date: Mon, 14 May 2012 16:52:27 +0800
Message-ID: <1336985547-31960-18-git-send-email-gaofeng@cn.fujitsu.com>
References: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:27016 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755144Ab2ENIxM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2012 04:53:12 -0400
In-Reply-To: <1336985547-31960-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace global data with pernet data of l4proto

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    3 ++-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    3 ++-
 net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
 net/netfilter/nf_conntrack_proto_generic.c     |    3 ++-
 net/netfilter/nf_conntrack_proto_gre.c         |    5 +++--
 net/netfilter/nf_conntrack_proto_sctp.c        |    3 ++-
 net/netfilter/nf_conntrack_proto_tcp.c         |    3 ++-
 net/netfilter/nf_conntrack_proto_udp.c         |    5 +++--
 net/netfilter/nf_conntrack_proto_udplite.c     |    5 +++--
 9 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index c80b73c..87e0827 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -283,13 +283,14 @@ static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[],
 				      struct net *net, void *data)
 {
 	unsigned int *timeout = data;
+	struct nf_icmp_net *in = icmp_pernet(net);
 
 	if (tb[CTA_TIMEOUT_ICMP_TIMEOUT]) {
 		*timeout =
 			ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMP_TIMEOUT])) * HZ;
 	} else {
 		/* Set default ICMP timeout. */
-		*timeout = nf_ct_icmp_timeout;
+		*timeout = in->timeout;
 	}
 	return 0;
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 0ea5ba9..0a191a7 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -290,13 +290,14 @@ static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[],
 					struct net *net, void *data)
 {
 	unsigned int *timeout = data;
+	struct nf_icmp_net *in = icmpv6_pernet(net);
 
 	if (tb[CTA_TIMEOUT_ICMPV6_TIMEOUT]) {
 		*timeout =
 		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_ICMPV6_TIMEOUT])) * HZ;
 	} else {
 		/* Set default ICMPv6 timeout. */
-		*timeout = nf_ct_icmpv6_timeout;
+		*timeout = in->timeout;
 	}
 	return 0;
 }
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index b301fb0..e7c71ed 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -715,7 +715,7 @@ static int dccp_nlattr_size(void)
 static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[],
 				      struct net *net, void *data)
 {
-	struct dccp_net *dn = dccp_pernet(&init_net);
+	struct dccp_net *dn = dccp_pernet(net);
 	unsigned int *timeouts = data;
 	int i;
 
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index de326f4..a69c478 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -79,13 +79,14 @@ static int generic_timeout_nlattr_to_obj(struct nlattr *tb[],
 					 struct net *net, void *data)
 {
 	unsigned int *timeout = data;
+	struct nf_generic_net *gn = generic_pernet(net);
 
 	if (tb[CTA_TIMEOUT_GENERIC_TIMEOUT])
 		*timeout =
 		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_GENERIC_TIMEOUT])) * HZ;
 	else {
 		/* Set default generic timeout. */
-		*timeout = nf_ct_generic_timeout;
+		*timeout = gn->timeout;
 	}
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index e4cc5e4..2a29ca5 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -308,10 +308,11 @@ static int gre_timeout_nlattr_to_obj(struct nlattr *tb[],
 				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct netns_proto_gre *net_gre = gre_pernet(net);
 
 	/* set default timeouts for GRE. */
-	timeouts[GRE_CT_UNREPLIED] = gre_timeouts[GRE_CT_UNREPLIED];
-	timeouts[GRE_CT_REPLIED] = gre_timeouts[GRE_CT_REPLIED];
+	timeouts[GRE_CT_UNREPLIED] = net_gre->gre_timeouts[GRE_CT_UNREPLIED];
+	timeouts[GRE_CT_REPLIED] = net_gre->gre_timeouts[GRE_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_GRE_UNREPLIED]) {
 		timeouts[GRE_CT_UNREPLIED] =
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index a28f3c4..ee8f2b5 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -566,11 +566,12 @@ static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
 				      struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct sctp_net *sn = sctp_pernet(net);
 	int i;
 
 	/* set default SCTP timeouts. */
 	for (i=0; i<SCTP_CONNTRACK_MAX; i++)
-		timeouts[i] = sctp_timeouts[i];
+		timeouts[i] = sn->timeouts[i];
 
 	/* there's a 1:1 mapping between attributes and protocol states. */
 	for (i=CTA_TIMEOUT_SCTP_UNSPEC+1; i<CTA_TIMEOUT_SCTP_MAX+1; i++) {
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index c0c0010..58f9523 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1263,11 +1263,12 @@ static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[],
 				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct nf_tcp_net *tn = tcp_pernet(net);
 	int i;
 
 	/* set default TCP timeouts. */
 	for (i=0; i<TCP_CONNTRACK_TIMEOUT_MAX; i++)
-		timeouts[i] = tcp_timeouts[i];
+		timeouts[i] = tn->timeouts[i];
 
 	if (tb[CTA_TIMEOUT_TCP_SYN_SENT]) {
 		timeouts[TCP_CONNTRACK_SYN_SENT] =
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 14444a9..70ed8b9 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -160,10 +160,11 @@ static int udp_timeout_nlattr_to_obj(struct nlattr *tb[],
 				     struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct nf_udp_net *un = udp_pernet(net);
 
 	/* set default timeouts for UDP. */
-	timeouts[UDP_CT_UNREPLIED] = udp_timeouts[UDP_CT_UNREPLIED];
-	timeouts[UDP_CT_REPLIED] = udp_timeouts[UDP_CT_REPLIED];
+	timeouts[UDP_CT_UNREPLIED] = un->timeouts[UDP_CT_UNREPLIED];
+	timeouts[UDP_CT_REPLIED] = un->timeouts[UDP_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_UDP_UNREPLIED]) {
 		timeouts[UDP_CT_UNREPLIED] =
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 34bd65f..807c9ab 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -176,10 +176,11 @@ static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[],
 					 struct net *net, void *data)
 {
 	unsigned int *timeouts = data;
+	struct udplite_net *un = udplite_pernet(net);
 
 	/* set default timeouts for UDPlite. */
-	timeouts[UDPLITE_CT_UNREPLIED] = udplite_timeouts[UDPLITE_CT_UNREPLIED];
-	timeouts[UDPLITE_CT_REPLIED] = udplite_timeouts[UDPLITE_CT_REPLIED];
+	timeouts[UDPLITE_CT_UNREPLIED] = un->timeouts[UDPLITE_CT_UNREPLIED];
+	timeouts[UDPLITE_CT_REPLIED] = un->timeouts[UDPLITE_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_UDPLITE_UNREPLIED]) {
 		timeouts[UDPLITE_CT_UNREPLIED] =
-- 
1.7.7.6

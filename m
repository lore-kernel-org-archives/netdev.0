From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 17/17] netfilter: cttimeout use pernet data of l4proto
Date: Fri, 27 Apr 2012 17:38:04 +0800
Message-ID: <1335519484-6089-18-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitsu.com>
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:36137 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1760009Ab2D0Jh6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2012 05:37:58 -0400
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

replace global data with pernet data of l4proto

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
---
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    8 +++++---
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    7 +++++--
 net/netfilter/nf_conntrack_proto_dccp.c        |    6 ++++--
 net/netfilter/nf_conntrack_proto_generic.c     |    6 ++++--
 net/netfilter/nf_conntrack_proto_gre.c         |   10 ++++++----
 net/netfilter/nf_conntrack_proto_sctp.c        |    7 +++++--
 net/netfilter/nf_conntrack_proto_tcp.c         |    8 +++++---
 net/netfilter/nf_conntrack_proto_udp.c         |   10 ++++++----
 net/netfilter/nf_conntrack_proto_udplite.c     |   10 ++++++----
 9 files changed, 46 insertions(+), 26 deletions(-)

diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 90da247..d84e294 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -279,16 +279,18 @@ static int icmp_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int icmp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net,
+				      void *data)
 {
 	unsigned int *timeout = data;
-
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
index 12ca315..7db08f8 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -286,16 +286,19 @@ static int icmpv6_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int icmpv6_timeout_nlattr_to_obj(struct nlattr *tb[],
+					struct net *net,
+					void *data)
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
index bc2ed4c..db6727a 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -712,9 +712,11 @@ static int dccp_nlattr_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int dccp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net,
+				      void *data)
 {
-	struct dccp_net *dn = dccp_pernet(&init_net);
+	struct dccp_net *dn = dccp_pernet(net);
 	unsigned int *timeouts = data;
 	int i;
 
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index 42b9cd6..9c3fa0a 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -75,7 +75,9 @@ static bool generic_new(struct nf_conn *ct, const struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int generic_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int generic_timeout_nlattr_to_obj(struct nlattr *tb[],
+					 struct net *net,
+					 void *data)
 {
 	unsigned int *timeout = data;
 
@@ -84,7 +86,7 @@ static int generic_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
 		    ntohl(nla_get_be32(tb[CTA_TIMEOUT_GENERIC_TIMEOUT])) * HZ;
 	else {
 		/* Set default generic timeout. */
-		*timeout = nf_ct_generic_timeout;
+		*timeout = generic_pernet(net)->timeout;
 	}
 
 	return 0;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 8d70452..afb8179 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -304,13 +304,15 @@ static void gre_destroy(struct nf_conn *ct)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int gre_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int gre_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net,
+				     void *data)
 {
 	unsigned int *timeouts = data;
-
+	struct netns_proto_gre *net_gre = gre_pernet(net);
 	/* set default timeouts for GRE. */
-	timeouts[GRE_CT_UNREPLIED] = gre_timeouts[GRE_CT_UNREPLIED];
-	timeouts[GRE_CT_REPLIED] = gre_timeouts[GRE_CT_REPLIED];
+	timeouts[GRE_CT_UNREPLIED] = net_gre->gre_timeouts[GRE_CT_UNREPLIED];
+	timeouts[GRE_CT_REPLIED] = net_gre->gre_timeouts[GRE_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_GRE_UNREPLIED]) {
 		timeouts[GRE_CT_UNREPLIED] =
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 291cef4..06926d0 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -562,14 +562,17 @@ static int sctp_nlattr_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int sctp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				      struct net *net,
+				      void *data)
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
index c72b8de..9da405a 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1259,14 +1259,16 @@ static int tcp_nlattr_tuple_size(void)
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int tcp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net,
+				     void *data)
 {
 	unsigned int *timeouts = data;
 	int i;
-
+	struct nf_tcp_net *tn = tcp_pernet(net);
 	/* set default TCP timeouts. */
 	for (i=0; i<TCP_CONNTRACK_TIMEOUT_MAX; i++)
-		timeouts[i] = tcp_timeouts[i];
+		timeouts[i] = tn->timeouts[i];
 
 	if (tb[CTA_TIMEOUT_TCP_SYN_SENT]) {
 		timeouts[TCP_CONNTRACK_SYN_SENT] =
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index c38ab58..c58e050 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -156,13 +156,15 @@ static int udp_error(struct net *net, struct nf_conn *tmpl, struct sk_buff *skb,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int udp_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int udp_timeout_nlattr_to_obj(struct nlattr *tb[],
+				     struct net *net,
+				     void *data)
 {
 	unsigned int *timeouts = data;
-
+	struct nf_udp_net *un = udp_pernet(net);
 	/* set default timeouts for UDP. */
-	timeouts[UDP_CT_UNREPLIED] = udp_timeouts[UDP_CT_UNREPLIED];
-	timeouts[UDP_CT_REPLIED] = udp_timeouts[UDP_CT_REPLIED];
+	timeouts[UDP_CT_UNREPLIED] = un->timeouts[UDP_CT_UNREPLIED];
+	timeouts[UDP_CT_REPLIED] = un->timeouts[UDP_CT_REPLIED];
 
 	if (tb[CTA_TIMEOUT_UDP_UNREPLIED]) {
 		timeouts[UDP_CT_UNREPLIED] =
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index cb3dc81..abae474 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -172,13 +172,15 @@ static int udplite_error(struct net *net, struct nf_conn *tmpl,
 #include <linux/netfilter/nfnetlink.h>
 #include <linux/netfilter/nfnetlink_cttimeout.h>
 
-static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[], void *data)
+static int udplite_timeout_nlattr_to_obj(struct nlattr *tb[],
+					 struct net *net,
+					 void *data)
 {
 	unsigned int *timeouts = data;
-
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

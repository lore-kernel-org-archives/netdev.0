From: pablo@netfilter.org
Subject: [PATCH 03/18] netfilter: nf_conntrack: prepare l4proto->init_net cleanup
Date: Fri,  6 Jul 2012 13:16:53 +0200
Message-ID: <1341573428-3204-4-git-send-email-pablo@netfilter.org>
References: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:43387 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933457Ab2GFLS4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 07:18:56 -0400
In-Reply-To: <1341573428-3204-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao feng <gaofeng@cn.fujitsu.com>

l4proto->init contain quite redundant code. We can simplify this
by adding a new parameter l3proto.

This patch prepares that code simplification.

Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l4proto.h   |    2 +-
 net/ipv4/netfilter/nf_conntrack_proto_icmp.c   |    2 +-
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |    2 +-
 net/netfilter/nf_conntrack_proto.c             |    5 +++--
 net/netfilter/nf_conntrack_proto_dccp.c        |    2 +-
 net/netfilter/nf_conntrack_proto_generic.c     |    2 +-
 net/netfilter/nf_conntrack_proto_gre.c         |    2 +-
 net/netfilter/nf_conntrack_proto_sctp.c        |    4 ++--
 net/netfilter/nf_conntrack_proto_tcp.c         |    4 ++--
 net/netfilter/nf_conntrack_proto_udp.c         |    4 ++--
 net/netfilter/nf_conntrack_proto_udplite.c     |    2 +-
 11 files changed, 16 insertions(+), 15 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index 81c52b5..5dd60f2 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -97,7 +97,7 @@ struct nf_conntrack_l4proto {
 #endif
 	int	*net_id;
 	/* Init l4proto pernet data */
-	int (*init_net)(struct net *net);
+	int (*init_net)(struct net *net, u_int16_t proto);
 
 	/* Protocol name */
 	const char *name;
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 041923c..76f7a2f 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -337,7 +337,7 @@ static struct ctl_table icmp_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int icmp_init_net(struct net *net)
+static int icmp_init_net(struct net *net, u_int16_t proto)
 {
 	struct nf_icmp_net *in = icmp_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)in;
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index 63ed012..807ae09 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -333,7 +333,7 @@ static struct ctl_table icmpv6_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static int icmpv6_init_net(struct net *net)
+static int icmpv6_init_net(struct net *net, u_int16_t proto)
 {
 	struct nf_icmp_net *in = icmpv6_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)in;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 9bd88aa..6f4b6f3 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -461,7 +461,7 @@ int nf_conntrack_l4proto_register(struct net *net,
 	int ret = 0;
 
 	if (l4proto->init_net) {
-		ret = l4proto->init_net(net);
+		ret = l4proto->init_net(net, l4proto->l3proto);
 		if (ret < 0)
 			return ret;
 	}
@@ -515,7 +515,8 @@ int nf_conntrack_proto_init(struct net *net)
 {
 	unsigned int i;
 	int err;
-	err = nf_conntrack_l4proto_generic.init_net(net);
+	err = nf_conntrack_l4proto_generic.init_net(net,
+					nf_conntrack_l4proto_generic.l3proto);
 	if (err < 0)
 		return err;
 	err = nf_ct_l4proto_register_sysctl(net,
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index c33f76a..52da8f0 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -815,7 +815,7 @@ static struct ctl_table dccp_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static int dccp_init_net(struct net *net)
+static int dccp_init_net(struct net *net, u_int16_t proto)
 {
 	struct dccp_net *dn = dccp_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)dn;
diff --git a/net/netfilter/nf_conntrack_proto_generic.c b/net/netfilter/nf_conntrack_proto_generic.c
index bb0e74f..d1ed7b4 100644
--- a/net/netfilter/nf_conntrack_proto_generic.c
+++ b/net/netfilter/nf_conntrack_proto_generic.c
@@ -135,7 +135,7 @@ static struct ctl_table generic_compat_sysctl_table[] = {
 #endif /* CONFIG_NF_CONNTRACK_PROC_COMPAT */
 #endif /* CONFIG_SYSCTL */
 
-static int generic_init_net(struct net *net)
+static int generic_init_net(struct net *net, u_int16_t proto)
 {
 	struct nf_generic_net *gn = generic_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)gn;
diff --git a/net/netfilter/nf_conntrack_proto_gre.c b/net/netfilter/nf_conntrack_proto_gre.c
index 5cac41c..b09b7af 100644
--- a/net/netfilter/nf_conntrack_proto_gre.c
+++ b/net/netfilter/nf_conntrack_proto_gre.c
@@ -348,7 +348,7 @@ gre_timeout_nla_policy[CTA_TIMEOUT_GRE_MAX+1] = {
 };
 #endif /* CONFIG_NF_CT_NETLINK_TIMEOUT */
 
-static int gre_init_net(struct net *net)
+static int gre_init_net(struct net *net, u_int16_t proto)
 {
 	struct netns_proto_gre *net_gre = gre_pernet(net);
 	int i;
diff --git a/net/netfilter/nf_conntrack_proto_sctp.c b/net/netfilter/nf_conntrack_proto_sctp.c
index 8fb0582..1e7836c 100644
--- a/net/netfilter/nf_conntrack_proto_sctp.c
+++ b/net/netfilter/nf_conntrack_proto_sctp.c
@@ -767,7 +767,7 @@ static int sctp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int sctpv4_init_net(struct net *net)
+static int sctpv4_init_net(struct net *net, u_int16_t proto)
 {
 	int ret;
 	struct sctp_net *sn = sctp_pernet(net);
@@ -793,7 +793,7 @@ static int sctpv4_init_net(struct net *net)
 	return ret;
 }
 
-static int sctpv6_init_net(struct net *net)
+static int sctpv6_init_net(struct net *net, u_int16_t proto)
 {
 	struct sctp_net *sn = sctp_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)sn;
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 99caa13..6db9d3c 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -1593,7 +1593,7 @@ static int tcp_kmemdup_compat_sysctl_table(struct nf_proto_net *pn)
 	return 0;
 }
 
-static int tcpv4_init_net(struct net *net)
+static int tcpv4_init_net(struct net *net, u_int16_t proto)
 {
 	int i;
 	int ret = 0;
@@ -1631,7 +1631,7 @@ static int tcpv4_init_net(struct net *net)
 	return ret;
 }
 
-static int tcpv6_init_net(struct net *net)
+static int tcpv6_init_net(struct net *net, u_int16_t proto)
 {
 	int i;
 	struct nf_tcp_net *tn = tcp_pernet(net);
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index a83cf93..2b978e6 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -283,7 +283,7 @@ static void udp_init_net_data(struct nf_udp_net *un)
 	}
 }
 
-static int udpv4_init_net(struct net *net)
+static int udpv4_init_net(struct net *net, u_int16_t proto)
 {
 	int ret;
 	struct nf_udp_net *un = udp_pernet(net);
@@ -307,7 +307,7 @@ static int udpv4_init_net(struct net *net)
 	return ret;
 }
 
-static int udpv6_init_net(struct net *net)
+static int udpv6_init_net(struct net *net, u_int16_t proto)
 {
 	struct nf_udp_net *un = udp_pernet(net);
 	struct nf_proto_net *pn = (struct nf_proto_net *)un;
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index b32e700..d33e511 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -234,7 +234,7 @@ static struct ctl_table udplite_sysctl_table[] = {
 };
 #endif /* CONFIG_SYSCTL */
 
-static int udplite_init_net(struct net *net)
+static int udplite_init_net(struct net *net, u_int16_t proto)
 {
 	int i;
 	struct udplite_net *un = udplite_pernet(net);
-- 
1.7.10

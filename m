From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 6/7] lib/utils: introduce rt_addr_n2a_rta()
Date: Tue, 22 Mar 2016 19:35:18 +0100
Message-ID: <1458671719-14361-7-git-send-email-phil@nwl.cc>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:36341 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbcCVSfi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:35:38 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simple macro eases calling rt_addr_n2a() with data from an rt_attr
pointer.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h       |  2 ++
 ip/iplink_bond.c      |  4 +---
 ip/ipmroute.c         |  8 ++------
 ip/ipprefix.c         | 14 +++-----------
 ip/iproute.c          | 20 +++++++-------------
 ip/iproute_lwtunnel.c | 19 ++++---------------
 ip/iprule.c           | 16 ++++++----------
 ip/link_ip6tnl.c      |  8 ++------
 tc/f_flower.c         |  8 ++------
 9 files changed, 29 insertions(+), 70 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index ebb80c9c20b6d..ef81d00f3d70d 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -130,6 +130,8 @@ const char *format_host(int af, int lne, const void *addr);
 const char *rt_addr_n2a_r(int af, int len, const void *addr,
 			       char *buf, int buflen);
 const char *rt_addr_n2a(int af, int len, const void *addr);
+#define rt_addr_n2a_rta(af, rta) \
+	rt_addr_n2a(af, RTA_PAYLOAD(rta), RTA_DATA(rta))
 
 int read_family(const char *name);
 const char *family_name(int family);
diff --git a/ip/iplink_bond.c b/ip/iplink_bond.c
index 7da58e4556c07..fe83479a091a8 100644
--- a/ip/iplink_bond.c
+++ b/ip/iplink_bond.c
@@ -422,9 +422,7 @@ static void bond_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		for (i = 0; i < BOND_MAX_ARP_TARGETS; i++) {
 			if (iptb[i])
 				fprintf(f, "%s",
-					rt_addr_n2a(AF_INET,
-						    RTA_PAYLOAD(iptb[i]),
-						    RTA_DATA(iptb[i])));
+					rt_addr_n2a_rta(AF_INET, iptb[i]));
 			if (i < BOND_MAX_ARP_TARGETS-1 && iptb[i+1])
 				fprintf(f, ",");
 		}
diff --git a/ip/ipmroute.c b/ip/ipmroute.c
index 2b9f892a62630..c33cdcbbde21b 100644
--- a/ip/ipmroute.c
+++ b/ip/ipmroute.c
@@ -123,16 +123,12 @@ int print_mroute(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[RTA_SRC])
 		len = snprintf(obuf, sizeof(obuf),
-			       "(%s, ", rt_addr_n2a(family,
-						    RTA_PAYLOAD(tb[RTA_SRC]),
-						    RTA_DATA(tb[RTA_SRC])));
+			       "(%s, ", rt_addr_n2a_rta(family, tb[RTA_SRC]));
 	else
 		len = sprintf(obuf, "(unknown, ");
 	if (tb[RTA_DST])
 		snprintf(obuf + len, sizeof(obuf) - len,
-			 "%s)", rt_addr_n2a(family,
-					    RTA_PAYLOAD(tb[RTA_DST]),
-					    RTA_DATA(tb[RTA_DST])));
+			 "%s)", rt_addr_n2a_rta(family, tb[RTA_DST]));
 	else
 		snprintf(obuf + len, sizeof(obuf) - len, "unknown) ");
 
diff --git a/ip/ipprefix.c b/ip/ipprefix.c
index 4d986dbc1a5d1..a833efcf67c4a 100644
--- a/ip/ipprefix.c
+++ b/ip/ipprefix.c
@@ -71,19 +71,11 @@ int print_prefix(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	parse_rtattr(tb, RTA_MAX, RTM_RTA(prefix), len);
 
-	fprintf(fp, "prefix ");
-
 	if (tb[PREFIX_ADDRESS]) {
-		struct in6_addr *pfx;
-
-		pfx = (struct in6_addr *)RTA_DATA(tb[PREFIX_ADDRESS]);
-
-		fprintf(fp, "%s", rt_addr_n2a(family,
-					      RTA_PAYLOAD(tb[PREFIX_ADDRESS]),
-					      pfx));
+		fprintf(fp, "prefix %s/%u",
+		        rt_addr_n2a_rta(family, tb[PREFIX_ADDRESS]),
+			prefix->prefix_len);
 	}
-	fprintf(fp, "/%u ", prefix->prefix_len);
-
 	fprintf(fp, "dev %s ", ll_index_to_name(prefix->prefix_ifindex));
 
 	if (prefix->prefix_flags & IF_PREFIX_ONLINK)
diff --git a/ip/iproute.c b/ip/iproute.c
index 67d551b54d00c..8224d7ffa94bf 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -370,11 +370,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[RTA_DST]) {
 		if (r->rtm_dst_len != host_len) {
-			fprintf(fp, "%s/%u ", rt_addr_n2a(r->rtm_family,
-						       RTA_PAYLOAD(tb[RTA_DST]),
-						       RTA_DATA(tb[RTA_DST])),
-				r->rtm_dst_len
-				);
+			fprintf(fp, "%s/%u ",
+			        rt_addr_n2a_rta(r->rtm_family, tb[RTA_DST]),
+			        r->rtm_dst_len);
 		} else {
 			fprintf(fp, "%s ",
 			        format_host_rta(r->rtm_family, tb[RTA_DST]));
@@ -386,11 +384,9 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	}
 	if (tb[RTA_SRC]) {
 		if (r->rtm_src_len != host_len) {
-			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
-						       RTA_PAYLOAD(tb[RTA_SRC]),
-						       RTA_DATA(tb[RTA_SRC])),
-				r->rtm_src_len
-				);
+			fprintf(fp, "from %s/%u ",
+			        rt_addr_n2a_rta(r->rtm_family, tb[RTA_SRC]),
+			        r->rtm_src_len);
 		} else {
 			fprintf(fp, "from %s ",
 			        format_host_rta(r->rtm_family, tb[RTA_SRC]));
@@ -439,9 +435,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		   and symbolic name will not be useful.
 		 */
 		fprintf(fp, " src %s ",
-			rt_addr_n2a(r->rtm_family,
-				    RTA_PAYLOAD(tb[RTA_PREFSRC]),
-				    RTA_DATA(tb[RTA_PREFSRC])));
+			rt_addr_n2a_rta(r->rtm_family, tb[RTA_PREFSRC]));
 	}
 	if (tb[RTA_PRIORITY])
 		fprintf(fp, " metric %u ", rta_getattr_u32(tb[RTA_PRIORITY]));
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 56af9e4e92ecd..3baac77208168 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -77,15 +77,11 @@ static void print_encap_ip(FILE *fp, struct rtattr *encap)
 
 	if (tb[LWTUNNEL_IP_SRC])
 		fprintf(fp, "src %s ",
-			rt_addr_n2a(AF_INET,
-				    RTA_PAYLOAD(tb[LWTUNNEL_IP_SRC]),
-				    RTA_DATA(tb[LWTUNNEL_IP_SRC])));
+			rt_addr_n2a_rta(AF_INET, tb[LWTUNNEL_IP_SRC]));
 
 	if (tb[LWTUNNEL_IP_DST])
 		fprintf(fp, "dst %s ",
-			rt_addr_n2a(AF_INET,
-				    RTA_PAYLOAD(tb[LWTUNNEL_IP_DST]),
-				    RTA_DATA(tb[LWTUNNEL_IP_DST])));
+			rt_addr_n2a_rta(AF_INET, tb[LWTUNNEL_IP_DST]));
 
 	if (tb[LWTUNNEL_IP_TTL])
 		fprintf(fp, "ttl %d ", rta_getattr_u8(tb[LWTUNNEL_IP_TTL]));
@@ -112,7 +108,6 @@ static void print_encap_ila(FILE *fp, struct rtattr *encap)
 static void print_encap_ip6(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[LWTUNNEL_IP6_MAX+1];
-	char abuf[256];
 
 	parse_rtattr_nested(tb, LWTUNNEL_IP6_MAX, encap);
 
@@ -121,17 +116,11 @@ static void print_encap_ip6(FILE *fp, struct rtattr *encap)
 
 	if (tb[LWTUNNEL_IP6_SRC])
 		fprintf(fp, "src %s ",
-			rt_addr_n2a(AF_INET6,
-				    RTA_PAYLOAD(tb[LWTUNNEL_IP6_SRC]),
-				    RTA_DATA(tb[LWTUNNEL_IP6_SRC]),
-				    abuf, sizeof(abuf)));
+			rt_addr_n2a_rta(AF_INET6, tb[LWTUNNEL_IP6_SRC]));
 
 	if (tb[LWTUNNEL_IP6_DST])
 		fprintf(fp, "dst %s ",
-			rt_addr_n2a(AF_INET6,
-				    RTA_PAYLOAD(tb[LWTUNNEL_IP6_DST]),
-				    RTA_DATA(tb[LWTUNNEL_IP6_DST]),
-				    abuf, sizeof(abuf)));
+			rt_addr_n2a_rta(AF_INET6, tb[LWTUNNEL_IP6_DST]));
 
 	if (tb[LWTUNNEL_IP6_HOPLIMIT])
 		fprintf(fp, "hoplimit %d ", rta_getattr_u8(tb[LWTUNNEL_IP6_HOPLIMIT]));
diff --git a/ip/iprule.c b/ip/iprule.c
index ac570440d6633..7cb19e4d5ebd0 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -83,11 +83,9 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[FRA_SRC]) {
 		if (r->rtm_src_len != host_len) {
-			fprintf(fp, "from %s/%u ", rt_addr_n2a(r->rtm_family,
-						       RTA_PAYLOAD(tb[FRA_SRC]),
-						       RTA_DATA(tb[FRA_SRC])),
-				r->rtm_src_len
-				);
+			fprintf(fp, "from %s/%u ",
+			        rt_addr_n2a_rta(r->rtm_family, tb[FRA_SRC]),
+			        r->rtm_src_len);
 		} else {
 			fprintf(fp, "from %s ",
 			        format_host_rta(r->rtm_family, tb[FRA_SRC]));
@@ -100,11 +98,9 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[FRA_DST]) {
 		if (r->rtm_dst_len != host_len) {
-			fprintf(fp, "to %s/%u ", rt_addr_n2a(r->rtm_family,
-						       RTA_PAYLOAD(tb[FRA_DST]),
-						       RTA_DATA(tb[FRA_DST])),
-				r->rtm_dst_len
-				);
+			fprintf(fp, "to %s/%u ",
+			        rt_addr_n2a_rta(r->rtm_family, tb[FRA_DST]),
+			        r->rtm_dst_len);
 		} else {
 			fprintf(fp, "to %s ",
 			        format_host_rta(r->rtm_family, tb[FRA_DST]));
diff --git a/ip/link_ip6tnl.c b/ip/link_ip6tnl.c
index 4b32fe5aa8088..8a31d0dcd1883 100644
--- a/ip/link_ip6tnl.c
+++ b/ip/link_ip6tnl.c
@@ -289,16 +289,12 @@ static void ip6tunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb
 
 	if (tb[IFLA_IPTUN_REMOTE]) {
 		fprintf(f, "remote %s ",
-			rt_addr_n2a(AF_INET6,
-				    RTA_PAYLOAD(tb[IFLA_IPTUN_REMOTE]),
-				    RTA_DATA(tb[IFLA_IPTUN_REMOTE])));
+			rt_addr_n2a_rta(AF_INET6, tb[IFLA_IPTUN_REMOTE]));
 	}
 
 	if (tb[IFLA_IPTUN_LOCAL]) {
 		fprintf(f, "local %s ",
-			rt_addr_n2a(AF_INET6,
-				    RTA_PAYLOAD(tb[IFLA_IPTUN_LOCAL]),
-				    RTA_DATA(tb[IFLA_IPTUN_LOCAL])));
+			rt_addr_n2a_rta(AF_INET6, tb[IFLA_IPTUN_LOCAL]));
 	}
 
 	if (tb[IFLA_IPTUN_LINK] && rta_getattr_u32(tb[IFLA_IPTUN_LINK])) {
diff --git a/tc/f_flower.c b/tc/f_flower.c
index 40f8c595b2eec..306f056c1b662 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -415,16 +415,12 @@ static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 	}
 	if (!addr_attr || RTA_PAYLOAD(addr_attr) != len)
 		return;
-	fprintf(f, "\n  %s %s", name, rt_addr_n2a(family,
-						  RTA_PAYLOAD(addr_attr),
-						  RTA_DATA(addr_attr)));
+	fprintf(f, "\n  %s %s", name, rt_addr_n2a_rta(family, addr_attr));
 	if (!mask_attr || RTA_PAYLOAD(mask_attr) != len)
 		return;
 	bits = __mask_bits(RTA_DATA(mask_attr), len);
 	if (bits < 0)
-		fprintf(f, "/%s", rt_addr_n2a(family,
-					      RTA_PAYLOAD(mask_attr),
-					      RTA_DATA(mask_attr)));
+		fprintf(f, "/%s", rt_addr_n2a_rta(family, mask_attr));
 	else if (bits < len * 8)
 		fprintf(f, "/%d", bits);
 }
-- 
2.7.2

From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 3/7] make format_host non-reentrant by default
Date: Tue, 22 Mar 2016 19:35:15 +0100
Message-ID: <1458671719-14361-4-git-send-email-phil@nwl.cc>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:51769 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751067AbcCVSfu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:35:50 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are only three users which require it to be reentrant, the rest is
fine without. Instead, provide a reentrant format_host_r() for users
which need it.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 bridge/fdb.c          |  4 +---
 include/utils.h       |  3 ++-
 ip/ip6tunnel.c        |  2 +-
 ip/ipaddress.c        | 13 ++++---------
 ip/ipaddrlabel.c      |  4 +---
 ip/iplink_geneve.c    |  5 ++---
 ip/iplink_vxlan.c     | 13 ++++++-------
 ip/ipmaddr.c          |  6 +-----
 ip/ipneigh.c          |  4 +---
 ip/iproute.c          | 21 +++++++--------------
 ip/iproute_lwtunnel.c |  4 +---
 ip/iprule.c           |  9 +++------
 ip/iptoken.c          |  4 +---
 ip/iptunnel.c         |  6 +++---
 ip/link_gre.c         |  5 ++---
 ip/link_gre6.c        |  5 ++---
 ip/link_iptnl.c       |  7 +++----
 ip/link_vti.c         |  5 ++---
 ip/link_vti6.c        |  5 ++---
 ip/tcp_metrics.c      |  6 ++----
 lib/utils.c           |  9 ++++++++-
 misc/ss.c             |  4 ++--
 tc/m_nat.c            |  4 ++--
 23 files changed, 59 insertions(+), 89 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 88f1b63c233e9..e8c314a3c0771 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -104,7 +104,6 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "dev %s ", ll_index_to_name(r->ndm_ifindex));
 
 	if (tb[NDA_DST]) {
-		SPRINT_BUF(abuf);
 		int family = AF_INET;
 
 		if (RTA_PAYLOAD(tb[NDA_DST]) == sizeof(struct in6_addr))
@@ -113,8 +112,7 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "dst %s ",
 			format_host(family,
 				    RTA_PAYLOAD(tb[NDA_DST]),
-				    RTA_DATA(tb[NDA_DST]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(tb[NDA_DST])));
 	}
 
 	if (tb[NDA_VLAN]) {
diff --git a/include/utils.h b/include/utils.h
index c43427c35a6cc..84083b0dbba71 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -122,8 +122,9 @@ int addr64_n2a(__u64 addr, char *buff, size_t len);
 int af_bit_len(int af);
 int af_byte_len(int af);
 
-const char *format_host(int af, int len, const void *addr,
+const char *format_host_r(int af, int len, const void *addr,
 			       char *buf, int buflen);
+const char *format_host(int af, int lne, const void *addr);
 const char *rt_addr_n2a(int af, int len, const void *addr,
 			       char *buf, int buflen);
 
diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index 2e9d3ed40d003..d588645eb942a 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -77,7 +77,7 @@ static void print_tunnel(struct ip6_tnl_parm2 *p)
 	printf("%s: %s/ipv6 remote %s local %s",
 	       p->name,
 	       tnl_strproto(p->proto),
-	       format_host(AF_INET6, 16, &p->raddr, s1, sizeof(s1)),
+	       format_host_r(AF_INET6, 16, &p->raddr, s1, sizeof(s1)),
 	       rt_addr_n2a(AF_INET6, 16, &p->laddr, s2, sizeof(s2)));
 	if (p->link) {
 		const char *n = ll_index_to_name(p->link);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 90d7b1096c3aa..03c8c03cd4a17 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -964,7 +964,6 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	/* Use local copy of ifa_flags to not interfere with filtering code */
 	unsigned int ifa_flags;
 	struct rtattr *rta_tb[IFA_MAX+1];
-	char abuf[256];
 
 	SPRINT_BUF(b1);
 
@@ -1061,8 +1060,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s",
 		              format_host(ifa->ifa_family,
 		                          RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
-		                          RTA_DATA(rta_tb[IFA_LOCAL]),
-		                          abuf, sizeof(abuf)));
+		                          RTA_DATA(rta_tb[IFA_LOCAL])));
 		if (rta_tb[IFA_ADDRESS] &&
 		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]),
 		           RTA_DATA(rta_tb[IFA_LOCAL]),
@@ -1071,8 +1069,7 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 			color_fprintf(fp, ifa_family_color(ifa->ifa_family),
 			              "%s", format_host(ifa->ifa_family,
 			              RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
-			              RTA_DATA(rta_tb[IFA_ADDRESS]),
-			              abuf, sizeof(abuf)));
+			              RTA_DATA(rta_tb[IFA_ADDRESS])));
 		}
 		fprintf(fp, "/%d ", ifa->ifa_prefixlen);
 	}
@@ -1085,16 +1082,14 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
 			format_host(ifa->ifa_family,
 				    RTA_PAYLOAD(rta_tb[IFA_BROADCAST]),
-				    RTA_DATA(rta_tb[IFA_BROADCAST]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(rta_tb[IFA_BROADCAST])));
 	}
 	if (rta_tb[IFA_ANYCAST]) {
 		fprintf(fp, "any ");
 		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
 			format_host(ifa->ifa_family,
 				    RTA_PAYLOAD(rta_tb[IFA_ANYCAST]),
-				    RTA_DATA(rta_tb[IFA_ANYCAST]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(rta_tb[IFA_ANYCAST])));
 	}
 	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
 	if (ifa_flags & IFA_F_SECONDARY) {
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index 05c44978ff37a..6076bb952297f 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -60,7 +60,6 @@ int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg
 	struct ifaddrlblmsg *ifal = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[IFAL_MAX+1];
-	char abuf[256];
 
 	if (n->nlmsg_type != RTM_NEWADDRLABEL && n->nlmsg_type != RTM_DELADDRLABEL)
 		return 0;
@@ -78,8 +77,7 @@ int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg
 		fprintf(fp, "prefix %s/%u ",
 			format_host(ifal->ifal_family,
 				    RTA_PAYLOAD(tb[IFAL_ADDRESS]),
-				    RTA_DATA(tb[IFAL_ADDRESS]),
-				    abuf, sizeof(abuf)),
+				    RTA_DATA(tb[IFAL_ADDRESS])),
 			ifal->ifal_prefixlen);
 	}
 
diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 40c08ec270d15..c6e7bbe0ce20e 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -138,7 +138,6 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	__u32 vni;
-	char s1[1024];
 	__u8 tos;
 
 	if (!tb)
@@ -156,7 +155,7 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 		if (addr)
 			fprintf(f, "remote %s ",
-				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+				format_host(AF_INET, 4, &addr));
 	} else if (tb[IFLA_GENEVE_REMOTE6]) {
 		struct in6_addr addr;
 
@@ -164,7 +163,7 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0) {
 			if (IN6_IS_ADDR_MULTICAST(&addr))
 				fprintf(f, "remote %s ",
-					format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
 		}
 	}
 
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 5c23cf534ce81..543522e139ff4 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -310,7 +310,6 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	unsigned int link;
 	__u8 tos;
 	__u32 maxaddr;
-	char s1[1024];
 	char s2[64];
 
 	if (!tb)
@@ -329,10 +328,10 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		if (addr) {
 			if (IN_MULTICAST(ntohl(addr)))
 				fprintf(f, "group %s ",
-					format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+					format_host(AF_INET, 4, &addr));
 			else
 				fprintf(f, "remote %s ",
-					format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+					format_host(AF_INET, 4, &addr));
 		}
 	} else if (tb[IFLA_VXLAN_GROUP6]) {
 		struct in6_addr addr;
@@ -341,10 +340,10 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0) {
 			if (IN6_IS_ADDR_MULTICAST(&addr))
 				fprintf(f, "group %s ",
-					format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
 			else
 				fprintf(f, "remote %s ",
-					format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
 		}
 	}
 
@@ -353,14 +352,14 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 		if (addr)
 			fprintf(f, "local %s ",
-				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+				format_host(AF_INET, 4, &addr));
 	} else if (tb[IFLA_VXLAN_LOCAL6]) {
 		struct in6_addr addr;
 
 		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_LOCAL6]), sizeof(struct in6_addr));
 		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0)
 			fprintf(f, "local %s ",
-				format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+				format_host(AF_INET6, sizeof(struct in6_addr), &addr));
 	}
 
 	if (tb[IFLA_VXLAN_LINK] &&
diff --git a/ip/ipmaddr.c b/ip/ipmaddr.c
index 347990b5c8f52..c3673979f9761 100644
--- a/ip/ipmaddr.c
+++ b/ip/ipmaddr.c
@@ -204,8 +204,6 @@ static void print_maddr(FILE *fp, struct ma_info *list)
 						    list->addr.bytelen, 0,
 						    b1, sizeof(b1)));
 	} else {
-		char abuf[256];
-
 		switch (list->addr.family) {
 		case AF_INET:
 			fprintf(fp, "inet  ");
@@ -219,9 +217,7 @@ static void print_maddr(FILE *fp, struct ma_info *list)
 		}
 		fprintf(fp, "%s",
 			format_host(list->addr.family,
-				    -1,
-				    list->addr.data,
-				    abuf, sizeof(abuf)));
+				    -1, list->addr.data));
 	}
 	if (list->users != 1)
 		fprintf(fp, " users %d", list->users);
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 6458c8eaa6b1e..583aad30dc820 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -198,7 +198,6 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	struct ndmsg *r = NLMSG_DATA(n);
 	int len = n->nlmsg_len;
 	struct rtattr *tb[NDA_MAX+1];
-	char abuf[256];
 	static int logit = 1;
 
 	if (n->nlmsg_type != RTM_NEWNEIGH && n->nlmsg_type != RTM_DELNEIGH &&
@@ -281,8 +280,7 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "%s ",
 			format_host(r->ndm_family,
 				    RTA_PAYLOAD(tb[NDA_DST]),
-				    RTA_DATA(tb[NDA_DST]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(tb[NDA_DST])));
 	}
 	if (!filter.index && r->ndm_ifindex)
 		fprintf(fp, "dev %s ", ll_index_to_name(r->ndm_ifindex));
diff --git a/ip/iproute.c b/ip/iproute.c
index 19b28701d4da1..8315ad3e6c6ac 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -380,8 +380,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		} else {
 			fprintf(fp, "%s ", format_host(r->rtm_family,
 						       RTA_PAYLOAD(tb[RTA_DST]),
-						       RTA_DATA(tb[RTA_DST]),
-						       abuf, sizeof(abuf))
+						       RTA_DATA(tb[RTA_DST]))
 				);
 		}
 	} else if (r->rtm_dst_len) {
@@ -400,8 +399,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		} else {
 			fprintf(fp, "from %s ", format_host(r->rtm_family,
 						       RTA_PAYLOAD(tb[RTA_SRC]),
-						       RTA_DATA(tb[RTA_SRC]),
-						       abuf, sizeof(abuf))
+						       RTA_DATA(tb[RTA_SRC]))
 				);
 		}
 	} else if (r->rtm_src_len) {
@@ -410,8 +408,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[RTA_NEWDST]) {
 		fprintf(fp, "as to %s ", format_host(r->rtm_family,
 						  RTA_PAYLOAD(tb[RTA_NEWDST]),
-						  RTA_DATA(tb[RTA_NEWDST]),
-						  abuf, sizeof(abuf))
+						  RTA_DATA(tb[RTA_NEWDST]))
 			);
 	}
 
@@ -427,8 +424,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "via %s ",
 			format_host(r->rtm_family,
 				    RTA_PAYLOAD(tb[RTA_GATEWAY]),
-				    RTA_DATA(tb[RTA_GATEWAY]),
-				    abuf, sizeof(abuf)));
+				    RTA_DATA(tb[RTA_GATEWAY])));
 	}
 	if (tb[RTA_VIA]) {
 		size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
@@ -436,8 +432,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 		fprintf(fp, "via %s %s ",
 			family_name(via->rtvia_family),
-			format_host(via->rtvia_family, len, via->rtvia_addr,
-				    abuf, sizeof(abuf)));
+			format_host(via->rtvia_family, len, via->rtvia_addr));
 	}
 	if (tb[RTA_OIF] && filter.oifmask != -1)
 		fprintf(fp, "dev %s ", ll_index_to_name(*(int *)RTA_DATA(tb[RTA_OIF])));
@@ -671,8 +666,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 					fprintf(fp, " via %s ",
 						format_host(r->rtm_family,
 							    RTA_PAYLOAD(tb[RTA_GATEWAY]),
-							    RTA_DATA(tb[RTA_GATEWAY]),
-							    abuf, sizeof(abuf)));
+							    RTA_DATA(tb[RTA_GATEWAY])));
 				}
 				if (tb[RTA_VIA]) {
 					size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
@@ -680,8 +674,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 					fprintf(fp, "via %s %s ",
 						family_name(via->rtvia_family),
-						format_host(via->rtvia_family, len, via->rtvia_addr,
-							    abuf, sizeof(abuf)));
+						format_host(via->rtvia_family, len, via->rtvia_addr));
 				}
 				if (tb[RTA_FLOW]) {
 					__u32 to = rta_getattr_u32(tb[RTA_FLOW]);
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index a53e11d9478e9..42abe3753ac6a 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -58,15 +58,13 @@ static const char *format_encap_type(int type)
 static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 {
 	struct rtattr *tb[MPLS_IPTUNNEL_MAX+1];
-	char abuf[256];
 
 	parse_rtattr_nested(tb, MPLS_IPTUNNEL_MAX, encap);
 
 	if (tb[MPLS_IPTUNNEL_DST])
 		fprintf(fp, " %s ", format_host(AF_MPLS,
 			RTA_PAYLOAD(tb[MPLS_IPTUNNEL_DST]),
-			RTA_DATA(tb[MPLS_IPTUNNEL_DST]),
-			abuf, sizeof(abuf)));
+			RTA_DATA(tb[MPLS_IPTUNNEL_DST])));
 }
 
 static void print_encap_ip(FILE *fp, struct rtattr *encap)
diff --git a/ip/iprule.c b/ip/iprule.c
index dc45c6b43e606..345b3b042307d 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -94,8 +94,7 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		} else {
 			fprintf(fp, "from %s ", format_host(r->rtm_family,
 						       RTA_PAYLOAD(tb[FRA_SRC]),
-						       RTA_DATA(tb[FRA_SRC]),
-						       abuf, sizeof(abuf))
+						       RTA_DATA(tb[FRA_SRC]))
 				);
 		}
 	} else if (r->rtm_src_len) {
@@ -115,8 +114,7 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		} else {
 			fprintf(fp, "to %s ", format_host(r->rtm_family,
 						       RTA_PAYLOAD(tb[FRA_DST]),
-						       RTA_DATA(tb[FRA_DST]),
-						       abuf, sizeof(abuf)));
+						       RTA_DATA(tb[FRA_DST])));
 		}
 	} else if (r->rtm_dst_len) {
 		fprintf(fp, "to 0/%d ", r->rtm_dst_len);
@@ -191,8 +189,7 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 			fprintf(fp, "map-to %s ",
 				format_host(r->rtm_family,
 					    RTA_PAYLOAD(tb[RTA_GATEWAY]),
-					    RTA_DATA(tb[RTA_GATEWAY]),
-					    abuf, sizeof(abuf)));
+					    RTA_DATA(tb[RTA_GATEWAY])));
 		} else
 			fprintf(fp, "masquerade");
 	} else if (r->rtm_type == FR_ACT_GOTO) {
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 1d22c03c63ab7..02fe98e249526 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -51,7 +51,6 @@ static int print_token(const struct sockaddr_nl *who, struct nlmsghdr *n, void *
 	int len = n->nlmsg_len;
 	struct rtattr *tb[IFLA_MAX + 1];
 	struct rtattr *ltb[IFLA_INET6_MAX + 1];
-	char abuf[256];
 
 	if (n->nlmsg_type != RTM_NEWLINK)
 		return -1;
@@ -82,8 +81,7 @@ static int print_token(const struct sockaddr_nl *who, struct nlmsghdr *n, void *
 	fprintf(fp, "token %s ",
 		format_host(ifi->ifi_family,
 			    RTA_PAYLOAD(ltb[IFLA_INET6_TOKEN]),
-			    RTA_DATA(ltb[IFLA_INET6_TOKEN]),
-			    abuf, sizeof(abuf)));
+			    RTA_DATA(ltb[IFLA_INET6_TOKEN])));
 	fprintf(fp, "dev %s ", ll_index_to_name(ifi->ifi_index));
 	fprintf(fp, "\n");
 	fflush(fp);
diff --git a/ip/iptunnel.c b/ip/iptunnel.c
index 65a4e6e9c1a5a..bfee99561615a 100644
--- a/ip/iptunnel.c
+++ b/ip/iptunnel.c
@@ -308,7 +308,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 	printf("%s: %s/ip remote %s local %s",
 	       p->name,
 	       tnl_strproto(p->iph.protocol),
-	       p->iph.daddr ? format_host(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1)) : "any",
+	       p->iph.daddr ? format_host_r(AF_INET, 4, &p->iph.daddr, s1, sizeof(s1)) : "any",
 	       p->iph.saddr ? rt_addr_n2a(AF_INET, 4, &p->iph.saddr, s2, sizeof(s2)) : "any");
 
 	if (p->iph.protocol == IPPROTO_IPV6 && (p->i_flags & SIT_ISATAP)) {
@@ -324,7 +324,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 				if (prl[i].addr != htonl(INADDR_ANY)) {
 					printf(" %s %s ",
 					       (prl[i].flags & PRL_DEFAULT) ? "pdr" : "pr",
-					       format_host(AF_INET, 4, &prl[i].addr, s1, sizeof(s1)));
+					       format_host(AF_INET, 4, &prl[i].addr));
 				}
 			}
 	}
@@ -360,7 +360,7 @@ static void print_tunnel(struct ip_tunnel_parm *p)
 		       ip6rd.prefixlen);
 		if (ip6rd.relay_prefix) {
 			printf(" 6rd-relay_prefix %s/%u",
-			       format_host(AF_INET, 4, &ip6rd.relay_prefix, s1, sizeof(s1)),
+			       format_host(AF_INET, 4, &ip6rd.relay_prefix),
 			       ip6rd.relay_prefixlen);
 		}
 	}
diff --git a/ip/link_gre.c b/ip/link_gre.c
index c50963d79d3c5..bcf003aaa5d7a 100644
--- a/ip/link_gre.c
+++ b/ip/link_gre.c
@@ -339,7 +339,6 @@ get_failed:
 
 static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
-	char s1[1024];
 	char s2[64];
 	const char *local = "any";
 	const char *remote = "any";
@@ -353,7 +352,7 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		unsigned int addr = rta_getattr_u32(tb[IFLA_GRE_REMOTE]);
 
 		if (addr)
-			remote = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+			remote = format_host(AF_INET, 4, &addr);
 	}
 
 	fprintf(f, "remote %s ", remote);
@@ -362,7 +361,7 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		unsigned int addr = rta_getattr_u32(tb[IFLA_GRE_LOCAL]);
 
 		if (addr)
-			local = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+			local = format_host(AF_INET, 4, &addr);
 	}
 
 	fprintf(f, "local %s ", local);
diff --git a/ip/link_gre6.c b/ip/link_gre6.c
index a48ea8b1ebae3..bddfc0ff97aa0 100644
--- a/ip/link_gre6.c
+++ b/ip/link_gre6.c
@@ -302,7 +302,6 @@ get_failed:
 
 static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
-	char s1[1024];
 	char s2[64];
 	const char *local = "any";
 	const char *remote = "any";
@@ -327,7 +326,7 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		memcpy(&addr, RTA_DATA(tb[IFLA_GRE_REMOTE]), sizeof(addr));
 
 		if (memcmp(&addr, &in6_addr_any, sizeof(addr)))
-			remote = format_host(AF_INET6, sizeof(addr), &addr, s1, sizeof(s1));
+			remote = format_host(AF_INET6, sizeof(addr), &addr);
 	}
 
 	fprintf(f, "remote %s ", remote);
@@ -338,7 +337,7 @@ static void gre_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		memcpy(&addr, RTA_DATA(tb[IFLA_GRE_LOCAL]), sizeof(addr));
 
 		if (memcmp(&addr, &in6_addr_any, sizeof(addr)))
-			local = format_host(AF_INET6, sizeof(addr), &addr, s1, sizeof(s1));
+			local = format_host(AF_INET6, sizeof(addr), &addr);
 	}
 
 	fprintf(f, "local %s ", local);
diff --git a/ip/link_iptnl.c b/ip/link_iptnl.c
index 04568ffbd81bf..8411a6a00a1b4 100644
--- a/ip/link_iptnl.c
+++ b/ip/link_iptnl.c
@@ -339,7 +339,7 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 		unsigned int addr = rta_getattr_u32(tb[IFLA_IPTUN_REMOTE]);
 
 		if (addr)
-			remote = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+			remote = format_host(AF_INET, 4, &addr);
 	}
 
 	fprintf(f, "remote %s ", remote);
@@ -348,7 +348,7 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 		unsigned int addr = rta_getattr_u32(tb[IFLA_IPTUN_LOCAL]);
 
 		if (addr)
-			local = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+			local = format_host(AF_INET, 4, &addr);
 	}
 
 	fprintf(f, "local %s ", local);
@@ -404,8 +404,7 @@ static void iptunnel_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[
 		       prefixlen);
 		if (relayprefix) {
 			printf("6rd-relay_prefix %s/%u ",
-			       format_host(AF_INET, 4, &relayprefix, s1,
-					   sizeof(s1)),
+			       format_host(AF_INET, 4, &relayprefix),
 			       relayprefixlen);
 		}
 	}
diff --git a/ip/link_vti.c b/ip/link_vti.c
index 587993035e8d5..8052e7514989a 100644
--- a/ip/link_vti.c
+++ b/ip/link_vti.c
@@ -198,7 +198,6 @@ get_failed:
 
 static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
-	char s1[1024];
 	char s2[64];
 	const char *local = "any";
 	const char *remote = "any";
@@ -210,7 +209,7 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		unsigned int addr = *(__u32 *)RTA_DATA(tb[IFLA_VTI_REMOTE]);
 
 		if (addr)
-			remote = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+			remote = format_host(AF_INET, 4, &addr);
 	}
 
 	fprintf(f, "remote %s ", remote);
@@ -219,7 +218,7 @@ static void vti_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		unsigned int addr = *(__u32 *)RTA_DATA(tb[IFLA_VTI_LOCAL]);
 
 		if (addr)
-			local = format_host(AF_INET, 4, &addr, s1, sizeof(s1));
+			local = format_host(AF_INET, 4, &addr);
 	}
 
 	fprintf(f, "local %s ", local);
diff --git a/ip/link_vti6.c b/ip/link_vti6.c
index 9a62eb5aa370d..9bcf7fe9dea46 100644
--- a/ip/link_vti6.c
+++ b/ip/link_vti6.c
@@ -197,7 +197,6 @@ get_failed:
 
 static void vti6_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
-	char s1[1024];
 	char s2[64];
 	const char *local = "any";
 	const char *remote = "any";
@@ -210,7 +209,7 @@ static void vti6_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VTI_REMOTE]) {
 		memcpy(&daddr, RTA_DATA(tb[IFLA_VTI_REMOTE]), sizeof(daddr));
 
-		remote = format_host(AF_INET6, 16, &daddr, s1, sizeof(s1));
+		remote = format_host(AF_INET6, 16, &daddr);
 	}
 
 	fprintf(f, "remote %s ", remote);
@@ -218,7 +217,7 @@ static void vti6_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VTI_LOCAL]) {
 		memcpy(&saddr, RTA_DATA(tb[IFLA_VTI_LOCAL]), sizeof(saddr));
 
-		local = format_host(AF_INET6, 16, &saddr, s1, sizeof(s1));
+		local = format_host(AF_INET6, 16, &saddr);
 	}
 
 	fprintf(f, "local %s ", local);
diff --git a/ip/tcp_metrics.c b/ip/tcp_metrics.c
index 3a649917191a8..f82604f458ada 100644
--- a/ip/tcp_metrics.c
+++ b/ip/tcp_metrics.c
@@ -95,7 +95,6 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	struct genlmsghdr *ghdr;
 	struct rtattr *attrs[TCP_METRICS_ATTR_MAX + 1], *a;
 	int len = n->nlmsg_len;
-	char abuf[256];
 	inet_prefix daddr, saddr;
 	int family, i, atype, stype, dlen = 0, slen = 0;
 
@@ -194,7 +193,7 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, "Deleted ");
 
 	fprintf(fp, "%s",
-		format_host(family, dlen, &daddr.data, abuf, sizeof(abuf)));
+		format_host(family, dlen, &daddr.data));
 
 	a = attrs[TCP_METRICS_ATTR_AGE];
 	if (a) {
@@ -298,8 +297,7 @@ static int process_msg(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (slen) {
 		fprintf(fp, " source %s",
-			format_host(family, slen, &saddr.data, abuf,
-				    sizeof(abuf)));
+			format_host(family, slen, &saddr.data));
 	}
 
 	fprintf(fp, "\n");
diff --git a/lib/utils.c b/lib/utils.c
index fa35f4d044064..22a5ef8fa8213 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -818,7 +818,7 @@ static const char *resolve_address(const void *addr, int len, int af)
 }
 #endif
 
-const char *format_host(int af, int len, const void *addr,
+const char *format_host_r(int af, int len, const void *addr,
 			char *buf, int buflen)
 {
 #ifdef RESOLVE_HOSTNAMES
@@ -835,6 +835,13 @@ const char *format_host(int af, int len, const void *addr,
 	return rt_addr_n2a(af, len, addr, buf, buflen);
 }
 
+const char *format_host(int af, int len, const void *addr)
+{
+	static char buf[256];
+
+	return format_host_r(af, len, addr, buf, 256);
+}
+
 
 char *hexstring_n2a(const __u8 *str, int len, char *buf, int blen)
 {
diff --git a/misc/ss.c b/misc/ss.c
index 192389cc82371..38cf3312a746e 100644
--- a/misc/ss.c
+++ b/misc/ss.c
@@ -1016,10 +1016,10 @@ static void inet_addr_print(const inet_prefix *a, int port, unsigned int ifindex
 			buf[0] = '*';
 			buf[1] = 0;
 		} else {
-			ap = format_host(AF_INET, 4, a->data, buf, sizeof(buf));
+			ap = format_host(AF_INET, 4, a->data);
 		}
 	} else {
-		ap = format_host(a->family, 16, a->data, buf, sizeof(buf));
+		ap = format_host(a->family, 16, a->data);
 		est_len = strlen(ap);
 		if (est_len <= addr_width)
 			est_len = addr_width;
diff --git a/tc/m_nat.c b/tc/m_nat.c
index deb071da90daf..4b90121c4b99e 100644
--- a/tc/m_nat.c
+++ b/tc/m_nat.c
@@ -191,9 +191,9 @@ print_nat(struct action_util *au, FILE * f, struct rtattr *arg)
 
 	fprintf(f, " nat %s %s/%d %s %s", sel->flags & TCA_NAT_FLAG_EGRESS ?
 					  "egress" : "ingress",
-		format_host(AF_INET, 4, &sel->old_addr, buf1, sizeof(buf1)),
+		format_host_r(AF_INET, 4, &sel->old_addr, buf1, sizeof(buf1)),
 		len,
-		format_host(AF_INET, 4, &sel->new_addr, buf2, sizeof(buf2)),
+		format_host_r(AF_INET, 4, &sel->new_addr, buf2, sizeof(buf2)),
 		action_n2a(sel->action, buf3, sizeof(buf3)));
 
 	if (show_stats) {
-- 
2.7.2

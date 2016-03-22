From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 5/7] lib/utils: introduce format_host_rta()
Date: Tue, 22 Mar 2016 19:35:17 +0100
Message-ID: <1458671719-14361-6-git-send-email-phil@nwl.cc>
References: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:52070 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750735AbcCVSfd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Mar 2016 14:35:33 -0400
In-Reply-To: <1458671719-14361-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This simple macro eases calling format_host() with data from an rt_attr
pointer.

Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 include/utils.h       |  2 ++
 ip/ipaddress.c        | 20 ++++++++------------
 ip/ipaddrlabel.c      |  5 ++---
 ip/ipneigh.c          |  4 +---
 ip/iproute.c          | 33 +++++++++++----------------------
 ip/iproute_lwtunnel.c |  5 ++---
 ip/iprule.c           | 16 ++++++----------
 ip/iptoken.c          |  9 +++------
 8 files changed, 35 insertions(+), 59 deletions(-)

diff --git a/include/utils.h b/include/utils.h
index bc2cbce0cc303..ebb80c9c20b6d 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -125,6 +125,8 @@ int af_byte_len(int af);
 const char *format_host_r(int af, int len, const void *addr,
 			       char *buf, int buflen);
 const char *format_host(int af, int lne, const void *addr);
+#define format_host_rta(af, rta) \
+	format_host(af, RTA_PAYLOAD(rta), RTA_DATA(rta))
 const char *rt_addr_n2a_r(int af, int len, const void *addr,
 			       char *buf, int buflen);
 const char *rt_addr_n2a(int af, int len, const void *addr);
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 03c8c03cd4a17..3998d8cec4ab2 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -1058,18 +1058,16 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 
 	if (rta_tb[IFA_LOCAL]) {
 		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s",
-		              format_host(ifa->ifa_family,
-		                          RTA_PAYLOAD(rta_tb[IFA_LOCAL]),
-		                          RTA_DATA(rta_tb[IFA_LOCAL])));
+		              format_host_rta(ifa->ifa_family,
+		                              rta_tb[IFA_LOCAL]));
 		if (rta_tb[IFA_ADDRESS] &&
 		    memcmp(RTA_DATA(rta_tb[IFA_ADDRESS]),
 		           RTA_DATA(rta_tb[IFA_LOCAL]),
 		           ifa->ifa_family == AF_INET ? 4 : 16)) {
 			fprintf(fp, " peer ");
 			color_fprintf(fp, ifa_family_color(ifa->ifa_family),
-			              "%s", format_host(ifa->ifa_family,
-			              RTA_PAYLOAD(rta_tb[IFA_ADDRESS]),
-			              RTA_DATA(rta_tb[IFA_ADDRESS])));
+			              "%s", format_host_rta(ifa->ifa_family,
+			              rta_tb[IFA_ADDRESS]));
 		}
 		fprintf(fp, "/%d ", ifa->ifa_prefixlen);
 	}
@@ -1080,16 +1078,14 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 	if (rta_tb[IFA_BROADCAST]) {
 		fprintf(fp, "brd ");
 		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
-			format_host(ifa->ifa_family,
-				    RTA_PAYLOAD(rta_tb[IFA_BROADCAST]),
-				    RTA_DATA(rta_tb[IFA_BROADCAST])));
+		              format_host_rta(ifa->ifa_family,
+		                              rta_tb[IFA_BROADCAST]));
 	}
 	if (rta_tb[IFA_ANYCAST]) {
 		fprintf(fp, "any ");
 		color_fprintf(fp, ifa_family_color(ifa->ifa_family), "%s ",
-			format_host(ifa->ifa_family,
-				    RTA_PAYLOAD(rta_tb[IFA_ANYCAST]),
-				    RTA_DATA(rta_tb[IFA_ANYCAST])));
+		              format_host_rta(ifa->ifa_family,
+		                              rta_tb[IFA_ANYCAST]));
 	}
 	fprintf(fp, "scope %s ", rtnl_rtscope_n2a(ifa->ifa_scope, b1, sizeof(b1)));
 	if (ifa_flags & IFA_F_SECONDARY) {
diff --git a/ip/ipaddrlabel.c b/ip/ipaddrlabel.c
index 6076bb952297f..b4cd784094719 100644
--- a/ip/ipaddrlabel.c
+++ b/ip/ipaddrlabel.c
@@ -75,9 +75,8 @@ int print_addrlabel(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg
 
 	if (tb[IFAL_ADDRESS]) {
 		fprintf(fp, "prefix %s/%u ",
-			format_host(ifal->ifal_family,
-				    RTA_PAYLOAD(tb[IFAL_ADDRESS]),
-				    RTA_DATA(tb[IFAL_ADDRESS])),
+			format_host_rta(ifal->ifal_family,
+		                        tb[IFAL_ADDRESS]),
 			ifal->ifal_prefixlen);
 	}
 
diff --git a/ip/ipneigh.c b/ip/ipneigh.c
index 583aad30dc820..c49fb4e7f7b58 100644
--- a/ip/ipneigh.c
+++ b/ip/ipneigh.c
@@ -278,9 +278,7 @@ int print_neigh(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 		fprintf(fp, "miss ");
 	if (tb[NDA_DST]) {
 		fprintf(fp, "%s ",
-			format_host(r->ndm_family,
-				    RTA_PAYLOAD(tb[NDA_DST]),
-				    RTA_DATA(tb[NDA_DST])));
+			format_host_rta(r->ndm_family, tb[NDA_DST]));
 	}
 	if (!filter.index && r->ndm_ifindex)
 		fprintf(fp, "dev %s ", ll_index_to_name(r->ndm_ifindex));
diff --git a/ip/iproute.c b/ip/iproute.c
index 1ec9294290b2a..67d551b54d00c 100644
--- a/ip/iproute.c
+++ b/ip/iproute.c
@@ -376,10 +376,8 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				r->rtm_dst_len
 				);
 		} else {
-			fprintf(fp, "%s ", format_host(r->rtm_family,
-						       RTA_PAYLOAD(tb[RTA_DST]),
-						       RTA_DATA(tb[RTA_DST]))
-				);
+			fprintf(fp, "%s ",
+			        format_host_rta(r->rtm_family, tb[RTA_DST]));
 		}
 	} else if (r->rtm_dst_len) {
 		fprintf(fp, "0/%d ", r->rtm_dst_len);
@@ -394,19 +392,15 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				r->rtm_src_len
 				);
 		} else {
-			fprintf(fp, "from %s ", format_host(r->rtm_family,
-						       RTA_PAYLOAD(tb[RTA_SRC]),
-						       RTA_DATA(tb[RTA_SRC]))
-				);
+			fprintf(fp, "from %s ",
+			        format_host_rta(r->rtm_family, tb[RTA_SRC]));
 		}
 	} else if (r->rtm_src_len) {
 		fprintf(fp, "from 0/%u ", r->rtm_src_len);
 	}
 	if (tb[RTA_NEWDST]) {
-		fprintf(fp, "as to %s ", format_host(r->rtm_family,
-						  RTA_PAYLOAD(tb[RTA_NEWDST]),
-						  RTA_DATA(tb[RTA_NEWDST]))
-			);
+		fprintf(fp, "as to %s ",
+		        format_host_rta(r->rtm_family, tb[RTA_NEWDST]));
 	}
 
 	if (tb[RTA_ENCAP])
@@ -419,9 +413,7 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 
 	if (tb[RTA_GATEWAY] && filter.rvia.bitlen != host_len) {
 		fprintf(fp, "via %s ",
-			format_host(r->rtm_family,
-				    RTA_PAYLOAD(tb[RTA_GATEWAY]),
-				    RTA_DATA(tb[RTA_GATEWAY])));
+		        format_host_rta(r->rtm_family, tb[RTA_GATEWAY]));
 	}
 	if (tb[RTA_VIA]) {
 		size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
@@ -653,16 +645,13 @@ int print_route(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 							tb[RTA_ENCAP]);
 				if (tb[RTA_NEWDST]) {
 					fprintf(fp, " as to %s ",
-						format_host(r->rtm_family,
-						RTA_PAYLOAD(tb[RTA_NEWDST]),
-						RTA_DATA(tb[RTA_NEWDST]),
-						abuf, sizeof(abuf)));
+						format_host_rta(r->rtm_family,
+								tb[RTA_NEWDST]));
 				}
 				if (tb[RTA_GATEWAY]) {
 					fprintf(fp, " via %s ",
-						format_host(r->rtm_family,
-							    RTA_PAYLOAD(tb[RTA_GATEWAY]),
-							    RTA_DATA(tb[RTA_GATEWAY])));
+						format_host_rta(r->rtm_family,
+								tb[RTA_GATEWAY]));
 				}
 				if (tb[RTA_VIA]) {
 					size_t len = RTA_PAYLOAD(tb[RTA_VIA]) - 2;
diff --git a/ip/iproute_lwtunnel.c b/ip/iproute_lwtunnel.c
index 53d3ad4e6ea8e..56af9e4e92ecd 100644
--- a/ip/iproute_lwtunnel.c
+++ b/ip/iproute_lwtunnel.c
@@ -62,9 +62,8 @@ static void print_encap_mpls(FILE *fp, struct rtattr *encap)
 	parse_rtattr_nested(tb, MPLS_IPTUNNEL_MAX, encap);
 
 	if (tb[MPLS_IPTUNNEL_DST])
-		fprintf(fp, " %s ", format_host(AF_MPLS,
-			RTA_PAYLOAD(tb[MPLS_IPTUNNEL_DST]),
-			RTA_DATA(tb[MPLS_IPTUNNEL_DST])));
+		fprintf(fp, " %s ",
+		        format_host_rta(AF_MPLS, tb[MPLS_IPTUNNEL_DST]));
 }
 
 static void print_encap_ip(FILE *fp, struct rtattr *encap)
diff --git a/ip/iprule.c b/ip/iprule.c
index 3fd510efe5e1b..ac570440d6633 100644
--- a/ip/iprule.c
+++ b/ip/iprule.c
@@ -89,10 +89,8 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				r->rtm_src_len
 				);
 		} else {
-			fprintf(fp, "from %s ", format_host(r->rtm_family,
-						       RTA_PAYLOAD(tb[FRA_SRC]),
-						       RTA_DATA(tb[FRA_SRC]))
-				);
+			fprintf(fp, "from %s ",
+			        format_host_rta(r->rtm_family, tb[FRA_SRC]));
 		}
 	} else if (r->rtm_src_len) {
 		fprintf(fp, "from 0/%d ", r->rtm_src_len);
@@ -108,9 +106,8 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 				r->rtm_dst_len
 				);
 		} else {
-			fprintf(fp, "to %s ", format_host(r->rtm_family,
-						       RTA_PAYLOAD(tb[FRA_DST]),
-						       RTA_DATA(tb[FRA_DST])));
+			fprintf(fp, "to %s ",
+			        format_host_rta(r->rtm_family, tb[FRA_DST]));
 		}
 	} else if (r->rtm_dst_len) {
 		fprintf(fp, "to 0/%d ", r->rtm_dst_len);
@@ -183,9 +180,8 @@ int print_rule(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (r->rtm_type == RTN_NAT) {
 		if (tb[RTA_GATEWAY]) {
 			fprintf(fp, "map-to %s ",
-				format_host(r->rtm_family,
-					    RTA_PAYLOAD(tb[RTA_GATEWAY]),
-					    RTA_DATA(tb[RTA_GATEWAY])));
+			        format_host_rta(r->rtm_family,
+			                        tb[RTA_GATEWAY]));
 		} else
 			fprintf(fp, "masquerade");
 	} else if (r->rtm_type == FR_ACT_GOTO) {
diff --git a/ip/iptoken.c b/ip/iptoken.c
index 02fe98e249526..6e1a1ab7f36e7 100644
--- a/ip/iptoken.c
+++ b/ip/iptoken.c
@@ -78,12 +78,9 @@ static int print_token(const struct sockaddr_nl *who, struct nlmsghdr *n, void *
 		return -1;
 	}
 
-	fprintf(fp, "token %s ",
-		format_host(ifi->ifi_family,
-			    RTA_PAYLOAD(ltb[IFLA_INET6_TOKEN]),
-			    RTA_DATA(ltb[IFLA_INET6_TOKEN])));
-	fprintf(fp, "dev %s ", ll_index_to_name(ifi->ifi_index));
-	fprintf(fp, "\n");
+	fprintf(fp, "token %s dev %s\n",
+	        format_host_rta(ifi->ifi_family, ltb[IFLA_INET6_TOKEN]),
+	        ll_index_to_name(ifi->ifi_index));
 	fflush(fp);
 
 	return 0;
-- 
2.7.2

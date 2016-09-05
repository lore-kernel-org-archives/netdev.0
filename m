From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH iproute2 1/2] tunnels: use macros for IPv6 address comparison
Date: Mon,  5 Sep 2016 11:35:27 +0200
Message-ID: <34aa27147303e9b5cf391a90eb29b2317036c9ed.1473067954.git.jbenc@redhat.com>
References: <cover.1473067954.git.jbenc@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44844 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932192AbcIEJft (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 5 Sep 2016 05:35:49 -0400
In-Reply-To: <cover.1473067954.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Replace open coded comparison of IPv6 addresses with appropriate macros.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 ip/ip6tunnel.c     |  8 ++++----
 ip/iplink_geneve.c |  6 +++---
 ip/iplink_vxlan.c  | 14 +++++++-------
 3 files changed, 14 insertions(+), 14 deletions(-)

diff --git a/ip/ip6tunnel.c b/ip/ip6tunnel.c
index ce760bd0bd41..b1c0ae62944c 100644
--- a/ip/ip6tunnel.c
+++ b/ip/ip6tunnel.c
@@ -313,10 +313,10 @@ static int ip6_tnl_parm_match(const struct ip6_tnl_parm2 *p1,
 {
 	return ((!p1->link || p1->link == p2->link) &&
 		(!p1->name[0] || strcmp(p1->name, p2->name) == 0) &&
-		(memcmp(&p1->laddr, &in6addr_any, sizeof(p1->laddr)) == 0 ||
-		 memcmp(&p1->laddr, &p2->laddr, sizeof(p1->laddr)) == 0) &&
-		(memcmp(&p1->raddr, &in6addr_any, sizeof(p1->raddr)) == 0 ||
-		 memcmp(&p1->raddr, &p2->raddr, sizeof(p1->raddr)) == 0) &&
+		(IN6_IS_ADDR_UNSPECIFIED(&p1->laddr) ||
+		 IN6_ARE_ADDR_EQUAL(&p1->laddr, &p2->laddr)) &&
+		(IN6_IS_ADDR_UNSPECIFIED(&p1->raddr) ||
+		 IN6_ARE_ADDR_EQUAL(&p1->raddr, &p2->raddr)) &&
 		(!p1->proto || !p2->proto || p1->proto == p2->proto) &&
 		(!p1->encap_limit || p1->encap_limit == p2->encap_limit) &&
 		(!p1->hop_limit || p1->hop_limit == p2->hop_limit) &&
diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 65af6b35eb8b..3bfba91c644c 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -150,7 +150,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 			return -1;
 		}
 
-		if (!daddr && memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) == 0) {
+		if (!daddr && IN6_IS_ADDR_UNSPECIFIED(&daddr6)) {
 			fprintf(stderr, "geneve: remote link partner not specified\n");
 			return -1;
 		}
@@ -159,7 +159,7 @@ static int geneve_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr32(n, 1024, IFLA_GENEVE_ID, vni);
 	if (daddr)
 		addattr_l(n, 1024, IFLA_GENEVE_REMOTE, &daddr, 4);
-	if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0)
+	if (!IN6_IS_ADDR_UNSPECIFIED(&daddr6))
 		addattr_l(n, 1024, IFLA_GENEVE_REMOTE6, &daddr6, sizeof(struct in6_addr));
 	addattr32(n, 1024, IFLA_GENEVE_LABEL, label);
 	addattr8(n, 1024, IFLA_GENEVE_TTL, ttl);
@@ -203,7 +203,7 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		struct in6_addr addr;
 
 		memcpy(&addr, RTA_DATA(tb[IFLA_GENEVE_REMOTE6]), sizeof(struct in6_addr));
-		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0) {
+		if (!IN6_IS_ADDR_UNSPECIFIED(&addr)) {
 			if (!IN6_IS_ADDR_MULTICAST(&addr))
 				fprintf(f, "remote %s ",
 					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 7ba68bc14c78..251d3f1cfb0b 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -260,8 +260,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	}
 
 	if ((gaddr && daddr) ||
-		(memcmp(&gaddr6, &in6addr_any, sizeof(gaddr6)) &&
-		 memcmp(&daddr6, &in6addr_any, sizeof(daddr6)))) {
+	    (!IN6_IS_ADDR_UNSPECIFIED(&gaddr6) &&
+	     !IN6_IS_ADDR_UNSPECIFIED(&daddr6))) {
 		fprintf(stderr, "vxlan: both group and remote cannot be specified\n");
 		return -1;
 	}
@@ -281,14 +281,14 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &gaddr, 4);
 	else if (daddr)
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &daddr, 4);
-	if (memcmp(&gaddr6, &in6addr_any, sizeof(gaddr6)) != 0)
+	if (!IN6_IS_ADDR_UNSPECIFIED(&gaddr6))
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &gaddr6, sizeof(struct in6_addr));
-	else if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0)
+	else if (!IN6_IS_ADDR_UNSPECIFIED(&daddr6))
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &daddr6, sizeof(struct in6_addr));
 
 	if (saddr)
 		addattr_l(n, 1024, IFLA_VXLAN_LOCAL, &saddr, 4);
-	else if (memcmp(&saddr6, &in6addr_any, sizeof(saddr6)) != 0)
+	else if (!IN6_IS_ADDR_UNSPECIFIED(&saddr6))
 		addattr_l(n, 1024, IFLA_VXLAN_LOCAL6, &saddr6, sizeof(struct in6_addr));
 
 	if (link)
@@ -365,7 +365,7 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		struct in6_addr addr;
 
 		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_GROUP6]), sizeof(struct in6_addr));
-		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0) {
+		if (!IN6_IS_ADDR_UNSPECIFIED(&addr)) {
 			if (IN6_IS_ADDR_MULTICAST(&addr))
 				fprintf(f, "group %s ",
 					format_host(AF_INET6, sizeof(struct in6_addr), &addr));
@@ -385,7 +385,7 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		struct in6_addr addr;
 
 		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_LOCAL6]), sizeof(struct in6_addr));
-		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0)
+		if (!IN6_IS_ADDR_UNSPECIFIED(&addr))
 			fprintf(f, "local %s ",
 				format_host(AF_INET6, sizeof(struct in6_addr), &addr));
 	}
-- 
1.8.3.1

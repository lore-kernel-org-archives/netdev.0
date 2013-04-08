From: Cong Wang <amwang@redhat.com>
Subject: [PATCH iproute2] vxlan: add ipv6 support
Date: Mon,  8 Apr 2013 10:18:56 +0800
Message-ID: <1365387536-25217-5-git-send-email-amwang@redhat.com>
References: <1365387536-25217-1-git-send-email-amwang@redhat.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29003 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760854Ab3DHCTW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 7 Apr 2013 22:19:22 -0400
In-Reply-To: <1365387536-25217-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 include/linux/if_link.h |    2 ++
 ip/iplink_vxlan.c       |   45 ++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 40 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 40167af..f74b8cc 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -306,6 +306,8 @@ enum {
 	IFLA_VXLAN_RSC,
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
+	IFLA_VXLAN_GROUP6,
+	IFLA_VXLAN_LOCAL6,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 1025326..c10ec0f 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -42,6 +42,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	int vni_set = 0;
 	__u32 saddr = 0;
 	__u32 gaddr = 0;
+	struct in6_addr saddr6 = IN6ADDR_ANY_INIT;
+	struct in6_addr gaddr6 = IN6ADDR_ANY_INIT;
 	unsigned link = 0;
 	__u8 tos = 0;
 	__u8 ttl = 0;
@@ -65,15 +67,26 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			vni_set = 1;
 		} else if (!matches(*argv, "group")) {
 			NEXT_ARG();
-			gaddr = get_addr32(*argv);
-
-			if (!IN_MULTICAST(ntohl(gaddr)))
-				invarg("invald group address", *argv);
+			if (!inet_pton(AF_INET, *argv, &gaddr)) {
+				if (!inet_pton(AF_INET6, *argv, &gaddr6)) {
+					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+					return -1;
+				} else if (!IN6_IS_ADDR_MULTICAST(&gaddr6))
+					invarg("invald group address", *argv);
+			} else if (!IN_MULTICAST(ntohl(gaddr)))
+					invarg("invald group address", *argv);
 		} else if (!matches(*argv, "local")) {
 			NEXT_ARG();
-			if (strcmp(*argv, "any"))
-				saddr = get_addr32(*argv);
-			if (IN_MULTICAST(ntohl(saddr)))
+			if (strcmp(*argv, "any")) {
+				if (!inet_pton(AF_INET, *argv, &saddr)) {
+					if (!inet_pton(AF_INET6, *argv, &saddr6)) {
+						fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+						return -1;
+					}
+				}
+			}
+
+			if (IN_MULTICAST(ntohl(saddr)) || IN6_IS_ADDR_MULTICAST(&saddr6))
 				invarg("invalid local address", *argv);
 		} else if (!matches(*argv, "dev")) {
 			NEXT_ARG();
@@ -163,8 +176,14 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	addattr32(n, 1024, IFLA_VXLAN_ID, vni);
 	if (gaddr)
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &gaddr, 4);
+	else if (memcmp(&gaddr6, &in6addr_any, sizeof(gaddr6)) != 0)
+		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &gaddr6, sizeof(struct in6_addr));
+
 	if (saddr)
 		addattr_l(n, 1024, IFLA_VXLAN_LOCAL, &saddr, 4);
+	else if (memcmp(&saddr6, &in6addr_any, sizeof(saddr6)) != 0)
+		addattr_l(n, 1024, IFLA_VXLAN_LOCAL6, &saddr6, sizeof(struct in6_addr));
+
 	if (link)
 		addattr32(n, 1024, IFLA_VXLAN_LINK, link);
 	addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
@@ -211,6 +230,12 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		if (addr)
 			fprintf(f, "group %s ",
 				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	} else if (tb[IFLA_VXLAN_GROUP6]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_GROUP6]), sizeof(struct in6_addr));
+		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0)
+			fprintf(f, "group %s ",
+				format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
 	}
 
 	if (tb[IFLA_VXLAN_LOCAL]) {
@@ -218,6 +243,12 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		if (addr)
 			fprintf(f, "local %s ",
 				format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
+	} else if (tb[IFLA_VXLAN_LOCAL6]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_LOCAL6]), sizeof(struct in6_addr));
+		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0)
+			fprintf(f, "local %s ",
+				format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
 	}
 
 	if (tb[IFLA_VXLAN_LINK] &&
-- 
1.7.7.6

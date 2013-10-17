From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH iproute2 v2] vxlan: add ipv6 support
Date: Wed, 16 Oct 2013 22:03:48 -0700
Message-ID: <1381986228-5780-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:46981 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717Ab3JQFD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Oct 2013 01:03:56 -0400
Received: by mail-pa0-f43.google.com with SMTP id hz1so1716491pad.30
        for <netdev@vger.kernel.org>; Wed, 16 Oct 2013 22:03:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The kernel already supports it, so add the support
to iproute2 as well.
    
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
v2: use a helper

diff --git a/include/utils.h b/include/utils.h
index 24ff19f..a3e310e 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -151,6 +151,7 @@ int print_timestamp(FILE *fp);
 extern int cmdlineno;
 extern ssize_t getcmdline(char **line, size_t *len, FILE *in);
 extern int makeargs(char *line, char *argv[], int maxargs);
+extern int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6);
 
 struct iplink_req;
 int iplink_parse(int argc, char **argv, struct iplink_req *req,
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 4304b0d..aa551d8 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -43,6 +43,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u32 saddr = 0;
 	__u32 gaddr = 0;
 	__u32 daddr = 0;
+	struct in6_addr saddr6 = IN6ADDR_ANY_INIT;
+	struct in6_addr gaddr6 = IN6ADDR_ANY_INIT;
+	struct in6_addr daddr6 = IN6ADDR_ANY_INIT;
 	unsigned link = 0;
 	__u8 tos = 0;
 	__u8 ttl = 0;
@@ -66,21 +69,30 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			vni_set = 1;
 		} else if (!matches(*argv, "group")) {
 			NEXT_ARG();
-			gaddr = get_addr32(*argv);
-
-			if (!IN_MULTICAST(ntohl(gaddr)))
+			if (!inet_get_addr(*argv, &gaddr, &gaddr6)) {
+				fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+				return -1;
+			}
+			if (!IN6_IS_ADDR_MULTICAST(&gaddr6) && !IN_MULTICAST(ntohl(gaddr)))
 				invarg("invalid group address", *argv);
 		} else if (!matches(*argv, "remote")) {
 			NEXT_ARG();
-			daddr = get_addr32(*argv);
-
-			if (IN_MULTICAST(ntohl(daddr)))
+			if (!inet_get_addr(*argv, &daddr, &daddr6)) {
+				fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+				return -1;
+			}
+			if (IN6_IS_ADDR_MULTICAST(&daddr6) || IN_MULTICAST(ntohl(daddr)))
 				invarg("invalid remote address", *argv);
 		} else if (!matches(*argv, "local")) {
 			NEXT_ARG();
-			if (strcmp(*argv, "any"))
-				saddr = get_addr32(*argv);
-			if (IN_MULTICAST(ntohl(saddr)))
+			if (strcmp(*argv, "any")) {
+				if (!inet_get_addr(*argv, &saddr, &saddr6)) {
+					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+					return -1;
+				}
+			}
+
+			if (IN_MULTICAST(ntohl(saddr)) || IN6_IS_ADDR_MULTICAST(&saddr6))
 				invarg("invalid local address", *argv);
 		} else if (!matches(*argv, "dev")) {
 			NEXT_ARG();
@@ -167,7 +179,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		fprintf(stderr, "vxlan: missing virtual network identifier\n");
 		return -1;
 	}
-	if (gaddr && daddr) {
+	if ((gaddr && daddr) ||
+		(memcmp(&gaddr6, &in6addr_any, sizeof(gaddr6)) &&
+		 memcmp(&daddr6, &in6addr_any, sizeof(daddr6)))) {
 		fprintf(stderr, "vxlan: both group and remote cannot be specified\n");
 		return -1;
 	}
@@ -176,8 +190,16 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &gaddr, 4);
 	else if (daddr)
 		addattr_l(n, 1024, IFLA_VXLAN_GROUP, &daddr, 4);
+	if (memcmp(&gaddr6, &in6addr_any, sizeof(gaddr6)) != 0)
+		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &gaddr6, sizeof(struct in6_addr));
+	else if (memcmp(&daddr6, &in6addr_any, sizeof(daddr6)) != 0)
+		addattr_l(n, 1024, IFLA_VXLAN_GROUP6, &daddr6, sizeof(struct in6_addr));
+
 	if (saddr)
 		addattr_l(n, 1024, IFLA_VXLAN_LOCAL, &saddr, 4);
+	else if (memcmp(&saddr6, &in6addr_any, sizeof(saddr6)) != 0)
+		addattr_l(n, 1024, IFLA_VXLAN_LOCAL6, &saddr6, sizeof(struct in6_addr));
+
 	if (link)
 		addattr32(n, 1024, IFLA_VXLAN_LINK, link);
 	addattr8(n, 1024, IFLA_VXLAN_TTL, ttl);
@@ -229,6 +251,17 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 				fprintf(f, "remote %s ",
 					format_host(AF_INET, 4, &addr, s1, sizeof(s1)));
 		}
+	} else if (tb[IFLA_VXLAN_GROUP6]) {
+		struct in6_addr addr;
+		memcpy(&addr, RTA_DATA(tb[IFLA_VXLAN_GROUP6]), sizeof(struct in6_addr));
+		if (memcmp(&addr, &in6addr_any, sizeof(addr)) != 0) {
+			if (IN6_IS_ADDR_MULTICAST(&addr))
+				fprintf(f, "group %s ",
+					format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+			else
+				fprintf(f, "remote %s ",
+					format_host(AF_INET6, sizeof(struct in6_addr), &addr, s1, sizeof(s1)));
+		}
 	}
 
 	if (tb[IFLA_VXLAN_LOCAL]) {
@@ -236,6 +269,12 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
diff --git a/lib/utils.c b/lib/utils.c
index dae1b51..4e9c719 100644
--- a/lib/utils.c
+++ b/lib/utils.c
@@ -868,3 +868,11 @@ int makeargs(char *line, char *argv[], int maxargs)
 
 	return argc;
 }
+
+int inet_get_addr(const char *src, __u32 *dst, struct in6_addr *dst6)
+{
+	if (strchr(src, ':'))
+		return inet_pton(AF_INET6, src, dst6);
+	else
+		return inet_pton(AF_INET, src, dst);
+}

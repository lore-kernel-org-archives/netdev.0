From: Cong Wang <amwang@redhat.com>
Subject: [Patch iproute2] vxlan: add ipv6 support
Date: Tue,  3 Sep 2013 11:33:30 +0800
Message-ID: <1378179210-1170-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62386 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154Ab3ICDeM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Sep 2013 23:34:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

The kernel already supports it, so add the support
to iproute2 as well.
    
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index d07aeca..0c37561 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -311,6 +311,8 @@ enum {
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
 	IFLA_VXLAN_PORT,	/* destination port */
+	IFLA_VXLAN_GROUP6,
+	IFLA_VXLAN_LOCAL6,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 4304b0d..12e1c74 100644
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
@@ -66,21 +69,36 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			vni_set = 1;
 		} else if (!matches(*argv, "group")) {
 			NEXT_ARG();
-			gaddr = get_addr32(*argv);
-
-			if (!IN_MULTICAST(ntohl(gaddr)))
-				invarg("invalid group address", *argv);
+			if (!inet_pton(AF_INET, *argv, &gaddr)) {
+				if (!inet_pton(AF_INET6, *argv, &gaddr6)) {
+					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+					return -1;
+				} else if (!IN6_IS_ADDR_MULTICAST(&gaddr6))
+					invarg("invald group address", *argv);
+			} else if (!IN_MULTICAST(ntohl(gaddr)))
+					invarg("invald group address", *argv);
 		} else if (!matches(*argv, "remote")) {
 			NEXT_ARG();
-			daddr = get_addr32(*argv);
-
-			if (IN_MULTICAST(ntohl(daddr)))
-				invarg("invalid remote address", *argv);
+			if (!inet_pton(AF_INET, *argv, &daddr)) {
+				if (!inet_pton(AF_INET6, *argv, &daddr6)) {
+					fprintf(stderr, "Invalid address \"%s\"\n", *argv);
+					return -1;
+				} else if (IN6_IS_ADDR_MULTICAST(&daddr6))
+					invarg("invald remote address", *argv);
+			} else if (IN_MULTICAST(ntohl(daddr)))
+					invarg("invald remote address", *argv);
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
@@ -167,7 +185,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
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
@@ -176,8 +196,16 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
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
@@ -229,6 +257,17 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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
@@ -236,6 +275,12 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
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

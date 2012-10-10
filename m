From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] iproute2: allow configuring vxlan port range
Date: Tue, 9 Oct 2012 23:41:49 -0700
Message-ID: <20121009234149.6db3f3db@nehalam.linuxnetplumber.net>
References: <20121010063545.453368147@vyatta.com>
	<20121010063623.694192145@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43167 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751956Ab2JJGma (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Oct 2012 02:42:30 -0400
In-Reply-To: <20121010063623.694192145@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

New options to ip link to allow setting vxlan port range.
Also, don't print everything that is defaulted when showing device.

---
 include/linux/if_link.h |    6 ++++++
 ip/iplink_vxlan.c       |   51 ++++++++++++++++++++++++++++++++---------------
 2 files changed, 41 insertions(+), 16 deletions(-)

diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1cf79fa..563e8fb 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -282,10 +282,16 @@ enum {
 	IFLA_VXLAN_LEARNING,
 	IFLA_VXLAN_AGEING,
 	IFLA_VXLAN_LIMIT,
+	IFLA_VXLAN_PORT_RANGE,
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
 
+struct ifla_vxlan_port_range {
+	__be16	low;
+	__be16	high;
+};
+
 /* SR-IOV virtual function management section */
 
 enum {
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index f52eb18..7957781 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -24,7 +24,8 @@
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ local ADDR ]\n");
-	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ [no]learning ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
+	fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: VNI := 0-16777215\n");
 	fprintf(stderr, "       ADDR := { IP_ADDRESS | any }\n");
@@ -46,6 +47,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 noage = 0;
 	__u32 age = 0;
 	__u32 maxaddr = 0;
+	struct ifla_vxlan_port_range range = { 0, 0 };
 
 	while (argc > 0) {
 		if (!matches(*argv, "id") ||
@@ -79,9 +81,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			if (strcmp(*argv, "inherit") != 0) {
 				if (get_unsigned(&uval, *argv, 0))
-					invarg("invalid TTL\n", *argv);
+					invarg("invalid TTL", *argv);
 				if (uval > 255)
-					invarg("TTL must be <= 255\n", *argv);
+					invarg("TTL must be <= 255", *argv);
 				ttl = uval;
 			}
 		} else if (!matches(*argv, "tos") ||
@@ -100,13 +102,23 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 			if (strcmp(*argv, "none") == 0)
 				noage = 1;
 			else if (get_u32(&age, *argv, 0))
-				invarg("ageing timer\n", *argv);
+				invarg("ageing timer", *argv);
 		} else if (!matches(*argv, "maxaddress")) {
 			NEXT_ARG();
 			if (strcmp(*argv, "unlimited") == 0)
 				maxaddr = 0;
 			else if (get_u32(&maxaddr, *argv, 0))
-				invarg("max addresses\n", *argv);
+				invarg("max addresses", *argv);
+		} else if (!matches(*argv, "port")) {
+			__u16 minport, maxport;
+			NEXT_ARG();
+			if (get_u16(&minport, *argv, 0))
+				invarg("min port", *argv);
+			NEXT_ARG();
+			if (get_u16(&maxport, *argv, 0))
+				invarg("max port", *argv);
+			range.low = htons(minport);
+			range.high = htons(maxport);
 		} else if (!matches(*argv, "nolearning")) {
 			learning = 0;
 		} else if (!matches(*argv, "learning")) {
@@ -140,6 +152,9 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		addattr32(n, 1024, IFLA_VXLAN_AGEING, age);
 	if (maxaddr)
 		addattr32(n, 1024, IFLA_VXLAN_LIMIT, maxaddr);
+	if (range.low || range.high)
+		addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
+			  &range, sizeof(range));
 
 	return 0;
 }
@@ -148,6 +163,8 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 {
 	__u32 vni;
 	unsigned link;
+	__u8 tos;
+	__u32 maxaddr;
 	char s1[1024];
 	char s2[64];
 
@@ -187,13 +204,18 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			fprintf(f, "dev %u ", link);
 	}
 
+	if (tb[IFLA_VXLAN_PORT_RANGE]) {
+		const struct ifla_vxlan_port_range *r
+			= RTA_DATA(tb[IFLA_VXLAN_PORT_RANGE]);
+		fprintf(f, "port %u %u ", ntohs(r->low), ntohs(r->high));
+	}	
+
 	if (tb[IFLA_VXLAN_LEARNING] &&
 	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
 		fputs("nolearning ", f);
-
-	if (tb[IFLA_VXLAN_TOS]) {
-		__u8 tos = rta_getattr_u8(tb[IFLA_VXLAN_TOS]);
-
+	
+	if (tb[IFLA_VXLAN_TOS] &&
+	    (tos = rta_getattr_u8(tb[IFLA_VXLAN_TOS]))) {
 		if (tos == 1)
 			fprintf(f, "tos inherit ");
 		else
@@ -213,13 +235,10 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 		else
 			fprintf(f, "ageing %u ", age);
 	}
-	if (tb[IFLA_VXLAN_LIMIT]) {
-		__u32 maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT]);
-		if (maxaddr == 0)
-			fprintf(f, "maxaddr unlimited ");
-		else
-			fprintf(f, "maxaddr %u ", maxaddr);
-	}
+
+	if (tb[IFLA_VXLAN_LIMIT] &&
+	    (maxaddr = rta_getattr_u32(tb[IFLA_VXLAN_LIMIT]) != 0))
+		    fprintf(f, "maxaddr %u ", maxaddr);
 }
 
 struct link_util vxlan_link_util = {
-- 
1.7.10.4

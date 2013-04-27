From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH iproute2] iproute2: add vxlan dstport option
Date: Sat, 27 Apr 2013 14:47:47 -0700
Message-ID: <20130427144747.48ace4fb@nehalam.linuxnetplumber.net>
References: <20130427213151.255971631@vyatta.com>
	<20130427213258.534077786@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f45.google.com ([209.85.210.45]:50429 "EHLO
	mail-da0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752373Ab3D0Vr5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Apr 2013 17:47:57 -0400
Received: by mail-da0-f45.google.com with SMTP id v40so437568dad.4
        for <netdev@vger.kernel.org>; Sat, 27 Apr 2013 14:47:56 -0700 (PDT)
In-Reply-To: <20130427213258.534077786@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ability to set UDP destination port on a per device basis.
If no port is assigned, the default IANA assigned port will be used.
If you want the kernel default value, then use port 0.

Source port range option is now called 'srcport', to avoid
confusion. The old option syntax is accepted for compatiablity.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>


diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 40167af..e708e86 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -301,11 +301,12 @@ enum {
 	IFLA_VXLAN_LEARNING,
 	IFLA_VXLAN_AGEING,
 	IFLA_VXLAN_LIMIT,
-	IFLA_VXLAN_PORT_RANGE,
+	IFLA_VXLAN_PORT_RANGE,	/* source port */
 	IFLA_VXLAN_PROXY,
 	IFLA_VXLAN_RSC,
 	IFLA_VXLAN_L2MISS,
 	IFLA_VXLAN_L3MISS,
+	IFLA_VXLAN_PORT,	/* destination port */
 	__IFLA_VXLAN_MAX
 };
 #define IFLA_VXLAN_MAX	(__IFLA_VXLAN_MAX - 1)
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 1025326..2d93ee2 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -25,8 +25,8 @@ static void explain(void)
 {
 	fprintf(stderr, "Usage: ... vxlan id VNI [ group ADDR ] [ local ADDR ]\n");
 	fprintf(stderr, "                 [ ttl TTL ] [ tos TOS ] [ dev PHYS_DEV ]\n");
-	fprintf(stderr, "                 [ port MIN MAX ] [ [no]learning ]\n");
-	fprintf(stderr, "                 [ [no]proxy ] [ [no]rsc ]\n");
+	fprintf(stderr, "                 [ dstport PORT ] [ srcport MIN MAX ]\n");
+	fprintf(stderr, "                 [ [no]learning ] [ [no]proxy ] [ [no]rsc ]\n");
 	fprintf(stderr, "                 [ [no]l2miss ] [ [no]l3miss ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where: VNI := 0-16777215\n");
@@ -53,6 +53,7 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	__u8 noage = 0;
 	__u32 age = 0;
 	__u32 maxaddr = 0;
+	__u16 dstport = 4789;
 	struct ifla_vxlan_port_range range = { 0, 0 };
 
 	while (argc > 0) {
@@ -115,7 +116,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				maxaddr = 0;
 			else if (get_u32(&maxaddr, *argv, 0))
 				invarg("max addresses", *argv);
-		} else if (!matches(*argv, "port")) {
+		} else if (!matches(*argv, "port") ||
+			   !matches(*argv, "srcport")) {
 			__u16 minport, maxport;
 			NEXT_ARG();
 			if (get_u16(&minport, *argv, 0))
@@ -125,6 +127,10 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 				invarg("max port", *argv);
 			range.low = htons(minport);
 			range.high = htons(maxport);
+		} else if (!matches(*argv, "dstport")){
+			NEXT_ARG();
+			if (get_u16(&dstport, *argv, 0))
+				invarg("dst port", *argv);
 		} else if (!matches(*argv, "nolearning")) {
 			learning = 0;
 		} else if (!matches(*argv, "learning")) {
@@ -155,7 +161,6 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 		}
 		argc--, argv++;
 	}
-
 	if (!vni_set) {
 		fprintf(stderr, "vxlan: missing virtual network identifier\n");
 		return -1;
@@ -183,6 +188,8 @@ static int vxlan_parse_opt(struct link_util *lu, int argc, char **argv,
 	if (range.low || range.high)
 		addattr_l(n, 1024, IFLA_VXLAN_PORT_RANGE,
 			  &range, sizeof(range));
+	if (dstport)
+		addattr16(n, 1024, IFLA_VXLAN_PORT, htons(dstport));
 
 	return 0;
 }
@@ -233,9 +240,13 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 	if (tb[IFLA_VXLAN_PORT_RANGE]) {
 		const struct ifla_vxlan_port_range *r
 			= RTA_DATA(tb[IFLA_VXLAN_PORT_RANGE]);
-		fprintf(f, "port %u %u ", ntohs(r->low), ntohs(r->high));
+		fprintf(f, "srcport %u %u ", ntohs(r->low), ntohs(r->high));
 	}
 
+	if (tb[IFLA_VXLAN_PORT])
+		fprintf(f, "dstport %u ",
+			ntohs(rta_getattr_u16(tb[IFLA_VXLAN_PORT])));
+
 	if (tb[IFLA_VXLAN_LEARNING] &&
 	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
 		fputs("nolearning ", f);

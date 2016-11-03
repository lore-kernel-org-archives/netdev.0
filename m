From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2 2/2] tc: flower: Support matching on SCTP ports
Date: Thu,  3 Nov 2016 13:26:41 +0100
Message-ID: <1478176001-29174-3-git-send-email-simon.horman@netronome.com>
References: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f47.google.com ([74.125.82.47]:35378 "EHLO
        mail-wm0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754410AbcKCM2R (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2016 08:28:17 -0400
Received: by mail-wm0-f47.google.com with SMTP id a197so201890981wmd.0
        for <netdev@vger.kernel.org>; Thu, 03 Nov 2016 05:28:17 -0700 (PDT)
In-Reply-To: <1478176001-29174-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Support matching on SCTP ports in the same way that matching
on TCP and UDP ports is already supported.

Example usage:

tc qdisc add dev eth0 ingress

tc filter add dev eth0 protocol ip parent ffff: \
        flower indev eth0 ip_proto sctp dst_port 80 \
        action drop

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 tc/f_flower.c | 65 ++++++++++++++++++++++++++++-------------------------------
 1 file changed, 31 insertions(+), 34 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 2d31d1aa832d..72fe42bc19be 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -96,6 +96,8 @@ static int flower_parse_ip_proto(char *str, __be16 eth_type, int type,
 		ip_proto = IPPROTO_TCP;
 	} else if (matches(str, "udp") == 0) {
 		ip_proto = IPPROTO_UDP;
+	} else if (matches(str, "sctp") == 0) {
+		ip_proto = IPPROTO_SCTP;
 	} else {
 		ret = get_u8(&ip_proto, str, 16);
 		if (ret)
@@ -156,21 +158,33 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 	return 0;
 }
 
-static int flower_parse_port(char *str, __u8 ip_port,
-			     int tcp_type, int udp_type, struct nlmsghdr *n)
+static int flower_port_attr_type(__u8 ip_port, bool is_src)
 {
-	int ret;
-	int type;
-	__be16 port;
-
 	if (ip_port == IPPROTO_TCP) {
-		type = tcp_type;
+		return is_src ? TCA_FLOWER_KEY_TCP_SRC :
+			TCA_FLOWER_KEY_TCP_DST;
 	} else if (ip_port == IPPROTO_UDP) {
-		type = udp_type;
+		return is_src ? TCA_FLOWER_KEY_UDP_SRC :
+			TCA_FLOWER_KEY_UDP_DST;
+	} else if (ip_port == IPPROTO_SCTP) {
+		return is_src ? TCA_FLOWER_KEY_SCTP_SRC :
+			TCA_FLOWER_KEY_SCTP_DST;
 	} else {
 		fprintf(stderr, "Illegal \"ip_proto\" for port\n");
 		return -1;
 	}
+}
+
+static int flower_parse_port(char *str, __u8 ip_port, bool is_src,
+			     struct nlmsghdr *n)
+{
+	int ret;
+	int type;
+	__be16 port;
+
+	type = flower_port_attr_type(ip_port, is_src);
+	if (type < 0)
+		return -1;
 
 	ret = get_be16(&port, str, 10);
 	if (ret)
@@ -323,18 +337,14 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			}
 		} else if (matches(*argv, "dst_port") == 0) {
 			NEXT_ARG();
-			ret = flower_parse_port(*argv, ip_proto,
-						TCA_FLOWER_KEY_TCP_DST,
-						TCA_FLOWER_KEY_UDP_DST, n);
+			ret = flower_parse_port(*argv, ip_proto, false, n);
 			if (ret < 0) {
 				fprintf(stderr, "Illegal \"dst_port\"\n");
 				return -1;
 			}
 		} else if (matches(*argv, "src_port") == 0) {
 			NEXT_ARG();
-			ret = flower_parse_port(*argv, ip_proto,
-						TCA_FLOWER_KEY_TCP_SRC,
-						TCA_FLOWER_KEY_UDP_SRC, n);
+			ret = flower_parse_port(*argv, ip_proto, true, n);
 			if (ret < 0) {
 				fprintf(stderr, "Illegal \"src_port\"\n");
 				return -1;
@@ -450,6 +460,8 @@ static void flower_print_ip_proto(FILE *f, __u8 *p_ip_proto,
 		fprintf(f, "tcp");
 	else if (ip_proto == IPPROTO_UDP)
 		fprintf(f, "udp");
+	else if (ip_proto == IPPROTO_SCTP)
+		fprintf(f, "sctp");
 	else
 		fprintf(f, "%02x", ip_proto);
 	*p_ip_proto = ip_proto;
@@ -492,20 +504,8 @@ static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 		fprintf(f, "/%d", bits);
 }
 
-static void flower_print_port(FILE *f, char *name, __u8 ip_proto,
-			      struct rtattr *tcp_attr,
-			      struct rtattr *udp_attr)
+static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
 {
-	struct rtattr *attr;
-
-	if (ip_proto == IPPROTO_TCP)
-		attr = tcp_attr;
-	else if (ip_proto == IPPROTO_UDP)
-		attr = udp_attr;
-	else
-		return;
-	if (!attr)
-		return;
 	fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u16(attr)));
 }
 
@@ -569,13 +569,10 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 			     tb[TCA_FLOWER_KEY_IPV6_SRC],
 			     tb[TCA_FLOWER_KEY_IPV6_SRC_MASK]);
 
-	flower_print_port(f, "dst_port", ip_proto,
-			  tb[TCA_FLOWER_KEY_TCP_DST],
-			  tb[TCA_FLOWER_KEY_UDP_DST]);
-
-	flower_print_port(f, "src_port", ip_proto,
-			  tb[TCA_FLOWER_KEY_TCP_SRC],
-			  tb[TCA_FLOWER_KEY_UDP_SRC]);
+	flower_print_port(f, "dst_port",
+			  tb[flower_port_attr_type(ip_proto, false)]);
+	flower_print_port(f, "src_port",
+			  tb[flower_port_attr_type(ip_proto, true)]);
 
 	if (tb[TCA_FLOWER_FLAGS])  {
 		__u32 flags = rta_getattr_u32(tb[TCA_FLOWER_FLAGS]);
-- 
2.7.0.rc3.207.g0ac5344

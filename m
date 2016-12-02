From: Simon Horman <simon.horman@netronome.com>
Subject: [[PATCH iproute2/net-next v2] 4/4] tc: flower: make use of flower_port_attr_type() safe and silent
Date: Fri,  2 Dec 2016 09:45:21 +0100
Message-ID: <1480668321-20875-5-git-send-email-simon.horman@netronome.com>
References: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, Simon Horman <simon.horman@netronome.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f174.google.com ([209.85.210.174]:33989 "EHLO
        mail-wj0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932398AbcLBIpk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 03:45:40 -0500
Received: by mail-wj0-f174.google.com with SMTP id mp19so226382653wjc.1
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 00:45:39 -0800 (PST)
In-Reply-To: <1480668321-20875-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make use of flower_port_attr_type() safe:
* flower_port_attr_type() may return a valid index into tb[] or -1.
  Only access tb[] in the case of the former.
* Do not access null entries in tb[]

Also make usage silent - it is valid for ip_proto to be invalid,
for example if it is not specified as part of the filter.

Fixes: a1fb0d484237 ("tc: flower: Support matching on SCTP ports")
Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
 tc/f_flower.c | 24 +++++++++++++-----------
 1 file changed, 13 insertions(+), 11 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index d86ccdc3d3f0..615e8f27bed2 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -162,19 +162,17 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 
 static int flower_port_attr_type(__u8 ip_proto, bool is_src)
 {
-	if (ip_proto == IPPROTO_TCP) {
+	if (ip_proto == IPPROTO_TCP)
 		return is_src ? TCA_FLOWER_KEY_TCP_SRC :
 			TCA_FLOWER_KEY_TCP_DST;
-	} else if (ip_proto == IPPROTO_UDP) {
+	else if (ip_proto == IPPROTO_UDP)
 		return is_src ? TCA_FLOWER_KEY_UDP_SRC :
 			TCA_FLOWER_KEY_UDP_DST;
-	} else if (ip_proto == IPPROTO_SCTP) {
+	else if (ip_proto == IPPROTO_SCTP)
 		return is_src ? TCA_FLOWER_KEY_SCTP_SRC :
 			TCA_FLOWER_KEY_SCTP_DST;
-	} else {
-		fprintf(stderr, "Illegal \"ip_proto\" for port\n");
+	else
 		return -1;
-	}
 }
 
 static int flower_parse_port(char *str, __u8 ip_proto, bool is_src,
@@ -511,7 +509,8 @@ static void flower_print_ip_addr(FILE *f, char *name, __be16 eth_type,
 
 static void flower_print_port(FILE *f, char *name, struct rtattr *attr)
 {
-	fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u16(attr)));
+	if (attr)
+		fprintf(f, "\n  %s %d", name, ntohs(rta_getattr_u16(attr)));
 }
 
 static int flower_print_opt(struct filter_util *qu, FILE *f,
@@ -520,6 +519,7 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 	struct rtattr *tb[TCA_FLOWER_MAX + 1];
 	__be16 eth_type = 0;
 	__u8 ip_proto = 0xff;
+	int nl_type;
 
 	if (!opt)
 		return 0;
@@ -574,10 +574,12 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 			     tb[TCA_FLOWER_KEY_IPV6_SRC],
 			     tb[TCA_FLOWER_KEY_IPV6_SRC_MASK]);
 
-	flower_print_port(f, "dst_port",
-			  tb[flower_port_attr_type(ip_proto, false)]);
-	flower_print_port(f, "src_port",
-			  tb[flower_port_attr_type(ip_proto, true)]);
+	nl_type = flower_port_attr_type(ip_proto, false);
+	if (nl_type >= 0)
+		flower_print_port(f, "dst_port", tb[nl_type]);
+	nl_type = flower_port_attr_type(ip_proto, true);
+	if (nl_type >= 0)
+		flower_print_port(f, "src_port", tb[nl_type]);
 
 	if (tb[TCA_FLOWER_FLAGS]) {
 		__u32 flags = rta_getattr_u32(tb[TCA_FLOWER_FLAGS]);
-- 
2.7.0.rc3.207.g0ac5344

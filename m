From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH iproute2/net-next 2/3] tc: flower: introduce enum flower_endpoint
Date: Fri,  2 Dec 2016 19:24:38 +0100
Message-ID: <1480703079-25422-3-git-send-email-simon.horman@netronome.com>
References: <1480703079-25422-1-git-send-email-simon.horman@netronome.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>,
        Jamal Hadi Salim <jhs@mojatatu.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Simon Horman <simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f174.google.com ([209.85.210.174]:33134 "EHLO
        mail-wj0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753815AbcLBSZv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 13:25:51 -0500
Received: by mail-wj0-f174.google.com with SMTP id xy5so239075749wjc.0
        for <netdev@vger.kernel.org>; Fri, 02 Dec 2016 10:24:56 -0800 (PST)
In-Reply-To: <1480703079-25422-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Introduce enum flower_endpoint and use it instead of a bool
as the type for paramatising source and destination.

This is intended to improve read-ability and provide some type
checking of endpoint parameters.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
---
v2
* Rename enums FLOWER_ENDPOINT_SRC/DST
---
 tc/f_flower.c | 27 +++++++++++++++++++--------
 1 file changed, 19 insertions(+), 8 deletions(-)

diff --git a/tc/f_flower.c b/tc/f_flower.c
index 615e8f27bed2..22d95305acb4 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -23,6 +23,11 @@
 #include "tc_util.h"
 #include "rt_names.h"
 
+enum flower_endpoint {
+	FLOWER_ENDPOINT_SRC,
+	FLOWER_ENDPOINT_DST
+};
+
 static void explain(void)
 {
 	fprintf(stderr,
@@ -160,29 +165,33 @@ static int flower_parse_ip_addr(char *str, __be16 eth_type,
 	return 0;
 }
 
-static int flower_port_attr_type(__u8 ip_proto, bool is_src)
+static int flower_port_attr_type(__u8 ip_proto, enum flower_endpoint endpoint)
 {
 	if (ip_proto == IPPROTO_TCP)
-		return is_src ? TCA_FLOWER_KEY_TCP_SRC :
+		return endpoint == FLOWER_ENDPOINT_SRC ?
+			TCA_FLOWER_KEY_TCP_SRC :
 			TCA_FLOWER_KEY_TCP_DST;
 	else if (ip_proto == IPPROTO_UDP)
-		return is_src ? TCA_FLOWER_KEY_UDP_SRC :
+		return endpoint == FLOWER_ENDPOINT_SRC ?
+			TCA_FLOWER_KEY_UDP_SRC :
 			TCA_FLOWER_KEY_UDP_DST;
 	else if (ip_proto == IPPROTO_SCTP)
-		return is_src ? TCA_FLOWER_KEY_SCTP_SRC :
+		return endpoint == FLOWER_ENDPOINT_SRC ?
+			TCA_FLOWER_KEY_SCTP_SRC :
 			TCA_FLOWER_KEY_SCTP_DST;
 	else
 		return -1;
 }
 
-static int flower_parse_port(char *str, __u8 ip_proto, bool is_src,
+static int flower_parse_port(char *str, __u8 ip_proto,
+			     enum flower_endpoint endpoint,
 			     struct nlmsghdr *n)
 {
 	int ret;
 	int type;
 	__be16 port;
 
-	type = flower_port_attr_type(ip_proto, is_src);
+	type = flower_port_attr_type(ip_proto, endpoint);
 	if (type < 0)
 		return -1;
 
@@ -340,14 +349,16 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 			}
 		} else if (matches(*argv, "dst_port") == 0) {
 			NEXT_ARG();
-			ret = flower_parse_port(*argv, ip_proto, false, n);
+			ret = flower_parse_port(*argv, ip_proto,
+						FLOWER_ENDPOINT_DST, n);
 			if (ret < 0) {
 				fprintf(stderr, "Illegal \"dst_port\"\n");
 				return -1;
 			}
 		} else if (matches(*argv, "src_port") == 0) {
 			NEXT_ARG();
-			ret = flower_parse_port(*argv, ip_proto, true, n);
+			ret = flower_parse_port(*argv, ip_proto,
+						FLOWER_ENDPOINT_SRC, n);
 			if (ret < 0) {
 				fprintf(stderr, "Illegal \"src_port\"\n");
 				return -1;
-- 
2.7.0.rc3.207.g0ac5344

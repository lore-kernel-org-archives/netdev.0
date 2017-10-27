From: Amritha Nambiar <amritha.nambiar@intel.com>
Subject: [iproute2,
 RFC PATCH] flower: Represent HW traffic classes as classid values
Date: Fri, 27 Oct 2017 02:37:44 -0700
Message-ID: <150909706435.48576.5205367455065671596.stgit@anamdev.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@intel.com, jiri@resnulli.us,
        amritha.nambiar@intel.com, jhs@mojatatu.com,
        alexander.duyck@gmail.com, xiyou.wangcong@gmail.com
To: stephen@networkplumber.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.43]:6325 "EHLO mga05.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752114AbdJ0JjV (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 27 Oct 2017 05:39:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use the classid values reserved in the range :ffe0 - :ffef
to identify hardware traffic classes.

Example:
Match Dst IPv4,Dst Port and route to TC1:
# tc filter add dev eth0 protocol ip parent ffff:\
  prio 1 flower dst_ip 192.168.1.1/32\
  ip_proto udp dst_port 12000 skip_sw\
  hw_tc 1

# tc filter show dev eth0 parent ffff:
filter pref 1 flower chain 0
filter pref 1 flower chain 0 handle 0x1 hw_tc 1
  eth_type ipv4
  ip_proto udp
  dst_ip 192.168.1.1
  dst_port 12000
  skip_sw
  in_hw

Signed-off-by: Amritha Nambiar <amritha.nambiar@intel.com>
---
 include/uapi/linux/pkt_sched.h |    1 +
 tc/f_flower.c                  |   35 +++++++++++++++++++++++++++++++----
 2 files changed, 32 insertions(+), 4 deletions(-)

diff --git a/include/uapi/linux/pkt_sched.h b/include/uapi/linux/pkt_sched.h
index e95b5c9..e7cc3d3 100644
--- a/include/uapi/linux/pkt_sched.h
+++ b/include/uapi/linux/pkt_sched.h
@@ -74,6 +74,7 @@ struct tc_estimator {
 #define TC_H_INGRESS    (0xFFFFFFF1U)
 #define TC_H_CLSACT	TC_H_INGRESS
 
+#define TC_H_MIN_PRIORITY	0xFFE0U
 #define TC_H_MIN_INGRESS	0xFFF2U
 #define TC_H_MIN_EGRESS		0xFFF3U
 
diff --git a/tc/f_flower.c b/tc/f_flower.c
index b180210..6ea0fba 100644
--- a/tc/f_flower.c
+++ b/tc/f_flower.c
@@ -614,6 +614,25 @@ static int flower_parse_opt(struct filter_util *qu, char *handle,
 				return -1;
 			}
 			addattr_l(n, MAX_MSG, TCA_FLOWER_CLASSID, &handle, 4);
+		} else if (matches(*argv, "hw_tc") == 0) {
+			unsigned int handle;
+			__u32 tc;
+			char *end;
+
+			NEXT_ARG();
+			tc = strtoul(*argv, &end, 0);
+			if (*end) {
+				fprintf(stderr, "Illegal TC index\n");
+				return -1;
+			}
+			if (tc >= TC_QOPT_MAX_QUEUE) {
+				fprintf(stderr, "TC index exceeds max range\n");
+				return -1;
+			}
+			handle = TC_H_MAKE(TC_H_MAJ(t->tcm_parent),
+					   TC_H_MIN(tc + TC_H_MIN_PRIORITY));
+			addattr_l(n, MAX_MSG, TCA_FLOWER_CLASSID, &handle,
+				  sizeof(handle));
 		} else if (matches(*argv, "ip_flags") == 0) {
 			NEXT_ARG();
 			ret = flower_parse_matching_flags(*argv,
@@ -1187,10 +1206,18 @@ static int flower_print_opt(struct filter_util *qu, FILE *f,
 		fprintf(f, "handle 0x%x ", handle);
 
 	if (tb[TCA_FLOWER_CLASSID]) {
-		SPRINT_BUF(b1);
-		fprintf(f, "classid %s ",
-			sprint_tc_classid(rta_getattr_u32(tb[TCA_FLOWER_CLASSID]),
-					  b1));
+		__u32 h = rta_getattr_u32(tb[TCA_FLOWER_CLASSID]);
+
+		if (TC_H_MIN(h) < TC_H_MIN_PRIORITY ||
+		    TC_H_MIN(h) > (TC_H_MIN_PRIORITY + TC_QOPT_MAX_QUEUE - 1)) {
+			SPRINT_BUF(b1);
+			fprintf(f, "classid %s ",
+				sprint_tc_classid(rta_getattr_u32(tb[TCA_FLOWER_CLASSID]),
+						  b1));
+		} else {
+			fprintf(f, "hw_tc %u ",
+				TC_H_MIN(h) - TC_H_MIN_PRIORITY);
+		}
 	}
 
 	if (tb[TCA_FLOWER_INDEV]) {

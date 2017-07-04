From: "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>
Subject: [PATCH 1/1] tc: custom qdisc pkt size translation table
Date: Mon,  3 Jul 2017 19:14:26 -0500
Message-ID: <20170704001426.9268-2-Robert.McCabe@rockwellcollins.com>
References: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
Cc: robert.mccabe@rockwellcollins.com,
        "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>,
        McCabe@rockwellcollins.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpimr.rockwellcollins.com ([205.175.225.240]:3161 "EHLO
        secvs01.rockwellcollins.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751734AbdGDAOt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 3 Jul 2017 20:14:49 -0400
In-Reply-To: <20170704001426.9268-1-Robert.McCabe@rockwellcollins.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added the "custom" linklayer qdisc stab option.
Allows the user to specify the pkt size translation
parameters from stdin.
Example:
   tc qdisc add ... stab tsize 8 linklayer custom htb
      Custom size table:
      InputSizeStart -> IntputSizeEnd: OutputSize
      0              -> 511          : 600
      512            -> 1023         : 1200
      1024           -> 1535         : 1800
      1536           -> 2047         : 2400
      2048           -> 2559         : 3000

blah

Signed-off-by: McCabe, Robert J <Robert.McCabe@rockwellcollins.com>
---
 include/linux/pkt_sched.h |  1 +
 tc/tc_core.c              | 46 ++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_core.h              |  2 +-
 tc/tc_stab.c              | 20 +++++++++-----------
 tc/tc_util.c              |  5 +++++
 5 files changed, 62 insertions(+), 12 deletions(-)

diff --git a/include/linux/pkt_sched.h b/include/linux/pkt_sched.h
index 099bf55..289bb81 100644
--- a/include/linux/pkt_sched.h
+++ b/include/linux/pkt_sched.h
@@ -82,6 +82,7 @@ enum tc_link_layer {
 	TC_LINKLAYER_UNAWARE, /* Indicate unaware old iproute2 util */
 	TC_LINKLAYER_ETHERNET,
 	TC_LINKLAYER_ATM,
+	TC_LINKLAYER_CUSTOM,
 };
 #define TC_LINKLAYER_MASK 0x0F /* limit use to lower 4 bits */
 
diff --git a/tc/tc_core.c b/tc/tc_core.c
index 821b741..167f4d7 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -21,6 +21,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <assert.h>
 
 #include "tc_core.h"
 #include <linux/atm.h>
@@ -28,6 +29,13 @@
 static double tick_in_usec = 1;
 static double clock_factor = 1;
 
+struct size_table_entry {
+	unsigned int input_size_boundary_start;
+	unsigned int output_size_bytes;
+};
+
+static struct size_table_entry* custom_size_table = NULL;
+static int num_size_table_entries = 0;
 int tc_core_time2big(unsigned int time)
 {
 	__u64 t = time;
@@ -89,6 +97,20 @@ static unsigned int tc_align_to_atm(unsigned int size)
 	return linksize;
 }
 
+static unsigned int tc_align_to_custom(unsigned int size)
+{
+	int i;
+
+	assert(custom_size_table != NULL);
+	for(i = num_size_table_entries -1; i >= 0 ; --i) {
+		if(custom_size_table[i].input_size_boundary_start < size) {
+			/* found it */
+			return custom_size_table[i].output_size_bytes;
+		}
+	}
+	return 0;
+}
+
 static unsigned int tc_adjust_size(unsigned int sz, unsigned int mpu, enum link_layer linklayer)
 {
 	if (sz < mpu)
@@ -97,6 +119,8 @@ static unsigned int tc_adjust_size(unsigned int sz, unsigned int mpu, enum link_
 	switch (linklayer) {
 	case LINKLAYER_ATM:
 		return tc_align_to_atm(sz);
+	case LINKLAYER_CUSTOM:
+		return tc_align_to_custom(sz);
 	case LINKLAYER_ETHERNET:
 	default:
 		/* No size adjustments on Ethernet */
@@ -185,6 +209,24 @@ int tc_calc_size_table(struct tc_sizespec *s, __u16 **stab)
 	if (!*stab)
 		return -1;
 
+	if(LINKLAYER_CUSTOM == linklayer) {
+		 custom_size_table = malloc(sizeof(struct size_table_entry)* s->tsize);
+		 if(!custom_size_table)
+			  return -1;
+		 num_size_table_entries = s->tsize;
+
+		 printf("Custom size table:\n");
+		 printf("InputSizeStart -> IntputSizeEnd: OutputSize\n");
+		 for(i = 0; i <= s->tsize - 1; ++i) {
+			  printf("%-14d -> %-13d: ", i << s->cell_log, ((i+1) << s->cell_log) - 1);
+			  if(!scanf("%u", &custom_size_table[i].output_size_bytes)) {
+					fprintf(stderr, "Invalid custom stab table entry!\n");
+					return -1;
+			  }
+			  custom_size_table[i].input_size_boundary_start = i << s->cell_log;
+		 }
+	}
+
 again:
 	for (i = s->tsize - 1; i >= 0; i--) {
 		sz = tc_adjust_size((i + 1) << s->cell_log, s->mpu, linklayer);
@@ -196,6 +238,10 @@ again:
 	}
 
 	s->cell_align = -1; /* Due to the sz calc */
+	if(custom_size_table) {
+		 free(custom_size_table);
+		 num_size_table_entries = 0;
+	}
 	return 0;
 }
 
diff --git a/tc/tc_core.h b/tc/tc_core.h
index 8a63b79..8e97222 100644
--- a/tc/tc_core.h
+++ b/tc/tc_core.h
@@ -10,9 +10,9 @@ enum link_layer {
 	LINKLAYER_UNSPEC,
 	LINKLAYER_ETHERNET,
 	LINKLAYER_ATM,
+	LINKLAYER_CUSTOM,
 };
 
-
 int  tc_core_time2big(unsigned time);
 unsigned tc_core_time2tick(unsigned time);
 unsigned tc_core_tick2time(unsigned tick);
diff --git a/tc/tc_stab.c b/tc/tc_stab.c
index 1a0a3e3..a468a70 100644
--- a/tc/tc_stab.c
+++ b/tc/tc_stab.c
@@ -37,7 +37,9 @@ static void stab_help(void)
 		"   tsize     : how many slots should size table have {512}\n"
 		"   mpu       : minimum packet size used in rate computations\n"
 		"   overhead  : per-packet size overhead used in rate computations\n"
-		"   linklayer : adapting to a linklayer e.g. atm\n"
+		"   linklayer : adapting to a linklayer e.g. ethernet, atm or custom\n"
+		"               a \"custom\" linklayer reads size table entries from\n"
+		"               stdin\n"
 		"Example: ... stab overhead 20 linklayer atm\n");
 
 }
@@ -107,13 +109,13 @@ int parse_size_table(int *argcp, char ***argvp, struct tc_sizespec *sp)
 void print_size_table(FILE *fp, const char *prefix, struct rtattr *rta)
 {
 	struct rtattr *tb[TCA_STAB_MAX + 1];
+	struct tc_sizespec s = {0};
 
 	SPRINT_BUF(b1);
 
 	parse_rtattr_nested(tb, TCA_STAB_MAX, rta);
 
 	if (tb[TCA_STAB_BASE]) {
-		struct tc_sizespec s = {0};
 
 		memcpy(&s, RTA_DATA(tb[TCA_STAB_BASE]),
 				MIN(RTA_PAYLOAD(tb[TCA_STAB_BASE]), sizeof(s)));
@@ -132,19 +134,15 @@ void print_size_table(FILE *fp, const char *prefix, struct rtattr *rta)
 			fprintf(fp, "tsize %u ", s.tsize);
 	}
 
-#if 0
 	if (tb[TCA_STAB_DATA]) {
 		unsigned int i, j, dlen;
 		__u16 *data = RTA_DATA(tb[TCA_STAB_DATA]);
 
-		dlen = RTA_PAYLOAD(tb[TCA_STAB_DATA]) / sizeof(__u16);
-
 		fprintf(fp, "\n%sstab data:", prefix);
-		for (i = 0; i < dlen/12; i++) {
-			fprintf(fp, "\n%s %3u:", prefix, i * 12);
-			for (j = 0; i * 12 + j < dlen; j++)
-				fprintf(fp, " %05x", data[i * 12 + j]);
-		}
+		 fprintf(fp, "\n%sInputSizeStart -> IntputSizeEnd: Output Size\n", prefix);
+		 for(i = 0; i <= s.tsize - 1; ++i) {
+			  fprintf(fp, "%s%-14d -> %-13d: %d\n", prefix,  i << s.cell_log,
+						 ((i+1) << s.cell_log) - 1, data[i]);
+		 }
 	}
-#endif
 }
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 3710468..62019c1 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -651,6 +651,8 @@ int get_linklayer(unsigned int *val, const char *arg)
 		res = LINKLAYER_ATM;
 	else if (matches(arg, "adsl") == 0)
 		res = LINKLAYER_ATM;
+	else if (matches(arg, "custom") == 0)
+		res = LINKLAYER_CUSTOM;
 	else
 		return -1; /* Indicate error */
 
@@ -670,6 +672,9 @@ void print_linklayer(char *buf, int len, unsigned int linklayer)
 	case LINKLAYER_ATM:
 		snprintf(buf, len, "%s", "atm");
 		return;
+	case LINKLAYER_CUSTOM:
+		snprintf(buf, len, "%s", "custom");
+		return;
 	default:
 		snprintf(buf, len, "%s", "unknown");
 		return;
-- 
2.7.4

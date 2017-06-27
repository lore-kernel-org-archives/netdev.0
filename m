From: "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>
Subject: [PATCH 1/1] tc: custom qdisc pkt size translation table
Date: Tue, 27 Jun 2017 11:29:17 -0500
Message-ID: <20170627162917.20244-1-Robert.McCabe@rockwellcollins.com>
Cc: robert.mccabe@rockwellcollins.com,
        "McCabe, Robert J" <Robert.McCabe@rockwellcollins.com>,
        McCabe@rockwellcollins.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from secvs01.rockwellcollins.com ([205.175.225.240]:63734 "EHLO
        secvs01.rockwellcollins.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751492AbdF0QjB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Jun 2017 12:39:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added the "custom" linklayer qdisc stab option.
This allows the user to specify the pkt size translation
parameters from stdin.
Example:
   tc qdisc add ... stab tsize 8 linklayer custom htb
   Custom size table:
   InputSizeStart -> IntputSizeEnd: Output Pkt Size
   0 - 255: 400
   256 - 511: 800
   512 - 767: 1200
   768 - 1023: 1600
   1024 - 1279: 2000
   1280 - 1535: 2400
   1536 - 1791: 2800
   1792 - 2047: 3200

Signed-off-by: McCabe, Robert J <Robert.McCabe@rockwellcollins.com>
---
 include/linux/pkt_sched.h |  1 +
 tc/tc_core.c              | 51 +++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_core.h              |  2 +-
 tc/tc_stab.c              |  4 +++-
 tc/tc_util.c              |  5 +++++
 5 files changed, 61 insertions(+), 2 deletions(-)

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
index 821b741..fb04704 100644
--- a/tc/tc_core.c
+++ b/tc/tc_core.c
@@ -21,6 +21,7 @@
 #include <netinet/in.h>
 #include <arpa/inet.h>
 #include <string.h>
+#include <assert.h>
 
 #include "tc_core.h"
 #include <linux/atm.h>
@@ -28,6 +29,16 @@
 static double tick_in_usec = 1;
 static double clock_factor = 1;
 
+struct size_table_entry {
+	unsigned int input_size_boundary_start;
+	unsigned int output_size_bytes;
+};
+
+//TODO: free
+static struct size_table_entry* custom_size_table = NULL;
+static int num_size_table_entries = 0;
+
+
 int tc_core_time2big(unsigned int time)
 {
 	__u64 t = time;
@@ -89,6 +100,23 @@ static unsigned int tc_align_to_atm(unsigned int size)
 	return linksize;
 }
 
+static unsigned int tc_align_to_custom(unsigned int size)
+{
+	int i;
+
+	assert(custom_size_table != NULL);
+
+	for(i = num_size_table_entries -1; i >= 0 ; --i)
+	{
+		if(custom_size_table[i].input_size_boundary_start < size)
+		{
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
@@ -97,6 +125,8 @@ static unsigned int tc_adjust_size(unsigned int sz, unsigned int mpu, enum link_
 	switch (linklayer) {
 	case LINKLAYER_ATM:
 		return tc_align_to_atm(sz);
+	case LINKLAYER_CUSTOM:
+		return tc_align_to_custom(sz);
 	case LINKLAYER_ETHERNET:
 	default:
 		/* No size adjustments on Ethernet */
@@ -185,6 +215,27 @@ int tc_calc_size_table(struct tc_sizespec *s, __u16 **stab)
 	if (!*stab)
 		return -1;
 
+	if(LINKLAYER_CUSTOM == linklayer)
+	{
+		custom_size_table = malloc(sizeof(struct size_table_entry)* s->tsize);
+		if(!custom_size_table)
+			return -1;
+		num_size_table_entries = s->tsize;
+
+		printf("Custom size table:\n");
+		printf("InputSizeStart -> IntputSizeEnd : Output Pkt Size\n");
+		for(i = 0; i <= s->tsize - 1; ++i)
+		{
+			printf("%d - %d: ", i << s->cell_log, ((i+1) << s->cell_log) - 1);
+			if(!scanf("%u", &custom_size_table[i].output_size_bytes))
+			{
+				fprintf(stderr, "Invalid custom stab table entry!\n");
+				return -1;
+			}
+
+			custom_size_table[i].input_size_boundary_start = i << s->cell_log;
+		}
+	}
 again:
 	for (i = s->tsize - 1; i >= 0; i--) {
 		sz = tc_adjust_size((i + 1) << s->cell_log, s->mpu, linklayer);
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
index 1a0a3e3..8374c76 100644
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
diff --git a/tc/tc_util.c b/tc/tc_util.c
index 24ca1f1..3ee1098 100644
--- a/tc/tc_util.c
+++ b/tc/tc_util.c
@@ -485,6 +485,8 @@ int get_linklayer(unsigned int *val, const char *arg)
 		res = LINKLAYER_ATM;
 	else if (matches(arg, "adsl") == 0)
 		res = LINKLAYER_ATM;
+	else if (matches(arg, "custom") == 0)
+		res = LINKLAYER_CUSTOM;
 	else
 		return -1; /* Indicate error */
 
@@ -504,6 +506,9 @@ void print_linklayer(char *buf, int len, unsigned int linklayer)
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

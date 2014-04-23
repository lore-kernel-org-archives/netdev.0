From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: [PATCH 2/2] iproute2: can: support CAN FD control interface
Date: Wed, 23 Apr 2014 19:27:27 +0200
Message-ID: <1398274047-5407-3-git-send-email-socketcan@hartkopp.net>
References: <1398274047-5407-1-git-send-email-socketcan@hartkopp.net>
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	Oliver Hartkopp <socketcan@hartkopp.net>
To: stephen@networkplumber.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1398274047-5407-1-git-send-email-socketcan@hartkopp.net>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

For CAN FD a new set of bittiming configuration and enabling functions for the
data section is provided by the CAN driver infrastructure.

This patch allows to configure the newly introduced CAN FD properties.

Signed-off-by: Oliver Hartkopp <socketcan@hartkopp.net>
---
 ip/iplink_can.c | 72 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 71 insertions(+), 1 deletion(-)

diff --git a/ip/iplink_can.c b/ip/iplink_can.c
index 66e6c0e..3bef82a 100644
--- a/ip/iplink_can.c
+++ b/ip/iplink_can.c
@@ -27,11 +27,16 @@ static void usage(void)
 		"\t[ tq TQ prop-seg PROP_SEG phase-seg1 PHASE-SEG1\n "
 		"\t  phase-seg2 PHASE-SEG2 [ sjw SJW ] ]\n"
 		"\n"
+		"\t[ dbitrate BITRATE [ dsample-point SAMPLE-POINT] ] | \n"
+		"\t[ dtq TQ dprop-seg PROP_SEG dphase-seg1 PHASE-SEG1\n "
+		"\t  dphase-seg2 PHASE-SEG2 [ dsjw SJW ] ]\n"
+		"\n"
 		"\t[ loopback { on | off } ]\n"
 		"\t[ listen-only { on | off } ]\n"
 		"\t[ triple-sampling { on | off } ]\n"
 		"\t[ one-shot { on | off } ]\n"
 		"\t[ berr-reporting { on | off } ]\n"
+		"\t[ fd { on | off } ]\n"
 		"\n"
 		"\t[ restart-ms TIME-MS ]\n"
 		"\t[ restart ]\n"
@@ -88,6 +93,7 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 	_PF(CAN_CTRLMODE_3_SAMPLES, "TRIPLE-SAMPLING");
 	_PF(CAN_CTRLMODE_ONE_SHOT, "ONE-SHOT");
 	_PF(CAN_CTRLMODE_BERR_REPORTING, "BERR-REPORTING");
+	_PF(CAN_CTRLMODE_FD, "FD");
 #undef _PF
 	if (cm)
 		fprintf(f, "%x", cm);
@@ -97,10 +103,11 @@ static void print_ctrlmode(FILE *f, __u32 cm)
 static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			 struct nlmsghdr *n)
 {
-	struct can_bittiming bt;
+	struct can_bittiming bt, dbt;
 	struct can_ctrlmode cm = {0, 0};
 
 	memset(&bt, 0, sizeof(bt));
+	memset(&dbt, 0, sizeof(dbt));
 	while (argc > 0) {
 		if (matches(*argv, "bitrate") == 0) {
 			NEXT_ARG();
@@ -134,6 +141,37 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			if (get_u32(&bt.sjw, *argv, 0))
 				invarg("invalid \"sjw\" value\n", *argv);
+		} else if (matches(*argv, "dbitrate") == 0) {
+			NEXT_ARG();
+			if (get_u32(&dbt.bitrate, *argv, 0))
+				invarg("invalid \"dbitrate\" value\n", *argv);
+		} else if (matches(*argv, "dsample-point") == 0) {
+			float sp;
+
+			NEXT_ARG();
+			if (get_float(&sp, *argv))
+				invarg("invalid \"dsample-point\" value\n", *argv);
+			dbt.sample_point = (__u32)(sp * 1000);
+		} else if (matches(*argv, "dtq") == 0) {
+			NEXT_ARG();
+			if (get_u32(&dbt.tq, *argv, 0))
+				invarg("invalid \"dtq\" value\n", *argv);
+		} else if (matches(*argv, "dprop-seg") == 0) {
+			NEXT_ARG();
+			if (get_u32(&dbt.prop_seg, *argv, 0))
+				invarg("invalid \"dprop-seg\" value\n", *argv);
+		} else if (matches(*argv, "dphase-seg1") == 0) {
+			NEXT_ARG();
+			if (get_u32(&dbt.phase_seg1, *argv, 0))
+				invarg("invalid \"dphase-seg1\" value\n", *argv);
+		} else if (matches(*argv, "dphase-seg2") == 0) {
+			NEXT_ARG();
+			if (get_u32(&dbt.phase_seg2, *argv, 0))
+				invarg("invalid \"dphase-seg2\" value\n", *argv);
+		} else if (matches(*argv, "dsjw") == 0) {
+			NEXT_ARG();
+			if (get_u32(&dbt.sjw, *argv, 0))
+				invarg("invalid \"dsjw\" value\n", *argv);
 		} else if (matches(*argv, "loopback") == 0) {
 			NEXT_ARG();
 			set_ctrlmode("loopback", *argv, &cm,
@@ -154,6 +192,10 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 			NEXT_ARG();
 			set_ctrlmode("berr-reporting", *argv, &cm,
 				     CAN_CTRLMODE_BERR_REPORTING);
+		} else if (matches(*argv, "fd") == 0) {
+			NEXT_ARG();
+			set_ctrlmode("fd", *argv, &cm,
+				     CAN_CTRLMODE_FD);
 		} else if (matches(*argv, "restart") == 0) {
 			__u32 val = 1;
 
@@ -178,6 +220,8 @@ static int can_parse_opt(struct link_util *lu, int argc, char **argv,
 
 	if (bt.bitrate || bt.tq)
 		addattr_l(n, 1024, IFLA_CAN_BITTIMING, &bt, sizeof(bt));
+	if (dbt.bitrate || dbt.tq)
+		addattr_l(n, 1024, IFLA_CAN_DATA_BITTIMING, &dbt, sizeof(dbt));
 	if (cm.mask)
 		addattr_l(n, 1024, IFLA_CAN_CTRLMODE, &cm, sizeof(cm));
 
@@ -249,6 +293,32 @@ static void can_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 			btc->brp_min, btc->brp_max, btc->brp_inc);
 	}
 
+	if (tb[IFLA_CAN_DATA_BITTIMING]) {
+		struct can_bittiming *dbt =
+			RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING]);
+
+		fprintf(f, "\n	  "
+			"dbitrate %d dsample-point %.3f ",
+			dbt->bitrate, (float)dbt->sample_point / 1000.);
+		fprintf(f, "\n	  "
+			"dtq %d dprop-seg %d dphase-seg1 %d "
+			"dphase-seg2 %d dsjw %d",
+			dbt->tq, dbt->prop_seg, dbt->phase_seg1,
+			dbt->phase_seg2, dbt->sjw);
+	}
+
+	if (tb[IFLA_CAN_DATA_BITTIMING_CONST]) {
+		struct can_bittiming_const *dbtc =
+			RTA_DATA(tb[IFLA_CAN_DATA_BITTIMING_CONST]);
+
+		fprintf(f, "\n	  "
+			"%s: dtseg1 %d..%d dtseg2 %d..%d "
+			"dsjw 1..%d dbrp %d..%d dbrp-inc %d",
+			dbtc->name, dbtc->tseg1_min, dbtc->tseg1_max,
+			dbtc->tseg2_min, dbtc->tseg2_max, dbtc->sjw_max,
+			dbtc->brp_min, dbtc->brp_max, dbtc->brp_inc);
+	}
+
 	if (tb[IFLA_CAN_CLOCK]) {
 		struct can_clock *clock = RTA_DATA(tb[IFLA_CAN_CLOCK]);
 
-- 
1.9.2

